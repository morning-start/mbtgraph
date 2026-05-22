---
title: "mbtgraph 近期行动清单 (TODO)"
version: "1.2.0"
status: "active (v0.4.1 — P5 全部完成)"
type: "todo"
role: "行动清单 — Task-level 可执行任务"
source: "ARCHITECTURE.md v3.0 + ROADMAP.md v2.2.0"
created: "2026-05-19"
updated: "2026-05-22"
author: "morning-start"
tags: ["todo", "action-items", "ci-cd", "p5-complete", "v0.5.0"]
---

# mbtgraph 近期行动清单 (TODO)

> **定位**: 🎯 **行动清单** (Action Items) — Task 级别、可勾选、有时间框架
>
> **版本**: v1.2.0 | **当前里程碑**: **v0.4.1 P5 完成** | **日期**: 2026-05-22
>
> **📖 配套文档**: [ROADMAP.md](./ROADMAP.md) = 战略蓝图（远期规划/技术方向）
>
> **🏗️ 架构依据**: [ARCHITECTURE.md](./ARCHITECTURE.md) = SOLID 评审 + 改进优先级

---

## 当前基线

```
✅ v0.4.1 已完成 (P5 图论核心算法扩展):
   14 包 / 483 tests / ~120 API / 30+ 算法 / SOLID 4.0/5

📍 当前位置:
   Phase 1: MVP 基础     ████████████████████████ 200% ✅
   Phase 2: 分析增强     ████████████░░░░░░░░░░░   50% 🔄
   Phase 3: 高级算法补全 ██████████████████████ 100% ✅ P5全部完成 🎉
   Phase 4: 生态完善       ░░░░░░░░░░░░░░░░░░░░░░░    0% ⬜

🎯 下个目标: v0.5.0 Ecosystem (CI/CD + 集成测试 + API 冻结)
```

---

## ✅ 已完成任务 (v0.4.1)

### ~~T01: P4 图匹配模块 — Hungarian 算法~~ ✅

**完成日期**: 2026-05-19 | **包路径**: `src/algo/matching/`

| 交付物 | 数量 |
|--------|:----:|
| 源文件 | 5 (moon.pkg / types / hungarian / test / README) |
| 公开 API | 2 函数 + 1 类型 + 3 方法 |
| 测试 | **21** (100% 通过) |
| Git commit | `b64478d` |

---

### ~~T05: Dinic 最大流算法~~ ✅

**完成日期**: 2026-05-19 | **包路径**: `src/algo/flow/dinic.mbt`

| 交付物 | 数量 |
|--------|:----:|
| 源文件 | 2 (dinic.mbt + dinic_test.mbt) |
| 公开 API | 1 函数 (`dinic`) |
| 测试 | **16** (含 3 个 EK 一致性验证) |
| Git commit | `a95415b` |

---

### ~~T06: 欧拉路径 Euler~~ ✅🆕

**完成日期**: 2026-05-22 | **包路径**: `src/algo/euler/`

| 交付物 | 数量 |
|--------|:----:|
| 源文件 | 5 (moon.pkg / types / euler / euler_test) |
| 公开 API | 3 函数 (hierholzer_undirected, hierholzer_directed, is_eulerian) |
| 测试 | **22** (100% 通过) |
| Git commit | `e538ea4` 系列 |

**验收结果**:
- [x] Hierholzer 无向图欧拉回路正确性 (7 tests)
- [x] Hierholzer 有向图欧拉路径正确性 (5 tests)
- [x] is_eulerian 判定函数 (5 tests)
- [x] EulerResult 类型 + 辅助方法 (5 tests)

---

### ~~T07: 图着色 Coloring~~ ✅🆕

**完成日期**: 2026-05-22 | **包路径**: `src/algo/coloring/`

| 交付物 | 数量 |
|--------|:----:|
| 源文件 | 7 (moon.pkg / types / greedy / welsh_powell / dsatur / backtracking / test) |
| 公开 API | 5 函数 (greedy_coloring, welsh_powell, dsatur, exact_coloring, chromatic_number) |
| 测试 | **21** (100% 通过) |
| Git commit | `2226aee` 系列 |

**验收结果**:
- [x] Greedy 贪心着色 (4 tests)
- [x] Welch-Powell 着色 (4 tests)
- [x] DSATUR 启发式 (4 tests)
- [x] 回溯精确着色 (4 tests)
- [x] ChromaticNumber 结果类型 (5 tests)

---

### ~~T08: TSP 旅行商~~ ✅🆕

**完成日期**: 2026-05-22 | **包路径**: `src/algo/hamiltonian/` (含 TSP)

| 交付物 | 数量 |
|--------|:----:|
| 源文件 | 6 (moon.pkg / types / hamiltonian_path / tsp / hamiltonian_test) |
| 公开 API | 6 函数 (hamiltonian_path/circuit, tsp_nearest_neighbor, tsp_exact_held_karp 等) |
| 测试 | **20** (100% 通过) |
| Git commit | `821ac95` 系列 |

**验收结果**:
- [x] 哈密顿快速检查 (6 tests)
- [x] 哈密顿路径回溯 (3 tests)
- [x] 哈密顿回路回溯 (3 tests)
- [x] TSP 最近邻启发式 (3 tests)
- [x] TSP Held-Karp 精确解 (3 tests)
- [x] HamiltonianResult/TSPResult 类型 (2 tests)

---

### ~~P5-A: 割点与桥 Cutpoints~~ ✅🆕

**完成日期**: 2026-05-22 | **包路径**: `src/algo/cutpoints/`

| 交付物 | 数量 |
|--------|:----:|
| 源文件 | 5 (moon.pkg / types / articulation_points / bridges / test) |
| 公开 API | 2 函数 (find_articulation_points, find_bridges) |
| 测试 | **15** (100% 通过) |
| Git commit | `a74d8ac` 系列 |

---

### ~~P5-C: 团/独立集/顶点覆盖 Clique~~ ✅🆕

**完成日期**: 2026-05-22 | **包路径**: `src/algo/clique/`

| 交付物 | 数量 |
|--------|:----:|
| 源文件 | 6 (moon.pkg / types / bron_kerbosch / independent_set / vertex_cover / test) |
| 公开 API | 4 函数 (find_maximum_clique, find_maximum_independent_set, find_minimum_vertex_cover_exact/approx) |
| 测试 | **14** (100% 通过) |
| Git commit | `b021639` 系列 |

---

## 🔥 P0 — 尽快完成 (v0.5.0 关键路径)

### T02: GitHub Actions CI/CD 流水线

**优先级**: 🔥🔥🔥 **最高** | **预估**: 1 天 | **文件**: `.github/workflows/ci.yml`

#### 任务拆解

| ID | 任务 | 验证方式 |
|:--:|------|---------|
| CI01 | **CI 主流水线** (fmt → check → test) | PR 触发自动运行 |
| CI02 | **多后端验证** (native + wasm) | 双后端均通过 |
| CI03 | **测试覆盖率报告** | coverage analyze 输出 |

#### 验收标准

- [ ] Push 到 main 分支触发完整流水线
- [ ] PR 触发 fmt + check + test 三步检查
- [ ] native 后端全量测试通过 (**483 tests**)
- [ ] wasm 后端编译 + 测试通过
- [ ] 测试覆盖率报告可在 Actions 页面查看

---

### T03: API 冻结与发布准备

**优先级**: ⭐⭐ **中高** | **预估**: 0.5 天

#### 任务清单

| ID | 任务 | 说明 |
|:--:|------|------|
| AP01 | **v0.4.1 API 审查** | 扫描所有 `pub` 函数，确认签名稳定 |
| AP02 | **CHANGELOG.md 更新** | 补充 v0.1.0 → v0.4.1 完整变更记录 |
| AP03 | **moon.pkg 导出审查** | 确认公开导出列表正确无误 |
| AP04 | **semver 策略确定** | 定义 Breaking Change 判定规则 |

#### API 冻结检查项

- [ ] 所有 `pub fn` 签名已 review 无误
- [ ] 无 `pub(open)` 滥用（trait 外的内部 API 应为 priv）
- [ ] 版本号策略文档化
- [ ] Breaking changes（如有）记录在 CHANGELOG.md

---

### T04: 集成测试 (跨模块端到端)

**优先级**: ⭐⭐⭐ **高** | **预估**: 0.5 天
**来源**: ARCHITECTURE.md §改进优先级 **P0**

#### 测试场景

| 场景 | 涉及模块 | 验证内容 |
|------|---------|---------|
| **生成→最短路径** | generators → shortest_path | 随机图 Dijkstra 正确性 |
| **生成→MST→连通性** | generators → mst → connectivity | MST 边数=V-1 且 CC=1 |
| **存储转换→算法** | storage converter → algo | Matrix→AdjList 算法一致性 |
| **流网络完整性** | flow (独立类型) | add_edge 链式调用 + deep_copy 不变式 |
| **匹配→流归约** | matching → flow | 二分图匹配 via 最大流一致性 |
| **P5 综合测试** | clique → independent_set → vertex_cover | 互补性定理验证 (α+τ=V) |

#### 验收标准

- [ ] 至少 6 个跨模块端到端测试用例（含 P5 新增）
- [ ] `moon test` 全量通过（含新增集成测试）

---

## ⭐ P1 — 下一批任务 (v0.5.0+)

### T09: 测试覆盖率提升

**目标**: ≥ 95%

| 模块 | 当前估计 | 目标 | 重点补充 |
|------|:-------:|:----:|----------|
| Core | ~95% | 98%+ | trait 边界情况 / GraphError 各分支 |
| Storage | ~90% | 95%+ | Converter 异常路径 / CSR/CSC 边界 |
| Flow | ~92% | 95%+ | deep_copy 一致性 / 残差图状态 |
| Matching | ~90% | 95%+ | GraphReadable 版本边界 |
| **Euler** 🆕 | ~90% | 95%+ | 有向/无向边界情况 |
| **Coloring** 🆕 | ~88% | 95%+ | DSatur 启发式边界 |
| **Clique** 🆕 | ~85% | 95%+ | Bron-Kerbosch 枢轴优化 |
| **Hamiltonian** 🆕 | ~85% | 95%+ | TSP Held-Karp 边界 |

### T10: CONTRIBUTING.md 完善

- [ ] 开发环境搭建详细步骤
- [ ] 新模块开发 SOP（引用 AGENTS.md）
- [ ] Code Review 检查清单
- [ ] 提交消息规范示例

### T11: P5 模块 README 补充 🆕

**优先级**: ⭐⭐ | **预估**: 1 天

| 模块 | 状态 | 说明 |
|------|:----:|------|
| Euler README | ⬜ 未创建 | 8 大章节标准模板 |
| Cutpoints README | ⬜ 未创建 | Tarjan 算法详解 |
| Coloring README | ⬜ 未创建 | 5 种着色算法对比 |
| Clique README | ⬜ 未创建 | 团/独立集/顶点覆盖关系 |
| Hamiltonian README | ⬜ 未创建 | 哈密顿 + TSP 双模块 |

---

## 📋 P2 — 有空就做 (v0.5.0+)

### T12: 性能基准测试套件

**来源**: ARCHITECTURE.md §改进优先级 **P1**

| 场景 | 指标 | 目标 |
|------|------|------|
| Dijkstra 大规模图 | 10K 节点执行时间 | < 100ms |
| Dinic 最大流 | 1K 节点稠密图 | < 50ms |
| Bron-Kerbosch | 30 节点完全图 | < 1s |
| TSP Held-Karp | 12 城市精确解 | < 500ms |

### T13: Push-Relabel 最大流

**优先级**: ⭐ | **包路径**: `src/algo/flow/push_relabel.mbt`

- [ ] 实现 Generic Push-Relabel 算法 O(V³)
- [ ] 与 EK/Dinic 一致性测试
- [ ] 性能对比基准

### T14: Edmonds Blossom 一般图匹配

**优先级**: ⭐⭐ | **包路径**: `src/algo/matching/blossom.mbt`

- [ ] 实现 Blossom 算法 O(V³)
- [ ] 扩展至一般图（非二分图）匹配
- [ ] 与 Hungarian 二分图特例一致性验证

---

## 进度追踪

### 已完成里程碑

| 里程碑 | 内容 | 日期 | 状态 |
|:------:|------|:----:|:----:|
| **v0.1.0** | M1-M3 + P0-P3 基础设施 + 核心算法 | 2026-05-19 | ✅ 达成 |
| **v0.4.0** | P4 匹配(21t) + Dinic(16t) | 2026-05-19 | ✅ Tagged |
| **v0.4.1** | **P5 全部: Euler(22t)+Cutpoints(15t)+Coloring(21t)+Clique(14t)+Hamiltonian(20t)** | **2026-05-22** | **✅ 完成** |
| **v0.2.0-alpha** | T02 CI/CD 完成 | ⬜ 待开始 | |
| **v0.2.0-beta** | T03-T04 API+集成测试完成 | ⬜ 待开始 | |
| **v0.5.0** | CI/CD + 集成测试 + API 冻结 | ⬜ 远期 | |

### Sprint 建议 (下一周)

```
┌─────────────────────────────────────────────────────┐
│              v0.5.0 Sprint 建议布局                  │
├──────────┬──────────┬──────────┬──────────┬─────────┤
│  周一    │  周二    │  周三    │  周四    │  周五   │
├──────────┼──────────┼──────────┼──────────┼─────────┤
│ T02 CI/CD│ T03 API  │ T04 集成 │ T09 覆盖率│T11 README│
│ 流水线   │ 冻结审查 │ 测试     │ 提升      │ 补充    │
└──────────┴──────────┴──────────┴──────────┴─────────┘
```

---

## 与 ROADMAP 的映射关系

| TODO 任务 | → 映射到 ROADMAP 章节 | 版本目标 | 状态 |
|-----------|---------------------|:-------:|:----:|
| ~~T01~~ P4 匹配 | §P4 Matching ✅ | **v0.4.0 ✅** | **已完成** |
| ~~T05~~ Dinic | §P3 Dinic ✅ | **v0.4.0 ✅** | **已完成** |
| **~~T06~~ Euler** 🆕 | **§P5-A Euler** | **✅ v0.4.1** | **✅ 已完成** |
| **~~T07~~ Coloring** 🆕 | **§P5-C Coloring** | **✅ v0.4.1** | **✅ 已完成** |
| **~~T08~~ TSP** 🆕 | **§P5-E Hamiltonian** | **✅ v0.4.1** | **✅ 已完成** |
| **P5-B Cutpoints** 🆕 | **§P5-B Cutpoints** | **✅ v0.4.1** | **✅ 已完成** |
| **P5-C Clique** 🆕 | **§P5-D Clique** | **✅ v0.4.1** | **✅ 已完成** |
| T02 CI/CD | §Phase 4 工程化 | v0.5.0 | ⬜ 待开始 |
| T03 API 冻结 | §改进优先级 P4 | v0.5.0 | ⬜ 待开始 |
| T04 集成测试 | §改进优先级 **P0** | v0.5.0 | ⬜ 待开始 |
| T09 覆盖率 | §改进优先级 P1 | v0.5.0+ | ⬜ 待开始 |
| T10 CONTRIBUTING | §Phase 4 社区生态 | v0.5.0+ | ⬜ 待开始 |

---

## 参考链接

| 文档 | 用途 |
|------|------|
| [ROADMAP.md](./ROADMAP.md) | 远期规划 (Analysis 层 / P5-P7 / v0.5.0+) |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | 架构权威 (SOLID 评审 / Trait 分层 / 竞品对比) |
| [AGENTS.md](../AGENTS.md) | 开发规范 (Top 10 陷阱 / 算法 SOP / Git 规范) |
| [MEMORY.md](../MEMORY.md) | 项目记忆 (语法陷阱 / 关键决策历史) |

---

> **💡 提示**: 本文件只追踪 **近期可执行任务**。
> 远期规划（Analysis 层 / IO 序列化 / 社区生态）见 [ROADMAP.md](./ROADMAP.md)。
>
> **🎯 当前状态**: **v0.4.1 已完成 P5 全部 5 个子模块** (483 tests / 14 packages / 30+ algorithms)，
> **下一步**: 选择 **T02(CI/CD)** / **T03(API冻结)** / **T04(集成测试)** 开始 v0.5.0 工程化，
> 或执行 **T11(P5 README 补充)** 完善文档。
