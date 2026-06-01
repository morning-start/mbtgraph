---
title: 图的读写操作
description: 查询和修改图数据的完整指南
---

# 🚧 内容建设中...

## 图的读写操作

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>查询：节点/边存在性、邻居列表、度数</li>
      <li>遍历：全量节点/边迭代器</li>
      <li>修改：更新权重、删除节点和边</li>
      <li>性能优化技巧（缓存、批处理）</li>
      <li>常见反模式与陷阱</li>
    </ul>
    <p>在此期间，可以先查看 <a href="/getting-started/concepts/">核心概念速查</a> 了解基本 API。</p>
  </div>
</div>

## 核心操作分类

### 只读操作 (GraphReadable)

所有存储都支持：
- `node_count()` / `edge_count()`
- `has_node()` / `has_edge()`
- `neighbors()` / `degree()`
- `get_node()` / `get_edge()`

### 可写操作 (GraphWritable)

仅动态存储支持：
- `add_node()` / `remove_node()`
- `add_edge()` / `remove_edge()`
- `update_weight()`

---

**相关文档：**
- [创建节点和边](/core-concepts/building-graphs/)
- [序列化与反序列化](/core-concepts/serialization/)
- [API 参考 - Core 模块](/api/core/)
