---
title: Kruskal 算法
description: 基于并查集的最小生成树算法
---

# 🚧 内容建设中...

## Kruskal 算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>并查集（Union-Find）数据结构详解</li>
      <li>边排序贪心策略</li>
      <li>MoonBit 完整代码实现</li>
      <li>复杂度分析：O(E log E)</li>
    </ul>
  </div>
</div>

## 算法简介
**Kruskal** 算法用于求解无向连通图的**最小生成树（MST）**。

### 核心思想
1. 将所有边按权重排序
2. 按顺序选择边，若不形成环则加入 MST
3. 使用 **并查集（Union-Find）** 高效判断是否成环

### 复杂度
- **时间**: O(E log E)（主要在排序）
- **空间**: O(V)

### 与 Prim 对比
| 特性 | Kruskal | Prim |
|------|---------|------|
| 策略 | 边排序 + 并查集 | 切分定理 + 优先队列 |
| 适用 | 稀疏图 | 稠密图 |
| 时间 | O(E log E) | O((V+E)log V) |

---

**相关文档：**
- [Prim 算法](/algorithms/mst/prim/index/)
- [并查集数据结构](/core-concepts/data-types/)
