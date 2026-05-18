---
title: "网络流算法模块设计"
version: "0.1.0"
status: "approved"
type: "design"
created: "2026-05-18"
updated: "2026-05-18"
author: "morning-start"
tags: ["flow", "max_flow", "edmonds_karp", "design"]
---

# 网络流 (`src/algorithms/flow/`) 设计文档

> **版本**: v0.1.0 | **状态**: 已批准 | **日期**: 2026-05-18

---

## 1. 概述

提供最大流求解能力，使用独立 FlowNetwork 类型管理容量和残差图，不污染 core 类型系统。

## 2. 设计决策

| 决策项 | 选择 |
|--------|------|
| 算法 | Edmonds-Karp（BFS 增广路） |
| 流图表示 | 独立 FlowNetwork 类型 |
| 结果类型 | MaxFlowResult { max_flow, flow_matrix } |

## 3. API 清单（3 个公开函数 + 2 个公开类型）

### 3.1 FlowNetwork — [flow_network.mbt](../src/algorithms/flow/flow_network.mbt)

```moonbit
pub(all) struct FlowNetwork {
  node_count : Int
  capacity : Array[Array[Double>>
  flow : Array[Array<Double>>
}
// 方法: new(node_count) -> FlowNetwork
//       add_edge(from, to, capacity) -> FlowNetwork
```

### 3.2 MaxFlowResult — [types.mbt](../src/algorithms/flow/types.mbt)

```moonbit
pub(all) struct MaxFlowResult {
  max_flow : Double
  flow_matrix : Array[Array[Double?>>
}
```

### 3.3 Edmonds-Karp — [edmonds_karp.mbt](../src/algorithms/flow/edmonds_karp.mbt)

| 函数 | 说明 | 返回 |
|------|------|------|
| `edmonds_karp(fn, source, sink)` | 最大流 (BFS 增广路) | `MaxFlowResult` |

## 4. 文件组织

```
src/algorithms/flow/
├── moon.pkg
├── types.mbt              # MaxFlowResult
├── flow_network.mbt       # FlowNetwork
├── edmonds_karp.mbt       # Edmonds-Karp
└── flow_test.mbt          # 测试
```

## 5. 算法复杂度

| 算法 | 时间复杂度 | 空间复杂度 |
|------|-----------|-----------|
| Edmonds-Karp | O(V E²) | O(V²) 容量+流量矩阵 |

## 6. 关键实现细节

- 残差图隐式维护: residual[u][v] = capacity[u][v] - flow[u][v]
- 反向边用于撤销: add_edge(u,v,c) 自动初始化反向边 capacity=0
- BFS 仅走残差 > 0 的边
- 路径瓶颈 = min(路径上各边残差)
