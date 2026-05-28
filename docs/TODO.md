# mbtgraph 任务清单 (TODO)

> **最后更新**: 2026-05-29 | **当前版本**: v0.14.0 ⚡ 性能优化 (进行中...)
> **下次评审**: 2026-06-04（每周日）
> **下个版本**: v0.14.0 ⚡ 性能优化
> **当前进度**: 5/10 优化完成

---

## 📋 任务总览

### 版本路线图速查

```
✅ v0.9.0   P5 图论核心完成 (551 tests)
✅ v0.10.0  🔍 社交网络分析套件 (588 tests)
✅ v0.11.0  📊 数据交换与可视化 (630 tests)
✅ v0.12.0  🚀 经典算法增强 (701 tests)
✅ v0.13.0  🛠️ 接口重构 + P0/P1 算法补齐 (736 tests)
🔶 v0.14.0  ⚡ 性能优化 (5/10 ✅ 进行中...)
⬜ v0.15.0  🔧 API 冻结候选 (=v1.0.0-rc.1)
⬜ v1.0.0   🎉 正式发布
```

---

## 🎯 v0.14.0: ⚡ 性能优化专项

> **时间范围**: 2026-05-28 起
> **目标测试数**: 736+ (无功能回归)
> **核心产出**: P0 性能缺陷修复 + P1 核心算法优化 + 性能基线

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

#### TASK-C: `neighbors()` 返回权重对，消除内部 `get_edge()`

- [ ] **问题**: [dijkstra.mbt:L59-65](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\algo\shortest_path\dijkstra.mbt#L59-L65) 邻居循环内调用 `get_edge()` 导致 O(deg) 冗余查找
- [ ] **修复方案 A** (推荐): 新增 trait 方法 `neighbors_with_weight()` 返回 `Iter[(NodeId, Double)]`
- [ ] **修复方案 B**: 修改 `neighbors()` 签名（Breaking Change，需评估）
- [ ] 变更现有算法: Dijkstra / Bellman-Ford / A* 等使用 `neighbors`+`get_edge` 模式的算法
- [ ] 预期收益: 消除 O(deg) 冗余查找，Dijkstra 再提速 **1.5-3x**

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

- [ ] 创建 `benchmarks/` 目录结构 + `moon.pkg`
- [ ] 设计 `BenchResult` 类型和计时工具
- [ ] 采集关键算法基线（100/1000/10000 节点随机图）

| 算法 | 图规模 | 关键指标 |
|------|--------|---------|
| Dijkstra | 10K 节点/50K 边 | 单源最短路时间 |
| BFS/DFS | 10K 节点 | 遍历时间 |
| CSR 转换 | 10K 节点 | AdjList→CSR 时间 |
| Dinic | 1K 节点 | 最大流时间 |
| Louvain | 10K 节点 | 社区检测时间 |

- [ ] 生成 `benchmarks/baseline_v0.14.0.csv`
- 预期: ~4h

---

### 🟣 第 4 波: 高级分析

#### TASK-H: Dynamic Dispatch / 内联分析

- [ ] 统计 trait 方法调用频率（neighbors/node_count 等）
- [ ] 标记内联候选函数
- [ ] 编写分析报告: `docs/design/dispatch_analysis.md`
- 预期: ~3h

---

#### TASK-I: Brandes 介数中心性并行化探索

- [ ] 分析 MoonBit 并发原语可用性
- [ ] 如可行: 实现分块并行版本
- [ ] 预期: 多核场景 2-4x 加速
- 预期: ~5h

---

#### TASK-J: Matrix 稀疏存储支持

- [ ] 稀疏度检测 + COO 格式自动切换
- [ ] 稀疏图内存降低 60-80%
- 预期: ~4h

---

### 📦 发布准备

#### TASK-Z: 性能报告文档 + Git Tag v0.14.0

- [ ] 生成 `benchmarks/perf_report_v0.14.0.md`
- [ ] 更新 MEMORY.md / AGENTS.md
- [ ] CHANGELOG.md 新增 v0.14.0 章节
- [ ] 最终验证: `moon check` + `moon test` 全部通过
- [ ] Git Tag: `v0.14.0`
- 预期: ~2h

---

## 📊 任务统计

| 波次 | 任务 | 状态 | 优先级 | 工作量 | 预期收益 |
|:----:|------|:----:|:------:|:------:|---------|
| **1** | **TASK-A: heap pop O(n) 修复** | ✅ **完成** | 🔴 P0 | 0.5h | 最短路径 2-5x |
| **1** | **TASK-B: CSR 冒泡排序修复** | ✅ **完成** | 🔴 P0 | 1h | CSR 构建 10-100x |
| 1 | TASK-C: neighbor 权重对 | ⬜ | 🟡 P1 | 3h | Dijkstra 1.5-3x |
| 2 | **TASK-D: Louvain 数据结构** | ✅ **完成** | 🟡 P1 | 3h | 社区检测 5-20x |
| 2 | **TASK-E: AdjList 批量操作** | ✅ **完成** | 🟡 P1 | 2h | 建图 2-3x |
| 2 | **TASK-F: CSR 反向索引** | ✅ **完成** | 🟡 P1 | 2h | 入边 O(V+E)→O(deg_in) |
| 3 | TASK-G: Benchmark 基线 | ⬜ | 🟢 P2 | 4h | 量化度量 |
| 4 | TASK-H: Dispatch 分析 | ⬜ | 🟢 P2 | 3h | 编译器优化 |
| 4 | TASK-I: Brandes 并行化 | ⬜ | 🔵 P3 | 5h | 多核 2-4x |
| 4 | TASK-J: 稀疏矩阵 | ⬜ | 🔵 P3 | 4h | 内存 -60-80% |
| 发布 | TASK-Z: 文档+Tag | ⬜ | 🟡 P1 | 2h | 发布 |
| **合计** | **11 tasks** | **5/11** | — | **~29.5h** | — |

---

## ✅ 已完成版本摘要

| 版本 | 主题 | 测试数 | 核心产出 |
|------|------|:------:|---------|
| **v0.9.0** | P5 图论核心 | 551 | Euler/Cutpoints/Coloring/Clique/Hamiltonian |
| **v0.10.0** | 🔍 社交网络分析 | 588 | PageRank + 4种中心性 + Louvain/标签传播 |
| **v0.11.0** | 📊 数据交换 | 630 | DOT/JSON 序列化 + 图统计工具 |
| **v0.12.0** | 🚀 经典算法增强 | 701 | A*/双向BFS/Hopcroft-Karp/费用流/Edmonds |
| **v0.13.0** | 🛠️ 接口重构 | **736** | Johnson/SPFA/边着色/BCC/双向Dij/Yen's + Trait精简 |

详细变更日志见: [CHANGELOG.md](../CHANGELOG.md)

---

## 📈 成功度量指标

| 指标 | 基线值 (v0.13.0) | 目标值 (v0.14.0) | 衡量方式 |
|------|:---------------:|:---------------:|---------|
| **测试总数** | 736 | ≥ 736 (无回归) | `moon test` |
| **Dijkstra 10K节点** | 待基线 | ↓ 3-15x (含 TASK-A) | Benchmark |
| **CSR 转换速度** | 待基线 | ↓ 10-100x | Benchmark |
| **Louvain 10K节点** | 待基线 | ↓ 5-20x | Benchmark |
| **建图速度** | 待基线 | ↓ 2-3x | Benchmark |
| **CSR 入边查询** | 待基线 | O(V+E) → O(1) | Benchmark |
| **代码覆盖率** | ~82% | ≥ 82% | `moon coverage analyze` |

---

<div align="center">

**💡 提示**: 本文档每周更新，反映最新进展和下周计划

*维护者: @morning-start | 最后更新: 2026-05-29 | 目标: v0.14.0 (性能优化)*

</div>