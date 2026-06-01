---
title: Floyd-Warshall 算法
description: 多源最短路径的动态规划解法
---

# 🚧 内容建设中...

## Floyd-Warshall 算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>多源最短路径问题定义</li>
      <li>矩阵动态规划的递推公式</li>
      <li>路径重建算法</li>
      <li>适用场景：稠密图、小规模全对最短路径</li>
    </ul>
  </div>
</div>

## 算法简介
**Floyd-Warshall** 用于求解所有节点对之间的最短路径。

### 复杂度
- **时间**: O(V³)
- **空间**: O(V²)

### 适用场景
- 节点数较少（< 1000）的稠密图
- 需要查询任意两点间最短路径

---

**相关文档：**
- [Dijkstra 算法](/algorithms/shortest-path/dijkstra/index/) （单源）
- [Bellman-Ford](/algorithms/shortest-path/bellman-ford/index/) （支持负权）
