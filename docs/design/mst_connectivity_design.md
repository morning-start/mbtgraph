---
title: "MST + 连通性模块设计"
version: "0.1.0"
status: "approved"
type: "design"
created: "2026-05-18"
updated: "2026-05-18"
author: "morning-start"
tags: ["mst", "connectivity", "scc", "union_find", "design"]
---

# MST + 连通性 (`src/algorithms/mst/` + `src/algorithms/connectivity/`) 设计文档

> **版本**: v0.1.0 | **状态**: 已批准 | **日期**: 2026-05-18

---

## 1. 概述

提供无向图最小生成树（MST）求解和图的连通性分析能力。

## 2. 设计决策

| 决策项           | 选择                                                     |
| ---------------- | -------------------------------------------------------- |
| MST 结果类型     | 独立 MstResult { total_weight, edges }                   |
| 连通分量结果类型 | ConnectedComponents { components: Array[Array[NodeId]] } |
| Union-Find 位置  | mst/union_find.mbt（Kruskal 核心依赖）                   |

## 3. API 清单（6 个公开函数 + 3 个结果类型）

### 3.1 MST 结果 — [mst/types.mbt](../src/algorithms/mst/types.mbt)

```moonbit
pub(all) struct MstResult {
  total_weight : Double
  edges : Array[(NodeId, NodeId, Double)]
}
// 方法: edge_count() -> Int, has_edge(u, v) -> Bool
```

### 3.2 连通性结果 — [connectivity/types.mbt](../src/algorithms/connectivity/types.mbt)

```moonbit
pub(all) struct ConnectedComponents {
  components : Array[Array[NodeId]]
}
// 方法: count() -> Int, component_of(id) -> Int, size(id) -> Int

pub(all) struct StronglyConnectedComponents {
  components : Array[Array[NodeId]]
}
```

### 3.3 MST 算法 — [mst/kruskal.mbt](../src/algorithms/mst/kruskal.mbt), [mst/prim.mbt](../src/algorithms/mst/prim.mbt)

| 函数            | 说明                                | 返回      |
| --------------- | ----------------------------------- | --------- |
| `kruskal(g)`    | Kruskal MST（需 GraphEdgeIterable） | MstResult |
| `prim(g, root)` | Prim MST                            | MstResult |

### 3.4 连通性算法 — [connectivity/components.mbt](../src/algorithms/connectivity/components.mbt), [connectivity/tarjan.mbt](../src/algorithms/connectivity/tarjan.mbt), [connectivity/kosaraju.mbt](../src/algorithms/connectivity/kosaraju.mbt)

| 函数                      | 说明                | 返回                |
| ------------------------- | ------------------- | ------------------- |
| `connected_components(g)` | 无向连通分量        | ConnectedComponents |
| `tarjan_scc(g)`           | Tarjan 强连通分量   | SCC                 |
| `kosaraju_scc(g)`         | Kosaraju 强连通分量 | SCC                 |

## 4. 文件组织

```
src/algorithms/
├── mst/
│   ├── moon.pkg
│   ├── types.mbt              # MstResult + 方法
│   ├── union_find.mbt         # Union-Find (priv)
│   ├── kruskal.mbt            # Kruskal 算法
│   ├── prim.mbt               # Prim 算法
│   └── mst_test.mbt           # 测试
└── connectivity/
    ├── moon.pkg
    ├── types.mbt              # CC + SCC 结果类型
    ├── components.mbt         # 无向连通分量
    ├── tarjan.mbt             # Tarjan SCC
    ├── kosaraju.mbt           # Kosaraju SCC
    └── connectivity_test.mbt  # 测试
```

## 5. 算法复杂度与约束

| 算法         | 时间复杂度    | Trait 约束                   | 特殊依赖        |
| ------------ | ------------- | ---------------------------- | --------------- |
| Kruskal      | O(E log E)    | GraphReadable + EdgeIterable | Union-Find      |
| Prim         | O((V+E)log V) | GraphReadable                | 最小堆          |
| 无向连通分量 | O(V+E)        | GraphReadable                | BFS visited[]   |
| Tarjan SCC   | O(V+E)        | GraphDirected                | DFS 时间戳栈    |
| Kosaraju SCC | O(V+E)        | GraphReadable                | 双 DFS + 反转图 |
