# 特殊图识别算法 (`recognition`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 25 通过

提供图论中 **7 种核心特殊图性质** 的快速判定能力，涵盖结构识别、组合优化和序列可图化三大方向：

- **弦图 (Chordal Graph)** — MCS 算法 + 完美消除序验证，O(V+E)
- **二部图 (Bipartite Graph)** — BFS 2-染色，O(V+E)
- **完全图 (Complete Graph)** — 邻接矩阵枚举，O(V²)
- **正则图 (Regular Graph)** — 度数一致性检查，O(V)
- **树 (Tree)** — 连通性 + 边数约束，O(V+E)
- **森林 (Forest)** — 无环性分量检查，O(V+E)
- **Havel-Hakimi 定理** — 度序列可实现性，O(V²)

## 为什么特殊图识别很重要？

在现实应用中，**识别图的特殊性质往往是算法选择的前置条件**：

| 特殊图类 | 实际应用场景 | 算法加速 |
|----------|-------------|---------|
| **树 / 森林** | 网络拓扑、XML/JSON 解析、文件系统 | MST O(1)、最短路径 O(V) |
| **二部图** | 任务调度、推荐系统匹配、社交网络分析 | 最大匹配 O(√VE)、着色 O(1) |
| **弦图** | 稀疏矩阵分解、概率图模型、数据库查询优化 | 最大团 O(V+E)、着色 O(V+E) |
| **完全图** | 团检测基准、完全子图搜索、TSP 特例 | 最短路径 O(1)、MST O(E) |
| **正则图** | 网络设计、纠错码构造、对称结构建模 | 均衡性保证 |

**核心价值**: 先识别 → 再选择最优算法 → 避免通用算法的冗余计算。

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | `GraphReadable` trait、`NodeId` 类型 |
| [`@storage`](../storage/) | 测试用图构建 (`UndirectedAdjList`) |

## 文件结构

```
lib/algo/recognition/
├── moon.pkg              # 包配置
├── recognition.mbt       # 7 种判定算法实现 (~360 行)
└── recognition_test.mbt  # 完整测试套件 (25 tests)
```

## API 总览

所有函数均为 **Trait 泛型** 实现，接受任意 `GraphReadable` 图结构：

| 函数 | 返回类型 | 复杂度 | 核心思想 |
|------|:--------:|:------:|----------|
| `is_bipartite(graph)` | `Bool` | O(V+E) | BFS 2-染色，奇环检测 |
| `is_complete(graph)` | `Bool` | O(V²) | 枚举所有节点对，验证邻接完整性 |
| `is_regular(graph)` | `Bool` | O(V) | 所有节点度数是否一致 |
| `is_tree(graph)` | `Bool` | O(V+E) | 无环 + 连通 + \|E\|=\|V\|-1 |
| `is_forest(graph)` | `Bool` | O(V+E) | 每个连通分量满足 \|E\|<\|V\| |
| `is_chordal(graph)` | `Bool` | O(V+E) | MCS 排序 + PEO 验证 |
| `is_graphic_sequence(seq)` | `Bool` | O(V²) | Havel-Hakimi 迭代消去法 |

### 函数签名

```moonbit
// ====== 图结构判定 (Trait 泛型) ======

pub fn[G : @core.GraphReadable] is_bipartite(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_complete(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_regular(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_tree(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_forest(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_chordal(graph : G) -> Bool

// ====== 序列可图化 (纯数组输入) ======

pub fn is_graphic_sequence(seq : Array[Int]) -> Bool
```

**设计特点**:
- 前 6 个函数为 **Trait 泛型**，支持所有实现了 `GraphReadable` 的存储结构（AdjList/Matrix/CSR/CSC 等）
- `is_graphic_sequence` 为 **独立函数**，仅接收度数数组，不依赖图实例
- 统一返回 `Bool`，语义清晰：`true` = 满足该性质，`false` = 不满足

## 使用示例

### 快速判定图类型

```moonbit
// 构建一个简单无向图: 0-1-2 (路径 P3)
let g = @storage.new_undirected()
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore

// 快速识别图性质
is_bipartite(g)   // => true  (路径图是二分图)
is_tree(g)        // => true  (路径是树)
is_forest(g)      // => true  (树是森林的特例)
is_complete(g)    // => false (缺少边 0-2)
is_regular(g)     // => false (度数: 1, 2, 1 不一致)
is_chordal(g)     // => true  (树是弦图！)
```

### 组合判定流程：智能算法选择器

```moonbit
/// 根据图类型自动选择最优着色算法
fn smart_coloring[G : @core.GraphReadable](graph : G) -> String {
  if is_bipartite(graph) {
    return "使用 2-染色算法: O(V+E)"
  }
  if is_chordal(graph) {
    return "使用完美消除序着色: O(V+E)"
  }
  // 回退到通用贪心着色
  return "使用 DSATUR 贪心着色: O(V²)"
}

/// 根据图类型选择最优最大匹配算法
fn smart_matching[G : @core.GraphReadable](graph : G) -> String {
  if is_bipartite(graph) {
    return "使用 Hopcroft-Karp: O(√VE)"
  }
  if is_tree(graph) || is_forest(graph) {
    return "使用 DFS 贪心: O(V)"
  }
  // 回退到通用 blossom 算法
  return "使用 Edmonds Blossom: O(V³)"
}
```

### Havel-Hakimi 构造示例

```moonbit
// 判定度序列 [3, 3, 2, 2, 2] 是否可图化
is_graphic_sequence([3, 3, 2, 2, 2])  // => true (存在对应简单图)

// 经典不可图化案例
is_graphic_sequence([5, 2, 1, 1])      // => false (度数超过节点数限制)

// 握手定理违反: 度数之和必须为偶数
is_graphic_sequence([3, 3, 3])          // => false (总和=9 为奇数)

// 空序列平凡可图化
is_graphic_sequence([])                 // => true

// 有效度序列示例
is_graphic_sequence([2, 2, 2])          // => true (三角形 K3)
is_graphic_sequence([2, 1, 1])          // => true (路径 P3)
```

### 经典图例完整诊断

```moonbit
/// 对 Petersen 图进行完整性质诊断 (10 节点, 15 边)
fn diagnose_petersen() {
  let petersen = make_petersen_graph()  // 假设已构建

  println("=== Petersen 图诊断报告 ===")
  println("节点数: 10, 边数: 15")
  println("二分图: ${is_bipartite(petersen)}")    // => false (含奇环)
  println("完全图: ${is_complete(petersen)}")      // => false
  println("正则图: ${is_regular(petersen)}")       // => true  (3-正则)
  println("树:     ${is_tree(petersen)}")          // => false
  println("森林:   ${is_forest(petersen)}")        // => false
  println("弦图:   ${is_chordal(petersen)}")       // => false (含无弦环)
}
```

## 算法原理

### 1. 二分图判定 — BFS 2-染色

**理论基础**: 图 G 是二分图当且仅当 G **不含奇环**（König 定理的推论）。

**算法步骤**:
1. 从每个未访问节点启动 BFS
2. 用两种颜色交替染色邻居节点
3. 若发现相邻节点同色 → 存在奇环 → 非二分图
4. 所有连通分量均通过 → 是二分图

```
时间复杂度: O(V + E)
空间复杂度: O(V)  (颜色数组 + BFS 队列)

关键不变式:
  - 同层节点颜色相同
  - 相邻层节点颜色相反
  - 冲突 ⇔ 奇环存在
```

**实际应用**:
- 任务调度：将任务分配到两个时间槽（避免冲突）
- 推荐系统：用户-物品二分图上的协同过滤
- 社交网络：检测社群两极分化

---

### 2. 弦图判定 — Maximum Cardinality Search (MCS)

**理论基础**: 图 G 是弦图当且仅当存在一个 **完美消除序 (Perfect Elimination Ordering, PEO)**。

**定义回顾**:
- **弦图 (Chordal Graph)**: 长度 ≥ 4 的每个环都至少有一条 **弦**（连接环上两个非连续节点的边）
- **完美消除序 (PEO)**: 对排序中每个节点 v，v 的后续邻居构成一个 **团**（完全子图）

**MCS 算法步骤**:
1. **逆向选择**: 从最后一个位置开始，每次选与已选集合邻接最多的未选节点
2. **权重更新**: 选中节点后，其所有未选邻居权重 +1
3. **PEO 验证**: 对每个节点 v，检查其后续邻居是否两两相连

```
MCS 排序过程 (示例):
  初始: 权重全为 0
  第1轮: 选权重最高节点 (如 A)，A 的邻居权重+1
  第2轮: 在剩余节点中选权重最高 (如 B)，B 的邻居权重+1
  ...
  最终得到逆序排列

PEO 验证 (对每个节点 v):
  later_neighbors(v) = { u | pos(u) > pos(v) 且 (v,u) ∈ E }
  检查: later_neighbors(v) 是否构成团？

时间复杂度: O(V + E)  (MCS: O(VE) 最坏, 但实际接近线性)
空间复杂度: O(V)      (权重数组 + 使用标记 + 位置映射)
```

**重要性质**:
- **树是弦图** (树的任意环长度 ≤ 3，平凡满足弦图定义)
- **完全图是弦图** (任意环都有足够多的弦)
- **区间图 ⊂ 弦图** (区间图是弦图的真子集)
- **弦图的补图是 comparability graph**

**实际应用**:
- 稀疏矩阵 Cholesky 分解：填充度最小化
- 概率图模型：弦化操作消除环路
- 数据库查询优化：连接顺序选择

---

### 3. 完全图判定 — 邻接对枚举

**理论基础**: K_n 是 n 个节点的图，其中每对不同节点之间都恰好有一条边。

**算法步骤**:
1. 收集所有节点 ID 到数组
2. 双重循环枚举所有 (i, j) 对，i < j
3. 检查每对节点是否存在边
4. 全部存在 → 完全图；任一缺失 → 非完全图

```
时间复杂度: O(V²)  (需检查 C(n,2) = n(n-1)/2 对节点)
空间复杂度: O(V)  (节点数组)

边界情况:
  - V ≤ 1: 平凡完全图 (空图和单节点图)
  - V = 2: 仅需检查 1 条边
  - V = n: 需检查 n(n-1)/2 条边
```

---

### 4. 正则图判定 — 度数一致性

**理论基础**: k-正则图中每个节点的度数都等于 k。

**算法步骤**:
1. 遍历所有节点，记录第一个节点的度数 d₀
2. 后续每个节点的度数必须等于 d₀
3. 任一不一致 → 非正则图

```
时间复杂度: O(V)  (仅需遍历所有节点一次)
空间复杂度: O(1)  (只存储一个参考度数)

特殊情况:
  - 空图: 平凡正则 (所有节点度数为 0)
  - 单节点: 平凡正则 (度数为 0)
  - 完全图 K_n: (n-1)-正则
  - 偶环 C_{2k}: 2-正则
  - Petersen 图: 3-正则
```

---

### 5. 树判定 — 结构三要素

**理论基础**: 无向连通图 T 是树当且仅当满足以下 **等价条件**之一：
1. T 连通且 |E| = |V| - 1
2. T 无环且 |E| = |V| - 1
3. T 中任意两点间有唯一简单路径

**本实现采用条件 1**:

**算法步骤**:
1. 边界检查: V = 0 → 非树; V = 1 → 检查边数为 0
2. 快速拒绝: |E| ≠ |V| - 1 → 直接返回 false
3. BFS 连通性检查: 从任一节点出发，统计可达节点数
4. 可达数 == V → 连通 → 是树

```
时间复杂度: O(V + E)  (BFS 遍历)
空间复杂度: O(V)      (visited 数组 + BFS 队列)

关键优化:
  - 先检查边数约束 (O(1))，避免不必要的 BFS
  - 空图和平凡图提前返回
```

**树的弦图性质**: 所有树都是弦图（因为树中无长度 ≥ 4 的环），所以 `is_tree(g)` 为真 ⇒ `is_chordal(g)` 必为真。

---

### 6. 森林判定 — 分量无环性

**理论基础**: 森林是无环图，等价于多个树的并集（不一定连通）。

**算法步骤**:
1. 对每个未访问节点启动 BFS
2. 统计该连通分量的节点数 Vᵢ 和边数 Eᵢ
3. 检查: Eᵢ < Vᵢ （严格小于，因为树满足 E = V - 1）
4. 所有分量通过 → 是森林

```
时间复杂度: O(V + E)  (每个节点/边访问一次)
空间复杂度: O(V)      (visited 数组 + BFS 队列)

注意: 无向图中 BFS 统计的边数是实际边数的 2 倍
      (因为每条边 (u,v) 会从 u→v 和 v→u 各遍历一次)
      所以最终 edges = edges / 2
```

**树与森林的关系**:
- 树 = 连通的森林
- `is_tree(g)` ⇒ `is_forest(g)` （但反之不成立）
- 空图是森林（0 个连通分量，平凡满足）

---

### 7. Havel-Hakimi 定理 — 度序列可图化

**定理陈述** (Havel, 1955; Hakimi, 1962):
> 非负整数序列 d₁ ≥ d₂ ≥ ... ≥ dₙ 可图化（即存在简单图以该序列为度数序列）当且仅当：
> 序列 d₂-1, d₃-1, ..., d_{d₁+1}-1, d_{d₁+2}, ..., dₙ 可图化。
>
> 递归基础: 全零序列可图化。

**算法步骤**:
1. 将序列降序排序
2. 移除前导零（若剩余为空 → 可图化）
3. 取最大度数 d = d₁
4. 若 d > 剩余序列长度 → 不可图化（无法找到足够的邻居）
5. 移除 d₁，将其后 d 个元素各减 1
6. 若出现负数 → 不可图化
7. 重复上述过程直到终止

```
示例演示: 序列 [3, 3, 2, 2, 2]

第1轮: 排序 [3, 3, 2, 2, 2]
       取 d=3, 后续减1: [2, 1, 1, 2]
第2轮: 排序 [2, 2, 1, 1]
       取 d=2, 后续减1: [1, 0, 1]
第3轮: 排序 [1, 1, 0]
       取 d=1, 后续减1: [0, 0]
第4轮: 全零 → 可图化 ✓

时间复杂度: O(V²)  (每轮排序 O(V log V)，共 O(V) 轮)
空间复杂度: O(V)  (原址修改序列)
```

**必要条件 (快速拒绝)**:
1. **握手定理**: 度数之和必须为偶数 (∑dᵢ ≡ 0 mod 2)
2. **上界约束**: max(dᵢ) ≤ n - 1（简单图最多连 n-1 条边）
3. **非负性**: 所有序数 dᵢ ≥ 0

## 时间复杂度对比表

| 判定类型 | 时间 | 空间 | 适用场景 |
|----------|:----:|:----:|----------|
| **is_regular** | **O(V)** | O(1) | 大规模图快速筛选 |
| **is_bipartite** | **O(V+E)** | O(V) | 匹配/着色前置判断 |
| **is_tree** | **O(V+E)** | O(V) | 拓扑结构确认 |
| **is_forest** | **O(V+E)** | O(V) | 无环性验证 |
| **is_chordal** | **O(V+E)** | O(V) | 高级算法启用条件 |
| **is_complete** | O(V²) | O(V) | 小规模图或稠密图 |
| **is_graphic_sequence** | O(V²) | O(V) | 序列有效性检查 |

**性能建议**:
- 大规模稀疏图优先使用 O(V+E) 算法 (bipartite/tree/forest/chordal)
- 需要批量判定时，先执行 O(V) 的 `is_regular` 过滤明显不符合的图
- `is_complete` 在 V > 10000 时应谨慎使用

## 内部组件

### 公开 API

| 函数 | 功能 |
|------|------|
| `is_bipartite()` | BFS 2-染色判定二分图 |
| `is_complete()` | 邻接对枚举判定完全图 |
| `is_regular()` | 度数一致性判定正则图 |
| `is_tree()` | 连通+边数约束判定树 |
| `is_forest()` | 分量无环性判定森林 |
| `is_chordal()` | MCS + PEO 验证判定弦图 |
| `is_graphic_sequence()` | Havel-Hakimi 迭代判定可图化 |

### 私有辅助函数

| 函数 | 功能 |
|------|------|
| `mcs_ordering()` | Maximum Cardinality Search 生成候选 PEO |
| `check_peo()` | 验证给定排序是否为完美消除序 |

## 边界行为

### 图结构判定的边界情况

| 输入 | is_bipartite | is_complete | is_regular | is_tree | is_forest | is_chordal |
|------|:------------:|:-----------:|:----------:|:-------:|:---------:|:----------:|
| **空图 (V=0)** | ✅ true | ✅ true | ✅ true | ❌ false | ✅ true | ✅ true |
| **单节点 (V=1, E=0)** | ✅ true | ✅ true | ✅ true | ✅ true | ✅ true | ✅ true |
| **两节点一边 (V=2, E=1)** | ✅ true | ✅ true | ✅ true | ✅ true | ✅ true | ✅ true |
| **孤立节点** | ✅ true | ❌ false | ❌ false* | ❌ false | ✅ true | ✅ true |
| **自环** | ❌ false | 视实现 | 视实现 | ❌ false | ❌ false | 视实现 |
| **平行边** | ✅ true | ✅ true | 视实现 | ❌ false | ❌ false | 视实现 |

\* 注: 多个孤立节点的度数均为 0，此时 is_regular 返回 true（0-正则）。

### Havel-Hakimi 边界情况

| 输入 | 结果 | 原因 |
|------|:----:|------|
| `[]` (空序列) | ✅ true | 空序列平凡可图化 |
| `[0]` | ✅ true | 单孤立节点 |
| `[0, 0, 0]` | ✅ true | 三个孤立节点 |
| `[-1, 2, 1]` | ❌ false | 含负数 |
| `[5, 2, 1, 1]` | ❌ false | 度数 5 > n-1 = 3 |
| `[3, 3, 3]` | ❌ false | 总和=9 为奇数（握手定理违反）|

### 退化情况的语义解释

**为什么空图不是树？**
- 树的定义要求连通性，空图没有节点，无法讨论连通性
- 从边的角度看：树要求 |E| = |V| - 1，空图 0 ≠ -1，不满足

**为什么单节点无边是树？**
- 满足 |E| = |V| - 1 (0 = 1 - 1) ✓
- 平凡连通（只有一个节点）✓
- 无环 ✓

**为什么空图是森林？**
- 森林的充要条件是无环，空图没有环 ✓
- 也可以看作 0 棵树的并集

## 测试覆盖

### 测试矩阵

| 类别 | 测试名 | 验证内容 | 预期结果 |
|------|--------|----------|:--------:|
| **二分图** | `is_bipartite_empty` | 空图 | ✅ true |
| | `is_bipartite_single_node` | 单节点 | ✅ true |
| | `is_bipartite_single_edge` | 两节点一边 | ✅ true |
| | `is_bipartite_even_cycle` | C₄ 偶环 | ✅ true |
| | `is_bipartite_odd_cycle` | C₅ 奇环 | ❌ false |
| | `is_bipartite_triangle` | K₃ 三角形 | ❌ false |
| | `is_bipartite_path3` | P₃ 路径 | ✅ true |
| **完全图** | `is_complete_empty` | 空图 | ✅ true |
| | `is_complete_single_node` | 单节点 | ✅ true |
| | `is_complete_triangle` | K₃ | ✅ true |
| | `is_complete_path3` | P₃ 路径 | ❌ false |
| **正则图** | `is_regular_empty` | 空图 | ✅ true |
| | `is_regular_single_node` | 单节点 | ✅ true |
| | `is_regular_triangle` | K₃ (2-正则) | ✅ true |
| | `is_regular_path3` | P₃ (度 1,2,1) | ❌ false |
| | `is_regular_even_cycle` | C₄ (2-正则) | ✅ true |
| **树** | `is_tree_empty` | 空图 | ❌ false |
| | `is_tree_single_node` | 单节点 | ✅ true |
| | `is_tree_single_edge` | 两节点一边 | ✅ true |
| | `is_tree_path3` | P₃ 路径 | ✅ true |
| | `is_tree_triangle` | K₃ | ❌ false |
| | `is_tree_odd_cycle` | C₅ | ❌ false |
| **森林** | `is_forest_empty` | 空图 | ✅ true |
| | `is_forest_single_node` | 单节点 | ✅ true |
| | `is_forest_single_edge` | 两节点一边 | ✅ true |
| | `is_forest_path3` | P₃ 路径 | ✅ true |
| | `is_forest_triangle` | K₃ | ❌ false |
| **弦图** | `is_chordal_empty` | 空图 | ✅ true |
| | `is_chordal_single_node` | 单节点 | ✅ true |
| | `is_chordal_triangle` | K₃ | ✅ true |
| | `is_chordal_even_cycle` | C₄ (无弦) | ❌ false |
| | `is_chordal_odd_cycle` | C₅ (无弦) | ❌ false |
| **Havel-Hakimi** | `is_graphic_sequence_empty` | 空序列 | ✅ true |
| | `is_graphic_sequence_valid` | [2,2,2] 三角形 | ✅ true |
| | `is_graphic_sequence_path3` | [2,1,1] 路径 | ✅ true |
| | `is_graphic_sequence_negative` | [-1,2,1] | ❌ false |
| | `is_graphic_sequence_odd_sum` | [3,3,3] | ❌ false |
| | `is_graphic_sequence_too_large` | [5,2,1,1] | ❌ false |

### 测试统计

| 类别 | 测试数量 | 覆盖重点 |
|------|:--------:|----------|
| 二分图 | 7 | 空/平凡/偶环/奇环/三角/路径 |
| 完全图 | 4 | 空/单节点/K₃/非完全 |
| 正则图 | 5 | 空/单节点/2-正则/非正则/环 |
| 树 | 6 | 空/单节点/边/路径/环/三角 |
| 森林 | 5 | 空/单节点/边/路径/非森林 |
| 弦图 | 5 | 空/单节点/K₃/偶环/奇环 |
| Havel-Hakimi | 6 | 空/有效/有效/负数/奇和/超限 |
| **合计** | **25** | **全覆盖边界 + 经典反例** |

运行命令:
```bash
moon test lib/algo/recognition  # 25 tests all pass
```

### 经典测试图例说明

| 图例 | 性质 | 为什么重要？ |
|------|------|-------------|
| **K₃ (三角形)** | 完全图、2-正则、弦图、非二分图 | 最小非二分图、最小非树完全图 |
| **C₄ (四边形)** | 2-正则、二分图、非弦图 | 最小非弦偶环 |
| **C₅ (五边形)** | 2-正则、非二分图、非弦图 | 最小非弦奇环、Petersen 子图 |
| **P₃ (路径)** | 树、森林、二分图、弦图 | 最小非平凡树 |
| **空图/单节点** | 多种性质的真值边界 | 测试退化情况处理 |

## 设计决策

### 为什么选择这 7 种判定？

选择基于 **实用性频率 × 算法触发价值 × 实现复杂度** 的三维评估：

#### 第一梯队：高频高价值 (必选)

| 判定 | 选择理由 |
|------|----------|
| **is_bipartite** | 二分图匹配是图论最经典问题之一，几乎所有的任务调度/分配问题都可归约到此 |
| **is_tree** | 树是最常见的图结构（DOM 树、语法树、网络拓扑），识别后可用线性时间算法 |
| **is_chordal** | 弦图识别是高级图算法（树分解、概率图模型）的核心前置条件 |

#### 第二梯队：中频辅助价值 (重要)

| 判定 | 选择理由 |
|------|----------|
| **is_forest** | 树的超集，用于无环性快速验证（如 DAG 的无向版本） |
| **is_complete** | 完全图是很多算法的最优情况（TSP、着色、团检测），识别后可走特例路径 |
| **is_regular** | 正则性是对称结构的标志，网络设计/编码理论中的常见约束 |

#### 第三梯队：理论工具 (补充)

| 判定 | 选择理由 |
|------|----------|
| **is_graphic_sequence** | Havel-Hakimi 是图论基础定理，常用于图生成器的输入验证和网络设计可行性分析 |

#### 未入选但值得关注的判定

| 判定 | 未选原因 | 未来可能 |
|------|----------|----------|
| **平面图 (Planar)** | Kuratowski 定理实现复杂 (O(V))，需子图同构判定 | v0.2.0 |
| **欧拉图 (Eulerian)** | 实现简单但应用场景较窄 | 按需添加 |
| **比较图 (Comparability)** | 需要传递定向，与当前 Trait 体系耦合度高 | 待研究 |
| **完美图 (Perfect)** | 需要多项式时间着色验证，复杂度高 | 远期规划 |

### 为什么统一返回 Bool 而非 Result/Enum？

1. **简洁性**: 判定问题是是非题，Bool 语义最直接
2. **组合友好**: 可以用逻辑运算符组合多个判定 (`is_tree(g) && is_bipartite(g)`)
3. **性能**: 避免枚举匹配的开销
4. **一致性**: 与数学定义一致（谓词函数返回布尔值）

### 为什么 Havel-Hakimi 不是泛型函数？

1. **输入不同**: 其他 6 个函数接收图结构，HH 接收整数数组
2. **用途差异**: HH 用于 **构造前验证**（"这个度序列能构成图吗？"），而非 **事后识别**
3. **独立性**: 不依赖 Graph trait，可在无图实例时调用

## 与其他模块配合

### 前置判定 → 算法选择

```moonbit
/// 智能最大匹配选择器
fn smart_max_matching[G : @core.GraphReadable](graph : G) -> MatchingResult {
  if is_bipartite(graph) {
    // 二分图: 使用 Hopcroft-Karp O(√VE)
    return hopcroft_karp(graph)
  }
  if is_tree(graph) || is_forest(graph) {
    // 树/森林: DFS 贪心 O(V)
    return greedy_tree_matching(graph)
  }
  // 一般图: 使用 Edmonds Blossom O(V³)
  return edmonds_blossom(graph)
}

/// 智能着色算法选择器
fn smart_coloring[G : @core.GraphReadable](graph : G) -> ColoringResult {
  if is_bipartite(graph) {
    return bipartite_2_coloring(graph)           // χ(G) = 2
  }
  if is_complete(graph) {
    let n = @core.GraphReadable::node_count(graph)
    return complete_coloring(graph, n)            // χ(G) = n
  }
  if is_chordal(graph) {
    return chordal_peo_coloring(graph)            // χ(G) = ω(G)
  }
  if is_tree(graph) {
    return tree_bipartite_coloring(graph)         // χ(G) ≤ 2
  }
  // 回退到通用算法
  return dsatur_coloring(graph)
}
```

### 后置验证 → 正确性保障

```moonbit
/// 验证生成的图是否符合预期性质
fn validate_generated_graph[G : @core.GraphReadable](
  graph : G,
  expected_bipartite : Bool,
  expected_chordal : Bool,
) -> Bool {
  let actual_bp = is_bipartite(graph)
  let actual_ch = is_chordal(graph)
  actual_bp == expected_bipartite && actual_ch == expected_chordal
}
```

### Havel-Hakimi + 图构建

```moonbit
/// 从度序列构建随机图 (前提: 序列可图化)
fn build_from_sequence(seq : Array[Int]) -> @storage.UndirectedAdjList? {
  if !is_graphic_sequence(seq) {
    return None
  }
  // 使用 Havel-Hakimi 构造过程反向构建图
  // (具体实现略，可参考构造性证明)
  Some(construct_graph(seq))
}
```

## 扩展计划

### v0.2.0 (规划中)

- [ ] **平面图判定** — Kuratowski 定理 + Hopcroft-Tarjan O(V) 算法
- [ ] **欧拉图/半欧拉图判定** — 连通性 + 度数奇偶性
- [ ] **比较图判定** — 传递定向验证
- [ ] **完美图判定** — ω(G) = χ(G) 验证

### v0.3.0 (远期)

- [ ] **有向图版本** — DAG/强连通/竞赛图判定
- [ ] **加权图版本** —阈值图/单位圆盘图判定
- [ ] **近似判定** — 近似弦图/近似二分图 (允许少量违规)

## 已知限制

| 限制 | 影响 | 解决方案 |
|------|------|----------|
| 仅支持无向图语义 | 有向图判定不准确 | 使用有向图专用版本 (规划中) |
| `is_complete` O(V²) 复杂度 | 大规模图性能差 | 改用邻接矩阵存储时 O(1) 查询 |
| `is_chordal` MCS 最坏 O(VE) | 极端稠密图较慢 | 实际稀疏图接近 O(V+E) |
| 不支持并行边/自环语义 | 多重图判定可能错误 | 前置调用 `simplify()` 转换为简单图 |

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| **v0.1.0** | **2026-06-01** | **初始版本：7 种判定算法 + 25 测试 + 完整文档** |

---

<div align="center">

**📐 mbtgraph 特殊图识别模块**

*图论性质快速判定 · 智能算法选择前置条件*

</div>
