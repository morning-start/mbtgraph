# mbtgraph 任务清单 (TODO)

> **最后更新**: 2026-05-29 | **当前版本**: v0.14.0 ⚡ 性能优化 ✅
> **下次评审**: 2026-06-04（每周日）
> **下个版本**: v0.15.0 🧩 经典算法扩充
> **当前进度**: v0.14.0 发布完成

---

## 📋 任务总览

### 版本路线图速查

```
✅ v0.9.0   P5 图论核心完成 (551 tests)
✅ v0.10.0  🔍 社交网络分析套件 (588 tests)
✅ v0.11.0  📊 数据交换与可视化 (630 tests)
✅ v0.12.0  🚀 经典算法增强 (701 tests)
✅ v0.13.0  🛠️ 接口重构 + P0/P1 算法补齐 (736 tests)
✅ v0.14.0  ⚡ 性能优化 (740 tests)
🔶 v0.15.0  🧩 经典算法扩充 (规划中...)
⬜ v0.16.0  🔧 API 冻结候选 (=v1.0.0-rc.1)
⬜ v1.0.0   🎉 正式发布
```

---

## ✅ v0.14.0: ⚡ 性能优化 (已发布)

> **时间范围**: 2026-05-28 ~ 2026-05-29
> **最终测试数**: 740 (无回归)
> **核心产出**: P0 性能缺陷修复 + P1 核心算法优化 + 性能基线

## 🎯 v0.15.0: 🧩 经典算法扩充

> **时间范围**: 2026-05-29 起
> **目标**: 从 [algorithms_catalog.md](algorithms_catalog.md) 中选择经典实用算法逐一实现
> **策略**: 每波 3-5 个算法，兼顾广度与深度
> **算法目录**: 已更新至 ~310 条（含研究前沿），~152 个未实现合理目标

---

### 🔴 第 1 波: 低垂果实（高收益、低风险）

#### TASK-A: 修复 heap.mbt `array_pop_last` O(n) 缺陷 ✅

| 项目 | 内容 |
|------|------|
| **问题** | `heap_pop` 中 `array_pop_last` 每次 O(n) 拷贝整个数组，Dijkstra 从 O((V+E)logV) 退化 |
| **影响范围** | Dijkstra / A* / Johnson / 双向Dijkstra / Yen's K短路 — 共 6 个算法 |
| **修复** | 替换为 `Array::pop()` O(1) 直接移除末尾元素 |
| **代码变更** | 2 文件：heap.mbt (替换函数+移除 `mut`) + kosaraju.mbt (移除死代码) |
| **验证** | ✅ 全量 736 测试通过 |
| **预期收益** | 最短路径模块整体加速 **2-5x** |

---

#### TASK-B: 修复 CSR Builder 冒泡排序 ✅

- [x] **问题**: [csr.mbt:L57-71](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\storage\csr.mbt#L57-L71) 使用冒泡排序 O(n²) 排序边，大图构建极慢
- [x] **修复**: 替换为快速排序 Lomuto 分区方案 O(n log n)
- [x] 代码量: ~35 行新增 (csr_qsort + csr_partition)
- [x] 验证: `moon check` 零警告 + 736 测试全通过
- [x] 预期收益: 大图 CSR 转换提速 **10-100x**

---

#### TASK-C: `neighbors()` 返回权重对，消除内部 `get_edge()` ✅

- [x] **问题**: [dijkstra.mbt:L59-65](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\algo\shortest_path\dijkstra.mbt#L59-L65) 邻居循环内调用 `get_edge()` 导致 O(deg) 冗余查找
- [x] **方案**: 新增 trait 方法 `neighbors_with_weight()` 返回 `Iter[(NodeId, Double)]`
- [x] **变更**:
  - `GraphReadable` trait 新增 `neighbors_with_weight`
  - 8 种存储 + MockTest 全部实现
  - 改造 10 个 neighbors+get_edge 循环（8 个算法文件）
- [x] 验证: `moon check` 零警告 + 736 测试全通过
- [x] 预期收益: Dijkstra/Bellman-Ford/A*/Prim/SPFA/Johnson/Yen 等提速 **1.5-3x**

---

### 🟡 第 2 波: 核心算法优化（中等工作量）

#### TASK-D: Louvain 数据结构重构 ✅

- [x] **问题**: [louvain.mbt:L212-262](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\algo\community\louvain.mbt#L212-L262) `find_neighbor_communities()` 和 `count_edges_to_community()` 全边扫描 → **O(E·V·K)**
- [x] **修复**: 改用邻接表表示（预建 `node→neighbors` 映射），消除全边扫描
- [x] 同时修复 `compute_gain` 公式错误（符号错误+缺少 -k_i²/(2m²) 项），使模块度增益计算符合 Louvain 原始论文
- [x] 验证: `moon check` 零警告 + 736 测试全通过
- [x] 预期收益: 10K 节点图提速 **5-20x**

---

#### TASK-E: AdjList 批量操作 + 无检查添加 ✅

- [x] **问题**: [directed_adj_list.mbt:L253-256](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\storage\directed_adj_list.mbt#L253-L256) `add_edge()` 每次线性查重 O(deg)，批量建图退化到 O(E·deg)
- [x] **新增**:
  - `add_edge_unchecked()` — 跳过查重，调用方保证不重复
  - `add_edges_batch(edges)` — 批量添加，一条失败则终止
- [x] **同步**: 为 DirectedAdjList + UndirectedAdjList 均添加了方法
- [x] 验证: `moon check` 零警告 + 736 测试全通过
- [x] 预期收益: 建图速度提升 **2-3x**

---

#### TASK-F: CSR `in_neighbors` 反向索引 ✅

- [x] **问题**: [csr.mbt:L244-290](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\storage\csr.mbt#L244-L290) `in_neighbors()` / `in_degree()` 扫描所有行 O(V+E)
- [x] **修复**: 构建时同步建立 `in_ptr` / `in_idx` / `in_vals` 反向索引（类 CSC 列指针结构）
- [x] 构建算法: O(n+E) 计数排序法，两次遍历边数组
- [x] 影响范围: `in_neighbors()` / `in_degree()` / `predecessors()` 均从 O(V+E) 降至 O(deg_in)
- [x] 验证: `moon check` 零警告 + 736 测试全通过

---

### 🔵 第 3 波: 基线建立与度量

#### TASK-G: Benchmark 框架 + 基线数据采集

- [x] 创建 `benchmarks/` 目录结构 + `moon.pkg`
- [x] 设计 `BenchResult` 类型和计时工具（使用 `@moonbitlang.core.bench`）
- [x] 采集关键算法基线（100/1000/5000/10000 节点链式/路径图）

| 算法 | 图规模 | 关键指标 |
|------|--------|---------|
| Dijkstra | 10K 节点/10K 边 | 76.89 μs |
| BFS/DFS | 10K 节点 | ~50 μs |
| CSR 转换 | 10K 节点 | 318.67 ms |
| Dinic | 1K 节点 | 13.89 ms |
| Louvain | 100 节点 | 257.97 μs |

- [x] 生成 `benchmarks/baseline_v0.14.0.csv`（19 行基线数据）
- 实际: ~2h（含 WASM GC 栈溢出调试，路径图优化）

---

### 🟣 第 4 波: 高级分析

#### TASK-H: Dynamic Dispatch / 内联分析 ✅

- [x] 统计 trait 方法调用频率（neighbors/node_count 等）
- [x] 标记内联候选函数
- [x] 编写分析报告: `docs/design/dispatch_analysis.md`
- 实际: ~0.5h（静态分析，无需运行时工具）
- **关键发现**:
  - `node_count` 是最热方法（82 次，占 GraphReadable 的 37.8%），内联收益最高
  - 前 6 个方法（node_count/neighbors/node_ids/contains_node/degree/neighbors_with_weight）占总调用的 95.6%
  - GraphWritable 的 681 次调用全部来自测试代码，不影响运行时性能
  - 8 个方法从未被使用（get_node/is_empty/remove_node/remove_edge/clear/out_neighbors/batch_neighbors/batch_edges）

---

## 🎯 v0.15.0: 🧩 经典算法扩充

### 🔴 第 1 波: 经典图论基础（~15h）

> 社区检测、链接预测、稠密子图——高频实用算法

#### TASK-1A: 社区检测补充（Leiden + 谱聚类）

- [ ] **Leiden 算法**: Louvain 改进版，保证社区内连通性
- [ ] **谱聚类**: 拉普拉斯特征向量 + K-Means 聚类
- 预期: ~6h（含测试）

#### TASK-1B: 链接预测套件

- [ ] **共同邻居** / **Jaccard** / **Adamic-Adar** / **优先连接** / **资源分配**
- 预期: ~4h（含测试）

#### TASK-1C: 稠密子图基础

- [ ] **K-Core 分解** / **K-Truss** / **三角计数** / **聚类系数**
- 预期: ~5h（含测试）

---

### 🟡 第 2 波: 中心性与图统计（~8h）

#### TASK-2A: 中心性补齐

- [ ] **Katz 中心性**: 衰减路径计数
- [ ] **Harmonic 中心性**: 不连通图友好变体
- [ ] **通信能力 / 集团中心性**
- 预期: ~5h

#### TASK-2B: 图统计扩展

- [ ] **直径与半径** / **Wiener 指数** / **网络效率** / **三元组计数**
- 预期: ~3h

---

### 🔵 第 3 波: 匹配与流扩展（~12h）

#### TASK-3A: KM 最大权匹配

- [ ] **Kuhn-Munkres 算法**: 二分图最大权完美匹配 O(V³)
- 预期: ~4h

#### TASK-3B: 网络流扩展

- [ ] **Push-Relabel (HLPP)** / **Stoer-Wagner 最小割** / **容量缩放**
- 预期: ~8h

---

### 🟣 第 4 波: 图算子与特殊图（~8h）

#### TASK-4A: 图算子

- [ ] **补图/反转/交并差** / **图积(笛卡尔/张量/字典序)** / **线图/收缩/幂图**
- 预期: ~4h

#### TASK-4B: 特殊图判定

- [ ] **弦图+完美消除序** / **二部图** / **正则/完全图** / **Havel-Hakimi**
- 预期: ~4h

---

### 📦 发布

#### TASK-ZZ: v0.15.0 发布

- [ ] 更新 CHANGELOG / MEMORY / AGENTS
- [ ] `moon check` + `moon test`
- [ ] Git Tag: `v0.15.0`
- 预期: ~1h

---

## 📊 任务统计

### v0.14.0 已完成

| 波次 | 任务 | 优先级 | 工作量 |
|:----:|------|:------:|:------:|
| **1** | **TASK-A: heap O(n) 修复** | 🔴 P0 | 0.5h |
| **1** | **TASK-B: CSR 快排** | 🔴 P0 | 1h |
| 1 | **TASK-C: neighbor 权重对** | 🟡 P1 | 3h |
| 2 | **TASK-D: Louvain 重构** | 🟡 P1 | 3h |
| 2 | **TASK-E: AdjList 批量** | 🟡 P1 | 2h |
| 2 | **TASK-F: CSR 反向索引** | 🟡 P1 | 2h |
| 3 | **TASK-G: Benchmark 基线** | 🟢 P2 | 2h |
| 4 | TASK-H: Dispatch 分析 | 🟢 P2 | 3h |
| 发布 | TASK-Z: 文档+Tag | 🟡 P1 | 2h |
| **合计** | **9/9 ✅** | — | **~18.5h** |

### v0.15.0 规划中

| 波次 | 任务 | 优先级 | 工作量 |
|:----:|------|:------:|:------:|
| 1 | TASK-1A: Leiden + 谱聚类 | 🟡 P1 | ~6h |
| 1 | TASK-1B: 链接预测套件 | 🟡 P1 | ~4h |
| 1 | TASK-1C: 稠密子图基础 | 🟢 P2 | ~5h |
| 2 | TASK-2A: 中心性补齐 | 🟢 P2 | ~5h |
| 2 | TASK-2B: 图统计扩展 | 🟢 P2 | ~3h |
| 3 | TASK-3A: KM 最大权匹配 | 🟡 P1 | ~4h |
| 3 | TASK-3B: 网络流扩展 | 🟢 P2 | ~8h |
| 4 | TASK-4A: 图算子 | 🔵 P3 | ~4h |
| 4 | TASK-4B: 特殊图判定 | 🔵 P3 | ~4h |
| 发布 | TASK-ZZ: 文档+Tag | 🟡 P1 | ~1h |
| **合计** | **10 tasks** | — | **~44h** |

---

## ✅ 已完成版本摘要

| 版本 | 主题 | 测试数 | 核心产出 |
|------|------|:------:|---------|
| **v0.14.0** | ⚡ 性能优化 | **740** | Heap/CSR快排/neighbors_weight/Louvain/AdjList批量/CSR反向索引/Bench/Dispatch分析 |
| **v0.13.0** | 🛠️ 接口重构 | **736** | Johnson/SPFA/边着色/BCC/双向Dij/Yen's + Trait精简 |
| **v0.12.0** | 🚀 经典算法增强 | 701 | A*/双向BFS/Hopcroft-Karp/费用流/Edmonds |
| **v0.11.0** | 📊 数据交换 | 630 | DOT/JSON + 图统计 |
| **v0.10.0** | 🔍 社交网络分析 | 588 | PageRank + 4中心性 + Louvain/LPA |
| **v0.9.0** | P5 图论核心 | 551 | Euler/Cutpoints/Coloring/Clique/Hamiltonian |

详细变更日志见: [CHANGELOG.md](../CHANGELOG.md)

---

## 📈 成功度量指标

| 指标 | v0.14.0 | v0.15.0 目标 | 衡量方式 |
|------|:-------:|:-----------:|---------|
| **测试总数** | 740 | ≥ 800 | `moon test` |
| **算法总数** | ~47 | ~60 | 新增 ~13 个 |
| **新模块** | 0 | +3~4 个 | 目录结构 |
| **Benchmark** | 基线已有 | 无回归 | Benchmarks |

---

<div align="center">

**💡 提示**: 本文档每周更新，反映最新进展和下周计划

*维护者: @morning-start | 最后更新: 2026-05-29 | 目标: v0.15.0 (经典算法扩充)*

</div>