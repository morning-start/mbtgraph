---
title: 6 层 Trait 详解
description: 深入理解 mbtgraph 的 Trait 分层架构设计
---

# 🚧 内容建设中...

## 6 层 Trait 详解

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 6 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>GraphReadable 基础接口（12 个方法）</li>
      <li>GraphWritable 可写扩展（+5 方法）</li>
      <li>GraphDirected 有向图特化（+6 方法）</li>
      <li>GraphFull 便捷别名</li>
      <li>GraphBatchReadable 批量优化（CSR/CSC）</li>
      <li>GraphEdgeIterable 边排序支持</li>
      <li>Trait 组合策略与最佳实践</li>
    </ul>
    <p>在此期间，你可以先参考 <a href="/getting-started/concepts/">核心概念速查</a> 获取基础知识。</p>
  </div>
</div>

## Trait 层级总览

```
GraphReadable (基础只读, 12 方法, 所有存储)
├── GraphWritable     (可写, +5 方法, 动态存储专属)
├── GraphDirected     (有向, +6 方法, 入边查询)
│   └── GraphFull    = Writable + Directed (便捷别名)
├── GraphBatchReadable(批量, +2 方法, CSR/CSC 专属)
└── GraphEdgeIterable (边排序, +1 方法, Kruskal 友好)
```

## 即将包含的内容

### GraphReadable - 基础只读接口

这是所有存储必须实现的接口，提供最基本的图查询能力。

**适用范围**：所有 8 种存储结构

**核心方法**：
- `node_count()` / `edge_count()` - 统计信息
- `has_node()` / `has_edge()` - 存在性检查
- `neighbors()` / `degree()` - 邻居查询
- `nodes()` / `edges()` - 全量遍历
- `get_node()` / `get_edge()` - 数据访问

### GraphWritable - 可写扩展

为动态存储提供增删改能力。

**适用范围**：AdjList、Matrix、EdgeList

**新增方法**：
- `add_node()` / `remove_node()`
- `add_edge()` / `remove_edge()`
- `update_weight()`

### 使用示例

```moonbit
// 定义一个接受任何 GraphReadable 的函数
pub fn[G : @core.GraphReadable] print_graph_info(graph : G) -> Unit {
  println("节点数: \(graph.node_count())")
  println("边数: \(graph.edge_count())")
}

// 可以传入任何存储
print_graph_info(my_adj_list)
print_graph_info(my_matrix)
print_graph_info(my_csr)
```

---

**相关文档：**
- [节点与边的表示](/core-concepts/data-types/)
- [存储选型指南](/core-concepts/storage-guide/)
- [API 参考 - Core 模块](/api/core/)
