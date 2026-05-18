---
title: "mbtgraph 开发路线图"
version: "1.0.0"
status: "active (P0-P3 完成)"
type: "roadmap"
created: "2026-05-18"
updated: "2026-05-19"
author: "morning-start"
license: "Apache-2.0"
tags: ["roadmap", "graph-algorithms", "moonbit", "trait-based"]
---

# mbtgraph 开发路线图

> **版本**: v1.0.0 | **状态**: 🎉 **P0-P3 全部完成** | **日期**: 2026-05-19

---

## 项目概览

### 当前成就

| 指标 | 数量 | 状态 |
|------|:----:|:----:|
| **算法模块** | **6 个** | ✅ 全部完成 |
| **公共 API 函数** | **~82 个** | ✅ 稳定 |
| **测试用例** | **317 个** | ✅ 100% 通过 |
| **包文档覆盖率** | **8/8 (100%)** | ✅ 完整 |
| **设计文档** | **8 份** | ✅ 完整 |
| **Git 提交** | **~23 次** | ✅ 原子分部 |
| **AGENTS.md 版本** | **v2.1.0** | ✅ 含实战经验 |

### 技术栈

```
语言:     MoonBit (native/wasm 后端)
架构:    Trait-based 分层 (GraphReadable → Writable → Directed)
存储:    8 种实现 (AdjList/Matrix/EdgeList/CSR/CSC)
测试:    双轨制 (Blackbox + Whitebox)
文档:    8 大章节标准模板
```

---

## 1. 已完成模块 ✅

### M1-M3: 基础设施层

| # | 模块 | 路径 | 测试数 | 完成日期 |
|---|------|------|:------:|:--------:|
| M1 | **核心类型 + Trait** (6 层分层) | `src/core/` | **68** | 2026-05-17 |
| M2 | **8 种图存储实现** (有向/无向/只读) | `src/storage/` | **~107** | 2026-05-17 |
| M3 | **遍历算法** (BFS/DFS/环检测/拓扑排序) | `src/algo/traversal/` | **~47** | 2026-05-18 |
| **M 小计** | | | **~222** | |

**M 层关键特性**:
- ✅ 6 层 trait 架构 (Readable/Writable/Directed/BatchReadable/EdgeIterable/Full)
- ✅ 8 种存储覆盖所有场景 (邻接表/矩阵/边集/CSR/CSC)
- ✅ 跨存储兼容性测试 (AdjList/Matrix/EdgeList × 所有算法)

---

### P0: 图生成器 ✅

> **完成日期**: 2026-05-18 | **状态**: ✅ **全部完成**

#### 功能清单

| ID | 函数 | 类别 | 说明 | 复杂度 |
|:--:|------|------|------|:------:|
| G01 | `empty_graph` | 经典 | 空图 | O(1) |
| G02 | `complete_graph` | 经典 | 完全图 K_n | O(V²) |
| G03 | `path_graph` | 经典 | 路径图 P_n | O(V) |
| G04 | `cycle_graph` | 经典 | 环形图 C_n | O(V) |
| G05 | `star_graph` | 经典 | 星形图 S_n | O(V) |
| G06 | `wheel_graph` | 经典 | 轮状图 W_n | O(V) |
| G07 | `complete_bipartite` | 经典/二分 | 完全二分图 K_{m,n} | O(V₁×V₂) |
| G08 | `grid_graph_2d` | 网格 | 2D 网格 (4 连通) | O(rows×cols) |
| G09 | `hexagonal_grid` | 网格 | 六边形网格 | O(radius²) |
| G10 | `triangular_grid` | 网格 | 三角网格 | O(size²) |
| G11 | `random_erdos_renyi` | 随机 | Erdős-Rényi G(n,p) | O(V²) |
| G12 | `random_regular` | 随机 | 正则随机图 | O(V×degree) |
| G13 | `random_tree` | 随机 | 随机树 | O(V) |
| G14 | `random_dag` | 随机 | 随机 DAG | O(V+E) |
| G15 | `random_bipartite` | 二分/随机 | 随机二分图 | O(V₁×V₂) |
| G16 | `complete_directed/undirected` | 辅助 | 有向/无向完全图 | O(V²) |

**统计**: **16 个函数** | **4 大类别** (经典/网格/随机/二分)

#### 测试覆盖

| 类别 | 测试数 | 内容 |
|------|:-----:|------|
| 经典图生成 | 24 | 每种图类型 3+ tests (空/正常/属性验证) |
| 特殊图生成 | 12 | 网格/六边形/三角拓扑验证 |
| 随机图生成 | 12 | 参数边界/概率分布/确定性 |
| 二分图专用 | 8 | 结构验证/节点分组正确性 |
| **合计** | **56** | **100% 通过** ✅ |

---

### P1: 最短路径 ✅

> **完成日期**: 2026-05-18 | **状态**: ✅ **全部完成**

#### 功能清单

| ID | 算法 | 复杂度 | 特性 | Trait 约束 |
|:--:|------|:------:|------|-----------|
| S01 | **Dijkstra** | O((V+E)log V) | 非负权，自建 BinaryHeap 优化 | GraphReadable |
| S02 | **Dijkstra Targeted** | O((V+E)log V) | 提前终止优化版，仅到目标 | GraphReadable |
| S03 | **Bellman-Ford** | O(VE) | 支持负权边，自动检测负环 | GraphReadable |
| S04 | **Floyd-Warshall** | O(V³) | 全源最短路径，支持负权 | GraphReadable |
| S05 | **BinaryHeap** (priv) | O(log N) | 私有实现，仅供 Dijkstra 使用 | — |

#### 结果类型

```moonbit
// 单源最短路径结果
pub(all) struct ShortestPathResult {
  distances : Array[Double?>       // None = 不可达
  parents : Array[@core.NodeId?]    // 路径重建
}
// 方法: distance_to() / is_reachable() / reachable_count() / path_to()

// 全源最短路径结果
pub(all) struct FloydWarshallResult {
  distances : Array[Array<Double?>>
  next : Array[Array[@core.NodeId?]>
}
// 方法: distance(from, to) / path(from, to)
```

#### 测试覆盖

| 类别 | 测试数 | 内容 |
|------|:-----:|------|
| Dijkstra 基础 | 9 | 距离/可达性/路径重建/空图/单节点/不可达 |
| Dijkstra targeted | 2 | 同目标/正常路径提前终止 |
| Bellman-Ford | 6 | 与 Dijkstra 一致/负权边/负环检测/空图/源不存在/路径重建 |
| Floyd-Warshall | 5 | 距离矩阵/路径重建/空图/负环检测/自距离为 0 |
| **跨存储兼容** | **6** | AdjList/Matrix/EdgeList × 3 种算法 |
| **合计** | **32** | **100% 通过** ✅ |

---

### P2: 最小生成树 + 连通性 ✅

> **完成日期**: 2026-05-18 | **状态**: ✅ **全部完成**

#### 2.1 MST 最小生成树

| ID | 组件 | 复杂度 | 适用场景 | Trait 约束 |
|:--:|------|:------:|---------|-----------|
| T01 | **Kruskal** | O(E log E) | 稀疏图 (E << V²) | GraphReadable + EdgeIterable |
| T02 | **Prim** | O(V²) 数组版 | 稠密图或增量构建 | GraphReadable |
| T03 | **Union-Find** (priv) | O(α(n)) 均摊 | 并查集数据结构，供 Kruskal 使用 | — |

##### MST 结果类型

```moonbit
pub(all) struct MstResult {
  total_weight : Double                                    // MST 总权重
  edges : Array[(@core.NodeId, @core.NodeId, Double)>       // MST 边列表
}
// 方法: edge_count() / has_edge(u, v)
```

#### 2.2 连通性分析

| ID | 算法 | 复杂度 | 类型 | Trait 约束 |
|:--:|------|:------:|------|-----------|
| T04 | **ConnectedComponents** | O(V+E) | 无向连通分量 (BFS/DFS 提取) | GraphReadable |
| T05 | **Tarjan SCC** | O(V+E) | 强连通分量 (DFS + lowlink stack) | GraphDirected |
| T06 | **Kosaraju SCC** | O(V+E) | 强连通分量 (双 DFS) | GraphDirected |

##### 连通性结果类型

```moonbit
pub(all) struct ConnectedComponents {
  count : Int
  components : Array[Array[@core.NodeId]>   // 每个分量一组节点
}

pub(all) struct StronglyConnectedComponents {
  count : Int
  components : Array[Array[@core.NodeId]>
}
```

#### 测试覆盖

| 类别 | 测试数 | 内容 |
|------|:-----:|------|
| Kruskal | 7 | 权重/边数/预期边/重边排除/空图/单节点/不连通森林 |
| Prim | 5 | 权重/边数/不同根一致性/空图/根不存在 |
| MST 一致性 | 1 | Kruskal vs Prim 相同权重和边数 |
| ConnectedComponents | 7 | 空图/单节点/完全图/不连通/森林/属性验证 |
| Tarjan SCC | 7 | 简单DAG/环形/完整图/空图/单节点/Kosaraju一致性 |
| Kosaraju SCC | 7 | 同上场景交叉验证 |
| **跨存储兼容** | **3** | AdjList/Matrix/EdgeList × CC/Tarjan/Kosaraju |
| **合计** | **37** | **100% 通过** ✅ |

---

### P3: 网络流 ✅

> **完成日期**: 2026-05-19 | **状态**: ✅ **全部完成**

#### 功能清单

| ID | 组件 | 复杂度 | 说明 |
|:--:|------|:------:|------|
| F01 | **FlowNetwork** (独立类型) | O(1) 创建 | 流网络数据结构（容量矩阵 + 流量矩阵）|
| F02 | **Edmonds-Karp** | O(VE²) | BFS 增广路最大流算法 |

##### FlowNetwork 设计决策

```moonbit
// 独立于 core.Graph trait 的流网络类型
pub(all) struct FlowNetwork {
  node_count : Int                    // 节点数
  capacity : Array[Array[Double]]     // 容量矩阵 capacity[u][v]
  flow : Array[Array[Double]]         // 流量矩阵 flow[u][v]
}
// 方法: FlowNetwork::new(n) / add_edge(from, to, cap)
```

**为什么独立类型？**
- 流网络语义特殊（残差图/反向边/增广路），不适合强制适配 Graph trait
- 矩阵表示 O(1) 访问，适合密集流网络场景
- 自动管理反向边（初始容量=0），对外透明

##### Edmonds-Karp 算法内部组件

| 组件 | 可见性 | 功能 |
|------|:------:|------|
| `ek_bfs()` | priv | BFS 在残差图中寻找最短增广路径 |
| `ek_find_path_bottleneck()` | priv | 沿 parent 数组计算瓶颈值 |
| `ek_augment()` | priv | 流量增广（正向+bottleneck，反向-bottleneck）|
| `deep_copy_matrix()` | priv | 深拷贝保证纯函数语义（输入不被修改）|

##### 最大流结果类型

```moonbit
pub(all) struct MaxFlowResult {
  max_flow : Double              // 最大流量值
  flow_matrix : Array[Array[Double?]>  // 流量矩阵 (None = 无流量)
}
```

#### 测试覆盖

| 类别 | 测试数 | 内容 |
|------|:-----:|------|
| FlowNetwork 基础 | 5 | 空网络/正常创建/添加边/越界/自环 |
| Edmonds-Karp 简单 | 3 | 两节点网络 (max_flow=10) / 矩阵大小 / 流量存在性 |
| Edmonds-Karp 经典 | 2 | 4 节点多路径 (max_flow=5) / 矩阵维度 |
| Edmonds-Karp 复杂 | 1 | CLRS 6 节点网络 (max_flow=23) |
| 边界情况 | 5 | 空图/source=sink/负索引/越界/无路径 |
| 属性验证 | 1 | 结果不可变性（原网络未被修改）|
| **合计** | **17** | **100% 通过** ✅ |

---

## 2. 项目总览仪表盘

### 代码产出统计

| 层级 | 模块 | 源文件 | 代码行 | 公共 API | 测试 | Git 提交 |
|------|------|:-----:|:-----:|:------:|:-----:|:-------:|
| **基础设施** | Core | 4 | ~400 | 20+ types/traits | 68 | 3 |
| | Storage | 12 | ~2000 | 8 structs + 8 converters | ~107 | 5 |
| | Traversal | 4 | ~500 | 4 functions | ~47 | 2 |
| **P0** | Generators | 5 | ~600 | 16 functions | 56 | 1 |
| **P1** | Shortest Path | 6 | ~550 | 5 functions | 32 | 1 |
| **P2** | MST | 5 | ~350 | 2 functions | 16 | 1 |
| | Connectivity | 6 | ~450 | 3 functions | 21 | 1 |
| **P3** | Flow | 5 | ~370 | 2 functions | 17 | 4 |
| **文档** | Design Docs | 8 | ~1800 | — | — | 3 |
| | READMEs | 8 | ~1250 | — | — | 2 |
| **总计** | **~69** | **~8270** | **~82** | **~317** | **~23** |

### 测试分布

```
Core:        ████████████████████ 68 (21%)
Storage:     ████████████████████████████████ 107 (34%)
Traversal:   ██████████████ 47 (15%)
Generators:  █████████████████████ 56 (18%)
ShortestPath:████████████████ 32 (10%)
MST:         ██████████ 16 (5%)
Connectivity:███████████████ 21 (7%)
Flow:        ██████████ 17 (5%)
─────────────────────────────────────
Total:       ████████████████████████████████████████ 317 tests (100%) ✅
```

### 文档覆盖

| 模块 | README | Design Doc | 总计 |
|------|:-----:|:----------:|:----:|
| core | ✅ | — | ✅ |
| storage | ✅ | ✅ survey | ✅ |
| traversal | ✅ | ✅ design | ✅ |
| generators | ✅ | ✅ design | ✅ |
| shortest_path | ✅ | ✅ design | ✅ |
| mst | ✅ | ✅ design (shared) | ✅ |
| connectivity | ✅ | ✅ design (shared) | ✅ |
| flow | ✅ | ✅ design | ✅ |
| **覆盖率** | **8/8** | **7/7** | **100%** ✅ |

---

## 3. 待办需求 (Backlog)

### P4 — 图匹配 🔥 推荐下一步

**目标**: 提供二分图和一般图的最大匹配能力，是实际应用中需求最高的算法类别之一。

#### 需求列表

| ID | 需求 | 说明 | 复杂度 | 状态 |
|:--:|------|------|:-----:|:----:|
| MT01 | **二分图最大匹配 (Hungarian)** | 匈牙利算法 O(VE) | 中 | ⬜ 待开发 |
| MT02 | **一般图最大匹配 (Edmonds)** | 花开花缩 O(V³) | 高 | ⬜ 待开发 |
| MT03 | **最大流解二分图匹配** | 复用 Edmonds-Karp | 低 | ⬜ 待开发 |
| MT04 | **MatchingResult 类型** | { matching_edges, cardinality } | 低 | ⬜ 待开发 |
| MT05 | 测试 | 完全二分图/K_{3,3}/ Petersen 图等 | 中 | ⬜ 待开发 |

**技术要点**:
-Hungarian 算法相对简洁，适合作为首个匹配算法
- 可复用 P3 的 Edmonds-Karp（二分图匹配可归约为最大流）
- 一般图匹配的 Edmonds 花开花缩较复杂，可作为进阶目标
- 包路径: `src/algo/matching/`

---

### P5 — 图着色 🎨

**目标**: 提供图的顶点着色能力，解决调度/寄存器分配等问题。

#### 需求列表

| ID | 需求 | 说明 | 复杂度 | 状态 |
|:--:|------|------|:-----:|:----:|
| CL01 | **贪心着色** | Welch-Powell 优化 | 低 | ⬜ 待开发 |
| CL02 | **回溯精确着色** | DSatur 启发式 | 中 | ⬜ 待开发 |
| CL03 | **双色判定** | 二分图判定 (BFS) | 低 | ⬜ 待开发 |
| CL04 | **ColoringResult 类型** | { colors, chromatic_number } | 低 | ⬜ 待开发 |
| CL05 | 测试 | 平面图/ Petersen/ 完全图等 | 中 | ⬜ 待开发 |

**技术要点**:
- 图着色是 NP-Complete 问题（k≥3 时）
- 贪心算法近似比 ≤ Δ(G)+1（Δ 为最大度）
- 平面图四色定理（特殊情况的精确算法）

---

### P6 — 欧拉路径 🔄

**目标**: 提供欧拉回路/路径判定和构造能力。

#### 需求列表

| ID | 需求 | 说明 | 复杂度 | 状态 |
|:--:|------|------|:-----:|:----:|
| EU01 | **欧拉回路判定** | 所有顶点度为偶数 | 低 | ⬜ 待开发 |
| EU02 | **欧拉路径判定** | 恰好 0 或 2 个奇度顶点 | 低 | ⬜ 待开发 |
| EU03 | **Hierholzer 算法** | O(E) 构造欧拉回路 | 中 | ⬜ 待开发 |
| EU04 | **EulerResult 类型** | { path, is_circuit } | 低 | ⬜ 待开发 |
| EU05 | 测试 | 完全图 K_n (n odd)/ 多笔画问题 | 中 | ⬜ 待开发 |

**技术要点**:
- Hierholzer 是线性时间算法，实现简洁
- 应用场景：邮递员问题（Chinese Postman）、DNA 序列组装
- 与 P4（匹配）结合可解决中国邮递员问题

---

### P7 — 哈密顿路径 / TSP 🌟

**目标**: 提供 NP-Hard 问题的精确和启发式算法。

#### 需求列表

| ID | 需求 | 说明 | 复杂度 | 状态 |
|:--:|------|------|:-----:|:----:|
| HM01 | **回溯哈密顿路径** | O(N!) 精确解 | 中 | ⬜ 待开发 |
| HM02 | **动态规划 TSP** | O(N²2^N) 精确解（Held-Karp）| 高 | ⬜ 待开发 |
| HM03 | **最近邻启发式** | O(N²) 近似解 | 低 | ⬜ 待开发 |
| HM04 | **2-opt / 3-opt 改进** | 局部搜索优化 | 中 | ⬜ 待开发 |
| HM05 | **TSPResult 类型** | { tour, cost, is_optimal } | 低 | ⬜ 待开发 |
| HM06 | 测试 | TSPLIB 小实例/ 对称/非对称 | 中 | ⬜ 待开发 |

**技术要点**:
- TSP 是最著名的 NP-Hard 问题之一
- 精确算法仅适用于 N≤20（动态规划）或 N≤30（分支限界）
- 启发式算法适用于大规模实例（N>100）
- 可与 P6（欧拉路径）形成对比（P vs NP-complete）

---

## 4. 工程化待办

### CI/CD 自动化 🔥 高优先级

| 任务 | 说明 | 工具 | 优先级 |
|------|------|------|:-----:|
| **GitHub Actions** | 自动化流水线: fmt → check → test → coverage | GitHub Actions | 🔥 **高** |
| **测试覆盖率门禁** | coverage < 90% 时阻止合并 | lcov / codecov | ⭐⭐ 中 |
| **多后端测试** | native + wasm 双后端验证 | moon build | ⭐⭐ 中 |
| **Release 自动化** | tag 触发自动构建 + 发布 | GitHub Release | ⭐ 低 |

### 性能基准测试

| 任务 | 说明 | 优先级 |
|------|------|:-----:|
| **Benchmark 套件** | 各存储/各算法在不同规模下的性能对比 | ⭐⭐ 中 |
| **规模梯度测试** | V=10/100/1000/10000 的运行时间和内存占用 | ⭐⭐ 中 |
| **可视化报告** | 生成性能图表（类似 Python benchmark）| ⭐ 低 |

### API 稳定性与发布

| 任务 | 说明 | 优先级 |
|------|------|:-----:|
| **v0.1.0 API 冻结** | 锁定当前公共 API，开始 semver 管理 | ⭐⭐ 中 |
| **moonpkg 发布** | 发布到 MoonBit 包注册中心 | 🔥 **高** |
| **CHANGELOG.md** | 维护版本变更历史 | ⭐⭐ 中 |
| **CONTRIBUTING.md** | 贡献指南（开发规范/提交流程）| ⭐ 低 |

### 社区与生态

| 任务 | 说明 | 优先级 |
|------|------|:-----:|
| **示例项目集合** | examples/: 最短路径导航/MST 网络/社交网络分析 | ⭐ 低 |
| **教程文档系列** | tutorials/: 从安装到实现完整项目 | ⭐ 低 |
| **博客/技术文章** | "用 MoonBit 实现图算法" 系列 | ⭐ 低 |
| **VS Code 插件** | 语法高亮/代码片段/图可视化预览 | ⭐ 低 |

---

## 5. 依赖关系图

```
已完成 (✅):
═══════════════════════════════════════════════════
M1 Core ─┬─ M2 Storage ── M3 Traversal
          │                 │
          └─────────────────┘
                    ↓
          ┌─────────────────────────────────────┐
          │                                     │
    P0 Generators ←── 测试基建依赖 ──→ P1 ShortestPath
          │                         │           │
          │                         ↓           │
          │                   P2 MST+Conn       │
          │                         │           │
          └─────────────────────────→ P3 Flow ←┘
═══════════════════════════════════════════════════

待开发 (⬜):
═══════════════════════════════════════════════════
P4 Matching ←── 可复用 P3 Flow ──→ P6 Euler (中国邮递员)
     │
     ↓
P5 Coloring (NP-Complete)
     │
     ↓
P7 Hamilton/TSP (NP-Hard)
═══════════════════════════════════════════════════
```

---

## 6. 版本里程碑

| 版本 | 内容 | 目标日期 | 状态 |
|------|------|:--------:|:----:|
| **v0.1.0** | M1-M3 + P0-P3 基础设施 + 核心算法 | 2026-05-19 | ✅ **当前** |
| **v0.2.0** | P4 图匹配 + CI/CD + moonpkg 发布 | 2026-05-26 | 🔄 规划中 |
| **v0.3.0** | P5 图着色 + P6 欧拉路径 + 基准测试 | 2026-06-09 | ⬜ 远期 |
| **v0.4.0** | P7 TSP + 性能优化 + 示例项目 | 2026-06-23 | ⬜ 远期 |
| **v1.0.0** | API 稳定 + 完整文档 + 社区生态 | 2026-Q3 | 🌟 愿景 |

---

## 7. 更新日志

| 日期 | 版本 | 操作 | 说明 |
|------|:----:|------|------|
| 2026-05-18 | v0.0.1 | 创建 | 初始化路线图，定义 P0-P3 需求 |
| 2026-05-18 | v0.1.0-alpha | **P0 完成** | 16 个图生成器函数, 56 tests |
| 2026-05-18 | v0.1.0-beta | **P1-P2 完成** | 最短路径(32) + MST+连通性(37), 69 tests |
| **2026-05-19** | **v0.1.0** | **🎉 P3 完成 + Roadmap 更新** | 网络流(17), **P0-P3 全部完成**, 317 tests, AGENTS v2.1.0 |

---

## 8. 参考文档

### 内部文档

| 文档 | 路径 | 内容 |
|------|------|------|
| **AGENTS.md** | `/AGENTS.md` | Agent 协作配置（含 Top 10 陷阱）|
| **MEMORY.md** | `/MEMORY.md` | 项目主记忆（15 条语法陷阱 + 15 条关键决策）|
| **Design Docs** | `/docs/design/*.md` (8 份) | 各模块设计规范 |
| **Reference** | `/docs/reference/*.md` (8 份) | 竞品库调研（C++/Go/Java/Python/Rust）|

### 外部参考

| 库 | 语言 | 参考价值 |
|----|:----:|---------|
| petgraph | Rust | 所有权安全图库（架构参考）|
| NetworkX | Python | 算法全面性（API 设计参考）|
| Boost.Graph | C++ | 模板元编程极致性能 |
| JGraphT | Java | 接口丰富性（扩展性参考）|

---

## 9. 快速启动指南

### 对于新开发者

```bash
# 1. 克隆仓库
git clone https://github.com/morning-start/mbtgraph.git
cd mbtgraph

# 2. 安装 MoonBit (如未安装)
# 参考: https://www.moonbitlang.com/

# 3. 运行测试
moon test                # 全量测试 (317 tests)
moon test src/algo/flow  # 单模块测试

# 4. 查看文档
cat src/algo/flow/README.md  # 最新模块文档
cat AGENTS.md                      # 开发规范
```

### 对于贡献者

```bash
# 1. 阅读 CONTRIBUTING.md (待创建)
# 2. Fork 并创建特性分支
git checkout -b feature/xxx

# 3. 开发并测试
moon fmt && moon info      # 格式化 + 更新接口
moon test                  # 确保全量通过

# 4. 提交（遵循 Conventional Commits）
git add src/
git commit -m "feat(module): description"

# 5. 创建 PR
# 确保 CI 通过 (待搭建)
```

---

## 附录 A: MoonBit 语法速查 (Top 10 陷阱)

详见 [AGENTS.md §错误速查](../AGENTS.md)，高频陷阱：

| # | 陷阱 | 正确写法 |
|---|------|---------|
| 1 | mut self | `(self)` + 内部 `let g = self` |
| 2 | For 元组解构 | 先绑定再 match |
| 3 | Match 多语句 | `{ stmt; stmt }` （不用逗号）|
| 4 | pub struct 失败 | 核心类型必须 `pub(all)` |
| 5 | Trait 方法未绑定 | 必须完全限定名 `@core.Trait::method()` |
| **6** | **嵌套泛型 `>>`** | **`Array[Array[T?]]` （非 `T?>>`)** ⚠️ |
| **7** | **保留字 `fn`/`var`** | **改名或用 `let mut`** ⚠️ |
| **8** | **返回值不能 ignore** | **链式赋值 `let x = func(x)`** ⚠️ |
| **9** | **数组引用副作用** | **算法前深拷贝** |
| **10** | **loop 废弃语法** | **`while true {}`** |

---

## 附录 B: 算法模块开发流程标准模板

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

> **🎉 恭喜！你正在阅读的是一个功能完整、测试充分、文档齐全的 MoonBit 图算法库！**
>
> **下一步**: 选择 **P4 图匹配** 开始新模块开发，或选择 **CI/CD** 提升工程质量。
