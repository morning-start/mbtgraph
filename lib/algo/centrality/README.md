# 中心性分析 (`centrality`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 72 通过

提供图节点重要性量化分析能力，包含 **7 种**中心性算法：
- **度中心性** — 直接邻居计数 O(V+E)，最简单直观
- **介数中心性** — Brandes 算法 O(VE)，衡量最短路径中介作用
- **接近中心性** — BFS 最短路径 O(V(V+E))，衡量全局可达效率
- **特征向量中心性** — 幂迭代法 O(kE)，衡量邻居影响力传递
- **Katz 中心性** — 衰减路径计数 O(kE)，引入外部偏置
- **Harmonic 中心性** — 不连通图友好变体 O(V(V+E))
- **通信能力 / 集团中心性** — 网络鲁棒性分析

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | GraphReadable trait、NodeId 等基础类型 |
| `@storage` (测试) | DirectedAdjList 测试构建 |

## 文件结构

```
lib/algo/centrality/
├── moon.pkg                    # 包配置
├── types.mbt                   # CentralityResult + DegreeMode 类型定义
├── degree_centrality.mbt       # 度中心性 (In/Out/Total 三模式)
├── betweenness_centrality.mbt  # 介数中心性 (Brandes 算法)
├── closeness_centrality.mbt    # 接近中心性 (BFS 最短路径)
├── eigenvector_centrality.mbt  # 特征向量中心性 (幂迭代)
├── katz_harmonic.mbt           # Katz + Harmonic + 通信能力 + 集团中心性
└── centrality_test.mbt         # 完整测试套件 (72 tests)
```

## API 总览

### 核心类型 ([types.mbt](types.mbt))

#### `DegreeMode` — 度中心性计算模式

```moonbit
pub(all) enum DegreeMode {
  In      // 入度（仅对有向图有意义）
  Out     // 出度（仅对有向图有意义）
  Total   // 总度 = 入度 + 出度（有向图）或度数（无向图）
}
```

#### `CentralityResult` — 通用中心性结果

所有核心中心性算法共享此结果结构：

```moonbit
pub(all) struct CentralityResult {
  scores : Array[Double]    // 节点中心性得分数组，索引对应 NodeId
  normalized : Bool         // 是否已归一化到 [0, 1] 范围
} derive(Debug)
```

**内置方法**:

| 方法 | 说明 | 返回 |
|------|------|------|
| `get_score(node_id)` | 获取指定节点的中心性得分 | `Double?` (越界返回 None) |
| `max_node()` | 获取得分最高的节点及其分数 | `(NodeId, Double)?` |
| `nonzero_count()` | 获取所有非零得分的节点数量 | `Int` |

#### `CommunicationResult` — 通信能力结果 ([katz_harmonic.mbt](katz_harmonic.mbt))

```moonbit
pub(all) struct CommunicationResult {
  scores : Array[Double]    // 节点通信能力得分
} derive(Debug)

// 方法: get_score(node_id) -> Double?
```

### 度中心性 ([degree_centrality.mbt](degree_centrality.mbt))

**直接邻居计数** — 最直观的中心性度量，时间复杂度 O(V+E)。

| 函数 | 说明 | 返回 |
|------|------|------|
| `degree_centrality(graph, mode)` | 计算所有节点的度中心性 | `CentralityResult` |

**参数说明**:
- `mode`: `DegreeMode::In`（入度）/ `DegreeMode::Out`（出度）/ `DegreeMode::Total`（总度）

**特性**:
- 自动归一化到 [0, 1]：`score(v) = degree(v) / (n - 1)`
- 无向图下 In/Out 模式等价于 Total
- 单节点图返回 0.0（无其他节点可连接）

### 介数中心性 ([betweenness_centrality.mbt](betweenness_centrality.mbt))

**Brandes 算法** — 衡量节点在最短路径中的中介作用，时间复杂度 O(VE)。

| 函数 | 说明 | 返回 |
|------|------|------|
| `betweenness_centrality(graph, normalized)` | 计算所有节点的介数中心性 | `CentralityResult` |

**参数说明**:
- `normalized`: 是否归一化（有向: `/((n-1)(n-2))`, 无向: `/2(n-1)(n-2))`）

**算法流程**:
1. 初始化 betweenness 数组为全零
2. 对每个节点 s 执行单源 BFS:
   - 计算最短路径数 sigma[v] 和前驱列表 pred[v]
   - 回溯计算依赖值 delta[v]
   - 累加到 betweenness[w]（w ≠ s）
3. 可选归一化处理

**特性**:
- 完全图所有节点介数为 0（存在直达路径，无需中介）
- 路径端点介数为 0（不作为任何路径的中介）
- 桥接节点获得最高分

### 接近中心性 ([closeness_centrality.mbt](closeness_centrality.mbt))

**BFS 最短路径** — 衡量节点到其他所有节点的平均距离倒数，时间复杂度 O(V(V+E))。

| 函数 | 说明 | 返回 |
|------|------|------|
| `closeness_centrality(graph, normalized)` | 计算所有节点的接近中心性 | `CentralityResult` |

**公式**:
```
C(v) = (reachable_count) / Σ dist(v, u)        // 原始值
C_norm(v) = C(v) / (n - 1)                      // 归一化后
```

**特性**:
- 不连通图中不可达节点不计入 sum_dist（避免无穷大）
- 中心节点得分最高，边缘节点得分最低
- 完全图所有节点得分相同

### 特征向量中心性 ([eigenvector_centrality.mbt](eigenvector_centrality.mbt))

**幂迭代法** — 衡量节点通过邻居网络的影响力传递，时间复杂度 O(kE)（k 为迭代次数）。

| 函数 | 说明 | 返回 |
|------|------|------|
| `eigenvector_centrality(graph, max_iterations, tolerance)` | 计算特征向量中心性 | `CentralityResult` |

**参数说明**:
- `max_iterations`: 最大迭代次数（建议 100-1000）
- `tolerance`: 收敛阈值（建议 1e-6）

**算法流程**:
1. 初始化所有节点得分为 1/n
2. 构建入边邻接表（反转邻接关系）
3. 迭代: `new_scores[v] = Σ scores[u]` （对所有入边 u→v）
4. L2 归一化: `scores = scores / ‖scores‖₂`
5. 检查收敛: `max|new - old| < tolerance`
6. 未收敛则继续迭代

**特性**:
- 高分节点的邻居也倾向于高分（递归影响）
- 星形图中心节点得分最高
- 完全图所有节点得分相同
- 自带 L2 归一化（normalized=true）

### Katz 中心性 ([katz_harmonic.mbt](katz_harmonic.mbt))

**衰减路径计数** — 在特征向量基础上加入外部偏置项 β，时间复杂度 O(kE)。

| 函数 | 说明 | 返回 |
|------|------|------|
| `katz_centrality(graph, alpha, beta, max_iterations, tolerance)` | 计算 Katz 中心性 | `CentralityResult` |

**公式**: `x = α · Aᵀ · x + β`

**参数说明**:
- `alpha`: 衰减因子（建议 0.01-0.2，必须 < 1/λ_max）
- `beta`: 外部偏置（建议 1.0，α=0 时所有节点得分=β）
- `max_iterations`: 最大迭代次数
- `tolerance`: 收敛阈值

**特性**:
- α=0 时退化为常数函数（所有节点得分 = β）
- β 控制基线得分，即使孤立节点也有非零值
- 默认不归一化（normalized=false）

### Harmonic 中心性 ([katz_harmonic.mbt](katz_harmonic.mbt))

**不连通图友好变体** — 接近中心性的改进版，时间复杂度 O(V(V+E))。

| 函数 | 说明 | 返回 |
|------|------|------|
| `harmonic_centrality(graph, normalized)` | 计算 Harmonic 中心性 | `CentralityResult` |

**公式**: `H(v) = Σ_{u≠v} 1 / dist(v, u)`

**vs 接近中心性对比**:

| 特性 | Closeness | Harmonic |
|------|-----------|----------|
| 不连通图处理 | 不可达节点忽略 | 不可达贡献为 0 |
| 分母定义 | 总和距离 | 倒数求和 |
| 适用场景 | 强连通图 | 一般图（推荐） |

### 通信能力中心性 ([katz_harmonic.mbt](katz_harmonic.mbt))

**网络鲁棒性度量** — 衡量移除某节点后对网络效率的影响，时间复杂度 O(V²(V+E))。

| 函数 | 说明 | 返回 |
|------|------|------|
| `communication_centrality(graph)` | 计算通信能力中心性 | `CommunicationResult` |

**公式**: `C(v) = 1 - E(G\{v}) / E(G)`

其中网络效率 `E(G) = average(1/dist(i,j))` 对所有可达节点对。

### 集团中心性 ([katz_harmonic.mbt](katz_harmonic.mbt))

**节点集合的重要性度量** — 衡量经过指定节点集合的最短路径比例。

| 函数 | 说明 | 返回 |
|------|------|------|
| `group_betweenness_centrality(graph, group)` | 计算集团介数中心性 | `Double` |

**参数说明**:
- `group`: 目标节点集合（Array[NodeId]）

**特性**:
- 空集合返回 0.0
- 完全图中任意集合返回 0.0（无需中介）
- 桥接节点集合得分最高

## 使用示例

### 基础用法：星形图的多维分析

```moonbit
// 构建星形图: 0 是中心，1-4 是叶子
let g = @storage.new_directed()
let mut i = 0
while i < 5 {
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  i = i + 1
}
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(0), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(0), 1.0) |> ignore

// 度中心性: 中心节点入度最高
let dc = degree_centrality(g, DegreeMode::In)
match dc.get_score(@core.NodeId(0)) {
  Some(s) => println("中心节点度中心性: ${s}")  // => 1.0 (4/4)
  None => ()
}

// 介数中心性: 所有路径经过中心
let bc = betweenness_centrality(g, true)
match bc.max_node() {
  Some((id, score)) => println("最高介数节点: ${id.0}, 得分: ${score}")
  None => ()
}

// 特征向量中心性: 中心节点继承所有叶子影响力
let ec = eigenvector_centrality(g, 100, 1.0e-6)
match ec.max_node() {
  Some((id, _)) => assert_eq(id.0, 0)  // 确认中心节点最高
  None => ()
}
```

### 多算法对比：路径图 vs 完全图

```moonbit
// === 路径图: 0 → 1 → 2 → 3 ===
let path = @storage.new_directed()
let mut i = 0
while i < 4 {
  @core.GraphWritable::add_node(path, 0.0) |> ignore
  i = i + 1
}
@core.GraphWritable::add_edge(path, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(path, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
@core.GraphWritable::add_edge(path, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore

let dc_path = degree_centrality(path, DegreeMode::Out)
let bc_path = betweenness_centrality(path, true)
let cc_path = closeness_centrality(path, true)

// 路径图特点:
// - 度中心性: 端点低 (0/1/1/0 归一化后)
// - 介数中心性: 中间节点高 (节点 1,2 是必经之路)
// - 接近中心性: 中间节点高 (平均距离短)

// === 完全图 K4: 所有两两相连 ===
let complete = @storage.new_directed()
let mut i = 0
while i < 4 {
  @core.GraphWritable::add_node(complete, 0.0) |> ignore
  i = i + 1
}
let mut a = 0
while a < 4 {
  let mut b = 0
  while b < 4 {
    if a != b {
      @core.GraphWritable::add_edge(complete, @core.NodeId(a), @core.NodeId(b), 1.0) |> ignore
    }
    b = b + 1
  }
  a = a + 1
}

let dc_complete = degree_centrality(complete, DegreeMode::Out)
let bc_complete = betweenness_centrality(complete, true)

// 完全图特点:
// - 度中心性: 所有节点相等 (3/3 = 1.0)
// - 介数中心性: 全部为 0 (直达路径无需中介)
for s in dc_complete.scores {
  assert_true(approx_eq(s, 1.0, 0.000001))  // 全部满分
}
```

### 边界情况处理

```moonbit
// === 空图 ===
let empty = @storage.new_directed()
let dc_empty = degree_centrality(empty, DegreeMode::Total)
assert_eq(dc_empty.scores.length(), 0)  // 空数组

let bc_empty = betweenness_centrality(empty, true)
assert_eq(bc_empty.scores.length(), 0)

let ec_empty = eigenvector_centrality(empty, 100, 1.0e-6)
assert_eq(ec_empty.scores.length(), 0)

// === 单节点图 ===
let single = @storage.new_directed()
@core.GraphWritable::add_node(single, 0.0) |> ignore

let dc_single = degree_centrality(single, DegreeMode::Total)
match dc_single.get_score(@core.NodeId(0)) {
  Some(s) => assert_true(approx_eq(s, 0.0, 1e-6))  // 无邻居，得分为 0
  None => ()
}

let ec_single = eigenvector_centrality(single, 100, 1.0e-6)
match ec_single.get_score(@core.NodeId(0)) {
  Some(s) => assert_true(approx_eq(s, 1.0, 1e-6))  // 单节点归一化为 1
  None => ()
}

// === 不连通图 ===
let disconnected = @storage.new_directed()
let mut i = 0
while i < 4 {
  @core.GraphWritable::add_node(disconnected, 0.0) |> ignore
  i = i + 1
}
@core.GraphWritable::add_edge(disconnected, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(disconnected, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore

// Harmonic 中心性对不连通图友好（不可达贡献为 0）
let hc = harmonic_centrality(disconnected, true)
match hc.get_score(@core.NodeId(0)) {
  Some(s) => assert_true(s > 0.0)  // 可达节点 1 有正贡献
  None => ()
}
match hc.get_score(@core.NodeId(2)) {
  Some(s) => assert_true(s > 0.0)  // 可达节点 3 有正贡献
  None => ()
}
```

### Katz 与 Harmonic 高级用法

```moonbit
let g = make_central_star()

// Katz 中心性: alpha 控制衰减速度
let katz_small = katz_centrality(g, 0.05, 1.0, 100, 1.0e-6)  // 弱衰减
let katz_large = katz_centrality(g, 0.2, 1.0, 100, 1.0e-6)   // 强衰减

// alpha=0 时退化为常数
let katz_zero = katz_centrality(g, 0.0, 2.0, 10, 1.0e-6)
for s in katz_zero.scores {
  assert_true(approx_eq(s, 2.0, 0.01))  // 全部等于 beta
}

// 通信能力: 找出关键节点
let comm = communication_centrality(g)
match comm.get_score(@core.NodeId(0)) {
  Some(s) => println("移除中心节点后的效率损失: ${s}")
  None => ()
}

// 集团中心性: 分析多个节点的联合重要性
let group_score = group_betweenness_centrality(g, [@core.NodeId(0), @core.NodeId(1)])
println("集团 {0,1} 的介数中心性: ${group_score}")
```

## 算法原理

### 中心性分类体系

本模块实现的 7 种中心性算法覆盖了三大类度量维度：

```
┌─────────────────────────────────────────────────────┐
│                  中心性度量分类                       │
├─────────────┬───────────────┬───────────────────────┤
│  局部度量   │   全局度量    │     迭代度量           │
├─────────────┼───────────────┼───────────────────────┤
│  度中心性   │  介数中心性   │  特征向量中心性        │
│  (O(V+E))   │  (O(VE))     │  (O(kE))              │
│             │               │                       │
│             │  接近中心性   │  Katz 中心性          │
│             │  (O(V(V+E))) │  (O(kE))              │
│             │               │                       │
│             │  Harmonic     │                       │
│             │  (O(V(V+E))) │                       │
└─────────────┴───────────────┴───────────────────────┘
```

### 核心概念解释

**度中心性 (Degree Centrality)**:
- 最简单的中心性度量：「朋友越多越重要」
- 有向图区分入度（被连接）和出度（主动连接）
- 局限：只考虑直接邻居，忽略间接影响

**介数中心性 (Betweenness Centrality)**:
- Brandes (2001) 的经典算法，将复杂度从 O(V³) 降至 O(VE)
- 核心思想：统计经过该节点的最短路径比例
- 应用场景：社交网络中的「信息桥梁」、交通网络的瓶颈检测
- 公式：`C_B(v) = Σ_{s≠v≠t} σ_st(v) / σ_st`，其中 σ_st 是 s-t 最短路径总数，σ_st(v) 是经过 v 的数量

**接近中心性 (Closeness Centrality)**:
- 衡量节点到达其他所有节点的效率
- 核心思想：「离所有人都近的节点更重要」
- 局限：不连通图中需要特殊处理（本实现忽略不可达节点）

**特征向量中心性 (Eigenvector Centrality)**:
- PageRank 的简化原型
- 核心思想：「连接到重要节点的人更重要」（递归定义）
- 数学本质：邻接矩阵最大特征值对应的特征向量
- 收敛条件：图必须强连通或含唯一最大特征值

**Katz 中心性**:
- 解决特征向量中心性的「零值问题」（孤立节点得分=0）
- 引入衰减因子 α 和偏置项 β
- α 控制「远距离影响的衰减程度」，β 保证非零基线

**Harmonic 中心性**:
- 接近中心性的改进，对不连通图更友好
- 不可达节点贡献 0 而非导致未定义

### 时间复杂度总览

| 算法 | 复杂度 | 空间 | 归一化 |
|------|--------|------|:------:|
| 度中心性 | O(V+E) | O(V) | ✅ |
| 介数中心性 | O(VE) | O(V²) | 可选 |
| 接近中心性 | O(V(V+E)) | O(V) | 可选 |
| 特征向量 | O(kE) | O(V+E) | ✅ (L2) |
| Katz | O(kE) | O(V+E) | ❌ |
| Harmonic | O(V(V+E)) | O(V) | 可选 |
| 通信能力 | O(V²(V+E)) | O(V) | N/A |
| 集团介数 | O(|g|·V²) | O(V) | N/A |

> 注: k 为迭代次数（通常 50-200），|g| 为集团大小

## 内部组件

### 度中心性内部组件

| 函数 | 功能 |
|------|------|
| `count_in_neighbors_dc()` | 统计目标节点的入边数量（遍历边集）|

### 介数中心性内部组件

| 函数 | 功能 |
|------|------|
| `brandes_accumulate()` | Brandes 单源 BFS + 依赖累积（核心）|
| `get_neighbor_list_br()` | 获取节点的邻居索引列表 |

### 接近中心性内部组件

| 函数 | 功能 |
|------|------|
| `bfs_distances_cl()` | 单源 BFS 计算到所有节点的最短距离 |
| `get_neighbor_list_cl()` | 获取节点的邻居索引列表 |

### 特征向量中心性内部组件

| 函数 | 功能 |
|------|------|
| `build_eigenvector_adjacency_ev()` | 构建入边邻接表（反转方向）|
| `eigenvector_iterate_ev()` | 单次幂迭代：new[v] = Σ old[u] for u∈in_neighbors(v) |
| `normalize_vector_ev()` | L2 归一化向量 |
| `max_diff_eigen_ev()` | 计算两个向量的最大分量差（收敛判据）|
| `sqrt_double_ev()` | 手动实现平方根（牛顿迭代）|

### Katz/Harmonic 内部组件

| 函数 | 功能 |
|------|------|
| `build_katz_adjacency()` | 构建 Katz 入边邻接表 |
| `katz_iterate()` | 单次 Katz 迭代：x = β + α·Aᵀ·x |
| `harmonic_bfs()` | 单源 BFS 用于 Harmonic 距离计算 |
| `compute_network_efficiency()` | 计算网络全局效率 E(G) |
| `all_pairs_bfs_comm()` | 带排除节点的单源 BFS（通信能力）|
| `group_bfs_to_target()` | BFS 到目标节点（支持阻塞集合）|

## 边界行为

| 条件 | 度中心性 | 介数中心性 | 接近中心性 | 特征向量 | Katz | Harmonic | 通信能力 | 集团介数 |
|------|:--------:|:----------:|:----------:|:--------:|:----:|:--------:|:--------:|:--------:|
| **空图 (n=0)** | scores=[] | scores=[] | scores=[] | scores=[] | scores=[] | scores=[] | scores=[] | 0.0 |
| **单节点 (n=1)** | [0.0] | [0.0] | [0.0] | [1.0] | [β] | [0.0] | [0.0] | 0.0 |
| **双节点 (n=2)** | 正常计算 | [0.0, 0.0]¹ | [0.0, 0.0]² | 正常 | 正常 | 正常 | [0.0, 0.0] | 0.0 |
| **完全图 Kn** | 全部 1.0 | 全部 0.0 | 全部相等 | 全部相等 | 全部相等 | 全部相等 | 低分 | 0.0 |
| **星形图** | 中心=1.0 | 中心最高 | 中心最高 | 中心最高 | 中心最高 | 中心最高 | 中心最高 | 中心={0} 最高 |
| **不连通图** | 各分量独立 | 正常³ | 不可达忽略⁴ | 可能不收敛⁵ | 正常 | 不可达=0⁶ | 正常 | 正常 |
| **孤立节点** | 0.0 | 0.0 | 0.0 | ~0.0 | ≈β | 0.0 | 0.0 | — |

> **注**:
> 1. n≤2 时介数定义为 0（无可中介的路径对）
> 2. n≤1 时接近性定义为 0；n=2 时取决于是否连通
> 3. 介数对各连通分量分别计算
> 4. 不可达节点不计入距离总和（避免无穷大）
> 5. 不连通图可能收敛到与初始值相关的局部解
> 6. 不可达节点对贡献 0（而非导致未定义）

## 测试覆盖

| 类别 | 度 | 介数 | 接近 | 特征向量 | Katz | Harmonic | 通信 | 集团 | 集成 | 合计 |
|------|:--:|:----:|:----:|:--------:|:----:|:--------:|:----:|:----:|:----:|:----:|
| 基础功能 | 4 | 5 | 4 | 4 | 3 | 3 | 2 | 3 | 3 | 31 |
| 边界情况 | 2 | 3 | 2 | 2 | 2 | 2 | 3 | 1 | 2 | 19 |
| 属性验证 | 2 | 4 | 4 | 4 | 3 | 3 | 1 | 1 | — | 22 |
| **合计** | **8** | **12** | **10** | **10** | **8** | **8** | **6** | **5** | **5** | **72** |

**测试分布详情**:

| 算法 | 测试名称 |
|------|---------|
| 度中心性 (8) | star_center_highest, out_mode, total_mode, complete_uniform, empty_graph, single_node, normalized_range, max_node_method |
| 介数中心性 (12) | bridge_node_highest, endpoints_zero, complete_zero, star_center_max, path_middle_higher, symmetric_property, empty_graph, two_nodes, normalized_range, nonzero_count, immutability, triangle_fair |
| 接近中心性 (10) | center_highest, path_ends_lower, complete_uniform, disconnected_low, single_node, empty_graph, normalized_range, positive_reachable, immutability, star_vs_path |
| 特征向量 (10) | converges, hub_highest, complete_uniform, empty_graph, single_node, non_negative, immutability, iterate_reasonable, path_ordering, normalized_flag |
| Katz (8) | star_center_highest, complete_uniform, empty_graph, single_node, path_all_non_negative, alpha_zero_equals_beta, immutability, non_negative |
| Harmonic (8) | center_highest, path_nodes_non_negative, complete_uniform, disconnected_nonzero, empty_graph, single_node, immutability, normalized_range |
| 通信能力 (6) | path_non_negative, empty_graph, single_node, two_nodes, bridge_non_negative, immutability |
| 集团介数 (5) | center_highest, empty_group, complete_any_group, bridge_group, immutability |
| 集成对比 (5) | all_on_star, degree_betweenness_correlation, all_handle_empty, all_handle_single, consistent_lengths |

运行命令:
```bash
moon test lib/algo/centrality  # 72 tests all pass
```

## 设计决策

### 为什么选择这 7 种中心性算法？

本模块的选择基于**覆盖完整度量维度**的原则：

| 维度 | 选择算法 | 理由 |
|------|---------|------|
| **局部 vs 全局** | 度(局部) + 介数/接近(全局) | 从简单到复杂的梯度 |
| **路径型 vs 迭代型** | 介数/接近(精确) + 特征向量/Katz(近似) | 不同精度需求 |
| **连通性敏感** | 接近 + Harmonic | 成对出现，互补使用 |
| **应用导向** | 通信能力 + 集团介数 | 网络鲁棒性和团队分析 |

### 为什么使用 Trait 泛型接口？

所有核心算法签名均为 `pub fn[G : @core.GraphReadable]`，原因：
1. **存储无关**: 同一算法适用于 AdjList/Matrix/CSR/CSC 等 8 种存储
2. **类型安全**: 编译期检查 Trait 约束
3. **统一接口**: 用户只需学习一套 API

### 为什么介数中心性选择 Brandes 算法？

| 方案 | 复杂度 | 选择理由 |
|------|--------|---------|
| 朴素算法 | O(V³) | 简单但慢，仅适合 V<100 |
| **Brandes** | **O(VE)** | **最优精确算法，本模块采用** |
| 近似采样 | O(kV) | 牺牲精度换速度（未来可扩展）|

### 为什么特征向量/Katz 使用幂迭代法？

| 方案 | 优势 | 劣势 |
|------|------|------|
| **幂迭代** | **实现简单、内存 O(V)、适合稀疏图** | **收敛速度依赖谱间隙** |
| QR 分解 | 保证收敛 | 实现 O(V³)、内存 O(V²) |
| ARPACK | 工业级性能 | 依赖外部库 |

对于 MoonBit 图库的场景（教学+中小规模），幂迭代是最佳平衡点。

### 为什么 CommunicationResult 独立于 CentralityResult？

通信能力中心性的语义不同于标准中心性：
- 得分范围是 [0, 1] 但含义是「效率损失比例」，不是「相对重要性」
- 无 `normalized` 字段（始终在 [0, 1] 内）
- 未来可能扩展额外字段（如 `efficiency_before`/`efficiency_after`）

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.1.0 | 2026-06-01 | 初始版本：7 种中心性算法 + 72 tests + 完整文档 |
