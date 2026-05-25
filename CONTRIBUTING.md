---
title: "mbtgraph 贡献者指南"
version: "0.1.0"
status: "active"
type: "contributing"
created: "2026-05-02"
updated: "2026-05-02"
author: "morning-start"
license: "MIT"
tags: ["contributing", "guide", "development"]
---

# 贡献指南

感谢你对 `mbtgraph` 感兴趣！我们欢迎所有形式的贡献，包括代码、文档、测试和 Bug 报告。

---

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
  - [报告 Bug](#报告-bug)
  - [提出新功能](#提出新功能)
  - [提交代码](#提交代码)
- [开发环境设置](#开发环境设置)
- [开发流程](#开发流程)
- [编码规范](#编码规范)
- [提交规范](#提交规范)
- [测试要求](#测试要求)
- [文档要求](#文档要求)

---

## 行为准则

本项目遵循 [Contributor Covenant](https://www.contributor-covenant.org/) 行为准则。请保持友好、尊重和包容的社区氛围。

---

## 如何贡献

### 报告 Bug

如果你发现了 Bug，请：

1. 搜索 [现有 Issues](https://github.com/morning-start/mbtgraph/issues) 确认是否已有报告
2. 创建新 Issue，包含：
   - **标题**: 简洁描述问题
   - **环境**: MoonBit 版本、操作系统
   - **复现步骤**: 详细的复现步骤
   - **预期行为**: 应该发生什么
   - **实际行为**: 实际发生了什么
   - **代码示例**: 最小复现代码

### 提出新功能

如果你想添加新算法或功能，请：

1. 先在 [Discussions](https://github.com/morning-start/mbtgraph/discussions) 或 Issues 中讨论
2. 说明功能的需求和使用场景
3. 提供算法的伪代码或参考文献
4. 与 maintainer 确认后再开始实现

### 提交代码

1. Fork 本仓库
2. 创建特性分支: `git checkout -b feature/amazing-feature`
3. 提交更改: `git commit -m 'feat: add amazing feature'`
4. 推送到分支: `git push origin feature/amazing-feature`
5. 提交 Pull Request

---

## 开发环境设置

### 前置要求

- **MoonBit**: 安装最新版 (https://moonbitlang.com)
- **Git**: 版本控制工具

### 快速开始

```bash
# 1. Fork 并克隆仓库
git clone https://github.com/YOUR_USERNAME/mbtgraph.git
cd mbtgraph

# 2. 安装依赖（如有）
# moon install ...

# 3. 验证环境
moon test

# 4. 配置 Git Hooks（推荐）
cp .githooks/* .git/hooks/
chmod +x .git/hooks/*
```

---

## 开发流程

### 分支策略

```
main (稳定分支)
  ↑
  │ PR
  │
feature/* (特性分支)
```

- `main`: 稳定分支，只能通过 PR 合并
- `feature/*`: 特性分支，从 `main` 创建
- `fix/*`: 修复分支，从 `main` 创建
- `docs/*`: 文档分支，从 `main` 创建

### 工作流

1. 从 `main` 创建特性分支
2. 实现功能，编写测试
3. 运行 `moon test` 确保通过
4. 运行 `moon fmt` 格式化代码
5. 运行 `moon info` 更新接口
6. 提交并推送
7. 创建 Pull Request
8. 等待 Review
9. 合并到 `main`

---

## 编码规范

### 命名约定

| 类别 | 规范 | 示例 |
|------|------|------|
| **类型/Struct** | PascalCase | `DirectedGraph`, `BFSResult` |
| **Trait** | PascalCase | `MutableGraph`, `WeightedGraph` |
| **公开函数** | snake_case | `breadth_first_search`, `dijkstra` |
| **私有函数** | 下划线前缀 | `_dfs_visit` |
| **常量** | UPPER_SNAKE_CASE | `DEFAULT_DAMPING_FACTOR` |

### 代码组织

- 使用块风格，块之间用 `///|` 分隔
- 相关函数放在同一文件中
- 每个 `.mbt` 文件应该有清晰的职责

### 文档注释

所有公开函数必须有文档注释：

```moonbit
/// 广度优先搜索
///
/// # 参数
/// - graph: 图
/// - source: 起始节点
///
/// # 返回值
/// BFSResult 包含遍历顺序、距离和父指针
///
/// # 复杂度
/// 时间 O(V+E), 空间 O(V)
fn breadth_first_search(graph: &Graph, source: NodeId) -> BFSResult {
  // ...
}
```

---

## 提交规范

### Commit Message 格式

遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Type 类型

| Type | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(algo): add bellman-ford shortest path` |
| `fix` | Bug 修复 | `fix(core): fix edge duplication in undirected graph` |
| `docs` | 文档 | `docs(readme): add installation instructions` |
| `test` | 测试 | `test(algo): add bfs test cases` |
| `refactor` | 重构 | `refactor(core): simplify graph trait` |
| `perf` | 性能优化 | `perf(algo): optimize dijkstra with fibonacci heap` |
| `ci` | CI 配置 | `ci: add github actions workflow` |
| `chore` | 杂项 | `chore: update dependencies` |

### Scope 范围

| Scope | 说明 |
|-------|------|
| `core` | 核心模块 |
| `algo` | 算法模块 |
| `analysis` | 分析模块 |
| `flow` | 流网络模块 |
| `utils` | 工具模块 |
| `test` | 测试 |
| `docs` | 文档 |
| `ci` | CI/CD |

### 示例

```
feat(algo): add kosaraju scc algorithm

- Implement two-pass DFS algorithm
- Add SCCResult type with components and component_id
- Add unit tests with standard test cases

Closes #123
```

---

## 测试要求

### 测试文件命名

- 黑盒测试: `<module>_test.mbt`
- 白盒测试: `<module>_wbtest.mbt`

### 测试覆盖率

| 模块 | 最低覆盖率 |
|------|----------|
| **core** | ≥ 90% |
| **algo** | ≥ 90% |
| **analysis** | ≥ 85% |
| **flow** | ≥ 85% |
| **utils** | ≥ 80% |

### 测试类型

1. **正确性测试**: 使用 `assert_eq` 验证算法输出
2. **属性测试**: 验证算法属性（如 PageRank scores 之和 ≈ 1.0）
3. **边界测试**: 空图、单节点、不连通图等
4. **错误处理测试**: 验证错误返回

### 运行测试

```bash
# 运行所有测试
moon test

# 运行特定目标测试
moon test --target native

# 更新快照
moon test --update

# 覆盖率分析
moon coverage analyze > uncovered.log
```

---

## 文档要求

### 文档类型

| 文档 | 路径 | 说明 |
|------|------|------|
| README | `README.mbt.md` | 项目入口文档 |
| 架构设计 | `docs/architecture/` | 架构、模块划分 |
| 需求规格 | `docs/requirements/srs.md` | 软件需求 |
| 系统设计 | `docs/design/sad.md` | 系统架构 |
| 测试策略 | `docs/quality/test_strategy.md` | 测试计划 |

### 文档更新

- 添加新算法时，更新架构设计文档
- 修改 API 时，更新 SRS 和 SAD
- 添加测试用例时，更新测试策略文档

---

## 📞 联系方式

- **Issues**: [GitHub Issues](https://github.com/morning-start/mbtgraph/issues)
- **Discussions**: [GitHub Discussions](https://github.com/morning-start/mbtgraph/discussions)

---

**最后更新**: 2026-05-02
