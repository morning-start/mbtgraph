---
title: Dinic 优化算法
description: 高效的最大流算法（层次图 + 阻塞流）
---

# 🚧 内容建设中...

## Dinic 算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 8 月上旬（优先级：P2）</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>层次图（Level Graph）构建</li>
      <li>阻塞流（Blocking Flow）概念</li>
      <li>当前弧优化（Current Arc Optimization）</li>
      <li>O(E√V) 复杂度的单位图特例</li>
      <li>生产级最大流算法推荐</li>
    </ul>
  </div>
</div>

## 算法简介
**Dinic 算法**（也称 Dinitz 算法）是比 Edmonds-Karp 更高效的最大流算法。

### 核心优化
1. **层次图**：用 BFS 构建分层网络
2. **阻塞流**：在层次图中找到无法再增加的流
3. **多路增广**：一次 BFS 可多次 DFS 增广
4. **当前弧优化**：避免重复检查已饱和边

### 复杂度对比

| 算法 | 时间复杂度 | 实际性能 |
|------|-----------|---------|
| Edmonds-Karp | O(VE²) | 较慢 |
| **Dinic** | **O(EV²)** 或 **O(E√V)** 单位图 | **快** |
| Push-Relabel | O(V³) | 理论最优 |

### 推荐场景
- ⭐ 大规模网络的**生产环境首选**
- 二分图匹配（Hopcroft-Karp 的替代）
- 需要高效求解最大流的问题

---

**相关文档：**
- [Edmonds-Karp](/algorithms/flow/max-flow/edmonds-karp) （入门版）
- [最小费用最大流](/algorithms/flow/min-cost-max-flow/index/) （扩展问题）
