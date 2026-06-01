---
title: Hopcroft-Karp 算法
description: 二分图匹配的高效算法
---

# 🚧 内容建设中...

## Hopcroft-Karp 算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 8 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>最短增广路分层策略</li>
      <li>阶段式增广（Phase-based Augmenting）</li>
      <li>O(E√V) 复杂度的证明直觉</li>
      <li>大规模二分图匹配的生产级选择</li>
    </ul>
  </div>
</div>

## 算法简介
**Hopcroft-Karp** 是 Hungarian 算法的改进版本，特别适合**大规模二分图**。

### 核心改进
1. **最短增广路优先**：BFS 找到多条最短的增广路径
2. **批量增广**：一次找到多条增广路径并同时应用
3. **阶段迭代**：重复上述过程直到无增广路径

### 复杂度对比

| 算法 | 时间复杂度 | 适用规模 |
|------|-----------|---------|
| Hungarian | O(VE) | 小型图 |
| **Hopcroft-Karp** | **O(E√V)** | **大型图** |

### 推荐场景
- ⭐ 大规模二分图匹配的**首选算法**
- 社交网络中的用户-兴趣匹配
- 推荐系统中的用户-物品二分图

---

**相关文档：**
- [Hungarian 算法](/algorithms/matching/bipartite/hungarian) （入门版）
- [实战案例 - 推荐](/use-cases/recommendation-system/bipartite)
