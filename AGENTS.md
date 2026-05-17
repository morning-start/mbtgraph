---
name: mbtgraph-agents
version: v2.0.0
author: mbtgraph-team
description: MoonBit 图算法库 Agent 协作配置
tags: [moonbit, graph-algorithms, trait-based, storage-patterns]
---

# mbtgraph — MoonBit 图算法库

MoonBit 图数据结构库：邻接表/矩阵/CSR/边集 + Trait 抽象层。

## 开发环境

```bash
moon fmt && moon info        # 格式化 + 更新接口
moon test                    # 运行测试
```

## 技术栈

| 组件 | 技术 | 说明 |
|------|------|------|
| 语言 | MoonBit | native/wasm 后端 |
| 架构 | Trait-based | GraphReadable → Writable → Directed |
| 测试 | 双轨制 | Blackbox (`*_test.mbt`) + Whitebox (`*_wbtest.mbt`) |

## 项目结构

```
src/
├── core/                     # 类型 + trait 定义
│   ├── types.mbt            # NodeId, Node, Edge
│   ├── traits.mbt           # GraphReadable 等核心 trait
│   └── error.mbt            # GraphError
└── storage/                  # 存储实现
    ├── directed_adj_list.mbt # 有向邻接表（参考实现）⭐
    ├── undirected_adj_list.mbt # 无向邻接表（半存储优化）
    ├── shared_helpers.mbt   # 公共辅助函数（同包直接调用）
    └── converter.mbt        # 格式转换器
```

**关键入口**: 新类型→`types.mbt` | 新trait→`traits.mbt` | 新存储→参考 `directed_adj_list.mbt`

## 编码规范

### 🔴 强制规则（CI 检查，必须遵守）

| # | 规则 | ✅ 正确 | ❌ 错误 | 检测方式 |
|---|------|--------|--------|---------|
| R1 | 使用 `@core.` 完全限定名 | `@core.NodeId(0)` | use 别名 | Code Review |
| R2 | Impl 用 `(self)` 非 `mut self` | `let g = self` | `mut self` | 编译报错 E3002 |
| R3 | 可变性按需声明 | 只改字段→`let g` | 需重新赋值→`let mut g` | Warning E0015 |
| R4 | 可见性正确选择 | 核心类型→`pub(all)` | trait→`pub(open)trait` | 编译报错 E4036/E4145 |
| R5 | For 循环不直接解构元组 | 先绑定再 match | `for (a,b) in ...` | 编译报错 E3002 |

### 🟡 推荐惯例（Code Review 关注）

- Match 多语句用 `{}` 包裹（不用逗号分隔）
- Option 匹配不需要 `_ => ()` 分支
- 同包内函数直接调用，无需模块前缀
- 公共逻辑复用 `shared_helpers.mbt`，不重复实现

### ❌ 禁止行为

1. 不要使用 `mut self` 参数（MoonBit 不支持）
2. 不要在 for 中解构元组（先绑定再 match）
3. 不要用 use/using 别名（使用完全限定名）
4. 不要忽略 .mbti 变更（每次修改后检查 `git diff -- "*.mbti"`）
5. 不要重复实现公共逻辑（使用 shared_helpers）

## 架构概要

### Trait 分层（4层）

```
GraphReadable (所有存储)
├── GraphWritable (仅动态存储: AdjList/Matrix/EdgeList)
└── GraphDirected (仅 Directed* 存储)
    └── GraphFull = Writable + Directed
```

**核心决策**:
- CSR 为只读格式，故意不实现 GraphWritable（LSP 原则）
- 有向/无向用独立结构体（非 runtime 字段判断）
- 算法约束: `fn[G: GraphReadable] bfs(g: G) -> ...`

详细设计: [docs/design/graph_trait_and_module_architecture.md](file:///e:/Workplace/APP/MoonBit/mbtgraph/docs/design/graph_trait_and_module_architecture.md)

## 测试指南

```bash
moon test                # 全量测试
moon test --update       # 更新快照
moon coverage analyze    # 覆盖率分析
```

**要求**: 核心高覆盖率 | 明确结果用 assertion | 复杂输出用 snapshot

## 错误速查

| 错误码 | 含义 | 快速修复 |
|--------|------|---------|
| **E0015** | unused_mut | 改为 `let`（只需改字段时）|
| **E3002** | Parse error | 检查: mut self / for解构 / 逗号分支 |
| **E4036** | read-only type | 改为 `pub(all) struct` |
| **E4145** | sealed trait | 改为 `pub(open)trait` |
| **E4021** | unbound variable | 用 `@core.Trait::method(self, ...)` |

**Top 5 陷阱**:
1. mut self → `(self)` + 内部 `let g = self`
2. For元组解构 → `for x in arr { match x { (a,b) => } }`
3. Match多语句 → `{ stmt; stmt }` （不用逗号）
4. 构造 pub struct 失败 → 核心类型必须 `pub(all)`
5. Trait方法调用未绑定 → 必须完全限定名

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

// Block 风格: ///| 分隔符 | 废弃代码放 deprecated.mbt
```
