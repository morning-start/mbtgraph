---
title: "mbtgraph 近期行动清单 (TODO)"
version: "1.1.0"
status: "active"
type: "todo"
role: "行动清单 — Task-level 可执行任务"
source: "ARCHITECTURE.md v3.0 + ROADMAP.md v2.1.0"
created: "2026-05-19"
updated: "2026-05-19"
author: "morning-start"
tags: ["todo", "action-items", "ci-cd", "matching", "dinic", "v0.4.0"]
---

# mbtgraph 近期行动清单 (TODO)

> **定位**: 🎯 **行动清单** (Action Items) — Task 级别、可勾选、有时间框架
>
> **版本**: v1.1.0 | **当前里程碑**: **v0.4.0 Tagged** | **日期**: 2026-05-19
>
> **📖 配套文档**: [ROADMAP.md](./ROADMAP.md) = 战略蓝图（远期规划/技术方向）
> **🏗️ 架构依据**: [ARCHITECTURE.md](./ARCHITECTURE.md) = SOLID 评审 + 改进优先级

---

## 当前基线

```
✅ v0.4.0 已发布 (tagged):
   9 包 / 391 tests / ~86 API / SOLID 4.0/5

📍 当前位置:
   Phase 1: MVP 基础     ████████████████████████ 200% ✅
   Phase 2: 分析增强     ████████████░░░░░░░░░░░   50% 🔄
   Phase 3: 高级算法补全 ██████████████░░░░░░░░░   60% 🔄 (P4+Dinic✅)
   Phase 4: 生态完善       ░░░░░░░░░░░░░░░░░░░░░░░    0% ⬜

🎯 下个目标: v0.5.0 Ecosystem (P5-P7 + CI/CD + API 冻结)
```

---

## ✅ 已完成任务 (v0.4.0)

### ~~T01: P4 图匹配模块 — Hungarian 算法~~ ✅

**完成日期**: 2026-05-19 | **包路径**: `src/algo/matching/`

| 交付物 | 数量 |
|--------|:----:|
| 源文件 | 5 (moon.pkg / types / hungarian / test / README) |
| 公开 API | 2 函数 + 1 类型 + 3 方法 |
| 测试 | **21** (100% 通过) |
| Git commit | `b64478d` |

**验收结果**:
- [x] `moon test src/algo/matching` 全部通过 (21/21)
- [x] 测试数 ≥ 15（实际 21，超额完成）
- [x] 典型案例: K_{3,3} = 3, K_{2,2} = 2, 星形图 = 1
- [x] README.md 完整（8 大章节标准模板）
- [x] 双版本 API: 纯数据版 + GraphReadable trait 版

---

### ~~T05: Dinic 最大流算法~~ ✅

**完成日期**: 2026-05-19 | **包路径**: `src/algo/flow/dinic.mbt`

| 交付物 | 数量 |
|--------|:----:|
| 源文件 | 2 (dinic.mbt + dinic_test.mbt) |
| 公开 API | 1 函数 (`dinic`) |
| 测试 | **16** (含 3 个 EK 一致性验证) |
| Design Doc | flow_design.md 更新至 v0.2.0 |
| README | flow/README.md 更新至 v0.2.0 (双算法指南) |
| Git commit | `a95415b` |

**验收结果**:
- [x] Dinic 与 Edmonds-Karp 结果完全一致 (3 个交叉测试)
- [x] 测试数 ≥ 8（实际 16，超额完成）
- [x] 纯函数语义不变式（深拷贝，输入网络不被修改）
- [x] flow_design.md + README 双文档更新

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
- [ ] native 后端全量测试通过 (**391 tests**)
- [ ] wasm 后端编译 + 测试通过
- [ ] 测试覆盖率报告可在 Actions 页面查看

---

### T03: API 冻结与发布准备

**优先级**: ⭐⭐ **中高** | **预估**: 0.5 天

#### 任务清单

| ID | 任务 | 说明 |
|:--:|------|------|
| AP01 | **v0.4.0 API 审查** | 扫描所有 `pub` 函数，确认签名稳定 |
| AP02 | **CHANGELOG.md 更新** | 补充 v0.1.0 → v0.4.0 完整变更记录 |
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

#### 验收标准

- [ ] 至少 5 个跨模块端到端测试用例
- [ ] `moon test` 全量通过（含新增集成测试）

---

## ⭐ P1 — 下一批算法 (v0.5.0+)

### T06: 欧拉路径 Euler 🆕

**优先级**: ⭐⭐ **推荐** | **预估**: 0.5-1 天 | **包路径**: `src/algo/euler/`
**来源**: ROADMAP §Phase 3 — O(E) 线时间算法

#### 任务拆解

| 步骤 | 内容 | 复杂度 |
|:----:|------|:-----:|
| 1 | EulerResult 类型 + is_eulerian 判定 | O(V) |
| 2 | Hierholzer 算法实现 | O(E) |
| 3 | 测试套件 (≥10 tests) | — |
| 4 | README.md | — |

#### 技术要点

```moonbit
// 核心判定条件:
// - 欧拉回路: 所有顶点度为偶数
// - 欧拉路径: 恰好 0 或 2 个奇度顶点
//
// Hierholzer 算法 (O(E)):
// 1. 从任意顶点开始沿未访问边走
// 2. 无路可走时回溯并记录回路
// 3. 将小回路合并到主路径中
```

---

### T07: 图着色 Coloring 🆕

**优先级**: ⭐⭐ | **预估**: 1-2 天 | **包路径**: `src/algo/coloring/`
**来源**: ROADMAP §Phase 3 — NP-Complete 代表问题

#### 任务拆解

| 步骤 | 内容 | 复杂度 |
|:----:|------|:-----:|
| 1 | ColoringResult 类型 (colors/chromatic_number) | — |
| 2 | Welch-Powell 贪心着色 | O(V²+VE), 近似 Δ+1 |
| 3 | DSatur 回溯精确着色 | O(kⁿ), 小规模精确 |
| 4 | 双色判定 (二分图检测) | O(V+E) |
| 5 | 测试套件 (≥12 tests) | — |
| 6 | README.md | — |

---

### T08: TSP 旅行商 🆕

**优先级**: ⭐⭐ | **预估**: 1-2 天 | **包路径**: `src/algo/tour/tsp/`
**来源**: ROADMAP §Phase 3 — NP-Hard 代表问题

#### 任务拆解

| 步骤 | 内容 | 复杂度 |
|:----:|------|:-----:|
| 1 | TSPResult 类型 (tour/cost/is_optimal) | — |
| 2 | 最近邻启发式 | O(N²), 快速近似 |
| 3 | Held-Karp DP 精确解 | O(N²2^N), N≤20 |
| 4 | 测试套件 (≥12 tests) | — |
| 5 | README.md | — |

---

## 📋 P2 — 有空就做 (v0.5.0+)

### T09: 测试覆盖率提升

**目标**: ≥ 95%

| 模块 | 当前估计 | 目标 | 重点补充 |
|------|:-------:|:----:|----------|
| Core | ~95% | 98%+ | trait 边界情况 / GraphError 各分支 |
| Storage | ~90% | 95%+ | Converter 异常路径 / CSR/CSC 边界 |
| Flow | ~92% | 95%+ | deep_copy 一致性 / 残差图状态 |
| Matching | ~90% | 95%+ | GraphReadable 版本边界 |

### T10: CONTRIBUTING.md 完善

- [ ] 开发环境搭建详细步骤
- [ ] 新模块开发 SOP（引用 AGENTS.md）
- [ ] Code Review 检查清单
- [ ] 提交消息规范示例

---

## 进度追踪

### 已完成里程碑

| 里程碑 | 内容 | 日期 | 状态 |
|:------:|------|:----:|:----:|
| **v0.1.0** | M1-M3 + P0-P3 基础设施 + 核心算法 | 2026-05-19 | ✅ 达成 |
| **v0.4.0** | **P4 匹配(21t) + Dinic(16t)** | **2026-05-19** | **✅ Tagged** |
| **v0.2.0-alpha** | T02 CI/CD 完成 | ⬜ 待开始 | |
| **v0.2.0-beta** | T03-T04 API+集成测试完成 | ⬜ 待开始 | |
| **v0.5.0** | T06-T08 新算法 + 工程化 | ⬜ 远期 | |

### Sprint 建议 (下一周)

```
┌─────────────────────────────────────────────────────┐
│              v0.5.0 Sprint 建议布局                  │
├──────────┬──────────┬──────────┬──────────┬─────────┤
│  周一    │  周二    │  周三    │  周四    │  周五   │
├──────────┼──────────┼──────────┼──────────┼─────────┤
│ T06 欧拉 │ T07 着色 │ T08 TSP  │ T02 CI/CD│ T03-T04 │
│ Hierholz│ 贪心+回溯│ DP+启发式│ 流水线   │API+集成 │
└──────────┴──────────┴──────────┴──────────┴─────────┘
```

---

## 与 ROADMAP 的映射关系

| TODO 任务 | → 映射到 ROADMAP 章节 | 版本目标 |
|-----------|---------------------|:-------:|
| ~~T01~~ P4 匹配 | §P4 图匹配 ✅ | **v0.4.0 ✅** |
| T02 CI/CD | §Phase 4 工程化 | v0.5.0 |
| T03 API 冻结 | §改进优先级 P4 | v0.5.0 |
| T04 集成测试 | §改进优先级 **P0** | v0.5.0 |
| ~~T05~~ Dinic | §P3 Dinic ✅ | **v0.4.0 ✅** |
| **T06 Euler** 🆕 | **§Phase 3 `algo/euler`** | **v0.5.0** |
| **T07 Coloring** 🆕 | **§Phase 3 `algo/coloring`** | **v0.5.0** |
| **T08 TSP** 🆕 | **§Phase 3 `algo/tour/tsp`** | **v0.5.0** |
| T09 覆盖率 | §改进优先级 P1 | v0.5.0+ |
| T10 CONTRIBUTING | §Phase 4 社区生态 | v0.5.0+ |

---

## 参考链接

| 文档 | 用途 |
|------|------|
| [ROADMAP.md](./ROADMAP.md) | 远期规划 (Analysis 层 / P5-P7 / v0.3.0+) |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | 架构权威 (SOLID 评审 / Trait 分层 / 竞品对比) |
| [AGENTS.md](../AGENTS.md) | 开发规范 (Top 10 陷阱 / 算法 SOP / Git 规范) |
| [MEMORY.md](../MEMORY.md) | 项目记忆 (语法陷阱 / 关键决策历史) |

---

> **💡 提示**: 本文件只追踪 **近期可执行任务**。
> 远期规划（Analysis 层 / IO 序列化 / 社区生态）见 [ROADMAP.md](./ROADMAP.md)。
>
> **🎯 当前状态**: **v0.4.0 已 Tagged** (391 tests / 9 packages)，
> **下一步**: 选择 T06(欧拉) / T07(着色) / T08(TSP) 继续算法开发，
> 或执行 T02(CI/CD) / T03(API冻结) 提升工程质量。
