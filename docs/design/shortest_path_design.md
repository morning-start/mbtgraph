---
title: "最短路径算法模块设计"
version: "0.1.0"
status: "approved"
type: "design"
created: "2026-05-18"
updated: "2026-05-18"
author: "morning-start"
tags: ["shortest_path", "dijkstra", "bellman_ford", "floyd_warshall", "design"]
---

# 最短路径算法 (`src/algorithms/shortest_path/`) 设计文档

> **版本**: v0.1.0 | **状态**: 已批准 | **日期**: 2026-05-18

---

## 1. 概述

提供加权图最短路径求解能力，覆盖单源和全源场景、非负权和负权边。

## 2. 设计决策

| 决策项 | 选择 |
|--------|------|
| 算法范围 | Dijkstra + Bellman-Ford + Floyd-Warshall |
| 优先队列 | 自建 BinaryHeap（二叉最小堆） |
| 结果类型 | 独立 ShortestPathResult 结构体 + 辅助方法 |

## 3. API 清单（5 个公开函数 + 2 个结果类型）

### 3.1 结果类型 — [types.mbt](../src/algorithms/shortest_path/types.mbt)

```moonbit
pub(all) struct ShortestPathResult {
  distances : Array[Double?>    // None = 不可达
  parents : Array[@core.NodeId?]
}
// 方法: distance_to(id) -> Double (不可达返回 -1)
//       path_to(id) -> Array[NodeId] (不可达返回空数组)
//       is_reachable(id) -> Bool
//       reachable_count() -> Int

pub(all) struct FloydWarshallResult {
  distances : Array[Array[Double?>>
  next : Array[Array[@core.NodeId?]>
}
// 方法: distance(from, to) -> Double
//       path(from, to) -> Array[NodeId]
```

### 3.2 Dijkstra — [dijkstra.mbt](../src/algorithms/shortest_path/dijkstra.mbt)

| 函数 | 说明 | 返回 |
|------|------|------|
| `dijkstra(g, source)` | 非负权单源最短路径 | ShortestPathResult |
| `dijkstra_targeted(g, source, target)` | 提前终止优化版 | 路径节点数组 |

### 3.3 Bellman-Ford — [bellman_ford.mbt](../src/algorithms/shortest_path/bellman_ford.mbt)

| 函数 | 说明 | 返回 |
|------|------|------|
| `bellman_ford(g, source)` | 支持负权的单源最短路径 | Result[ShortestPathResult, String] |

### 3.4 Floyd-Warshall — [floyd_warshall.mbt](../src/algorithms/shortest_path/floyd_warshall.mbt)

| 函数 | 说明 | 返回 |
|------|------|------|
| `floyd_warshall(g)` | 全源最短路径 | Result[FloydWarshallResult, String] |

## 4. 文件组织

```
src/algorithms/shortest_path/
├── moon.pkg
├── types.mbt           # 结果类型 + 辅助方法
├── heap.mbt            # BinaryHeap (priv, 不对外暴露)
├── dijkstra.mbt        # Dijkstra 算法
├── bellman_ford.mbt    # Bellman-Ford 算法
├── floyd_warshall.mbt   # Floyd-Warshall 算法
└── shortest_path_test.mbt  # 测试
```

## 5. 算法复杂度与约束

| 算法 | 时间复杂度 | Trait 约束 | 权重限制 | 特殊处理 |
|------|-----------|-----------|---------|---------|
| Dijkstra | O((V+E)log V) | GraphReadable | 非负权 | 不可达 = None |
| Bellman-Ford | O(VE) | GraphReadable | 允许负权 | 第 V 轮松弛 → 负环 Err |
| Floyd-Warshall | O(V³) | GraphReadable | 允许负权 | 含负环 Err |

## 6. 内部组件：BinaryHeap

- **可见性**: `priv struct`，仅包内使用
- **类型**: 存储 `(Double, NodeId)` 元组，按 Double 排序
- **操作**: push / pop / is_empty / length
- **用途**: 仅 Dijkstra 使用

## 7. 边界处理

| 条件 | 行为 |
|------|------|
| 空图 (V=0) | 返回空结果 / Ok(空矩阵) |
| 源点不存在 | 返回空结果 / Err |
| 目标不可达 | distance=None / distance=-1 / path=[] |
| 负环存在 (BF/FW) | Err("negative cycle detected") |
