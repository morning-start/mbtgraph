---
title: 错误处理机制
description: mbtgraph 的错误类型和处理模式
---

# 🚧 内容建设中...

## 错误处理机制

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 6 月下旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>GraphError 错误类型枚举</li>
      <li>Result[T, E] 类型的正确使用</li>
      <li>常见错误场景及处理示例</li>
      <li>错误恢复策略</li>
      <li>调试技巧与日志记录</li>
    </ul>
    <p>在此期间，你可以先参考 <a href="/getting-started/concepts/">核心概念速查</a> 中的错误处理部分。</p>
  </div>
</div>

## 错误类型概览

mbtgraph 使用 `Result[T, GraphError]` 来处理可能失败的操作。

### 主要错误类型

```moonbit
pub enum GraphError {
  NodeNotFound(NodeId)        // 节点不存在
  DuplicateNode               // 重复添加节点
  EdgeNotFound                // 边不存在
  DuplicateEdge               // 重复边
  InvalidOperation(String)    // 无效操作（如对只读存储执行写入）
  IndexOutOfBounds(Int)       // 索引越界
}
```

### 基本处理模式

```moonbit
match operation_that_may_fail(graph) {
  Ok(result) => {
    // 成功：使用结果
    process(result)
  }
  Err(error) => {
    // 失败：根据错误类型处理
    match error {
      @core.GraphError::NodeNotFound(id) => {
        println("错误：节点 \(id) 不存在")
      }
      @core.GraphError::DuplicateEdge => {
        println("警告：边已存在，将被忽略")
      }
      _ => {
        println("未知错误")
      }
    }
  }
}
```

---

**相关文档：**
- [节点与边的表示](/core-concepts/data-types/)
- [6 层 Trait 详解](/core-concepts/traits/)
- [API 参考 - Core 模块](/api/core/)
