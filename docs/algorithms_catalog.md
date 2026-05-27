# 📚 完整图算法目录

> **用途**: 记录所有图论算法的分类、名称、简介及当前实现状态
> **最后更新**: 2026-05-26 | **当前实现**: ~43 个算法 / ~701 tests
> **对标参考**: NetworkX (Python), JGraphT (Java), Boost Graph (C++), igraph (R/Python), Neo4j GDS

---

## 图例说明

| 标记 | 含义 | 数量 |
|:----:|------|:----:|
| ✅ | 已实现（完整实现 + 测试） | ~43 |
| 🟡 | 部分实现（基础功能可用） | ~3 |
| ⬜ | 未实现（计划中） | ~40+ |
| 🔲 | 暂不考虑（v1.0 后） | ~20 |

---

## 目录结构总览

```
1.  图遍历 (Traversal)
2.  最短路径 (Shortest Paths)
3.  最小生成树 (Minimum Spanning Trees)
4.  网络流 (Network Flow)
5.  图匹配 (Graph Matching)
6.  连通性 (Connectivity)
7.  图着色 (Graph Coloring)
8.  团与独立集 (Clique & Independent Set)
9.  欧拉图与哈密顿图 (Eulerian & Hamiltonian)
10. 图同构与子树 (Graph Isomorphism & Subgraph)
11. 网络分析：中心性 (Centrality)
12. 网络分析：社区检测 (Community Detection)
13. 网络分析：PageRank 与排序 (Ranking)
14. 网络分析：相似度与链接预测 (Similarity & Link Prediction)
15. 割点、桥与割集 (Cut Points, Bridges & Cuts)
16. 特殊图论算法 (Specialized)
17. 图生成与随机模型 (Graph Generation)
18. I/O 与序列化 (Input/Output)
```

---

## 1. 图遍历 (Traversal) ✅ 4/7

> 基础图搜索算法，是复杂算法的基础。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 1 | **广度优先搜索 (BFS)** | 队列实现的层序遍历，无权图最短路径 | ✅ | O(V+E) | `traversal/bfs.mbt` |
| 2 | **深度优先搜索 (DFS)** | 栈/递归实现的深度遍历，强连通分量基础 | ✅ | O(V+E) | `traversal/dfs.mbt` |
| 3 | **双向 BFS** | 从起点终点同时 BFS，层交替扩展相遇停止 | ✅ | O(b^(d/2)) | `traversal/bidirectional_bfs.mbt` |
| 4 | **拓扑排序 (Topological Sort)** | DAG 节点线性排序，Kahn 算法 | ✅ | O(V+E) | `traversal/topological_sort.mbt` |
| 5 | **环检测 (Cycle Detection)** | 有向图/无向图环检测，DFS 回溯边 | ✅ | O(V+E) | `traversal/cycle_detection.mbt` |
| 6 | **字典序 BFS (Lexicographic BFS)** | 按邻居标签顺序的 BFS，用于弦图检测 | ⬜ | O(V+E) | — |
| 7 | **迭代深化深度优先 (IDDFS)** | 结合 BFS 完备性和 DFS 空间效率的搜索 | ⬜ | O(b^d) | — |

---

## 2. 最短路径 (Shortest Paths) ✅ 4/8

> 在加权/无权图中寻找节点间的最短路径。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 8 | **Dijkstra 算法** | 单源非负权最短路径，优先队列实现 | ✅ | O((V+E)logV) | `shortest_path/dijkstra.mbt` |
| 9 | **Bellman-Ford 算法** | 单源负权边最短路径，可检测负权环 | ✅ | O(VE) | `shortest_path/bellman_ford.mbt` |
| 10 | **Floyd-Warshall 算法** | 全对最短路径，动态规划 | ✅ | O(V³) | `shortest_path/floyd_warshall.mbt` |
| 11 | **A\* 搜索** | 启发式搜索，f(n)=g(n)+h(n) | ✅ | O(b^d) | `shortest_path/a_star.mbt` |
| 12 | **Johnson 算法** | 全对最短路径，Bellman-Ford + Dijkstra | ⬜ | O(V²logV + VE) | — |
| 13 | **双向 Dijkstra** | 从起点终点同时 Dijkstra | ⬜ | O((V+E)logV) | — |
| 14 | **K 最短路径 (Yen's)** | 找出前 K 条最短路径 | ⬜ | O(KV(E+VlogV)) | — |
| 15 | **SPFA 算法** | Bellman-Ford 队列优化（负权检测） | ⬜ | O(kE) 均摊 | — |

---

## 3. 最小生成树 (Minimum Spanning Trees) ✅ 2/3

> 找到连接所有节点的最小权重子图。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 16 | **Kruskal 算法** | 边贪心 + 并查集，适用于稀疏图 | ✅ | O(ElogE) | `mst/kruskal.mbt` |
| 17 | **Prim 算法** | 点贪心，维护到树的最短距离 | ✅ | O((V+E)logV) | `mst/prim.mbt` |
| 18 | **Borůvka 算法** | 并行友好的 MST 算法，每轮选择每个分量的最小出边 | ⬜ | O(ElogV) | — |
| 19 | **次小生成树** | 在 MST 基础上找第二优生成树 | 🔲 | O(V²) | — |

---

## 4. 网络流 (Network Flow) ✅ 3/5

> 在网络中最大化从源点到汇点的流量。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 20 | **Edmonds-Karp 算法** | BFS 找增广路的最大流算法 | ✅ | O(VE²) | `flow/edmonds_karp.mbt` |
| 21 | **Dinic 算法** | 分层图 + 阻塞流，实际性能最优 | ✅ | O(V²E) | `flow/dinic.mbt` |
| 22 | **最小费用最大流** | SSP + Bellman-Ford，每次找最短费用路径 | ✅ | O(F·E·V) | `flow/min_cost_max_flow.mbt` |
| 23 | **Push-Relabel (预流推进)** | 最高标号预流推进，理论最优 | ⬜ | O(V²√E) | — |
| 24 | **容量缩放 (Capacity Scaling)** | 按容量位缩放增广，适用于大容量 | ⬜ | O(E²logU) | — |
| 25 | **最小割 (Global Min-Cut)** | Stoer-Wagner 算法，无向图全局最小割 | ⬜ | O(VE + V²logV) | — |
| 26 | **多商品流 (Multicommodity Flow)** | 多种商品同时流动（NP-Hard 近似） | 🔲 | 近似 O(·) | — |

---

## 5. 图匹配 (Graph Matching) ✅ 3/6

> 在图中找最大基数匹配或最大权匹配。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 27 | **匈牙利算法 (Hungarian)** | 二分图最大/完美匹配 | ✅ | O(VE) | `matching/hungarian.mbt` |
| 28 | **Hopcroft-Karp 算法** | 二分图最大匹配，BFS+DFS 交替 | ✅ | O(E√V) | `matching/hopcroft_karp.mbt` |
| 29 | **Edmonds 一般图匹配 (Blossom)** | 带奇环收缩的一般图最大匹配 | ✅ | O(V³) | `matching/edmonds_matching.mbt` |
| 30 | **KM 算法 (Kuhn-Munkres)** | 二分图最大权完美匹配 | ⬜ | O(V³) | — |
| 31 | **Edmonds 一般图最大权匹配** | 加权 Blossom 算法（Blossom V） | 🔲 | O(V³) | — |
| 32 | **稳定婚姻 (Stable Marriage)** | Gale-Shapley 算法，稳定匹配 | 🔲 | O(V²) | — |

---

## 6. 连通性 (Connectivity) ✅ 3/5

> 检测图的连通分量、强连通分量、双连通分量。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 33 | **连通分量 (Connected Components)** | 无向图连通分量，DFS/BFS 遍历 | ✅ | O(V+E) | `connectivity/cc.mbt` |
| 34 | **Tarjan 强连通分量 (SCC)** | 基于 DFN/Low 的单遍 DFS 算法 | ✅ | O(V+E) | `connectivity/tarjan_scc.mbt` |
| 35 | **Kosaraju 强连通分量 (SCC)** | 两次 DFS，原图 + 转置图 | ✅ | O(V+E) | `connectivity/kosaraju_scc.mbt` |
| 36 | **双连通分量 (BCC)** | 割点分离的极大 2-连通子图 | ⬜ | O(V+E) | — |
| 37 | **Gabow 算法** | 更高效的 SCC 算法（空间优化） | ⬜ | O(V+E) | — |

---

## 7. 图着色 (Graph Coloring) ✅ 4/5

> 为图节点/边着色，使得相邻元素颜色不同。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 38 | **贪心着色** | 按某种顶点次序贪心地使用最小颜色 | ✅ | O(V+E) | `coloring/greedy_coloring.mbt` |
| 39 | **Welsh-Powell 算法** | 按度数降序贪心着色 | ✅ | O(V²) | `coloring/welsh_powell.mbt` |
| 40 | **DSATUR 算法** | 饱和度优先的贪心着色 | ✅ | O(V³) | `coloring/dsatur.mbt` |
| 41 | **精确着色 (Exact Coloring)** | 分支定界精确算法，复杂度高 | ✅ | O(exp) | `coloring/exact_coloring.mbt` |
| 42 | **边着色 (Edge Coloring)** | Vizing 定理，为边分配颜色 | ⬜ | O(V·E) | — |
| 43 | **弦图着色 (Chordal Coloring)** | 弦图的完美消除序着色 | 🔲 | O(V+E) | — |

---

## 8. 团与独立集 (Clique & Independent Set) ✅ 1/3

> 在图中寻找完全子图（团）和独立集。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 44 | **Bron-Kerbosch 算法** | 无枢轴/有枢轴版本枚举所有极大团 | ✅ | O(3^(V/3)) | `clique/bron_kerbosch.mbt` |
| 45 | **最大团 (Maximum Clique)** | 分支定界查找最大团 | ⬜ | O(exp) | — |
| 46 | **最大独立集 (Maximum IS)** | 补图最大团等价转换 | ⬜ | O(exp) | — |

---

## 9. 欧拉图与哈密顿图 (Eulerian & Hamiltonian) ✅ 2/3

> 欧拉路径（一笔画问题）和哈密顿路径（旅行商问题）。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 47 | **Hierholzer 算法** | 有向/无向欧拉回路和路径 | ✅ | O(E) | `euler/hierholzer.mbt` |
| 48 | **哈密顿回路 (回溯)** | 回溯搜索哈密顿回路 | ✅ | O(exp) | `hamiltonian/backtrack.mbt` |
| 49 | **最近邻 TSP** | 旅行商问题近似解，最近邻贪心 | ✅ | O(V²) | `hamiltonian/nearest_neighbor.mbt` |
| 50 | **Held-Karp 算法** | TSP 精确解，DP+位掩码 | ✅ | O(V²·2^V) | `hamiltonian/held_karp.mbt` |
| 51 | **中国邮路问题 (Chinese Postman)** | 在图中找遍历所有边的最短闭路 | ⬜ | O(V³) | — |
| 52 | **2-opt 局部搜索 TSP** | TSP 优化，2-边交换局部搜索 | 🔲 | O(V²) | — |

---

## 10. 图同构与子树 (Graph Isomorphism & Subgraph) ⬜ 0/4

> 判断两个图是否同构，寻找最大公共子图。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 53 | **VF2 算法** | 图同构/子图同构检测，回溯+剪枝 | ⬜ | O(V!·V) | — |
| 54 | **树同构 (AHU 算法)** | 有根树/无根树同构检测 | ⬜ | O(V) | — |
| 55 | **图编辑距离 (GED)** | 通过编辑操作把一个图变为另一个的最小代价 | 🔲 | O(exp) | — |
| 56 | **最大公共子图 (MCS)** | 寻找两个图的最大公共子结构 | 🔲 | O(exp) | — |

---

## 11. 网络分析：中心性 (Centrality) ✅ 4/5

> 度量节点在网络中的重要性。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 57 | **度中心性 (Degree Centrality)** | 节点度数作为重要性 | ✅ | O(V) | `centrality/degree.mbt` |
| 58 | **介数中心性 (Betweenness)** | Brandes 算法，通过节点的最短路径数 | ✅ | O(VE) | `centrality/betweenness.mbt` |
| 59 | **接近中心性 (Closeness)** | 到所有其他节点的平均距离的倒数 | ✅ | O(V(V+E)) | `centrality/closeness.mbt` |
| 60 | **特征向量中心性 (Eigenvector)** | 邻居重要性的迭代加权 | ✅ | O(V+E) | `centrality/eigenvector.mbt` |
| 61 | **Katz 中心性** | 带衰减因子的特征向量中心性扩展 | ⬜ | O(V+E) | — |
| 62 | **PageRank 中心性** | 特征向量中心性的有向图变体 | ✅ | O(V+E) | `pagerank/pagerank.mbt` |
| 63 | **Harmonic 中心性** | 接近中心性的变体，处理不连通图 | 🔲 | O(V(V+E)) | — |

---

## 12. 网络分析：社区检测 (Community Detection) ✅ 2/5

> 将网络划分为密集连接的子群组。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 64 | **Louvain 算法** | 模块度优化的贪心社区检测 | ✅ | O(V+E) | `community/louvain.mbt` |
| 65 | **标签传播 (LPA)** | 邻居标签投票的线性社区检测 | ✅ | O(V+E) | `community/label_propagation.mbt` |
| 66 | **Infomap** | 基于信息论的社区检测，流压缩 | ⬜ | O(E) | — |
| 67 | **Girvan-Newman 算法** | 基于边介数的层次聚类社区检测 | ⬜ | O(V·E·(V+E)) | — |
| 68 | **谱聚类 (Spectral Clustering)** | 基于拉普拉斯特征向量的聚类 | ⬜ | O(V³) | — |
| 69 | **K-Clique 渗流** | 重叠社区检测，允许节点属于多社区 | ⬜ | O(exp) | — |
| 70 | **随机块模型 (SBM)** | 基于概率生成模型的社区发现 | 🔲 | O(V²) | — |

---

## 13. 网络分析：相似度与链接预测 (Similarity & Link Prediction) ⬜ 0/5

> 计算节点相似度，预测可能出现的边。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 71 | **Jaccard 相似度** | 邻居集合交集/并集 | ⬜ | O(deg(u)+deg(v)) | — |
| 72 | **Adamic-Adar 系数** | 共同邻居的度倒数加权 | ⬜ | O(deg(u)+deg(v)) | — |
| 73 | **优先连接 (Preferential Attachment)** | 度乘积作为链接概率 | ⬜ | O(1) | — |
| 74 | **Katz 链接预测** | 路径计数加权求和 | ⬜ | O(V³) | — |
| 75 | **SimRank** | 基于随机游走的节点相似度 | ⬜ | O(V²) | — |
| 76 | **Node2Vec** | 基于随机游走的图嵌入（ML 方法） | 🔲 | O(V+E) | — |

---

## 14. 割点、桥与割集 (Cut Points, Bridges & Cuts) ✅ 1/2

> 删除后使图不连通的极小结构。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 77 | **Tarjan 割点 (Articulation Points)** | 基于 DFN/Low 的割点检测 | ✅ | O(V+E) | `cutpoints/tarjan_cutpoints.mbt` |
| 78 | **Tarjan 桥 (Bridges)** | 基于 DFN/Low 的桥检测 | ✅ | O(V+E) | `cutpoints/tarjan_bridges.mbt` |
| 79 | **最小 s-t 割** | 源点到汇点之间的最小权重割 | ⬜ | O(maxflow) | — |

---

## 15. 图嵌入与机器学习 (Graph Embedding & ML) ⬜ 0/5

> 将图数据转化为向量表示用于机器学习。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 80 | **DeepWalk** | 随机游走 + Skip-gram 的图嵌入 | 🔲 | O(V+E) | — |
| 81 | **Node2Vec** | 偏置随机游走，平衡 BFS/DFS 采样 | 🔲 | O(V+E) | — |
| 82 | **Laplacian Eigenmaps** | 拉普拉斯矩阵特征分解降维 | 🔲 | O(V³) | — |
| 83 | **Graph Convolution (GCN)** | 图神经网络基础消息传递 | 🔲 | O(V+E) | — |
| 84 | **GraphSAGE** | 采样+聚合的归纳式图嵌入 | 🔲 | O(V+E) | — |

---

## 16. 图生成与随机模型 (Graph Generation) ✅ 5/7

> 生成具有特定性质的图的算法。

| # | 算法 | 简介 | 状态 | 复杂度 | 实现位置 |
|---|------|------|:----:|:------:|---------|
| 85 | **Erdős–Rényi 模型** | G(n,p) 随机图 | ✅ | O(V²) | `generators/random_graph.mbt` |
| 86 | **Watts–Strogatz 小世界** | 高聚类系数的网络模型 | ✅ | O(V+E) | `generators/small_world.mbt` |
| 87 | **Barabási–Albert 优先连接** | 无标度网络幂律度分布 | ✅ | O(V+E) | `generators/scale_free.mbt` |
| 88 | **配置模型 (Configuration Model)** | 指定度序列的随机图生成 | ✅ | O(V+E) | `generators/configuration.mbt` |
| 89 | **正则图生成 (Regular Graph)** | 每个节点度数相同的图 | ✅ | O(V·deg) | `generators/regular.mbt` |
| 90 | **格点图 (Grid Graph)** | 二维/三维网格图 | ⬜ | O(V) | — |
| 91 | **树生成 (Random Tree)** | 随机树生成（Prüfer 序列等） | ⬜ | O(V) | — |
| 92 | **Kronecker 图** | 递归矩阵乘法的图生成（大规模） | 🔲 | O(V·logV) | — |

---

## 17. I/O 与序列化 (Input/Output) ✅ 2/4

> 将图写入/读取为标准格式，连接外部工具链。

| # | 格式/工具 | 简介 | 状态 | 实现位置 |
|---|----------|------|:----:|---------|
| 93 | **DOT 格式** | Graphviz 标准格式，支持 digraph/graph | ✅ | `io/dot.mbt` |
| 94 | **JSON 格式** | 自定义 JSON Schema 序列化 | ✅ | `io/json_serializer.mbt` |
| 95 | **GEXF 格式** | Gephi 标准 XML 格式 | ⬜ | — |
| 96 | **GraphML 格式** | XML 图标记语言，通用图表示 | ⬜ | — |
| 97 | **CSV 边列表** | 简单逗号分隔的边列表 | 🔲 | — |
| 98 | **GML 格式** | Graph Modelling Language（Ledat 格式） | 🔲 | — |

---

## 18. 图统计与摘要 (Graph Statistics) ✅ 3/3

> 计算图的基本统计量，用于分析和了解图的总体特征。

| # | 统计量 | 简介 | 状态 | 实现位置 |
|---|-------|------|:----:|---------|
| 99 | **基本统计** | 节点/边数、密度、有向标志、自环数 | ✅ | `io/graph_stats.mbt` |
| 100 | **度分布** | 最小/最大度、直方图 | ✅ | `io/graph_stats.mbt` |
| 101 | **连通性统计** | 连通分量数、最大分量大小 | ✅ | `io/graph_stats.mbt` |
| 102 | **直径与半径** | 图的最大/最小偏心率 | ⬜ | — |
| 103 | **聚类系数 (Clustering Coefficient)** | 节点邻域三角密度 | ⬜ | — |
| 104 | **度相关性 (Assortativity)** | 度-度相关性（同配性） | ⬜ | — |
| 105 | **互惠性 (Reciprocity)** | 有向图中双向边比例 | 🔲 | — |

---

## 📊 汇总统计

| 大类 | 已实现 | 未实现 | 暂不考虑 | 总数 |
|:----|:-----:|:------:|:--------:|:----:|
| 1. 图遍历 | 4 | 2 | 0 | 6 |
| 2. 最短路径 | 4 | 4 | 0 | 8 |
| 3. 最小生成树 | 2 | 0 | 1 | 3 |
| 4. 网络流 | 3 | 2 | 1 | 6 |
| 5. 图匹配 | 3 | 1 | 2 | 6 |
| 6. 连通性 | 3 | 2 | 0 | 5 |
| 7. 图着色 | 4 | 1 | 1 | 6 |
| 8. 团与独立集 | 1 | 2 | 0 | 3 |
| 9. 欧拉图与哈密顿图 | 4 | 0 | 1 | 5 |
| 10. 图同构与子树 | 0 | 2 | 2 | 4 |
| 11. 中心性 | 5 | 1 | 1 | 7 |
| 12. 社区检测 | 2 | 3 | 1 | 6 |
| 13. 相似度与链接预测 | 0 | 4 | 1 | 5 |
| 14. 割点桥与割集 | 2 | 1 | 0 | 3 |
| 15. 图嵌入与 ML | 0 | 0 | 5 | 5 |
| 16. 图生成 | 5 | 2 | 1 | 8 |
| 17. I/O 与序列化 | 2 | 2 | 2 | 6 |
| 18. 图统计 | 3 | 2 | 1 | 6 |
| **合计** | **47** | **31** | **20** | **98** |

其中：
- ✅ **已实现**: 47 个（含完整测试覆盖）
- ⬜ **未实现-合理目标**: 31 个（v1.0 后优先添加）
- 🔲 **暂不考虑**: 20 个（复杂度过高或属 ML 领域）

---

## 🎯 v1.0 建议包含范围

v1.0 目标算法数: **~50+** 个（当前 47 个，需补充 ~5-8 个关键缺失）

### P0: 必须补齐（3 个）
> 这些是图算法库的"门面"，如果是图库却没有，用户会很惊讶。

1. **Johnson 算法** — 全对最短路径的稀疏图优化（`shortest_path/`）
2. **SPFA 算法** — Bellman-Ford 的队列优化版本（`shortest_path/`）
3. **边着色** — Vizing 定理实现（`coloring/`）

### P1: 重要补齐（3-5 个）
> 实际应用中常见的需求，有较高用户需求度。

1. **双连通分量 (BCC)** — 与割点配套的连通性分析
2. **双向 Dijkstra** — 路径搜索的常见加速需求
3. **K 最短路径 (Yen's)** — 路径推荐/备选场景

### P2: 性能增强（~3 个）
> 已有实现可用但不高效，提供更优版本。

1. **Push-Relabel** — 对 Dinic 的补充（大规模图流算法）
2. **Stoer-Wagner 最小割** — 全局最小割
3. **KM 算法** — 二分图最大权匹配

---

## 📈 NetworkX 算法覆盖对比

| 类别 | NetworkX | mbtgraph | 覆盖率 |
|:----|:-------:|:--------:|:-----:|
| 最短路径 | 12 | 4 | 33% |
| 中心性 | 7 | 5 | 71% |
| 社区检测 | 8 | 2 | 25% |
| 连通性 | 6 | 3 | 50% |
| 着色 | 6 | 4 | 67% |
| 匹配 | 5 | 3 | 60% |
| 生成器 | 12 | 5 | 42% |
| 图同构 | 3 | 0 | 0% |
| 链接预测 | 5 | 0 | 0% |
| 割/分离 | 4 | 2 | 50% |
| **综合** | **68+** | **~47** | **~48%** |

---

## 🔗 参考来源

- [NetworkX 算法参考](https://networkx.org/documentation/stable/reference/algorithms/index.html)
- [Neo4j Graph Data Science Library](https://neo4j.com/docs/graph-data-science/current/algorithms/)
- [JGraphT Algorithm Reference](https://jgrapht.org/guide/UserOverview#graph-algorithms)
- [Boost Graph Library (BGL)](https://www.boost.org/doc/libs/1_85_0/libs/graph/doc/)
- [igraph Algorithms](https://igraph.org/python/doc/api/igraph.Graph.html)
- [petgraph (Rust)](https://docs.rs/petgraph/latest/petgraph/)