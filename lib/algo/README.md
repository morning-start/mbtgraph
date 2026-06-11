# mbtgraph 算法模块 (`algo/)

> **版本**: v0.16.0 | **算法模块**: 19 个 | **总测试**: 651 通过

提供 ~65 种图算法的完整实现，覆盖图分析的核心领域。

## 算法全景

```
┌─────────────────────────────────────────────────────────────────┐
│                        mbtgraph 算法体系                         │
├─────────────┬─────────────┬─────────────┬───────────────────────┤
│  图遍历     │  最短路径    │  最小生成树  │  连通性分析            │
│  traversal  │ shortest_   │  mst        │  connectivity         │
│  59 tests   │ path 66     │  16 tests   │  22 tests             │
├─────────────┼─────────────┼─────────────┼───────────────────────┤
│  网络流     │  图匹配      │  社区检测    │  中心性分析            │
│  flow       │  matching   │  community  │  centrality           │
│  83 tests   │  56 tests   │  54 tests   │  72 tests             │
├─────────────┼─────────────┼─────────────┼───────────────────────┤
│  稠密子图   │  链接预测    │  图着色      │  团检测               │
│  dense_     │  link_      │  coloring   │  clique               │
│  subgraph   │  prediction │  29 tests   │  14 tests             │
│  20 tests   │  19 tests   │             │                       │
├─────────────┼─────────────┼─────────────┼───────────────────────┤
│  割点/桥    │  欧拉路径    │  哈密顿/TSP  │  图算子               │
│  cutpoints  │  euler      │  hamiltonian│  operators            │
│  15 tests   │  22 tests   │  20 tests   │  28 tests             │
├─────────────┼─────────────┼─────────────┼───────────────────────┤
│  特殊图识别 │  PageRank    │  集成测试    │                       │
│  recognition│  pagerank   │  integration│                       │
│  38 tests   │  15 tests   │  10 tests   │                       │
└─────────────┴─────────────┴─────────────┴───────────────────────┘
```

## 模块索引

### 🔴 核心图论

| 模块 | 算法数 | 测试 | 说明 |
|------|:------:|:----:|------|
| [traversal](traversal/) | 5 | 59 | BFS / DFS / 环检测 / 拓扑排序 / 双向 BFS |
| [shortest_path](shortest_path/) | 7 | 66 | Dijkstra / Bellman-Ford / Floyd / A* / SPFA / Johnson / Yen K短路 |
| [mst](mst/) | 2 | 16 | Kruskal / Prim |
| [connectivity](connectivity/) | 3 | 22 | 连通分量 / Tarjan SCC / Kosaraju SCC |

### 🟡 流与匹配

| 模块 | 算法数 | 测试 | 说明 |
|------|:------:|:----:|------|
| [flow](flow/) | 6 | 83 | Edmonds-Karp / Dinic / Push-Relabel / 容量缩放 / Stoer-Wagner / 费用流 |
| [matching](matching/) | 4 | 56 | Hungarian / Hopcroft-Karp / Edmonds Blossom / KM 最大权匹配 |

### 🟢 社会网络分析

| 模块 | 算法数 | 测试 | 说明 |
|------|:------:|:----:|------|
| [community](community/) | 4 | 54 | Louvain / Leiden / 标签传播 / 谱聚类 |
| [centrality](centrality/) | 7 | 72 | 度/介数/接近/特征向量/Katz/Harmonic/通信能力 |
| [pagerank](pagerank/) | 1 | 15 | PageRank 迭代算法 |
| [link_prediction](link_prediction/) | 5 | 19 | 共同邻居/Jaccard/Adamic-Adar/优先连接/资源分配 |

### 🔵 结构分析

| 模块 | 算法数 | 测试 | 说明 |
|------|:------:|:----:|------|
| [dense_subgraph](dense_subgraph/) | 4 | 20 | K-Core / K-Truss / 三角计数 / 聚类系数 |
| [coloring](coloring/) | 4 | 29 | 贪心/Welsh-Powell/DSATUR/精确着色 |
| [clique](clique/) | 1 | 14 | Bron-Kerbosch 最大团 |
| [cutpoints](cutpoints/) | 2 | 15 | Tarjan 割点 / 桥检测 |

### 🟣 特殊图与路径

| 模块 | 算法数 | 测试 | 说明 |
|------|:------:|:----:|------|
| [euler](euler/) | 1 | 22 | Hierholzer 欧拉路径/回路 |
| [hamiltonian](hamiltonian/) | 3 | 20 | 回溯/最近邻/Held-Karp TSP |
| [recognition](recognition/) | 7 | 38 | 弦图/二部图/完全图/正则图/树/森林/Havel-Hakimi |
| [operators](operators/) | 11 | 28 | 补图/反转/并交差/图积/线图/收缩/幂图 |

### ⚪ 辅助

| 模块 | 说明 |
|------|------|
| [integration](integration/) | 跨模块集成测试 (10 tests) |

## 快速使用

```moonbit
// 1. 创建图
let g = @storage.new_directed()
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore

// 2. 调用算法（泛型约束）
let distances = @algo.shortest_path.dijkstra(g, @core.NodeId(0))
let communities = @algo.community.louvain(g, 1.0)

// 3. 使用独立类型算法
let net = @algo.flow.FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)
let result = @algo.flow.dinic(net, 0, 3)
```

## 算法选型速查

| 问题类型 | 推荐算法 | 复杂度 | 模块 |
|---------|---------|:------:|------|
| 单源最短路（非负权）| Dijkstra | O((V+E)logV) | shortest_path |
| 单源最短路（含负权）| Bellman-Ford / SPFA | O(VE) | shortest_path |
| 全源最短路 | Floyd-Warshall | O(V³) | shortest_path |
| K短路 | Yen's | O(KV(V+E)logV) | shortest_path |
| 最大流 | Dinic | O(E√V) | flow |
| 最小费用流 | Min Cost Max Flow | O(F·E·logV) | flow |
| 二分图最大匹配 | Hopcroft-Karp | O(E√V) | matching |
| 一般图最大匹配 | Edmonds Blossom | O(V³) | matching |
| 社区检测 | Louvain | O(E·logV) | community |
| 中心性分析 | Brandes 介数 | O(VE) | centrality |
| 最小生成树 | Kruskal / Prim | O(E log E) | mst |
| 拓扑排序 | Kahn / DFS | O(V+E) | traversal |
| 三角形计数 | 枚举 | O(V·deg²) | dense_subgraph |
| 图着色 | DSATUR | 指数（精确）| coloring |

## 依赖关系

```
algo/* → core (GraphReadable / NodeId / Edge)
algo/flow → core (独立 FlowNetwork 类型)
algo/community/spectral → @la (linear-algebra)
algo/* → storage (测试构建)
```

## 开发指南

添加新算法模块：

1. 创建目录 `lib/algo/<module_name>/`
2. 编写 `moon.pkg` 配置
3. 实现算法（参考 flow/ 或任意模块）
4. 编写测试 `*_test.mbt`
5. 更新本 README 索引
6. 更新 `docs/algorithms_catalog.md`

详细规范见 [AGENTS.md](../../AGENTS.md)。

---

<div align="center">

**📊 统计**: 19 模块 | ~65 算法 | 651 测试 | 100% 通过

*最后更新: 2026-05-29 | mbtgraph v0.16.0*

</div>
