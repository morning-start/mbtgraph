# Core API Reference

> **包名**: `morning-start/mbtgraph/lib/core`
> **路径**: `lib/core/`

## 概述

Core 模块定义了 mbtgraph 的基础类型和 Trait 接口。所有存储实现和算法都依赖此模块。

---

## 类型

### NodeId

```moonbit
pub(all) struct NodeId(Int) derive(Eq, Debug)
```

节点唯一标识符（整数索引）。

**方法**: 无

---

### Node

```moonbit
pub(all) struct Node {
  id : NodeId
  data : Double
} derive(Debug)
```

带数据的节点。

**字段**:
- `id`: 节点标识符
- `data`: 节点数据（Double 类型）

---

### Edge

```moonbit
pub(all) struct Edge {
  from : NodeId
  to : NodeId
  data : Double
} derive(Debug)
```

带数据的边。

**字段**:
- `from`: 起点节点 ID
- `to`: 终点节点 ID
- `data`: 边权重（Double 类型）

---

### GraphError

```moonbit
pub(all) enum GraphError {
  NodeNotFound(NodeId)
  EdgeAlreadyExists(NodeId, NodeId)
  InvalidNodeId
} derive(Eq, Debug)
```

图操作错误类型。

**变体**:
- `NodeNotFound(NodeId)`: 节点不存在
- `EdgeAlreadyExists(NodeId, NodeId)`: 边已存在
- `InvalidNodeId`: 无效的节点 ID

---

## Traits

### GraphReadable

```moonbit
pub(open) trait GraphReadable {
  fn node_count(Self) -> Int
  fn edge_count(Self) -> Int
  fn contains_node(Self, NodeId) -> Bool
  fn contains_edge(Self, NodeId, NodeId) -> Bool
  fn get_node(Self, NodeId) -> Double?
  fn get_edge(Self, NodeId, NodeId) -> Double?
  fn neighbors(Self, NodeId) -> Iter[NodeId]
  fn neighbors_with_weight(Self, NodeId) -> Iter[(NodeId, Double)]
  fn degree(Self, NodeId) -> Int
  fn is_directed(Self) -> Bool
  fn is_empty(Self) -> Bool
  fn node_ids(Self) -> Iter[NodeId]
  fn edges(Self) -> Iter[(NodeId, NodeId, Double)]
}
```

图只读接口。所有存储实现的最低要求，符合接口隔离原则 (ISP)。

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `node_count()` | `Int` | 节点数量 |
| `edge_count()` | `Int` | 边数量 |
| `contains_node(NodeId)` | `Bool` | 检查节点是否存在 |
| `contains_edge(NodeId, NodeId)` | `Bool` | 检查边是否存在 |
| `get_node(NodeId)` | `Double?` | 获取节点数据 |
| `get_edge(NodeId, NodeId)` | `Double?` | 获取边数据 |
| `neighbors(NodeId)` | `Iter[NodeId]` | 获取邻居节点（出边目标） |
| `neighbors_with_weight(NodeId)` | `Iter[(NodeId, Double)]` | 获取邻居节点及边权重 |
| `degree(NodeId)` | `Int` | 节点度（无向图）或出度（有向图） |
| `is_directed()` | `Bool` | 是否为有向图 |
| `is_empty()` | `Bool` | 是否为空图 |
| `node_ids()` | `Iter[NodeId]` | 迭代所有节点 ID |
| `edges()` | `Iter[(NodeId, NodeId, Double)]` | 迭代所有边 |

**实现者**:
- `DirectedAdjList`, `UndirectedAdjList`
- `DirectedMatrix`, `UndirectedMatrix`
- `EdgeListGraph`, `UndirectedEdgeListGraph`
- `CSRGraph`, `CSCGraph`

---

### GraphWritable

```moonbit
pub(open) trait GraphWritable: GraphReadable {
  fn add_node(Self, Double) -> NodeId
  fn remove_node(Self, NodeId) -> Bool
  fn add_edge(Self, NodeId, NodeId, Double) -> Result[Unit, GraphError]
  fn remove_edge(Self, NodeId, NodeId) -> Bool
  fn clear(Self) -> Unit
}
```

图可写接口。仅适用于支持动态修改的存储。

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `add_node(Double)` | `NodeId` | 添加节点，返回其 ID |
| `remove_node(NodeId)` | `Bool` | 删除节点及其关联的所有边 |
| `add_edge(NodeId, NodeId, Double)` | `Result[Unit, GraphError]` | 添加边 |
| `remove_edge(NodeId, NodeId)` | `Bool` | 删除边 |
| `clear()` | `Unit` | 清空图 |

**实现者**:
- `DirectedAdjList`, `UndirectedAdjList`
- `DirectedMatrix`, `UndirectedMatrix`
- `EdgeListGraph`, `UndirectedEdgeListGraph`

---

### GraphDirected

```moonbit
pub(open) trait GraphDirected: GraphReadable {
  fn in_neighbors(Self, NodeId) -> Iter[NodeId]
  fn out_neighbors(Self, NodeId) -> Iter[NodeId]
  fn in_degree(Self, NodeId) -> Int
  fn out_degree(Self, NodeId) -> Int
  fn predecessors(Self, NodeId) -> Iter[(NodeId, Double)]
  fn successors(Self, NodeId) -> Iter[(NodeId, Double)]
}
```

有向图扩展接口。提供入边查询能力。

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `in_neighbors(NodeId)` | `Iter[NodeId]` | 获取前驱节点（入边源） |
| `out_neighbors(NodeId)` | `Iter[NodeId]` | 获取后继节点（出边目标） |
| `in_degree(NodeId)` | `Int` | 入度 |
| `out_degree(NodeId)` | `Int` | 出度 |
| `predecessors(NodeId)` | `Iter[(NodeId, Double)]` | 前驱边 (源节点, 边数据) |
| `successors(NodeId)` | `Iter[(NodeId, Double)]` | 后继边 (目标节点, 边数据) |

**实现者**:
- `DirectedAdjList`, `DirectedMatrix`
- `EdgeListGraph`
- `CSRGraph`, `CSCGraph`
- `UndirectedAdjList`, `UndirectedEdgeListGraph`, `UndirectedMatrix` (适配：入边 = 出边)

---

### GraphFull

```moonbit
pub(open) trait GraphFull: GraphWritable + GraphDirected {
}
```

完整图接口。组合可写 + 有向图能力，适用于邻接表等通用实现。

**实现者**:
- `DirectedAdjList`

---

### GraphBatchReadable

```moonbit
pub(open) trait GraphBatchReadable: GraphReadable {
  fn batch_neighbors(Self, Array[NodeId]) -> Array[Array[NodeId]]
  fn batch_edges(Self, Array[(NodeId, NodeId)]) -> Array[Double?]
}
```

CSR 批量读取接口。提供批量处理优化，适合大图计算。

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `batch_neighbors(Array[NodeId])` | `Array[Array[NodeId]]` | 批量获取邻居 |
| `batch_edges(Array[(NodeId, NodeId)])` | `Array[Double?]` | 批量获取边数据 |

**实现者**:
- `CSRGraph`, `CSCGraph`

---

## Trait 继承关系

```
GraphReadable
├── GraphWritable (+5 methods)
├── GraphDirected (+6 methods)
│   └── GraphFull = Writable + Directed (便捷别名)
└── GraphBatchReadable (+2 methods)
```
