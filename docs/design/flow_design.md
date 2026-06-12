# 网络流模块设计文档

> **模块**: `lib/algo/flow/`
> **创建日期**: 2026-06-12
> **状态**: ✅ 6 个算法全部实现

---

## 1. 架构设计

### 1.1 独立类型模式

网络流模块采用 **独立类型模式**（而非 Trait 兼容型），这是 mbtgraph 中"双轨制"架构的典型案例：

```
Trait 兼容型（多数算法）： pub fn[G : GraphReadable] dijkstra(graph, start)
独立类型型（流网络）：    pub fn dinic(net : FlowNetwork, source, sink)
```

**决策理由**:
1. 流网络需要维护 `capacity` 和 `flow` 两个矩阵，语义上不同于一般图
2. `FlowNetwork` 使用 `Int` 节点索引而非 `NodeId`，避免装箱开销
3. 矩阵访问 O(1) 优于 trait 方法调用，这对密集增广的流算法至关重要

### 1.2 类型层次

```
FlowNetwork
├── node_count : Int
├── capacity : Array[Array[Double]]
└── flow : Array[Array[Double]]

CostFlowNetwork (extends FlowNetwork)
└── cost : Array[Array[Double]]
```

### 1.3 返回值设计

所有流算法返回统一的 `MaxFlowResult`:
```
MaxFlowResult
├── max_flow : Double
└── flow_matrix : Array[Array[Double?]]
```

---

## 2. 算法全景

| 算法 | 复杂度 | 策略 | 场景 |
|------|:------:|------|------|
| Edmonds-Karp | O(VE²) | BFS 最短增广路 | 教学友好，小图 |
| Dinic ⭐ | O(E√V) | 分层图+阻塞流 | 通用最优 |
| Push-Relabel | O(V²E) | 预流推进+重标记 | 稠密图 |
| Capacity Scaling | O(E²·logU) | 分治缩放 | 超大容量网络 |
| Stoer-Wagner | O(VE+V²logV) | 最大邻接搜索 | 全局最小割 |
| Min Cost Max Flow | O(V²·E) | SSP 最短费用路 | 带权网络 |

---

## 3. 设计决策记录

### DDR-01: 选择独立类型而非 GraphReadable

| 方案 | 优势 | 劣势 |
|------|------|------|
| **独立类型** ⭐ | 性能好，语义清晰 | 不能复用 Trait 方法 |
| Trait 兼容 | 统一 API 风格 | 性能差，语义混淆 |

**结论**: 独立类型。流网络的容量/流量语义与一般图不同。

### DDR-02: 使用矩阵而非邻接表

- 矩阵 O(1) 随机访问，适合残量网络频繁查询
- 流图通常稠密或中等规模（V ≤ 10K）
- 空间 O(V²) 对 V ≤ 10K 可接受（~800MB for 10K）

### DDR-03: Dinic 为推荐算法

- 平均性能最优（O(E√V)）
- 实现简单（BFS 分层 + DFS 阻塞流）
- 一致性高于 Push-Relabel

---

## 4. 纯函数语义

所有算法通过深拷贝保证不可变性：

```moonbit
let work_flow = deep_copy_matrix(net.flow)
// 修改 work_flow，不触及原始 net
MaxFlowResult::{ max_flow: total, flow_matrix: result_matrix }
```

---

## 5. 边界处理

| 边界 | 行为 |
|------|------|
| source == sink | 返回 `max_flow: 0.0` |
| source/sink 越界 | 返回 `max_flow: 0.0` |
| 空图 (node_count == 0) | 返回 `max_flow: 0.0` |
| 负权容量 | 不支持，视为 0 |

---

## 6. 测试策略

- Edmonds-Karp 与 Dinic 的一致性验证（10 tests）
- 经典网络流案例（7 tests）
- 边界条件（空图/越界/零容量）
- Stoer-Wagner 与 MaxFlow 最小割等价性
