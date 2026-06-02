# mbtgraph 文档站

> **MoonBit 生态首个生产级图算法库**的官方文档站点，基于 [Astro](https://astro.build/) + [Starlight](https://starlight.astro.build/) 构建。

## 📖 项目简介

mbtgraph 是一个用 **MoonBit** 语言编写的**生产级图算法库**，提供：

| 维度 | 规格 |
|------|------|
| **存储结构** | 8 种（邻接表/矩阵/边集/CSR/CSC 及其有向/无向变体） |
| **Trait 分层** | 6 层（GraphReadable → Writable → Directed → Full → BatchReadable → EdgeIterable） |
| **算法数量** | ~49 个（遍历、最短路径、MST、连通性、网络流、匹配、着色、社区检测等） |
| **编译目标** | native / wasm / js 三后端支持 |
| **测试体系** | Blackbox 功能测试 + Whitebox 内部逻辑验证 |

---

## � 文档结构

文档按学习路径组织，分为以下 **6 大模块**：

### 1️⃣ 入门指南 (`getting-started/`)

面向初学者，帮助快速上手 mbtgraph 库。

| 文件 | 内容 | 状态 |
|------|------|------|
| `installation.md` | 安装与环境配置 | ✅ |
| `concepts.md` | 核心概念概览 | ✅ |
| `first-graph.md` | 第一个图程序实战 | ✅ |

**编写要求**：
- 假设读者具备基本的 MoonBit 语法知识
- 提供可复制的完整代码示例
- 包含常见问题排查 (FAQ)

---

### 2️⃣ 基础概念 (`core-concepts/`)

深入理解 mbtgraph 的**核心抽象与设计哲学**。

| 文件 | 内容 | 行数要求 | 状态 |
|------|------|---------|------|
| `index.md` | 模块导航页 | ~100 | ✅ |
| `data-types.md` | NodeId / Node / Edge / Weight 类型详解 | ~400+ | ✅ |
| `traits.md` | 6 层 Trait 设计原理与使用 | ~800+ | ✅ |
| `storage-guide.md` | 8 种存储选型指南 | ~700+ | ✅ |
| `building-graphs.md` | 图构建方法与最佳实践 | ~800+ | ✅ |
| `graph-operations.md` | CRUD 操作完整参考 | ~1000+ | ✅ |
| `error-handling.md` | GraphError 错误处理模式 | ~300+ | ✅ |
| `storage-decision.md` | 存储决策树与性能对比 | ~400+ | ✅ |
| `storage-converter.md` | 存储类型转换函数 | ~300+ | ✅ |
| `serialization.md` | 序列化与反序列化 | ~300+ | ✅ |
| `benchmarks.md` | 性能基准测试数据 | ~400+ | ✅ |

**编写要求**：
- 每篇 ≥ 300 行，核心类型/Traits/操作类文档 ≥ 700 行
- 必须包含：**真实场景类比** + **完整 MoonBit 代码** + **对比表格**
- 使用 `@core.` 完全限定名（不使用 use 别名）
- 代码示例必须可直接运行

---

### 3️⃣ 算法教程 (`algorithms/`)

**核心亮点模块** — 采用 **VisuAlgo 风格**的分步动画演示。

#### 3.1 图遍历 (`traversal/`)

| 文件 | 算法 | 核心特色 | 状态 |
|------|------|---------|------|
| `bfs/index.md` | 广度优先搜索 | 🎬 队列状态动画 · 涟漪扩散类比 | ✅ |
| `dfs/index.md` | 深度优先搜索 | 🎬 栈状态动画 · 时间戳系统详解 | ✅ |
| `advanced/index.md` | 高级遍历技巧 | 双向BFS · 环检测 · 拓扑排序 | 占位 |

#### 3.2 最短路径 (`shortest-path/`)

| 文件 | 算法 | 核心特色 | 状态 |
|------|------|---------|------|
| `dijkstra/index.md` | Dijkstra | 🎬 优先队列动画 · 松弛操作可视化 | ✅ |
| `bellman-ford/index.md` | Bellman-Ford | 负权边处理 · 负环检测 | 占位 |
| `a-star/index.md` | A* 启发式搜索 | 启发式函数 · 网格寻路 | 占位 |
| `floyd-warshall/index.md` | Floyd-Warshall | 全源最短路径 · 路径重建 | 占位 |

#### 3.3 最小生成树 (`mst/`)

| 文件 | 算法 | 核心特色 | 状态 |
|------|------|---------|------|
| `kruskal-prim/index.md` | Kruskal & Prim | 🎬 双算法对比 · 割性质证明 · Union-Find | ✅ |
| `kruskal/index.md` | Kruskal (独立版) | 边排序策略详解 | 占位 |
| `prim/index.md` | Prim (独立版) | 贪心生长策略详解 | 占位 |

#### 3.4 连通性 (`connectivity/`)

| 文件 | 主题 | 状态 |
|------|------|------|
| `connected-components/index.md` | 连通分量 (CC) | 占位 |
| `articulation-points/index.md` | 割点与桥 (Tarjan) | 占位 |
| `scc/tarjan.md` | Tarjan SCC | 占位 |
| `scc/kosaraju.md` | Kosaraju SCC | 占位 |

#### 3.5 网络流 (`flow/`)

| 文件 | 主题 | 状态 |
|------|------|------|
| `basics/index.md` | 流网络基础概念 | 占位 |
| `max-flow/ford-fulkerson.md` | Ford-Fulkerson 方法 | 占位 |
| `max-flow/edmonds-karp.md` | Edmonds-Karp (BFS 实现) | 占位 |
| `max-flow/dinic.md` | Dinic 算法 (层次图) | 占位 |
| `min-cost-max-flow/index.md` | 最小费用最大流 | 占位 |

#### 3.6 图匹配 (`matching/`)

| 文件 | 主题 | 状态 |
|------|------|------|
| `bipartite/hungarian.md` | 匈牙利算法 (二分图完美匹配) | 占位 |
| `bipartite/hopcroft-karp.md` | Hopcroft-Karp (最大匹配) | 占位 |
| `general/edmonds.md` | Edmonds 花朵算法 (一般图匹配) | 占位 |

#### 3.7 其他算法 (`other/`, `centrality/`, `coloring/`, `community/`)

| 文件 | 主题 | 状态 |
|------|------|------|
| `other/index.md` | 欧拉路径/哈密顿路径/PageRank | 占位 |
| `centrality/index.md` | 中心性指标 (度/接近/中介/特征向量) | 占位 |
| `coloring/index.md` | 图着色 (Greedy/WP/DSATUR) | 占位 |
| `community/index.md` | 社区检测 (Louvain/标签传播) | 占位 |

**算法教程编写要求（重要！）**：

```
✅ 必须包含的内容:
   ┌────────────────────────────────────────────┐
   │ 1. 算法简介 (~100行)                        │
   │    - 核心思想 + 直观类比 (GPS/迷宫/网络等)    │
   │    - 与其他算法的对比表格                    │
   │                                            │
   │ 2. 动画演示 (~300行) ⭐ 核心亮点            │
   │    - VisuAlgo 风格分步 ASCII 动画            │
   │    - 数据结构追踪 (队列/栈/堆/UF 变化)       │
   │    - 至少 5 步详细执行过程                  │
   │                                            │
   │ 3. 完整实现 (~200行)                         │
   │    - 来自 lib/algo/ 的真实 MoonBit 源码      │
   │    - 4 个关键"为什么"设计决策解释             │
   │                                            │
   │ 4. 使用示例 (3个, 每个~80行)                 │
   │    - 示例1: 基础用法 (输出结果)              │
   │    - 示例2: 实际应用 (GPS/网络/社交等)       │
   │    - 示例3: 进阶场景 (变体/优化)             │
   │                                            │
   │ 5. 复杂度分析 (~100行)                       │
   │    - 时间/空间复杂度分解表                   │
   │    - 与其他实现的对比                         │
   │                                            │
   │ 6. 应用场景 (4个)                            │
   │    - 真实世界案例说明                        │
   │                                            │
   │ 7. 练习题 (3道, 递进难度)                    │
   │    - ⭐⭐ 手动执行                           │
   │    - ⭐⭐⭐ 编程实现                          │
   │    - ⭐⭐⭐⭐ 进阶挑战                        │
   │    - 使用 <details> 折叠显示答案             │
   │                                            │
   │ 8. 相关资源                                  │
   │    - VisuAlgo/Algorithm Visualizer 链接      │
   │    - 内部链接到相关算法                      │
   └────────────────────────────────────────────┘

📏 目标行数: 1200-1500 行/篇 (核心算法)
```

---

### 4️⃣ API 参考 (`api/`)

自动生成的 API 文档，供快速查阅。

| 文件 | 内容 | 状态 |
|------|------|------|
| `core.md` | 核心类型与 Trait 接口 | 占位 |
| `storage.md` | 存储结构 API | 占位 |
| `algorithms.md` | 算法函数 API | 占位 |
| `io.md` | 输入输出 API | 占位 |

**编写要求**：
- 以函数签名 + 参数说明 + 返回值 + 示例为主
- 保持简洁，避免冗长解释（详细内容链接到对应教程）

---

### 5️⃣ 使用案例 (`use-cases/`)

端到端的完整项目示例。

| 案例 | 内容 | 状态 |
|------|------|------|
| `social-network/` | 社交网络分析 (构建/社区发现/影响力排名) | 占位 |
| `recommendation-system/` | 推荐系统 (二分图匹配/协同过滤/嵌入) | 占位 |
| `knowledge-graph/` | 知识图谱 (抽取/查询/可视化) | 占位 |

**编写要求**：
- 提供完整的可运行项目代码
- 包含数据准备 → 图构建 → 算法调用 → 结果展示 全流程

---

### 6️⃣ 贡献指南 (`contributing/`)

面向贡献者的开发规范。

| 文件 | 内容 | 状态 |
|------|------|------|
| `setup.md` | 开发环境搭建 | ✅ |
| `coding-standards.md` | 编码规范 (R1-R7 强制规则) | ✅ |
| `documentation.md` | 文档编写规范 (本文件所在位置) | ✅ |
| `testing.md` | 测试规范与覆盖率要求 | ✅ |

---

## ⚠️ 编写注意事项

### YAML Frontmatter 规范

```yaml
---
title: "标题内容"           # ⚠️ 必须用双引号包裹含特殊字符的值
description: "描述内容"     # 同上
# 不要在 title/description 中使用未转义的特殊字符:
#   : ( ) & * # @ ! | 等
---
```

**常见错误**：
```yaml
# ❌ 错误: 含冒号和括号
title: 最小生成树 (MST): Kruskal & Prim 算法

# ✅ 正确: 用双引号包裹
title: "最小生成树 (MST): Kruskal & Prim 算法"
```

### Markdown 格式规范

| 规则 | 说明 |
|------|------|
| **代码块** | 使用 ```moonbit 或 ```bash 等明确语言标识 |
| **中文标点** | 正文使用全角标点（，。：；！？） |
| **英文术语** | 首次出现时标注英文，如：深度优先搜索（Depth-First Search, DFS） |
| **链接格式** | 内部链接使用相对路径 `/path/to/page/` |
| **图片** | 放置在 `src/assets/` 目录下，使用相对路径引用 |

### 代码示例规范

```moonbit
// ✅ 正确: 使用完全限定名
let g = @core.GraphWritable::add_node(g, "data")
let result = @traversal.dfs(g, @core.NodeId(0))

// ❌ 错误: 使用 use 别名
use core.{ GraphReadable, NodeId }
// ...
GraphReadable::node_count(graph)
```

### 文档风格指南

1. **目标读者**: 具备一定编程基础的 MoonBit 学习者或图算法研究者
2. **语言**: 中文为主，技术术语保留英文并附中文解释
3. **深度**: 从概念到实现到应用，层层递进
4. **可操作性**: 所有代码示例必须可复制粘贴直接运行

---

## 🛠️ 本地开发

```bash
# 进入站点目录
cd site

# 安装依赖
bun install

# 启动开发服务器 (http://localhost:4321/)
bun run dev

# 构建生产版本
bun run build

# 预览构建结果
bun run preview
```

### 项目技术栈

| 组件 | 技术 | 版本 |
|------|------|------|
| 静态站点生成器 | [Astro](https://astro.build/) | v4.x |
| 文档主题 | [Starlight](https://starlight.astro.build/) | latest |
| 包管理器 | Bun | latest |
| UI 组件 | Astro 内置 + Starlight 组件 | - |

---

## 📊 当前进度

### 已完成的教程

| 模块 | 教程 | 行数 | 质量 |
|------|------|------|------|
| **基础概念** | data-types | ~410 | ✅ |
| **基础概念** | traits | ~795 | ✅ |
| **基础概念** | storage-guide | ~680 | ✅ |
| **基础概念** | building-graphs | ~780 | ✅ |
| **基础概念** | graph-operations | ~983 | ✅ |
| **算法-遍历** | BFS | ~771 | ✅ VisuAlgo 风格 |
| **算法-遍历** | DFS | ~1361 | ✅ VisuAlgo 风格 |
| **算法-最短路径** | Dijkstra | ~1314 | ✅ VisuAlgo 风格 |
| **算法-MST** | Kruskal & Prim | ~1437 | ✅ VisuAlgo 风格 |

**已完成**: ~8,531 行高质量教程内容

### 待编写的教程（优先级排序）

| 优先级 | 模块 | 教程 | 预估行数 |
|--------|------|------|----------|
| 🔴 P0 | 算法-最短路径 | Bellman-Ford | ~1200 |
| 🔴 P0 | 算法-最短路径 | Floyd-Warshall | ~1000 |
| 🔴 P0 | 算法-连通性 | Tarjan SCC | ~1200 |
| 🟡 P1 | 算法-连通性 | Kosaraju SCC | ~900 |
| 🟡 P1 | 算法-网络流 | Edmonds-Karp | ~1300 |
| 🟡 P1 | 算法-网络流 | Dinic | ~1400 |
| � P2 | 算法-MST | Kruskal (独立版) | ~800 |
| 🟢 P2 | 算法-MST | Prim (独立版) | ~800 |
| 🟢 P2 | 算法-匹配 | Hopcroft-Karp | ~1100 |
| 🟢 P2 | 算法-匹配 | 匈牙利算法 | ~1000 |

---

## 📌 相关资源

- **主仓库**: [github.com/moonbit/mbtgraph](https://github.com/moonbit/mbtgraph)
- **在线预览**: [GitHub Pages 部署地址] (待配置)
- **MoonBit 官方**: [www.moonbitlang.com](https://www.moonbitlang.com/)
- **Starlight 文档**: [starlight.astro.build](https://starlight.astro.build/)

---

<div align="center">

**mbtgraph 文档站** · 基于 ❤️ 和 Starlight 构建

*最后更新: 2025 年*

</div>
