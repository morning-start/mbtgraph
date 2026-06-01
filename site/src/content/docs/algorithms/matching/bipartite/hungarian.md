---
title: 匈牙利算法
description: 二分图最大匹配的经典算法
---

# 🚧 内容建设中...

## 匈牙利算法 (Hungarian Algorithm)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 8 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>二分图匹配问题定义</li>
      <li>增广路定理与交替路径</li>
      <li>Hungarian 算法的 DFS/BFS 实现</li>
      <li>O(VE) 时间复杂度分析</li>
      <li>应用：任务分配、人员配对</li>
    </ul>
  </div>
</div>

## 算法简介
**匈牙利算法**用于求解**二分图的最大匹配（Maximum Bipartite Matching）**。

### 二分图匹配
- 二分图的顶点可分为两个不相交的集合 U 和 V
- 每条边连接 U 中的一个顶点和 V 中的一个顶点
- **匹配**是一组没有公共端点的边的集合
- **最大匹配**是边数最多的匹配

### 应用场景
- 工作分配：工人与任务的匹配
- 婚姻匹配：稳定婚姻问题
- 课程安排：学生与课程的匹配

---

**相关文档：**
- [Hopcroft-Karp](/algorithms/matching/bipartite/hopcroft-karp) （优化版）
- [一般图匹配 - Edmonds](/algorithms/matching/general/edmonds)
