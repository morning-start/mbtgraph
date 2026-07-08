---
title: Floyd-Warshall 全源最短路径算法
description: 动态规划求解所有节点对最短路径：三重循环、DP 表演化、负环检测、MoonBit 实现
---

# Floyd-Warshall 全源最短路径算法

> 🎯 **本节目标**: 掌握 Floyd-Warshall 算法原理、DP 表演化与负环检测 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**Floyd-Warshall 算法**（简称 FW）是一种通过**动态规划**计算**所有节点对之间最短路径**的算法，由 Robert Floyd 和 Stephen Warshall 分别提出。它的核心思想是**逐步引入中转节点 k**：允许使用节点 {0,1,...,k} 作为中转时，检查每对节点 (i,j) 经过 k 是否能获得更短路径。

状态转移方程：`dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])`。FW 的**三重循环**结构使其实现极简，时间复杂度 O(V³)，适用于 V ≤ 400 的小图。它同时支持负权边，并能通过检查对角线 `dist[i][i] < 0` 检测全局负环。

> ⚠️ Floyd-Warshall 属于**矩阵 DP** 类算法，不适合用逐节点的 Cytoscape 动画来展示。下面用静态分析图说明其 DP 表演化过程。

## 动画演示

Floyd-Warshall 的核心是**距离矩阵的逐步演化**，适合用表格而非节点动画展示。以下用 4 节点图演示：

```
    0 ──(3)──→ 1
    ↑╲         │╲
   (8) ╲       │  (4)
    │   ╲      ↓   ╲
    │    ╲     │    ╲
    ▼     ╲    ▼     ╲
    2 ←─(2)── 3 ←─(-5)
```

**初始化**：对角线为 0，有边填权重，无边为 ∞。

```
k=-1（无中转）:
     0  1  2  3
  0 [0, 3, 8, ∞]
  1 [∞, 0, ∞, 4]
  2 [2, ∞, 0, ∞]
  3 [∞,-5, ∞, 0]
```

**关键轮次**（允许中转节点增加）：

| k | 改善的路径 | 说明 |
|---|-----------|------|
| k=0 | 2→1: ∞→5（经 0） | 首次中转带来的改善 |
| k=1 | 0→3: ∞→7（经 1），3→3: 0→-1 | dist[3][3] 变负 → 负环迹象 |
| k=3 | 0→1: 3→2（经 3），0→3: 7→6（经 1） | 利用负权边进一步优化 |

**负环检测**：最终 `dist[3][3] = -1 < 0`，说明存在负环（3→1→3，总权重 -1）。

## MoonBit 实现

核心代码来自 `lib/algo/shortest_path/floyd_warshall.mbt`：

```moonbit
///|
/// Floyd-Warshall 全源最短路径
/// 成功返回 FloydWarshallResult，检测到负环返回 Err
/// 时间复杂度: O(V³)，空间复杂度: O(V²)
pub fn[G : @core.GraphReadable] floyd_warshall(
  graph : G,
) -> Result[FloydWarshallResult, String] {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return Ok(FloydWarshallResult::{ distances: [], next: [] })
  }

  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)

  // dist[i][j]: i→j 的最短距离，next[i][j]: 路径上 i 的下一个节点
  let dist : Array[Array[Double?]] = []
  let nxt : Array[Array[@core.NodeId?]] = []

  for i in 0..<size {
    let row_d : Array[Double?] = []
    let row_n : Array[@core.NodeId?] = []
    for j in 0..<size {
      row_d.push(if i == j { Some(0.0) } else { None })
      row_n.push(None)
    }
    dist.push(row_d)
    nxt.push(row_n)
  }

  // 填入直接边
  for u in @core.GraphReadable::node_ids(graph) {
    for v in @core.GraphReadable::neighbors(graph, u) {
      match @core.GraphReadable::get_edge(graph, u, v) {
        Some(w) => {
          if u.0 >= 0 && u.0 < size && v.0 >= 0 && v.0 < size {
            dist[u.0][v.0] = Some(w)
            nxt[u.0][v.0] = Some(v)
          }
        }
        None => ()
      }
    }
  }

  // 核心三重循环：k = 中转节点
  for k in 0..<size {
    for i in 0..<size {
      for j in 0..<size {
        match dist[i][k] {
          Some(dik) =>
            match dist[k][j] {
              Some(dkj) => {
                let through = dik + dkj
                let should_update = match dist[i][j] {
                  None => true
                  Some(dij) => through < dij
                }
                if should_update {
                  dist[i][j] = Some(through)
                  nxt[i][j] = nxt[i][k]
                }
              }
              None => ()
            }
          None => ()
        }
      }
    }
  }

  // 负环检测：检查对角线
  for i in 0..<size {
    match dist[i][i] {
      Some(d) => if d < 0.0 { return Err("negative cycle detected") }
      None => ()
    }
  }

  Ok(FloydWarshallResult::{ distances: dist, next: nxt })
}
```

**`next[][]` 矩阵的作用**：`next[i][j]` 存储从 i 到 j 最短路径上 i 的下一个节点，通过递归查找可重建完整路径。

## 使用示例

```moonbit
fn floyd_warshall_demo() -> Unit {
  let g = build_sample_directed_graph()

  match @shortest_path.floyd_warshall(g) {
    Ok(result) => {
      let from = @core.NodeId(0); let to = @core.NodeId(3)
      let dist = result.distance_between(from, to)
      let path = result.path_from_to(from, to)
      println("0 → 3 最短距离: \{dist\}")
      println("路径: \{path\}")
    }
    Err(msg) => println("检测到负环: \{msg\}")
  }
}
```

## 实际场景

- **物流调度预计算**：离线计算所有仓库间的最短运输距离，查询时 O(1) 响应
- **社交网络全量分析**：计算所有用户间的"关系距离"，验证六度分隔理论
- **编译器寄存器分配**：计算变量之间的"拷贝距离"，优化赋值顺序

## 扩展阅读

- [Dijkstra 算法](/algorithms/shortest-path/dijkstra/) — 单源最短路径（稀疏图更快）
- [Bellman-Ford 算法](/algorithms/shortest-path/bellman-ford/) — 单源 + 负权边
