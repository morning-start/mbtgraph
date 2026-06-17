# Flow API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/flow`
> **路径**: `lib/algo/flow/`

## 概述

Flow 模块提供网络流算法，包括最大流、最小费用最大流和全局最小割。

---

## 函数

### edmonds_karp

```moonbit
pub fn edmonds_karp(FlowNetwork, Int, Int) -> MaxFlowResult
```

Edmonds-Karp 算法：基于 BFS 的最大流。

**参数**:
- `FlowNetwork`: 流网络
- `Int`: 源点
- `Int`: 汇点

**复杂度**: O(VE²)

---

### dinic

```moonbit
pub fn dinic(FlowNetwork, Int, Int) -> MaxFlowResult
```

Dinic 算法：基于分层图的最大流。

**复杂度**: O(V²E)

---

### push_relabel

```moonbit
pub fn push_relabel(FlowNetwork, Int, Int) -> MaxFlowResult
```

Push-Relabel 算法：预流推进最大流。

**复杂度**: O(V²E)

---

### capacity_scaling

```moonbit
pub fn capacity_scaling(FlowNetwork, Int, Int) -> MaxFlowResult
```

Capacity Scaling 算法：容量缩放最大流。

---

### min_cost_max_flow

```moonbit
pub fn min_cost_max_flow(CostFlowNetwork, Int, Int) -> MinCostMaxFlowResult
```

最小费用最大流算法。

**参数**:
- `CostFlowNetwork`: 带费用的流网络
- `Int`: 源点
- `Int`: 汇点

---

### stoer_wagner

```moonbit
pub fn stoer_wagner(Array[Array[Double]]) -> StoerWagnerResult
```

Stoer-Wagner 算法：全局最小割。

**参数**:
- `Array[Array[Double]]`: 邻接矩阵

---

## 类型

### FlowNetwork

```moonbit
pub(all) struct FlowNetwork {
  node_count : Int
  capacity : Array[Array[Double]]
  flow : Array[Array[Double]]
}
pub fn FlowNetwork::new(Int) -> Self
pub fn FlowNetwork::add_edge(Self, Int, Int, Double) -> Self
```

**方法**:
| 方法 | 签名 | 说明 |
|------|------|------|
| `new(Int)` | `Self` | 创建指定节点数的流网络 |
| `add_edge(Int, Int, Double)` | `Self` | 添加边（返回自身，支持链式调用） |

**使用模式**:
```moonbit
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)
let net = net.add_edge(0, 2, 13.0)
let result = edmonds_karp(net, 0, 3)
```

---

### CostFlowNetwork

```moonbit
pub(all) struct CostFlowNetwork {
  node_count : Int
  capacity : Array[Array[Double]]
  cost : Array[Array[Double]]
  flow : Array[Array[Double]]
}
pub fn CostFlowNetwork::new(Int) -> Self
pub fn CostFlowNetwork::add_edge(Self, Int, Int, Double, Double) -> Self
```

**方法**:
| 方法 | 签名 | 说明 |
|------|------|------|
| `new(Int)` | `Self` | 创建指定节点数的费用流网络 |
| `add_edge(Int, Int, Double, Double)` | `Self` | 添加边（容量, 费用） |

---

## 结果类型

### MaxFlowResult

```moonbit
pub(all) struct MaxFlowResult {
  max_flow : Double
  flow_matrix : Array[Array[Double?]]
}
```

**字段**:
- `max_flow`: 最大流量
- `flow_matrix`: 流量矩阵

---

### MinCostMaxFlowResult

```moonbit
pub(all) struct MinCostMaxFlowResult {
  max_flow : Double
  min_cost : Double
  flow_matrix : Array[Array[Double?]]
}
```

**字段**:
- `max_flow`: 最大流量
- `min_cost`: 最小费用
- `flow_matrix`: 流量矩阵

---

### StoerWagnerResult

```moonbit
pub(all) struct StoerWagnerResult {
  min_cut_weight : Double
  partition : Array[Int]
}
```

**字段**:
- `min_cut_weight`: 最小割权重
- `partition`: 分区标记

---

## 使用示例

```moonbit
// 最大流
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)
let net = net.add_edge(0, 2, 13.0)
let net = net.add_edge(1, 2, 10.0)
let net = net.add_edge(1, 3, 12.0)
let net = net.add_edge(2, 1, 4.0)
let net = net.add_edge(2, 3, 14.0)
let result = dinic(net, 0, 3)
println("Max flow: \{result.max_flow}")
```
