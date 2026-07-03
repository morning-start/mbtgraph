---
title: 编码规范
description: mbtgraph 项目的 MoonBit 编码约定、Trait 使用规范和 Git 提交约定
---

# 编码规范

> ⏱️ **预计阅读时间**: 8 分钟

## 强制规则

以下规则来自 `AGENTS.md`，所有贡献者必须遵守：

| # | 规则 | ✅ 正确 | ❌ 错误 |
|---|------|--------|--------|
| R1 | 使用 `@core.` 完全限定名 | `@core.NodeId(0)` | `use` 别名 |
| R2 | Impl 用 `(self)` 而非 `mut self` | `let g = self` | `mut self` |
| R3 | 可变性按需声明 | 只改字段→`let g` | 需重新赋值→`let mut g` |
| R4 | 可见性正确选择 | 核心类型→`pub(all)` | Trait→`pub(open) trait` |
| R5 | For 循环不直接解构元组 | 先绑定再 `match` | `for (a,b) in ...` |
| R6 | 嵌套泛型用 `]]` 结尾 | `Array[Array[Double?]]` | `Array[Array[Double?>>` |
| R7 | 避免保留字命名 | `net`, `graph` | `fn`, `var` |

## 命名约定

| 类别 | 规范 | 示例 |
|------|------|------|
| **函数** | `snake_case` | `add_node`, `find_shortest_path` |
| **类型/结构体** | `PascalCase` | `GraphReadable`, `BfsResult` |
| **常量** | `UPPER_SNAKE_CASE` | `MAX_NODES`, `INF` |
| **文件名** | `snake_case` | `dijkstra.mbt`, `bellman_ford.mbt` |
| **包名** | `snake_case` | `shortest_path`, `max_flow` |

## 禁止行为

1. **不要使用 `mut self` 参数**（MoonBit 不支持）→ 使用 `(self)` + 内部 `let g = self`
2. **不要在 `for` 中解构元组** → 先绑定再 `match`
3. **不要用 `use`/`using` 别名** → 使用完全限定名
4. **不要忽略 `.mbti` 变更** → 修改后运行 `moon info` 检查差异
5. **不要使用 `var` 声明变量** → 改用 `let mut`
6. **不要使用 `loop {}` 语法** → 改用 `while true {}`
7. **不要重复实现公共逻辑** → 使用 `shared_helpers.mbt`

## Trait 使用规范

mbtgraph 的 6 层 Trait 体系：

```
GraphReadable (只读基础)
├── GraphWritable     (可写)
├── GraphDirected     (有向)
│   └── GraphFull    = Writable + Directed
├── GraphBatchReadable (批量读取，CSR/CSC)
└── GraphEdgeIterable  (边排序，Kruskal)
```

算法实现应使用最通用的 Trait 约束：

```moonbit
// ✅ 如果只需要读，用 GraphReadable
pub fn[G : @core.GraphReadable] bfs(graph : G, start : @core.NodeId) -> BfsResult

// ✅ 如果需要写，用 GraphWritable
pub fn[G : @core.GraphWritable] add_node(g : G, data : Int) -> @core.NodeId
```

## 函数声明模式

### 模式 A：Trait 泛型函数（大多数算法）

```moonbit
pub fn[G : @core.GraphReadable] algo_name(
  graph : G,
  start : @core.NodeId,
  param : Int,
) -> ResultType {
  let g = graph  // 不可变引用
  // ... 实现 ...
}
```

### 模式 B：独立类型方法（流网络等特殊语义）

```moonbit
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 10.0)   // 链式调用，消费返回值
let result = dinic(net, 0, 3)
```

> 注意：链式调用**必须消费返回值**，不要使用 `ignore()` 丢弃。

## 数组与纯函数

所有算法保证纯函数语义——不修改输入数据：

```moonbit
// ✅ 深拷贝后操作
let capacity_copy = deep_copy_matrix(graph.capacity_matrix())
// ❌ 不要直接修改输入的矩阵
graph.capacity_matrix()[0][1] = 5.0
```

## Git 提交规范

### 提交格式

```
<type>(<scope>): <subject>

<body (可选)>
```

### Type 与 Scope

| Type | 场景 | 示例 |
|------|------|------|
| `feat` | 新功能/模块 | `feat(flow): add FlowNetwork base types` |
| `fix` | 修复 Bug | `fix(storage): correct Array::make 2D init` |
| `refactor` | 重构（不改行为） | `refactor(core): simplify trait visibility` |
| `test` | 测试代码 | `test(flow): add complete test suite` |
| `docs` | 文档 | `docs(flow): add README and design doc` |
| `chore` | 构建/工具 | `chore: update .mbti binding files` |

### 提交顺序

```
Commit 1: feat(scope): 基础类型和结构体
Commit 2: feat(scope): 算法实现
Commit 3: test(scope): 测试套件
Commit 4: docs(scope): 文档和设计说明
```

避免单次混合提交（代码 + 测试 + 文档），保持原子性。

---

**相关文档：**
- [开发环境搭建](/contributing/setup)
- [测试规范](/contributing/testing)
- [完整 AGENTS.md](https://github.com/morning-start/mbtgraph/blob/main/AGENTS.md)
