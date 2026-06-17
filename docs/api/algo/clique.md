# Clique API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/clique`
> **路径**: `lib/algo/clique/`

## 概述

Clique 模块提供团检测、独立集和顶点覆盖算法。

---

## 函数

### find_maximum_clique

```moonbit
pub fn[G : @core.GraphReadable] find_maximum_clique(G) -> CliqueResult
```

查找最大团（Bron-Kerbosch 算法）。

---

### find_maximum_independent_set

```moonbit
pub fn[G : @core.GraphReadable] find_maximum_independent_set(G) -> IndependentSetResult
```

查找最大独立集。

---

### find_minimum_vertex_cover_exact

```moonbit
pub fn[G : @core.GraphReadable] find_minimum_vertex_cover_exact(G) -> VertexCoverResult
```

精确最小顶点覆盖（指数时间）。

---

### find_minimum_vertex_cover_approx

```moonbit
pub fn[G : @core.GraphReadable] find_minimum_vertex_cover_approx(G) -> VertexCoverResult
```

近似最小顶点覆盖（2-近似算法）。

---

## 结果类型

### CliqueResult

```moonbit
pub(all) struct CliqueResult {
  maximum_clique : Array[@core.NodeId]
  size : Int
}
```

---

### IndependentSetResult

```moonbit
pub(all) struct IndependentSetResult {
  maximum_set : Array[@core.NodeId]
  size : Int
}
```

---

### VertexCoverResult

```moonbit
pub(all) struct VertexCoverResult {
  cover : Array[@core.NodeId]
  size : Int
  is_optimal : Bool
}
```
