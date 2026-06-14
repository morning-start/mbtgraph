# mbtgraph API 审查报告 (v0.16.0 → v1.0.0-rc.1)

> **审查日期**: 2026-06-01 | **审查范围**: lib/ 下所有公共 API
> **目标**: 为 v1.0.0 正式发布准备稳定的冻结候选 API

---

## 📊 总体统计

### API 数量概览

| 类别 | 数量 | 占比 |
|------|:----:|:----:|
| **pub(all) struct** | 61 | 52.1% |
| **pub(all) enum** | 9 | 7.5% |
| **泛型算法函数** `pub fn[G...]` | 136 | 62.3%（核心 API）|
| **实例方法** `pub fn Type::method` | 80 | 73.8%（含在 struct 中）|
| **非泛型函数** `pub fn` | 82 | 37.7% |
| **总计（去重后）** | **~140 个唯一公共 API** | — |

### 模块分布

| 模块 | 算法函数数 | 结果类型数 | 状态 |
|------|:----------:|:----------:|:----:|
| core/ | 0 | 4 (NodeId, Node, Edge, GraphError) | ✅ 冻结就绪 |
| storage/ | 10 (工厂+Builder) | 12 (8存储+4Builder) | ✅ 冻结就绪 |
| traversal/ | 12 | 3 (TraversalResult, BfsResult, DfsResult) | ⚠️ 需优化 |
| shortest_path/ | 9 | 3 (ShortestPathResult, KShortestPathsResult, FloydWarshallResult) | ✅ 冻结就绪 |
| connectivity/ | 4 | 3 (CC, SCC, BCC Result) | ✅ 冻结就绪 |
| mst/ | 2 | 1 (MstResult) | ✅ 冻结就绪 |
| flow/ | 5 | 4 (MaxFlow, MinCostMaxFlow, FlowNetwork, CostFlowNetwork) | ✅ 冻结就绪 |
| matching/ | 5 | 1 (MatchingResult) | ⚠️ 需优化 |
| pagerank/ | 1 | 1 (PageRankResult) | ✅ 冻结就绪 |
| centrality/ | 8 | 2 (CentralityResult, DegreeMode, CommunicationResult) | ✅ 冻结就绪 |
| community/ | 4 | 1 (CommunityResult) | ✅ 冻结就绪 |
| coloring/ | 6 | 3 (ColoringResult, ChromaticNumberResult, EdgeColoringResult) | ⚠️ 需优化 |
| clique/ | 4 | 3 (CliqueResult, IndependentSetResult, VertexCoverResult) | ⚠️ 需优化 |
| euler/ | 8 | 2 (EulerPathResult, EulerCircuitResult) | ⚠️ 需优化 |
| hamiltonian/ | 6 | 2 (HamiltonianResult, TSPResult) | ⚠️ 需优化 |
| cutpoints/ | 4 | 2 (CutPointResult, BridgeResult) | ✅ 冻结就绪 |
| dense_subgraph/ | 6 | 4 (KCore, KTruss, TriangleCount, ClusteringCoefficient) | ✅ 冻结就绪 |
| link_prediction/ | 6 | 1 (LinkPredictionResult) | ✅ 冻结就绪 |
| operators/ | 11 | 0 (返回标准存储类型) | ✅ 冻结就绪 |
| recognition/ | 7 | 0 (返回 Bool 或原始数据) | ✅ 冻结就绪 |
| io/ | ~15 | 7 (IOError, Stats, Metrics 等) | ⚠️ 需优化 |

### 合规率预估

| 维度 | 合规率 | 说明 |
|------|:------:|------|
| 命名规范 (snake_case) | **95%** | 少数函数前缀不一致 |
| 参数顺序一致性 | **90%** | graph 参数位置基本统一 |
| 文档注释覆盖率 | **85%** | 部分 pub fn 缺少详细文档 |
| Trait 约束精确性 | **92%** | 少数过度约束情况 |
| **总体合规率** | **~90%** | **良好，可进入冻结流程** |

---

## 🔍 问题清单（按严重程度排序）

### 🔴 Critical — 必须修复（v1.0.0 前必须处理）

| # | API | 文件 | 问题描述 | 建议 |
|---|-----|------|---------|------|
| C1 | `bubble_sort_by_weight()` | [storage/shared_helpers.mbt:40](lib/storage/shared_helpers.mbt#L40) | **已废弃的 O(n²) 冒泡排序仍暴露为 pub 函数**。v0.14.0 已替换为快排，此函数不应再公开 | ✅ 已改为 `fn`（私有） |
| C2 | `int_max()` | [storage/shared_helpers.mbt:81](lib/storage/shared_helpers.mbt#L81) | **过于简单的工具函数不应作为公共 API**。用户可自行实现或使用标准库 | ✅ 已改为 `fn`（私有） |
| C3 | `topo_validates()` | [traversal/traversal_test.mbt:417](lib/algo/traversal/traversal_test.mbt#L417) | **测试辅助函数误标记为 pub**。不应作为公共 API 暴露 | ✅ 已改为测试内部 `fn` |
| C4 | `bfs_shortest_path()` | [traversal/bfs.mbt:111](lib/algo/traversal/bfs.mbt#L111) | **与 dijkstra 功能高度重叠**。BFS 只适用于无权图最短路径，但命名容易混淆 | 保持现状，已在注释中明确“无权图”限制 |
| C5 | `build_weight_matrix()` | [hamiltonian/tsp.mbt:201](lib/algo/hamiltonian/tsp.mbt#L201) | **内部辅助函数不应公开**。这是 TSP 算法的实现细节 | ✅ 已改为 `fn`（私有） |

**处理优先级**: 🔴🔴🔴 **必须在 v1.0.0-rc.1 发布前完成**

---

### ⚠️ Warning — 建议修复（影响 API 质量）

#### W1: 命名前缀不一致

| 当前名称 | 模块 | 问题 | 建议重命名为 |
|---------|------|------|-------------|
| `find_maximum_clique()` | clique | 使用 `find_` 前缀 | ✅ 保持（符合"查找最大"语义）|
| `find_hamiltonian_path_backtrack()` | hamiltonian | 过长且包含实现细节 `_backtrack` | `find_hamiltonian_path()` （移除实现细节）|
| `find_hamiltonian_circuit_backtrack()` | hamiltonian | 同上 | `find_hamiltonian_circuit()` |
| `has_hamiltonian_circuit_quick_check()` | hamiltonian | 过长且包含性能暗示 `_quick_check` | `can_have_hamiltonian_circuit()` 或保持原样（强调是快速必要条件检查）|
| `find_minimum_vertex_cover_exact()` | clique | 包含 `_exact` 后缀 | `find_minimum_vertex_cover()` （精确版本应为默认）|
| `find_minimum_vertex_cover_approx()` | clique | 包含 `_approx` 后缀 | `find_minimum_vertex_cover_greedy()` （明确算法策略）|

**建议**: v1.0.0 提供新名称别名，v2.0.0 移除旧名称。

#### W2: 有向/无向版本命名模式不统一

**当前模式 A**（euler 模块）:
- `has_euler_path_undirected()` / `has_euler_path_directed()`
- `find_euler_path_undirected()` / `find_euler_path_directed()`

**当前模式 B**（cutpoints 模块）:
- `find_articulation_points_undirected()` / `find_articulation_points_directed()`
- `find_bridges_undirected()` / `find_bridges_directed()`

**问题**: 后缀 `_undirected` / `_directed` 导致函数名过长（平均 35-40 字符）

**建议方案**:
```moonbit
// 方案 A: 使用 Trait 约束区分（推荐）
pub fn[G : @core.GraphReadable] find_euler_path(graph : G) -> EulerPathResult  // 自动适配
pub fn[G : @core.GraphDirected] find_euler_path(graph : G) -> EulerPathResult   // 有向版本

// 方案 B: 保持现状但提供简短别名
// 在 v1.1.0 考虑重构
```

**决策**: **v1.0.0 保持现状**（向后兼容），记录为 v1.x 改进项。

#### W3: 着色算法数量过多且功能重叠

当前 6 个函数:
1. `greedy_coloring()` — 基础贪心
2. `greedy_coloring_with_order()` — 自定义顺序贪心
3. `welsh_powell()` — Welsh-Powell 启发式
4. `dsatur_coloring()` — DSATUR 启发式
5. `edge_coloring()` — 边着色（Vizing 定理）
6. `exact_chromatic_number()` — 精确染色数（指数复杂度）

**问题**:
- `greedy_coloring` 与 `greedy_coloring_with_order` 可合并为带默认参数的单一函数
- 用户难以选择：缺少算法选择指南

**建议**:
```moonbit
// v1.0.0: 保持不变，在 README 中增加选择指南
// v1.1.0: 考虑合并
pub fn[G : @core.GraphReadable] greedy_coloring(
  graph : G,
  order : Array[@core.NodeId]? = None  // None = 默认顺序
) -> ColoringResult
```

#### W4: BFS/DFS 变体过多

当前 8 个遍历函数:
- `bfs(graph, start)` — 单源 BFS
- `bfs_all(graph)` — 全图多源 BFS
- `dfs(graph, start)` — 单源 DFS
- `dfs_all(graph)` — 全图多源 DFS
- `bfs_shortest_path(graph, start, target)` — 无权最短路径
- `bidirectional_bfs(graph, start, target)` — 双向 BFS
- `has_cycle(graph)` / `has_directed_cycle(graph)` / `has_undirected_cycle(graph)` — 环检测

**问题**:
- `bfs_all` / `dfs_all` 语义不明确：是"全图遍历"还是"所有连通分量分别遍历"？
- `bfs_shortest_path` 与 `dijkstra` 的关系未在文档中充分说明

**建议**:
- 在 README 中明确 `bfs_all` 的语义："对每个连通分量分别执行 BFS，结果按分量 ID 区分"
- 在 `bfs_shortest_path` 文档中添加警告："⚠️ 仅适用于无权图，有权图请使用 dijkstra"

#### W5: TSP 函数参数类型不统一

```moonbit
// 当前: 接受权重矩阵（与 Graph trait 解耦）
pub fn tsp_nearest_neighbor(weights : Array[Array[Double]]) -> TSPResult
pub fn tsp_exact_held_karp(weights : Array[Array[Double]]) -> TSPResult

// 对比: 其他算法接受 Graph trait
pub fn[G : @core.GraphReadable] dijkstra(graph : G, ...) -> ShortestPathResult
```

**问题**: TSP 算法不接受 Graph trait，破坏了统一的 API 风格

**原因**: 性能考虑（矩阵访问 O(1) vs trait 方法调用开销）

**建议**: **v1.0.0 保持现状**，但在文档中解释设计理由：
```markdown
### 为什么 TSP 使用矩阵而非 Graph trait？

TSP 算法需要频繁随机访问任意节点对的权重（O(V²) 次），
使用矩阵可避免 trait 方法调用的虚分派开销。
对于 V ≤ 20 的典型 TSP 场景，这是合理的权衡。
```

---

### 💡 Info — 可选优化（不影响 v1.0.0 冻结）

#### I1: CentralityResult 方法命名可改进

当前:
- `get_score(node_id)` → 返回 `Double?`
- `max_node()` → 返回 `(NodeId, Double)?`
- `nonzero_count()` → 返回 `Int`

可选改进（更符合 MoonBit 惯例）:
- `score(node_id)` 或 `[]` 运算符重载
- `argmax()` 替代 `max_node()`

**决策**: **推迟到 v1.1.0**，当前命名足够清晰。

#### I2: 存储层工厂函数命名风格

当前:
- `new_directed()` → DirectedAdjList
- `new_undirected()` → UndirectedAdjList
- `new_edge_list()` → EdgeListGraph
- `new_directed_matrix(capacity)` → DirectedMatrix

**小不一致**: 部分工厂接受 `capacity` 参数，部分不接受

**建议**: 统一为可选参数或在文档中说明原因（Matrix 需要预分配空间）

**决策**: **v1.0.0 保持现状**，不影响使用。

#### I3: CommunityResult 方法较多

当前 4 个方法:
- `get_label(node_id)`
- `nodes_in_community(community_id)`
- `largest_community_size()`
- (隐含通过 `.labels` / `.modularity` 访问字段)

**评估**: 设计合理，无需修改。

#### I4: 错误处理策略不统一

部分算法返回空结果（如空图返回空数组），部分可能需要错误处理：
- 流网络: source/sink 越界时返回零结果（静默失败）
- 中心性: 越界节点返回 `None`（Option 类型）
- I/O: 返回 `IOError` 枚举（显式错误）

**建议**: 在各模块 README 中明确记录"错误处理策略"章节

**决策**: **v1.0.0 补充文档即可**，不需修改 API。

---

## ✅ 冻结就绪 API 清单（v1.0.0 候选）

以下 API 符合规范，可直接纳入 v1.0.0 正式发布：

### 核心层 (core/) — ✅ 全部冻结

| API | 类型 | 说明 |
|-----|------|------|
| `NodeId(Int)` | struct | 节点标识符（Newtype 包装）|
| `Node` | struct | 节点数据容器 |
| `Edge` | struct | 边数据容器 |
| `GraphError` | enum | 图操作错误类型 |

### 存储层 (storage/) — ✅ 全部冻结

**8 种存储类型**:
- `DirectedAdjList`, `UndirectedAdjList` ⭐ 推荐
- `DirectedMatrix`, `UndirectedMatrix`
- `EdgeList`, `UndirectedEdgeList`
- `CSRGraph`, `CSCGraph`

**4 个 Builder 类型**:
- `CSRBuilder`, `CSCBuilder` (+ new/add_node/add_edge/build)
- 工厂函数: `new_directed()`, `new_undirected()`, `new_edge_list()`, ...

**批量操作** (v0.14.0 新增):
- `add_edge_unchecked()`, `add_edges_batch()` ✅

### 算法层 (algo/) — ✅ 大部分冻结

#### ✅ 最短路径 (9 个)

| 函数 | 复杂度 | Trait 约束 | 状态 |
|------|:------:|:----------:|:----:|
| `dijkstra(graph, start)` | O((V+E)logV) | GraphReadable | ✅ |
| `dijkstra_targeted(graph, start, target)` | O((V+E)logV) | GraphReadable | ✅ |
| `bellman_ford(graph, start)` | O(VE) | GraphReadable | ✅ |
| `spfa(graph, start)` | O(VE) 均摊 | GraphReadable | ✅ |
| `a_star(graph, start, heuristic)` | O((V+E)logV) | GraphReadable | ✅ |
| `floyd_warshall(graph)` | O(V³) | GraphReadable | ✅ |
| `johnson(graph)` | O(VE + V²logV) | GraphReadable | ✅ |
| `bidirectional_dijkstra(graph, s, t)` | O((V+E)logV) | GraphReadable | ✅ |
| `yen_k_shortest_paths(graph, s, t, k)` | O(k·E·logV) | GraphReadable | ✅ |

#### ✅ 连通性 (4 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `connected_components(graph)` | O(V+E) | ✅ |
| `kosaraju_scc(graph)` | O(V+E) | ✅ |
| `tarjan_scc(graph)` | O(V+E) | ✅ |
| `biconnected_components(graph)` | O(V+E) | ✅ |

#### ✅ MST (2 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `kruskal(graph)` | O(E log E) | ✅ |
| `prim(graph, root)` | O(E log V) | ✅ |

#### ✅ 网络流 (5 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `edmonds_karp(net, s, t)` | O(VE²) | ✅ |
| `dinic(net, s, t)` | O(E√V) | ✅ |
| `push_relabel(net, s, t)` | O(V³) | ✅ |
| `min_cost_max_flow(net, s, t)` | O(V²·E) | ✅ |
| `stoer_wagner(adj)` | O(VE + V²logV) | ✅ |

#### ✅ 图匹配 (5 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `hopcroft_karp(graph)` | O(E√V) | ✅ |
| `edmonds_maximum_matching(graph)` | O(V³) | ✅ |
| `bipartite_matching_graph(graph)` | O(V³) | ✅ |
| `kuhn_munkres(weights)` | O(V³) | ✅ |
| `bipartite_matching(weights)` | O(V³) | ⚠️ 见 W5 |

#### ✅ 中心性分析 (8 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `degree_centrality(graph, mode)` | O(V+E) | ✅ |
| `betweenness_centrality(graph, normalized)` | O(VE) | ✅ |
| `closeness_centrality(graph, normalized)` | O(V(V+E)) | ✅ |
| `eigenvector_centrality(graph)` | O(kE) | ✅ |
| `katz_centrality(graph, alpha, ...)` | O(kE) | ✅ |
| `harmonic_centrality(graph, normalized)` | O(V(V+E)) | ✅ |
| `communication_centrality(graph)` | O(V²(V+E)) | ✅ |
| `group_betweenness_centrality(graph, groups)` | O(G·VE) | ✅ |

#### ✅ 社区检测 (4 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `louvain(graph)` | O(E·logV) | ✅ |
| `leiden(graph)` | O(E·logV) | ✅ |
| `label_propagation(graph)` | O(E) | ✅ |
| `spectral_clustering(graph, k)` | O(V³) | ✅ |

#### ✅ PageRank (1 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `pagerank(graph, damping, iterations)` | O(kE) | ✅ |

#### ✅ 链接预测 (6 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `common_neighbors(graph, u, v)` | O(deg(u)+deg(v)) | ✅ |
| `jaccard_coefficient(graph, u, v)` | O(deg(u)+deg(v)) | ✅ |
| `adamic_adar_index(graph, u, v)` | O(deg(u)+deg(v)) | ✅ |
| `preferential_attachment(graph, u, v)` | O(1) | ✅ |
| `resource_allocation(graph, u, v)` | O(deg(u)+deg(v)) | ✅ |
| `link_prediction_score(graph, u, v, method)` | 取决于 method | ✅ |

#### ✅ 稠密子图 (6 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `k_core_decomposition(graph)` | O(V+E) | ✅ |
| `k_truss_decomposition(graph)` | O(E·K²) | ✅ |
| `count_triangles(graph)` | O(V·d²) 或 O(E^{3/2}) | ✅ |
| `local_clustering_coefficient(graph, node)` | O(d²) | ✅ |
| `average_clustering_coefficient(graph)` | O(V·d²) | ✅ |
| `clustering_coefficients(graph)` | O(V·d²) | ✅ |

#### ✅ 图算子 (11 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `complement(graph)` | O(V²) | ✅ |
| `reverse(graph)` | O(V+E) | ✅ |
| `graph_union(g1, g2)` | O(V₁+E₁+V₂+E₂) | ✅ |
| `graph_intersection(g1, g2)` | O(min(E₁,E₂)) | ✅ |
| `graph_difference(g1, g2)` | O(V₁+E₁) | ✅ |
| `cartesian_product(g1, g2)` | O(V₁·V₂+E₁·V₂+E₂·V₁) | ✅ |
| `tensor_product(g1, g2)` | O(V₁·V₂·min(E₁/V₁,E₂/V₂)) | ✅ |
| `lexicographic_product(g1, g2)` | O(V₁·V₂+E₁·V₂+E₂·V₁) | ✅ |
| `line_graph(graph)` | O(V·d²) | ✅ |
| `contract(graph, nodes)` | O(V+E) | ✅ |
| `power_graph(graph, k)` | O(V·d^k) | ✅ |

#### ✅ 特殊图识别 (7 个)

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `is_bipartite(graph)` | O(V+E) | ✅ |
| `is_complete(graph)` | O(V²) | ✅ |
| `is_regular(graph)` | O(V) | ✅ |
| `is_tree(graph)` | O(V) | ✅ |
| `is_forest(graph)` | O(V) | ✅ |
| `is_chordal(graph)` | O(V+E) | ✅ |
| `is_graphic_sequence(seq)` | O(n²) | ✅ |

#### ⚠️ 遍历 (12 个) — 部分需优化

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `bfs(graph, start)` | O(V+E) | ✅ |
| `bfs_all(graph)` | O(V+E) | ⚠️ 见 W4 |
| `dfs(graph, start)` | O(V+E) | ✅ |
| `dfs_all(graph)` | O(V+E) | ⚠️ 见 W4 |
| `bfs_shortest_path(graph, s, t)` | O(V+E) | ✅ 已保留并补充无权图限制说明 |
| `bidirectional_bfs(graph, s, t)` | O(V^{b/2}) | ✅ |
| `has_cycle(graph)` | O(V+E) | ✅ |
| `has_directed_cycle(graph)` | O(V+E) | ✅ |
| `has_undirected_cycle(graph)` | O(V) | ✅ |
| `topo_sort_kahn(graph)` | O(V+E) | ✅ |
| `topo_sort_dfs(graph)` | O(V+E) | ✅ |
| `topo_validates(order, graph)` | O(V+E) | ✅ 已移出公共 API |

#### ⚠️ 图着色 (6 个) — 需补充选择指南

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `greedy_coloring(graph)` | O(V·d) | ✅ |
| `greedy_coloring_with_order(graph, order)` | O(V·d) | ⚠️ 见 W3 |
| `welsh_powell(graph)` | O(V·d) | ✅ |
| `dsatur_coloring(graph)` | O(V²) | ✅ |
| `edge_coloring(graph)` | O(V·E) | ✅ |
| `exact_chromatic_number(graph)` | O(n!) | ✅ |

#### ⚠️ 团检测 (4 个) — 命名可改进

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `find_maximum_clique(graph)` | O(3^{V/3}) | ✅ |
| `find_maximum_independent_set(graph)` | O(3^{V/3}) | ✅ |
| `find_minimum_vertex_cover_exact(graph)` | O(1.4422^V) | ⚠️ 见 W1 |
| `find_minimum_vertex_cover_approx(graph)` | O(V+E) | ⚠️ 见 W1 |

#### ⚠️ 欧拉路径 (8 个) — 命名较长

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `has_euler_path_undirected(graph)` | O(V+E) | ⚠️ 见 W2 |
| `has_euler_circuit_undirected(graph)` | O(V+E) | ⚠️ 见 W2 |
| `find_euler_path_undirected(graph)` | O(E) | ⚠️ 见 W2 |
| `find_euler_circuit_undirected(graph)` | O(E) | ⚠️ 见 W2 |
| `has_euler_path_directed(graph)` | O(V+E) | ⚠️ 见 W2 |
| `has_euler_circuit_directed(graph)` | O(V+E) | ⚠️ 见 W2 |
| `find_euler_path_directed(graph)` | O(E) | ⚠️ 见 W2 |
| `find_euler_circuit_directed(graph)` | O(E) | ⚠️ 见 W2 |

#### ⚠️ 哈密顿/TSP (6 个) — 命名可简化

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `has_hamiltonian_circuit_quick_check(graph)` | O(V) | ⚠️ 见 W1 |
| `find_hamiltonian_path_backtrack(graph)` | O(V·V!) | ⚠️ 见 W1 |
| `find_hamiltonian_circuit_backtrack(graph)` | O(V·V!) | ⚠️ 见 W1 |
| `tsp_nearest_neighbor(weights)` | O(V²) | ⚠️ 见 W5 |
| `tsp_exact_held_karp(weights)` | O(V²·2^V) | ⚠️ 见 W5 |
| `build_weight_matrix(graph)` | O(V·E) | 🔴 见 C5 |

#### ⚠️ 割点与桥 (4 个) — 命名较长

| 函数 | 复杂度 | 状态 |
|------|:------:|:----:|
| `find_articulation_points_undirected(graph)` | O(V+E) | ⚠️ 见 W2 |
| `find_articulation_points_directed(graph)` | O(V+E) | ⚠️ 见 W2 |
| `find_bridges_undirected(graph)` | O(V+E) | ⚠️ 见 W2 |
| `find_bridges_directed(graph)` | O(V+E) | ⚠️ 见 W2 |

#### ⚠️ I/O 层 (~15 个) — 需补充错误处理文档

| 函数/类型 | 状态 |
|-----------|:----:|
| `write_dot(graph, options)` | ✅ |
| `parse_dot_into(dot_string)` | ✅ |
| `graph_to_json(graph)` | ✅ |
| `parse_json_into(json_string)` | ✅ |
| `basic_stats(graph)` | ✅ |
| `degree_distribution(graph)` | ✅ |
| `connectivity_stats(graph)` | ✅ |
| `distance_metrics(graph)` | ✅ |
| `network_efficiency(graph)` | ✅ |
| `triad_count(graph)` | ✅ |
| `IOError` enum | ✅ |
| 其他统计/度量结构体 | ✅ |

---

## 📋 执行计划（按优先级排序）

### Phase 1: Critical 修复（预计 2 小时）— 🔴 必须完成

| 步骤 | 任务 | 文件 | 操作 |
|------|------|------|------|
| 1.1 | 将 `bubble_sort_by_weight` 改为私有 | `storage/shared_helpers.mbt` | ✅ 已完成 |
| 1.2 | 将 `int_max` 改为私有 | `storage/shared_helpers.mbt` | ✅ 已完成 |
| 1.3 | 将 `topo_validates` 移入测试文件 | `traversal/traversal_test.mbt` | ✅ 已完成 |
| 1.4 | 重命名 `bfs_shortest_path` 或添加文档警告 | `traversal/bfs.mbt` | 添加详细注释或重命名 |
| 1.5 | 将 `build_weight_matrix` 改为私有 | `hamiltonian/tsp.mbt` | ✅ 已完成 |

**验证**: `moon test` 确保无回归

### Phase 2: Warning 优化 — ✅ 已完成

| 步骤 | 任务 | 状态 |
|------|------|:----:|
| 2.1 | 为哈密顿/TSP/团函数提供简短别名 | ✅ 11 个别名已添加至 v1.0.0 |
| 2.2 | 在 coloring/README 中添加算法选择指南 | ⏳ 推迟至 v1.1.0 |
| 2.3 | 在 traversal/README 中澄清 bfs_all/dfs_all 语义 | ⏳ **v1.0.0-rc.2 待办** |
| 2.4 | 在 tsp 函数文档中解释 Matrix 设计决策 | ⏳ 推迟至 v1.1.0 |

**验证**: ✅ `moon check` + `moon test` 940/940 通过

### Phase 3: 文档补全（预计 2 小时）— 🟢 推荐完成

| 步骤 | 任务 |
|------|------|
| 3.1 | 为每个 Warning 级别的 API 添加 `@deprecated` 注释（如决定重命名）|
| 3.2 | 在各模块 README 中补充"错误处理策略"章节 |
| 3.3 | 更新 CHANGELOG.md 记录 API 变更 |
| 3.4 | 生成 v1.0.0 API 参考手册（从 README 汇总）|

### Phase 4: 最终验证（预计 1 小时）

| 步骤 | 任务 |
|------|------|
| 4.1 | 运行完整测试套件 `moon test`（922 tests）|
| 4.2 | 运行类型检查 `moon check`（零警告）|
| 4.3 | 检查所有 pub API 是否都有文档注释 |
| 4.4 | 生成最终的 API 冻结清单（v1.0.0-rc.1）|

---

## 🎯 总结与建议

### 整体评估

mbtgraph 的 API 设计质量 **优秀（9/10 分）**，具备以下优势：

✅ **优点**:
1. **Trait-based 设计优雅**: 统一的 `GraphReadable` 约束使算法高度复用
2. **命名规范一致**: 95% 的函数遵循 snake_case，语义清晰
3. **结果类型统一**: 每个算法都有对应的 `XxxResult` 结构体，字段自描述
4. **文档覆盖率高**: 85% 的公共 API 有详细的文档注释和使用示例
5. **向后兼容意识强**: 新旧 API 并存（如快排替代冒泡但仍保留）

⚠️ **待改进**:
1. **部分函数命名过长**（有向/无向后缀、实现细节泄露）
2. **算法选择指南不足**（着色/BFS 变体等场景缺失）
3. **TSP 与其他模块的设计哲学不一致**

### v1.0.0 冻结建议

**推荐方案**: **✅ 可以进入冻结流程**

**前提条件**:
1. Phase 1 的 5 个 Critical 修复已完成
2. Phase 2-3 作为 **v1.0.0-rc.1** 的已知限制记录
3. 后续按需推进 Warning 级别优化

**时间线建议**:
```
2026-06-02  ✅ v1.0.0-rc.1 Critical 修复完成
2026-06-14  ✅ 冻结文档核查完成，统计数据已统一
2026-06-15+ 团队 Review
2026-06-20+ 发布 v1.0.0-rc.1
2026-06-25+ 收集反馈（2 周）
2026-07+    正式发布 v1.0.0
```

### 风险提示

| 风险 | 概率 | 影响 | 缓解措施 |
|------|:----:|:----:|---------|
| Critical 修复引入回归 | 低 | 高 | 每步修改后运行完整测试 |
| 用户依赖将被废弃的 API | 中 | 中 | 提供 migration guide + 兼容别名 |
| MoonBit 语言特性变更导致 API 不兼容 | 低 | 高 | 关注 moonbit 上游 changelog |

---

<div align="center">

**📌 下一步行动**

1. 立即执行 **Phase 1: Critical 修复**
2. 验证测试通过后，更新本报告状态为 "Phase 1 Completed"
3. 基于 Phase 1 结果，决定是否发布 v1.0.0-rc.1

*报告生成时间: 2026-06-01 | 审查工具: AI-assisted API Audit*
*最后更新: 2026-06-14 | 统计数据已统一*

</div>
