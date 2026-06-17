# Operators API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/operators`
> **路径**: `lib/algo/operators/`

## 概述

Operators 模块提供图运算函数，支持图的组合、变换和代数操作。

---

## 函数

### 图运算

#### graph_union

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_union(G1, G2) -> @storage.UndirectedAdjList
```

图并集：合并两个图的所有边。

---

#### graph_intersection

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_intersection(G1, G2) -> @storage.UndirectedAdjList
```

图交集：保留两个图共有的边。

---

#### graph_difference

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_difference(G1, G2) -> @storage.UndirectedAdjList
```

图差集：保留 G1 中有而 G2 中没有的边。

---

#### complement

```moonbit
pub fn[G : @core.GraphReadable] complement(G) -> @storage.UndirectedAdjList
```

补图：原图中不存在的边构成的图。

---

### 图变换

#### reverse

```moonbit
pub fn[G : @core.GraphReadable] reverse(G) -> @storage.DirectedAdjList
```

反转有向图：反转所有边的方向。

---

#### line_graph

```moonbit
pub fn[G : @core.GraphReadable] line_graph(G) -> @storage.UndirectedAdjList
```

线图：原图的边变为新图的节点。

---

#### power_graph

```moonbit
pub fn[G : @core.GraphReadable] power_graph(G, Int) -> @storage.UndirectedAdjList
```

幂图：距离 ≤ k 的节点之间添加边。

**参数**:
- `Int`: 幂次 k

---

#### contract

```moonbit
pub fn[G : @core.GraphReadable] contract(G, @core.NodeId, @core.NodeId) -> @storage.UndirectedAdjList
```

收缩边：将两个节点合并为一个。

---

### 图积

#### cartesian_product

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] cartesian_product(G1, G2) -> @storage.UndirectedAdjList
```

笛卡尔积：图的笛卡尔积。

---

#### tensor_product

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] tensor_product(G1, G2) -> @storage.UndirectedAdjList
```

张量积：图的张量积（Kronecker 积）。

---

#### lexicographic_product

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] lexicographic_product(G1, G2) -> @storage.UndirectedAdjList
```

字典积：图的字典积。

---

## 使用示例

```moonbit
// 补图
let comp = @operators.complement(g)

// 笛卡尔积
let product = @operators.cartesian_product(g1, g2)

// 幂图（距离 ≤ 2 的节点相连）
let power = @operators.power_graph(g, 2)
```
