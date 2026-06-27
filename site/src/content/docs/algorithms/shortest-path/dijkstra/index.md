---
title: Dijkstra 最短路径算法
description: 非负权图单源最短路径详解：贪心策略、优先队列动画、松弛操作、MoonBit 实现、GPS导航应用
---

# Dijkstra 最短路径算法

> 🎯 **本节目标**: 掌握 Dijkstra 算法原理、优先队列机制、松弛操作及实际应用
>
> ⏱️ **预计阅读时间**: 35 分钟 | 🎮 **互动演示**: 3 个可运行示例 + 堆状态追踪

## 📖 算法简介

**Dijkstra 算法**（发音: /ˈdaɪkstrə/）是一种用于在**非负权重图**中找到**单源最短路径**的贪心算法。

### 核心思想 💡

想象你是**一名经验丰富的 GPS 导航员**：

```
🚗 GPS 导航类比:

  起点 (S) ●───────────────────────● 终点 (T)
            ╲                     ╱
             ╲   (多条可选路线)   ╱
              ╲                 ╱
               ●───●───●───●───●
                路线1  路线2  路线3

导航员的工作方式:
1. 📍 从当前位置出发，查看所有"相邻路口"
2. 📏 计算到达每个路口的距离（累计路程）
3. ✅ 选择距离最近的路口作为"下一个目的地"
4. 🔄 重复以上步骤，直到到达终点或探索完所有路口

关键规则:
  ⛔ 一旦确定某条路线是"最优的"，就不再修改
  ✅ 每次都选择当前已知的最短路径延伸
```

Dijkstra 就像这位导航员，**每次从"距离起点最近"的未确定节点出发，逐步扩展最短路径树**。

### 为什么叫"Dijkstra"?

| 信息 | 详情 |
|------|------|
| **发明者** | Edsger W. Dijkstra（荷兰计算机科学家） |
| **发表时间** | 1956 年（时年 26 岁！） |
| **论文标题** | "A note on two problems in connexion with graphs" |
| **时间复杂度** | O((V+E) log V)（使用二叉堆） |
| **空间复杂度** | O(V) |
| **前置条件** | ⚠️ **所有边权重必须非负**！ |

### Dijkstra vs 其他最短路径算法

| 算法 | 时间复杂度 | 权重限制 | 特色 |
|------|-----------|---------|------|
| **BFS** | O(V+E) | 无权/等权 | 最简单，层级遍历 |
| **Dijkstra** | **O((V+E) log V)** | **非负权** ⭐ | **实际应用最广** |
| **Bellman-Ford** | O(VE) | 允许负权 | 可检测负权环 |
| **SPFA** | O(kE) 平均 | 允许负权 | Bellman-Ford 优化版 |
| **A\*** | O((V+E) log V) | 非负权 + 启发式 | 带目标导向的 Dijkstra |

### 核心操作：松弛 (Relaxation)

```
🔑 松弛操作是 Dijkstra 的灵魂！

定义:
  对于边 u → v (权重 w):
    如果 dist[u] + w < dist[v]:
      则更新 dist[v] = dist[u] + w
      并记录 parent[v] = u

直观理解:
  ┌────────────────────────────────────┐
  │  当前已知: S → ... → u → v        │
  │            距离 = dist[u] + w     │
  │                                    │
  │  vs                                │
  │                                    │
  │  之前记录: S → ... → v' → v       │
  │            距离 = dist[v] (更远?)  │
  │                                    │
  │  如果新路径更短 → 更新! (松弛成功) │
  └────────────────────────────────────┘

示例:
  已知: dist[B] = 10, 边 B→C 权重=3
  当前: dist[C] = 15 (通过其他路径)

  松弛: dist[B] + 3 = 13 < 15 = dist[C]
  → 更新 dist[C] = 13, parent[C] = B ✅
```

---

## 🎬 交互式动画：Dijkstra 分步执行过程

<div class="viz-preview-card">
  <iframe src="/visualizations/dijkstra/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/dijkstra/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 动画说明

> **配色含义（VisuAlgo 风格）**:

| 颜色 | 含义 |
|------|------|
| **深棕色** | 起点 |
| **橙色** | 当前正在处理的节点 |
| **黄色** | 刚被发现的新节点 |
| **绿色** | 已处理完毕（最短距离已确定） |
| **灰色** | 默认未访问状态 |
| **红色粗线** | 最终最短路径树中的边 |
| **灰色虚线** | 已跳过的边 |

### 预期结果

Dijkstra 从节点 0 开始，按最短距离顺序逐节点确定：

```
访问顺序: [0, 2, 1, 3, 4, 5]
最短距离: dist[0]=0, dist[2]=2, dist[1]=4, dist[3]=4, dist[4]=9, dist[5]=11
最短路径(0→5): [0, 2, 3, 5] (距离=11)
```

---

### 示例图: 带权有向图

考虑以下带权有向图（经典教材示例）：

```
     (2)  1 ──→ 3 (4)
     ↑    ↘   ↓ ↘
    (4)   (5)(1)(3)
     ↓     ↙   ↓  ↘
     0 ←── 2 ──→ 4 ←─┘
          (7)   (2)
```

**边列表（带权重）**:
- 0 → 1 (权重 4)
- 0 → 2 (权重 2)
- 1 → 2 (权重 5)
- 1 → 3 (权重 10)
- 2 → 1 (权重 8)  ⚠️ 注意: 这是反向边!
- 2 → 3 (权重 2)
- 2 → 4 (权重 7)
- 3 → 4 (权重 3)
- 3 → 5 (权重 2)
- 4 → 5 (权重 5)

> 💡 **这是一个非负权图**，非常适合展示 Dijkstra 的完整流程！

### 从节点 0 开始的 Dijkstra 执行过程

> 🎮 **点击每个步骤查看优先队列和距离数组变化**

#### 初始化阶段

```
Step 0: 初始化
┌──────────────────────────────────────────────────────────┐
│ Priority Queue (Min-Heap): [(0.0, NodeId(0))]           │  ← 起点入队，距离=0
│                                                           │
│ Distances[]:                                             │
│   [0] = 0.0    ← 起点到自己的距离为 0                    │
│   [1] = ∞      ← 未知，设为无穷大                         │
│   [2] = ∞                                                │
│   [3] = ∞                                                │
│   [4] = ∞                                                │
│   [5] = ∞                                                │
│                                                           │
│ Parents[]: 全部 None                                     │
│ Visited[]: 全部 false                                    │
└──────────────────────────────────────────────────────────┘

图示状态:
  [0]✓ (dist=0)
   │╲
   │ ╲ (4)  (2)
   ○1       ○2
```

#### 第 1 次提取：处理节点 0

```
Step 1: 从堆中取出最小元素 → NodeId(0), dist=0.0
┌──────────────────────────────────────────────────────────┐
│ Pop: (0.0, NodeId(0))                                   │  ← 取出距离最小的节点
│ Mark NodeId(0) as visited ✓                             │
│                                                           │
│ 🔍 松弛 NodeId(0) 的邻居:                               │
│                                                           │
│   邻居 1: weight=4                                       │
│     new_dist = 0.0 + 4 = 4.0 < ∞? ✅ YES!               │
│     → Update dist[1] = 4.0, parent[1] = 0               │
│     → Push (4.0, NodeId(1)) to PQ                       │
│                                                           │
│   邻居 2: weight=2                                       │
│     new_dist = 0.0 + 2 = 2.0 < ∞? ✅ YES!               │
│     → Update dist[2] = 2.0, parent[2] = 0               │
│     → Push (2.0, NodeId(2)) to PQ                       │
│                                                           │
│ Priority Queue: [(2.0, NodeId(2)), (4.0, NodeId(1))]   │  ← 自动排序!
│                                                           │
│ Distances[]:                                             │
│   [0]=0.0✓  [1]=4.0  [2]=2.0  [3]=∞  [4]=∞  [5]=∞      │
└──────────────────────────────────────────────────────────┘

图示:
  [0]✓ (dist=0) 已完成!
   │╲
   │ ╲(4)   (2)
   ①1      ②2  ← 新发现!
```

#### 第 2 次提取：处理节点 2（距离最小！）

```
Step 2: Pop (2.0, NodeId(2)) — 当前距离最小的未访问节点!
┌──────────────────────────────────────────────────────────┐
│ Mark NodeId(2) as visited ✓                             │
│                                                           │
│ 🔍 松弛 NodeId(2) 的邻居:                               │
│                                                           │
│   邻居 1: weight=8                                       │
│     new_dist = 2.0 + 8 = 10.0 < 4.0? ❌ NO!             │
│     → 保持 dist[1] = 4.0 不变 (已有更短路径)              │
│                                                           │
│   邻居 3: weight=2                                       │
│     new_dist = 2.0 + 2 = 4.0 < ∞? ✅ YES!               │
│     → Update dist[3] = 4.0, parent[3] = 2               │
│     → Push (4.0, NodeId(3)) to PQ                       │
│                                                           │
│   邿居 4: weight=7                                       │
│     new_dist = 2.0 + 7 = 9.0 < ∞? ✅ YES!               │
│     → Update dist[4] = 9.0, parent[4] = 2               │
│     → Push (9.0, NodeId(4)) to PQ                       │
│                                                           │
│ Priority Queue:                                          │
│   [(4.0, NodeId(1)), (4.0, NodeId(3)), (9.0, NodeId(4))]│
│                                                           │
│ Distances[]:                                             │
│   [0]=0.0✓  [1]=4.0  [2]=2.0✓  [3]=4.0  [4]=9.0  [5]=∞ │
└──────────────────────────────────────────────────────────┘

⭐ 关键观察:
  - 节点 2 被选中是因为它的距离 (2.0) 是当前最小的
  - 节点 1 虽然"先被加入队列"，但距离更大，所以后处理
  - 这就是"贪心策略": 总是选择当前最优的!

图示:
  [0]✓      ①1 (dist=4)
   │╲         ↑
   │  ╲(2)    │(8) 失败! 4+8 > 4
   │   ②✓ ──→┘
   │    │╲
   │   (2)(7)
   │    ↓  ↓
   ○3   ○4  ← 新发现!
```

#### 第 3 次提取：处理节点 1 或 3（距离相同，都是 4.0）

假设堆实现返回 NodeId(1)：

```
Step 3: Pop (4.0, NodeId(1))
┌──────────────────────────────────────────────────────────┐
│ Mark NodeId(1) as visited ✓                             │
│                                                           │
│ 🔍 松弛 NodeId(1) 的邻居:                               │
│                                                           │
│   邻居 2: weight=5  (但 NodeId(2) 已 visited!)           │
│     → 跳过 (已确定最短路径)                              │
│                                                           │
│   邇居 3: weight=10                                      │
│     new_dist = 4.0 + 10 = 14.0 < 4.0? ❌ NO!            │
│     → 保持 dist[3] = 4.0 不变                           │
│                                                           │
│ Priority Queue:                                          │
│   [(4.0, NodeId(3)), (9.0, NodeId(4))]                  │
│                                                           │
│ Distances[] (无变化):                                    │
│   [0]=0.0✓  [1]=4.0✓  [2]=2.0✓  [3]=4.0  [4]=9.0  [5]=∞│
└──────────────────────────────────────────────────────────┘

💡 重要性质:
  一旦节点被标记为 visited，其距离就是最终的最短距离！
  这也是 Dijkstra 要求非负权的原因。
```

#### 第 4 次提取：处理节点 3

```
Step 4: Pop (4.0, NodeId(3))
┌──────────────────────────────────────────────────────────┐
│ Mark NodeId(3) as visited ✓                             │
│                                                           │
│ 🔍 松弛 NodeId(3) 的邻居:                               │
│                                                           │
│   邻居 4: weight=3                                       │
│     new_dist = 4.0 + 3 = 7.0 < 9.0? ✅ YES! ⭐         │
│     → Update dist[4] = 7.0 (从 9.0 改善!), parent[4] = 3│
│     → Push (7.0, NodeId(4)) to PQ                       │
│                                                           │
│   邇居 5: weight=2                                       │
│     new_dist = 4.0 + 2 = 6.0 < ∞? ✅ YES!               │
│     → Update dist[5] = 6.0, parent[5] = 3               │
│     → Push (6.0, NodeId(5)) to PQ                       │
│                                                           │
│ Priority Queue (可能有重复):                             │
│   [(6.0, NodeId(5)), (7.0, NodeId(4)), (9.0, NodeId(4))]│
│   ⚠️ NodeId(4) 出现两次! 后面的 9.0 会被跳过            │
│                                                           │
│ Distances[]:                                             │
│   [0]=0.0✓  [1]=4.0✓  [2]=2.0✓  [3]=4.0✓  [4]=7.0  [5]=6.0│
└──────────────────────────────────────────────────────────┘

⭐ 关键事件: 成功松弛了节点 4!
  旧路径: 0→2→4 (距离=9.0)
  新路径: 0→2→3→4 (距离=7.0) ← 更优!
```

#### 第 5 次提取：处理节点 5

```
Step 5: Pop (6.0, NodeId(5))
┌──────────────────────────────────────────────────────────┐
│ Mark NodeId(5) as visited ✓                             │
│                                                           │
│ 🔍 松弛 NodeId(5) 的邻居:                               │
│   (假设没有出边，或者都已 visited)                        │
│   → 无操作                                              │
│                                                           │
│ Priority Queue:                                          │
│   [(7.0, NodeId(4)), (9.0, NodeId(4))]                  │
│                                                           │
│ Distances[] (无变化):                                    │
│   [0]=0.0✓  [1]=4.0✓  [2]=2.0✓  [3]=4.0✓  [4]=7.0  [5]=6.0✓│
└──────────────────────────────────────────────────────────┘
```

#### 第 6 次提取：处理节点 4（最后一个）

```
Step 6: Pop (7.0, NodeId(4)) ← 第一次出现，接受!
┌──────────────────────────────────────────────────────────┐
│ Mark NodeId(4) as visited ✓                             │
│                                                           │
│ 🔍 松弛 NodeId(4) 的邻居:                               │
│   (假设无出边或已处理)                                   │
│                                                           │
│ Priority Queue: [(9.0, NodeId(4))]                      │
│                                                           │
│ 所有节点已 visited!                                      │
└──────────────────────────────────────────────────────────┘

Step 7: Pop (9.0, NodeId(4)) ← 第二次出现，跳过!
┌──────────────────────────────────────────────────────────┐
│ NodeId(4) already visited → SKIP! ❌                    │
│                                                           │
│ Priority Queue: []                                      │  ← 堆空! 算法结束!
└──────────────────────────────────────────────────────────┘
```

### 最终结果汇总

```
✅ Dijkstra 完成!

═════════════════════════════════════════════════
📊 最终最短距离表 (从节点 0 出发)
═════════════════════════════════════════════════

  ┌──────┬────────────┬───────────┬────────────────┐
  │ 目标 │ 最短距离   │ 父节点    │ 最短路径       │
  ├──────┼────────────┼───────────┼────────────────┤
  │  0   │    0.0     │   None    │ [0]            │
  │  1   │    4.0     │   0       │ [0, 1]         │
  │  2   │    2.0     │   0       │ [0, 2]         │
  │  3   │    4.0     │   2       │ [0, 2, 3]      │
  │  4   │    7.0     │   3       │ [0, 2, 3, 4]   │ ⭐
  │  5   │    6.0     │   3       │ [0, 2, 3, 5]   │
  └──────┴────────────┴───────────┴────────────────┘


🌲 最短路径树 (SPT - Shortest Path Tree):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      0 (source)
     / \
    /   \
   1     2
        / \
       3   \
      / \   (unused: 0→1 和 2→4 被更优路径替代)
     4   5

边集 (构成 SPT): {0→1, 0→2, 2→3, 3→4, 3→5}


🔄 松弛历史 (关键更新记录):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Step 1: dist[1] ∞ → 4.0 (via 0)
          dist[2] ∞ → 2.0 (via 0)

  Step 2: dist[3] ∞ → 4.0 (via 2)  ⭐
          dist[4] ∞ → 9.0 (via 2)

  Step 4: dist[4] 9.0 → 7.0 (via 3)  ⭐⭐ 关键改善!
          dist[5] ∞ → 6.0 (via 3)


📈 距离演变时间线:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  节点 1: ∞ ──────────→ 4.0 (Step 1, final)
  节点 2: ∞ ──→ 2.0 (Step 1, final)
  节点 3: ∞ ──────────→ 4.0 (Step 2, final)
  节点 4: ∞ ──→ 9.0 ──→ 7.0 (Step 2 → Step 4, final) ⭐
  节点 5: ∞ ──────────────────→ 6.0 (Step 4, final)
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/shortest_path/dijkstra.mbt`）

```moonbit
///|
/// Dijkstra 单源最短路径
///
/// 从 source 节点出发，计算到所有可达节点的最短距离。
/// 假设所有边权重非负。
///
/// 时间复杂度: O((V + E) log V)
/// 空间复杂度: O(V)
pub fn[G : @core.GraphReadable] dijkstra(
  graph : G,
  source : @core.NodeId,
) -> ShortestPathResult {
  let nc = @core.GraphReadable::node_count(graph)

  // 边界检查：空图或无效源点
  if nc == 0 || !@core.GraphReadable::contains_node(graph, source) {
    return ShortestPathResult::{ distances: [], parents: [] }
  }

  // 初始化数据结构
  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let inf = 1000000000000000000.0  // 表示无穷大

  let distances : Array[Double?] = Array::make(size, None)  // 最短距离
  let parents : Array[@core.NodeId?] = Array::make(size, None)  // 父节点（路径重建用）
  distances[source.0] = Some(0.0)  // 起点距离为 0

  // 初始化优先队列（二叉最小堆）
  let mut pq = heap_new()
  pq = heap_push(pq, 0.0, source)  // 将 (距离, 节点) 入队

  let visited : Array[Bool] = Array::make(size, false)  // 已确定集合

  // 主循环：当优先队列不为空时继续
  while !heap_is_empty(pq) {
    // 取出距离最小的节点
    let (pq_next, top_opt) = heap_pop(pq)
    pq = pq_next

    match top_opt {
      Some((u, _)) => {
        let uid = u.0

        // ⚠️ 关键优化: 如果该节点已经访问过，跳过!
        // （因为可能存在重复入队的情况）
        if visited[uid] {
          continue
        }

        // 标记为已访问（距离已最终确定）
        visited[uid] = true

        // 🔑 核心: 松弛所有邻接边
        for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
          match vw {
            (v, weight) => {
              let vid = v.0

              // 边界检查 + 是否已确定
              if vid < 0 || vid >= size || visited[vid] {
                continue
              }

              // 获取当前节点的距离（如果不可达则跳过）
              let ud = match distances[uid] {
                None => continue
                Some(d) => d
              }

              // ⭐ 松弛操作: 尝试通过 u 到达 v
              let new_dist = ud + weight

              // 判断是否需要更新
              let should_update = match distances[vid] {
                None => true                    // 首次发现
                Some(d) => new_dist < d          // 发现更短路径
              }

              if should_update {
                distances[vid] = Some(new_dist)  // 更新最短距离
                parents[vid] = Some(u)           // 更新父节点
                pq = heap_push(pq, new_dist, v)  // 重新入队（可能重复!）
              }
            }
          }
        }
      }
      None => ()  // 堆空（理论上不会进入这里）
    }
  }

  // 返回完整结果
  ShortestPathResult::{ distances, parents }
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么使用优先队列（最小堆）而非普通队列？

```moonbit
// ❌ 方式 A: 使用普通队列 (FIFO) → 退化为 BFS!
// 问题: 无法保证每次取出的是"距离最近的节点"
// 结果: 可能需要多次遍历才能收敛

// ✅ 方式 B: 使用优先队列 (Min-Heap) → Dijkstra 的核心!
// 优势:
//   - 每次取出距离最小的未确定节点 O(log V)
//   - 保证贪心选择的正确性（非负权前提下）
//   - 支持动态插入（松弛后重新入队）O(log V)

// 堆的操作复杂度:
heap_push(pq, priority, node)   // O(log V) - 插入
heap_pop(pq)                    // O(log V) - 取出最小值
heap_is_empty(pq)               // O(1)   - 判空
```

**为什么不能简单排序后依次处理？**
- 因为在处理过程中会产生新的"候选距离"（通过松弛操作）
- 这些新距离可能比堆中已有的某些元素更小
- 必须使用支持动态插入的数据结构！

#### 2️⃣ 为什么允许重复入队？visited 数组的作用？

```moonbit
/// 场景: 节点 v 被多次松弛
///
/// 示例（来自上面的动画演示）:
///   Step 2: 通过节点 2 松弛节点 4 → dist[4] = 9.0, 入队 (9.0, 4)
///   Step 4: 通过节点 3 再次松弛节点 4 → dist[4] = 7.0, 再次入队 (7.0, 4)
///
/// 此时堆中有两个 (NodeId(4)):
///   - (9.0, NodeId(4))  ← 旧记录，稍后会被跳过
///   - (7.0, NodeId(4))  ← 新记录，会先被取出并标记 visited
///
/// 当第二次遇到 NodeId(4) 时:
if visited[uid] {
  continue  // ⚠️ 直接跳过，避免重复处理!
}

/// 设计权衡:
///   ✅ 优点: 实现简单，不需要"Decrease-Key" 操作（减少堆的实现复杂度）
///   ❌ 缺点: 堆中可能有重复元素，增加空间开销
///
/// 替代方案:
///   - 使用 Fibonacci Heap + Decrease-Key: O(V log V + E) 理论上更快
///   - 但实际中，重复入队的常数因子更小，通常性能更好
```

#### 3️⃣ 为什么要求非负权重？

```
❌ 如果存在负权边，Dijkstra 会出错!

反例:

  0 --(4)--> 1 --(2)--> 2
   \                  /
    ------(-5)-------/

正确答案: 0 → 1 → 2 = 4 + 2 = 6
         0 → 2 = -5 (更短!)

Dijkstra 的执行过程:
  1. 取出 0 (dist=0), 松弛得到: dist[1]=4, dist[2]=-5
  2. 堆中: [(-5, 2), (4, 1)]
  3. 取出 2 (dist=-5), 标记 visited ← ❌ 错误! 2 的距离不是最终的!
  4. 后续无法通过 2 改善 1 的距离 (虽然 0→2→1 = -5+? 可能更短)

原因:
  Dijkstra 的贪心策略基于一个假设:
  "一旦节点被取出（标记 visited），其距离就是最短的"

  这个假设在**非负权图**中成立，但在**含负权边**时不成立!
  因为负权边可能让"已经绕远的路"变得"更近"。

解决方案:
  - 使用 Bellman-Ford 算法 (O(VE)，允许负权)
  - 使用 SPFA 算法 (Bellman-Ford 的优化版)
```

#### 4️⃣ 结果类型的设计与使用

```moonbit
/// ShortestPathResult 提供丰富的查询接口:

pub(all) struct ShortestPathResult {
  distances : Array[Double?],    // 最短距离 (Option 类型，不可达为 None)
  parents : Array[NodeId?],      // 父节点 (用于路径重建)
}

// 查询方法:
result.distance_to(target)        // Double: 返回最短距离 (-1 表示不可达)
result.is_reachable(target)       // Bool: 是否可达
result.reachable_count()          // Int: 可达节点数量
result.path_to(target)            // Array[NodeId]: 重建最短路径

// path_to 内部实现 (反向追溯):
fn path_to(self, target) -> Array[NodeId] {
  let mut cur = target
  let mut path = []

  // 从 target 回溯到 source
  while cur != source {
    path.push(cur)
    cur = self.parents[cur.0].unwrap()  // 获取父节点
  }

  path.push(source)
  path.reverse()  // 反转为正序: [source, ..., target]
}
```

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 查询最短距离和路径

```moonbit
fn dijkstra_basic_demo() -> Unit {
  // 构建带权有向图（与动画演示相同）
  let g = build_sample_weighted_graph()

  // 执行 Dijkstra
  let result = @shortest_path.dijkstra(g, @core.NodeId(0))

  // 输出结果
  println("=== Dijkstra 最短路径结果 ===")
  println("起点: NodeId(0)")
  println("可达节点数: ${result.reachable_count()}")

  // 输出到每个节点的最短距离
  println("\n📏 最短距离:")
  for i in 0..6 {
    let target = @core.NodeId(i)
    let dist = result.distance_to(target)

    match dist {
      d if d >= 0.0 => {
        // 获取路径
        let path = result.path_to(target)
        let path_str = path.map(fn(id) { id.to_string() }).join(" → ")

        println("  到节点 ${i}: 距离=${dist}, 路径=[${path_str}]")
      }
      _ => println("  到节点 ${i}: 不可达 😢")
    }
  }
}

// 输出:
// === Dijkstra 最短路径结果 ===
// 起点: NodeId(0)
// 可达节点数: 6
//
// 📏 最短距离:
//   到节点 0: 距离=0.0, 路径=[NodeId(0)]
//   到节点 1: 距离=4.0, 路径=[NodeId(0), NodeId(1)]
//   到节点 2: 距离=2.0, 路径=[NodeId(0), NodeId(2)]
//   到节点 3: 距离=4.0, 路径=[NodeId(0), NodeId(2), NodeId(3)]
//   到节点 4: 距离=7.0, 路径=[NodeId(0), NodeId(2), NodeId(3), NodeId(4)]
//   到节点 5: 距离=6.0, 路径=[NodeId(0), NodeId(2), NodeId(3), NodeId(5)]
```

### 示例 2: 🗺️ GPS 导航 - 寻找最优路线

```moonbit
/// 使用 Dijkstra 解决道路网中的最短路径问题
///
/// 场景: 在城市道路网中查找两点之间的最短驾驶距离
fn find_shortest_driving_route(
  road_network : DirectedAdjList,
  start_location : String,
  end_location : String,
  location_to_id : Map[String, NodeId],
  id_to_location : Map[NodeId, String]
) -> Unit {
  let start_id = location_to_id.get(start_location).unwrap()
  let end_id = location_to_id.get(end_location).unwrap()

  // 执行 Dijkstra
  let result = @shortest_path.dijkstra(road_network, start_id)

  // 查询最短距离
  let distance = result.distance_to(end_id)

  match distance {
    d if d < 0.0 => {
      println("\n🚫 从 '${start_location}' 到 '${end_location}' 没有可行路线!")
    }
    _ => {
      println("\n🚗 最优驾驶路线:")
      println("   起点: ${start_location}")
      println("   终点: ${end_location}")
      println("   总距离: ${distance} 公里")

      // 重建路径
      let path = result.path_to(end_id)

      println("\n   详细路线 (${path.length()} 个路段):")
      for (step, node_id) in path.indexed() {
        let loc_name = id_to_location.get(node_id).unwrap_or("?")
        let step_dist = result.distance_to(node_id)

        if (step == 0) {
          println("   ${step}. 📍 ${loc_name} (出发, 累计 ${step_dist} km)")
        } else {
          println("   ${step}. ➡️  ${loc_name} (累计 ${step_dist} km)")
        }
      }

      // 给出建议
      if (distance <= 50.0) {
        println("\n   ✅ 距离较近，推荐自驾!")
      } else if (distance <= 200.0) {
        println("\n   💡 中等距离，可考虑高速优先路线")
      } else {
        println("\n   ✈️ 长途旅行，建议检查是否有航班")
      }
    }
  }
}

// 使用示例
let city_roads = build_city_road_network()
find_shortest_driving_route(
  city_roads,
  "Home", "Office",
  location_map, id_map
)

// 可能的输出:
// 🚗 最优驾驶路线:
//    起点: Home
//    终点: Office
//    总距离: 23.5 公里
//
//    详细路线 (5 个路段):
//    0. 📍 Home (出发, 累计 0.0 km)
//    1. ➡️  Station_A (累计 2.3 km)
//    2. ➡️  Highway_Entry (累计 8.7 km)
//    3. ➡️  Exit_15 (累计 18.2 km)
//    4. ➡️  Office (累计 23.5 km)
//
//    ✅ 距离较近，推荐自驾!
```

### 示例 3: 🌐 网络路由 - 找最佳数据传输路径

```moonbit
/// 使用 Dijkstra 解决计算机网络中的路由问题
///
/// 场景: 在网络拓扑图中寻找延迟最低的数据传输路径
///       边权重 = 链路延迟 (ms)
fn find_lowest_latency_path(
  network_topology : DirectedAdjList,
  source_server : String,
  target_server : String,
  server_to_id : Map[String, NodeId],
  id_to_server : Map[NodeId, String]
) -> Unit {
  let src_id = server_to_id.get(source_server).unwrap()
  let tgt_id = server_to_id.get(target_server).unwrap()

  // 执行 Dijkstra（这里"距离"实际上是"延迟"）
  let result = @shortest_path.dijkstra(network_topology, src_id)

  let latency = result.distance_to(tgt_id)

  match latency {
    l if l < 0.0 => {
      println("❌ 从 '${source_server}' 无法到达 '${target_server}'!")
    }
    _ => {
      println("=== 网络路由分析 ===")
      println("源服务器: ${source_server}")
      println("目标服务器: ${target_server}")
      println("最低延迟: ${latency} ms")

      // 重建路径
      let path = result.path_to(tgt_id)

      println("\n数据包转发路径 (经过 ${path.length() - 1} 跳):")
      for (hop, server_id) in path.indexed() {
        let name = id_to_server.get(server_id).unwrap_or("?")
        let hop_latency = result.distance_to(server_id)

        if (hop == 0) {
          println("  Hop ${hop}: 🖥️  ${name} [源端, 发送数据包]")
        } else if (hop == path.length() - 1) {
          println("  Hop ${hop}: 🖥️  ${name} [目的端, 总延迟 ${hop_latency}ms]")
        } else {
          println("  Hop ${hop}: 🖥️  ${name} [路由器, 累计延迟 ${hop_latency}ms]")
        }
      }

      // 服务质量评估
      if (latency < 10.0) {
        println("\n🟢 延迟极低: 适合实时音视频通话!")
      } else if (latency < 50.0) {
        println("\n🟡 延迟较低: 适合在线游戏、网页浏览")
      } else if (latency < 100.0) {
        println("\n🟠 延迟中等: 可接受，但可能影响实时应用")
      } else {
        println("\n🔴 延迟较高: 建议优化路由或升级链路")
      }

      // 可靠性提示
      if (path.length() > 10) {
        println("\n⚠️ 警告: 路径跳数过多 (${path.length() - 1} 跳)，可能影响可靠性")
      }
    }
  }
}

// 使用示例
let network = build_datacenter_network()
find_lowest_latency_path(
  network,
  "Server_Beijing",
  "Server_Shanghai",
  server_map, id_rev_map
)

// 可能的输出:
// === 网络分析 ===
// 源服务器: Server_Beijing
// 目标服务器: Server_Shanghai
// 最低延迟: 28.5 ms
//
// 数据包转发路径 (4 跳):
//   Hop 0: 🖥️  Server_Beijing [源端, 发送数据包]
//   Hop 1: 🖥️  Router_Jinan [路由器, 累计延迟 8.2ms]
//   Hop 2: 🖥️  Router_Nanjing [路由器, 累计延迟 18.7ms]
//   Hop 3: 🖥️  Server_Shanghai [目的端, 总延迟 28.5ms]
//
// 🟢 延迟极低: 适合实时音视频通话!
```

---

## 📈 复杂度分析

### 时间复杂度: O((V + E) log V)

| 操作 | 次数 | 单次复杂度 | 总复杂度 | 说明 |
|------|------|-----------|----------|------|
| 初始化数组 | 1 次 | O(V) | O(V) | 创建 distances/parents/visited |
| 堆插入 (push) | O(E) 次* | O(log V) | O(E log V) | 每次松弛成功都会 push |
| 堆取出 (pop) | O(V) 次 | O(log V) | O(V log V) | 每个节点至少 pop 一次 |
| 邻居遍历 | O(E) 总计 | O(1) 每次 | O(E) | 遍历所有邻接边 |
| **总计** | | **O((V+E) log V)** | |

> \* 实际 push 次数可能超过 E（因为有重复入队），但上界仍是 O(E log V)

### 空间复杂度: O(V)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `distances[]` | O(V) | 最短距离数组 |
| `parents[]` | O(V) | 父节点指针 |
| `visited[]` | O(V) | 访问标记 |
| **优先队列 (堆)** | **O(E)** | 最坏情况: 每条边都触发一次 push |
| **总计** | **O(V + E)** | 通常简称为 O(V)（稀疏图）|

### 与其他实现的对比

| 实现方式 | 时间复杂度 | 空间复杂度 | 适用场景 |
|----------|-----------|-----------|----------|
| **二叉堆** (mbtgraph 采用) | **O((V+E) log V)** | O(V+E) | **通用场景，性能均衡** |
| 斐波那契堆 | O(V log V + E) | O(V) | 稠密图理论最优 |
| 数组 (朴素) | O(V²) | O(V) | 稠密图小规模，无堆开销 |
| Bucket Queue | O(V + E + C) | O(V+C) | 小整数权重 (C=max_weight) |

### 什么时候应该用 Dijkstra？

```
✅ 使用 Dijkstra 的场景:
  - 图的所有边权重 ≥ 0（非负）
  - 需要单源最短路径（一个起点，多个终点）
  - 图的规模适中（V < 10^6）
  - 对实现复杂度和性能都有要求

❌ 不使用 Dijkstra 的场景:
  - 存在负权边 → 用 Bellman-Ford / SPFA
  - 需要全源最短路径 → 用 Floyd-Warshall
  - 有明确的目标点和启发式信息 → 用 A*
  - 无权图（所有边权重相同）→ 用 BFS (更快!)
```

---

## 🎯 实际应用场景

### 应用 1: 🗺️ 地图导航 / GPS 系统

```
问题: 在道路网中找到两点之间的最短/最快路径

边的语义:
  - 权重 = 物理距离 → 最短路径
  - 权重 = 预估时间 → 最快路径
  - 权重 = (距离, 红绿灯, 拥堵) → 综合最优

实际系统优化:
  ✅ 双向 Dijkstra: 同时从起点和终点搜索，相遇即停止
  ✅ A* 算法: 加入欧几里得距离作为启发式函数
  ✅ 分层地图: 高速公路层 + 城市街道层
  ✅ 预计算: 离线计算常用路径对

代表产品:
  - Google Maps, Apple Maps, 高德地图, 百度地图
  - OpenStreetMap + OSRM 开源引擎
```

### 应用 2: 🌐 计算机网络路由

```
问题: 数据包如何从源主机传输到目标主机？（IP 层路由）

协议实例:
  - OSPF (Open Shortest Path First): 内部网关协议
  - IS-IS: 另一种链路状态路由协议
  - RIP: 距离向量协议（类似 Bellman-Ford）

OSPF 的工作原理:
  1. 每个路由器广播自己的链路状态（到邻居的带宽/延迟）
  2. 每个路由器构建完整的网络拓扑图
  3. 运行 Dijkstra 计算到所有其他路由器的最短路径
  4. 根据计算结果生成路由表

边的语义:
  权重 = 带宽倒数 × 延迟（综合指标）

为什么用 Dijkstra 而不是 Bellman-Ford?
  ✅ 收敛速度更快 (O((V+E)log V) vs O(VE))
  ✅ 无环路（链路状态协议天然避免）
  ⚠️ 但需要更多内存存储拓扑信息
```

### 应用 3: 🎮 游戏寻路 AI

```
问题: NPC (非玩家角色) 如何智能地移动到目标位置?

游戏中的应用:
  - RTS 游戏: 单位自动寻路 (StarCraft, Warcraft)
  - RPG 游戏: 跟随玩家 / 逃跑到安全点
  - FPS 游戏: Bot 移动和战术决策

游戏中的特殊需求:
  1. **实时性**: 必须在毫秒级完成计算（不能卡顿）
  2. **动态障碍**: 其他单位/建筑物可能移动
  3. **群体行为**: 多个 NPC 不能全部走同一条路

优化技术:
  - 预计算可视性图 (Visibility Graph)
  - 路径平滑 (Path Smoothing): 避免锯齿状移动
  - 层级寻路 (Hierarchical Pathfinding): 先找区域再找精确路径
  - 流场寻路 (Flow Field): 大规模群体移动

vs A* 算法:
  - Dijkstra: 适用于需要全局信息的场景
  - A*: 适用于有明确目标的场景（更快，利用启发式）
```

### 应用 4: 📱 社交网络的"六度分隔"

```
问题: 在社交网络中，两个用户之间的"关系强度最强"的路径是什么?

边的语义:
  - 权重 = 互动频率的倒数（互动越多，权重越小）
  - 或者: 权重 = 关系亲疏程度（好友=1, 熟人=2, 泛泛之交=10）

查询示例:
  "我和马云之间关系最强的路径是什么?"
  → Dijkstra 可以找到总权重最小（关系最强）的路径

实际应用:
  - LinkedIn 的"您可能认识的人"
  - Facebook 的 Graph Search
  - 微信的朋友推荐

注意:
  这里不是找"最短路径"（跳数最少），
  而是"最优路径"（关系强度最高），
  本质上是最短路径问题的变种!
```

---

## 🧪 练习题

### 练习 1: 手动执行 Dijkstra ⭐⭐

对于以下带权无向图，从节点 A 开始执行 Dijkstra，写出：

1. 每次从堆中取出的节点及其距离
2. 最终的 `dist[]` 数组
3. 从 A 到 F 的最短路径和距离

```
    A
   / \
  4   1
 /     \
B---2---C
|       |\
3       1  \
|       |   5
D---3---E   F
```

<details>
<summary>📝 点击查看答案</summary>

```
初始化:
  dist[A]=0, 其他=∞
  PQ: [(0, A)]

Step 1: Pop A (dist=0)
  松弛: B=4, C=1
  PQ: [(1, C), (4, B)]

Step 2: Pop C (dist=1) ⭐
  松弛: B=min(4, 1+2)=3 ✅ 更新!, E=2, F=6
  PQ: [(2, E), (3, B), (4, B旧), (6, F)]

Step 3: Pop E (dist=2)
  松弛: D=min(∞, 2+3)=5
  PQ: [(3, B), (4, B旧), (5, D), (6, F)]

Step 4: Pop B (dist=3) ← 新值!
  松弛: D=min(5, 3+3)=5 (不变, 但 D 未 visited)
  PQ: [(4, B旧→SKIP), (5, D), (6, F)]

Step 5: Pop B旧 → SKIP (already visited)
  PQ: [(5, D), (6, F)]

Step 6: Pop D (dist=5)
  无有效松弛
  PQ: [(6, F)]

Step 7: Pop F (dist=6)
  完成!


最终结果:
  dist[A]=0, dist[B]=3, dist[C]=1, dist[D]=5, dist[E]=2, dist[F]=6

A → F 的最短路径:
  距离: 6
  路径: [A, C, F]  (直接通过 C!)
  或者: [A, C, E, ?] (不存在比 6 更短的)

验证: A→C(1) + C→F(5) = 6 ✅
```

</details>

### 练习 2: 编程实现 - 限制路径长度 ⭐⭐⭐

基于 Dijkstra 的结果，实现一个函数，找出从起点到终点的**所经节点数不超过 K**的最短路径。

```moonbit
/// 提示:
/// 1. 在 Dijkstra 的基础上增加维度: (distance, hops, node)
/// 2. 优先按 distance 排序，其次按 hops 排序
/// 3. 当 hops > K 时停止扩展
```

<details>
<summary>💻 点击查看解答框架</summary>

```moonbit
/// 受限 Dijkstra: 限制最大跳数
pub fn[G : @core.GraphReadable] dijkstra_limited_hops(
  graph : G,
  source : NodeId,
  max_hops : Int
) -> ShortestPathResult {
  // 类似标准 Dijkstra，但状态变为 (distance, hops, node)
  // 堆中比较: 先比较 distance，再比较 hops

  let mut pq = LimitedHeap::new()
  pq.push(LimitedState::{ dist: 0.0, hops: 0, node: source })

  let mut best_dist : Map[(NodeId, Int), Double] = Map::new()
  best_dist.insert((source, 0), 0.0)

  while !pq.is_empty() {
    let state = pq.pop()

    if state.hops >= max_hops {
      continue  // 达到跳数上限
    }

    for (neighbor, weight) in neighbors_with_weight(graph, state.node) {
      let new_dist = state.dist + weight
      let new_hops = state.hops + 1
      let key = (neighbor, new_hops)

      // 只在改进时更新
      if (!best_dist.contains_key(key) ||
          new_dist < best_dist.get(key).unwrap()) {
        best_dist.insert(key, new_dist)
        pq.push(LimitedState::{
          dist: new_dist,
          hops: new_hops,
          node: neighbor
        })
      }
    }
  }

  // 从 best_dist 中提取每个节点的最优解（不受跳数限制的那个）
  extract_best_result(best_dist)
}
```

</details>

### 练习 3: 进阶 - A* 算法实现 ⭐⭐⭐⭐

**挑战**: 实现 A* 算法（Dijkstra 的启发式增强版），用于网格地图上的最短路径搜索。

**原理**:
- 在 Dijkstra 的基础上加入**启发式函数** h(n)：估计从节点 n 到目标节点的代价
- 优先级 f(n) = g(n) + h(n)，其中 g(n) 是实际代价，h(n) 是估计代价
- 当 h(n) **可采纳**（不高于真实代价）且**一致**时，A* 保证找到最优解

**提示**:
- 对于网格地图，常用曼哈顿距离 |x1-x2| + |y1-y2| 作为启发式函数
- 需要维护 `g_score[]`（实际代价）和 `f_score[]`（优先级）
- 可以提前终止（当目标节点被取出时即可停止）

<details>
<summary>🔧 参考实现框架</summary>

```moonbit
/// A* 寻路算法（网格地图专用）
pub fn a_star_grid(
  grid : Array[Array[Int]],  // 0=通路, 1=墙壁
  start : (Int, Int),
  goal : (Int, Int),
) -> Array[(Int, Int)] {
  // 启发式函数: 曼哈顿距离
  fn heuristic(a : (Int, Int), b : (Int, Int)) -> Int {
    (a.0 - b.0).abs() + (a.1 - b.1).abs()
  }

  // 优先队列: 按 f_score = g_score + heuristic 排序
  let mut open_set = PriorityQueue::new()
  let start_node = coord_to_node(start.0, start.1)
  let goal_node = coord_to_node(goal.0, goal.1)

  let start_h = heuristic(start, goal)
  open_set.push(NodeData::{
    node: start_node,
    f_score: start_h.to_double(),
    g_score: 0.0
  })

  let mut came_from : Map[NodeId, NodeId] = Map::new()
  let mut g_score : Map[NodeId, Double] = Map::new()
  g_score.insert(start_node, 0.0)

  while !open_set.is_empty() {
    let current = open_set.pop().node

    // 提前终止!
    if current == goal_node {
      return reconstruct_path(came_from, current)
    }

    for neighbor in get_neighbors(grid, current) {
      let tentative_g = g_score.get(current).unwrap() +
                        edge_cost(current, neighbor)

      let is_better = match g_score.get(neighbor) {
        None => true,
        Some(g) => tentative_g < g
      }

      if is_better {
        came_from.insert(neighbor, current)
        g_score.insert(neighbor, tentative_g)

        let f = tentative_g + heuristic(node_to_coord(neighbor), goal).to_double()
        open_set.push(NodeData::{ node: neighbor, f_score: f, g_score: tentative_g })
      }
    }
  }

  []  // 无法到达
}

// 使用示例
let grid = [
  [0, 0, 1, 0, 0],
  [0, 0, 1, 0, 0],
  [0, 0, 0, 0, 0],
  [0, 0, 1, 1, 0],
  [0, 0, 0, 0, 0]
]

let path = a_star_grid(grid, (0, 0), (4, 4))
println("A* 路径: ${path}")  // 应该比 DFS/BFS 找到的更直接!
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/sssp | 🏆 业界标杆，支持 Dijkstra/Bellman-Ford 对比 |
| Algorithm Visualizer | https://algorithm-visualizer.org/graphs/dijkstra.html | 清晰的堆状态可视化 |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/Dijkstra.html | 学术风格，支持手动步进 |

### 理论延伸阅读

- **Bellman-Ford 算法**: [Bellman-Ford 教程](/algorithms/shortest-path/bellman-ford/)（允许负权边）
- **A\* 算法**: [A* 教程](/algorithms/shortest-path/a-star/)（启发式搜索）
- **Floyd-Warshall**: [Floyd-Warshall 教程](/algorithms/shortest-path/floyd-warshall/)（全源最短路径）
- **广度优先搜索**: [BFS 教程](/algorithms/traversal/bfs/index/)（无权图特例）
- **深度优先搜索**: [DFS 教程](/algorithms/traversal/dfs/index/)（另一种遍历策略）

### 经典教材推荐

| 书名 | 作者 | 推荐章节 |
|------|------|----------|
| *Introduction to Algorithms (CLRS)* | Cormen et al. | Ch.24 Single-Source Shortest Paths |
| *Algorithms* | Sedgewick & Wayne | Ch.4.4 Shortest Paths |
| 算法导论（中文版） | 殷建平等译 | 第24章 单源最短路径 |

### mbtgraph API 参考

```moonbit
// 核心函数
@shortest_path.dijkstra(graph, source)              // 标准 Dijkstra → ShortestPathResult
@shortest_path.dijkstra_targeted(graph, s, t)        // 提早终止版 → Array[NodeId]

// 结果查询
result.distance_to(target)           // Double (最短距离, -1=不可达)
result.is_reachable(target)          // Bool
result.reachable_count()             // Int
result.path_to(target)               // Array[NodeId] (重建路径)

// 相关算法
@shortest_path.bellman_ford(graph, source)           // 允许负权边
@shortest_path.spfa(graph, source)                   // Bellman-Ford 优化版
@shortest_path.a_star(graph, source, target, heuristic) // 启发式搜索
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** Dijkstra 的核心思想（贪心策略 + 优先队列）
- [ ] **理解** 松弛操作的原理和作用（尝试通过 u 改善到 v 的距离）
- [ ] **手动执行** 小规模图的 Dijkstra 过程（写出堆状态/dist/parent 变化）
- [ ] **实现** MoonBit 版本的 Dijkstra（理解优先队列、visited 跳过、重复入队）
- [ ] **区分** Dijkstra vs BFS vs Bellman-Ford vs A* 的适用场景
- [ ] **知道** Dijkstra 的局限性（非负权要求、单源限制）
- [ ] **分析** Dijkstra 的时间/空间复杂度（O((V+E)log V) / O(V+E)）
- [ ] **应用** Dijkstra 到实际问题（GPS 导航/网络路由/游戏寻路/社交网络）

> 💡 **下一步**: 尝试实现练习题中的**受限 Dijkstra**或 **A* 算法**，或者直接进入 [Kruskal/Prim 最小生成树](/algorithms/mst/kruskal-prim/) 学习另一种重要的图优化算法！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 Dijkstra:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_weighted_graph()
  let result = @shortest_path.dijkstra(g, @core.NodeId(0))

  // 查询到某个节点的最短距离
  let target = @core.NodeId(5)
  println("最短距离: ${result.distance_to(target)}")

  // 重建最短路径
  let path = result.path_to(target)
  println("最短路径: ${path}")
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看 Dijkstra 动画：<a href="https://visualgo.net/en/sssp" target="_blank">https://visualgo.net/en/sssp</a></p>
    <p>💡 <strong>重点观察</strong>: 优先队列是如何自动保持最小值在顶部的，以及"松弛"操作是如何让距离数组逐步优化的。</p>
  </div>
</div>
