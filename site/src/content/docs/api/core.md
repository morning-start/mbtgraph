---
title: Core 模块接口
description: NodeId、Node、Edge 类型定义，6 层 Trait 接口签名，GraphError 错误枚举
---

# Core 模块接口

> 模块路径: `lib/core/` · 文件: `types.mbt`, `traits.mbt`, `error.mbt`

---

## 一、类型定义 (types.mbt)

### NodeId

节点唯一标识符（整数索引包装类型），所有图操作的基础。

```moonbit
pub(all) struct NodeId(Int) derive(Debug, Eq)
```

| 方法 | 描述 |
|------|------|
| `NodeId(id: Int)` | 用整数创建节点 ID |
| `.0` | 解包获取底层 Int 值 |

### Node

带数据的节点（MVP 阶段固定为 `Double`，后续可泛型化）。

```moonbit
pub(all) struct Node {
  id : NodeId
  data : Double
} derive(Debug)
```

### Edge

带数据的边。

```moonbit
pub(all) struct Edge {
  from : NodeId
  to : NodeId
  data : Double
} derive(Debug)
```

---

## 二、Trait 接口 (traits.mbt)

### GraphReadable — 12 方法

所有存储实现的**最低要求接口**。

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

| 方法 | 返回 | 说明 |
|------|:----:|------|
| `node_count` | `Int` | 总节点数 |
| `edge_count` | `Int` | 总边数 |
| `contains_node` | `Bool` | 节点是否存在 |
| `contains_edge` | `Bool` | 边是否存在 |
| `get_node` | `Double?` | 获取节点数据 |
| `get_edge` | `Double?` | 获取边权重 |
| `neighbors` | `Iter[NodeId]` | 邻居节点迭代器 |
| `neighbors_with_weight` | `Iter[(NodeId, Double)]` | 邻居+权重迭代器 |
| `degree` | `Int` | 节点度（或出度） |
| `is_directed` | `Bool` | 是否为有向图 |
| `is_empty` | `Bool` | 是否为空图 |
| `node_ids` | `Iter[NodeId]` | 所有节点 ID 迭代器 |
| `edges` | `Iter[(NodeId, NodeId, Double)]` | 所有边迭代器 |

### GraphWritable — +5 方法（继承 GraphReadable）

动态修改接口（邻接表、邻接矩阵实现，CSR/CSC 不实现）。

```moonbit
pub(open) trait GraphWritable: GraphReadable {
  fn add_node(Self, Double) -> NodeId
  fn remove_node(Self, NodeId) -> Bool
  fn add_edge(Self, NodeId, NodeId, Double) -> Result[Unit, GraphError]
  fn remove_edge(Self, NodeId, NodeId) -> Bool
  fn clear(Self) -> Unit
}
```

| 方法 | 返回 | 错误 |
|------|:----:|------|
| `add_node` | `NodeId` | — |
| `remove_node` | `Bool` | `false`=节点不存在 |
| `add_edge` | `Result[Unit, GraphError]` | `NodeNotFound` / `EdgeAlreadyExists` |
| `remove_edge` | `Bool` | `false`=边不存在 |
| `clear` | `Unit` | — |

### GraphDirected — +6 方法（继承 GraphReadable）

有向图入边/出边查询。

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

### GraphFull — 便捷别名（继承 GraphWritable + GraphDirected）

```moonbit
pub(open) trait GraphFull: GraphWritable + GraphDirected {}
```

### GraphBatchReadable — +2 方法（继承 GraphReadable）

CSR/CSC 批量读取优化。

```moonbit
pub(open) trait GraphBatchReadable: GraphReadable {
  fn batch_neighbors(Self, Array[NodeId]) -> Array[Array[NodeId]]
  fn batch_edges(Self, Array[(NodeId, NodeId)]) -> Array[Double?]
}
```

### GraphEdgeIterable — +1 方法（继承 GraphReadable）

```moonbit
pub(open) trait GraphEdgeIterable: GraphReadable {
  fn sorted_edges(Self) -> Iter[(NodeId, NodeId, Double)]
}
```

边排序接口（Kruskal 算法所需）。

---

## 三、错误枚举 (error.mbt)

```moonbit
pub(all) enum GraphError {
  NodeNotFound(NodeId)
  EdgeAlreadyExists(NodeId, NodeId)
  InvalidNodeId
} derive(Debug, Eq)
```

| 变体 | 含义 |
|------|------|
| `NodeNotFound(n)` | 节点 `n` 不存在 |
| `EdgeAlreadyExists(u,v)` | 边 `(u,v)` 已存在 |
| `InvalidNodeId` | 节点 ID 无效（如负数） |

---

## 四、Trait 继承关系图

```
GraphReadable (12 方法, 所有存储)
├── GraphWritable     (+5, 邻接表/矩阵)
│   └── GraphFull    = Writable + Directed (便捷别名)
├── GraphDirected     (+6, 有向图)
│   └── GraphFull    (同上)
├── GraphBatchReadable (+2, CSR/CSC)
└── GraphEdgeIterable  (+1, 边排序)
```

---

**相关文档：**
- [Storage 模块接口](/api/storage/)
- [各算法模块 API](/api/algorithms/)
- [IO 模块接口](/api/io/)
- [6 层 Trait 详解](/core-concepts/traits/)
