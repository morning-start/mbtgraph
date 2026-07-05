---
title: 图存储调研报告
description: 8 种图存储方式的核心特点、复杂度、适用场景及优缺点的系统调研
---

> **版本**: v0.1.0 | **状态**: 参考 | **日期**: 2026-05-07

---

## 1. 概述

图是一种重要的数据结构，用于表示对象之间的关系。选择合适的图存储方式对算法性能和内存效率至关重要。本报告系统调研了 8 种主流的图数据存储方式。

---

## 2. 存储方式总览

| 存储方式 | 空间复杂度 | 邻居查询 | 边存在查询 | 增删操作 | 缓存友好 |
|---------|:---------:|:--------:|:--------:|:--------:|:--------:|
| **邻接表** | O(V+E) | O(k) | O(k) | O(1) | 🟡 一般 |
| **邻接矩阵** | O(V²) | O(V) | O(1) | O(1) | ✅ 好 |
| **CSR** | O(V+E) | O(k) | O(log k) | ❌ 只读 | ✅✅ 极好 |
| **CSC** | O(V+E) | O(k) | O(log k) | ❌ 只读 | ✅✅ 极好 |
| **边集数组** | O(E) | O(E) | O(E) | O(1) | 🟡 一般 |

---

## 3. 各存储方式详解

### 3.1 邻接表 (Adjacency List)

```
特性:
  空间: O(V+E)       查询边: O(deg(v))
  添加边: O(1)        删除边: O(deg(v))
  遍历邻居: O(deg(v))  内存: 链表/数组
```

| 优点 | 缺点 |
|------|------|
| 空间高效，适合稀疏图 | 边存在查询慢 O(k) |
| 邻居遍历灵活 | 删除边需查找 |
| 动态增删支持好 | 缓存不友好 |

**实现** (mbtgraph: `DirectedAdjList`):
- `adj: Array[Array[(NodeId, Double)]]`
- 整型 ID 索引，支持动态扩容

### 3.2 邻接矩阵 (Adjacency Matrix)

```
特性:
  空间: O(V²)       查询边: O(1)
  添加边: O(1)       删除边: O(1)
  遍历邻居: O(V)     内存: 连续 2D 数组
```

| 优点 | 缺点 |
|------|------|
| 边存在查询 O(1) 常数 | 空间 O(V²) 巨大 |
| 简单直观 | 遍历邻居 O(V) 浪费 |
| 适合稠密图 | 稀疏图 90%+ 空间浪费 |

**实现** (mbtgraph: `DirectedMatrix`):
- `matrix: Array[Array[Double]]`
- 无向图仅存储上三角，节省 50%

### 3.3 CSR (Compressed Sparse Row)

```
特性:
  空间: O(V+E)       查询边: O(log deg(v))
  构建: O(E+V)       删除边: ❌ 只读
  遍历邻居: O(deg(v))  内存: 3 个连续数组
```

| 优点 | 缺点 |
|------|------|
| 缓存友好连续内存 | 只读不可修改 |
| 空间高效 | 构建成本高 |
| 支持批量查询 | 入边查询需 CSC |

**实现** (mbtgraph: `CSRGraph`):
- `row_ptr: Array[Int]` — 行偏移
- `col_idx: Array[Int]` — 列索引
- `values: Array[Double]` — 边权重

### 3.4 CSC (Compressed Sparse Column)

CSR 的转置版本，优化入边查询。
- 入边查询 O(deg(v)) — 邻接表需 O(V) 全扫描
- 与 CSR 共享相同底层结构

### 3.5 边集数组 (Edge List)

```
特性:
  空间: O(E)         查询边: O(E)
  添加边: O(1)       删除边: O(E)
  遍历所有边: O(E)    排序: O(E log E)
```

| 优点 | 缺点 |
|------|------|
| 最紧凑存储 | 所有查询慢 |
| 排序方便（Kruskal 友好）| 不适合频繁查询 |
| 适合批处理 | 无邻居概念 |

**实现** (mbtgraph: `EdgeListGraph`):
- `edges: Array[(NodeId, NodeId, Double)]`

---

## 4. 8 种存储一览（mbtgraph）

| 名称 | 有向/无向 | 空间 | 特点 |
|------|:---------:|:----:|------|
| `DirectedAdjList` ⭐ | 有向 | O(V+E) | 默认推荐，通用 |
| `UndirectedAdjList` ⭐ | 无向 | O(V+E) | 半存储，节省 50% |
| `DirectedMatrix` | 有向 | O(V²) | 稠密小图 (V<1000) |
| `UndirectedMatrix` | 无向 | O(V²/2) | 上三角存储 |
| `EdgeListGraph` | 有向 | O(E) | Kruskal 友好 |
| `UndirectedEdgeListGraph` | 无向 | O(E) | 无向边集 |
| `CSRGraph` | 有向 | O(V+E) | 大规模静态图 |
| `CSCGraph` | 有向 | O(V+E) | 入边密集查询 |

---

## 5. 选型决策

```
输入规模及场景
│
├─ 节点数 < 1000（稠密图）
│  └─ 邻接矩阵
│
├─ 节点数 10³ ~ 10⁵（通用稀疏图）
│  ├─ 需要修改？→ 是 → 邻接表
│  └─ 只读 → CSR
│
├─ 节点数 > 10⁵（大规模图）
│  ├─ 批处理 → CSR/CSC
│  └─ 入边查询 → CSC
│
└─ 特定场景
   ├─ Kruskal MST → EdgeList
   └─ 无向图 → UndirectedAdjList
```
