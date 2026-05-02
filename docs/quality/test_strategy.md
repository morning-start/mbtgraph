---
title: "mbtgraph 测试策略与计划"
version: "0.1.0"
status: "draft"
type: "test-strategy"
created: "2026-05-02"
updated: "2026-05-02"
author: "morning-start"
license: "Apache-2.0"
tags: ["testing", "quality", "graph", "algorithm"]
traceability:
  source:
    - "docs/requirements/srs.md"
    - "docs/design/sad.md"
  targets:
    - "test/"
---

# mbtgraph 测试策略与计划

> **版本**: v0.1.0 | **状态**: 草稿 | **日期**: 2026-05-02

---

## 1. 测试目标

### 1.1 质量目标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| **单元测试覆盖率** | ≥ 80% | 核心算法 ≥ 90% |
| **集成测试覆盖率** | ≥ 70% | 跨模块场景 |
| **性能测试通过率** | 100% | 所有性能指标达标 |
| **缺陷密度** | < 0.5 defects/KLOC | 每千行代码缺陷数 |

### 1.2 测试原则

- ✅ **优先断言测试**: 使用 `assert_eq` 或 `assert_true` 用于确定性结果
- ✅ **属性检验**: 对算法属性进行验证（如 PageRank scores 之和 ≈ 1.0）
- ✅ **快照测试**: 用于复杂输出记录当前行为
- ✅ **性能回归**: 建立性能基准，防止退化

---

## 2. 测试分层

### 2.1 测试层次

```
┌─────────────────────────────────────────┐
│         集成测试 (Integration)           │  ← 跨模块场景
├─────────────────────────────────────────┤
│         模块测试 (Module)               │  ← 单包完整场景
├─────────────────────────────────────────┤
│         单元测试 (Unit)                 │  ← 单函数正确性
├─────────────────────────────────────────┤
│         属性测试 (Property)             │  ← 算法属性验证
├─────────────────────────────────────────┤
│         性能测试 (Performance)          │  ← 时间/内存基准
└─────────────────────────────────────────┘
```

### 2.2 测试文件组织

```
test/
├── fixtures/                    # 测试数据文件
│   ├── karate_club.dot          # Karate Club 社交网络 (34节点)
│   ├── drosophila_ppi.dot      # 果蝇蛋白质互作网络
│   ├── small_test.dot           # 小型人工测试图
│   └── large_random_10k.dot    # 大规模随机图 (10K节点, 性能基准)
│
├── core/                        # core 包测试
│   ├── directed_test.mbt        # 有向图测试
│   ├── undirected_test.mbt      # 无向图测试
│   ├── weighted_test.mbt        # 加权图测试
│   └── multigraph_test.mbt      # 多重图测试
│
├── algo/                        # algo 包测试
│   ├── traverse_test.mbt        # 遍历算法测试
│   ├── shortest_path_test.mbt   # 最短路径测试
│   ├── spanning_tree_test.mbt   # 生成树测试
│   ├── connectivity_test.mbt    # 连通性测试
│   └── cycle_test.mbt           # 环检测测试
│
├── analysis/                    # analysis 包测试
│   ├── centrality_test.mbt      # 中心性测试
│   ├── community_test.mbt       # 社区检测测试
│   └── clustering_test.mbt      # 聚类系数测试
│
├── flow/                        # flow 包测试
│   ├── max_flow_test.mbt        # 最大流测试
│   ├── min_cost_flow_test.mbt   # 最小费用流测试
│   └── cut_test.mbt             # 割算法测试
│
├── integration/                 # 集成测试
│   └── cross_module_test.mbt    # 跨模块场景
│
└── performance/                 # 性能测试
    └── benchmark_test.mbt       # 性能基准测试
```

---

## 3. 单元测试策略

### 3.1 核心模块测试

#### 3.1.1 有向图测试 (`core/directed_test.mbt`)

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `test_create_empty` | 无 | `node_count() == 0`, `edge_count() == 0` | 功能 |
| `test_add_single_node` | 添加节点 A | `node_count() == 1` | 功能 |
| `test_add_edge` | 添加边 A→B | `edge_count() == 1`, `contains_edge(A,B) == true` | 功能 |
| `test_remove_node` | 删除节点 A | 关联边也被删除 | 功能 |
| `test_neighbors` | 添加 A→B, A→C | `neighbors(A)` 包含 B 和 C | 功能 |
| `test_successors_predecessors` | 添加 A→B→C | `successors(A)` = [B], `predecessors(C)` = [B] | 功能 |
| `test_reverse` | 图 G: A→B→C | `G.reverse()`: C→B→A | 功能 |

**示例代码**:

```moonbit
fn test_create_empty() {
  let g = DirectedGraph::new()
  assert_eq(g.node_count(), 0)
  assert_eq(g.edge_count(), 0)
}

fn test_add_single_node() {
  let mut g = DirectedGraph::new()
  let a = g.add_node("A")
  assert_eq(g.node_count(), 1)
  assert_true(g.contains_node(a))
}
```

---

#### 3.1.2 无向图测试 (`core/undirected_test.mbt`)

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `test_undirected_edge_symmetry` | 添加边 A-B | `contains_edge(A,B) == true`, `contains_edge(B,A) == true` | 功能 |
| `test_no_duplicate_edges` | 添加边 A-B, B-A | `edge_count() == 1` | 功能 |
| `test_degree` | 添加 A-B, A-C | `degree(A) == 2` | 功能 |

---

### 3.2 算法测试

#### 3.2.1 BFS 测试 (`algo/traverse_test.mbt`)

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `test_bfs_linear` | 线性图 A→B→C→D, 从 A 开始 | 顺序: [A,B,C,D] | 功能 |
| `test_bfs_tree` | 树形结构, 从根开始 | 层次顺序 | 功能 |
| `test_bfs_distances` | 线性图 A→B→C | 距离: {A:0, B:1, C:2} | 功能 |
| `test_bfs_disconnected` | 不连通图 | 仅遍历可达节点 | 功能 |
| `test_bfs_cycle` | 环图 A→B→C→A | 正确终止 | 功能 |

**示例代码**:

```moonbit
fn test_bfs_linear() {
  let mut g = DirectedGraph::new()
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  let d = g.add_node("D")
  g.add_edge(a, b, ())
  g.add_edge(b, c, ())
  g.add_edge(c, d, ())

  let result = bfs(&g, a)
  assert_eq(result.discovered_order, [a, b, c, d])
  assert_eq(result.distance[a], 0)
  assert_eq(result.distance[b], 1)
  assert_eq(result.distance[c], 2)
  assert_eq(result.distance[d], 3)
}
```

---

#### 3.2.2 Dijkstra 测试 (`algo/shortest_path_test.mbt`)

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `test_dijkstra_simple` | 3 节点三角图 | 最短路径正确 | 功能 |
| `test_dijkstra_early_termination` | 指定 target | 提前终止 | 功能 |
| `test_dijkstra_no_path` | 不连通图 | 距离为 ∞ | 功能 |
| `test_dijkstra_negative_weight` | 包含负权边 | 返回错误 | 错误处理 |
| `test_dijkstra_path_reconstruction` | 复杂图 | 路径可重构 | 功能 |

---

#### 3.2.3 Kosaraju SCC 测试 (`algo/connectivity_test.mbt`)

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `test_scc_single_component` | 强连通图 | 1 个 SCC 包含所有节点 | 功能 |
| `test_scc_multiple_components` | 2 个分离的环 | 2 个 SCC | 功能 |
| `test_scc_dag` | DAG | 每个节点一个 SCC | 功能 |
| `test_scc_empty_graph` | 空图 | 0 个 SCC | 功能 |
| `test_scc_standard` | 标准测试图 (CLRS 示例) | SCC 划分正确 | 功能 |

---

### 3.3 网络分析测试

#### 3.3.1 PageRank 测试 (`analysis/centrality_test.mbt`)

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `test_pagerank_sum` | 任意图 | `sum(scores) ≈ 1.0` | 属性 |
| `test_pagerank_convergence` | Karate Club 图 | `iterations < 50`, `converged == true` | 属性 |
| `test_pagerank_known_result` | 简单星型图 | 中心节点分数最高 | 功能 |
| `test_pagerank_networkx_comparison` | Karate Club 图 | 与 NetworkX 误差 < 1e-5 | 回归 |
| `test_pagerank_dangling_nodes` | 包含悬挂节点的图 | 正确处理 | 功能 |

**属性检验示例**:

```moonbit
fn test_pagerank_sum() {
  let mut g = DirectedGraph::new()
  // ... 构建图 ...

  let result = pagerank(&g, damping=0.85, tolerance=1e-6, max_iter=100)
  let sum = result.values().fold(0.0, fn(acc, v) { acc + v })
  assert_true(abs(sum - 1.0) < 1e-6)
}
```

---

#### 3.3.2 Louvain 测试 (`analysis/community_test.mbt`)

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `test_louvain_modularity` | Karate Club 图 | `modularity > 0.3` | 属性 |
| `test_louvain_all_nodes_assigned` | 任意图 | 所有节点都在某个社区 | 属性 |
| `test_louvain_stability` | 同一图运行 3 次 | 结果一致 | 属性 |
| `test_louvain_known_result` | 已知社区结构的图 | 社区划分正确 | 功能 |

---

### 3.4 流网络测试

#### 3.4.1 Dinic 最大流测试 (`flow/max_flow_test.mbt`)

**测试场景**:

| 测试用例 | 输入 | 预期输出 | 类型 |
|---------|------|---------|------|
| `test_max_flow_simple` | 简单网络 | 最大流值正确 | 功能 |
| `test_max_flow_min_cut` | 标准网络 | 最大流 = 最小割容量 | 属性 |
| `test_max_flow_conservation` | 任意图 | 流入 = 流出 (除源汇) | 属性 |
| `test_max_flow_capacity` | 任意图 | 流量 ≤ 容量 | 属性 |
| `test_max_flow_standard` | 标准测试用例 (CLRS) | 结果正确 | 功能 |

---

## 4. 集成测试策略

### 4.1 跨模块场景

| 测试场景 | 涉及模块 | 描述 |
|---------|---------|------|
| `test_graph_to_pagerank` | core + analysis | 创建图 → 计算 PageRank → 验证结果 |
| `test_bfs_to_shortest_path` | algo/traverse + algo/shortest_path | BFS 树 → Dijkstra 验证 |
| `test_scc_to_toposort` | algo/connectivity | SCC 缩点 → 拓扑排序 |
| `test_louvain_to_modularity` | analysis/community | 社区检测 → 模块度验证 |
| `test_dot_import_to_analysis` | utils/io + analysis | 导入 DOT 文件 → 计算中心性 |

### 4.2 端到端场景

```
测试场景: 社交网络分析
1. 从 DOT 文件导入 Karate Club 图
2. 计算节点数、边数
3. 运行 BFS 从节点 0 开始
4. 计算 PageRank
5. 运行 Louvain 社区检测
6. 验证模块度 > 0.3
7. 导出结果为 JSON
```

---

## 5. 性能测试策略

### 5.1 性能基准

| 算法 | 图规模 | 目标时间 | 目标内存 |
|------|--------|---------|----------|
| **BFS** | 100K 节点 | < 50ms | < 50MB |
| **Dijkstra** | 100K 节点, 500K 边 | < 200ms | < 100MB |
| **PageRank** | 100K 节点 | < 1s | < 200MB |
| **Louvain** | 100K 节点 | < 5s | < 500MB |
| **Dinic** | 10K 节点, 100K 边 | < 500ms | < 100MB |

### 5.2 性能测试方法

```moonbit
fn benchmark_dijkstra_100k() {
  let g = generate_random_graph(100_000, 500_000)
  let start_time = current_time_ms()
  let _ = dijkstra(&g, source=0)
  let end_time = current_time_ms()
  let duration = end_time - start_time
  assert_true(duration < 200)  // 200ms 目标
}
```

---

## 6. 测试数据

### 6.1 固定测试数据

| 文件 | 描述 | 规模 | 用途 |
|------|------|------|------|
| `karate_club.dot` | Zachary Karate Club 社交网络 | 34 节点, 78 边 | 社区检测、中心性验证 |
| `drosophila_ppi.dot` | 果蝇蛋白质互作网络 | ~7K 节点 | 大规模社区检测 |
| `small_test.dot` | 手工构造的小图 | 5-10 节点 | 算法正确性验证 |
| `large_random_10k.dot` | 大规模随机图 | 10K 节点 | 性能基准测试 |

### 6.2 测试图生成器

```moonbit
// 使用内置图生成器创建测试图
fn test_with_generated_graph() {
  // 完全图 K_10
  let g1 = generators::complete_graph(10)
  assert_eq(g1.node_count(), 10)
  assert_eq(g1.edge_count(), 45)  // 10*9/2

  // 随机图 G(n=100, p=0.1)
  let g2 = generators::erdos_renyi(100, 0.1)
  assert_true(g2.node_count() == 100)
}
```

---

## 7. 测试工具与命令

### 7.1 MoonBit 测试命令

```bash
# 运行所有测试
moon test

# 运行特定目标测试
moon test --target native

# 更新快照测试
moon test --update

# 覆盖率分析
moon coverage analyze > uncovered.log

# 查看未覆盖代码
cat uncovered.log
```

### 7.2 CI/CD 集成

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: moonbitlang/setup@v1
      - run: moon test --target native
      - run: moon coverage analyze > uncovered.log
```

---

## 8. 缺陷管理

### 8.1 缺陷分类

| 类别 | 说明 | 示例 |
|------|------|------|
| **逻辑错误** | 算法实现错误 | BFS 返回错误顺序 |
| **边界条件** | 特殊输入未处理 | 空图、单节点图 |
| **性能退化** | 时间/内存超标 | Dijkstra 100K 节点 > 200ms |
| **类型错误** | 编译期类型不匹配 | Trait 约束不满足 |
| **内存泄漏** | 未释放资源 | (MoonBit 自动管理，较少见) |

### 8.2 缺陷修复流程

1. **报告**: 在 GitHub Issues 创建 Issue
2. **复现**: 编写失败的测试用例
3. **修复**: 修改代码使测试通过
4. **验证**: 运行完整测试套件
5. **合并**: PR 合并后关闭 Issue

---

## 9. 质量门禁

### 9.1 提交前检查

| 检查项 | 工具 | 阈值 |
|--------|------|------|
| 代码格式 | `moon fmt` | 100% 通过 |
| 接口一致性 | `moon info` | .mbti 无意外变更 |
| 单元测试 | `moon test` | 100% 通过 |
| 覆盖率 | `moon coverage analyze` | ≥ 80% |

### 9.2 发布前检查

| 检查项 | 工具 | 阈值 |
|--------|------|------|
| 全平台测试 | `moon test --target wasm/js/native` | 100% 通过 |
| 性能基准 | 自定义 benchmark | 所有指标达标 |
| 文档完整性 | 手动检查 | 所有公开 API 有文档 |
| 变更日志 | CHANGELOG.md | 更新 |

---

## 10. 附录

### 10.1 参考文档

- [软件需求规格](docs/requirements/srs.md)
- [系统架构设计](docs/design/sad.md)
- [MoonBit 测试文档](https://docs.moonbitlang.com/testing/)

### 10.2 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| v0.1.0 | 2026-05-02 | 初始版本，定义测试策略和计划 |

---

**文档状态**: 草稿 ⏳  
**待办事项**: 
- [ ] 补充 Phase 3 高级算法测试用例
- [ ] 补充 I/O 模块测试用例
- [ ] 建立性能基准数据库
