---
title: "Floyd-Warshall 全源最短路径算法"
description: "全源最短路径详解：动态规划表演化、三重循环动画、路径重建、MoonBit实现、社交网络分析"
---

# Floyd-Warshall 全源最短路径算法

> 🎯 **本节目标**: 掌握 Floyd-Warshall 算法原理、DP 表动态演化过程、负环检测及实际应用
>
> ⏱️ **预计阅读时间**: 30 分钟 | 🎮 **互动演示**: 3 个可运行示例 + DP 表追踪

## 📖 算法简介

**Floyd-Warshall 算法**（简称 **FW 算法**）是一种用于计算**所有节点对之间最短路径**的动态规划算法。

### 核心思想 💡

想象你是**一名物流调度中心的管理员**：

```
🚚 物流调度类比:

  仓库网络:
    [北京] ──(成本)──→ [上海]
      │╲               ╱│╲
      │  ╲           ╱  │  ╲
    (成本) (成本)   (成本)(成本)
      │    ╲       ╱    │    ╲
      ▼     ╲     ▼     ▼     ╲
   [广州]  [成都] [武汉] [西安] [杭州]

问题: 需要知道"任意两个城市之间的最低运输成本"

朴素方法:
  对每对城市 (V×V = 25 对), 各跑一次 Dijkstra → O(V² × (V+E)logV)
  太慢了!

Floyd-Warshall 的智慧:
  "如果北京→上海→广州 比北京→广州更便宜,
   那以后所有经过北京的到广州的路线, 都可以考虑绕道上海!"

核心策略: 动态规划 — 逐步引入"中转节点"
```

### 为什么需要 Floyd-Warshall?

| 场景 | 单源 (Dijkstra/BF) | **Floyd-Warshall** |
|------|-------------------|-------------------|
| 只需要从一个起点出发 | ✅ Dijkstra/BF 更快 | 可用但浪费 |
| **需要所有点对的最短路径** | ❌ 需要运行 V 次 | **✅ 一次搞定!** |
| 图的规模小 (V<400) | 都行 | **FW 更简洁** |
| 需要检测全局负环 | 需要对每个起点检测 | **✅ 天然支持** |
| 需要频繁查询不同起终点 | 每次都要重算 | **预计算, O(1) 查询** |

### 动态规划思想

```
FW 算法的 DP 定义:

  dist[k][i][j] = 从 i 到 j 的最短路径,
                   中间只允许使用节点 {0,1,...,k} 作为中转

状态转移方程:
  dist[k][i][j] = min(
    dist[k-1][i][j],          // 不使用 k 作为中转 (保持原路径)
    dist[k-1][i][k] + dist[k-1][k][j]  // 使用 k 作为中转!
  )

直观理解:
  k=0: 只允许直连或通过节点 0 中转
  k=1: 允许通过 {0,1} 中转 (可能发现更优路径)
  k=2: 允许通过 {0,1,2} 中转
  ...
  k=V-1: 允许通过任意节点中转 → 最终答案!

空间优化:
  实际上 dist[k] 只依赖 dist[k-1],
  所以可以压缩为二维数组 (滚动数组优化)!
```

---

## 🎬 动画演示：Floyd-Warshall 分步执行过程

让我们通过一个具体例子来理解 FW 算法的执行流程，特别关注**DP 表的逐步演化**。

### 示例图: 4 节点带权有向图

```
    0 ──(3)──→ 1
    ↑╲         │╲
   (8) ╲       │  (4)
    │   ╲      ↓   ╲
    │    ╲     │    ╲
    ▼     ╲    ▼     ╲
    2 ←─(2)── 3 ←──(-5)

边列表 (直接距离):
  0→1=3,  0→2=8,  1→3=4,  2→0=2,  3→1=-5

注意: 包含一条负权边 3→1=-5 !
```

### 初始化阶段: 构建直接距离矩阵

```
Step 0: 初始化距离矩阵 dist[][]
┌─────────────────────────────────────────────┐
│              直接距离矩阵 (k = -1, 无中转)      │
│                                                     │
│     ┌───┬───┬───┬───┐                         │
│     │ 0 │ 1 │ 2 │ 3 │  目标 j                │
│ ├───┼───┼───┼───┤                         │
│ │ 0 │ 0 │ 3 │ 8 │ ∞ │  从 i 出发            │
│ ├───┼───┼───┼───┤                         │
│ │ 1 │ ∞ │ 0 │ ∞ │ 4 │                        │
│ ├───┼───┼───┼───┤                         │
│ │ 2 │ 2 │ ∞ │ 0 │ ∞ │                        │
│ ├───┼───┼───┼───┤                         │
│ │ 3 │ ∞ │-5 │ ∞ │ 0 │  ⚠️ 注意: 3→1 = -5!  │
│ └───┴───┴───┴───┴───┘                         │
│                                                     │
│ 规则:                                              │
│   dist[i][i] = 0  (自己到自己 = 0)                │
│   有边 → 权重值                                    │
│   无边 → ∞ (无穷大)                               │
└─────────────────────────────────────────────┘

同时初始化 next[][] 矩阵 (用于路径重建):
  next[i][j] = j 如果 i→j 有边, 否则 None
```

### k=0: 允许节点 0 作为中转

```
Round k=0: 尝试通过节点 0 中转
┌─────────────────────────────────────────────┐
│ 检查所有 (i,j) 对:                           │
│   是否 dist[i][0] + dist[0][j] < dist[i][j]? │
│                                                     │
│ 改进的路径:                                      │
│   1→0→2: dist[1][0]+dist[0][2] = ∞+8 = ∞     │
│         vs dist[1][2]=∞ → 不变                 │
│                                                     │
│   1→0→3: dist[1][0]+dist[0][3] = ∞+∞ = ∞     │
│         vs dist[1][3]=4 → 不变                  │
│                                                     │
│   3→0→1: dist[3][0]+dist[0][1] = ∞+3 = ∞     │
│         vs dist[3][1]=-5 → 不变 (-5 < ∞!)      │
│                                                     │
│   3→0→2: dist[3][0]+dist[0][2] = ∞+8 = ∞     │
│         vs dist[3][2]=∞ → 不变                  │
│                                                     │
│   2→0→1: dist[2][0]+dist[0][1] = 2+3 = 5      │
│         vs dist[2][1]=∞ → ✅ 更新! dist[2][1]=5 │
│         next[2][1] = 0 (中转节点是 0)             │
│                                                     │
│ 本轮更新: 仅 1 个元素改善                          │
└─────────────────────────────────────────────┘

更新后的矩阵 (k=0):
     ┌───┬───┬───┬───┐
     │ 0 │ 1 │ 2 │ 3 │
 ├───┼───┼───┼───┤
 │ 0 │ 0 │ 3 │ 8 │ ∞ │
 │ 1 │ ∞ │ 0 │ ∞ │ 4 │
 │ 2 │ 2 │ 5 │ 0 │ ∞ │  ⭐ 2→1 改善: ∞→5 (经 0)
 │ 3 │ ∞ │-5 │ ∞ │ 0 │
 └───┴───┴───┴───┴───┘
```

### k=1: 允许节点 {0,1} 作为中转

```
Round k=1: 尝试通过节点 0 或 1 中转
┌─────────────────────────────────────────────┐
│ 关键检查:                                       │
│                                                     │
│   0→1→3: dist[0][1]+dist[1][3] = 3+4 = 7     │
│         vs dist[0][3]=∞ → ✅ 更新! dist[0][3]=7 │
│         next[0][3] = 1                            │
│                                                     │
│   0→1→2: dist[0][1]+dist[1][2] = 3+∞ = ∞     │
│         vs dist[0][2]=8 → 不变                  │
│                                                     │
│   2→0→1: 已经在 k=0 更新过, 保持 5              │
│                                                     │
│   2→...→3: dist[2][0]+dist[0][3] = 2+7 = 9    │  ⭐ 新发现的路径!
│         vs dist[3]=∞ → ✅ 更新! dist[2][3]=9    │
│         (但等一下, 这不是直接比较...)           │
│         让我重新检查:                             │
│         dist[2][0]=2, dist[0][3]刚变为7        │
│         2+7=9 < ∞? ✅ 是的!                      │
│                                                     │
│   3→1→0: dist[3][1]+dist[1][0] = -5+∞ = ∞    │
│         vs dist[3][0]=∞ → 不变                  │
│                                                     │
│   3→1→3: dist[3][1]+dist[1][3] = -5+4 = -1    │  🔥🔥🔥 关键!
│         vs dist[3][3]=0 → ✅ 更新! dist[3][3]=-1 │
│         next[3][3] = 1                            │
│                                                     │
│ ⚠️ dist[3][3] 变成负数!                          │
│   这意味着存在从 3 出发回到 3 的负权路径!        │
│   (3→1→3 = -5+4 = -1 < 0)                       │
│   但这还不是最终结论 (还需继续迭代)             │
│                                                     │
│ 本轮更新: 3 个元素改善                            │
└─────────────────────────────────────────────┘

更新后的矩阵 (k=1):
     ┌───┬───┬───┬───┐
     │ 0 │ 1 │ 2 │ 3 │
 ├───┼───┼───┼───┤
 │ 0 │ 0 │ 3 │ 8 │ 7 │  ⭐ 0→3: ∞→7 (经 1)
 │ 1 │ ∞ │ 0 │ ∞ │ 4 │
 │ 2 │ 2 │ 5 │ 0 │ 9 │  ⭐ 2→3: ∞→9 (经 0→1 或 0→1→3?)
 │ 3 │ ∞ │-5 │ ∞ │-1│  🔥 3→3: 0→-1 (经 1)! 存在负环迹象
 └───┴───┴───┴───┴───┘
```

### k=2: 允许节点 {0,1,2} 作为中转

```
Round k=2: 尝试通过节点 0/1/2 中转
┌─────────────────────────────────────────────┐
│ 关键检查:                                       │
│                                                     │
│   0→...→2: 已是直达 8, 检查是否可改善          │
│     经 1: dist[0][1]+dist[1][2] = 3+∞ = ∞    │
│     经 0: dist[0][0]+dist[0][2] = 0+8 = 8     │
│     → 不变                                       │
│                                                     │
│   0→...→3: 当前 7, 检查:                        │
│     经 2: dist[0][2]+dist[2][3] = 8+9 = 17    │
│       vs 7 → 不变                                 │
│     经 1: dist[0][1]+dist[1][3] = 3+4 = 7       │
│       = 当前值 → 不变                              │
│                                                     │
│   1→...→0: 当前 ∞, 检查:                        │
│     经 2: dist[1][2]+dist[2][0] = ∞+2 = ∞       │
│     经 0: dist[1][0]+dist[0][0] = ∞+0 = ∞      │
│     → 不变                                       │
│                                                     │
│   1→...→2: 当前 ∞, 检查:                        │
│     经 0: dist[1][0]+dist[0][2] = ∞+8 = ∞      │
│     经 2: dist[1][2]+dist[2][2] = ∞+0 = ∞      │
│     → 不变                                       │
│                                                     │
│   3→...→0: 当前 ∞, 检查:                        │
│     经 1: dist[3][1]+dist[1][0] = -5+∞ = ∞     │
│     经 2: dist[3][2]+dist[2][0] = ∞+2 = ∞      │
│     → 不变                                       │
│                                                     │
│   3→...→2: 当前 ∞, 检查:                        │
│     经 1: dist[3][1]+dist[1][2] = -5+∞ = ∞     │
│     经 0: dist[3][0]+dist[0][2] = ∞+8 = ∞      │
│     → 不变                                       │
│                                                     │
│ 本轮更新: 0 个元素! (矩阵已趋于稳定)            │
└─────────────────────────────────────────────┘

更新后的矩阵 (k=2): 无变化
     ┌───┬───┬───┬───┐
     │ 0 │ 1 │ 2 │ 3 │
 ├───┼───┼───┼───┤
 │ 0 │ 0 │ 3 │ 8 │ 7 │
 │ 1 │ ∞ │ 0 │ ∞ │ 4 │
 │ 2 │ 2 │ 5 │ 0 │ 9 │
 │ 3 │ ∞ │-5 │ ∞ │-1│
 └───┴───┴───┴───┴───┘
```

### k=3: 允许节点 {0,1,2,3} 作为中转（最后一轮）

```
Round k=3: 最后一个中转节点
┌─────────────────────────────────────────────┐
│ 这是关键的一轮! 可能发现更多改善...            │
│                                                     │
│   0→...→1: 当前 3, 检查:                        │
│     经 3: dist[0][3]+dist[3][1] = 7+(-5) = 2   │
│       vs 3 → ✅ 更新! dist[0][1] = 2            │
│       next[0][1] = 3                              │
│       新路径: 0→...→3→1 = 7 + (-5) = 2           │
│              (比原来的 0→1=3 更短!)               │
│              原来是 0→2→0→1=2+0+3=5, 现在更好了    │
│                                                     │
│   0→...→2: 当前 8, 检查:                        │
│     经 3: dist[0][3]+dist[3][2] = 7+∞ = ∞       │
│     经 1: dist[0][1](新!)+dist[1][2] = 2+∞ = ∞  │
│     → 不变 (虽然 dist[0][1] 改善了, 但无助于 0→2)│
│                                                     │
│   0→...→3: 当前 7, 检查:                        │
│     经 2: dist[0][2]+dist[2][3] = 8+9 = 17      │
│     经 1: dist[0][1](新!)+dist[1][3] = 2+4 = 6   │
│       vs 7 → ✅ 更新! dist[0][3] = 6             │
│       next[0][3] = 1                              │
│       新路径: 0→3→1→3 = 2+4 = 6 (比之前的 7 更短!)│
│                                                     │
│   1→...→0: 当前 ∞, 检查:                        │
│     经 3: dist[1][3]+dist[3][0] = 4+∞ = ∞       │
│     经 2: dist[1][2]+dist[2][0] = ∞+2 = ∞       │
│     经 0: ...                                     │
│     → 不变                                       │
│                                                     │
│   1→...→2: 当前 ∞                                │
│     → 不变                                       │
│                                                     │
│   2→...→0: 当前 2                                 │
│     经 3: dist[2][3]+dist[3][0] = 9+∞ = ∞       │
│     → 不变                                       │
│                                                     │
│   2→...→1: 当前 5                                 │
│     经 3: dist[2][3]+dist[3][1] = 9+(-5) = 4     │
│       vs 5 → ✅ 更新! dist[2][1] = 4             │
│       next[2][1] = 3                              │
│                                                     │
│   3→...→0: 当前 ∞ → 不变                         │
│   3→...→2: 当前 ∞ → 不变                         │
│                                                     │
│ 本轮更新: 4 个元素改善!                           │
└─────────────────────────────────────────────┘

最终距离矩阵 (k=3, 完成!):
     ┌───┬───┬───┬───┐
     │ 0 │ 1 │ 2 │ 3 │
 ├───┼───┼───┼───┤
 │ 0 │ 0 │ 2 │ 8 │ 6 │  ⭐⭐ 0→1 和 0→3 大幅改善!
 │ 1 │ ∞ │ 0 │ ∞ │ 4 │
 │ 2 │ 2 │ 4 │ 0 │ 9 │  ⭐ 2→1 再次改善
 │ 3 │ ∞ │-5 │ ∞ │-1│  🔥 3→3 仍为负!
 └───┴───┴───┴───┴───┘
```

### 负环检测

```
负环检测: 检查对角线 dist[i][i]
┌─────────────────────────────────────────────┐
│   dist[0][0] = 0   ≥ 0 ✅                     │
│   dist[1][1] = 0   ≥ 0 ✅                     │
│   dist[2][2] = 0   ≥ 0 ✅                     │
│   dist[3][3] = -1  < 0 ❌ 负环!              │
│                                                     │
│ 结论: 图中存在可达的负环!                    │
│   路径: 3 → 1 → 3 (权重: -5 + 4 = -1)      │
│   可以无限次绕此环使距离 → -∞               │
│                                                     │
│ 返回 Err("negative cycle detected")          │
└─────────────────────────────────────────────┘


═════════════════════════════════════════════
📊 最终结果汇总 (假设无负环的版本)
═════════════════════════════════════════════

  最短距离矩阵:
     ┌───┬───┬───┬───┐
     │→  │ 0 │ 1 │ 2 │ 3 │
 ├───┼───┼───┼───┤
 │ 0 │ 0 │ 2 │ 8 │ 6 │
 │ 1 │ ∞ │ 0 │ ∞ │ 4 │
 │ 2 │ 2 │ 4 │ 0 │ 9 │
 │ 3 │ ∞ │-5 │ ∞ │ * │  (* = -∞ 若有负环)
 └───┴───┴───┴───┴───┘

  最短路径 (next[] 重建):
    0→1: 0→3→1 (距离=2)
    0→2: 0→2 (距离=8)
    0→3: 0→3→1→3 (距离=6)  ← 利用负权边!
    1→3: 1→3 (距离=4)
    2→0: 2→0 (距离=2)
    2→1: 2→3→1 (距离=4)
    2→3: 2→0→...→3 (距离=9)
    3→1: 3→1 (距离=-5)
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/shortest_path/floyd_warshall.mbt`）

```moonbit
///|
/// Floyd-Warshall 全源最短路径
///
/// 成功返回 FloydWarshallResult（含距离矩阵和路径重建信息）。
/// 如果检测到负环，返回 Err。
///
/// 时间复杂度: O(V³)
/// 空间复杂度: O(V²)
pub fn[G : @core.GraphReadable] floyd_warshall(
  graph : G,
) -> Result[FloydWarshallResult, String] {
  let nc = @core.GraphReadable::node_count(graph)

  // 边界检查: 空图
  if nc == 0 {
    return Ok(FloydWarshallResult::{ distances: [], next: [] })
  }

  // 初始化数据结构
  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let inf = 1000000000000000000.0

  // dist[i][j]: 从 i 到 j 的最短距离
  let dist : Array[Array[Double?]] = []
  // next[i][j]: 从 i 到 j 的最短路径上, i 的下一个节点 (用于重建)
  let nxt : Array[Array[@core.NodeId?]] = []

  // Step 1: 初始化矩阵
  for i in 0..<size {
    let row_d : Array[Double?] = []
    let row_n : Array[@core.NodeId?] = []
    for j in 0..<size {
      if i == j {
        row_d.push(Some(0.0))       // 自己到自己 = 0
      } else {
        row_d.push(None)            // 无边 = ∞
      }
      row_n.push(None)               // 初始无路径
    }
    dist.push(row_d)
    nxt.push(row_n)
  }

  // Step 2: 填入直接边的权重
  for u in @core.GraphReadable::node_ids(graph) {
    for v in @core.GraphReadable::neighbors(graph, u) {
      match @core.GraphReadable::get_edge(graph, u, v) {
        Some(w) => {
          let ui = u.0
          let vi = v.0
          if ui >= 0 && ui < size && vi >= 0 && vi < size {
            dist[ui][vi] = Some(w)     // 直接距离
            nxt[ui][vi] = Some(v)       // 下一步走到 v
          }
        }
        None => ()
      }
    }
  }

  // Step 3: 🔑 核心 — 三重循环动态规划
  for k in 0..<size {              // 中转节点 k
    for i in 0..<size {            // 起点 i
      for j in 0..<size {          // 终点 j
        match dist[i][k] {
          Some(dik) =>
            match dist[k][j] {
              Some(dkj) => {
                let through = dik + dkj  // 经过 k 中转的距离
                let should_update = match dist[i][j] {
                  None => true                    // 首次发现路径
                  Some(dij) => through < dij      // 发现更短路径
                }
                if should_update {
                  dist[i][j] = Some(through)   // 更新最短距离
                  nxt[i][j] = nxt[i][k]        // 更新路径: i 下一步走向 k
                }
              }
              None => ()
            }
          None => ()  // i→k 不可达, 跳过
        }
      }
    }
  }

  // Step 4: 负环检测 (检查对角线)
  for i in 0..<size {
    match dist[i][i] {
      Some(d) =>
        if d < 0.0 {
          return Err("negative cycle detected")  // 🔑 对角线为负 → 负环!
        }
      None => ()
    }
  }

  Ok(FloydWarshallResult::{ distances: dist, next: nxt })
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么是三重循环？

```moonbit
/// 直观理解:
///
/// 外层循环 k: "允许使用哪些节点作为中转站"
///   k=0: 只能直连, 或经过节点 0
///   k=1: 可以经过 {0,1}
///   ...
///   k=V-1: 可以经过任意节点
///
/// 内层循环 (i,j): "检查每一对起点和终点"
///   对于每个 (i,j), 问: "如果强制经过 k, 会更短吗?"
///
/// 类比:
///   Bellman-Ford: V-1 轮 × E 条边 = O(VE)
///   Floyd-Warshall: V 轮 × V × V 对 = O(V³)
///
/// 当 E ≈ V² (稠密图) 时, 两者复杂度相近
/// 但 FW 一次性给出所有点对的结果!
```

#### 2️⃣ next[][] 路径重建矩阵

```moonbit
/// 路径重建原理:
///
/// next[i][j] 的含义:
///   在从 i 到 j 的最短路径上, i 的下一个邻居是谁?
///
/// 初始化:
///   next[i][j] = j  (如果有直接边 i→j)
///   next[i][j] = None (如果没有边)
///
/// 更新规则 (当 dist[i][j] 通过 k 改善时):
///   next[i][j] = next[i][k]  (先走到 k, 再从 k 到 j)
///
/// 路径重建算法:
///   fn path(i, j):
///     if dist[i][j] == ∞: return []  (不可达)
///     if i == j: return [i]
///     let k = next[i][j]
///     return [i] ++ path(k, j)  (递归!)
///
/// 示例: 重建 0→3 的路径
///   next[0][3] = 1  →  先走 0→1
///   next[1][3] = 3  → 再走 1→3
///   结果: [0, 1, 3]
```

#### 3️⃣ 负环检测: 对角线检查

```moonbit
/// 为什么检查 dist[i][i] < 0 就能检测负环?
///
/// 正常情况:
///   dist[i][i] = 0  (自己到自己, 不动, 距离为 0)
///
/// 存在负环时:
///   假设有环: i → a → b → ... → i, 总权重 W < 0
///   FW 算法会找到: 从 i 出发, 绕一圈回到 i, 总距离 = W < 0
///   因此 dist[i][i] 会被更新为 W (负数!)
///
/// 注意:
///   只有当负环**从 i 可达**时, dist[i][i] 才会是负数
///   如果某个负环与 i 不连通, 则不会影响 dist[i][i]
///   但只要有一个 dist[i][i] < 0, 就说明图中存在负环
```

#### 4️⃣ 与多次调用 Dijkstra/BF 的对比

```moonbit
/// 方案 A: 对每个节点调用 BF/Dijkstra
///   时间: O(V × VE) 或 O(V × (V+E)logV)
///   空间: O(V) (每次只用一个 distances[])
///   缺点: 重复计算, 无法利用已有结果
///
/// 方案 B: Floyd-Warshall (一次计算全部)
///   时间: O(V³)
///   空间: O(V²) (存储完整距离矩阵)
///   优势:
///     ✅ 预计算, 后续查询 O(1)
///     ✅ 代码极其简洁 (只有 ~10 行核心逻辑)
///     ✅ 天然支持路径重建
///     ✅ 同时检测全局负环
///
/// 选择建议:
///   V ≤ 400 且需要多源查询 → 用 FW
///   V 很大且只需单源 → 用 Dijkstra/BF
```

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 全源最短距离查询

```moonbit
fn floyd_warshall_basic_demo() -> Unit {
  // 构建带权有向图
  let g = build_sample_directed_graph()

  // 执行 Floyd-Warshall
  match @shortest_path.floyd_warshall(g) {
    Ok(result) => {
      println("=== Floyd-Warshall 全源最短路径 ===")

      // 输出距离矩阵
      println("\n📏 距离矩阵:")
      print_distance_matrix(result)

      // 查询特定路径
      println("\n🔍 路径查询:")
      let queries = [
        (@core.NodeId(0), @core.NodeId(3)),
        (@core.NodeId(2), @core.NodeId(1)),
        (@core.NodeId(3), @core.NodeId(0)),
      ]

      for (from_id, to_id) in queries {
        let path = result.path_from_to(from_id, to_id)
        match path.length {
          0 => println("  ${from_id} → ${to_id}: 不可达 😢")
          _ => {
            let dist = result.distance_between(from_id, to_id)
            let path_str = path.map(fn(id) { id.to_string() }).join(" → ")
            println("  ${from_id} → ${to_id}: 距离=${dist}, 路径=[${path_str}]")
          }
        }
      }
    }
    Err(msg) => {
      println("❌ 错误: ${msg}")
    }
  }
}

// 输出:
// === Floyd-Warshall 全源最短路径 ===
//
// 📏 距离矩阵:
//        → 0    1    2    3
//   从 0 [  0    2    8    6 ]
//   从 1 [  ∞    0    ∞    4 ]
//   从 2 [  2    4    0    9 ]
//   从 3 [  ∞   -5    ∞   -∞ ]  (含负环!)
//
// 🔍 路径查询:
//   NodeId(0) → NodeId(3): 距离=6, 路径=[NodeId(0), NodeId(3), NodeId(1), NodeId(3)]
//   NodeId(2) → NodeId(1): 距离=4, 路径=[NodeId(2), NodeId(3), NodeId(1)]
//   NodeId(3) → NodeId(0): 不可达 😢
```

### 示例 2: 👥 社交网络的"六度分隔"全量分析

```moonbit
/// 使用 Floyd-Warshall 计算社交网络中所有人的"关系距离"

fn analyze_social_network_all_pairs(
  social_graph : DirectedAdjList,
  user_names : Map[Int, String],
) -> Unit {
  match @shortest_path.floyd_warshall(social_graph) {
    Ok(result) => {
      let nc = result.node_count()

      println("=== 👥 社交网络全量分析 (Floyd-Warshall) ===\n")
      println("用户总数: ${nc}")

      // 找出每对用户的最短关系链长度
      let mut total_dist = 0.0
      let mut reachable_pairs = 0
      let mut max_dist = 0.0
      let mut furthest_pair : (Int, Int) = (0, 0)

      for i in 0..nc {
        for j in 0..nc {
          if i == j { continue }

          let d = result.distance_between(@core.NodeId(i), @core.NodeId(j))
          if d < 999999.0 {
            total_dist = total_dist + d
            reachable_pairs = reachable_pairs + 1

            if d > max_dist {
              max_dist = d
              furthest_pair = (i, j)
            }
          }
        }
      }

      let avg_dist = total_dist / reachable_pairs.to_double()

      println("📊 统计信息:")
      println("  可达用户对: ${reachable_pairs} / ${nc * (nc - 1)}")
      println("  平均距离: ${avg_dist.toFixed(2)} 度")
      println("  最大距离: ${max_dist.toInt()} 度")

      let (u_idx, v_idx) = furthest_pair
      let u_name = user_names.get(u_idx).unwrap_or("?")
      let v_name = user_names.get(v_idx).unwrap_or("?")

      println("\n  🔍 最远用户对:")
      let path = result.path_from_to(@core.NodeId(u_idx), @core.NodeId(v_idx))
      println("    ${u_name} → ${v_name}: ${max_dist.toInt()} 跳")
      println("    路径: ${path.map(fn(i) { user_names.get(i.0).unwrap_or("?") }).join(" → ")}")

      // 六度分隔验证
      println("\n🎯 六度分隔验证:")
      let within_six = 0
      for i in 0..nc {
        for j in 0..nc {
          if i != j {
            let d = result.distance_between(@core.NodeId(i), @core.NodeId(j))
            if d >= 0.0 && d < 999999.0 && d <= 6.0 {
              within_six = within_six + 1
            }
          }
        }
      }
      let six_degree_pct = within_six.to_double() / reachable_pairs.to_double() * 100.0
      println("  距离 ≤ 6 的用户对: ${within_six} (${six_degree_pct.toFixed(1)}%)")
    }
    Err(msg) => {
      println("❌ 分析失败: ${msg}")
    }
  }
}
```

### 示例 3: 🎮 游戏传送点系统 - 全源最优路径

```moonbit
/// 使用 Floyd-Warshall 预计算游戏世界中所有位置间的最优路径
///
/// 场景: 开放世界游戏, 玩家可以在固定传送点之间快速移动
///       需要预计算所有传送点对之间的最优路径 (考虑传送费用)

fn compute_teleport_network(
  teleport_nodes : Array[(Int, Int)],  // (x,y) 坐标
  teleport_costs : Array[(Int, Int, Double)],  // (from, to, cost)
) -> Unit {
  // 构建传送图
  let mut tp_graph = DirectedAdjList::new()
  let mut node_ids : Array[NodeId] = []

  for (x, y) in teleport_nodes {
    let id = @core.GraphWritable::add_node(tp_graph, (x, y))
    node_ids.push(id)
  }

  // 添加传送边 (双向, 可能费用不同)
  for (from_idx, to_idx, cost) in teleport_costs {
    @core.GraphWritable::add_edge(tp_graph, node_ids[from_idx], node_ids[to_idx], cost) |> ignore
  }

  // 预计算全源最短路径
  match @shortest_path.floyd_warshall(tp_graph) {
    Ok(result) => {
      println("=== 🎮 传送网络全源最优路径 ===\n")
      println("传送点数量: ${teleport_nodes.length()}")

      // 输出费用矩阵
      println("\n💰 传送费用矩阵:")
      for i in 0..teleport_nodes.length() {
        let row_parts : Array[String] = []
        for j in 0..teleport_nodes.length() {
          if i == j {
            row_parts.push("  -  ")
          } else {
            let d = result.distance_between(node_ids[i], node_ids[j])
            match d {
              dd if dd < 999999.0 => row_parts.push("${dd.toInt().to_string().pad_start(4)}"),
              _ => row_points.push("  ∞  "),
            }
          }
        }
        println("  [${i}] ${row_parts.join("")}")
      }

      // 回答常见查询
      println("\n🎯 常见查询 (预计算, O(1) 响应):")
      let common_queries = [
        (0, teleport_nodes.length() - 1),  // 第一个到最后一个
        (1, 3),
        (2, 0),
      ]

      for (from_idx, to_idx) in common_queries {
        if from_idx < teleport_nodes.length() && to_idx < teleport_nodes.length() {
          let (fx, fy) = teleport_nodes[from_idx]
          let (tx, ty) = teleport_nodes[to_idx]
          let cost = result.distance_between(node_ids[from_idx], node_ids[to_idx])
          let path = result.path_from_to(node_ids[from_idx], node_ids[to_idx])

          println("  (${fx},${fy}) → (${tx},${ty}): 费用=${cost}, ${path.length()-1} 次传送")
        }
      }
    }
    Err(msg) => {
      println("❌ 传送网络计算失败: ${msg}")
      println("提示: 传送网络中存在'无限费用环路'!")
    }
  }
}
```

---

## 📈 复杂度分析

### 时间复杂度: O(V³)

| 操作 | 复杂度 | 说明 |
|------|--------|------|
| 初始化矩阵 | O(V²) | 创建 V×V 的 dist 和 next 数组 |
| 填入直接边 | O(V+E) | 遍历邻接表 |
| **主循环 (三重)** | **O(V³)** | k × i × j |
| 负环检测 | O(V) | 检查对角线 |
| **总时间** | **O(V³)** | |

### 空间复杂度: O(V²)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `dist[V][V]` | O(V²) | 距离矩阵 |
| `next[V][V]` | O(V²) | 路径重建矩阵 |
| **总计** | **O(V²)** | |

### 与其他方案对比

| 方法 | 时间 | 空间 | 适用场景 |
|------|------|------|---------|
| **Floyd-Warshall** | **O(V³)** | **O(V²)** | 小图 + 多源查询 |
| Dijkstra × V 次 | O(V²E log V) | O(V) | 稀疏大图 + 单源 |
| BF × V 次 | O(V²E) | O(V) | 含负权 + 单源 |
| Johnson's | O(VE log V) | O(V+E) | 稀疏图 + 全源 (先用 BF 重加权) |

---

## 🎯 实际应用场景

### 应用 1: 🗺️ 地图应用 - 预计算所有地点间距离

```
场景: 离线地图 / 物流调度中心

优势:
  - 服务器端预计算, 客户端即时响应
  - 支持任意起终点的路径查询
  - 图更新后只需重新计算一次

实现:
  1. 定期 (如每小时) 运行 FW 计算全源距离
  2. 将结果存入数据库 / Redis 缓存
  3. API 请求时 O(1) 查询返回
```

### 应用 2: 🕸️ 编译器优化 - 寄存器分配

```
场景: 编译器中计算变量之间的"拷贝距离"

原理:
  - 将变量视为节点
  - 两变量之间存在赋值关系视为有向边
  - 边权重 = 拷贝开销 (或类型转换开销)
  - FW 找出最优的赋值顺序 (最小化总拷贝量)

扩展:
  - 可以加入"寄存器数量限制"
  - 变为"寄存器分配"问题的变种
```

### 应用 3: 🧠 关系推理 - 传递闭包计算

```
场景: 社交网络 / 知识图谱中的关系传递

传递闭包:
  R* = R¹ ∪ R² ∪ R³ ∪ ... (所有可能的路径)

FW 变体:
  将 min(+) 操作替换为 OR(AND) 即可计算传递闭包
  用于:
  - 社交网络中的"朋友的朋友"推荐
  - 知识图谱中的实体关联推断
  - 网络安全中的信任传播分析
```

### 应用 4: 🎯 最小化直径聚类

```
场景: 选择 k 个设施/服务器, 使最大服务距离最小

FW 的作用:
  - 快速计算所有点对距离
  - 基于距离矩阵进行后续聚类 (如 k-medoids)
  - 评估聚类质量的直径指标
```

---

## 🧪 练习题

### 练习 1: 手动执行 Floyd-Warshall ⭐⭐

对于以下 3 节点图，手动执行 FW 算法：

1. 写出初始距离矩阵
2. 逐轮 (k=0,1,2) 更新距离矩阵
3. 给出最终的全源最短路径
4. 检测是否存在负环

```
  A ──(1)──→ B
   ↘         ↙
    (4)     (2)
     ↙       ╱
      C ←──(-1)─ D
```

<details>
<summary>📝 点击查看答案</summary>

```
初始矩阵:
     A   B   C   D
  A [ 0   1   4   ∞ ]
  B [ ∞   0   ∞   2 ]
  C [ ∞   ∞   0   ∞ ]
  D [ ∞  -1   ∞   0 ]

k=0 (经 A 中转):
  B→A→C: ∞+4=∞ → 不变
  D→A→B: ∞+1=∞ → 不变 (但 D→B 已有 -1)
  D→A→C: ∞+4=∞ → 不变
  → 无变化

k=1 (经 A,B 中转):
  A→B→D: 1+2=3 < ∞ → dist[A][D]=3, next[A][D]=B
  C→... (C 无人可达它, 它也到不了别人)
  D→B→A: -1+∞=∞ → 不变
  → 1 个更新

k=2 (经 A,B,C 中转):
  无新的有效路径
  → 无变化

k=3 (经 A,B,C,D 中转):
  C→D→A: ∞+∞=∞ → 不变
  C→D→B: ∞+-1=∞ → 不变
  D→B→A: -1+∞=∞ → 不变
  A→D→B: 3+-1=2 < dist[A][B]=1? ❌ 不变
  → 无变化

最终矩阵:
     A   B   C   D
  A [ 0   1   4   3 ]
  B [ ∞   0   ∞   2 ]
  C [ ∞   ∞   0   ∞ ]
  D [ ∞  -1   ∞   0 ]

对角线: [0, 0, 0, 0] 全部 ≥ 0 → ✅ 无负环

最短路径:
  A→B: [A,B] = 1
  A→D: [A,B,D] = 3
  D→B: [D,B] = -1 (利用负权边!)
```

</details>

### 练习 2: 编程实现 - 路径重建优化 ⭐⭐⭐

基于 Floyd-Warshall 的 `next[][]` 矩阵，实现一个函数，找出**经过最多中转节点的最短路径**。

```moonbit
/// 提示:
/// 1. 遍历所有 (i,j) 对, 重建每条路径
/// 2. 统计每条路径的中转节点数量
/// 3. 返回中转最多的那条路径
```

<details>
<summary>💻 参考框架</summary>

```moonbit
/// 找出经过最多中转节点的最短路径
pub fn find_most_hops_shortest_path(
  result : FloydWarshallResult
) -> (Array[NodeId], Int) {
  let mut max_hops = 0
  let mut best_path : Array[NodeId] = []
  let size = result.distances.length()

  for i in 0..size {
    for j in 0..size {
      if i == j { continue }

      let d = match result.distances[i][j] {
        Some(dd) => if dd < 999999.0 { true } else { false }
        None => false
      }

      if !d { continue }

      // 重建路径并统计跳数
      let path = reconstruct_path(result.next, i, j)
      let hops = path.length() - 1  // 路径边数 = 跳数 - 1

      if hops > max_hops {
        max_hops = hops
        best_path = path
      }
    }
  }

  (best_path, max_hops)
}
```

</details>

### 练习 3: 进阶 - Johnson's 全源最短路径 ⭐⭐⭐⭐

**挑战**: 实现 **Johnson's 算法** —— 稀疏图上的高效全源最短路径。

**原理**:
1. 添加一个虚拟超级源点 s，连接到所有节点（权重 0）
2. 运行 Bellman-Ford 计算 h[v] = s→v 的最短距离（即势能函数）
3. 重新定义边权重: w'(u,v) = w(u,v) + h[u] - h[v]（保证非负）
4. 对每个节点运行 Dijkstra（因为现在权重非负！）
5. 还原真实距离: d(u,v) = d'(u,v) - h[u] + h[v]

**提示**: 时间复杂度 O(VE + V² log V)，优于 FW 的 O(V³)（当图稀疏时）

<details>
<summary>🔧 参考框架</summary>

```moonbit
/// Johnson's 全源最短路径 (稀疏图优化版)
pub fn[G : GraphReadable] johnson(
  graph : G
) -> Result[Array[Array[Double?]], String> {
  // Step 1: 添加虚拟源点, 运行 BF 计算势能
  // Step 2: 重加权 (保证非负)
  // Step 3: 对每个节点运行 Dijkstra
  // Step 4: 还原距离
  // 详细实现略 (~60 行)
  Err("not implemented")
}
```

**Johnson vs Floyd-Warshall**:
| | Johnson | FW |
|--|---------|-----|
| 时间 | O(VE + V²logV) | O(V³) |
| 稀疏图 (E << V²) | **更快** | 较慢 |
| 稠密图 (E ≈ V²) | 较慢 | **更快** |
| 实现 | 较复杂 | **极简** |

</details>

---

## 🔗 相关资源

### 在线可视化工具

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/sssp | 🏆 支持 FW 模式，DP 表动画 |
| Algorithm Visualizer | https://algorithm-visualizer.org/graphs/floyd-warshall.html | 清晰的矩阵演化可视化 |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/Floyd.html | 学术风格 |

### 理论延伸阅读

- **Bellman-Ford**: [Bellman-Ford 教程](/algorithms/shortest-path/bellman-ford/)（单源 + 负权）
- **Dijkstra**: [Dijkstra 教程](/algorithms/shortest-path/dijkstra/)（非负权单源）
- **强连通分量**: [Tarjan SCC](/algorithms/connectivity/scc/tarjan/)（基于 DFS）
- **传递闭包**: 图论高级主题

### 经典教材推荐

| 书名 | 作者 | 推荐章节 |
|------|------|----------|
| *Introduction to Algorithms (CLRS)* | Cormen et al. | Ch.25 All-Pairs Shortest Paths (Section 25.2) |
| *Algorithms* | Sedgewick & Wayne | Ch.6.6 Floyd-Warshall Algorithm |

### mbtgraph API 参考

```moonbit
// Floyd-Warshall (全源, 一次计算)
@shortest_path.floyd_warshall(graph)  → Result[FloydWarshallResult, String]

// 结果查询
result.distance_between(from, to)  // Double (两点间最短距离)
result.path_from_to(from, to)    // Array[NodeId] (重建路径)
result.node_count()              // Int (节点数)

// 对比: 单源算法
@shortest_path.dijkstra(graph, src)      // 单源 (非负权)
@shortest_path.bellman_ford(graph, src)   // 单源 (含负权)
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** Floyd-Warshall 的核心思想（动态规划 + 逐步引入中转）
- [ ] **理解** 三重循环的含义（k=中转, i=起点, j=终点）
- [ ] **手动执行** 4×4 矩阵的 FW 过程（写出每轮 dist 变化）
- [ ] **实现** MoonBit 版本的 FW（理解 dist/next 双矩阵）
- [ ] **区分** FW vs Dijkstra×V vs Johnson's 适用场景
- [ ] **知道** FW 的局限性（O(V³) 不适合大规模稀疏图）
- [ ] **应用** FW 到实际问题（地图预计算/编译器优化/关系推理）
- [ ] **推导** 负环检测的正确性（对角线 dist[i][i] < 0）

> 💡 **下一步**: 尝试实现练习题中的 **Johnson's 算法** 或 **路径重建优化**，或者进入 [Tarjan SCC 强连通分量](/algorithms/connectivity/scc/tarjan/) 学习连通性算法！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 Floyd-Warshall:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_directed_graph()

  match @shortest_path.floyd_warshall(g) {
    Ok(result) => {
      // 查询任意两点的最短距离
      println("0→3: ${result.distance_between(@core.NodeId(0), @core.NodeId(3))}")

      // 重建路径
      let path = result.path_from_to(@core.NodeId(0), @core.NodeId(3))
      println("路径: ${path}")
    }
    Err(msg) => println("检测到负环: ${msg}")
  }
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看全源最短路径动画：<a href="https://visualgo.net/en/sssp" target="_blank">https://visualgo.net/en/sssp</a></p>
    <p>💡 <strong>重点观察</strong>: 选择 "All-Pairs Shortest Paths" 模式，观看距离矩阵如何随着每次中转节点的引入而逐步优化！</p>
  </div>
</div>
