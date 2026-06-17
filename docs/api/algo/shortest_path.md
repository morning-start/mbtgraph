# Shortest Path API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/shortest_path`
> **路径**: `lib/algo/shortest_path/`

## 概述

Shortest Path 模块提供各种最短路径算法，适用于不同场景（非负权图、负权图、全源最短路径等）。

---

## 函数

### dijkstra

```moonbit
pub fn[G : @core.GraphReadable] dijkstra(G, @core.NodeId) -> ShortestPathResult
```

Dijkstra 算法：单源最短路径（非负权图）。

**参数**:
- `G`: 图实例（边权重必须非负）
- `@core.NodeId`: 源节点

**返回**: `ShortestPathResult`

**复杂度**: O((V + E) log V)

---

### dijkstra_targeted

```moonbit
pub fn[G : @core.GraphReadable] dijkstra_targeted(G, @core.NodeId, @core.NodeId) -> Array[@core.NodeId]
```

目标导向 Dijkstra：查找两节点间最短路径。

**返回**: 路径节点数组

---

### bellman_ford

```moonbit
pub fn[G : @core.GraphReadable] bellman_ford(G, @core.NodeId) -> Result[ShortestPathResult, String]
```

Bellman-Ford 算法：支持负权边的单源最短路径。

**返回**: `Result[ShortestPathResult, String]` - 存在负环时返回错误

**复杂度**: O(VE)

---

### spfa

```moonbit
pub fn[G : @core.GraphReadable] spfa(G, @core.NodeId) -> Result[ShortestPathResult, String]
```

SPFA (Shortest Path Faster Algorithm)：Bellman-Ford 的优化版本。

**返回**: `Result[ShortestPathResult, String]`

---

### floyd_warshall

```moonbit
pub fn[G : @core.GraphReadable] floyd_warshall(G) -> Result[FloydWarshallResult, String]
```

Floyd-Warshall 算法：全源最短路径。

**返回**: `Result[FloydWarshallResult, String]`

**复杂度**: O(V³)

---

### johnson

```moonbit
pub fn[G : @core.GraphReadable] johnson(G) -> Result[FloydWarshallResult, String]
```

Johnson 算法：稀疏图的全源最短路径（结合 Bellman-Ford + Dijkstra）。

**返回**: `Result[FloydWarshallResult, String]`

---

### a_star

```moonbit
pub fn[G : @core.GraphReadable] a_star(G, @core.NodeId, @core.NodeId, (@core.NodeId) -> Double) -> Array[@core.NodeId]
```

A* 算法：启发式最短路径搜索。

**参数**:
- `G`: 图实例
- `@core.NodeId`: 起点
- `@core.NodeId`: 终点
- `(@core.NodeId) -> Double`: 启发式函数（估计到目标的距离）

**返回**: 路径节点数组

---

### yen_k_shortest_paths

```moonbit
pub fn[G : @core.GraphReadable] yen_k_shortest_paths(G, @core.NodeId, @core.NodeId, Int) -> Result[KShortestPathsResult, String]
```

Yen's K 最短路径算法。

**参数**:
- `Int`: K 值（返回前 K 条最短路径）

---

### bidirectional_dijkstra

```moonbit
pub fn[G : @core.GraphReadable] bidirectional_dijkstra(G, @core.NodeId, @core.NodeId) -> Result[ShortestPathResult, String]
```

双向 Dijkstra：从起点和终点同时搜索。

---

## 结果类型

### ShortestPathResult

```moonbit
pub(all) struct ShortestPathResult {
  distances : Array[Double?]
  parents : Array[@core.NodeId?]
}
pub fn ShortestPathResult::distance_to(Self, @core.NodeId) -> Double
pub fn ShortestPathResult::is_reachable(Self, @core.NodeId) -> Bool
pub fn ShortestPathResult::path_to(Self, @core.NodeId) -> Array[@core.NodeId]
pub fn ShortestPathResult::reachable_count(Self) -> Int
```

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `distance_to(NodeId)` | `Double` | 获取到指定节点的距离 |
| `is_reachable(NodeId)` | `Bool` | 检查节点是否可达 |
| `path_to(NodeId)` | `Array[NodeId]` | 重建到指定节点的路径 |
| `reachable_count()` | `Int` | 可达节点数量 |

---

### FloydWarshallResult

```moonbit
pub(all) struct FloydWarshallResult {
  distances : Array[Array[Double?]]
  next : Array[Array[@core.NodeId?]]
}
pub fn FloydWarshallResult::distance(Self, @core.NodeId, @core.NodeId) -> Double
pub fn FloydWarshallResult::path(Self, @core.NodeId, @core.NodeId) -> Array[@core.NodeId]
```

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `distance(NodeId, NodeId)` | `Double` | 获取两节点间距离 |
| `path(NodeId, NodeId)` | `Array[NodeId]` | 重建两节点间路径 |

---

### KShortestPathsResult

```moonbit
pub(all) struct KShortestPathsResult {
  paths : Array[Array[@core.NodeId]]
  distances : Array[Double]
  k : Int
}
pub fn KShortestPathsResult::distance(Self, Int) -> Double
pub fn KShortestPathsResult::path(Self, Int) -> Array[@core.NodeId]
```

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `distance(Int)` | `Double` | 获取第 K 条路径的距离 |
| `path(Int)` | `Array[NodeId]` | 获取第 K 条路径 |

---

## 算法选择指南

| 场景 | 推荐算法 | 复杂度 |
|------|---------|--------|
| 非负权单源 | Dijkstra | O((V+E) log V) |
| 负权单源 | Bellman-Ford / SPFA | O(VE) |
| 全源（稠密） | Floyd-Warshall | O(V³) |
| 全源（稀疏） | Johnson | O(VE + V² log V) |
| 启发式搜索 | A* | 取决于启发式函数 |
| K 条最短路径 | Yen's | O(KV(V+E log V)) |
