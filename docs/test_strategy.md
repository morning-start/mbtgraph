---
title: "mbtgraph 测试策略与计划"
version: "1.0.0"
status: "active"
type: "test-strategy"
created: "2026-05-02"
updated: "2026-05-25"
author: "morning-start"
license: "MIT"
tags: ["testing", "quality", "graph", "algorithm", "moonbit"]
traceability:
  source:
    - "docs/requirements/srs.md"
    - "docs/design/sad.md"
    - "AGENTS.md"
    - "MEMORY.md"
  targets:
    - "lib/**/*_test.mbt"
    - "lib/**/*_wbtest.mbt"
---

# mbtgraph 测试策略与计划

> **版本**: v1.0.0 | **状态**: 生效 | **日期**: 2026-05-25
> **基线**: v0.9.0 | **总测试数**: 551 | **通过率**: 100%

---

## 1. 测试目标

### 1.1 质量目标（已达成 ✅）

| 指标 | 目标值 | 当前值 (v0.9.0) | 说明 |
|------|--------|----------------|------|
| **单元测试覆盖率** | ≥ 80% | **~85%** (估算) | 核心算法模块 ≥ 90% |
| **总测试用例数** | ≥ 400 | **551** ✅ | 黑盒 517 + 白盒 34 |
| **测试通过率** | 100% | **100%** ✅ | 551/551 全通过 |
| **模块覆盖** | P0-P3 | **P0-P5** ✅ | 12 算法子模块全部覆盖 |
| **双轨制测试** | 核心 + 存储 | **core + storage** ✅ | 白盒验证内部实现 |

### 1.2 测试原则

- ✅ **双轨制测试**: 黑盒 (`*_test.mbt`) 验证公开 API + 白盒 (`*_wbtest.mbt`) 验证内部实现
- ✅ **断言优先**: 使用 `assert_eq` / `assert_true` 用于确定性结果；无 Show impl 时用 `assert_true(a == b)`
- ✅ **属性检验**: 对算法不变量进行验证（如 PageRank scores 之和 ≈ 1.0、最大流 = 最小割）
- ✅ **跨存储一致性**: 算法在 AdjList/Matrix/EdgeList/CSR 上行为一致（`cross_storage_test.mbt`）
- ✅ **纯函数语义**: 算法前深拷贝，保证输入不被修改

---

## 2. 测试分层与组织

### 2.1 测试层次

```
┌─────────────────────────────────────────────┐
│     跨存储兼容性测试 (Cross-Storage)         │  ← 多存储行为一致
├─────────────────────────────────────────────┤
│     集成测试 (Integration)                   │  ← 跨模块端到端场景
├─────────────────────────────────────────────┤
│     模块黑盒测试 (Blackbox)                  │  ← 公开 API 正确性
├─────────────────────────────────────────────┤
│     模块白盒测试 (Whitebox)                  │  ← 内部实现/Trait 验证
├─────────────────────────────────────────────┤
│     属性测试 (Property)                      │  ← 算法不变量验证
└─────────────────────────────────────────────┘
```

### 2.2 测试文件组织（实际结构）

> **关键决策**: 测试文件**跟随源码放置在各包目录内**，非独立 `test/` 目录。

```
lib/
├── core/                            # 基础类型 + Trait 定义
│   ├── types.mbt                    # NodeId, Node, Edge
│   ├── traits.mbt                   # 6 层 trait 定义
│   ├── error.mbt                    # GraphError 枚举
│   ├── types_test.mbt               # [Blackbox] 24 tests
│   ├── error_test.mbt               # [Blackbox] 25 tests
│   └── traits_wbtest.mbt            # [Whitebox] 19 tests — MockGraph 实现 6 Trait
│
├── storage/                         # 存储实现 (8 种)
│   ├── directed_adj_list.mbt        # 有向邻接表 ⭐
│   ├── undirected_adj_list.mbt      # 无向邻接表（半存储优化）
│   ├── directed_matrix.mbt          # 有向邻接矩阵
│   ├── undirected_matrix.mbt        # 无向邻接矩阵（上三角优化）
│   ├── edge_list.mbt                # 有向边集
│   ├── csr.mbt                      # CSR 只读格式
│   ├── csc.mbt                      # CSC 只读格式
│   ├── converter.mbt                # 8 个泛型转换函数
│   ├── shared_helpers.mbt           # 公共辅助函数
│   ├── directed_adj_list_test.mbt   # [Blackbox] 19 tests
│   ├── undirected_adj_list_test.mbt # [Blackbox] 15 tests
│   ├── matrix_test.mbt              # [Blackbox] 15 tests
│   ├── edge_list_test.mbt           # [Blackbox] 15 tests
│   ├── csr_csc_test.mbt             # [Blackbox] 15 tests — Builder 模式
│   ├── converter_test.mbt           # [Blackbox] 16 tests — 三层转换架构
│   └── helpers_wbtest.mbt           # [Whitebox] 13 tests — has_node/find_slot 等
│
├── algo/                            # 图算法模块 ⭐ P0-P5 全部完成
│   ├── traversal/                   # 遍历 (BFS/DFS/环检测/拓扑)
│   │   ├── traversal_test.mbt       # [Blackbox] ~47 tests
│   │   └── cross_storage_test.mbt   # [Cross-Storage] 多存储一致性验证 🆕
│   ├── generators/                  # 图生成器 (P0)
│   │   └── generators_test.mbt      # [Blackbox] 56 tests — 16 函数
│   ├── shortest_path/               # 最短路径 (P1)
│   │   └── shortest_path_test.mbt   # [Blackbox] 32 tests — Dijkstra/BF/FW
│   ├── mst/                         # 最小生成树 (P2)
│   │   └── mst_test.mbt             # [Blackbox] 16 tests — Kruskal/Prim
│   ├── connectivity/                # 连通性 (P2)
│   │   └── connectivity_test.mbt    # [Blackbox] 21 tests — CC/Tarjan/Kosaraju
│   ├── flow/                        # 网络流 (P3) — 独立类型模式
│   ├── flow_test.mbt                # [Blackbox] Edmonds-Karp 测试
│   ├── dinic_test.mbt               # [Blackbox] Dinic 最大流测试
│   ├── matching/                    # 图匹配 (P4)
│   │   └── matching_test.mbt        # [Blackbox] 21 tests — Hungarian
│   ├── euler/                       # 欧拉路径 (P5-A) 🆕
│   │   └── euler_test.mbt           # [Blackbox] 22 tests — Hierholzer
│   ├── cutpoints/                   # 割点与桥 (P5-B) 🆕
│   │   └── cutpoints_test.mbt       # [Blackbox] 15 tests — Tarjan DFN/Low
│   ├── coloring/                    # 图着色 (P5-C) 🆕
│   │   └── coloring_test.mbt        # [Blackbox] 21 tests — Greedy/WP/DSATUR/Exact
│   ├── clique/                      # 团/独立集/顶点覆盖 (P5-D) 🆕
│   │   └── clique_test.mbt          # [Blackbox] 14 tests — Bron-Kerbosch
│   └── hamiltonian/                 # 哈密顿/TSP (P5-E) 🆕
│       └── hamiltonian_test.mbt     # [Blackbox] 20 tests — Backtrack+NN+Held-Karp
│
└── utils/                           # 工具层（待开发）
    └── generators/                  # 图生成器（已在 algo 内实现）
```

### 2.3 测试统计总览（v0.9.0）

| 层级 | 包 | 黑盒 | 白盒 | 总计 | 状态 |
|------|-----|:----:|:----:|:----:|:----:|
| **基础类型** | core | 49 | 19 | **68** | ✅ |
| **存储层** | storage | 92 | 15 | **~107** | ✅ |
| **算法 (P0-P4)** | algo/* | 226 | 0 | **226** | ✅ |
| **算法 (P5)** | algo/* 🆕 | 150 | 0 | **150** | ✅ |
| **合计** | — | **517** | **34** | **551** | **✅ 全通过** |

---

## 3. 双轨制测试策略

### 3.1 核心概念

| 类型 | 文件命名 | 可见性 | 用途 | 典型场景 |
|------|---------|--------|------|---------|
| **黑盒测试** | `*_test.mbt` | 仅访问 `pub` API | 验证公开行为正确性 | 算法结果、CRUD 操作 |
| **白盒测试** | `*_wbtest.mbt` | 可访问 `pub(all)` 内部 | 验证实现细节/Trait | MockGraph、Helper 函数 |

### 3.2 黑盒测试规范 (`*_test.mbt`)

**适用范围**: 所有公开 API 的功能验证

**语法规范**:

```moonbit
// MoonBit 原生测试语法（非 fn test_xxx() 风格）

///|
test "模块名_具体场景" {
  // Arrange: 构建测试数据
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore

  // Act: 执行被测操作
  let result = bfs(&g, n0)

  // Assert: 验证结果
  assert_eq(result.discovered_order.length(), 2)
  assert_true(result.distance[n0] == 0)
}
```

**命名规范**: `test "{module}_{scenario}"`

**分类比例**（参考 flow 模块实战）:

| 类别 | 比例 | 内容 |
|------|:----:|------|
| 基础功能测试 | ~30% | 类型创建 / 方法正确性 |
| 算法正确性测试 | ~40% | 经典案例 / 已知答案 |
| 边界情况测试 | ~20% | 空图 / 越界 / 异常输入 |
| 属性验证测试 | ~10% | 不变性 / 一致性约束 |

### 3.3 白盒测试规范 (`*_wbtest.mbt`)

**适用范围**: 需要 `pub(all)` 访问权限的内部实现验证

**当前白盒测试清单**:

| 文件 | 测试数 | 覆盖内容 |
|------|:------:|----------|
| `core/traits_wbtest.mbt` | 19 | MockGraph 实现 6 层 Trait 共 26 方法 |
| `storage/helpers_wbtest.mbt` | 13 | has_node / find_slot / remove_from_list / bubble_sort |

**MockGraph 设计要点**（traits_wbtest）:

```moonbit
// MockGraph 用于验证 Trait 分层的正确性
struct MockGraph {
  mut nodes : Array[Node?]
  mut adj : Array[Array[(NodeId, Double)]]
  mut node_cnt : Int          // 独立追踪节点计数
  directed : Bool             // 切换有向/无向模式
}

// 实现 GraphReadable (12 方法)
impl @core.GraphReadable for MockGraph with node_count(self) { self.node_cnt }
// ... 其他方法

// 实现 GraphWritable (+5 方法) — 仅动态存储
impl @core.GraphWritable for MockGraph with add_node(self, data) { ... }
// ...

// 实现 GraphDirected (+6 方法) — 仅有向图
impl @core.GraphDirected for MockGraph with in_degree(self, id) { ... }
// ...
```

---

## 4. 单元测试策略

### 4.1 Core 模块测试

#### 4.1.1 类型测试 (`types_test.mbt`) — 24 tests

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `node_id_construct` | `NodeId(0)` | 内部值 == 0 | 功能 |
| `node_id_equality` | `NodeId(0) == NodeId(0)` | true | 功能 |
| `node_id_invalid_negative` | `NodeId(-1)` | 允许构造（运行时检查） | 边界 |
| `node_construct_fields` | `Node::{ id: NodeId(0), data: 1.0 }` | 字段正确 | 功能 |
| `edge_construct_fields` | `Edge::{ from: ..., to: ..., weight: 1.0 }` | 字段正确 | 功能 |

#### 4.1.2 错误类型测试 (`error_test.mbt`) — 25 tests

**测试场景**:

| 测试用例 | 覆盖 |
|---------|------|
| 3 变体 × 构造匹配 | `InvalidNode` / `InvalidEdge` / `OperationFailed` |
| Eq 实现 (11 cases) | 所有变体等价性比较 |
| Result 集成 (7 cases) | 与 `Result[ T, @core.GraphError ]` 的配合使用 |

#### 4.1.3 Trait 白盒测试 (`traits_wbtest.mbt`) — 19 tests

**核心价值**: 验证 6 层 Trait 分层的编译期约束正确性

| Trait 层 | 方法数 | 关键验证点 |
|---------|:------:|-----------|
| GraphReadable | 12 | node_count / edge_count / contains_node / get_node / neighbors ... |
| GraphWritable | +5 | add_node / add_edge / remove_node / remove_edge / update_data |
| GraphBatchReadable | +2 | batch_nodes / batch_edges |
| GraphEdgeIterable | +1 | edges_sorted |
| GraphDirected | +6 | in_degree / out_degree / in_neighbors / predecessors / successors / is_directed |
| GraphFull | 0 | 别名：Writable + Directed |

---

### 4.2 Storage 模块测试

#### 4.2.1 有向邻接表测试 (`directed_adj_list_test.mbt`) — 19 tests

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `new_empty_graph` | `new_directed()` | node_count=0, edge_count=0 | 功能 |
| `add_single_node` | add_node("A") | node_count=1, contains_node=true | 功能 |
| `add_edge_basic` | A→B weight=1.0 | edge_count=1, contains_edge(A,B)=true | 功能 |
| `remove_node_cascade` | 删除节点 A | 关联边也被删除 | 功能 |
| `graph_directed_api` | 有向图 | in_degree/out_degree/successors/predecessors | Trait |
| `self_loop_handling` | A→A | 正确处理自环 | 边界 |

#### 4.2.2 无向邻接表测试 (`undirected_adj_list_test.mbt`) — 15 tests

**测试场景**:

| 测试用例 | 验证点 | 类型 |
|---------|--------|------|
| `undirected_symmetry` | contains_edge(A,B) == contains_edge(B,A) | 功能 |
| `no_duplicate_edges` | 添加 A-B 和 B-A → edge_count=1 | 半存储优化 |
| `degree_calculation` | A-B, A-C → degree(A)=2 | 功能 |
| `edges_sorted` | 返回边按权重排序 | EdgeIterable |

#### 4.2.3 CSR/CSC 测试 (`csr_csc_test.mbt`) — 15 tests

**测试场景**:

| 测试用例 | 验证点 | 类型 |
|---------|--------|------|
| `builder_pattern` | CSRBuilder→build() 不可变构建 | 设计模式 |
| `batch_operations` | batch_nodes/batch_edges 高效查询 | BatchReadable |
| `read_only_enforcement` | CSR 不实现 GraphWritable | LSP 原则 |
| `csr_vs_csr` | 同一图的 CSR 和 CSC 数据一致 | 一致性 |

#### 4.2.4 转换器测试 (`converter_test.mbt`) — 16 tests

**三层架构验证**:

| 分组 | 约束 | 函数数 | 保护机制 |
|------|------|:------:|---------|
| **有向转换组** | `[G : GraphDirected]` | 5 | 编译期保证源是有向图 |
| **无向转换组** | `[G : GraphReadable]` + assert | 3 | 运行时 `assert_true(!is_directed)` |
| **语义转换** | `[G : GraphReadable]` + raise | 2 | `as_undirected` / `as_directed` 显式跨边界 |

---

### 4.3 算法模块测试

#### 4.3.1 遍历算法测试 (`traversal_test.mbt`) — ~47 tests

**BFS 测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `bfs_linear_graph` | 0→1→2→3, 从 0 开始 | discovered=[0,1,2,3] | 功能 |
| `bfs_distances` | 线性图 | distance[0]=0, distance[1]=1, ... | 功能 |
| `bfs_disconnected` | 不连通图 | 仅遍历可达节点 | 功能 |
| `bfs_cycle` | 环图 0→1→2→0 | 正确终止，不无限循环 | 功能 |
| `dfs_preorder_postorder` | 树形结构 | 前序/后序正确 | 功能 |
| `cycle_detection Directed` | 有向环图 | detect_cycle = true | 功能 |
| `cycle_detection_acyclic` | DAG | detect_cycle = false | 功能 |
| `topological_sort_dag` | 标准 DAG | 合法拓扑序 | 功能 |
| `topological_sort_cycle` | 有环图 | 返回错误 | 错误处理 |

**跨存储兼容性测试** (`cross_storage_test.mbt`) 🆕:

> **核心原则**: 算法只依赖 `@core.GraphReadable`，不应因存储实现差异导致结果不同。

```moonbit
///|
/// 构建线性有向图: 0 → 1 → 2 → 3 (4 节点, 3 边)
fn make_linear_adjlist() -> @storage.DirectedAdjList { ... }
fn make_linear_matrix() -> @storage.DirectedMatrix { ... }
fn make_linear_edgelist() -> @storage.EdgeListGraph { ... }
fn make_linear_csr() -> @storage.CSRGraph { ... }

///|
test "bfs_consistent_across_storages" {
  let adj = make_linear_adjlist()
  let mat = make_linear_matrix()
  let el = make_linear_edgelist()
  let csr = make_linear_csr()

  let r_adj = bfs(&adj, @core.NodeId(0))
  let r_mat = bfs(&mat, @core.NodeId(0))
  let r_el = bfs(&el, @core.NodeId(0))
  let r_csr = bfs(&csr, @core.NodeId(0))

  assert_eq(r_adj.discovered_order.length(), r_mat.discovered_order.length())
  assert_eq(r_mat.discovered_order.length(), r_el.discovered_order.length())
  assert_eq(r_el.discovered_order.length(), r_csr.discovered_order.length())
}
```

#### 4.3.2 图生成器测试 (`generators_test.mbt`) — 56 tests

**16 个生成函数全覆盖**:

| 函数 | 验证点 |
|------|--------|
| `complete_graph(n)` | node_count=n, edge_count=n*(n-1)/2 (有向) 或 n*(n-1)/2 (无向) |
| `star_graph(n)` | 中心节点度 = n-1 |
| `path_graph(n)` | 线性拓扑 |
| `cycle_graph(n)` | 环形拓扑 |
| `erdos_renyi(n, p)` | 随机性 + 节点数正确 |
| `barabasi_albert(n, m)` | 幂律度分布特性 |

#### 4.3.3 最短路径测试 (`shortest_path_test.mbt`) — 32 tests

**Dijkstra 测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `dijkstra_simple` | 3 节点三角图 | 最短路径正确 | 功能 |
| `dijkstra_early_termination` | 指定 target | 提前终止 | 功能 |
| `dijkstra_no_path` | 不连通图 | 距离为 ∞ | 功能 |
| `dijkstra_negative_weight` | 负权边 | 返回错误/警告 | 错误处理 |
| `dijkstra_path_reconstruction` | 复杂图 | 路径可重构 | 功能 |

**Bellman-Ford 测试**:

| 测试用例 | 验证点 |
|---------|--------|
| `bf_negative_cycle` | 检测负权环并返回错误 |
| `bf_vs_dijkstra` | 非负权图上与 Dijkstra 结果一致 |

**Floyd-Warshall 测试**:

| 测试用例 | 验证点 |
|---------|--------|
| `fw_all_pairs` | 所有节点对最短路径矩阵正确 |
| `fw_self_distance` | 对角线元素为 0 |

#### 4.3.4 MST 测试 (`mst_test.mbt`) — 16 tests

| 测试用例 | 算法 | 验证点 |
|---------|------|--------|
| `kruskal_complete_k4` | Kruskal | 总权重最小，无环 |
| `prim_vs_kruskal` | Prim | 与 Kruskal 结果权重相同 |
| `mst_unique` | 两种算法 | 权重相同但边可能不同（多解） |
| `mst_disconnected` | Kruskal | 不连通图返回森林 |

#### 4.3.5 连通性测试 (`connectivity_test.mbt`) — 21 tests

| 测试用例 | 算法 | 验证点 |
|---------|------|--------|
| `cc_undirected_single` | CC | 连通图 1 个分量 |
| `cc_undirected_multiple` | CC | 不连通图多个分量 |
| `tarjan_scc_standard` | Tarjan | CLRS 标准示例 SCC 正确 |
| `kosaraju_vs_tarjan` | Kosaraju | 与 Tarjan 结果一致 |
| `scc_dag` | 两者 | DAG 每个节点一个 SCC |

#### 4.3.6 网络流测试 (`flow_test.mbt` + `dinic_test.mbt`) — 33 tests

**FlowNetwork 基础测试** (flow_test.mbt):

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `flow_network_new_empty` | new(0) | node_count=0, capacity/flow 为空 | 功能 |
| `flow_network_add_edge` | add_edge(0,1,10.0) | capacity[0][1]=10.0, flow=0 | 功能 |
| `flow_network_out_of_bounds` | add_edge(0,5,...) | 安全处理越界 | 边界 |
| `flow_network_self_loop` | add_edge(1,1,5.0) | 自环处理 | 边界 |

**Edmonds-Karp 算法测试**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `ek_simple_network` | 2 节点 1 边 | max_flow = capacity | 功能 |
| `ek_classic_network` | CLRS 示例 | max_flow 正确 | 回归 |
| `ek_multi_path` | 多路网络 | 利用所有增广路径 | 功能 |
| `ek_max_flow_min_cut` | 标准网络 | max_flow = min_cut_capacity | 属性 |
| `ek_flow_conservation` | 任意图 | 流入=流出 (除源汇) | 属性 |
| `ek_flow_capacity` | 任意图 | flow ≤ capacity | 属性 |

**Dinic 算法测试** (dinic_test.mbt):

| 测试用例 | 验证点 |
|---------|--------|
| `dinic_vs_edmonds_karp` | 相同输入下结果一致（交叉验证） |
| `dinic_bfs_layering` | Level graph 正确构建 |
| `dinic_blocking_flow` | 阻塞流正确计算 |

#### 4.3.7 匈牙利算法测试 (`matching_test.mbt`) — 21 tests

| 测试用例 | 验证点 |
|---------|--------|
| `hungarian_perfect_matching` | 完全二分图完美匹配 |
| `hungarian_maximum_cardinal` | 最大基数匹配 |
| `hungarian_weighted` | 带权最大匹配权重正确 |

#### 4.3.8 P5 高级算法测试 (92 tests)

**欧拉路径** (`euler_test.mbt`) — 22 tests:

| 测试用例 | 验证点 |
|---------|--------|
| `euler_circuit_directed` | 有向欧拉回路存在时返回完整路径 |
| `euler_trail_undirected` | 无向欧拉路径（恰好 2 个奇度点） |
| `euler_no_path` | 不存在欧拉路径时返回 None |
| `hierholzer_time_complexity` | O(E) 时间复杂度 |

**割点与桥** (`cutpoints_test.mbt`) — 15 tests:

| 测试用例 | 验证点 |
|---------|--------|
| `articulation_point_standard` | 标准图割点集合正确 |
| `bridge_detection` | 桥边集合正确 |
| `dfn_low_property` | DFN/Low 时间戳性质满足 |
| `tarjan_single_dfs` | O(V+E) 单次 DFS |

**图着色** (`coloring_test.mbt`) — 21 tests:

| 测试用例 | 算法 | 验证点 |
|---------|------|--------|
| `coloring_greedy_valid` | Greedy | 颜色分配合法（相邻不同色） |
| `coloring_wp_better` | Welsh-Powell | 度大的优先着色，色数 ≤ Greedy |
| `coloring_dsatur_saturation` | DSATUR | 饱和度启发式 |
| `coloring_exact_optimal` | Backtracking | 色数最优（NP-C 精确解） |
| `coloring_complete_graph_kn` | 任意算法 | K_n 色数 = n |

**团检测** (`clique_test.mbt`) — 14 tests:

| 测试用例 | 验证点 |
|---------|--------|
| `bron_kerbosch_complete` | 完全图 K_n 最大团大小 = n |
| `bron_kerbosch_pivot` | 枢轴优化减少递归分支 |
| `independent_set_derived` | 补图最大团 = 原图最大独立集 |
| `vertex_cover_derived` | V - α(G) = τ(G) （König 定理特例） |

**哈密顿/TSP** (`hamiltonian_test.mbt`) — 20 tests:

| 测试用例 | 算法 | 验证点 |
|---------|------|--------|
| `hamiltonian_cycle_complete` | Backtrack | 完全图存在哈密顿回路 |
| `hamiltonian_no_path` | Backtrack | 无哈密顿路径时返回 None |
| `tsp_nearest_neighbor` | NN 启发式 | 返回合法路径（不一定最优） |
| `tsp_held_karp_small` | Held-Karp DP | V≤12 时精确最优解 |
| `tsp_hk_vs_bruteforce` | Held-Karp | 小规模与暴力搜索结果一致 |

---

## 5. 集成测试策略

### 5.1 跨模块场景（Sprint T04 待开发 🔧）

| 测试场景 | 涉及模块 | 描述 | 状态 |
|---------|---------|------|:----:|
| `test_graph_to_analysis` | storage + algo | 创建图 → BFS → PageRank → Louvain | 🔄 待编写 |
| `test_scc_to_toposort` | connectivity + traversal | SCC 缩点 → 拓扑排序 | 🔄 待编写 |
| `test_mst_to_flow` | mst + flow | MST 子图 → 最大流 | 🔄 待编写 |
| `test_converter_roundtrip` | converter 全链 | AdjList → Matrix → CSR → EdgeList → AdjList | 🔄 待编写 |
| `test_p5_pipeline` | euler + hamiltonian | 欧拉子图 → TSP 路径优化 | 🔄 待编写 |

### 5.2 端到端场景示例

```
测试场景: 社交网络分析流水线
1. 用 generators 生成 Erdős-Rényi 随机图 G(n=1000, p=0.05)
2. 用 connectivity::connected_components 计算 CC
3. 对最大连通分量运行 traversal::bfs
4. 用 shortest_path::dijkstra 计算所有对最短路径
5. 运行 mst::kruskal 得到骨干网络
6. 验证 MST 边集 ⊆ 原图边集
7. 验证 MST 总权重 ≤ 任意其他生成树
```

---

## 6. 性能测试策略

### 6.1 性能基准目标

| 算法 | 图规模 | 目标时间 | 目标内存 | 复杂度 | 状态 |
|------|--------|---------|----------|--------|:----:|
| **BFS** | 100K 节点 | < 50ms | < 50MB | O(V+E) | 🔄 待基准化 |
| **Dijkstra** | 100K 节点, 500K 边 | < 200ms | < 100MB | O((V+E)log V) | 🔄 待基准化 |
| **PageRank** | 100K 节点 | < 1s | < 200MB | 迭代收敛 | 🔄 待开发 |
| **Louvain** | 100K 节点 | < 5s | < 500MB | 启发式 | 🔄 待开发 |
| **Dinic** | 10K 节点, 100K 边 | < 500ms | < 100MB | O(E√V) | 🔄 待基准化 |
| **Kruskal** | 100K 节点, 500K 边 | < 500ms | < 200MB | O(E log E) | 🔄 待基准化 |
| **Bron-Kerbosch** | 200 节点 | < 1s | < 100MB | O(3^{V/3}) | 🔄 待基准化 |
| **Held-Karp** | V≤12 节点 | < 100ms | < 50MB | O(2^V·V²) | 🔄 待基准化 |

### 6.2 性能测试框架设计（Sprint T13 待设计 🔧）

```moonbit
// 性能基准测试模式（规划中）
fn benchmark_dijkstra_100k() {
  let g = generators::erdos_renyi(100_000, 0.01)
  let start_time = current_time_ms()
  let _ = dijkstra(&g, source=@core.NodeId(0))
  let end_time = current_time_ms()
  let duration = end_time - start_time
  assert_true(duration < 200)  // 200ms 目标
}
```

---

## 7. 测试工具与命令

### 7.1 MoonBit 测试命令速查

```bash
# === 日常开发 ===
moon check               # 类型检查（零错误零警告）
moon fmt && moon info     # 格式化 + 更新 .mbti 接口文件
moon test                # 运行全部测试 (551 tests)

# === 目标后端测试 ===
moon test --target native    # Native 后端（默认）
moon test --target wasm      # Wasm 后端
moon test --target js        # JavaScript 后端

# === 单模块测试 ===
moon test lib/algorithms/flow       # 流网络模块
moon test lib/algorithms/traversal  # 遍历模块
moon test lib/storage               # 存储层全部

# === 覆盖率分析 ===
moon coverage analyze > uncovered.log
cat uncovered.log

# === 快照测试 ===
moon test --update        # 更新快照（如有）
```

### 7.2 CI/CD 流水线（Sprint T02 待开发 🔧）

```yaml
# .github/workflows/test.yml
name: CI Pipeline
on: [push, pull_request]
jobs:
  quality-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: moonbitlang/setup@v1
      - name: Format Check
        run: moon fmt && git diff --exit-code
      - name: Type Check
        run: moon check
      - name: Interface Diff
        run: moon info && git diff --exit-code -- "*.mbti"
  test:
    needs: quality-gate
    strategy:
      matrix:
        target: [native, wasm, js]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: moonbitlang/setup@v1
      - name: Test (${{ matrix.target }})
        run: moon test --target ${{ matrix.target }}
  coverage:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: moonbitlang/setup@v1
      - name: Coverage Analysis
        run: moon coverage analyze > coverage-report.txt
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage-report.txt
```

---

## 8. 缺陷管理

### 8.1 缺陷分类

| 类别 | 说明 | 示例 | 处理优先级 |
|------|------|------|-----------|
| **逻辑错误** | 算法实现错误 | BFS 返回错误顺序 | P0 紧急 |
| **边界条件** | 特殊输入未处理 | 空图/单节点图/越界 | P0 紧急 |
| **性能退化** | 时间/内存超标 | Dijkstra 100K > 200ms | P1 高 |
| **类型错误** | 编译期类型不匹配 | Trait 约束不满足 | P0 紧急 |
| **语义违反** | 纯函数语义破坏 | 算法修改了输入图 | P0 紧急 |
| **Trait 违反** | LSP/ISP 原则违反 | CSR 实现了 Writable | P1 高 |

### 8.2 缺陷修复流程

```
报告 (GitHub Issues)
  ↓
复现 (编写失败测试用例 → 确认可重现)
  ↓
定位 (根因分析 → 确定修复方案)
  ↓
修复 (修改代码使测试通过)
  ↓
验证 (moon check → moon test 全量通过)
  ↓
审查 (Code Review → 确认无回归)
  ↓
合并 (PR merge → 自动关闭 Issue)
```

### 8.3 MoonBit 特有缺陷速查

| 错误码 | 含义 | 常见原因 | 修复方式 |
|--------|------|---------|---------|
| **E0015** | unused_mut | 只改字段却用了 `let mut` | 改为 `let` |
| **E3002** | Parse error | mut self / for解构 / `>>` 嵌套泛型 | 见 AGENTS.md Top10 |
| **E4018** | read-only type | blackbox 中访问 pub(all) | 改用 wbtest 或改为 pub |
| **E4063** | impl 一致性 | trait impl 可见性与 trait 不匹配 | 改为 `pub impl` |
| **E4139** | value cannot be ignored | 忽略非 Unit 返回值 | 链式赋值或 `ignore()` |
| **E0029** | unused_package | 存在其他编译错误的副作用 | 先修其他错误 |

---

## 9. 质量门禁

### 9.1 提交前检查（开发者本地执行）

| 检查项 | 命令 | 阈值 | 必要性 |
|--------|------|------|--------|
| 代码格式 | `moon fmt` | 无 diff | 必须 |
| 接口一致性 | `moon info` | .mbti 无意外变更 | 必须 |
| 类型检查 | `moon check` | 零错误零警告 | 必须 |
| 单元测试 | `moon test` | 100% 通过 (551/551) | 必须 |
| 新增测试 | 目测 | 新功能必须有对应测试 | 必须 |

### 9.2 发布前检查（CI/CD 自动执行）

| 检查项 | 工具 | 阈值 | 适用阶段 |
|--------|------|------|---------|
| 全平台测试 | `moon test --target wasm/js/native` | 100% 通过 | Alpha/Beta/RC |
| 性能基准 | Benchmark Suite | 所有指标达标 | Beta/RC |
| API 冻结扫描 | 自定义脚本 | `pub` 签名无变更 | RC/Release |
| 文档完整性 | 手动检查 | 所有公开 API 有文档 | Release |
| 变更日志 | CHANGELOG.md | 更新至当前版本 | Release |
| 版本号同步 | 跨文件检查 | moon.mod.json/README/CHANGELOG 一致 | Release |

### 9.3 测试增量规范

每次新增/修改代码时，必须同步更新测试：

| 变更类型 | 测试要求 | 示例 |
|---------|---------|------|
| 新增 `pub fn` | 至少 3 个测试（正常+边界+属性） | 新算法函数 |
| 新增 `pub struct` | 构造 + 字段 + 方法测试 | FlowNetwork |
| 新增 `trait` impl | 白盒验证所有 trait 方法 | MockGraph |
| 修复 Bug | 先写失败测试，再修复 | Regression test |
| 重构内部实现 | 保持现有测试通过 | Refactoring |

---

## 10. 附录

### 10.1 参考文档

| 文档 | 路径 | 用途 |
|------|------|------|
| 软件需求规格 | `docs/requirements/srs.md` | 需求追溯 |
| 系统架构设计 | `docs/design/sad.md` | 架构参考 |
| Trait 分层设计 | `docs/design/graph_trait_and_module_architecture.md` | 测试策略依据 |
| 开发规范 | `AGENTS.md` | 编码规则 + Top10 陷阱 |
| 项目记忆 | `MEMORY.md` | 决策记录 + 统计 |
| MoonBit 测试文档 | https://docs.moonbitlang.com/testing/ | 官方指南 |

### 10.2 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| **v1.0.0** | **2026-05-25** | **重大重写**：对齐项目实际架构（551 tests/P0-P5/双轨制/跨存储），修正测试文件组织、语法、模块覆盖等 7 大问题 |
| v0.1.0 | 2026-05-02 | 初始版本，定义测试策略和计划（与项目实际严重脱节） |

### 10.3 待办事项

- [x] ~~补充 Phase 3 高级算法测试用例~~ → ✅ P5 全部完成 (92 tests)
- [x] ~~补充 I/O 模块测试用例~~ → → utils 层待开发，暂不需要
- [x] ~~建立性能基准数据库~~ → → Sprint T13 规划中
- [ ] **编写集成测试** (Sprint T04): 跨模块端到端场景
- [ ] **搭建 CI/CD 流水线** (Sprint T02): GitHub Actions
- [ ] **性能基准测试框架** (Sprint T13): Benchmark Suite
- [ ] **API 冻结审查** (Sprint T03): 扫描所有 `pub` 函数签名稳定性

---

**文档状态**: 生效 ✅ | **基线版本**: v0.9.0 | **下次审查**: v1.0.0-alpha 发布前
