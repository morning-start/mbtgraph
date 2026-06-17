# Coloring API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/coloring`
> **路径**: `lib/algo/coloring/`

## 概述

Coloring 模块提供图着色算法，包括顶点着色和边着色。

---

## 函数

### greedy_coloring

```moonbit
pub fn[G : @core.GraphReadable] greedy_coloring(G) -> ColoringResult
```

贪心着色算法。

---

### greedy_coloring_with_order

```moonbit
pub fn[G : @core.GraphReadable] greedy_coloring_with_order(G, Array[Int]) -> ColoringResult
```

按指定顺序的贪心着色。

**参数**:
- `Array[Int]`: 节点处理顺序

---

### welsh_powell

```moonbit
pub fn[G : @core.GraphReadable] welsh_powell(G) -> ColoringResult
```

Welsh-Powell 算法：按度数降序着色。

---

### dsatur_coloring

```moonbit
pub fn[G : @core.GraphReadable] dsatur_coloring(G) -> ColoringResult
```

DSATUR 算法：饱和度优先着色。

**特点**:
- 启发式算法
- 通常比贪心算法效果更好

---

### exact_chromatic_number

```moonbit
pub fn[G : @core.GraphReadable] exact_chromatic_number(G, Int) -> ChromaticNumberResult
```

精确色数算法（回溯搜索）。

**参数**:
- `Int`: 搜索上界

---

### edge_coloring

```moonbit
pub fn[G : @core.GraphReadable] edge_coloring(G) -> EdgeColoringResult
```

边着色算法。

---

## 结果类型

### ColoringResult

```moonbit
pub(all) struct ColoringResult {
  colors : Array[Int]
  num_colors : Int
  is_valid : Bool
}
```

**字段**:
- `colors`: 节点颜色数组
- `num_colors`: 使用的颜色数量
- `is_valid`: 着色是否有效

---

### ChromaticNumberResult

```moonbit
pub(all) struct ChromaticNumberResult {
  chromatic_number : Int?
  optimal_coloring : Array[Int]?
  upper_bound : Int
  lower_bound : Int
  exact : Bool
}
```

---

### EdgeColoringResult

```moonbit
pub(all) struct EdgeColoringResult {
  edge_colors : Array[Array[Int?]]
  num_colors : Int
  max_degree : Int
  is_valid : Bool
}
pub fn EdgeColoringResult::edge_color(Self, @core.NodeId, @core.NodeId) -> Int
```

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `edge_color(NodeId, NodeId)` | `Int` | 获取边的颜色 |

---

## 使用示例

```moonbit
let result = @coloring.dsatur_coloring(g)
println("Colors used: \{result.num_colors}")
for (node_id, color) in result.colors {
  println("Node \{node_id}: Color \{color}")
}
```
