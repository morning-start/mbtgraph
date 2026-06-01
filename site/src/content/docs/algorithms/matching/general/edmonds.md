---
title: Edmonds 算法
description: 一般图最大匹配的花朵算法
---

# 🚧 内容建设中...

## Edmonds 花朵算法 (Blossom Algorithm)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 8 月下旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>奇数长度环（花朵）的处理技巧</li>
      <li>花朵收缩与展开操作</li>
      <li>复杂度分析：O(V³) 或 O(V²E)</li>
      <li>一般图 vs 二分图的区别</li>
    </ul>
  </div>
</div>

## 算法简介
**Edmonds 花朵算法**（也称 Blossom 算法）由 Jack Edmonds 于 1965 年提出，用于求解**一般图（非二分图）的最大匹配**。

### 为什么需要特殊算法？
- 二分图：不存在奇数长度的环，Hungarian/Hopcroft-Karp 可用
- 一般图：可能存在**奇环（Odd Cycle）**，需要收缩处理

### 花朵（Blossom）
- 长度为奇数的环
- 以未匹配边为起点的交替路径形成的环
- 通过**收缩花朵**为单个节点来简化问题

### 复杂度
- **时间**: O(V³) 或 O(V²E)（取决于实现）
- **空间**: O(V²)

---

**相关文档：**
- [Hungarian 算法](/algorithms/matching/bipartite/hungarian) （二分图版本）
- [Hopcroft-Karp](/algorithms/matching/bipartite/hopcroft-karp)
