# mbtgraph API Surface v1.1.0

> **冻结日期**: 2026-06-14 | **当前版本**: v1.1.0
> **原则**: 所有 pub API 在 v1.x 中保持兼容，破坏性变更需 major 版本

---

## 1. 核心类型 (`lib/core/`)

### 基础类型

| 类型 | 定义 | 说明 |
|------|------|------|
| `NodeId` | `pub(all) struct NodeId(Int)` | 节点唯一标识符，Newtype 模式 |
| `Node` | `pub(all) struct Node { id, data }` | 带数据的节点 |
| `Edge` | `pub(all) struct Edge { from, to, data }` | 带数据的边 |

### Trait 层次

```
GraphReadable (12 methods, 根 trait)
├── GraphWritable     (5 methods, 动态存储)
├── GraphDirected     (6 methods, 有向扩展)
│   └── GraphFull    = Writable + Directed (组合别名)
└── GraphBatchReadable (2 methods, CSR/CSC 专属)
```

**冻结决策**: 5 个 trait 方法签名已冻结，不计划在 v1.0.0 中修改。

---

## 2. 存储层 (`lib/storage/`)

### 构造函数约定

| 模式 | 示例 | 适用类型 |
|------|------|---------|
| **自由函数** `new_xxx()` | `new_directed()` | AdjList, Matrix, EdgeList |
| **关联函数** `Type::new()` | `CSRBuilder::new()` | CSR/CSC Builder |

**冻结决策**: 两种模式并存，不统一。理由：
- AdjList/Matrix/EdgeList 是轻量构造，自由函数更简洁
- CSR/CSC 是 Builder 模式，关联函数更自然
- 改动影响 466 处调用，风险高于收益

### 存储类型矩阵

| 类型 | 构造函数 | GraphReadable | GraphWritable | GraphDirected | GraphFull | GraphBatchReadable |
|------|---------|:-------------:|:-------------:|:-------------:|:---------:|:------------------:|
| `DirectedAdjList` | `new_directed()` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `UndirectedAdjList` | `new_undirected()` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `DirectedMatrix` | `new_directed_matrix(cap)` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `UndirectedMatrix` | `new_undirected_matrix(cap)` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `EdgeListGraph` | `new_edge_list()` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `UndirectedEdgeListGraph` | `new_undirected_edge_list()` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `CSRGraph` | `CSRBuilder::build()` | ✅ | ❌ | ❌ | ❌ | ✅ |
| `CSCGraph` | `CSCBuilder::build()` | ✅ | ❌ | ❌ | ❌ | ✅ |

### 批量操作 API (v0.14.0 新增)

| 方法 | 签名 | 适用类型 |
|------|------|---------|
| `add_edge_unchecked` | `(self, from, to, data) -> Result[Unit, GraphError]` | DirectedAdjList, UndirectedAdjList |
| `add_edges_batch` | `(self, edges) -> Result[Unit, GraphError]` | DirectedAdjList, UndirectedAdjList |

**冻结决策**: 仅 AdjList 提供批量 API，Matrix/EdgeList 不补充。理由：Matrix/EdgeList 非高频写入场景。

---

## 3. 算法层 (`lib/algo/`)

### 参数命名约定

| 约定 | 示例 | 说明 |
|------|------|------|
| 图参数名 | `graph` | 所有泛型算法统一使用 `graph` |
| 流网络参数名 | `graph` | FlowNetwork 算法也用 `graph` |
| 源/汇参数名 | `source`, `sink` | Int 类型（Flow 模块）|
| 起点参数名 | `start` | NodeId 类型（遍历/最短路径）|

### 返回类型命名约定

所有算法返回 `XxxResult` 结构体，定义在对应 `types.mbt` 中。

| 模块 | 返回类型 | 状态 |
|------|---------|:----:|
| traversal | `TraversalResult`, `BfsResult`, `DfsResult` | ✅ 冻结 |
| shortest_path | `ShortestPathResult`, `KShortestPathsResult`, `FloydWarshallResult` | ✅ 冻结 |
| mst | `MstResult` | ✅ 冻结 |
| connectivity | `ConnectedComponentsResult`, `StronglyConnectedComponentsResult`, `BiconnectedComponentsResult` | ✅ 冻结 |
| flow | `MaxFlowResult`, `MinCostMaxFlowResult`, `StoerWagnerResult` | ✅ 冻结 |
| matching | `MatchingResult`, `KMMatchingResult` | ✅ 冻结 |
| community | `CommunityResult` | ✅ 冻结 |
| centrality | `CentralityResult`, `CommunicationResult` | ✅ 冻结 |
| pagerank | `PageRankResult` | ✅ 冻结 |
| link_prediction | `LinkPredictionResult` | ✅ 冻结 |
| dense_subgraph | `KCoreResult`, `KTrussResult`, `TriangleCountResult`, `ClusteringCoefficientResult` | ✅ 冻结 |
| coloring | `ColoringResult`, `ChromaticNumberResult`, `EdgeColoringResult` | ✅ 冻结 |
| clique | `CliqueResult`, `IndependentSetResult`, `VertexCoverResult` | ✅ 冻结 |
| cutpoints | `CutPointResult`, `BridgeResult` | ✅ 冻结 |
| euler | `EulerPathResult`, `EulerCircuitResult` | ✅ 冻结 |
| hamiltonian | `HamiltonianResult`, `TSPResult` | ✅ 冻结 |

### Result 方法命名约定

| 模式 | 示例 | 说明 |
|------|------|------|
| `get_xxx()` | `get_score()`, `get_label()`, `get_rank()` | 获取单个值 |
| `is_xxx()` | `is_visited()`, `is_matched()`, `is_reachable()` | 布尔查询 |
| `size()` / `count()` | `size()`, `count()`, `edge_count()` | 数量查询 |
| `xxx_to()` | `path_to()`, `distance_to()` | 按节点查询 |
| `nodes_in_xxx()` | `nodes_in_community()` | 成员查询 |

**冻结决策**: `size()`/`count()`/`edge_count()` 语义一致但命名不统一，保持现状。理由：
- 改名影响所有下游代码
- 语义清晰，不会造成混淆

### 算法函数命名约定

| 模式 | 示例 | 适用场景 |
|------|------|---------|
| `算法名()` | `dijkstra()`, `bfs()`, `louvain()` | 单一算法 |
| `问题_算法名()` | `bipartite_matching()`, `bipartite_matching_graph()` | 多实现算法 |
| `is_xxx()` | `is_bipartite()`, `is_tree()`, `is_graphic_sequence()` | 判定函数 |

**冻结决策**: matching 模块 4 种命名风格保持现状。理由：
- `bipartite_matching` / `bipartite_matching_graph` — 问题描述
- `hopcroft_karp` / `edmonds_maximum_matching` / `kuhn_munkres` — 算法名
- 语义清晰，统一改动收益不大

---

## 4. Flow 模块特殊 API

### 独立类型模式

Flow 模块使用独立的 `FlowNetwork` / `CostFlowNetwork` 类型，不继承 `GraphReadable`。

```moonbit
// 链式构造
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)

// 算法调用（Int 节点索引）
let result = dinic(net, 0, 3)
```

**冻结决策**: 保持独立类型模式。理由：
- 流网络的容量/流量矩阵语义不同于通用图
- 矩阵访问 O(1)，适合密集流网络
- 反向边自动管理，对外透明

---

## 5. I/O 模块 (`lib/io/`)

### 导出函数

| 函数 | 签名 | 说明 |
|------|------|------|
| `write_dot` | `[G:GraphReadable](graph, name) -> String` | 导出 DOT 格式 |
| `parse_dot_into` | `[G:GraphWritable](graph, str) -> Result` | 导入 DOT 格式 |
| `graph_to_json` | `[G:GraphReadable](graph, pretty) -> String` | 导出 JSON 格式 |
| `parse_json_into` | `[G:GraphWritable](graph, str) -> Result` | 导入 JSON 格式 |
| `basic_stats` | `[G:GraphReadable](graph) -> GraphStats` | 基础统计 |
| `degree_distribution` | `[G:GraphReadable](graph) -> DegreeDistribution` | 度分布 |
| `connectivity_stats` | `[G:GraphReadable](graph) -> ConnectivityStats` | 连通性统计 |
| `distance_metrics` | `[G:GraphReadable](graph) -> DistanceMetrics` | 距离指标 |
| `network_efficiency` | `[G:GraphReadable](graph) -> NetworkEfficiency` | 网络效率 |
| `triad_counting` | `[G:GraphReadable](graph) -> TriadCount` | 三元组计数 |

### 导出类型

| 类型 | 文件 | 说明 |
|------|------|------|
| `IOError` | types.mbt | I/O 错误枚举 |
| `GraphStats` | types.mbt | 基础统计结果 |
| `ConnectivityStats` | types.mbt | 连通性统计 |
| `DegreeDistribution` | types.mbt | 度分布 |
| `DistanceMetrics` | graph_metrics.mbt | 距离指标 |
| `NetworkEfficiency` | graph_metrics.mbt | 网络效率 |
| `TriadCount` | graph_metrics.mbt | 三元组计数 |
| `DotToken` | dot.mbt | DOT 解析器 token |

**冻结决策**: `DistanceMetrics`/`NetworkEfficiency`/`TriadCount` 保留在 `graph_metrics.mbt`，不迁移到 `types.mbt`。理由：它们是 graph_metrics 专属类型，与 graph_stats 类型语义不同。

---

## 6. 可见性决策

### 已修复 (v0.16.0)

| 文件 | 变更 | 理由 |
|------|------|------|
| `shared_helpers.mbt` | `has_node` `pub fn` → `fn` | 仅 storage 包内使用 |
| `shared_helpers.mbt` | `find_slot` `pub fn` → `fn` | 仅 storage 包内使用 |
| `shared_helpers.mbt` | `remove_from_list` `pub fn` → `fn` | 仅 storage 包内使用 |

### 保持 pub

| 函数 | 理由 |
|------|------|
| `find_max_node_id` | 被 algo 包调用 |

---

## 7. API 简短别名（v1.0.0 Phase 2 新增）

| 模块 | 别名 | 原始名称 |
|------|------|---------|
| euler | `has_euler_path(graph)` | `has_euler_path_undirected(graph)` |
| euler | `has_euler_circuit(graph)` | `has_euler_circuit_undirected(graph)` |
| euler | `find_euler_path(graph)` | `find_euler_path_undirected(graph)` |
| euler | `find_euler_circuit(graph)` | `find_euler_circuit_undirected(graph)` |
| cutpoints | `find_articulation_points(graph)` | `find_articulation_points_undirected(graph)` |
| cutpoints | `find_bridges(graph)` | `find_bridges_undirected(graph)` |
| hamiltonian | `find_hamiltonian_path(graph)` | `find_hamiltonian_path_backtrack(graph)` |
| hamiltonian | `find_hamiltonian_circuit(graph)` | `find_hamiltonian_circuit_backtrack(graph)` |
| hamiltonian | `can_have_hamiltonian_circuit(graph)` | `has_hamiltonian_circuit_quick_check(graph)` |
| clique | `find_minimum_vertex_cover(graph)` | `find_minimum_vertex_cover_exact(graph)` |
| clique | `find_minimum_vertex_cover_greedy(graph)` | `find_minimum_vertex_cover_approx(graph)` |

**冻结决策**: 11 个别名已同步冻结，原始函数名保持可用（向后兼容）。

---

## 8. 废弃 API

| API | 废弃版本 | 替代方案 | 计划移除 |
|-----|---------|---------|---------|
| `bubble_sort_by_weight` | v0.14.0 | 快速排序 (csr_qsort) | 已私有化 |
| `int_max` | v0.16.0 | 用户自行实现或使用标准库 | 已私有化 |

---

## 9. 统计摘要

| 类别 | 数量 | 说明 |
|------|:----:|------|
| 公共结构体 | 61 | 含 4 I/O 统计类型 + 8 存储 + 4 Builder |
| 公共枚举 | 9 | GraphError, IOError, DegreeMode, DotToken 等 |
| 公共 Trait | 5 | GraphReadable → GraphBatchReadable |
| Trait 方法 | 26 | 全部冻结 |
| 存储类型 | 8 种结构 + 4 Builder | 共 12 个存储相关类型 |
| 算法模块 | 19 | lib/algo/* |
| 泛型算法函数 | 136 | `[G: GraphReadable]` 约束的算法 |
| 简短别名 | 11 | Phase 2 新增（函数总调用约 147）|
| 结果类型 | 42 | 19 个算法模块独有结果类型 |
| I/O 函数 | ~15 | DOT/JSON/统计 |

---

## 10. 已知限制 (v1.0.0 不修复)

| 限制 | 说明 | 计划版本 |
|------|------|---------|
| Node/Edge 数据类型固定 Double | 不支持泛型 | v2.0.0 |
| 构造函数命名不统一 | `new_xxx()` vs `Type::new()` | v2.0.0 |
| Result 方法命名不统一 | `size()`/`count()`/`edge_count()` | v2.0.0 |
| matching 函数命名不统一 | 4 种命名模式 | v2.0.0 |
| FlowNetwork 用 Int 节点索引 | 与 NodeId 类型体系分离 | v2.0.0 |
| 着色算法选择指南缺失 | greedy_coloring 与 greedy_coloring_with_order 功能重叠，用户难以选择 | v1.1.0 |
| TSP 使用 Matrix 而非 Graph trait | 性能考虑（矩阵 O(1) 访问），文档需解释 | v1.1.0 |
| bfs_all/dfs_all 语义不明确 | 需说明是否按连通分量分别遍历 | v1.0.0-rc.2 |

---

<div align="center">

**🔒 API Freeze Status**: 本文档记录的 API 表面已冻结

*最后更新: 2026-06-14 | mbtgraph v0.16.0 | **940 tests** | **~278 API surface***

</div>
