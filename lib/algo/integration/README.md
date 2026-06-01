# Integration — 跨模块集成测试

> 验证 mbtgraph 各算法模块之间的接口兼容性与协作能力。

## 为什么需要集成测试？

单元测试可以验证单个算法的正确性，但**无法发现模块间的接口不兼容问题**。在 Trait-based 架构中，以下风险只能通过跨模块协作来暴露：

| 风险类型 | 单元测试能发现？ | 集成测试能发现？ |
|---------|:---:|:---:|
| 泛型约束不匹配 | ✅ | ✅ |
| 存储实现遗漏 Trait 方法 | ❌ | ✅ |
| 算法输出格式与下游模块期望不一致 | ❌ | ✅ |
| 不同存储类型的运行时行为差异 | ❌ | ✅ |
| 迭代算法的收敛性依赖图结构特性 | 部分 | ✅ |

本模块的核心价值：**确保 `pagerank`、`centrality`、`community` 三个分析模块能在同一张图上无缝衔接，且对 5 种存储实现行为一致。**

---

## 依赖关系

```
integration (本模块)
├── @core          — NodeId, GraphReadable/Writable Trait
├── @storage       — 5 种存储实现 (DirectedAdjList / UndirectedAdjList / EdgeList / CSR / DirectedMatrix)
├── @pagerank      — PageRank 算法
├── @centrality    — 5 种中心性指标 (度/接近/介数/特征向量)
└── @community     — 社区检测 (Louvain / 标签传播)
```

**被测模块清单**:

| 模块 | 路径 | 在集成测试中的角色 |
|------|------|------------------|
| `core` | `lib/core/` | 提供 Trait 约束与基础类型 |
| `storage` | `lib/storage/` | 提供多种图存储后端 |
| `pagerank` | `lib/algo/pagerank/` | 重要性排序算法 |
| `centrality` | `lib/algo/centrality/` | 节点影响力度量 |
| `community` | `lib/algo/community/` | 图分割与聚类 |

---

## 文件结构

```
lib/algo/integration/
├── moon.pkg              # 包配置 (依赖 core/storage/centrality/community/pagerank)
└── integration_test.mbt  # 10 个集成测试用例 (~310 行)
```

> 本模块为纯测试模块，无公开 API，不导出任何类型或函数。

---

## 测试场景总览

### 按工作流分类

| # | 测试名 | 工作流类型 | 存储类型 | 涉及模块 | 验证目标 |
|---|--------|-----------|----------|---------|---------|
| 1 | `pagerank_and_eigenvector_aligned_on_star` | **中心性交叉验证** | DirectedAdjList | pagerank + centrality | 星形图中心节点排名一致 |
| 2 | `louvain_detects_two_clusters` | **社区 + 中心性联合** | UndirectedAdjList | community + centrality | 桥接节点的度中心性 |
| 3 | `label_propagation_and_pagerank_on_chain` | **社区 + 排序联合** | DirectedAdjList | community + pagerank | 有向链图的收敛性与秩和 |
| 4 | `all_three_on_edge_list` | **多算法 × EdgeList** | EdgeList | pagerank + centrality + community | 边集存储的全栈兼容 |
| 5 | `all_three_on_csr` | **多算法 × CSR** | CSR | pagerank + centrality + community | CSR 只读存储的兼容 |
| 6 | `all_three_on_directed_matrix` | **多算法 × Matrix** | DirectedMatrix | pagerank + centrality + community | 矩阵存储的稠密图支持 |
| 7 | `pagerank_and_betweenness_on_bridge_graph` | **排名 + 结构角色** | UndirectedAdjList | pagerank + centrality | 桥接节点的高介数 |
| 8 | `centrality_and_community_on_ring` | **对称性验证** | UndirectedAdjList | centrality + community | 环图各节点等价性 |
| 9 | `pagerank_and_closeness_on_chain_directed` | **有向图双指标** | DirectedAdjList | pagerank + centrality | 链式传播的 PageRank 分布 |
| 10 | `louvain_and_label_propagation_consistent` | **社区算法对比** | UndirectedAdjList | community | 两种方法的结果一致性 |

### 按维度统计

- **算法组合**: 10 个测试覆盖 pagerank×centrality(4)、community×centrality(3)、community×pagerank(2)、community 内部对比(1)
- **存储覆盖**: DirectedAdjList(4)、UndirectedAdjList(4)、EdgeList(1)、CSR(1)、DirectedMatrix(1)
- **图拓扑**: 星形图、双集群桥接图、有向链图、环图、简单路径图

---

## 典型集成流水线示例

### 流水线 A：存储构建 → PageRank → 中心性 → 社区检测

这是最典型的「图分析全流程」——在同一张图上依次运行三类分析算法，验证数据管道的端到端正确性。

```moonbit
// 1. 构建双集群图 (两个三角形通过桥边连接)
let g = make_two_clusters_connected()
// 拓扑: 0-1-2 (团) --- 3-4-5 (团), 桥边 = (2,3)

// 2. PageRank: 识别全局重要性
let pr_result = @pagerank.pagerank(g, 0.85, 100, 0.000001)
assert_true(pr_result.converged)
assert_true(approx_eq(pr_result.total_rank(), 1.0, 0.001))

// 3. 介数中心性: 识别结构关键节点 (桥接节点应有高分)
let bc_result = @centrality.betweenness_centrality(g, true)
let bridge_score = bc_result.get_score(@core.NodeId(2))
match bridge_score {
  Some(s) => assert_true(s > 0.3)  // 节点 2 是桥接点
  None => assert_true(false)
}

// 4. Louvain 社区检测: 验证聚类结果合理
let lv_result = @community.louvain(g, 1.0)
assert_true(lv_result.num_communities >= 2)   // 应检测到 2 个社区
assert_true(lv_result.modularity > 0.2)       // 模块度应显著大于 0
```

**辅助函数** (`make_two_clusters_connected`):

```moonbit
fn make_two_clusters_connected() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 6 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  // 团内边 + 桥边
  let edges = [(0, 1), (0, 2), (1, 2),   // 团 A
               (3, 4), (3, 5), (4, 5),   // 团 B
               (2, 3)]                    // 桥边
  for e in edges {
    let (u, v) = e
    @core.GraphWritable::add_edge(g, @core.NodeId(u), @core.NodeId(v), 1.0) |> ignore
  }
  g
}
```

### 流水线 B：多存储类型兼容性验证

同一个三算法组合（PageRank + 中心性 + 社区检测）分别在 5 种存储上执行，验证 Trait 抽象层的完备性。

```moonbit
// === EdgeList 存储 ===
let g_el = @storage.new_edge_list()
// ... 构建 4 节点环图 ...
let pr = @pagerank.pagerank(g_el, 0.85, 100, 0.000001)
let dc = @centrality.degree_centrality(g_el, @centrality.DegreeMode::Total)
let lp = @community.label_propagation(g_el, 100)

// === CSR 存储 (只读批量存储) ===
let builder = @storage.CSRBuilder::new()
let builder = builder.add_node(@core.NodeId(0), 0.0)
let builder = builder.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
// ... 更多构建 ...
let g_csr = builder.build()
let pr = @pagerank.pagerank(g_csr, 0.85, 100, 0.000001)
let bc = @centrality.betweenness_centrality(g_csr, true)
let lv = @community.louvain(g_csr, 1.0)

// === DirectedMatrix 存储 (稠密图) ===
let g_mat = @storage.new_directed_matrix(3)
// ... 构建有向环 ...
let pr = @pagerank.pagerank(g_mat, 0.85, 100, 0.000001)
let cc = @centrality.closeness_centrality(g_mat, true)
let lp = @community.label_propagation(g_mat, 100)
```

### 流水线 C：中心性交叉验证（环图对称性）

利用环图的拓扑对称性，验证不同中心性指标的数学一致性。

```moonbit
// 构建 6 节点无向环: 0-1-2-3-4-5-0
let g = @storage.new_undirected()
let mut i = 0
while i < 6 {
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  i = i + 1
}
let ring_edges = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 0)]
for e in ring_edges {
  let (u, v) = e
  @core.GraphWritable::add_edge(g, @core.NodeId(u), @core.NodeId(v), 1.0) |> ignore
}

// 度中心性: 环图每个节点度数为 2, 归一化后应全部相等
let dc = @centrality.degree_centrality(g, @centrality.DegreeMode::Total)
for s in dc.scores {
  assert_true(approx_eq(s, 2.0 / 5.0, 0.0001))  // (n-1) 归一化
}

// 接近中心性: 环图所有节点对称, 分数应相同且 > 0
let cc = @centrality.closeness_centrality(g, true)
for s in cc.scores {
  assert_true(s > 0.0)
}

// 标签传播: 环图可能聚为 1 个社区 (均匀连接)
let lp = @community.label_propagation(g, 100)
assert_true(lp.labels.length() == 6)
```

---

## 测试覆盖矩阵

### 算法 × 存储 兼容性

| 算法 \ 存储 | DirAdjList | UndirAdjList | EdgeList | CSR | DirMatrix |
|------------|:----------:|:------------:|:--------:|:---:|:---------:|
| PageRank | ✅ T1,T3,T9 | ✅ T2,T7,T10 | ✅ T4 | ✅ T5 | ✅ T6 |
| DegreeCentrality | — | ✅ T2,T8 | ✅ T4 | — | — |
| BetweennessCentrality | — | ✅ T7 | — | ✅ T5 | — |
| ClosenessCentrality | ✅ T9 | ✅ T8 | — | — | ✅ T6 |
| EigenvectorCentrality | ✅ T1 | — | — | — | — |
| Louvain | — | ✅ T2,T10 | — | ✅ T5 | — |
| LabelPropagation | ✅ T3 | ✅ T4,T8,T10 | ✅ T4 | — | ✅ T6 |

### 模块组合覆盖

| 组合 | 测试编号 | 场景 |
|------|---------|------|
| pagerank + centrality | T1, T7, T9 | 排名与影响力的关联验证 |
| community + centrality | T2, T8 | 社区结构与局部角色的关联 |
| community + pagerank | T3 | 聚类与全局重要性的交叉 |
| pagerank + centrality + community | T4, T5, T6 | 全栈三模块协同 |
| community 内部对比 | T10 | Louvain vs 标签传播一致性 |

---

## 已知限制

| 限制 | 说明 | 影响 |
|------|------|------|
| **仅覆盖分析类算法** | 当前未包含 traversal/shortest_path/mst/flow/matching 等计算类算法的跨模块测试 | 无法保证这些模块与分析模块的接口兼容 |
| **无 I/O round-trip 测试** | 未验证 DOT/JSON 导入 → 算法处理 → 导出的完整链路 | I/O 序列化误差可能影响算法输入 |
| **无大规模图测试** | 所有测试用例 ≤ 6 节点 | 大规模图的内存/性能边界未被验证 |
| **CSC/UndirectedMatrix 未覆盖** | 8 种存储仅测试了 5 种 | 剩余 3 种存储的实现完整性未知 |
| **无并发安全性测试** | 未验证共享图数据在多算法并行调用下的行为 | 实际管线可能存在竞态风险 |

---

## 扩展计划

### 高优先级（建议下一版本补充）

| 计划 | 描述 | 预期价值 |
|------|------|---------|
| **traversal → shortest_path 流水线** | BFS/DFS 发现可达子图 → Dijkstra 计算最短路径 | 验证遍历输出的图结构与路径算法的输入兼容性 |
| **mst → flow 管线** | Kruskal/Prim 生成 MST → 基于 MST 构建流网络 → Edmonds-Karp | 验证 MST 边集可被 flow 模块消费 |
| **I/O round-trip 测试** | DOT 导入 → pagerank + community → DOT 导出 → 内容校验 | 确保 I/O 序列化不损失精度 |
| **generators → 多算法** | 图生成器创建随机图 → 全部算法模块依次执行 | 验证生成器输出满足所有模块的前置条件 |

### 中优先级

| 计划 | 描述 |
|------|------|
| **matching → centrality 关联** | 匈牙利算法最大匹配 → 验证匹配边的介数中心性分布 |
| **coloring → community 对比** | 图着色 vs 社区检测的分区一致性 |
| **hamiltonian → euler 联合** | 哈密顿路径存在性与欧拉回路的图论约束交叉验证 |

### 低优先级

| 计划 | 描述 |
|------|------|
| **性能基准集成** | 1000+ 节点的跨模块端到端耗时测量 |
| **CSC/UndirectedMatrix 补齐** | 剩余存储类型的三算法全覆盖 |
| **模糊测试集成** | 随机生成畸形图 → 验证所有模块不会 panic |

---

## 运行方式

```bash
# 单独运行集成测试
moon test lib/algo/integration

# 全量测试 (包含集成测试)
moon test

# 更新快照 (如有 snapshot 测试)
moon test lib/algo/integration --update
```

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v0.1.0 | 2026-06-01 | 初始版本：10 个测试用例，覆盖 3 算法模块 × 5 种存储 |

---

<div align="center">

**mbtgraph Integration Test Suite**

*纯测试模块 · 无公开 API · 专注跨模块协作验证*

</div>
