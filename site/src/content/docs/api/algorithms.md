---
title: 各算法模块 API
description: 所有算法函数的签名、参数、返回类型和模块索引
---

# 各算法模块 API

> 模块路径: `lib/algo/` · 19 个子模块 · 65+ 算法

---

## 一、图遍历 (traversal)

```moonbit
// Trait 约束: GraphReadable
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult
pub fn[G : @core.GraphReadable] dfs(graph : G, start : NodeId) -> DfsResult
pub fn[G : @core.GraphReadable] bidirectional_bfs(graph : G, start : NodeId, target : NodeId) -> Array[NodeId]?
pub fn[G : @core.GraphReadable] topological_sort(graph : G) -> Array[NodeId]
pub fn[G : @core.GraphReadable] topological_sort_kahn(graph : G) -> Array[NodeId]
pub fn[G : @core.GraphReadable] cycle_detection(graph : G) -> Bool
```

| 函数 | 返回 | 说明 |
|------|:----:|------|
| `bfs` | `BfsResult` | BFS 遍历顺序与距离 |
| `dfs` | `DfsResult` | DFS 遍历顺序与分类 |
| `bidirectional_bfs` | `Array[NodeId]?` | 双向搜索最短路径 |
| `topological_sort` | `Array[NodeId]` | Kahn 算法拓扑排序 |
| `topological_sort_kahn` | `Array[NodeId]` | Kahn 算法（显式） |
| `cycle_detection` | `Bool` | 检测有向图环 |

---

## 二、最短路径 (shortest_path)

```moonbit
pub fn[G : @core.GraphReadable] dijkstra(graph : G, source : NodeId) -> ShortestPathResult
pub fn[G : @core.GraphReadable] bellman_ford(graph : G, source : NodeId) -> ShortestPathResult
pub fn[G : @core.GraphReadable] floyd_warshall(graph : G) -> AllPairsShortestPathResult
pub fn[G : @core.GraphReadable] a_star(graph : G, start : NodeId, target : NodeId, heuristic : (NodeId) -> Double) -> Array[NodeId]
// 其他: johnson, spfa, bidirectional_dijkstra, yen_k_shortest_paths
```

| 函数 | 约束 | 复杂度 | 说明 |
|------|:----:|:------:|------|
| `dijkstra` | 非负权 | O(E log V) | ⭐ 单源默认选择 |
| `bellman_ford` | 可含负权 | O(VE) | 负权检测 |
| `floyd_warshall` | 任意 | O(V³) | 全源最短路径 |
| `a_star` | 非负权+启发式 | O(b^d) | 启发式加速搜索 |

---

## 三、最小生成树 (mst)

```moonbit
// Kruskal: 需要 GraphReadable
pub fn[G : @core.GraphReadable] kruskal(graph : G) -> MstResult

// Prim: 需要 GraphReadable
pub fn[G : @core.GraphReadable] prim(graph : G, root : NodeId) -> MstResult
```

| 结果方法 | 返回 | 说明 |
|---------|:----:|------|
| `MstResult.total_weight` | `Double` | MST 总权重 |
| `MstResult.edges` | `Array[(NodeId,NodeId,Double)]` | MST 边列表 |
| `MstResult.edge_count()` | `Int` | MST 边数 |
| `MstResult.has_edge(u,v)` | `Bool` | 检查某条边是否在 MST 中 |

---

## 四、连通性 (connectivity)

```moonbit
pub fn[G : @core.GraphReadable] connected_components(graph : G) -> ConnectedComponentsResult
pub fn[G : @core.GraphDirected] tarjan_scc(graph : G) -> StronglyConnectedComponentsResult
pub fn[G : @core.GraphDirected] kosaraju_scc(graph : G) -> StronglyConnectedComponentsResult
pub fn[G : @core.GraphReadable] biconnected_components(graph : G) -> BiconnectedComponentsResult
```

---

## 五、网络流 (flow)

使用独立 `FlowNetwork` / `CostFlowNetwork` 类型（非 Trait 约束）。

```moonbit
// 流网络构造
let net = FlowNetwork::new(node_count)
let net = net.add_edge(from, to, capacity)

// 费用流网络构造
let net = CostFlowNetwork::new(node_count)
let net = net.add_edge(from, to, capacity, cost)

// 算法
pub fn edmonds_karp(graph : FlowNetwork, source : Int, sink : Int) -> MaxFlowResult
pub fn dinic(graph : FlowNetwork, source : Int, sink : Int) -> MaxFlowResult
pub fn min_cost_max_flow(graph : CostFlowNetwork, source : Int, sink : Int) -> MinCostMaxFlowResult
pub fn push_relabel(graph : FlowNetwork, source : Int, sink : Int) -> MaxFlowResult
pub fn capacity_scaling(graph : FlowNetwork, source : Int, sink : Int) -> MaxFlowResult
pub fn stoer_wagner(adj : Array[Array[Double]]) -> StoerWagnerResult
```

---

## 六、图匹配 (matching)

```moonbit
// 二分图匹配（邻接表版）
pub fn bipartite_matching(n_left : Int, n_right : Int, edges : Array[(Int, Int)]) -> MatchingResult

// 二分图匹配（图结构版）
pub fn[G : @core.GraphReadable] bipartite_matching_graph(graph : G, left : Array[NodeId], right : Array[NodeId]) -> MatchingResult

// Hopcroft-Karp（大规模二分图）
pub fn[G : @core.GraphReadable] hopcroft_karp(graph : G, left : Array[NodeId], right : Array[NodeId]) -> MatchingResult

// 一般图最大匹配（开花算法）
pub fn[G : @core.GraphReadable] edmonds_maximum_matching(graph : G) -> MatchingResult

// 最大权匹配 (Kuhn-Munkres)
pub fn kuhn_munkres(weights : Array[Array[Double]]) -> KMMatchingResult
```

---

## 七、图着色 (coloring)

```moonbit
pub fn[G : @core.GraphReadable] greedy_coloring(graph : G) -> ColoringResult
pub fn[G : @core.GraphReadable] greedy_coloring_with_order(graph : G, order : Array[Int]) -> ColoringResult
pub fn[G : @core.GraphReadable] welsh_powell(graph : G) -> ColoringResult
pub fn[G : @core.GraphReadable] dsatur_coloring(graph : G) -> ColoringResult
pub fn[G : @core.GraphReadable] edge_coloring(graph : G) -> EdgeColoringResult
pub fn[G : @core.GraphReadable] exact_chromatic_number(graph : G, time_limit_ms : Int) -> ChromaticNumberResult
```

---

## 八、社区检测 (community)

```moonbit
pub fn[G : @core.GraphReadable] louvain(graph : G, resolution : Double) -> CommunityResult
pub fn[G : @core.GraphReadable] leiden(graph : G, resolution : Double) -> CommunityResult
pub fn[G : @core.GraphReadable] label_propagation(graph : G, max_iterations : Int) -> CommunityResult
pub fn[G : @core.GraphReadable] spectral_clustering(graph : G, k : Int) -> CommunityResult
```

---

## 九、中心性 (centrality)

```moonbit
pub fn[G : @core.GraphReadable] degree_centrality(graph : G, mode : DegreeMode) -> CentralityResult
pub fn[G : @core.GraphReadable] betweenness_centrality(graph : G, normalized : Bool) -> CentralityResult
pub fn[G : @core.GraphReadable] closeness_centrality(graph : G, normalized : Bool) -> CentralityResult
pub fn[G : @core.GraphReadable] eigenvector_centrality(graph : G, max_iter : Int, tolerance : Double) -> CentralityResult
pub fn[G : @core.GraphReadable] katz_centrality(graph : G, alpha : Double, beta : Double) -> CentralityResult
pub fn[G : @core.GraphReadable] harmonic_centrality(graph : G, normalized : Bool) -> CentralityResult
```

---

## 十、PageRank

```moonbit
pub fn[G : @core.GraphReadable] pagerank(graph : G, damping_factor : Double, max_iterations : Int) -> PageRankResult
```

| 结果方法 | 说明 |
|---------|------|
| `get_rank(node)` | 获取节点 PageRank 值 |
| `top_nodes(k)` | 获取 Top-K 节点 |
| `total_rank()` | 所有节点 PR 值之和 |

---

## 十一、欧拉路径 (euler)

```moonbit
pub fn[G : @core.GraphReadable] has_euler_path(graph : G) -> Bool
pub fn[G : @core.GraphReadable] has_euler_circuit(graph : G) -> Bool
pub fn[G : @core.GraphReadable] find_euler_path(graph : G) -> EulerPathResult
pub fn[G : @core.GraphReadable] find_euler_circuit(graph : G) -> EulerCircuitResult
// 有向图版: has_euler_path_directed, find_euler_path_directed 等
```

---

## 十二、割点与桥 (cutpoints)

```moonbit
pub fn[G : @core.GraphReadable] find_articulation_points(graph : G) -> CutPointResult
pub fn[G : @core.GraphReadable] find_bridges(graph : G) -> BridgeResult
pub fn[G : @core.GraphDirected] find_articulation_points_directed(graph : G) -> CutPointResult
pub fn[G : @core.GraphDirected] find_bridges_directed(graph : G) -> BridgeResult
```

---

## 十三、团检测 (clique)

```moonbit
pub fn[G : @core.GraphReadable] find_maximum_clique(graph : G) -> CliqueResult
pub fn[G : @core.GraphReadable] find_maximum_independent_set(g : G) -> IndependentSetResult
pub fn[G : @core.GraphReadable] find_minimum_vertex_cover(g : G) -> VertexCoverResult
```

---

## 十四、稠密子图 (dense_subgraph)

```moonbit
pub fn[G : @core.GraphReadable] k_core_decomposition(graph : G) -> KCoreResult
pub fn[G : @core.GraphReadable] k_truss_decomposition(graph : G) -> KTrussResult
pub fn[G : @core.GraphReadable] count_triangles(graph : G) -> TriangleCountResult
pub fn[G : @core.GraphReadable] local_clustering_coefficient(graph : G, node : NodeId) -> Double
pub fn[G : @core.GraphReadable] average_clustering_coefficient(graph : G) -> Double
```

---

## 十五、链接预测 (link_prediction)

```moonbit
pub fn[G : @core.GraphReadable] common_neighbors(graph : G, u : NodeId, v : NodeId) -> Int
pub fn[G : @core.GraphReadable] jaccard_coefficient(graph : G, u : NodeId, v : NodeId) -> Double
pub fn[G : @core.GraphReadable] adamic_adar(graph : G, u : NodeId, v : NodeId) -> Double
pub fn[G : @core.GraphReadable] preferential_attachment(graph : G, u : NodeId, v : NodeId) -> Double
pub fn[G : @core.GraphReadable] resource_allocation(graph : G, u : NodeId, v : NodeId) -> Double
```

---

## 十六、哈密顿路径与 TSP (hamiltonian)

```moonbit
// 哈密顿路径/回路（回溯搜索 + 快速检查）
pub fn[G : @core.GraphReadable] has_hamiltonian_circuit_quick_check(graph : G) -> Bool
pub fn[G : @core.GraphReadable] find_hamiltonian_path(graph : G) -> HamiltonianResult
pub fn[G : @core.GraphReadable] find_hamiltonian_circuit(graph : G) -> HamiltonianResult
pub fn[G : @core.GraphReadable] find_hamiltonian_path_backtrack(graph : G) -> HamiltonianResult
pub fn[G : @core.GraphReadable] find_hamiltonian_circuit_backtrack(graph : G) -> HamiltonianResult
pub fn[G : @core.GraphReadable] can_have_hamiltonian_circuit(graph : G) -> Bool

// TSP（旅行商问题）
pub fn tsp_nearest_neighbor(weights : Array[Array[Double]]) -> TSPResult
pub fn tsp_exact_held_karp(weights : Array[Array[Double]]) -> TSPResult
```

| 函数 | 类型 | 复杂度 | 说明 |
|------|:----:|:------:|------|
| `find_hamiltonian_path` | 回溯 | O(n!) | 查找哈密顿路径 |
| `find_hamiltonian_circuit` | 回溯 | O(n!) | 查找哈密顿回路 |
| `can_have_hamiltonian_circuit` | 检查 | O(V) | Dirac 必要条件（度 ≥ n/2） |
| `tsp_nearest_neighbor` | 启发式 | O(V²) | 近似解（无最优保证） |
| `tsp_exact_held_karp` | 精确 DP | O(V²2^V) | Held-Karp 动态规划（V ≤ 20） |

---

## 十七、图算子 (operators)

对已有图进行结构变换，返回新的图实例，不修改原图。

```moonbit
// 一元算子
pub fn[G : @core.GraphReadable] complement(graph : G) -> @storage.UndirectedAdjList
pub fn[G : @core.GraphReadable] reverse(graph : G) -> @storage.DirectedAdjList
pub fn[G : @core.GraphReadable] line_graph(graph : G) -> @storage.UndirectedAdjList
pub fn[G : @core.GraphReadable] contract(graph : G, u : NodeId, v : NodeId) -> @storage.UndirectedAdjList
pub fn[G : @core.GraphReadable] power_graph(graph : G, k : Int) -> @storage.UndirectedAdjList

// 二元算子
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_union(a : G1, b : G2) -> @storage.UndirectedAdjList
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_intersection(a : G1, b : G2) -> @storage.UndirectedAdjList
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_difference(a : G1, b : G2) -> @storage.UndirectedAdjList
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] cartesian_product(a : G1, b : G2) -> @storage.UndirectedAdjList
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] tensor_product(a : G1, b : G2) -> @storage.UndirectedAdjList
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] lexicographic_product(a : G1, b : G2) -> @storage.UndirectedAdjList
```

| 算子 | 返回 | 说明 |
|------|:----:|------|
| `complement` | `UndirectedAdjList` | 补图（含边 ⇔ 不含边） |
| `reverse` | `DirectedAdjList` | 有向边全部反向 |
| `graph_union` | `UndirectedAdjList` | 并图（节点和边的并集） |
| `graph_intersection` | `UndirectedAdjList` | 交图（边集交集） |
| `graph_difference` | `UndirectedAdjList` | 差图（在 a 中但不在 b 中的边） |
| `cartesian_product` | `UndirectedAdjList` | 笛卡尔积 |
| `tensor_product` | `UndirectedAdjList` | 张量积 (Kronecker 积) |
| `lexicographic_product` | `UndirectedAdjList` | 字典序积 |
| `line_graph` | `UndirectedAdjList` | 线图（边 → 节点） |
| `contract` | `UndirectedAdjList` | 收缩边 (u,v)，合并为超节点 |
| `power_graph` | `UndirectedAdjList` | k 次幂图（距离 ≤ k 连边） |

---

## 十八、特殊图识别 (recognition)

判断图是否满足某种特殊图性质，统一返回 `Bool`。

```moonbit
// 图结构判定
pub fn[G : @core.GraphReadable] is_bipartite(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_complete(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_regular(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_tree(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_forest(graph : G) -> Bool
pub fn[G : @core.GraphReadable] is_chordal(graph : G) -> Bool

// 序列可图化判定（Havel-Hakimi 定理）
pub fn is_graphic_sequence(seq : Array[Int]) -> Bool
```

| 函数 | 复杂度 | 说明 |
|------|:------:|------|
| `is_bipartite` | O(V+E) | BFS 2-染色判定 |
| `is_complete` | O(V²) | 检查每对节点是否都有边 |
| `is_regular` | O(V) | 检查所有节点度数是否相同 |
| `is_tree` | O(V+E) | 检查是否无环且连通 |
| `is_forest` | O(V+E) | 检查是否无环（不要求连通） |
| `is_chordal` | O(V+E) | 弦图判定（最小完美消除序） |
| `is_graphic_sequence` | O(V²) | Havel-Hakimi 算法 |

---

**相关文档：**
- [Core 模块接口](/api/core/)
- [Storage 模块接口](/api/storage/)
- [IO 模块接口](/api/io/)
- [算法总览](/algorithms/index/)
