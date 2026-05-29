# Project Memory

## 项目基础

- **模块**: `morning-start/mbtgraph`
- **语言**: MoonBit
- **协议**: MIT ✅ (2026-05-23 从 MIT 更改)
- **版本**: v0.14.0 (⚡ 性能优化已发布)
- **架构**: MoonBit 包按目录组织，每个目录含 `moon.pkg` 声明依赖
- **总测试数**: **736+ tests** (全通过 ✅)
- **算法模块**: **15 子模块** (P0-P5 + 社交网络分析) + **~49 算法** + **I/O 模块** (DOT/JSON/统计)
- **Git Tags**: v0.5.0 → v0.6.0 → v0.7.0 → v0.8.0 → v0.9.0 → v0.10.0 → v0.11.0 → v0.12.0 → v0.13.0 → v0.14.0

## 图存储架构

### Trait 分层体系（5 层）

采用 5 层 trait 架构，遵循 SOLID 原则（特别是 LSP 和 ISP）：

```
GraphReadable          ← 基础只读（12 方法，所有存储都实现）
├── GraphWritable      ← 可写（+5 方法，仅动态存储；CSR 故意不实现 LSP）
├── GraphDirected      ← 有向图入边查询（+6 方法）
│   └── GraphFull     ← 完整别名（= Writable + Directed）
└── GraphBatchReadable ← 批量优化（+2 方法，CSR/CSC 专用）
```

**核心决策**:
- CSR/CSC 等只读存储**不实现** `GraphWritable`，避免违反里氏替换原则
- 算法使用 trait 约束 `[G : @core.GraphReadable]` 而非具体类型
- 无向图采用**半存储优化**：邻接表用左上角三角存储，矩阵用上三角存储
- **v0.13.0 移除 GraphEdgeIterable**（仅 3 种存储实现，零算法使用；Kruskal 内部自行排序边）
- **v0.13.0 参数命名统一**：全部 `pub fn` 图参数统一为 `graph`

### 存储层完整清单

```
lib/storage/
├── 有向图 (3)
│   ├── directed_adj_list.mbt     ⭐ 默认推荐 | Readable + Writable + Directed
│   ├── directed_matrix.mbt       小规模稠密图 | Readable + Writable + Directed
│   └── edge_list.mbt            Kruskal 友好 | Readable + Writable
│
├── 无向图 (3)
│   ├── undirected_adj_list.mbt   ⭐ 半存储优化 | Readable + Writable
│   ├── undirected_matrix.mbt     上三角优化    | Readable + Writable
│   └── undirected_edge_list.mbt  无向边集       | Readable + Writable
│
├── 只读高性能 (2)
│   ├── csr.mbt                  亿级节点       | Readable + BatchReadable
│   └── csc.mbt                  入边密集       | Readable + BatchReadable
│
└── 工具 (3)
     ├── converter.mbt            8 个泛型转换函数
     ├── shared_helpers.mbt       6 个公共辅助函数 (find_max_node_id/int_max 等)
     └── README.md                包文档
```

### 包结构

```
lib/
├── core/          # 基础类型(3) + trait定义(5) + 错误类型(1) + 测试(64)
├── storage/       # 存储实现(8结构体) + 转换器(8) + 工具(6) + 测试(~103) + 文档
├── algo/          # 图算法模块 ⭐ v0.13.0 全部完成 (15 子模块, 736 tests)
│   ├── traversal/      # 遍历 (BFS/DFS/环检测/拓扑/双向BFS) — ~58 tests ✅
│   ├── generators/     # 图生成器 (P0) — 16 函数, 56 tests ✅
│   ├── shortest_path/  # 最短路径 — Dijkstra/BF/FW/A*/Johnson/SPFA/双向Dij/Yen's, 76 tests ✅
│   ├── mst/            # 最小生成树 (P2) — Kruskal/Prim, 16 tests ✅
│   ├── connectivity/   # 连通性 — CC/Tarjan/Kosaraju/BCC, 26 tests ✅
│   ├── flow/           # 网络流 (P3) — Edmonds-Karp + Dinic + 费用流, 33 tests ✅
│   ├── matching/       # 图匹配 (P4) — Hungarian/HK/Edmonds, 21 tests ✅
│   ├── euler/          # 欧拉路径 (P5-A) — Hierholzer 有向/无向, 22 tests ✅
│   ├── cutpoints/      # 割点与桥 (P5-B) — Tarjan DFN/Low, 15 tests ✅
│   ├── coloring/       # 图着色 — Greedy/WP/DSATUR/Exact/边着色, 29 tests ✅
│   ├── clique/         # 团/独立集/顶点覆盖 (P5-D) — Bron-Kerbosch, 14 tests ✅
│   ├── hamiltonian/    # 哈密顿/TSP (P5-E) — Backtrack+NN+Held-Karp, 20 tests ✅
│   ├── pagerank/       # PageRank 幂法迭代, 15 tests ✅
│   ├── centrality/     # 中心性分析 (度/介数/接近/特征向量), 45 tests ✅
│   ├── community/      # 社区检测 (Louvain/标签传播), 35 tests ✅
│   └── integration/    # 跨模块集成测试, 10 tests ✅
└── io/            # I/O 模块 v0.11.0 (DOT + JSON + 图统计, 42 tests)
    ├── dot.mbt               # DOT 格式读写
    ├── json_serializer.mbt   # JSON 格式读写
    ├── graph_stats.mbt       # 图统计工具
    ├── types.mbt             # 错误类型与统计类型
    └── io_test.mbt           # 42 测试
```

### 存储选型速查

| 需求 | 推荐 |
|------|------|
| 通用有向图 | DirectedAdjList (`new_directed()`) |
| 通用无向图 | UndirectedAdjList (`new_undirected()`) |
| V<1000 稠密图 | DirectedMatrix (`new_directed_matrix(cap)`) |
| V>10K 静态大图 | CSRGraph (`to_csr(g)`) |
| 入边密集查询 | CSCGraph (`to_csc(g)`) |
| Kruskal/MST | UndirectedEdgeList / UndirectedAdjList |

### 向后兼容

- 保留现有 `AdjGraph` 作为类型别名：`pub type Graph = AdjacencyListGraph[Double, Double]`

## 编码规范

- **块风格**: 代码块以 `///|` 分隔，块顺序无关
- **废弃代码**: 移至 `deprecated.mbt`
- **测试**: 双轨制 — 黑盒 `*_test.mbt` + 白盒 `*_wbtest.mbt`
- **接口文件**: 修改后运行 `moon info` 更新 `.mbti`，检查 diff 确认变更可见性
- **强制规则 (R1-R7)**: 见 AGENTS.md §编码规范

### MoonBit 语法陷阱（已验证）

| 规则 | 正确 | 错误 | 编译错误 |
|------|------|------|---------|
| 结构体构造 | `Node::{ id, data }` | `Node { id, data }` | E3002 |
| Int→Double | `x.to_double()` | `x.to_float()` | E4014 |
| 科学计数法 | `0.000001` | `1e-300` | Parse error |
| 无 Show 时断言 | `assert_true(a == b)` | `assert_eq(a, b)` | 缺少 Show impl |
| Option 匹配 | 不需要 `_ => ()` 分支 | 添加冗余分支 | — |
| Impl 参数 | `(self)` | `mut self` | E3002 |
| For 循环 | 先绑定再 match | `for (a,b) in ...` | E3002 |
| 跨包类型可见性 | `pub(all) struct` | `pub struct` | E4018 (blackbox test) |
| 跨包 trait 可见性 | `pub impl Trait for T` | `impl Trait for T` | E4063 (一致性检查) |
| 二维数组初始化 | 逐行 push 独立创建 | `Array::make(n, Array::make(n, x))` | 数据污染 bug |
| **嵌套泛型** ⭐ | `Array[Array[T?]]` | `Array[Array[T?>>` | Parse error (>> 冲突) |
| **保留字命名** ⭐ | `net`, `graph`, `data` | `fn`, `var` | Parse error / deprecated |
| **返回值消费** ⭐ | `let x = func(x)` 或 `ignore()` | `func(x) \|> ignore` (非 Unit 时) | E4139 |
| **废弃语法** ⭐ | `let mut` / `while true {}` | `var` / `loop {}` | Deprecated warning/error |
| **数组引用副作用** ⭐ | 算法前深拷贝 | 直接修改输入数组 | 测试失败 (不可变性违反) |
| **has_edge 不存在** ⭐ | `contains_edge()` | `has_edge()` | 未绑定方法 |
| **neighbors 返回 Iter** ⭐ | `.to_array()` 转换 | 直接 for 遍历 | 类型不匹配 |

## 测试状态

### 当前覆盖率 (v0.13.0 - 🛠️ 接口重构 + P0/P1 补齐)

**总计**: **736 tests** (全通过 ✅) | **15 算法模块** | **~49 算法实现** | **I/O 模块**

| 包 | 黑盒 | 白盒 | 总计 | 状态 |
|----|:----:|:----:|:----:|:----:|
| core | 45 | 19 | **64** | ✅ 全通过 (-4 EdgeIterable 测试移除) |
| storage | 88 | 15 | **~103** | ✅ 全通过 (-4 EdgeIterable 测试移除) |
| algo (P0-P4) | **325** | **0** | **325** | ✅ 全通过 (+35 v0.13.0) |
| ├─ traversal (+双向BFS) | ~58 | - | ~58 | ✅ |
| ├─ generators | 56 | - | 56 | ✅ |
| ├─ shortest_path (+Johnson/SPFA/双向Dij/Yen's) | ~76 | - | ~76 | ✅ +36 |
| ├─ mst | 16 | - | 16 | ✅ |
| ├─ connectivity (+BCC) | ~26 | - | ~26 | ✅ +5 |
| ├─ flow (+费用流) | ~49 | - | ~49 | ✅ |
| └─ matching (+HK+Edmonds) | ~51 | - | ~51 | ✅ |
| algo (P5) | **150** | **0** | **150** | ✅ 全通过 |
| ├─ euler (P5-A) | 22 | - | 22 | ✅ Hierholzer |
| ├─ cutpoints (P5-B) | 15 | - | 15 | ✅ Tarjan |
| ├─ coloring (P5-C + 边着色) | ~29 | - | ~29 | ✅ +8 |
| ├─ clique (P5-D) | 14 | - | 14 | ✅ Bron-Kerbosch |
| └─ hamiltonian (P5-E) | 20 | - | 20 | ✅ TSP+回溯 |
| algo (v0.10.0) | **95** | **10** | **105** | ✅ 全通过 |
| ├─ pagerank | 15 | - | 15 | ✅ 幂法迭代 |
| ├─ centrality | 45 | - | 45 | ✅ 4种中心性 |
| ├─ community | 35 | - | 35 | ✅ Louvain+标签传播 |
| └─ integration | - | 10 | 10 | ✅ 跨模块测试 |
| io (v0.11.0) | **42** | **0** | **42** | ✅ 全通过 |
| ├─ dot | 20 | - | 20 | ✅ 序列化+解析+往返 |
| ├─ json | 12 | - | 12 | ✅ 序列化+解析+往返 |
| └─ graph_stats | 10 | - | 10 | ✅ 基本+度分布+连通性 |
| root | 0 | 0 | 0 | — |
| **合计** | **762** | **44** | **806** | **✅ 736 passed** |

### P5 模块完成总结（2026-05-22）

| 模块 | 核心算法 | 测试数 | 复杂度 | Git Tag |
|------|---------|:-----:|:------:|---------|
| **Euler** (P5-A) | Hierholzer 欧拉路径/回路 | **22** | O(E) | v0.5.0 |
| **Cutpoints** (P5-B) | Tarjan 割点/桥检测 | **15** | O(V+E) | v0.6.0 |
| **Coloring** (P5-C) | Greedy/WP/DSATUR/Exact | **21** | O(V²)→O(k^V) | v0.7.0 |
| **Clique** (P5-D) | Bron-Kerbosch 最大团 | **14** | O(3^{V/3}) | v0.8.0 |
| **Hamiltonian** (P5-E) | 回溯+NN+Held-Karp TSP | **20** | O(V!)→O(2^V·V²) | v0.9.0 |
| **P5 合计** | **5 大类, 12 种算法** | **92** | — | — |

### Core 测试详情

| 文件 | 类型 | 数量 | 覆盖 |
|------|------|:----:|------|
| types_test.mbt | Blackbox | 24 | NodeId构造/Eq + Node构造/字段 + Edge构造/字段 + 组合 |
| error_test.mbt | Blackbox | 25 | 3变体×构造匹配 + Eq(11) + Result集成(7) |
| traits_wbtest.mbt | Whitebox | 19 | MockGraph 实现 5 Trait 共 25 方法 |

### Storage 测试详情

| 文件 | 类型 | 数量 | 覆盖 |
|------|------|:----:|------|
| directed_adj_list_test.mbt | Blackbox | 18 | CRUD + GraphDirected (in/out degree/neighbors) |
| undirected_adj_list_test.mbt | Blackbox | 14 | 双向语义 + 半存储优化 |
| matrix_test.mbt | Blackbox | 15 | DirectedMatrix + UndirectedMatrix O(1)查询 |
| edge_list_test.mbt | Blackbox | 13 | EdgeListGraph + UndirectedEdgeListGraph |
| csr_csc_test.mbt | Blackbox | 15 | CSRGraph/CSCGraph Builder模式 + batch操作 |
| converter_test.mbt | Blackbox | **16** | 有向转换(8) + 无向转换(5) + 语义转换(3) |
| helpers_wbtest.mbt | Whitebox | 13 | has_node/find_slot/remove_from_list/bubble_sort |

### 转换器架构（三层设计）

| 分组 | 约束 | 函数数 | 保护机制 |
|------|------|:------:|---------|
| **有向转换组** | `[G : GraphDirected]` | 5 | **编译期**保证源是有向图 |
| **无向转换组** | `[G : GraphReadable]` + `raise` | 3 | **运行时** `assert_true(!is_directed)` |
| **语义转换** | `[G : GraphReadable]` + `raise` | 2 | `as_undirected` / `as_directed` 显式跨边界 |

### MockGraph 设计要点（traits_wbtest）

- 使用 `node_cnt` 字段独立追踪节点计数（不依赖 nodes.length()）
- 支持 directed 标志位切换有向/无向模式
- remove_node() 级联删除关联边并递减 node_cnt
- bubble_sort_by_weight 用于内部排序实现

## 工具链

```bash
moon check               # 类型检查（零错误零警告）
moon test                # 运行全部测试 (736 tests)
moon fmt && moon info     # 格式化 + 更新 .mbti 接口文件
moon build --target <tgt> # 构建（wasm/js/native）
moon coverage analyze    # 覆盖率分析
```

## 关键决策记录

### 🎯 里程碑决策（按时间倒序）

| 日期 | 决策 | 原因 | 影响 |
|------|------|------|------|
| **2026-05-25** | **ROADMAP v2.0.0 重大重构 + 文档体系重建** 🚀 | 用户明确要求"先完成更多算法和功能，后续才处理发布和生态问题"，从工程化优先转向算法优先 | 四阶段规划(基础→优化→工程化→拓展) + 方案C功能集群 + 小步快跑(每2周) + docs目录整理(26→18文件) |
| **2026-05-25** | **创建 PROJECT_VISION.md + ARCHITECTURE.md** 📖 | 删除过时的 ARCHITECTURE(v0.1.0) 和 SRS(draft) 后需要替代文档 | 愿景文档回答"为什么做"，架构文档回答"怎么做"，两者互补 |
| **2026-05-25** | **AGENTS.md 升级至 v3.0.0** 📋 | 配合 ROADMAP v2 + 文档体系重建全面更新 | 新增快速入口导航、项目统计快照(三列对比)、完整文档索引(11个)、开发中模块展示(pagerank/centrality/community) |
| **2026-05-25** | **docs 目录整理 (删除12个文件)** 🧹 | 过时文档(ARCHITECTURE/sad/quality_report/srs) + 已完成模块设计(flow/generators等5个) + brainstorming历史产物(superpowers/) | 净减10文件(26→18)，保留8个详细竞品调研+3个核心design+ROADMAP/TODO/PROJECT_VISION/ARCHITECTURE |
| **2026-05-25** | **TODO.md 重写聚焦 v0.10.0** ✅ | 从旧Sprint格式改为基于新ROADMAP的任务分解 | 18个TASK(~38h/~95tests)：PageRank(5) + 中心性(6) + 社区检测(4) + 集成发布(3)，含两周时间线 |
| **2026-05-27** | **AGENTS.md 剥离动态元数据** 📋 | 版本号/日期/统计数导致频繁更新，委托给 CHANGELOG.md | 删除 7 块动态内容，~463→~376 行，降为低频更新 |
| **2026-05-27** | **UPDATE_GUIDE.md 同步降级 AGENTS.md** ✅ | AGENTS.md 改为稳定文档，不再随模块完成更新 | 从 P0→P2，仅架构变更时更新 |
| **2026-05-28** | **v0.13.0 接口重构 + P0/P1 发布** 🚀 | 4阶段完成：快速修复→P0算法→全面重构→P1补齐 | 新增 6 个算法(Johnson/SPFA/边着色/BCC/双向Dij/Yen's)，Trait 6→5层，参数统一，736 tests |
| **2026-05-29** | **v0.14.0 性能优化发布** ⚡ | 8/11 任务完成：heap O(n) 修复、CSR 快排、neighbors_with_weight、Louvain 重构、AdjList 批量操作、CSR 反向索引、Benchmark 框架、Dispatch 分析 | 性能基线建立，留 3 个 P3 延后 |
| **2026-05-28** | **移除 GraphEdgeIterable trait** ✅ | 仅 3 种存储实现，零算法使用，Kruskal 内部排序 | 减少维护负担，5层更清晰 |
| **2026-05-28** | **参数命名 g→graph 统一** ✅ | API 一致性审计发现约一半用 g 一半用 graph | 27+ pub fn 统一，提升可读性 |
| **2026-05-27** | **README.mbt.md 全面优化重写** 📝 | 对标 petgraph/NetworkX 最佳实践；删除 8 处未验证内容（性能星级/包大小/主观评价）| 517行→257行(-50%)；建立 README 撰写原则：首屏示例、零虚假、职责分离、数据驱动 |
| **2026-05-27** | **GitHub 仓库详情配置** 📝 | 用户填写 GitHub Edit repository details 表单 | Description/Topics/首页展示配置建议 |
| **2026-05-27** | **v0.13.0 接口重构分析完成** 📋 | 完成 API 审计、Trait 体系评估、代码冗余分析 | 发现 6 个关键问题：connectivity 命名不一致、GraphEdgeIterable 冗余、参数顺序不统一 |
| **2026-05-27** | **推荐分步重构方案 C** ✅ | 轻量修复→算法补齐→全面重构→P1 补齐，每步可交付 | 预计提前交付 |
| **2026-05-26** | **v0.12.0 经典算法增强发布** 🚀 | A* 启发式搜索 + 双向 BFS + Hopcroft-Karp + 最小费用最大流 + Edmonds 一般图匹配 | 5 个新算法, 630->701 tests |
| **2026-05-23** | **协议从 MIT 更改为 MIT** ✅ | 更宽松的开源协议，便于社区采纳和二次开发 | moon.mod.json + 全部文档同步 |
| **2026-05-23** | **Sprint任务体系重构** 🆕 | TODO.md 重写为 Sprint 格式（4个Sprint），聚焦 v1.0.0 生产就绪 | 提升项目管理效率 |
| **2026-05-23** | **Git Tags 版本管理建立** 🆕 | 为每个 P5 模块创建独立 minor 版本标签 | 清晰追踪模块完成节点 |
| **2026-05-23** | **文档更新规范体系建立** 🆕 | UPDATE_GUIDE.md 定义触发条件矩阵和一致性检查脚本 | Agent 自动化文档管理 |
| **2026-05-27** | **文档更新规范优化** ✅ | AGENTS.md 降为 P2，移除动态内容 | 减少 ~19% 体积，低频维护 |
| **2026-05-22** | **P5 图论核心算法扩展全部完成** 🎉 | Euler/Cutpoints/Coloring/Clique/Hamiltonian 共 5 模块, 92 tests | 算法库覆盖 NP-C/NP-Hard 场景 |

### 🔧 架构与设计决策

| 日期 | 决策 | 原因 |
|------|------|------|
| **2026-05-25** | **ROADMAP v2.0.0 四阶段规划** | **用户明确要求"先完成基础算法→优化→工程化→拓展"，废弃旧工程化优先路线图** |
| **2026-05-25** | **方案C功能集群 (版本主题制)** | **每个版本有清晰卖点：v0.10.0🔍社交分析 / v0.11.0📊数据交换 / v0.12.0🚀算法增强** |
| **2026-05-25** | **文档双轨制 (PROJECT_VISION + ARCHITECTURE)** | **愿景回答"为什么做"(战略层)，架构回答"怎么做"(技术层)，替代过时的SRS和旧ARCHITECTURE(v0.1.0)** |
| **2026-05-25** | **docs目录精简原则** | **删除标准：(1)过时(2)重复(3)已完成历史(4)草稿未完成；保留核心+归档详细调研** |
| **2026-05-27** | **AGENTS.md 精简为稳定文档** | **移除版本号/日期/统计/历史表，委托给 CHANGELOG.md，避免频繁更新** |
| 2026-05-08 | 4 层 trait 分层 → 6 层 | 新增 BatchReadable + EdgeIterable |
| **2026-05-28** | **6 层 trait → 5 层** | **移除 GraphEdgeIterable（零算法使用），简化架构** |
| 2026-05-08 | CSR 不实现 Writable | 里氏替换原则 (LSP) |
| 2026-05-17 | 无向图半存储优化 | 节省 ~50% 内存 |
| 2026-05-17 | 新增 CSC 格式 | 补齐调研文档，支持入边密集场景 |
| 2026-05-17 | converter 扩展至 8 函数 | 支持所有存储互转 |
| 2026-05-17 | storage struct 改 pub(all) + impl 改 pub | blackbox test 跨包可见性要求 (E4018/E4063) |
| 2026-05-17 | Matrix 构造改逐行初始化 | Array::make 二维数组共享 bug 修复 |
| 2026-05-17 | 转换器三层架构重构 | 有向(GraphDirected) + 无向(assert) + 语义(as_*) 分离 |
| **2026-05-28** | **共享辅助函数提取 find_max_node_id/int_max** | **消除全项目 ~16 个重复的 find_max_id 副本** |
| **2026-05-28** | **返回类型统一加 Result 后缀** | **ConnectedComponents→Result, SCC→Result，API 命名一致** |
| **2026-05-19** | **FlowNetwork 独立类型设计** | **流网络语义特殊（容量/流量矩阵），不强制适配 Graph trait** |
| **2026-05-19** | **Edmonds-Karp 算法选择** | **实现简洁（~40% code less），足够实用，为 Dinic 扩展预留接口** |
| **2026-05-19** | **深拷贝纯函数语义** | **算法修改输入数据时必须 deep_copy，保证原网络不被修改** |
| **2026-05-19** | **AGENTS.md v2.1.0 固化经验** | **Top10陷阱/算法开发流程/Git规范/错误速查扩展（避免重复踩坑）** |
| **2026-05-27** | **README 撰写原则建立** | **对标 petgraph/NetworkX：首屏示例、零虚假声明、职责分离(README≠API文档)、数据驱动(所有数字可验证)** |

## 算法复杂度速查表

| 类别 | 算法 | 时间复杂度 | 空间复杂度 | 模块 |
|------|------|:---------:|:---------:|------|
| **遍历** | BFS | O(V+E) | O(V) | traversal |
| | DFS | O(V+E) | O(V) | traversal |
| | 双向 BFS | O(b^{d/2}) | O(b^{d/2}) | traversal |
| **最短路径** | Dijkstra | O((V+E)log V) | O(V) | shortest_path |
| | Bellman-Ford | O(VE) | O(V) | shortest_path |
| | Floyd-Warshall | O(V³) | O(V²) | shortest_path |
| | A* 启发式搜索 | O(b^d) | O(b^d) | shortest_path |
| | Johnson 全源 | O(V²logV+VE) | O(V²) | shortest_path |
| | SPFA | O(kE) 平均 | O(V) | shortest_path |
| | 双向 Dijkstra | O((V+E)logV) | O(V) | shortest_path |
| | Yen's K短路 | O(K·V·(E+V·logV)) | O(K·V) | shortest_path |
| **MST** | Kruskal | O(E log E) | O(E) | mst |
| | Prim | O(V²) | O(V) | mst |
| **连通性** | 连通分量 | O(V+E) | O(V) | connectivity |
| | Tarjan SCC | O(V+E) | O(V) | connectivity |
| | Kosaraju SCC | O(V+E) | O(V) | connectivity |
| | BCC 双连通分量 | O(V+E) | O(V) | connectivity |
| **网络流** | Edmonds-Karp | O(VE²) | O(E) | flow |
| | Dinic | O(E√V) | O(V²) | flow |
| | 最小费用最大流 (SSP) | O(V·E·C) | O(V²) | flow |
| **匹配** | Hungarian | O(VE) | O(V+E) | matching |
| | Hopcroft-Karp | O(E√V) | O(V+E) | matching |
| | Edmonds (一般图匹配) | O(V³) | O(V²) | matching |
| **欧拉** | Hierholzer | O(E) | O(E) | euler |
| **割点/桥** | Tarjan | O(V+E) | O(V) | cutpoints |
| **着色** | Greedy/WP | O(V²) | O(V) | coloring |
| | DSATUR | O(V²+kV) | O(V) | coloring |
| | Backtracking Exact | O(k^V) | O(V) | coloring |
| | 边着色 (贪心) | O(VE) | O(V²) | coloring |
| **团** | Bron-Kerbosch | O(3^{V/3}) | O(V²) | clique |
| **哈密顿** | 回溯 | O(V!) | O(V) | hamiltonian |
| | TSP 最近邻 | O(V²) | O(V) | hamiltonian |
| | TSP Held-Karp | O(2^V·V²) V≤12 | O(2^V·V) | hamiltonian |
| **PageRank** | 幂法迭代 | O(kE) | O(N+E) | pagerank |
| **中心性** | 度 | O(V+E) | O(V) | centrality |
| | 介数 (Brandes) | O(VE) | O(V+E) | centrality |
| | 接近 | O(V(E+V)) | O(V²) | centrality |
| | 特征向量 | O(kE) | O(V+E) | centrality |
| **社区** | Louvain | O(N log N) | O(N+E) | community |
| | 标签传播 | O(kE) | O(V) | community |

## 开发效率基准

| 指标 | 典型值 |
|------|:-----:|
| 单模块开发耗时 | 30min - 1h |
| 平均测试数/模块 | 18 tests (P5 平均 18.4 tests) |
| commits/模块 | 3-5 |
| 首次编译通过率 | ~50% |
| 调试/实现比 | ~1:3 |

## 📋 下一步计划 (Sprint 1-4)

### Sprint 1: 生产就绪基础（当前阶段）

**目标**: v1.0.0-alpha 发布候选

| 任务ID | 任务 | 优先级 | 状态 |
|--------|------|:------:|:----:|
| **T01** | AGENTS.md 升级至 v2.5.0 (P5 经验固化) | P0 | ✅ 完成 |
| **T02** | GitHub Actions CI/CD 流水线 (fmt → check → test) | P0 | 🔄 待开发 |
| **T03** | API 冻结审查 (扫描所有 `pub` 函数签名稳定性) | P0 | 🔄 待执行 |
| **T04** | 集成测试 (跨模块端到端场景验证) | P1 | 🔄 待编写 |

### Sprint 2: 文档与生态完善

**目标**: v1.0.0-beta 文档完整

| 任务ID | 任务 | 优先级 | 状态 |
|--------|------|:------:|:----:|
| **T11** | P5 模块 README 补充 (5个模块文档完善) | P1 | 🔄 待开发 |
| **T12** | 官方教程编写 (快速入门 + 5 个典型场景) | P1 | 🔄 待编写 |
| **T13** | 性能基准测试框架 (Benchmark Suite) | P2 | 🔄 待设计 |

### Sprint 3: 高级特性与优化

**目标**: v1.0.0-rc 功能完整

| 任务ID | 任务 | 优先级 | 状态 |
|--------|------|:------:|:----:|
| **T21** | 序列化/反序列化支持 (JSON/二进制格式) | P2 | 🔄 待调研 |
| **T22** | 图可视化输出 (DOT/Graphviz 集成) | P2 | 🔄 待设计 |
| **T23** | 并发安全存储实现 (线程安全邻接表) | P3 | 🔄 待评估 |

### Sprint 4: 发布准备

**目标**: v1.0.0 正式发布 🚀

| 任务ID | 任务 | 优先级 | 状态 |
|--------|------|:------:|:----:|
| **T31** | CHANGELOG 完善至 v1.0.0 | P0 | 🔄 待整理 |
| **T32** | npm/moonpkg 发布流程配置 | P0 | 🔄 待配置 |
| **T33** | 示例项目集合 (3-5 个完整示例) | P1 | 🔄 待开发 |
| **T34** | 社区贡献指南 (CONTRIBUTING.md) | P1 | 🔄 待编写 |

---

## 📊 项目统计总览（v0.14.0）

| 维度 | 数值 | 说明 |
|------|:----:|------|
| **版本** | **v0.14.0** | ⚡ 性能优化 |
| **Trait 层数** | **5** | 移除 GraphEdgeIterable |
| **算法模块** | **15** | P0(1) + P1(1) + P2(2) + P3(1) + P4(1) + P5(5) + 社交网络分析(3) + 集成(1) |
| **I/O 模块** | **1** | DOT + JSON + 图统计 (42 tests) |
| **算法总数** | **~49** | 含 Johnson/SPFA/边着色/BCC/双向Dij/Yen's |
| **测试用例** | **736+** | 跨模块全部通过 ✅ |
| **性能基线** | **19 行** | 4 种规模 × 5 算法 |
| **Git Tags** | **10+** | v0.5.0 → v0.14.0 |
| **文档覆盖率** | **100%** | 15/15 模块有 README, 设计文档完整 |
| **协议** | **MIT** | 2026-05-23 确认 |
| **状态** | **🎉 Beta 质量** | 可用于生产环境测试 |

---

## 📝 2026-05-25 工作日志 (ROADMAP v2 规划日)

### 当日基线 (v0.9.0)

| 维度 | 数值 |
|------|:----:|
| 版本 | v0.9.0 |
| 算法模块 | 12 (P0-P5 全部完成) |
| 测试用例 | **551** (全通过 ✅) |
| Git Tags | 5 (v0.5.0→v0.9.0) |

### 核心产出

| # | 产出 | 类型 | 说明 |
|---|------|:----:|------|
| 1 | **ROADMAP.md v2.0.0** | 重写 | 四阶段规划 + 方案C功能集群 + 9版本计划(v0.10→v1.0) |
| 2 | **docs/design/roadmap_v2_redesign_2026-05-25.md** | 新建 | 完整设计决策文档(~500行) |
| 3 | **docs/PROJECT_VISION.md** | 新建 | 项目愿景与意义(回答"为什么做") |
| 4 | **docs/ARCHITECTURE.md** (重建) | 重建 | 架构总览v1.0.0(基于v0.9.0实际代码+未来设想) |
| 5 | **docs/TODO.md** | 重写 | 聚焦v0.10.0的18个TASK分解(~38h/~95tests) |
| 6 | **AGENTS.md v3.0.0** | 升级 | 快速入口+文档索引+统计快照+开发中模块展示 |
| 7 | **docs/reference/library_survey.md** | 新建 | 竞品汇总表(8个库对比) |
| 8 | **删除12个文件** | 整理 | docs目录从26→18文件(-30%) |

### 关键决策

1. **方向调整**: 工程化优先 → **算法完整性优先**（用户决策）
2. **发布节奏**: 4个大Sprint → **小步快跑每2周1版**
3. **版本组织**: 按时间平铺 → **方案C功能集群**(🔍📊🚀主题制)
4. **文档策略**: 过时文档保留 → **删除/合并/精简三原则**

### 算法缺口识别

| 优先级 | 缺口算法 | 数量 | 计划版本 |
|--------|---------|:----:|:-------:|
| P0 | A*/Johnson/费用流/HK/Edmonds/双向BFS | 6 | v0.12.0 |
| P1 | PageRank/4种中心性/Louvain/标签传播 | 7 | **v0.10.0** ← 当前目标 |
| P2 | DOT/JSON/图统计 | 3 | v0.11.0 |
