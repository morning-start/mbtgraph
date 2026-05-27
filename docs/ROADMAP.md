# mbtgraph 项目路线图

> **最后更新**: 2026-05-26 | **当前版本**: v0.12.0 | **状态**: 🚀 经典算法增强已发布，进入 v0.13.0 接口重构准备

---

## 📌 项目愿景

**成为 MoonBit 生态系统中最完整、最高质量的图算法库，覆盖从基础遍历到高级图分析的全面需求。**

### 核心定位

- **目标用户**: 算法竞赛选手、科研工作者、图数据库开发者、需要图算法的生产系统
- **差异化优势**:
  - ✅ 唯一覆盖 **8 大算法领域**的 MoonBit 图库（遍历/路径/MST/连通性/流/匹配/图论/NP-Hard + 高级分析）
  - ✅ 业界领先的 **6 层 Trait 设计**（对标 petgraph 的 3 层）
  - ✅ **8 种存储结构**（比 petgraph 多 2 种）
  - ✅ 原生多后端支持（wasm/js/native）
  - ✅ 超小体积（wasm < 1MB）

---

## 🎯 四阶段发展规划

### 核心理念：先做深，再做广；先有价值，再完美

```
┌─────────────────────────────────────────────────────────────┐
│ 阶段 1: 基础算法完成 + 接口完善     → 核心竞争力             │
│   v0.10.0 🔍 社交网络分析套件                                  │
│   v0.11.0 📊 数据交换与可视化                                 │
│   v0.12.0 🚀 经典算法增强                                    │
│   v0.13.0 🛠️ 接口重构与 API 冻结准备                          │
├─────────────────────────────────────────────────────────────┤
│ 阶段 2: 优化 + 结构体/接口调整       → 质量提升               │
│   v0.14.0 ⚡ 性能优化专项                                     │
│   v0.15.0 🔧 API 冻结候选 (=v1.0.0-rc.1)                    │
├─────────────────────────────────────────────────────────────┤
│ 阶段 3: 工程化 → v1.0.0            → 生产就绪               │
│   v1.0.0-rc.2 🔄 CI/CD 上线                                 │
│   v1.0.0 🎉 正式发布 🚀                                      │
├─────────────────────────────────────────────────────────────┤
│ 阶段 4: 拓展和高级算法              → 生态扩展               │
│   v1.1.0 🌐 高级图机器学习基础                               │
│   v1.2.0 📈 大规模图处理                                     │
│   v1.3.0+ 🚀 生态与社区                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 当前基线 (v0.12.0)

### 已完成资产

| 维度 | 数值 | 说明 |
|------|:----:|------|
| **算法模块** | 15 | P0-P5 全覆盖 + 社交网络分析 |
| **I/O 模块** | 1 | DOT + JSON + 图统计 |
| **算法总数** | 43+ | 含 A*/双向 BFS/Hopcroft-Karp/费用流/Edmonds 匹配 |
| **测试用例** | 701 | 全通过 ✅ |
| **代码行数** | ~10000+ | 含测试和文档 |
| **Git Tags** | 7 | v0.5.0 → v0.11.0 → v0.12.0

### 已有算法清单

```
✅ 遍历: BFS, DFS, 双向 BFS
✅ 最短路径: Dijkstra, Bellman-Ford, Floyd-Warshall, A* 启发式搜索
✅ MST: Kruskal, Prim
✅ 连通性: CC, Tarjan SCC, Kosaraju SCC
✅ 流网络: Edmonds-Karp, Dinic (最大流), 最小费用最大流
✅ 匹配: Hungarian (二分图), Hopcroft-Karp, Edmonds (一般图匹配)
✅ 图论: Euler, Cutpoints/Bridges, Coloring, Clique, Hamiltonian/TSP
✅ 图生成器: 16 种随机图生成
```

### 关键缺口识别

#### 🔴 P0 缺失基础算法（已补齐 ✅）

| 算法 | 分类 | 复杂度 | 用途 | 测试数 |
|------|------|--------|------|:------:|
| **A* 启发式搜索** | 最短路径 | O(b^d) | 导航/游戏AI | 14 ✅ |
| **最小费用最大流** | 流网络 | O(V·E·C) | 物流/资源分配 | 16 ✅ |
| **Hopcroft-Karp** | 匹配 | O(E√V) | 快速二分图匹配 | 13 ✅ |
| **一般图匹配 (Edmonds)** | 匹配 | O(V³) | 非二分图匹配 | 17 ✅ |
| **双向 BFS** | 遍历 | O(b^{d/2}) | 无权图最短路径 | 11 ✅ |

**小计**: 5 算法 | **71 tests** ✅ 全部完成

#### 🟡 P1 高级分析算法（已补齐 ✅）

| 算法/模块 | 分类 | 复杂度 | 用途 | 测试数 |
|-----------|------|--------|------|:------:|
| **PageRank** | 图分析 | O(kE) | 网页排序/影响力 | 15 ✅ |
| **度中心性** | 中心性 | O(V+E) | 基础指标 | 8 ✅ |
| **介数中心性 (Brandes)** | 中心性 | O(VE) | 关键节点 | 12 ✅ |
| **接近中心性** | 中心性 | O(V(E+VlogV)) | 中心位置 | 10 ✅ |
| **特征向量中心性** | 中心性 | O(kE) | 影响力传播 | 10 ✅ |
| **Louvain 社区检测** | 社区 | O(N log N) | 社群发现 | 20 ✅ |
| **标签传播算法** | 社区 | O(kE) | 快速聚类 | 15 ✅ |

**小计**: 7 模块 | **~100 tests** ✅ 全部完成

#### 🟢 P2 I/O 与工具（已补齐 ✅）

| 功能 | 分类 | 复杂度 | 用途 | 测试数 |
|------|------|--------|------|:------:|
| **DOT 格式解析/生成** | I/O | O(N) | Graphviz 兼容 | 20 ✅ |
| **JSON 序列化** | I/O | O(N) | 数据交换 | 12 ✅ |
| **图统计信息** | 工具 | O(V+E) | 快速洞察 | 10 ✅ |

**小计**: 3 功能 | **42 tests** ✅ 全部完成

---

## 🚀 版本计划详情

### 阶段 1: 基础算法完成 + 接口完善

> **时间范围**: 2026 Q2-Q3 (5月25日 - 7月中旬)
> **目标版本**: v0.10.0 → v0.13.0
> **新增测试**: ~222 tests (总计 ~773)
> **核心产出**: 补齐所有基础算法 + 高级分析能力

---

#### 📍 Version 0.10.0: 🔍 社交网络分析套件

**发布日期**: 2026-06-05 (预计 2 周)
**主题**: 让 mbtgraph 具备完整的社交网络分析能力

##### 模块组成

```
src/algo/
├── pagerank/                    # [NEW] PageRank 算法
│   ├── moon.pkg
│   ├── types.mbt               # PageRankResult { ranks, iterations, converged }
│   ├── pagerank.mbt            # 幂法迭代实现 (~120 行)
│   └── pagerank_test.mbt       # 15 tests
│
├── centrality/                  # [NEW] 中心性分析套件
│   ├── moon.pkg
│   ├── types.mbt               # CentralityResult { scores, normalized }
│   ├── degree_centrality.mbt   # 度中心性 (~60 行)
│   ├── betweenness_centrality.mbt # 介数中心性 Brandes (~150 行)
│   ├── closeness_centrality.mbt # 接近中心性 (~80 行)
│   ├── eigenvector_centrality.mbt # 特征向量中心性 (~100 行)
│   └── centrality_test.mbt     # 45 tests (各算法 8-15 个)
│
└── community/                   # [NEW] 社区检测
    ├── moon.pkg
    ├── types.mbt               # CommunityResult { labels, modularity, levels }
    ├── louvain.mbt             # Louvain 算法 (~250 行)
    ├── label_propagation.mbt   # 标签传播 (~120 行)
    └── community_test.mbt      # 35 tests
```

##### 技术亮点

1. **PageRank 幂法优化**
   - 支持 dangling nodes 处理（无出边节点）
   - 可配置 damping factor (默认 0.85)
   - 收敛阈值 ε = 1e-6
   - 个人化 PageRank (Personalized PageRank) 可选

2. **Brandes 介数中心性**
   - O(VE) 比朴素 O(V³) 快
   - 支持有向/无向图
   - 归一化选项

3. **Louvain 社区检测**
   - Phase 1: 贪心 Modularity 最大化
   - Phase 2: 超图聚合
   - Resolution 参数可调
   - 适用于 Karate Club / Dolphin 经典数据集

##### 测试策略

| 模块 | 基础功能 | 边界情况 | 属性验证 | 性能基准 | 总计 |
|------|:--------:|:--------:|:--------:|:--------:|:----:|
| PageRank | 5 | 3 | 4 | 3 | **15** |
| 度中心性 | 4 | 2 | 2 | — | **8** |
| 介数中心性 | 6 | 3 | 3 | — | **12** |
| 接近中心性 | 5 | 2 | 3 | — | **10** |
| 特征向量中心性 | 5 | 2 | 3 | — | **10** |
| Louvain | 8 | 4 | 4 | 4 | **20** |
| 标签传播 | 6 | 4 | 3 | 2 | **15** |
| **合计** | **39** | **20** | **22** | **9** | **~95** |

##### 验收标准

- [x] `moon test` 全部通过 (588 tests)
- [x] `moon check` 零错误零警告
- [x] 覆盖率 ≥ 88%（新模块）
- [x] 文档包含使用示例 + 复杂度说明
- [x] 经典数据集测试通过（Karate Club / Dolphin / Football）

---

#### 📍 Version 0.11.0: 📊 数据交换与可视化

**发布日期**: 2026-05-26 (1 天 🚀)
**主题**: 让图数据可以导入导出，连接外部生态

##### 模块组成

```
src/io/                           # [NEW] I/O 模块
├── moon.pkg
├── types.mbt                    # IOError 变体 + 格式配置
├── dot.mbt                      # DOT 格式解析器/生成器 (~300 行)
│   ├── parse_dot()              # 解析 DOT 字符串 → 图对象
│   └── write_dot()              # 图对象 → DOT 字符串
├── json_serializer.mbt          # JSON 序列化 (~150 行)
│   ├── to_json()                # 图对象 → JSON 字符串
│   └── from_json()              # JSON 字符串 → 图对象
├── graph_stats.mbt             # [NEW] 图统计信息工具 (~80 行)
│   ├── basic_stats()            # V, E, 密度, 直方图
│   ├── degree_distribution()    # 度分布序列
│   └── connectivity_stats()     # 连通分量统计
└── io_test.mbt                  # 42 tests
    ├── dot_test.mbt             # 20 tests (解析/生成/往返)
    ├── json_test.mbt           # 12 tests (序列化/反序列化/Schema)
    └── stats_test.mbt          # 10 tests (统计正确性)
```

##### 技术亮点

1. **DOT 格式支持**
   - 兼容 Graphviz / NetworkX 标准
   - 支持有向图 (`digraph`) 和无向图 (`graph`)
   - 保留节点/边属性（label/color/shape/weight）
   - 错误处理：语法错误时提供行号提示

2. **JSON Schema 设计**
   ```json
   {
     "version": "1.0",
     "directed": true,
     "multigraph": false,
     "nodes": [
       {"id": 0, "data": {"label": "A"}},
       {"id": 1, "data": {"label": "B"}}
     ],
     "edges": [
       {"source": 0, "target": 1, "weight": 1.5}
     ],
     "metadata": {"name": "example", "created": "2026-06-19"}
   }
   ```

3. **图统计信息**
   - 基础指标：节点数、边数、密度、自环数
   - 度分布：度序列、平均度、最大/最小度
   - 连通性：连通分量数、最大分量大小
   - 可视化友好：可直接用于绘图库输入

##### 测试策略

| 模块 | 正常场景 | 异常处理 | 往返一致性 | 性能 | 总计 |
|------|:--------:|:--------:|:----------:|:----:|:----:|
| DOT 解析 | 8 | 6 | 4 | 2 | **20** |
| JSON 序列化 | 5 | 3 | 3 | 1 | **12** |
| 图统计 | 6 | 2 | — | 2 | **10** |
| **合计** | **19** | **11** | **7** | **5** | **42** |

##### 验收标准

- [x] 全 8 种存储类型兼容 DOT/JSON 读写
- [x] JSON 往返转换无损（parse → graph → serialize → parse → 对比）
- [x] 图统计结果与手动计算一致
- [x] 全部 42 个测试通过，总计 630 tests

##### 接口完善工作（本版本附带）

1. **标准化数据访问接口**
   - 确保 I/O 模块可支持所有 8 种存储类型
   - 统一 `to_adj_list()` / `from_adj_list()` 模式

2. **错误类型体系**
   ```moonbit
   pub type IOError {
     ParseError(String)
     UnsupportedFormat(String)
     InvalidData(String)
     FileNotFound(String)
   }
   ```

---

#### 📍 Version 0.12.0: 🚀 经典算法增强

**发布日期**: 2026-07-03 (预计 2 周)
**主题**: 补齐经典图算法的最后几块拼图

##### 模块组成

```
src/algo/
├── shortest_path/               # [ENHANCED] 新增算法
│   └── a_star.mbt             # [NEW] A* 启发式搜索 (~130 行)
│
├── flow/                        # [ENHANCED] 新增算法
│   └── min_cost_max_flow.mbt  # [NEW] 最小费用最大流 (~200 行)
│
├── matching/                     # [ENHANCED] 新增算法
│   ├── hopcroft_karp.mbt      # [NEW] Hopcroft-Karp (~120 行)
│   └── edmonds_matching.mbt   # [NEW] 一般图匹配 Edmonds (~180 行)
│
└── traversal/                    # [ENHANCED] 新增变体
    └── bidirectional_bfs.mbt  # [NEW] 双向 BFS (~80 行)
```

##### 技术亮点

1. **A* 启发式搜索**
   - 支持自定义启发函数（曼哈顿距离/欧几里得等）
   - 适用于网格图/道路网络
   - 比 Dijkstra 快几个数量级（有良好启发函数时）
   - 应用场景：游戏 AI寻路、导航系统

2. **Johnson 全源最短路径**
   - 使用 Bellman-Ford + Dijkstra 组合
   - 时间复杂度 O(V²logV + VE)，比 Floyd-Warshall O(V³) 更适合稀疏图
   - 可处理负权边（但无负权环）

3. **最小费用最大流 (Successive Shortest Path)**
   - 基于 SPFA/Bellman-Ford 找最短路
   - 每次增广最短费用路径
   - 应用场景：物流调度、资源分配、交通流

4. **Hopcroft-Karp 二分图匹配**
   - O(E√V) 比 Hungarian O(VE) 快
   - 使用 BFS 分层 + DFS 增广
   - 适用于大规模稀疏二分图

5. **Edmonds 一般图匹配 (Blossom Algorithm)**
   - O(V³) 或 O(V²E) 实现
   - 处理奇数环（blossom）收缩/展开
   - 填补非二分图匹配空白

6. **双向 BFS**
   - 从起点和终点同时搜索
   - 理论加速 O(b^(d/2))
   - 适用于无权图最短路径

##### 测试策略

| 算法 | 基础正确性 | 特殊案例 | 性能对比 | 总计 |
|------|:----------:|:--------:|:--------:|:----:|
| A* | 6 | 5 (启发函数/网格/障碍) | 3 (vs Dijkstra) | **14** |
| Johnson | 5 | 4 (负权/稠密 vs FW) | 3 | **12** |
| 最小费用最大流 | 8 | 5 (多商品/退化) | 3 (vs EK) | **16** |
| Hopcroft-Karp | 6 | 4 (完备性/边界) | 3 (vs Hungarian) | **13** |
| Edmonds 匹配 | 8 | 6 ( blossom/非二分) | 3 | **17** |
| 双向 BFS | 5 | 3 (奇偶层/不连通) | 3 (vs BFS) | **11** |
| **合计** | **38** | **27** | **18** | **~83** |

##### 验收标准

- [x] A* 在网格图中找到最优路径（与 Dijkstra 一致）
- [x] 最小费用最大流满足流量守恒 + 费用最优
- [x] Hopcroft-Karp 与 Hungarian 结果一致
- [x] Edmonds 匹配通过一般图测试集
- [x] 双向 BFS 访问节点数 ≤ 单向 BFS

##### 接口完善工作（本版本附带）

1. **算法 Trait 抽象**
   ```moonbit
   pub trait ShortestPathAlgorithm {
     find_shortest_path(G, source, target) -> PathResult
     find_distances(G, source) -> Array[Double]
   }

   pub trait MatchingAlgorithm {
     find_maximum_matching(G) -> MatchingResult
   }
   ```

2. **性能优化接口**
   - 为 CSR/CSC 存储提供专用快速路径
   - 启发函数的 Trait 约束

---

#### 📍 Version 0.13.0: 🛠️ 接口重构与 API 冻结准备

**发布日期**: 2026-07-17 (预计 2 周)
**主题**: 整理阶段 1 的技术债务，为 v1.0.0 冻结 API

##### 主要工作

1. **API 审计与 Breaking Changes 文档**
   - 扫描所有 `pub` 函数签名
   - 识别不稳定或设计不佳的 API
   - 编写 Migration Guide (v0.x → v1.0)

2. **结构体重构**
   - 合并重复的类型定义
   - 统一命名规范（如 `Result` 后缀）
   - 优化字段顺序（常用字段前置）

3. **Trait 体系优化**
   - 评估是否需要新增/删除/合并 Trait
   - 确保 LSP 原则不被违反
   - 为未来扩展预留 extension point

4. **性能回归测试建立**
   - 建立 Benchmark 基线（v0.13.0 性能数据）
   - 关键算法性能 profiling
   - 识别热点并记录优化机会

5. **文档同步更新**
   - AGENTS.md 更新至 v3.0.0
   - MEMORY.md 决策记录整理
   - README.mbt.md 算法表更新至完整版

##### 交付物

- [ ] `docs/migration_guide.md` - API 迁移指南
- [ ] `docs/api_audit_report.md` - API 审计报告
- [ ] `benchmarks/baseline_v0.13.0.csv` - 性能基线数据
- [ ] Git Tag: v0.13.0

##### 验收标准

- [ ] 100% 公开 API 有文档注释
- [ ] Breaking Changes 完整列出并有迁移路径
- [ ] Benchmark 基线已建立
- [ ] 所有文档一致性检查通过

---

### 阶段 2: 优化 + 结构体/接口调整

> **时间范围**: 2026 Q3 (7月-8月)
> **目标版本**: v0.14.0 → v0.15.0
> **核心产出**: 性能优化 + 内存优化 + API 稳定

---

#### 📍 Version 0.14.0: ⚡ 性能优化专项

**发布日期**: 2026-07-31 (预计 2 周)
**主题**: 让关键算法在生产环境跑得更快

##### 优化重点

1. **存储层优化**
   - CSR/CSC 批量操作 SIMD 向量化探索
   - AdjList 缓存友好的内存布局调整
   - Matrix 稀疏存储支持（>50% 零元素时自动转换）

2. **算法级优化**
   - Dijkstra 使用斐波那契堆（理论改进）
   - Dinic 当前弧优化 (current arc optimization)
   - Louvain 精细-grained 锁（未来并发准备）

3. **编译器级优化**
   - 内联关键路径函数
   - 减少 dynamic dispatch
   - 利用 MoonBit 的 native 后端特性

##### 交付物

- [ ] 性能对比报告（优化前/后 Benchmark）
- [ ] 热点函数列表及优化措施
- [ ] 内存占用对比报告
- [ ] Git Tag: v0.14.0

---

#### 📍 Version 0.15.0: 🔧 API 冻结候选

**发布日期**: 2026-08-14 (预计 2 周)
**主题**: 最终 API 敲定，进入稳定期

##### 主要工作

1. **API 最终审查**
   - 确认所有公开 API 符合 semver 规范
   - 标记 `@deprecated` 的 API（如有）
   - 冻结 Trait 方法签名

2. **向后兼容性保证**
   - 编写兼容性测试套件
   - 确保 v0.15.0 的代码可在 v1.0.0 无修改运行

3. **Release Candidate 准备**
   - 生成 API Reference 文档
   - 准备 Changelog 初稿
   - 确认版本号升至 v1.0.0-rc.1

##### 交付物

- [ ] API Reference 文档（自动生成或手动整理）
- [ ] 兼容性测试套件 (compat_test.mbt)
- [ ] Git Tag: v0.15.0 (= v1.0.0-rc.1)

---

### 阶段 3: 工程化 → v1.0.0

> **时间范围**: 2026 Q3 (8月-9月初)
> **目标版本**: v1.0.0 正式发布 🚀
> **核心产出**: 生产级质量保证 + 发布流程

---

#### 📍 Version 1.0.0-rc.2: 🔄 CI/CD 上线

**发布日期**: 2026-08-28 (预计 2 周)

##### 主要工作

1. **GitHub Actions Pipeline**
   ```
   PR/Push 触发:
     ├─ Lint: moon fmt --check
     ├─ Type Check: moon check (全量零错误)
     ├─ Test: moon test (全量通过 + 覆盖率报告)
     ├─ Build: moon build --target {native,wasm,js}
     └─ Docs: 文档生成 + 一致性检查
   ```

2. **自动化质量门禁**
   - 代码覆盖率 ≥ 85%（核心模块 ≥ 95%）
   - Benchmark 回归检测（性能下降 > 5% 时告警）
   - API breaking change 自动检测

3. **贡献者基础设施**
   - CONTRIBUTING.md 贡献者指南
   - Issue/PR 模板
   - Code Review 检查清单

##### 交付物

- [ ] `.github/workflows/ci.yml` - CI 配置
- [ ] `.github/workflows/benchmark.yml` - 性能回归检测
- [ ] `CONTRIBUTING.md` - 贡献指南
- [ ] GitHub 绿色 badge 显示在 README

---

#### 📍 Version 1.0.0: 🎉 正式发布

**发布日期**: 2026-09-11 (预计 2 周)

##### 发布物料

1. **CHANGELOG.md v1.0.0 章节**
   - ✨ 主要新功能（社交网络分析/I/O/经典算法增强）
   - 📊 统计数据（773+ tests / 40+ 算法 / 15 模块）
   - 🔄 Migration Guide 链接
   - 🙏 致谢贡献者

2. **GitHub Release**
   - Release Notes（专业排版）
   - 二进制下载链接（native/wasm/js）
   - 安装指南更新

3. **包发布**
   - mooncakes.io 发布配置（如可用）
   - 版本 tag: v1.0.0

4. **示例项目集合** (可选但推荐)
   - 3-5 个完整可运行示例
   - 覆盖主要使用场景

##### 验收标准（最终质量门禁）

- [ ] `moon check` 零错误零警告 ✅
- [ ] `moon test` 全部通过（773+ tests, 0 failure）✅
- [ ] 覆盖率 ≥ 85%（核心模块 ≥ 95%）✅
- [ ] 文档覆盖率 100%（所有公开 API 有注释）✅
- [ ] CI Pipeline 绿色 ✅
- [ ] Benchmark 基线已建立 ✅
- [ ] Breaking Changes 文档完整 ✅
- [ ] Examples 全部可运行 ✅
- [ ] AGENTS.md / MEMORY.md 已更新至最新状态 ✅

---

### 阶段 4: 拓展和高级算法

> **时间范围**: 2026 Q4+
> **目标版本**: v1.1.0 → v1.3.0+
> **核心产出**: 前沿探索 + 生态扩展

---

#### 📍 Version 1.1.0: 🌐 高级图机器学习基础

**预计时间**: 2026 Q4 (10月-11月)

##### 可能的功能

- [ ] Node2Vec / DeepWalk 图嵌入算法
- [ ] 图神经网络 (GNN) 可行性 PoC
- [ ] WebAssembly 加速探索（SIMD/WASM GC）

---

#### 📍 Version 1.2.0: 📈 大规模图处理

**预计时间**: 2026 Q4 - 2027 Q1

##### 可能的功能

- [ ] 外部存储支持（内存映射文件/磁盘溢出）
- [ ] 分布式图计算接口设计
- [ ] 1M+ 节点的性能优化

---

#### 📍 Version 1.3.0+: 🚀 生态与社区

**预计时间**: 2027+

##### 可能的功能

- [ ] 交互式 Demo（Wasm Playground）
- [ ] Fuzz Testing 集成
- [ ] 多语言绑定（如有需求）
- [ ] 成为 MoonBit 官方推荐图算法库

---

## 📈 版本总览表

| 版本 | 主题 | 新增模块 | 新增测试 | 累计测试 | 关键里程碑 |
|------|------|:--------:|:--------:|:--------:|------------|
| **v0.9.0** | P5 完成 | 5 (euler→hamiltonian) | 92 | 551 | 🎉 图论核心完成 |
| **v0.10.0** | 🔍 社交网络分析 | 3 (pagerank/centrality/community) | 105 | **588** | 🎉 高级分析能力 |
| **v0.11.0** | 📊 数据交换 | 1 (io) + stats 工具 | 42 | **630** | 🎉 I/O 生态打通 |
| **v0.12.0** | 🚀 经典算法增强 | 5 (a*/费用流/hk/edmonds/双向bfs) | 71 | **701** | 🎉 基础算法补齐 |
| **v0.13.0** | 🛠️ 接口重构 | — | — | **~771** | API 冻结准备 |
| **v0.14.0** | ⚡ 性能优化 | — | — | **~771** | 生产级性能 |
| **v0.15.0** | 🔧 API 冻结 | — | — | **~771** | RC 候选 |
| **v1.0.0** | 🎉 正式发布 | — | — | **~771+** | 🚀 生产就绪 |
| **v1.1.0+** | 🌐 高级拓展 | TBD | TBD | TBD | 前沿探索 |

---

## ⚠️ 风险评估与缓解策略

### 🔴 高风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|:----:|---------|
| **v0.10.0 工作量过大** (3 大模块) | 延期 1-2 周 | 中 | 拆分为 v0.10.0-alpha (PageRank) + v0.10.0 (全部) |
| **Edmonds 匹配复杂度高** | 可能推迟到 v0.13.0 | 中 | 降级为 P2，先用 Hopcroft-Karp 满足大部分场景 |
| **MoonBit 语言变更导致重构** | API breaking changes | 低 | 密切跟踪 changelog；抽象层隔离 |

### 🟡 中风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|:----:|---------|
| **DOT 解析器 bug** | I/O 功能不稳定 | 中 | 先实现子集，参考 NetworkX test suite |
| **性能优化效果不明显** | v0.14.0 价值降低 | 低 | 提前 profiling，只优化确认的热点 |
| **文档滞后于代码** | 用户困惑 | 中 | 强制"代码+测试+文档"原子提交 |

### 🟢 低风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|:----:|---------|
| **测试覆盖率不足** | 边界 case bug | 低 | 每个 module 要求 ≥ 85% 覆盖率 |
| **Benchmark 数据波动** | 误判回归 | 低 | 多次运行取中位数 + 固定测试环境 |

---

## 💡 开发节奏建议

### 每日工作流

```
上午: 实现 1 个算法函数 + 核心逻辑
下午: 编写对应测试 + 调试
傍晚: 文档注释 + git commit
```

### 每周里程碑

```
周五: 集成测试 + 代码审查 + 周报
周末: (可选) 技术调研/阅读论文
```

### 双周发布节奏

```
第 1 周结束: Alpha 版本 (内部测试)
第 2 周结束: 正式版本 + Git Tag + Release Notes
```

---

## 🎯 下一步行动（立即执行）

### 本周任务（Week of 5.26 - 6.01）

1. **[P0]** 🎉 v0.12.0 经典算法增强已发布（A* / 双向 BFS / Hopcroft-Karp / 最小费用最大流 / Edmonds 匹配）
2. **[P0]** 开始 v0.13.0 接口重构与 API 冻结准备工作
3. **[P1]** 更新 TODO.md 规划 v0.13.0 详细任务分解
4. **[P1]** 调研 v0.13.0 API 审计范围和方法

### 关键决策点

- [x] **ROADMAP 重构**: 采用方案C（功能集群）+ 小步快跑 ✅
- [x] **I/O 模块位置**: 放在 `src/io/` ✅
- [x] **PageRank 实现**: 支持 personalized/damping factor 配置 ✅
- [x] **DOT/JSON 格式**: 状态机解析 + 递归下降 ✅
- [x] **v0.12.0 算法优先级**: A*/双向BFS/费用流/Hopcroft-Karp/Edmonds匹配 ✅

---

## 📈 成功度量指标

### 技术指标

| 指标 | 当前值 (v0.12.0) | 目标值 (v1.0.0) | 衡量方式 |
|------|:---------------:|:---------------:|---------|
| **测试总数** | 701 | **≥ 773** | `moon test` |
| **代码覆盖率** | ~82% | **≥ 85%** | `moon coverage analyze` |
| **算法数量** | 43+ | **40+** | 统计 pub fn 数量 |
| **文档完整度** | 90% | **100%** | 人工审计 + CI check |
| **构建时间** | < 30s | < 60s（含 benchmark） | CI 日志 |
| **wasm 体积** | ~900KB | **< 1MB** | `moon build --target wasm` |

### 社区指标

| 指标 | 当前值 | 目标值 (v1.0.0 后 3 个月) | 衡量方式 |
|------|:-----:|:------------------------:|---------|
| **GitHub Stars** | — | **≥ 50** | GitHub API |
| **月下载量** | — | **≥ 100** | mooncakes.io 统计 |
| **Contributors** | 1 | **≥ 3** | GitHub 贡献者列表 |
| **Open Issues** | 0 | **≤ 10**（及时关闭） | Issue tracker |
| **PR 合并率** | — | **≥ 80%** | GitHub 统计 |

---

## 📚 相关文档

- **详细设计文档**: [docs/design/roadmap_v2_redesign_2026-05-25.md](design/roadmap_v2_redesign_2026-05-25.md) （本次重构的完整设计决策）
- **架构总览**: [docs/design/graph_trait_and_module_architecture.md](design/graph_trait_and_module_architecture.md)
- **编码规范**: [AGENTS.md](../AGENTS.md) （Top 10 陷阱 + 错误速查）
- **项目记忆**: [MEMORY.md](../MEMORY.md) （关键决策记录）
- **更新日志**: [CHANGELOG.md](../CHANGELOG.md) （版本历史）
- **TODO 清单**: [TODO.md](TODO.md) （任务分解）

---

## 🙏 致谢与参考

本路线图参考了以下项目的成熟实践：

- **[NetworkX](https://networkx.org/)** (Python) — 算法分类与优先级
- **[petgraph](https://github.com/petgraph/petgraph)** (Rust) — Trait 设计理念
- **[JGraphT](https://jgrapht.org/)** (Java) — 模块化架构
- **[LEMON](https://lemon.cs.elte.hu/)** (C++) — 性能优化思路

---

## 📝 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| **v2.0.0** | 2026-05-25 | 🎉 **重大重构**: 采用方案C（功能集群）+ 四阶段规划 + 小步快跑，优先算法完整性而非工程化 |
| **v1.0.0-draft** | 2026-05-23 | 初始版本：基于 v0.5.0 现状重新规划，聚焦 v1.0.0 生产就绪目标 |

---

<div align="center">

**🎯 让我们一起打造 MoonBit 最强的图算法库！**

*最后更新: 2026-05-25 | 维护者: @morning-start | 下次评审: 2026-06-25*

</div>
