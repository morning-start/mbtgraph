# Project Memory

## 项目基础

- **模块**: `morning-start/mbtgraph`
- **语言**: MoonBit
- **协议**: Apache-2.0
- **架构**: MoonBit 包按目录组织，每个目录含 `moon.pkg` 声明依赖

## 图存储架构

### Trait 分层体系（6 层）

采用 6 层 trait 架构，遵循 SOLID 原则（特别是 LSP 和 ISP）：

```
GraphReadable          ← 基础只读（12 方法，所有存储都实现）
├── GraphWritable      ← 可写（+5 方法，仅动态存储；CSR 故意不实现 LSP）
├── GraphDirected      ← 有向图入边查询（+6 方法）
│   └── GraphFull     ← 完整别名（= Writable + Directed）
├── GraphBatchReadable ← 批量优化（+2 方法，CSR/CSC 专用）
└── GraphEdgeIterable  ← 边排序（+1 方法，Kruskal 友好）
```

**核心决策**:
- CSR/CSC 等只读存储**不实现** `GraphWritable`，避免违反里氏替换原则
- 算法使用 trait 约束 `[G : @core.GraphReadable]` 而非具体类型
- 无向图采用**半存储优化**：邻接表用左上角三角存储，矩阵用上三角存储

### 存储层完整清单

```
src/storage/
├── 有向图 (3)
│   ├── directed_adj_list.mbt     ⭐ 默认推荐 | Readable + Writable + Directed
│   ├── directed_matrix.mbt       小规模稠密图 | Readable + Writable + Directed
│   └── edge_list.mbt            Kruskal 友好 | Readable + Writable + EdgeIterable
│
├── 无向图 (3)
│   ├── undirected_adj_list.mbt   ⭐ 半存储优化 | Readable + Writable + EdgeIterable
│   ├── undirected_matrix.mbt     上三角优化    | Readable + Writable
│   └── undirected_edge_list.mbt  无向边集       | Readable + Writable + EdgeIterable
│
├── 只读高性能 (2)
│   ├── csr.mbt                  亿级节点       | Readable + BatchReadable
│   └── csc.mbt                  入边密集       | Readable + BatchReadable
│
└── 工具 (3)
    ├── converter.mbt            8 个泛型转换函数
    ├── shared_helpers.mbt       4 个公共辅助函数
    └── README.md                包文档
```

### 包结构

```
src/
├── core/          # 基础类型(3) + trait定义(6) + 错误类型(1) + 测试(68)
├── storage/       # 存储实现(8结构体) + 转换器(8) + 工具(4) + 测试(~107) + 文档
├── algo/          # 图算法模块 ⭐ P0-P5 全部完成 (12 子模块)
│   ├── traversal/      # 遍历 (BFS/DFS/环检测/拓扑) — ~47 tests ✅
│   ├── generators/     # 图生成器 (P0) — 16 函数, 56 tests ✅
│   ├── shortest_path/  # 最短路径 (P1) — Dijkstra/BF/FW, 32 tests ✅
│   ├── mst/            # 最小生成树 (P2) — Kruskal/Prim, 16 tests ✅
│   ├── connectivity/   # 连通性 (P2) — CC/Tarjan/Kosaraju, 21 tests ✅
│   ├── flow/           # 网络流 (P3) — Edmonds-Karp + Dinic, 33 tests ✅
│   ├── matching/       # 图匹配 (P4) — Hungarian, 21 tests ✅
│   ├── euler/          # 欧拉路径 (P5-A) — Hierholzer, 22 tests ✅🆕
│   ├── cutpoints/      # 割点与桥 (P5-B) — Tarjan, 15 tests ✅🆕
│   ├── coloring/       # 图着色 (P5-C) — Greedy/WP/DSATUR/Exact, 21 tests ✅🆕
│   ├── clique/         # 团/独立集/顶点覆盖 (P5-D) — Bron-Kerbosch, 14 tests ✅🆕
│   └── hamiltonian/    # 哈密顿/TSP (P5-E) — Backtrack+NN+Held-Karp, 20 tests ✅🆕
└── utils/         # 工具层（序列化等）— 待开发
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
- **强制规则 (R1-R5)**: 见 AGENTS.md §编码规范

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

## 测试状态

### 当前覆盖率

| 包 | 黑盒 | 白盒 | 总计 | 状态 |
|----|:----:|:----:|:----:|:----:|
| core | 49 | 19 | **68** | ✅ 全通过 |
| storage | 92 | 15 | **~107** | ✅ 全通过 |
| algo (总计) | **~376** | **0** | **~376** | ✅ 全通过 |
| ├─ traversal | ~47 | - | ~47 | ✅ |
| ├─ generators | 56 | - | 56 | ✅ |
| ├─ shortest_path | 32 | - | 32 | ✅ |
| ├─ mst | 16 | - | 16 | ✅ |
| ├─ connectivity | 21 | - | 21 | ✅ |
| ├─ flow | 33 | - | 33 | ✅ |
| ├─ matching | 21 | - | 21 | ✅ |
| ├─ euler 🆕 | 22 | - | 22 | ✅ |
| ├─ cutpoints 🆕 | 15 | - | 15 | ✅ |
| ├─ coloring 🆕 | 21 | - | 21 | ✅ |
| ├─ clique 🆕 | 14 | - | 14 | ✅ |
| └─ hamiltonian 🆕 | 20 | - | 20 | ✅ |
| root | 0 | 0 | 0 | — |
| **合计** | **~517** | **34** | **~551** | **✅** |

### Core 测试详情

| 文件 | 类型 | 数量 | 覆盖 |
|------|------|:----:|------|
| types_test.mbt | Blackbox | 24 | NodeId构造/Eq + Node构造/字段 + Edge构造/字段 + 组合 |
| error_test.mbt | Blackbox | 25 | 3变体×构造匹配 + Eq(11) + Result集成(7) |
| traits_wbtest.mbt | Whitebox | 19 | MockGraph 实现 6 Trait 共 26 方法 |

### Storage 测试详情

| 文件 | 类型 | 数量 | 覆盖 |
|------|------|:----:|------|
| directed_adj_list_test.mbt | Blackbox | 19 | CRUD + GraphDirected (in/out degree/neighbors) |
| undirected_adj_list_test.mbt | Blackbox | 15 | 双向语义 + 半存储优化 + edges_sorted |
| matrix_test.mbt | Blackbox | 15 | DirectedMatrix + UndirectedMatrix O(1)查询 |
| edge_list_test.mbt | Blackbox | 15 | EdgeListGraph + UndirectedEdgeListGraph |
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
- bubble_sort_by_weight 用于 edges_sorted 的冒泡排序实现

## 工具链

```bash
moon check               # 类型检查（零错误零警告）
moon test                # 运行全部测试
moon fmt && moon info     # 格式化 + 更新 .mbti 接口文件
moon build --target <tgt> # 构建（wasm/js/native）
moon coverage analyze    # 覆盖率分析
```

## 关键决策记录

| 日期 | 决策 | 原因 |
|------|------|------|
| 2026-05-08 | 4 层 trait 分层 → 6 层 | 新增 BatchReadable + EdgeIterable |
| 2026-05-08 | CSR 不实现 Writable | 里氏替换原则 (LSP) |
| 2026-05-17 | 无向图半存储优化 | 节省 ~50% 内存 |
| 2026-05-17 | 新增 CSC 格式 | 补齐调研文档，支持入边密集场景 |
| 2026-05-17 | 新增 UndirectedEdgeList | 补齐调研文档，支持无向 Kruskal |
| 2026-05-17 | converter 扩展至 8 函数 | 支持所有存储互转 |
| 2026-05-17 | storage struct 改 pub(all) + impl 改 pub | blackbox test 跨包可见性要求 (E4018/E4063) |
| 2026-05-17 | Matrix 构造改逐行初始化 | Array::make 二维数组共享 bug 修复 |
| 2026-05-17 | 转换器三层架构重构 | 有向(GraphDirected) + 无向(assert) + 语义(as_*) 分离 |
| 2026-05-17 | CSR/CSC 补充 GraphDirected trait | 各6方法(in/out neighbors/degree/predecessors/successors) |
| **2026-05-19** | **FlowNetwork 独立类型设计** | **流网络语义特殊（容量/流量矩阵），不强制适配 Graph trait** |
| **2026-05-19** | **Edmonds-Karp 算法选择** | **实现简洁（~40% code less），足够实用，为 Dinic 扩展预留接口** |
| **2026-05-19** | **深拷贝纯函数语义** | **算法修改输入数据时必须 deep_copy，保证原网络不被修改** |
| **2026-05-19** | **AGENTS.md v2.1.0 固化经验** | **Top10陷阱/算法开发流程/Git规范/错误速查扩展（避免重复踩坑）** |
| **2026-05-19** | **Roadmap P0-P3 全部完成** | **图生成器+最短路径+MST+连通性+网络流，包文档覆盖率 8/8 (100%)** |
| **2026-05-19** | **Dinic 最大流算法实现** | **比 EK 快一个数量级 O(E√V)，双算法并存可交叉验证** |
| **2026-05-19** | **Hungarian 匈牙利算法实现** | **二分图最大匹配 O(VE)，提供纯数据版本和 Trait 版本** |
| **2026-05-22** | **P5 图论核心算法扩展全部完成** | **Euler/Cutpoints/Coloring/Clique/Hamiltonian 共 5 模块, 92 tests** |
| **2026-05-22** | **Hierholzer 欧拉算法** | **O(E) 时间复杂度，支持有向/无向图路径和回路检测** |
| **2026-05-22** | **Tarjan 割点与桥检测** | **O(V+E) 单次 DFS，基于 DFN/Low 时间戳** |
| **2026-05-22** | **图着色算法集（4种）** | **贪心/Welsh-Powell/DSATUR启发式 + 回溯精确解，覆盖多项式和NP-C** |
| **2026-05-22** | **Bron-Kerbosch 最大团算法** | **O(3^{V/3}) 带枢轴优化，派生独立集和顶点覆盖** |
| **2026-05-22** | **哈密顿路径/TSP 算法集** | **回溯精确 + 最近邻启发式 + Held-Karp DP，覆盖 NP-Hard 场景** |
| **2026-05-23** | **Git Tags 版本管理 v0.5.0-v0.9.0** | **为每个 P5 模块创建独立的 minor 版本标签，清晰追踪模块完成节点** |
