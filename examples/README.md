# mbtgraph 示例

> mbtgraph 算法库的使用示例，帮助你快速上手。

---

## 示例列表

### 基础示例

| 示例 | 文件 | 说明 |
|------|------|------|
| 最短路径 | [shortest_path.mbt](shortest_path.mbt) | Dijkstra、A*、Floyd-Warshall、Bellman-Ford |
| 最小生成树 | [mst.mbt](mst.mbt) | Kruskal、Prim |
| 图遍历 | [traversal.mbt](traversal.mbt) | BFS、DFS、环检测、拓扑排序 |
| 连通性 | [connectivity.mbt](connectivity.mbt) | 连通分量、强连通分量 |
| 网络流 | [flow.mbt](flow.mbt) | 最大流、最小费用流、最小割 |

### 高级示例

| 示例 | 文件 | 说明 |
|------|------|------|
| 社区检测 | [community.mbt](community.mbt) | Louvain、Leiden、标签传播 |
| 中心性分析 | [centrality.mbt](centrality.mbt) | PageRank、介数中心性、接近中心性 |
| 匹配算法 | [matching.mbt](matching.mbt) | Hungarian、Hopcroft-Karp、Edmonds |
| 图着色 | [coloring.mbt](coloring.mbt) | 贪心、DSATUR、精确色数、边着色 |
| I/O 示例 | [io_example.mbt](io_example.mbt) | DOT/JSON 序列化、图统计 |

---

## 快速开始

### 运行单个示例

```bash
# 基础示例
moon run examples/shortest_path.mbt
moon run examples/mst.mbt
moon run examples/traversal.mbt
moon run examples/connectivity.mbt
moon run examples/flow.mbt

# 高级示例
moon run examples/community.mbt
moon run examples/centrality.mbt
moon run examples/matching.mbt
moon run examples/coloring.mbt
moon run examples/io_example.mbt
```

### 运行所有示例

```bash
moon run examples/
```

---

## 示例说明

### 基础示例

#### 最短路径示例

演示各种最短路径算法的使用：

- **Dijkstra**: 非负权图单源最短路径
- **Dijkstra Targeted**: 两节点间最短路径
- **A***: 启发式搜索
- **Floyd-Warshall**: 全源最短路径
- **Bellman-Ford**: 支持负权边的最短路径

#### 最小生成树示例

演示 MST 算法的使用：

- **Kruskal**: 基于边排序的 MST
- **Prim**: 基于顶点扩展的 MST
- **MST 成员检查**: 验证边是否在 MST 中

#### 图遍历示例

演示遍历算法的使用：

- **BFS**: 广度优先搜索，层级遍历
- **DFS**: 深度优先搜索，时间戳
- **BFS 最短路径**: 无权图最短路径
- **环检测**: 检测图中是否存在环
- **拓扑排序**: 有向无环图的线性排序

#### 连通性示例

演示连通性算法的使用：

- **连通分量**: 无向图连通分量检测
- **Tarjan SCC**: 强连通分量检测
- **Kosaraju SCC**: 另一种 SCC 算法

#### 网络流示例

演示网络流算法的使用：

- **最大流**: Edmonds-Karp、Dinic、Push-Relabel
- **最小费用最大流**: 在最大流基础上最小化费用
- **全局最小割**: Stoer-Wagner 算法
- **算法比较**: 不同最大流算法的性能对比

### 高级示例

#### 社区检测示例

演示社区检测算法的使用：

- **Louvain**: 基于模块度优化的社区检测
- **Leiden**: Louvain 的改进版
- **标签传播**: 半监督社区检测
- **谱聚类**: 基于拉普拉斯矩阵

#### 中心性分析示例

演示中心性分析算法的使用：

- **PageRank**: 网页排名算法
- **度中心性**: 节点连接数
- **介数中心性**: 节点在最短路径中的中介作用
- **接近中心性**: 节点到其他节点的平均距离
- **特征向量中心性**: 连接高影响力节点的节点

#### 匹配算法示例

演示匹配算法的使用：

- **Hopcroft-Karp**: 二部图最大匹配
- **Hungarian (KM)**: 加权二部图最优匹配
- **Edmonds Blossom**: 一般图最大匹配

#### 图着色示例

演示图着色算法的使用：

- **贪心着色**: 快速近似着色
- **Welsh-Powell**: 按度数降序着色
- **DSATUR**: 饱和度优先着色
- **精确色数**: 回溯搜索精确解
- **边着色**: 边的着色问题

#### I/O 示例

演示图的序列化/反序列化：

- **DOT 格式**: Graphviz 格式导出/导入
- **JSON 格式**: JSON 格式导出/导入
- **图统计**: 基本统计、度分布、连通性、距离指标

---

## 学习路径

### 入门

1. 从 `traversal.mbt` 开始，理解基本遍历
2. 学习 `shortest_path.mbt` 和 `mst.mbt`

### 进阶

3. 探索 `connectivity.mbt` 和 `flow.mbt`
4. 学习 `community.mbt` 和 `centrality.mbt`

### 高级

5. 深入 `matching.mbt` 和 `coloring.mbt`
6. 掌握 `io_example.mbt` 的序列化功能

---

## 相关资源

- [Getting Started](../docs/guides/getting_started.md) — 快速入门指南
- [Algorithm Guide](../docs/guides/algorithm_guide.md) — 算法选择指南
- [API Reference](../docs/api/README.md) — 完整 API 文档
