---
title: Kosaraju 算法：强连通分量 (SCC)
description: 基于两次 DFS 的直观强连通分量检测，图转置 + 完成时间逆序，O(V+E) 时间复杂度
---

# Kosaraju 算法：强连通分量（SCC）

> 🎯 **本节目标**: 掌握 Kosaraju 算法原理、两次 DFS 流程与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**Kosaraju 算法**（也叫 Kosaraju-Sharir 算法）是一种求解有向图**强连通分量（SCC）**的算法。与 Tarjan SCC 不同，Kosaraju 的思路更直观：

1. **第一次 DFS**：在原始图上遍历，记录节点的"完成时间"（exit_time / finish order）
2. **图转置**：反转所有边的方向
3. **第二次 DFS**：按完成时间的倒序在转置图上遍历，每次 DFS 访问到的节点构成一个 SCC

这一思路的正确性基于引理：SCC 在转置图中保持不变，而按完成时间降序访问能确保每个 SCC 被完整遍历一次。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/kosaraju/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/kosaraju/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 同一颜色 | 属于同一个 SCC |
| 橙色 | 当前 DFS 处理中 |
| 绿色 | 当前轮已处理完毕 |
| 灰色 | 默认 |

## MoonBit 实现

核心代码来自 `lib/algo/connectivity/scc/kosaraju.mbt`：

```moonbit
///|
/// Kosaraju SCC 算法
/// 返回所有强连通分量
/// 时间复杂度 O(V+E)，空间复杂度 O(V+E)
pub fn[G : @core.GraphReadable] kosaraju_scc(graph : G) -> SccResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 { return SccResult::{ scc_list: [], count: 0 } }

  let max_id = find_max_node_id(graph)
  let size = max(max_id + 1, 1)

  // Step 1: 第一次 DFS，记录完成顺序
  let visited = Array::make(size, false)
  let order : Array[@core.NodeId] = []  // 完成顺序栈

  for start in @core.GraphReadable::node_ids(graph) {
    if visited[start.0] { continue }
    // 迭代式 DFS
    typealias Frame = (@core.NodeId, Iterator[@core.NodeId])
    let stack : Array[Frame] = [(start, @core.GraphReadable::neighbors(graph, start))]
    visited[start.0] = true
    while stack.length() > 0 {
      let (u, mut iter) = stack[stack.length() - 1]
      let next = iter.next()
      match next {
        Some(v) => if !visited[v.0] { visited[v.0] = true; stack.push((v, @core.GraphReadable::neighbors(graph, v))) }
        None => { order.push(u); stack.pop() }
      }
    }
  }

  // Step 2: 构建转置图（反转边的方向）
  let mut transpose : Array[Array[@core.NodeId]] = Array::make(size, [])
  for u in @core.GraphReadable::node_ids(graph) {
    for v in @core.GraphReadable::neighbors(graph, u) {
      transpose[v.0] = transpose[v.0] + [u]
    }
  }

  // Step 3: 第二次 DFS — 按完成顺序逆序在转置图上遍历
  let visited2 = Array::make(size, false)
  let scc_list : Array[Array[@core.NodeId]] = []

  for i in order.length() - 1 .. 0 {
    let u = order[i]
    if visited2[u.0] { continue }

    let scc : Array[@core.NodeId] = []
    let stack : Array[@core.NodeId] = [u]
    visited2[u.0] = true
    let mut head = 0
    while head < stack.length() {
      let cur = stack[head]; head = head + 1
      scc.push(cur)
      for nbr in transpose[cur.0] {
        if !visited2[nbr.0] { visited2[nbr.0] = true; stack.push(nbr) }
      }
    }
    scc_list.push(scc)
  }

  SccResult::{ scc_list, count: scc_list.length() }
}
```

**为什么需要转置？** 在转置图中，从 u 可达 v 等价于在原图中 v 可达 u。第二次 DFS 按完成时间降序访问，确保先处理"源头" SCC，从而完整剥离每个 SCC。

## 使用示例

```moonbit
fn kosaraju_scc_demo() -> Unit {
  let g = build_sample_directed_graph()
  let result = @connectivity.kosaraju_scc(g)

  println("SCC 数量: \{result.count\}")
  for (i, scc) in result.scc_list.indexed() {
    println("SCC #\{i\}: \{scc\}")
  }
}
```

## 实际场景

- **网页排名预处理**：Google PageRank 在 SCC 压缩后的 DAG 上迭代更快
- **课程依赖分析**：将强连通课程群识别为"必须同时学习"的模块
- **程序分析**：识别函数调用图中的递归环（SCC）

## 扩展阅读

- [Tarjan SCC 算法](/algorithms/connectivity/scc/tarjan/) — 单次 DFS 的 SCC 算法
- [连通分量](/algorithms/connectivity/connected-components/) — 无向图版本的连通性分析
