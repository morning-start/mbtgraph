---
title: Dijkstra 算法
description: 经典的非负权图单源最短路径算法
---

# 🚧 内容建设中...

## Dijkstra 算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 6 月下旬（优先级：P1）</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>📊 贪心思想图解（逐步选择最近节点）</li>
      <li>🧩 优先队列优化的实现细节</li>
      <li>💻 MoonBit 完整代码示例（含详细注释）</li>
      <li>📈 时间复杂度分析：O((V+E)log V)</li>
      <li>🎯 实际应用：地图导航、网络路由</li>
      <li>🆚 与 Bellman-Ford 的对比</li>
      <li>🧪 练习题：4 道巩固题目</li>
    </ul>
    <p>Dijkstra 是最经典实用的最短路径算法，<strong>强烈推荐学习</strong>！</p>
  </div>
</div>

## 算法简介

**Dijkstra 算法** 由荷兰计算机科学家 Edsger W. Dijkstra 于 1956 年提出，是解决**带权非负图的单源最短路径问题**的经典算法。

### 核心思想
- **贪心策略**：每次选择距离起点最近的未访问节点
- **松弛操作（Relaxation）**：通过新发现的更短路径更新邻居的距离
- **优先队列优化**：使用最小堆高效获取最近的节点

### 前提条件
- ⚠️ 所有边的权重必须为 **非负数**
- 如果存在负权边，需使用 Bellman-Ford 算法

### 复杂度分析

| 实现方式 | 时间复杂度 | 空间复杂度 |
|---------|-----------|-----------|
| 数组实现 | O(V²) | O(V) |
| 二叉堆 | O((V+E)log V) | O(V) |
| 斐波那契堆 | O(V log V + E) | O(V) |

### 适用场景
1. **地图导航** - GPS 导航系统
2. **网络路由** - IP 包转发路径选择
3. **社交网络** - 最短关系链
4. **机器人路径规划**

---

**相关文档：**
- [Bellman-Ford 算法](/algorithms/shortest-path/bellman-ford/index/) （支持负权边）
- [A* 启发式搜索](/algorithms/shortest-path/a-star/index/) （更快但近似最优）
- [Floyd-Warshall](/algorithms/shortest-path/floyd-warshall/index/) （多源最短路径）
