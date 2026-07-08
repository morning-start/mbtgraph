---
title: API 面概览
description: mbtgraph v0.1.2 公开 API 面：Trait、存储、算法、I/O 的签名、命名约定和冻结状态
---

> **冻结日期**: 2026-07-03 | **版本**: v0.1.2
> **原则**: 所有 pub API 在 v1.x 中保持兼容，破坏性变更需 major 版本

---

## 1. 核心类型

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
│   └── GraphFull    = GraphWritable + GraphDirected (组合别名)
└── GraphBatchReadable (2 methods, CSR/CSC 专属)
```

---

## 2. 存储层

### 构造函数约定

| 模式 | 示例 | 适用类型 |
|------|------|---------|
| **自由函数** `new_xxx()` | `new_directed()` | AdjList, Matrix, EdgeList |
| **关联函数** `Type::new()` | `CSRBuilder::new()` | CSR/CSC Builder |

### Trait 实现矩阵

| 类型 | Readable | Writable | Directed | Full | BatchReadable |
|------|:--------:|:--------:|:--------:|:----:|:-------------:|
| `DirectedAdjList` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `UndirectedAdjList` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `DirectedMatrix` | ✅ | ✅ | ✅ | ✅ | ❌ |
| `UndirectedMatrix` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `EdgeListGraph` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `UndirectedEdgeListGraph` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `CSRGraph` | ✅ | ❌ | ❌ | ❌ | ✅ |
| `CSCGraph` | ✅ | ❌ | ❌ | ❌ | ✅ |

### 批量操作 API

| 方法 | 适用类型 |
|------|---------|
| `add_edge_unchecked(from, to, data)` | DirectedAdjList, UndirectedAdjList |
| `add_edges_batch(edges)` | DirectedAdjList, UndirectedAdjList |

---

## 3. 算法层

### 参数命名约定

| 约定 | 示例 | 说明 |
|------|------|------|
| 图参数名 | `graph` | 所有泛型算法统一 |
| 源/汇参数名 | `source`, `sink` | Int 类型（Flow 模块）|
| 起点参数名 | `start` | NodeId 类型（遍历/最短路径）|

### 返回类型速查

| 模块 | 返回类型 | 状态 |
|------|---------|:----:|
| traversal | `BfsResult`, `DfsResult` | ✅ |
| shortest_path | `ShortestPathResult`, `KShortestPathsResult`, `FloydWarshallResult` | ✅ |
| mst | `MstResult` | ✅ |
| connectivity | `ConnectedComponentsResult`, `SCCResult`, `BCCResult` | ✅ |
| flow | `MaxFlowResult`, `MinCostMaxFlowResult`, `StoerWagnerResult` | ✅ |
| matching | `MatchingResult`, `KMMatchingResult` | ✅ |
| community | `CommunityResult` | ✅ |
| centrality | `CentralityResult` | ✅ |
| pagerank | `PageRankResult` | ✅ |
| coloring | `ColoringResult`, `ChromaticNumberResult`, `EdgeColoringResult` | ✅ |
| clique | `CliqueResult`, `IndependentSetResult`, `VertexCoverResult` | ✅ |
| cutpoints | `CutPointResult`, `BridgeResult` | ✅ |
| euler | `EulerPathResult`, `EulerCircuitResult` | ✅ |
| hamiltonian | `HamiltonianResult`, `TSPResult` | ✅ |

---

## 4. I/O 层

| 函数 | 签名 | 说明 |
|------|------|------|
| `write_dot` | `(G, String) -> String` | DOT 序列化 |
| `parse_dot_into` | `(String) -> Result[UndirectedAdjList, IOError]` | DOT 反序列化 |
| `graph_to_json` | `(G, Bool) -> String` | JSON 序列化 |
| `parse_json_into` | `(String) -> Result[UndirectedAdjList, IOError]` | JSON 反序列化 |
| `basic_stats` | `(G) -> GraphStats` | 图统计 |
| `degree_distribution` | `(G) -> DegreeDistribution` | 度分布 |

---

## 完整参考

- [Core 模块 API](/api/core/) — 类型与 Trait 详情
- [Storage 模块 API](/api/storage/) — 存储详情
- [算法模块 API](/api/algorithms/) — 算法函数详情
- [I/O 模块 API](/api/io/) — 序列化详情
- [生成器 API](/api/generators/) — 图生成器详情
