---
title: A* 启发式搜索
description: 启发式搜索加速最短路径：f=g+h 核心公式、可采纳性、MoonBit 实现与游戏寻路应用
---

# A\* 启发式搜索

> 🎯 **本节目标**: 掌握 A* 算法原理、启发函数设计与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**A\* 算法**（发音: "A-star"）是一种在带权图中寻找从起点到终点的最短路径的**启发式搜索**算法，由 Peter Hart、Nils Nilsson 和 Bertram Raphael 于 1968 年提出。它在 Dijkstra 的基础上加入**启发函数 h(n)**，引导搜索方向，大幅减少探索范围。

A* 的核心公式是 **f(n) = g(n) + h(n)**，其中 g(n) 是从起点到节点 n 的实际代价，h(n) 是从 n 到终点的估计代价（启发函数）。当 h(n) **可采纳**（不高于真实代价）且**一致**时，A* 保证找到最优解，并且通常比 Dijkstra 快一个数量级。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/a_star/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/a_star/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 深棕色 | 起点 |
| 橙色 | 当前处理节点（open 集中 f 值最小） |
| 黄色 | open 集中的候选节点 |
| 绿色 | 已关闭（closed）的节点 |
| 灰色 | 未探索 |
| 红色粗线 | 最终路径 |

## MoonBit 实现

核心代码来自 `lib/algo/shortest_path/a_star.mbt`：

```moonbit
///|
/// A* 启发式搜索
/// 返回最短路径节点序列，不可达返回空数组
pub fn[G : @core.GraphReadable] a_star(
  graph : G,
  start : @core.NodeId,
  target : @core.NodeId,
  heuristic : (@core.NodeId) -> Double,
) -> Array[@core.NodeId] {
  if start == target { return [start] }
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 { return [] }

  let max_id = max_node_id(graph)
  let size = max_int(max_id + 1, 1)
  let g_score : Array[Double?] = Array::make(size, None)
  let parent : Array[@core.NodeId?] = Array::make(size, None)
  g_score[start.0] = Some(0.0)

  let mut pq = heap_new()
  pq = heap_push(pq, heuristic(start), start)
  let visited : Array[Bool] = Array::make(size, false)

  while !heap_is_empty(pq) {
    let (pq_next, top_opt) = heap_pop(pq)
    pq = pq_next
    match top_opt {
      Some((u, _)) => {
        if u == target {
          return reconstruct_path(parent, start, target)
        }
        if visited[u.0] { continue }
        visited[u.0] = true

        for v in @core.GraphReadable::neighbors(graph, u) {
          let w = @core.GraphReadable::get_edge(graph, u, v)
          match w {
            Some(weight) => {
              let new_g = g_score[u.0].as_or(0.0) + weight
              let old_g = g_score[v.0]
              if old_g == None || new_g < old_g.as_or(0.0) {
                g_score[v.0] = Some(new_g)
                parent[v.0] = Some(u)
                let f = new_g + heuristic(v)
                pq = heap_push(pq, f, v)
              }
            }
            None => ()
          }
        }
      }
      None => ()
    }
  }
  []  // 不可达
}
```

**为什么 A* 能选择目标方向？** 优先队列按 f = g + h 排序。h(n) 指导搜索方向——曼哈顿距离引导网格寻路偏向目标，而 h=0 时退化为 Dijkstra。可采纳的 h 保证第一次取出目标节点时路径一定是最优的。

## 使用示例

```moonbit
fn a_star_demo() -> Unit {
  // 曼哈顿距离启发函数
  fn manhattan(node : @core.NodeId) -> Double {
    let x = node.0 % 5; let y = node.0 / 5
    let tx = 4; let ty = 4
    ((tx - x).abs() + (ty - y).abs()).to_double()
  }

  let g = build_grid_graph()
  let path = @shortest_path.a_star(g, @core.NodeId(0), @core.NodeId(24), manhattan)
  println("找到路径，长度: ${path.length()}")
}
```

## 实际场景

- **游戏 AI 寻路**：RTS 游戏中单位自动寻路（结合网格地图和曼哈顿距离）
- **地图导航**：GPS 系统中用欧几里得距离作为启发函数加速路线规划
- **机器人路径规划**：在已知环境中快速规划无碰撞路径

## 扩展阅读

- [Dijkstra 算法](/algorithms/shortest-path/dijkstra/) — A* 的基础（h=0 的特例）
- [Bellman-Ford 算法](/algorithms/shortest-path/bellman-ford/) — 支持负权边的单源算法
