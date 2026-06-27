---
title: Tarjan 算法：强连通分量 (SCC)
description: 基于 DFS 时间戳与 low 值的单次遍历强连通分量检测，O(V+E) 时间复杂度
---

# Tarjan 算法：强连通分量（SCC）

> 🎯 **本节目标**: 掌握 Tarjan SCC 算法原理、low 值机制与 MoonBit 实现 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

在有向图中，**强连通分量（Strongly Connected Component, SCC）** 是最大的节点子集，其中任意两个节点都可以互相到达。SCC 分析将"谁和谁在同一个闭环圈子中"这一直观问题形式化。

**Tarjan SCC 算法**（1972 年）通过单次 DFS，利用**时间戳（disc）** 和**低点值（low）** 检测所有的 SCC。当 `disc[u] == low[u]` 时，栈顶到 u 之间的所有节点构成一个 SCC。核心思路是：如果一个节点无法从它的子节点回到它的祖先，那么它就是当前 SCC 的根。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/tarjan/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/tarjan/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 同一颜色 | 属于同一个 SCC |
| 橙色 | 当前栈中（尚未确定分量） |
| 灰色 | 默认未访问 |

## MoonBit 实现

核心代码来自 `lib/algo/connectivity/scc/tarjan.mbt`：

```moonbit
///|
/// Tarjan SCC 算法
/// 返回所有强连通分量
/// 时间复杂度 O(V+E)，空间复杂度 O(V)
pub fn[G : @core.GraphReadable] tarjan_scc(graph : G) -> SccResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 { return SccResult::{ scc_list: [], count: 0 } }

  let max_id = find_max_node_id(graph)
  let size = max(max_id + 1, 1)

  let disc : Array[Int] = Array::make(size, -1)    // 发现时间
  let low : Array[Int] = Array::make(size, -1)      // 低点值
  let in_stack : Array[Bool] = Array::make(size, false)
  let stack : Array[@core.NodeId] = []              // 显式栈
  let scc_list : Array[Array[@core.NodeId]] = []
  let mut time = 0

  for start in @core.GraphReadable::node_ids(graph) {
    if disc[start.0] != -1 { continue }

    // 迭代式 DFS
    typealias StackFrame = (@core.NodeId, Iterator[@core.NodeId])
    let dfs_stack : Array[StackFrame] = []
    disc[start.0] = time; low[start.0] = time
    time = time + 1
    stack.push(start); in_stack[start.0] = true
    dfs_stack.push((start, @core.GraphReadable::neighbors(graph, start)))

    while dfs_stack.length() > 0 {
      let (u, mut nbr_iter) = dfs_stack[dfs_stack.length() - 1]
      let next = nbr_iter.next()
      match next {
        Some(v) => {
          if disc[v.0] == -1 {
            disc[v.0] = time; low[v.0] = time
            time = time + 1
            stack.push(v); in_stack[v.0] = true
            dfs_stack.push((v, @core.GraphReadable::neighbors(graph, v)))
          } else if in_stack[v.0] {
            low[u.0] = min(low[u.0], disc[v.0])
          }
        }
        None => {
          dfs_stack.pop()
          if dfs_stack.length() > 0 {
            let (p, _) = dfs_stack[dfs_stack.length() - 1]
            low[p.0] = min(low[p.0], low[u.0])
          }
          if disc[u.0] == low[u.0] {
            // u 是一个 SCC 的根
            let mut scc : Array[@core.NodeId] = []
            while stack.length() > 0 {
              let w = stack.pop()
              in_stack[w.0] = false
              scc.push(w)
              if w.0 == u.0 { break }
            }
            scc_list.push(scc)
          }
        }
      }
    }
  }

  SccResult::{ scc_list, count: scc_list.length() }
}
```

**为什么 `disc[u] == low[u]` 表示 SCC 根？** `low[u]` 记录 u 或 u 的后代通过回边能到达的最早祖先。如果 `low[u] == disc[u]`，说明 u 的后代无法绕过 u 回到更早的祖先——u 就是这个 SCC 中第一个被发现的节点（根），从栈顶到 u 的节点构成一个 SCC。

## 使用示例

```moonbit
fn tarjan_scc_demo() -> Unit {
  let g = build_sample_directed_graph()
  let result = @connectivity.tarjan_scc(g)

  println("SCC 数量: ${result.count}")
  for (i, scc) in result.scc_list.indexed() {
    println("SCC #${i}: ${scc}")
  }
}
```

## 实际场景

- **循环依赖检测**：在编译器/构建系统中检测模块间的循环导入
- **社交网络聚类**：识别紧密互关的"朋友圈"，分析信息传播路径
- **SCC 压缩 (Kosaraju-Sharir)**：将 DAG 中的每个 SCC 缩为一个"超级节点"，方便后续分析

## 扩展阅读

- [Kosaraju 算法](/algorithms/connectivity/scc/kosaraju/) — 另一种 SCC 算法（两次 DFS，更直观）
- [连通分量](/algorithms/connectivity/connected-components/) — 无向图版本的连通性分析
