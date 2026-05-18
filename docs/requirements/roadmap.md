---
title: "mbtgraph 开发路线图与需求待办"
version: "0.1.0"
status: "active"
type: "roadmap"
created: "2026-05-18"
updated: "2026-05-18"
author: "morning-start"
license: "Apache-2.0"
tags: ["roadmap", "requirements", "graph", "algorithm"]
traceability:
  source: "docs/design/sad.md"
  targets:
    - "src/algorithms/"
    - "src/generators/"
---

# mbtgraph 开发路线图

> **版本**: v0.1.0 | **状态**: 活跃 | **日期**: 2026-05-18

---

## 1. 已完成模块

| # | 模块 | 路径 | 状态 | 测试数 |
|---|------|------|:----:|:------:|
| M1 | 核心类型 + Trait | `src/core/` | ✅ 完成 | 68 |
| M2 | 8 种图存储实现 | `src/storage/` | ✅ 完成 | ~107 |
| M3 | 遍历算法 (BFS/DFS/环检测/拓扑排序) | `src/algorithms/traversal/` | ✅ 完成 | ~47 (含跨存储 20) |
| **合计** | | | | **222** |

---

## 2. 待办需求 (Backlog)

### P0 — 图生成器 🔥 当前进行中

**目标**: 提供经典图结构和随机图的快速构建能力，大幅提升算法测试效率。

**优先级理由**: 高 ROI —— 一次开发，惠及所有后续算法测试。当前测试手动建图（如 `cross_storage_test.mbt`），生成器可参数化替代。

#### 需求列表

| ID | 需求 | 说明 | 复杂度 | 状态 |
|:--:|------|------|:-----:|:----:|
| G01 | 完全图 K_n | 有向/无向，所有节点两两相连 | 低 | ⬜ 待开发 |
| G02 | 环图 C_n | 单一环路，有向/无向 | 低 | ⬜ 待开发 |
| G03 | 路径图 P_n | 线性链式，有向/无向 | 低 | ⬜ 待开发 |
| G04 | 星型图 S_n | 中心节点连接所有叶节点 | 低 | ⬜ 待开发 |
| G05 | 网格图 m×n | 二维网格拓扑 | 中 | ⬜ 待开发 |
| G06 | 完全二分图 K_{m,n} | 两部分完全连接 | 低 | ⬜ 待开发 |
| G07 | Erdos-Renyi 随机图 G(n,p) | 每条边以概率 p 存在 | 中 | ⬜ 待开发 |
| G08 | 图生成器测试 | 覆盖所有生成器 + 属性验证 | 中 | ⬜ 待开发 |

**技术约束**:
- 依赖 `@core.GraphWritable` trait (`add_node` / `add_edge`)
- 返回类型统一为 `DirectedAdjList` 或 `UndirectedAdjList`
- 随机图需确认 MoonBit 标准库 Random 模块可用性
- 包路径: `src/generators/`

---

### P1 — 最短路径算法 🛣️

**目标**: 提供加权图最短路径求解能力，是用户需求最高的经典算法集合。

#### 需求列表

| ID | 需求 | 说明 | Trait 约束 | 复杂度 | 状态 |
|:--:|------|------|-----------|:-----:|:----:|
| S01 | Dijkstra | 非负权单源最短路径 | GraphReadable | 中 | ⬜ 待开发 |
| S02 | Bellman-Ford | 支持负权边 + 负环检测 | GraphReadable | 中 | ⬜ 待开发 |
| S03 | Floyd-Warshall | 全源最短路径，稠密小图 | GraphReadable | 中 | ⬜ 待开发 |
| S04 | 最短路径结果类型 | ShortestPathResult { distances, parents } + path_to | - | 低 | ⬜ 待开发 |
| S05 | 测试 | 正常/空图/负权/不连通等场景 | - | 中 | ⬜ 待开发 |

**技术要点**:
- Dijkstra 需要**优先队列/最小堆**数据结构
- 结果类型复用 traversal 的 `path_to()` 设计思路
- 设计文档预研: [sad.md S5.3](../design/sad.md)
- 包路径: `src/algorithms/shortest_path/`

---

### P2 — 最小生成树 + 连通性 🌳

**目标**: MST 解决无向图最小连通问题；连通性分析提供图的分解能力。

#### 需求列表

| ID | 需求 | 说明 | Trait 约束 | 复杂度 | 状态 |
|:--:|------|------|-----------|:-----:|:----:|
| T01 | Kruskal MST | 边排序 + 并查集(Union-Find) | GraphReadable + EdgeIterable | 中 | ⬜ 待开发 |
| T02 | Prim MST | 类似 Dijkstra 的贪心策略 | GraphReadable | 中 | ⬜ 待开发 |
| T03 | Union-Find 数据结构 | 带路径压缩 + 按秩合并 | - | 低 | ⬜ 待开发 |
| T04 | 无向连通分量 | 基于 BFS/DFS 的 visited[] 分组 | GraphReadable | 低 | ⬜ 待开发 |
| T05 | Tarjan SCC | 强连通分量，利用 DFS 时间戳 | GraphDirected | 高 | ⬜ 待开发 |
| T06 | Kosaraju SCC | 双 DFS 强连通分量 | GraphReadable | 中 | ⬜ 待开发 |
| T07 | 测试 | 各算法正确性 + 边界条件 | - | 中 | ⬜ 待开发 |

**技术要点**:
- Kruskal 天然绑定 `GraphEdgeIterable` trait（该 trait 存在的核心理由）
- Tarjan 可直接复用 `DfsResult.entry_time / exit_time` 字段
- 无向连通分量可基于 `bfs_all` / `dfs_all` 的 visited[] 数组提取
- 包路径: `src/algorithms/mst/`, `src/algorithms/connectivity/`

---

### P3 — 网络流算法 💧

**目标**: 最大流/最小割求解，图论中最复杂的算法类别。

> ⚠️ 建议在 P0~P2 完成后再启动此方向。

#### 需求列表

| ID | 需求 | 说明 | 复杂度 | 状态 |
|:--:|------|------|:-----:|:----:|
| F01 | Ford-Fulkerson (Edmonds-Karp) | BFS 寻增广路 O(VE²) | 高 | ⬜ 待开发 |
| F02 | Dinic | 分层图 + 阻塞流 O(V²E) | 高 | ⬜ 待开发 |
| F03 | 最大流最小割定理验证 | 复用最大流结果 | 中 | ⬜ 待开发 |
| F04 | FlowEdge 类型定义 | { capacity, flow } 带容量边 | 低 | ⬜ 待开发 |
| F05 | 测试 | 典型网络流实例 | 中 | ⬜ 待开发 |

**技术风险**:
- 需要扩展 core 类型系统（FlowEdge 或残差图表示）
- CSR 等只读存储无法使用（需要动态修改边容量）
- 可能需要新增 `GraphResidual` trait 或扩展 `GraphWritable`
- 包路径: `src/algorithms/flow/`

---

## 3. 依赖关系图

```
P0 图生成器 ─────────────────────────────┐
   │                                      ↓
   │                              提升 P1/P2/P3 测试效率
   │
P1 最短路径 ──→ P2 MST+连通性 ──→ P3 网络流
   │                ↑
   │           复用 DFS 时间戳 (Tarjan)
   ↓
P0 图生成器 ←── 测试基建依赖
```

## 4. 版本规划里程碑

| 版本 | 内容 | 目标状态 |
|------|------|---------|
| v0.2.0 | P0 图生成器 + 文档完善 | 🔄 进行中 |
| v0.3.0 | P1 最短路径 (Dijkstra/Bellman-Ford) | ⬜ 规划中 |
| v0.4.0 | P2 MST + 连通性 (Kruskal/Tarjan) | ⬜ 规划中 |
| v0.5.0 | P3 网络流 (Dinic) | ⬜ 远期 |

## 5. 更新日志

| 日期 | 操作 | 说明 |
|------|------|------|
| 2026-05-18 | 创建 | 初始化路线图，基于项目现状评估 |
