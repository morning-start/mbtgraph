---
title: 广度优先搜索 (BFS)
description: 图的层级遍历算法详解
---

# 🚧 内容建设中...

## 广度优先搜索 (BFS)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 6 月中旬（优先级：P1）</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>📊 算法原理（图文+动画演示）</li>
      <li>🧩 核心思想：队列 + 层级遍历</li>
      <li>💻 MoonBit 完整代码实现与逐行注释</li>
      <li>📈 复杂度分析：O(V+E) 时间，O(V) 空间</li>
      <li>🎯 实际应用：最短路径（无权图）、社交网络层级发现</li>
      <li>🧪 练习题：3 道巩固题目</li>
    </ul>
    <p>在此期间，可以先查看 <a href="/getting-started/first-graph/">第一个图程序</a> 中的 BFS 使用示例。</p>
  </div>
</div>

## 算法简介

**广度优先搜索（Breadth-First Search, BFS）** 是一种用于遍历或搜索图数据结构的算法。

### 核心特点
- 使用 **队列（Queue）** 作为辅助数据结构
- **层级遍历**：先访问距离起点近的节点，再访问远的节点
- 可用于求解 **无权图的最短路径**

### 时间复杂度
- **时间**: O(V + E)，V 为节点数，E 为边数
- **空间**: O(V)，需要存储队列和访问标记

### 典型应用场景
1. **无权图的最短路径**
2. **社交网络的 N 度好友发现**
3. **网络爬虫的网页抓取策略**
4. **垃圾回收算法中的标记阶段**

---

**相关文档：**
- [深度优先搜索 (DFS)](/algorithms/traversal/dfs/index/)
- [高级遍历技巧](/algorithms/traversal/advanced/index/)
- [API 参考 - Traversal 模块](/api/algorithms/)
