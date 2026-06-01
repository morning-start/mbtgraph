---
title: Core 模块接口
description: 核心类型定义、Trait 接口和错误处理
---

# 🚧 内容建设中...

## Core 模块接口

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 10 月上旬（可从源码自动生成）</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>NodeId, Node, Edge, Weight 类型定义</li>
      <li>6 层 Trait 完整接口文档</li>
      <li>GraphError 错误类型枚举</li>
      <li>类型安全的使用示例</li>
    </ul>
    <p>在此期间，可以查看 <a href="/core-concepts/traits/">Trait 系统教程</a> 了解核心接口。</p>
  </div>
</div>

## 模块结构

```
lib/core/
├── types.mbt       # NodeId, Node, Edge, Weight
├── traits.mbt      # 6 层 Trait 定义
└── error.mbt       # GraphError 类型
```

### 核心类型

#### NodeId
```moonbit
pub struct NodeId {
  id: Int,
}
```

#### Node
```moonbit
pub struct Node[T] {
  id: NodeId,
  data: T,
}
```

#### Edge
```moonbit
pub struct Edge {
  source: NodeId,
  target: NodeId,
  weight: Option[Double],
}
```

---

**相关文档：**
- [Storage 模块接口](/api/storage/)
- [各算法模块 API](/api/algorithms/)
