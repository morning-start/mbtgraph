---
title: "mbtgraph 贡献者指南"
version: "1.0.0"
status: "active"
type: "contributing"
created: "2026-05-02"
updated: "2026-05-23"
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

如果你发现了 Bug，请：

1. 搜索 [现有 Issues](https://github.com/morning-start/mbtgraph/issues) 确认是否已有报告
2. 创建新 Issue，包含：
   - **标题**: 简洁描述问题
   - **环境**: MoonBit 版本（当前 0.9.0）、操作系统
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

**当前算法模块覆盖情况**（P0-P5 已完成）：

| 模块 | 状态 | 算法 |
|------|:----:|------|
| traversal (遍历) | ✅ 完成 | BFS / DFS / 环检测 / 拓扑排序 |
| shortest_path (最短路径) | ✅ 完成 | Dijkstra / Bellman-Ford / Floyd-Warshall |
| mst (最小生成树) | ✅ 完成 | Kruskal / Prim |
| connectivity (连通性) | ✅ 完成 | 连通分量 / Tarjan SCC / Kosaraju SCC |
| flow (网络流) | ✅ 完成 | Edmonds-Karp / Dinic |
| matching (图匹配) | ✅ 完成 | Hungarian 二分图匹配 |
| euler (欧拉路径) | ✅ 完成 | Hierholzer 回路/路径 + 判定 |
| cutpoints (割点与桥) | ✅ 完成 | Tarjan 割点/桥检测 |
| coloring (图着色) | ✅ 完成 | Greedy / Welsh-Powell / DSATUR / 回溯精确 |
| clique (团检测) | ✅ 完成 | Bron-Kerbosch 最大团 / 独立集 / 顶点覆盖 |
| hamiltonian (哈密顿/TSP) | ✅ 完成 | 快速检查 / 回溯 / TSP 最近邻与精确解 |

### 提交代码

1. Fork 本仓库
2. 创建特性分支: `git checkout -b feature/amazing-feature`
3. 提交更改: `git commit -m 'feat(algo): add amazing algorithm'`
4. 推送到分支: `git push origin feature/amazing-feature`
5. 提交 Pull Request

---

## 开发环境设置

### 前置要求

- **MoonBit**: 安装最新版 (https://moonbitlang.com)，当前项目使用版本兼容 0.9.0
- **Git**: 版本控制工具

### 快速开始

```bash
# 1. Fork 并克隆仓库
git clone https://github.com/YOUR_USERNAME/mbtgraph.git
cd mbtgraph

# 2. 验证环境（确保 483 个测试全通过）
moon test

# 3. 配置 Git Hooks（推荐）
cp .githooks/* .git/hooks/
chmod +x .git/hooks/*
```

---

## 项目结构概览

```
lib/
├── core/                      # 核心抽象层 [68 tests]
│   ├── types.mbt             # NodeId / Node / Edge 基础类型
│   ├── traits.mbt            # 6 层 Trait 分层体系
│   └── error.mbt             # GraphError 错误类型
│
├── storage/                   # 存储实现层 [~107 tests]
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
├── algo/                      # 算法模块 [~309 tests] ⭐ P0-P5 全部完成
│   ├── traversal/            # 遍历 [BFS/DFS/环检测/拓扑排序]
│   ├── shortest_path/        # 最短路径 [Dijkstra/BF/FW]
│   ├── mst/                  # 最小生成树 [Kruskal/Prim]
│   ├── connectivity/         # 连通性 [CC/Tarjan/Kosaraju]
│   ├── flow/                 # 网络流 [Edmonds-Karp/Dinic]
│   ├── matching/             # 图匹配 [Hungarian]
│   ├── euler/                # 欧拉路径 [Hierholzer]
│   ├── cutpoints/            # 割点与桥 [Tarjan]
│   ├── coloring/             # 图着色 [Greedy/WP/DSATUR/回溯]
│   ├── clique/               # 团检测 [Bron-Kerbosch]
│   └── hamiltonian/          # 哈密顿/TSP [回溯/最近邻/Held-Karp]
│
└── utils/
    └── generators/           # 图生成器 [56 tests, 15 函数]
        ├── classic.mbt       # 经典图 (complete/path/cycle/star...)
        ├── random.mbt        # 随机图 (erdos_renyi/tree/dag)
        ├── grid.mbt          # 网格 (2d/hexagonal)
        └── bipartite.mbt     # 二分图
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

> ⚠️ **重要**: 完整编码规范见 [`AGENTS.md`](../AGENTS.md)，以下为核心规则速查。

### 强制规则（CI 检查）

| # | 规则 | ✅ 正确 | ❌ 错误 | 检测方式 |
|---|------|--------|--------|---------|
| R1 | 使用 `@core.` 完全限定名 | `@core.NodeId(0)` | use 别名 | Code Review |
| R2 | Impl 用 `(self)` 非 `mut self` | `let g = self` | `mut self` | 编译报错 E3002 |
| R3 | 可变性按需声明 | 只改字段→`let g` | 需重新赋值→`let mut g` | Warning E0015 |
| R4 | 可见性正确选择 | 核心类型→`pub(all)` | trait→`pub(open)trait` | 编译报错 E4036/E4145 |
| R5 | For 循环不直接解构元组 | 先绑定再 match | `for (a,b) in ...` | 编译报错 E3002 |
| R6 | **嵌套泛型用 `]]` 结尾** | `Array[Array[Double?]]` | `Array[Array[Double?>>` | Parse error |
| R7 | **避免保留字命名** | `net`, `graph` | `fn`, `var` | Parse error / deprecated |

### 命名约定

| 类别 | 规范 | 示例 |
|------|------|------|
| **类型/Struct** | PascalCase | `DirectedGraph`, `BFSResult`, `FlowNetwork` |
| **Trait** | PascalCase | `GraphReadable`, `GraphWritable`, `GraphDirected` |
| **公开函数** | snake_case | `breadth_first_search`, `dijkstra`, `kruskal` |
| **私有函数** | 无前缀 (MoonBit priv) | `ek_bfs`, `deep_copy_matrix` |
| **常量** | UPPER_SNAKE_CASE | `DEFAULT_DAMPING_FACTOR` |

### 推荐惯例

- Match 多语句用 `{}` 包裹（不用逗号分隔）
- Option 匹配不需要 `_ => ()` 分支
- 同包内函数直接调用，无需模块前缀
- 公共逻辑复用 `shared_helpers.mbt`，不重复实现
- **数组修改需深拷贝**（保证纯函数语义）
- **链式赋值处理返回值**（`let net = net.add_edge(...)` 而非 ignore）

### 组件内聚策略

| 数据结构 | 位置 | 可见性 | 使用者 |
|----------|------|:------:|--------|
| BinaryHeap (二叉最小堆) | `algo/shortest_path/heap.mbt` | priv | Dijkstra |
| UnionFind (并查集) | `algo/mst/union_find.mbt` | priv | Kruskal |
| TarjanState (可变状态载体) | `algo/connectivity/tarjan.mbt` | priv | Tarjan SCC |
| FlowNetwork (流网络) | `algo/flow/flow_network.mbt` | pub(all) | Edmonds-Karp / Dinic |

### 文档注释

所有公开函数必须有文档注释：

```moonbit
/// 广度优先搜索
///
/// # 参数
/// - graph: 图 (实现 GraphReadable trait)
/// - source: 起始节点
///
/// # 返回值
/// BfsResult 包含遍历顺序、距离和父指针
///
/// # 复杂度
/// 时间 O(V+E), 空间 O(V)
pub fn[G : @core.GraphReadable] bfs(g : G, start : @core.NodeId) -> BfsResult {
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
| `feat` | 新功能 | `feat(hamiltonian): add TSP algorithms` |
| `fix` | Bug 修复 | `fix(core): fix edge duplication in undirected graph` |
| `docs` | 文档 | `docs(readme): add installation instructions` |
| `test` | 测试代码 | `test(flow): add dinic test cases` |
| `refactor` | 重构 | `refactor(core): simplify graph trait` |
| `perf` | 性能优化 | `perf(sp): optimize dijkstra with fibonacci heap` |
| `ci` | CI 配置 | `ci: add github actions workflow` |
| `chore` | 杂项 | `chore: update dependencies` |

### Scope 范围（完整列表）

| Scope | 说明 | 对应目录 |
|-------|------|---------|
| `core` | 核心类型 + Trait | `lib/core/` |
| `storage` | 存储实现层 | `lib/storage/` |
| `traversal` | 遍历算法 | `lib/algo/traversal/` |
| `shortest_path` | 最短路径 | `lib/algo/shortest_path/` |
| `mst` | 最小生成树 | `lib/algo/mst/` |
| `connectivity` | 连通性分析 | `lib/algo/connectivity/` |
| `flow` | 网络流 | `lib/algo/flow/` |
| `matching` | 图匹配 | `lib/algo/matching/` |
| `euler` | 欧拉路径 | `lib/algo/euler/` |
| `cutpoints` | 割点与桥 | `lib/algo/cutpoints/` |
| `coloring` | 图着色 | `lib/algo/coloring/` |
| `clique` | 团检测 | `lib/algo/clique/` |
| `hamiltonian` | 哈密顿/TSP | `lib/algo/hamiltonian/` |
| `generators` | 图生成器 | `lib/utils/generators/` |
| `test` | 测试代码 | 各模块 `*_test.mbt` |
| `docs` | 文档 | `docs/` |
| `ci` | CI/CD | `.github/workflows/` |

### 示例

```
feat(euler): add Hierholzer euler path/circuit algorithms

- Implement undirected/directed Hierholzer algorithm
- Add has_euler_path/is_euler_circuit predicates
- Add EulerResult type with path and circuit methods
- Add unit tests with standard test cases (22 tests)

Closes #123
```

---

## 测试要求

### 测试文件命名

- 黑盒测试: `<module>_test.mbt` — 公开 API 行为验证
- 白盒测试: `<module>_wbtest.mbt` — 内部实现细节验证

### 当前测试统计

| 模块 | 测试文件数 | 测试用例数 | 状态 |
|------|:---------:|:---------:|:----:|
| core | 3 (types/traits/error) | ~68 | ✅ 全通过 |
| storage | ~8 | ~107 | ✅ 全通过 |
| traversal | 2 (traversal/cross_storage) | ~47 | ✅ 全通过 |
| generators | 1 | 56 | ✅ 全通过 |
| shortest_path | 1 | 32 | ✅ 全通过 |
| mst | 1 | 16 | ✅ 全通过 |
| connectivity | 1 | 21 | ✅ 全通过 |
| flow | 2 (flow/dinic) | 33 | ✅ 全通过 |
| matching | 1 | 21 | ✅ 全通过 |
| euler | 1 | 22 | ✅ 全通过 |
| cutpoints | 1 | 15 | ✅ 全通过 |
| coloring | 1 | 21 | ✅ 全通过 |
| clique | 1 | 14 | ✅ 全通过 |
| hamiltonian | 1 | 20 | ✅ 全通过 |
| **合计** | **~25** | **483** | **✅ 100% 通过** |

### 测试分类比例（参考标准）

| 分类 | 占比 | 说明 |
|------|:----:|------|
| 基础功能测试 | ~30% | 类型创建/方法正确性 |
| 算法正确性测试 | ~40% | 经典案例/已知答案 |
| 边界情况测试 | ~20% | 空图/越界/异常输入 |
| 属性验证测试 | ~10% | 不可变性/一致性约束 |

### 测试类型

1. **正确性测试**: 使用 `assert_eq` 验证算法输出
2. **属性测试**: 验证算法属性（如 MST 边数 = V-1；SCC 分割覆盖所有节点）
3. **边界测试**: 空图、单节点、不连通图等
4. **跨存储一致性验证**: 每算法在 AdjList/Matrix/EdgeList 上测试结果一致
5. **结果不可变性验证**: 保证原始输入不被算法修改

### 运行测试

```bash
# 运行全量测试（483 tests）
moon test

# 运行特定模块测试
moon test lib/algo/hamiltonian       # P5 最新模块 (20 tests)
moon test lib/algo/euler             # 欧拉路径模块 (22 tests)
moon test lib/algo/flow              # 网络流模块 (33 tests)

# 更新快照
moon test --update

# 检查单模块编译
moon check lib/algorithms/shortest_path
```

---

## 文档要求

### 文档类型

| 文档 | 路径 | 说明 | 状态 |
|------|------|------|:----:|
| README | `README.mbt.md` | 项目入口文档 | ✅ |
| 架构设计 | `docs/ARCHITECTURE.md` | 架构总览、Trait 分层、SOLID 评审 | ✅ |
| 开发规范 | `AGENTS.md` | 编码规范 + Top 10 陷阱 + 算法 SOP | ✅ |
| 模块设计 | `docs/design/*.md` | 各算法模块详细设计规范 (8 份) | ✅ |
| 竞品调研 | `docs/reference/*.md` | 主流图库分析报告 (8 份) | ✅ |
| 路线图 | `docs/ROADMAP.md` | 发展路线图与里程碑 | ✅ |
| 变更日志 | `CHANGELOG.md` | 版本变更记录 | ✅ |
| 记忆系统 | `MEMORY.md` | 关键决策与语法陷阱记录 | ✅ |

### 文档更新时机

- 添加新算法时：更新 `README.mbt.md` + 新增 `docs/design/xxx_design.md` + 更新 `ROADMAP.md`
- 修改公共 API 时：运行 `moon info` 更新接口 + 更新 `CHANGELOG.md`
- 添加测试用例时：更新对应模块 README 的测试统计

---

## 📚 相关资源

| 资源 | 说明 |
|------|------|
| [`AGENTS.md`](../AGENTS.md) | **必读** — 开发规范速查（Top 10 陷阱/错误码表/算法 SOP） |
| [`MEMORY.md`](../MEMORY.md) | 项目记忆 — 关键决策与语法陷阱 |
| [`README.mbt.md`](../README.mbt.md) | 库使用文档 — API 总览与快速开始 |
| [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) | 架构权威文档 — Trait 分层/SOLID 评审/竞品对比 |
| [`docs/ROADMAP.md`](../docs/ROADMAP.md) | 战略蓝图 — Phase 进度/版本规划/依赖关系 |

---

## 📞 联系方式

- **Issues**: [GitHub Issues](https://github.com/morning-start/mbtgraph/issues)
- **Discussions**: [GitHub Discussions](https://github.com/morning-start/mbtgraph/discussions)

---

**最后更新**: 2026-05-23 | **适用版本**: v0.9.0+ | **测试基线**: 483 tests passed
