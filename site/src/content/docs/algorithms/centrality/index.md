---
title: 中心性指标
description: 衡量图中节点重要性的多种方法
---

# 🚧 内容建设中...

## 中心性指标 (Centrality Measures)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 9 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>度中心性（Degree Centrality）</li>
      <li>介数中心性（Betweenness Centrality）</li>
      <li>接近中心性（Closeness Centrality）</li>
      <li>特征向量中心性 / PageRank</li>
      <li>各指标的适用场景对比</li>
    </ul>
  </div>
</div>

## 为什么要衡量中心性？

在社交网络、引文网络、基础设施网络等场景中，我们经常需要回答：
- "谁是网络中最重要的人物？"
- "哪个节点对信息传播影响最大？"
- "移除哪个节点会导致网络严重断裂？"

不同的**中心性指标**从不同角度定义"重要性"：

### 主要指标

| 指标 | 直觉含义 | 计算复杂度 | 典型应用 |
|------|---------|-----------|---------|
| **度中心性** | 直接连接数量多 | O(1) per node | 流行度排名 |
| **介数中心性** | 位于多条最短路径上 | O(VE) 或 O(V³) | 信息桥梁 |
| **接近中心性** | 到其他节点距离近 | O(V*(V+E)) | 传播速度 |
| **PageRank** | 被重要节点指向 | 迭代收敛 | 网页排序 |

### PageRank 特别说明

**PageRank** 是 Google 搜索引擎的核心算法，最初用于网页重要性排序，现已广泛应用于：
- 社交网络影响力分析
- 学术论文重要性评估
- 推荐系统中的物品权重

---

**相关文档：**
- [社区检测](/algorithms/community/index/)
- [实战案例 - 社交网络](/use-cases/social-network/influencers)
