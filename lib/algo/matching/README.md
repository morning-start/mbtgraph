# 图匹配模块 (Matching)

> **版本**: v0.2.0 | **状态**: 稳定 | **测试**: 56 通过 | **算法**: 4 个

提供图匹配问题的完整求解能力，覆盖二分图与一般图、基数与权重四大维度：

| 算法 | 适用图类 | 问题类型 | 复杂度 |
|------|:--------:|:--------:|:------:|
| **Hungarian** | 二分图 | 最大基数匹配 | O(VE) |
| **Hopcroft-Karp** | 二分图 | 最大基数匹配（高效） | O(E√V) |
| **Edmonds (Blossom)** | 一般图 | 最大基数匹配 | O(V³) |
| **Kuhn-Munkres (KM)** | 完全二分图 | 最大权完美匹配 | O(V³) |

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | GraphReadable trait + NodeId 类型 |

## 文件结构

```
lib/algo/matching/
├── moon.pkg                # 包配置
├── types.mbt               # MatchingResult / KMMatchingResult 结果类型
├── hungarian.mbt           # 匈牙利算法 (O(VE))
├── hopcroft_karp.mbt       # Hopcroft-Karp (O(E√V))
├── edmonds_matching.mbt    # Edmonds Blossom (O(V³))
├── kuhn_munkres.mbt        # KM 最大权匹配 (O(V³))
└── matching_test.mbt       # 综合测试套件 (56 tests)
```

## API 总览

### 核心类型 ([types.mbt](types.mbt))

#### `MatchingResult` — 基数匹配结果

```moonbit
pub(all) struct MatchingResult {
  matching_edges : Array[(NodeId, NodeId)]  // 匹配边列表
  cardinality : Int                         // 匹配基数
}
```

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `size()` | `Int` | 匹配基数（匹配边数）|
| `is_matched(node)` | `Bool` | 节点是否在匹配中 |
| `get_partner(node)` | `NodeId?` | 获取匹配伙伴，未匹配返回 None |

#### `KMMatchingResult` — KM 权重匹配结果

```moonbit
pub(all) struct KMMatchingResult {
  matching : Array[Int]    // matching[i] = j 表示左部节点 i 匹配右部节点 j
  total_weight : Double    // 匹配总权重
}
```

### Hungarian ([hungarian.mbt](hungarian.mbt))

**匈牙利算法** — 二分图最大基数匹配，基于 DFS 增广路搜索。

| 函数 | 说明 | 返回 | 复杂度 |
|------|------|------|:------:|
| `bipartite_matching(n_left, n_right, edges)` | 邻接表版本 | `MatchingResult` | O(VE) |
| `bipartite_matching_graph(graph, left, right)` | Trait 版本 | `MatchingResult` | O(VE) |

**算法流程**:
1. 初始化空匹配 M
2. 对每个左部节点 u，执行 DFS 寻找增广路
3. 找到增广路 → 翻转匹配状态 → |M| + 1
4. 无增广路 → 终止（Berge 定理保证最大性）

### Hopcroft-Karp ([hopcroft_karp.mbt](hopcroft_karp.mbt))

**二分图最大匹配高效算法** — 时间复杂度 O(E√V)，比匈牙利快一个数量级。

| 函数 | 说明 | 返回 | 复杂度 |
|------|------|------|:------:|
| `hopcroft_karp(graph, left_nodes, right_nodes)` | BFS+DFS 混合 | `MatchingResult` | O(E√V) |

**核心优化 vs Hungarian**:

| 特性 | Hungarian | Hopcroft-Karp |
|------|-----------|---------------|
| 每轮增广路数 | **1 条** (DFS) | **多条** (BFS 分层) |
| 时间复杂度 | O(VE) | **O(E√V)** |
| 适用场景 | 中小规模 | 大规模稀疏二分图 |

**算法流程**:
1. BFS 分层：从所有未匹配左部节点出发，构建层次图
2. DFS 多路增广：在层次图上同时寻找多条不相交增广路
3. 重复直到 BFS 无法到达未匹配右部节点

### Edmonds Blossom ([edmonds_matching.mbt](edmonds_matching.mbt))

**一般图最大匹配算法** — 处理非二分图，使用花收缩（blossom contraction）处理奇数环。

| 函数 | 说明 | 返回 | 复杂度 |
|------|------|------|:------:|
| `edmonds_maximum_matching(graph)` | 一般图最大匹配 | `MatchingResult` | O(V³) |

**核心难点**: 一般图中可能存在奇数环，导致交替路径无法直接翻转。Edmonds 通过"花收缩"将奇数环收缩为单个节点，消除阻碍后再展开。

**适用场景**: 社交网络匹配、资源分配（非二分结构）

### Kuhn-Munkres (KM) ([kuhn_munkres.mbt](kuhn_munkres.mbt))

**二分图最大权完美匹配** — 时间复杂度 O(V³)，基于可行顶点标号和相等子图。

| 函数 | 说明 | 返回 | 复杂度 |
|------|------|------|:------:|
| `kuhn_munkres(weights)` | 权重矩阵输入 | `KMMatchingResult` | O(V³) |

**参数**: `weights` 为 n×n 权重矩阵 `Array[Array[Double]]`

**算法流程**:
1. 初始化可行标号：l(x) = max_j(W[x][j])，l'(y) = 0
2. 对每个左部节点，在相等子图中 DFS 寻找增广路
3. 若失败，计算松弛量 δ 并调整标号
4. 重复直到找到完美匹配

**核心概念**:
- **可行顶点标号**: l(x) + l'(y) ≥ W[x][y]
- **相等子图**: 满足 l(x) + l'(y) = W[x][y] 的边构成的子图
- **互补松弛性**: 当 Σ(l(x) + l'(y)) = Σ W[i][π(i)] 时达到最优

## 使用示例

### 匈牙利算法：基础二分图匹配

```moonbit
// 构建完全二分图 K_{3,3}
let edges : Array[(Int, Int)] = [
  (0, 0), (0, 1), (0, 2),
  (1, 0), (1, 1), (1, 2),
  (2, 0), (2, 1), (2, 2),
]

let result = bipartite_matching(3, 3, edges)
result.size()        // => 3 (完美匹配)
result.is_matched(@core.NodeId(0))  // => true
result.get_partner(@core.NodeId(0)) // => Some(NodeId(3))
```

### Hopcroft-Karp：大规模稀疏二分图

```moonbit
// 基于 GraphReadable 的高效匹配
let left : Array[@core.NodeId] = [@core.NodeId(0), @core.NodeId(1), @core.NodeId(2)]
let right : Array[@core.NodeId] = [@core.NodeId(3), @core.NodeId(4), @core.NodeId(5)]

let result = hopcroft_karp(my_graph, left, right)
result.size()        // => 最大匹配基数
```

### Edmonds：一般图最大匹配

```moonbit
// 一般图（非二分图）的最大匹配
let g = @storage.new_undirected()
// ... 添加节点和边

let result = edmonds_maximum_matching(g)
result.size()        // => 最大匹配基数
```

### KM：最大权完美匹配

```moonbit
// 3×3 权重矩阵
let weights : Array[Array[Double]] = [
  [1.0, 2.0, 3.0],
  [4.0, 5.0, 6.0],
  [7.0, 8.0, 9.0],
]

let result = kuhn_munkres(weights)
result.total_weight  // => 15.0 (最大权重完美匹配)
result.matching      // => [2, 0, 1] (左0→右2, 左1→右0, 左2→右1)
```

### 算法选择指南

```moonbit
// 二分图基数匹配（小规模）→ Hungarian
let r1 = bipartite_matching(n_left, n_right, edges)

// 二分图基数匹配（大规模）→ Hopcroft-Karp
let r2 = hopcroft_karp(graph, left, right)

// 一般图基数匹配 → Edmonds Blossom
let r3 = edmonds_maximum_matching(graph)

// 二分图最大权匹配 → KM
let r4 = kuhn_munkres(weights)
```

### 边界情况处理

```moonbit
// 空图
let r1 = bipartite_matching(0, 0, [])
r1.size()            // => 0

// 无边图
let r2 = bipartite_matching(3, 3, [])
r2.size()            // => 0

// 非对称分区
let r3 = bipartite_matching(2, 5, [(0,0), (1,1)])
r3.size()            // => 2 (≤ min(2,5))

// KM 空矩阵
let r4 = kuhn_munkres([])
r4.total_weight      // => 0.0
```

## 算法原理

### 增广路与 Berge 定理

所有基数匹配算法共享的核心概念：

```
增广路: 交替路径（非匹配边→匹配边→...），两端均为未匹配节点
翻转操作: 沿增广路交换匹配/非匹配状态，使 |M| + 1
Berge 定理: 当且仅当不存在增广路时，匹配为最大匹配
```

### 时间复杂度对比

| 算法 | 核心操作 | 迭代次数 | 总计 | 适用场景 |
|------|---------|---------|------|---------|
| Hungarian | DFS 增广 | O(V) | O(VE) | 中小规模二分图 |
| Hopcroft-Karp | BFS 分层 + DFS 多路增广 | O(√V) | O(E√V) | 大规模稀疏二分图 |
| Edmonds | 花收缩 + 增广 | O(V) | O(V³) | 一般图 |
| KM | 标号调整 + 相等子图增广 | O(V) | O(V³) | 完全二分图权重匹配 |

## 内部组件

| 组件 | 文件 | 功能 |
|------|------|------|
| `hungarian_dfs()` | hungarian.mbt | DFS 在交替树上寻找增广路径 |
| `find_node_index()` | hungarian.mbt | 在 NodeId 数组中线性查找索引 |
| `hopcroft_karp_impl()` | hopcroft_karp.mbt | BFS 分层 + DFS 多路增广核心实现 |
| `bfs_layer()` | hopcroft_karp.mbt | 构建层次图 |
| `edmonds_maximum_matching()` | edmonds_matching.mbt | 花收缩算法主函数 |
| `contract_blossom()` | edmonds_matching.mbt | 奇数环收缩操作 |
| `kuhn_munkres()` | kuhn_munkres.mbt | KM 算法主函数 |
| `dfs_km()` | kuhn_munkres.mbt | 相等子图中 DFS 寻找增广路 |
| `adjust_labels()` | kuhn_munkres.mbt | 标号调整（计算松弛量 δ）|

## 边界行为

| 场景 | Hungarian | Hopcroft-Karp | Edmonds | KM |
|------|-----------|---------------|---------|-----|
| 空图 (n=0) | cardinality=0 | cardinality=0 | cardinality=0 | weight=0.0 |
| 无边图 | cardinality=0 | cardinality=0 | cardinality=0 | weight=0.0 |
| 单条边 | cardinality=1 | cardinality=1 | cardinality=1 | weight=w |
| 非对称分区 | ≤ min(\|U\|,\|V\|) | ≤ min(\|U\|,\|V\|) | N/A | N/A |
| 不连通分量 | 各分量独立计算 | 各分量独立计算 | 全局最优 | 全局最优 |
| 自环边 | 自动忽略 | 自动忽略 | 自动忽略 | N/A |
| 输入图不可变 | ✅ | ✅ | ✅ | ✅ |

## 测试覆盖

| 类别 | Hungarian | HK | Edmonds | KM | 集成 | 内容 |
|------|:---------:|:--:|:-------:|:--:|:----:|------|
| 类型基础 | 5 | — | — | — | — | size/is_matched/get_partner |
| 空图/边界 | 4 | 2 | 2 | 2 | — | 空图/无边/零分区 |
| 正常场景 | 5 | 4 | 4 | 4 | 2 | 单边/完全图/路径/星形 |
| 非对称 | 2 | 2 | — | — | — | 左大右小/右大左小 |
| 复杂场景 | 2 | 3 | 3 | 2 | — | 不连通/多路径/奇数环 |
| 属性验证 | 3 | 2 | 2 | 2 | — | 基数≤min/权重最优 |
| **合计** | **21** | **13** | **11** | **10** | **2** | **56** |

运行命令:
```bash
moon test lib/algo/matching  # 56 tests (4 algorithms)
```

## 设计决策

### Q1: 为什么同时提供 Hungarian 和 Hopcroft-Karp？

两者都是二分图最大基数匹配，但复杂度不同：
- **Hungarian O(VE)**: 实现简单，中小规模 (V < 10K) 足够
- **Hopcroft-Karp O(E√V)**: 大规模稀疏图 (V > 10K) 显著更快
- 用户可根据场景选择，无需强制统一

### Q2: Edmonds Blossom 的花收缩如何处理奇数环？

一般图中交替路径可能形成奇数环（花），导致无法直接翻转。Edmonds 的解决方案：
1. 检测到花 → 将整个花收缩为一个虚拟节点
2. 在收缩后的图上继续寻找增广路
3. 找到后展开花，恢复原始匹配

### Q3: KM 算法为什么需要完全二分图？

KM 算法基于可行顶点标号理论，要求对所有 (i,j) 对都有权重定义。对于稀疏权重矩阵，可将缺失边设为 0 或 -∞（视具体语义）。

## 配合模块

| 模块 | 关系 |
|------|------|
| `algo/flow` | 二分图匹配可归约为最大流（备用方案）|
| `algo/recognition` | 二部图判定可作为匹配前置检查 |
| `core` | 提供 NodeId / GraphReadable trait |
| `storage` | GraphReadable 版本的底层图存储 |

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.1.0 | 2026-05-19 | 初始版本：Hungarian 算法 + 21 tests |
| v0.1.1 | 2026-05-22 | 新增 Hopcroft-Karp + Edmonds Blossom |
| **v0.2.0** | **2026-05-29** | **新增 KM 最大权匹配 + 56 tests** |
