# mbtgraph — 项目架构总览

> **版本**: v1.1.0 | **最后更新**: 2026-06-21
> **当前代码版本**: v1.1.0 | **测试数**: 940 | **协议**: MIT

---

## 📖 文档定位

本文档是 mbtgraph 的**架构权威参考**，用于：

- ✅ 向新贡献者介绍项目整体结构
- ✅ 理解核心设计决策及其原因
- ✅ 指导新模块/算法的开发流程
- ✅ 了解未来扩展方向（v1.0.0+）

**补充文档**:
- [PROJECT_VISION.md](./PROJECT_VISION.md) — 项目愿景与意义
- [ROADMAP.md](./ROADMAP.md) — 版本规划与时间线
- [design/graph_trait_and_module_architecture.md](./design/graph_trait_and_module_architecture.md) — Trait 设计细节

---

## 🏗️ 架构总览

### 系统分层

```
┌─────────────────────────────────────────────────────────────┐
│                     应用层 (Users)                          │
│   社交网络分析 / 路径规划 / 推荐系统 / 依赖分析 / ...      │
├─────────────────────────────────────────────────────────────┤
│                    算法层 (algo/)                           │
│  ┌──────────┬──────────┬──────────┬──────────┬──────────┐  │
│  │ traversal│ shortest_│   mst    │connectivity│  flow    │  │
│  │ BFS/DFS  │  path    │ Kruskal  │ CC/Tarjan │ EK/Dinic │  │
│  ├──────────┼──────────┼──────────┼──────────┼──────────┤  │
│  │ matching │  euler   │cutpoints │ coloring  │clique    │  │
│  │ Hungarian│Hierholzer│ Tarjan   │ Greedy/...│Bron-Kerb │  │
│  ├──────────┼──────────┼──────────┼──────────┼──────────┤  │
│  │hamiltonian│generators│ pagerank │centrality │community  │  │
│  │ TSP      │ random   │ (v0.10)  │ (v0.10)   │(v0.10)   │  │
│  └──────────┴──────────┴──────────┴──────────┴──────────┘  │
├─────────────────────────────────────────────────────────────┤
│                   抽象层 (core/traits.mbt)                 │
│         GraphReadable → Writable → Directed → Full        │
│              + BatchReadable + EdgeIterable                │
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
| **LSP 原则** | CSR 不实现 `GraphWritable`（只读存储不可写） | 避免运行时错误 |
| **ISP 原则** | 6 层 Trait 细粒度拆分 | 存储只需实现必要接口 |
| **纯函数语义** | MoonBit 不可变性 + 深拷贝 | 天然线程安全，易推理 |
| **渐进式复杂度** | 从简单存储到优化存储 | 用户按需选择 |

---

## 📦 目录结构详解

```
mbtgraph/
├── lib/
│   ├── core/                        # 🔵 基础定义层
│   │   ├── types.mbt               # 核心类型: NodeId, Node, Edge, Weight
│   │   ├── traits.mbt              # 6 层 Trait 定义 (架构核心)
│   │   └── error.mbt               # GraphError 错误类型
│   │
│   ├── storage/                     # 🟢 存储实现层 (8 种)
│   │   ├── directed_adj_list.mbt   # 有向邻接表 ⭐ 默认推荐
│   │   ├── undirected_adj_list.mbt # 无向邻接表 (半存储优化)
│   │   ├── directed_matrix.mbt     # 有向邻接矩阵
│   │   ├── undirected_matrix.mbt   # 无向邻接矩阵 (上三角)
│   │   ├── edge_list.mbt           # 有向边集数组
│   │   ├── undirected_edge_list.mbt# 无向边集数组
│   │   ├── csr.mbt                 # 压缩稀疏行 (亿级节点)
│   │   ├── csc.mbt                 # 压缩稀疏列 (入边密集)
│   │   ├── converter.mbt           # 8 个泛型转换函数
│   │   └── shared_helpers.mbt      # 公共辅助函数
│   │
│   └── algo/                        # 🟣 算法模块层 (12+ 子模块)
│       ├── traversal/              # P0: 图遍历
│       ├── generators/             # P0: 图生成器
│       ├── shortest_path/          # P1: 最短路径
│       ├── mst/                    # P2: 最小生成树
│       ├── connectivity/           # P2: 连通性分析
│       ├── flow/                   # P3: 网络流
│       ├── matching/               # P4: 图匹配
│       ├── euler/                  # P5-A: 欧拉路径
│       ├── cutpoints/              # P5-B: 割点与桥
│       ├── coloring/               # P5-C: 图着色
│       ├── clique/                 # P5-D: 团检测
│       ├── hamiltonian/            # P5-E: 哈密顿/TSP
│       ├── pagerank/               # 🆕 v0.10: PageRank
│       ├── centrality/             # 🆕 v0.10: 中心性分析
│       └── community/              # 🆕 v0.10: 社区检测
│
├── docs/                           # 📚 文档目录
│   ├── PROJECT_VISION.md          # 项目愿景与意义
│   ├── ARCHITECTURE.md            # 本文档：架构总览
│   ├── ROADMAP.md                 # 版本路线图
│   ├── TODO.md                    # 任务清单
│   ├── design/                    # 设计文档
│   │   ├── graph_trait_and_module_architecture.md
│   │   ├── graph_storage_survey.md
│   │   └── roadmap_v2_redesign_*.md
│   ├── reference/                 # 参考资料
│   │   └── library_survey.md      # 竞品对比汇总
│   └── quality/                   # 质量保障
│       └── test_strategy.md       # 测试策略
│
├── AGENTS.md                      # Agent 协作配置 + 编码规范
├── MEMORY.md                      # 项目记忆与决策记录
├── CHANGELOG.md                   # 版本变更日志
├── moon.mod.json                  # 包配置
└── README.mbt.md                  # 主页文档
```

---

## 🔬 核心架构组件

### 1️⃣ 类型系统 (core/types.mbt)

```moonbit
pub(all) type NodeId {     // 节点 ID（紧凑整数）
  NodeId(Int)              // 内部使用 0-based 索引
}

pub(all) struct Node {     // 节点数据
  id : NodeId
  data : Double            // MVP 阶段用 Double，后续可泛型化
}

pub(all) struct Edge {     // 边数据
  source : NodeId
  target : NodeId
  weight : Double          // 权重（默认 1.0）
}

pub(all) type Weight {     // 边权变体
  Unweighted               // 无权图
  Weighted(Double)         // 加权图
}
```

**设计决策**:
- `NodeId` 使用 newtype 包装而非裸 Int，防止混淆
- `data` 字段暂用 Double，平衡灵活性与复杂度
- `Weight` 使用 enum 区分有权/无权图

---

### 2️⃣ Trait 分层体系 (core/traits.mbt)

```
Layer 1: GraphReadable (基础只读)
├── Layer 2a: GraphWritable (可写 — 动态存储专属)
├── Layer 2b: GraphDirected (有向 — 入边查询)
│   └── Layer 3: GraphFull = Writable + Directed (便捷别名)
├── Layer 2c: GraphBatchReadable (批量 — CSR/CSC 专属)
└── Layer 2d: GraphEdgeIterable (边排序 — Kruskal 友好)
```

#### 各层能力矩阵

| 方法 | Readable | Writable | Directed | Batch | EdgeIter | 说明 |
|------|:--------:|:--------:|:--------:|:-----:|:-------:|------|
| node_count | ✅ | ✅ | ✅ | ✅ | ✅ | 节点数 |
| edge_count | ✅ | ✅ | ✅ | ✅ | ✅ | 边数 |
| contains_node | ✅ | ✅ | ✅ | ✅ | ✅ | 节点存在? |
| contains_edge | ✅ | ✅ | ✅ | ✅ | ✅ | 边存在? |
| get_node | ✅ | ✅ | ✅ | ✅ | ✅ | 获取节点 |
| get_edge | ✅ | ✅ | ✅ | ✅ | ✅ | 获取边 |
| neighbors | ✅ | ✅ | ✅ | ✅ | ✅ | 出边邻居 |
| degree | ✅ | ✅ | ✅ | ✅ | ✅ | 出度 |
| **add_node** | — | ✅ | — | — | — | 新增节点 |
| **remove_node** | — | ✅ | — | — | — | 删除节点 |
| **add_edge** | — | ✅ | — | — | — | 新增边 |
| **remove_edge** | — | ✅ | — | — | — | 删除边 |
| **clear** | — | ✅ | — | — | — | 清空图 |
| **in_neighbors** | — | — | ✅ | — | — | 入边邻居 |
| **in_degree** | — | — | ✅ | — | — | 入度 |
| **out_neighbors** | — | — | ✅ | — | — | 出边邻居(别名) |
| **out_degree** | — | — | ✅ | — | — | 出度(别名) |
| **predecessors** | — | — | ✅ | — | — | 前驱节点 |
| **batch_neighbors** | — | — | — | ✅ | — | 批量邻居查询 |
| **edges** | — | — | — | — | ✅ | 所有边迭代器 |

#### 为什么这样分层？

**问题**: 不同存储结构的能力差异巨大

| 存储 | 可修改？ | 高效入边查询？ | 批量操作？ |
|------|:-------:|:------------:|:---------:|
| AdjList | ✅ | ❌ O(E) 全扫描 | ❌ |
| Matrix | ✅ | ✅ O(1) | ❌ |
| CSR | ❌ 只读 | ❌ 需 CSC | ✅ O(deg) |
| CSC | ❌ 只读 | ✅ O(deg) | ✅ O(deg) |

**解决方案**: 分层 Trait 让每个存储只实现它支持的接口

```moonbit
// CSR 只实现 Readable + BatchReadable（不实现 Writable！）
// 这符合 LSP 原则：如果需要"可写图"，CSR 不会被误用
```

---

### 3️⃣ 存储层实现 (storage/)

#### 存储选型指南

| 场景 | 推荐存储 | Trait 实现 | 时间复杂度 |
|------|---------|-----------|-----------|
| **通用稀疏图** | `DirectedAdjList` ⭐ | R+W+D+E | 邻居 O(k), 查询 O(1) |
| **无向通用图** | `UndirectedAdjList` ⭐ | R+W+E | 半存储节省 50% |
| **稠密小图 (<1000 节点)** | `DirectedMatrix` | R+W+D | 邻居 O(V), 空间 O(V²) |
| **Kruskal/MST 场景** | `EdgeList` | R+W+E | 边排序 O(E log E) |
| **大规模静态图 (>100K 节点)** | `CSR` | R+B | 极致缓存友好 |
| **入边密集查询** | `CSC` | R+B | in_degree O(1) |

#### 存储间转换

```moonbit
let adj = to_adj_list(matrix)        // Matrix → AdjList
let csr = to_csr(adj_list)           // AdjList → CSR
let edge_list = to_edge_list(csr)    // CSR → EdgeList
// 8 种双向转换，全部泛型实现
```

---

### 4️⃣ 算法层设计模式 (algo/)

#### 统一函数签名模式

```moonbit
pub fn[G : @core.GraphReadable] algorithm_name(
  graph : G,
  param1 : Type1,           // 必要参数
  param2 : Type2?,          // 可选参数 (Option)
) -> ResultType {
  // 实现细节...
}
```

**关键特征**:
- 泛型约束 `[G : @core.GraphReadable]` — 适用所有图类型
- 返回值类型统一为 `XxxResult` 结构体（含结果 + 元数据）
- 参数使用 Option 处理可选配置

#### 算法模块的两种组织方式

**方式 A: Trait 兼容型**（大多数算法）

```moonbit
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult {
  // 通过 trait 方法访问图: graph.neighbors(node), graph.degree(node), etc.
}
```
✅ 优点: 一套代码适用于所有 8 种存储

**方式 B: 独立数据结构型**（特殊语义场景，如流网络）

```moonbit
let net = FlowNetwork::new(num_nodes)
let net = net.add_edge(0, 1, 16.0)  // 链式赋值
let result = edmonds_karp(net, 0, 5)
```
✅ 优点: 自包含容量/流量矩阵，不依赖 Graph trait
✅ 用途: 流网络、二分图匹配等需要额外语义的场景

---

## 🔄 数据流示例

### 示例: 计算最短路径并输出 DOT 格式

```moonbit
use @core.{NodeId, GraphReadable, DirectedAdjList, DijkstraResult}

fn main {
  let mut g = DirectedAdjList::new(5)
  let g = add_edges(g)  // 添加边...

  let result : DijkstraResult = dijkstra(g, NodeId(0))

  println("距离: ${result.distances}")
  println("路径: ${result.paths}")

  let dot_str = write_dot(g)  // v0.11.0 功能
  println(dot_str)
}
```

**数据流**:
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

## 📈 当前实现状态 (v1.1.0)

### 已完成模块统计

| 类别 | 模块数 | 算法数 | 测试数 | 状态 |
|------|:------:|:------:|:------:|:----:|
| **遍历** | 1 | 4 (BFS/DFS/环检测/拓扑) | ~47 | ✅ 完成 |
| **图生成器** | 1 | 16 函数 | 56 | ✅ 完成 |
| **最短路径** | 1 | 8 (Dijkstra/BF/FW/A*/Johnson/SPFA/双向BFS/双向Dijkstra/Yen's K) | ~80 | ✅ 完成 |
| **MST** | 1 | 2 (Kruskal/Prim) | 16 | ✅ 完成 |
| **连通性** | 1 | 3 (CC/Tarjan/Kosaraju) | 21 | ✅ 完成 |
| **网络流** | 1 | 4 (Edmonds-Karp/Dinic/最小费用最大流/Push-Relabel) | ~45 | ✅ 完成 |
| **匹配** | 1 | 4 (Hungarian/Hopcroft-Karp/Edmonds/Kuhn-Munkres) | ~35 | ✅ 完成 |
| **欧拉路径** | 1 | 1 (Hierholzer) | 22 | ✅ 完成 |
| **割点/桥** | 1 | 2 (Tarjan/BCC) | ~18 | ✅ 完成 |
| **着色** | 1 | 5 (Greedy/WP/DSATUR/Exact/边着色) | ~25 | ✅ 完成 |
| **团/独立集** | 1 | 1 (Bron-Kerbosch) | 14 | ✅ 完成 |
| **哈密顿/TSP** | 1 | 3 (Backtrack/NN/Held-Karp) | 20 | ✅ 完成 |
| **PageRank** | 1 | 1 (幂法) | ~15 | ✅ 完成 |
| **中心性** | 1 | 4 (度/接近/中介/特征向量) | ~20 | ✅ 完成 |
| **社区检测** | 1 | 4 (Louvain/LPA/Leiden/谱聚类) | ~25 | ✅ 完成 |
| **链接预测** | 1 | 5 (共同邻居/Jaccard/AA/RA/优先连接) | ~20 | ✅ 完成 |
| **稠密子图** | 1 | 4 (K-Core/聚类系数/三角形/稠密子图发现) | ~18 | ✅ 完成 |
| **图算子** | 1 | 9 (并集/交集/差集/补图/反转等) | ~25 | ✅ 完成 |
| **图识别** | 1 | 7 (二部图/正则图/完全图/树等) | ~20 | ✅ 完成 |
| **I/O** | 1 | DOT/JSON/统计 | ~20 | ✅ 完成 |
| **合计** | **19+** | **65+** | **940** | **✅ 全完成** |

### 代码质量指标

| 指标 | 数值 |
|------|:----:|
| 总测试数 | **940** (黑盒 + 白盒) |
| 通过率 | **100%** ✅ |
| 代码行数 | ~15,000+ (含测试和文档) |
| 文档覆盖率 | ~95% (公开 API) |

---

## 🔮 未来架构演进 (v1.0.0+)

### v0.10.0-v0.13.0: 功能扩展期

```
新增模块:
├── algo/pagerank/           # PageRank 幂法
├── algo/centrality/         # 中心性分析 (4 种指标)
├── algo/community/          # 社区检测 (Louvain + LP)
├── io/dot.mbt              # DOT 格式 I/O
├── io/json_serializer.mbt  # JSON 序列化
└── utils/graph_stats.mbt   # 图统计工具

预计新增: ~220 tests (总计 ~771)
```

### v1.0.0+: 架构增强方向

#### 方向 A: 性能优化层

```
lib/
├── storage/
│   ├── concurrent_adj_list.mbt  # [NEW] 并发安全邻接表
│   └── memory_mapped_graph.mbt # [NEW] 内存映射大图
└── algo/
    └── parallel/               # [NEW] 并行算法
        ├── parallel_bfs.mbt
        └── parallel_pagerank.mbt
```

#### 方向 B: 序列化与 I/O 层

```
lib/
├── io/
│   ├── dot.mbt                 # ✅ DOT 格式 (v0.11.0)
│   ├── json_serializer.mbt     # ✅ JSON (v0.11.0)
│   ├── graphml.mbt             # [FUTURE] GraphML (XML)
│   └── binary_format.mbt       # [FUTURE] 二进制格式
└── viz/
    └── renderer.mbt            # [FUTURE] 图可视化输出
```

#### 方向 C: 高级算法层

```
lib/algo/
├── advanced_path/              # [FUTURE]
│   ├── a_star.mbt              # A* 启发式搜索 (v0.12.0)
│   └── johnson.mbt             # Johnson 全源最短路径 (v0.12.0)
├── advanced_flow/              # [FUTURE]
│   └── min_cost_max_flow.mbt   # 最小费用最大流 (v0.12.0)
├── advanced_matching/          # [FUTURE]
│   ├── hopcroft_karp.mbt       # Hopcroft-Karp (v0.12.0)
│   └── edmonds_matching.mbt    # 一般图匹配 (v0.12.0)
└── ml/                         # [FUTURE] v1.1.0+
    ├── node2vec.mbt            # 图嵌入
    └── community_detection/
        └── louvain.mbt         # (已在 v0.10.0 规划)
```

#### 方向 D: Trait 扩展 (可能性评估)

```
潜在新 Trait:
├── GraphWeighted              # 加权图专用方法
│   ├── edge_weight(u, v)      # 获取边权重
│   └── weighted_neighbors(u)  # 带权的邻居列表
├── GraphMutable               # 可变视图（借用语义）
│   └── borrow_mut()           # 获取可变引用
└── GraphParallel              # 并行图操作
    ├── par_for_each_node()    # 并行节点遍历
    └── par_map_edges()        # 并行边映射
```

**⚠️ 注意**: 这些是探索方向，非承诺功能。具体实现取决于：
- MoonBit 语言特性演进（如并发支持）
- 社区需求反馈
- 性能基准测试结果

---

## ⚙️ 关键设计决策记录

### 决策 1: 为什么选择 6 层 Trait 而非单一接口？

**选项对比**:
- A: 单一 `Graph` trait（所有方法）→ ❌ CSR 无法实现 `add_edge()`
- B: 可选方法 + default impl → ❌ MoonBit 不支持 trait default method
- C: 多层继承 → ✅ **最终选择**

**理由**:
- 符合 LSP 原则（里氏替换）
- 符合 ISP 原则（接口隔离）
- 存储只需实现必要接口
- 编译期类型安全检查

### 决策 2: 为什么算法使用独立类型而非适配 Graph trait？

**场景**: 流网络 (`FlowNetwork`)、二分图 (`BipartiteGraph`)

**理由**:
- 这些场景有**额外的语义约束**（容量/流量/左右分区）
- 强制适配 Graph trait 会引入**不必要的抽象泄漏**
- 独立类型可以**优化内部数据结构**（如流量矩阵连续存储）

**原则**: 当算法需要的操作超出（或不同于）标准图操作时，使用独立类型。

### 决策 3: 为什么无向图采用半存储优化？

**传统方式**: 无向边存两次 `(u,v)` 和 `(v,u)` → 空间浪费 50%

**mbtgraph 方式**:
- 邻接表: 只存 `id_u < id_v` 的边，查询时联合两个邻接表
- 矩阵: 只存上三角部分

**收益**: 无向图内存减半，代价是代码略复杂（已封装在 `shared_helpers.mbt`）

### 决策 4: 为什么测试采用双轨制？

| 测试类型 | 文件命名 | 目的 |
|---------|---------|------|
| **黑盒测试** | `*_test.mbt` | 验证公开 API 行为正确性 |
| **白盒测试** | `*_wbtest.mbt` | 验证内部实现细节正确性 |

**理由**:
- 黑盒测试保证**契约不变**
- 白盒测试帮助**调试复杂算法**
- 两者互补，提高信心

---

## 🔧 开发新模块的流程

### 标准模板（从 TODO.md TASK-001 衍生）

```
1️⃣ 创建目录结构
   mkdir lib/algo/new_module
   touch moon.pkg types.mbt algorithm.mbt algorithm_test.mbt

2️⃣ 定义类型 (types.mbt)
   pub(all) struct NewAlgorithmResult { ... }

3️⃣ 实现算法 (algorithm.mbt)
   pub fn[G : @core.GraphReadable] new_algorithm(graph : G, ...) -> NewAlgorithmResult

4️⃣ 编写测试 (algorithm_test.mbt)
   - 基础功能: 正常案例 (3-5 个)
   - 边界情况: 空图/单节点/不连通 (2-3 个)
   - 属性验证: 不可变性/一致性 (2-3 个)
   - 性能基准: 大图性能 (可选)

5️⃣ 编写文档 (README.md)
   - API 使用示例
   - 复杂度说明
   - 与竞品对比

6️⃣ 集成验证
   moon check lib/algo/new_module  # 编译通过
   moon test lib/algo/new_module   # 测试全过
   git commit -m "feat(algo): add new module"
```

---

## 📊 架构度量

| 度量项 | 当前值 | 目标值 (v1.0.0) |
|--------|:------:|:---------------:|
| Trait 层数 | **6** | 6-8 (可能新增) |
| 存储种类 | **8** | 8-10 |
| 算法模块数 | **12** | **15-18** |
| 平均模块测试数 | ~46 | ≥ 40 |
| Trait 方法覆盖率 | 100% | 100% |
| 存储间转换覆盖率 | 8/8 = 100% | 100% |
| 文档/API 比例 | ~90% | **100%** |

---

## 🚀 快速开始

### 安装

```bash
# 从源码构建 (需要 MoonBit 工具链)
git clone https://github.com/morning-start/mbtgraph.git
cd mbtgraph
moon build
```

### 第一个图算法

```moonbit
use @core.{NodeId, DirectedAdjList}
use @algo::traversal::{bfs, dfs}
use @algo::shortest_path::{dijkstra, bellman_ford, floyd_warshall}

fn main {
  let mut g = DirectedAdjList::new(4)
  let g = g.add_edge(NodeId(0), NodeId(1), 1.0)
  let g = g.add_edge(NodeId(1), NodeId(2), 2.0)
  let g = g.add_edge(NodeId(2), NodeId(3), 3.0)
  let g = g.add_edge(NodeId(0), NodeId(3), 10.0)

  let bfs_result = bfs(g, NodeId(0))
  let shortest = dijkstra(g, NodeId(0))
  println("BFS 访问顺序: ${bfs_result.visited}")
  println("最短距离: ${shortest.distances}")
}
```

---

<div align="center">

**🏗️ mbtgraph 架构总览 v1.1.0**

*基于 v1.1.0 实际代码 | 最后更新: 2026-06-21 | 下次评审: 2026-07-21*

</div>
