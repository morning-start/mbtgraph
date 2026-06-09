---
title: "Edmonds-Karp 算法：最大流"
description: "基于 BFS 最短增广路的 Ford-Fulkerson 实现，残差图与瓶颈容量，O(VE²) 时间复杂度"
---

# 💧 Edmonds-Karp 算法：最大流（Max Flow）

> **"想象一个城市供水系统：水源通过管道网络向各城区供水，每根管道有最大输送能力。如何调度才能让总供水量最大化？——这就是最大流问题的本质。"**

## 📖 目录

- [算法简介](#算法简介)
- [核心概念](#核心概念)
- [动画演示](#动画演示)
- [MoonBit 完整实现](#moonbit-完整实现)
- [代码详解](#代码详解)
- [使用示例](#使用示例)
- [复杂度分析](#复杂度分析)
- [实际应用场景](#实际应用场景)
- [练习题](#练习题)
- [相关资源](#相关资源)
- [总结清单](#总结清单)

---

## 算法简介

### 什么是最大流问题？

给定一个**流网络**（带容量的有向图），从**源点 (Source)** 到**汇点 (Sink)** 传输"流"，使得：

1. **容量约束**：每条边的流量 ≤ 该边的容量
2. **流量守恒**：中间节点的流入量 = 流出量
3. **目标**：最大化从源点到汇点的总流量

```
        ┌───[10]──→ ② ←──[5]───┐
       ↗              │            │
     [20]         [15] │         [10]
    ↓              ↓    ↓          ↓
   (S)① ────→ ③ ────→ ④ ──────→ (T)⑤
              [10]      [15]

   S=源点(Source), T=汇点(Sink)
   [n] = 边容量
   目标: 最大化 S → T 的总流量
```

### Edmonds-Karp 是什么？

**Edmonds-Karp 算法** (1972) 是 **Ford-Fulkerson 方法** 的具体化：

| 方法 | 增广路选择策略 | 时间复杂度 |
|------|---------------|-----------|
| Ford-Fulkerson (通用) | 任意/DFS | O(E × max_flow) — 可能不终止！ |
| **Edmonds-Karp** | **BFS 最短路径** | **O(V E²)** — 保证多项式终止 ✅ |
| Dinic | DFS 分层 + 阻塞流 | O(E√V) 或 O(V²E) |

### 算法核心流程

```
┌────────────────────────────────────────────────────┐
│               EDMONDS-KARP 主循环                    │
├────────────────────────────────────────────────────┤
│                                                    │
│  while true:                                       │
│    1. BFS 在残差图中找 S→T 路径                     │
│       └─ 找不到 → 结束，返回最大流                   │
│                                                    │
│    2. 计算路径上的瓶颈容量 (bottleneck)             │
│       └─ bottleneck = min(路径上每条边的剩余容量)     │
│                                                    │
│    3. 沿路径增广:                                   │
│       ├─ 正向边: flow += bottleneck                 │
│       └─ 反向边: flow -= bottleneck (允许撤销!)      │
│                                                    │
│    4. total_flow += bottleneck                      │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## 核心概念

### 🌊 流网络 (Flow Network)

在 mbtgraph 中，`FlowNetwork` 是一个**独立类型**，不继承 `GraphReadable` trait：

```moonbit
pub(all) struct FlowNetwork {
  node_count : Int                  // 节点数
  capacity : Array[Array[Double]]   // 容量矩阵 capacity[u][v]
  flow : Array[Array[Double]]      // 流量矩阵 flow[u][v]
}
```

**为什么独立类型？**
- 流网络需要同时维护**容量**和**流量**两个矩阵
- 需要 O(1) 的随机访问（邻接矩阵语义）
- 与通用图接口的语义差异较大

### 📊 残差图 (Residual Graph)

这是最大流算法的**核心概念**！残差图表示当前状态下还能发送多少额外流量：

```
对于边 (u, v):
  残余容量 = capacity[u][v] - flow[u][v]

如果 flow[u][v] = 3, capacity[u][v] = 10:
  正向还可送: 10 - 3 = 7
  反向可撤销: 3 (把之前送的流量"退回来")
```

**关键洞察**：反向边允许我们**撤销之前的决策**！

```
原始决策: 在 (u,v) 上送了 3 单位流量
后悔了?   → 通过反向边 (v,u) "退回" 最多 3 单位
          → 相当于重新选择另一条路径
```

### 🔍 增广路径 (Augmenting Path)

在残差图中从 S 到 T 的**任意一条可行路径**：

```
增广路径要求: 路径上每条边的剩余容量 > 0

示例:
  S ──[剩7]──→ A ──[剩5]──→ B ──[剩3]──→ T
  这是一条有效的增广路径!
```

### 🚧 瓶颈容量 (Bottleneck)

增广路径上**最小的剩余容量**，决定了这次能推送多少流量：

```
路径: S → A → B → T
剩余: [7, 5, 3]

bottleneck = min(7, 5, 3) = 3

→ 这次增广只能推送 3 单位流量
→ 推送后: [4, 2, 0]  (B→T 边饱和了!)
```

### ✅ 最大流最小割定理 (Max-Flow Min-Cut Theorem)

> **定理**：最大流的值 = 最小割的容量

这意味着：当找不到增广路时，当前的流就是最大的。**Edmonds-Karp 的终止条件正是基于此**。

---

## 动画演示

### 示例网络

使用经典示例来演示完整的 Edmonds-Karp 执行过程：

```
          ┌───[10]──→ ②
         ↗            │ ↓
       [16]         [12]│ [9]
       ↓             ↓  ↓
   (S)① ────→ ③ ────→ (T)④
           [13]

   节点: ①=S(源), ②, ③, ④=T(汇)
   边:   ①→②(cap=10), ①→③(cap=16), ②→③(cap=12),
         ②→④(cap=9), ③→④(cap=13)
```

### 初始化状态

```
┌─────────────────────────────────────────────────────┐
│  容量矩阵 (capacity)                                │
├────┬────┬────┬────┬────┐                           │
│    │ ①  │ ②  │ ③  │ ④  │                           │
├────┼────┼────┼────┼────┤                           │
│ ①  │  0 │ 10 │ 16 │  0 │                           │
│ ②  │  0 │  0 │ 12 │  9 │                           │
│ ③  │  0 │  0 │  0 │ 13 │                           │
│ ④  │  0 │  0 │  0 │  0 │                           │
└────┴────┴────┴────┴────┘

┌─────────────────────────────────────────────────────┐
│  流量矩阵 (flow) — 初始全为 0                        │
├────┬────┬────┬────┬────┐                           │
│    │ ①  │ ②  │ ③  │ ④  │                           │
├────┼────┼────┼────┼────┤                           │
│ ①  │  0 │  0 │  0 │  0 │                           │
│ ②  │  0 │  0 │  0 │  0 │                           │
│ ③  │  0 │  0 │  0 │  0 │                           │
│ ④  │  0 │  0 │  0 │  0 │                           │
└────┴────┴────┴────┴────┘

  total_flow = 0
```

---

### 🎬 第 1 次 BFS 寻找增广路

```
BFS 从 S(①) 开始:

  队列: [①]
  访问 ①:
    ①→②: 剩余 = 10-0 = 10 > 0 ✓ → 入队, parent[②]=①
    ①→③: 剩余 = 16-0 = 16 > 0 ✓ → 入队, parent[③]=①

  队列: [②, ③]
  访问 ②:
    ②→③: 剩余 = 12-0 = 12 > 0 ✓ → 入队, parent[③]=① (已有,跳过)
    ②→④: 剩余 = 9-0 = 9 > 0 ✓ → 入队! parent[④]=②
    ⚡ 到达 T(④)! 找到增广路!

  增广路径: ① → ② → ④  (最短路径, 长度=2)
```

**计算瓶颈容量**：
```
路径: ①→②→④
  ①→②: cap-flow = 10 - 0 = 10
  ②→④: cap-flow = 9 - 0 = 9
  bottleneck = min(10, 9) = **9**
```

**增广操作**：
```
正向边增加流量:
  flow[①][②] += 9  → flow[①][②] = 9
  flow[②][④] += 9  → flow[②][④] = 9

反向边减少流量 (用于未来撤销):
  flow[②][①] -= 9  → flow[②][①] = -9
  flow[④][②] -= 9  → flow[④][②] = -9

total_flow = 0 + 9 = **9**
```

**增广后的流量矩阵**：
```
     ①    ②    ③    ④
① [   0,   9,   0,   0 ]
② [  -9,   0,   0,   9 ]
③ [   0,   0,   0,   0 ]
④ [   0,  -9,   0,   0 ]
```

---

### 🎬 第 2 次 BFS 寻找增广路

```
当前残差 (cap - flow, 忽略 ≤0):

  ①→②: 10-9 = 1    ①→③: 16-0 = 16
  ②→③: 12-0 = 12   ②→④: 9-9 = 0 (饱和!)
  ③→④: 13-0 = 13

BFS:
  ① → ②(剩1), ③(剩16)
  ② → ③(剩12)  [②→④ 已饱和,跳过]
  ③ → **④**(剩13)! ✓

  增广路径: ① → ③ → 4
```

**计算瓶颈容量**：
```
  ①→③: 16 - 0 = 16
  ③→④: 13 - 0 = 13
  bottleneck = min(16, 13) = **4**
```

**增广后**：
```
flow[①][3] += 4  → 4
flow[3][4] += 4  → 4
(反向边相应更新...)

total_flow = 9 + 4 = **13**

流量矩阵:
     ①    ②    ③    ④
① [   0,   9,   4,   0 ]
② [  -9,   0,   0,   9 ]
③ [   0,   0,   0,   4 ]
④ [   0,  -9,  -4,   0 ]
```

---

### 🎬 第 3 次 BFS 寻找增广路

```
当前残差:

  ①→②: 10-9 = 1    ①→③: 16-4 = 12
  ②→③: 12-0 = 12   ②→④: 9-9 = 0 (饱和!)
  ③→④: 13-4 = 9

BFS:
  ① → ②(剩1), ③(剩12)
  ② → ③(剩12)
  ③ → **④**(剩9)! ✓

  增广路径: ① → ② → ③ → 4
```

**瓶颈容量**：
```
  ①→②: 1,  ②→③: 12,  ③→④: 9
  bottleneck = min(1, 12, 9) = **1**
```

**增广后**：
```
flow[①][2] += 1  → 10  (①→₂ 饱和!)
flow[2][3] += 1  → 1
flow[3][4] += 1  → 5

total_flow = 13 + 1 = **14**
```

---

### 🎬 第 4 次 BFS — 关键的一步！

```
当前残差:

  ①→②: 10-10 = 0 (饱和!)   ①→③: 16-4 = 12
  ②→③: 12-1 = 11          ②→④: 9-9 = 0 (饱和!)
  ③→④: 13-5 = 8

  ★ 反向边也参与残差计算! ★
  ②→①: 0 - (-9) = 9  (可以"退还" 9 单位!)

BFS:
  ① → ③(剩12)           [①→② 已饱和]
  ③ → ②?  ③→②: 0-0=0, 但 ②的反向...
     等等, 让我仔细看:

  实际上 BFS 在残差图中搜索时:
  对每个邻居 v, 检查 capacity[u][v] - flow[u][v] > 0

  从 ③ 出发:
    ③→④: 13-5 = 8 > 0 ✓ → 可以到 ④!

  增广路径: ① → ③ → 4
```

**瓶颈容量**：
```
  ①→③: 12,  ③→④: 8
  bottleneck = min(12, 8) = **8**
```

**增广后**：
```
flow[①][3] += 8  → 12
flow[3][4] += 8  → 13  (③→₄ 饱和!)

total_flow = 14 + 8 = **22**

流量矩阵 (最终):
     ①    ②    ③    ④
① [   0,  10,  12,   0 ]
② [ -10,   0,   1,   9 ]
③ [   0,   0,   0,  13 ]
④ [   0,  -9, -13,   0 ]
```

---

### 🎬 第 5 次 BFS — 终止检测

```
当前残差:

  ①→②: 0 (饱和!)    ①→③: 4 (还剩一点)
  ②→③: 11           ②→④: 0 (饱和!)
  ③→④: 0 (饱和!)

BFS 从 ①:
  ① → ③(剩4)
  ③ 的邻居:
    ③→④: 0 (饱和!)
    ③→②: 0-1=-1 (但检查反向: flow[②][3]=1, 所以 ③→₂ 方向的残差?)

让我用代码逻辑:
  对于边 (u,v): residual = capacity[u][v] - flow[u][v]
  ③→④: 13 - 13 = 0  ❌
  ③→②: 0 - 1 = -1  ❌

  从 ③ 无法到达任何未访问节点!

  ② 呢? 能从 ① 到达 ② 吗?
  ①→②: 0  ❌ (饱和)

BFS 结束, 未到达 T!

⛔ **找不到增广路 → 算法终止!**

🎉 **最大流 = 22**
```

---

### 📊 完整执行过程汇总

```
═══════════════════════════════════════════════════════
           EDMONDS-KARP 执行总览
═══════════════════════════════════════════════════════

  迭代 #1: 路径 ①→②→④     瓶颈=9   总流=9
  迭代 #2: 路径 ①→③→④     瓶颈=4   总流=13
  迭代 #3: 路径 ①→②→③→④   瓶颈=1   总流=14
  迭代 #4: 路径 ①→③→④     瓶颈=8   总流=22
  迭代 #5: BFS 失败 → 终止

═══════════════════════════════════════════════════════
  最终结果: MAX_FLOW = 22
═══════════════════════════════════════════════════════

  最终流量分布:
   ①→②: 10/10 (100% 利用) 🔴饱和
   ①→③: 12/16 (75% 利用)
   ②→③: 1/12  (8% 利用)
   ②→④: 9/9  (100% 利用) 🔴饱和
   ③→④: 13/13 (100% 利用) 🔴饱和
```

---

## MoonBit 完整实现

以下是 mbtgraph 中 Edmonds-Karp 的完整实现：

```moonbit
///|
/// Edmonds-Karp 最大流算法
///
/// 使用 BFS 寻找最短增广路，时间复杂度 O(VE²)。
/// 每次增广沿瓶颈值更新正向流量、减少反向流量（残差图语义）。
///|

// BFS 在残差图中寻找增广路径
fn ek_bfs(
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
  n : Int,
  source : Int,
  sink : Int,
) -> (Array[Int?], Bool) {
  let parent : Array[Int?] = Array::make(n, None)
  let visited : Array[Bool] = Array::make(n, false)
  let queue : Array[Int] = [source]
  visited[source] = true
  let mut head = 0

  while head < queue.length() {
    let u = queue[head]
    head = head + 1
    let mut v = 0
    while v < n {
      if !visited[v] {
        // 检查正向边和反向边的残余容量
        let forward_cap = capacity[u][v] - flow[u][v]
        let backward_cap = flow[v][u]
        if forward_cap > 0.000001 || backward_cap > 0.000001 {
          parent[v] = Some(u)
          visited[v] = true
          if v == sink {
            return (parent, true)  // 找到增广路!
          }
          queue.push(v)
        }
      }
      v = v + 1
    }
  }
  (parent, false)  // 未找到增广路
}

// 找到增广路径上的瓶颈容量
fn ek_find_path_bottleneck(
  parent : Array[Int?],
  sink : Int,
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
) -> Double {
  let mut bottleneck = 1000000000000000000.0
  let mut cur = sink
  while true {
    match parent[cur] {
      None => break
      Some(p) => {
        let residual = capacity[p][cur] - flow[p][cur]
        if residual < bottleneck && residual > 0.0 {
          bottleneck = residual
        }
        cur = p
      }
    }
  }
  bottleneck
}

// 沿增广路径进行流量增广
fn ek_augment(
  parent : Array[Int?],
  source : Int,
  sink : Int,
  _capacity : Array[Array[Double]],
  flow_ref : Array[Array[Double]],
  bottleneck : Double,
) -> Unit {
  let mut v = sink
  while v != source {
    match parent[v] {
      None => break
      Some(u) => {
        flow_ref[u][v] = flow_ref[u][v] + bottleneck   // 正向边增加
        flow_ref[v][u] = flow_ref[v][u] - bottleneck   // 反向边减少 (允许撤销)
        v = u
      }
    }
  }
}

// 矩阵深拷贝 (保证纯函数语义)
fn deep_copy_matrix(src : Array[Array[Double]]) -> Array[Array[Double]] {
  let result : Array[Array[Double]] = []
  for i in 0..<src.length() {
    let row : Array[Double] = []
    for j in 0..<src[i].length() {
      row.push(src[i][j])
    }
    result.push(row)
  }
  result
}

// 公开 API
pub fn edmonds_karp(
  graph : FlowNetwork,
  source : Int,
  sink : Int,
) -> MaxFlowResult {
  let n = graph.node_count

  // 边界检查
  if n == 0 ||
    source < 0 || source >= n ||
    sink < 0 || sink >= n ||
    source == sink {
    return MaxFlowResult::{ max_flow: 0.0, flow_matrix: [] }
  }

  let work_flow = deep_copy_matrix(graph.flow)
  let mut total_flow = 0.0

  // 主循环: 不断寻找增广路
  while true {
    let (parent, found) = ek_bfs(graph.capacity, work_flow, n, source, sink)
    if !found {
      break  // 无增广路 → 达到最大流
    }

    let bottleneck = ek_find_path_bottleneck(
      parent, sink, graph.capacity, work_flow
    )
    if bottleneck <= 0.000001 {
      break
    }

    ek_augment(parent, source, sink, graph.capacity, work_flow, bottleneck)
    total_flow = total_flow + bottleneck
  }

  // 构建结果矩阵 (只保留正向流量)
  let result_matrix : Array[Array[Double?]] = []
  for i in 0..<n {
    let row : Array[Double?] = []
    for j in 0..<n {
      if work_flow[i][j] > 0.000001 {
        row.push(Some(work_flow[i][j]))
      } else {
        row.push(None)
      }
    }
    result_matrix.push(row)
  }

  MaxFlowResult::{ max_flow: total_flow, flow_matrix: result_matrix }
}
```

---

## 代码详解

### 设计决策 1️⃣：为什么选择 BFS 而非 DFS？

```moonbit
// Edmonds-Karp: 使用 BFS (队列)
let queue : Array[Int] = [source]
// ... FIFO 顺序探索

// Ford-Fulkerson (原始版): 可能使用 DFS (栈)
// 问题: DFS 可能反复选择"不好"的长路径
//       导致增广次数过多 → O(E × max_flow) 可能指数级!
```

**BFS 的优势**：
- **总是找到最短增广路**（边数最少）
- 保证每条边至多成为瓶颈 **O(V)** 次
- 从而得到 **O(VE²)** 的严格多项式上界

### 设计决策 2️⃣：为什么需要反向边？

```moonbit
flow_ref[v][u] = flow_ref[v][u] - bottleneck  // 反向边减少
```

**没有反向边的问题**：
```
假设第一次选择了次优路径:
  S → A → B → T  (送了 5 单位)

后来发现更好的路径:
  S → C → D → T  (本可以送 10 单位)
  但中间需要经过 B，而 B→T 已经被之前的 5 单位占用了!

没有反向边: 卡死了, 最大流不是最优的
有反向边:   可以通过 B→A 的反向边"退还",
             然后 S→C→D→B→T 送更多流量
```

### 设计决策 3️⃣：为什么用 `FlowNetwork` 独立类型？

```moonbit
pub(all) struct FlowNetwork {
  node_count : Int
  capacity : Array[Array[Double]]
  flow : Array[Array[Double]]
}
```

**原因**：
| 需求 | GraphReadable trait | FlowNetwork |
|------|---------------------|-------------|
| 容量查询 | ❌ 不支持 | ✅ capacity[][] |
| 流量修改 | ❌ 只读语义 | ✅ 可变 flow[][] |
| 矩阵随机访问 | O(neighbors) 遍历 | O(1) 直接访问 |
| 双矩阵管理 | 不适用 | ✅ capacity + flow |

### 设计决策 4️⃣：浮点数精度处理

```moonbit
if forward_cap > 0.000001 || backward_cap > 0.000001 {
if bottleneck <= 0.000001 { break }

**原因**: Double 浮点数存在精度误差。
使用 ε = 10⁻⁶ 作为"实质为零"的阈值，
避免因 0.0000001 这样的微小值导致的无限循环。
```

---

## 使用示例

### 示例 1：基础用法 — 网络带宽分配

```moonbit
use lib.algo.flow.{edmonds_karp, FlowNetwork}

fn main {
  // 创建 4 节点流网络 (0=源, 3=汇)
  let net = FlowNetwork::new(4)

  // 添加管道 (from, to, capacity)
  let net = net.add_edge(0, 1, 10.0)   // S→A, 容量 10
  let net = net.add_edge(0, 2, 16.0)   // S→B, 容量 16
  let net = net.add_edge(1, 2, 12.0)   // A→B, 容量 12
  let net = net.add_edge(1, 3, 9.0)    // A→T, 容量 9
  let net = net.add_edge(2, 3, 13.0)   // B→T, 容量 13

  // 计算 0 → 3 的最大流
  let result = edmonds_karp(net, 0, 3)

  println("最大流: ${result.max_flow}")
  // 输出: 最大流: 22.0

  // 打印流量矩阵
  println("流量分布:")
  let mut i = 0
  while i < result.flow_matrix.length() {
    let mut j = 0
    while j < result.flow_matrix[i].length() {
      match result.flow_matrix[i][j] {
        Some(f) => println("  [${i}→${j}]: ${f}"),
        None => ()
      }
      j = j + 1
    }
    i = i + 1
  }
  // 输出:
  //   [0→1]: 10
  //   [0→2]: 12
  //   [1→2]: 1
  //   [1→3]: 9
  //   [2→3]: 13
}
```

### 示例 2：二分图最大匹配

```moonbit
// 将二分图匹配转化为最大流问题
//
// 左侧: 工人 W1, W2, W3 (节点 0,1,2)
// 右侧: 工作 J1, J2, J3 (节点 3,4,5)
// 源: S=6, 汇: T=7
//
// 边: S→Wi (容量1), Wi→Jj (若工人i能做工作j, 容量1), Jj→T (容量1)

fn maximum_bipartite_matching(
  workers : Int,
  jobs : Int,
  edges : Array[Tuple2[Int, Int]],
) -> Int {
  let n = workers + jobs + 2  // +2 for S and T
  let s = workers + jobs       // Source index
  let t = workers + jobs + 1   // Sink index

  let mut net = FlowNetwork::new(n)

  // S → 每个工人 (容量 1)
  let mut w = 0
  while w < workers {
    let net = net.add_edge(s, w, 1.0)
    w = w + 1
  }

  // 每个工作 → T (容量 1)
  let mut j = 0
  while j < jobs {
    let net = net.add_edge(workers + j, t, 1.0)
    j = j + 1
  }

  // 工人 → 工作 的匹配边
  for edge in edges {
    let net = net.add_edge(edge.0, workers + edge.1, 1.0)
  }

  let result = edmonds_karp(net, s, t)
  result.max_flow |> int()  // 最大匹配数
}

// 3 个工人, 3 个工作
let matching_edges = [
  (0, 0),  // W1 能做 J1
  (0, 1),  // W1 能做 J2
  (1, 1),  // W2 能做 J2
  (1, 2),  // W2 能做 J3
  (2, 0),  // W3 能做 J1
  (2, 2),  // W3 能做 J3
]

let max_match = maximum_bipartite_matching(3, 3, matching_edges)
println("最大匹配数: ${max_match}")
// 输出: 最大匹配数: 3 (完美匹配!)
```

### 示例 3：网络冗余容量分析

```moonbit
fn analyze_network_redundancy(
  capacities : Array[Tuple4[Int, Int, Double, String]],
  source : Int,
  sink : Int,
  node_count : Int,
) -> Tuple2[Double, Array[String]] {
  let mut net = FlowNetwork::new(node_count)
  for cap in capacities {
    let net = net.add_edge(cap.0, cap.1, cap.2)
  }

  let result = edmonds_karp(net, source, sink)

  // 分析各边的利用率
  let mut analysis : Array[String] = []
  for cap in capacities {
    let used = match result.flow_matrix[cap.0][cap.1] {
      Some(f) => f,
      None => 0.0
    }
    let utilization = if cap.2 > 0.0 { used / cap.2 * 100.0 } else { 0.0 }
    let status = if utilization >= 99.9 {
      "🔴 瓶颈"
    } else if utilization >= 50.0 {
      "🟡 中等"
    } else {
      "🟢 充裕"
    }
    analysis.push("${cap.3}: ${used}/${cap.2} (${utilization:.1f}%) ${status}")
  }

  (result.max_flow, analysis)
}

// 分析数据中心网络
let caps = [
  (0, 1, 10.0, "核心→交换A"),
  (0, 2, 15.0, "核心→交换B"),
  (1, 3, 8.0,  "交换A→服务器1"),
  (1, 4, 6.0,  "交换A→服务器2"),
  (2, 4, 10.0, "交换B→服务器2"),
  (2, 5, 12.0, "交换B→服务器3"),
  (3, 6, 8.0,  "服务器1→存储"),
  (4, 6, 12.0, "服务器2→存储"),
  (5, 6, 10.0, "服务器3→存储"),
]

let (max_f, report) = analyze_network_redundancy(caps, 0, 6, 7)
println("总吞吐量: ${max_f}")
for line in report {
  println(line)
}
```

---

## 复杂度分析

### 时间复杂度：O(V E²)

| 阶段 | 操作 | 复杂度 | 次数 |
|------|------|--------|------|
| BFS 寻找增广路 | 遍历 V 个节点、E 条边 | O(V + E) | O(VE) 次 |
| 计算瓶颈容量 | 回溯路径 | O(V) | O(VE) 次 |
| 增广操作 | 更新路径上的边 | O(V) | O(VE) 次 |
| **总计** | | **O(V E²)** | |

**为什么是 O(VE) 次增广？**

关键定理：在 Edmonds-Karp 中，每条边至多成为**瓶颈 O(V)** 次。

*直觉证明*：每次某边 (u,v) 成为瓶颈，BFS 找到的最短路径长度严格增加。而最长简单路径长度 ≤ V-1，所以至多增加 O(V) 次。

### 空间复杂度：O(V²)

| 数据结构 | 用途 | 大小 |
|---------|------|------|
| `capacity[][]` | 容量矩阵 | O(V²) |
| `flow[][]` | 流量矩阵 | O(V²) |
| `parent[]` | BFS 父节点 | O(V) |
| `visited[]` | BFS 访问标记 | O(V) |
| `queue[]` | BFS 队列 | O(V) |
| **总计** | | **O(V²)** |

### 算法对比

```
┌────────────────┬──────────────┬──────────────┬──────────────┐
│    算法        │  时间复杂度    │  空间复杂度    │  特点         │
├────────────────┼──────────────┼──────────────┼──────────────┤
│ Ford-Fulkerson │ O(E·max_flow)│ O(V²)        │ 可能不终止!  │
│ Edmonds-Karp   │ O(V·E²)      │ O(V²)        │ 保证终止 ✅   │
│ Dinic          │ O(E·V²)      │ O(V²)        │ 实际最快     │
│ Push-Relabel   │ O(V³)        │ O(V²)        │ 并行友好     │
└────────────────┴──────────────┴──────────────┴──────────────┘
```

---

## 实际应用场景

### 🌐 场景 1：网络带宽调度

**问题**：数据中心各服务器之间的数据传输，如何最大化吞吐量？

**解决方案**：构建流网络，链路带宽为容量，运行 Edmonds-Karp

**实例**：SDN 软件定义网络的集中式路由

### 👥 场景 2：二分图匹配

**问题**：求职者与岗位的最优匹配、学生与学校的录取

**解决方案**：转化为最大流问题（如示例 2）

**意义**：匹配问题是组合优化的基础

### 🚗 场景 3：交通流量规划

**问题**：城市道路网中，如何安排信号灯使车流量最大？

**解决方案**：路口为节点，道路为有向边（容量=车道数×限速）

**工具**：Google Maps 的路线规划内核

### 🖼️ 场景 4：图像分割 (Image Segmentation)

**问题**：将图像的前景与背景分离

**解决方案**：构建像素图 + 源/汇，最大流 = 最小割 = 最佳分割

**经典算法**：Graph Cut (Boykov-Kolmogorov)

---

## 练习题

### 练习 1：手动执行 Edmonds-Karp ⭐⭐

对以下网络手动执行 Edmonds-Karp（S=0, T=3）：

```
  0 ──[3]──→ 1 ──[2]──→ 3
  │                       ↑
  └──[2]──→ 2 ──[3]──────┘

  边: 0→1(3), 0→2(2), 1→3(2), 2→3(3)
```

<details>
<summary>📖 参考答案</summary>

```
初始: flow 全为 0

Iter 1: BFS 0→1→3, bottleneck=min(3,2)=2
  flow: 0→1=2, 1→3=2, total=2

Iter 2: BFS 0→2→3, bottleneck=min(2,3)=2
  flow: 0→2=2, 2→3=2, total=4

Iter 3: BFS 0→1→... 0→1 剩余=1, 但 1→3 已饱和(2/2)
       1 还能去哪? 1→? 只有 1→3
       尝试: 0→1(剩1), 但 1 无法到 3
       0→2 已饱和(2/2)

BFS 失败!

MAX_FLOW = 4
```

</details>

---

### 练习 2：找出最小割 ⭐⭐⭐

对于练习 1 的网络，找出一个**最小割**（容量之和 = 最大流的边集）。

<details>
<summary>💡 提示</summary>

**方法**：最后一次 BFS 后，已访问的节点集合 S vs 未访问的集合 T。

```
最后 BFS 从 0 出发:
  0 → 1? 0→1 剩余=3-2=1>0 ✓, 访问 1
  0 → 2? 0→2 剩余=2-2=0 ✗
  1 → 3? 1→3 剩余=2-2=0 ✗

已访问: {0, 1}, 未访问: {2, 3}

最小割 = 从 {0,1} 到 {2,3} 的边:
  0→2: 容量 2
  1→3: 容量 2
  总和 = 4 = MAX_FLOW ✓
```

</details>

---

### 练习 3：实现容量缩放版的 Edmonds-Karp ⭐⭐⭐⭐

标准 Edmonds-Karp 每次只沿一条增广路增广。**容量缩放 (Capacity Scaling)** 优化：

1. 先按容量大小排序所有边
2. 从最大容量的 Δ 开始，只考虑容量 ≥ Δ 的边
3. 每轮将 Δ 减半，在上轮流量的基础上继续增广
4. 直到 Δ = 1

**要求**：实现此优化并分析其时间复杂度 O(E² log U)，其中 U 为最大容量。

<details>
<summary>📖 解题思路</summary>

```moonbit
pub fn edmonds_karp_scaling(
  graph : FlowNetwork,
  source : Int,
  sink : Int,
) -> MaxFlowResult {
  // Step 1: 找到最大容量 U
  let mut u = 0.0
  // ... 遍历 capacity 矩阵找到最大值 ...

  // Step 2: 从最高有效位开始
  let mut delta = largest_power_of_2(u)

  while delta >= 1.0 {
    // 只考虑 capacity[u][v] >= delta 的边进行 BFS
    // (修改 ek_bfs 的判断条件)
    let (parent, found) = ek_bfs_threshold(
      graph.capacity, work_flow, n, source, sink, delta
    )
    // ... 同标准 EK 增广 ...

    delta = delta / 2.0
  }

  // 返回结果
}
```

**复杂度分析**：
- O(log U) 轮缩放
- 每轮 O(VE) 次增广（类似标准 EK）
- 总计 O(VE² log U)，当 U 很大时优于标准 O(VE²)

</details>

---

## 相关资源

### 📚 推荐阅读

| 资源 | 类型 | 说明 |
|------|------|------|
| *Original Paper* | 论文 | J. Edmonds, R.M. Karp, "Theoretical improvements in algorithmic efficiency," 1972 |
| *CLRS* | 教材 | 《算法导论》第 26.2 节 - Ford-Fulkerson 方法 |
| *VisuAlgo* | 交互可视化 | https://visualgo.net/en/maxflow |
| *Dinic 教程* | 本站文档 | [/algorithms/flow/max-flow/dinic](/algorithms/flow/max-flow/dinic) |

### 🔗 相关算法

```
Edmonds-Karp (本文)
  ├── Ford-Fulkerson 方法   → 通用框架 (可能不终止)
  ├── Dinic 算法            → 分层图 + 阻塞流 (更快!)
  ├── Push-Relabel          → 局部推进 (并行友好)
  ├── 最小费用最大流         → 带成本的流优化
  └── 二分图最大匹配         → 特殊应用场景
```

### 🛠️ mbtgraph 相关源码

| 文件 | 说明 |
|------|------|
| [`lib/algo/flow/edmonds_karp.mbt`](../../../lib/algo/flow/edmonds_karp.mbt) | Edmonds-Karp 核心实现 |
| [`lib/algo/flow/flow_network.mbt`](../../../lib/algo/flow/flow_network.mbt) | `FlowNetwork` 类型定义 |
| [`lib/algo/flow/types.mbt`](../../../lib/algo/flow/types.mbt) | `MaxFlowResult` 类型定义 |
| [`lib/algo/flow/dinic.mbt`](../../../lib/algo/flow/dinic.mbt) | Dinic 优化实现 (推荐生产使用) |

---

## 总结清单

### ✅ 核心知识点

- [ ] **最大流问题**：源点到汇点的最大可行流量（满足容量约束 + 流量守恒）
- [ ] **残差图**：表示还能送多少流量，包含正向剩余 + 反向撤销
- [ ] **增广路径**：残差图中 S→T 的任意可行路径
- [ ] **BFS 选择策略**：总是选最短路径，保证 O(VE²) 上界
- [ ] **反向边的作用**：允许"撤销"之前的流量分配，确保最优性
- [ ] **最大流最小割定理**：max_flow = min_cut（终止正确性保证）

### 🔑 关键代码模式

```moonbit
// Edmonds-Karp 三件套
while true {
  let (parent, found) = bfs(residual_graph)  // 1. 找增广路
  if !found { break }                          //    找不到则结束
  let b = find_bottleneck(parent)              // 2. 算瓶颈
  augment(parent, b)                            // 3. 增广
  total_flow += b
}
```

### ⚠️ 常见陷阱

| 陷阱 | 后果 | 解决方法 |
|------|------|---------|
| 忽略反向边 | 可能得不到最大流 | **必须**维护反向流量 |
| 浮点精度误差 | 死循环或错误终止 | 使用 ε = 10⁻⁆ 阈值 |
| 源汇相同 | 结果无意义 | 入参校验 `source != sink` |
| 未深拷贝 flow | 原网络被修改 | `deep_copy_matrix` 保护原数据 |
| 容量为负 | BFS 行为异常 | `add_edge` 时校验 `capacity > 0` |

### 📊 最大流算法速查

```
┌──────────────┬───────────────┬───────────────┬────────────────┐
│    算法       │  时间         │  适用场景       │  推荐度        │
├──────────────┼───────────────┼───────────────┼────────────────┤
│ Edmonds-Karp │ O(V·E²)       │ 学习/小规模     │ ⭐⭐⭐ 入门首选 │
│ Dinic         │ O(E·V²)       │ 通用/生产环境   │ ⭐⭐⭐⭐⭐ 推荐  │
│ Push-Relabel  │ O(V³)         │ 大规模/并行     │ ⭐⭐⭐⭐ 特殊   │
└──────────────┴───────────────┴───────────────┴────────────────┘
```

---

<div align="center">

**💧 Edmonds-Karp 算法 — BFS 增广路，最大流的基础**

*下一篇：[Dinic 算法](/algorithms/flow/max-flow/dinic) | [返回网络流目录](/algorithms/flow)*

</div>
