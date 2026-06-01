---
title: 连通分量 (CC)
description: 无向图的连通区域划分算法
---

# 🚧 内容建设中...

## 连通分量 (Connected Components)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>连通分量定义与性质</li>
      <li>BFS/DFS 实现方法</li>
      <li>并查集优化方案</li>
      <li>应用：社交网络中的群体发现</li>
    </ul>
  </div>
</div>

## 算法简介
**连通分量（Connected Components, CC）** 是无向图中最大的连通子图集合。

### 核心思想
- 使用 BFS 或 DFS 遍历
- 每次遍历找到一个连通分量
- 重复直到所有节点被访问

### 应用场景
- 社交网络中的社群发现
- 图像处理中的区域标记
- 网络中的连通性分析

---

**相关文档：**
- [强连通分量 (SCC)](/algorithms/connectivity/scc/tarjan)
- [BFS 基础](/algorithms/traversal/bfs/index/)
