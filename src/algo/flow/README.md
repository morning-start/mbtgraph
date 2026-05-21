# 网络流算法 (`flow`)

> **版本**: v0.2.0 | **状态**: 稳定 | **测试**: 33 通过

提供流网络上的最大流求解能力，包含两种算法：
- **Edmonds-Karp** — BFS 增广路算法 O(VE²)，实现简洁，适合入门学习
- **Dinic** — 分层阻塞流算法 O(E√V)，性能更优，适合大规模网络

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | 类型定义 |

## 文件结构

```
src/algo/flow/
├── moon.pkg           # 包配置
├── types.mbt          # MaxFlowResult 结果类型
├── flow_network.mbt   # FlowNetwork 流网络结构体 + 工厂/边添加
├── edmonds_karp.mbt   # Edmonds-Karp 最大流算法 (O(VE²))
├── dinic.mbt          # Dinic 最大流算法 (O(E√V))
├── flow_test.mbt      # Edmonds-Karp 测试 (17 tests)
└── dinic_test.mbt     # Dinic 测试 (16 tests)
```

## API 总览

### 核心类型 ([types.mbt](types.mbt))

#### `MaxFlowResult` — 最大流结果

```moonbit
pub(all) struct MaxFlowResult {
  max_flow : Double              // 最大流量值
  flow_matrix : Array[Array[Double?>>  // 流量矩阵 (None = 无流量)
}
```

### FlowNetwork ([flow_network.mbt](flow_network.mbt))

**独立的流网络数据结构** — 使用邻接矩阵存储容量和流量，不依赖 core 的 Graph trait。

```moonbit
pub(all) struct FlowNetwork {
  node_count : Int                    // 节点数
  capacity : Array[Array[Double>>     // 容量矩阵 capacity[u][v]
  flow : Array[Array[Double>>         // 流量矩阵 flow[u][v]
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

### Edmonds-Karp ([edmonds_karp.mbt](edmonds_karp.mbt))

**BFS 增广路最大流算法** — 时间复杂度 O(VE²)，Ford-Fulkerson 的 BFS 变体。

| 函数 | 说明 | 返回 |
|------|------|------|
| `edmonds_karp(net, source, sink)` | 计算从 source 到 sink 的最大流 | `MaxFlowResult` |

**算法流程**:
1. 初始化：所有边流量为 0
2. 循环：用 BFS 在残差图中寻找最短增广路径
3. 找到路径 → 计算瓶颈容量 → 沿路径增广流量
4. 无增广路径 → 终止，返回最大流

**特性**:
- 保证在 O(VE²) 内终止（BFS 保证每次找到最短增广路）
- 自动处理多路径并行流量分配
- 输入网络不被修改（深拷贝语义）

### Dinic ([dinic.mbt](dinic.mbt)) ✨ 新增

**分层阻塞流最大流算法** — 时间复杂度 O(E√V)，比 Edmonds-Karp 快一个数量级。

| 函数 | 说明 | 返回 |
|------|------|------|
| `dinic(net, source, sink)` | 计算从 source 到 sink 的最大流 | `MaxFlowResult` |

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

**内部组件**:

| 组件 | 可见性 | 功能 |
|------|:------:|------|
| `dinic_bfs()` | priv | BFS 构建层次图 (level graph) |
| `dinic_dfs()` | priv | 在层次图上找阻塞流 (含当前弧优化) |
| `dinic_deep_copy()` | priv | 深拷贝保证纯函数语义 |

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

### 经典多路径网络

```moonbit
// CLRS 示例: 4 节点 5 条边的有向网络
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 3.0)   // s -> a
let net = net.add_edge(0, 2, 2.0)   // s -> b
let net = net.add_edge(1, 3, 2.0)   // a -> t
let net = net.add_edge(2, 3, 3.0)   // b -> t

let result = dinic(net, 0, 3)
result.max_flow               // => 4.0
```

### 复杂网络（CLRS 图 26-6）

```moonbit
// 6 节点 10 条边的经典示例
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

let result = dinic(net, 0, 5)
result.max_flow               // => 23.0
// 与 edmonds_karp(net, 0, 5).max_flow 完全一致
```

### 算法选择指南

```moonbit
// 小规模 / 教学用途 → Edmonds-Karp（代码简洁易理解）
let result = edmonds_karp(small_net, s, t)

// 大规模 / 生产环境 → Dinic（性能更优）
let result = dinic(large_net, s, t)

// 验证正确性 → 双算法交叉验证
let ek_result = edmonds_karp(net, s, t)
let dinic_result = dinic(net, s, t)
assert(abs(ek_result.max_flow - dinic_result.max_flow) < 0.001)
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

两种算法共享相同的核心概念：

```
残差容量 r(u, v) = c(u, v) - f(u, v)   // 正向剩余容量
残差容量 r(v, u) = f(u, v)             // 反向可撤销容量

增广路径: source → ... → sink，满足每条边 r > 0
瓶颈值: 路径上最小残差容量
增广操作: 正向 +bottleneck，反向 -bottleneck
```

### 时间复杂度对比

| 阶段 | Edmonds-Karp | Dinic |
|------|-------------|-------|
| 单次搜索 | O(E) BFS | O(E) BFS 分层 + O(VE) DFS 阻塞流 |
| 增广次数 | O(VE) | **O(√V)** (分层次数) |
| 总计 | **O(VE²)** | **O(E√V)** |
| 最坏场景 | 长链状图 | 单位容量网络 |

实际性能：Dinic 通常比 EK 快 **5-50x**（取决于图的稠密程度和拓扑结构）。

## 内部组件

### Edmonds-Karp 组件

| 函数 | 功能 |
|------|------|
| `ek_bfs()` | BFS 在残差图中寻找 source→sink 路径 |
| `ek_find_path_bottleneck()` | 沿 parent 数组回溯计算瓶颈值 |
| `ek_augment()` | 沿路径更新流量（正向+，反向-）|
| `deep_copy_matrix()` | 深拷贝保证纯函数语义 |

### Dinic 组件

| 函数 | 功能 |
|------|------|
| `dinic_bfs()` | BFS 构建层次图，标记每个节点的 level |
| `dinic_dfs()` | 在层次图上 DFS 找阻塞流（含当前弧优化）|
| `dinic_deep_copy()` | 深拷贝保证纯函数语义 |

## 边界行为

| 条件 | 行为 | 返回值 |
|------|------|--------|
| 空网络 (n=0) | 直接返回零结果 | max_flow=0.0, matrix=[] |
| source == sink | 视为无效请求 | max_flow=0.0, matrix=[] |
| source < 0 或 >= n | 节点越界 | max_flow=0.0, matrix=[] |
| sink < 0 或 >= n | 节点越界 | max_flow=0.0, matrix=[] |
| 无增广路径存在 | 正常终止 | max_flow=0.0 (无可行流) |
| 自环 (u→u) | add_edge 直接忽略 | 返回未修改的网络 |
| 并行边 (多次 add_edge) | 后写入覆盖前值 | 取最后一次的容量 |

## 测试覆盖

| 类别 | EK | Dinic | 内容 |
|------|:--:|:----:|------|
| 基础功能 | 5 | 6 | 空网络/简单/多路径/经典/并行/菱形/瓶颈 |
| 一致性验证 | — | 3 | Dinic vs EK 结果一致性 (simple/clrs/parallel) |
| 边界情况 | 5 | 4 | 空/source=sink/无路径/单节点 |
| 属性验证 | 1 | 3 | 纯函数不变式/矩阵维度/非负性 |
| **合计** | **17** | **16** | **33 total** |

运行命令:
```bash
moon test src/algo/flow  # 33 tests (17 EK + 16 Dinic)
```

## 设计决策

### 为什么使用独立 FlowNetwork 类型？

1. **类型安全**: 流网络的容量/流量矩阵语义不同于通用图的邻接表
2. **性能**: 矩阵访问 O(1)，适合密集流网络场景
3. **简洁**: 避免将流语义耦合到 core.Graph trait 层次
4. **残差图**: 反向边自动管理，对外透明

### 为什么同时实现两种算法？

1. **教学价值**: EK 代码简洁易懂，适合理解增广路概念
2. **正确性验证**: 两种独立实现可交叉验证结果
3. **场景适配**: 不同规模/拓扑的图可选择最优算法
4. **扩展基础**: 共享 FlowNetwork 类型，后续可扩展 Push-Relabel 等

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
  let fn = fn.add(edge.from.0, edge.to.0, edge.weight)
}

// 最大流（任选算法）
let result = dinic(fn, 0, 2)
```

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.1.0 | 2026-05-19 | 初始版本：Edmonds-Karp + 17 tests |
| **v0.2.0** | **2026-05-19** | **新增 Dinic 算法 + 16 tests + README 更新** |
