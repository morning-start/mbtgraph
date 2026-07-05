---
title: 项目愿景
description: mbtgraph 的使命——填补 MoonBit 生态图算法空白，成为 MoonBit 官方推荐的图算法标准库
---

import { Card, CardGrid } from '@astrojs/starlight/components';

## 🎯 一句话定义

**mbtgraph 是 MoonBit 生态系统中首个生产级图算法库，提供从基础数据结构到高级图分析的完整解决方案。**

---

## 🌟 为什么需要 mbtgraph？

### MoonBit 生态的空白

MoonBit 作为新兴的多后端编程语言（支持 native/wasm/js），在 2026 年仍面临一个关键问题：

```
MoonBit 生态系统 (2026)
  ✅ Web 框架    ✅ 数据库驱动   ✅ HTTP 客户端
  ✅ JSON 解析   ✅ 日志库       ✅ 测试框架
  ❌ 图算法库    ❌ 图数据结构   ❌ 网络分析工具   ← 空白！
```

**现状**: 开发者如果需要在 MoonBit 中使用图算法，必须：
1. 自己从零实现（重复造轮子）
2. 通过 FFI 调用其他语言的库（性能损失 + 复杂度）
3. 放弃图相关的功能需求（限制应用场景）

**mbtgraph 的使命**: 填补这一空白，让 MoonBit 开发者开箱即用地使用高质量图算法。

---

## 💡 项目价值主张

<CardGrid stagger>
	<Card title="社交网络分析" icon="groups">
	没有 mbtgraph：需要自己实现 PageRank/社区检测<br/>
	有 mbtgraph：`pagerank(graph)` 一行调用
	</Card>
	<Card title="路径规划" icon="route">
	没有 mbtgraph：手写 Dijkstra/A\* (100+ 行 bug 多)<br/>
	有 mbtgraph：`dijkstra(graph, source)` 生产级实现
	</Card>
	<Card title="网络流优化" icon="activity">
	没有 mbtgraph：无法实现<br/>
	有 mbtgraph：`max_flow(network, s, t)` 直接可用
	</Card>
	<Card title="Wasm 前端" icon="globe">
	没有 mbtgraph：无图可视化数据源<br/>
	有 mbtgraph：DOT/JSON 序列化直接对接 D3.js
	</Card>
</CardGrid>

### 对 MoonBit 生态的贡献

| 维度 | 贡献 |
|------|------|
| **生态完整性** | 补齐"数据结构与算法"版图的关键拼图 |
| **语言竞争力** | 展示 MoonBit 在系统编程领域的能力 |
| **学习资源** | 为学习者提供算法实现的 MoonBit 最佳实践 |
| **工业就绪** | 证明 MoonBit 可用于生产级数学计算 |

---

## 🎯 项目目标

### 终极愿景

> **成为 MoonBit 官方推荐的图算法标准库，如同 NetworkX 之于 Python，petgraph 之于 Rust。**

### 阶段性成果

| 阶段 | 版本 | 核心产出 | 状态 |
|:----:|:----:|---------|:----:|
| **核心完成** | v0.1.0 | 19 个算法模块、8 种存储结构、5 层 Trait 架构 | ✅ 已完成 |
| **文档完善** | v0.1.1 | 补充算法、完善文档、调试可视化站点 | ✅ 已完成 |
| **高级拓展** | v0.2.0+ | 高级图算法、大规模图处理 | ⬜ 规划中 |

---

## 📊 竞品对比

| 维度 | mbtgraph | NetworkX | petgraph | JGraphT |
|------|:--------:|:--------:|:--------:|:-------:|
| **语言** | MoonBit ⭐ | Python | Rust | Java |
| **多后端** | native+wasm+js ⭐ | Python only | Native | JVM only |
| **wasm 体积** | 53 KB（gzip 23 KB）⭐ | N/A | ~2MB | >50MB |
| **Trait 层数** | 5 层 ⭐ | 3 层 | 3 层 | 4 层 |
| **存储种类** | 8 种 ⭐ | 4 种 | 5 种 | 6 种 |
| **纯函数** | ✅ 天然支持 ⭐ | ❌ | 部分 | ❌ |

**⭐ = mbtgraph 的独特优势**

---

## 👥 目标用户

| 用户类型 | 典型需求 |
|---------|---------|
| **MoonBit 应用开发者** | Wasm 前端/后端的路径规划、依赖分析、状态机 |
| **算法竞赛选手** | 快速原型验证、经典算法参考 |
| **科研工作者** | 社区检测、中心性分析、PageRank |
| **教育工作者** | 数据结构课程教学的清晰代码示例 |

---

## 相关文档

- [项目路线图](/about/roadmap/) — 版本规划与时间线
- [架构总览](/core-concepts/traits/) — Trait 分层与存储设计
- [算法目录](/algorithms/catalog/) — 完整算法清单
