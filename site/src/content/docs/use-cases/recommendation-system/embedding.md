---
title: 图嵌入入门
description: 将图的节点映射到低维向量空间
---

# 🚧 内容建设中...

## 图嵌入入门 (Graph Embedding)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 10 月下旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>图嵌入的基本概念与目标</li>
      <li>基于随机游走的方法（DeepWalk、Node2Vec）</li>
      <li>基于图神经网络的方法简介</li>
      <li>在推荐系统中的应用</li>
    </ul>
  </div>
</div>

## 什么是图嵌入？

**图嵌入（Graph Embedding）**：将图中的节点（或边、子图）映射到低维稠密向量空间，同时保持图的结构信息。

### 直觉理解

原始图 → 嵌入向量
```
节点 A ──┬── 节点 B          A → [0.2, -0.5, 0.8, ...]
         │                   B → [0.3, -0.4, 0.7, ...]
         └── 节点 C          C → [0.25, -0.45, 0.75, ...]
```

### 为什么需要图嵌入？
- **降维**：高维稀疏 → 低维稠密
- **可计算**：向量运算比图查询快得多
- **通用表示**：可用于下游任务（分类、聚类、推荐）

### 主要方法

| 方法 | 思想 | 复杂度 | 特点 |
|------|------|--------|------|
| DeepWalk | 随机游走 + Word2Vec | O(t·l·n) | 简单有效 |
| Node2Vec | 偏置随机游走 | O(t·l·n) | 可控制 BFS/DFS 平衡 |
| GraphSAGE | 图神经网络 | O(E) | 归纳学习 |

---

**相关文档：**
- [用户-物品二分图](/use-cases/recommendation-system/bipartite)
- [协同过滤实现](/use-cases/recommendation-system/collaborative-filtering)
- [社区检测](/algorithms/community/index/)
