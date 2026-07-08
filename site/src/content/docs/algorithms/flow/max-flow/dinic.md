---
title: Dinic 算法：最大流
description: BFS 分层 + DFS 阻塞流 + 当前弧优化，O(E√V) 时间复杂度，生产环境首选
---

# Dinic 算法：最大流

> 🎯 **本节目标**: 掌握 Dinic 算法原理、层次图 + 阻塞流机制与 MoonBit 实现 | ⏱️ **预计阅读时间**: 12 分钟

## 算法简介

**Dinic 算法**（也称 Dinitz 算法，1970 年由 Yefim Dinitz 提出）是最大流问题的**高效求解器**。它在 Edmonds-Karp 的基础上做了三个关键优化：
1. **层次图**：BFS 一次分层，后续 DFS 始终沿最短路径增广
2. **阻塞流**：一个 Phase 通过多次 DFS 找到多条增广路（非单条）
3. **当前弧优化**：跳过已检查的饱和边，不重复扫描

时间复杂度 O(E√V)，比 Edmonds-Karp 的 O(VE²) 快 10-100 倍，是大规模网络流的首选算法。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/dinic/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/dinic/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 橙色 | 当前 BFS 分层处理中 |
| 蓝色 | 当前弧（DFS 当前通道） |
| 绿色 | 已增广的流量 |
| 红色 | 饱和边 |

## MoonBit 实现

核心代码来自 `lib/algo/flow/dinic.mbt`：

```moonbit
/// BFS 构建层次图
fn dinic_bfs(
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
  n : Int, source : Int, sink : Int,
) -> (Array[Int], Bool) {
  let level : Array[Int] = Array::make(n, -1)
  level[source] = 0
  let queue : Array[Int] = [source]
  let mut head = 0

  while head < queue.length() {
    let u = queue[head]; head = head + 1
    let mut v = 0
    while v < n {
      if level[v] == -1 {
        let residual = capacity[u][v] - flow[u][v]
        if residual > 0.000001 {
          level[v] = level[u] + 1
          if v == sink { return (level, true) }
          queue.push(v)
        }
      }
      v = v + 1
    }
  }
  (level, level[sink] != -1)
}

/// DFS 在层次图上找阻塞流（含当前弧优化）
fn dinic_dfs(
  u : Int, sink : Int, min_cap : Double,
  capacity : Array[Array[Double]],
  flow_ref : Array[Array[Double]],
  level : Array[Int],
  current_arc : Array[Int], n : Int,
) -> Double {
  if u == sink { return min_cap }

  let mut total_sent = 0.0
  let mut remaining = min_cap
  let mut i = current_arc[u]

  while i < n {
    let v = i
    let residual = capacity[u][v] - flow_ref[u][v]
    if residual > 0.000001 && level[v] == level[u] + 1 {
      let send_cap = if remaining < residual { remaining } else { residual }
      let pushed = dinic_dfs(v, sink, send_cap, capacity, flow_ref, level, current_arc, n)
      if pushed > 0.000001 {
        flow_ref[u][v] = flow_ref[u][v] + pushed
        flow_ref[v][u] = flow_ref[v][u] - pushed
        total_sent = total_sent + pushed
        remaining = remaining - pushed
        if remaining <= 0.000001 {
          current_arc[u] = i
          return total_sent
        }
      }
    }
    i = i + 1
  }

  current_arc[u] = i
  total_sent
}

/// Dinic 最大流算法
/// 时间复杂度 O(E√V)，空间复杂度 O(V²)
pub fn dinic(
  graph : FlowNetwork, source : Int, sink : Int,
) -> MaxFlowResult {
  let n = graph.node_count()
  let capacity = graph.capacity_matrix()
  let flow = dinic_deep_copy(graph.flow_matrix())
  let mut max_flow = 0.0
  let mut iter_count = 0

  while true {
    let (level, can_reach) = dinic_bfs(capacity, flow, n, source, sink)
    if !can_reach { break }
    let current_arc : Array[Int] = Array::make(n, 0)  // 当前弧

    while true {
      let pushed = dinic_dfs(source, sink, 1000000000000000000.0, capacity, flow, level, current_arc, n)
      if pushed <= 0.000001 { break }
      max_flow = max_flow + pushed
    }
    iter_count = iter_count + 1
  }

  MaxFlowResult::{ max_flow, flow_matrix: flow, iteration_count: iter_count }
}
```

**当前弧优化为什么有效？** 在单次 Phase 内，已经检查过的边已无剩余容量（或已充分增广），无需在下一次 DFS 中重新遍历。`current_arc[u]` 记住上次扫描到的位置，跳过已饱和的边。

## 使用示例

```moonbit
fn dinic_demo() -> Unit {
  let net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0)
  let net = net.add_edge(0, 2, 5.0)
  let net = net.add_edge(1, 2, 6.0)
  let net = net.add_edge(1, 3, 8.0)
  let net = net.add_edge(2, 3, 9.0)

  let result = @flow.dinic(net, 0, 3)
  println("Dinic 最大流量: \{result.max_flow\}")
  println("Phase 数: \{result.iteration_count\}")
}
```

## 实际场景

- **云计算流量调度**：多数据中心间带宽分配，Dinic 高效求解
- **视频流分发**：CDN 节点间的最大并发流计算
- **二分图匹配加速**：Dinic 在大规模二分图上比匈牙利算法快（O(√VE) vs O(VE)）

## 扩展阅读

- [Edmonds-Karp 算法](/algorithms/flow/max-flow/edmonds-karp/) — Dinic 的前身和对比基准
- [Ford-Fulkerson 方法](/algorithms/flow/max-flow/ford-fulkerson/) — 最大流通用框架
- [最小费用最大流](/algorithms/flow/min-cost-max-flow/) — 在最大流基础上优化成本
