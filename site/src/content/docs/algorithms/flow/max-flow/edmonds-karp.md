---
title: Edmonds-Karp 算法：最大流
description: 基于 BFS 最短增广路的 Ford-Fulkerson 实现，O(VE²) 时间复杂度
---

# Edmonds-Karp 算法：最大流

> 🎯 **本节目标**: 掌握 Edmonds-Karp 算法原理、BFS 增广路搜索与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**Edmonds-Karp 算法**是 Ford-Fulkerson 方法的一个具体实现，由 Jack Edmonds 和 Richard Karp 于 1972 年提出。与通用 Ford-Fulkerson 框架不同，Edmonds-Karp **使用 BFS 寻找最短增广路**（边数最少），从而保证多项式时间复杂度 O(VE²)。

算法在**残差图**上反复执行 BFS：从源点出发，沿着有剩余容量的边搜索到汇点的路径，找到瓶颈容量后推送流量并更新反向边——"反悔"机制允许后续迭代撤销之前的流量分配。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/ford_fulkerson/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/ford_fulkerson/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 橙色 | 当前 BFS 搜索路径 |
| 绿色 | 已推送流量的边 |
| 红色 | 饱和边（流量 = 容量） |
| 虚线 | 反向边（残差） |

## MoonBit 实现

核心代码来自 `lib/algo/flow/edmonds_karp.mbt`。算法使用 **FlowNetwork** 独立类型（非 GraphReadable 实现），包含容量矩阵和流量矩阵。

```moonbit
///|
/// Edmonds-Karp 最大流算法
/// 时间复杂度 O(VE²)，空间复杂度 O(V²)
pub fn edmonds_karp(
  graph : FlowNetwork,
  source : Int,
  sink : Int,
) -> MaxFlowResult {
  let n = graph.node_count()
  let capacity = graph.capacity_matrix()   // 容量矩阵
  let flow = deep_copy_matrix(graph.flow_matrix())  // 深拷贝保持纯函数
  let mut max_flow = 0.0
  let mut iter_count = 0

  while true {
    // BFS 寻找最短增广路
    let parent : Array[Int?] = Array::make(n, None)
    let visited : Array[Bool] = Array::make(n, false)
    let queue : Array[Int] = [source]
    visited[source] = true
    let mut head = 0
    let mut found = false

    while head < queue.length() && !found {
      let u = queue[head]; head = head + 1
      let mut v = 0
      while v < n {
        if !visited[v] && capacity[u][v] - flow[u][v] > 0.000001 {
          visited[v] = true
          parent[v] = Some(u)
          if v == sink { found = true; break }
          queue.push(v)
        }
        v = v + 1
      }
    }

    if !found { break }  // 无可增广路

    // 计算瓶颈容量
    let mut bottleneck = 1000000000000000000.0
    let mut cur = sink
    while true {
      match parent[cur] {
        None => break
        Some(p) => {
          let residual = capacity[p][cur] - flow[p][cur]
          if residual < bottleneck && residual > 0.0 { bottleneck = residual }
          cur = p
        }
      }
    }

    // 沿路径增广
    cur = sink
    while cur != source {
      match parent[cur] {
        None => break
        Some(p) => {
          flow[p][cur] = flow[p][cur] + bottleneck
          flow[cur][p] = flow[cur][p] - bottleneck  // 反向边
          cur = p
        }
      }
    }

    max_flow = max_flow + bottleneck
    iter_count = iter_count + 1
  }

  MaxFlowResult::{ max_flow, flow_matrix: flow, iteration_count: iter_count }
}
```

**为什么深度复制流量矩阵？** 保证纯函数语义：多次调用算法不会相互影响。虽然增加了 O(V²) 开销，但避免了对输入网络的副作用。

## 使用示例

```moonbit
fn edmonds_karp_demo() -> Unit {
  let net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0)
  let net = net.add_edge(0, 2, 5.0)
  let net = net.add_edge(1, 2, 6.0)
  let net = net.add_edge(1, 3, 8.0)
  let net = net.add_edge(2, 3, 9.0)

  let result = @flow.edmonds_karp(net, 0, 3)
  println("最大流量: \{result.max_flow\}")
  println("迭代次数: \{result.iteration_count\}")
}
```

## 实际场景

- **交通流量优化**：道路网的车辆最大通行能力分析
- **供水管网调度**：水源到城区的水流量最大化
- **二分图匹配**：最大流可规约为二分图最大匹配（增加超级源汇）

## 扩展阅读

- [Dinic 算法](/algorithms/flow/max-flow/dinic/) — 更高效的最大流算法（O(E√V)）
- [Ford-Fulkerson 方法](/algorithms/flow/max-flow/ford-fulkerson/) — 最大流通用框架
- [最小费用最大流](/algorithms/flow/min-cost-max-flow/) — 在最大流基础上优化成本
