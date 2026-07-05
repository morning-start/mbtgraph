---
title: Hopcroft-Karp 算法：二分图最大匹配
description: BFS 分层 + DFS 增广，O(E√V) 时间复杂度，大规模二分图匹配的生产级选择
---

# Hopcroft-Karp 算法：二分图最大匹配

> 🎯 **本节目标**: 掌握 Hopcroft-Karp 算法原理、BFS 分层 + 多路增广与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**Hopcroft-Karp 算法**（1973 年）是二分图最大匹配的高效算法。它在匈牙利算法（逐个 DFS 找增广路）的基础上做了关键优化：通过 **BFS 一次分层**找到所有最短增广路，然后用 **DFS 批量增广**同层多条不相交的增广路。

这种"批处理"策略将时间复杂度从 O(VE) 降至 O(E√V)，在处理大规模稀疏二分图时优势尤为明显。算法分为若干 Phase，每个 Phase 交替执行 BFS 建模和 DFS 增广，直到不存在增广路。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/hungarian/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/hungarian/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 橙色 | BFS 分层当前层 |
| 蓝色 | DFS 找增广路 |
| 绿色 | 本 Phase 新增匹配 |
| 灰色 | 未处理/已匹配稳定 |

## MoonBit 实现

核心代码来自 `lib/algo/matching/hopcroft_karp.mbt`：

```moonbit
///|
/// Hopcroft-Karp 二分图最大匹配
/// 时间复杂度 O(E√V)，空间复杂度 O(V+E)
pub fn[G : @core.GraphReadable] hopcroft_karp(
  graph : G,
  left_nodes : Array[@core.NodeId],
  right_nodes : Array[@core.NodeId],
) -> MatchingResult {
  let INF = 1000000000
  let n_left = left_nodes.length()
  let n_right = right_nodes.length()
  if n_left == 0 || n_right == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  // 为方便索引，将 NodeId 映射到 [0..n_left) 和 [0..n_right)
  let left_ids : Map[Int, Int] = Map::new()
  let right_ids : Map[Int, Int] = Map::new()
  for (i, n) in left_nodes.indexed() { left_ids.insert(n.0, i) }
  for (i, n) in right_nodes.indexed() { right_ids.insert(n.0, i) }

  // 邻接表（左节点索引 → 右节点索引列表）
  let adj : Array[Array[Int]] = Array::make(n_left, [])
  for u in left_nodes {
    let ui = left_ids.get(u.0).unwrap()
    for v in @core.GraphReadable::neighbors(graph, u) {
      match right_ids.get(v.0) {
        Some(vi) => adj[ui].push(vi)
        None => ()
      }
    }
  }

  let pair_u : Array[Int?] = Array::make(n_left, None)   // 左→右匹配
  let pair_v : Array[Int?] = Array::make(n_right, None)  // 右→左匹配
  let dist : Array[Int] = Array::make(n_left, 0)

  // BFS 分层
  fn bfs_level() -> Bool {
    let queue : Array[Int] = []
    for (ui, pu) in pair_u.indexed() {
      match pu {
        None => { dist[ui] = 0; queue.push(ui) }  // 未匹配左节点
        Some(_) => { dist[ui] = INF }
      }
    }
    let mut found = false
    let mut head = 0
    while head < queue.length() {
      let u = queue[head]; head = head + 1
      for v in adj[u] {
        match pair_v[v] {
          Some(mu) => if dist[mu] == INF { dist[mu] = dist[u] + 1; queue.push(mu) }
          None => found = true  // 最后一个右节点是自由节点
        }
      }
    }
    found
  }

  // DFS 增广
  fn dfs_augment(u : Int) -> Bool {
    for v in adj[u] {
      match pair_v[v] {
        None => {
          pair_u[u] = Some(v); pair_v[v] = Some(u)
          return true
        }
        Some(mu) => if dist[mu] == dist[u] + 1 && dfs_augment(mu) {
          pair_u[u] = Some(v); pair_v[v] = Some(u)
          return true
        }
      }
    }
    dist[u] = INF
    false
  }

  let mut cardinality = 0
  while bfs_level() {
    for (ui, pu) in pair_u.copy().indexed() {
      if pu == None && dfs_augment(ui) {
        cardinality = cardinality + 1
      }
    }
  }

  let result_edges : Array[(@core.NodeId, @core.NodeId)] = []
  for (ui, vi_opt) in pair_u.indexed() {
    match vi_opt {
      Some(vi) => result_edges.push((left_nodes[ui], right_nodes[vi]))
      None => ()
    }
  }

  MatchingResult::{ matching_edges: result_edges, cardinality }
}
```

**为什么 BFS + DFS 交替？** BFS 构建所有未匹配左节点的"距离图"（到自由右节点的最短路径）；DFS 沿着距离严格递增的方向寻找多条不相交的增广路。每次 Phase 都至少使所有最短增广路长度增加，最多 O(√V) 个 Phase。

## 使用示例

```moonbit
fn hopcroft_karp_demo() -> Unit {
  let g = build_sample_bipartite_graph()
  let left = [@core.NodeId(0), @core.NodeId(1), @core.NodeId(2)]
  let right = [@core.NodeId(3), @core.NodeId(4), @core.NodeId(5)]

  let result = @matching.hopcroft_karp(g, left, right)
  println("最大匹配数: ${result.cardinality}")
}
```

## 实际场景

- **大规模推荐系统**：用户与物品的匹配（如广告投放、商品推荐）
- **搜索引擎结果**：搜索词与搜索结果之间的相关匹配
- **编译器寄存器分配**：将虚拟寄存器映射到物理寄存器

## 扩展阅读

- [匈牙利算法](/algorithms/matching/bipartite/hungarian/) — 二分图匹配的入门算法（O(VE)）
- [Edmonds 一般图匹配](/algorithms/matching/general/edmonds/) — 支持奇环的一般图匹配
