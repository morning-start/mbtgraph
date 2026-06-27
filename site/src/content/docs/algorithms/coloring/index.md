---
title: 图着色算法 (Graph Coloring)
description: 贪心着色与 DSATUR 详解：原理、动画演示、MoonBit 实现
---

# 图着色算法 (Graph Coloring)

> 🎯 **本节目标**: 掌握图着色问题定义、贪心着色与 DSATUR 算法原理 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**图着色**：给定无向图 G = (V, E)，为每个节点分配一种"颜色"，使得任意一条边的两端颜色不同。最少需要的颜色数称为**色数 (Chromatic Number)** χ(G)。图着色是经典的 NP-Hard 问题，实际中常用近似算法。

mbtgraph 提供了三种着色算法：
- **贪心着色** (Greedy)：按任意顺序为每个节点分配可用的最小颜色，复杂度 O(V²)，色数上界 Δ+1
- **DSATUR** (Degree SATuration)：贪心的优化版，优先为"选择最受限制"的节点着色，通常比贪心更优
- **精确着色**：通过回溯搜索精确解，适用于小图（V ≤ 20）

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/coloring/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/coloring/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 同色节点 | 被分配了相同颜色的节点（无直接边相连） |
| 橙色 | 当前正在着色的节点 |
| 灰色 | 尚未着色 |

## MoonBit 实现

核心代码来自 `lib/algo/coloring/greedy.mbt` 和 `dsatur.mbt`：

```moonbit
/// 贪心着色：按节点顺序分配最小可用颜色
/// 时间复杂度 O(V²)，空间复杂度 O(V)
pub fn[G : @core.GraphReadable] greedy_coloring(graph : G) -> ColoringResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 { return ColoringResult::{ colors: [], num_colors: 0 } }

  let max_id = find_max_node_id(graph)
  let size = max(max_id + 1, 1)
  let result : Array[Int?] = Array::make(size, None)
  let used : Array[Bool] = Array::make(size, false)

  for u in @core.GraphReadable::node_ids(graph) {
    // 标记已使用的颜色
    for _ in 0..<used.length() { used[_] = false }
    for v in @core.GraphReadable::neighbors(graph, u) {
      match result[v.0] { Some(c) => used[c] = true None => () }
    }
    // 找最小可用颜色
    let mut color = 0
    while color < used.length() && used[color] { color = color + 1 }
    result[u.0] = Some(color)
  }

  let colors : Array[Int] = []
  let mut max_color = 0
  for u in @core.GraphReadable::node_ids(graph) {
    match result[u.0] {
      Some(c) => { colors.push(c); if c > max_color { max_color = c } }
      None => ()
    }
  }

  ColoringResult::{ colors, num_colors: max_color + 1 }
}
```

**DSATUR 的核心改进**：`greedy_coloring` 按固定顺序（或随机顺序）着色，而 DSATUR 动态选择**饱和度最高**（已有不同颜色邻居数最多）的节点优先着色，通常能使用更少的颜色。

## 使用示例

```moonbit
fn coloring_demo() -> Unit {
  let mut g = @storage.UndirectedAdjList::new()
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 5]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[2], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 1.0)

  let greedy_result = @coloring.greedy_coloring(g)
  let dsatur_result = @coloring.dsatur_coloring(g)
  println("贪心着色: ${greedy_result.num_colors} 色")
  println("DSATUR:   ${dsatur_result.num_colors} 色")
}
```

## 实际场景

- **考试排课**：冲突图中的颜色 = 考试时间段，最小颜色数 = 最少时段
- **寄存器分配**：编译器中将变量分配到物理寄存器，相邻变量不可同寄存器
- **地图着色**：相邻国家/地区不同色的经典四色问题

## 扩展阅读

- [图论四色定理](https://en.wikipedia.org/wiki/Four_color_theorem) — 图着色的理论基础
- [Welsh-Powell 算法](/algorithms/coloring/) — 按度数降序的贪心着色变体
