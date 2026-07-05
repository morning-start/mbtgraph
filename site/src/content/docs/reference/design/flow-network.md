---
title: 网络流模块设计
description: FlowNetwork 独立类型模式与 6 种流算法的设计决策
---

> **模块**: `lib/algo/flow/` | **状态**: ✅ 6 个算法全部实现

---

## 1. 架构设计

### 1.1 独立类型模式

网络流模块采用 **独立类型模式**（而非 Trait 兼容型），这是 mbtgraph 中"双轨制"架构的典型案例：

```
Trait 兼容型（多数算法）： pub fn[G : GraphReadable] dijkstra(graph, start)
独立类型型（流网络）：    pub fn dinic(net : FlowNetwork, source, sink)
```

**决策理由**:
1. 流网络需要维护 `capacity` 和 `flow` 两个矩阵，语义上不同于一般图
2. `FlowNetwork` 使用 `Int` 节点索引而非 `NodeId`，避免装箱开销
3. 矩阵访问 O(1) 优于 trait 方法调用，对密集增广的流算法至关重要

### 1.2 类型层次

```
FlowNetwork
├── node_count : Int
├── capacity : Array[Array[Double]]
└── flow : Array[Array[Double]]

CostFlowNetwork (extends FlowNetwork)
└── cost : Array[Array[Double]]
```

---

## 2. 算法总览

| 算法 | 复杂度 | 特点 |
|------|:------:|------|
| Edmonds-Karp | O(VE²) | BFS 增广，实现简单 |
| Dinic ⭐ | O(V²E) | 分层图+阻塞流，通用最优 |
| 最小费用最大流 | O(F·E·V) | SSP 最短路增广 |
| Push-Relabel | O(V²√E) | 理论最优，HLPP 实现 |
| 容量缩放 | O(E²logU) | 按位缩放，大容量友好 |
| Stoer-Wagner | O(VE+V²logV) | 无向图全局最小割 |

---

## 3. 设计决策

### DDR-01: 返回值统一

所有流算法返回统一结果类型：

```moonbit
pub(all) struct MaxFlowResult {
  max_flow_value : Double
  source : Int
  sink : Int
  flow : Array[Array[Double]]
}
```

### DDR-02: 链式赋值模式

```moonbit
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)  // 链式赋值
let net = net.add_edge(1, 2, 12.0)
let result = dinic(net, 0, 3)       // 内部自动深拷贝
```

### DDR-03: 深拷贝保证

所有算法内部对 `flow` 和 `capacity` 矩阵进行深拷贝，保证输入网络不被修改：

```moonbit
pub fn dinic(net : FlowNetwork, s : Int, t : Int) -> MaxFlowResult {
  let flow = deep_copy_matrix(net.flow)  // 深拷贝
  let cap = net.capacity                 // 只读引用
  // ... 算法逻辑 ...
}
```

---

## 4. API 速查

```moonbit
// 创建流网络
let net = FlowNetwork::new(6)
let net = net.add_edge(0, 1, 16.0)
      .add_edge(0, 2, 13.0)
      .add_edge(1, 2, 10.0)

// 最大流
let result = dinic(net, 0, 5)
println("Max flow: \{result.max_flow_value}")

// 最小费用最大流
let cnet = CostFlowNetwork::new(4)
let cnet = cnet.add_edge(0, 1, 10.0, 2.0)
let result = min_cost_max_flow(cnet, 0, 3)

// 全局最小割
let cut = stoer_wagner(net)
```

### 模块函数

| 函数 | 说明 |
|------|------|
| `edmonds_karp(net, s, t)` | BFS 增广 |
| `dinic(net, s, t)` | ⭐ 推荐使用 |
| `min_cost_max_flow(cnet, s, t)` | 带费用 |
| `push_relabel(net, s, t)` | HLPP |
| `capacity_scaling(net, s, t)` | 大容量 |
| `stoer_wagner(net)` | 全局最小割 |
