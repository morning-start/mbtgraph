---
title: 8 种存储对比表
description: 全面对比 mbtgraph 的 8 种图存储结构
---

# 🚧 内容建设中...

## 8 种存储对比表

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 6 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>有向/无向邻接表（AdjList）</li>
      <li>有向/无向邻接矩阵（Matrix）</li>
      <li>有向/无向边集数组（EdgeList）</li>
      <li>压缩稀疏行/列（CSR/CSC）</li>
      <li>空间复杂度、时间复杂度对比</li>
      <li>适用场景分析</li>
    </ul>
    <p>在此期间，你可以先参考 <a href="/getting-started/concepts/">核心概念速查</a> 获取基础知识。</p>
  </div>
</div>

## 存储结构速览

### 有向图存储

| 存储 | 空间 | 邻居查询 | 增删操作 | 适用场景 |
|------|:----:|:--------:|:--------:|---------|
| **DirectedAdjList** ⭐ | O(V+E) | O(k) | O(1) | 通用推荐 |
| DirectedMatrix | O(V²) | O(1) | O(1) | 稠密小图 |
| EdgeList | O(E) | O(E) | O(log E) | MST/Kruskal |
| CSR | O(V+E) | O(k) | ❌ | 大规模静态图 |
| CSC | O(V+E) | O(k) | ❌ | 入边密集查询 |

### 无向图存储

| 存储 | 空间 | 特点 | 适用场景 |
|------|:----:|------|---------|
| **UndirectedAdjList** ⭐ | O(V+E/2) | 半存储 -50% | 无向通用图 |
| UndirectedMatrix | O(V²/2) | 对称矩阵 | 小型无向图 |
| UndirectedEdgeList | O(E/2) | 无向边集 | 无向 MST |

---

**相关文档：**
- [场景化选型决策树](/core-concepts/storage-decision/)
- [性能基准测试](/core-concepts/benchmarks/)
- [存储转换器使用](/core-concepts/storage-converter/)
