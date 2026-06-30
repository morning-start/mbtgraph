---
title: Tarjan 算法：割点与桥（Articulation Points & Bridges）
description: 基于 DFS 时间戳与 low 值的无向图关键节点/边检测，O(V+E) 时间复杂度
---

# Tarjan 算法：割点与桥

> 🎯 **本节目标**: 掌握割点与桥的判定条件、Tarjan 算法原理与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**割点（Articulation Point）** 是移除后会使图变得不连通的节点；**桥（Bridge）** 是移除后使图变得不连通的边。它们在网络脆弱性分析和容错设计中至关重要。

Tarjan 算法（1972 年）通过单次 DFS，利用**时间戳（disc）** 和**低点值（low）** 来同时检测所有割点和桥：
- **割点判定**：根节点有 ≥2 个子树，或非根节点 `low[v] ≥ disc[u]`
- **桥判定**：`low[v] > disc[u]`（严格大于，表示 v 无法绕过 u 回到祖先）

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/cutpoints/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/cutpoints/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 橙色 | 当前处理节点 |
| 红色 | 标记为割点 |
| 红色粗线 | 标记为桥 |
| 绿色 | 已处理完毕 |
| 灰色 | 默认 |

## MoonBit 实现

核心代码来自 `lib/algo/cutpoints/tarjan.mbt`：

```moonbit
///|
/// Tarjan 算法：同时检测无向图的割点和桥
/// 时间复杂度 O(V+E)，空间复杂度 O(V)
pub fn[G : @core.GraphReadable] find_articulation_points_and_bridges(
  graph : G
) -> CutPointBridgeResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return CutPointBridgeResult::{
      articulation_points: [], bridges: [], count_ap: 0, count_bridges: 0
    }
  }

  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)

  let disc : Array[Int] = Array::make(size, -1)    // 发现时间
  let low : Array[Int] = Array::make(size, -1)      // 低点值
  let visited : Array[Bool] = Array::make(size, false)
  let parent : Array[Int] = Array::make(size, -1)   // DFS 树父节点

  let art_points : Array[@core.NodeId] = []
  let bridge_edges : Array[(@core.NodeId, @core.NodeId)] = []
  let mut time = 0

  for start in @core.GraphReadable::node_ids(graph) {
    if visited[start.0] { continue }

    // DFS 遍历
    let stack : Array[(@core.NodeId, Iterator[@core.NodeId])] = []
    visited[start.0] = true
    disc[start.0] = time; low[start.0] = time
    time = time + 1
    stack.push((start, @core.GraphReadable::neighbors(graph, start)))
    let mut child_count = 0

    while stack.length() > 0 {
      let (node, mut nbr_iter) = stack[stack.length() - 1]
      let next_nbr = nbr_iter.next()
      match next_nbr {
        Some(nbr) => {
          let nid = nbr.0
          if !visited[nid] {
            visited[nid] = true
            parent[nid] = node.0
            disc[nid] = time; low[nid] = time
            time = time + 1
            stack.push((nbr, @core.GraphReadable::neighbors(graph, nbr)))
          } else if nid != parent[node.0] {
            // 回边：用已发现的邻居更新 low 值
            low[node.0] = min(low[node.0], disc[nid])
          }
        }
        None => {
          stack.pop()
          if stack.length() > 0 {
            let (p_node, _) = stack[stack.length() - 1]
            low[p_node.0] = min(low[p_node.0], low[node.0])

            if low[node.0] > disc[p_node.0] {
              // 桥：v 无法绕过 u 回到祖先
              bridge_edges.push((p_node, node))
            }
            if p_node.0 != start.0 && low[node.0] >= disc[p_node.0] {
              // 非根割点
              if !art_points.contains(p_node) {
                art_points.push(p_node)
              }
            }
          }
        }
      }
    }
    // 根节点割点判定
    if child_count > 1 { art_points.push(start) }
  }

  CutPointBridgeResult::{
    articulation_points: art_points,
    bridges: bridge_edges,
    count_ap: art_points.length(),
    count_bridges: bridge_edges.length(),
  }
}
```

**割点 vs 桥的判定区别**：割点用 `low[v] ≥ disc[u]`（等于号表示 v 能到 u 自身），桥用 `low[v] > disc[u]`（严格大于）。桥的条件更严格。

## 使用示例

```moonbit
fn cutpoint_demo() -> Unit {
  let g = build_sample_graph()
  let result = @cutpoints.find_articulation_points_and_bridges(g)

  println("割点数量: ${result.count_ap}")
  for ap in result.articulation_points {
    println("  割点: NodeId(${ap.0})")
  }

  println("桥数量: ${result.count_bridges}")
  for (u, v) in result.bridges {
    println("  桥: NodeId(${u.0}) — NodeId(${v.0})")
  }
}
```

## 实际场景

- **网络拓扑脆弱性分析**：找出哪些路由器（割点）或链路（桥）是单点故障
- **交通拥堵预测**：识别关键路口和桥梁，提前规划绕行方案
- **社交网络关键人物**：发现"信息传递必经"的关键意见领袖

## 扩展阅读

- [连通分量](/algorithms/connectivity/connected-components/) — 割点与桥的基础概念
- [强连通分量 (Tarjan)](/algorithms/connectivity/scc/tarjan/) — Tarjan 算法在有向图上的应用
