---
title: "图生成器模块设计"
version: "0.1.0"
status: "approved"
type: "design"
created: "2026-05-18"
updated: "2026-05-18"
author: "morning-start"
tags: ["generators", "graph", "design"]
---

# 图生成器 (`src/generators/`) 设计文档

> **版本**: v0.1.0 | **状态**: 已批准 | **日期**: 2026-05-18

---

## 1. 概述

提供经典图结构和随机图的快速构建能力，通过 `GraphWritable` trait 泛型支持所有可写存储类型。

## 2. 设计决策

| 决策项 | 选择 |
|--------|------|
| 返回类型 | 泛型 `[G : @core.GraphWritable]`，调用者传入空图实例 |
| 有向/无向 | 分离函数：`xxx_directed(g, ...)` / `xxx_undirected(g, ...)` |
| 边权重 | 可配置统一权重参数 `weight : Double`（默认 1.0） |
| 节点编号 | 从 `NodeId(0)` 到 `NodeId(n-1)` 连续编号 |

## 3. API 清单（16 个公开函数）

### 3.1 经典图 — [classic.mbt](../src/generators/classic.mbt)

| 函数 | 说明 | 参数 |
|------|------|------|
| `complete_directed` | 有向完全图 K_n | g, n, weight=1.0 |
| `complete_undirected` | 无向完全图 K_n | g, n, weight=1.0 |
| `cycle_directed` | 有向环图 C_n | g, n, weight=1.0 |
| `cycle_undirected` | 无向环图 C_n | g, n, weight=1.0 |
| `path_directed` | 有向路径图 P_n | g, n, weight=1.0 |
| `path_undirected` | 无向路径图 P_n | g, n, weight=1.0 |
| `star_directed` | 有向星型图 S_n（中心→叶） | g, n, weight=1.0 |
| `star_undirected` | 无向星型图 S_n | g, n, weight=1.0 |

### 3.2 网格图 — [grid.mbt](../src/generators/grid.mbt)

| 函数 | 说明 | 参数 |
|------|------|------|
| `grid_directed` | 有向网格图 m×n | g, rows, cols, weight=1.0 |
| `grid_undirected` | 无向网格图 m×n | g, rows, cols, weight=1.0 |

### 3.3 二分图 — [bipartite.mbt](../src/generators/bipartite.mbt)

| 函数 | 说明 | 参数 |
|------|------|------|
| `bipartite_complete_directed` | 有向完全二分图 K_{m,n} | g, m, n, weight=1.0 |
| `bipartite_complete_undirected` | 无向完全二分图 K_{m,n} | g, m, n, weight=1.0 |

### 3.4 随机图 — [random.mbt](../src/generators/random.mbt)

| 函数 | 说明 | 参数 |
|------|------|------|
| `random_erdos_renyi_directed` | 有向 Erdos-Renyi G(n,p) | g, n, p, seed, weight=1.0 |
| `random_erdos_renyi_undirected` | 无向 Erdos-Renyi G(n,p) | g, n, p, seed, weight=1.0 |

## 4. 文件组织

```
src/generators/
├── moon.pkg
├── classic.mbt       # 完全图/环图/路径图/星型图 (8 函数)
├── grid.mbt          # 网格图 (2 函数)
├── bipartite.mbt     # 二分图 (2 函数)
├── random.mbt        # Erdos-Renyi 随机图 (2 函数)
└── generators_test.mbt  # 测试
```

## 5. 使用示例

```moonbit
// 构建有向完全图 K5
let g = @storage.new_directed()
let g = complete_directed(g, 5, 1.0)

// 构建无向星型图 S6
let ug = @storage.new_undirected()
let ug = star_undirected(ug, 6, 1.0)

// 算法直接使用 —— trait 抽象保证兼容
let result = bfs(g, @core.NodeId(0))
```
