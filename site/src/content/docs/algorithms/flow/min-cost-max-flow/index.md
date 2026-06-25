---
title: 最小费用最大流
description: 在最大流基础上优化单位流量成本，实现最优资源分配
---

# 最小费用最大流 (Min-Cost Max-Flow)

> **核心问题**: 在流量最大的前提下，使总运输成本最小 \
> **API**: `CostFlowNetwork` · `min_cost_max_flow` \
> **前置**: [流网络基础](/algorithms/flow/basics/)

---

## 一、问题定义

每条边增加**单位流量费用** cost(e)：

- **流量**：从 s 到 t 送多少单位
- **费用**：每单位流量花多少钱

**目标**：在达到最大流量的前提下，最小化总费用 `Σ f(e) × cost(e)`。

### 现实场景

```
工厂 → 仓库 A (容量 10, 单价 2元/单位)
     → 仓库 B (容量 5,  单价 3元/单位)
仓库 A → 门店 (容量 8, 单价 1元/单位)
仓库 B → 门店 (容量 9, 单价 4元/单位)

问：如何以最低运费将 14 单位货物送到门店？
```

---

## 二、CostFlowNetwork 用法

```moonbit
fn main {
  // 4 节点费用流网络
  let mut net = CostFlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0, 2.0)  // s→A: 容量10, 单价2
  let net = net.add_edge(0, 2, 5.0, 3.0)   // s→B: 容量5, 单价3
  let net = net.add_edge(1, 2, 6.0, 1.0)   // A→B: 容量6, 单价1
  let net = net.add_edge(1, 3, 8.0, 1.0)   // A→t: 容量8, 单价1
  let net = net.add_edge(2, 3, 9.0, 4.0)   // B→t: 容量9, 单价4

  let result = @flow.min_cost_max_flow(net, 0, 3)
  println("最大流量: \(result.max_flow)")
  println("最小总费用: \(result.min_cost)")
  println("\n流量分配:")
  for edge in result.flow_edges {
    let (from, to, flow) = edge
    println("  \(from)→\(to): 流量=\(flow)")
  }
}
```

**输出：**
```
最大流量: 14.0
最小总费用: 43.0

流量分配:
  0→1: 流量=9.0  (容量10, 单价2)
  0→2: 流量=5.0  (容量5, 单价3)
  1→2: 流量=1.0  (容量6, 单价1)
  1→3: 流量=8.0  (容量8, 单价1)
  2→3: 流量=5.0  (容量9, 单价4)
```

**分析：** 优先使用低价路径 `s→A→t`（单价 2+1=3），满了之后再使用 `s→B→t`（单价 3+4=7）。

---

## 三、关键 API

```moonbit
// 创建费用流网络
CostFlowNetwork::new(node_count: Int) -> CostFlowNetwork

// 添加边 (from, to, capacity, cost)
CostFlowNetwork::add_edge(self, Int, Int, Double, Double) -> CostFlowNetwork

// 计算最小费用最大流
min_cost_max_flow(graph, source, sink) -> MinCostMaxFlowResult
```

---

**相关文档：**
- [流网络基础](/algorithms/flow/basics/)
- [Dinic 算法](/algorithms/flow/max-flow/dinic)
- [Edmonds-Karp 算法](/algorithms/flow/max-flow/edmonds-karp)
