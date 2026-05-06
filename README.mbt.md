# mbtgraph

> **MoonBit 生态的高性能、类型安全、模块化图算法库**

[![License](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![MoonBit](https://img.shields.io/badge/MoonBit-v0.1+-green.svg)](https://moonbitlang.com)
[![Version](https://img.shields.io/badge/Version-0.1.0-orange.svg)](moon.mod.json)

---

## 🌟 项目简介

`mbtgraph` 是一个使用 [MoonBit](https://moonbitlang.com) 编写的纯图算法库，提供从基础遍历到高级社区检测的全谱系图算法。

**核心定位**: 纯算法包设计，可被其他 MoonBit 项目依赖，编译到 wasm/js/native 多目标。

### ✨ 核心卖点

1. 🚀 **高性能**: 接近 Rust/C++，远超 Python/Java（原生编译）
2. 🔒 **类型安全**: 编译期类型检查，利用 MoonBit Trait 系统保证接口安全
3. 🌐 **多后端**: 一套代码，wasm/js/native 三端运行
4. 📦 **超小体积**: wasm 目标 < 1MB，适合浏览器/边缘计算
5. 🧠 **社区检测专精**: Louvain/Leiden 实现，竞品薄弱环节
6. 📚 **中文友好**: 面向中文开发者生态

---

## 📦 安装使用

### 添加依赖

在 `moon.mod.json` 中添加：

```json
{
  "deps": ["morning-start/mbtgraph"]
}
```

### 快速开始

```moonbit nocheck
// 导入核心模块
use morning-start/mbtgraph/core::DirectedGraph
use morning-start/mbtgraph/algo/traverse::bfs

fn main {
  // 创建有向图
  let mut g = DirectedGraph::new()
  let a = g.add_node("A")
  let b = g.add_node("B")
  let c = g.add_node("C")
  g.add_edge(a, b, ())
  g.add_edge(b, c, ())
  g.add_edge(a, c, ())

  // BFS 遍历
  let result = bfs(&g, a)
  println("BFS 顺序: {:?}", result.discovered_order)
}
```

---

## 🗂️ 功能模块

### 核心抽象层 (`src/core`)

| 模块 | 说明 |
|------|------|
| `types.mbt` | 基础类型定义 (NodeId, EdgeId, EdgeKey) |
| `traits.mbt` | 核心 Trait 定义 (Graph, MutableGraph, WeightedGraph...) |
| `directed.mbt` | 有向图实现 |
| `undirected.mbt` | 无向图实现 |
| `weighted.mbt` | 加权图扩展 trait |
| `multigraph.mbt` | 多重图支持 |

### 经典算法层 (`src/algo`)

| 子模块 | 算法 |
|--------|------|
| `traverse` | BFS, DFS |
| `shortest_path` | Dijkstra, Bellman-Ford, A*, Floyd-Warshall, Johnson |
| `spanning_tree` | Kruskal, Prim |
| `connectivity` | SCC (Kosaraju/Tarjan), WCC, 双连通, 拓扑排序 |
| `cycle` | 环检测, 欧拉路径/回路 |

### 网络分析层 (`src/analysis`) ⭐

| 子模块 | 算法 |
|--------|------|
| `centrality` | Degree, Betweenness, Closeness, PageRank, HITS, Harmonic |
| `community` | Louvain, Leiden, LPA, Greedy Modularity |
| `clustering` | Local/Global Clustering Coefficient, Triangle Counting |

### 流网络层 (`src/flow`)

| 子模块 | 算法 |
|--------|------|
| `max_flow` | Ford-Fulkerson, Edmonds-Karp, Dinic, Push-Relabel |
| `min_cost_flow` | Successive Shortest, Cycle Canceling |
| `cut` | Stoer-Wagner 全局最小割, 边/点连通度 |

### 高级算法层

| 模块 | 算法 |
|------|------|
| `matching` | Greedy, Maximum Cardinality (Blossom), Bipartite |
| `isomorphism` | VF2, Color Refinement, Tree Isomorphism |
| `coloring` | Greedy DSATUR, Exact |
| `tour` | Hamiltonian, TSP (2-approx, Christofides), Eulerian |

### 工具层 (`src/utils`)

| 子模块 | 功能 |
|--------|------|
| `io` | DOT, GraphML, JSON, CSV 格式读写 |
| `generators` | 经典图 (Kn, Cn, Sn), 随机图 (ER, BA, WS) |
| `layout` | Force-directed, Circular, Hierarchical 布局 |

---

## 📊 开发路线图

| 版本 | 重点 | 里程碑 |
|------|------|--------|
| **v0.1.0** | 核心基础 | 图结构 + BFS/DFS + Dijkstra + SCC |
| **v0.2.0** | 网络分析 | PageRank + Louvain/Leiden + MST + 图生成器 |
| **v0.3.0** | 高级算法 | MaxFlow + Matching + Isomorphism + Coloring + TSP |
| **v0.4.0** | 生态完善 | I/O + Layout + 文档 + 发布 mooncakes |
| **v1.0.0** | 生产就绪 | API 稳定 + 全覆盖测试 + 性能达标 |

---

## 🏗️ 架构设计

### Trait 层次结构

```
                    ┌─────────────────┐
                    │     Graph       │  ← 最小接口: 查询操作
                    │  [N, E]          │
                    ├─────────────────┤
                    │ node_count()    │
                    │ edge_count()    │
                    │ contains_node() │
                    │ contains_edge() │
                    │ neighbors()     │
                    └────────┬────────┘
                             │
            ┌────────────────┼────────────────┐
            ▼                ▼                ▼
    ┌───────────────┐ ┌──────────────┐ ┌──────────────┐
    │ MutableGraph  │ │WeightedGraph │ │DirectedGraph │
    │ [N,E]:Graph   │ │ [N,E]:Graph  │ │ [N,E]:Graph  │
    ├───────────────┤ ├──────────────┤ ├──────────────┤
    │ add_node()    │ │ edge_weight()│ │ successors() │
    │ add_edge()    │ │ total_weight│ │ predecessors│
    │ remove_node() │ └──────┬───────┘ │ reverse()    │
    │ remove_edge() │        │         └──────┬───────┘
    │ set_weight()  │        ▼                │
    └───────────────┘ ┌──────────────┐        │
                      │UndirectedGraph│◄───────┘
                      │ [N,E]:Graph   │
                      ├──────────────┤
                      │ degree()      │
                      └──────────────┘
```

详细架构设计请参考: [架构设计文档](docs/architecture/project_structure_design.md)

---

## 🎯 与竞品对比

| 维度 | NetworkX | petgraph | JGraphT | **mbtgraph** |
|------|----------|----------|---------|-------------|
| 语言 | Python | Rust | Java | **MoonBit** |
| 性能 | ★★★ | ★★★★★ | ★★★★ | **★★★★** (原生编译) |
| 易用性 | ★★★★★ | ★★★★ | ★★★★ | **★★★★** (简洁语法) |
| 类型安全 | ★★ | ★★★★★ | ★★★★★ | **★★★★** (编译期检查) |
| 社区检测 | ★★★★★ | ✗ | ★★ | **★★★★★** (重点投入!) |
| 多后端 | ✗ | ✗ | JVM only | **✅ wasm/js/native** |
| 包大小 | ~50MB | ~5MB | ~50MB | **~1MB** (wasm) |

---

## 📖 文档导航

| 文档类型 | 文件路径 | 说明 |
|---------|---------|------|
| 📐 架构设计 | [docs/architecture/project_structure_design.md](docs/architecture/project_structure_design.md) | 项目架构、模块划分、算法伪代码 |
| 📋 需求规格 | [docs/requirements/srs.md](docs/requirements/srs.md) | 软件需求规格说明 |
| 🏛️ 系统设计 | [docs/design/sad.md](docs/design/sad.md) | 系统架构设计 |
| 🧪 测试策略 | [docs/quality/test_strategy.md](docs/quality/test_strategy.md) | 测试计划与策略 |
| 📚 调研报告 | [docs/reference/](docs/reference/) | 8 份竞品调研报告 |

---

## 🛠️ 开发工具

### 基本命令

```bash
# 格式化代码
moon fmt

# 更新接口文件
moon info

# 运行测试
moon test

# 覆盖率分析
moon coverage analyze > uncovered.log

# 运行特定测试
moon test --target native
```

### 编码约定

- MoonBit 代码使用块风格，块之间用 `///|` 分隔
- 测试文件以 `_test.mbt`（黑盒）或 `_wbtest.mbt`（白盒）结尾
- 优先使用 `assert_eq` 或 `assert_true(pattern is Pattern(...))`

详见 [AGENTS.md](AGENTS.md)

---

## 📄 许可证

本项目采用 [Apache-2.0](LICENSE) 许可证。

---

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 提交 Pull Request

详见 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📞 联系方式

- **Issues**: [GitHub Issues](https://github.com/morning-start/mbtgraph/issues)
- **Discussions**: [GitHub Discussions](https://github.com/morning-start/mbtgraph/discussions)

---

**版本**: v0.1.0  
**最后更新**: 2026-05-02  
**状态**: 开发中 🚧
