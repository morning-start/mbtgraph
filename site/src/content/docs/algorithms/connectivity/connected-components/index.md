---
title: 连通分量 (Connected Components)
description: 无向图连通性分析：DFS/BFS/Union-Find 三种解法，O(V+E) 时间复杂度
---

# 连通分量（Connected Components）

> 🎯 **本节目标**: 掌握连通分量概念、三种解法的异同与 MoonBit 实现 | ⏱️ **预计阅读时间**: 8 分钟

## 算法简介

在**无向图**中，**连通分量（Connected Component, CC）** 是最大的节点子集，其中任意两个节点之间都存在路径。如果一个图只有一个连通分量，则称该图是**连通的**。

连通分量是最基础的图分析工具——当我们回答"这个图各部分是否连通？有多少个独立簇？"时，就是在做连通分量检测。三种经典解法是 **DFS 遍历**、**BFS 遍历**和 **Union-Find 并查集**，时间均为 O(V+E)。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/connected_components/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/connected_components/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 同一颜色 | 属于同一个连通分量 |
| 灰色 | 默认未处理 |

## MoonBit 实现

核心代码来自 `lib/algo/connectivity/components.mbt`（DFS 版本）：

```moonbit
fn[G : @core.GraphReadable] cc_dfs_visit(
  g : G, start : @core.NodeId,
  visited : Array[Bool], component : Array[@core.NodeId],
) -> Unit {
  let stack : Array[@core.NodeId] = [start]
  visited[start.0] = true
  let mut head = 0
  while head < stack.length() {
    let cur = stack[head]
    component.push(cur)
    head = head + 1
    for nbr in @core.GraphReadable::neighbors(g, cur) {
      if !visited[nbr.0] {
        visited[nbr.0] = true
        stack.push(nbr)
      }
    }
  }
}

/// 连通分量检测 (DFS 版本)
/// 时间复杂度 O(V+E)，空间复杂度 O(V)
pub fn[G : @core.GraphReadable] connected_components(g : G) -> ConnectedComponentsResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return ConnectedComponentsResult::{
      components: [], count: 0, is_connected: false, largest_component_size: 0
    }
  }
  let max_id = find_max_node_id(g)
  let size = max(max_id + 1, 1)
  let visited : Array[Bool] = Array::make(size, false)
  let result : Array[Array[@core.NodeId]] = []

  for node in @core.GraphReadable::node_ids(g) {
    if !visited[node.0] {
      let component : Array[@core.NodeId] = []
      cc_dfs_visit(g, node, visited, component)
      result.push(component)
    }
  }

  let mut largest = 0
  for comp in result { if comp.length() > largest { largest = comp.length() } }

  ConnectedComponentsResult::{
    components: result, count: result.length(),
    is_connected: result.length() == 1, largest_component_size: largest,
  }
}
```

**为什么入队时标记 visited？** 在 `stack.push(nbr)` 之前立即标记 visited，可避免同一节点被多个邻居重复入队——每个节点最多入队 1 次。

**三种解法对比**：DFS 和 BFS 需要邻接表结构，Union-Find 只需边列表（更灵活）。Union-Find 天然支持增量更新（动态加边），但对删边操作不友好。

## 使用示例

```moonbit
fn cc_demo() -> Unit {
  let g = build_sample_undirected_graph()
  let result = @connectivity.connected_components(g)

  println("连通分量数量: ${result.count}")
  println("是否全连通: ${result.is_connected}")
  println("最大分量大小: ${result.largest_component_size}")

  for (i, comp) in result.components.indexed() {
    println("分量 #${i}: ${comp}")
  }
}
```

## 实际场景

- **社交网络社群发现**：自动识别互相关注的用户群体，用于精准推荐和舆情分析
- **图像连通区域标记**：二值图像中分离不同的物体/字符，OCR 预处理的必要步骤
- **网络分区检测**：判断电信/计算机网络是否存在分区故障

## 扩展阅读

- [割点与桥](/algorithms/connectivity/articulation-points/) — 基于连通分量的进阶分析
- [强连通分量 (Tarjan)](/algorithms/connectivity/scc/tarjan/) — 有向图版本的连通性分析
- [Union-Find 并查集](/algorithms/mst/kruskal/) — CC 的另一种解法和核心数据结构
