# Recognition API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/recognition`
> **路径**: `lib/algo/recognition/`

## 概述

Recognition 模块提供图类型识别算法，用于判断图的结构特性。

---

## 函数

### is_bipartite

```moonbit
pub fn[G : @core.GraphReadable] is_bipartite(G) -> Bool
```

检测图是否为二部图。

---

### is_complete

```moonbit
pub fn[G : @core.GraphReadable] is_complete(G) -> Bool
```

检测图是否为完全图。

---

### is_regular

```moonbit
pub fn[G : @core.GraphReadable] is_regular(G) -> Bool
```

检测图是否为正则图（所有节点度数相同）。

---

### is_tree

```moonbit
pub fn[G : @core.GraphReadable] is_tree(G) -> Bool
```

检测图是否为树（连通无环图）。

---

### is_forest

```moonbit
pub fn[G : @core.GraphReadable] is_forest(G) -> Bool
```

检测图是否为森林（无环图，可能不连通）。

---

### is_chordal

```moonbit
pub fn[G : @core.GraphReadable] is_chordal(G) -> Bool
```

检测图是否为弦图（所有长度 ≥ 4 的环都有弦）。

---

### is_graphic_sequence

```moonbit
pub fn is_graphic_sequence(Array[Int]) -> Bool
```

检测整数序列是否可作为某个图的度序列。

---

## 使用示例

```moonbit
if @recognition.is_bipartite(g) {
  println("Graph is bipartite")
}

if @recognition.is_tree(g) {
  println("Graph is a tree")
}

let degrees = [2, 2, 2, 2]
if @recognition.is_graphic_sequence(degrees) {
  println("Sequence is graphic")
}
```
