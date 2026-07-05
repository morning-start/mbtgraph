---
title: Kruskal 最小生成树
description: 按权重排序所有边，用并查集贪心选边的最小生成树算法：原理、动画演示、MoonBit 实现
---

# Kruskal 最小生成树

> 🎯 **本节目标**: 掌握 Kruskal 算法原理、Union-Find 数据结构与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**Kruskal 算法**是一种求解**最小生成树（MST）**的贪心算法，由 Joseph Kruskal 于 1956 年提出。它将所有边按权重从小到大排序，然后用**并查集（Union-Find）**逐一检查：如果边的两端不在同一集合中，就加入 MST 并合并集合；否则跳过（会形成环路）。

Kruskal 的优势在于：天然支持**不连通图**（返回森林），且对**稀疏图**（E ≈ V）非常高效，时间复杂度为 O(E log E)，瓶颈在于排序。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/kruskal/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/kruskal/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 橙色 | 当前检查的边 |
| 绿色 | 已加入 MST |
| 红色 | 跳过的边（会形成环路） |
| 灰色 | 默认未处理 |

## MoonBit 实现

核心代码来自 `lib/algo/mst/kruskal.mbt`：

```moonbit
///|
/// Kruskal 最小生成树
/// 返回无向图的最小生成树（不连通时返回森林）
pub fn[G : @core.GraphReadable] kruskal(graph : G) -> MstResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }
  let max_id = mst_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let uf = uf_new(size)

  // 收集边（只存 u.0 < v.0 避免重复）
  let raw_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for u in @core.GraphReadable::node_ids(graph) {
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw { (v, w) => if u.0 < v.0 { raw_edges.push((u, v, w)) } }
    }
  }

  let sorted = sort_edges(raw_edges)
  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0

  for edge in sorted {
    match edge {
      (u, v, w) =>
        if uf_union(uf, u.0, v.0) {
          mst_edges.push((u, v, w))
          total_weight = total_weight + w
        }
    }
  }

  MstResult::{ total_weight, edges: mst_edges }
}
```

Union-Find 实现：

```moonbit
priv struct UnionFind { parent : Array[Int]; rank : Array[Int] }

fn uf_new(size : Int) -> UnionFind {
  let p = [for i in 0..<size { i }]
  let r = [for _ in 0..<size { 0 }]
  UnionFind::{ parent: p, rank: r }
}

fn uf_find(uf : UnionFind, x : Int) -> Int {
  if uf.parent[x] != x {
    let root = uf_find(uf, uf.parent[x])
    uf.parent[x] = root  // 路径压缩
    root
  } else { x }
}

fn uf_union(uf : UnionFind, x : Int, y : Int) -> Bool {
  let rx = uf_find(uf, x); let ry = uf_find(uf, y)
  if rx == ry { return false }
  // 按秩合并
  if uf.rank[rx] < uf.rank[ry] { uf.parent[rx] = ry }
  else if uf.rank[rx] > uf.rank[ry] { uf.parent[ry] = rx }
  else { uf.parent[ry] = rx; uf.rank[rx] = uf.rank[rx] + 1 }
  true
}
```

**为什么只存 `u.0 < v.0` 的边？** 无向图的邻接表会为每条边生成两个方向，只存一个方向可减少一半的边数，加速排序和并查集操作。

## 使用示例

```moonbit
fn kruskal_demo() -> Unit {
  let mut g = @storage.UndirectedAdjList::new_with_capacity(5, 7)
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 5]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[3], 3.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[3], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[4], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 7.0)

  let result = @mst.kruskal(g)
  println("MST 总权重: \(result.total_weight)")
  for (u, v, w) in result.edges {
    println("  边 \(u.0)-\(v.0): 权重=\(w)")
  }
}
```

## 实际场景

- **电信骨干网设计**：用最低成本连接所有城市的光纤网络
- **电路布线**：在芯片上连接数千个引脚，最小化总线长
- **图像分割**：将像素视为节点，颜色差异为权重，Kruskal 贪心合并相似区域

## 扩展阅读

- [Prim 算法](/algorithms/mst/prim/) — 另一方向构建 MST（从节点出发逐步扩展）
- [Kruskal vs Prim 对比](/algorithms/mst/kruskal-prim/) — 两种 MST 算法的详细比较
