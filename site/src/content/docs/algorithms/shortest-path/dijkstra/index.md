---
title: Dijkstra 最短路径算法
description: 非负权图单源最短路径详解：贪心策略、优先队列、松弛操作、MoonBit 实现
---

# Dijkstra 最短路径算法

> 🎯 **本节目标**: 掌握 Dijkstra 算法原理、优先队列机制与 MoonBit 实现 | ⏱️ **预计阅读时间**: 12 分钟

## 算法简介

**Dijkstra 算法**（发音: /ˈdaɪkstrə/）是一种在**非负权重图**中求解**单源最短路径**的贪心算法，由 Edsger W. Dijkstra 于 1956 年提出。它每次从"距离起点最近"的未确定节点出发，通过**松弛操作**逐步扩展最短路径树。

Dijkstra 算法的前置条件是**所有边权重必须非负**。它使用**优先队列（最小堆）** 管理候选节点，确保每次取出的是当前距离最小的节点。一旦节点被标记为"已确定"，其距离就是最终的最短距离——这一贪心策略在非负权图中成立，但在含负权边时失效。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/dijkstra/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/dijkstra/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 深棕色 | 起点 |
| 橙色 | 当前正在处理的节点 |
| 黄色 | 刚通过松弛发现的新节点 |
| 绿色 | 已确定最短距离（visited） |
| 灰色 | 默认未访问状态 |
| 红色粗线 | 最终最短路径树中的边 |

## MoonBit 实现

核心代码来自 `lib/algo/shortest_path/dijkstra.mbt`：

```moonbit
///|
/// Dijkstra 单源最短路径（所有边权重非负）
/// 时间复杂度: O((V + E) log V)，空间复杂度: O(V)
pub fn[G : @core.GraphReadable] dijkstra(
  graph : G,
  source : @core.NodeId,
) -> ShortestPathResult {
  let nc = @core.GraphReadable::node_count(graph)

  if nc == 0 || !@core.GraphReadable::contains_node(graph, source) {
    return ShortestPathResult::{ distances: [], parents: [] }
  }

  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let inf = 1000000000000000000.0

  let distances : Array[Double?] = Array::make(size, None)
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  distances[source.0] = Some(0.0)

  let mut pq = heap_new()
  pq = heap_push(pq, 0.0, source)

  let visited : Array[Bool] = Array::make(size, false)

  while !heap_is_empty(pq) {
    let (pq_next, top_opt) = heap_pop(pq)
    pq = pq_next

    match top_opt {
      Some((u, _)) => {
        let uid = u.0

        // 已确定的节点跳过（处理重复入队）
        if visited[uid] { continue }
        visited[uid] = true

        for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
          match vw {
            (v, weight) => {
              let vid = v.0
              if vid < 0 || vid >= size || visited[vid] { continue }

              let ud = match distances[uid] {
                None => continue
                Some(d) => d
              }

              let new_dist = ud + weight
              let should_update = match distances[vid] {
                None => true
                Some(d) => new_dist < d
              }

              if should_update {
                distances[vid] = Some(new_dist)
                parents[vid] = Some(u)
                pq = heap_push(pq, new_dist, v)
              }
            }
          }
        }
      }
      None => ()
    }
  }

  ShortestPathResult::{ distances, parents }
}
```

**为什么允许重复入队？** 同一节点可能被多次松弛（发现更短路径）。重复入队后旧的记录会被 `visited` 跳过，避免了实现 Decrease-Key 的复杂度。

## 使用示例

```moonbit
fn dijkstra_demo() -> Unit {
  let g = build_sample_weighted_graph()
  let result = @shortest_path.dijkstra(g, @core.NodeId(0))

  let target = @core.NodeId(5)
  let dist = result.distance_to(target)
  let path = result.path_to(target)
  println("0 → 5 的最短距离: ${dist}")
  println("路径: ${path.map(fn(id) { id.to_string() }).join(" → ")}")
}
```

## 实际场景

- **GPS 导航**：道路网中寻找最短/最快路线（边权重 = 距离或预估时间）
- **OSPF 路由协议**：互联网内部网关协议，每个路由器运行 Dijkstra 计算到所有节点的最短路径
- **游戏寻路 AI**：NPC 在开放世界中寻找无障碍路径到达目标

## 扩展阅读

- [Bellman-Ford 算法](/algorithms/shortest-path/bellman-ford/) — 支持负权边的单源最短路径
- [A* 启发式搜索](/algorithms/shortest-path/a-star/) — 带目标导向的 Dijkstra 优化
- [Floyd-Warshall 算法](/algorithms/shortest-path/floyd-warshall/) — 全源最短路径
