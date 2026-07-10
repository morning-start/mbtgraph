# v0.1.3 大规模性能基准报告

> **基线版本**: v0.1.3 | **更新日期**: 2026-07-10
> **测试框架**: `@moonbitlang.core.bench` | **运行环境**: WASM (moon test)
> **基准规模**: 5000 / 10000 节点

---

## 概述

本报告记录 v0.1.3 版本在大规模图（5000 / 10000 节点）下的性能基线数据。
**图结构**: 路径图（k=1），有向/无向 — `make_path_graph()` / `make_path_graph_undirected()`

所有测试使用 `@moonbitlang.core.bench` 框架，每项 10 次运行取统计值。

> **注意**: WASM GC 栈限制下，部分 O(V³) 或 O(VE) 算法仅在 benchmarks/ 包的
> 小规模（100/1000）下运行。大规模包仅包含 O(V+E)~O(E log V) 的算法。

---

## 算法覆盖矩阵

| 算法 | 类别 | 5000 节点 | 10000 节点 |
|:----|:----|:--------:|:---------:|
| **最短路径** | | |
| Dijkstra | 单源最短路径 | ✅ | ✅ |
| **遍历** | | |
| BFS | 广度优先搜索 | ✅ | ✅ |
| DFS | 深度优先搜索 | ✅ | ✅ |
| TopoSort (Kahn) | 拓扑排序 | ✅ | ✅ |
| **MST** | | |
| Kruskal | 最小生成树 | ✅ | ✅ |
| Prim | 最小生成树 | ✅ | ❌ |
| Borůvka | 最小生成树 | ✅ | ✅ |
| **连通性** | | |
| Connected Components | 连通分量 | ✅ | ✅ |
| Kosaraju SCC | 强连通分量 | ✅ | ✅ |
| Tarjan SCC | 强连通分量 | ✅ | ✅ |
| Is Bipartite | 二分图判定 | ✅ | ✅ |
| **中心性** | | |
| PageRank | 幂法迭代排名 | ✅ | ❌ |
| Degree Centrality | 度中心性 | ✅ | ✅ |
| **密集子图** | | |
| K-Core | 核分解 | ✅ | ✅ |
| Triangle Counting | 三角形计数 | ✅ | ✅ |
| Average Clustering Coef | 平均聚类系数 | ✅ | ✅ |
| **存储转换** | | |
| CSR Conversion | 有向→CSR | ✅ | ✅ |
| CSC Conversion | 有向→CSC | ✅ | ✅ |

---

## 运行命令

```bash
moon test benchmarks_large    # 5000 / 10000 节点
moon test benchmarks          # 100 / 1000 节点（另见 benchmarks/README.md）
```

---

## 原始数据

完整基线数据见 [baseline_v0.1.3.csv](baseline_v0.1.3.csv)（即将更新）。
