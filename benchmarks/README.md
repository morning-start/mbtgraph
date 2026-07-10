# v0.1.3 性能基准报告

> **基线版本**: v0.1.3 | **更新日期**: 2026-07-10
> **测试框架**: `@moonbitlang.core.bench` | **运行环境**: WASM (moon test)
> **基准规模**: 100 / 1000 节点

---

## 概述

本报告记录 v0.1.3 版本在中小规模图（100 / 1000 节点）下的性能基线数据。
**图结构**: 链式图（k=5 / k=10），有向/无向 — `make_chain_graph()` / `make_chain_graph_undirected()`
**流网络**: 线性链（i → i+1）— `make_flow_graph()`

所有测试使用 `@moonbitlang.core.bench` 框架，每项 10 次运行取统计值。

---

## 算法覆盖矩阵

| 算法 | 类别 | 100 节点 | 1000 节点 |
|:----|:----|:-------:|:--------:|
| **最短路径** | | |
| Dijkstra | 单源最短路径 | ✅ | ✅ |
| Bellman-Ford | 单源最短路径（负权） | ✅ | ✅ |
| Floyd-Warshall | 全源最短路径 | ✅ | ❌ |
| **遍历** | | |
| BFS | 广度优先搜索 | ✅ | ✅ |
| DFS | 深度优先搜索 | ✅ | ✅ |
| TopoSort (Kahn) | 拓扑排序 | ✅ | ✅ |
| Bidirectional BFS | 双向搜索 | ✅ | ✅ |
| Has Cycle | 环检测 | ✅ | ✅ |
| **MST** | | |
| Kruskal | 最小生成树 | ✅ | ✅ |
| Prim | 最小生成树 | ✅ | ✅ |
| Borůvka | 最小生成树 | ✅ | ✅ |
| **社区检测** | | |
| Louvain | 模块度优化 | ✅ | ❌ |
| Label Propagation | 标签传播 | ✅ | ✅ |
| Leiden | 改进 Louvain | ✅ | ✅ |
| **连通性** | | |
| Connected Components | 连通分量 | ✅ | ✅ |
| Kosaraju SCC | 强连通分量 | ✅ | ✅ |
| Tarjan SCC | 强连通分量 | ✅ | ✅ |
| Is Bipartite | 二分图判定 | ✅ | ✅ |
| **中心性** | | |
| PageRank | 幂法迭代排名 | ✅ | ✅ |
| Degree Centrality | 度中心性 | ✅ | ✅ |
| Eigenvector Centrality | 特征向量中心性 | ✅ | ✅ |
| Betweenness Centrality | 介数中心性 | ✅ | ❌ |
| **着色** | | |
| Greedy Coloring | 贪心着色 | ✅ | ✅ |
| Welsh-Powell | 改进贪心着色 | ✅ | ✅ |
| DSATUR | 饱和度着色 | ✅ | ✅ |
| **密集子图** | | |
| K-Core | 核分解 | ✅ | ✅ |
| Triangle Counting | 三角形计数 | ✅ | ✅ |
| Average Clustering Coef | 平均聚类系数 | ✅ | ✅ |
| **流网络** | | |
| Dinic | 最大流 | ✅ | ✅ |
| Edmonds-Karp | 最大流 | ✅ | ❌ |
| Push-Relabel | 最大流 | ✅ | ❌ |
| Capacity Scaling | 最大流（缩放） | ✅ | ❌ |
| **存储转换** | | |
| CSR Conversion | 有向→CSR | ✅ | ✅ |
| CSC Conversion | 有向→CSC | ✅ | ✅ |

---

## 运行命令

```bash
moon test benchmarks          # 100 / 1000 节点
moon test benchmarks_large    # 5000 / 10000 节点（另见 benchmarks_large/README.md）
```

---

## 原始数据

完整基线数据见 [baseline_v0.1.3.csv](baseline_v0.1.3.csv)（即将更新）。
