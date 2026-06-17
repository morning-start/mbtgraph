# mbtgraph API Reference

> **版本**: v1.1.0 | **最后更新**: 2026-06-17

## 概述

mbtgraph 是 MoonBit 生态首个生产级图算法库，提供 8 种存储实现、5 层 Trait 架构、65+ 算法和高级图分析功能。

### 核心特性

- **5 层 Trait 架构**: GraphReadable → GraphWritable → GraphDirected → GraphFull + GraphBatchReadable
- **8 种存储实现**: 邻接表、邻接矩阵、边集数组、CSR、CSC（有向/无向变体）
- **65+ 算法**: 遍历、最短路径、最小生成树、连通性、网络流、匹配、着色、团检测等
- **纯函数语义**: 所有算法保证输入不可变

---

## 模块索引

### 核心模块

| 模块 | 路径 | 说明 |
|------|------|------|
| [Core](core.md) | `lib/core` | 基础类型、Trait 定义、错误类型 |
| [Storage](storage.md) | `lib/storage` | 8 种图存储实现 + 转换函数 |
| [I/O](io.md) | `lib/io` | DOT/JSON 序列化 + 图统计 |
| [Generators](generators.md) | `lib/utils/generators` | 图生成器（完全图、星图、网格等） |

### 算法模块

| 模块 | 路径 | 说明 |
|------|------|------|
| [Traversal](algo/traversal.md) | `lib/algo/traversal` | BFS/DFS/环检测/拓扑排序 |
| [Shortest Path](algo/shortest_path.md) | `lib/algo/shortest_path` | Dijkstra/Bellman-Ford/Floyd/A*/SPFA |
| [MST](algo/mst.md) | `lib/algo/mst` | 最小生成树（Kruskal/Prim） |
| [Connectivity](algo/connectivity.md) | `lib/algo/connectivity` | 连通分量/SCC/BCC |
| [Flow](algo/flow.md) | `lib/algo/flow` | 网络流（Dinic/Edmonds-Karp/费用流） |
| [Matching](algo/matching.md) | `lib/algo/matching` | 图匹配（Hungarian/Hopcroft-Karp/Edmonds） |
| [Coloring](algo/coloring.md) | `lib/algo/coloring` | 图着色（Greedy/DSATUR/精确算法） |
| [Clique](algo/clique.md) | `lib/algo/clique` | 团检测/独立集/顶点覆盖 |
| [Euler](algo/euler.md) | `lib/algo/euler` | 欧拉路径/回路 |
| [Cutpoints](algo/cutpoints.md) | `lib/algo/cutpoints` | 割点与桥 |
| [Hamiltonian](algo/hamiltonian.md) | `lib/algo/hamiltonian` | 哈密顿路径/TSP |
| [Centrality](algo/centrality.md) | `lib/algo/centrality` | 中心性分析（PageRank/介数/接近度等） |
| [Community](algo/community.md) | `lib/algo/community` | 社区检测（Louvain/Leiden/标签传播） |
| [PageRank](algo/pagerank.md) | `lib/algo/pagerank` | PageRank 算法 |
| [Recognition](algo/recognition.md) | `lib/algo/recognition` | 图类型识别（二部图/弦图/正则图等） |
| [Operators](algo/operators.md) | `lib/algo/operators` | 图运算（并集/交集/补图/线图等） |
| [Link Prediction](algo/link_prediction.md) | `lib/algo/link_prediction` | 链接预测（Jaccard/Adamic-Adar 等） |
| [Dense Subgraph](algo/dense_subgraph.md) | `lib/algo/dense_subgraph` | 密度子图（聚类系数/K-Core/K-Truss） |

---

## 快速开始

### 安装

```toml
# moon.pkg.json
{
  "import": ["morning-start/mbtgraph"]
}
```

### 基本用法

```moonbit
// 创建有向图
let g = @storage.new_directed()
let n0 = @core.GraphWritable::add_node(g, 0.0)
let n1 = @core.GraphWritable::add_node(g, 1.0)
let n2 = @core.GraphWritable::add_node(g, 2.0)
let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)
let _ = @core.GraphWritable::add_edge(g, n1, n2, 2.0)

// 运行 BFS 遍历
let result = @traversal.bfs(g, n0)

// 获取最短路径
let path = result.path_to(n2)
// path = [n0, n1, n2]
```

---

## 依赖关系

```
core (基础层)
├── storage (存储层，依赖 core)
├── io (I/O 层，依赖 core)
├── generators (生成器，依赖 core + storage)
└── algo/* (算法层，依赖 core)
    ├── traversal
    ├── shortest_path
    ├── mst
    ├── connectivity
    ├── flow (独立类型 FlowNetwork)
    ├── matching
    ├── coloring
    ├── clique
    ├── euler
    ├── cutpoints
    ├── hamiltonian
    ├── centrality
    ├── community
    ├── pagerank
    ├── recognition
    ├── operators (依赖 storage)
    ├── link_prediction
    └── dense_subgraph
```

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.1.0 | 2026-06-14 | CI/CD 上线 |
| v1.0.0 | 2026-06-14 | 正式发布，API 冻结 |
| v0.16.0 | 2026-06-12 | API 冻结候选 |
