---
title: 其他重要算法
description: 欧拉路径、哈密顿路径、团检测等高级算法
---

# 🚧 内容建设中...

## 其他重要算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 9 月下旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>欧拉路径与回路（Hierholzer 算法）</li>
      <li>哈密顿路径与 TSP（旅行商问题）</li>
      <li>团检测（Bron-Kerbosch 算法）</li>
      <li>链接预测算法</li>
    </ul>
  </div>
</div>

## 算法列表

### 1. 欧拉路径与回路 (Eulerian Path/Circuit)

**定义**：
- **欧拉回路**：经过每条边**恰好一次**并回到起点的路径
- **欧拉路径**：经过每条边**恰好一次**的路径（不要求回到起点）

**存在条件**：
- 回路：所有节点度数为偶数
- 路径：恰好 0 或 2 个奇度节点

**算法**: Hierholzer - O(E) 时间复杂度

### 2. 哈密顿路径与 TSP

**定义**：
- **哈密顿路径/回路**：访问每个节点**恰好一次**
- **TSP（旅行商问题）**：找到访问所有城市并返回起点的最短路径

**复杂度**: NP-Hard
- 精确解：回溯法 O(n!)，Held-Karp O(2ⁿn²)
- 近似解：最近邻、遗传算法等

### 3. 团检测 (Clique Detection)

**定义**：
- **团（Clique）**：完全子图（任意两点间都有边）
- **最大团问题**：找到节点数最多的团

**算法**: Bron-Kerbosch - O(3^(n/3)) 时间

### 4. 链接预测 (Link Prediction)

**目标**：预测未来可能形成的边
- 基于：共同邻居、路径长度、随机游走等
- 应用：社交网络好友推荐、知识图谱补全

---

**相关文档：**
- [BFS/DFS](/algorithms/traversal/bfs/index/) （基础遍历）
- [实战案例 - 社交网络](/use-cases/social-network/build-graph)
