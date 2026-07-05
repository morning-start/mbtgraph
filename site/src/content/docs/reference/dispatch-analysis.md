---
title: Trait 动态调度分析
description: mbtgraph 中 6 层 Trait 方法的调用频率统计与优化建议
---

> **分析范围**: `lib/algo/` 下所有 `*.mbt` 文件
> **统计方法**: 通过 `@core.TraitName::method_name` 完全限定名模式匹配

---

## 1. 总览

| Trait | 方法数 | 总调用次数 | 占比 |
|------|:------:|:--------:|:----:|
| GraphReadable | 12 | 229 | ~80% |
| GraphDirected | 6 | 15 | ~5% |
| GraphWritable | 5 | 680+ | 几乎全部在测试代码中 |
| GraphBatchReadable | 2 | 少量 | 仅 CSR/CSC 场景 |

---

## 2. GraphReadable 调用频率

### 调用分布

| 排名 | 方法 | 调用次数 | 比例 | 主要调用方 |
|:----:|------|:--------:|:----:|-----------|
| 1 | `node_count` | **82** | 37.8% | 全部算法模块 |
| 2 | `neighbors` | **41** | 18.9% | 遍历、连通性、图生成器 |
| 3 | `node_ids` | **38** | 17.5% | 社区检测、着色、团检测 |
| 4 | `contains_node` | 21 | 9.7% | 匹配算法、连通性 |
| 5 | `degree` | 14 | 6.5% | 着色、中心性、匹配 |
| 6 | `neighbors_with_weight` | 11 | 5.1% | 最短路径、MST |
| 7 | `edges` | 7 | 3.2% | MST (Kruskal)、欧拉路径 |
| 8 | `edge_count` | 6 | 2.8% | MST、统计 |
| 9 | `get_edge` | 6 | 2.8% | 双向 Dijkstra |
| 10 | `is_directed` | 3 | 1.4% | 转换器、社区检测 |
| 11 | `get_node` | 0 | 0% | 未使用 |
| 12 | `is_empty` | 0 | 0% | 未使用 |

### 结论

- **高频（>10%）**: `node_count`, `neighbors`, `node_ids` — 应优先内联优化
- **低频（0%）**: `get_node`, `is_empty` — 可考虑移除或标记 deprecated

---

## 3. GraphDirected 调用频率

| 排名 | 方法 | 调用次数 | 比例 | 调用来源 |
|:----:|------|:--------:|:----:|----------|
| 1 | `out_degree` | 6 | 40% | 拓扑排序、匹配、割点 |
| 2 | `in_degree` | 5 | 33.3% | 拓扑排序 (Kahn)、匹配 |
| 3 | `successors` | 2 | 13.3% | 流网络 |
| 4 | `in_neighbors` | 1 | 6.7% | 拓扑排序 (Kahn) |
| 5 | `predecessors` | 1 | 6.7% | 拓扑排序 (Kahn) |
| 6 | `out_neighbors` | 0 | 0% | 未使用（等同于 `neighbors`） |

### 结论

- `out_degree`, `in_degree` 最常用 — 优先优化
- `out_neighbors` 未被使用 — 可考虑与 `neighbors` 统一

---

## 4. GraphWritable 调用频率

| 方法 | 调用次数 | 说明 |
|------|:--------:|------|
| `add_edge` | 356 | 仅用在 `*_test.mbt` |
| `add_node` | 325 | 仅用在 `*_test.mbt` |
| `remove_node` | 少量 | 测试 |
| `remove_edge` | 少量 | 测试 |
| `clear` | 少量 | 测试 |

**关键发现**: `add_edge` + `add_node` 占 Writable 调用的 100%，但**全部来自测试代码**——算法代码不直接调用 Writable（符合纯函数设计）。

---

## 5. 优化建议

### 高频内联候选

| 方法 | 当前间接调用 | 建议 |
|------|:-----------:|------|
| `node_count` | 82 次全算法热点 | 考虑存储内联 Getter |
| `neighbors` | 41 次遍历核心 | 保持 Trait 抽象 |
| `node_ids` | 38 次迭代热点 | 配合 CSR batch 优化 |

### 低频简化候选

| 方法 | 当前调用数 | 建议 |
|------|:---------:|------|
| `get_node` | 0 | 标记 deprecated，v2.0 移除 |
| `is_empty` | 0 | 用户应直接调用 `node_count == 0` |
| `out_neighbors` | 0 | 与 `neighbors` 合并 |
