---
title: Bellman-Ford 算法
description: 支持负权边的单源最短路径算法
---

# 🚧 内容建设中...

## Bellman-Ford 算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>动态规划思路详解</li>
      <li>负权边处理机制</li>
      <li>负环检测算法</li>
      <li>与 Dijkstra 的对比分析</li>
    </ul>
  </div>
</div>

## 算法简介
**Bellman-Ford** 是一种基于动态规划的最短路径算法，可以处理包含**负权边**的图。

### 核心特点
- ✅ 支持 **负权边**
- ✅ 可检测 **负环（Negative Cycle）**
- ❌ 时间复杂度较高：O(VE)

### 适用场景
- 金融网络中的套利检测
- 包含负权边的图问题

---

**相关文档：**
- [Dijkstra 算法](/algorithms/shortest-path/dijkstra/index/)
- [Floyd-Warshall](/algorithms/shortest-path/floyd-warshall/index/)
