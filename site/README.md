---
name: mbtgraph-site-readme
version: v2.0.0
author: mbtgraph-team
description: mbtgraph 文档站 — 编写规范、模块结构、开发指南
tags: [documentation, starlight, moonbit, graph-algorithms]
last-updated: 2026-06-02
---

# mbtgraph 文档站

> **MoonBit 生态首个生产级图算法库**的官方文档站点 · 基于 [Astro](https://astro.build/) + [Starlight](https://starlight.astro.build/)

## 目录

- [快速开始](#快速开始)
- [文档架构](#文档架构)
- [编写规范](#编写规范)
  - [YAML Frontmatter](#yaml-frontmatter)
  - [代码规范](#代码规范)
  - [风格指南](#风格指南)
- [模块总览](#模块总览)
- [当前进度](#当前进度)
- [相关资源](#相关资源)

---

## 快速开始

```bash
cd site && bun install && bun run dev   # http://localhost:4321/
```

| 命令 | 用途 |
|------|------|
| `bun run dev` | 启动开发服务器 |
| `bun run build` | 构建生产版本 → `./dist/` |
| `bun run preview` | 预览构建结果 |

**技术栈**: Astro v4.x + Starlight + Bun

---

## 文档架构

文档按学习路径组织为 **6 大模块**，采用**渐进式披露**策略（高频内容前置，低频详情按需展开）。

### 模块速查表

| # | 模块 | 路径 | 定位 | 核心文件数 | 状态 |
|---|------|------|------|-----------|------|
| 1 | 入门指南 | `getting-started/` | 快速上手 | 3 | ✅ 完成 |
| 2 | 基础概念 | `core-concepts/` | 核心抽象与设计哲学 | 11 | ✅ 完成 |
| 3 | 算法教程 | `algorithms/` | **核心亮点** — VisuAlgo 风格动画 | ~30 | 🔄 进行中 |
| 4 | API 参考 | `api/` | 函数签名快速查阅 | 4 | 📋 占位 |
| 5 | 使用案例 | `use-cases/` | 端到端完整示例 | 3 套 | 📋 占位 |
| 6 | 贡献指南 | `contributing/` | 开发规范与工作流 | 4 | ✅ 完成 |

### 算法教程子模块 (`algorithms/`)

这是文档站的**核心亮点模块**，采用 **VisuAlgo 风格**分步动画演示。

| 分类 | 包含算法 | 已完成 | 待编写 |
|------|---------|--------|--------|
| **遍历** | BFS, DFS, 高级技巧 | ✅ BFS, DFS | 双向BFS, 环检测 |
| **最短路径** | Dijkstra, Bellman-Ford, A*, Floyd-Warshall | ✅ Dijkstra | BF, A*, FW |
| **MST** | Kruskal, Prim | ✅ Kruskal&Prim(合) | 独立版 |
| **连通性** | CC, 割点/桥, Tarjan SCC, Kosaraju SCC | - | 全部待写 |
| **网络流** | FF, EK, Dinic, MCMF | - | 全部待写 |
| **图匹配** | 匈牙利, HK, Edmonds | - | 全部待写 |
| **其他** | 欧拉/哈密顿/PageRank/中心性/着色/社区 | - | 全部待写 |

---

## 编写规范

### YAML Frontmatter

```yaml
---
title: "标题"            # ⚠️ 含特殊字符必须双引号
description: "描述"      # 同上
---
```

**常见错误与修复**:
| ❌ 错误 | ✅ 正确 | 原因 |
|---------|---------|------|
| `title: 最小生成树 (MST): K & P` | `title: "最小生成树 (MST): K & P"` | 冒号/括号/& 为 YAML 特殊字符 |

### 代码规范

```moonbit
// ✅ 使用完全限定名，不使用 use 别名
let g = @core.GraphWritable::add_node(g, "data")
let result = @traversal.dfs(g, @core.NodeId(0))

// ❌ 禁止
use core.{ GraphReadable, NodeId }
GraphReadable::node_count(graph)
```

### 风格指南

| 规则 | 要求 |
|------|------|
| 语言 | 中文为主，术语保留英文并附中文（首次出现时） |
| 标点 | 正文使用全角标点（，。：；！？） |
| 代码块 | 必须标注语言：\`\`\`moonbit / \`\`\`bash |
| 目标读者 | 具备一定编程基础的 MoonBit 学习者或图算法研究者 |
| 可操作性 | 所有代码示例必须可复制粘贴直接运行 |

### 算法教程质量标准（核心!）

每篇算法教程**必须包含**以下 8 个部分（目标 1200-1500 行）：

| # | 章节 | 内容要点 | 行数 |
|---|------|---------|------|
| 1 | 算法简介 | 核心思想 + 直观类比(GPS/迷宫/网络) + 算法对比表 | ~100 |
| 2 | **动画演示** ⭐ | VisuAlgo 风格 ASCII 分步动画，数据结构追踪，≥5 步 | ~300 |
| 3 | 完整实现 | lib/algo/ 真实源码 + 4 个"为什么"设计决策 | ~200 |
| 4 | 使用示例 | 3 个场景: 基础用法 / 实际应用 / 进阶变体 | ~240 |
| 5 | 复杂度分析 | 时间/空间分解表 + 实现对比 | ~100 |
| 6 | 应用场景 | 4 个真实世界案例 | ~160 |
| 7 | 练习题 | 3 道(⭐⭐→⭐⭐⭐⭐)，\<details\> 折叠答案 | ~150 |
| 8 | 相关资源 | VisuAlgo 链接 + 内部算法链接 + 教材推荐 | ~50 |

**动画演示是核心差异化点** — 必须展示数据结构（队列/栈/堆/UF）的每步状态变化。

---

## 模块总览

### 1️⃣ 入门指南 (`getting-started/`)

| 文件 | 内容 | 要求 |
|------|------|------|
| `installation.md` | 安装与环境配置 | 含 FAQ |
| `concepts.md` | 核心概念概览 | 可运行示例 |
| `first-graph.md` | 第一个图程序 | 从零到运行的完整流程 |

### 2️⃣ 基础概念 (`core-concepts/`)

| 文件 | 内容 | 最低行数 |
|------|------|---------|
| `data-types.md` | NodeId/Node/Edge/Weight | ≥400 |
| `traits.md` | 6 层 Trait 设计原理 | ≥700 |
| `storage-guide.md` | 8 种存储选型 | ≥600 |
| `building-graphs.md` | 图构建方法与最佳实践 | ≥700 |
| `graph-operations.md` | CRUD 操作完整参考 | ≥900 |
| 其余 6 文件 | error/storage-dec/converter/ser/benchmarks/index | 各 ≥300 |

**通用要求**: 真实场景类比 + 完整 MoonBit 代码 + 对比表格

### 3️⃣ API 参考 (`api/`)

以函数签名 + 参数 + 返回值 + 示例为主，保持简洁。详细说明链接到对应教程。

### 4️⃣ 使用案例 (`use-cases/`)

提供完整的可运行项目代码，覆盖 **数据准备 → 图构建 → 算法调用 → 结果展示** 全流程。

### 5️⃣ 贡献指南 (`contributing/`)

| 文件 | 内容 |
|------|------|
| `setup.md` | 开发环境搭建 |
| `coding-standards.md` | R1-R7 强制规则 |
| `documentation.md` | **本文档所在位置** |
| `testing.md` | 测试规范与覆盖率要求 |

---

## 当前进度

### ✅ 已完成 (9 篇, ~8,531 行)

| 模块 | 教程 | 行数 | 特色 |
|------|------|------|------|
| 基础概念 | data-types | ~410 | 场景化类型设计 |
| 基础概念 | traits | ~795 | ISP/LSP/DIP 三原则 |
| 基础概念 | storage-guide | ~680 | 8 存储决策矩阵 |
| 基础概念 | building-graphs | ~780 | 3 种批量构建模式 |
| 基础概念 | graph-operations | ~983 | CRUD + 4 大反模式 |
| 算法-遍历 | BFS | ~771 | 🎬 6 步队列动画 |
| 算法-遍历 | DFS | ~1361 | 🎬 12 步栈动画+时间戳 |
| 算法-最短路径 | Dijkstra | ~1314 | 🎬 7 步优先队列+松弛 |
| 算法-MST | Kruskal&Prim | ~1437 | 🎬 双算法对比+割性质 |

### 📋 待编写 (按优先级)

| 优先级 | 教程 | 预估行数 | 依赖 |
|--------|------|---------|------|
| 🔴 P0 | Bellman-Ford | ~1200 | 无 |
| 🔴 P0 | Floyd-Warshall | ~1000 | 无 |
| 🔴 P0 | Tarjan SCC | ~1200 | DFS 教程 |
| 🟡 P1 | Kosaraju SCC | ~900 | DFS 教程 |
| 🟡 P1 | Edmonds-Karp | ~1300 | 无 |
| 🟡 P1 | Dinic | ~1400 | EK 教程 |
| 🟢 P2 | Hopcroft-Karp | ~1100 | 无 |
| 🟢 P2 | 匈牙利算法 | ~1000 | 无 |

---

## 边界定义

### ✅ 本 README 覆盖范围

- 文档站项目结构与模块划分
- Markdown/YAML/MoonBit 代码编写规范
- 算法教程质量标准与模板
- 当前进度追踪与任务规划

### ❌ 不在本文档范围内

- MoonBit 语言语法教学 → [MoonBit 官方文档](https://www.moonbitlang.com/)
- Starlight 主题配置细节 → [Starlight 文档](https://starlight.astro.build/)
- 图算法的数学证明 → 链接到各算法教程
- CI/CD 流水线配置 → `.github/workflows/`

---

## 相关资源

| 资源 | 链接 |
|------|------|
| 主仓库 | [github.com/moonbit/mbtgraph](https://github.com/moonbit/mbtgraph) |
| MoonBit 官方 | [www.moonbitlang.com](https://www.moonbitlang.com/) |
| Starlight 文档 | [starlight.astro.build](https://starlight.astro.build/) |
| VisuAlgo (算法动画) | [visualgo.net](https://visualgo.net/) |
| 项目 AGENTS.md | [`../AGENTS.md`](../AGENTS.md) |

---

<div align="center">

**v2.0.0** · 基于 agents-writer 最佳实践优化 · 最后更新: 2026-06-02

</div>
