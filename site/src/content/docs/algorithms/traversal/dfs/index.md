---
title: 深度优先搜索 (DFS)
description: 图的纵深遍历算法详解：原理、动画演示、时间戳、MoonBit 实现
---

# 深度优先搜索 (DFS)

> 🎯 **本节目标**: 掌握 DFS 算法原理、时间戳系统与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**深度优先搜索（Depth-First Search, DFS）** 是一种用于深入探索图/树数据结构的算法。它从起点出发，沿一条路径尽可能深入地前进，直到无路可走才回溯，然后尝试其他分支——如同走迷宫时，选择一条路走到死胡同，再退回上一个岔路口。

DFS 使用**栈（Stack）** 数据结构（后进先出），天然支持先入后出的深入行为。与 BFS 不同，DFS 不保证最短路径，但它拥有独特的 **时间戳系统**（entry_time / exit_time），可用于拓扑排序、环检测和强连通分量分析。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/dfs/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/dfs/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 深棕色 | 起点 |
| 橙色 | 当前栈顶节点（正在探索） |
| 黄色 | 新发现的节点（刚入栈） |
| 绿色 | 已处理完毕（已弹栈） |
| 灰色 | 默认未访问状态 |
| 红色粗线 | 树边（首次发现邻居的边） |
| 蓝色虚线 | 回边（指向栈中祖先，表示有环） |

## MoonBit 实现

核心代码来自 `lib/algo/traversal/dfs.mbt`：

```moonbit
///|
/// 单源 DFS：从 start 节点开始遍历（迭代式，显式栈）
/// 时间复杂度: O(V + E)，空间复杂度: O(V)
pub fn[G : @core.GraphReadable] dfs(
  graph : G,
  start : @core.NodeId
) -> DfsResult {
  let nc = @core.GraphReadable::node_count(graph)

  // 边界检查
  if nc == 0 || !@core.GraphReadable::contains_node(graph, start) {
    return empty_dfs_result()
  }

  let max_id = dfs_find_max_id(graph)
  let size = max(max_id + 1, 1)

  let visited = Array::make(size, false)
  let order : Array[@core.NodeId] = []
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  let entry = Array::make(size, -1)    // 进入时间戳
  let exit = Array::make(size, -1)     // 退出时间戳
  let mut time = 0

  let stack : Array[@core.NodeId] = [start]
  visited[start.0] = true
  entry[start.0] = time
  time = time + 1
  let mut stack_len = 1

  while stack_len > 0 {
    let cur = stack[stack_len - 1]  // peek 栈顶（不弹出）

    // 寻找第一个未访问的邻居
    let mut found = false
    for nid in @core.GraphReadable::neighbors(graph, cur) {
      let idx = nid.0
      if idx >= 0 && idx < size && !visited[idx] {
        visited[idx] = true
        parents[idx] = Some(cur)
        entry[idx] = time
        time = time + 1
        stack.push(nid)
        stack_len = stack_len + 1
        found = true
        break  // 只找一个邻居就深入
      }
    }

    // 无未访问邻居 → 回溯
    if !found {
      order.push(cur)
      exit[cur.0] = time
      time = time + 1
      stack_len = stack_len - 1
    }
  }

  DfsResult::{
    base: TraversalResult::{ visited, order, parents },
    entry_time: entry,
    exit_time: exit,
  }
}
```

**为什么用显式栈而非递归？** MoonBit 对递归深度有限制。显式栈版本适用于任意规模的图，且能精确控制 entry/exit 时间戳——将结果按 `exit_time` 降序排列即得拓扑排序。

## 使用示例

```moonbit
fn dfs_demo() -> Unit {
  let g = build_sample_dag()
  let result = @traversal.dfs(g, @core.NodeId(0))

  println("=== DFS 遍历结果 ===")
  println("完成顺序 (post-order): \{result.base.order\}")

  // 拓扑排序：将 order 反转
  let topo = result.base.order.reverse()
  println("拓扑排序: \{topo\}")
}
```

## 实际场景

- **拓扑排序**：在课程依赖规划中确定学习顺序，按 DFS 退出时间降序排列即是合法顺序
- **环检测**：依赖管理（Makefile、模块导入）中检测循环依赖——存在回边即有环
- **强连通分量**：Tarjan 和 Kosaraju 算法均基于 DFS，用于分析有向图的强连通性

## 扩展阅读

- [BFS 广度优先搜索](/algorithms/traversal/bfs/) — 对比学习两种遍历策略
- [Tarjan 强连通分量](/algorithms/connectivity/scc/tarjan/) — 基于 DFS 时间戳的 SCC 算法
- [Kosaraju 算法](/algorithms/connectivity/scc/kosaraju/) — 两次 DFS 的 SCC 算法
