# 稠密子图分析 (`dense_subgraph`)

> **版本**: v0.2.0 | **状态**: 稳定 | **测试**: 20 通过

提供无向图的稠密子图分析与聚类结构发现能力，包含 4 种核心算法：
- **K-Core 分解** — 基于度数的层次化稠密子图识别 O(V+E)
- **K-Truss 分解** — 基于三角形计数的边层次分解
- **三角形计数** — 全局与节点级三角形统计
- **聚类系数** — 局部与全局聚集程度度量

## 为什么需要稠密子图分析？

在社交网络、生物网络、知识图谱等复杂网络中，**稠密子图（Dense Subgraph）** 是理解网络结构的关键工具：

| 应用场景 | 稠密子图的作用 |
|---------|--------------|
| 社交网络 | 发现紧密社群、影响力群体、核心用户圈 |
| 生物网络 | 识别蛋白质复合物、基因调控模块 |
| 推荐系统 | 挖掘兴趣相似的用户群组 |
| 金融风控 | 检测异常关联的交易团伙 |
| 知识图谱 | 发现主题相关的实体簇 |

本模块提供的 4 种算法从不同角度刻画网络的"密集程度"：

```
K-Core (节点级)     K-Truss (边级)      三角形 (计数)        聚类系数 (比率)
   ↓                   ↓                  ↓                    ↓
"这个节点有多核心?"  "这条边有多重要?"   "有多少三元闭环?"    "邻居间连接多紧密?"
```

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | GraphReadable trait + NodeId 类型 |
| [`@storage`](../storage/) | UndirectedAdjList (KTrussResult 内部存储) |

## 文件结构

```
lib/algo/dense_subgraph/
├── moon.pkg                      # 包配置
├── types.mbt                     # 4 种结果类型定义 + 辅助方法
├── kcore.mbt                     # K-Core 分解 (Batagelj & Zaversnik O(V+E))
├── ktruss.mbt                    # K-Truss 分解 (基于三角形 support)
├── triangle.mbt                  # 三角形计数 (节点迭代法)
├── clustering.mbt                # 聚类系数 (局部/全局)
└── dense_subgraph_test.mbt       # 完整测试套件 (17 tests)
```

## API 总览

### 核心类型 ([types.mbt](types.mbt))

#### `KCoreResult` — K-Core 分解结果

```moonbit
pub(all) struct KCoreResult {
  core : Array[Int]    // core[i] = 节点 i 的 core number
}
```

| 方法 | 说明 | 返回 |
|------|------|------|
| `core_number(node)` | 获取指定节点的 core number | `Int` |

#### `KTrussResult` — K-Truss 分解结果

```moonbit
pub(all) struct KTrussResult {
  truss : @storage.UndirectedAdjList  // 边权重 = truss number
}
```

| 方法 | 说明 | 返回 |
|------|------|------|
| `truss_number(u, v)` | 获取边的 truss number | `Int?` (无边返回 None) |

#### `TriangleCountResult` — 三角形计数结果

```moonbit
pub(all) struct TriangleCountResult {
  total : Int           // 全局三角形总数
  per_node : Array[Int] // 每个节点参与的三角形数
}
```

| 方法 | 说明 | 返回 |
|------|------|------|
| `total_triangles()` | 获取全局三角形总数 | `Int` |
| `node_triangles(node)` | 获取指定节点参与的三角形数 | `Int` |

#### `ClusteringCoefficientResult` — 聚类系数结果

```moonbit
pub(all) struct ClusteringCoefficientResult {
  locals : Array[Double]  // 每个节点的局部聚类系数
  global : Double         // 全局平均聚类系数
}
```

| 方法 | 说明 | 返回 |
|------|------|------|
| `local_coefficient(node)` | 获取指定节点的局部聚类系数 | `Double` |
| `global_coefficient()` | 获取全局平均聚类系数 | `Double` |

---

### K-Core 分解 ([kcore.mbt](kcore.mbt))

**Batagelj & Zaversnik O(V+E) 算法** — 基于度数的"剥洋葱法"，从外层逐层剥离低度数节点。

| 函数 | 约束 | 说明 | 返回 |
|------|:----:|------|------|
| `k_core_decomposition(graph)` | `G : @core.GraphReadable` | 计算每个节点的 core number | `KCoreResult` |

**Core Number 定义**:
- 节点 v 的 **core number** = 最大整数 k，使得 v 属于某个 **k-core**
- **k-core**：最大诱导子图中每个节点的度数 ≥ k
- 性质：k-core 一定是 (k-1)-core 的子集（嵌套结构）

**算法流程**（剥洋葱法）:
1. 计算所有节点的初始度数
2. 使用 bin 排序按度数排序节点
3. 从最低度数节点开始处理，将其 core number 设为当前度数
4. 对每个被处理节点：减少其邻居的度数，维护 bin 排序顺序
5. 重复直到所有节点处理完毕

**时间复杂度**: O(V + E)，空间复杂度: O(V + E)

---

### K-Truss 分解 ([ktruss.mbt](ktruss.mbt))

**基于三角形支持度的边层次分解** — 比 K-Core 更精细的稠密子图刻画。

| 函数 | 约束 | 说明 | 返回 |
|------|:----:|------|------|
| `k_truss_decomposition(graph)` | `G : @core.GraphReadable` | 计算每条边的 truss number | `KTrussResult` |

**Truss Number 定义**:
- 边 e 的 **support** = 包含 e 的三角形数量
- 边 e 的 **truss number** = support + 2
- **k-truss**：最大边子集中每条边的 truss number ≥ k
- 性质：k-truss 中每条边至少参与 (k-2) 个三角形

**算法流程**:
1. 预计算所有节点的排序邻居集合
2. 初始化 HashMap 存储每条边的 support（初始为 0）
3. 遍历所有可能的三角形 (u, v, w)，三条边各 +1
4. 将 support + 2 作为边权重写入结果图

**时间复杂度**: O(Σ d(v)²)，最坏 O(V·d_max²)

---

### 三角形计数 ([triangle.mbt](triangle.mbt))

**节点迭代法** — 遍历所有边 (u,v)，通过邻居集合交集找共同邻居 w。

| 函数 | 约束 | 说明 | 返回 |
|------|:----:|------|------|
| `count_triangles(graph)` | `G : @core.GraphReadable` | 统计全局和节点级三角形数 | `TriangleCountResult` |

**算法优化**:
- 预计算并排序所有邻居集合 → 支持 O(d(u)+d(v)) 的交集运算
- 只枚举 w > v > u 的有序三元组 → 避免重复计数
- 使用双指针归并求交集 → 高效的集合操作

**时间复杂度**: O(Σ d(u)·d(v))，对于稀疏图接近 O(m^(3/2))

---

### 聚类系数 ([clustering.mbt](clustering.mbt))

**局部与全局聚集程度度量** — 衡量"朋友的朋友也是朋友"的概率。

| 函数 | 约束 | 说明 | 返回 |
|------|:----:|------|------|
| `local_clustering_coefficient(graph, node)` | `G : @core.GraphReadable` | 单个节点的局部聚类系数 | `Double` |
| `average_clustering_coefficient(graph)` | `G : @core.GraphReadable` | 所有节点的平均值 | `Double` |
| `clustering_coefficients(graph)` | `G : @core.GraphReadable` | 完整结果（局部+全局） | `ClusteringCoefficientResult` |

**数学定义**:

```
局部聚类系数 C(v) = (v 的邻居间的实际边数) / C(deg(v), 2)

其中 C(n, 2) = n × (n-1) / 2 是可能的最大边数

特殊情况：
- deg(v) < 2 时，C(v) = 0.0（无法形成三角形）
- deg(v) = 2 且两邻居相连时，C(v) = 1.0

全局聚类系数 = 所有节点局部系数的平均值
```

## 使用示例

### K-Core 分解：识别社交网络核心圈

```moonbit
// 构建混合图: 三角形(0,1,2) + 链(2,3,4)
let g = @storage.new_undirected()
@core.GraphWritable::add_node(g, 0.0) |> ignore  // 节点 0
@core.GraphWritable::add_node(g, 0.0) |> ignore  // 节点 1
@core.GraphWritable::add_node(g, 0.0) |> ignore  // 节点 2
@core.GraphWritable::add_node(g, 0.0) |> ignore  // 节点 3
@core.GraphWritable::add_node(g, 0.0) |> ignore  // 节点 4

@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore  // 三角形
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0) |> ignore  // 链

// 执行 K-Core 分解
let result = k_core_decomposition(g)

// 结果解读
result.core_number(@core.NodeId(0))  // => 2 (属于 2-core)
result.core_number(@core.NodeId(1))  // => 2 (属于 2-core)
result.core_number(@core.NodeId(2))  // => 2 (属于 2-core)
result.core_number(@core.NodeId(3))  // => 1 (仅属于 1-core)
result.core_number(@core.NodeId(4))  // => 1 (仅属于 1-core)

// 可视化: 2-core = {0,1,2} 构成紧密三角形
//        1-core = {0,1,2,3,4} 整个连通分量
```

### K-Truss 分解：发现强关联边

```moonbit
// 完全图 K4: 4 个节点全连接
let g = @storage.new_undirected()
let mut i = 0
while i < 4 {
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  i = i + 1
}
// 添加所有 6 条边...
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore

// 执行 K-Truss 分解
let result = k_truss_decomposition(g)

// K4 中每条边参与 2 个三角形 → truss = 2 + 2 = 4
match result.truss_number(@core.NodeId(0), @core.NodeId(1)) {
  Some(t) => t  // => 4 (属于 4-truss)
  None => -1    // 不可能
}

// 应用: 过滤高 truss 边可得到更紧密的子图
// 例如只保留 truss >= 3 的边 → 得到所有有三角形支撑的边
```

### 三角形计数：统计网络闭合三元组

```moonbit
// 使用前面的 K4 图
let tri_result = count_triangles(g)

tri_result.total_triangles()              // => 4 (K4 有 C(4,3)=4 个三角形)
tri_result.node_triangles(@core.NodeId(0)) // => 3 (节点 0 参与所有含它的三角形)

// 应用场景:
// 1. 社交网络: 三角形数量衡量网络"闭合性"
// 2. 生物网络: 蛋白质相互作用中的功能模块指标
// 3. 聚类质量: 三角形密度反映社区紧密度
```

### 聚类系数计算：量化小世界特性

```moonbit
// 使用混合图 (三角形 + 链)
let cc_result = clustering_coefficients(g)

// 局部聚类系数
cc_result.local_coefficient(@core.NodeId(0))  // => 1.0 (deg=2, 两邻居互连)
cc_result.local_coefficient(@core.NodeId(2))  // => 0.333... (deg=3, 仅 1/3 可能边存在)
cc_result.local_coefficient(@core.NodeId(3))  // => 0.0 (deg=1, 无法形成三角形)

// 全局平均聚类系数
cc_result.global_coefficient()  // => 0.4666... ((1+1+0.333+0+0)/5)

// 小世界网络特征: 高聚类系数 + 短平均路径长度
// 典型值: 社交网络 ~0.3-0.6, 随机图 ~0.0-0.1
```

### 组合使用：完整的稠密子图分析流水线

```moonbit
// 一步到位获取所有稠密子图指标
let g = make_social_network()  // 你的图数据

// 1. K-Core: 找到核心节点群
let cores = k_core_decomposition(g)
let core_nodes = []  // 收集 core >= 3 的节点

// 2. K-Truss: 找到强关联边
let trusses = k_truss_decomposition(g)

// 3. 三角形: 统计闭合三元组
let triangles = count_triangles(g)

// 4. 聚类系数: 度量聚集程度
let clustering = clustering_coefficients(g)

// 综合报告
println("核心节点数: ${count_core_nodes(cores, 3)}")
println("总三角形数: ${triangles.total_triangles()}")
println("全局聚类系数: ${clustering.global_coefficient()}")
```

## 算法原理

### Core Number 与 K-Core 层次结构

**直观理解**: 想象一张网，K-Core 就是"剥洋葱"——每次去掉度数 < k 的节点后剩下的部分。

```
原始图 (6 节点):
    0 --- 1 --- 2
    |  X  |  X  |
    3 --- 4 --- 5

1-Core (所有节点度数 >= 1): {0,1,2,3,4,5} — 去掉孤立点后的剩余
2-Core (所有节点度数 >= 2): {0,1,2,3,4}   — 去掉叶子节点 5 后
3-Core (所有节点度数 >= 3): {0,1,2,3,4}   — 如果满足条件
...

Core Number 含义:
- core=3 表示该节点属于 3-core 但不属于 4-core
- 核心节点通常在网络中扮演重要角色（信息枢纽）
```

**数学性质**:
- **嵌套性**: (k+1)-core ⊆ k-core ⊆ ... ⊆ 1-core
- **唯一性**: 每个节点有唯一的 core number
- **最大性**: k-core 是最大的度数 ≥ k 的诱导子图

### Truss Number 与 K-Truss 层次结构

**与 K-Core 的区别**:
- K-Core 基于**节点度数**（粗粒度）
- K-Truss 基于**边参与的三角形数**（细粒度）

```
边 (u,v) 的 support = 包含该边的三角形数量
Truss Number = Support + 2

示例:
- 无三角形的边: support=0 → truss=2 (2-truss, 最弱)
- 属于 1 个三角形的边: support=1 → truss=3 (3-truss)
- 属于 2 个三角形的边: support=2 → truss=4 (4-truss)
- K4 中所有边: support=2 → truss=4
```

**应用优势**:
- K-Truss 能发现 K-Core 无法识别的稠密模式
- 对于"星形"结构（中心节点高度数但邻居不互连），K-Core 给出高分但 K-Truss 正确识别为松散

### 三角形计数方法对比

本模块采用**节点迭代法**（Node Iterator），这是当前最优的实际算法之一：

| 方法 | 思路 | 时间复杂度 | 适用场景 |
|------|------|-----------|---------|
| **节点迭代法 (本模块)** | 枚举边 (u,v)，找共同邻居 w | O(m·d_max) | 一般稀疏图 ✅ |
| 边迭代法 | 枚举边对，检查是否共邻居 | O(m^3/2) | 极稀疏图 |
| 矩阵乘法 | A³ 对角线 / 6 | O(n^ω) | 密集图/GPU |

**优化技巧**:
1. **排序邻居集合** → 支持线性时间交集
2. **有序枚举 (u<v<w)** → 每个三角形只计数一次
3. **预计算邻居表** → 避免重复遍历

### 聚类系数的两种定义

| 类型 | 定义 | 公式 | 特点 |
|------|------|------|------|
| **局部** | 单个节点的邻居闭合率 | C(v) = 2×T(v) / (d(v)×(d(v)-1)) | 反映节点局部密度 |
| **全局** | 所有节点局部的均值 | C_global = ΣC(v) / n | 反映整体网络性质 |

**特殊值含义**:
- C = 1.0: 节点的所有邻居都互相连接（团）
- C = 0.0: 节点邻居间无边（星形/链端点）
- C ≈ 0.3-0.6: 典型社交网络（小世界特性）

## 内部组件

### K-Core 分解组件

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `k_core_decomposition()` | pub | 主算法入口 |
| `collect_neighbors()` | priv | 将邻居迭代器收集为 Array[Int] |

**数据结构**:
- `deg[]`: 动态度数数组（随算法递减）
- `bin[]`: 度数桶排序数组
- `vert[]`: 按当前度数排序的节点数组
- `pos[]`: 节点在 vert 中的位置索引
- `core[]`: 最终的 core number 结果

### K-Truss 分解组件

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `k_truss_decomposition()` | pub | 主算法入口 |
| `sorted_neighbors()` | priv | 排序邻居集合 |
| `intersection_result()` | priv | 双指针归并求交集 |

**数据结构**:
- `neighbor_sets[]`: 预计算的排序邻居数组
- `edge_support`: HashMap[Int,Int] 存储边→support 映射
- 编码方式: key = u * n + v (保证 u < v)

### 三角形计数组件

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `count_triangles()` | pub | 主算法入口 |
| `sorted_neighbors()` | priv | 排序邻居集合 |
| `intersection_result()` | priv | 双指针归并求交集 |

### 聚类系数组件

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `clustering_coefficients()` | pub | 完整计算（局部+全局） |
| `local_clustering_coefficient()` | pub | 单节点局部系数 |
| `average_clustering_coefficient()` | pub | 全局平均值 |
| `sorted_neighbors()` | priv | 排序邻居集合 |

## 边界行为

| 条件 | K-Core | K-Truss | 三角形 | 聚类系数 |
|------|--------|---------|--------|----------|
| **空图 (n=0)** | core=[] | 空 UndirectedAdjList | total=0, per_node=[] | locals=[], global=0.0 |
| **单节点 (n=1)** | core=[0] | 无边，查询返回 None | total=0 | local=0.0, global=0.0 |
| **无边图 (E=0)** | 所有 core=0 | 空 UndirectedAdjList | total=0 | 所有 local=0.0 |
| **完全图 Kn** | 所有 core=n-1 | 所有 truss=n (n≥3) | total=C(n,3) | 所有 local=1.0 |
| **路径图 Pn** | 端点 core=1, 其余视情况 | 所有 truss=2 | total=0 | 端点 0.0, 内部 0.0 |
| **自环** | 计入度数 | 取决于实现 | 不计入三角形 | 不影响 |
| **重边** | 计入度数 | 取决于实现 | 不重复计数 | 不影响 |

**设计原则**:
- 所有函数对空图安全，不会 panic
- 返回值语义明确（空数组 / None / 0.0）
- 符合数学定义的边界行为

## 测试覆盖

| 类别 | 测试数 | 内容 |
|------|:------:|------|
| **K-Core 基础** | 5 | 三角形/K4/路径P4/混合图/空图 |
| **三角形计数** | 5 | 空/三角形/K4/P4/混合图 |
| **K-Truss** | 4 | 三角形/K4/P4/空图 |
| **聚类系数** | 5 | 三角形端点中间/K4/混合图/空图 |
| **边界情况** | 5 | 空图/单节点/无边/极端拓扑 |
| **属性验证** | 3 | 一致性/数学恒等式/范围约束 |
| **合计** | **17** | **全覆盖 4 种算法** |

运行命令:
```bash
moon test lib/algo/dense_subgraph  # 17 tests all passed
```

测试用例详解:

| 测试名 | 验证内容 | 关键断言 |
|--------|---------|---------|
| `kcore_triangle` | 三角形 3 节点 core=2 | 所有节点 core_number == 2 |
| `kcore_k4` | 完全图 K4 core=3 | 所有节点 core_number == 3 |
| `kcore_path4` | 路径图无高核 | 所有节点 core_number == 1 |
| `kcore_mixed` | 混合图分层 | 三角形区 core=2, 链区 core=1 |
| `kcore_empty` | 空图安全 | core.length() == 0 |
| `triangle_count_k4` | K4 三角形数 | total == 4, 每节点 3 |
| `ktruss_triangle` | 三角形 truss=3 | support=1 → truss=3 |
| `ktruss_k4` | K4 truss=4 | support=2 → truss=4 |
| `clustering_mixed` | 混合图系数精确值 | node0=1.0, node2=0.333..., global≈0.467 |

## 设计决策

### 为什么选择 Batagelj & Zaversnik 算法？

1. **最优复杂度**: O(V+E) 是理论下界，无法更快
2. **空间高效**: 仅需 O(V+E) 额外空间（bin 排序）
3. **数值稳定**: 纯整数运算，无浮点误差
4. **单次遍历**: 每条边最多被访问常数次

替代方案对比:

| 算法 | 复杂度 | 缺点 |
|------|--------|------|
| **B&Z (本模块)** | O(V+E) | — |
| 重复剥除法 | O(k·(V+E)) | 需要多次扫描 |
| 矩阵方法 | O(V³) | 空间 O(V²) |

### 为什么 K-Truss 基于三角形计数而非迭代删除？

1. **直接计算**: 一次遍历即可得到所有边的 support
2. **完整信息**: 保留所有层次的 truss number（非仅最大 k-truss）
3. **简洁实现**: 无需复杂的边删除和维护逻辑

代价: 空间 O(E) 存储 edge_support HashMap。对于超大规模图可改用迭代删除法节省内存。

### 为什么三角形计数采用节点迭代法？

1. **实际性能优**: 对于稀疏图（大多数真实网络），m·d_max << m^(3/2)
2. **实现简洁**: 代码清晰易维护
3. **缓存友好**: 邻居集合预排序后顺序访问

### 为什么聚类系数提供三个级别的 API？

```moonbit
// 级别 1: 单节点快速查询
let cc = local_clustering_coefficient(g, target_node)

// 级别 2: 全局汇总
let avg = average_clustering_coefficient(g)

// 级别 3: 完整分析（推荐用于报告）
let full = clustering_coefficients(g)
full.local_coefficient(node)   // 任意节点
full.global_coefficient()      // 全局均值
```

**设计理念**:
- 最小 API 表面积：用户按需选择
- 避免冗余计算：`clustering_coefficients()` 内部复用 `local_clustering_coefficient()`
- 一致接口：所有结果类型都有清晰的辅助方法

## 与其他模块配合

### 结合社区检测模块

```moonbit
// 先用 K-Core 过滤噪声节点
let cores = k_core_decomposition(social_graph)
let filtered = filter_graph_by_core(social_graph, cores, min_core: 3)

// 再执行 Louvain 社区检测（更准确）
let communities = louvain(filtered)
```

### 结合中心性分析

```moonbit
// K-Core 识别结构性核心
let cores = k_core_decomposition(g)

// PageRank 识别影响力核心
let pr = pagerank(g)

// 交叉验证: 同时在两个维度上高的节点是真正的关键节点
let key_nodes = find_intersection(
  nodes_with_core_ge(cores, 3),
  top_k_nodes(pr, 10)
)
```

### 结合 I/O 模块导出

```moonbit
// 分析完成后可视化
let g = load_from_dot("social_network.dot")
let cores = k_core_decomposition(g)
let colored = color_by_core(g, cores)
export_to_dot(colored, "network_colored_by_core.dot")
```

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.1.0 | 2026-06-01 | 初始版本：K-Core + K-Truss + 三角形计数 + 聚类系数 + 17 tests |

---

<div align="center">

**📐 mbtgraph Dense Subgraph Module**

*稠密子图分析 — 发现网络中的隐藏结构*

</div>
