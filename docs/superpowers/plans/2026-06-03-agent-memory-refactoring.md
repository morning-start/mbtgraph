# Agent 记忆系统重构实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 MEMORY.md 从 ~542 行瘦身至 ~150 行，建立 `memory/` 日志目录，在 AGENTS.md 中写入完整记忆系统规范

**Architecture:** 严格双层架构——MEMORY.md 作为稳定知识库（~150行，低频更新），memory/ 目录作为操作日志（按需增长，每日一个文件）。删除所有跨文档重复内容和动态统计数据。

**Tech Stack:** Markdown 文件重组（无代码变更）

**设计文档:** [docs/superpowers/specs/2026-06-03-agent-memory-refactoring-design.md](../specs/2026-06-03-agent-memory-refactoring-design.md)

---

## 文件结构映射

```
修改:
  MEMORY.md                    # 重写: 542行 → ~150行
  AGENTS.md                    # 替换 L338-345 为完整记忆系统章节

新建:
  memory/                      # 日志目录
  memory/2026-05-25.md         # 从 MEMORY.md L401-439 迁移
  memory/2026-06-03.md         # 从 MEMORY.md L442-542 迁移
```

---

### Task 1: 创建 memory/ 目录并迁移历史日志

**Files:**
- Create: `memory/.gitkeep`
- Create: `memory/2026-05-25.md`
- Create: `memory/2026-06-03.md`

- [ ] **Step 1: 创建 memory/ 目录和占位文件**

创建 `memory/` 目录，添加 `.gitkeep` 确保目录被 Git 跟踪。

```bash
mkdir memory
```

写入 `memory/.gitkeep`（空文件即可，确保目录存在）。

- [ ] **Step 2: 创建 memory/2026-05-25.md（从 MEMORY.md L401-439 迁移）**

将 MEMORY.md 中 `## 📝 2026-05-25 工作日志 (ROADMAP v2 规划日)` 整段（L401-439）迁移至新文件。内容保持原样，仅调整标题格式。

文件内容：

```markdown
# 2026-05-25 工作日志 (ROADMAP v2 规划日)

> 从 MEMORY.md 迁移 — 原始位置 L401-439

## 当日基线 (v0.9.0)

| 维度 | 数值 |
|------|:----:|
| 版本 | v0.9.0 |
| 算法模块 | 12 (P0-P5 全部完成) |
| 测试用例 | **551** (全通过 ✅) |
| Git Tags | 5 (v0.5.0→v0.9.0) |

## 核心产出

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

## 关键决策

1. **方向调整**: 工程化优先 → **算法完整性优先**（用户决策）
2. **发布节奏**: 4个大Sprint → **小步快跑每2周1版**
3. **版本组织**: 按时间平铺 → **方案C功能集群**(🔍📊🚀主题制)
4. **文档策略**: 过时文档保留 → **删除/合并/精简三原则**

## 算法缺口识别

| 优先级 | 缺口算法 | 数量 | 计划版本 |
|--------|---------|:----:|:-------:|
| P0 | A*/Johnson/费用流/HK/Edmonds/双向BFS | 6 | v0.12.0 |
| P1 | PageRank/4种中心性/Louvain/标签传播 | 7 | **v0.10.0** ← 当前目标 |
| P2 | DOT/JSON/图统计 | 3 | v0.11.0 |
```

- [ ] **Step 3: 创建 memory/2026-06-03.md（从 MEMORY.md L442-542 迁移）**

将 MEMORY.md 中 `## 🎨 文档站可视化系统 (2026-06-03)` 整段（L442-542）迁移至新文件。内容保持原样。

文件内容：

```markdown
# 2026-06-03 工作日志 (文档站可视化系统)

> 从 MEMORY.md 迁移 — 原始位置 L442-542

## 技术栈

| 组件 | 选型 | 版本 | 说明 |
|------|------|------|------|
| **图渲染引擎** | Cytoscape.js | 3.30.2 | 图论可视化库，支持 dagre 布局 |
| **布局算法** | cytoscape-dagre + dagre | 2.5.0 / 0.8.5 | 左到右层级布局，适合算法演示 |
| **站点框架** | Astro (SSG) + Starlight | — | 文档站框架，Markdown 原生支持 |
| **CDN** | jsdelivr (主) + unpkg (备) | — | 国内稳定，onerror 自动回退 |

## 架构决策

| 决策 | 方案 | 原因 |
|------|------|------|
| **嵌入方式** | iframe 独立 HTML（非 MDX 组件） | MDX 解析与 MoonBit `let`/`${}` 语法冲突（63+ 处），iframe 完全隔离 |
| **展示模式** | 缩略图预览(340px) + 全屏跳转 | 文档页不占用过多空间，全屏页提供完整体验 |
| **布局模式** | 全屏画布 + 悬浮头部 + 固定底栏 | VisuAlgo 风格沉浸式体验，控制栏贴底不遮挡图区域 |

## 文件结构

```
site/
├── public/visualizations/
│   └── bfs.html          # BFS 可视化（独立完整，~720行）
├── src/
│   ├── components/
│   │   └── GraphVisualization.astro  # Astro 组件版（预留，当前未使用）
│   ├── content/docs/algorithms/traversal/bfs/index.md  # 含 iframe 嵌入
│   └── styles/global.css    # 新增 Section 25: .viz-preview-card 样式
└── astro.config.mjs        # 已配置 mdx + expressive-code 集成
```

## 踩过的坑（经验清单）

### P0 - 阻塞性问题

| # | 问题 | 根因 | 修复 |
|---|------|------|------|
| 1 | **图初始化失败** `Cannot read 'graphlib' of undefined` | 缺少 `dagre` 核心依赖库（cytoscape-dagre 的依赖） | 在 cytoscape-dagre **之前**加载 `dagre@0.8.5` |
| 2 | **BFS 只访问 1 个节点**（其余 5 个灰色） | `generateSteps()` 中发现邻居时**提前标记 `visited[nbr]=true`**，导致出队时被跳过 | 删除提前标记，改为**只在出队时标记 visited**（标准 BFS） |
| 3 | **重置后节点颜色残留绿色** | `finish` 步骤用 `animate()` 设置样式，动画状态残留覆盖了后续 `.style()` | ① finish 改用 `.style()` ② resetVisuals 先调 `cy.elements().stop(true, false)` ③ 重置时设 `transition-duration: '0s'` |
| 4 | **Canvas 高度为 0，图不可见** | `#gv-canvas` 用 `height:100%` 但父容器无固定高度 | 改用 `position:absolute; top:0; left:0;` 绝对定位填满 flex 容器 |

### P1 - 兼容性问题

| # | 问题 | 根因 | 修复 |
|---|------|------|------|
| 5 | **MDX 解析错误**: `let` 保留字 / `${}` 语法 | acorn 解析器将代码块中的 MoonBit 语法当 JSX 表达式 | **放弃 MDX 方案**，改用 iframe 嵌入独立 HTML |
| 6 | **Cytoscape v3 样式警告**: text-wrap/cursor/font-weight/node:hover | v3.30.2 不支持这些 CSS 属性/选择器 | 移除 text-wrap:nowrap、cursor:pointer、font-weight:'700'、node:hover 选择器 |
| 7 | **集成顺序错误**: expressiveCode 必须在 mdx 之前 | astro-expressive-code 要求先于 mdx 加载 | 调整 integrations 数组顺序 |
| 8 | **URL 路径 404**: `/docs/algorithms/...` 不存在 | Starlight 服务在根级别，无 `/docs/` 前缀 | 使用 `/algorithms/traversal/bfs/` 路径 |

### P2 - UX 优化

| # | 问题 | 方案 |
|---|------|------|
| 9 | iframe 太小看不清全貌 | 缩略图预览(340px) + 右下角"全屏演示"按钮跳转新标签页 |
| 10 | 控制栏挤占画布空间 | Header 改为左上角悬浮卡片，Controls+Status+Legend 合并为底部固定栏 |
| 11 | 动画完成后无法重播 | 增加 `isFinished` 状态机：完成后按钮变 ↻ 绿色脉冲图标，点击自动 reset+play |
| 12 | 完成后状态文字不变 | `updateUI()` 分三路分支：完成态(显示最终结果) / 重置态(全部归零) / 播放态(实时步骤) |

## 动画引擎设计模式（可复用）

```javascript
// 1. 步骤生成器: 将算法分解为离散原子操作
function generateSteps(startId) {
  // 每步包含: type, targets, message, order, queue, levels
  // 类型: init → dequeue → visit_edge → skip_edge → visit_node → finish
}

// 2. 执行引擎: 单步执行(带动画) vs 快速重建(无动画)
executeStep(step, true)   // animate() 带过渡效果
rebuildTo(idx)            // style() 无动画，用于 jumpTo/reset

// 3. 状态机: idle → playing → finished → replay
// isFinished 标志控制按钮图标切换 ▶/⏸/↻

// 4. 视觉重置铁律:
// resetVisuals() 必须: stop() → style(transition=0s)
```

## 依赖加载顺序（必须严格遵守）

```html
<!-- 正确顺序 -->
<script src="cytoscape.min.js"></script>        <!-- 1. 核心 -->
<script src="dagre.min.js"></script>              <!-- 2. 布局核心 (dagre 依赖 graphlib) -->
<script src="cytoscape-dagre.js"></script>        <!-- 3. Cytoscape 插件 (依赖 1+2) -->

<!-- waitForDeps 必须检测全部三个: cytoscape && dagre && cytospaceDagre -->
```

## 扩展到其他算法的检查清单

- [ ] 复制 bfs.html 为新算法模板
- [ ] 修改图数据（nodes/edges/adjList）匹配目标算法示例图
- [ ] 重写 `generateSteps()` 实现目标算法的步骤逻辑
- [ ] 更新配色方案和状态消息
- [ ] 更新文档 md 中的 iframe 引用
- [ ] 验证：依赖加载 → 节点可见 → 算法正确性 → 完成/重置/重播循环
```

- [ ] **Step 4: 验证文件创建成功**

确认三个文件已创建：
- `memory/.gitkeep` 存在
- `memory/2026-05-25.md` 内容完整（从原 L401-439 迁移）
- `memory/2026-06-03.md` 内容完整（从原 L442-542 迁移）

- [ ] **Step 5: Commit**

```bash
git add memory/
git commit -m "chore(memory): create memory/ directory and migrate logs from MEMORY.md"
```

---

### Task 2: 重写 MEMORY.md（瘦身至 ~150 行）

**Files:**
- Modify: `MEMORY.md` (full rewrite)

- [ ] **Step 1: 重写 MEMORY.md 为精简版 (~150 行)**

用以下内容完全替换当前 MEMORY.md。核心变化：
- 删除：测试状态表(L135-169)、复杂度速查表(L282-326)、Sprint计划(L337-380)、项目统计总览(L382-398)、工作日志(L401-542)
- 精简：包结构树（从详细列表改为摘要）、决策记录（从全文改为索引格式）
- 保留：项目身份、Trait 分层、存储选型、编码规范、工具链、快速参考

```markdown
# Project Memory

## 1. 项目基础

- **模块**: `morning-start/mbtgraph`
- **语言**: MoonBit (native/wasm/js 三后端)
- **协议**: MIT
- **版本**: v0.14.0 (详见 CHANGELOG.md)
- **架构**: MoonBit 包按目录组织，每个目录含 `moon.pkg` 声明依赖
- **总测试数**: 运行 `moon test` 获取实时数据
- **算法模块**: **15 子模块** + **~49 算法** + **I/O 模块** (DOT/JSON/统计)

## 2. 图存储架构

### Trait 分层体系（5 层）

```
GraphReadable          ← 基础只读（12 方法，所有存储）
├── GraphWritable      ← 可写（+5 方法，仅动态存储；CSR 故意不实现 LSP）
├── GraphDirected      ← 有向图入边查询（+6 方法）
│   └── GraphFull     ← 完整别名（= Writable + Directed）
└── GraphBatchReadable ← 批量优化（+2 方法，CSR/CSC 专用）
```

**核心决策**: CSR/CSC 不实现 GraphWritable（LSP）；算法用 trait 约束 `[G : @core.GraphReadable]`；v0.13.0 移除 GraphEdgeIterable（零算法使用）；参数统一为 `graph`。

### 存储层清单

```
lib/storage/
├── 有向图: directed_adj_list ⭐ | directed_matrix | edge_list
├── 无向图: undirected_adj_list ⭐ | undirected_matrix | undirected_edge_list
├── 只读高性能: csr (亿级节点) | csc (入边密集)
└── 工具: converter (8泛型转换) | shared_helpers (6公共函数)
```

### 存储选型速查

| 需求 | 推荐 |
|------|------|
| 通用有向图 | DirectedAdjList (`new_directed()`) |
| 通用无向图 | UndirectedAdjList (`new_undirected()`) |
| V<1000 稠密图 | DirectedMatrix (`new_directed_matrix(cap)`) |
| V>10K 静态大图 | CSRGraph (`to_csr(g)`) |
| 入边密集查询 | CSCGraph (`to_csc(g)`) |

### 包结构摘要

```
lib/
├── core/       # 类型(3) + trait(5) + 错误(1) = 64 tests
├── storage/    # 存储体(8) + 转换器(8) + 工具(6) = ~103 tests
├── algo/       # 15子模块, ~49算法, ~491 tests (详见 algorithms_catalog.md)
└── io/         # DOT + JSON + 图统计 = 42 tests
```

### 转换器三层架构

| 分组 | 约束 | 函数数 | 保护机制 |
|------|------|:------:|---------|
| 有向转换组 | `[G : GraphDirected]` | 5 | 编译期保证源是有向图 |
| 无向转换组 | `[G : GraphReadable]` + `raise` | 3 | 运行时 `assert_true(!is_directed)` |
| 语义转换 | `[G : GraphReadable]` + `raise` | 2 | `as_undirected` / `as_directed` 显式跨边界 |

## 3. 编码规范摘要

### 强制规则 (R1-R7)

| # | 规则 | 正确 | 错误 |
|---|------|------|------|
| R1 | 完全限定名 | `@core.NodeId(0)` | use 别名 |
| R2 | Impl 参数 | `(self)` | `mut self` |
| R3 | 按需声明可变性 | 只改字段→`let g` | 需重新赋值→`let mut g` |
| R4 | 可见性 | 核心类型→`pub(all)` | trait→`pub(open)trait` |
| R5 | For 循环 | 先绑定再 match | `for (a,b) in ...` |
| R6 | 嵌套泛型 | `Array[Array[T?]]` | `Array[Array[T?>>` |
| R7 | 避免保留字 | `net`, `graph` | `fn`, `var` |

### Top 10 语法陷阱（按频率排序）

| # | 陷阱 | 正确写法 | 错误写法 |
|---|------|---------|---------|
| 1 | mut self | `(self)` + 内部 `let g = self` | `mut self` 参数 |
| 2 | For元组解构 | 先绑定再 match | `for (a,b) in ...` |
| 3 | Match多语句 | `{ stmt; stmt }` | 逗号分隔 |
| 4 | pub struct 失败 | `pub(all) struct` | `pub struct` |
| 5 | Trait方法调用 | 完全限定名 | 未绑定 |
| 6 | 嵌套泛型 >> | `Array[Array[T?]]` | `T?>>` |
| 7 | 保留字 fn/var | 改名或用 `let mut` | 直接使用 |
| 8 | 返回值消费 | `let x = func(x)` 或 `ignore()` | 丢弃非 Unit |
| 9 | 数组引用副作用 | 算法前深拷贝 | 直接修改输入 |
| 10 | loop 废弃 | `while true {}` | `loop {}` |

### 推荐惯例

- Match 多语句用 `{}` 包裹；Option 匹配不需要 `_ => ()` 分支
- 同包内直接调用，无需模块前缀；公共逻辑复用 `shared_helpers.mbt`
- **数组修改需深拷贝**（纯函数语义）；**链式赋值处理返回值**

## 4. 关键决策索引

> 详细记录见各 design doc 和 memory/ 日志。此处仅保留索引。

### 里程碑决策（按时间倒序）

| 日期 | 决策（一句话） | 详情链接 |
|------|---------------|---------|
| 2026-05-29 | v0.14.0 性能优化：heap/CSR快排/batch等8任务完成 | CHANGELOG.md |
| 2026-05-28 | v0.13.0 接口重构：6→5层trait, 移除EdgeIterable, 参数g→graph | docs/design/v0130_refactoring_analysis.md |
| 2026-05-27 | AGENTS.md 剥离动态元数据，降为稳定文档 | — |
| 2026-05-25 | ROADMAP v2.0.0：四阶段规划+方案C功能集群+小步快跑 | docs/design/roadmap_v2_redesign_2026-05-25.md |
| 2026-05-23 | MIT 协议确认 + Sprint任务体系 + Git Tags 管理 | — |
| 2026-05-22 | P5 五大模块全部完成（Euler/Cutpoints/Coloring/Clique/Hamiltonian） | — |

### 架构与设计决策

| 日期 | 决策（一句话） | 详情链接 |
|------|---------------|---------|
| 2026-05-19 | FlowNetwork 独立类型设计（不继承GraphReadable）+ 深拷贝纯函数语义 | docs/design/ （flow 设计文档） |
| 2026-05-17 | 无向图半存储优化(~50%内存节省) + CSC补齐 + converter三层重构 | docs/design/graph_storage_survey.md |
| 2026-05-08 | Trait 4层→6层(BatchReadable+EdgeIterable), 后6层→5层(移除EdgeIterable) | docs/design/graph_trait_and_module_architecture.md |

## 5. 快速参考

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

## 6. 工具链

```bash
moon check               # 类型检查（零错误零警告）
moon test                # 运行全部测试
moon fmt && moon info     # 格式化 + 更新 .mbti 接口文件
moon build --target <tgt> # 构建（wasm/js/native）
```

---

> **记忆系统规范**: 详见 AGENTS.md §记忆系统 章节
> **算法复杂度详情**: 详见 docs/algorithms_catalog.md
> **任务规划**: 详见 docs/TODO.md
> **变更日志**: 详见 CHANGELOG.md
```

- [ ] **Step 2: 验证行数**

运行以下命令确认 MEMORY.md 行数在目标范围内：

```bash
wc -l MEMORY.md
# 预期: ≤ 200 行（目标 ~150 行）
```

- [ ] **Step 3: Commit**

```bash
git add MEMORY.md
git commit -m "refactor(memory): slim MEMORY.md from 542 to ~150 lines (strict two-layer architecture)"
```

---

### Task 3: 更新 AGENTS.md 记忆系统章节

**Files:**
- Modify: `AGENTS.md:338-345` (替换现有简略版为完整章节)

- [ ] **Step 1: 替换 AGENTS.md 中「记忆系统」章节**

将 AGENTS.md 当前 L338-345 的内容：

```markdown
## 记忆系统

| 层级 | 文件 | 内容 |
|------|------|------|
| 项目记忆 | `MEMORY.md` | 关键决策、架构约定 |
| 每日记忆 | `memory/YYYY-MM-DD.md` | 操作日志 |

**流程**: 启动读 MEMORY → 今日 memory → 工作中更新 → 完成后写入 memory
```

替换为以下完整章节：

```markdown
## 记忆系统

### 分层架构

| 层级 | 文件 | 性质 | 行数上限 | 职责 |
|------|------|:----:|:--------:|------|
| **项目记忆** | `MEMORY.md` | 稳定知识库 | ~150 行 | 架构约定、决策索引、编码摘要 |
| **操作日志** | `memory/YYYY-MM-DD.md` | 流水日志 | 不限 | 当日操作、实现经验、发布记录 |

### 内容分类速查

**-> 放入 MEMORY.md**:
- 项目身份信息（版本/语言/协议/模块数摘要）
- 架构约定（Trait 分层、存储选型模式、包结构精简版）
- 编码规范摘要（R1-R7 + Top10 陷阱 + 语法规则表）
- 关键决策索引（日期 + 一句话 + 链接；不拷贝全文）

**-> 放入 memory/ 日志**:
- 每日工作记录（做了什么、产出什么、决策过程）
- 一次性实现经验（踩坑清单、依赖顺序、调试过程）
- 版本发布记录（变更清单、发布决策）

**-> 不放记忆系统（已有归属）**:
- 动态测试数/版本统计 -> `CHANGELOG.md`
- 算法复杂度详情 -> `docs/algorithms_catalog.md`
- Sprint 任务计划 -> `docs/TODO.md`
- 详细设计文档 -> `docs/design/*.md`
- 开发效率基准 -> 不需要持久化

### 写入规则

1. **MEMORY.md 更新时机**（低频）:
   - 新模块完成 -> 追加到 S2 包结构 / S4 决策索引
   - 架构变更 -> 修改 S2 架构约定段
   - 发现新编码陷阱 -> 追加到 S3 编码规范摘要

2. **memory/ 日志写入规范**:
   - 文件名格式: `YYYY-MM-DD.md`（使用工作日期）
   - 结构模板:

     ```markdown
     # YYYY-MM-DD 工作日志

     ## 当日目标
     - [ ]

     ## 完成事项
     - [ ] 产出物（文件/代码/文档）

     ## 遇到的问题
     - [ ] 问题描述 + 解决方案

     ## 关键经验
     - [ ] 可复用的经验/踩坑
     ```

   - 每个工作日一个文件，无工作的日子不创建

3. **MEMORY.md 瘦身检查清单**（每次更新后执行）:
   - [ ] 有没有动态统计数据？（应删除或委托 CHANGELOG）
   - [ ] 有没有单次操作记录？（应移至 memory/）
   - [ ] 有没有和其他文档重复的内容？（应删除并引用原文）
   - [ ] 总行数是否接近 200 行？（触发审查）

### 读取流程

```
Agent 启动 -> 读 MEMORY.md（必读，~150行快速加载）
            -> 读 memory/今日.md（推荐读，恢复当日上下文）
            -> 开始工作
```

- MEMORY.md 是**必读**（每个会话启动时自动加载）
- memory/ 当日日志是**推荐读**（恢复上下文）
- memory/ 历史日志是**按需查**（遇到相关问题时搜索）
```

- [ ] **Step 2: 验证 AGENTS.md 格式正确**

确认替换后 AGENTS.md 无格式错误，新章节与前后文衔接自然。

- [ ] **Step 3: Commit**

```bash
git add AGENTS.md
git commit -m "docs(agents): replace memory system section with complete specification (two-layer architecture)"
```

---

### Task 4: 验证与收尾

**Files:**
- Verify: `MEMORY.md`, `memory/`, `AGENTS.md`

- [ ] **Step 1: 行数验证**

```bash
wc -l MEMORY.md
# 预期: <= 200 行
```

```bash
ls -la memory/
# 预期: .gitkeep, 2026-05-25.md, 2026-06-03.md
```

- [ ] **Step 2: 重复内容扫描**

确认以下内容已从 MEMORY.md 删除且不丢失：
- [ ] 测试状态表（~33行）-> 已委托 `moon test`
- [ ] 算法复杂度速查表（~45行）-> 已由 `algorithms_catalog.md` 覆盖
- [ ] Sprint 任务计划（~42行）-> 已由 `TODO.md` 覆盖
- [ ] 项目统计总览（~16行）-> 已由 `CHANGELOG.md` 覆盖
- [ ] 开发效率基准（~10行）-> 不需要持久化
- [ ] 2026-05-25 工作日志（~39行）-> 已迁移至 `memory/2026-05-25.md`
- [ ] 可视化踩坑清单（~100行）-> 已迁移至 `memory/2026-06-03.md`

- [ ] **Step 3: 代码未受影响验证**

```bash
moon test
# 预期: 全部通过（本次变更仅涉及 .md 文件）
```

- [ ] **Step 4: 最终 Commit（如有遗漏修正）**

如果有任何小修正需要提交：

```bash
git add -A
git commit -m "chore(memory): verification and final cleanup for memory system refactoring"
```

---

## 自审检查

### Spec 覆盖率

| 设计文档要求 | 对应 Task | 状态 |
|-------------|:--------:|:----:|
| 建立 memory/ 日志目录 | Task 1 | ✅ |
| 迁移工作日志至 memory/ | Task 1 Step 2-3 | ✅ |
| MEMORY.md 瘦身至 ~150 行 | Task 2 | ✅ |
| 删除动态统计数据 | Task 2 Step 1 | ✅ |
| 删除重复内容（Sprint/复杂度/统计） | Task 2 Step 1 | ✅ |
| 决策记录改为索引格式 | Task 2 Step 1 | ✅ |
| AGENTS.md 写入完整记忆规范 | Task 3 | ✅ |
| 定义写入/读取/清理流程 | Task 3 Step 1 | ✅ |
| 验证（行数/重复/代码无损） | Task 4 | ✅ |

### 占位符扫描

- 无 TBD/TODO/不完整段落
- 所有代码块均为实际内容（Markdown 文件内容）
- 所有命令均可直接执行

### 类型一致性

- 文件路径在各 Task 中一致（`MEMORY.md`, `memory/`, `AGENTS.md`）
- 行号引用基于设计文档中的分析结果
