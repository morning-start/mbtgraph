---
title: Prim 最小生成树
description: 从单个节点出发，逐步扩展的最小生成树构建算法
---

# Prim 算法

> **核心思想**: 从根节点出发，每次选择连接已选集合与未选集合的最小边 \
> **API**: `prim(graph, root)` → `MstResult` \
> **前置**: [Kruskal & Prim 对比详解](/algorithms/mst/kruskal-prim/)

---

## 一、算法原理

<div class="viz-preview-card">
  <iframe src="/visualizations/prim/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/prim/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

Prim 算法从一个根节点出发，维护一个"已选节点集"，每次选择连接"已选"与"未选"节点的最小边：

```
已选集合 S = {0}     ← 从节点 0 开始
候选边：0-1(2), 0-3(1) → 选最小的 0-3(1)
S = {0, 3}
候选边：0-1(2), 3-1(3), 3-2(5) → 选最小的 0-1(2)
...重复直到所有节点都在 S 中
```

**时间复杂度**: O(E log V) 使用二叉堆

---

## 二、代码示例

```moonbit
fn main {
  let mut g = @storage.UndirectedAdjList::new()
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 6]
  // 无向带权图
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[3], 3.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[3], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[4], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 7.0)

  let result = @mst.prim(g, nodes[0])
  println("MST 总权重: \(result.total_weight)")
  println("MST 边数: \(result.edge_count())")
  for (u, v, w) in result.edges {
    println("  边 \(u.0)-\(v.0): 权重=\(w)")
  }
}
```

**输出：**
```
MST 总权重: 13.0
MST 边数: 4
  边 0-3: 权重=1.0
  边 0-1: 权重=2.0
  边 1-2: 权重=4.0
  边 2-4: 权重=6.0
```

Prim 构建的 MST 与 Kruskal 结果相同（总权重 13），但边加入顺序不同。

---

## 三、对比

| 特性 | Prim | Kruskal |
|:----|:----:|:-------:|
| 思路 | 节点扩展 | 边排序 |
| 数据结构 | 二叉堆 | 并查集 |
| 适用图 | **稠密图** ⭐ | 稀疏图 |
| 实现复杂度 | 中等 | 简单 |

> **选型建议**：边多的稠密图用 Prim，边少的稀疏图用 Kruskal。

---

**相关文档：**
- [Kruskal 算法](/algorithms/mst/kruskal/)
- [Kruskal & Prim 对比详解](/algorithms/mst/kruskal-prim/)
