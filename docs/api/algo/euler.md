# Euler API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/euler`
> **路径**: `lib/algo/euler/`

## 概述

Euler 模块提供欧拉路径和欧拉回路检测与查找算法。

---

## 函数

### 检测函数

#### has_euler_circuit_directed

```moonbit
pub fn[G : @core.GraphDirected] has_euler_circuit_directed(G) -> Bool
```

检测有向图是否存在欧拉回路。

---

#### has_euler_circuit_undirected

```moonbit
pub fn[G : @core.GraphReadable] has_euler_circuit_undirected(G) -> Bool
```

检测无向图是否存在欧拉回路。

---

#### has_euler_path_directed

```moonbit
pub fn[G : @core.GraphDirected] has_euler_path_directed(G) -> Bool
```

检测有向图是否存在欧拉路径。

---

#### has_euler_path_undirected

```moonbit
pub fn[G : @core.GraphReadable] has_euler_path_undirected(G) -> Bool
```

检测无向图是否存在欧拉路径。

---

### 查找函数

#### find_euler_circuit_directed

```moonbit
pub fn[G : @core.GraphDirected] find_euler_circuit_directed(G) -> EulerCircuitResult
```

查找有向图的欧拉回路（Hierholzer 算法）。

---

#### find_euler_circuit_undirected

```moonbit
pub fn[G : @core.GraphReadable] find_euler_circuit_undirected(G) -> EulerCircuitResult
```

查找无向图的欧拉回路。

---

#### find_euler_path_directed

```moonbit
pub fn[G : @core.GraphDirected] find_euler_path_directed(G) -> EulerPathResult
```

查找有向图的欧拉路径。

---

#### find_euler_path_undirected

```moonbit
pub fn[G : @core.GraphReadable] find_euler_path_undirected(G) -> EulerPathResult
```

查找无向图的欧拉路径。

---

## 结果类型

### EulerCircuitResult

```moonbit
pub(all) struct EulerCircuitResult {
  exists : Bool
  circuit : Array[@core.Edge]
  start_node : @core.NodeId?
} derive(Debug)
```

**字段**:
- `exists`: 是否存在欧拉回路
- `circuit`: 欧拉回路边序列
- `start_node`: 起始节点

---

### EulerPathResult

```moonbit
pub(all) struct EulerPathResult {
  exists : Bool
  path : Array[@core.Edge]
  start_node : @core.NodeId?
  end_node : @core.NodeId?
} derive(Debug)
```

**字段**:
- `exists`: 是否存在欧拉路径
- `path`: 欧拉路径边序列
- `start_node`: 起始节点
- `end_node`: 终止节点

---

## 使用示例

```moonbit
if @euler.has_euler_circuit_undirected(g) {
  let result = @euler.find_euler_circuit_undirected(g)
  for edge in result.circuit {
    println("\{edge.from} -> \{edge.to}")
  }
}
```
