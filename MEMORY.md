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
