# mbtgraph — MoonBit 图算法库

MoonBit 生态首个生产级图算法库：8 种存储 + 5 层 Trait + ~49 算法 + 高级图分析。

## 📖 快速入口

| 想了解什么？ | 去哪里？ |
|-------------|---------|
| **项目愿景与意义** | [docs/PROJECT_VISION.md](docs/PROJECT_VISION.md) |
| **架构设计与技术细节** | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| **版本规划与路线图** | [docs/ROADMAP.md](docs/ROADMAP.md) |
| **当前任务清单** | [docs/TODO.md](docs/TODO.md) |
| **本文档 (Agent 规范)** | 👈 **你在这里** |

---

## 开发环境

```bash
moon fmt && moon info        # 格式化 + 更新接口
moon test                    # 运行测试
moon check lib/algo/pagerank  # 检查单模块编译
```

---

## 技术栈

| 组件 | 技术 | 说明 |
|------|------|------|
| 语言 | MoonBit | native/wasm/js 三后端 |
| 架构 | Trait-based (6 层) | GraphReadable → Writable → Directed → Full |
| 存储实现 | 8 种结构 | AdjList/Matrix/EdgeList/CSR/CSC (+ 有向/无向变体) |
| 算法模式 | 双轨制 | Trait 兼容型 + 独立类型型 (如 FlowNetwork) |
| 测试体系 | Blackbox + Whitebox | `*_test.mbt` + `*_wbtest.mbt` |

---

## 项目结构

```
lib/
├── core/                        # 🔵 基础定义层
│   ├── types.mbt               # NodeId, Node, Edge, Weight
│   ├── traits.mbt              # 6 层 Trait 定义
│   └── error.mbt               # GraphError 错误类型
│
├── storage/                     # 🟢 存储实现层 (8 种)
│   ├── directed_adj_list.mbt   # ⭐ 有向邻接表
│   ├── undirected_adj_list.mbt # ⭐ 无向邻接表
│   ├── directed_matrix.mbt     # 有向邻接矩阵
│   ├── undirected_matrix.mbt   # 无向邻接矩阵
│   ├── edge_list.mbt           # 有向边集数组
│   ├── undirected_edge_list.mbt# 无向边集数组
│   ├── csr.mbt                 # 压缩稀疏行
│   ├── csc.mbt                 # 压缩稀疏列
│   ├── converter.mbt           # 8 个泛型转换函数
│   └── shared_helpers.mbt      # 公共辅助函数
│
├── algo/                        # 🟣 算法模块层
│   ├── traversal/              # 图遍历 (BFS/DFS/环检测/拓扑排序/双向BFS)
│   ├── generators/             # 图生成器
│   ├── shortest_path/          # 最短路径 (Dijkstra/Bellman-Ford/Floyd/A*)
│   ├── mst/                    # 最小生成树 (Kruskal/Prim)
│   ├── connectivity/           # 连通性 (CC/Tarjan SCC/Kosaraju SCC)
│   ├── flow/                   # 网络流 (Edmonds-Karp/Dinic/最小费用最大流)
│   ├── matching/               # 图匹配 (Hungarian/Hopcroft-Karp/Edmonds)
│   ├── euler/                  # 欧拉路径 (Hierholzer)
│   ├── cutpoints/              # 割点与桥 (Tarjan)
│   ├── coloring/               # 图着色 (Greedy/WP/DSATUR/Exact)
│   ├── clique/                 # 团检测 (Bron-Kerbosch)
│   ├── hamiltonian/            # 哈密顿/TSP (回溯/NN/Held-Karp)
│   ├── pagerank/               # PageRank
│   ├── centrality/             # 中心性分析
│   ├── community/              # 社区检测 (Louvain/标签传播)
│   └── integration/            # 跨模块集成测试
│
├── io/                          # 🟠 I/O 模块层
│   ├── types.mbt               # IOError + 统计类型
│   ├── dot.mbt                 # DOT 格式读写
│   ├── json_serializer.mbt     # JSON 格式读写
│   ├── graph_stats.mbt         # 图统计工具
│   └── io_test.mbt             # 集成测试
│
└── algo/ 下各模块对应 MoonBit 算法开发标准模板
```

**关键入口**: 新类型→`types.mbt` | 新trait→`traits.mbt` | 新存储→参考 `directed_adj_list.mbt` | 新算法→参考 `flow/` 或任意 P5 模块 | 新 I/O 格式→参考 `dot.mbt`

**当前进度**: 详见 [docs/TODO.md](docs/TODO.md) | 完整统计: [CHANGELOG.md](CHANGELOG.md) | 算法全景: [docs/algorithms_catalog.md](docs/algorithms_catalog.md)

---

## 架构速查

### Trait 分层 (6 层)

```
GraphReadable (基础只读, 12 方法, 所有存储)
├── GraphWritable     (可写, +5 方法, 动态存储专属)
├── GraphDirected     (有向, +6 方法, 入边查询)
│   └── GraphFull    = Writable + Directed (便捷别名)
├── GraphBatchReadable(批量, +2 方法, CSR/CSC 专属)
└── GraphEdgeIterable (边排序, +1 方法, Kruskal 友好)
```

**详细设计**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

### 存储选型速查

| 场景 | 推荐 | Trait | 复杂度 |
|------|------|:----:|--------|
| 通用稀疏图 | `DirectedAdjList` ⭐ | R+W+D+E | 邻居 O(k) |
| 无向通用图 | `UndirectedAdjList` ⭐ | R+W+E | 半存储 -50% |
| 稠密小图 (<1K) | `DirectedMatrix` | R+W+D | O(V²) 空间 |
| MST/Kruskal | `EdgeList` | R+W+E | O(E log E) |
| 大规模静态图 (>100K) | `CSR` | R+B | 缓存友好 |
| 入边密集查询 | `CSC` | R+B | in_degree O(1) |

### 算法模式

```moonbit
// 模式 A: Trait 兼容型 (大多数算法)
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult { ... }

// 模式 B: 独立类型型 (流网络等特殊语义)
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)  // 链式赋值
let result = edmonds_karp(net, 0, 5)
```

---

## 编码规范

### 强制规则（必须遵守）

| # | 规则 | ✅ 正确 | ❌ 错误 |
|---|------|--------|--------|
| R1 | 使用 `@core.` 完全限定名 | `@core.NodeId(0)` | use 别名 |
| R2 | Impl 用 `(self)` 非 `mut self` | `let g = self` | `mut self` |
| R3 | 可变性按需声明 | 只改字段→`let g` | 需重新赋值→`let mut g` |
| R4 | 可见性正确选择 | 核心类型→`pub(all)` | trait→`pub(open)trait` |
| R5 | For 循环不直接解构元组 | 先绑定再 match | `for (a,b) in ...` |
| R6 | 嵌套泛型用 `]]` 结尾 | `Array[Array[Double?]]` | `Array[Array[Double?>>` |
| R7 | 避免保留字命名 | `net`, `graph` | `fn`, `var` |

### 推荐惯例

- Match 多语句用 `{}` 包裹（不用逗号分隔）
- Option 匹配不需要 `_ => ()` 分支
- 同包内函数直接调用，无需模块前缀
- 公共逻辑复用 `shared_helpers.mbt`，不重复实现
- **数组修改需深拷贝**（保证纯函数语义）
- **链式赋值处理返回值**（`let net = net.add_edge(...)` 而非 ignore）

### 禁止行为

1. 不要使用 `mut self` 参数（MoonBit 不支持）
2. 不要在 for 中解构元组（先绑定再 match）
3. 不要用 use/using 别名（使用完全限定名）
4. 不要忽略 .mbti 变更（修改后检查 `git diff -- "*.mbti"`）
5. 不要重复实现公共逻辑（使用 shared_helpers）
6. **不要用 `var` 声明变量**（已废弃，改用 `let mut`）
7. **不要用 `loop {}` 语法**（已废弃，改用 `while true {}`）

---

## 算法模块开发流程

```
1️⃣ 设计阶段
   └─ brainstorming → 用户确认技术选型 → 写 design doc

2️⃣ 基础类型（Commit 1: feat）
   ├─ moon.pkg（包配置）
   ├─ types.mbt（结果类型 + 辅助方法）
   └─ 核心数据结构（如 FlowNetwork / UnionFind / BinaryHeap）

3️⃣ 算法实现（Commit 2: feat）
   ├─ 私有辅助函数（priv fn）
   └─ 公开 API 函数（pub fn）

4️⃣ 测试文件（Commit 3: test）
   ├─ 辅助构建函数（make_xxx_network/graph）
   ├─ 正常场景测试（3-5 个典型案例）
   ├─ 边界情况测试（空图/越界/无效输入）
   └─ 属性验证测试（不可变性/一致性）

5️⃣ 文档（Commit 4: docs）
   ├─ README.md（API 总览 + 使用示例 + 算法原理）
   └─ docs/design/xxx_design.md（设计决策记录）

6️⃣ 验证阶段
   └─ moon check → moon test → git log 验证
```

### 关键经验

| 阶段 | 经验 | 示例 |
|------|------|------|
| 类型设计 | **独立类型 vs 适配 Trait** | FlowNetwork 不继承 GraphReadable，自包含容量/流量矩阵 |
| 纯函数语义 | **深拷贝避免副作用** | `deep_copy_matrix(net.flow)` 保证原网络不被修改 |
| 方法链式调用 | **返回值必须消费** | `let net = net.add_edge(0,1,10.0)` 而非 `add_edge(...) \|> ignore` |
| Git 提交 | **原子性 + 顺序原则** | 类型→算法→测试→文档（底层→上层） |
| 文档完整性 | **标准模板** | API/示例/原理/内部组件/边界行为/测试/设计决策 |

---

## 测试指南

```bash
moon test                    # 全量测试
moon test lib/algo/pagerank  # 单模块测试
moon test --update           # 更新快照
moon coverage analyze        # 覆盖率分析
```

**要求**: 核心高覆盖率 | 明确结果用 assertion | 复杂输出用 snapshot

**测试分类比例**:
- 基础功能测试: ~30%（类型创建/方法正确性）
- 算法正确性测试: ~40%（经典案例/已知答案）
- 边界情况测试: ~20%（空图/越界/异常输入）
- 属性验证测试: ~10%（不可变性/一致性约束）

---

## 错误速查

| 错误码 | 含义 | 快速修复 |
|--------|------|---------|
| **E0015** | unused_mut | 改为 `let`（只需改字段时）|
| **E3002** | Parse error | 检查: mut self / for解构 / 逗号分支 / `>>` 嵌套泛型 |
| **E4036** | read-only type | 改为 `pub(all) struct` |
| **E4145** | sealed trait | 改为 `pub(open)trait` |
| **E4021** | unbound variable | 用 `@core.Trait::method(self, ...)` |
| **E4139** | value cannot be implicitly ignored | 链式赋值: `let x = func(x)` 或 `func(x) \|> ignore` |
| **Deprecated** | `var` / `loop {}` | 改为 `let mut` / `while true {}` |

**Top 10 陷阱**（按出现频率排序）:

1. **mut self** → `(self)` + 内部 `let g = self`
2. **For元组解构** → `for x in arr { match x { (a,b) => } }`
3. **Match多语句** → `{ stmt; stmt }` （不用逗号）
4. **构造 pub struct 失败** → 核心类型必须 `pub(all)`
5. **Trait方法调用未绑定** → 必须完全限定名
6. **嵌套泛型 `>>` 冲突** → `Array[Array[T?]]` （非 `T?>>`）⚠️ 高频
7. **保留字 `fn`/`var`** → 改名或用 `let mut` ⚠️ 高频
8. **返回值不能忽略** → 链式赋值或显式 `ignore()` ⚠️ 高频
9. **数组引用副作用** → 算法前深拷贝，保证纯函数语义
10. **loop 废弃语法** → 统一使用 `while true {}`

---

## Git 提交规范

### Conventional Commits

```
<type>(<scope>): <subject>

<body (可选)>
```

| Type | 场景 | 示例 |
|------|------|------|
| `feat` | 新功能/新模块 | `feat(flow): add FlowNetwork base types` |
| `fix` | Bug 修复 | `fix(storage): correct Array::make 2D initialization` |
| `refactor` | 重构（不改行为） | `refactor(core): simplify trait visibility` |
| `test` | 测试代码 | `test(flow): add complete test suite (17 tests)` |
| `docs` | 文档 | `docs(flow): add README and design document` |
| `chore` | 构建/工具 | `chore: update .mbti binding files` |

### 提交顺序

```
✅ 推荐顺序（底层 → 上层）:
   Commit 1: feat(scope): 基础类型和结构体
   Commit 2: feat(scope): 算法实现
   Commit 3: test(scope): 测试套件
   Commit 4: docs(scope): 文档和设计说明

❌ 避免:
   - 单次提交混合代码+测试+文档
   - 提交顺序混乱（文档在代码之前）
   - 过大的 commit（> 500 行变更）
```

---

## 安全与权限

| 级别 | 操作 | 示例 |
|------|------|------|
| ✅ 允许 | 读文件、运行 fmt/info/test、编辑 `.mbt` | 日常开发 |
| ⚠️ 确认 | 改依赖、删文件、git操作、改 AGENTS.md | 需用户同意 |
| 🚫 禁止 | 提交敏感信息、改 `.git` 目录、运行未知命令 | 永不执行 |

---

## 工作风格

### 协作原则

1. **先理解再规划** — 歧义必确认，不得自行假设
2. **小步迭代** — 优先小改动、频繁验证
3. **证据优先** — 判断基于代码/文档/命令输出

### 输出要求

- 执行类: TodoWrite 进度追踪
- 分析类: "结论→依据→建议" 三层结构
- 错误处理: 错误码 + 原因 + 修复方案

---

## 📚 项目文档索引

| 文档 | 路径 | 用途 |
|------|------|------|
| **项目愿景** | `docs/PROJECT_VISION.md` | 为什么做这个项目？意义与目标 |
| **架构总览** | `docs/ARCHITECTURE.md` | 怎么设计的？当前+未来架构 |
| **路线图** | `docs/ROADMAP.md` | 版本规划与时间线 |
| **任务清单** | `docs/TODO.md` | 当前版本任务分解 |
| **算法目录** | `docs/algorithms_catalog.md` | 图算法全景分类与实现状态 |
| **更新规范** | `docs/UPDATE_GUIDE.md` | Agent 文档自动化更新规则 |
| **Trait设计** | `docs/design/graph_trait_and_module_architecture.md` | 6层Trait详细设计 |
| **存储调研** | `docs/design/graph_storage_survey.md` | 8种存储选型依据 |
| **竞品汇总** | `docs/reference/library_survey.md` | 主流图库对比表 |
| **测试策略** | `docs/quality/test_strategy.md` | 双轨测试方法论 |
| **重构分析** | `docs/design/v0130_refactoring_analysis.md` | 接口重构时机与方案 |
| **项目记忆** | `MEMORY.md` | 关键决策与架构约定 |
| **变更日志** | `CHANGELOG.md` | 版本历史记录 |

---

## 记忆系统

| 层级 | 文件 | 内容 |
|------|------|------|
| 项目记忆 | `MEMORY.md` | 关键决策、架构约定 |
| 每日记忆 | `memory/YYYY-MM-DD.md` | 操作日志 |

**流程**: 启动读 MEMORY → 今日 memory → 工作中更新 → 完成后写入 memory

---

## 快速参考

```moonbit
// 泛型函数
pub fn[G : @core.GraphReadable] to_adj_list(g : G) -> AdjList { ... }

// Option/Result
match value { Some(x) => ..., None => ... }  // Option 不需要 _ => ()
@core.GraphWritable::add_node(g, data) |> ignore  // 丢弃 Result<Unit>

// 流网络模式（独立类型）
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)  // 链式赋值，不 ignore
let result = edmonds_karp(net, 0, 5)  // 深拷贝内部执行

// Git 提交（PowerShell 多行格式）
git add file.mbt && git commit -m "feat(module): description"
```

---

<div align="center">

**🤖 mbtgraph Agent 规范**

*文档版本与变更历史详见 [CHANGELOG.md](CHANGELOG.md)*

</div>