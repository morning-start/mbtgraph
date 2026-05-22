---
title: "mbtgraph 发展路线图 (ROADMAP)"
version: "2.2.0"
status: "active (v0.4.1 — P5 图论核心算法扩展完成)"
type: "roadmap"
role: "战略蓝图 — Module-level 技术方向与架构演进"
source: "ARCHITECTURE.md v3.0"
created: "2026-05-18"
updated: "2026-05-22"
author: "morning-start"
license: "Apache-2.0"
tags: ["roadmap", "graph-algorithms", "moonbit", "trait-based", "strategy"]
---

# mbtgraph 发展路线图 (ROADMAP)

> **定位**: 🗺️ **战略蓝图** (Strategic Blueprint) — Module 级别、展望性、技术方向
>
> **版本**: v2.2.0 | **基准架构**: [ARCHITECTURE.md](./ARCHITECTURE.md) v3.0 (SOLID 4.0/5)
>
> **📖 配套文档**: [TODO.md](./TODO.md) = 行动清单（近期任务/可执行项）

---

## 架构基线

### 当前状态快照

```
mbtgraph v0.4.1 (P5 完成) ────────────────────────────────
│
│  📦 包数:     14 个 (core / storage / algo×12 / utils)
│  🧪 测试:     483 个 (100% 通过) ↑+92
│  🔌 公开API:  ~120 个函数/类型/trait
│  📄 文档:      14/14 README + Design Doc (100%)
│  🏗️ 架构评分: ⭐⭐⭐⭐☆ 4.0/5 (SOLID 十维评审)
│  ⚡ 后端:      native / wasm 双后端
│  🏷️ Tags:     v0.1.0 → v0.2.0 → v0.3.0 → v0.4.0 → v0.4.1
│
└───────────────────────────────────────────────────────
```

### 四层架构模型（来自 ARCHITECTURE.md §项目目录结构）

```
                    ┌──────────────────┐
                    │    utils/        │ ← 工具层 (generators 56t)
                    ├──────────────────┤
                    │    algo/         │ ← 算法层 (283t, 12 子模块) 🆕
                    │  traversal/sp/mst│
                    │  conn/flow/match│
                    │  euler/cutpoints │ ← P5 新增
                    │  coloring/clique │
                    │  hamiltonian     │
                    ├──────────────────┤
                    │   storage/       │ ← 存储层 (~107t, 8 种实现)
                    │ 有向/无向/只读   │
                    ├──────────────────┤
                    │    core/         │ ← 核心抽象层 (68t, 6 层 trait)
                    │ types/traits/err│
                    └──────────────────┘
```

### Trait 分层体系（6 层，12 方法）

| 层级 | Trait | 方法数 | 职责 |
|:----:|-------|:-----:|------|
| L0 | `GraphReadable` | **12** | 最小只读接口 (node/edge/neighbor/degree/iter) |
| L1a | `GraphWritable` | **6** | 动态修改 (add/remove node+edge+clear) |
| L1b | `BatchReadable` | **2** | 批量查询 (nodes/edges_batch) |
| L1c | `EdgeIterable` | **1** | 边迭代 (edges_iter → Kruskal) |
| L2 | `GraphDirected` | **6** | 有向图扩展 (in/out neighbor/degree/succ/pred) |
| L3 | `GraphFull` | **0** | 组合别名 = Writable + Directed |

---

## Phase 进度总览

> 数据来源: [ARCHITECTURE.md](./ARCHITECTURE.md) §开发路线图

```
Phase 1: MVP 基础     ████████████████████████ 200% ✅ 超额完成
Phase 2: 网络分析增强   ████████████░░░░░░░░░░░   50% 🔄 进行中
Phase 3: 高级算法补全   ██████████████████████ 100% ✅ P5全部完成 🎉
Phase 4: 生态完善       ░░░░░░░░░░░░░░░░░░░░░░░    0% ⬜ 未开始
```

---

## 1. 已完成模块 ✅

### M1-M3: 基础设施层

| # | 模块 | 路径 | 测试数 | Trait 实现 | 完成日期 |
|---|------|------|:------:|-----------|:--------:|
| M1 | **核心类型 + Trait** (6 层) | `src/core/` | **68** | 定义方 | 2026-05-17 |
| M2 | **8 种存储实现** | `src/storage/` | **~107** | Full/Writable/Read | 2026-05-17 |
| M3 | **遍历算法** (BFS/DFS/环检测/拓扑) | `src/algo/traversal/` | **~47** | GraphReadable | 2026-05-18 |

**M 层关键设计决策** (ARCHITECTURE.md §内部基础设施分布策略):
- ✅ 组件内聚: 无 `internal/` 包，私有数据结构定义在使用方内部
- ✅ CSR 只读: 故意不实现 GraphWritable (LSP 原则)
- ✅ Converter 三层架构: 有向转换/无向转换/语义转换 (as_*)

### P0-P3: 核心算法模块

#### P0: 图生成器 ✅

| 类别 | 函数数 | 测试数 | 位置 |
|------|:-----:|:-----:|------|
| 经典图 | 8 | 24 | `src/utils/generators/classic.mbt` |
| 网格拓扑 | 3 | 12 | `src/utils/generators/grid.mbt` |
| 随机图 | 4 | 12 | `src/utils/generators/random.mbt` |
| 二分图专用 | 2 | 8 | `src/utils/generators/bipartite.mbt` |
| **合计** | **16** | **56** | |

#### P1: 最短路径 ✅

| 算法 | 复杂度 | 私有组件 | 测试数 |
|------|:-----:|---------|:-----:|
| Dijkstra | O((V+E)log V) | BinaryHeap (priv) | 9+2=11 |
| Bellman-Ford | O(VE) | — | 6 |
| Floyd-Warshall | O(V³) | — | 5 |
| **跨存储兼容** | — | AdjList/Matrix/EdgeList | 6 |
| **合计** | | | **32** |

#### P2: MST + 连通性 ✅

| 算法 | 复杂度 | 私有组件 | 测试数 |
|------|:-----:|---------|:-----:|
| Kruskal | O(E log E) | UnionFind (priv) | 7 |
| Prim | O(V²) | — | 5 |
| ConnectedComponents | O(V+E) | — | 7 |
| Tarjan SCC | O(V+E) | TarjanState (priv) | 7 |
| Kosaraju SCC | O(V+E) | — | 7 |
| **跨存储兼容** | — | | 3 |
| **MST 一致性验证** | — | Kruskal vs Prim | 1 |
| **合计** | | | **37** |

#### P3: 网络流 ✅

> **完成日期**: 2026-05-19 | **状态**: ✅ **全部完成 (双算法)**

| 组件 | 设计模式 | 测试数 |
|------|---------|:-----:|
| FlowNetwork (独立类型) | 不适配 Graph trait | 5 |
| Edmonds-Karp | deep_copy 纯函数语义, O(VE²) | 11 |
| **Dinic** ✨ | **BFS分层+DFS阻塞流, O(E√V)** | **16** |
| **合计** | | **33** |

**P3 关键设计**: FlowNetwork 为独立类型（矩阵表示），不强制适配 GraphReadable。
双算法并存: EK 教学友好 / Dinic 性能更优，可交叉验证正确性。

#### P4: 图匹配 ✅

> **完成日期**: 2026-05-19 | **状态**: ✅ **全部完成**

| 组件 | 复杂度 | 测试数 |
|------|:-----:|:-----:|
| MatchingResult 类型 + 3 方法 | — | 5 |
| Hungarian 匈牙利算法 | O(VE) | 16 |
| bipartite_matching_graph (Trait 版本) | O(VE) | — |
| **合计** | | **21** |

**P4 关键设计**: 二分图最大匹配，DFS 增广路搜索。
提供纯数据版本（零依赖）和 GraphReadable trait 版本（与存储层集成）。

---

#### P5: 图论核心算法扩展 ✅🆕

> **完成日期**: 2026-05-22 | **状态**: ✅ **全部完成 (5 子模块, 92 tests)**

##### P5-A: Euler 欧拉路径/回路 ✅

> **路径**: `src/algo/euler/` | **测试**: **22** | **Git**: `e538ea4`

| 组件 | 算法 | 复杂度 | 测试数 |
|------|------|:-----:|:-----:|
| EulerResult 类型 | — | — | 5 |
| Hierholzer 无向图欧拉回路 | O(E) | 7 |
| Hierholzer 有向图欧拉路径 | O(E) | 5 |
| is_eulerian 判定 | O(V) | 5 |
| **合计** | | | **22** |

##### P5-B: 割点与桥 (Cutpoints) ✅

> **路径**: `src/algo/cutpoints/` | **测试**: **15** | **Git**: `a74d8ac`

| 组件 | 算法 | 复杂度 | 测试数 |
|------|------|:-----:|:-----:|
| CutpointResult / BridgeResult | — | — | 4 |
| Tarjan 割点检测 | O(V+E) | 6 |
| Tarjan 桥检测 | O(V+E) | 5 |
| **合计** | | | **15** |

##### P5-C: 图着色 (Coloring) ✅

> **路径**: `src/algo/coloring/` | **测试**: **21** | **Git**: `2226aee`

| 组件 | 算法 | 复杂度 | 测试数 |
|------|------|:-----:|:-----:|
| ColoringResult / ChromaticResult | — | — | 5 |
| Greedy 贪心着色 | O(V²) | 4 |
| Welch-Powell 着色 | O(V²+VE) | 4 |
| DSATUR 启发式 | O(V²+kV) | 4 |
| 回溯精确着色 | O(k^V) | 4 |
| **合计** | | | **21** |

##### P5-D: 团/独立集/顶点覆盖 (Clique) ✅

> **路径**: `src/algo/clique/` | **测试**: **14** | **Git**: `b021639`

| 组件 | 算法 | 复杂度 | 测试数 |
|------|------|:-----:|:-----:|
| CliqueResult / IndependentSetResult / VertexCoverResult | — | — | 3 |
| Bron-Kerbosch 最大团 | O(3^{V/3}) | 6 |
| 最大独立集 (补图法) | O(3^{V/3}) | 3 |
| 最小顶点覆盖 (精确 + 近似) | 精确 O(3^{V/3}) / 近似 O(V²) | 2 |
| **合计** | | | **14** |

##### P5-E: 哈密顿路径/TSP (Hamiltonian) ✅

> **路径**: `src/algo/hamiltonian/` | **测试**: **20** | **Git**: `821ac95`

| 组件 | 算法 | 复杂度 | 测试数 |
|------|------|:-----:|:-----:|
| HamiltonianResult / TSPResult | — | — | 2 |
| 哈密顿快速检查 | O(V+E) | 6 |
| 哈密顿路径回溯 | O(V!) | 3 |
| 哈密顿回路回溯 | O(V!) | 3 |
| TSP 最近邻启发式 | O(V²) | 3 |
| TSP Held-Karp 精确解 | O(V!)/O(2^V·V²) V≤12 | 3 |
| **合计** | | | **20** |

**P5 总计**: **5 子模块 / 15+ 算法 / 92 tests / 11 commits**

---

## 2. 项目仪表盘

### 代码产出统计

| 层级 | 模块 | 源文件 | 代码行 | 公共 API | 测试 | Git 提交 |
|------|------|:-----:|:-----:|:------:|:-----:|:-------:|
| **L3 核心** | Core | 4 | ~400 | 20+ types/traits | 68 | 3 |
| | Storage | 12 | ~2000 | 8 structs + 8 converters | ~107 | 5 |
| | Traversal | 4 | ~500 | 4 functions | ~47 | 2 |
| **L2 算法** | Generators | 5 | ~600 | 16 functions | 56 | 1 |
| | Shortest Path | 6 | ~550 | 5 functions | 32 | 1 |
| | MST | 5 | ~350 | 2 functions | 16 | 1 |
| | Connectivity | 6 | ~450 | 3 functions | 21 | 1 |
| | Flow | 7 | ~540 | 4 functions | 33 | 6 |
| | Matching | 5 | ~250 | 2+3 methods | 21 | 1 |
| **Euler 🆕** | 5 | ~400 | 3 functions | **22** | 3 |
| **Cutpoints 🆕** | 5 | ~300 | 2 functions | **15** | 3 |
| **Coloring 🆕** | 6 | ~500 | 5 functions | **21** | 3 |
| **Clique 🆕** | 6 | ~450 | 4 functions | **14** | 3 |
| **Hamiltonian 🆕** | 6 | ~400 | 4 functions | **20** | 3 |
| **文档** | Design Docs | 13~14 | ~2800 | — | — | 6 |
| | READMEs | 14 | ~2000 | — | — | 4 |
| **总计** | **~96** | **~11040** | **~120** | **~483** | **~45** |

### 测试分布热力图

```
Storage:      ████████████████████████████████ 107 (22%)  ← 最大
Core:         ████████████████████ 68 (14%)
Generators:   █████████████████████ 56 (12%)
Flow:         ███████████████████ 33 (7%)
Traversal:    ██████████████ 47 (10%)
ShortestPath: ███████████████ 32 (7%)
**Euler 🆕:**   █████████████████ **22 (5%)**
**Coloring 🆕:** █████████████████ **21 (4%)**
Connectivity: ███████████████ 21 (4%)
Matching:     ███████████████ 21 (4%)
**Hamiltonian 🆕:** ███████████████ **20 (4%)**
**Cutpoints 🆕:** ████████████ **15 (3%)**
**Clique 🆕:**   ████████████ **14 (3%)**
MST:          ██████████ 16 (3%)
───────────────────────────────────────────────────
Total:        ████████████████████████████████████████ 483 tests (100%) ✅
```

---

## 3. 远期模块规划 (Backlog)

> 📝 **近期可执行任务见 [TODO.md](./TODO.md)** | 本节为 Module-level 技术方向

### Phase 2 待完成: 网络分析增强 (50% → 100%)

> 当前状态: MST + Generators 已提前完成；PageRank / Louvain / 中心性 待开发

| 模块路径 | 核心算法 | 复杂度 | Trait 约束 | 优先级 | 状态 |
|----------|---------|:-----:|-----------|:-----:|:----:|
| `algo/analysis/centrality` | PageRank | O(kE) 迭代 | GraphDirected | ⭐⭐ | ⬜ |
| | Betweenness Centrality | O(VE²) | GraphReadable | ⭐ | ⬜ |
| `algo/analysis/community` | Louvain 社区检测 | O(m log n) | GraphWritable | ⭐⭐⭐ | ⬜ |
| | Label Propagation | O(m) | GraphWritable | ⭐⭐ | ⬜ |
| `algo/analysis/clustering` | Clustering Coefficient | O(Vd²) | GraphReadable | ⭐ | ⬜ |

**技术要点** (ARCHITECTURE.md §PageRank/Louvain):
- PageRank: 阻尼因子 d=0.85, 容忍度 ε=1e-6, 通常 10-20 次迭代收敛
- Louvain: 两阶段迭代 (节点移动 + 超图聚合), 接近线性复杂度
- **差异化定位**: 这是 mbtgraph 相对竞品的**核心卖点** (NetworkX 强但慢, petgraph 无此功能)

### Phase 3 待完成: 高级算法补全 (100% ✅) 🎉

> 当前状态: **✅ 全部完成！** P0-P5 + Dinic + Matching + Euler + Cutpoints + Coloring + Clique + Hamiltonian

| 模块路径 | 核心算法 | 复杂度 | 说明 | 优先级 | 状态 |
|----------|---------|:-----:|------|:-----:|:----:|
| `algo/flow/dinic` | Dinic 最大流 | O(E√V) | 比 EK 快一个数量级 | 🔥🔥 | **✅ 已完成** |
| `algo/flow/push_relabel` | Push-Relabel | O(V³) | 理论最优实践 | ⭐ | ⬜ 可选 |
| `algo/matching` | Hungarian 匈牙利 | O(VE) | 二分图最大匹配 | 🔥🔥🔥 | **✅ 已完成** |
| | Edmonds Blossom | O(V³) | 一般图最大匹配 | ⭐⭐ | ⬜ 远期 |
| `algo/euler` | Hierholzer | O(E) | 欧拉回路构造 | ⭐⭐ | **✅ 已完成** |
| `algo/cutpoints` | Tarjan | O(V+E) | 割点/桥检测 | ⭐⭐ | **✅ 已完成** |
| `algo/coloring` | DSatur/Welsh-Powell | O(V²)~O(k^V) | 图着色 (NP-C) | ⭐⭐ | **✅ 已完成** |
| `algo/clique` | Bron-Kerbosch | O(3^{V/3}) | 团/独立集/顶点覆盖 | ⭐⭐ | **✅ 已完成** |
| `algo/hamiltonian` | 回溯 + 最近邻 + Held-Karp | O(V!)~O(2^V) | 哈密顿/TSP (NP-Hard) | ⭐⭐ | **✅ 已完成** |

### Phase 4: 生态完善 (0%)

| 模块路径 | 内容 | 说明 | 优先级 |
|----------|------|------|:-----:|
| `utils/io` | DOT / GraphML / JSON / CSV 序列化 | 与 NetworkX/Gephi 互通 | ⭐⭐ |
| `utils/layout` | Force-directed / Circular / Hierarchical | 可视化布局引擎 | ⭐ |
| CI/CD | GitHub Actions 自动化流水线 | fmt → check → test → coverage | 🔥🔥 → [TODO](./TODO.md) |
| 发布 | moonpkg 注册中心发布 | semver 管理 | 🔥🔥 → [TODO](./TODO.md) |

---

## 4. 架构演进路线

> 基于 ARCHITECTURE.md §架构合理性审查报告 (SOLID 4.0/5)

### 当前风险矩阵

| # | 风险 | 严重度 | 影响范围 | 缓解方案 |
|---|------|:-----:|---------|---------|
| **R1** | FlowNetwork 独立于 Graph trait | 🟡 中 | flow 模块 | Adapter 模式桥接 (v0.3+) |
| **R2** | 缺少 analysis 层 | 🟢 低 | Phase 2 | 正在开发中 |
| **R3** | 无 IO/Layout 支持 | 🟢 低 | Phase 4 | 外部工具链弥补 |
| **R4** | 无集中集成测试 | 🟡 中 | 全局质量 | 添加 integration_test (v0.5) |
| **R5** | 性能未基准测试 | 🟡 中 | 优化依据 | Benchmark 套件 (v0.5) |

### 改进优先级 (ARCHITECTURE.md §改进优先级)

| 优先级 | 改进项 | 版本目标 | 预期收益 |
|:-----:|--------|:-------:|---------|
| **P0** | 集成测试 (跨模块端到端) | v0.5.0 | 提升整体信心 |
| **P1** | 性能基准测试套件 | v0.5.0 | 数据驱动优化决策 |
| **P2** | FlowNetwork → Graph 适配器 | v0.5.0+ | 统一抽象层 |
| **P3** | CI/CD 自动化 | v0.5.0 | 工程质量提升 |
| **P4** | API 冻结 (semver) | v0.5.0 | 生态基础 |

---

## 5. 版本里程碑

```
时间轴 ─────────────────────────────────────────────────────────────►

v0.1.0  ★              v0.3.0           v0.4.0  ★       v0.4.1 ★当前    v0.5.0            v1.0.0
  │                     │                │               │             │                 │
  │ M1-M3 + P0-P3       │ P4+Dinic       │ P4+Dinic      │ P5 全部      │ Analysis        │ API稳定
  │ 317 tests           │ CI/CD          │ 391t          │ 483t         │ CI/CD+API       │ 全覆盖
  │ 8 packages          │ API冻结         │ 9 packages    │ 14 packages  │ Benchmark        │ 生产就绪
  │                     │ 集成测试        │               │ 30+ algorithms│ Integration      │
  │ 2026-05-19          │ 2026-05-26      │ 2026-05-19     │ 2026-05-22   │ 2026-06         │ 2026-Q3
```

| 版本 | 代号 | 核心内容 | 目标日期 | 状态 | 详情 |
|:----:|------|---------|:--------:|:----:|------|
| **v0.1.0** | Foundation | M1-M3 + P0-P3 基础设施 + 核心算法 | 2026-05-19 | ✅ 完成 | 8 包 / 317t / 82 API |
| **v0.2.0** | Expansion | P4 匹配 + Dinic + CI/CD + API 冻结 | 2026-05-26 | 🔄 进行中 | → [TODO.md](./TODO.md) |
| **v0.3.0** | Analysis | PageRank + Louvain + Benchmark 套件 | 2026-06-09 | ⬜ 远期 | 差异化核心竞争力 |
| **v0.4.0** | Enhanced Flow+Match | P4 Matching + Dinic 双算法 | 2026-05-19 | ✅ Tagged | 9 包 / 391t / 86 API |
| **v0.4.1** | **P5 Core Algorithms** | **Euler/Cutpoints/Coloring/Clique/Hamiltonian** | **2026-05-22** | **✅ 完成** | **14 包 / 483t / 120 API / 30+ 算法** |
| v0.5.0 | Ecosystem | IO 序列化 + Layout + CI/CD + 集成测试 | 2026-06 | ⬜ 下一步 | 生态完善 |
| v1.0.0 | Production | API 稳定 (semver) + 全覆盖 + 文档完整 | 2026-Q3 | 🌟 愿景 | 生产就绪 |

---

## 6. 依赖关系图

```
已完成 (✅) — v0.1.0:
═══════════════════════════════════════════════════
M1 Core ─┬─ M2 Storage ── M3 Traversal
          │                 │
          └─────────────────┘
                    ↓
          ┌──────────────────────────────────────┐
          │                                      │
    P0 Gen(utils)←─ 测试基建依赖 ─→ P1 ShortestPath
          │                         │           │
          │                         ↓           │
          │                   P2 MST+Conn       │
          │                         │           │
          └─────────────────────────→ P3 Flow ←┘
═══════════════════════════════════════════════════

已完成 (✅) — v0.4.0:
═══════════════════════════════════════════════════
P3 Flow ──┬── Edmonds-Karp (O(VE²))
            └── Dinic ✨ (O(E√V))
P4 Matching ✅ ── Hungarian (O(VE))
═══════════════════════════════════════════════════

已完成 (✅) — v0.4.1 🆕 P5 全部完成:
═══════════════════════════════════════════════════
P5-A Euler ──┬─ Hierholzer O(E) ────────────── 22 tests
             │
P5-B Cutpoints ── Tarjan O(V+E) ─────────── 15 tests
             │
P5-C Coloring ──┬─ Greedy/WP/DSATUR ─────── 21 tests
             │  └─ Backtracking Exact
             │
P5-D Clique ──┬─ Bron-Kerbosch O(3^{V/3}) ─ 14 tests
             │  └─ Independent Set / Vertex Cover
             │
P5-E Hamiltonian ─┬─ Backtrack Path/Circuit ─ 20 tests
                  └─ TSP Nearest Neighbor / Held-Karp
═══════════════════════════════════════════════════

待开发 (⬜) — v0.5.0+:
═══════════════════════════════════════════════════
Phase 2 Analysis (差异化核心):
  Centrality ←── PageRank / Betweenness
  Community ←── Louvain / LPA
  Clustering ←── Local / Global Coef

Phase 4 Ecosystem:
  CI/CD Pipeline ── fmt → check → test → coverage
  IO Serialization ── DOT / GraphML / JSON
═══════════════════════════════════════════════════
```

---

## 7. 更新日志

| 日期 | 版本 | 操作 | 说明 |
|------|:----:|------|------|
| 2026-05-18 | v0.0.1 | 创建 | 初始化路线图，定义 P0-P3 需求 |
| 2026-05-18 | v0.1.0-alpha | **P0 完成** | 16 个图生成器, 56 tests |
| 2026-05-18 | v0.1.0-beta | **P1-P2 完成** | 最短路径(32) + MST+连通性(37), 69 tests |
| 2026-05-19 | v0.1.0 | **P3 完成** | 网络流(17), **P0-P3 全部完成**, 317 tests |
| 2026-05-19 | v1.0.0 | **首次拆分** | TODO/ROADMAP 分离，行动 vs 战略 |
| 2026-05-19 | v2.0.0 | **基于 ARCHITECT 重构** | 以 ARCHITECTURE.md v3.0 为唯一数据源 |
| 2026-05-19 | **v2.1.0** | **🎉 P4+Dinic 完成 + v0.4.0 Tagged** | **P4 匹配(21t) + Dinic(16t), 391 tests, 9 packages** |
| **2026-05-22** | **v2.2.0** | **🎉🎉 P5 图论核心算法扩展全部完成** | **Euler(22t) + Cutpoints(15t) + Coloring(21t) + Clique(14t) + Hamiltonian(20t), 483 tests, 14 packages, 30+ 算法** |

---

## 8. 参考文档

### 内部文档 (docs/)

| 文档 | 角色 | 内容 |
|------|:----:|------|
| **[TODO.md](./TODO.md)** | 🎯 行动清单 | 近期任务 (Task-level, 可执行) |
| **[ARCHITECTURE.md](./ARCHITECTURE.md)** | 🏗️ 架构权威 | 项目结构/Trait分层/SOLID评审/竞品对比 |
| **[AGENTS.md](../AGENTS.md)** | 🤖 Agent 协作 | 开发规范 + Top 10 陷阱 + 算法 SOP |
| **[MEMORY.md](../MEMORY.md)** | 🧠 项目记忆 | 语法陷阱 + 关键决策记录 |
| **Design Docs** (`design/*.md`) | 📐 模块设计 | 各算法模块详细设计规范 |
| **Reference** (`reference/*.md`) | 📚 竞品调研 | C++/Go/Java/Python/Rust 图库分析 |

### 外部参考

| 库 | 语言 | 借鉴点 | 参考价值 |
|----|:----:|--------|:-------:|
| petgraph | Rust | 所有权安全/Index-based 节点 | ⭐⭐⭐⭐⭐ 架构参考 |
| NetworkX | Python | 模块化组织/算法全面性 | ⭐⭐⭐⭐ API 参考 |
| Boost.Graph | C++ | 模板元编程/极致性能 | ⭐⭐⭐⭐ 性能参考 |
| JGraphT | Java | 接口丰富性/扩展性设计 | ⭐⭐⭐ 扩展参考 |
| LEMON (C++) | C++ | 高性能流算法实现 | ⭐⭐⭐ Flow 参考 |

---

## 9. 快速导航

### 对于新开发者

```bash
git clone https://github.com/morning-start/mbtgraph.git && cd mbtgraph
moon test                           # 全量测试 (483 tests ✅)
moon test src/algo/hamiltonian       # P5 最新模块测试 (20 tests)
moon test src/algo/euler             # 欧拉路径模块 (22 tests)
cat AGENTS.md                       # 开发规范 (Top 10 陷阱)
cat TODO.md                         # 📋 近期待办 ← 从这里开始
```

### 对于贡献者

```bash
cat CONTRIBUTING.md                  # 贡献指南
cat docs/ARCHITECTURE.md             # 架构设计 (必读)
cat docs/ROADMAP.md                 # 本文件: 远期规划
# → 选择 TODO.md 中的任务开始贡献
```

---

## 附录 A: MoonBit 语法速查 (Top 10 陷阱)

详见 [AGENTS.md §错误速查](../AGENTS.md):

| # | 陷阱 | 正确写法 | 来源 |
|---|------|---------|:-----:|
| 1 | mut self | `(self)` + 内部 `let g = self` | 编译 E3002 |
| 2 | For 元组解构 | 先绑定再 match | 编译 E3002 |
| 3 | Match 多语句 | `{ stmt; stmt }` | 编译 E3002 |
| 4 | pub struct 失败 | 核心类型必须 `pub(all)` | 编译 E4036 |
| 5 | Trait 方法未绑定 | `@core.Trait::method()` | 编译 E4021 |
| **6** | **嵌套泛型 `>>`** | **`Array[Array[T?]]`** | flow 模块实战 |
| **7** | **保留字 `fn`/`var`** | **改名或用 `let mut`** | flow 模块实战 |
| **8** | **返回值不能 ignore** | **链式赋值 `let x = func(x)`** | flow 模块实战 |
| **9** | **数组引用副作用** | **算法前深拷贝** | clique 模块实战 |
| **10** | **loop 废弃语法** | **`while true {}`** | 废弃警告 |

---

## 附录 B: 算法模块开发 SOP

详见 [AGENTS.md §算法模块开发流程](../AGENTS.md)：

```
1️⃣ 设计阶段    → brainstorming → 用户确认 → design doc
2️⃣ 基础类型    → moon.pkg + types.mbt + 数据结构     [Commit 1: feat]
3️⃣ 算法实现    → priv fn 辅助函数 + pub fn 公开 API   [Commit 2: feat]
4️⃣ 测试文件    → make_xxx + 正常/边界/属性测试         [Commit 3: test]
5️⃣ 文档        → README.md (8 大章节) + design doc    [Commit 4: docs]
6️⃣ 验证        → moon check → test (✅) → git log
```

---

> **🎯 战略总结**: mbtgraph 以 **Trait 驱动的模块化架构** 为核心竞争力，
> **v0.4.1 已完成 P5 图论核心算法扩展** (483 tests / 14 packages / 30+ algorithms)，
> **下一步**: [TODO.md](./TODO.md) 中的 CI/CD + API 冻结 + 集成测试 (v0.5.0 Ecosystem)，
> **Phase 2 的网络分析模块 (PageRank/Louvain)** 将是 v0.5.0+ 差异化突破口。
