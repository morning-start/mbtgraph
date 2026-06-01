---
title: A* 启发式搜索
description: 结合启发信息的智能寻路算法
---

# 🚧 内容建设中...

## A* 启发式搜索

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月下旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>启发函数设计原则</li>
      <li>可采纳性与一致性条件</li>
      <li>游戏寻路应用实例</li>
      <li>与 Dijkstra 的性能对比</li>
    </ul>
  </div>
</div>

## 算法简介
**A* (A-Star)** 是一种启发式搜索算法，结合了 Dijkstra 和贪心最佳优先搜索的优点。

### 核心公式
```
f(n) = g(n) + h(n)
```
- `g(n)`: 从起点到节点 n 的实际代价
- `h(n)`: 从节点 n 到终点的估计代价（启发函数）
- `f(n)`: 总估计代价

### 应用场景
- 游戏开发中的 NPC 寻路
- 机器人路径规划
- 地图导航（带地理信息）

---

**相关文档：**
- [Dijkstra 算法](/algorithms/shortest-path/dijkstra/index/) （无启发）
- [实战案例 - 推荐系统](/use-cases/recommendation-system/collaborative-filtering)
