# Traversal API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/traversal`
> **路径**: `lib/algo/traversal/`

## 概述

Traversal 模块提供图遍历算法，包括 BFS、DFS、环检测和拓扑排序。

---

## 函数

### BFS (广度优先搜索)

#### bfs

```moonbit
pub fn[G : @core.GraphReadable] bfs(G, @core.NodeId) -> BfsResult
```

从指定节点开始的广度优先搜索。

**参数**:
- `G`: 图实例
- `@core.NodeId`: 起始节点

**返回**: `BfsResult`

---

#### bfs_all

```moonbit
pub fn[G : @core.GraphReadable] bfs_all(G) -> BfsResult
```

遍历图中所有连通分量的 BFS。

---

#### bfs_shortest_path

```moonbit
pub fn[G : @core.GraphReadable] bfs_shortest_path(G, @core.NodeId, @core.NodeId) -> Array[@core.NodeId]
```

使用 BFS 查找两节点间的最短路径（无权图）。

**返回**: 路径节点数组，空数组表示不可达

---

#### bidirectional_bfs

```moonbit
pub fn[G : @core.GraphReadable] bidirectional_bfs(G, @core.NodeId, @core.NodeId) -> Array[@core.NodeId]
```

双向 BFS 查找最短路径。从起点和终点同时搜索，相遇时停止。

---

### DFS (深度优先搜索)

#### dfs

```moonbit
pub fn[G : @core.GraphReadable] dfs(G, @core.NodeId) -> DfsResult
```

从指定节点开始的深度优先搜索。

---

#### dfs_all

```moonbit
pub fn[G : @core.GraphReadable] dfs_all(G) -> DfsResult
```

遍历图中所有连通分量的 DFS。

---

### 环检测

#### has_cycle

```moonbit
pub fn[G : @core.GraphReadable] has_cycle(G) -> Bool
```

检测图中是否存在环（自动选择有向/无向检测）。

---

#### has_directed_cycle

```moonbit
pub fn[G : @core.GraphDirected] has_directed(G) -> Bool
```

检测有向图中是否存在环。

---

#### has_undirected_cycle

```moonbit
pub fn[G : @core.GraphReadable] has_undirected_cycle(G) -> Bool
```

检测无向图中是否存在环。

---

### 拓扑排序

#### topo_sort_dfs

```moonbit
pub fn[G : @core.GraphDirected] topo_sort_dfs(G) -> Result[Array[@core.NodeId], String]
```

基于 DFS 的拓扑排序。

**返回**: `Result[Array[NodeId], String]` - 成功返回拓扑序，失败（有环）返回错误

---

#### topo_sort_kahn

```moonbit
pub fn[G : @core.GraphDirected] topo_sort_kahn(G) -> Result[Array[@core.NodeId], String]
```

基于 Kahn 算法的拓扑排序（BFS 方式）。

---

## 结果类型

### TraversalResult

```moonbit
pub(all) struct TraversalResult {
  visited : Array[Bool]
  order : Array[@core.NodeId]
  parents : Array[@core.NodeId?]
}
pub fn TraversalResult::is_visited(Self, @core.NodeId) -> Bool
pub fn TraversalResult::path_to(Self, @core.NodeId) -> Array[@core.NodeId]
pub fn TraversalResult::reachable_count(Self) -> Int
```

**字段**:
- `visited`: 节点访问标记数组
- `order`: 遍历顺序
- `parents`: 父节点数组（用于路径重建）

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `is_visited(NodeId)` | `Bool` | 检查节点是否被访问 |
| `path_to(NodeId)` | `Array[NodeId]` | 重建到指定节点的路径 |
| `reachable_count()` | `Int` | 可达节点数量 |

---

### BfsResult

```moonbit
pub(all) struct BfsResult {
  base : TraversalResult
  levels : Array[Int]
}
pub fn BfsResult::distance(Self, @core.NodeId) -> Int
```

BFS 结果，包含层级信息。

**额外字段**:
- `levels`: 节点层级（距源点的最短距离）

**额外方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `distance(NodeId)` | `Int` | 获取节点距源点的距离 |

---

### DfsResult

```moonbit
pub(all) struct DfsResult {
  base : TraversalResult
  entry_time : Array[Int]
  exit_time : Array[Int]
}
```

DFS 结果，包含时间戳信息。

**额外字段**:
- `entry_time`: 节点进入时间
- `exit_time`: 节点退出时间

---

## 使用示例

```moonbit
let g = @storage.new_directed()
// ... 添加节点和边

// BFS 遍历
let result = @traversal.bfs(g, start_node)
let path = result.path_to(target_node)
let dist = result.distance(target_node)

// 拓扑排序
match @traversal.topo_sort_kahn(g) {
  Ok(order) => // 处理拓扑序
  Err(msg) => // 图有环
}
```
