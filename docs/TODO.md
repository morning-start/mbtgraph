---
title: "mbtgraph 近期行动清单 (TODO)"
version: "1.0.0"
status: "active"
type: "todo"
role: "行动清单 — Task-level 可执行任务"
source: "ARCHITECTURE.md v3.0 + ROADMAP.md v2.0.0"
created: "2026-05-19"
updated: "2026-05-19"
author: "morning-start"
tags: ["todo", "action-items", "ci-cd", "matching", "v0.2.0"]
---

# mbtgraph 近期行动清单 (TODO)

> **定位**: 🎯 **行动清单** (Action Items) — Task 级别、可勾选、有时间框架
>
> **版本**: v1.0.0 | **目标里程碑**: **v0.2.0 Expansion** | **日期**: 2026-05-19
>
> **📖 配套文档**: [ROADMAP.md](./ROADMAP.md) = 战略蓝图（远期规划/技术方向）
> **🏗️ 架构依据**: [ARCHITECTURE.md](./ARCHITECTURE.md) = SOLID 评审 + 改进优先级

---

## 当前基线

```
✅ v0.1.0 Foundation 已发布:
   8 包 / 317 tests / ~82 API / SOLID 4.0/5

📍 当前位置:
   Phase 1: MVP ████████████████████████ 200% ✅
   Phase 2: 分析 ████████████░░░░░░░░░░░  50% 🔄
   Phase 3: 高级 ██████░░░░░░░░░░░░░░░░░  25% 🔄
   Phase 4: 生态 ░░░░░░░░░░░░░░░░░░░░░░░   0% ⬜

🎯 下个目标: v0.2.0 Expansion (2026-05-26)
```

---

## 🔥 P0 — 本周必须完成 (v0.2.0 关键路径)

### T01: P4 图匹配模块 — Hungarian 算法

**优先级**: 🔥🔥🔥 **最高** | **预估**: 2-3 天 | **包路径**: `src/algo/matching/`
**来源**: ROADMAP §Phase 3 待完成 + ARCHITECTURE.md §推荐下一步 #2

#### 任务拆解

| 步骤 | 内容 | 文件 | 预估 |
|:----:|------|------|:----:|
| 1 | 创建包配置 + MatchingResult 类型 | `moon.pkg` + `types.mbt` | 0.5h |
| 2 | 实现 Hungarian 匈牙利算法 | `hungarian.mbt` | 2-3h |
| 3 | 实现最大流归约解法 (复用 Edmonds-Karp) | `flow_reduction.mbt` | 1h |
| 4 | 编写测试套件 (≥15 tests) | `matching_test.mbt` | 1.5h |
| 5 | 编写 README.md (8 大章节标准模板) | `README.md` | 1h |

#### 验收标准 (checkbox)

- [ ] `moon test src/algo/matching` 全部通过
- [ ] 测试数 ≥ 15（覆盖: 正常/边界/属性/跨存储）
- [ ] 典型案例: K_{3,3} 最大匹配 = 9, Petersen = 5
- [ ] README.md 包含: API 总览 / 使用示例 / 算法原理 / 复杂度分析
- [ ] 跨存储兼容: AdjList / Matrix 均正确

#### 技术要点

```moonbit
// 结果类型设计
pub(all) struct MatchingResult {
  matching_edges : Array[(@core.NodeId, @core.NodeId)]  // 匹配边列表
  cardinality : Int                                      // 匹配数 (大小)
}
// 方法: size() / is_matched(node) / get_partner(node)

// Hungarian 核心思路 (二分图 O(VE))
// 1. 从空匹配开始
// 2. 寻找增广路 (BFS/DFS 在交替树上)
// 3. 沿增广路翻转匹配状态
// 4. 重复直到无增广路
```

**参考**: [ROADMAP.md §Phase 3](./ROADMAP.md#phase-3-待完成--高级算法补全-25---100%)

---

### T02: GitHub Actions CI/CD 流水线

**优先级**: 🔥🔥🔥 **高** | **预估**: 1 天 | **文件**: `.github/workflows/ci.yml`
**来源**: ARCHITECTURE.md §改进优先级 P3 + Phase 4 工程化

#### 任务拆解

| ID | 任务 | 验证方式 |
|:--:|------|---------|
| CI01 | **CI 主流水线** (fmt → check → test) | PR 触发自动运行 |
| CI02 | **多后端验证** (native + wasm) | 双后端均通过 |
| CI03 | **测试覆盖率报告** | coverage analyze 输出 |

#### 流水线 YAML 草案

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    strategy:
      matrix:
        backend: [native, wasm]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: moonbitlang/setup-moonbit@v1
      - run: moon fmt --check
      - run: moon check
      - run: moon test
      - run: moon coverage analyze
```

#### 验收标准

- [ ] Push 到 main 分支触发完整流水线
- [ ] PR 触发 fmt + check + test 三步检查
- [ ] native 后端全量测试通过 (317 tests)
- [ ] wasm 后端编译 + 测试通过
- [ ] 测试覆盖率报告可在 Actions 页面查看

---

## ⭐ P1 — 尽快完成 (本周内)

### T03: API 冻结与发布准备

**优先级**: ⭐⭐ **中高** | **预估**: 0.5 天
**来源**: ARCHITECTURE.md §改进优先级 P4 + ROADMAP §版本里程碑 v0.2.0

#### 任务清单

| ID | 任务 | 说明 |
|:--:|------|------|
| AP01 | **v0.1.0 API 审查** | 扫描所有 `pub` 函数，确认签名稳定 |
| AP02 | **CHANGELOG.md 更新** | 补充 v0.1.0 正式变更记录 |
| AP03 | **moon.pkg 导出审查** | 确认公开导出列表正确无误 |
| AP04 | **semver 策略确定** | 定义 Breaking Change 判定规则 |

#### API 冻结检查项

- [ ] 所有 `pub fn` 签名已 review 无误
- [ ] 无 `pub(open)` 滥用（trait 外的内部 API 应为 priv）
- [ ] 版本号策略文档化: `MAJOR.PATCH` (无 MINOR 因 0.x 阶段)
- [ ] Breaking changes（如有）记录在 CHANGELOG.md

---

### T04: 集成测试 (跨模块端到端)

**优先级**: ⭐⭐⭐ **高** | **预估**: 0.5 天
**来源**: ARCHITECTURE.md §改进优先级 **P0** (架构风险 R4 缓解方案)

#### 测试场景

| 场景 | 涉及模块 | 验证内容 |
|------|---------|---------|
| **生成→最短路径** | generators → shortest_path | 随机图 Dijkstra 正确性 |
| **生成→MST→连通性** | generators → mst → connectivity | MST 边数=V-1 且 CC=1 |
| **存储转换→算法** | storage converter → algo | Matrix→AdjList 算法一致性 |
| **流网络完整性** | flow (独立类型) | add_edge 链式调用 + deep_copy 不变式 |

#### 验收标准

- [ ] 新建 `src/integration_test.mbt` 或分散到各模块
- [ ] 至少 4 个跨模块端到端测试用例
- [ ] `moon test` 全量通过（含新增集成测试）

---

## 📋 P2 — 有空就做 (两周内 / v0.2.0+)

### T05: Dinic 最大流算法

**优先级**: ⭐⭐ 中 | **预估**: 1-2 天 | **包路径**: `src/algo/flow/dinic.mbt`
**来源**: ARCHITECTURE.md §Dinic 最大流算法 (含伪代码和流程图)

#### 技术要点

```moonbit
// Dinic vs Edmonds-Karp 对比
// EK:  O(VE²)     — 每次 BFS 一条增广路
// Dinic: O(E√V)   — BFS 分层 + DFS 多路增广 (阻塞流)
//
// 核心改进:
// 1. BFS 构建层次图 (level graph)
// 2. DFS 在层次图上反复找阻塞流 (blocking flow)
// 3. 当前弧优化 (current arc optimization) 避免重复边
```

#### 验收标准

- [ ] Dinic 与 Edmonds-Karp 在相同输入上结果一致
- [ ] 大规模网络 (V>50) 性能优于 EK（可选 benchmark 验证）
- [ ] 测试数 ≥ 8

---

### T06: 测试覆盖率提升

**优先级**: ⭐⭐ 中 | **目标**: ≥ 95%
**来源**: ARCHITECTURE.md §测试策略

| 模块 | 当前估计 | 目标 | 重点补充 |
|------|:-------:|:----:|----------|
| Core | ~95% | 98%+ | trait 边界情况 / GraphError 各分支 |
| Storage | ~90% | 95%+ | Converter 异常路径 / CSR/CSC 边界 |
| Flow | ~92% | 95%+ | deep_copy_matrix 一致性 / 残差图状态 |

---

### T07: CONTRIBUTING.md 完善

**说明**: 文件已有基础版本。需补充:
- [ ] 开发环境搭建详细步骤 (MoonBit 安装/配置)
- [ ] 新模块开发 SOP（引用 AGENTS.md §算法模块开发流程）
- [ ] Code Review 检查清单 (命名/trait/测试/文档)
- [ ] 提交消息规范示例 (Conventional Commits)

---

## 进度追踪

### Sprint 规划 (2026-05-19 ~ 05-26)

```
┌─────────────────────────────────────────────────────┐
│              v0.2.0 Sprint (1 周)                    │
├──────────┬──────────┬──────────┬──────────┬─────────┤
│  周一    │  周二    │  周三    │  周四    │  周五   │
├──────────┼──────────┼──────────┼──────────┼─────────┤
│ T01 匹配 │ T01 匹配 │ T01 测试 │ T02 CI/CD│ T03-T04 │
│ types   │Hungarian│ + docs   │ 流水线   │API+集成 │
│ +Result │ 算法    │          │          │         │
└──────────┴──────────┴──────────┴──────────┴─────────┘

周末缓冲: T05-T07 (有空就做)
```

### 里程碑检查表

| 里程碑 | 触发条件 | 状态 |
|:------:|---------|:----:|
| **v0.1.0** | M1-M3 + P0-P3 完成 | ✅ 达成 |
| **v0.2.0-alpha** | T01 匹配 + T02 CI/CD 完成 | ⬜ 进行中 |
| **v0.2.0-beta** | T03 API 冻结 + T04 集成测试完成 | ⬜ 待开始 |
| **v0.2.0** | 全部 P0-P1 完成 + tag 发布 | ⬜ 待开始 |

---

## 与 ROADMAP 的映射关系

| TODO 任务 | → 映射到 ROADMAP 章节 | 版本目标 |
|-----------|---------------------|:-------:|
| T01 P4 匹配 | §Phase 3 `algo/matching` | v0.2.0 |
| T02 CI/CD | §Phase 4 工程化 + §改进优先级 P3 | v0.2.0 |
| T03 API 冻结 | §Phase 4 发布 + §改进优先级 P4 | v0.2.0 |
| T04 集成测试 | §改进优先级 **P0** (ARCHITECTURE R4) | v0.2.0 |
| T05 Dinic | §Phase 3 `algo/flow/dinic` | v0.2.0+ |
| T06 覆盖率 | §改进优先级 P1 (Benchmark 前置) | v0.3.0 |
| T07 CONTRIBUTING | §Phase 4 社区生态 | v0.3.0 |

---

## 参考链接

| 文档 | 用途 |
|------|------|
| [ROADMAP.md](./ROADMAP.md) | 远期规划 (P5-P7 / Analysis 层 / v0.3.0+) |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | 架构权威 (SOLID 评审 / Trait 分层 / 竞品对比) |
| [AGENTS.md](../AGENTS.md) | 开发规范 (Top 10 陷阱 / 算法 SOP / Git 规范) |
| [MEMORY.md](../MEMORY.md) | 项目记忆 (语法陷阱 / 关键决策历史) |

---

> **💡 提示**: 本文件只追踪 **近期可执行任务**。
> 远期规划（Analysis 层 / P5-P7 / IO 序列化 / 社区生态）见 [ROADMAP.md](./ROADMAP.md)。
>
> **🎯 当前目标**: 在 **2026-05-26 前**完成 v0.2.0 Expansion，
> 核心交付物: **P4 图匹配 + CI/CD + API 冻结 + 集成测试**。
