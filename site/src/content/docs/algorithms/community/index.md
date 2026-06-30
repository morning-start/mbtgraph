---
title: Louvain 社区检测算法
description: 基于模块度优化的经典社区发现算法详解：原理、动画演示、MoonBit 实现
---

# Louvain 社区检测算法

> 🎯 **本节目标**: 掌握 Louvain 算法原理、模块度优化机制与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**社区检测**的目标是将图中的节点划分为若干个"内部密集、外部稀疏"的社区。**Louvain 算法**（Blondel et al., 2008）是目前最流行的社区检测算法之一，通过**贪心优化模块度 (Modularity)** 实现高效社区划分。

算法包含两个阶段交替执行：
1. **局部优化**：遍历所有节点，将其移动到使模块度增量最大的邻居社区
2. **聚合**：将每个社区收缩为一个"超级节点"，构建新图

重复迭代直到模块度不再提升。算法无需预先指定社区数量，时间复杂度 O(V log V)，可处理百万节点级别的图。

模块度 Q 衡量社区划分质量，范围 [-0.5, 1]。Q > 0.3 表示有意义的社区结构，Q > 0.5 表示明显的社区结构。`resolution` 参数控制划分粒度：值越小社区越粗，值越大社区越细。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/louvain/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/louvain/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 同色节点 | 属于同一个社区 |
| 橙色 | 当前正在尝试移动的节点 |
| 灰色 | 默认 |

## MoonBit 实现

核心代码来自 `lib/algo/community/louvain.mbt`：

```moonbit
///|
/// Louvain 社区检测算法
/// 时间复杂度 O(V log V)，空间复杂度 O(V+E)
pub fn[G : @core.GraphReadable] louvain(
  graph : G,
  resolution : Double,
) -> CommunityResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return CommunityResult::{
      community_labels: [], num_communities: 0, modularity: 0.0, levels: 0
    }
  }

  // 初始化：每个节点自成一个社区
  let node_list = collect_nodes(graph)
  let n = node_list.length()
  let mut label : Array[Int] = [for i in 0..<n { i }]
  let mut community_weight = compute_total_weight(graph)  // 总权重 2m

  let mut improved = true
  let mut current_resolution = resolution
  let mut num_levels = 0

  while improved {
    improved = false
    // Phase 1: 局部移动优化
    for u in node_list {
      let current_community = label[u.0]
      let best_community = current_community
      let best_delta_q = 0.0

      // 计算将 u 移动到每个邻居社区的模块度增量
      for v in @core.GraphReadable::neighbors(graph, u) {
        let target_community = label[v.0]
        if target_community == current_community { continue }

        let delta_q = compute_modularity_gain(
          graph, u, current_community, target_community,
          community_weight, current_resolution
        )

        if delta_q > best_delta_q {
          best_delta_q = delta_q
          best_community = target_community
        }
      }

      // 如果有正向收益，执行移动
      if best_delta_q > 0.000001 {
        label[u.0] = best_community
        improved = true
      }
    }

    // Phase 2: 聚合（如果有改善）
    if improved {
      // 将同一标签的节点收缩为超级节点
      // 更新 community_weight
      num_levels = num_levels + 1
    }
  }

  CommunityResult::{
    community_labels: label,
    num_communities: count_unique(label),
    modularity: compute_modularity(graph, label, community_weight),
    levels: num_levels,
  }
}
```

**Resolution 调参的直觉**：`resolution` 出现在模块度增益公式的分母中。`resolution > 1` 使小社区更易获益（划分更细），`resolution < 1` 使大社区更易获益（划分更粗）。

## 使用示例

```moonbit
fn louvain_demo() -> Unit {
  let mut g = @storage.UndirectedAdjList::new()
  let n = [@core.GraphWritable::add_node(g, 0.0); 10]

  // 3 个三角形 + 弱连接
  let edges = [(0,1),(0,2),(1,2),(1,3),(4,5),(4,6),(5,6),(7,8),(7,9),(8,9)]
  for (u, v) in edges {
    let _ = @core.GraphWritable::add_edge(g, n[u], n[v], 1.0)
  }
  let _ = @core.GraphWritable::add_edge(g, n[2], n[4], 0.5)
  let _ = @core.GraphWritable::add_edge(g, n[5], n[7], 0.5)

  let result = @community.louvain(g, 1.0)
  println("社区数量: ${result.num_communities}")
  println("模块度: ${result.modularity}")

  for (node, com) in result.community_labels.indexed() {
    println("  节点 ${node} → 社区 #${com}")
  }
}
```

## 实际场景

- **社交网络群体识别**：自动发现 Twitter/Facebook 中的兴趣群组
- **生物网络模块分析**：蛋白质互作网络中的功能模块检测
- **推荐系统冷启动**：利用社区划分向新用户推荐所在社区的热门内容

## 扩展阅读

- [标签传播算法 (LPA)](/algorithms/community/) — 更简单的社区检测算法
- [Leiden 算法](/algorithms/community/) — Louvain 的改进版（解决连通性缺陷）
- [中心性分析](/algorithms/centrality/) — 另一种分析图结构的方法
