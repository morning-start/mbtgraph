---
title: "最小生成树 (MST): Kruskal & Prim 算法"
description: "Kruskal 和 Prim 两种最小生成树算法的详细对比、原理说明与 MoonBit 实现"
---

# 最小生成树 (MST): Kruskal & Prim 算法

> 🎯 **本节目标**: 理解 MST 概念，掌握 Kruskal 和 Prim 两种算法的异同与选择依据 | ⏱️ **预计阅读时间**: 8 分钟

## 算法简介

**最小生成树（Minimum Spanning Tree, MST）** 是一个无向连通图 G = (V, E) 的极小连通子图，它包含所有 V 个节点，且边的权重之和最小。求解 MST 有两种经典贪心算法：**Kruskal**（按边选）和 **Prim**（按点长）。

### Kruskal 算法

将所有边按权重从小到大排序，用**并查集**检查每条边的两端是否已连通。若未连通则加入 MST，否则跳过。适用于**稀疏图**，复杂度 O(E log E)。

### Prim 算法

从起点出发，每次选择**连接已选集合与未选集合的最小权重边**加入 MST。使用数组实现 O(V²)，适用于**稠密图**；使用二叉堆可实现 O(E log V)。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/kruskal/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/kruskal/" target="_blank" class="viz-fullscreen-btn">全屏演示 Kruskal</a>
</div>

<div class="viz-preview-card">
  <iframe src="/visualizations/prim/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/prim/" target="_blank" class="viz-fullscreen-btn">全屏演示 Prim</a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 橙色 | 当前处理的边/节点 |
| 绿色 | 已加入 MST |
| 红色 | 跳过的边（会形成环路） |

## MoonBit 实现

参见各算法的独立教程页面：

- [Kruskal 完整实现](/algorithms/mst/kruskal/)
- [Prim 完整实现](/algorithms/mst/prim/)

## 算法对比

| 维度 | Kruskal | Prim |
|------|---------|------|
| **策略** | 选最小的边 | 扩展最近的节点 |
| **数据结构** | 并查集 (Union-Find) | 数组 / 优先队列 |
| **时间复杂度** | O(E log E) | O(V²) 或 O(E log V) |
| **适用图** | 稀疏图（E ≈ V） | 稠密图（E ≈ V²） |
| **不连通图** | ✅ 返回森林 | ❌ 只返回所在分量 |
| **需要起点** | ❌ 不需要 | ✅ 需要 root |

## 使用示例

```moonbit
fn mst_demo() -> Unit {
  let mut g = @storage.UndirectedAdjList::new_with_capacity(5, 7)
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 5]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[3], 3.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[3], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[4], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 7.0)

  let kruskal_result = @mst.kruskal(g)
  let prim_result = @mst.prim(g, nodes[0])

  println("Kruskal MST 权重: \(kruskal_result.total_weight)")
  println("Prim MST 权重:    \(prim_result.total_weight)")
  // 两者应一致（连通图）
}
```

## 实际场景

- **网络设计**：铺设光纤/电缆/管道网络，MST 保证最低成本
- **电路布线**：VLSI 设计中连接所有引脚的最小总线长
- **聚类分析**：Kruskal 可用于层次聚类（去掉最重的 V-K 条边得到 K 个簇）

## 扩展阅读

- [并查集 (Union-Find)](/algorithms/mst/kruskal/) — Kruskal 使用的核心数据结构
