---
title: Tarjan 算法
description: 基于 DFS 的强连通分量检测算法
---

# 🚧 内容建设中...

## Tarjan 算法 (SCC)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>Tarjan 算法的 DFS 单次遍历策略</li>
      <li>lowlink 值与栈的使用技巧</li>
      <li>完整 MoonBit 实现</li>
      <li>复杂度：O(V+E)</li>
    </ul>
  </div>
</div>

## 算法简介
**Tarjan 算法** 由 Robert Tarjan 于 1972 年提出，用于在有向图中寻找**强连通分量（Strongly Connected Components, SCC）**。

### 强连通分量的定义
在有向图中，如果两个节点 u 和 v 可以互相到达，则它们属于同一个 SCC。

### Tarjan vs Kosaraju

| 特性 | Tarjan | Kosaraju |
|------|--------|----------|
| DFS 次数 | 1 次 | 2 次 |
| 需要反转图 | 否 | 是 |
| 空间复杂度 | O(V) | O(V) |
| 实现难度 | 较高 | 较低 |

---

**相关文档：**
- [Kosaraju 算法](/algorithms/connectivity/scc/kosaraju)
- [DFS 基础](/algorithms/traversal/dfs/index/)
