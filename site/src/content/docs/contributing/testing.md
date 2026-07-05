---
title: 测试策略与规范
description: mbtgraph 的双轨测试体系、测试分层、模块测试场景和 CI/CD 集成
---

> **测试基线**: v0.1.1 | **总测试数**: 768 | **通过率**: 100%

---

## 1. 测试目标

### 质量目标 (已达成 ✅)

| 指标 | 目标 | 当前值 |
|------|:----:|:------:|
| 单元测试覆盖率 | ≥ 80% | **~85%** |
| 总测试用例数 | ≥ 400 | **768** ✅ |
| 测试通过率 | 100% | **100%** ✅ |
| 模块覆盖 | P0-P3 | **P0-P5** ✅ |
| 双轨制测试 | core + storage | **core + storage + algo** ✅ |

### 测试原则

- ✅ **断言优先**: 使用 `assert_eq` / `assert_true` 用于确定性结果
- ✅ **属性检验**: 验证算法不变量（如 PageRank scores 之和 ≈ 1.0、最大流 = 最小割）
- ✅ **跨存储一致性**: 算法在 AdjList/Matrix/EdgeList/CSR 上行为一致
- ✅ **纯函数语义**: 算法前深拷贝，保证输入不被修改

---

## 2. 双轨制测试体系

### 核心概念

| 类型 | 文件命名 | 可见性 | 用途 | 典型场景 |
|------|---------|--------|------|---------|
| **黑盒测试** | `*_test.mbt` | 仅访问 `pub` API | 验证公开行为正确性 | 算法结果、CRUD 操作 |
| **白盒测试** | `*_wbtest.mbt` | 可访问 `pub(all)` 内部 | 验证实现细节/Trait | MockGraph、Helper 函数 |

### 黑盒测试规范

```moonbit
///|
test "模块名_具体场景" {
  // Arrange: 构建测试数据
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore

  // Act: 执行被测操作
  let result = bfs(g, n0)

  // Assert: 验证结果
  assert_eq(result.discovered_order.length(), 2)
  assert_true(result.distance[n0] == 0)
}
```

**命名规范**: `test "{module}_{scenario}"`

### 白盒测试规范

**当前白盒测试清单**:

| 文件 | 测试数 | 覆盖内容 |
|------|:------:|----------|
| `core/traits_wbtest.mbt` | 19 | MockGraph 实现 5 层 Trait 共 26 方法 |
| `storage/helpers_wbtest.mbt` | 13 | has_node / find_slot / remove_from_list / bubble_sort |

**MockGraph 设计要点**:

```moonbit
// MockGraph 用于验证 Trait 分层的编译期约束正确性
struct MockGraph {
  mut nodes : Array[Node?]
  mut adj : Array[Array[(NodeId, Double)]]
  mut node_cnt : Int
  directed : Bool
}

// 实现 GraphReadable (12 方法)
impl @core.GraphReadable for MockGraph with node_count(self) { self.node_cnt }
impl @core.GraphWritable for MockGraph with add_node(self, data) { ... }
impl @core.GraphDirected for MockGraph with in_degree(self, id) { ... }
```

---

## 3. 测试分层

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

### 测试文件结构

测试文件**跟随源码放置在各包目录内**：

```
lib/
├── core/
│   ├── types.mbt                    # NodeId, Node, Edge
│   ├── traits.mbt                   # 5 层 trait 定义
│   ├── error.mbt                    # GraphError 枚举
│   ├── types_test.mbt               # [Blackbox] 24 tests
│   ├── error_test.mbt               # [Blackbox] 25 tests
│   └── traits_wbtest.mbt            # [Whitebox] 19 tests
│
├── storage/
│   ├── directed_adj_list.mbt        # 有向邻接表 ⭐
│   ├── directed_adj_list_test.mbt   # [Blackbox] 19 tests
│   ├── matrix_test.mbt              # [Blackbox] 15 tests
│   ├── csr_csc_test.mbt             # [Blackbox] 15 tests
│   ├── converter_test.mbt           # [Blackbox] 16 tests
│   └── helpers_wbtest.mbt           # [Whitebox] 13 tests
│
├── algo/
│   ├── traversal/
│   │   ├── traversal_test.mbt       # [Blackbox] ~47 tests
│   │   └── cross_storage_test.mbt   # [Cross-Storage] 🆕
│   ├── shortest_path/
│   │   └── shortest_path_test.mbt   # [Blackbox] 32 tests
│   ├── flow/
│   │   ├── flow_test.mbt            # [Blackbox] EK 测试
│   │   └── dinic_test.mbt           # [Blackbox] Dinic 测试
│   └── ... (各算法模块)
└── utils/
    └── generators/
        └── generators_test.mbt      # [Blackbox] 56 tests
```

---

## 4. 测试统计总览

| 层级 | 包 | 黑盒 | 白盒 | 总计 |
|------|:---:|:----:|:----:|:----:|
| **基础类型** | core | 49 | 19 | **68** |
| **存储层** | storage | 92 | 15 | **~107** |
| **算法 (P0-P4)** | algo/* | 226 | 0 | **226** |
| **算法 (P5)** | algo/* | 150 | 0 | **150** |
| **高级算法** | pagerank/centrality/community | 65 | 0 | **65** |
| **链接预测/稠密子图** | link_prediction/dense_subgraph | ~48 | 0 | **48** |
| **图算子/图识别** | operators/recognition | ~55 | 0 | **55** |
| **I/O** | io | ~42 | 0 | **42** |
| **集成测试** | integration | ~60 | 0 | **60** |
| **其他** | 生成器/哈密顿 | ~76 | 0 | **76** |
| **合计** | — | **~730** | **~37** | **768** |

---

## 5. 模块测试场景

### 5.1 Core 模块测试

| 文件 | 测试数 | 测试内容 |
|------|:------:|----------|
| `types_test.mbt` | 24 | NodeId 构造/等价/无效值；Node/Edge 字段正确性 |
| `error_test.mbt` | 25 | 3 种错误变体构造匹配、Eq 实现、Result 集成测试 |
| `traits_wbtest.mbt` | 19 | MockGraph 实现 5 层 Trait 共 26 方法 |

### 5.2 Storage 模块测试

| 测试文件 | 测试数 | 关键验证点 |
|----------|:------:|-----------|
| `directed_adj_list_test.mbt` | 19 | 图 CRUD、有向图 API、自环处理 |
| `undirected_adj_list_test.mbt` | 15 | 无向对称性、半存储优化（无重复边）、度数计算 |
| `matrix_test.mbt` | 15 | 稠密图创建、O(1) 访问正确性 |
| `csr_csc_test.mbt` | 15 | Builder 模式、batch_operations、只读强制（LSP 原则）|
| `converter_test.mbt` | 16 | 三层转换架构：有向/无向/语义转换 |
| `helpers_wbtest.mbt` | 13 | has_node / find_slot / remove_from_list |

### 5.3 算法模块测试

#### 遍历 (~47 tests)

| 测试用例 | 说明 |
|---------|------|
| `bfs_linear_graph` | 线性图 BFS 顺序正确 |
| `bfs_distances` | 距离计算正确 |
| `bfs_disconnected` | 不连通图仅遍历可达节点 |
| `cycle_detection` | 有向/无向环检测 |
| `topological_sort` | DAG 拓扑序、有环图报错 |

**跨存储兼容性测试**:

```moonbit
///|
test "bfs_consistent_across_storages" {
  let adj = make_linear_adjlist()
  let mat = make_linear_matrix()
  let el  = make_linear_edgelist()
  let csr = make_linear_csr()

  let r_adj = bfs(&adj, @core.NodeId(0))
  let r_mat = bfs(&mat, @core.NodeId(0))
  let r_el  = bfs(&el,  @core.NodeId(0))
  let r_csr = bfs(&csr, @core.NodeId(0))

  assert_eq(r_adj.discovered_order.length(), r_mat.discovered_order.length())
  assert_eq(r_mat.discovered_order.length(), r_el.discovered_order.length())
  assert_eq(r_el.discovered_order.length(),  r_csr.discovered_order.length())
}
```

#### 最短路径 (~80 tests)

| 测试用例 | 算法 | 验证点 |
|---------|------|--------|
| `dijkstra_simple` | Dijkstra | 3 节点三角图最短路径 |
| `dijkstra_early_termination` | Dijkstra | 指定 target 提前终止 |
| `dijkstra_negative_weight` | Dijkstra | 负权边返回错误 |
| `bf_negative_cycle` | Bellman-Ford | 检测负权环 |
| `bf_vs_dijkstra` | Bellman-Ford | 非负权图与 Dijkstra 一致 |
| `fw_all_pairs` | Floyd-Warshall | 全源最短路径矩阵正确 |

#### MST (16 tests)

| 测试用例 | 验证点 |
|---------|--------|
| `kruskal_complete_k4` | 总权重最小，无环 |
| `prim_vs_kruskal` | 与 Kruskal 权重一致 |
| `mst_disconnected` | 不连通图返回森林 |

#### 网络流 (~45 tests)

| 测试用例 | 算法 | 验证点 |
|---------|------|--------|
| `ek_simple_flow` | Edmonds-Karp | 标准 4 节点网络 |
| `dinic_vs_ek` | Dinic | 与 EK 结果一致 |
| `mcmf_basic` | Min-Cost Max-Flow | 带费用的流量优化 |
| `stoer_wagner_simple` | Stoer-Wagner | 全局最小割正确性 |

### 5.4 测试分类比例

| 类别 | 比例 | 内容 |
|------|:----:|------|
| 基础功能测试 | ~30% | 类型创建 / 方法正确性 |
| 算法正确性测试 | ~40% | 经典案例 / 已知答案 |
| 边界情况测试 | ~20% | 空图 / 越界 / 异常输入 |
| 属性验证测试 | ~10% | 不变性 / 一致性约束 |

---

## 6. 断言方式

| 方式 | 函数 | 适用场景 |
|------|------|---------|
| **布尔断言** | `assert_eq(a, b)` | 简单值比较 |
| **布尔断言** | `assert_true(cond)` | 条件验证 |
| **快照测试** | `inspect(value, content="...")` | 复杂结构输出 |
| **错误测试** | `inspect` 错误结果 | 异常处理验证 |

---

## 7. 运行测试

```bash
# 全量测试
moon test

# 单模块测试
moon test lib/algo/pagerank

# 更新快照
moon test --update

# 覆盖率分析
moon coverage analyze
moon coverage report              # 生成 HTML 报告
```

---

## 8. CI/CD 集成

GitHub Actions 自动执行：

```yaml
# 每次 push 自动运行：
# 1. moon fmt 格式检查
# 2. moon check 类型检查
# 3. moon test 全量测试
# 4. 覆盖率报告生成
```

---

## 相关文档

- [编码规范](/contributing/coding-standards/) — MoonBit 编码约定
- [开发环境搭建](/contributing/setup/) — 环境配置指南
- [项目架构](/core-concepts/architecture/) — 整体架构总览

> **提示**: 添加新算法时，遵循"类型 → 算法 → 测试 → 文档"的提交顺序。
