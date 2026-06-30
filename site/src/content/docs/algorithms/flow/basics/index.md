---
title: 流网络基础概念
description: 网络流的形式化定义、FlowNetwork 数据结构、最大流最小割定理
---

# 流网络基础概念

> **核心问题**: 从源点到汇点能输送的最大流量是多少？ \
> **API**: `FlowNetwork::new` · `add_edge` · `edmonds_karp` · `dinic`

---

## 一、流网络定义

**流网络** (Flow Network) 是一个有向图 G = (V, E)，具有以下特征：

1. **源点 s**：只有出边，流量产生点
2. **汇点 t**：只有入边，流量消耗点
3. **容量 c(e) ≥ 0**：每条边能承载的最大流量
4. **流量 f(e)**：实际经过的流量，满足 `0 ≤ f(e) ≤ c(e)`

### 流量守恒定律

除源点和汇点外，每个节点的**流入量 = 流出量**——就像水管中的水不会凭空消失。

### 经典类比

```
  ┌── 水厂（源点）──→ 管道(容量 10) ──→ 中转站 ──→ 管道(容量 8) ──→ 用户（汇点）
```

- 水厂能供水（源点）
- 用户需要水（汇点）
- 管道有容量限制（边有容量）
- 中转站不能存水（流量守恒）

---

## 二、FlowNetwork 数据结构

mbtgraph 使用独立的 `FlowNetwork` 类型（不是 GraphReadable Trait 的实现），包含**容量矩阵**和**流量矩阵**：

```moonbit
// 创建 4 个节点的流网络
let mut net = FlowNetwork::new(4)

// 添加边 (from, to, capacity)
let net = net.add_edge(0, 1, 10.0)  // s→A: 容量 10
let net = net.add_edge(0, 2, 5.0)   // s→B: 容量 5
let net = net.add_edge(1, 2, 6.0)   // A→B: 容量 6
let net = net.add_edge(1, 3, 8.0)   // A→t: 容量 8
let net = net.add_edge(2, 3, 9.0)   // B→t: 容量 9
```

> `add_edge` 使用链式赋值 `let net = net.add_edge(...)` 返回新实例，保持纯函数语义。

---

## 三、残差网络与增广路径

### 残差容量 (Residual Capacity)

对于边 e = (u, v) 和正向流量 f(e)：
- **向前残差**: c(u,v) - f(u,v) — 还能加多少流量
- **向后残差**: f(u,v) — 还能撤销多少流量（用于"反悔"）

### 增广路径 (Augmenting Path)

残差网络中从 s 到 t 的一条路径，路径上所有边的残差容量 > 0。

**核心思路：** 只要存在增广路径，就沿它推送流量；找不到增广路径时，当前流即为最大流。

---

## 四、最大流最小割定理

**定理**：最大流的流量值 = 最小割的容量值。

- **割**: 将节点分为 S 和 T 两部分（s∈S, t∈T），割的容量 = 从 S 到 T 的边容量之和
- **最小割**: 容量最小的割

这个定理是网络流的基石——它将"最大流量"问题等价于"最薄弱环节"问题。

---

## 五、算法速览

| 算法 | 时间复杂度 | 增广方式 | 适用场景 |
|------|:----------:|---------|---------|
| **Edmonds-Karp** | O(VE²) | BFS 最短路 | ⭐ 教学首选 |
| **Dinic** | O(E√V) ~ O(V²E) | 分层 + DFS | ⭐ 默认推荐 |
| **Push-Relabel** | O(V²E) | 预流推进 | 并行计算 |
| **容量缩放** | O(E² log C) | 按位缩放 | 大容量图 |

---

**相关文档：**
- [Edmonds-Karp 算法](/algorithms/flow/max-flow/edmonds-karp)
- [Dinic 算法](/algorithms/flow/max-flow/dinic)
- [Ford-Fulkerson 方法](/algorithms/flow/max-flow/ford-fulkerson)
- [最小费用最大流](/algorithms/flow/min-cost-max-flow/index/)
