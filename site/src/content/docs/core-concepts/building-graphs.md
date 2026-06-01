---
title: 创建节点和边
description: 从零开始构建图结构
---

# 🚧 内容建设中...

## 创建节点和边

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>创建空图（不同存储类型）</li>
      <li>添加单个/批量节点</li>
      <li>添加有向/无向边</li>
      <li>设置边的权重</li>
      <li>构建复杂图的模式（工厂函数、Builder 模式）</li>
    </ul>
    <p>在此期间，可以参考 <a href="/getting-started/first-graph/">第一个图程序</a> 中的示例代码。</p>
  </div>
</div>

## 基本用法速览

```moonbit
// 创建空图
let mut g = @storage.DirectedAdjList::new()

// 添加节点
g = @core.GraphWritable::add_node(g, "Node A") |> ignore

// 添加边
g = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
```

---

**相关文档：**
- [图的读写操作](/core-concepts/graph-operations/)
- [6 层 Trait 详解](/core-concepts/traits/)
- [API 参考 - Storage 模块](/api/storage/)
