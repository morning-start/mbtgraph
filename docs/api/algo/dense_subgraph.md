# Dense Subgraph API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/dense_subgraph`
> **路径**: `lib/algo/dense_subgraph/`

## 概述

Dense Subgraph 模块提供密度子图分析算法，包括聚类系数、三角形计数、K-Core 和 K-Truss 分解。

---

## 函数

### 聚类系数

#### local_clustering_coefficient

```moonbit
pub fn[G : @core.GraphReadable] local_clustering_coefficient(G, @core.NodeId) -> Double
```

计算单个节点的局部聚类系数。

---

#### clustering_coefficients

```moonbit
pub fn[G : @core.GraphReadable] clustering_coefficients(G) -> ClusteringCoefficientResult
```

计算所有节点的局部聚类系数和全局聚类系数。

---

#### average_clustering_coefficient

```moonbit
pub fn[G : @core.GraphReadable] average_clustering_coefficient(G) -> Double
```

计算平均聚类系数。

---

### 三角形计数

#### count_triangles

```moonbit
pub fn[G : @core.GraphReadable] count_triangles(G) -> TriangleCountResult
```

统计图中的三角形数量。

---

### K-Core 分解

#### k_core_decomposition

```moonbit
pub fn[G : @core.GraphReadable] k_core_decomposition(G) -> KCoreResult
```

K-Core 分解：找到每个节点的核心度。

---

### K-Truss 分解

#### k_truss_decomposition

```moonbit
pub fn[G : @core.GraphReadable] k_truss_decomposition(G) -> KTrussResult
```

K-Truss 分解：找到每个边的支撑度。

---

## 结果类型

### ClusteringCoefficientResult

```moonbit
pub(all) struct ClusteringCoefficientResult {
  locals : Array[Double]
  global : Double
} derive(Debug)
pub fn ClusteringCoefficientResult::global_coefficient(Self) -> Double
pub fn ClusteringCoefficientResult::local_coefficient(Self, @core.NodeId) -> Double
```

---

### TriangleCountResult

```moonbit
pub(all) struct TriangleCountResult {
  total : Int
  per_node : Array[Int]
} derive(Debug)
pub fn TriangleCountResult::node_triangles(Self, @core.NodeId) -> Int
pub fn TriangleCountResult::total_triangles(Self) -> Int
```

---

### KCoreResult

```moonbit
pub(all) struct KCoreResult {
  core : Array[Int]
} derive(Debug)
pub fn KCoreResult::core_number(Self, @core.NodeId) -> Int
```

---

### KTrussResult

```moonbit
pub(all) struct KTrussResult {
  truss : @storage.UndirectedAdjList
}
pub fn KTrussResult::truss_number(Self, @core.NodeId, @core.NodeId) -> Int?
```

---

## 使用示例

```moonbit
// 聚类系数
let cc = @dense_subgraph.clustering_coefficients(g)
println("Global clustering: \{cc.global_coefficient()}")

// 三角形计数
let tc = @dense_subgraph.count_triangles(g)
println("Total triangles: \{tc.total_triangles()}")

// K-Core 分解
let kc = @dense_subgraph.k_core_decomposition(g)
println("Core number of node 0: \{kc.core_number(n0)}")
```
