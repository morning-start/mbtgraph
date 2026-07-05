---
title: 基础教程概述
description: mbtgraph 核心概念与使用方法详解
---

# 基础教程

欢迎来到 mbtgraph 基础教程！本部分将帮助你深入理解图算法库的核心概念和使用方法。

## 教程内容

本教程分为三个主要模块：

### 1. 图的数据结构

学习图的基本组成元素：
- [节点与边的表示](/core-concepts/data-types/) - 理解 NodeId、Node、Edge 等核心类型
- [5 层 Trait 详解](/core-concepts/traits/) - 掌握 Trait 分层架构的设计思想
- [错误处理机制](/core-concepts/error-handling/) - 学会正确处理图操作中的异常情况

### 2. 存储结构选型指南

根据你的应用场景选择最合适的存储结构：
- [8 种存储对比表](/core-concepts/storage-guide/) - 全面了解各种存储的特点
- [场景化选型决策树](/core-concepts/storage-decision/) - 快速找到适合你需求的存储
- [性能基准测试](/core-concepts/benchmarks/) - 基于实际数据的性能对比
- [存储转换器使用](/core-concepts/storage-converter/) - 在不同存储间灵活转换

### 3. 图的构建与操作

掌握图的创建和管理技巧：
- [创建节点和边](/core-concepts/building-graphs/) - 从零开始构建图
- [图的读写操作](/core-concepts/graph-operations/) - 查询和修改图数据
- [序列化与反序列化](/core-concepts/serialization/) - 图的持久化存储

## 学习建议

### 新手路线（推荐）

如果你是第一次接触图算法或 MoonBit 语言：

1. 先阅读 **[核心概念速查](/getting-started/concepts/)** 获得全局概览
2. 深入学习 **[节点与边的表示](/core-concepts/data-types/)**
3. 重点理解 **[Trait 系统](/core-concepts/traits/)** - 这是 mbtgraph 的核心设计
4. 根据 **[存储选型指南](/core-concepts/storage-guide/)** 选择合适的存储结构
5. 动手实践 **[第一个图程序](/getting-started/first-graph/)** 巩固所学

### 有经验者路线

如果你已经熟悉图算法或其他语言的图库：

1. 快速浏览 **[Trait 分层体系](/core-concepts/traits/)** 了解设计差异
2. 查看 **[存储对比表](/core-concepts/storage-guide/)** 了解性能特性
3. 直接进入 **[算法教程](/algorithms/index/)** 学习具体实现
4. 参考 **[API 文档](/api/core/)** 查阅详细接口说明

## 核心设计理念

mbtgraph 的设计遵循以下原则：

### 1. Trait 驱动的泛型编程

通过 Trait 机制实现算法与存储的解耦：

```moonbit
// 同一个 BFS 函数可用于所有实现了 GraphReadable 的存储
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult { ... }
```

**优势**：
- 算法代码只需编写一次
- 用户可自由选择存储结构
- 新增存储无需修改算法代码

### 2. 渐进式复杂度

从简单到复杂的 Trait 层级：

```
GraphReadable (只读)
├── GraphWritable (可写)
│   └── GraphFull = Writable + Directed (完全功能)
└── GraphBatchReadable (批量优化)
```

**优势**：
- 按需选择，避免过度设计
- 接口清晰，易于理解和测试
- 支持不同性能需求的场景

### 3. 纯函数语义

所有操作返回新实例，不修改原始数据：

```moonbit
let g = @storage.DirectedAdjList::new()
let g = @core.GraphWritable::add_node(g, "A")  // 返回新实例
let result = bfs(g, start)  // g 保持不变
```

**优势**：
- 无副作用，便于推理
- 天然支持撤销/回滚
- 易于并行化和测试

## 与其他图库的区别

| 特性 | mbtgraph | NetworkX (Python) | Boost Graph (C++) |
|------|---------|-------------------|-------------------|
| 语言 | MoonBit | Python | C++ |
| 类型安全 | 强类型编译时检查 | 弱类型运行时检查 | 强类型模板 |
| 函数式语义 | 纯函数，不可变 | 可变对象 | 可变对象 |
| 存储抽象 | Trait 泛型 | 统一接口 | 模板参数化 |
| 后端支持 | native/wasm/js | 仅 Python | 仅 C++ |
| 学习曲线 | 中等 | 低 | 高 |

## 下一步

完成基础教程后，你可以：

- 进入 **[算法原理与实践](/algorithms/index/)** 学习具体的图算法
- 查看 **[实战案例](/use-cases/social-network/build-graph/)** 了解真实应用场景
- 阅读 **[API 参考](/api/core/)** 查询详细的接口文档

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">💡</span>
    <p class="callout-title">提示</p>
  </div>
  <div class="callout-content">
    <p>在学习过程中遇到问题？可以查看 <a href="/contributing/coding-standards/">编码规范</a> 或在 GitHub 提交 Issue。</p>
  </div>
</div>
