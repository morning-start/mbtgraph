# mbtgraph AGENTS.md

MoonBit 生产级图算法库：**8 种存储 · 6 层 Trait · 65+ 算法 · 940 tests**。

---

## 1. 命令速查

| 作用 | 命令 |
|------|------|
| 格式化 | `moon fmt && moon info` |
| 编译检查 | `moon check` |
| 全量测试 | `moon test` |
| 单模块测试 | `moon test lib/algo/{模块名}` |
| 更新快照 | `moon test --update` |
| 覆盖率 | `moon coverage analyze && moon coverage report` |

| 站点 (site/) | 命令 |
|--------------|------|
| 开发 | `cd site && bun run dev` |
| 构建 | `cd site && bun run build` |

---

## 2. 架构速查

### 6 层 Trait

```
GraphReadable (12 方法, 所有存储)
├── GraphWritable      (+5, 动态存储专属)
├── GraphDirected      (+6, 入边查询)
│   └── GraphFull      = Writable + Directed (别名)
├── GraphBatchReadable (+2, CSR/CSC 专属)
└── GraphEdgeIterable  (+1, 边排序)
```

### 存储选型

```text
稀疏通用 → DirectedAdjList ⭐     | 无向通用 → UndirectedAdjList
稠密小图 → DirectedMatrix        | MST友好  → EdgeList
大静态图 → CSR (只读, 缓存友好)     | 入边密集 → CSC
```

### 算法双轨制

```moonbit
// A: Trait 兼容型（多数算法）
pub fn[G : @core.GraphReadable] dijkstra(graph : G, start : NodeId) -> ShortestPathResult

// B: 独立类型型（特殊语义）
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)  // 链式赋值
let result = dinic(net, 0, 3)
```

---

## 3. 编码硬规则

| # | 规则 | ✅ 正确 | ❌ 错误 |
|---|------|--------|--------|
| R1 | `@core.` 完全限定名 | `@core.NodeId(0)` | use 别名 |
| R2 | `(self)` 非 `mut self` | `let g = self` | `mut self` |
| R3 | 可变性按需 | 只改字段→`let g` | 重新赋值需 `let mut` |
| R4 | 可见性 | 核心类型 `pub(all)` | Trait `pub(open)` |
| R5 | for 不直接解构元组 | `for x in arr { match x { (a,b) => } }` | `for (a,b) in ...` |
| R6 | 嵌套泛型 `]]` 结尾 | `Array[Array[Double?]]` | `Array[Array[Double?>>` |
| R7 | 避免保留字 | `net`, `graph` | `fn`, `var` |
| R8 | 纯函数语义 | 算法前深拷贝 | 直接修改入参 |

### 禁止

- `mut self` — MoonBit 不支持
- `var` / `loop {}` — 已废弃，用 `let mut` / `while true {}`
- `use`/`using` 别名 — 用完全限定名
- `for (a,b) in arr` — 先绑定再 match

---

## 4. 高频错误 & 修复

| 现象 | 原因 | 修复 |
|------|------|------|
| `E0015` unused_mut | 字段不需改 | 去 `mut` |
| `E3002` Parse error | `mut self` / for 解构 / `>>` | 查 R2/R5/R6 |
| `E4036` read-only | struct 缺 `pub(all)` | 加 `pub(all)` |
| `E4145` sealed | trait 缺 `pub(open)` | 加 `pub(open)` |
| `E4021` unbound | trait 方法未限名 | `@core.Trait::method(self, ...)` |
| `E4139` ignore | 返回值没消费 | `let _ = ...` 或 `... \|> ignore` |
| 数组副作用 | 入参被改 | 算法前深拷贝 |

---

## 5. 开发流程

```
1. 读此文件 + CHANGELOG.md → 了解上下文
2. 读目标模块现有代码 → 理解模式
3. moon check → moon test → 确认基线
4. 实现 → 验证 → 提交
```

**提交规范**: `<type>(<scope>): <subject>`

| type | 场景 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修 bug |
| `test` | 测试 |
| `docs` | 文档 |
| `refactor` | 重构 |
| `chore` | 构建/工具 |

提交顺序: `feat(类型/算法)` → `test(测试)` → `docs(文档)`

---

## 6. 关键文件索引

| 内容 | 路径 |
|------|------|
| Trait 定义 | `lib/core/traits.mbt` |
| 核心类型 | `lib/core/types.mbt` |
| 错误类型 | `lib/core/error.mbt` |
| AdjList 实现 | `lib/storage/directed_adj_list.mbt` |
| 流网络示例 | `lib/algo/flow/` |
| 算法目录 | [文档站点](https://morning-start.github.io/mbtgraph/algorithms/catalog/) |
| API 参考 | [文档站点](https://morning-start.github.io/mbtgraph/api/core/) |

---

**版本**: v0.1.1 | **语言**: MoonBit | **协议**: MIT | **测试**: 940
