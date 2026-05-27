# mbtgraph 任务清单 (TODO)

> **最后更新**: 2026-05-27 | **当前版本**: v0.12.0 ✅ 🚀 经典算法增强
> **下次评审**: 2026-06-01（每周日）
> **下个版本**: v0.13.0 🛠️ 接口重构（详见 [重构分析](design/v0130_refactoring_analysis.md)）

---

## 📋 任务总览

### 当前冲刺：v0.10.0 社交网络分析套件

| 模块 | 状态 | 测试数 | 目标完成 | 进度 |
|------|:----:|:------:|---------|:----:|
| **PageRank** | ✅ 完成 | 15 | 2026-05-26 | **100%** |
| **中心性分析** | ✅ 完成 | 45 | 2026-05-26 | **100%** |
| **社区检测** | ✅ 完成 | 35 | 2026-05-26 | **100%** |
| **文档与集成** | ✅ 完成 | 10 | 2026-05-26 | **100%** |
| **v0.10.0 发布** | ✅ **已发布** | **105** | **2026-05-26** | **100%** |

### 版本路线图速查

```
✅ v0.9.0  P5 图论核心完成 (551 tests)
✅ v0.10.0 🔍 社交网络分析套件 (588 tests)
✅ v0.11.0 📊 数据交换与可视化 (630 tests)
✅ v0.12.0 🚀 经典算法增强 (701 tests) ← 已发布
⬜ v0.13.0 🛠️ 接口重构与 API 冻结准备
⬜ v1.0.0  🎉 正式发布
```

---

## 🎯 v0.10.0: 🔍 社交网络分析套件

> **时间范围**: 2026-05-25 → 2026-05-26 (2 天 🎉)
> **新增测试**: 105 tests (总计 588)
> **核心产出**: PageRank + 中心性分析 + 社区检测 + 集成测试

---

### 模块 A: PageRank 算法 [P0]

#### TASK-001: 创建目录结构与包配置

- [x] 创建 `src/algo/pagerank/` 目录
- [x] 创建 `moon.pkg` 配置文件（依赖 `@core`）
- [x] 创建空文件骨架:
  - `types.mbt`
  - `pagerank.mbt`
  - `pagerank_test.mbt`
- **工作量**: 0.5h
- **验收**: `moon check src/algo/pagerank` 通过（空模块编译 OK）

---

#### TASK-002: 实现核心数据结构

- [x] 定义 `PageRankResult` 结构体:
  ```moonbit
  pub(all) struct PageRankResult {
    ranks : Array[Double]      // 节点排名值
    iterations : Int           // 实际迭代次数
    converged : Bool          // 是否收敛
    damping_factor : Double   // 使用的阻尼系数
    tolerance : Double        // 收敛阈值
  }
  ```
- [x] 实现 `get_rank(self, node_id) -> Double?` 方法
- [x] 实现 `top_nodes(self, k) -> Array[(NodeId, Double)]` 方法
- [x] 实现 `total_rank(self) -> Double` 属性验证方法
- **工作量**: 1h
- **依赖**: TASK-001
- **验收**: 类型定义完整 + 辅助方法可调用

---

#### TASK-003: 实现 PageRank 幂法迭代算法

- [x] 核心函数签名:
  ```moonbit
  pub fn pagerank[G : @core.GraphReadable](
    graph : G,
    damping_factor : Double,   // 默认 0.85
    max_iterations : Int,       // 默认 100
    tolerance : Double          // 默认 1e-6
  ) -> PageRankResult
  ```
- [x] 初始化阶段: 均匀分布 rank = 1/N
- [x] 迭代公式实现:
  ```
  PR(v) = (1-d)/N + d * Σ(PR(u)/out_degree(u))  for u ∈ neighbors(v)
  ```
- [x] Dangling nodes 处理（无出边节点均匀分配）
- [x] 收敛判断: ||PR_new - PR_old||∞ < ε
- [x] 个人化 PageRank 可选支持（personalization vector）
- **复杂度**: O(kE)，k 通常 < 50
- **代码量**: ~120 行
- **工作量**: 3h
- **依赖**: TASK-002
- **验收**: 简单图/星形图/完全图结果正确

---

#### TASK-004: 编写 PageRank 测试套件 (15 tests)

| 分类 | 数量 | 测试项 |
|------|:----:|--------|
| 基础功能 | 5 | 简单图正确性 / 星形图 / 完全图 / 单节点图 / 空图 |
| 参数验证 | 3 | damping factor 范围(0<d<1) / max_iter 截断 / 收敛阈值敏感度 |
| 属性验证 | 4 | rank 总和 ≈ 1 / 对称图均匀分布 / dangling node 处理 / 不可变性 |
| 性能基准 | 3 | 100节点<100ms / 1000节点<1s / 收敛迭代数合理 |
| **合计** | **15** | |

- **工作量**: 2h
- **依赖**: TASK-003
- **验收**: `moon test src/algo/pagerank` 全通过 + 覆盖率 ≥ 90%

---

#### TASK-005: 编写 PageRank 文档

- [x] `src/algo/pagerank/README.md`:
  - API 使用示例（3 个典型场景）
  - 参数说明表（damping/max_iter/tolerance）
  - 时间/空间复杂度
  - 与 NetworkX 对比说明
- [x] `docs/design/pagerank_design.md`:
  - 算法数学原理（含公式）
  - 设计决策记录
  - Dangling nodes 处理策略
- **工作量**: 1.5h
- **依赖**: TASK-004
- **验收**: 示例代码可直接运行 + 公式正确

---

### 模块 B: 中心性分析 [P0]

#### TASK-006: 创建目录结构与类型定义

- [x] 创建 `src/algo/centrality/` 目录
- [x] 创建 `moon.pkg`（依赖 `@core`）
- [x] 定义通用结果类型:
  ```moonbit
  pub(all) struct CentralityResult {
    scores : Array[Double]
    normalized : Bool
  }
  ```
- [x] 创建文件骨架:
  - `degree_centrality.mbt`
  - `betweenness_centrality.mbt`
  - `closeness_centrality.mbt`
  - `eigenvector_centrality.mbt`
  - `centrality_test.mbt`
- **工作量**: 1h
- **验收**: 目录结构完整 + 可编译

---

#### TASK-007: 实现度中心性 (Degree Centrality)

- [x] 函数签名:
  ```moonbit
  pub fn degree_centrality[G : @core.GraphReadable](
    graph : G,
    mode : DegreeMode  // In/Out/Total
  ) -> CentralityResult
  ```
- [x] 有向图支持: in_degree / out_degree / total_degree 三种模式
- [x] 归一化: C(v) = degree(v) / (N-1)
- [x] 无向图简化: 直接使用 degree
- **复杂度**: O(V+E)
- **代码量**: ~60 行
- **工作量**: 1h
- **依赖**: TASK-006
- **验收**: 星形图中心节点得分最高

---

#### TASK-008: 实现介数中心性 (Betweenness Centrality)

- [x] 使用 Brandes 算法（O(VE) 比朴素 O(V³) 快）
- [x] 函数签名:
  ```moonbit
  pub fn betweenness_centrality[G : @core.GraphReadable](
    graph : G,
    normalized : Bool  // 默认 true
  ) -> CentralityResult
  ```
- [x] 关键步骤:
  1. 对每个节点 s 执行 BFS（或 Dijkstra 加权）
  2. 计算最短路径计数 σ(s,t)
  3. 依赖累积: δ(s,t|v) = (σ_sv/σ_st) * (1 + Σ δ(s,w|w))
  4. 归一化: 2/((N-1)(N-2)) 无向图
- [x] 支持有向/无向图
- **复杂度**: O(VE)
- **代码量**: ~150 行
- **工作量**: 4h
- **依赖**: TASK-006
- **验收**: 桥节点介数最高 + 与手动计算一致

---

#### TASK-009: 实现接近中心性 (Closeness Centrality)

- [x] 函数签名:
  ```moonbit
  pub fn closeness_centrality[G : @core.GraphReadable](
    graph : G,
    normalized : Bool
  ) -> CentralityResult
  ```
- [x] 公式: C(v) = (N-1) / Σ d(v,u)
- [x] 使用 Floyd-Warshall 或多次 BFS/Dijkstra 计算全源最短路径
- [x] 不连通图处理: Wasserman Faust 改进（只计算可达节点）
- **复杂度**: O(V(E+VlogV))
- **代码量**: ~80 行
- **工作量**: 2h
- **依赖**: TASK-006
- **验收**: 中心位置节点得分最高

---

#### TASK-010: 实现特征向量中心性 (Eigenvector Centrality)

- [x] 函数签名:
  ```moonbit
  pub fn eigenvector_centrality[G : @core.GraphReadable](
    graph : G,
    max_iterations : Int,
    tolerance : Double
  ) -> CentralityResult
  ```
- [x] 幂法迭代（类似 PageRank 但无 damping）:
  - x_v^(k+1) = (1/λ) * Σ x_u^k  for u ∈ neighbors(v)
  - 收敛判断: ||x_new - x_old|| < ε
- [x] 适用限制: 强连通图效果最佳
- **复杂度**: O(kE)
- **代码量**: ~100 行
- **工作量**: 3h
- **依赖**: TASK-006
- **验收**: 重要枢纽节点得分高 + 收敛稳定

---

#### TASK-011: 编写中心性分析测试套件 (45 tests)

| 算法 | 基础功能 | 边界情况 | 属性验证 | 小计 |
|------|:--------:|:--------:|:--------:|:----:|
| 度中心性 | 4 | 2 | 2 | **8** |
| 介数中心性 | 6 | 3 | 3 | **12** |
| 接近中心性 | 5 | 2 | 3 | **10** |
| 特征向量中心性 | 5 | 2 | 3 | **10** |
| 集成测试 | 5 | — | — | **5** |
| **合计** | **25** | **9** | **11** | **45** |

- **工作量**: 3h
- **依赖**: TASK-007~010
- **验收**: 全部通过 + 覆盖率 ≥ 88%

---

### 模块 C: 社区检测 [P0]

#### TASK-012: 创建目录结构与类型定义

- [x] 创建 `src/algo/community/` 目录
- [x] 创建 `moon.pkg`（依赖 `@core`）
- [x] 定义结果类型:
  ```moonbit
  pub(all) struct CommunityResult {
    labels : Array[Int]         // 节点所属社区标签
    modularity : Double         // 模块度值
    num_communities : Int       // 社区数量
    levels : Int                # Louvain 层数
  }
  ```
- [x] 创建文件骨架:
  - `louvain.mbt`
  - `label_propagation.mbt`
  - `community_test.mbt`
- **工作量**: 1h
- **验收**: 目录结构完整 + 可编译

---

#### TASK-013: 实现 Louvain 社区检测算法

- [x] 函数签名:
  ```moonbit
  pub fn louvain[G : @core.GraphReadable](
    graph : G,
    resolution : Double  // 默认 1.0
  ) -> CommunityResult
  ```
- [x] Phase 1: 贪心 Modularity 最大化
  - ΔQ = [(Σ_in + 2*Σ_tot)/(2m) - (Σ_tot/(2m))^2] - [Σ_in/(2m)]
  - 每次选择 ΔQ 最大的社区移动
  - 仅遍历节点及其邻居（非全图扫描）
- [x] Phase 2: 超图聚合
  - 社区→新节点
  - 重复 Phase 1 直到 Q 不再提升
- [x] Resolution 参数可调（影响社区粒度）
- **复杂度**: O(N log N) 近似线性
- **代码量**: ~250 行
- **工作量**: 5h
- **依赖**: TASK-012
- **验收**: Karate Club 图正确分成 2 个社区 + Q ≥ 0.6

---

#### TASK-014: 实现标签传播算法 (Label Propagation)

- [x] 函数签名:
  ```moonbit
  pub fn label_propagation[G : @core.GraphReadable](
    graph : G,
    max_iterations : Int,  // 默认 100
    seed : Int             // 随机种子（可选）
  ) -> CommunityResult
  ```
- [x] 初始化: 每个节点唯一标签
- [x] 异步迭代: 随机顺序更新，采用邻居最多标签
- [x] 收敛条件: 所有节点标签不再变化 或达到 max_iter
- [x] 特点: 速度快但结果不稳定（需多次运行取平均）
- **复杂度**: O(kE)，k 通常 < 10
- **代码量**: ~120 行
- **工作量**: 2.5h
- **依赖**: TASK-012
- **验收**: 能识别明显社区结构 + 多次运行一致性 > 80%

---

#### TASK-015: 编写社区检测测试套件 (35 tests)

| 算法 | 经典案例 | 参数验证 | 属性验证 | 性能 | 小计 |
|------|:--------:|:--------:|:--------:|:----:|:----:|
| **Louvain** | 5 | 3 | 4 | 4 | **16** |
| Karate Club / Dolphin / Football | resolution / max_level / 空图 | Q单调递增 / 社区不重叠 / 连通性保持 | 1000节点<5s | |
| **Label Propagation** | 5 | 4 | 3 | 2 | **14** |
| 简单图/不连通图/完全图/空图/单节点 | 种子固定/异步vs同步/max_iter | 社区连通/标签完整性/不可变性 | 5000节点<1s | |
| **集成对比** | 5 | — | — | — | **5** |
| 同一图两种算法结果合理性 | — | — | — | — | |
| **合计** | **15** | **7** | **7** | **6** | **35** |

- **工作量**: 3h
- **依赖**: TASK-013~014
- **验收**: `moon test src/algo/community` 全部通过 (35/35)

---

### 集成与发布准备

#### TASK-016: 集成测试与跨模块验证 ✅

- [x] 页面排名 + 中心性组合使用示例
- [x] 中心性 + 社区检测联动分析
- [x] 所有存储类型兼容性测试（AdjList/Matrix/CSR/EdgeList）
- [x] 内存占用检查（无泄漏）
- **工作量**: 2h
- **依赖**: TASK-005, 011, 015
- **验收**: 跨模块场景正常工作（10 tests, 全部通过）

---

#### TASK-017: 项目文档更新 ✅

- [x] AGENTS.md 更新:
  - 添加 pagerank/centrality/community 模块行
  - 更新测试数至 588
  - 更新版本号至 v0.10.0
- [x] MEMORY.md 更新:
  - 添加决策记录（PageRank 幂法/Brandes/Louvain vs GN）
  - 更新包结构
- [ ] README.mbt.md 更新:
  - 算法表添加 3 大模块
  - 统计数据更新
- **工作量**: 1.5h
- **依赖**: TASK-016
- **验收**: 文档一致性检查通过

---

#### TASK-018: Git Tag v0.10.0 发布

- [ ] 最终验证:
  - [ ] `moon check` 零错误零警告 ✅
  - [ ] `moon test` 全通过 (588 tests, 0 failure) ✅
  - [ ] 新模块覆盖率 ≥ 88%
  - [ ] 文档包含使用示例 + 复杂度说明
- [ ] Git 操作:
  ```bash
  git add .
  git commit -m "feat(algo): add social network analysis suite (PageRank + Centrality + Community Detection)"
  git tag -a v0.10.0 -m "feat(v0.10.0): 🔍 Social Network Analysis Suite"
  git push origin main --tags
  ```
- [ ] CHANGELOG.md 新增 v0.10.0 章节
- **工作量**: 1h
- **依赖**: TASK-017
- **验收**: Tag 存在 + GitHub Release 可访问

---

## 🎯 v0.11.0: 📊 数据交换与可视化

> **时间范围**: 2026-05-26（1 天 🚀）
> **新增测试**: 42 tests（总计 630）
> **核心产出**: DOT 格式读写 + JSON 序列化 + 图统计工具

---

### 模块 A: I/O 基础设施

#### TASK-101: 创建目录结构与类型定义

- [x] 创建 `src/io/` 目录
- [x] 创建 `moon.pkg`（依赖 `@core` 和 `@storage`）
- [x] 定义错误类型:
  ```moonbit
  pub(all) enum IOError {
    ParseError(String)
    UnsupportedFormat(String)
    InvalidData(String)
  }
  ```
- [x] 定义图统计类型:
  - `GraphStats`（节点/边/密度/有向标志/度分布统计）
  - `ConnectivityStats`（连通分量信息）
  - `DegreeDistribution`（度分布直方图）
- **验收**: `moon check src/io` 通过

---

#### TASK-102: DOT 格式序列化与解析

- [x] `write_dot[G : @core.GraphReadable]` — 泛型 DOT 序列化
- [x] `parse_dot_into[G : @core.GraphWritable]` — DOT 解析（状态机+递归下降）
- [x] 支持 `digraph` / `graph` 两种关键字
- [x] 支持 `[weight=...]` 边属性
- [x] 支持 `//`、`#` 行注释和 `/* */` 块注释
- [x] 兼容 AdjList / Matrix / CSR / EdgeList 全部存储类型
- **验收**: 20 个测试全部通过

---

#### TASK-103: JSON 格式序列化与解析

- [x] `graph_to_json[G : @core.GraphReadable]` — 泛型 JSON 序列化（compact/pretty）
- [x] `parse_json_into[G : @core.GraphWritable]` — JSON 解析（手动递归实现）
- [x] 格式规范: `{ mbtgraph, directed, nodes, edges }` 四字段
- [x] 往返测试验证: JSON → 图 → JSON 一致性
- **验收**: 12 个测试全部通过

---

#### TASK-104: 图统计工具

- [x] `basic_stats[G : @core.GraphReadable]` — 基本统计（节点/边/密度/度数）
- [x] `degree_distribution[G : @core.GraphReadable]` — 度分布直方图
- [x] `connectivity_stats[G : @core.GraphReadable]` — 连通性统计（基于 DFS）
- **验收**: 10 个测试全部通过

---

#### TASK-105: 编写 I/O 测试套件 (42 tests)

| 分类 | 数量 | 测试项 |
|------|:----:|--------|
| DOT 序列化 | 5 | 有向/无向/自定义名/单节点/空图 |
| DOT 解析 | 10 | 基础有向/无向/权重/无名称/注释(3种)/多边/错误处理/已存在图 |
| DOT 往返 | 5 | 有向/无向/链图/单节点/空图 |
| JSON 序列化 | 4 | 有向/无向/pretty/空图 |
| JSON 解析 | 4 | 基础/多边/已存在图/错误输入 |
| JSON 往返 | 4 | 有向/无向/链图/pretty |
| 图统计 | 10 | 基本(4) + 度分布(3) + 连通性(3) |
| **合计** | **42** | |

- **验收**: `moon test src/io` 42/42 全部通过

---

### 模块 B: 发布准备

#### TASK-106: 项目文档与版本发布

- [x] TODO.md 更新（v0.11.0 完成标记）
- [x] AGENTS.md 更新（测试数 588→630）
- [x] MEMORY.md 更新（I/O 模块记录）
- [x] CHANGELOG.md 新增 v0.11.0 条目
- [x] Git 提交 v0.11.0 发布
- **验收**: 文档一致性检查通过

---

## 🎯 v0.12.0: 🚀 经典算法增强

> **时间范围**: 2026-05-26（1 天 🚀）
> **新增测试**: 71 tests（总计 701）
> **核心产出**: 5 个经典算法覆盖遍历/路径/流/匹配四大领域

---

### TASK-107: 双向 BFS（traversal/）

- [x] `bidirectional_bfs[G: GraphReadable]` — 层交替双向广度优先搜索
- [x] 从起点和终点同时 BFS，相遇时重建最短路径
- [x] 时间复杂度 O(b^(d/2))，比单 BFS 搜索空间大幅减少
- **代码量**: ~134 行
- **测试**: 11 个（5 基础正确 + 3 边界 + 3 跨存储）
- **验收**: 59 tests 全部通过

---

### TASK-108: Hopcroft-Karp 二分图匹配（matching/）

- [x] `hopcroft_karp[G: GraphReadable]` — O(E√V) 二分图最大匹配
- [x] BFS 分层 + DFS 增广交替进行
- [x] 与 Hungarian 结果一致验证
- **代码量**: ~159 行
- **测试**: 13 个（6 基础正确 + 4 边界 + 3 跨存储）
- **验收**: 34 tests 全部通过

---

### TASK-109: A* 启发式搜索（shortest_path/）

- [x] `a_star[G: GraphReadable]` — 可配置启发函数的 A* 搜索
- [x] 启发函数通过闭包 `|NodeId| -> Double` 传入
- [x] 与 Dijkstra 结果一致（零启发函数退化）
- **代码量**: ~114 行
- **测试**: 14 个（6 基础正确 + 5 边界 + 3 跨存储）
- **验收**: 40 tests 全部通过

---

### TASK-110: 最小费用最大流（flow/）

- [x] `CostFlowNetwork` — 扩展 FlowNetwork 增加费用矩阵
- [x] `min_cost_max_flow` — SSP 算法（Bellman-Ford 找最短费用路径）
- [x] 流量守恒 + 费用最优双验证
- **代码量**: ~232 行
- **测试**: 16 个（8 基础正确 + 5 边界 + 3 验证）
- **验收**: 49 tests 全部通过

---

### TASK-111: Edmonds 一般图匹配（matching/）

- [x] `edmonds_matching[G: GraphReadable]` — 带奇环收缩的一般图最大匹配
- [x] 三态标签体系（0=未访问, 1=偶点, 2=奇点）检测奇环
- [x] Blossom 收缩 + 展开
- **代码量**: ~268 行
- **测试**: 17 个（8 基础正确 + 6 边界 + 3 跨存储）
- **验收**: 51 tests 全部通过

---

### TASK-112: 项目文档与版本发布

- [x] TODO.md 更新（v0.12.0 完成标记）
- [x] AGENTS.md 更新（测试数 630→701）
- [x] MEMORY.md 更新（5 新算法记录）
- [x] CHANGELOG.md 新增 v0.12.0 条目
- [x] `git tag v0.12.0`
- **验收**: 文档一致性检查通过

---

## 📅 开发计划时间线

> **实际完成**: 2026-05-26（比计划提前 10 天 🚀）

### 第 1 周 (5.25 - 5.26): 全模块冲刺

| 日期 | 实际完成 |
|------|---------|
| **5.25 (Mon)** | PageRank + 中心性 + 社区检测 + 集成测试 |
| **5.26 (Tue)** | 文档更新 + Git Tag v0.10.0 发布准备 |

---

## ✅ 验收标准 (v0.10.0 Final Checklist)

### 功能完整性

- [x] PageRank: 基本算法 + dangling nodes + 个人化可选
- [x] 中心性: 度/介数/接近/特征向量 四种指标
- [x] 社区检测: Louvain + 标签传播 两种算法
- [x] 所有函数有完整的 `///` 文档注释

### 质量保证

- [x] `moon test` 全通过 (**588 tests**, 0 failure)
- [x] `moon check` 零错误零警告
- [x] 新模块覆盖率 ≥ **88%**
- [x] 经典数据集测试通过（Karate Club / Dolphin / Football）

### 文档完整性

- [x] 每个模块有 README.md（API + 示例 + 复杂度）
- [ ] AGENTS.md / MEMORY.md / README.mbt.md 已更新
- [ ] CHANGELOG.md 有 v0.10.0 条目
- [ ] Git Tag v0.10.0 已创建

### 设计原则遵守

- [x] 无 `mut self` 参数
- [x] 无 `for` 元组解构
- [x] 无嵌套泛型 `>>` 冲突
- [x] 所有返回值已消费（无 E4139 warning）
- [x] 数组深拷贝正确（纯函数语义）

---

## 📊 任务统计

| 类别 | 任务数 | 预估工时 | 测试数 |
|------|:------:|:--------:|:------:|
| **PageRank** | 5 (001-005) | 8h | 15 |
| **中心性分析** | 6 (006-011) | 14h | 45 |
| **社区检测** | 4 (012-015) | 11.5h | 35 |
| **集成与发布** | 3 (016-018) | 4.5h | 10 |
| **合计** | **18 tasks** | **~38h** | **105 tests** |

---

## 🔄 下一步 (v0.12.0 之后)

已完成 v0.12.0 的所有算法补齐。经过全面审计分析，v0.13.0 采用分步策略：
详见 [design/v0130_refactoring_analysis.md](./design/v0130_refactoring_analysis.md)

```
v0.13.0 🛠️ 接口重构与 API 冻结准备
  ├── 阶段 1: 快速修复 (connectivity 命名 + shared_helpers)
  ├── 阶段 2: 补齐 P0 算法 (Johnson + SPFA + 边着色)
  ├── 阶段 3: 全面重构 (Trait 精简 + API 审计 + 签名统一)
  └── 阶段 4: 补齐 P1 算法 (BCC + 双向 Dijkstra + Yen's)
v1.0.0  🎉 正式发布
```

详细规划见: [ROADMAP.md](./ROADMAP.md) | [重构分析](./design/v0130_refactoring_analysis.md)

---

<div align="center">

**💡 提示**: 本文档每周更新，反映最新进展和下周计划

*维护者: @morning-start | 最后更新: 2026-05-26 | 目标: v0.10.0 (已完成 🎉)*

</div>