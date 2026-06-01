# 团检测与相关算法 (`clique`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 14 通过

提供图论中三大经典组合优化问题的求解能力：
- **Bron-Kerbosch** — 最大团枚举算法 O(3^{V/3})，回溯法 + 候选集剪枝
- **最大独立集** — 补图团检测变换，时间复杂度 O(3^{V/3})
- **最小顶点覆盖** — 精确解（基于独立集补集）+ 近似解（贪心 2-近似）

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | GraphReadable trait、NodeId 等类型定义 |
| [`@storage`](../storage/) | UndirectedAdjList 无向邻接表存储 |

## 文件结构

```
lib/algo/clique/
├── moon.pkg                # 包配置
├── types.mbt               # CliqueResult / IndependentSetResult / VertexCoverResult
├── helpers.mbt             # 公共辅助函数（数组操作）
├── bron_kerbosch.mbt       # Bron-Kerbosch 最大团算法 (O(3^{V/3}))
├── independent_set.mbt     # 最大独立集算法（补图变换）
├── vertex_cover.mbt        # 最小顶点覆盖（精确 + 近似）
└── clique_test.mbt         # 完整测试套件 (14 tests)
```

## API 总览

### 核心类型 ([types.mbt](types.mbt))

#### `CliqueResult` — 最大团查找结果

```moonbit
pub(all) struct CliqueResult {
  maximum_clique : Array[@core.NodeId]  // 最大团的节点列表（按 ID 排序）
  size : Int                            // 团的大小 ω(G)
}
```

#### `IndependentSetResult` — 最大独立集查找结果

```moonbit
pub(all) struct IndependentSetResult {
  maximum_set : Array[@core.NodeId]  // 最大独立集的节点列表
  size : Int                         // 独立数 α(G)
}
```

#### `VertexCoverResult` — 顶点覆盖查找结果

```moonbit
pub(all) struct VertexCoverResult {
  cover : Array[@core.NodeId]  // 顶点覆盖的节点列表
  size : Int                   // 覆盖大小 τ(G)
  is_optimal : Bool            // 是否为最优解（精确 vs 近似）
}
```

### Bron-Kerbosch 固检测 ([bron_kerbosch.mbt](bron_kerbosch.mbt))

**经典最大团枚举算法** — 时间复杂度 O(3^{V/3})，基于回溯法的候选集剪枝策略。

| 函数 | 说明 | 返回 |
|------|------|------|
| `find_maximum_clique(graph)` | 查找图中的最大团 | `CliqueResult` |

**算法流程**:
1. 初始化：候选集 P = 所有节点，当前团 R = ∅，已排除 X = ∅
2. 递归：选择 v ∈ P，将 v 加入 R，更新 P = P ∩ N(v)，X = X ∩ N(v)
3. 剪枝：当 P = ∅ 且 X = ∅ 时，R 为极大团，记录最大者
4. 回溯：将 v 从 P 移入 X，尝试下一个候选节点

**特性**:
- 泛型实现，兼容所有 `GraphReadable` 存储（无向图优先）
- 保证找到全局最优解（非近似算法）
- 结果节点按 ID 升序排列

### 最大独立集 ([independent_set.mbt](independent_set.mbt))

**补图变换算法** — 利用「图的独立集 = 补图的团」这一对偶关系。

| 函数 | 说明 | 返回 |
|------|------|------|
| `find_maximum_independent_set(graph)` | 查找图中的最大独立集 | `IndependentSetResult` |

**核心原理**:
```
原图 G 的独立集 S ⟺ 衴图 Ḡ 的团 C
α(G) = ω(Ḡ)
```

**实现细节**:
- 在 Bron-Kerbosch 的邻居交集步骤中，改用「非邻居」集合
- 避免显式构建补图，节省 O(V²) 空间
- 结果自动排序，保证确定性输出

### 最小顶点覆盖 ([vertex_cover.mbt](vertex_cover.mbt))

提供两种求解策略：精确算法与贪心近似算法。

| 函数 | 说明 | 返回 | 最优性 |
|------|------|------|:------:|
| `find_minimum_vertex_cover_exact(graph)` | 基于独立集补集的精确解 | `VertexCoverResult` | ✅ |
| `find_minimum_vertex_cover_approx(graph)` | 最大度贪心的 2-近似解 | `VertexCoverResult` | ❌ |

**核心原理**:
```
对于任意无向图 G：
  顶点覆盖 C + 独立集 S = V（互补关系）
  τ(G) + α(G) = \|V\|

精确解: C = V \ S* （S* 为最大独立集）
近似解: 贪心选择度数最大的节点，标记其邻居为已覆盖
```

**近似比保证**:
- 贪心算法保证 `|C_approx| ≤ 2 × |C_optimal|`
- 对于一般图，这是 NP-hard 问题的最佳多项式时间近似比之一

## 使用示例

### 基础用法：完全图的最大团

```moonbit
// 构建完全图 K5（5 个节点两两相连）
let g = @storage.new_undirected()
let mut i = 0
while i < 5 {
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  i = i + 1
}
let mut u = 0
while u < 5 {
  let mut v = u + 1
  while v < 5 {
    @storage.UndirectedAdjList::add_edge(g, @core.NodeId(u), @core.NodeId(v), 1.0) |> ignore
    v = v + 1
  }
  u = u + 1
}

// 查找最大团
let result = find_maximum_clique(g)
result.size                  // => 5 (完全图 K5 本身就是最大团)
result.maximum_clique        // => [NodeId(0), NodeId(1), NodeId(2), NodeId(3), NodeId(4)]
```

### 独立集应用：空图 vs 完全图

```moonbit
// 空图 E5（5 个孤立节点）— 所有节点互不相连
let empty_g = create_empty_graph(5)
let is_result = find_maximum_independent_set(empty_g)
is_result.size              // => 5 (所有节点都是独立的)

// 完全图 K5 — 任意两个节点都相邻
let complete_g = create_complete_graph(5)
let is_result = find_maximum_independent_set(complete_g)
is_result.size              // => 1 (最多选 1 个节点)
```

### 顶点覆盖：精确解 vs 近似解对比

```moonbit
// 构建环图 C10（10 个节点的环）
let cycle_g = create_cycle_graph(10)

// 精确解（基于独立集补集）
let exact_vc = find_minimum_vertex_cover_exact(cycle_g)
exact_vc.size               // => 5 (环图的最小顶点覆盖 = n/2)
exact_vc.is_optimal         // => true

// 近似解（贪心最大度）
let approx_vc = find_minimum_vertex_cover_approx(cycle_g)
approx_vc.size             // >= 5 且 <= 10 (满足 2-近似保证)
approx_vc.is_optimal       // => false

// 验证互补性：独立集 + 顶点覆盖 = 总节点数
let is_result = find_maximum_independent_set(cycle_g)
assert(is_result.size + exact_vc.size == 10)  // ✓
```

### Petersen 图的经典测试

```moonbit
// Petersen 图（10 节点，15 条边的著名反例图）
let petersen = create_petersen_graph()

// 最大团大小为 2（Petersen 图是三角形自由的）
let clique_result = find_maximum_clique(petersen)
clique_result.size          // => 2

// 最大独立集大小为 4
let is_result = find_maximum_independent_set(petersen)
is_result.size              // => 4

// 最小顶点覆盖大小为 6（互补性验证）
let vc_result = find_minimum_vertex_cover_exact(petersen)
vc_result.size              // => 6
assert(clique_result.size + is_result.size <= 11)  // 松弛互补性
```

### 星形图的特殊性质

```moonbit
// 星形图 S5（1 个中心节点 + 4 个叶子节点）
let star_g = create_star_graph(5)

// 最大团 = 2（中心 + 任一叶子）
let clique_result = find_maximum_clique(star_g)
clique_result.size          // => 2

// 最大独立集 = 4（所有叶子节点互不相连）
let is_result = find_maximum_independent_set(star_g)
is_result.size              // => 4

// 最小顶点覆盖 = 1（只需覆盖中心节点即可覆盖所有边）
let vc_result = find_minimum_vertex_cover_exact(star_g)
vc_result.size              // => 1
```

### 算法选择指南

```moonbit
// 需要精确解 → 使用 exact 版本
let optimal_vc = find_minimum_vertex_cover_exact(g)

// 大规模图 / 快速近似 → 使用 approx 版本（2-近似保证）
let fast_vc = find_minimum_vertex_cover_approx(g)

// 验证正确性 → 交叉验证互补性
let is_result = find_maximum_independent_set(g)
let vc_result = find_minimum_vertex_cover_exact(g)
let n = @core.GraphReadable::node_count(g)
assert(is_result.size + vc_result.size == n)  // 严格互补性
```

## 算法原理

### Bron-Kerbosch 回溯框架

Bron-Kerbosch 算法是解决最大团问题的经典回溯方法，其核心思想是通过三个集合的动态维护来枚举所有极大团：

```
R (Current Clique): 当前正在构建的候选团
P (Candidates):     可能加入 R 的候选节点（必须与 R 中所有节点相邻）
X (Excluded):       已排除的节点（用于避免重复枚举）

递归终止条件:
  P = ∅ ∧ X = ∅ → R 是极大团，记录并返回

递归步骤:
  for each v in P:
    R' = R ∪ {v}
    P' = P ∩ N(v)   // 只保留 v 的邻居（保证团性质）
    X' = X ∩ N(v)
    BronKerbosch(R', P', X')
    P = P \ {v}
    X = X ∪ {v}
```

### 时间复杂度分析

| 图类型 | 复杂度 | 说明 |
|--------|--------|------|
| 一般图 | O(3^{V/3}) | 最坏情况（稀疏图）|
| 稠密图 | O(1.4422^V) | 实际表现优于理论上界 |
| 空图 | O(V) | 每个节点自成团 |
| 完全图 | O(V²) | 只有一个极大团 |

**关键优化点**:
- **候选集剪枝**: P ∩ N(v) 过滤掉不相邻节点，大幅减少递归分支
- **早停机制**: 一旦找到大小为当前上界的团即可终止（本实现保留完整枚举以保证正确性）

### 三问题对偶关系

```
┌─────────────┐     补图变换      ┌─────────────┐
│  最大团     │ ←────────────→ │  最大独立集  │
│  ω(G)       │                 │  α(G) = ω(Ḡ) │
└─────────────┘                 └─────────────┘
        ↓ 互补关系 ↓
┌─────────────┐
│ 最小顶点覆盖 │  τ(G) = |V| - α(G)
└─────────────┘
```

这三个问题是 NP-hard 等价的，但通过上述变换可以统一用 Bron-Kerbosch 框架求解。

## 内部组件

### 公共辅助函数 ([helpers.mbt](helpers.mbt))

| 函数 | 功能 |
|------|------|
| `copy_array_int(arr)` | 深拷贝 Int 数组（保证纯函数语义）|
| `intersect_arrays(a, b)` | 计算两个数组的交集 |
| `remove_from_array(arr, val)` | 从数组中移除指定元素 |

### Bron-Kerbosch 组件 ([bron_kerbosch.mbt](bron_kerbosch.mbt))

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `bk_recursive()` | priv | 核心递归函数，维护 R/P/X 三个集合 |
| `get_neighbor_indices()` | priv | 获取指定节点的邻居索引列表 |

### 独立集组件 ([independent_set.mbt](independent_set.mbt))

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `bk_recursive_complement()` | priv | 补图版本的 BK 递归（使用非邻居）|
| `get_non_neighbor_indices()` | priv | 获取指定节点的非邻居索引列表 |

### 顶点覆盖组件 ([vertex_cover.mbt](vertex_cover.mbt))

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `compute_degrees()` | priv | 计算所有节点的度数 |
| `find_max_degree_node()` | priv | 在未覆盖节点中度数最大的节点 |
| `mark_neighbors_covered()` | priv | 标记选中节点及其邻居为已覆盖 |
| `validate_vertex_cover()` | priv | 验证顶点覆盖的正确性（每条边至少一端在覆盖中）|
| `sort_cover()` | priv | 对覆盖节点排序（保证确定性输出）|

## 边界行为

| 条件 | 行为 | 返回值 |
|------|------|--------|
| 空图 (n=0) | 直接返回空结果 | size=0, 列表=[] |
| 单节点图 (n=1) | 返回只含该节点的结果 | size=1, 列表=[NodeId(0)] |
| 无边图（空图变体）| 团大小=1，独立集大小=n，顶点覆盖=0 | 符合理论预期 |
| 完全图 Kn | 团大小=n，独立集大小=1，顶点覆盖=n-1 | 符合理论预期 |
| 有向图输入 | 算法仍可运行（使用出边/入边语义）| 结果可能不符合无向图理论 |
| 自环 | 不影响团/独立集结果 | 正常处理 |
| 并行边 | 视为单条边 | 正常处理 |

**特殊说明**:
- 算法主要针对**无向图**设计，有向图的结果可能不符合直觉
- 节点 ID 必须连续且从 0 开始（内部使用数组索引映射）
- 结果中的节点列表已排序，保证输出的确定性

## 测试覆盖

| 类别 | 数量 | 内容 |
|------|:----:|------|
| 基础功能 | 5 | 空图团/完全图团/空图独立集/完全图独立集/单节点 |
| 经典图例 | 4 | C5 团/C5 路径/Petersen 图/星形图 |
| 顶点覆盖 | 3 | 空图覆盖/完全图覆盖/精确+近似对比 |
| 互补性验证 | 2 | 团-独立集松弛互补/独立集-顶点覆盖严格互补 |
| **合计** | **14** | **14 total** |

**测试图类型**:

| 图类型 | 节点数 | 边数 | 特殊性质 |
|--------|:------:|:----:|----------|
| 空图 En | 5 | 0 | 无边，极端稀疏 |
| 完全图 Kn | 5/4 | 10/6 | 全连接，极端稠密 |
| 环图 Cn | 5/10 | 5/10 | 2-正则，三角形自由 |
| 路径 Pn | 4 | 3 | 树的特殊情况 |
| Petersen 图 | 10 | 15 | 强正则图，著名反例 |
| 星形图 Sn | 5 | 4 | 树，中心-叶子结构 |

运行命令:
```bash
moon test lib/algo/clique  # 14 tests
```

## 设计决策

### 为什么选择简化版 Bron-Kerbosch？

1. **代码清晰**: 基础版本更易理解和维护，适合作为教学参考
2. **正确性优先**: 避免 pivoting 优化的复杂性，降低出错风险
3. **足够实用**: 对于中小规模图（V < 50），性能完全可接受
4. **扩展友好**: 后续可在此基础上添加 Tomita 版本的 pivoting 优化

### 为什么同时提供精确解和近似解？

1. **场景适配**: 小规模图用精确解，大规模图用近似解
2. **质量验证**: 近似解可与精确解对比，评估近似比
3. **NP-hard 现实**: 顶点覆盖问题不存在多项式时间精确算法（除非 P=NP）
4. **理论价值**: 2-近似算法是教科书级的最优多项式时间近似

### 为什么使用补图变换而非显式构建补图？

1. **空间效率**: 避免存储 O(V²) 的补图邻接矩阵
2. **时间效率**: 在 BK 递归中动态计算非邻居集合
3. **代码复用**: 共享相同的回溯框架，仅修改邻居查询逻辑

### 为什么结果需要排序？

1. **确定性**: 相同输入总是产生相同输出，便于测试和调试
2. **可读性**: 排序后的结果更易于人工检查
3. **一致性**: 三个算法的输出格式统一，方便下游使用

### 📝 命名说明与未来规划 (v0.16.0)

当前函数名称包含精度信息后缀，这是为了明确区分精确算法和近似算法：

| 当前函数名 | 语义 | 复杂度 | v1.1.0 计划重命名为 |
|-----------|------|:------:|:-------------------:|
| `find_minimum_vertex_cover_exact()` | 精确解（指数时间）| O(1.4422^V) | `find_minimum_vertex_cover()` |
| `find_minimum_vertex_cover_approx()` | 近似解（多项式时间）| O(V+E) | `find_minimum_vertex_cover_greedy()` |

**为什么现在不改？**
- 向后兼容性考虑（v1.0.0 冻结期不引入 Breaking Changes）
- 给用户迁移时间

**如何使用？**
```moonbit
// 当前用法（v0.16.0 - v1.0.x）
let exact_result = find_minimum_vertex_cover_exact(graph)
let approx_result = find_minimum_vertex_cover_approx(graph)

// 未来用法（v1.1.0+，向后兼容别名会保留至 v2.0.0）
// let exact_result = find_minimum_vertex_cover(graph)
// let approx_result = find_minimum_vertex_cover_greedy(graph)
```

## 与其他模块配合

```moonbit
// 从有向图转换为无向图（clique 模块推荐无向输入）
let directed_g = @storage.new_directed()
// ... 构建有向图 ...

// 使用 converter 转换（如果可用）
// let undirected_g = @storage.to_undirected(directed_g)

// 或者手动构建无向图
let undirected_g = @storage.new_undirected()
for node in @core.GraphReadable::nodes(directed_g) {
  @core.GraphWritable::add_node(undirected_g, 0.0) |> ignore
}
for edge in @core.GraphReadable::edges(directed_g) {
  @storage.UndirectedAdjList::add_edge(
    undirected_g,
    edge.from,
    edge.to,
    edge.weight,
  ) |> ignore
}

// 执行团检测
let clique_result = find_maximum_clique(undirected_g)

// 结合连通性分析（先找连通分量，再在每个分量内找团）
// let components = @connectivity.find_connected_components(undirected_g)
// for component in components {
//   let subgraph = extract_subgraph(undirected_g, component)
//   let result = find_maximum_clique(subgraph)
//   // ...
// }
```

### 典型应用场景

```moonbit
// 场景 1: 社交网络分析（寻找紧密社群）
// let social_network = build_social_graph()
// let communities = find_maximum_clique(social_network)
// communities.maximum_clique  // 最紧密的朋友圈

// 场景 2: 任务调度（独立集 = 可并行执行的任务）
// let dependency_graph = build_task_dependency()
// let parallel_tasks = find_maximum_independent_set(dependency_graph)
// parallel_tasks.maximum_set  // 可并行执行的最大任务集合

// 场景 3: 网络监控（顶点覆盖 = 最少监控点）
// let network_topology = build_network()
// let monitors = find_minimum_vertex_cover_exact(network_topology)
// monitors.cover  // 最少的监控节点部署位置
```

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.16.0 | 2026-06-01 | 文档更新：补充命名说明与 v1.1.0 重命名规划 |
| v0.1.0 | 2026-06-01 | 初始版本：Bron-Kerbosch + 最大独立集 + 最小顶点覆盖（精确+近似）+ 14 tests |

---

<div align="center">

**📐 mbtgraph Clique 模块**

*团检测 · 独立集 · 顶点覆盖 — NP-hard 组合优化问题的 MoonBit 实现*

</div>
