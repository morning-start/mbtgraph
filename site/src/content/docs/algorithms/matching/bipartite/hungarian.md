---
title: 匈牙利算法：二分图最大匹配入门
description: DFS 增广路搜索，O(VE) 时间复杂度，二分图匹配的经典入门算法
---

# 匈牙利算法：二分图最大匹配入门

> 🎯 **本节目标**: 掌握匈牙利算法（Kuhn 算法）原理、DFS 增广路搜索与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**匈牙利算法**（也称 **Kuhn's Algorithm**）用于求解**二分图的最大基数匹配**问题。二分图将节点分为左右两部分，边只连接左右两侧的节点。最大匹配就是找到最多的不共享端点的边。

算法的核心是**DFS 增广路搜索**：从左部每个未匹配节点出发，尝试寻找一条增广路（起点和终点均为未匹配节点、交替经过匹配边和未匹配边的路径）。找到增广路即可将匹配数 +1。如果目标右节点已被匹配，递归尝试让该节点释放——即"让位"给新人。

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
| 橙色 | 当前尝试的左节点 |
| 黄色 | 正在递归搜索增广路 |
| 绿色 | 已成功匹配 |
| 红色 | 匹配冲突（递归让位） |

## MoonBit 实现

核心代码来自 `lib/algo/matching/hungarian.mbt`：

```moonbit
/// DFS 增广路搜索
fn hungarian_dfs(
  u : Int,
  adj : Array[Array[Int]],
  match_right : Array[Int?],
  visited : Array[Bool],
) -> Bool {
  let mut i = 0
  while i < adj[u].length() {
    let v = adj[u][i]
    if !visited[v] {
      visited[v] = true
      match match_right[v] {
        None => {
          match_right[v] = Some(u)
          return true  // 找到增广路
        }
        Some(matched_u) =>
          // 尝试让已匹配的右节点重新分配
          if hungarian_dfs(matched_u, adj, match_right, visited) {
            match_right[v] = Some(u)
            return true
          }
      }
    }
    i = i + 1
  }
  false  // 无增广路
}

/// 二分图最大匹配（邻接表版本）
/// 时间复杂度 O(VE)，空间复杂度 O(V+E)
pub fn bipartite_matching(
  n_left : Int, n_right : Int,
  edges : Array[(Int, Int)],
) -> MatchingResult {
  if n_left == 0 || n_right == 0 || edges.length() == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  let adj : Array[Array[Int]] = Array::make(n_left, [])
  for edge in edges {
    match edge { (u, v) => if u >= 0 && u < n_left && v >= 0 && v < n_right { adj[u].push(v) } }
  }

  let match_right : Array[Int?] = Array::make(n_right, None)
  let mut cardinality = 0

  for u in 0..<n_left {
    let visited : Array[Bool] = Array::make(n_right, false)
    if hungarian_dfs(u, adj, match_right, visited) {
      cardinality = cardinality + 1
    }
  }

  // 构建匹配边列表
  let result_edges : Array[(@core.NodeId, @core.NodeId)] = []
  for (v, u_opt) in match_right.indexed() {
    match u_opt { Some(u) => result_edges.push((@core.NodeId(u), @core.NodeId(v))) None => () }
  }

  MatchingResult::{ matching_edges: result_edges, cardinality }
}
```

**为什么 DFS 回溯可以找到最大匹配？** 增广路径定理：当图中不存在增广路时，当前匹配即为最大匹配。匈牙利算法通过 DFS 反复寻找增广路来逐步扩大匹配，直到无法找到为止。

## 使用示例

```moonbit
fn hungarian_demo() -> Unit {
  // 3 个左节点，3 个右节点
  let edges : Array[(Int, Int)] = [
    (0, 0), (0, 1), (1, 1), (1, 2), (2, 0), (2, 2)
  ]
  let result = @matching.bipartite_matching(3, 3, edges)
  println("最大匹配数: \{result.cardinality\}")
  for (u, v) in result.matching_edges {
    println("  NodeId(\{u.0\}) ↔ NodeId(\{v.0\})")
  }
}
```

## 实际场景

- **任务分配**：N 个工人与 M 个任务的匹配（每个人擅长不同任务）
- **排课系统**：教师与教室的时间段匹配
- **相亲配对**：月老系统中的稳定匹配（可结合偏好扩展为稳定婚姻问题）

## 扩展阅读

- [Hopcroft-Karp 算法](/algorithms/matching/bipartite/hopcroft-karp/) — 更快的二分图匹配（O(E√V)）
- [Edmonds 一般图匹配](/algorithms/matching/general/edmonds/) — 支持奇环的一般图匹配
