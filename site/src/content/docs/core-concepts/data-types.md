---
title: 节点与边的表示
description: 图的基本数据类型详解
---

# 🚧 内容建设中...

## 节点与边的表示

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 6 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>NodeId 类型及其用法</li>
      <li>Node 数据结构（支持泛型）</li>
      <li>Edge 结构体（有向/无向、加权/无权）</li>
      <li>Weight 类型的设计与最佳实践</li>
      <li>类型安全的边界检查机制</li>
    </ul>
    <p>在此期间，你可以先参考 <a href="/getting-started/concepts/">核心概念速查</a> 获取基础知识。</p>
  </div>
</div>

## 即将包含的内容

### NodeId - 节点标识符

```moonbit
// 节点 ID 是一个简单的整数包装器
pub struct NodeId {
  id: Int,
}

// 创建方式
let node0 = @core.NodeId(0)
let node1 = @core.NodeId(1)
```

### Node - 节点数据

```moonbit
// 节点可以携带任意类型的数据
pub struct Node[T] {
  id: NodeId,
  data: T,
}

// 示例：字符串类型的用户节点
let user_a = @core.Node {
  id: @core.NodeId(0),
  data: "Alice",
}
```

### Edge - 边的定义

```moonbit
// 边连接两个节点，可选权重
pub struct Edge {
  source: NodeId,
  target: NodeId,
  weight: Option[Double],
}

// 有权边
let weighted_edge = @core.Edge {
  source: @core.NodeId(0),
  target: @core.NodeId(1),
  weight: Some(10.5),
}

// 无权边
let unweighted_edge = @core.Edge {
  source: @core.NodeId(0),
  target: @core.NodeId(1),
  weight: None,
}
```

---

**相关文档：**
- [6 层 Trait 详解](/core-concepts/traits/)
- [错误处理机制](/core-concepts/error-handling/)
- [API 参考 - Core 模块](/api/core/)
