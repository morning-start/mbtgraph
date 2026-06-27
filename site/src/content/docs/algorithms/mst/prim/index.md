---
title: Prim 最小生成树
description: 从单个节点出发逐步扩展的最小生成树算法：原理、动画演示、MoonBit 实现
---

# Prim 最小生成树

> 🎯 **本节目标**: 掌握 Prim 算法原理、数组/优先队列实现与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**Prim 算法**是一种求解**最小生成树（MST）**的贪心算法，最早由 Jarník 于 1930 年发现，后由 Prim 于 1957 年独立提出。它从单个节点出发，每次选择**连接已选集合与未选集合的最小权重边**，逐步扩展 MST——如同从一颗种子长成覆盖所有节点的树。

Prim 使用数组（O(V²)，适用于稠密图）或优先队列（O(E log V)，适用于中等密度图）来维护候选边。与 Kruskal 不同，Prim 需要一个起点，且仅适用于连通图。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/prim/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/prim/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 深棕色 | 起点 |
| 橙色 | 当前候选的最小权重边 |
| 绿色 | 已加入 MST |
| 灰色 | 默认未处理 |

## MoonBit 实现

核心代码来自 `lib/algo/mst/prim.mbt`：

```moonbit
///|
/// Prim 最小生成树（从 root 节点开始）
/// 时间复杂度: O(V²)，空间复杂度: O(V)
pub fn[G : @core.GraphReadable] prim(
  graph : G,
  root : @core.NodeId,
) -> MstResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 || !@core.GraphReadable::contains_node(graph, root) {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }
  let max_id = mst_find_max_id(graph)
  let size = max_int(max_id + 1, 1)

  // key[v]: v 到已选集合的最小边权重
  let key : Array[Double?] = Array::make(size, None)
  let parent : Array[@core.NodeId?] = Array::make(size, None)
  let in_mst : Array[Bool] = Array::make(size, false)
  key[root.0] = Some(0.0)

  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0
  let mut count = 0

  while count < nc {
    // 线性扫描找 key 最小的未选节点
    let (u, found) = prim_min_key(key, in_mst, size)
    if !found { break }  // 图不连通，提前终止

    in_mst[u] = true
    match parent[u] {
      Some(p) =>
        match key[u] {
          Some(w) => {
            mst_edges.push((p, @core.NodeId(u), w))
            total_weight = total_weight + w
          }
          None => ()
        }
      None => ()
    }

    // 更新邻居的 key 值
    let unode = @core.NodeId(u)
    for vw in @core.GraphReadable::neighbors_with_weight(graph, unode) {
      match vw {
        (v, w) => {
          let vid = v.0
          if vid >= 0 && vid < size && !in_mst[vid] {
            match key[vid] {
              None => { key[vid] = Some(w); parent[vid] = Some(unode) }
              Some(k) => if w < k { key[vid] = Some(w); parent[vid] = Some(unode) }
            }
          }
        }
      }
    }
    count = count + 1
  }

  MstResult::{ total_weight, edges: mst_edges }
}
```

**数组 vs 优先队列？** 当前实现用数组（O(V²)），对稠密图（E ≈ V²）性能与 O(E log V) 差异不大。对于稀疏图，可改用二叉堆实现 O(E log V)。

## 使用示例

```moonbit
fn prim_demo() -> Unit {
  let mut g = @storage.UndirectedAdjList::new_with_capacity(5, 7)
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 5]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 3.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[3], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[4], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[0], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 7.0)

  let result = @mst.prim(g, nodes[0])
  println("MST 总权重: \(result.total_weight)")
}
```

## 实际场景

- **稠密图 MST 求解**：当图接近完全图时（如所有城市之间的完整连接成本），Prim 的 O(V²) 数组实现更优
- **渐进式网路铺设**：从数据中心出发逐步铺设光纤覆盖所有节点
- **聚类分析**：类似 Prim 的贪心合并过程用于单链接聚类

## 扩展阅读

- [Kruskal 算法](/algorithms/mst/kruskal/) — 边排序的另一种 MST 算法
- [Kruskal vs Prim 对比](/algorithms/mst/kruskal-prim/) — 两种 MST 算法的详细比较
