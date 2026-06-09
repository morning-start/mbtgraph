# 网络流算法 (`flow`)

> **版本**: v0.3.0 | **状态**: 稳定 | **测试**: 83 通过 | **算法**: 6 个

提供全面的网络流求解能力，包含 6 个算法：
- **最大流系列**: Edmonds-Karp / Dinic / Push-Relabel / 容量缩放 — 四种不同策略求最大流
- **最小割**: Stoer-Wagner — 全局最小割（无向图）
- **费用流**: Min Cost Max Flow — 最小费用最大流

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | 类型定义 |

## 文件结构

```
lib/algo/flow/
├── moon.pkg              # 包配置
├── types.mbt             # MaxFlowResult / MinCostMaxFlowResult 结果类型
├── flow_network.mbt      # FlowNetwork / CostFlowNetwork 结构体 + 工厂/边添加
├── edmonds_karp.mbt      # Edmonds-Karp 最大流算法 (O(VE²))
├── dinic.mbt             # Dinic 最大流算法 (O(E√V))
├── push_relabel.mbt      # Push-Relabel 预流推进算法 (O(V²E))
├── stoer_wagner.mbt      # Stoer-Wagner 全局最小割算法
├── min_cost_max_flow.mbt # 最小费用最大流算法
├── capacity_scaling.mbt  # 容量缩放最大流算法 (O(E²logU))
└── flow_test.mbt         # 综合测试套件 (83 tests)
```

## API 总览

### 核心类型 ([types.mbt](types.mbt))

#### `MaxFlowResult` — 最大流结果

```moonbit
pub(all) struct MaxFlowResult {
  max_flow : Double                      // 最大流量值
  flow_matrix : Array[Array[Double?]]    // 流量矩阵 (None = 无流量)
}
```

#### `MinCostMaxFlowResult` — 最小费用最大流结果

```moonbit
pub(all) struct MinCostMaxFlowResult {
  max_flow : Double                      // 最大流量值
  min_cost : Double                      // 最小总费用
  flow_matrix : Array[Array[Double?]]    // 流量矩阵
  cost_matrix : Array[Array[Double?]]    // 费用矩阵
}
```

#### `StoerWagnerResult` — 全局最小割结果

```moonbit
pub(all) struct StoerWagnerResult {
  min_cut_weight : Double                // 最小割权重
  partition : Array[Int]                 // 割的一侧顶点集合
}
```

### FlowNetwork ([flow_network.mbt](flow_network.mbt))

**独立的流网络数据结构** — 使用邻接矩阵存储容量和流量，不依赖 core 的 Graph trait。

```moonbit
pub(all) struct FlowNetwork {
  node_count : Int                        // 节点数
  capacity : Array[Array[Double]]         // 容量矩阵 capacity[u][v]
  flow : Array[Array[Double]]             // 流量矩阵 flow[u][v]
}
```

| 函数 | 说明 | 返回 |
|------|------|------|
| `FlowNetwork::new(n)` | 创建 n 节点的空流网络 | `FlowNetwork` |
| `add_edge(self, from, to, cap)` | 添加有向边（含反向边用于残差图） | `FlowNetwork` |

**设计要点**:
- 独立于 core 的 Edge/Graph 体系，完全自包含
- 每条边自动创建反向边（初始容量 = 0），用于残差图的流量撤销操作
- 方法返回新实例（函数式风格），原始网络不被修改

### CostFlowNetwork ([flow_network.mbt](flow_network.mbt))

**带费用的流网络数据结构** — 在 FlowNetwork 基础之上增加单位费用矩阵。

```moonbit
pub(all) struct CostFlowNetwork {
  node_count : Int
  capacity : Array[Array[Double]]         // 容量矩阵
  cost : Array[Array[Double]]             // 单位费用矩阵
  flow : Array[Array[Double]]             // 流量矩阵
}
```

| 函数 | 说明 | 返回 |
|------|------|------|
| `CostFlowNetwork::new(n)` | 创建 n 节点的空费用流网络 | `CostFlowNetwork` |
| `add_edge(self, from, to, cap, cost)` | 添加有向边（容量 + 单位费用） | `CostFlowNetwork` |

### Edmonds-Karp ([edmonds_karp.mbt](edmonds_karp.mbt))

**BFS 增广路最大流算法** — 时间复杂度 O(VE²)，Ford-Fulkerson 的 BFS 变体。

| 函数 | 说明 | 返回 |
|------|------|------|
| `edmonds_karp(graph, source, sink)` | 计算从 source 到 sink 的最大流 | `MaxFlowResult` |

**算法流程**:
1. 初始化：所有边流量为 0
2. 循环：用 BFS 在残差图中寻找最短增广路径
3. 找到路径 → 计算瓶颈容量 → 沿路径增广流量
4. 无增广路径 → 终止，返回最大流

**特性**:
- 保证在 O(VE²) 内终止（BFS 保证每次找到最短增广路）
- 自动处理多路径并行流量分配
- 输入网络不被修改（深拷贝语义）

### Dinic ([dinic.mbt](dinic.mbt))

**分层阻塞流最大流算法** — 时间复杂度 O(E√V)，比 Edmonds-Karp 快一个数量级。

| 函数 | 说明 | 返回 |
|------|------|------|
| `dinic(graph, source, sink)` | 计算从 source 到 sink 的最大流 | `MaxFlowResult` |

**算法流程**:
1. **BFS 分层**: 从 source 出发构建层次图（level graph）
2. **DFS 阻塞流**: 在层次图上反复 DFS 寻找多条增广路（当前弧优化）
3. **重复**: 直到 BFS 无法到达 sink 为止

**核心优化 vs Edmonds-Karp**:

| 特性 | Edmonds-Karp | Dinic |
|------|-------------|-------|
| 每轮增广路数 | **1 条** (单次 BFS) | **多条** (DFS 阻塞流) |
| 边扫描效率 | 每次从头扫描 | **当前弧优化** (跳过已饱和边) |
| 时间复杂度 | O(VE²) | **O(E√V)** |
| 适用场景 | 中小规模图 (V < 1000) | 大规模稠密图 |

### Push-Relabel ([push_relabel.mbt](push_relabel.mbt))

**预流推进算法** — 时间复杂度 O(V²E)，使用高度标号（height labeling）和溢出节点（excess flow）概念。

| 函数 | 说明 | 返回 |
|------|------|------|
| `push_relabel(graph, source, sink)` | 使用 Push-Relabel 计算最大流 | `MaxFlowResult` |

**算法流程**:
1. **初始化**: source 高度 = n，其余高度 = 0；从 source 推送初始流量
2. **推送 (Push)**: 将 excess 从高标号节点推送到低标号邻接节点
3. **重标号 (Relabel)**: 当节点有 excess 但无可行推送边时，提升其高度
4. **终止**: 所有节点 excess = 0，返回最大流

**特性**:
- 理论时间复杂度 O(V²E)，稠密图表现优秀
- 与 Dinic 互补：Dinic 适合分层友好的图，Push-Relabel 适合通用场景

### 容量缩放最大流 ([capacity_scaling.mbt](capacity_scaling.mbt))

**基于缩放技术的最大流算法** — 时间复杂度 O(E²·logU)，通过从大到小逐步降低容量阈值，将大规模问题分解为若干轮子问题。

| 函数 | 说明 | 返回 |
|------|------|------|
| `capacity_scaling(graph, source, sink)` | 使用容量缩放技术计算最大流 | `MaxFlowResult` |

**算法流程**:
1. 计算初始 Δ = 2^{⌊log₂(maxCap)⌋}
2. 在残量 ≥ Δ 的图中反复 BFS 增广
3. 当前 Δ 无增广路 → Δ 减半
4. Δ < 1 时终止

**特性**:
- 大容量网络友好，减少不必要的增广次数
- 内部使用 BFS 搜索残量 ≥ Δ 的增广路
- 适合容量值跨度大的网络场景

### Stoer-Wagner 全局最小割 ([stoer_wagner.mbt](stoer_wagner.mbt))

**无向图全局最小割算法** — 时间复杂度 O(VE + V²logV)。

| 函数 | 说明 | 返回 |
|------|------|------|
| `stoer_wagner(adj)` | 计算无向加权图的全局最小割 | `StoerWagnerResult` |

**参数**: `adj` 是 `Array[Array[Double]]` 形式的邻接矩阵。

**算法流程**:
1. 维护当前图（初始为完整图）
2. 每轮执行最大邻接搜索（Maximum Adjacency Search），找到当前图的最紧凑割
3. 合并最后两个节点，缩小图规模
4. 记录所有轮中的最小割，即为全局最小割

**特性**:
- 适用于稠密和稀疏无向图
- 结果包含割的权重和一侧顶点集合

### 最小费用最大流 ([min_cost_max_flow.mbt](min_cost_max_flow.mbt))

**在给定单位费用下寻找最大流中总费用最小的流** — 使用 SPFA 最短路径算法在残差图上反复寻找费用最小的增广路。

| 函数 | 说明 | 返回 |
|------|------|------|
| `min_cost_max_flow(graph, source, sink)` | 计算最小费用最大流 | `MinCostMaxFlowResult` |

**特性**:
- 支持负费用边（无负环）
- 使用势能（potential）优化避免负权边导致的退化
- 结果包含最大流量、最小费用、流量矩阵和费用矩阵

## 算法对比速查

| 算法 | 时间复杂度 | 输入类型 | 适用场景 |
|------|:---------:|:--------:|---------|
| Edmonds-Karp | O(VE²) | FlowNetwork | 教学/小规模，实现最简单 |
| Dinic | O(E√V) | FlowNetwork | 通用最优，分层图友好 |
| Push-Relabel | O(V²E) | FlowNetwork | 稠密图，理论界优秀 |
| Capacity Scaling | O(E²·logU) | FlowNetwork | 大容量网络友好 |
| Stoer-Wagner | O(VE + V²logV) | `Array[Array[Double]]` | 无向图最小割 |
| Min Cost Max Flow | O(F·E·logV) | CostFlowNetwork | 带费用约束的最大流 |

## 使用示例

### 基础用法：简单两节点网络

```moonbit
// 构建网络: 0 --[10.0]--> 1
let net = FlowNetwork::new(2)
let net = net.add_edge(0, 1, 10.0)

// 使用 Edmonds-Karp
let result_ek = edmonds_karp(net, 0, 1)
result_ek.max_flow          // => 10.0

// 使用 Dinic（结果一致，速度更快）
let result_dinic = dinic(net, 0, 1)
result_dinic.max_flow       // => 10.0
```

### 经典多路径网络（CLRS 图 26-6）

```moonbit
// 6 节点 10 条边
let net = FlowNetwork::new(6)
let net = net.add_edge(0, 1, 16.0)
let net = net.add_edge(0, 2, 13.0)
let net = net.add_edge(1, 2, 10.0)
let net = net.add_edge(1, 3, 12.0)
let net = net.add_edge(2, 1, 4.0)
let net = net.add_edge(2, 4, 14.0)
let net = net.add_edge(3, 2, 9.0)
let net = net.add_edge(3, 5, 20.0)
let net = net.add_edge(4, 3, 7.0)
let net = net.add_edge(4, 5, 4.0)

// 四种算法结果一致
let ek = edmonds_karp(net, 0, 5)
let din = dinic(net, 0, 5)
let pr = push_relabel(net, 0, 5)
let cs = capacity_scaling(net, 0, 5)
// 全部返回 23.0
```

### 最小费用最大流

```moonbit
let net = CostFlowNetwork::new(4)
let net = net.add_edge(0, 1, 10.0, 2.0)  // 容量 10，单位费用 2
let net = net.add_edge(0, 2, 5.0, 1.0)
let net = net.add_edge(1, 3, 8.0, 3.0)
let net = net.add_edge(2, 3, 7.0, 4.0)

let result = min_cost_max_flow(net, 0, 3)
result.max_flow    // => 12.0
result.min_cost    // => 38.0
```

### Stoer-Wagner 全局最小割

```moonbit
let adj : Array[Array[Double]] = [
  [0.0, 5.0, 0.0, 0.0],
  [5.0, 0.0, 4.0, 6.0],
  [0.0, 4.0, 0.0, 3.0],
  [0.0, 6.0, 3.0, 0.0],
]
let result = stoer_wagner(adj)
result.min_cut_weight   // => 5.0
```

### 算法选择指南

```moonbit
// 小规模 / 教学用途 → Edmonds-Karp
let result = edmonds_karp(net, s, t)

// 大规模 / 生产环境 → Dinic（性能最优）
let result = dinic(net, s, t)

// 稠密图 → Push-Relabel
let result = push_relabel(net, s, t)

// 超大容量网络 → Capacity Scaling
let result = capacity_scaling(net, s, t)

// 验证正确性 → 多算法交叉验证
let r1 = dinic(net, s, t)
let r2 = edmonds_karp(net, s, t)
let r3 = push_relabel(net, s, t)
assert(abs(r1.max_flow - r2.max_flow) < 0.001)
assert(abs(r2.max_flow - r3.max_flow) < 0.001)
```

### 边界情况处理

```moonbit
// 空网络
let r1 = dinic(FlowNetwork::new(0), 0, 1)
r1.max_flow                  // => 0.0

// Source == Sink
let r2 = dinic(net, 0, 0)
r2.max_flow                  // => 0.0

// 无路径可达
let isolated = FlowNetwork::new(3)
let isolated = isolated.add_edge(0, 1, 5.0)
let r4 = dinic(isolated, 0, 2)
r4.max_flow                  // => 0.0 (节点 2 不可达)
```

### 结果不可变性验证

```moonbit
let original = make_clrs_network()
let _result = dinic(original, 0, 5)
original.flow[0][1]          // => 0.0 (原网络未被修改)
```

## 算法原理

### 残差图与增广路径

所有最大流算法共享相同的核心概念：

```
残差容量 r(u, v) = c(u, v) - f(u, v)   // 正向剩余容量
残差容量 r(v, u) = f(u, v)             // 反向可撤销容量

增广路径: source → ... → sink，满足每条边 r > 0
瓶颈值: 路径上最小残差容量
增广操作: 正向 +bottleneck，反向 -bottleneck
```

### 时间复杂度对比

| 阶段 | Edmonds-Karp | Dinic | Push-Relabel | 容量缩放 |
|------|-------------|-------|-------------|---------|
| 核心操作 | BFS 增广 | 分层+阻塞流 | 推送+重标号 | 缩放轮次+BFS |
| 单次搜索 | O(E) | O(E) BFS + O(VE) DFS | O(1) push | O(E) BFS |
| 迭代次数 | O(VE) | O(√V) | O(V²E) push | O(logU) |
| 总计 | O(VE²) | **O(E√V)** | O(V²E) | O(E²·logU) |

### 流网络 vs 通用图

FlowNetwork 是独立的数据结构，专为流算法优化：
- 邻接矩阵存储 → 容量/流量 O(1) 访问
- 自动反向边管理 → 残差图透明
- 纯函数语义 → 深拷贝保证安全性

## 测试覆盖

| 类别 | 说明 | 测试数 |
|------|------|:------:|
| 基础功能 | 简单/双节点/多路径/经典CLRS网络 | ~25 |
| 算法一致性 | 不同算法间结果交叉验证 | ~15 |
| 边界情况 | 空图/source=sink/越界/无路径/单节点 | ~20 |
| 属性验证 | 不可变性/流量守恒/矩阵维度/非负性 | ~15 |
| Stoer-Wagner | 三角形/链式/线形图/完全图 | ~5 |
| 费用流 | 基础/链式/无路径/多路径 | ~3 |
| **合计** | **83 tests** | **83** |

运行命令:
```bash
moon test lib/algo/flow  # 83 tests (6 个算法)
```

## 设计决策

### 为什么使用独立 FlowNetwork 类型？

1. **类型安全**: 流网络的容量/流量矩阵语义不同于通用图的邻接表
2. **性能**: 矩阵访问 O(1)，适合密集流网络场景
3. **简洁**: 避免将流语义耦合到 core.Graph trait 层次
4. **残差图**: 反向边自动管理，对外透明

### 为什么同时实现多种算法？

1. **教学价值**: 不同算法展示不同的增广策略和优化思路
2. **正确性验证**: 多种独立实现可交叉验证结果
3. **场景适配**: 不同规模/拓扑/容量范围的图可选择最优算法
4. **扩展基础**: 共享 FlowNetwork 类型体系

### 算法命名规范

所有流算法函数统一使用 `graph` 作为参数名（而非 `net`），保持与核心算法模块一致的参数命名约定。

## 与其他模块配合

```moonbit
// 从 Graph 存储构建 FlowNetwork（手动转换）
let g = @storage.new_directed()
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 3.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 4.0) |> ignore

// 转换为 FlowNetwork
let fn = FlowNetwork::new(@core.GraphReadable::node_count(g))
for edge in @core.GraphReadable::edges(g) {
  let fn = fn.add_edge(edge.from.0, edge.to.0, edge.weight)
}

// 最大流（任选算法）
let result = dinic(fn, 0, 2)
```

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.1.0 | 2026-05-19 | 初始版本：Edmonds-Karp |
| v0.2.0 | 2026-05-19 | 新增 Dinic 算法 |
| **v0.3.0** | **2026-06-09** | **新增 Push-Relabel / Stoer-Wagner / 最小费用流 / 容量缩放 (83 tests)** |
