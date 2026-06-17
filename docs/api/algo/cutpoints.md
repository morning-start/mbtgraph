# Cutpoints API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/cutpoints`
> **路径**: `lib/algo/cutpoints/`

## 概述

Cutpoints 模块提供割点（关节点）和桥（割边）检测算法。

---

## 函数

### 无向图

#### find_articulation_points_undirected

```moonbit
pub fn[G : @core.GraphReadable] find_articulation_points_undirected(G) -> CutPointResult
```

查找无向图的割点。

---

#### find_bridges_undirected

```moonbit
pub fn[G : @core.GraphReadable] find_bridges_undirected(G) -> BridgeResult
```

查找无向图的桥。

---

### 有向图

#### find_articulation_points_directed

```moonbit
pub fn[G : @core.GraphDirected] find_articulation_points_directed(G) -> CutPointResult
```

查找有向图的割点。

---

#### find_bridges_directed

```moonbit
pub fn[G : @core.GraphDirected] find_bridges_directed(G) -> BridgeResult
```

查找有向图的桥。

---

## 结果类型

### CutPointResult

```moonbit
pub(all) struct CutPointResult {
  cut_points : Array[@core.NodeId]
  is_cut_point : Array[Bool]
  count : Int
}
```

**字段**:
- `cut_points`: 割点列表
- `is_cut_point`: 割点标记数组
- `count`: 割点数量

---

### BridgeResult

```moonbit
pub(all) struct BridgeResult {
  bridges : Array[@core.Edge]
  is_bridge : Array[Bool]
  count : Int
}
```

**字段**:
- `bridges`: 桥边列表
- `is_bridge`: 桥标记数组
- `count`: 桥数量

---

## 使用示例

```moonbit
let cut_result = @cutpoints.find_articulation_points_undirected(g)
println("Articulation points: \{cut_result.count}")

let bridge_result = @cutpoints.find_bridges_undirected(g)
println("Bridges: \{bridge_result.count}")
```
