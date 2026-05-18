# 网络流算法 (`flow`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 17 通过

提供流网络上的最大流求解能力，基于 Edmonds-Karp 算法（Ford-Fulkerson 的 BFS 实现）。

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | 类型定义 |

## 文件结构

```
src/algorithms/flow/
├── moon.pkg           # 包配置
├── types.mbt          # MaxFlowResult 结果类型
├── flow_network.mbt   # FlowNetwork 流网络结构体 + 工厂/边添加
├── edmonds_karp.mbt   # Edmonds-Karp 最大流算法
└── flow_test.mbt      # 17 个测试
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
- 容量矩阵只读，仅修改工作副本的流量矩阵

## 使用示例

### 基础用法：简单两节点网络

```moonbit
// 构建网络: 0 --[10.0]--> 1
let net = FlowNetwork::new(2)
let net = net.add_edge(0, 1, 10.0)

// 计算最大流
let result = edmonds_karp(net, 0, 1)
result.max_flow               // => 10.0
// result.flow_matrix[0][1]    // => Some(10.0)
// result.flow_matrix[1][0]    // => None (反向无流量)
```

### 经典多路径网络

```moonbit
// CLRS 示例: 4 节点 5 条边的有向网络
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 3.0)   // s -> a
let net = net.add_edge(0, 2, 2.0)   // s -> b
let net = net.add_edge(1, 2, 5.0)   // a -> b
let net = net.add_edge(1, 3, 2.0)   // a -> t
let net = net.add_edge(2, 3, 3.0)   // b -> t

let result = edmonds_karp(net, 0, 3)
result.max_flow               // => 5.0
// 流量分配: s->a->t (2.0) + s->b->t (2.0) + s->a->b->t (1.0)
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

let result = edmonds_karp(net, 0, 5)
result.max_flow               // => 23.0
```

### 边界情况处理

```moonbit
// 空网络
let r1 = edmonds_karp(FlowNetwork::new(0), 0, 1)
r1.max_flow                  // => 0.0
r1.flow_matrix.length()      // => 0

// Source == Sink
let r2 = edmonds_karp(net, 0, 0)
r2.max_flow                  // => 0.0

// 不存在的节点
let r3 = edmonds_karp(net, -1, 1)
r3.max_flow                  // => 0.0

// 无路径可达
let isolated = FlowNetwork::new(3)
let isolated = isolated.add_edge(0, 1, 5.0)
let r4 = edmonds_karp(isolated, 0, 2)
r4.max_flow                  // => 0.0 (节点 2 不可达)
```

### 结果不可变性验证

```moonbit
let original = make_simple_network()
let _result = edmonds_karp(original, 0, 1)
original.flow[0][1]          // => 0.0 (原网络未被修改)
```

## 算法原理

### 残差图与增广路径

Edmonds-Karp 核心概念：

```
残差容量 r(u, v) = c(u, v) - f(u, v)   // 正向剩余容量
残差容量 r(v, u) = f(u, v)             // 反向可撤销容量

增广路径: source → ... → sink，满足每条边 r > 0
瓶颈值: 路径上最小残差容量
增广操作: 正向 +bottleneck，反向 -bottleneck
```

### 时间复杂度分析

| 阶段 | 复杂度 | 说明 |
|------|--------|------|
| 单次 BFS | O(E) | 遍历所有边找最短路 |
| 增广次数 | O(VE) | 每次至少使最短增广路长度 +1 |
| 总计 | **O(VE²)** | 最坏情况上界 |

实际性能通常优于理论最坏值，尤其对稀疏图。

### 与 Dinic 对比

| 特性 | Edmonds-Karp | Dinic |
|------|-------------|-------|
| 时间复杂度 | O(VE²) | O(V²E) / O(E√V) (单位容量) |
| 实现难度 | ⭐⭐ 简单 | ⭐⭐⭐ 中等 |
| 适用场景 | 一般用途 | 大规模稠密图 |
| 当前状态 | ✅ 已实现 | 📋 待扩展 |

## 内部组件

### BFS 增广路径搜索 (`ek_bfs`)

私有辅助函数，在残差图中 BFS 寻找 source→sink 路径。

- **输入**: 容量矩阵、流量矩阵、节点数、源点、汇点
- **输出**: `(parent数组, 是否找到)`
- **parent[v]**: 记录节点 v 的前驱，用于路径重建和瓶颈计算

### 瓶颈值计算 (`ek_find_path_bottleneck`)

沿 parent 数组回溯，找出路径最小残差容量。

### 流量增广 (`ek_augment`)

沿 parent 数组更新流量：
- 正向边 `+bottleneck`
- 反向边 `-bottleneck`（支持未来撤销）

### 深拷贝 (`deep_copy_matrix`)

保证纯函数语义：算法在副本上执行，不修改原始网络。

## 边界行为

| 条件 | 行为 | 返回值 |
|------|------|--------|
| 空网络 (n=0) | 直接返回零结果 | max_flow=0.0, matrix=[] |
| source == sink | 视为无效请求 | max_flow=0.0, matrix=[] |
| source < 0 或 >= n | 节点越界 | max_flow=0.0, matrix=[] |
| sink < 0 或 >= n | 节点越界 | max_flow=0.0, matrix=[] |
| 无增广路径存在 | 正常终止 | max_flow=0.0 (无可行流) |
| 自环 (u→u) | add_edge 直接忽略 | 返回未修改的网络 |
| from/to 越界 | add_edge 直接忽略 | 返回未修改的网络 |

## 测试覆盖

| 类别 | 数量 | 内容 |
|------|:----:|------|
| FlowNetwork 基础 | 5 | 空网络/正常创建/添加边/越界/自环 |
| Edmonds-Karp 简单 | 3 | 两节点最大流/矩阵大小/流量存在性 |
| Edmonds-Karp 经典 | 2 | 4 节点多路径/矩阵维度验证 |
| Edmonds-Karp 复杂 | 1 | CLRS 6 节点网络 (max_flow=23) |
| 边界情况 | 5 | 空图/source=sink/负索引/越界/无路径 |
| 不可变性验证 | 1 | 原始网络未被修改 |
| **合计** | **17** | |

## 设计决策

### 为什么使用独立 FlowNetwork 类型？

1. **类型安全**: 流网络的容量/流量矩阵语义不同于通用图的邻接表
2. **性能**: 矩阵访问 O(1)，适合密集流网络场景
3. **简洁**: 避免将流语义耦合到 core.Graph trait 层次
4. **残差图**: 反向边自动管理，对外透明

### 为什么选择 Edmonds-Karp 而非 Dinic？

1. **实现简洁**: 代码量少 ~40%，适合作为首个流算法实现
2. **正确性易证**: BFS 保证最短增广路，逻辑清晰
3. **足够实用**: 对于中小规模图（V < 1000）性能良好
4. **扩展友好**: 后续可在此基础上实现 Dinic（相同的 FlowNetwork 类型）

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

// 最大流
let result = edmonds_karp(fn, 0, 2)
```
