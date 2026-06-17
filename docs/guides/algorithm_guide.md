# 算法选择指南

> 何时用什么算法？快速选择你的图算法。

---

## 决策流程图

```
你的问题是什么？
│
├─ 最短路径？
│  ├─ 非负权图 → Dijkstra
│  ├─ 有负权边 → Bellman-Ford / SPFA
│  ├─ 全源最短路径 → Floyd-Warshall (稠密) / Johnson (稀疏)
│  └─ 启发式搜索 → A*
│
├─ 最小生成树？
│  ├─ 稀疏图 → Kruskal
│  └─ 稠密图 → Prim
│
├─ 连通性？
│  ├─ 无向图 → Connected Components
│  ├─ 有向图 SCC → Tarjan / Kosaraju
│  └─ 割点/桥 → Cutpoints
│
├─ 网络流？
│  ├─ 最大流 → Dinic (通用) / Edmonds-Karp (简单)
│  ├─ 最小费用流 → Min-Cost Max-Flow
│  └─ 最小割 → Stoer-Wagner
│
├─ 匹配？
│  ├─ 二部图 → Hopcroft-Karp
│  ├─ 一般图 → Edmonds Blossom
│  └─ 加权二部图 → Hungarian (KM)
│
├─ 着色？
│  ├─ 快速近似 → Greedy / Welsh-Powell
│  ├─ 更优解 → DSATUR
│  └─ 精确色数 → Exact Chromatic Number
│
├─ 社区检测？
│  ├─ 通用 → Louvain / Leiden
│  ├─ 快速 → Label Propagation
│  └─ 指定数量 → Spectral Clustering
│
└─ 其他？
   ├─ 中心性 → Centrality (8种)
   ├─ PageRank → PageRank
   └─ 图识别 → Recognition
```

---

## 按场景选择

### 导航与路径规划

| 场景 | 算法 | 复杂度 | 说明 |
|------|------|--------|------|
| 无权图最短路径 | BFS | O(V+E) | 最快 |
| 非负权图 | Dijkstra | O((V+E)logV) | 标准选择 |
| 有负权图 | Bellman-Ford | O(VE) | 支持负权 |
| 频繁查询 | Floyd-Warshall | O(V³) | 预计算后 O(1) 查询 |
| 启发式搜索 | A* | O(E) | 需要启发函数 |

### 网络分析

| 场景 | 算法 | 复杂度 | 说明 |
|------|------|--------|------|
| 瓶颈检测 | Min-Cut | O(V³) | Stoer-Wagner |
| 流量优化 | Max-Flow | O(V²E) | Dinic |
| 成本优化 | Min-Cost Flow | O(V²E) | 费用流 |
| 资源分配 | Matching | O(E√V) | Hopcroft-Karp |

### 社交网络

| 场景 | 算法 | 复杂度 | 说明 |
|------|------|--------|------|
| 影响力排序 | PageRank | O(kE) | 迭代收敛 |
| 关键人物 | Betweenness | O(VE) | 桥梁节点 |
| 小圈子 | Community | O(nlogn) | Louvain |
| 信息传播 | BFS/DFS | O(V+E) | 遍历 |

### 生物信息

| 场景 | 算法 | 复杂度 | 说明 |
|------|------|--------|------|
| 蛋白质交互 | Community | O(nlogn) | 模块检测 |
| 基因调控 | DAG/Topo Sort | O(V+E) | 依赖分析 |
| 结构匹配 | Graph Isomorphism | 指数 | 识别算法 |

---

## 复杂度速查表

| 算法 | 时间复杂度 | 空间复杂度 | 适用场景 |
|------|-----------|-----------|---------|
| BFS | O(V+E) | O(V) | 无权图最短路径 |
| DFS | O(V+E) | O(V) | 遍历/环检测 |
| Dijkstra | O((V+E)logV) | O(V) | 非负权最短路径 |
| Bellman-Ford | O(VE) | O(V) | 负权最短路径 |
| Floyd-Warshall | O(V³) | O(V²) | 全源最短路径 |
| Kruskal | O(ElogE) | O(V) | 稀疏图 MST |
| Prim | O((V+E)logV) | O(V) | 稠密图 MST |
| Dinic | O(V²E) | O(V+E) | 最大流 |
| Tarjan SCC | O(V+E) | O(V) | 强连通分量 |
| Louvain | O(nlogn) | O(V+E) | 社区检测 |
| PageRank | O(kE) | O(V) | 节点重要性 |

---

## 代码示例

### 最短路径选择

```moonbit
// 非负权图：Dijkstra
let sp = @shortest_path.dijkstra(g, source)

// 有负权图：Bellman-Ford
let sp = @shortest_path.bellman_ford(g, source)

// 全源：Floyd-Warshall
let fw = @shortest_path.floyd_warshall(g)
let dist = fw.distance(node_a, node_b)

// A* 启发式
let path = @shortest_path.a_star(g, start, goal, heuristic_fn)
```

### 连通性选择

```moonbit
// 无向图连通分量
let cc = @connectivity.connected_components(g)

// 有向图 SCC
let scc = @connectivity.tarjan_scc(directed_g)

// 割点检测
let cut = @cutpoints.find_articulation_points_undirected(g)
```

### 匹配选择

```moonbit
// 二部图匹配
let m = @matching.hopcroft_karp(g, left_nodes, right_nodes)

// 一般图匹配
let m = @matching.edmonds_maximum_matching(g)

// 加权匹配
let km = @matching.kuhn_munkres(weight_matrix)
```

---

## 性能提示

1. **选对存储**: 稀疏图用 AdjList，稠密图用 Matrix
2. **预计算**: Floyd-Warshall 预计算后 O(1) 查询
3. **批量操作**: CSR 支持 `batch_neighbors` 批量查询
4. **避免重复**: PageRank/中心性结果可缓存复用
