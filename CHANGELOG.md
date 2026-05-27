# 变更日志

本项目的所有重要变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)，
本项目遵循 [语义化版本](https://semver.org/spec/v2.0.0.html)规范。

## [v0.11.0] - 2026-05-26

### 新增
- 📊 **数据交换与可视化模块** (全新 `src/io/` 模块, 42 测试用例):
  - **DOT 格式读写**：泛型 `write_dot` 序列化、`parse_dot_into` 递归下降解析器，支持 `digraph`/`graph`、`[weight=...]` 属性、`//`/`#`/`/* */` 注释 (20 tests)
  - **JSON 格式读写**：`graph_to_json` (compact/pretty)、`parse_json_into` 完整 JSON 解析器，`{ mbtgraph, directed, nodes, edges }` 格式 (12 tests)
  - **图统计工具**：`basic_stats`、`degree_distribution`、`connectivity_stats` 泛型图统计 (10 tests)
- 🔗 全部 I/O 函数兼容 8 种存储类型（AdjList/Matrix/CSR/EdgeList 有向/无向变体）

### 改进
- 全量测试从 588 增长至 **630**（+42），无回归
- MEMORY.md 更新包结构，新增 I/O 模块行
- AGENTS.md 项目统计更新

## [v0.10.0] - 2026-05-26

### 新增
- 🚀 **社交网络分析套件** (3 大模块, 105 测试用例):
  - **PageRank**：幂法迭代算法，支持 damping factor、dangling nodes 处理和个人化 PageRank (15 tests)
  - **中心性分析**：度中心性、介数中心性（Brandes 算法）、接近中心性、特征向量中心性（幂法迭代）(45 tests)
  - **社区检测**：Louvain 贪心模块度优化算法、标签传播异步迭代算法 (35 tests)
- 🔗 跨模块集成测试 (10 tests)：验证 PageRank+中心性+社区检测联动，覆盖 AdjList/Matrix/CSR/EdgeList 全部存储类型

### 改进
- 算法模块数从 12 扩展至 **15**，算法总数从 30+ 扩展至 **~38**
- 全量测试从 551 增长至 **588**，无回归
- AGENTS.md 升级至 v3.1.0，MEMORY.md/README.mbt.md 同步更新

## [未发布]

### 新增
- 📋 Sprint任务体系重构：TODO.md采用4-Sprint格式，聚焦v1.0.0生产就绪目标
- 📝 文档更新规范体系成熟：UPDATE_GUIDE.md + 自动化检查脚本全面应用
- 🔧 AGENTS.md升级至v2.4.0（Sprint系统+文档规范化）
- 📊 MEMORY.md新增3条关键决策记录

### 改进
- ROADMAP.md聚焦v1.0.0里程碑，明确生产就绪标准
- TODO.md从线性列表升级为Sprint任务体系
- 项目文档版本号统一至基准

---

## [0.9.0] - 2026-05-22

### 🎯 新增 - P5-E: Hamiltonian 哈密顿路径/TSP 算法 ✅
**路径**: `src/algo/hamiltonian/` | **测试**: **20**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| 哈密顿快速检查 | O(V+E) | |
| 哈密顿路径回溯 | O(V!) | |
| 哈密顿回路回溯 | O(V!) | |
| TSP 最近邻启发式 | O(V²) | |
| TSP Held-Karp 精确解 | O(2^V·V²) (V≤12) |

**提交记录**:
- `feat(hamiltonian)`: 添加基础类型和包配置
- `feat(hamiltonian)`: 实现哈密顿路径/回路和 TSP 算法

---

## [0.8.0] - 2026-05-22

### 🔗 新增 - P5-D: Clique 最大团/独立集/顶点覆盖 ✅
**路径**: `src/algo/clique/` | **测试**: **14**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| Bron-Kerbosch 最大团 | O(3^{V/3}) | |
| 最大独立集 (补图法) | O(3^{V/3}) | |
| 最小顶点覆盖 (精确+近似) | 精确 O(3^{V/3}) / 近似 O(V²) | |

**提交记录**:
- `feat(clique)`: add base types and package configuration
- `feat(clique)`: 实现 Bron-Kerbosch 最大团、独立集、顶点覆盖算法
- `test(clique)`: 添加完整测试套件 (14 tests)

---

## [0.7.0] - 2026-05-22

### 🎨 新增 - P5-C: Coloring 图着色算法 ✅
**路径**: `src/algo/coloring/` | **测试**: **21**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| Greedy 贪心着色 | O(V²) | |
| Welch-Powell 着色 | O(V²+VE) | |
| DSATUR 启发式 | O(V²+kV) | |
| 回溯精确着色 | O(k^V) | |

**提交记录**:
- `feat(coloring)`: add base types and package configuration
- `feat(coloring)`: implement greedy/Welsh-Powell/DSATUR/exact chromatic algorithms with tests
- `docs(coloring)`: add comprehensive README and documentation comments

---

## [0.6.0] - 2026-05-22

### ✂️ 新增 - P5-B: Cutpoints 割点与桥检测 ✅
**路径**: `src/algo/cutpoints/` | **测试**: **15**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| Tarjan 割点检测 | O(V+E) | |
| Tarjan 桥检测 | O(V+E) | |

**提交记录**:
- `feat(cutpoints)`: add base types and package configuration
- `feat(cutpoints)`: 实现 Tarjan 割点与桥检测算法
- `test(cutpoints)`: 添加完整测试套件

---

## [0.5.0] - 2026-05-23

### 🎉 重大新增 - P5 图论核心算法扩展 (5 子模块, 92 tests, 30+ 算法)

#### P5-A: Euler 欧拉路径/回路 ✅
**路径**: `src/algo/euler/` | **测试**: **22**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| Hierholzer 无向图欧拉回路 | O(E) | |
| Hierholzer 有向图欧拉路径 | O(E) | |
| is_eulerian 判定 | O(V) | |

#### P5-B: Cutpoints 割点与桥 ✅
**路径**: `src/algo/cutpoints/` | **测试**: **15**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| Tarjan 割点检测 | O(V+E) | |
| Tarjan 桥检测 | O(V+E) | |

#### P5-C: Coloring 图着色 ✅
**路径**: `src/algo/coloring/` | **测试**: **21**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| Greedy 贪心着色 | O(V²) | |
| Welch-Powell 着色 | O(V²+VE) | |
| DSATUR 启发式 | O(V²+kV) | |
| 回溯精确着色 | O(k^V) | |

#### P5-D: Clique 团/独立集/顶点覆盖 ✅
**路径**: `src/algo/clique/` | **测试**: **14**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| Bron-Kerbosch 最大团 | O(3^{V/3}) | |
| 最大独立集 (补图法) | O(3^{V/3}) | |
| 最小顶点覆盖 (精确+近似) | 精确 O(3^{V/3}) / 近似 O(V²) | |

#### P5-E: Hamiltonian 哈密顿/TSP ✅
**路径**: `src/algo/hamiltonian/` | **测试**: **20**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| 哈密顿快速检查 | O(V+E) | |
| 哈密顿路径回溯 | O(V!) | |
| 哈密顿回路回溯 | O(V!) | |
| TSP 最近邻启发式 | O(V²) | |
| TSP Held-Karp 精确解 | O(2^V·V²) (V≤12) | |

### 统计数据
- **总测试数**: 483 (从 391 增加 92, +23.5%)
- **包数量**: 14 个 (从 9 增加 5)
- **算法总数**: 30+ (从 ~18 增加 12+)
- **代码行数**: ~11,040 行

### 文档更新
- AGENTS.md 升级至 v2.2.0 (P5模块完整信息)
- MEMORY.md 添加P5决策记录和最新测试数据
- README.mbt.md 更新至v0.5.0内容
- Git Tags: v0.5.0 → v0.6.0 → v0.7.0 → v0.8.0 → v0.9.0

---

## [0.4.0] - 2026-05-19

### 🔥 重大新增 - P4 匹配 + Dinic 双算法

#### P4: Matching 图匹配 ✅
**路径**: `src/algo/matching/` | **测试**: **21**

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| Hungarian 匈牙利算法 | O(VE) | |

#### Flow: Dinic 最大流算法 ✨
**路径**: `src/algo/flow/dinic.mbt` | **测试**: **16** (含3个EK一致性验证)

| 组件 | 算法 | 复杂度 |
|------|------|:-----:|
| Dinic 分层阻塞流 | O(E√V) | 比 EK 快一个数量级 |

### 统计数据
- **总测试数**: 391 (从 317 增加 74, +23.3%)
- **包数量**: 9 个 (增加 matching 模块)
- **网络流双算法并存**: EK 教学友好 / Dinic 性能更优

---

## [0.3.0] - 2026-05-19

### 重大变更 - 完整的算法库 (P0-P3 ✅)

#### 核心模块 - [0.1.0]
**状态**: 🟢 稳定基础
**提交**: 7 次（1 feat, 4 refactor, 2 docs）

**变更**:
- `feat`: 添加图数据结构核心模块（类型、trait、错误处理）
- `refactor`: 优化代码结构、调整可见性、移除冗余实现
- `refactor`: 修复 trait 可见性和类型定义
- `docs`: 添加完整的 README 文档

**核心组件**:
- `NodeId`、`Node`、`Edge` 类型
- `GraphReadable`、`GraphWritable`、`GraphDirected` trait
- `GraphError` 错误类型

**稳定性**: 生产就绪，基础 API 稳定

---

#### 存储模块 - [0.2.0]
**状态**: 🟢 功能丰富且稳定
**提交**: 13+ 次（5 feat, 3 refactor, 1 fix, 3 docs, 1 chore）

**与 0.1.x 的破坏性变更**:
- 重大重构：将单体存储拆分为专门化实现
- 新存储格式：CSR/CSC 用于稀疏图
- 增强的转换系统，支持双向转换

**变更**:
- `feat`: 完整的图存储实现（AdjList、Matrix、EdgeList、CSR、CSC）
- `feat`: 为所有存储类型添加无向变体
- `feat`: 实现 GraphDirected trait 并重构转换逻辑
- `feat`: 添加 CSC 结构和转换函数
- `refactor`: 重构存储模块，提取共享辅助函数
- `refactor`: 拆分邻接表转换器，添加有向/无向实现
- `fix`: 修复结构体可见性、Array::make 2D 初始化 bug、添加 GraphDirected 实现
- `chore`: 更新所有模块的 mbti 绑定文件

**核心组件**:
- 有向/无向邻接表（`directed_adj_list`、`undirected_adj_list`）
- 有向/无向矩阵（`directed_matrix`、`undirected_matrix`）
- 边集图（`edge_list`、`undirected_edge_list`）
- 压缩格式（`csr`、`csc`）
- 转换器系统（`converter`），支持格式转换
- 共享辅助函数（`shared_helpers`）

**测试覆盖**: 跨存储兼容性已验证

**稳定性**: 成熟实现，经过充分测试

---

#### 遍历模块 - [0.1.1]
**状态**: 🟢 完整且有文档
**提交**: 8 次（2 feat, 2 refactor, 1 test, 2 docs, 1 chore）

**与 0.1.0 的变更**:
- `feat`: 添加 BFS 和 DFS 图遍历算法
- `feat`: 添加环检测和拓扑排序工具
- `refactor`: 修复内部辅助函数可见性和公共 API 的结构体字段
- `refactor`: 移除工具函数中不必要的 pub 修饰符
- `test`: 添加完整的跨存储遍历测试套件
- `docs`: 添加 README 文档和设计文档

**核心算法**:
- 广度优先搜索（BFS）
- 深度优先搜索（DFS）
- 环检测
- 拓扑排序

**稳定性**: 经过充分测试，公共 API 干净整洁

---

#### 图生成器模块 - [0.1.1]
**状态**: 🟢 完整且已测试
**提交**: 6 次（1 feat, 1 fix, 1 test, 2 docs, 1 chore）

**与 0.1.0 的变更**:
- `feat`: 添加支持泛型 GraphWritable 的图生成器（16 个函数）
- `fix`: 修复 MoonBit 语法兼容性以通过编译
- `test`: 添加 56 个测试，验证跨存储兼容性
- `docs`: 添加包 README 和设计文档

**核心生成器**:
- 经典图：完全图、环图、路径图、星形图、轮图、二部图
- 网格图：2D/3D 网格、环面网格、六边形网格
- 随机图：Erdős–Rényi、Watts-Strogatz、Barabási–Albert
- 特殊图：树、有向无环图（DAG）

**测试覆盖**: 56 个测试，跨存储兼容性已验证

**稳定性**: 健壮、文档完善

---

#### 最短路径模块 - [0.1.0]
**状态**: 🟢 初始发布
**提交**: 4 次（1 feat, 1 test, 1 docs, 1 chore）

**变更**:
- `feat`: 添加 Dijkstra、Bellman-Ford、Floyd-Warshall 算法
- `test`: 添加 32 个测试，验证跨存储兼容性
- `docs`: 添加完整的 README 文档

**核心算法**:
- Dijkstra（非负权重）
- Bellman-Ford（负权边、负环检测）
- Floyd-Warshall（全源最短路径）

**测试覆盖**: 32 个测试，多种存储后端

**稳定性**: 完整实现，可投入使用

---

#### 最小生成树模块 - [0.1.0]
**状态**: 🟢 初始发布
**提交**: 3 次（1 feat, 1 test, 1 chore）

**变更**:
- `feat`: 添加 Kruskal 和 Prim 最小生成树算法
- `test`: 添加 16 个测试（与连通性模块共享）

**核心算法**:
- Kruskal 算法（使用并查集数据结构）
- Prim 算法（使用二叉堆优化）

**支撑数据结构**:
- 并查集（Disjoint Set Union），带路径压缩和按秩合并
- 二叉最小堆用于优先队列操作

**测试覆盖**: 16 个测试

**稳定性**: 完整实现

---

#### 连通性模块 - [0.1.0]
**状态**: 🟢 初始发布
**提交**: 5 次（1 feat, 1 test, 2 docs, 1 chore）

**变更**:
- `feat`: 添加连通分量、Tarjan SCC、Kosaraju SCC 算法
- `test`: 添加 21 个测试（与 MST 模块共享）
- `docs`: 添加设计文档

**核心算法**:
- 连通分量（无向图）
- Tarjan 强连通分量
- Kosaraju 强连通分量

**测试覆盖**: 21 个测试

**稳定性**: 完整实现

---

#### 网络流模块 - [0.1.0]
**状态**: 🟢 初始发布（最新）
**提交**: 5 次（2 feat, 1 test, 2 docs）

**变更**:
- `feat`: 添加 FlowNetwork 基础类型和结构体
- `feat`: 实现 Edmonds-Karp 最大流算法
- `test`: 添加完整测试套件（17 个测试）
- `docs`: 添加 README 和设计文档

**核心组件**:
- `FlowNetwork` 类型（独立于 Graph trait）
- Edmonds-Karp 算法（基于 BFS 的 Ford-Fulkerson 方法）
- 容量/流量矩阵管理

**设计决策**:
- 独立类型系统（不继承 GraphReadable），保证语义清晰
- 纯函数语义，使用深拷贝确保不可变性

**测试覆盖**: 17 个测试

**稳定性**: 刚实现完成，经过充分测试

---

## 项目总览

| 模块 | 版本 | 状态 | 测试数 | 核心功能 |
|------|------|------|--------|----------|
| **core** | 0.1.0 | 🟢 稳定 | - | 类型、Trait、错误 |
| **storage** | 0.2.0 | 🟢 成熟 | - | 10+ 格式、转换器 |
| **traversal** | 0.1.1 | 🟢 完整 | - | BFS、DFS、环检测、拓扑排序 |
| **generators** | 0.1.1 | 🟢 健壮 | 56 | 16 个图生成器 |
| **shortest_path** | 0.1.0 | 🟢 就绪 | 32 | Dijkstra、BF、FW |
| **mst** | 0.1.0 | 🟢 就绪 | 16 | Kruskal、Prim |
| **connectivity** | 0.1.0 | 🟢 就绪 | 21 | CC、Tarjan、Kosaraju |
| **flow** | 0.1.0 | 🟢 全新 | 17 | Edmonds-Karp |

**总测试数量**: 179+ 测试覆盖所有算法模块

**路线图进度**: ✅ P0 (核心+存储) → ✅ P1 (遍历+生成器) → ✅ P2 (最短路径+MST+连通性) → ✅ P3 (网络流)

---

## 版本指南

### 版本号含义
- **主版本** (x.0.0): 不兼容的 API 变更 / 完全重写
- **次版本** (0.x.0): 向后兼容的新功能 / 重要新增
- **修订版** (0.0.x): 向后兼容的错误修复 / 文档更新

### 触发条件
- **主版本**: 公共 API 的破坏性变更、移除功能
- **次版本**: 新算法模块、重要功能添加、重大重构
- **修订版**: 错误修复、文档改进、测试覆盖率提升

### 当前版本策略
- 核心/存储: 较高的次版本号反映成熟度和广泛的重构
- 算法模块: 从 0.1.0 开始，逐步递增修订版
- 下一次主要发布将在所有模块 API 稳定时同步版本号

---

[Unreleased]: https://github.com/morning-start/mbtgraph/compare/v0.9.0...HEAD
[0.9.0]: https://github.com/morning-start/mbtgraph/releases/tag/v0.9.0
[0.8.0]: https://github.com/morning-start/mbtgraph/releases/tag/v0.8.0
[0.7.0]: https://github.com/morning-start/mbtgraph/releases/tag/v0.7.0
[0.6.0]: https://github.com/morning-start/mbtgraph/releases/tag/v0.6.0
[0.5.0]: https://github.com/morning-start/mbtgraph/releases/tag/v0.5.0
[0.4.0]: https://github.com/morning-start/mbtgraph/releases/tag/v0.4.0
[0.3.0]: https://github.com/morning-start/mbtgraph/releases/tag/v0.3.0
