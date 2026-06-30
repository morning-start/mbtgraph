---
title: 广度优先搜索 (BFS)
description: 图的层级遍历算法详解：原理、动画演示、MoonBit 实现
---

# 广度优先搜索 (BFS)

> 🎯 **本节目标**: 掌握 BFS 算法原理与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**广度优先搜索（Breadth-First Search, BFS）** 是一种用于逐层遍历或搜索图/树数据结构的算法。它从起点出发，先访问所有距离为 1 的邻居节点，再访问距离为 2 的节点，以此类推——如同水面投石产生的涟漪，一圈一圈向外扩散。

BFS 使用**队列（Queue）** 数据结构，先入先出地处理节点，保证每一层在进入下一层之前被完全遍历。由于这一特性，BFS 是无权图（所有边权重相同）上求最短路径的自然选择。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/bfs/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/bfs/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 深棕色 | 起点 |
| 橙色 | 当前处理中 |
| 黄色 | 刚发现的新节点 |
| 绿色 | 已处理完毕 |
| 灰色 | 默认未访问状态 |
| 红色粗线 | 树边（首次发现邻居的边） |
| 灰色虚线 | 已跳过的边（邻居已访问） |

## MoonBit 实现

核心代码来自 `lib/algo/traversal/bfs.mbt`：

```moonbit
///|
/// 单源 BFS：从 start 节点开始遍历
/// 时间复杂度: O(V + E)，空间复杂度: O(V)
pub fn[G : @core.GraphReadable] bfs(
  graph : G,
  start : @core.NodeId
) -> BfsResult {
  let nc = @core.GraphReadable::node_count(graph)

  // 边界检查
  if nc == 0 || !@core.GraphReadable::contains_node(graph, start) {
    return empty_bfs_result()
  }

  // 找到最大 NodeId 确定数组大小
  let max_id = find_max_node_id(graph)
  let size = max(max_id + 1, 1)

  let visited = Array::make(size, false)
  let order : Array[@core.NodeId] = []
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  let levels = Array::make(size, -1)
  let queue : Array[@core.NodeId] = []

  // 起点初始化
  visited[start.0] = true
  levels[start.0] = 0
  parents[start.0] = None
  queue.push(start)

  let mut head = 0  // 头指针避免 shift() 的 O(n) 开销

  while head < queue.length() {
    let cur = queue[head]
    head = head + 1
    order.push(cur)

    for nid in @core.GraphReadable::neighbors(graph, cur) {
      let idx = nid.0
      if idx >= 0 && idx < size && !visited[idx] {
        visited[idx] = true
        parents[idx] = Some(cur)
        levels[idx] = levels[cur.0] + 1
        queue.push(nid)
      }
    }
  }

  BfsResult::{
    base: TraversalResult::{ visited, order, parents },
    levels: levels,
  }
}
```

**为什么使用 `head` 指针而非 `shift()`？** MoonBit 的 `shift()` 操作需要 O(n) 移动数组元素，使用头指针可将出队操作降为 O(1)，整体从 O(V²) 优化到 O(V)。

## 使用示例

```moonbit
fn bfs_demo() -> Unit {
  let g = build_sample_undirected_graph()
  let result = @traversal.bfs(g, @core.NodeId(0))

  println("=== BFS 遍历结果 ===")
  println("访问顺序: ${result.base.order}")
  println("可达节点数: ${result.base.reachable_count()}")

  // 查询最短路径
  let path = result.base.path_to(@core.NodeId(3))
  println("0 → 3 的最短路径: ${path}")
}
```

## 实际场景

- **社交网络推荐**：以用户为起点执行 BFS，推荐第 2 层的"二度好友"（可能认识的人）
- **网络爬虫**：从种子 URL 开始按广度优先顺序抓取网页，优先抓取"离家近"的同域名页面
- **GPS 导航**：在无权道路网中寻找最近加油站或餐厅，BFS 保证找到的最近目标确实最近

## 扩展阅读

- [DFS 深度优先搜索](/algorithms/traversal/dfs/) — 对比学习的另一基础遍历算法
- [Dijkstra 最短路径](/algorithms/shortest-path/dijkstra/) — 带权图的 BFS 泛化
