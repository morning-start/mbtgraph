# mbtgraph 任务清单 (TODO)

> **最后更新**: 2026-05-23 | **当前版本**: v0.5.0 | **当前冲刺**: Sprint 1 - 高级图分析算法
> **下次评审**: 2026-05-30（每周五）

---

## 📋 任务总览

### 当前进度

| 冲刺 | 状态 | 重点 | 目标完成 | 进度 |
|------|:----:|------|---------|:----:|
| **Sprint 1** | 🔨 进行中 | 高级图分析算法 | 2026-06-06 | **0%** |
| Sprint 2 | ⬜ 待开始 | I/O 序列化 | 2026-06-20 | — |
| Sprint 3 | ⬜ 待开始 | 工程化基础设施 | 2026-06-27 | — |
| Sprint 4 | ⬜ 待开始 | 文档与发布准备 | 2026-07-04 | — |

---

## 🎯 Sprint 1: 高级图分析算法（5.23 - 6.06）

**目标**: 完成 PageRank、中心性分析、社区检测三大模块，新增 ~70 测试

**负责人**: @morning-start
**优先级规则**: P0 (必须) > P1 (重要) > P2 (可选)

### P0 - 必须完成（阻塞后续开发）

#### 模块 A: PageRank 算法 [P0]

- [ ] **[TASK-001]** 创建 `src/algo/pagerank/` 目录结构
  - **截止日期**: 2026-05-24 (今天)
  - **工作量**: 0.5h
  - **交付物**: `moon.pkg`, `types.mbt`, `pagerank.mbt`, `pagerank_test.mbt`
  - **依赖**: 无
  - **验收标准**: 目录存在 + moon.pkg 配置正确 + 可编译通过空模块

- [ ] **[TASK-002]** 实现 PageRank 核心数据结构（PageRankResult 类型）
  - **截止日期**: 2026-05-24
  - **工作量**: 1h
  - **交付物**: `types.mbt` 包含 ranks 字段、迭代次数、收敛值
  - **依赖**: TASK-001
  - **验收标准**: 结构体定义完整 + 辅助方法（get_rank/top_nodes）

- [ ] **[TASK-003]** 实现 PageRank 幂法迭代算法
  - **截止日期**: 2026-05-26
  - **工作量**: 3h
  - **交付物**: `pagerank.mbt` 的 `pagerank()` 函数（~100 行代码）
  - **依赖**: TASK-002
  - **关键实现**:
    - 初始化：均匀分布 rank = 1/N
    - 迭代公式：PR(v) = (1-d)/N + d * Σ(PR(u)/out_degree(u))
    - 收敛判断：||PR_new - PR_old|| < ε (ε=1e-6)
    - 处理 dangling nodes（无出边节点）
    - 支持参数配置：damping factor (默认 0.85), max_iter (默认 100)
  - **复杂度**: O(kE)，k 为迭代次数（通常 < 50）
  - **验收标准**: 经典案例测试通过（简单图/星形图/完全图）

- [ ] **[TASK-004]** 编写 PageRank 测试套件（15 tests）
  - **截止日期**: 2026-05-27
  - **工作量**: 2h
  - **交付物**: `pagerank_test.mbt`
  - **依赖**: TASK-003
  - **测试分类**:
    - 基础功能 (5t): 简单图正确性 / 星形图 / 完全图 / 单节点图 / 空图
    - 参数验证 (3t): damping factor 范围 / max_iter 截断 / 收敛阈值敏感度
    - 属性验证 (4t): rank 总和 ≈ 1 / 对称图均匀分布 / dangling node 处理 / 不可变性
    - 边界情况 (3t): 超大图性能 / 不连通图 / 自环处理
  - **验收标准**: `moon test src/algo/pagerank` 全部通过 + 覆盖率 ≥ 90%

- [ ] **[TASK-005]** 编写 PageRank 文档（README + design doc）
  - **截止日期**: 2026-05-28
  - **工作量**: 1.5h
  - **交付物**: `README.md`, `docs/design/pagerank_design.md`
  - **依赖**: TASK-004
  - **内容要求**:
    - README: API 使用示例 + 复杂度说明 + 参数说明
    - Design doc: 算法原理/数学公式/设计决策/与 NetworkX 对比
  - **验收标准**: 示例代码可直接运行 + 公式渲染正确

---

#### 模块 B: 中心性分析 [P0]

- [ ] **[TASK-006]** 创建 `src/algo/centrality/` 目录结构
  - **截止日期**: 2026-05-25
  - **工作量**: 0.5h
  - **交付物**: `moon.pkg`, `types.mbt`, `degree_centrality.mbt`, `betweenness_centrality.mbt`, `closeness_centrality.mbt`, `eigenvector_centrality.mbt`, `centrality_test.mbt`
  - **依赖**: 无
  - **验收标准**: 目录存在 + 可编译通过

- [ ] **[TASK-007]** 实现度中心性（Degree Centrality）
  - **截止日期**: 2026-05-27
  - **工作量**: 1h
  - **交付物**: `degree_centrality.mbt`
  - **关键实现**:
    - 有向图：in_degree / out_degree / total_degree 三种模式
    - 归一化：C(v) = degree(v) / (N-1)
    - 复杂度: O(V+E)
  - **验收标准**: 星形图中心节点得分最高

- [ ] **[TASK-008]** 实现介数中心性（Betweenness Centrality）
  - **截止日期**: 2026-05-29
  - **工作量**: 4h
  - **交付物**: `betweenness_centrality.mbt`
  - **关键实现**:
    - Brandes 算法（O(VE) 比朴素 O(V³) 快）
    - 基于 BFS 的最短路径计数
    - 依赖累积：δ(s,t|v) = (σ_sv/σ_st) * (1 + Σ δ(s,w|w))
    - 归一化：2/((N-1)(N-2)) 对于无向图
    - **注意**: 大图可能较慢（V>1000 时需优化）
  - **复杂度**: O(VE) （Brandes 算法）
  - **验收标准**: 桥节点介数最高 + 与 NetworkX 结果一致（误差 < 1e-6）

- [ ] **[TASK-009]** 实现接近中心性（Closeness Centrality）
  - **截止日期**: 2026-05-30
  - **工作量**: 2h
  - **交付物**: `closeness_centrality.mbt`
  - **关键实现**:
    - C(v) = (N-1) / Σ d(v,u) （所有节点对距离之和的倒数）
    - 使用 Floyd-Warshall 或多次 BFS/Dijkstra
    - 处理不连通图：只计算可达节点（Wasserman Faust 改进）
    - 复杂度: O(V(E+VlogV)) （使用 Dijkstra）或 O(V³)（FW）
  - **验收标准**: 中心位置节点得分最高

- [ ] **[TASK-010]** 实现特征向量中心性（Eigenvector Centrality）
  - **截止日期**: 2026-06-01
  - **工作量**: 3h
  - **交付物**: `eigenvector_centrality.mbt`
  - **关键实现**:
    - 幂法迭代（类似 PageRank 但无 damping）
    - x_v = (1/λ) * Σ x_u （邻居得分加权和）
    - 收敛判断：||x_new - x_old|| < ε
    - **限制**: 只适用于强连通图（否则需要调整）
    - 复杂度: O(kE)
  - **验收标准**: 重要枢纽节点得分高 + 收敛稳定

- [ ] **[TASK-011]** 编写中心性分析测试套件（25 tests）
  - **截止日期**: 2026-06-02
  - **工作量**: 3h
  - **交付物**: `centrality_test.mbt`
  - **测试分配**:
    - 度中心性 (6t): 有向/无向/归一化/边界/异常输入
    - 介数中心性 (8t): Brandes 正确性/桥节点/对称性/性能基准
    - 接近中心性 (6t): 中心节点/不连通图/归一化
    - 特征向量中心性 (5t): 收敛性/强连通/初始向量敏感性
  - **验收标准**: 全部通过 + 覆盖率 ≥ 88%

---

#### 模块 C: 社区检测 [P0]

- [ ] **[TASK-012]** 创建 `src/algo/community/` 目录结构
  - **截止日期**: 2026-05-28
  - **工作量**: 0.5h
  - **交付物**: `moon.pkg`, `types.mbt`, `louvain.mbt`, `label_propagation.mbt`, `community_test.mbt`
  - **依赖**: 无
  - **验收标准**: 目录存在 + 可编译通过

- [ ] **[TASK-013]** 实现 Louvain 社区检测算法
  - **截止日期**: 2026-06-03
  - **工作量**: 5h
  - **交付物**: `louvain.mbt`
  - **关键实现**:
    - Phase 1: 贪心节点移动（Modularity 最大化）
      - ΔQ = [Δ_in/(2m) - (Σ_tot*Σ_in)/(2m)²]
      - 每次选择 ΔQ 最大的社区移动
    - Phase 2: 聚合超图（社区→新节点）
    - 重复直到 Modularity 不再提升
    - 数据结构：社区标签数组 + 内部边统计
    - **优化**: 仅遍历节点及其邻居（非全图扫描）
    - 复杂度: O(N log N) 近似线性
  - **验收标准**: Karate Club 图正确分成 2 个社区 + Modularity ≥ 0.6

- [ ] **[TASK-014]** 实现标签传播算法（Label Propagation）
  - **截止日期**: 2026-06-04
  - **工作量**: 2.5h
  - **交付物**: `label_propagation.mbt`
  - **关键实现**:
    - 初始化：每个节点唯一标签
    - 异步迭代：随机顺序更新，采用邻居最多标签
    - 收敛条件：所有节点标签不再变化或达到 max_iter
    - **特点**: 速度快但结果不稳定（需多次运行取平均）
    - 复杂度: O(kE)，k 通常 < 10
  - **验收标准**: 能识别明显社区结构 + 多次运行一致性 > 80%

- [ ] **[TASK-015]** 编写社区检测测试套件（30 tests）
  - **截止日期**: 2026-06-05
  - **工作量**: 3h
  - **交付物**: `community_test.mbt`
  - **测试分配**:
    - Louvain (15t):
      - 经典案例 (5t): Karate Club / Dolphin / Football
      - 参数验证 (3t): resolution 参数 / max_level / 空图
      - 属性验证 (4t): Modularity 单调递增 / 社区不重叠 / 连通性保持 / 不可变性
      - 性能 (3t): 1000 节点 < 5s / 5000 节点 < 30s / 内存稳定性
    - Label Propagation (15t):
      - 基本功能 (5t): 简单图/不连通图/完全图/空图/单节点
      - 稳定性 (4t): 多次运行方差/种子固定/异步vs同步/max_iter 效果
      - 边界情况 (3t): 超大图/权重影响/孤立节点
      - 属性验证 (3t): 社区连通/标签完整性/不可变性
  - **验收标准**: 全部通过 + 覆盖率 ≥ 87%

---

### P1 - 重要但非阻塞（提升质量）

- [ ] **[TASK-016]** Sprint 1 代码审查与重构
  - **截止日期**: 2026-06-06
  - **工作量**: 2h
  - **交付物**: 清洁代码 + 性能优化记录
  - **依赖**: TASK-004, TASK-011, TASK-015
  - **检查项**:
    - [ ] 符合 AGENTS.md 编码规范（R1-R7 规则）
    - [ ] 无 `mut self` / 无 `for` 元组解构 / 无嵌套泛型 `>>` 错误
    - [ ] 所有返回值已消费（无 E4139 warning）
    - [ ] 数组深拷贝正确（纯函数语义保证）
    - [ ] 复杂度符合预期（无明显性能退化）
    - [ ] 文档注释完整（所有 pub 函数有 `///` 注释）
  - **验收标准**: `moon check` 零错误零警告 + `moon fmt` 格式一致

- [ ] **[TASK-017]** 更新项目文档（AGENTS.md / MEMORY.md / README.mbt.md）
  - **截止日期**: 2026-06-06
  - **工作量**: 1.5h
  - **交付物**: 文档更新 + CHANGELOG.md 新增 v0.6.0 条目
  - **依赖**: TASK-016
  - **内容**:
    - AGENTS.md: 添加 pagerank/centrality/community 模块行 + 更新测试数至 ~621
    - MEMORY.md: 添加决策记录（PageRank 幂法选择/Brandes vs 朴素/Louvain vs GN）
    - README.mbt.md: 更新算法表 + 统计数据 + 版本号至 v0.6.0
    - CHANGELOG.md: 新增 [0.6.0] 章节（70+ tests / 3 模块 / PageRank+Centrality+Community）
  - **验收标准**: 文档一致性检查通过 (`bash scripts/check_doc_consistency.sh`)

- [ ] **[TASK-018]** 创建 Git Tag v0.6.0
  - **截止日期**: 2026-06-06
  - **工作量**: 0.5h
  - **交付物**: Git Tag + Release Notes
  - **依赖**: TASK-017
  - **命令**:
    ```bash
    git tag -a v0.6.0 -m "feat(algo): add PageRank, Centrality, Community Detection modules"
    git push origin v0.6.0
    ```
  - **验收标准**: Tag 存在 + GitHub Release 页面可访问

---

## ⏳ Sprint 2: I/O 序列化（6.07 - 6.20）

**目标**: 实现 DOT/GraphML/JSON 三种格式支持，新增 ~42 测试

> ⚠️ **前置条件**: Sprint 1 全部完成（TASK-001 至 TASK-018）

### P0 - 必须完成

- [ ] **[TASK-021]** 设计 I/O 模块架构（技术方案决策）
  - **截止日期**: 2026-06-07
  - **工作量**: 2h
  - **交付物**: 技术文档 `docs/design/io_architecture.md`
  - **关键决策**:
    - [ ] 模块位置：`src/io/` vs `src/utils/io/`？
    - [ ] 错误处理策略：Result 类型 vs 异常？
    - [ ] 解析器实现手写 vs 使用 parser combinator？
    - [ ] 是否支持流式读取（大文件）？
  - **推荐方案**: `src/io/` 独立目录 + Result 类型错误处理 + 手写解析器（避免外部依赖）+ 先不支持流式（MVP）

- [ ] **[TASK-022]** 实现 DOT 格式解析器/生成器
  - **截止日期**: 2026-06-10
  - **工作量**: 6h
  - **交付物**: `src/io/dot.mbt` (~300 行), `dot_test.mbt` (20 tests)
  - **功能清单**:
    - ✅ 解析 DOT 语法的子集（digraph/graph/node/edge/属性）
    - ✅ 支持 Graphviz 标准属性（color/shape/label/weight）
    - ✅ 生成 DOT 格式输出（从内存图对象）
    - ✅ 错误处理（语法错误行号提示）
    - ❌ 不支持子图（subgraph）复杂语法（v1.1 再考虑）
  - **参考实现**: Python NetworkX `nx_agraph.read_dot()`
  - **验收标准**: 可解析 10+ 真实 .dot 文件 + 往返转换一致（parse → graph → write → parse）

- [ ] **[TASK-023]** 实现 JSON 序列化/反序列化
  - **截止日期**: 2026-06-13
  - **工作量**: 4h
  - **交付物**: `src/io/json_serializer.mbt` (~150 行), `json_test.mbt` (10 tests)
  - **Schema 设计**:
    ```json
    {
      "directed": true,
      "nodes": [{"id": 0, "data": 0.0}, ...],
      "edges": [{"from": 0, "to": 1, "weight": 1.0}, ...],
      "metadata": {"name": "example", "version": "1.0"}
    }
    ```
  - **功能**:
    - ✅ 从 MoonBit 图对象导出为 JSON 字符串
    - ✅ 从 JSON 字符串构建图对象（自动选择存储类型）
    - ✅ 美化输出（pretty print）和紧凑输出（minified）
    - ✅ Schema 版本控制（向后兼容）
  - **验收标准**: 往返转换无损 + 支持所有 8 种存储类型

- [ ] **[TASK-024]** 实现 GraphML 格式读写
  - **截止日期**: 2026-06-16
  - **工作量**: 5h
  - **交付物**: `src/io/graphml.mbt` (~250 行), `graphml_test.mbt` (12 tests)
  - **挑战**: XML 解析（MoonBit 可能没有成熟 XML 库）
  - **备选方案**:
    - 方案 A: 手写简易 XML parser（仅支持 GraphML 子集）
    - 方案 B: 使用正则表达式提取关键信息（快速但不健壮）
    - 方案 C: 暂缓 GraphML，优先 DOT + JSON（推荐 MVP）
  - **建议**: 选择方案 C（标记为 P1），Sprint 2 仅完成 DOT + JSON
  - **验收标准**: 如实现，需与 JGraphT 生成的文件互操作

- [ ] **[TASK-025]** I/O 集成测试 + 文档
  - **截止日期**: 2026-06-18
  - **工作量**: 3h
  - **交付物**: 集成测试文件 + README.md + design docs
  - **测试场景**:
    - 真实数据集导入（Karate Club.dot / football.graphml）
    - 大规模图序列化性能（10K 节点 < 1s）
    - Malformed input 错误恢复
    - 跨格式转换（DOT → Graph → JSON）
  - **验收标准**: 所有集成测试通过 + 用户文档完整

---

## 🔮 Sprint 3: 工程化基础设施（6.21 - 6.27）

**目标**: 建立 CI/CD Pipeline 和 Benchmark 套件

> ⚠️ **前置条件**: Sprint 2 完成

### P0 - 必须完成

- [ ] **[TASK-031]** 设置 GitHub Actions CI Pipeline
  - **截止日期**: 2026-06-21
  - **工作量**: 4h
  - **交付物**: `.github/workflows/ci.yml`
  - **Pipeline 阶段**:
    1. **Lint**: `moon fmt --check` + 自定义 lint 规则检查
    2. **Type Check**: `moon check`（全量零错误）
    3. **Test**: `moon test`（全量通过 + 覆盖率报告）
    4. **Build**: `moon build --target native` + `--target wasm` + `--target js`
    5. **Docs**: 文档生成 + 一致性检查脚本
  - **触发条件**: PR to main + push to main + manual dispatch
  - **验收标准**: 绿色 build badge 显示在 README

- [ ] **[TASK-032]** 创建 Benchmark 套件
  - **截止日期**: 2026-06-23
  - **工作量**: 5h
  - **交付物**: `benchmarks/` 目录 + benchmark 脚本
  - **Benchmark 场景**:
    - 构建性能: add_node/add_edge 各 10K 次
    - 算法性能: BFS/DFS/Pagerank 在不同规模图上（100/1K/10K 节点）
    - 内存占用: CSR vs AdjList vs Matrix（相同图的内存消耗）
    - I/O 性能: DOT/JSON 序列化/反序列化速度
  - **输出格式**: CSV（可导入 Excel/Gnuplot）+ Markdown 表格
  - **基线建立**: v0.6.0 的性能数据作为回归检测基准
  - **验收标准**: 每个 benchmark 运行 3 次取中位数 + CV < 5%

- [ ] **[TASK-033]** 实现 API 兼容性检查工具
  - **截止日期**: 2026-06-24
  - **工作量**: 3h
  - **交付物**: `scripts/api_compat_check.sh` + `.mbti` diff 检测
  - **功能**:
    - 对比 main 和 PR 分支的 `.mbti` 文件差异
    - 检测 breaking changes（函数签名变更/类型删除/public → private）
    - 自动生成 Migration Guide 片段
    - 集成到 CI Pipeline（breaking change 需人工审核）
  - **验收标准**: 可准确检测 90%+ 的 API 变更

- [ ] **[TASK-034]** 编写 CONTRIBUTING.md 贡献者指南
  - **截止日期**: 2026-06-25
  - **工作量**: 2h
  - **交付物**: `CONTRIBUTING.md`
  - **章节**:
    1. 开发环境搭建（MoonBit 工具链安装）
    2. 代码风格指南（引用 AGENTS.md）
    3. 提交信息规范（Conventional Commits）
    4. PR 流程（Fork → Branch → Test → Review → Merge）
    5. 测试要求（覆盖率 + 黑盒/白盒比例）
    6. Issue/PR 模板说明
  - **验收标准**: 新贡献者可在 30 分钟内完成首次 PR

- [ ] **[TASK-035]** 建立 Issue/PR 模板
  - **截止日期**: 2026-06-26
  - **工作量**: 1h
  - **交付物**: `.github/ISSUE_TEMPLATE/` + `.github/PULL_REQUEST_TEMPLATE.md`
  - **模板内容**:
    - Bug Report: 复现步骤 + 期望行为 + 实际行为 + 环境信息
    - Feature Request: 用例描述 + 伪代码/示例 + 优先级评估
    - PR Template: 变更概述 + 测试截图 + Breaking Changes 声明
  - **验收标准**: GitHub 自动加载模板

---

## 📝 Sprint 4: 文档与发布准备（6.28 - 7.04）

**目标**: 完善文档体系，准备 v1.0.0 正式发布

> ⚠️ **前置条件**: Sprint 3 完成

### P0 - 必须完成

- [ ] **[TASK-041]** API 审计与 Breaking Changes 文档
  - **截止日期**: 2026-06-28
  - **工作量**: 4h
  - **交付物**: `docs/migration_guide.md` + Breaking Changes 清单
  - **审计范围**:
    - 所有公开 API（pub fn / pub struct / pub trait）
    - 与 v0.5.0 的差异对比
    - 分类：Compatible / Deprecated / Breaking
    - Breaking Changes 影响评估和迁移路径
  - **验收标准**: 100% 公开 API 已审计 + migration path 明确

- [ ] **[TASK-042]** 英文版 README + 国际化准备
  - **截止日期**: 2026-06-29
  - **工作量**: 6h
  - **交付物**: `README.en.mbt.md`
  - **翻译策略**:
    - 保持中文版为主（原语言）
    - 英文版覆盖核心内容（特性/API/快速开始/安装）
    - 代码示例不变（通用）
    - 使用简洁英文（非母语友好）
  - **验收标准**: 英文版可独立阅读 + Google Translate 得分 > 90

- [ ] **[TASK-043]** 编写 10+ Tutorial 示例
  - **截止日期**: 2026-07-01
  - **工作量**: 8h
  - **交付物**: `examples/` 目录（10 个可运行示例）
  - **示例列表**:
    1. `basics/bfs_dfs.mbt` — 基础遍历入门
    2. `shortest_path/navigation.mbt` — 导航系统（Dijkstra）
    3. `mst/network_design.mbt` — 网络布线（Kruskal）
    4. `flow/water_pipe.mbt` — 水管网络最大流（Dinic）
    5. `matching/job_assignment.mbt` — 工作分配（Hungarian）
    6. `social_network/pagerank.mbt` — 社交网络影响力排名
    7. `community_detection/twitter.mbt` — Twitter 社区发现（Louvain）
    8. `io/import_export.mbt` — 图数据导入导出
    9. `performance/storage_selection.mbt` — 存储选型指南
    10. `advanced/tsp_solver.mbt` — 旅行商问题求解器
  - **每个示例包含**:
    - 问题背景说明
    - 完整可运行代码
    - 预期输出注释
    - 扩展练习题
  - **验收标准**: 所有示例 `moon run` 通过 + 注释清晰

- [ ] **[TASK-044]** 准备 v1.0.0 发布物料
  - **截止日期**: 2026-07-02
  - **工作量**: 3h
  - **交付物**:
    - CHANGELOG.md v1.0.0 章节
    - GitHub Release Notes（Markdown）
    - Git Tag: v1.0.0
    - mooncakes.io 发布配置（如可用）
  - **Release Notes 内容**:
    - ✨ 主要新功能（PageRank/I/O/CI/CD）
    - 📊 统计数据（700+ tests / 40+ 算法 / 8 存储）
    - 🔄 Migration Guide 链接
    - 🙏 致谢（如有贡献者）
    - 🔗 后续路线图链接
  - **验收标准**: Release Notes 完整专业 + Tag 已推送

- [ ] **[TASK-045]** 最终质量门禁检查
  - **截止日期**: 2026-07-04
  - **工作量**: 2h
  - **交付物**: 质量检查报告
  - **检查清单**:
    - [ ] `moon check` 零错误零警告 ✅
    - [ ] `moon test` 全部通过（700+ tests, 0 failure）✅
    - [ ] 覆盖率 ≥ 85%（核心模块 ≥ 95%）✅
    - [ ] 文档覆盖率 100%（所有公开 API 有注释）✅
    - [ ] CI Pipeline 绿色 ✅
    - [ ] Benchmark 基线已建立 ✅
    - [ ] Breaking Changes 文档完整 ✅
    - [ ] Examples 全部可运行 ✅
    - [ ] AGENTS.md / MEMORY.md 已更新至最新状态 ✅
    - [ ] Changelog 完整 ✅
  - **决策点**: 是否满足 v1.0.0 发布标准？是 → 发布；否 → 延期至 v0.9.1

---

## 📚 Backlog（未来迭代）

> 以下任务暂不纳入当前 Sprint，待资源允许时排期

### P1 - 重要（v1.1.0-v1.2.0）

- [ ] **[BACKLOG-101]** Fuzz Testing 集成
  - **预估工作量**: 8h
  - **思路**: 使用随机图生成器 + 属性验证（如 MST 权重唯一性/流守恒）
  - **工具**: 可能需要自研（MoonBit 生态暂无成熟 fuzz 框架）

- [ ] **[BACKLOG-102]** 交互式 Demo（Wasm Playground）
  - **预估工作量**: 16h
  - **思路**: 类似 Rust Playground，在线编辑运行 mbtgraph 代码
  - **技术栈**: MoonBit wasm + Web 前端

- [ ] **[BACKLOG-103]** GraphML 格式完整实现
  - **预估工作量**: 6h
  - **前提**: MoonBit 有可用 XML 解析库或自行实现

- [ ] **[BACKLOG-104]** 性能优化专项
  - **预估工作量**: 20h
  - **方向**:
    - CSR/CSC 批量操作 SIMD 向量化
    - 并行算法（多线程 BFS/PageRank）
    - 内存池分配器（减少 GC 压力）

### P2 - 可选（v1.3.0+）

- [ ] **[BACKLOG-201]** Node2Vec / DeepWalk 图嵌入
  - **预估工作量**: 12h
  - **应用**: 图机器学习基础，节点表示学习

- [ ] **[BACKLOG-202]** 外部存储支持（大图）
  - **预估工作量**: 16h
  - **技术**: 内存映射文件 / SQLite 后端 / 磁盘溢出

- [ ] **[BACKLOG-203]** GNN 可行性研究
  - **预估工作量**: 8h（调研）+ 40h（PoC）
  - **产出**: 可行性报告 + 简单 GCN/FNN 实现

- [ ] **[BACKLOG-204]** 分布式图计算接口
  - **预估工作量**: 20h
  - **设计**: 定义 MapReduce-style 图操作抽象层

### Won't Do（明确不做）

- ~~GUI 可视化编辑器~~ → 使用 yEd / Gephi / Cytoscape
- ~~Python/R 绑定~~ → 聚焦 MoonBit 生态
- ~~实时流图处理~~ → 超出库定位（考虑 Apache Flink/Spark）
- ~~数据库后端~~ → 使用 Neo4j / TigerGraph

---

## 🚫 阻塞项与风险

### 当前阻塞

| 任务 ID | 被阻塞任务 | 阻塞原因 | 缓解措施 | 预计解除时间 |
|---------|-----------|---------|---------|-------------|
| 无 | — | — | — | — |

### 潜在风险

| 风险 | 影响任务 | 概率 | 缓解计划 |
|------|---------|:----:|---------|
| MoonBit 工具链 bug | 所有开发任务 | 低 | 提 issue 给官方 + workaround |
| I/O 模块设计决策耗时 | TASK-021 | 中 | 设定 2h 时间盒，超时选择推荐方案 |
| GraphML XML 解析困难 | TASK-024 | 中 | 降级为 P1，优先 DOT+JSON |
| Benchmark 数据波动 | TASK-032 | 低 | 多次运行取中位数 + 固定测试环境 |
| 文档翻译质量 | TASK-042 | 中 | 使用 AI 辅助 + 人工校对 |

---

## 📊 进度跟踪

### 本周总结（Week of 5.23 - 5.30）

**目标**: 完成 TASK-001 至 TASK-005（PageRank 模块）

**每日计划**:

| 日期 | 任务 | 状态 | 实际用时 |
|------|------|:----:|:-------:|
| 5.23 (Fri) | TASK-001: 创建 pagerank 目录 | ⬜ 待开始 | — |
| 5.24 (Sat) | TASK-002 + TASK-003: 数据结构 + 核心算法 | ⬜ 待开始 | — |
| 5.25 (Sun) | TASK-006: 创建 centrality 目录 | ⬜ 待开始 | — |
| 5.26 (Mon) | TASK-003 (续) + TASK-007: 度中心性 | ⬜ 待开始 | — |
| 5.27 (Tue) | TASK-004: PageRank 测试 + TASK-007 (续) | ⬜ 待开始 | — |
| 5.28 (Wed) | TASK-005: PageRank 文档 + TASK-012: community 目录 | ⬜ 待开始 | — |
| 5.29 (Thu) | TASK-008: 介数中心性 | ⬜ 待开始 | — |
| 5.30 (Fri) | TASK-009: 接近中心性 + 周复盘 | ⬜ 待开始 | — |

**周目标达成条件**:
- [ ] PageRank 模块 100% 完成（代码+测试+文档）
- [ ] 中心性分析进度 ≥ 60%（至少完成度+介数中心性）
- [ ] 社区检测目录已创建并开始编码

---

## 💡 快速参考

### 优先级定义

| 优先级 | 含义 | 响应时间 | 示例 |
|--------|------|---------|------|
| **P0** | 必须完成（阻塞发布） | 立即处理 | 核心算法 / 测试失败 / CI red |
| **P1** | 重要（影响质量） | 本周内 | 文档完善 / 重构优化 |
| **P2** | 可选（锦上添花） | 有空再做 | 性能优化 / 新 feature |
| **P3** | 暂不考虑 | Backlog | 探索性功能 |

### 状态定义

| 状态 | 图标 | 说明 |
|------|:----:|------|
| 待开始 | ⬜ | 尚未开工 |
| 进行中 | 🔨 | 正在实施 |
| 已完成 | ✅ | 验收通过 |
| 已阻塞 | 🚫 | 等待前置条件 |
| 已取消 | ❌ | 不再需要 |

### 工作量估算单位

| 单位 | 含义 | 示例 |
|------|------|------|
| h | 小时 | 2h = 2 小时 |
| d | 天 | 1d = 6-8 小时（有效工作时间）|

---

## 🔄 更新日志

| 日期 | 操作 | 说明 |
|------|------|------|
| 2026-05-23 | 🎉 初始创建 | 基于 ROADMAP.md Sprint 计划分解出 45+ 任务 |
| - | - | - |

---

<div align="center">

**📌 提示**: 本文档每周五更新，反映最新进展和下周计划

*维护者: @morning-start | 最后更新: 2026-05-23*

</div>
