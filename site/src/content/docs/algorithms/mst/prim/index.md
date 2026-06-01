---
title: Prim 算法
description: 基于切分定理的最小生成树算法
---

# 🚧 内容建设中...

## Prim 算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>切分定理（Cut Property）证明</li>
      <li>优先队列实现细节</li>
      <li>延迟/即时删除优化策略</li>
      <li>适用场景：稠密图 MST</li>
    </ul>
  </div>
</div>

## 算法简介
**Prim** 算法是另一种求解最小生成树的经典方法，特别适合**稠密图**。

### 核心思想
1. 从任意节点开始构建 MST
2. 维护一个已访问节点集合 S
3. 每次选择连接 S 和 V-S 的最小权重边
4. 使用优先队列高效获取最小边

### 复杂度
- **时间**: O((V+E)log V) 或 O(V² + E)（取决于实现）
- **空间**: O(V)

---

**相关文档：**
- [Kruskal 算法](/algorithms/mst/kruskal/index/)
- [存储选型指南](/core-concepts/storage-guide/)
