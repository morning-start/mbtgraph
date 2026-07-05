# mbtgraph — Agent 指令集

MoonBit 生态首个生产级图算法库。**当前阶段**: v0.1.1 · API 已冻结 · 文档生态建设期 · 940 tests

---

## 🚨 红牌门禁（触碰即否决）

下列操作**必须明确向用户申请许可**，不得自行执行：

| 门禁 | 原因 |
|------|------|
| 修改 `lib/core/traits.mbt` 中任意的 Trait 定义 | API 已冻结，破坏性变更需 major 版本 |
| 修改 `lib/core/types.mbt` 中的 `NodeId`/`Node`/`Edge`/`Weight` | 核心类型，全库依赖 |
| 删除或改名公开函数/结构体 | 破坏向后兼容 |
| 修改 `moon.pkg` 的 `deps` 或新增外部依赖 | 需要评估依赖树影响 |
| 直接推送（`git push`）到 `master` | 必须先经用户确认 |
| 删除文件 | 不可逆操作 |

---

## 🟢 无门禁操作（直接执行）

- 编辑 `lib/algo/*.mbt`（仅修改算法内部实现，不改变公开 API 签名）
- 编辑 `lib/storage/*.mbt`（不改变 Trait impl 签名）
- 编辑 `lib/io/*.mbt`（不改变公开函数签名）
- 编辑 `site/src/**`（站点内容和组件）
- 编辑 `AGENTS.md`、`CHANGELOG.md`、`README*.md`
- 运行 `moon fmt`、`moon check`、`moon test`
- 读取任意文件

---

## 🎯 项目阶段定位

### 当前不在做什么

| ❌ 不做 | 理由 |
|---------|------|
| 新算法模块 | v0.1.1 已覆盖 65+ 算法，API 已冻结 |
| 核心 Trait 重构 | 6 层 Trait 设计已定型冻结 |
| 新存储结构 | 8 种存储已覆盖所有主流场景 |

### 当前在做什么

| ✅ 做 | 优先级 |
|-------|:------:|
| 文档站点完善（site/） | 🔴 P0 |
| 可视化演示修复与优化 | 🔴 P0 |
| 质量保障（测试补充、边界 case） | 🟡 P1 |
| mooncakes.io 发布准备 | 🟡 P1 |

---

## 🧱 架构核心原则（必须写进代码里）

### 原则 1: 纯函数语义

```moonbit
// ✅ 正确：算法前深拷贝，输入不可变
pub fn dijkstra(graph : G, source : NodeId) -> ShortestPathResult {
  // graph 不会被修改
}

// ❌ 错误：不得修改输入参数
```

### 原则 2: Trait 泛型 + 完全限定名

```moonbit
// ✅ 正确：使用 @core. 完全限定名
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult
  let n = @core.GraphReadable::node_count(graph)

// ❌ 错误：不得 use/using 别名
```

### 原则 3: 独立类型模式（流网络等）

```moonbit
// 链式赋值，返回值必须消费
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)
let result = dinic(net, 0, 3)
```

### 原则 4: 返回值不可忽略

```moonbit
// ✅ 正确
let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)
@core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore

// ❌ 错误
@core.GraphWritable::add_edge(g, n0, n1, 1.0)  // 编译警告 E4139
```

---

## 📐 架构速查

### 6 层 Trait

```
GraphReadable (12方法, 所有存储)
├── GraphWritable      (+5, 动态存储)
├── GraphDirected      (+6, 入边查询)
│   └── GraphFull      = Writable + Directed
├── GraphBatchReadable (+2, CSR/CSC 专属)
└── GraphEdgeIterable  (+1, 边排序)
```

### 存储选型

| 场景 | 选型 | 空间 | 邻居查询 |
|------|------|:----:|:--------:|
| 通用稀疏图 | `DirectedAdjList` ⭐ | O(V+E) | O(k) |
| 无向通用 | `UndirectedAdjList` | O(V+E) | O(k) |
| 稠密小图 | `DirectedMatrix` | O(V²) | O(V) |
| MST/Kruskal | `EdgeList` | O(E) | O(E) |
| 大规模静态 | `CSR` | O(V+E) | O(k) |
| 入边密集 | `CSC` | O(V+E) | O(k) |

---

## ⚡ 高频编译错误

| 错误 | 原因 | 秒修 |
|------|------|------|
| `E0015` unused_mut | 字段无需 `mut` | 去掉 `mut` |
| `E3002` Parse | `mut self` / for 解构 / `>>` | 改 `(self)` / 先 bind 再 match / 用 `]]` |
| `E4036` read-only | struct 缺 `pub(all)` | 加 `pub(all)` |
| `E4145` sealed | trait 缺 `pub(open)` | 加 `pub(open)` |
| `E4021` unbound | trait 方法缺限定名 | `@core.Trait::method(self, ...)` |
| `E4139` ignore | 返回值未消费 | `let _ = ...` 或 `... \|> ignore` |
| 数组副作用 | 直接修改入参数组 | 算法前 `deep_copy_matrix()` |
| `var` 废弃 | 用了 `var` | 改为 `let mut` |
| `loop {}` 废弃 | 用了 `loop` | 改为 `while true {}` |

**最高频 3 个陷阱**: `mut self` > for 元组解构 > `>>` 嵌套泛型。

---

## 🔧 命令

```bash
moon fmt && moon info   # 格式化 + 更新接口
moon check              # 编译检查
moon test               # 全量测试
moon test lib/algo/xxx  # 单模块测试

bun run dev   # site/ 开发服务器
bun run build # site/ 生产构建
```

---

## 📁 关键文件

| 内容 | 路径 |
|------|------|
| Trait 定义 | `lib/core/traits.mbt` |
| 核心类型 | `lib/core/types.mbt` |
| 错误类型 | `lib/core/error.mbt` |
| 有向邻接表（参考实现） | `lib/storage/directed_adj_list.mbt` |
| 流网络模式（独立类型示例） | `lib/algo/flow/` |
| 站点内容 | `site/src/content/docs/` |
| 可视化页面 | `site/src/pages/visualizations/` |

---

**版本**: v0.1.1 | **协议**: MIT | **测试**: 940 | **API 状态**: ✅ 冻结
