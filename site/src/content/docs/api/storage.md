---
title: Storage 模块接口
description: 8 种图存储结构的完整 API 文档
---

# 🚧 内容建设中...

## Storage 模块接口

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 10 月中旬（可从源码自动生成）</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>DirectedAdjList / UndirectedAdjList</li>
      <li>DirectedMatrix / UndirectedMatrix</li>
      <li>EdgeList / UndirectedEdgeList</li>
      <li>CSR / CSC 压缩存储</li>
      <li>Converter 转换函数</li>
    </ul>
    <p>在此期间，可以参考 <a href="/core-concepts/storage-guide/">存储选型指南</a>。</p>
  </div>
</div>

## 存储模块列表

| 模块 | 文件路径 | Trait 支持 |
|------|---------|-----------|
| 有向邻接表 | `directed_adj_list.mbt` | R+W+D+E |
| 无向邻接表 | `undirected_adj_list.mbt` | R+W+E |
| 有向矩阵 | `directed_matrix.mbt` | R+W+D |
| 无向矩阵 | `undirected_matrix.mbt` | R+W |
| 边集数组 | `edge_list.mbt` | R+W+E |
| 无向边集 | `undirected_edge_list.mbt` | R+W+E |
| CSR | `csr.mbt` | R+B |
| CSC | `csc.mbt` | R+B |

**R**: GraphReadable | **W**: GraphWritable | **D**: GraphDirected | **B**: BatchReadable | **E**: EdgeIterable

---

**相关文档：**
- [Core 模块接口](/api/core/)
- [IO 模块接口](/api/io/)
