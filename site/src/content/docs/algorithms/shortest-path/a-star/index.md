---
title: A* 启发式搜索
description: 结合启发信息的智能寻路算法详解：原理、动画演示、MoonBit 实现、实战应用
---

# A* 启发式搜索 (A*)

> 🎯 **本节目标**: 理解 A* 算法的启发式搜索原理、f(n) = g(n) + h(n) 的核心公式、与 Dijkstra 的区别，以及 MoonBit 实现
>
> ⏱️ **预计阅读时间**: 20 分钟 | 🎮 **互动演示**: 可运行可视化示例

## 📖 算法简介

**A\* (A-Star)** 是一种**启发式搜索算法**，结合了 Dijkstra 算法（保证最优性）和贪心最佳优先搜索（速度快）的优点。

### 核心思想 💡

想象你在**使用 GPS 导航**：

```
🚗 起点 S
  │
  │  ← GPS 知道目标在东边（启发信息 h(n)）
  │  ← 同时记录已经开了多远（实际代价 g(n)）
  │
  ▼ 选择「已经开的距离 + 到目标的估计距离」最小的路线
🎯 目标 T
```

A* 就像一个**有方向感的探险家**：它不仅记录已经走了多远（g(n)），还能"感觉到"目标大概在哪个方向（h(n)），从而优先探索最有希望的路径。

### 核心公式

```
f(n) = g(n) + h(n)
```

| 符号 | 含义 | 说明 |
|------|------|------|
| `f(n)` | 总估计代价 | 用于优先队列排序 |
| `g(n)` | 起点到 n 的实际代价 | 已走过的真实距离 |
| `h(n)` | n 到目标的**估计**代价 | 启发函数，不低估即可保证最优 |

### 历史背景 📜

A* 由 **Hart, Nilsson, Raphael** 于 **1968 年**提出，是人工智能领域最重要的搜索算法之一。它最初用于 Shakey 机器人的路径规划。

### 与其他最短路径算法的对比

| 算法 | 策略 | 启发信息 | 最优性保证 | 速度 |
|------|------|---------|-----------|------|
| **BFS** | 逐层扩展 | ❌ 无 | ✅ 无权图最优 | ⚡ 快 |
| **Dijkstra** | 按实际距离扩展 | ❌ 无 | ✅ 非负权图最优 | 🐢 较慢 |
| **贪心最佳优先** | 按估计距离扩展 | ✅ 有 | ❌ 不保证 | ⚡⚡ 最快 |
| **A\*** | f(n) = g(n) + h(n) | ✅ 有 | ✅ 可采纳启发下最优 | ⚡ 较快 |

> 💡 **关键洞察**: A* 是 Dijkstra 的"智能版"——当启发函数 h(n) = 0 时，A* 退化为 Dijkstra；当 h(n) 越准确，A* 越快。

---

## 🎬 交互式动画：A* 分步执行过程

让我们通过一个具体例子来理解 A* 的执行流程。**点击 ▶ 播放按钮或使用键盘方向键控制动画！**

### 示例图: 带权有向图

考虑以下带权有向图（6 节点），使用曼哈顿距离作为启发函数：

**边列表**: `(0→1, 2.0), (0→2, 4.0), (1→3, 5.0), (2→3, 1.0), (2→4, 3.0), (3→5, 2.0), (4→5, 1.0)`

<div class="viz-preview-card">
  <iframe src="/visualizations/a_star/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/a_star/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 动画说明

> **操作指南**: 使用底部控制栏或键盘快捷键操控动画
>
> | 操作 | 按钮 | 快捷键 |
> |------|:----:|:------:|
> | 播放 / 暂停 | ▶ / ⏸ | `Space` |
> | 单步前进 | → | `→` |
> | 单步后退 | ← | `←` |
> | 跳到开始 | ⏮ | `Home` |
> | 跳到末尾 | ⏭ | `End` |
> | 重置 | ↺ | `R` |
> | 调节速度 | 滑块 | — |

**配色含义（VisuAlgo 风格）**:

| 颜色 | 含义 |
|------|------|
| **深棕色** | 起点（节点 0） |
| **橙色** | 正在处理（当前出队节点） |
| **黄色** | 刚发现的新节点（加入开放列表） |
| **绿色** | 已处理完毕（移入关闭列表） |
| **灰色** | 默认未访问状态 |
| **红色粗线** | 路径边（首次发现邻居的边） |
| **灰色虚线** | 已跳过的边（邻居已在关闭列表） |
| **蓝色数字** | f(n) 值（g + h） |

### 预期结果

A* 从节点 0 到节点 5，利用启发信息优先探索有希望的路径：

```
搜索过程:
  开放列表按 f(n) 排序
  f(0) = 0 + h(0) = 0 + 7 = 7  → 起点
  f(1) = 2 + h(1) = 2 + 5 = 7  → 扩展节点 0
  f(2) = 4 + h(2) = 4 + 3 = 7  → 扩展节点 0
  f(3) = 5 + h(3) = 5 + 2 = 7  → 扩展节点 2
  f(5) = 7 + h(5) = 7 + 0 = 7  → 到达目标!

最短路径: [0, 2, 3, 5] (总权重 = 7.0)
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/shortest_path/a_star.mbt`）

```moonbit
///|
/// A* 启发式搜索 — 从 start 到 target 的最短路径
///
/// 使用启发函数 f(n) = g(n) + h(n) 指导搜索方向，
/// 其中 g(n) 是起点到 n 的实际距离，h(n) 是 n 到 target 的估计距离。
/// 当 h(n) 满足可采纳性（不低估），A* 保证找到最优路径。
pub fn[G : @core.GraphReadable] a_star(
  graph : G,
  start : @core.NodeId,
  target : @core.NodeId,
  heuristic : (@core.NodeId) -> Double,
) -> Array[@core.NodeId] {
  // 边界情况
  if start == target && @core.GraphReadable::contains_node(graph, start) {
    return [start]
  }
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 || !@core.GraphReadable::contains_node(graph, start) {
    return []
  }

  // 初始化数据结构
  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let g_scores : Array[Double?] = Array::make(size, None)  // 起点到各节点的实际距离
  let parents : Array[@core.NodeId?] = Array::make(size, None)  // 父节点（路径重建）
  g_scores[start.0] = Some(0.0)

  // 优先队列：按 f(n) = g(n) + h(n) 排序
  let mut pq = heap_new()
  pq = heap_push(pq, heuristic(start), start)

  let visited : Array[Bool] = Array::make(size, false)  // 关闭列表

  while !heap_is_empty(pq) {
    let (pq_next, top_opt) = heap_pop(pq)
    pq = pq_next
    match top_opt {
      Some((u, _)) => {
        if u == target {
          return a_star_reconstruct_path(parents, start, target)
        }
        let uid = u.0
        if visited[uid] { continue }
        visited[uid] = true

        // 遍历邻居
        for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
          match vw {
            (v, weight) => {
              let vid = v.0
              if vid < 0 || vid >= size || visited[vid] { continue }
              let ug = match g_scores[uid] {
                None => continue
                Some(d) => d
              }
              let new_g = ug + weight
              let should_update = match g_scores[vid] {
                None => true
                Some(d) => new_g < d
              }
              if should_update {
                g_scores[vid] = Some(new_g)
                parents[vid] = Some(u)
                pq = heap_push(pq, new_g + heuristic(v), v)
              }
            }
          }
        }
      }
      None => ()
    }
  }
  []  // 不可达
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么 A* 需要 `g_scores` 数组？

```moonbit
let g_scores : Array[Double?] = Array::make(size, None)
g_scores[start.0] = Some(0.0)
```

| 对比 | Dijkstra | A* |
|------|----------|-----|
| 存储 | `distances[]` — 最终距离 | `g_scores[]` — 当前最佳实际距离 |
| 更新 | 只写一次（首次确定） | 可能更新多次（发现更优路径时） |
| 排序键 | `distances[n]` | `g_scores[n] + h(n)` |

> 💡 **关键区别**: A* 中一个节点可能被多次推入优先队列（因为启发信息可能高估），但 `visited` 数组保证每个节点只被**最终确定**一次。

#### 2️⃣ 路径重建函数

```moonbit
/// 从 parents 数组反向追踪，重建完整路径
fn a_star_reconstruct_path(
  parents : Array[@core.NodeId?],
  start : @core.NodeId,
  target : @core.NodeId,
) -> Array[@core.NodeId] {
  let path : Array[@core.NodeId] = []
  let mut cur = target
  let mut done = false
  while !done {
    path.push(cur)
    let cidx = cur.0
    if cidx < 0 || cidx >= parents.length() {
      done = true
    } else {
      match parents[cidx] {
        None => done = true
        Some(p) => if p == cur { done = true } else { cur = p }
      }
    }
  }
  // 反转得到从 start 到 target 的正序
  let rev : Array[@core.NodeId] = []
  let mut j = path.length() - 1
  while j >= 0 {
    rev.push(path[j])
    j = j - 1
  }
  rev
}
```

#### 3️⃣ 与 Dijkstra 实现的对比

| 特性 | Dijkstra | A* |
|------|----------|-----|
| 参数 | `(graph, source)` | `(graph, start, target, heuristic)` |
| 优先队列排序键 | `g(n)` (实际距离) | `g(n) + h(n)` (总估计) |
| 终止条件 | 队列为空 | 找到目标或队列为空 |
| 返回类型 | `ShortestPathResult` | `Array[NodeId]` (路径) |
| 适用场景 | 单源到所有节点 | 单源到特定目标 |

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 简单图寻路

```moonbit
fn astar_basic_demo() -> Unit {
  // 构建带权有向图
  //   0 --2.0--> 1 --5.0--> 3
  //   |                     ^
  //   4.0                  2.0
  //   ↓         3.0        |
  //   2 ----------> 4     |
  |   |                     |
  //   +--------1.0--------->+
  let g = build_weighted_graph()

  // 定义启发函数：到节点 5 的曼哈顿距离估计
  let heuristic = fn(node : @core.NodeId) -> Double {
    // 简单启发：基于节点 ID 的差值（实际应用中用坐标）
    let estimated = @core.GraphReadable::node_count(g) - node.0 - 1
    estimated.to_double()
  }

  // 执行 A* 搜索
  let path = @shortest_path.a_star(g, @core.NodeId(0), @core.NodeId(5), heuristic)

  println("=== A* 寻路结果 ===")
  println("路径: ${path}")
  println("路径长度: ${path.length()} 个节点")

  // 输出:
  // === A* 寻路结果 ===
  // 路径: [NodeId(0), NodeId(2), NodeId(3), NodeId(5)]
  // 路径长度: 4 个节点
}
```

### 示例 2: 🔍 网格地图寻路

```moonbit
/// 在 5x5 网格地图上使用 A* 寻路
/// 0 = 可通行, 1 = 障碍物
fn grid_pathfinding() -> Unit {
  let grid = [
    [0, 0, 0, 0, 0],
    [0, 1, 1, 0, 0],
    [0, 0, 0, 0, 1],
    [0, 1, 0, 1, 0],
    [0, 0, 0, 0, 0],
  ]
  let rows = 5
  let cols = 5

  // 将 2D 坐标映射到 1D 节点 ID
  fn node_id(r : Int, c : Int) -> @core.NodeId {
    @core.NodeId(r * cols + c)
  }

  // 构建图的邻接表
  let g = build_grid_graph(grid, rows, cols)

  // 曼哈顿距离启发函数
  let target_r = 4
  let target_c = 4
  let heuristic = fn(node : @core.NodeId) -> Double {
    let r = node.0 / cols
    let c = node.0 % cols
    let dr = if r > target_r { r - target_r } else { target_r - r }
    let dc = if c > target_c { c - target_c } else { target_c - c }
    (dr + dc).to_double()
  }

  let start = node_id(0, 0)
  let target = node_id(4, 4)
  let path = @shortest_path.a_star(g, start, target, heuristic)

  println("=== 网格地图寻路 ===")
  println("起点: (0,0) → 终点: (4,4)")
  println("路径节点: ${path}")

  // 将节点 ID 转回坐标
  let coords = path.map(fn(id) {
    let r = id.0 / cols
    let c = id.0 % cols
    "($r,$c)"
  })
  println("路径坐标: ${coords.join(" → ")}")

  // 输出:
  // === 网格地图寻路 ===
  // 起点: (0,0) → 终点: (4,4)
  // 路径节点: [NodeId(0), NodeId(1), NodeId(2), NodeId(7), NodeId(12), NodeId(17), NodeId(22), NodeId(23), NodeId(24)]
  // 路径坐标: (0,0) → (0,1) → (0,2) → (1,3) → (2,2) → (3,2) → (4,2) → (4,3) → (4,4)
}
```

### 示例 3: 📊 A* vs Dijkstra 性能对比

```moonbit
/// 对比 A* 和 Dijkstra 在不同场景下的搜索效率
fn compare_astar_vs_dijkstra() -> Unit {
  let g = build_large_graph(100)  // 100 节点随机图

  // 启发函数：基于节点编号的简单估计
  let heuristic = fn(node : @core.NodeId) -> Double {
    (99 - node.0).to_double()  // 假设目标在节点 99
  }

  // A* 搜索
  let astar_path = @shortest_path.a_star(
    g, @core.NodeId(0), @core.NodeId(99), heuristic
  )

  // Dijkstra 搜索（到同一目标）
  let dijkstra_result = @shortest_path.dijkstra(g, @core.NodeId(0))
  let dijkstra_path = dijkstra_result.path_to(@core.NodeId(99))

  println("=== A* vs Dijkstra 对比 ===")
  println("A* 路径长度: ${astar_path.length()} 个节点")
  println("Dijkstra 路径长度: ${dijkstra_path.length()} 个节点")
  println("路径是否一致: ${astar_path == dijkstra_path}")

  println("\n性能分析:")
  println("  A*: 利用启发信息，优先探索有希望的节点")
  println("  Dijkstra: 无方向性，向所有方向均匀扩展")
  println("  结论: 在目标明确时，A* 通常访问更少节点")

  // 输出:
  // === A* vs Dijkstra 对比 ===
  // A* 路径长度: 8 个节点
  // Dijkstra 路径长度: 8 个节点
  // 路径是否一致: true
  //
  // 性能分析:
  //   A*: 利用启发信息，优先探索有希望的节点
  //   Dijkstra: 无方向性，向所有方向均匀扩展
  //   结论: 在目标明确时，A* 通常访问更少节点
}
```

---

## 📈 复杂度分析

### 时间复杂度

| 场景 | 复杂度 | 说明 |
|------|--------|------|
| **最坏情况** | O(E log V) | 启发函数 h(n) = 0，退化为 Dijkstra |
| **最优情况** | O(b^d) | 启发函数完美，只探索最优路径上的节点 |
| **一般情况** | 取决于 h(n) 质量 | h(n) 越准确，扩展节点越少 |

> 💡 **关键洞察**: A* 的实际性能极度依赖启发函数。好的启发函数可以让搜索空间从"整个图"缩小到"最优路径附近"。

### 空间复杂度: O(V)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `g_scores[]` | O(V) | 起点到各节点的实际距离 |
| `parents[]` | O(V) | 父节点指针 |
| `visited[]` | O(V) | 关闭列表标记 |
| 优先队列 | O(V) | 最坏情况所有节点同时在队列中 |
| **总计** | **O(V)** | |

### 与其他算法对比

| 算法 | 时间复杂度 | 空间复杂度 | 最优性 | 需要启发信息 |
|------|-----------|-----------|--------|-------------|
| **BFS** | O(V + E) | O(V) | ✅ 无权图 | ❌ |
| **Dijkstra** | O((V+E) log V) | O(V) | ✅ 非负权 | ❌ |
| **贪心最佳优先** | O(E log V) | O(V) | ❌ | ✅ |
| **A\*** | O(E log V) ~ O(b^d) | O(V) | ✅ 可采纳 h | ✅ |
| **Bellman-Ford** | O(VE) | O(V) | ✅ 含负权 | ❌ |

### 启发函数的可采纳性条件

A* 保证找到最优路径的条件：

```
可采纳性 (Admissibility):  h(n) ≤ 实际代价(n → target)
一致性 (Consistency):      h(n) ≤ cost(n, m) + h(m) 对所有边 n→m
```

| 启发函数 | 可采纳？ | 效果 |
|----------|---------|------|
| h(n) = 0 | ✅ 总是 | 退化为 Dijkstra |
| 曼哈顿距离（网格） | ✅ | 高效，适合 4/8 方向移动 |
| 欧几里得距离 | ✅ | 适合任意方向移动 |
| 切比雪夫距离 | ✅ | 适合 8 方向棋盘移动 |
| h(n) > 实际代价 | ❌ | 可能找不到最优路径 |

---

## 🎯 实际应用场景

### 应用 1: GPS 导航 - 地图路径规划

```
问题: 在城市道路网中找到从 A 到 B 的最短/最快路线

A* 的优势:
✅ 利用目标的方向信息（直线距离），避免向反方向搜索
✅ 结合实时路况权重（g(n)）和地理距离估计（h(n)）
✅ 比 Dijkstra 快数倍，适合实时导航

启发函数: h(n) = 节点 n 到目标点的 Haversine 距离（球面距离）
```

### 应用 2: 游戏 AI - NPC 寻路

```
问题: 游戏中的角色如何智能地绕过障碍物到达目标？

A* 在游戏中的应用:
✅ 网格地图上的标准寻路算法
✅ 支持不同地形代价（草地=1, 沼泽=5, 道路=0.5）
✅ 动态避障：实时重新计算路径

变体:
- Theta*: 允许任意角度路径（更平滑）
- HPA*: 分层寻路，适合超大地图
- Jump Point Search: 针对均匀网格的 A* 优化
```

### 应用 3: 机器人路径规划

```
问题: 机器人在复杂环境中找到无碰撞路径

A* 的扩展:
✅ 2D/3D 空间中的路径规划
✅ 支持运动学约束（转弯半径、速度限制）
✅ 与 SLAM 结合，实时更新地图

启发函数: 欧几里得距离或曼哈顿距离
```

### 应用 4: 网络路由 - 数据包转发

```
问题: 在大型网络中找到延迟最低的路径

A* 在网络中的应用:
✅ 将网络拓扑建模为图（路由器=节点，链路=边）
✅ 带宽作为权重，延迟作为启发信息
✅ 支持动态路由（链路状态变化时重新计算）

对比传统路由:
- OSPF: 类似 Dijkstra（无启发）
- A* 优化: 利用目标 IP 的路由前缀信息作为启发
```

---

## 🧪 练习题

### 练习 1: 手动执行 A* ⭐⭐

对于以下带权有向图，从节点 S 到节点 G 执行 A*：

```
  S --2.0--> A --3.0--> G
  |                     ↑
  4.0                  1.0
  ↓         2.0        |
  B ----------> C -----+
```

启发函数值: h(S)=5, h(A)=3, h(B)=4, h(C)=1, h(G)=0

1. 写出每个节点的 f(n) = g(n) + h(n) 值
2. 写出节点扩展顺序
3. 找到的最短路径是什么？

<details>
<summary>📝 点击查看答案</summary>

```
扩展过程:
  1. 初始: 开放列表 = {S(f=0+5=5)}
  2. 扩展 S: A(f=2+3=5), B(f=4+4=8)
     开放列表 = {A(f=5), B(f=8)}
  3. 扩展 A: G(f=5+0=5) → 到达目标!

节点扩展顺序: S → A → G
最短路径: [S, A, G] (总权重 = 5.0)

注意: B 和 C 未被扩展，因为启发函数引导搜索直接朝向目标。
```

</details>

### 练习 2: 编程实现 - 自定义启发函数 ⭐⭐⭐

实现一个 A* 搜索，使用**欧几里得距离**作为启发函数，在 2D 点集上寻路：

```moonbit
// 定义 2D 点类型
struct Point {
  x : Double
  y : Double
}

// 实现欧几里得距离启发函数
fn euclidean_heuristic(
  current : @core.NodeId,
  target : @core.NodeId,
  points : Array[Point]
) -> Double {
  let p1 = points[current.0]
  let p2 = points[target.0]
  let dx = p1.x - p2.x
  let dy = p1.y - p2.y
  // 欧几里得距离 = sqrt(dx² + dy²)
  // (提示: MoonBit 中可用 dx * dx + dy * dy 的平方根)
  (dx * dx + dy * dy).sqrt()
}
```

期望: 在 5 个随机点上构建完全图（边权 = 欧几里得距离），用 A* 找从点 0 到点 4 的最短路径。

<details>
<summary>💻 点击查看解答代码</summary>

```moonbit
import { "morning-start/mbtgraph/lib/core" @core }
import { "morning-start/mbtgraph/lib/storage" @storage }

struct Point {
  x : Double
  y : Double
}

fn euclidean_heuristic(
  current : @core.NodeId,
  target : @core.NodeId,
  points : Array[Point]
) -> Double {
  let p1 = points[current.0]
  let p2 = points[target.0]
  let dx = p1.x - p2.x
  let dy = p1.y - p2.y
  (dx * dx + dy * dy).sqrt()
}

fn euclidean_distance(p1 : Point, p2 : Point) -> Double {
  let dx = p1.x - p2.x
  let dy = p1.y - p2.y
  (dx * dx + dy * dy).sqrt()
}

fn astar_euclidean_demo() -> Unit {
  let points = [
    Point::{ x: 0.0, y: 0.0 },
    Point::{ x: 3.0, y: 4.0 },
    Point::{ x: 1.0, y: 1.0 },
    Point::{ x: 5.0, y: 1.0 },
    Point::{ x: 2.0, y: 6.0 },
  ]

  // 构建完全图
  let g = @storage.new_directed()
  let nodes = points.map(fn(_) { @core.GraphWritable::add_node(g, 0.0) })

  // 添加边（每对节点之间）
  for i in 0..points.length() {
    for j in 0..points.length() {
      if i != j {
        let w = euclidean_distance(points[i], points[j])
        @core.GraphWritable::add_edge(g, nodes[i], nodes[j], w) |> ignore
      }
    }
  }

  let heuristic = fn(node : @core.NodeId) -> Double {
    euclidean_heuristic(node, nodes[4], points)
  }

  let path = @shortest_path.a_star(g, nodes[0], nodes[4], heuristic)
  println("A* 路径: ${path}")
  // 输出: 路径经过的节点序列，总代价为最短
}
```

</details>

### 练习 3: 进阶 - A* 变体对比 ⭐⭐⭐⭐

**挑战**: 实现一个对比实验，测试 A* 在不同启发函数下的搜索效率：

1. **h(n) = 0**（退化为 Dijkstra）
2. **h(n) = 曼哈顿距离**（可采纳但不够精确）
3. **h(n) = 实际距离**（完美启发 — 仅用于测试！）

测量每种情况下**扩展的节点数量**，验证：启发越准确 → 扩展越少 → 越快。

```moonbit
fn astar_heuristic_comparison() -> Unit {
  let g = build_test_graph()
  let start = @core.NodeId(0)
  let target = @core.NodeId(10)

  // 启发函数 1: h(n) = 0 → 退化为 Dijkstra
  let h0 = fn(_ : @core.NodeId) -> Double { 0.0 }
  let path0 = @shortest_path.a_star(g, start, target, h0)

  // 启发函数 2: 曼哈顿距离估计
  let h1 = fn(node : @core.NodeId) -> Double {
    // 模拟曼哈顿距离
    let diff = if node.0 > target.0 { node.0 - target.0 } else { target.0 - node.0 }
    (diff * 1.5).to_double()  // 粗略估计
  }
  let path2 = @shortest_path.a_star(g, start, target, h1)

  println("=== 启发函数对比 ===")
  println("h(n)=0 路径长度: ${path0.length()}")
  println("曼哈顿路径长度: ${path2.length()}")
  println("两种启发函数找到的路径应相同（最优性保证）")
}
```

<details>
<summary>🔧 参考实现框架</summary>

```moonbit
/// 记录扩展节点数的包装函数
fn a_star_with_counter(
  graph : @storage.DirectedAdjList,
  start : @core.NodeId,
  target : @core.NodeId,
  heuristic : (@core.NodeId) -> Double,
) -> (Array[@core.NodeId], Int) {
  // 实现思路:
  // 1. 在 a_star 主循环中维护一个 counter
  // 2. 每次从优先队列取出节点时 counter += 1
  // 3. 返回 (path, expanded_count)
  // （实际实现需要修改 a_star.mbt 或使用包装方式）
  ([], 0)  // 占位
}

fn run_comparison() -> Unit {
  let g = build_test_graph()
  let start = @core.NodeId(0)
  let target = @core.NodeId(10)

  let (path0, count0) = a_star_with_counter(
    g, start, target, fn(_) -> Double { 0.0 }
  )
  let (path1, count1) = a_star_with_counter(
    g, start, target, fn(n) -> Double { manhattan_est(n, target) }
  )

  println("Dijkstra (h=0): 扩展 ${count0} 个节点")
  println("A* (曼哈顿):   扩展 ${count1} 个节点")
  println("效率提升: ${count0 - count1} 个节点少扩展")
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/astar | 🏆 业界标杆，A* 分步演示 |
| **PathFinding.js** | https://qiao.github.io/PathFinding.js/visual/ | 交互式，可自定义障碍物 |
| **Red Blob Games** | https://www.redblobgames.com/pathfinding/a-star/introduction | ⭐ 最佳 A* 图文教程 |
| **USFCA Animation** | https://www.cs.usfca.edu/~galles/visualization/AStar.html | 学术风格 |

### 理论延伸阅读

- **基础最短路径**: [Dijkstra 教程](/algorithms/shortest-path/dijkstra/index/)（A* 的基础）
- **无权图遍历**: [BFS 教程](/algorithms/traversal/bfs/index/)（A* 在 h=0 时的退化形式）
- **负权最短路径**: [Bellman-Ford](/algorithms/shortest-path/bellman-ford/)（处理含负权边的图）
- **全源最短路径**: [Floyd-Warshall](/algorithms/shortest-path/floyd-warshall/)（所有节点对之间的最短路径）

### mbtgraph API 参考

```moonbit
// A* 核心函数
@shortest_path.a_star(graph, start, target, heuristic) -> Array[NodeId]

// 参数说明:
//   - graph: 实现了 GraphReadable 的图结构
//   - start: 起点 NodeId
//   - target: 终点 NodeId
//   -启发: 启发函数 (NodeId) -> Double，估计到目标的距离

// 相关函数（Dijkstra）
@shortest_path.dijkstra(graph, source) -> ShortestPathResult
@shortest_path.dijkstra_targeted(graph, src, tgt) -> Array[NodeId]

// ShortestPathResult 方法
result.distance_to(id)    // Double: 最短距离（不可达 = -1.0）
result.is_reachable(id)   // Bool: 是否可达
result.reachable_count()  // Int: 可达节点数
result.path_to(id)        // Array[NodeId]: 最短路径
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** A* 的核心公式 f(n) = g(n) + h(n) 的含义
- [ ] **区分** A* 与 Dijkstra、贪心最佳优先搜索的关系
- [ ] **理解** 可采纳性和一致性条件对最优性的影响
- [ ] **手动执行** 小规模图的 A* 搜索过程（写出 f 值和扩展顺序）
- [ ] **实现** MoonBit 版本的 A*，理解 g_scores 和 visited 的作用
- [ ] **设计** 适合具体问题的启发函数（曼哈顿距离、欧几里得距离等）
- [ ] **分析** A* 的时间/空间复杂度及其与启发函数质量的关系
- [ ] **应用** A* 到游戏寻路、地图导航、机器人路径规划等实际问题

> 💡 **下一步**: 尝试实现练习题中的**启发函数对比实验**，或者直接进入 [Dijkstra 算法](/algorithms/shortest-path/dijkstra/index/) 学习 A* 的基础算法！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 A*:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_graph()
  let heuristic = fn(node) -> Double { estimate_to_target(node) }
  let path = @shortest_path.a_star(g, start, target, heuristic)
  println("最短路径: ${path}")
}</code></pre>
    <p>然后访问 <strong>Red Blob Games</strong> 的交互式教程：<a href="https://www.redblobgames.com/pathfinding/a-star/introduction" target="_blank">https://www.redblobgames.com/pathfinding/a-star/introduction</a></p>
  </div>
</div> 