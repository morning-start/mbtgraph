---
title: 各算法模块 API
description: 图算法库的所有算法接口文档
---

# 🚧 内容建设中...

## 各算法模块 API

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 10 月下旬（可从源码自动生成）</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>遍历算法 (BFS/DFS) API</li>
      <li>最短路径算法 API</li>
      <li>MST 算法 API</li>
      <li>连通性算法 API</li>
      <li>网络流算法 API</li>
      <li>匹配算法 API</li>
      <li>着色、社区检测、中心性等 API</li>
    </ul>
    <p>在此期间，可以参考 <a href="/algorithms/index/">算法教程</a> 中的使用示例。</p>
  </div>
</div>

## 算法模块列表

```
lib/algo/
├── traversal/          # BFS, DFS, 拓扑排序等
├── shortest_path/      # Dijkstra, Bellman-Ford, Floyd, A*
├── mst/                # Kruskal, Prim
├── connectivity/       # CC, Tarjan SCC, Kosaraju SCC, 割点桥
├── flow/               # Edmonds-Karp, Dinic, 最小费用流
├── matching/           # Hungarian, Hopcroft-Karp, Edmonds
├── euler/              # Hierholzer (欧拉路径)
├── cutpoints/          # Tarjan (割点桥)
├── coloring/            # Greedy, DSATUR, Exact
├── clique/             # Bron-Kerbosch
├── hamiltonian/         # TSP
├── pagerank/            # PageRank
├── centrality/          # 各种中心性指标
└── community/           # Louvain, 标签传播
```

### 函数签名示例

```moonbit
// 遍历
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult
pub fn[G : @core.GraphReadable] dfs(graph : G, start : NodeId) -> DfsResult

// 最短路径
pub fn[G : @core.GraphReadable] dijkstra(graph : G, source : NodeId) -> ShortestPathResult
pub fn bellman_ford(graph : FlowNetwork, source : Int) -> BellmanFordResult

// MST
pub fn kruskal(graph : G) -> MstResult  // 需要 EdgeIterable
pub fn prim(graph : G, start : NodeId) -> MstResult
```

---

**相关文档：**
- [Core 模块接口](/api/core/)
- [Storage 模块接口](/api/storage/)
- [IO 模块接口](/api/io/)
