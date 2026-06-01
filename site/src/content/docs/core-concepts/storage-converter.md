---
title: 存储转换器使用
description: 在不同的图存储结构之间灵活转换
---

# 🚧 内容建设中...

## 存储转换器使用

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>8 个泛型转换函数详解</li>
      <li>有向 ↔ 无向转换</li>
      <li>动态 ↔ 静态存储转换</li>
      <li>数据保留与丢失说明</li>
      <li>最佳实践与注意事项</li>
    </ul>
    <p>在此期间，可以先了解 <a href="/getting-started/concepts/">核心概念速查</a> 中的存储部分。</p>
  </div>
</div>

## 转换函数一览

```moonbit
// 有向 → 无向
let undirected = to_undirected_adj_list(directed_graph)

// AdjList → Matrix
let matrix = to_matrix(adj_list)

// AdjList → CSR (大规模优化)
let csr = to_csr(adj_list)

// EdgeList → AdjList (Kruskal 后重建)
let adj_list = from_edge_list(edge_list)
```

### 使用场景示例

**场景 1：构建阶段用 AdjList，算法阶段转 CSR**

```moonbit
// 构建阶段：需要频繁增删
let mut g = @storage.DirectedAdjList::new()
g = @core.GraphWritable::add_node(g, "A") |> ignore
// ... 更多操作

// 算法阶段：转为静态存储提升性能
let csr = @converter.to_csr(g)
let result = bfs(csr, start)  // 缓存友好
```

**场景 2：MST 算法需要 EdgeList**

```moonbit
// 从 AdjList 转 EdgeList
let edge_list = @converter.to_edge_list(my_adj_list)
let mst_result = kruskal(edge_list)  // 需要 EdgeIterable
```

---

**相关文档：**
- [8 种存储对比表](/core-concepts/storage-guide/)
- [场景化选型决策树](/core-concepts/storage-decision/)
- [API 参考 - Storage 模块](/api/storage/)
