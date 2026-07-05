---
title: 项目架构总览
description: mbtgraph 的完整架构设计：系统分层、Trait 体系、存储实现、算法模式
---

> **当前代码版本**: v0.1.1 | **测试数**: 768 | **协议**: MIT

---

## 🏗️ 架构总览

### 系统分层

```
┌─────────────────────────────────────────────────────────────┐
│                     应用层 (Users)                          │
│   社交网络分析 / 路径规划 / 推荐系统 / 依赖分析 / ...      │
├─────────────────────────────────────────────────────────────┤
│                    算法层 (algo/)                           │
│  traversal  shortest_path  mst  connectivity  flow         │
│  matching   euler  cutpoints  coloring  clique             │
│  hamiltonian  pagerank  centrality  community              │
│  generators  link_prediction  dense_subgraph  operators    │
├─────────────────────────────────────────────────────────────┤
│                   抽象层 (core/traits.mbt)                 │
│     GraphReadable → Writable → Directed → Full            │
│          + BatchReadable + EdgeIterable                    │
├─────────────────────────────────────────────────────────────┤
│                   存储层 (storage/)                        │
│  AdjList(2) / Matrix(2) / EdgeList(2) / CSR / CSC         │
├─────────────────────────────────────────────────────────────┤
│                   基础层 (core/types.mbt)                  │
│              NodeId / Node / Edge / GraphError             │
└─────────────────────────────────────────────────────────────┘
```

### 核心设计原则

| 原则 | 实现方式 | 好处 |
|------|---------|------|
| **算法-存储解耦** | Trait 泛型约束 `[G : @core.GraphReadable]` | 一套算法适用所有图类型 |
| **LSP 原则** | CSR 不实现 `GraphWritable` | 避免运行时错误 |
| **ISP 原则** | 5 层 Trait 细粒度拆分 | 存储只需实现必要接口 |
| **纯函数语义** | MoonBit 不可变性 + 深拷贝 | 天然线程安全，易推理 |

---

## 📦 目录结构

```
mbtgraph/
├── lib/
│   ├── core/                    # 🔵 基础定义层
│   │   ├── types.mbt            # NodeId, Node, Edge, Weight
│   │   ├── traits.mbt           # 5 层 Trait 定义
│   │   └── error.mbt            # GraphError 错误类型
│   │
│   ├── storage/                 # 🟢 存储实现层 (8 种)
│   │   ├── directed_adj_list.mbt    # ⭐ 有向邻接表
│   │   ├── undirected_adj_list.mbt  # 无向邻接表
│   │   ├── directed_matrix.mbt      # 有向邻接矩阵
│   │   ├── undirected_matrix.mbt    # 无向邻接矩阵
│   │   ├── edge_list.mbt            # 有向边集数组
│   │   ├── undirected_edge_list.mbt # 无向边集数组
│   │   ├── csr.mbt                  # 压缩稀疏行
│   │   ├── csc.mbt                  # 压缩稀疏列
│   │   ├── converter.mbt            # 8 个泛型转换函数
│   │   └── shared_helpers.mbt       # 公共辅助函数
│   │
│   └── algo/                    # 🟣 算法模块层
│       ├── traversal/           # 图遍历 (BFS/DFS/环检测/拓扑排序)
│       ├── generators/          # 图生成器 (16 种)
│       ├── shortest_path/       # 最短路径 (Dijkstra/BF/FW/A*/Johnson...)
│       ├── mst/                 # 最小生成树 (Kruskal/Prim)
│       ├── connectivity/        # 连通性 (CC/Tarjan/Kosaraju/BCC)
│       ├── flow/                # 网络流 (EK/Dinic/费用流/Push-Relabel...)
│       ├── matching/            # 图匹配 (Hungarian/HK/Edmonds/KM)
│       ├── euler/               # 欧拉路径 (Hierholzer)
│       ├── cutpoints/           # 割点与桥 (Tarjan)
│       ├── coloring/            # 图着色 (Greedy/WP/DSATUR/Exact)
│       ├── clique/              # 团检测 (Bron-Kerbosch)
│       ├── hamiltonian/         # 哈密顿/TSP
│       ├── pagerank/            # PageRank
│       ├── centrality/          # 中心性分析
│       ├── community/           # 社区检测 (Louvain/Leiden/LPA/谱聚类)
│       ├── link_prediction/     # 链接预测
│       ├── dense_subgraph/      # 稠密子图 (K-Core/K-Truss)
│       ├── operators/           # 图算子 (补图/反转/积图...)
│       └── integration/         # 跨模块集成测试
│
├── docs/                        # 📚 文档目录
├── site/                        # 🌐 可视化站点 (Astro)
├── AGENTS.md                    # Agent 协作配置
├── MEMORY.md                    # 项目记忆
├── CHANGELOG.md                 # 变更日志
└── moon.mod.json                # 包配置
```

---

## 🔬 核心架构组件

### 1️⃣ 类型系统

```moonbit
pub(all) struct NodeId(Int)     // 节点 ID（紧凑整数包装）
pub(all) struct Node {          // 节点数据
  id : NodeId
  data : Double                 // MVP 阶段用 Double
}
pub(all) struct Edge {          // 边数据
  source : NodeId
  target : NodeId
  weight : Double
}
```

**设计决策**:
- `NodeId` 使用 newtype 包装而非裸 Int，防止参数混淆
- `data` 暂用 Double，平衡灵活性与复杂度

### 2️⃣ Trait 分层体系

```
Layer 1: GraphReadable (基础只读)
├── Layer 2a: GraphWritable (可写 — 动态存储专属)
├── Layer 2b: GraphDirected (有向 — 入边查询)
│   └── Layer 3: GraphFull = Writable + Directed (便捷别名)
└── Layer 2c: GraphBatchReadable (批量 — CSR/CSC 专属)
```

详见 [Trait 详解](/core-concepts/traits/) 和 [Trait 架构设计](/reference/design/graph-trait-architecture/)。

### 3️⃣ 存储层

| 场景 | 推荐存储 | Trait 实现 |
|------|---------|-----------|
| **通用稀疏图** | `DirectedAdjList` ⭐ | R+W+D |
| **无向通用图** | `UndirectedAdjList` | R+W |
| **稠密小图 (<1000 节点)** | `DirectedMatrix` | R+W+D |
| **Kruskal/MST 场景** | `EdgeList` | R+W+E |
| **大规模静态图 (>100K 节点)** | `CSR` | R+B |
| **入边密集查询** | `CSC` | R+B |

**存储间转换**:

```moonbit
let adj = @storage.to_adj_list(matrix)     // Matrix → AdjList
let csr = @storage.to_csr(adj_list)        // AdjList → CSR
let edge_list = @storage.to_edge_list(csr) // CSR → EdgeList
```

### 4️⃣ 算法层 — 两种设计模式

**方式 A: Trait 兼容型**（大多数算法）

```moonbit
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult {
  // 一套代码适用于所有 8 种存储
}
```

**方式 B: 独立数据结构型**（特殊语义场景）

```moonbit
let net = FlowNetwork::new(num_nodes)
let net = net.add_edge(0, 1, 16.0)  // 链式赋值
let result = edmonds_karp(net, 0, 5)
```

---

## 📈 实现状态 (v0.1.1)

| 类别 | 模块数 | 算法数 | 测试数 | 状态 |
|------|:------:|:------:|:------:|:----:|
| **遍历** | 1 | 5 | ~47 | ✅ |
| **图生成器** | 1 | 16 函数 | 56 | ✅ |
| **最短路径** | 1 | 8 | ~80 | ✅ |
| **MST** | 1 | 2 | 16 | ✅ |
| **连通性** | 1 | 3 | 21 | ✅ |
| **网络流** | 1 | 6 | ~45 | ✅ |
| **匹配** | 1 | 4 | ~35 | ✅ |
| **欧拉路径** | 1 | 1 | 22 | ✅ |
| **割点/桥** | 1 | 2 | ~18 | ✅ |
| **着色** | 1 | 5 | ~25 | ✅ |
| **团/独立集** | 1 | 3 | 14 | ✅ |
| **哈密顿/TSP** | 1 | 3 | 20 | ✅ |
| **PageRank** | 1 | 1 | ~15 | ✅ |
| **中心性** | 1 | 4 | ~20 | ✅ |
| **社区检测** | 1 | 4 | ~25 | ✅ |
| **链接预测** | 1 | 5 | ~20 | ✅ |
| **稠密子图** | 1 | 4 | ~18 | ✅ |
| **图算子** | 1 | 9 | ~25 | ✅ |
| **图识别** | 1 | 7 | ~20 | ✅ |
| **I/O** | 1 | DOT/JSON/统计 | ~20 | ✅ |
| **合计** | **19+** | **65+** | **768** | **✅** |

---

## 🔄 数据流示例

```
用户代码
  ↓ 调用 dijkstra(g, src)
algo/shortest_path/dijkstra.mbt
  ↓ 通过 trait 方法访问
GraphReadable::neighbors(g, node)
GraphReadable::degree(g, node)
GraphReadable::get_edge(g, u, v)
  ↓ 内部实现
storage/directed_adj_list.mbt (或任何其他存储)
  ↓ 返回结果
DijkstraResult { distances, paths, visited }
```

---

## 🔧 开发新模块流程

```
1️⃣ 创建目录结构
   mkdir lib/algo/new_module && touch moon.pkg types.mbt algorithm.mbt
2️⃣ 定义类型 (types.mbt)
3️⃣ 实现算法 (algorithm.mbt)
4️⃣ 编写测试 (algorithm_test.mbt)
5️⃣ 集成验证: moon check → moon test
```

---

## 相关文档

- [Trait 详解](/core-concepts/traits/) — 5 层 Trait 完整教程
- [Trait 架构设计](/reference/design/graph-trait-architecture/) — 设计决策详情
- [存储选型指南](/core-concepts/storage-guide/) — 8 种存储对比
- [算法目录](/algorithms/catalog/) — 完整算法清单
- [测试策略](/contributing/testing/) — 双轨测试体系
