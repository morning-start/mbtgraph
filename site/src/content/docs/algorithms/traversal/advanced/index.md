---
title: 高级遍历技巧
description: 双向 BFS、迭代加深等优化方法
---

# 🚧 内容建设中...

## 高级遍历技巧

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>双向 BFS（Bidirectional BFS）</li>
      <li>迭代加深（Iterative Deepening）</li>
      <li>A* 算法的启发式搜索思想</li>
      <li>遍历优化策略与性能调优</li>
      <li>大规模图的内存管理技巧</li>
    </ul>
    <p>建议先掌握基础的 <a href="/algorithms/traversal/bfs/index/">BFS</a> 和 <a href="/algorithms/traversal/dfs/index/">DFS</a>。</p>
  </div>
</div>

## 即将包含的内容

### 双向 BFS

从起点和终点同时进行 BFS，在中间相遇时停止。

**优势**：
- 时间复杂度：O(2b^(d/2)) vs O(b^d)
- 适用于已知起点和终点的情况

### 迭代加深

结合 DFS 和 BFS 的优点，逐步增加搜索深度。

**优势**：
- 内存占用低（类似 DFS）
- 能找到最短路径（类似 BFS）

---

**相关文档：**
- [BFS 基础](/algorithms/traversal/bfs/index/)
- [DFS 基础](/algorithms/traversal/dfs/index/)
- [A* 启发式搜索](/algorithms/shortest-path/a-star/index/)
