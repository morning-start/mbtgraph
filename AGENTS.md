---
name: mbtgraph-agents
version: v2.4.0
author: mbtgraph-team
description: MoonBit 图算法库 Agent 协作配置（含实战经验固化 + P5 模块扩展 + 文档更新规范 + Sprint任务体系）
tags: [moonbit, graph-algorithms, trait-based, storage-patterns, network-flow, p5-complete, doc-guide, sprint-system]
---

# mbtgraph — MoonBit 图算法库

MoonBit 图数据结构库：邻接表/矩阵/CSR/边集 + Trait 抽象层 + 算法模块。

## 开发环境

```bash
moon fmt && moon info        # 格式化 + 更新接口
moon test                    # 运行测试
moon check src/algorithms/flow  # 检查单模块编译
```

## 技术栈

| 组件 | 技术 | 说明 |
|------|------|------|
| 语言 | MoonBit | native/wasm 后端 |
| 架构 | Trait-based | GraphReadable → Writable → Directed |
| 算法模块 | 独立类型模式 | 流网络等特殊语义场景可脱离 Graph trait |
| 测试 | 双轨制 | Blackbox (`*_test.mbt`) + Whitebox (`*_wbtest.mbt`) |

## 项目结构

```
src/
├── core/                     # 类型 + trait 定义
│   ├── types.mbt            # NodeId, Node, Edge
│   ├── traits.mbt           # GraphReadable 等核心 trait (6 层)
│   └── error.mbt            # GraphError
├── storage/                  # 存储实现 (8 种)
│   ├── directed_adj_list.mbt # 有向邻接表（参考实现）⭐
│   ├── undirected_adj_list.mbt # 无向邻接表（半存储优化）
│   ├── shared_helpers.mbt   # 公共辅助函数（同包直接调用）
│   └── converter.mbt        # 格式转换器 (8 函数)
└── algo/                     # 算法模块 ⭐ P0-P5 全部完成 (12 子模块)
    ├── traversal/           # 遍历 (BFS/DFS/环检测/拓扑) — ~47 tests
    ├── generators/          # 图生成器 (P0) — 16 函数, 56 tests
    ├── shortest_path/       # 最短路径 (P1) — Dijkstra/BF/FW, 32 tests
    ├── mst/                 # 最小生成树 (P2) — Kruskal/Prim, 16 tests
    ├── connectivity/        # 连通性 (P2) — CC/Tarjan/Kosaraju, 21 tests
    ├── flow/                # 网络流 (P3) — Edmonds-Karp + Dinic, 33 tests
    ├── matching/            # 图匹配 (P4) — Hungarian, 21 tests
    ├── euler/               # 欧拉路径 (P5-A) — Hierholzer, 22 tests 🆕
    ├── cutpoints/           # 割点与桥 (P5-B) — Tarjan, 15 tests 🆕
    ├── coloring/            # 图着色 (P5-C) — Greedy/WP/DSATUR/Exact, 21 tests 🆕
    ├── clique/              # 团/独立集/顶点覆盖 (P5-D) — Bron-Kerbosch, 14 tests 🆕
    └── hamiltonian/         # 哈密顿/TSP (P5-E) — Backtrack+NN+Held-Karp, 20 tests 🆕
```

**关键入口**: 新类型→`types.mbt` | 新trait→`traits.mbt` | 新存储→参考 `directed_adj_list.mbt` | 新算法→参考 `flow/` 或任意 P5 模块

## 编码规范

### 🔴 强制规则（CI 检查，必须遵守）

| # | 规则 | ✅ 正确 | ❌ 错误 | 检测方式 |
|---|------|--------|--------|---------|
| R1 | 使用 `@core.` 完全限定名 | `@core.NodeId(0)` | use 别名 | Code Review |
| R2 | Impl 用 `(self)` 非 `mut self` | `let g = self` | `mut self` | 编译报错 E3002 |
| R3 | 可变性按需声明 | 只改字段→`let g` | 需重新赋值→`let mut g` | Warning E0015 |
| R4 | 可见性正确选择 | 核心类型→`pub(all)` | trait→`pub(open)trait` | 编译报错 E4036/E4145 |
| R5 | For 循环不直接解构元组 | 先绑定再 match | `for (a,b) in ...` | 编译报错 E3002 |
| R6 | **嵌套泛型用 `]]` 结尾** | `Array[Array[Double?]]` | `Array[Array[Double?>>` | Parse error |
| R7 | **避免保留字命名** | `net`, `graph` | `fn`, `var` | Parse error / deprecated |

### 🟡 推荐惯例（Code Review 关注）

- Match 多语句用 `{}` 包裹（不用逗号分隔）
- Option 匹配不需要 `_ => ()` 分支
- 同包内函数直接调用，无需模块前缀
- 公共逻辑复用 `shared_helpers.mbt`，不重复实现
- **数组修改需深拷贝**（保证纯函数语义）
- **链式赋值处理返回值**（`let net = net.add_edge(...)` 而非 ignore）

### ❌ 禁止行为

1. 不要使用 `mut self` 参数（MoonBit 不支持）
2. 不要在 for 中解构元组（先绑定再 match）
3. 不要用 use/using 别名（使用完全限定名）
4. 不要忽略 .mbti 变更（每次修改后检查 `git diff -- "*.mbti"`）
5. 不要重复实现公共逻辑（使用 shared_helpers）
6. **不要用 `var` 声明变量**（已废弃，改用 `let mut`）
7. **不要用 `loop {}` 语法**（已废弃，改用 `while true {}`）

## 架构概要

### Trait 分层（6 层）

```
GraphReadable (所有存储, 12 方法)
├── GraphWritable (仅动态存储: AdjList/Matrix/EdgeList, +6 方法)
├── BatchReadable (批量优化: CSR/CSC, +2 方法)
├── EdgeIterable (边排序: Kruskal 友好, +1 方法)
└── GraphDirected (仅 Directed* 存储, +6 方法)
    └── GraphFull = Writable + Directed
```

**核心决策**:
- CSR 为只读格式，故意不实现 GraphWritable（LSP 原则）
- 有向/无向用独立结构体（非 runtime 字段判断）
- 算法约束: `fn[G: GraphReadable] bfs(g: G) -> ...`
- **流网络等特殊语义模块**可独立于 Graph trait（如 FlowNetwork 类型）

详细设计: [docs/design/graph_trait_and_module_architecture.md](file:///e:/Workplace/APP/MoonBit/mbtgraph/docs/design/graph_trait_and_module_architecture.md)

## 算法模块开发流程

### 标准模板（基于 flow 模块实战验证）

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
   └─ moon check → moon test (17/17 ✅) → git log 验证
```

### 关键经验（从 flow 模块提炼）

| 阶段 | 经验 | 示例 |
|------|------|------|
| 类型设计 | **独立类型 vs 适配 Trait** | FlowNetwork 不继承 GraphReadable，自包含容量/流量矩阵 |
| 纯函数语义 | **深拷贝避免副作用** | `deep_copy_matrix(net.flow)` 保证原网络不被修改 |
| 方法链式调用 | **返回值必须消费** | `let net = net.add_edge(0,1,10.0)` 而非 `add_edge(...) \|\> ignore` |
| Git 提交 | **原子性 + 顺序原则** | 类型→算法→测试→文档（底层→上层） |
| 文档完整性 | **8 大章节标准模板** | API/示例/原理/内部组件/边界行为/测试/设计决策/配合 |

## 测试指南

```bash
moon test                # 全量测试
moon test --update       # 更新快照
moon coverage analyze    # 覆盖率分析
moon test src/algorithms/flow  # 单模块测试
```

**要求**: 核心高覆盖率 | 明确结果用 assertion | 复杂输出用 snapshot

**测试分类比例**（参考 flow 模块）:
- 基础功能测试: ~30%（类型创建/方法正确性）
- 算法正确性测试: ~40%（经典案例/已知答案）
- 边界情况测试: ~20%（空图/越界/异常输入）
- 属性验证测试: ~10%（不可变性/一致性约束）

## 错误速查

| 错误码 | 含义 | 快速修复 |
|--------|------|---------|
| **E0015** | unused_mut | 改为 `let`（只需改字段时）|
| **E3002** | Parse error | 检查: mut self / for解构 / 逗号分支 / `>>` 嵌套泛型 |
| **E4036** | read-only type | 改为 `pub(all) struct` |
| **E4145** | sealed trait | 改为 `pub(open)trait` |
| **E4021** | unbound variable | 用 `@core.Trait::method(self, ...)` |
| **E4139** | value cannot be implicitly ignored | 链式赋值: `let x = func(x)` 或 `func(x) \|\> ignore` |
| **Deprecated** | `var` / `loop {}` | 改为 `let mut` / `while true {}` |

**Top 10 陷阱**（按出现频率排序）:
1. mut self → `(self)` + 内部 `let g = self`
2. For元组解构 → `for x in arr { match x { (a,b) => } }`
3. Match多语句 → `{ stmt; stmt }` （不用逗号）
4. 构造 pub struct 失败 → 核心类型必须 `pub(all)`
5. Trait方法调用未绑定 → 必须完全限定名
6. **嵌套泛型 `>>` 冲突** → `Array[Array[T?]]` （非 `T?>>`）⚠️ 高频
7. **保留字 `fn`/`var`** → 改名或用 `let mut` ⚠️ 高频
8. **返回值不能忽略** → 链式赋值或显式 `ignore()` ⚠️ 高频
9. **数组引用副作用** → 算法前深拷贝，保证纯函数语义
10. **loop 废弃语法** → 统一使用 `while true {}`

## Git 提交规范

### Conventional Commits 格式

```
<type>(<scope>): <subject>

<body (可选)>
```

### 提交类型

| Type | 场景 | 示例 |
|------|------|------|
| `feat` | 新功能/新模块 | `feat(flow): add FlowNetwork base types` |
| `fix` | Bug 修复 | `fix(storage): correct Array::make 2D initialization` |
| `refactor` | 重构（不改行为） | `refactor(core): simplify trait visibility` |
| `test` | 测试代码 | `test(flow): add complete test suite (17 tests)` |
| `docs` | 文档 | `docs(flow): add README and design document` |
| `chore` | 构建/工具 | `chore: update .mbti binding files` |

### 分部提交顺序（原子性原则）

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

## 安全与权限

| 级别 | 操作 | 示例 |
|------|------|------|
| ✅ 允许 | 读文件、运行 fmt/info/test、编辑 `.mbt` | 日常开发 |
| ⚠️ 确认 | 改依赖、删文件、git操作、改 AGENTS.md | 需用户同意 |
| 🚫 禁止 | 提交敏感信息、改 `.git` 目录、运行未知命令 | 永不执行 |

## 工作风格

### 协作原则
1. **先理解再规划** — 歧义必确认，不得自行假设
2. **小步迭代** — 优先小改动、频繁验证
3. **证据优先** — 判断基于代码/文档/命令输出

### 输出要求
- 执行类: TodoWrite 进度追踪
- 分析类: "结论→依据→建议" 三层结构
- 错误处理: 错误码 + 原因 + 修复方案

## 记忆系统

| 层级 | 文件 | 内容 |
|------|------|------|
| 项目记忆 | `MEMORY.md` | 关键决策、架构约定 |
| 每日记忆 | `memory/YYYY-MM-DD.md` | 操作日志 |

**流程**: 启动读 MEMORY → 今日 memory | 工作中更新 | 完成后写入 memory

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

// Block 风格: ///| 分隔符 | 废弃代码放 deprecated.mbt

// Git 提交（PowerShell 多行格式）
git add file.mbt && git commit -m "feat(module): description"
```

---

## 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| **v2.4.0** | 2026-05-23 | 📋 **Sprint任务体系建立**：重写TODO.md为Sprint格式 + ROADMAP聚焦v1.0.0 + 文档规范化体系成熟 |
| **v2.3.0** | 2026-05-23 | 📝 **新增文档更新规范**：创建UPDATE_GUIDE.md + 自动化检查脚本，定义配置/文档更新触发条件和规则矩阵 |
| **v2.2.0** | 2026-05-23 | 🎉 **P5 模块扩展完成**：项目结构更新至12子模块/Trait分层6层/测试数据~551t/Git Tags版本管理 |
| **v2.1.0** | 2026-05-19 | 🔥 固化 flow 模块经验：Top10陷阱/算法开发流程/Git规范/错误速查扩展 |
| **v2.0.0** | 2026-05-18 | 初始版本：基础编码规则/Trait分层/测试指南 |

---

## 📚 文档更新规范

> **详细指南**: [docs/UPDATE_GUIDE.md](docs/UPDATE_GUIDE.md) — **Agent必读**
>
> **自动化检查**: `bash scripts/check_doc_consistency.sh` — 一键验证一致性

### 核心原则

每次代码提交或模块完成后，**必须**按优先级更新以下文件：

#### P0 必须（立即更新）

| 文件 | 触发条件 | 更新内容 |
|------|---------|----------|
| `moon.mod.json` | 新模块完成 / 版本发布 | version + description |
| `AGENTS.md` | 任何变更 | version + 项目结构/规范 |
| `MEMORY.md` | 重要决策 / 模块完成 | 包结构 + 测试数 + 决策记录 |
| `README.mbt.md` | 新模块 / 版本发布 | 算法表 + 统计 + 路线图 |
| `CHANGELOG.md` | 功能添加 / 版本发布 | 变更记录 |
| Git Tag | 里程碑完成 | `git tag -a v0.X.0` |

#### P1 推荐（尽快更新）

| 文件 | 更新时机 |
|------|---------|
| `docs/ROADMAP.md` | 状态变更 / 统计更新 |
| `docs/TODO.md` | 任务完成标记 |

### 快速参考

```bash
# 完成新模块后的标准操作流：
# 1️⃣ 更新 moon.mod.json (version+1)
# 2️⃣ 更新 AGENTS.md (添加模块行)
# 3️⃣ 更新 MEMORY.md (包结构+决策)
# 4️⃣ 更新 README.mbt.md (算法表+统计)
# 5️⃣ 更新 CHANGELOG.md (新版本章节)
# 6️⃣ 创建 Git Tag
# 7️⃣ 运行一致性检查: bash scripts/check_doc_consistency.sh
# 8️⃣ 提交: git commit -m "release(v0.X.0): ..."
```

详见 [docs/UPDATE_GUIDE.md](docs/UPDATE_GUIDE.md) 的完整触发条件矩阵和场景化示例。
