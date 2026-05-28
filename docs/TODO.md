# mbtgraph 任务清单 (TODO)

> **最后更新**: 2026-05-28 | **当前版本**: v0.13.0 ✅ 🛠️ 接口重构 + P0/P1 算法补齐
> **下次评审**: 2026-06-04（每周日）
> **下个版本**: v0.14.0 ⚡ 性能优化

---

## 📋 任务总览

### 版本路线图速查

```
✅ v0.9.0   P5 图论核心完成 (551 tests)
✅ v0.10.0  🔍 社交网络分析套件 (588 tests)
✅ v0.11.0  📊 数据交换与可视化 (630 tests)
✅ v0.12.0  🚀 经典算法增强 (701 tests)
✅ v0.13.0  🛠️ 接口重构 + P0/P1 算法补齐 (736 tests) ← 当前
⬜ v0.14.0  ⚡ 性能优化
⬜ v0.15.0  🔧 API 冻结候选 (=v1.0.0-rc.1)
⬜ v1.0.0   🎉 正式发布
```

---

## 🎯 v0.14.0: ⚡ 性能优化专项

> **时间范围**: 2026-05-28 起
> **目标测试数**: 736+ (无新增算法，可能新增基准测试)
> **核心产出**: 存储层优化 + 热点算法优化 + 性能基线建立

---

### 阶段 A: 性能基线建立

#### TASK-1401: 创建 Benchmark 基础设施

- [ ] 创建 `benchmarks/` 目录结构
- [ ] 设计 Benchmark 框架:
  ```moonbit
  pub(all) struct BenchResult {
    name : String
    iterations : Int
    total_time_ns : Int64
    avg_time_ns : Double
    min_time_ns : Int64
    max_time_ns : Int64
  }
  ```
- [ ] 实现高精度计时工具 (`bench_timer.mbt`)
- [ ] 实现 CSV 报告生成器 (`bench_reporter.mbt`)
- [ ] 创建 `moon.pkg` 配置文件
- **工作量**: 2h
- **验收**: 可运行独立 benchmark 并输出 CSV

---

#### TASK-1402: 建立核心算法性能基线

- [ ] 对以下算法采集基线数据 (100/1000/10000 节点随机图):

| 算法 | 图规模 | 关键指标 |
|------|--------|---------|
| BFS/DFS | 10K 节点 | 遍历时间 |
| Dijkstra | 10K 节点/50K 边 | 单源最短路 |
| Floyd-Warshall | 500 节点 | 全源最短路 |
| Kruskal | 10K 节点 | MST 构建 |
| Dinic | 1K 节点 | 最大流 |
| PageRank | 10K 节点 | 收敛迭代 |
| Louvain | 10K 节点 | 社区检测 |
| Brandes 介数 | 1K 节点 | 中心性计算 |

- [ ] 生成 `benchmarks/baseline_v0.13.0.csv`
- [ ] 建立内存占用基线 (各存储类型 10K 节点)
- **工作量**: 3h
- **依赖**: TASK-1401
- **验收**: 基线数据可重复、CSV 格式规范

---

### 阶段 B: 存储层优化

#### TASK-1403: AdjList 内存布局优化

- [ ] 分析当前邻接表内存访问模式
- [ ] 优化邻居数组存储布局 (缓存友好性):
  - 节点 ID 连续分配
  - 邻居数组预分配 + 动态扩容策略
  - 减少 Array::push 频繁 realloc
- [ ] 批量添加边接口 `add_edges_batch(edges : Array[Edge])`
- [ ] 对比测试: 优化前后 10K 节点图构建速度
- **复杂度预期**: 构建速度提升 20-40%
- **代码量**: ~80 行修改
- **工作量**: 3h
- **验收**: 基准测试显示正向提升 + 无功能回归

---

#### TASK-1404: CSR/CSC 批量操作优化

- [ ] CSR Builder 模式优化:
  - 边排序预处理 (按 source 排序)
  - 偏移数组增量构建
  - 目标数组批量写入
- [ ] 新增 `csr_from_sorted_edges` 快速构造路径
- [ ] CSC 对称优化 (列优先批量写入)
- [ ] 对比测试: AdjList → CSR/CSC 转换速度
- **复杂度预期**: 转换速度提升 30-50%
- **代码量**: ~100 行修改
- **工作量**: 2.5h
- **验收**: 转换基准提升 + 现有 15 测试全通过

---

#### TASK-1405: Matrix 稀疏存储支持

- [ ] 实现稀疏度检测: `is_sparse(threshold : Double = 0.7)`
- [ ] 当零元素 > 70% 时自动切换内部存储为 COO 格式:
  ```moonbit
  pub(all) struct SparseMatrixEntry {
    row : Int
    col : Int
    value : Double
  }
  ```
- [ ] 稀疏矩阵基本操作 (get/set/neighbors) 适配
- [ ] 对比测试: 500 节点稀疏图 (密度 10%) vs 密集存储
- **复杂度预期**: 稀疏场景内存降低 60-80%
- **代码量**: ~150 行
- **工作量**: 4h
- **验收**: 稀疏图内存占用显著下降 + API 兼容

---

### 阶段 C: 热点算法优化

#### TASK-1406: Dijkstra 优先队列优化

- [ ] 分析当前 BinaryHeap 实现性能瓶颈
- [ ] 评估优化方案:

| 方案 | 复杂度改进 | 实现难度 | 预期收益 |
|------|:---------:|:--------:|:--------:|
| 斐波那契堆 | O(V log V) → O(V log V) 均摊更优 | 高 | 理论最优 |
| 二项堆 | O((V+E) log V) | 中 | 10-20% 提升 |
| Bucket Queue (整数权) | O(V+E+W) | 低 | 整数权 3-5x |
| Decrease-Key 缓存 | — | 低 | 5-15% 提升 |

- [ ] 选定方案并实现
- [ ] 对比测试: Dijkstra 10K 节点随机图
- **工作量**: 4h
- **验收**: 最短路径模块 76 测试全通过 + 基准提升

---

#### TASK-1407: Dinic 当前弧优化 (Current Arc Optimization)

- [ ] 实现 current_arc 数组记录每层已遍历边位置
- [ ] DFS 增广时跳过已饱和边，避免重复检查
- [ ] 优化效果: 每次 DFS 从 O(E) 降至 O(实际增广边数)
- [ ] 对比测试: Dinic 1K 节点最大流
- **复杂度预期**: 实际运行时间降低 30-60% (稠密图更明显)
- **代码量**: ~50 行修改
- **工作量**: 2h
- **验收**: 流网络模块 49 测试全通过 + 基准提升

---

#### TASK-1408: Louvain 细粒度锁准备 (数据结构层面)

- [ ] 优化 Phase 1 内部数据结构:
  - 社区总权重缓存 (避免重复计算 Σ_tot)
  - ΔQ 增量计算公式简化
  - 邻居社区集合快速查找 (用 HashMap 替代线性扫描)
- [ ] 优化 Phase 2 超图聚合效率
- [ ] 对比测试: Louvain Karate Club / 10K 节点随机图
- **复杂度预期**: 运行时间降低 20-40%
- **代码量**: ~120 行修改
- **工作量**: 3h
- **验收**: 社区检测 35 测试全通过 + 基准提升

---

#### TASK-1409: Brandes 介数中心性并行化探索

- [ ] 分析 Brandes 算法并行化可能性:
  - 各源点 BFS 独立 → 数据并行
  - 依赖累积阶段 → 归约模式
- [ ] 评估 MoonBit 并发原语可用性
- [ ] 如可行: 实现分块并行版本
- [ ] 对比测试: Brandes 1K 节点
- **复杂度预期**: 多核场景 2-4x 加速 (如并发可用)
- **代码量**: ~200 行 (新文件)
- **工作量**: 5h
- **依赖**: MoonBit 并发能力调研
- **验收**: 结果与串行完全一致 + 加速比可测

---

### 阶段 D: 编译器级优化

#### TASK-1410: 关键路径函数内联分析

- [ ] 通过 profiling 识别 Top 10 热点函数:
  - `@core.GraphReadable::neighbors` (被调用最频繁)
  - `@core.GraphReadable::degree`
  - 优先队列 push/pop
  - 数组深拷贝 `deep_copy_*`
- [ ] 标记内联候选函数 (`inline` 注解或等价机制)
- [ ] 验证内联后二进制大小和运行时间变化
- **工作量**: 2h
- **验收**: profiling 报告 + 内联建议清单

---

#### TASK-1411: Dynamic Dispatch 开销分析

- [ ] 统计 trait 方法调用频率 (通过 code review)
- [ ] 识别高频 trait 方法调用热点:
  - `graph.neighbors(node_id)` — 几乎每个算法都调用
  - `graph.node_count()` / `graph.edge_count()`
- [ ] 评估 monomorphization 可能性 (编译期特化)
- [ ] 编写分析报告: `docs/design/dispatch_analysis.md`
- **工作量**: 2h
- **交付物**: Dynamic Dispatch 开销分析报告

---

### 阶段 E: 验证与发布

#### TASK-1412: 性能回归测试框架

- [ ] 编写 `benchmarks/regression_test.mbt`:
  - 加载 v0.13.0 基线数据
  - 运行当前版本 benchmark
  - 自动对比 + 生成报告
  - 回归阈值: 性能下降 > 5% 告警
- [ ] 集成到开发工作流
- **工作量**: 2h
- **依赖**: TASK-1402, 1403-1411
- **验收**: 可一键检测性能回归

---

#### TASK-1413: 性能对比报告与文档

- [ ] 生成 `benchmarks/perf_report_v0.14.0.md`:
  - 优化前后对比表格
  - 各维度提升百分比
  - 热点函数列表及优化措施
  - 内存占用对比
- [ ] 更新 MEMORY.md 性能相关记录
- [ ] 更新 AGENTS.md 测试数/版本号
- **工作量**: 1.5h
- **依赖**: TASK-1412
- **验收**: 报告数据驱动、结论清晰

---

#### TASK-1414: Git Tag v0.14.0 发布

- [ ] 最终验证:
  - [ ] `moon check` 零错误零警告
  - [ ] `moon test` 全通过 (736+ tests, 0 failure)
  - [ ] 无功能回归 (全部现有测试通过)
  - [ ] 性能基线已建立
  - [ ] 性能报告完成
- [ ] Git 操作:
  ```bash
  git add .
  git commit -m "perf(v0.14.0): performance optimization baseline and hot-path improvements"
  git tag -a v0.14.0 -m "perf(v0.14.0): ⚡ Performance Optimization"
  ```
- [ ] CHANGELOG.md 新增 v0.14.0 章节
- **工作量**: 1h
- **依赖**: TASK-1413
- **验收**: Tag 存在 + 性能报告可查阅

---

## 📊 任务统计

| 类别 | 任务数 | 预估工时 | 产出 |
|------|:------:|:--------:|------|
| **基线建立** | 2 (1401-1402) | 5h | Benchmark 框架 + 基线数据 |
| **存储层优化** | 3 (1403-1405) | 9.5h | AdjList/CSR/Matrix 优化 |
| **算法级优化** | 4 (1406-1409) | 14h | Dijkstra/Dinic/Louvain/Brandes |
| **编译器级分析** | 2 (1410-1411) | 4h | 内联/Dispatch 分析报告 |
| **验证与发布** | 3 (1412-1414) | 4.5h | 回归测试 + 报告 + 发布 |
| **合计** | **14 tasks** | **~37h** | 性能提升 + 基线 |

---

## ✅ 已完成版本摘要

| 版本 | 主题 | 测试数 | 核心产出 |
|------|------|:------:|---------|
| **v0.9.0** | P5 图论核心 | 551 | Euler/Cutpoints/Coloring/Clique/Hamiltonian |
| **v0.10.0** | � 社交网络分析 | 588 | PageRank + 4种中心性 + Louvain/标签传播 |
| **v0.11.0** | 📊 数据交换 | 630 | DOT/JSON 序列化 + 图统计工具 |
| **v0.12.0** | 🚀 经典算法增强 | 701 | A*/双向BFS/Hopcroft-Karp/费用流/Edmonds |
| **v0.13.0** | 🛠️ 接口重构 | **736** | Johnson/SPFA/边着色/BCC/双向Dij/Yen's + Trait精简 |

详细变更日志见: [CHANGELOG.md](../CHANGELOG.md)

---

## � 成功度量指标

| 指标 | 基线值 (v0.13.0) | 目标值 (v0.14.0) | 衡量方式 |
|------|:---------------:|:---------------:|---------|
| **测试总数** | 736 | ≥ 736 (无回归) | `moon test` |
| **Dijkstra 10K节点** | TBD (待基线) | ↓ 10-30% | Benchmark |
| **Dinic 1K节点** | TBD (待基线) | ↓ 30-60% | Benchmark |
| **Louvain 10K节点** | TBD (待基线) | ↓ 20-40% | Benchmark |
| **CSR 转换速度** | TBD (待基线) | ↓ 30-50% | Benchmark |
| **稀疏矩阵内存** | TBD (待基线) | ↓ 60-80% | 内存分析 |
| **代码覆盖率** | ~82% | ≥ 82% | `moon coverage analyze` |

---

<div align="center">

**💡 提示**: 本文档每周更新，反映最新进展和下周计划

*维护者: @morning-start | 最后更新: 2026-05-28 | 目标: v0.14.0 (性能优化)*

</div>
