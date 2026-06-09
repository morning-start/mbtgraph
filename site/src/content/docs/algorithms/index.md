---
title: 算法总览
description: mbtgraph 完整算法目录与学习路线图
---

# 算法原理与实践

欢迎来到 mbtgraph 的核心部分——**算法教程**！本模块将深入讲解各种经典图算法的原理、实现和应用。

## 算法分类

mbtgraph 提供了约 **49 个图算法**，覆盖以下主要类别：

### 1. 图遍历算法 🌳
- **广度优先搜索 (BFS)** - 层级遍历，最短路径（无权图）
- **深度优先搜索 (DFS)** - 递归探索，拓扑排序、环检测
- **高级技巧** - 双向 BFS、迭代加深等优化方法

### 2. 最短路径算法 🗺️
- **Dijkstra** - 非负权图的单源最短路径
- **Bellman-Ford** - 支持负权边的动态规划方法
- **Floyd-Warshall** - 多源最短路径的全对算法
- **A* 启发式搜索** - 结合启发信息的智能寻路

### 3. 最小生成树 (MST) 🌲
- **Kruskal** - 基于并查集的贪心算法
- **Prim** - 基于切分定理的优先队列算法

### 4. 连通性算法 🔗
- **连通分量 (CC)** - 无向图的连通区域划分
- **强连通分量 (SCC)** - 有向图的强连通区域
  - Tarjan 算法 - 单次 DFS
  - Kosaraju 算法 - 两次 DFS
- **割点与桥** - 关键节点和边的识别

### 5. 网络流算法 💧
- **流网络基础** - 容量、流量、残差图
- **最大流问题**
  - Ford-Fulkerson 方法
  - Edmonds-Karp 实现（BFS 增广）
  - Dinic 优化算法（层次图 + 阻塞流）
- **最小费用最大流** - 成本优化的流量分配

### 6. 图匹配算法 🔗
- **二分图匹配**
  - 匈牙利算法 (Hungarian)
  - Hopcroft-Karp 优化
- **一般图匹配** - Edmonds 花朵算法

### 7. 图着色算法 🎨
- 贪心着色
- DSATUR 算法
- 精确着色（回溯法）

### 8. 社区检测算法 👥
- Louvain 算法
- 标签传播算法
- Leiden 算法改进

### 9. 中心性指标 📊
- 度中心性
- 介数中心性
- 接近中心性
- 特征向量中心性 / PageRank

### 10. 其他重要算法 ⭐
- 欧拉路径与回路
- 哈密顿路径与 TSP
- 团检测 (Bron-Kerbosch)
- 链接预测

## 学习路线推荐

### 新手路线（从零到一）

```
第 1 步：掌握基础遍历
├─ BFS 教程 → 理解层级遍历思想
└─ DFS 教程 → 掌握递归与栈的应用

第 2 步：学习最短路径
├─ Dijkstra → 贪心 + 优先队列
└─ Bellman-Ford → 动态规划基础

第 3 步：进阶算法
├─ MST (Kruskal/Prim) → 并查集应用
├─ 连通性 (Tarjan/Kosaraju) → 强连通分量
└─ 网络流 (Edmonds-Karp/Dinic) → 最大流

第 4 步：高级主题
├─ 匹配、着色、社区检测
├─ 中心性分析
└─ TSP、团检测等 NP-Hard 问题
```

### 应用导向路线

根据你的实际需求选择：

| 应用场景 | 推荐学习的算法 |
|---------|--------------|
| **社交网络** | BFS/DFS, 中心性, 社区检测 |
| **地图导航** | Dijkstra, A*, 最短路径 |
| **推荐系统** | 二分图匹配, PageRank |
| **物流优化** | MST, 网络流, TSP |
| **知识图谱** | 连通分量, 链接预测 |
| **网络安全** | 割点桥, 强连通分量 |

## 算法模式说明

mbtgraph 的算法实现采用**双轨制**设计：

### 模式 A：Trait 泛型函数（大多数算法）

```moonbit
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult {
  // 可用于任何实现了 GraphReadable 的存储
}
```

**优点**：
- 算法与存储完全解耦
- 用户自由选择存储结构
- 代码复用性高

**适用算法**：BFS、DFS、Dijkstra、Prim、Kruskal 等

### 模式 B：独立类型（特殊语义算法）

```moonbit
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)
let result = edmonds_karp(net, 0, 5)
```

**特点**：
- 自包含的数据结构
- 特殊语义（容量、流量矩阵）
- 更直观的 API 设计

**适用算法**：网络流、匹配等需要额外状态的算法

## 复杂度速查表

| 算法 | 时间复杂度 | 空间复杂度 | 适用场景 |
|------|-----------|-----------|---------|
| BFS | O(V+E) | O(V) | 无权最短路径 |
| DFS | O(V+E) | O(V) | 拓扑排序、环检测 |
| Dijkstra | O((V+E)log V) | O(V) | 非负权最短路径 |
| Bellman-Ford | O(VE) | O(V) | 负权边检测 |
| Floyd-Warshall | O(V³) | O(V²) | 多源最短路径 |
| Kruskal | O(E log E) | O(V) | 稀疏图 MST |
| Prim | O((V+E)log V) | O(V) | 稠密图 MST |
| Edmonds-Karp | O(VE²) | O(V²) | 最大流入门 |
| Dinic | O(E√V) | O(V²) | 高效最大流 |

## 代码示例规范

每个算法教程都包含以下标准结构：

```markdown
## 算法名称

### 📊 算法原理
[图文结合解释核心思想]

### 🧩 核心思想
[关键步骤分解]

### 💻 代码实现
[MoonBit 代码 + 详细注释]

### 📈 复杂度分析
[时间/空间复杂度 + 对比表格]

### 🎯 实际应用
[真实场景案例]

### 🧪 练习题
[2-3 道巩固题]
```

## 开始学习

选择你感兴趣的算法类别，或按照推荐路线循序渐进：

- 🌳 [从图遍历开始](/algorithms/traversal/bfs/index/) - 最基础的算法
- 🗺️ [直接学最短路径](/algorithms/shortest-path/dijkstra/index/) - 经典实用算法
- 📖 [查看完整目录](#算法分类) - 浏览所有可用算法

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">💡</span>
    <p class="callout-title">学习建议</p>
  </div>
  <div class="callout-content">
    <ul>
      <li>每个算法教程都包含<strong>可运行的代码示例</strong>，建议动手实践</li>
      <li>遇到不理解的概念，先回到 <a href="/core-concepts/index/">基础教程</a> 补充知识</li>
      <li>完成练习题有助于巩固理解</li>
      <li>想看实际应用？前往 <a href="/use-cases/social-network/build-graph/">实战案例</a></li>
    </ul>
  </div>
</div>
