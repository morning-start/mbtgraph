---
title: "mbtgraph 贡献者指南"
version: "2.0.0"
status: "active"
type: "contributing"
created: "2026-05-02"
updated: "2026-06-21"
author: "morning-start"
license: "MIT"
tags: ["contributing", "guide", "development"]
---

# 贡献指南

感谢你对 `mbtgraph` 感兴趣！我们欢迎所有形式的贡献，包括代码、文档、测试和 Bug 报告。

---

## 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [开发环境设置](#开发环境设置)
- [项目结构概览](#项目结构概览)
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

1. 搜索 [现有 Issues](https://github.com/morning-start/mbtgraph/issues) 确认是否已有报告
2. 创建新 Issue，包含：标题、环境（MoonBit 版本、OS）、复现步骤、预期/实际行为、最小复现代码

### 提出新功能

1. 先在 [Discussions](https://github.com/morning-start/mbtgraph/discussions) 或 Issues 中讨论
2. 说明功能需求和使用场景，提供算法伪代码或参考文献
3. 与 maintainer 确认后再开始实现

### 提交代码

1. Fork 本仓库
2. 创建特性分支: `git checkout -b feature/amazing-feature`
3. 实现功能 + 编写测试
4. 运行 `uv run python tests/gen/all.py` 重新生成随机图测试（如涉及算法模块）
5. 提交: `git commit -m 'feat(algo): add amazing algorithm'`
6. 推送: `git push origin feature/amazing-feature`
7. 创建 Pull Request（CI 必须通过）

---

## 开发环境设置

### 前置要求

| 工具 | 版本 | 用途 |
|------|------|------|
| **MoonBit** | 最新 | 编译、测试、格式化 |
| **Git** | 2.x | 版本控制 |
| **uv** | 0.11+ | Python 环境管理（测试生成用） |
| **Python** | 3.10+ | NetworkX 随机图测试生成 |

### 快速开始

```bash
# 1. Fork 并克隆仓库
git clone https://github.com/YOUR_USERNAME/mbtgraph.git
cd mbtgraph

# 2. 验证环境（772 tests 全通过）
moon test

# 3. 配置 Git Hooks（pre-commit: fmt+info+check, pre-push: check+test）
git config core.hooksPath .githooks

# 4. 安装 Python 测试生成依赖（可选，用于扩展测试）
cd tests && uv sync && cd ..
```

---

## 项目结构概览

```
lib/
├── core/                      # 核心抽象层
│   ├── types.mbt             # NodeId / Node / Edge 基础类型
│   ├── traits.mbt            # 5 层 Trait 分层体系
│   └── error.mbt             # GraphError 错误类型
│
├── storage/                   # 存储实现层 (8 种)
│   ├── directed_adj_list.mbt # 有向邻接表（推荐默认）
│   ├── undirected_adj_list.mbt # 无向邻接表（半存储优化）
│   ├── directed_matrix.mbt   # 有向邻接矩阵
│   ├── undirected_matrix.mbt # 无向邻接矩阵
│   ├── edge_list.mbt         # 有向边列表
│   ├── undirected_edge_list.mbt # 无向边列表
│   ├── csr.mbt               # 压缩稀疏行 CSR（只读）
│   ├── csc.mbt               # 压缩稀疏列 CSC（只读）
│   ├── converter.mbt         # 10 个格式转换函数
│   └── shared_helpers.mbt    # 公共辅助函数
│
├── algo/                      # 算法模块 (18 个)
│   ├── traversal/            # 遍历 [BFS/DFS/环检测/拓扑排序]
│   ├── shortest_path/        # 最短路径 [Dijkstra/BF/FW/A*/Bidirectional]
│   ├── mst/                  # 最小生成树 [Kruskal/Prim]
│   ├── connectivity/         # 连通性 [CC/Tarjan/Kosaraju/BCC]
│   ├── flow/                 # 网络流 [Edmonds-Karp/Dinic/Push-Relabel]
│   ├── matching/             # 图匹配 [Hopcroft-Karp/Hungarian/Edmonds]
│   ├── euler/                # 欧拉路径 [Hierholzer]
│   ├── cutpoints/            # 割点与桥 [Tarjan]
│   ├── coloring/             # 图着色 [Greedy/WP/DSATUR/Edge]
│   ├── clique/               # 团检测 [Bron-Kerbosch/独立集/顶点覆盖]
│   ├── hamiltonian/          # 哈密顿/TSP [回溯/Held-Karp]
│   ├── pagerank/             # PageRank
│   ├── centrality/           # 中心性 [Degree/Betweenness/Closeness/Eigenvector/Katz/Harmonic]
│   ├── community/            # 社区检测 [Louvain/Leiden/LabelPropagation]
│   ├── recognition/          # 图识别 [Bipartite/Complete/Tree/Chordal]
│   ├── dense_subgraph/       # 稠密子图 [K-Core/三角形/聚类系数]
│   ├── link_prediction/      # 链接预测 [CommonNeighbors/Jaccard/AA/PA]
│   ├── operators/            # 图运算 [Complement/Reverse/Union/Cartesian/Tensor/Lex/Line/Power]
│   └── integration/          # Python/NetworkX 随机图集成测试
│
├── io/                        # I/O 模块
│   ├── dot.mbt               # DOT 格式读写
│   ├── json_serializer.mbt   # JSON 格式读写
│   └── graph_stats.mbt       # 图统计工具
│
└── utils/
    └── generators/           # 图生成器
        ├── classic.mbt       # 完全图/环图/路径图/星型图
        ├── random.mbt        # Erdos-Renyi 随机图
        ├── grid.mbt          # 网格图
        └── bipartite.mbt     # 二分图

tests/
├── gen/                       # Python 测试生成工具
│   ├── gen_fixtures.py       # 每算法生成 5 个随机图 + NetworkX ground truth
│   ├── gen_tests.py          # 自动生成 MoonBit 集成测试文件
│   ├── all.py                # 主控脚本（一键生成）
│   └── utils.py              # 公共 JSON 导出函数
└── fixtures/                  # 按模块分目录的 JSON fixture 数据
```

---

## 开发流程

### 分支策略

```
master (稳定分支, CI 必须通过)
  ↑
  │ PR (require 1 approval + CI pass)
  │
feature/* (特性分支)
```

- `master`: 稳定分支，只能通过 PR 合并，CI 必须通过
- `feature/*`: 从 `master` 创建
- `fix/*`: 从 `master` 创建
- `docs/*`: 从 `master` 创建

### 工作流

1. 从 `master` 创建特性分支
2. 实现功能，编写测试
3. 如涉及算法模块，运行 `cd tests && uv run python gen/all.py` 重新生成随机图测试
4. 运行 `moon test` 确保通过（pre-commit 会自动运行）
5. 提交并推送
6. 创建 Pull Request
7. 等待 CI 通过 + Review 批准
8. 合并到 `master`

### CI/CD 流水线

**本地 pre-commit（每次提交自动运行）：**
1. Security scan — 检测密钥/凭证
2. `moon fmt` — 格式化 + 自动重新 stage
3. `moon info` — 更新 .mbti 接口文件 + 自动重新 stage
4. `moon check` — 编译检查（含弃用警告拦截）

**本地 pre-push（每次推送自动运行）：**
5. `moon check` — 编译检查（含弃用警告拦截）
6. `moon test` — 运行全量 772 测试

**本地 commit-msg（每次提交自动检查）：**
7. Conventional Commits 格式校验

**GitHub CI（PR 合并前必须通过）：**
- `moon fmt --check`
- `moon fmt && git diff --exit-code`（格式一致性门禁）
- `moon check`（编译 + 弃用警告拦截）
- `moon test`（全量测试 + 弃用警告拦截）
- Bun 构建 site

**分支保护（master）：**
- 要求 CI 通过
- 要求 1 个 reviewer 批准
- 管理员也受约束

---

## 编码规范

> 完整编码规范见 [`AGENTS.md`](AGENTS.md)，以下为核心规则速查。

### 强制规则（CI 检查）

| # | 规则 | ✅ 正确 | ❌ 错误 |
|---|------|--------|--------|
| R1 | 使用 `@core.` 完全限定名 | `@core.NodeId(0)` | use 别名 |
| R2 | Impl 用 `(self)` 非 `mut self` | `let g = self` | `mut self` |
| R3 | 可变性按需声明 | 只改字段→`let g` | 需重新赋值→`let mut g` |
| R4 | 可见性正确选择 | 核心类型→`pub(all)` | trait→`pub(open)trait` |
| R5 | For 循环不直接解构元组 | 先绑定再 match | `for (a,b) in ...` |
| R6 | 嵌套泛型用 `]]` 结尾 | `Array[Array[Double?]]` | `Array[Array[Double?>>` |
| R7 | 避免保留字命名 | `net`, `graph` | `fn`, `var` |

### 命名约定

| 类别 | 规范 | 示例 |
|------|------|------|
| 类型/Struct | PascalCase | `DirectedGraph`, `BFSResult` |
| Trait | PascalCase | `GraphReadable`, `GraphWritable` |
| 公开函数 | snake_case | `breadth_first_search`, `dijkstra` |
| 私有函数 | 无前缀 | `ek_bfs`, `deep_copy_matrix` |

### 文档注释

所有公开函数必须有文档注释（参数、返回值、复杂度）。

---

## 提交规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/)：

```
<type>(<scope>): <description>
```

| Type | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(hamiltonian): add TSP algorithms` |
| `fix` | Bug 修复 | `fix(core): fix edge duplication` |
| `test` | 测试 | `test(flow): add dinic test cases` |
| `refactor` | 重构 | `refactor(core): simplify graph trait` |
| `ci` | CI 配置 | `ci: add github actions workflow` |
| `chore` | 杂项 | `chore: update dependencies` |

---

## 测试要求

### 测试体系

项目采用**双轨制测试** + **Python/NetworkX 随机图验证**：

| 测试类型 | 文件位置 | 说明 |
|---------|---------|------|
| 黑盒测试 | `lib/algo/*_test.mbt` | 公开 API 行为验证 |
| 白盒测试 | `lib/algo/*_wbtest.mbt` | 内部实现细节验证 |
| 随机图集成测试 | `lib/algo/integration/*_test.mbt` | Python/NetworkX ground truth 验证 |

### Python/NetworkX 随机图测试

每个算法用 5 个随机图验证，数据由 Python/NetworkX 生成：

```bash
# 重新生成所有随机图测试
cd tests && uv run python gen/all.py

# 单独生成 fixture 或测试
uv run python gen/gen_fixtures.py  # 生成随机图 JSON
uv run python gen/gen_tests.py     # 生成 MoonBit 测试文件
```

当前覆盖 **55 个算法，295 个随机图测试**。

### 运行测试

```bash
moon test                          # 全量测试 (772 tests)
moon test lib/algo/integration     # 仅随机图集成测试
moon test lib/algo/shortest_path   # 仅最短路径模块
```

---

## 文档要求

| 文档 | 路径 | 说明 |
|------|------|------|
| README | `README.mbt.md` | 项目入口文档 |
| 架构设计 | [文档站点 → 架构总览](https://morning-start.github.io/mbtgraph/core-concepts/architecture/) | 架构总览、Trait 分层 |
| 开发规范 | `AGENTS.md` | 编码规范 + Top 10 陷阱 |
| 路线图 | [文档站点 → 路线图](https://morning-start.github.io/mbtgraph/about/roadmap/) | 发展路线图 |
| 变更日志 | `CHANGELOG.md` | 版本变更记录 |

---

## 相关资源

| 资源 | 说明 |
|------|------|
| [`AGENTS.md`](AGENTS.md) | 开发规范速查 |
| [`README.mbt.md`](README.mbt.md) | 库使用文档 |
| [`docs/ARCHITECTURE.md`](https://morning-start.github.io/mbtgraph/core-concepts/architecture/) | 架构权威文档 |
| [`docs/ROADMAP.md`](https://morning-start.github.io/mbtgraph/about/roadmap/) | 路线图 |

---

**最后更新**: 2026-07-07 | **适用版本**: v0.1.3+ | **测试基线**: 772 tests passed
