---
title: Bellman-Ford 最短路径算法
description: 支持负权边的单源最短路径详解：V-1 轮松弛、负环检测、MoonBit 实现
---

# Bellman-Ford 最短路径算法

> 🎯 **本节目标**: 掌握 Bellman-Ford 算法原理、负权边处理与负环检测 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**Bellman-Ford 算法**是一种在**含负权边的图**中求解单源最短路径的算法，由 Richard Bellman 和 Lester Ford 分别独立提出。与 Dijkstra 不同，Bellman-Ford 通过**反复松弛所有边**（最多 V-1 轮）来逐步逼近最短距离，因此天然支持负权边。

它的核心价值在于**负环检测**：如果第 V 轮松弛仍有更新，说明图中存在从源点可达的负权环（可无限缩小距离），此时算法返回错误而非错误结果。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/bellman_ford/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/bellman_ford/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 深棕色 | 起点 |
| 橙色 | 本轮发生松弛的边 |
| 绿色 | 最短距离已确定 |
| 红色 | 检测到负环的边 |
| 灰色 | 默认/未访问 |

## MoonBit 实现

核心代码来自 `lib/algo/shortest_path/bellman_ford.mbt`：

```moonbit
///|
/// Bellman-Ford 单源最短路径（支持负权边）
/// 成功返回 ShortestPathResult，检测到负环返回 Err
/// 时间复杂度: O(VE)，空间复杂度: O(V + E)
pub fn[G : @core.GraphReadable] bellman_ford(
  graph : G,
  source : @core.NodeId,
) -> Result[ShortestPathResult, String] {
  let nc = @core.GraphReadable::node_count(graph)

  if nc == 0 {
    return Ok(ShortestPathResult::{ distances: [], parents: [] })
  }
  if !@core.GraphReadable::contains_node(graph, source) {
    return Err("source node not found")
  }

  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)

  let distances : Array[Double?] = Array::make(size, None)
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  distances[source.0] = Some(0.0)

  // 预收集所有边，避免每轮重复遍历邻居
  let edge_list : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for u in @core.GraphReadable::node_ids(graph) {
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw { (v, w) => edge_list.push((u, v, w)) }
    }
  }

  // Step 1: 进行 V-1 轮松弛
  for _ in 0..<nc {
    for edge in edge_list {
      match edge {
        (u, v, w) => {
          let uid = u.0; let vid = v.0
          if uid < 0 || uid >= size || vid < 0 || vid >= size { continue }
          let ud = match distances[uid] { None => continue; Some(d) => d }
          let new_dist = ud + w
          let should_update = match distances[vid] {
            None => true
            Some(d) => new_dist < d
          }
          if should_update {
            distances[vid] = Some(new_dist)
            parents[vid] = Some(u)
          }
        }
      }
    }
  }

  // Step 2: 负环检测（第 V 轮）
  for edge in edge_list {
    match edge {
      (u, v, w) => {
        let uid = u.0; let vid = v.0
        if uid < 0 || uid >= size || vid < 0 || vid >= size { continue }
        match distances[uid] {
          None => continue
          Some(ud) =>
            match distances[vid] {
              Some(vd) => if ud + w < vd { return Err("negative cycle detected") }
              None => ()
            }
        }
      }
    }
  }

  Ok(ShortestPathResult::{ distances, parents })
}
```

**为什么需要 V-1 轮？** 最短路径至多包含 V-1 条边（否则必然经过重复节点形成环），每轮至少确定一个节点的最短距离，V-1 轮后所有可达节点的距离都达到最优。

## 使用示例

```moonbit
fn bellman_ford_demo() -> Unit {
  let g = build_negative_weight_graph()

  match @shortest_path.bellman_ford(g, @core.NodeId(0)) {
    Ok(result) => {
      let target = @core.NodeId(4)
      println("0 → 4 最短距离: ${result.distance_to(target)}")
      println("路径: ${result.path_to(target)}")
    }
    Err(msg) => println("检测到负环: ${msg}")
  }
}
```

## 实际场景

- **外汇套利检测**：将汇率取对数后建模为图，Bellman-Ford 检测"套利环"（负环）
- **RIP 路由协议**：距离向量路由协议，Bellman-Ford 是其理论基础
- **含负权边的物流优化**：某些路径有"奖励"（负成本）时仍可正确求解

## 扩展阅读

- [Dijkstra 算法](/algorithms/shortest-path/dijkstra/) — 非负权图的单源最短路径（更快）
- [SPFA 算法](/algorithms/shortest-path/bellman-ford/) — Bellman-Ford 的队列优化版本
- [Floyd-Warshall 算法](/algorithms/shortest-path/floyd-warshall/) — 全源最短路径
