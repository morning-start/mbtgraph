---
title: "网络流算法模块设计"
version: "0.2.0"
status: "approved"
type: "design"
created: "2026-05-18"
updated: "2026-05-19"
author: "morning-start"
tags: ["flow", "max_flow", "edmonds_karp", "dinic", "design"]
---

# 网络流 (`src/algo/flow/`) 设计文档

> **版本**: v0.2.0 | **状态**: 已批准 | **日期**: 2026-05-19
>
> **变更**: v0.1.0 → v0.2.0 新增 Dinic 算法 (O(E√V))

---

## 1. 概述

提供最大流求解能力，使用独立 FlowNetwork 类型管理容量和残差图，不污染 core 类型系统。

**v0.2.0 新增**: Dinic 分层阻塞流算法，比 Edmonds-Karp 快一个数量级。

## 2. 设计决策

| 决策项 | 选择 | 说明 |
|--------|------|------|
| 流图表示 | 独立 FlowNetwork 类型 | 矩阵 O(1) 访问，适合密集网络 |
| 结果类型 | MaxFlowResult { max_flow, flow_matrix } | 含流量矩阵便于分析 |
| 算法 1 | Edmonds-Karp（BFS 增广路） | O(VE²)，实现简洁，教学友好 |
| 算法 2 | **Dinic（分层阻塞流）** ✨ | **O(E√V)，性能更优，生产推荐** |
| 语义保证 | 深拷贝纯函数 | 输入网络不被修改 |

### 为什么两种算法？

| 维度 | Edmonds-Karp | Dinic |
|------|-------------|-------|
| 实现复杂度 | ⭐⭐ 低 (~100 行) | ⭐⭐⭐ 中 (~170 行) |
| 时间复杂度 | O(VE²) | O(E√V) |
| 适用场景 | 中小规模 / 教学 | 大规模 / 生产 |
| 核心价值 | 易于理解增广路概念 | 当前弧优化 + 阻塞流 |
| 验证价值 | 基准参考 | 可与 EK 交叉验证 |

## 3. API 清单（4 个公开函数 + 2 个公开类型）

### 3.1 FlowNetwork — [flow_network.mbt](../src/algo/flow/flow_network.mbt)

```moonbit
pub(all) struct FlowNetwork {
  node_count : Int
  capacity : Array[Array[Double>>     // 容量矩阵
  flow : Array[Array[Double>>         // 流量矩阵
}
// 方法:
//   FlowNetwork::new(node_count) -> FlowNetwork
//   add_edge(self, from, to, capacity) -> FlowNetwork
```

**设计要点**:
- 独立于 core 的 Edge/Graph 体系，完全自包含
- `add_edge` 自动创建反向边（初始容量 = 0），用于残差图撤销
- 函数式风格：方法返回新实例，原始网络不被修改
- 矩阵表示限制：并行边后写覆盖前值

### 3.2 MaxFlowResult — [types.mbt](../src/algo/flow/types.mbt)

```moonbit
pub(all) struct MaxFlowResult {
  max_flow : Double                          // 最大流量值
  flow_matrix : Array[Array[Double?>>        // 流量矩阵 (None = 无流量)
}
```

### 3.3 Edmonds-Karp — [edmonds_karp.mbt](../src/algo/flow/edmonds_karp.mbt)

| 函数 | 说明 | 返回 |
|------|------|------|
| `edmonds_karp(net, source, sink)` | 最大流 (BFS 增广路) | `MaxFlowResult` |

**内部组件**:

| 组件 | 功能 |
|------|------|
| `ek_bfs()` | BFS 在残差图中找 source→sink 路径 |
| `ek_find_path_bottleneck()` | 回溯 parent 数组计算瓶颈容量 |
| `ek_augment()` | 沿路径更新流量（正向+，反向-）|
| `deep_copy_matrix()` | 深拷贝保证纯函数语义 |

### 3.4 Dinic — [dinic.mbt](../src/algo/flow/dinic.mbt) ✨ v0.2.0 新增

| 函数 | 说明 | 返回 |
|------|------|------|
| `dinic(net, source, sink)` | 最大流 (BFS 分层 + DFS 阻塞流) | `MaxFlowResult` |

**内部组件**:

| 组件 | 功能 |
|------|------|
| `dinic_bfs()` | BFS 构建层次图 (level graph)，标记每个节点距 source 的最短距离 |
| `dinic_dfs()` | 在层次图上 DFS 找阻塞流，含**当前弧优化**跳过已饱和边 |
| `dinic_deep_copy()` | 深拷贝保证纯函数语义 |

**Dinic 三大核心优化**:

```
优化 1: BFS 分层
  → 只沿层次递增的边搜索，保证每次找到的是最短增广路
  → 层次数 ≤ V，因此外层循环最多 √V 次（单位容量网络）

优化 2: 阻塞流
  → 每次 DFS 不只找 1 条路，而是找"阻塞流"（无法再增广为止）
  → 单次 BFS 分层可推送多条增广路的流量

优化 3: 当前弧优化
  → current_arc[u] 记录节点 u 下次从哪条边开始扫描
  → 已饱和的边不再重复检查，总边扫描次数 = O(VE)
```

## 4. 文件组织

```
src/algo/flow/
├── moon.pkg              # 包配置 (import @core)
├── types.mbt             # MaxFlowResult 结果类型
├── flow_network.mbt      # FlowNetwork 流网络结构体
├── edmonds_karp.mbt      # Edmonds-Karp 最大流 (O(VE²))
├── dinic.mbt             # Dinic 最大流 (O(E√V))       ← v0.2.0 新增
├── flow_test.mbt         # Edmonds-Karp 测试 (17 tests)
├── dinic_test.mbt        # Dinic 测试 (16 tests)        ← v0.2.0 新增
└── README.md             # 模块文档 (v0.2.0 双算法指南)
```

## 5. 算法复杂度对比

| 维度 | Edmonds-Karp | Dinic |
|------|-------------|-------|
| **时间复杂度** | O(VE²) | **O(E√V)** |
| 空间复杂度 | O(V²) | O(V²) |
| 单次搜索 | O(E) BFS | O(E) BFS + O(VE) DFS |
| 增广轮数 | O(VE) | **O(√V)** |
| 最坏场景 | 长链状图 | 单位容量网络 |
| 实际加速比 | 基线 (1x) | **5-50x** (取决于拓扑) |

## 6. 关键实现细节

### 6.1 共享机制（两算法通用）

- **残差图隐式维护**: `residual[u][v] = capacity[u][v] - flow[u][v]`
- **反向边用于撤销**: `add_edge(u,v,c)` 自动初始化反向边 `capacity=0`
- **深拷贝纯函数语义**: 算法在副本上执行，`original.flow` 始终为 0
- **浮点容差**: 使用 `0.000001` 作为零值判定阈值

### 6.2 Edmonds-Karp 特有

- BFS 仅走 `residual > 0` 的边
- 路径瓶颈 = min(路径上各边残差)
- 每次增广恰好 1 条路径

### 6.3 Dinic 特有

- **层次图 (Level Graph)**: `level[v]` = source 到 v 的最短距离（边数）
- **DFS 只走 level[v] == level[u] + 1 的边**（保证不回头）
- **当前弧数组**: `current_arc[u]` 从上次停止位置继续，跳过已饱和边
- **提前终止**: 当 `remaining <= 0` 时立即返回（无需遍历剩余边）

## 7. 测试策略

| 类别 | EK tests | Dinic tests | 内容 |
|------|:--------:|:-----------:|------|
| 基础功能 | 5 | 6 | 空/简单/多路径/经典/并行/菱形/瓶颈 |
| 一致性验证 | — | 3 | Dinic vs EK 结果一致性 |
| 边界情况 | 5 | 4 | 空/source=sink/无路径/单节点 |
| 属性验证 | 1 | 3 | 纯函数不变式/矩阵维度/非负性 |
| **合计** | **17** | **16** | **33 total** |

**交叉验证设计**: 3 个一致性测试确保两种独立实现的正确性：
```moonbit
let ek_result = edmonds_karp(net, s, t)
let dinic_result = dinic(net, s, t)
assert(abs(ek_result.max_flow - dinic_result.max_flow) < 0.001)
```

## 8. 扩展规划

### 已完成

| 版本 | 内容 | 测试 |
|:----:|------|:----:|
| v0.1.0 | Edmonds-Karp + FlowNetwork | 17 |
| **v0.2.0** | **+ Dinic 算法** | **+16 (33 total)** |

### 待扩展

| 优先级 | 算法 | 复杂度 | 说明 |
|:-----:|------|:-----:|------|
| P1 | Push-Relabel | O(V³) | 理论最优实践 |
| P2 | Cost Flow (最小费用流) | O(VE log V) | 扩展到带权边场景 |
| P3 | 多源多汇 | — | 复用单源单汇结果 |

## 9. 设计决策记录

### DD-01: 为什么独立 FlowNetwork 类型？

**决策**: 不适配 core.GraphReadable trait

**理由**:
1. 流网络的容量/流量矩阵语义不同于通用图的邻接表
2. 矩阵访问 O(1)，适合密集流网络场景
3. 反向边管理是流算法特有逻辑，不应污染 Graph trait
4. 未来可通过 Adapter 模式桥接（ARCHITECTURE.md R1 风险项）

### DD-02: 为什么同时实现两种算法？

**决策**: EK + Dinic 双算法并存

**理由**:
1. 教学价值: EK 代码简洁，适合理解增广路核心概念
2. 正确性验证: 两种独立实现可交叉验证结果
3. 场景适配: 不同规模/拓扑选择最优算法
4. 扩展基础: 共享 FlowNetwork，后续 Push-Relabel 易接入

### DD-03: Dinic 的 mut 参数问题

**问题**: MoonBit 不支持 `mut fn_param` 语法

**解决**: 用 `let mut remaining = min_cap` 在函数体内重新绑定可变变量
