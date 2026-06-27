---
title: 算法总览
description: mbtgraph 完整算法目录与学习路线图
---

# 算法原理与实践

欢迎来到 mbtgraph 的核心部分——**算法教程**！本模块深入讲解各种经典图算法的原理、实现和应用。

mbtgraph 提供了约 **49 个图算法**，覆盖以下主要类别。每个算法页面都包含：概念讲解、交互式动画演示、MoonBit 核心实现代码和实际应用场景。

## 算法分类

### 1. 图遍历算法 🌳
- **[广度优先搜索 (BFS)](/algorithms/traversal/bfs/)** — 层级遍历，无权图最短路径
- **[深度优先搜索 (DFS)](/algorithms/traversal/dfs/)** — 递归探索，拓扑排序、环检测
- **[高级遍历技巧](/algorithms/traversal/advanced/)** — 双向 BFS、迭代加深等优化

### 2. 最短路径算法 🗺️
- **[Dijkstra](/algorithms/shortest-path/dijkstra/)** — 非负权图单源最短路径
- **[Bellman-Ford](/algorithms/shortest-path/bellman-ford/)** — 支持负权边，可检测负环
- **[Floyd-Warshall](/algorithms/shortest-path/floyd-warshall/)** — 全源最短路径（DP 表，O(V³)）
- **[A\* 启发式搜索](/algorithms/shortest-path/a-star/)** — 结合启发信息的智能寻路

### 3. 最小生成树 🌲
- **[Kruskal](/algorithms/mst/kruskal/)** — 边排序 + 并查集，稀疏图优先
- **[Prim](/algorithms/mst/prim/)** — 从起点扩展，稠密图优先
- **[Kruskal vs Prim 对比](/algorithms/mst/kruskal-prim/)** — 两种 MST 算法详解

### 4. 连通性算法 🔗
- **[连通分量 (CC)](/algorithms/connectivity/connected-components/)** — 无向图连通区域划分
- **[割点与桥](/algorithms/connectivity/articulation-points/)** — Tarjan 算法检测关键节点和边
- **[Tarjan 强连通分量 (SCC)](/algorithms/connectivity/scc/tarjan/)** — 单次 DFS
- **[Kosaraju 强连通分量 (SCC)](/algorithms/connectivity/scc/kosaraju/)** — 两次 DFS（图转置）

### 5. 网络流算法 💧
- **[流网络基础](/algorithms/flow/basics/)** — 容量、流量、残差图基本概念
- **[Ford-Fulkerson 方法](/algorithms/flow/max-flow/ford-fulkerson/)** — 增广路通用框架
- **[Edmonds-Karp](/algorithms/flow/max-flow/edmonds-karp/)** — BFS 增广路，O(VE²)
- **[Dinic](/algorithms/flow/max-flow/dinic/)** — 层次图 + 阻塞流，O(E√V)
- **[最小费用最大流](/algorithms/flow/min-cost-max-flow/)** — 成本优化的流量分配

### 6. 图匹配算法 🔗
- **[匈牙利算法 (Hungarian)](/algorithms/matching/bipartite/hungarian/)** — DFS 增广，O(VE)
- **[Hopcroft-Karp](/algorithms/matching/bipartite/hopcroft-karp/)** — 二分图匹配加速，O(E√V)
- **[Edmonds 一般图匹配](/algorithms/matching/general/edmonds/)** — 开花算法处理奇环

### 7. 图着色算法 🎨
- **[贪心着色 & DSATUR](/algorithms/coloring/)** — 经典近似算法

### 8. 社区检测算法 👥
- **[Louvain 算法](/algorithms/community/)** — 模块度贪心优化

### 9. 中心性指标 📊
- **[度中心性、介数中心性等](/algorithms/centrality/)** — 节点重要性量化

### 10. 其他重要算法 ⭐
- **[欧拉路径与回路](/algorithms/euler/)** — Hierholzer 算法
- **[哈密顿路径 & TSP](/algorithms/other/)** — NP-Hard 问题经典解法
- **[图生成器 & 图算子](/algorithms/other/)** — 测试与基准工具

## 学习路线推荐

| 阶段 | 算法 | 目标 |
|------|------|------|
| **基础** | BFS → DFS → Dijkstra | 掌握图遍历与最短路径 |
| **进阶** | MST → 连通分量 → 网络流 | 理解图结构分析 |
| **高级** | 匹配 → 着色 → 社区检测 | 复杂图分析场景 |

> 💡 **建议**：每个算法页面都包含交互式动画演示，建议边看边动手操作，直观理解执行过程后再阅读 MoonBit 代码实现。
