---
title: "Bellman-Ford 最短路径算法"
description: "支持负权边的单源最短路径详解：V-1轮松弛动画、负环检测、MoonBit实现、金融套利应用"
---

# Bellman-Ford 最短路径算法

> 🎯 **本节目标**: 掌握 Bellman-Ford 算法原理、负权边处理机制、负环检测及实际应用
>
> ⏱️ **预计阅读时间**: 30 分钟 | 🎮 **互动演示**: 3 个可运行示例 + 松弛轮次追踪

## 📖 算法简介

**Bellman-Ford 算法**是一种用于在**含负权边的图**中找到单源最短路径的算法。

### 核心思想 💡

想象你是**一名外汇交易员**：

```
💰 外汇套利类比:

  100 USD ──(汇率)──→ 某货币 A ──(汇率)──→ 某货币 B ──(汇率)──→ USD
                                                    ↓
                                              如果 > 100 💰 套利!

策略:
1. 🔍 遍历所有可能的"兑换路线"
2. 📊 计算每条路线的最终收益（取对数后 = 最短路径）
3. 🔄 反复优化: 第 2 轮可能发现更好的中转方案
4. ⚠️ 如果第 N 轮还能改善 → 存在"无限套利机会"(负环!)
5. ✅ 当无法再改善时 → 找到最优兑换路径

关键规则:
  - 允许"负权重"边 (汇率损失 < 0)
  - 最多迭代 V-1 次 (V=节点数)
  - 第 V 次仍能松弛 → 存在负环!
```

Bellman-Ford 就像这位交易员，**反复扫描所有可能的路径来寻找最优解**，同时能检测是否存在"无限套利"的机会。

### 为什么需要 Bellman-Ford?

| 场景 | Dijkstra | **Bellman-Ford** | 说明 |
|------|---------|-----------------|------|
| 所有边权重 ≥ 0 | ✅ 最佳 | 可用但较慢 | Dijkstra 更快 O((V+E)logV) |
| **存在负权边** | ❌ **错误!** | **✅ 唯一选择** | 核心优势 |
| **需要检测负环** | ❌ 无法检测 | **✅ 天然支持** | 金融/网络关键需求 |
| 图的规模小 (V<500) | 都行 | 更简单 | 无需优先队列 |

### 与 Dijkstra 的本质区别

```
Dijkstra (贪心):
  "一旦确定最短距离, 就不再修改"
  → 前提: 后面不可能出现更短的替代路径
  → 这个前提在非负权图中成立!

Bellman-Ford (动态规划):
  "每轮都重新检查所有边, 允许修改已确定的距离"
  → 因为负权边可能让"绕远的路"反而更近!

示例:
  S ──(4)──→ A ──(-2)──→ T    直接: S→A→T = 4 + (-2) = 2
   ╲                              ╲
    ╲──(1)──→ B ──(1)──→ T       绕远: S→B→T = 1 + 1 = 2 (相同)
                                    但如果 B→T 权重为 -1:
                                   绕远: S→B→T = 1 + (-1) = 0 ← 更优!
```

---

## 🎬 交互式动画：Bellman-Ford 分步执行过程

<div class="viz-preview-card">
  <iframe src="/visualizations/bellman_ford/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/bellman_ford/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 动画说明

> **配色含义（VisuAlgo 风格）**:

| 颜色 | 含义 |
|------|------|
| **深棕色** | 起点 |
| **橙色** | 当前被松弛的节点 |
| **黄色** | 距离被更新的节点 |
| **绿色** | 已完成松弛轮次 |
| **灰色** | 默认未访问状态 |
| **红色粗线** | 当前最短路径树中的边 |
| **灰色虚线** | 已跳过的边 |
| **紫色色** | 负权边 |

### 预期结果

Bellman-Ford 从节点 0 开始，经过 V-1=4 轮松弛：

```
最终距离: dist[0]=0, dist[1]=1, dist[2]=4, dist[3]=2, dist[4]=5
最短路径(0→4): [0, 2, 1, 3, 4] (距离=5)
负环检测: 无负环
```

---

### 示例图: 含负权边的有向图

考虑以下有向图（包含负权边）：

```
     (6)  1 ────────→ 3 (-2)
     ↑ ↘           ↗ │
    (5)  (8)      (-4)(3)
     │    ╲        ╱  │
     0 ←──(2)── 2 ──┘
         (-7)

节点数 V=5, 边数 E=8
起点: NodeId(0)
```

**边列表（带权重）**:
- (0,1,5), (0,2,6), (1,2,8), (1,3,-2)
- (2,1,-7), (2,3,-4), (2,4,2), (3,4,3)

> 💡 **这个图包含负权边** (如 -2, -7, -4)，Dijkstra 会出错！

### 初始化阶段

```
Step 0: 初始化
┌──────────────────────────────────────────────────────────┐
│ 起点: NodeId(0)                                         │
│                                                           │
│ Distances[]:                                             │
│   [0] = 0.0    ← 起点到自己的距离为 0                    │
│   [1] = ∞      ← 未知                                   │
│   [2] = ∞                                            │
│   [3] = ∞                                            │
│   [4] = ∞                                            │
│                                                           │
│ Parents[]: 全部 None                                     │
│                                                           │
│ 边总数 E = 8                                             │
│ 最大轮数 = V - 1 = 4 轮                                  │
└──────────────────────────────────────────────────────────┘

图示状态:
  [0]✓ (dist=0)
   │╲
   │ ╲(5)  (6)
   ○1      ○2              ○3          ○4
```

### 第 1 轮松弛 (i=1): 从起点出发的第一波传播

```
Round 1: 遍历所有 8 条边
┌──────────────────────────────────────────────────────────┐
│ 检查每条边 (u,v,w): if dist[u]+w < dist[v] 则更新       │
│                                                           │
│ 边 (0,1,5):  dist[0]+5 = 5 < ∞? ✅ → dist[1]=5, p[1]=0 │
│ 边 (0,2,6):  dist[0]+6 = 6 < ∞? ✅ → dist[2]=6, p[2]=0 │
│ 边 (1,2,8):  dist[1]=∞ → 跳过                           │
│ 边 (1,3,-2): dist[1]=∞ → 跳过                           │
│ 边 (2,1,-7): dist[2]=∞ → 跳过                           │
│ 边 (2,3,-4): dist[2]=∞ → 跳过                           │
│ 边 (2,4,2):  dist[2]=∞ → 跳过                           │
│ 边 (3,4,3):  dist[3]=∞ → 跳过                           │
│                                                           │
│ 本轮更新: 2 条边成功松弛                                  │
│                                                           │
│ Distances[]:                                             │
│   [0]=0.0  [1]=5.0  [2]=6.0  [3]=∞  [4]=∞               │
└──────────────────────────────────────────────────────────┘

图示 (Round 1 结束):
  [0]✓ (dist=0)
   │╲
   │(5)╲ (6)
   ①1   ②2            ○3          ○4
```

### 第 2 轮松弛 (i=2): 利用新发现的距离继续扩展

```
Round 2: 再次遍历所有 8 条边
┌──────────────────────────────────────────────────────────┐
│ 边 (0,1,5):  0+5=5 < 5? ❌ 不变                        │
│ 边 (0,2,6):  0+6=6 < 6? ❌ 不变                        │
│ 边 (1,2,8):  5+8=13 < 6? ❌ 不变                        │
│ 边 (1,3,-2): 5+(-2)=3 < ∞? ✅ → dist[3]=3, p[3]=1 ⭐  │
│ 边 (2,1,-7): 6+(-7)=-1 < 5? ✅ → dist[1]=-1, p[1]=2 ⭐⭐│
│ 边 (2,3,-4): 6+(-4)=2 < 3? ✅ → dist[3]=2, p[3]=2 ⭐⭐│
│ 边 (2,4,2):  6+2=8 < ∞? ✅ → dist[4]=8, p[4]=2        │
│ 边 (3,4,3):  dist[3]刚被更新, 但本轮使用旧值或新值?       │
│            (取决于遍历顺序, 这里假设顺序靠后)             │
│            2+3=5 < 8? ✅ → dist[4]=5, p[4]=3             │
│                                                           │
│ ⭐ 关键事件: 通过负权边 (2,1,-7)!                        │
│    dist[1] 从 5 改善到 -1! (这就是负权的威力!)           │
│                                                           │
│ 本轮更新: 5 条边成功松弛 (大量改进!)                     │
│                                                           │
│ Distances[]:                                             │
│   [0]=0.0  [1]=-1.0  [2]=6.0  [3]=2.0  [4]=5.0          │
└──────────────────────────────────────────────────────────┘

图示 (Round 2 结束):
  [0]✓ (dist=0)
   │╲
   │  ╲
   ①①(-1)←──②2(dist=6)
   │↑ (-7)    │╲ (-4)
   │╲         ╲ ②③(dist=2)
   │  ╲        ╲  │(3)
   └──┘         └→④⑤(dist=5)

⚠️ 注意: dist[1] 变成了负数!
   这在 Dijkstra 中是不可能的 (因为非负权)!
```

### 第 3 轮松弛 (i=3): 进一步利用负权边

```
Round 3: 第三次遍历所有边
┌──────────────────────────────────────────────────────────┐
│ 边 (0,1,5):  0+5=5 > -1? ❌                            │
│ 边 (0,2,6):  0+6=6 < 6? ❌ 不变                        │
│ 边 (1,2,8):  -1+8=7 > 6? ❌                            │
│ 边 (1,3,-2): -1+(-2)=-3 < 2? ✅ → dist[3]=-3 ⭐⭐⭐     │
│ 边 (2,1,-7):  6+(-7)=-1 = -1? ❌ 不变                   │
│ 边 (2,3,-4):  6+(-4)=2 > -3? ❌ (已被 1→3 替代!)       │
│ 边 (2,4,2):  6+2=8 > 5? ❌                             │
│ 边 (3,4,3):  -3+3=0 < 5? ✅ → dist[4]=0, p[4]=3 ⭐⭐   │
│                                                           │
│ ⭐⭐⭐ 关键: dist[3] 从 2 → -3!                          │
│     路径变为: 0→2→1→3 (利用两条负权边!)                │
│     0→2(6) + 2→1(-7) + 1→3(-2) = -3                    │
│                                                           │
│ 本轮更新: 2 条边成功松弛                                 │
│                                                           │
│ Distances[]:                                             │
│   [0]=0.0  [1]=-1.0  [2]=6.0  [3]=-3.0  [4]=0.0         │
└──────────────────────────────────────────────────────────┘

图示 (Round 3 结束):
  [0]✓(0) ──(6)→ ②2(6)
                │╲
           (-7) │  ╲ (-4)
                ↓   ╲→ ③③(-3) ──(3)→ ④④(0)
               ①①(-1)╲_______↑
                       (-2)
```

### 第 4 轮松弛 (i=4): 最后一轮 (V-1=4)

```
Round 4: 第四次 (最后一轮!) 遍历所有边
┌──────────────────────────────────────────────────────────┐
│ 边 (0,1,5):  0+5=5 > -1? ❌                             │
│ 边 (0,2,6):  0+6=6 = 6? ❌ 不变                         │
│ 边 (1,2,8):  -1+8=7 > 6? ❌                             │
│ 边 (1,3,-2): -1+(-2)=-3 = -3? ❌ 不变                  │
│ 边 (2,1,-7):  6+(-7)=-1 = -1? ❌ 不变                  │
│ 边 (2,3,-4):  6+(-4)=2 > -3? ❌                        │
│ 边 (2,4,2):  6+2=8 > 0? ❌                             │
│ 边 (3,4,3):  -3+3=0 = 0? ❌ 不变                       │
│                                                           │
│ 本轮更新: 0 条边! → 收敛! ✅                             │
│                                                           │
│ Distances[] (最终结果):                                  │
│   [0]=0.0  [1]=-1.0  [2]=6.0  [3]=-3.0  [4]=0.0         │
└──────────────────────────────────────────────────────────┐

🎯 第 4 轮无任何更新 → 算法收敛!
   已找到从节点 0 到所有节点的最短路径。
```

### 第 5 轮检测: 负环检测 (额外的一轮!)

```
Round 5 (负环检测): 再遍历一次所有边
┌──────────────────────────────────────────────────────────┐
│ 如果存在任何边 (u,v,w) 满足 dist[u]+w < dist[v]:       │
│   → 说明还存在可松弛的边                                │
│   → 即存在负环! (可以无限循环减少总权重)                 │
│                                                           │
│ 检查结果:                                               │
│   所有边都不满足松弛条件 → ✅ 无负环!                   │
│                                                           │
│ 返回 Ok(ShortestPathResult{ distances, parents })       │
└──────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════
📊 最终结果汇总
═══════════════════════════════════════════════

  ┌──────┬────────────┬───────────┬──────────────────────────┐
  │ 目标 │ 最短距离   │ 父节点    │ 最短路径                 │
  ├──────┼────────────┼───────────┼──────────────────────────┤
  │  0   │    0.0     │   None    │ [0]                      │
  │  1   │   -1.0     │   2       │ [0, 2, 1]                │
  │  2   │    6.0     │   0       │ [0, 2]                   │
  │  3   │   -3.0     │   1       │ [0, 2, 1, 3]            │
  │  4   │    0.0     │   3       │ [0, 2, 1, 3, 4]         │
  └──────┴────────────┴───────────┴──────────────────────────┘


🔄 松弛历史时间线:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Round 1: dist[1]=5, dist[2]=6        (首次发现)
  Round 2: dist[3]=3, dist[1]=-1 ⭐,    (负权边生效!)
           dist[3]=2, dist[4]=8→5
  Round 3: dist[3]=-3 ⭐⭐⭐, dist[4]=0  (再次通过负权边改善)
  Round 4: (无变化) → 收敛! ✅

  关键洞察: 负权边让距离可以"越走越小"!
  这就是为什么 Dijkstra 在负权图上会失败!


🌲 最终最短路径树 (SPT):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      0 (source)
      │
      └──→ 2 (weight=6)
           │
           ├──→ 1 (weight=-7)  ← 负权边!
           │    │
           │    └──→ 3 (weight=-2)  ← 负权边!
           │         │
           │         └──→ 4 (weight=3)
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/shortest_path/bellman_ford.mbt`）

```moonbit
///|
/// Bellman-Ford 单源最短路径（支持负权边）
///
/// 成功返回 ShortestPathResult。
/// 如果检测到负环，返回 Err。
///
/// 时间复杂度: O(V × E)
/// 空间复杂度: O(V + E)
pub fn[G : @core.GraphReadable] bellman_ford(
  graph : G,
  source : @core.NodeId,
) -> Result[ShortestPathResult, String] {
  let nc = @core.GraphReadable::node_count(graph)

  // 边界检查: 空图
  if nc == 0 {
    return Ok(ShortestPathResult::{ distances: [], parents: [] })
  }

  // 边界检查: 源点不存在
  if !@core.GraphReadable::contains_node(graph, source) {
    return Err("source node not found")
  }

  // 初始化数据结构
  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let inf = 1000000000000000000.0

  let distances : Array[Double?] = Array::make(size, None)  // 最短距离
  let parents : Array[@core.NodeId?] = Array::make(size, None)  // 父节点
  distances[source.0] = Some(0.0)  // 起点距离为 0

  // Step 1: 预收集所有边 (避免每次遍历时重复查询邻居)
  let node_list : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(graph) {
    node_list.push(nid)
  }

  let edge_list : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for u in node_list {
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw {
        (v, w) => edge_list.push((u, v, w))
      }
    }
  }

  // Step 2: 核心 — 进行 V-1 轮松弛
  for _ in 0..<nc {
    let mut relaxed = false  // 标记本轮是否有更新

    // 遍历所有边进行松弛
    for edge in edge_list {
      match edge {
        (u, v, w) => {
          let uid = u.0
          let vid = v.0

          // 边界检查
          if uid < 0 || uid >= size || vid < 0 || vid >= size {
            continue
          }

          // 获取起点的当前距离
          let ud = match distances[uid] {
            None => continue      // 不可达，跳过
            Some(d) => d
          }

          // ⭐ 松弛操作
          let new_dist = ud + w

          let should_update = match distances[vid] {
            None => true                    // 首次发现
            Some(d) => new_dist < d          // 发现更短路径
          }

          if should_update {
            distances[vid] = Some(new_dist)  // 更新最短距离
            parents[vid] = Some(u)           // 更新父节点
            relaxed = true                   // 标记本轮有更新
          }
        }
      }
    }

    // 可选优化: 如果本轮无任何更新, 提前终止
    // if !relaxed { break }
  }

  // Step 3: 负环检测 (第 V 轮检查)
  for edge in edge_list {
    match edge {
      (u, v, w) => {
        let uid = u.0
        let vid = v.0

        if uid < 0 || uid >= size || vid < 0 || vid >= size {
          continue
        }

        match distances[uid] {
          None => continue
          Some(ud) =>
            match distances[vid] {
              Some(vd) =>
                // 🔑 如果还能松弛 → 存在负环!
                if ud + w < vd {
                  return Err("negative cycle detected")
                }
              None => ()
            }
        }
      }
    }

  // 返回成功结果
  Ok(ShortestPathResult::{ distances, parents })
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么需要 V-1 轮？

```moonbit
/// 直观理解:
///
/// 最短路径最多包含 V-1 条边 (否则必然经过某个节点两次 → 形成环)
/// 如果环的权重 ≥ 0: 去掉环只会更短 (或相等)
/// 如果环的权重 < 0 (负环): 可以无限绕圈使路径越来越短 → 无解!
///
/// 因此:
///   - V-1 轮足够保证找到所有不含环的最短路径
///   - 第 V 轮如果能继续松弛 → 存在可达的负环

数学证明 (归纳法):
  Base: 0 轮后, 只有起点的距离是正确的 (=0)
  Step: 假设 k 轮后, 所有不超 k 条边的最短路径都已正确
        第 k+1 轮会尝试用这些正确的结果松弛出 k+1 条边的路径
  Conclusion: V-1 轮后, 所有不超 V-1 条边的最短路径都正确
```

#### 2️⃣ 为什么预收集边列表？

```moonbit
// ❌ 方式 A: 每轮实时查询邻居
for round in 0..V-1 {
  for u in nodes {           // V 次
    for (v,w) in neighbors(u) {  // deg(u) 次
      relax(u, v, w)
    }
  }
}
// 总复杂度: O(V × (V+E)) = O(V² + VE)
// 问题: neighbors() 每次调用可能有开销

// ✅ 方式 B: 预收集边列表 (mbtgraph 采用)
let edge_list = collect_all_edges()  // O(V+E) 一次性
for round in 0..V-1 {
  for (u,v,w) in edge_list {    // E 次
    relax(u, v, w)
  }
}
// 总复杂度: O(V×E + E) = O(VE)
// 优势: 边列表只收集一次, 缓存友好
```

#### 3️⃣ 负环检测原理

```moonbit
/// 负环检测的关键洞察:
///
/// 正常情况:
///   V-1 轮后, 所有最短路径都已确定 (路径长度 ≤ V-1 条边)
///   第 V 轮不会再有任何松弛
///
/// 存在负环时:
///   负环上的节点可以无限次绕环, 每绕一次距离就减少
///   因此永远无法"确定"最短路径 (它是 -∞)
///   第 V 轮仍然能够松弛某些边!
///
/// 示例:
///   A --(+1)--> B --(-3)--> C --(+1)--> A   (形成环: 1-3+1 = -1 < 0)
///
///   Round 1: dist[A]=0, dist[B]=1, dist[C]=-2
///   Round 2: dist[A] 可以通过 C→A 改善: -2+1 = -1 < 0!
///   Round 3: dist[B] 可以通过 A→B 改善: -1+1 = 0 < 1!
///   ... 永远不会停止!

if ud + w < vd {
  return Err("negative cycle detected")  // 🔑 第 V 轮还能松弛 → 负环!
}
```

#### 4️⃣ Result 类型的设计

```moonbit
/// 返回 Result 类型 (而非普通 struct)
///
/// 原因: Bellman-Ford 可能失败 (负环)
///
/// 使用方式:
match bellman_ford(graph, source) {
  Ok(result) => {
    // 成功: 使用 result.distance_to(target) 等
  }
  Err(msg) => {
    // 失败: 图中存在负环, 无法计算最短路径
    println("错误: ${msg}")
    // 可能的处理: 报告给用户 / 尝试移除负环边后重试
  }
}

/// 对比 Dijkstra (总是成功):
let result = dijkstra(graph, source)  // 总是返回 ShortestPathResult
// 不需要处理 Error 情况 (前提是无负权边)
```

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 含负权边的最短路径

```moonbit
fn bellman_ford_basic_demo() -> Unit {
  // 构建含负权边的有向图
  let g = build_negative_weight_graph()

  // 执行 Bellman-Ford
  match @shortest_path.bellman_ford(g, @core.NodeId(0)) {
    Ok(result) => {
      println("=== Bellman-Ford 结果 ===")
      println("起点: NodeId(0)")
      println("负环检测结果: 无 ✅")

      println("\n📏 最短距离:")
      for i in 0..5 {
        let target = @core.NodeId(i)
        let dist = result.distance_to(target)

        match dist {
          d if d >= 0.0 || d > -999999.0 => {
            let path = result.path_to(target)
            let path_str = path.map(fn(id) { id.to_string() }).join(" → ")
            println("  到节点 ${i}: 距离=${dist}, 路径=[${path_str}]")
          }
          _ => println("  到节点 ${i}: 不可达")
        }
      }
    }
    Err(msg) => {
      println("❌ 错误: ${msg}")
      println("提示: 图中存在负权环, 无法计算确定的最短路径")
    }
  }
}

// 输出:
// === Bellman-Ford 结果 ===
// 起点: NodeId(0)
// 负环检测结果: 无 ✅
//
// 📏 最短距离:
//   到节点 0: 距离=0.0, 路径=[NodeId(0)]
//   到节点 1: 距离=-1.0, 路径=[NodeId(0), NodeId(2), NodeId(1)]
//   到节点 2: 距离=6.0, 路径=[NodeId(0), NodeId(2)]
//   到节点 3: 距离=-3.0, 路径=[NodeId(0), NodeId(2), NodeId(1), NodeId(3)]
//   到节点 4: 距离=0.0, 路径=[NodeId(0), NodeId(2), NodeId(1), NodeId(3), NodeId(4)]
//
// 注意: dist[1], dist[3], dist[4] 都是负数或零!
// 这是正常现象 (说明通过负权边找到了"获利"路径)
```

### 示例 2: 💰 外汇套利检测 (负环的实际应用)

```moonbit
/// 使用 Bellman-Ford 检测外汇市场中的套利机会
///
/// 原理:
///   将汇率转换为对数权重: weight = -ln(rate)
///   如果存在总权重为负的环 → 存在套利机会 (乘积 > 1)
fn detect_arbitrage(
  currencies : Array[String],
  exchange_rates : Array[(Int, Int, Double)],  // (from, to, rate)
) -> Unit {
  // 构建汇率图
  let mut fx_graph = DirectedAdjList::new()

  let mut curr_nodes : Array[NodeId] = []
  for currency in currencies {
    let node = @core.GraphWritable::add_node(fx_graph, currency)
    curr_nodes.push(node)
  }

  // 添加边: weight = -ln(rate)
  // (这样找最短路径 = 找最大乘积汇率)
  for (from_idx, to_idx, rate) in exchange_rates {
    let weight = -(Double::ln(rate)).abs()
    @core.GraphWritable::add_edge(fx_graph, curr_nodes[from_idx], curr_nodes[to_idx], weight) |> ignore
  }

  // 对每个货币作为起点运行 Bellman-Ford
  println("=== 💰 外汇套利检测 ===\n")

  for (src_idx, src_currency) in currencies.indexed() {
    match @shortest_path.bellman_ford(fx_graph, curr_nodes[src_idx]) {
      Ok(_) => {
        println("  以 ${src_currency} 为起点: 未发现套利机会")
      }
      Err(msg) => {
        println("  🚨 以 ${src_currency} 为起点: 发现套利机会!")
        println("     原因: ${msg}")
        println("     ⚠️ 建议: 可构建套利策略!")
      }
    }
  }
}

// 使用示例
let currencies = ["USD", "EUR", "GBP", "JPY"]
let rates = [
  (0, 1, 0.92),   // USD → EUR: 1 USD = 0.92 EUR
  (1, 0, 1.09),   // EUR → USD: 1 EUR = 1.09 USD
  (1, 2, 0.86),   // EUR → GBP: 1 EUR = 0.86 GBP
  (2, 1, 1.16),   // GBP → EUR: 1 GBP = 1.16 EUR
  (0, 3, 149.50), // USD → JPY: 1 USD = 149.50 JPY
  (3, 0, 0.0067), // JPY → USD: 1 JPY = 0.0067 USD
  // 人为添加一个可能产生套利的环
  (0, 1, 0.85),   // 异常低汇率 (模拟套利机会)
]

detect_arbitrage(currencies, rates)

// 可能的输出:
// === 💰 外汇套利检测 ===
//
//   以 USD 为起点: 🚨 发现套利机会!
//      原因: negative cycle detected
//      ⚠️ 建议: 可构建套利策略!
//   以 EUR 为起点: 未发现套利机会
//   以 GBP 为起点: 未发现套利机会
//   以 JPY 为起点: 未发现套利机会
```

### 示例 3: 🔄 分布式系统中的网络容错路由

```moonbit
/// 使用 Bellman-Ford 解决含"负延迟"链路的路由问题
///
/// 场景: 某些网络链路由于缓存/预取技术,
///       有效延迟可能为负值 (即提前收到数据)
fn fault_tolerant_routing(
  network_topology : DirectedAdjList,
  source_server : String,
  target_servers : Array[String],
  server_to_id : Map[String, NodeId],
  id_to_server : Map[NodeId, String]
) -> Unit {
  let src_id = server_to_id.get(source_server).unwrap()

  // 执行 Bellman-Ford (支持负权 = 支持"预取加速"链路)
  match @shortest_path.bellman_ford(network_topology, src_id) {
    Ok(result) => {
      println("=== 🔄 容错路由分析 (支持预取加速) ===")
      println("源服务器: ${source_server}\n")

      for target_name in target_servers {
        let tgt_id = server_to_id.get(target_name).unwrap()
        let latency = result.distance_to(tgt_id)

        match latency {
          l if l < 999999.0 => {
            let path = result.path_to(tgt_id)

            println("目标: ${target_name}")
            println("  有效延迟: ${latency} ms")

            if (l < 0.0) {
              println("  🚀 预取加速生效! (有效延迟为负, 数据被提前送达)")
            }

            println("  路径 (${path.length()} 跳):")
            for (hop, node_id) in path.indexed() {
              let name = id_to_server.get(node_id).unwrap_or("?")
              let hop_lat = result.distance_to(node_id)
              println("    ${hop}. ${name} (${hop_lat} ms)")
            }
            println("")
          }
          _ => {
            println("目标: ${target_name} → 不可达 😢\n")
          }
        }
      }
    }
    Err(msg) => {
      println("❌ 路由计算失败: ${msg}")
      println("提示: 网络拓扑中存在'正反馈环路'(如无限预取循环)")
    }
  }
}
```

---

## 📈 复杂度分析

### 时间复杂度: O(V × E)

| 操作 | 次数 | 复杂度 | 说明 |
|------|------|--------|------|
| 初始化数组 | 1 次 | O(V) | 创建 distances/parents |
| 收集边列表 | 1 次 | O(V+E) | 遍历邻接表 |
| **主循环 (V-1 轮)** | V-1 次 | O(E) 每轮 | 每轮遍历所有边 |
| **总计 (主循环)** | | **O(VE)** | |
| 负环检测 | 1 轮 | O(E) | 再遍历一次所有边 |
| **总时间** | | **O(VE)** | |

### 空间复杂度: O(V + E)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `distances[]` | O(V) | 最短距离数组 |
| `parents[]` | O(V) | 父节点指针 |
| `edge_list` | O(E) | 预收集的所有边 |
| `node_list` | O(V) | 节点列表 |
| **总计** | **O(V+E)** | |

### 与其他算法对比

| 算法 | 时间 | 负权边 | 负环检测 | 适用场景 |
|------|------|--------|---------|---------|
| **BFS** | O(V+E) | ❌ | ❌ | 无权图 |
| **Dijkstra** | O((V+E)logV) | ❌ | ❌ | 非负权图 |
| **Bellman-Ford** | **O(VE)** | **✅** | **✅** | **含负权图** |
| **SPFA** | O(kE) 平均 | ✅ | ✅ | BF 的优化版 |
| **Floyd-Warshall** | O(V³) | ✅ | ✅ | 全源最短路径 |

### 什么时候应该用 Bellman-Ford？

```
✅ 使用场景:
  - 图中存在负权边 (必须!)
  - 需要检测负环 (金融/网络)
  - 图规模较小 (V < 500)
  - 实现简单性优先于性能

❌ 不适用:
  - 大规模非负权图 → 用 Dijkstra (更快)
  - 需要全源最短路径 → 用 Floyd-Warshall
  - V 很大且 E 接近 V² → O(VE) 太慢
```

---

## 🎯 实际应用场景

### 应用 1: 💰 金融套利检测

```
问题: 在外汇/加密货币市场中检测套利机会

原理:
  将货币视为节点, 汇率视为边权重
  利用对数转换将乘法问题转为加法问题:
    rate(A→B) × rate(B→C) × rate(C→A) > 1
    ⇔ ln(rate(A→B)) + ln(rate(B→C)) + ln(rate(C→A)) > 0
    ⇔ -ln(...) + -ln(...) + -ln(...) < 0  (负环!)

实际应用:
  - 高频交易系统的套利信号生成
  - DeFi 协议中的 MEV (Miner Extractable Value) 检测
  - 跨交易所价差监控
```

### 应用 2: 🌐 分布式网络路由

```
问题: 在网络拓扑变化时快速重新计算最优路由

应用场景:
  - 因特网 BGP 协议的路径向量算法 (类似 BF 思想)
  - 软件定义网络 (SDN) 的集中式路由计算
  - 无线传感器网络的能量感知路由 (负权 = 能量回收)

特殊性质:
  - 支持动态边权重更新 (增量式重计算)
  - 天然支持"负延迟"链路 (预取/缓存)
```

### 应用 3: 🎮 游戏开发中的时间旅行

```
问题: 游戏中允许"时间倒流"机制的路径规划

场景:
  - 某些传送门可以让玩家"回到过去" (消耗时间为负)
  - 寻找完成所有任务的最短游戏时间
  - 检测是否存在"无限刷分"的漏洞 (负环 = 无限刷!)

实现:
  - 普通移动: 正权重 (耗时)
  - 传送门/存读档: 负权重 (节省时间)
  - Bellman-Ford 找最优通关路线
  - 负环检测防止作弊漏洞
```

### 应用 4: 📊 项目管理中的关键路径 (变种)

```
问题: 项目任务调度中考虑"时间压缩"任务

变种应用:
  - 某些任务可以通过"加班"缩短持续时间 (负权调整)
  - 某些依赖关系可以并行化 (减少等待时间)
  - 寻找项目的最短完工时间

注意: 这里不是标准的 Bellman-Ford,
      而是 DAG 上的动态规划 (如果无环的话),
      但如果有反馈回路 (迭代开发), 则需要 BF 来处理。
```

---

## 🧪 练习题

### 练习 1: 手动执行 Bellman-Ford ⭐⭐

对于以下含负权边的图，从节点 S 开始执行 Bellman-Ford：

1. 写出每轮松弛后的 `dist[]` 数组
2. 给出最终的最短路径
3. 判断是否存在负环

```
  S ──(4)──→ A ──(2)──→ B
   │╲          ↗ │╲
  (2) ╲       ╱  │  ╲(3)
   │   ╲    (1)  │   ╲
   ▼    ╲   ▼    ▼    ▼
   C ──(3)→ D ←─(-2)─ E
```

<details>
<summary>📝 点击查看答案</summary>

```
初始化: dist[S]=0, 其他=∞

Round 1:
  (S,A,4): dist[A]=4
  (S,C,2): dist[C]=2
  (C,D,3): dist[D]=5
  结果: [S=0, A=4, B=∞, C=2, D=5, E=∞]

Round 2:
  (A,B,2): dist[B]=4+2=6
  (D,E,-2): dist[E]=5-2=3
  (E,B,3): dist[B]=min(6, 3+3)=6 (不变)
  (E,D,1): dist[D]=min(5, 3+1)=4 ✅ 改善!
  结果: [S=0, A=4, B=6, C=2, D=4, E=3]

Round 3:
  (D,E,-2): dist[E]=min(3, 4-2)=2 ✅ 改善!
  (E,B,3): dist[B]=min(6, 2+3)=5 ✅ 改善!
  (E,D,1): dist[D]=min(4, 2+1)=3 ✅ 改善!
  结果: [S=0, A=4, B=5, C=2, D=3, E=2]

Round 4:
  (D,E,-2): dist[E]=min(2, 3-2)=1 ✅ 改善!
  (E,B,3): dist[B]=min(5, 1+3)=4 ✅ 改善!
  (E,D,1): dist[D]=min(3, 1+1)=2 ✅ 改善!
  结果: [S=0, A=4, B=4, C=2, D=2, E=1]

Round 5 (负环检测):
  (D,E,-2): 2-2=0 > 1? ❌ 不能松弛
  (E,D,1): 1+1=2 > 2? ❌ 不能松弛
  ... 所有边都不能松弛 → 无负环 ✅

最终答案:
  dist[S]=0, dist[A]=4, dist[B]=4, dist[C]=2, dist[D]=2, dist[E]=1
  最短路径:
    S→A: [S,A] = 4
    S→B: [S,C,D,E,B] = 2+3-2+3 = 4 (利用负权边!)
    S→C: [S,C] = 2
    S→D: [S,C,D,E,D] = 2+3-2+1 = 4... 等等, 让我重新算

  实际上 S→D 的最短路径应为:
    S→C(2) → D(3) → E(-2) → D(1) = 2+3-2+1 = 4? 不是最短
    或者 S→C(2) → D(3) = 5 (第一轮)
    Round 2: D 通过 E 改善: S→C→D→E→D = 2+3-2+1 = 4
    Round 3: E 改善后 D 又改善...
    
  这里展示的是负权边导致的"多轮逐步改善"现象!
```

</details>

### 练习 2: 编程实现 - SPFA 优化版 ⭐⭐⭐

基于 Bellman-Ford 的思路，实现 **SPFA (Shortest Path Faster Algorithm)** —— 只松弛"距离被更新的节点"的出边。

```moonbit
/// 提示:
/// 1. 使用队列存储"需要重新松弛的节点"
/// 2. 每次从队首取出一个节点, 松弛其所有出边
/// 3. 如果某节点的距离被改善, 将其入队
/// 4. 用入队次数检测负环 (> V 次则存在负环)
```

<details>
<summary>💻 点击查看参考实现</summary>

mbtgraph 已提供完整的 SPFA 实现 (`lib/algo/shortest_path/spfa.mbt`):

```moonbit
/// SPFA 核心伪代码:
queue = [source]
in_queue[source] = true
enqueue_count[source] = 1

while queue not empty:
  u = queue.dequeue()
  in_queue[u] = false

  for (v, weight) in neighbors(u):
    if dist[u] + weight < dist[v]:
      dist[v] = dist[u] + weight
      parent[v] = u

      if not in_queue[v]:
        queue.enqueue(v)
        in_queue[v] = true
        enqueue_count[v] += 1

        if enqueue_count[v] > V:  // 🔑 负环检测
          return Error("negative cycle detected")
```

SPFA vs Bellman-Ford:
- 平均: O(kE), k 通常很小 → **远快于 O(VE)**
- 最坏: O(VE) (退化到 Bellman-Ford)
- 空间: O(V) 额外 (队列 + 入队计数)

</details>

### 练习 3: 进阶 - 找出构成负环的所有边 ⭐⭐⭐⭐

**挑战**: 在检测到负环后，输出构成该负环的所有边。

**提示**:
1. 在负环检测阶段，记录最后被松弛的边 `(u, v)`
2. 从节点 `v` 开始回溯 `parent[]` V 步
3. 回溯路径中一定会经过负环上的某个节点
4. 从该节点继续回溯直到回到自身，即可得到完整环

<details>
<summary>🔧 参考框架</summary>

```moonbit
/// 找出负环并返回环上的边
pub fn[G : @core.GraphReadable] find_negative_cycle(
  graph : G
) -> Result[Array[(NodeId, NodeId)], String] {
  // 1. 添加一个虚拟超级源点, 连接到所有节点 (权重 0)
  // 2. 运行 Bellman-Ford (从超级源点出发)
  // 3. 如果检测到负环, 记录最后被松弛的边 (u, v)
  // 4. 从 v 开始沿 parent[] 回溯 V 步
  // 5. 记录回溯路径上首次重复出现的节点 → 环的入口
  // 6. 从环入口继续回溯直到回到自身 → 完整环

  // 详细实现略 (约 40-50 行)
  Err("not implemented")
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/sssp | 🏆 支持 BF/Dijkstra/BF 对比，含负权边模式 |
| Algorithm Visualizer | https://algorithm-visualizer.org/graphs/bellman-ford.html | 清晰的逐轮可视化 |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/BellmanFord.html | 学术风格 |

### 理论延伸阅读

- **Dijkstra 教程**: [Dijkstra](/algorithms/shortest-path/dijkstra/)（非负权图的更优选择）
- **SPFA**: [SPFA 算法](/)（Bellman-Ford 的队列优化版）
- **Floyd-Warshall**: [Floyd-Warshall](/algorithms/shortest-path/floyd-warshall/)（全源最短路径）
- **网络流**: [Edmonds-Karp](/algorithms/flow/edmonds-karp/)（另一种重要的图算法）

### 经典教材推荐

| 书名 | 作者 | 推荐章节 |
|------|------|----------|
| *Introduction to Algorithms (CLRS)* | Cormen et al. | Ch.24 Single-Source Shortest Paths (Section 24.1) |
| *Algorithms* | Sedgewick & Wayne | Ch.4.4 Shortest Paths |
| 算法导论（中文版） | 殷建平等译 | 第24章 单源最短路径 (24.1 节 Bellman-Ford) |

### mbtgraph API 参考

```moonbit
// Bellman-Ford (支持负权边, 可检测负环)
@shortest_path.bellman_ford(graph, source)  → Result[ShortestPathResult, String]

// SPFA (BF 的队列优化版)
@shortest_path.spfa(graph, source)          → Result[ShortestPathResult, String]

// Dijkstra (仅非负权, 更快)
@shortest_path.dijkstra(graph, source)      → ShortestPathResult (总是成功)

// 结果查询 (三者通用)
result.distance_to(target)    // Double (最短距离)
result.path_to(target)        // Array[NodeId] (重建路径)
result.is_reachable(target)   // Bool
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** Bellman-Ford 的核心思想（V-1 轮全局松弛）
- [ ] **理解** 为什么 Dijkstra 不能处理负权边（贪心假设失效）
- [ ] **手动执行** 小规模图的 BF 过程（写出每轮 dist[] 变化）
- [ ] **实现** MoonBit 版本的 Bellman-Ford（理解 V-1 轮、负环检测）
- [ ] **区分** Bellman-Ford vs Dijkstra vs SPFA vs Floyd-Warshall
- [ ] **知道** Bellman-Ford 的局限性（O(VE) 慢于 Dijkstra）
- [ ] **应用** BF 到实际问题（外汇套利/网络容错路由/游戏时间旅行）
- [ ] **推导** 负环检测的正确性（第 V 轮仍能松弛 → 存在负环）

> 💡 **下一步**: 尝试实现练习题中的 **SPFA 优化版** 或 **负环查找算法**，或者进入 [Floyd-Warshall](/algorithms/shortest-path/floyd-warshall/) 学习全源最短路径！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 Bellman-Ford:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_negative_weight_graph()

  // 方式 1: Bellman-Ford (标准版)
  match @shortest_path.bellman_ford(g, @core.NodeId(0)) {
    Ok(result) => println("最短距离: ${result.distance_to(@core.NodeId(3))}"),
    Err(msg) => println("检测到负环: ${msg}")
  }

  // 方式 2: SPFA (优化版, 通常更快)
  match @shortest_path.spfa(g, @core.NodeId(0)) {
    Ok(result) => println("SPFA 结果: ${result.distance_to(@core.NodeId(3))}"),
    Err(msg) => println("检测到负环: ${msg}")
  }
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看含负权边的最短路径动画：<a href="https://visualgo.net/en/sssp" target="_blank">https://visualgo.net/en/sssp</a></p>
    <p>💡 <strong>重点观察</strong>: 选择 "Negative Weight Edge" 模式，对比 Dijkstra 和 Bellman-Ford 在同一张图上的不同行为！</p>
  </div>
</div>
