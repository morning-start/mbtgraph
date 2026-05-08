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
- **Architecture**: MoonBit packages organized per directory with `moon.pkg` dependency declarations

## Project Structure

```
mbtgraph/
├── moon.mod.json          # Module metadata
├── AGENTS.md              # This file - Agent workflow guide
├── MEMORY.md              # Persistent memory log
├── memory/                # Memory directory (for dated logs)
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

### How to Use Memory

1. **Before starting**: Read MEMORY.md for recent context
2. **During work**: Note significant decisions and changes
3. **After completion**: Update MEMORY.md with operation summary

### Memory Format

```markdown
## YYYY-MM-DD

### 操作：[Brief description]

- [Key decision or action]
- [Important finding]
- [Change made]
```

### Memory Directory

- `MEMORY.md` — Current memory log
- `memory/` — Directory for dated memory files (if needed)

## Tooling Reference

| Tool | Purpose |
|------|---------|
| `moon fmt` | Code formatting |
| `moon info` | Generate package interfaces (.mbti) |
| `moon ide` | IDE helpers: peek-def, outline, find-references |
| `moon test` | Run test suite |
| `moon build` | Build project |
| `moon run` | Execute entry point |

## Official Resources

- [MoonBit Documentation](https://docs.moonbitlang.com)
- [MoonBit Language Reference](https://docs.moonbitlang.cn/language/index.html)
- [MoonBit Tutorials](https://docs.moonbitlang.cn/tutorial/index.html)
- [Mooncakes Package Registry](https://mooncakes.io)
- [MoonBit Skills Repository](https://github.com/moonbitlang/skills)
