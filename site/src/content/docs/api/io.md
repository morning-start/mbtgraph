---
title: IO 模块接口
description: DOT 格式读写、JSON 序列化、图统计工具
---

# 🚧 内容建设中...

## IO 模块接口

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 11 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>DOT 格式读写（Graphviz 兼容）</li>
      <li>JSON 序列化与反序列化</li>
      <li>图统计工具（度分布、连通分量数等）</li>
      <li>I/O 错误处理</li>
    </ul>
  </div>
</div>

## IO 模块结构

```
lib/io/
├── types.mbt               # IOError + 统计类型
├── dot.mbt                 # DOT 格式读写
├── json_serializer.mbt     # JSON 格式读写
├── graph_stats.mbt         # 图统计工具
└── io_test.mbt             # 集成测试
```

### 主要功能

#### DOT 格式支持
```moonbit
// 导出为 DOT 格式
let dot_string = @io.dot::to_dot(my_graph)

// 从 DOT 格式导入
match @io.dot::from_dot(dot_string) {
  Ok(graph) => { /* 使用 graph */ }
  Err(e) => { /* 处理错误 */ }
}
```

#### JSON 格式支持
```moonbit
// 导出为 JSON
let json_str = @io.json_serializer::to_json(my_graph)

// 从 JSON 导入
match @io.json_serializer::from_json(json_str) {
  Ok(graph) => { /* 使用 graph */ }
  Err(e) => { /* 处理错误 */ }
}
```

#### 统计工具
```moonbit
// 计算图的统计信息
let stats = @io.graph_stats::analyze(my_graph)
println("平均度: \(stats.average_degree)")
println("密度: \(stats.density)")
```

---

**相关文档：**
- [Core 模块接口](/api/core/)
- [Storage 模块接口](/api/storage/)
- [序列化与反序列化](/core-concepts/serialization/)
