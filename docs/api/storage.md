# Storage API Reference

> **包名**: `morning-start/mbtgraph/lib/storage`
> **路径**: `lib/storage/`

## 概述

Storage 模块提供 8 种图存储实现和相关的工厂函数、转换函数。

---

## 工厂函数

### new_directed

```moonbit
pub fn new_directed() -> DirectedAdjList
```

创建新的有向邻接表。

---

### new_undirected

```moonbit
pub fn new_undirected() -> UndirectedAdjList
```

创建新的无向邻接表。

---

### new_directed_matrix

```moonbit
pub fn new_directed_matrix(Int) -> DirectedMatrix
```

创建新的有向邻接矩阵，参数为预分配容量。

---

### new_undirected_matrix

```moonbit
pub fn new_undirected_matrix(Int) -> UndirectedMatrix
```

创建新的无向邻接矩阵，参数为预分配容量。

---

### new_edge_list

```moonbit
pub fn new_edge_list() -> EdgeListGraph
```

创建新的有向边集数组。

---

### new_undirected_edge_list

```moonbit
pub fn new_undirected_edge_list() -> UndirectedEdgeListGraph
```

创建新的无向边集数组。

---

## 转换函数

### to_directed_adj_list

```moonbit
pub fn[G : @core.GraphDirected] to_directed_adj_list(G) -> DirectedAdjList
```

任意有向图 → 有向邻接表。

---

### to_directed_matrix

```moonbit
pub fn[G : @core.GraphDirected] to_directed_matrix(G, Int) -> DirectedMatrix
```

任意有向图 → 有向邻接矩阵（参数为预分配容量）。

---

### to_undirected_adj_list

```moonbit
pub fn[G : @core.GraphReadable] to_undirected_adj_list(G) -> UndirectedAdjList raise
```

任意图 → 无向邻接表。运行时检查源图是否无向。

---

### to_undirected_matrix

```moonbit
pub fn[G : @core.GraphReadable] to_undirected_matrix(G, Int) -> UndirectedMatrix raise
```

任意图 → 无向邻接矩阵（参数为预分配容量）。

---

### to_edge_list

```moonbit
pub fn[G : @core.GraphDirected] to_edge_list(G) -> EdgeListGraph
```

任意有向图 → 有向边集数组。

---

### to_undirected_edge_list

```moonbit
pub fn[G : @core.GraphReadable] to_undirected_edge_list(G) -> UndirectedEdgeListGraph raise
```

任意图 → 无向边集数组。

---

### to_csr

```moonbit
pub fn[G : @core.GraphDirected] to_csr(G) -> CSRGraph
```

任意有向图 → 压缩稀疏行 (CSR)。

---

### to_csc

```moonbit
pub fn[G : @core.GraphDirected] to_csc(G) -> CSCGraph
```

任意有向图 → 压缩稀疏列 (CSC)。

---

### as_directed

```moonbit
pub fn[G : @core.GraphReadable] as_directed(G) -> DirectedAdjList raise
```

语义转换：将无向图视为有向图（双向边）。

---

### as_undirected

```moonbit
pub fn[G : @core.GraphReadable] as_undirected(G) -> UndirectedAdjList raise
```

语义转换：将有向图视为无向图。

---

## 辅助函数

### find_max_node_id

```moonbit
pub fn[G : @core.GraphReadable] find_max_node_id(G) -> Int
```

查找图中最大的节点 ID。

---

## 存储实现

### DirectedAdjList

有向邻接表。通用稀疏图的首选存储。

```moonbit
pub(all) struct DirectedAdjList {
  mut node_cnt : Int
  mut edge_cnt : Int
  nodes : Array[@core.Node?]
  adj : Array[Array[(@core.NodeId, Double)]]
  rev_adj : Array[Array[(@core.NodeId, Double)]]
}
```

**Trait 实现**:
- `GraphReadable`
- `GraphWritable`
- `GraphDirected`
- `GraphFull`

**额外方法**:
| 方法 | 签名 | 说明 |
|------|------|------|
| `add_edge_unchecked` | `(NodeId, NodeId, Double) -> Result[Unit, GraphError]` | 添加边（不检查节点存在性） |
| `add_edges_batch` | `Array[(NodeId, NodeId, Double)] -> Result[Int, GraphError]` | 批量添加边 |

**复杂度**:
- 节点查询: O(1)
- 边查询: O(k)，k 为度数
- 添加节点: O(1) 均摊
- 添加边: O(1) 均摊

---

### UndirectedAdjList

无向邻接表。半存储策略，节省 50% 空间。

```moonbit
pub(all) struct UndirectedAdjList {
  mut node_cnt : Int
  mut edge_cnt : Int
  nodes : Array[@core.Node?]
  adj : Array[Array[(@core.NodeId, Double)]]
}
```

**Trait 实现**:
- `GraphReadable`
- `GraphWritable`

**额外方法**:
| 方法 | 签名 | 说明 |
|------|------|------|
| `add_edge_unchecked` | `(NodeId, NodeId, Double) -> Result[Unit, GraphError]` | 添加边（不检查节点存在性） |
| `add_edges_batch` | `Array[(NodeId, NodeId, Double)] -> Result[Int, GraphError]` | 批量添加边 |

---

### DirectedMatrix

有向邻接矩阵。适合稠密小图 (<1K 节点)。

```moonbit
pub(all) struct DirectedMatrix {
  mut node_count : Int
  mut edge_count : Int
  capacity : Int
  nodes : Array[@core.Node?]
  matrix : Array[Array[Double?]]
}
```

**Trait 实现**:
- `GraphReadable`
- `GraphWritable`
- `GraphDirected`

**复杂度**:
- 节点查询: O(1)
- 边查询: O(1)
- 空间: O(V²)

---

### UndirectedMatrix

无向邻接矩阵。

```moonbit
pub(all) struct UndirectedMatrix {
  mut node_count : Int
  mut edge_count : Int
  capacity : Int
  nodes : Array[@core.Node?]
  matrix : Array[Array[Double?]]
}
```

**Trait 实现**:
- `GraphReadable`
- `GraphWritable`

---

### EdgeListGraph

有向边集数组。适合 Kruskal 等边排序算法。

```moonbit
pub(all) struct EdgeListGraph {
  mut node_cnt : Int
  nodes : Array[@core.Node?]
  mut edges : Array[@core.Edge]
}
```

**Trait 实现**:
- `GraphReadable`
- `GraphWritable`
- `GraphDirected`

---

### UndirectedEdgeListGraph

无向边集数组。

```moonbit
pub(all) struct UndirectedEdgeListGraph {
  mut node_cnt : Int
  nodes : Array[@core.Node?]
  mut edges : Array[@core.Edge]
}
```

**Trait 实现**:
- `GraphReadable`
- `GraphWritable`

---

### CSRGraph

压缩稀疏行 (Compressed Sparse Row)。适合大规模静态图 (>100K 节点)，缓存友好。

```moonbit
pub(all) struct CSRGraph {
  nodes : Array[@core.Node]
  row_ptr : Array[Int]
  col_idx : Array[@core.NodeId]
  values : Array[Double]
  in_ptr : Array[Int]
  in_idx : Array[@core.NodeId]
  in_vals : Array[Double]
}
```

**Trait 实现**:
- `GraphReadable`
- `GraphDirected`
- `GraphBatchReadable`

**特点**:
- 只读存储，构建后不可修改
- 支持批量邻居查询
- 内存连续，缓存友好

---

### CSCGraph

压缩稀疏列 (Compressed Sparse Column)。适合入边密集查询。

```moonbit
pub(all) struct CSCGraph {
  nodes : Array[@core.Node]
  col_ptr : Array[Int]
  row_idx : Array[@core.NodeId]
  values : Array[Double]
}
```

**Trait 实现**:
- `GraphReadable`
- `GraphDirected`
- `GraphBatchReadable`

**特点**:
- 只读存储
- `in_degree()` 查询 O(1)
- 适合 PageRank 等入边密集算法

---

## Builder 模式

### CSRBuilder

```moonbit
pub(all) struct CSRBuilder {
  nodes : Array[@core.Node]
  edges : Array[(@core.NodeId, @core.NodeId, Double)]
}
pub fn CSRBuilder::new() -> Self
pub fn CSRBuilder::add_node(Self, @core.NodeId, Double) -> Self
pub fn CSRBuilder::add_edge(Self, @core.NodeId, @core.NodeId, Double) -> Self
pub fn CSRBuilder::build(Self) -> CSRGraph
```

### CSCBuilder

```moonbit
pub(all) struct CSCBuilder {
  nodes : Array[@core.Node]
  edges : Array[(@core.NodeId, @core.NodeId, Double)]
}
pub fn CSCBuilder::new() -> Self
pub fn CSCBuilder::add_node(Self, @core.NodeId, Double) -> Self
pub fn CSCBuilder::add_edge(Self, @core.NodeId, @core.NodeId, Double) -> Self
pub fn CSCBuilder::build(Self) -> CSCGraph
```

---

## 存储选型指南

| 场景 | 推荐存储 | Trait | 复杂度 |
|------|---------|:-----:|--------|
| 通用稀疏图 | `DirectedAdjList` ⭐ | R+W+D+E | 邻居 O(k) |
| 无向通用图 | `UndirectedAdjList` ⭐ | R+W+E | 半存储 -50% |
| 稠密小图 (<1K) | `DirectedMatrix` | R+W+D | O(V²) 空间 |
| MST/Kruskal | `EdgeList` | R+W+E | O(E log E) |
| 大规模静态图 (>100K) | `CSR` | R+B | 缓存友好 |
| 入边密集查询 | `CSC` | R+B | in_degree O(1) |
