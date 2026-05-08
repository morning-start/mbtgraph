# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

You can browse and install extra skills here:
<https://github.com/moonbitlang/skills>

## Every Session

1. Read MEMORY.md — check recent context and operations
2. Read this AGENTS.md — this is your workflow guide
3. Follow the workflow below for all tasks

## Project Overview

- **Module**: `morning-start/mbtgraph`
- **Language**: MoonBit (AI-native language for cloud & edge computing)
- **License**: Apache-2.0
- **Purpose**: Graph data structure and algorithm library

## Project Architecture

### Package Structure

```
src/
├── core/          # 基础类型 + trait 定义 (NodeId, Node, Edge, GraphError, Traits)
├── storage/       # 存储实现（每个子包一种存储方式）
│   ├── adjacency_list/   # 邻接表（默认实现，支持动态增删）
│   ├── adjacency_matrix/ # 邻接矩阵（稠密图优化）
│   ├── csr/              # CSR（大规模只读图）
│   ├── edge_list/        # 边集数组（边排序友好）
│   ├── hybrid/           # 混合图（快速查询）
│   └── converter.mbt     # 格式转换器
├── algorithms/    # 图算法（遍历/最短路径/MST/连通性/拓扑排序）
├── generators/    # 图生成器（经典图/随机图）
└── utils/         # 工具层（序列化等）
```

### Trait 分层体系

采用 4 层 trait 架构，遵循 SOLID 原则（特别是 LSP 和 ISP）：

```
GraphReadable[N, E]  ← 基础只读（所有存储都实现）
    ├── GraphWritable[N, E]  ← 可写（仅动态存储实现）
    └── GraphDirected[N, E]  ← 有向图入边查询
            └── GraphFull[N, E]  ← 完整图别名（= Writable + Directed）
```

**核心决策**:
- CSR 等只读存储**不实现** `GraphWritable`，避免违反里氏替换原则
- MoonBit 支持 `pub trait B: A` 继承语法
- 算法使用 trait 约束 `bfs[G: GraphReadable](g: G)` 而非具体类型
- 保留现有 `AdjGraph` 作为向后兼容类型别名

**实现优先级**: P0 核心 trait → P1 邻接表 → P2 基础算法 → P3 CSR → P4+ 扩展

详细设计文档: [docs/design/graph_trait_and_module_architecture.md](file:///e:/Workplace/APP/MoonBit/mbtgraph/docs/design/graph_trait_and_module_architecture.md)

## Project Structure

```
mbtgraph/
├── moon.mod.json          # Module metadata
├── AGENTS.md              # This file - Agent workflow guide
├── MEMORY.md              # Persistent memory log (project-level)
├── memory/                # Memory directory (for dated session logs)
├── docs/
│   └── design/            # Design documents and surveys
└── src/                   # Source packages (each with moon.pkg)
    ├── *.mbt              # Source files
    ├── *_test.mbt         # Blackbox test files
    └── *_wbtest.mbt       # Whitebox test files
```

**Package Organization**:
- Each directory contains a `moon.pkg` file listing dependencies
- Blackbox tests: `*_test.mbt` (external API testing)
- Whitebox tests: `*_wbtest.mbt` (internal implementation testing)

## MoonBit Skills Guide

### Available Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `moonbit-core-skill` | Core syntax, types, functions | Basic language features |
| `moonbit-data-structures-skill` | Arrays, tuples, structs, enums, Map, Set | Data structure design |
| `moonbit-tutorial-skill` | Environment setup, Hello World, project structure | Newcomer onboarding |
| `moonbit-functions-skill` | Higher-order functions, closures, pipes | Functional programming |
| `moonbit-pattern-matching-skill` | match, destructuring, guards | Pattern matching tasks |
| `moonbit-generics-skill` | Generics, Traits, impl, type constraints | Abstraction & reuse |
| `moonbit-error-handling-skill` | Option, Result, raise, try/catch | Error handling |
| `moonbit-toolchain-skill` | moon CLI, compile, build, format | Build & tooling |
| `moonbit-testing-skill` | Unit tests, expect tests, coverage | Testing & debugging |
| `moonbit-packages-skill` | mooncakes, dependency management | Package management |
| `moonbit-wasm-skill` | wasm/wasm-gc backend | WebAssembly targets |
| `moonbit-js-skill` | JavaScript backend | Node.js/browser targets |
| `moonbit-native-skill` | native/llvm backend | Native performance |

### Skill Selection Flow

1. **Task involves syntax/language features** → `moonbit-core-skill`
2. **Task involves data modeling** → `moonbit-data-structures-skill`
3. **Task involves testing** → `moonbit-testing-skill`
4. **Task involves build/CLI** → `moonbit-toolchain-skill`
5. **Task involves dependencies** → `moonbit-packages-skill`
6. **Task involves error handling** → `moonbit-error-handling-skill`

## Development Commands

### Essential Commands

```bash
# Format code
moon fmt

# Update package interfaces (.mbti files)
moon info

# Run tests
moon test

# Run benchmarks
moon bench

# Run tests with coverage
moon coverage analyze > uncovered.log

# Update snapshot tests
moon test --update

# Build project
moon build

# Run main entry
moon run cmd/main
```

### Recommended Workflow

```bash
# 1. Format and update interfaces
moon info && moon fmt

# 2. Check .mbti diffs for expected changes
git diff -- "*.mbti"

# 3. Run tests
moon test

# 4. If snapshots changed, update them
moon test --update
```

## Coding Conventions

### Block Style

- MoonBit code uses block style, each block separated by `///|`
- Block order is irrelevant; process blocks independently during refactoring
- Keep deprecated blocks in `deprecated.mbt` per directory

### Naming & Style

- Follow MoonBit standard formatting (`moon fmt`)
- Use descriptive names for functions and types
- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for stable results
- Use snapshot tests for behavior recording
- For scientific computations, prefer assertion tests over snapshots

### Interface Files (.mbti)

- Each package has a generated `.mbti` interface file
- If `.mbti` doesn't change, your refactoring is externally invisible
- Always check `.mbti` diffs after changes

## Testing Strategy

### Test Types

| Type | File Suffix | Purpose |
|------|-------------|---------|
| Blackbox | `*_test.mbt` | External API testing |
| Whitebox | `*_wbtest.mbt` | Internal implementation testing |

### Test Commands

```bash
# Run all tests
moon test

# Update snapshot tests
moon test --update

# Analyze coverage
moon coverage analyze > uncovered.log
```

### Coverage Requirements

- Aim for high coverage on core logic
- Use `uncovered.log` to identify untested code paths
- Prefer assertion tests for well-defined results
- Use snapshot tests for complex output formatting

## Memory System

### Memory Architecture

本项目采用双层记忆架构：

| 层级 | 位置 | 用途 | 内容 |
|------|------|------|------|
| **项目记忆** | `MEMORY.md` | 项目级持久化记忆 | 项目关键决策、架构变更、重要约定、现状描述 |
| **每日记忆** | `memory/YYYY-MM-DD.md` | 会话级操作日志 | 当天具体操作、临时上下文、短期发现 |

### How to Use Memory

**Every Session 启动流程**:
1. 读取 `MEMORY.md` — 了解项目级记忆和关键约定
2. 读取 `memory/YYYY-MM-DD.md`（今天）— 检查今日已有操作上下文
3. 读取 `memory/YYYY-MM-DD.md`（昨天）— 了解最近操作背景（可选）

**During Work**:
- 重要决策 → 更新 `MEMORY.md`
- 日常操作 → 追加到 `memory/YYYY-MM-DD.md`

**After Completion**:
- 项目级变更：更新 `MEMORY.md`（聚焦现状，不区分日期）
- 会话级记录：写入 `memory/YYYY-MM-DD.md`

### Memory Format

**项目记忆 (MEMORY.md)**:
聚焦项目现状，包含架构、规范、决策等，不按日期区分。

**每日记忆 (memory/YYYY-MM-DD.md)**:
```markdown
# YYYY-MM-DD Memory Log

## 操作：[Brief description]

- [Key decision or action]
- [Important finding]
- [Change made]
```

### Memory Files

- `MEMORY.md` — 项目记忆，存储关键决策和架构约定
- `memory/` — 每日记忆目录，按日期存储操作日志（如 `2026-05-08.md`）

## Tooling Reference

| Tool | Purpose |
|------|---------|
| `moon fmt` | Code formatting |
| `moon info` | Generate package interfaces (.mbti) |
| `moon ide` | IDE helpers: peek-def, outline, find-references |
| `moon test` | Run test suite |
| `moon bench` | Run benchmarks |
| `moon build` | Build project |
| `moon run` | Execute entry point |

## Official Resources

- [MoonBit Documentation](https://docs.moonbitlang.com)
- [MoonBit Language Reference](https://docs.moonbitlang.cn/language/index.html)
- [MoonBit Tutorials](https://docs.moonbitlang.cn/tutorial/index.html)
- [Mooncakes Package Registry](https://mooncakes.io)
- [MoonBit Skills Repository](https://github.com/moonbitlang/skills)
