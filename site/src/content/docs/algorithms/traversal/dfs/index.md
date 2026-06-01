---
title: 深度优先搜索 (DFS)
description: 图的递归探索算法详解
---

# 🚧 内容建设中...

## 深度优先搜索 (DFS)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 6 月中旬（优先级：P1）</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>📊 算法原理（递归栈图解）</li>
      <li>🧩 核心思想：栈 + 回溯探索</li>
      <li>💻 MoonBit 完整代码实现（递归 + 迭代版本）</li>
      <li>📈 复杂度分析：O(V+E) 时间，O(V) 空间</li>
      <li>🎯 实际应用：环检测、拓扑排序、路径查找</li>
      <li>🧪 练习题：3 道巩固题目</li>
    </ul>
    <p>在此期间，可以参考 <a href="/algorithms/traversal/bfs/index/">BFS 教程</a> 了解遍历算法基础。</p>
  </div>
</div>

## 算法简介

**深度优先搜索（Depth-First Search, DFS）** 是另一种重要的图遍历算法。

### 核心特点
- 使用 **栈（Stack）** 或 **递归调用栈**
- **深度优先**：沿着一条路径走到底，再回溯探索其他分支
- 可用于检测 **环、连通性、拓扑排序**

### 与 BFS 的对比

| 特性 | BFS | DFS |
|------|-----|-----|
| 数据结构 | 队列 | 栈/递归 |
| 遍历顺序 | 层级 | 深度 |
| 最短路径 | 无权图 ✅ | ❌ |
| 内存占用 | 较大（广） | 较小（深）|
| 适用场景 | 最短路径 | 环检测、拓扑排序 |

### 典型应用场景
1. **环检测**（有向图/无向图）
2. **拓扑排序**（任务调度）
3. **强连通分量**（Tarjan/Kosaraju）
4. **路径查找**（迷宫问题）
5. **生成树构造**

---

**相关文档：**
- [广度优先搜索 (BFS)](/algorithms/traversal/bfs/index/)
- [高级遍历技巧](/algorithms/traversal/advanced/index/)
- [强连通分量 - Tarjan](/algorithms/connectivity/scc/tarjan)
