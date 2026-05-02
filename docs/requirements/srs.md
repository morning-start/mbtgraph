---
title: "mbtgraph 软件需求规格说明 (SRS)"
version: "0.1.0"
status: "draft"
type: "srs"
created: "2026-05-02"
updated: "2026-05-02"
author: "morning-start"
license: "Apache-2.0"
tags: ["requirements", "graph", "algorithm", "library"]
traceability:
  source: "docs/architecture/project_structure_design.md"
  targets:
    - "docs/design/sad.md"
    - "docs/quality/test_strategy.md"
    - "README.mbt.md"
---

# mbtgraph 软件需求规格说明 (SRS)

> **版本**: v0.1.0 | **状态**: 草稿 | **日期**: 2026-05-02

---

## 1. 引言

### 1.1 目的

本文档定义 `mbtgraph` 图算法库的功能需求、非功能需求和约束条件，作为项目设计、开发、测试的基准文档。

### 1.2 范围

`mbtgraph` 是一个使用 MoonBit 编写的**纯图算法库**（Library/Package），提供：

- ✅ 核心图数据结构（有向图、无向图、加权图、多重图）
- ✅ 经典图论算法（遍历、最短路径、生成树、连通性）
- ✅ 网络科学分析（中心性、社区检测、聚类系数）
- ✅ 流网络算法（最大流、最小费用流）
- ✅ 高级图算法（匹配、同构、着色、回路）
- ✅ 辅助工具（I/O、图生成器、布局算法）

**不在范围内**:
- ❌ CLI/GUI 应用程序
- ❌ 数据库集成
- ❌ 网络通信功能
- ❌ 可视化渲染引擎（仅提供布局坐标输出）

### 1.3 目标用户

| 用户类型 | 描述 |
|---------|------|
| **库消费者** | 其他 MoonBit 项目的开发者，通过 `moon.mod.json` 依赖本库 |
| **贡献者** | 参与算法实现、测试、文档编写的开发者 |
| **研究者** | 需要高效图算法进行学术研究的学者 |
| **教育者** | 使用本库作为图论教学示例的教师/学生 |

### 1.4 术语表

| 术语 | 英文 | 定义 |
|------|------|------|
| 节点 | Node/Vertex | 图的基本元素 |
| 边 | Edge | 连接两个节点的关系 |
| 有向图 | Directed Graph | 边具有方向的图 |
| 无向图 | Undirected Graph | 边无方向的图 |
| 加权图 | Weighted Graph | 边带有权重的图 |
| 连通分量 | Connected Component | 互相可达的节点集合 |
| 强连通 | Strongly Connected | 有向图中任意两点互相可达 |
| 模块度 | Modularity | 社区划分质量的衡量指标 |
| Trait | Trait | MoonBit 的类型抽象机制（类似接口） |

---

## 2. 总体描述

### 2.1 产品视角

本库是 MoonBit 生态系统中的一个**独立算法包**，可被其他 MoonBit 项目作为依赖项引入。

```
┌─────────────────────────────────────────┐
│         消费者项目 (Consumer)             │
│  ┌──────────────────────────────────┐   │
│  │  业务代码                         │   │
│  │  使用 mbtgraph 的 API             │   │
│  └──────────┬───────────────────────┘   │
└─────────────┼───────────────────────────┘
              │ depends on
┌─────────────▼───────────────────────────┐
│         mbtgraph (本库)                  │
│  ┌──────────────────────────────────┐   │
│  │  src/core   - 核心抽象            │   │
│  │  src/algo   - 经典算法            │   │
│  │  src/analysis - 网络分析          │   │
│  │  src/flow   - 流网络              │   │
│  │  src/utils  - 工具集              │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### 2.2 产品功能概览

| 功能模块 | 优先级 | 描述 |
|---------|--------|------|
| 核心图结构 | P0 | 有向图、无向图、加权图实现 |
| 遍历算法 | P0 | BFS、DFS |
| 最短路径 | P0 | Dijkstra、Bellman-Ford |
| 连通性分析 | P0 | SCC、拓扑排序 |
| 中心性算法 | P1 | PageRank、Betweenness、Closeness |
| 社区检测 | P1 | Louvain、Leiden |
| 最小生成树 | P1 | Kruskal、Prim |
| 最大流 | P2 | Dinic、Edmonds-Karp |
| 匹配算法 | P2 | Blossom 算法 |
| 同构检测 | P2 | VF2 算法 |
| 图着色 | P2 | Greedy DSATUR、精确算法 |
| I/O 工具 | P3 | DOT、GraphML、JSON 格式 |
| 布局算法 | P3 | 力导向、环形、层次布局 |

### 2.3 运行环境

| 目标平台 | 说明 | 优先级 |
|---------|------|--------|
| **native** | 本地原生编译（性能最优） | 高 |
| **wasm** | WebAssembly（浏览器/边缘计算） | 高 |
| **js** | JavaScript 互操作 | 中 |

---

## 3. 功能需求

### 3.1 核心抽象层 (FR-CORE)

#### FR-CORE-001: 图基础接口

**描述**: 定义所有图类型共享的最小查询接口

**输入**: 无

**处理**:

```pseudo
Trait Graph[N, E]:
  fn node_count(self) -> Int
  fn edge_count(self) -> Int
  fn contains_node(self, node: NodeId) -> Bool
  fn contains_edge(self, from: NodeId, to: NodeId) -> Bool
  fn neighbors(self, node: NodeId) -> List[Neighbor[N, E]]
```

**输出**: 图的基本信息

**验收标准**:
- ✅ `node_count()` 返回正确的节点数
- ✅ `edge_count()` 返回正确的边数
- ✅ `contains_node()` 正确判断节点存在性
- ✅ `neighbors()` 返回所有邻居列表

---

#### FR-CORE-002: 可变图接口

**描述**: 支持动态添加/删除节点和边

**处理**:

```pseudo
Trait MutableGraph[N, E]: Graph[N, E]
  fn add_node(self, data: N) -> NodeId
  fn add_edge(self, from: NodeId, to: NodeId, data: E) -> Result[EdgeId, Error]
  fn remove_node(self, node: NodeId) -> Result[Unit, Error]
  fn remove_edge(self, from: NodeId, to: NodeId) -> Result[Unit, Error]
```

**验收标准**:
- ✅ 添加节点后 `node_count()` 增加 1
- ✅ 添加边后 `edge_count()` 增加 1
- ✅ 删除节点时同时删除关联边
- ✅ 删除不存在的节点/边返回错误

---

#### FR-CORE-003: 有向图实现

**描述**: 实现有向图数据结构

**数据结构**: 邻接表 + HashMap

**验收标准**:
- ✅ `successors()` 返回后继节点
- ✅ `predecessors()` 返回前驱节点
- ✅ `reverse()` 返回转置图

---

#### FR-CORE-004: 无向图实现

**描述**: 实现无向图数据结构

**数据结构**: 邻接表 + HashSet（边去重）

**验收标准**:
- ✅ 边 (u,v) 和 (v,u) 等价
- ✅ `degree()` 返回节点度
- ✅ 不会重复添加相同的边

---

#### FR-CORE-005: 加权图扩展

**描述**: 为图添加边权重支持

**处理**:

```pseudo
Trait WeightedGraph[N, E]: Graph[N, E]
  fn edge_weight(self, edge: EdgeId) -> Option[Weight]
  fn total_weight(self) -> Weight
```

**验收标准**:
- ✅ 支持 Int64/Float64 权重类型
- ✅ 无权重边返回默认值或 None

---

### 3.2 经典算法层 (FR-ALGO)

#### FR-ALGO-001: BFS 广度优先搜索

**输入**: 图 G, 起始节点 source

**输出**: `BFSResult { discovered_order: List[NodeId], distance: Map[NodeId, Int], parent: Map[NodeId, NodeId] }`

**处理**: 使用队列进行层次遍历（详见架构设计文档伪代码）

**验收标准**:
- ✅ 返回的遍历顺序符合 BFS 定义
- ✅ 距离数组正确
- ✅ 父指针可重构最短路径树
- ✅ 时间复杂度 O(V+E)

---

#### FR-ALGO-002: DFS 深度优先搜索

**输入**: 图 G, 起始节点 source

**输出**: `DFSResult { discovered_order: List[NodeId], discovery_time: Map[NodeId, Int], finish_time: Map[NodeId, Int] }`

**验收标准**:
- ✅ 返回的遍历顺序符合 DFS 定义
- ✅ 发现/完成时间正确

---

#### FR-ALGO-003: Dijkstra 最短路径

**输入**: 加权图 G (权重 ≥ 0), 源节点 source, 可选目标 target

**输出**: `Result[ShortestPathResult, GraphError]`

**验收标准**:
- ✅ 最短路径距离正确
- ✅ 可重构完整路径
- ✅ 支持提前终止（指定 target 时）
- ✅ 负权重边返回错误

---

#### FR-ALGO-004: Bellman-Ford 最短路径

**输入**: 加权图 G (支持负权), 源节点 source

**输出**: `Result[ShortestPathResult, GraphError]`

**验收标准**:
- ✅ 正确处理负权重边
- ✅ 检测到负权环返回错误
- ✅ 时间复杂度 O(VE)

---

#### FR-ALGO-005: Kosaraju 强连通分量

**输入**: 有向图 G

**输出**: `SCCResult { components: List[List[NodeId]], component_id: Map[NodeId, Int], count: Int }`

**验收标准**:
- ✅ 每个 SCC 内部节点强连通
- ✅ 不同 SCC 之间不连通
- ✅ 时间复杂度 O(V+E)

---

#### FR-ALGO-006: 拓扑排序

**输入**: 有向无环图 G

**输出**: `Result[List[NodeId], GraphError]`

**验收标准**:
- ✅ 返回的序列满足拓扑序
- ✅ 有环图返回错误

---

#### FR-ALGO-007: Kruskal 最小生成树

**输入**: 无向加权连通图 G

**输出**: `MSTResult { edges: List[Edge], total_weight: Weight }`

**验收标准**:
- ✅ 生成树包含所有节点
- ✅ 总权重最小
- ✅ 边数 = V - 1

---

### 3.3 网络分析层 (FR-ANALYSIS)

#### FR-ANALYSIS-001: PageRank

**输入**: 有向图 G, 阻尼因子 (默认 0.85), 收敛阈值 (默认 1e-6), 最大迭代次数 (默认 100)

**输出**: `PageRankResult { scores: Map[NodeId, Float], iterations: Int, converged: Bool }`

**验收标准**:
- ✅ Scores 之和 ≈ 1.0
- ✅ 在 Karate Club 数据集上结果与 NetworkX 一致（误差 < 1e-5）
- ✅ 收敛时 iterations < 50

---

#### FR-ANALYSIS-002: Louvain 社区检测

**输入**: 加权无向图 G

**输出**: `CommunityResult { communities: List[List[NodeId]], membership: Map[NodeId, Int], modularity: Float }`

**验收标准**:
- ✅ 模块度 ≥ 0.3（标准社交网络图）
- ✅ 所有节点都被分配到社区
- ✅ 社区划分稳定（多次运行结果一致）

---

#### FR-ANALYSIS-003: 介数中心性

**输入**: 图 G

**输出**: `CentralityResult { scores: Map[NodeId, Float] }`

**验收标准**:
- ✅ 在 Karate Club 数据集上结果合理
- ✅ 时间复杂度 O(VE)

---

### 3.4 流网络层 (FR-FLOW)

#### FR-FLOW-001: Dinic 最大流

**输入**: 容量网络 G (有向, 边容量 ≥ 0), 源 s, 汇 t

**输出**: `MaxFlowResult { value: Int, flows: Map[EdgeId, Int], min_cut: List[Edge] }`

**验收标准**:
- ✅ 最大流值 = 最小割容量（最大流最小割定理）
- ✅ 流量守恒（除源汇外，流入 = 流出）
- ✅ 不超过边容量

---

### 3.5 工具层 (FR-UTILS)

#### FR-UTILS-001: 图生成器

**描述**: 提供标准图生成函数

**支持类型**:
- ✅ 完全图 K_n
- ✅ 环图 C_n
- ✅ 星图 S_n
- ✅ Erdős–Rényi 随机图 G(n,p)
- ✅ Barabási–Albert 无标度网络
- ✅ Watts–Strogatz 小世界网络

---

#### FR-UTILS-002: DOT 格式读写

**描述**: 支持 Graphviz DOT 格式的序列化与反序列化

**验收标准**:
- ✅ 正确导出 DOT 格式字符串
- ✅ 正确解析 DOT 文件为图结构
- ✅ 支持节点/边属性

---

## 4. 非功能需求

### 4.1 性能需求

| 指标 | 目标值 | 测试条件 |
|------|--------|----------|
| **BFS 遍历** | 100K 节点 < 50ms | native 目标 |
| **Dijkstra** | 100K 节点, 500K 边 < 200ms | native 目标 |
| **PageRank** | 100K 节点, 收敛 < 1s | native 目标 |
| **Louvain** | 100K 节点, 完成 < 5s | native 目标 |
| **Dinic 最大流** | 10K 节点, 100K 边 < 500ms | native 目标 |
| **内存占用** | 100K 节点图 < 100MB | native 目标 |
| **Wasm 体积** | < 1MB | 完整构建 |

### 4.2 可靠性需求

| 指标 | 目标值 | 说明 |
|------|--------|------|
| **单元测试覆盖率** | ≥ 80% | 核心算法 ≥ 90% |
| **崩溃率** | 0 | 所有错误通过 Result 返回 |
| **API 稳定性** | 语义化版本 | 破坏性变更需升主版本 |

### 4.3 安全性需求

- ✅ 无外部网络请求
- ✅ 无文件写入操作（仅 I/O 模块读取/写入用户指定文件）
- ✅ 无未定义行为（利用 MoonBit 类型系统保证）

### 4.4 可维护性需求

- ✅ 所有公开 API 必须有文档注释
- ✅ 所有算法必须包含单元测试
- ✅ 代码符合 MoonBit 官方风格指南
- ✅ 架构文档保持更新

---

## 5. 接口需求

### 5.1 编程接口

本库通过 MoonBit 模块系统导出公开 API，消费者通过 `use` 语句导入：

```moonbit
// 导入核心模块
use morning-start/mbtgraph/core::DirectedGraph
use morning-start/mbtgraph/algo/traverse::bfs
use morning-start/mbtgraph/analysis/centrality::pagerank

// 使用 API
let g = DirectedGraph::new()
// ...
```

### 5.2 数据接口

#### 5.2.1 DOT 格式导入导出

```
输入: DOT 格式字符串或文件
输出: 图结构 (DirectedGraph/UndirectedGraph)

输入: 图结构
输出: DOT 格式字符串
```

#### 5.2.2 JSON 格式

```
输入: JSON 格式字符串
输出: 图结构

输入: 图结构
输出: JSON 格式对象 { nodes: [...], edges: [...] }
```

---

## 6. 约束条件

### 6.1 技术约束

| 约束项 | 说明 |
|--------|------|
| **语言** | 必须使用 MoonBit 编写 |
| **依赖** | 最小化外部依赖，优先使用标准库 |
| **后端兼容** | 必须同时支持 wasm/js/native 后端 |
| **内存安全** | 禁止 unsafe 操作 |

### 6.2 业务约束

| 约束项 | 说明 |
|--------|------|
| **许可证** | Apache-2.0 |
| **包发布** | 兼容 mooncakes.io 发布规范 |
| **文档语言** | 中文为主，关键 API 提供英文注释 |

---

## 7. 验收标准总结

| 模块 | 核心验收标准 | 测试数据 |
|------|-------------|----------|
| **core** | 正确创建/修改/查询图 | 人工构造小图 |
| **algo/traverse** | BFS/DFS 顺序正确 | 小图 + 中等图 |
| **algo/shortest_path** | 最短路径距离正确 | 标准测试用例 |
| **algo/connectivity** | SCC 划分正确 | 标准测试用例 |
| **analysis/centrality** | PageRank 与 NetworkX 一致 | Karate Club |
| **analysis/community** | 模块度 > 0.3 | Karate Club + Drosophila PPI |
| **flow/max_flow** | 最大流 = 最小割容量 | 标准网络流测试用例 |

---

## 8. 附录

### 8.1 参考文档

- [项目架构设计](docs/architecture/project_structure_design.md)
- [竞品调研报告](docs/reference/)

### 8.2 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| v0.1.0 | 2026-05-02 | 初始版本，定义 MVP + Phase 1-2 需求 |

---

**文档状态**: 草稿 ⏳  
**待办事项**: 
- [ ] 补充 Phase 3 高级算法需求
- [ ] 补充 Phase 4 工具层详细需求
- [ ] 性能指标需与实测数据对齐
