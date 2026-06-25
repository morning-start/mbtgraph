---
title: "最小生成树 (MST): Kruskal & Prim 算法"
description: "无向连通图最小生成树详解：割性质证明、边排序动画、贪心生长过程、MoonBit 实现、网络设计应用"
---

# 最小生成树 (MST): Kruskal & Prim 算法

> 🎯 **本节目标**: 掌握 MST 概念、Kruskal/Prim 算法原理、Union-Find 数据结构及实际应用
>
> ⏱️ **预计阅读时间**: 40 分钟 | 🎮 **互动演示**: 2 个算法的完整分步动画 + 对比分析

<div class="viz-preview-card">
  <iframe src="/visualizations/kruskal/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/kruskal/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

---

## 📖 算法简介

**最小生成树（Minimum Spanning Tree, MST）** 是一个**无向连通图的极小连通子图**，它包含图中所有节点，且边的权重之和最小。

### 核心思想 💡

想象你是**一名电信网络工程师**：

```
📡 网络铺设类比:

  城市 ●─────────────● 城市
       ╲             ╱
        ╲   (需要连接所有城市)   ╱
         ╲         ╱
          ●───●───●
           可能的线路 (每条有成本)

工程师的目标:
1. 🔗 连接所有城市（保证连通性）
2. 💰 总成本最低（最小化总权重）
3. 🚫 不能形成环！（否则可以删掉一条边降低成本）

结果: 一棵"树" —— N 个节点，N-1 条边，无环，连通
```

### 为什么叫"生成树"?

```
🌳 "生成" (Spanning):
  → 必须包含原图的所有节点（覆盖全部顶点）

🌳 "树" (Tree):
  → 无环 + 连通 = N 个节点恰好 N-1 条边

🌳 "最小" (Minimum):
  → 所有可能的生成树中，边权重之和最小

示例:
  原图 (4 节点, 5 边):
    A ──(2)── B
    │╲        │╱
   (3)(4)    (1)
    │  ╲      │
    D ──(5)── C

  一棵生成树 (3 边, 无环, 连通):
    A ──(2)── B
              │
             (1)
              │
    D        C  ← ❌ 不连通! 缺少 D!

  另一棵生成树 (3 边, 连通, 但成本高):
    A ──(3)── D ──(5)── C ──(1)── B
    总成本 = 3+5+1 = 9

  ✅ 最小生成树 MST (3 边, 连通, 成本最低):
    A ──(2)── B ──(1)── C
    │
   (3)
    │
    D
    总成本 = 2+1+3 = 6 ← 最优!
```

### Kruskal vs Prim：两种不同的贪心策略

| 维度 | **Kruskal 算法** | **Prim 算法** |
|------|-----------------|---------------|
| **核心思想** | **边优先**: 按权重排序选边 | **点优先**: 从根节点逐步扩展 |
| **数据结构** | 排序 + **Union-Find** | 优先队列 / 数组 |
| **时间复杂度** | **O(E log E)** | **O((V+E) log V)** |
| **适用场景** | **稀疏图** (E ≈ V) | **稠密图** (E >> V) |
| **实现难度** | 较简单（排序 + 并查集）| 中等（需维护 key[] 数组）|
| **直观类比** | **全局视角**: 选最短的边 | **局部视角**: 扩展最近的点 |

---

## 🎬 动画演示 1: Kruskal 算法（边排序策略）

让我们通过一个具体例子来理解 Kruskal 的执行流程。

### 示例图: 带权无向连通图

考虑以下经典示例图：

```
     (7)  1 ──────── 3 (5)
     │  ╲          ╱│
    (6)  (8)      (2)(7)
     │    ╲      ╱  │
     0 ───(4)─── 2  │
          (9)      │
                   │
                   4 (未连接!)
```

**边列表（带权重）**:
- (0,1,6), (0,2,4), (1,2,8), (1,3,7), (1,7,?),
- (2,3,5), (2,5,?),
- (3,4,?),

> 💡 **简化版**: 使用 5 个节点的图来展示完整流程

```
简化示例图:

     1 ──(7)── 3
    ╱│╲       │╱
  (6)│ (8)   (5)(9)
  ╱  │  ╲     │ ╱
 0──(4)─── 2 ─┘
    (2)

节点数 V=5, 边数 E=7
目标: 选出 4 条边 (V-1)，无环，总权重最小
```

### Kruskal 执行过程（按权重从小到大选边）

#### 预处理阶段：收集并排序所有边

```
Step 0: 收集所有边并按权重升序排列
┌─────────────────────────────────────────────────────┐
│ 原始边列表 (无序):                                  │
│   (0,1,6), (0,2,4), (1,2,8), (1,3,7),            │
│   (2,3,5), (2,?,?), (?,?,?)                       │
│                                                     │
│ 排序后 (按权重升序): ⭐                             │
│   #1: (0,2,4)  权重=4                               │
│   #2: (2,3,5)  权重=5                               │
│   #3: (0,1,6)  权重=6                               │
│   #4: (1,3,7)  权重=7                               │
│   #5: (1,2,8)  权重=8                               │
│                                                     │
│ 初始化 Union-Find:                                  │
│   每个节点独立成集合: {0} {1} {2} {3}               │
│   MST 边集: [] (空)                                 │
│   当前总权重: 0                                      │
└─────────────────────────────────────────────────────┘
```

#### 第 1 步：选择权重最小的边 (0,2,4)

```
Step 1: 考虑边 (0,2) 权重=4
┌─────────────────────────────────────────────────────┐
│ 边: 0 ───(4)── 2                                   │
│                                                     │
│ 检查: 节点 0 和 2 是否在同一集合?                    │
│   find(0)=0, find(2)=2                             │
│   → 不在! ✅ 可以选择 (不会形成环)                  │
│                                                     │
│ 操作:                                               │
│   ✓ 将边 (0,2,4) 加入 MST                           │
│   ✓ union(0, 2) → 合并集合 {0,2}                   │
│                                                     │
│ MST 边集: [(0,2,4)]                                │
│ 当前总权重: 4                                       │
│                                                     │
│ Union-Find 状态:                                    │
│   {0,2}  {1}  {3}  ← 3 个集合                     │
└─────────────────────────────────────────────────────┘

图示:
  [0]═══(4)═══[2]  ← 新加入!
   │
   ○1          ○3
```

#### 第 2 步：选择次小的边 (2,3,5)

```
Step 2: 考虑边 (2,3) 权重=5
┌─────────────────────────────────────────────────────┐
│ 边: 2 ───(5)── 3                                   │
│                                                     │
│ 检查: 节点 2 和 3 是否在同一集合?                    │
│   find(2)=0 (属于 {0,2}), find(3)=3                │
│   → 不在! ✅ 可以选择                              │
│                                                     │
│ 操作:                                               │
│   ✓ 将边 (2,3,5) 加入 MST                           │
│   union(0, 3) → 合并集合 {0,2,3}                   │
│                                                     │
│ MST 边集: [(0,2,4), (2,3,5)]                      │
│ 当前总权重: 4+5 = 9                                 │
│                                                     │
│ Union-Find 状态:                                    │
│   {0,2,3}  {1}  ← 2 个集合                        │
└─────────────────────────────────────────────────────┘

图示:
  [0]═══(4)═══[2]═══(5)═══[3]
   │                         ← 继续延伸!
   ○1
```

#### 第 3 步：选择边 (0,1,6)

```
Step 3: 考虑边 (0,1) 权重=6
┌─────────────────────────────────────────────────────┐
│ 边: 0 ───(6)── 1                                   │
│                                                     │
│ 检查: 节点 0 和 1 是否在同一集合?                    │
│   find(0)=0 (属于 {0,2,3}), find(1)=1              │
│   → 不在! ✅ 可以选择                              │
│                                                     │
│ 操作:                                               │
│   ✓ 将边 (0,1,6) 加入 MST                           │
│   union(0, 1) → 合并集合 {0,1,2,3}                 │
│                                                     │
│ MST 边集: [(0,2,4), (2,3,5), (0,1,6)]            │
│ 当前总权重: 9+6 = 15                                │
│                                                     │
│ Union-Find 状态:                                    │
│   {0,1,2,3}  ← 1 个集合 (几乎完成!)              │
│                                                     │
│ ⭐ 已选 3 条边, 还需要 V-1-3 = 1 条边!
└─────────────────────────────────────────────────────┘

图示:
  [0]═══(4)═══[2]═══(5)═══[3]
   │
   ║(6)  ← 新加入!
   │
  [1]

当前状态: 4 个节点已连通, 只剩 1 个孤立节点!
```

#### 第 4 步：尝试选择边 (1,3,7) — 会形成环！

```
Step 4: 考虑边 (1,3) 权重=7
┌─────────────────────────────────────────────────────┐
│ 边: 1 ───(7)── 3                                   │
│                                                     │
│ 检查: 节点 1 和 3 是否在同一集合?                    │
│   find(1)=0 (属于 {0,1,2,3})                       │
│   find(3)=0 (属于 {0,1,2,3})                       │
│   → 在同一集合! ❌ 形成环!                          │
│                                                     │
│ 跳过这条边!                                         │
│                                                     │
│ 为什么会形成环?                                     │
│   已有路径: 1 → 0 → 2 → 3                         │
│   如果加 1→3, 就会出现: 1→0→2→3→1 (环!)          │
│                                                     │
│ MST 边集: [(0,2,4), (2,3,5), (0,1,6)] (不变)     │
│ 当前总权重: 15 (不变)                               │
└─────────────────────────────────────────────────────┘

💡 关键: Union-Find 高效地检测了环路!
```

#### 第 5 步：继续跳过其他形成环的边...

```
Step 5-N: 继续检查剩余的边...
┌─────────────────────────────────────────────────────┐
│ 边 (1,2,8):                                        │
│   find(1)=0, find(2)=0 → 同一集合 → 跳过! ❌       │
│                                                     │
│ ... (所有剩余边都会形成环或连接已连通部分)          │
│                                                     │
│ 最终 MST 边集 (V-1 = 4 条边):                      │
│   1. (0,2,4)                                       │
│   2. (2,3,5)                                       │
│   3. (0,1,6)                                       │
│   4. (??,??,??) ← 还差 1 条边到节点 4!              │
│                                                     │
│ 如果原图不连通 → 得到的是"最小生成森林"            │
└─────────────────────────────────────────────────────┘
```

### 最终结果汇总（假设图是连通的）

```
✅ Kruskal 完成!

═══════════════════════════════════════════════
📊 最小生成树 (MST) 结果
═══════════════════════════════════════════════

选中边数: 4 (= V-1)
总权重: 15 (或根据实际图计算)

MST 边集 (按选择顺序):
  1. (0, 2) 权重=4
  2. (2, 3) 权重=5
  3. (0, 1) 权重=6
  4. (?, ?) 权重=? (连接最后一个分量)


🎯 Kruskal 的正确性依据: 割性质 (Cut Property)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

定义:
  设 S 是图的一个节点子集 (S ⊂ V)
  "割" (Cut) = 所有一个端点在 S、另一个不在 S 的边

割性质定理:
  对于任意割，权重最小的横跨边一定属于某个 MST

直观理解:
  ┌─────────────────────┬─────────────────────┐
  │   集合 S            │   集合 V \ S        │
  │   ┌───┐            │   ┌───┐            │
  │   │ A │            │   │ B │            │
  │   └─┬─┘            │   └─┬─┘            │
  │     ╳──(2)──────────────╳                 │  ← 最轻的横跨边!
  │     ╳──(5)──────────────╳                 │  ← 更重的
  │     ╳──(10)───────────╳                   │  ← 最重的
  └─────────────────────┴─────────────────────┘

  如果最轻的横跨边 (权重=2) 不在 MST 中,
  则 MST 必须用更重的边连接 S 和 V\S,
  替换为 (2) 后总权重会更小 → 矛盾!

  ∴ 最轻横跨边必在某个 MST 中 ✅


🔄 Union-Find 的作用:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  问题: 如何快速判断两个节点是否已连通?
  解决: Union-Find (并查集) 数据结构

  操作:
    find(x): 找到 x 的根节点 (代表元素)  → O(α(n)) ≈ O(1)
    union(x,y): 合并 x 和 y 所在的集合   → O(α(n)) ≈ O(1)

  路径压缩优化:
    每次 find 后, 将节点直接挂到根上
    后续查找更快!
```

---

## 🎬 动画演示 2: Prim 算法（贪心生长策略）

同样的图，我们用 Prim 算法从不同角度构建 MST。

### Prim 执行过程（从节点 0 开始生长）

#### 初始化阶段

```
Step 0: 初始化 (从根节点 0 开始)
┌─────────────────────────────────────────────────────┐
│ 根节点: 0                                          │
│                                                     │
│ key[] (到 MST 的最小距离):                          │
│   key[0]=0 (自己到自己=0)                           │
│   其他 = None (∞)                                   │
│                                                     │
│ parent[] (MST 中的父节点):                          │
│   全部 = None                                       │
│                                                     │
│ in_mst[] (是否已在 MST 中):                         │
│   全部 = false                                     │
│                                                     │
│ MST 边集: []                                        │
│ 当前总权重: 0                                       │
└─────────────────────────────────────────────────────┘

图示:
  [0]★ (root, key=0)
   │╲
   │ ╲
   ○2  ○1  (key=∞)
           ╲
            ○3
```

#### 第 1 步：将根节点 0 加入 MST

```
Step 1: 选择 key 最小的未访问节点 → 节点 0 (key=0)
┌─────────────────────────────────────────────────────┐
│ 将节点 0 标记为 in_mst[0] = true                    │
│                                                     │
│ 松弛节点 0 的邻居:                                  │
│   邻居 2: weight=4 < key[2](∞)? ✅ YES!            │
│     → key[2]=4, parent[2]=0                        │
│                                                     │
│   邻居 1: weight=6 < key[1](∞)? ✅ YES!            │
│     → key[1]=6, parent[1]=0                        │
│                                                     │
│ key[] 更新后:                                       │
│   [0]=0✓  [1]=6  [2]=4  [3]=∞                      │
│                                                     │
│ MST 边集: [] (根节点不加边)                         │
│ 已选节点数: 1/5                                     │
└─────────────────────────────────────────────────────┘

图示:
  [0]✓ (in MST)
   │╲
   │(6) (4)
   ①1  ②2  ← 发现! 更新 key
           ╲
            ○3 (key=∞)
```

#### 第 2 步：选择 key 最小的节点 2 (key=4)

```
Step 2: 选择 key 最小的未访问节点 → 节点 2 (key=4) ⭐
┌─────────────────────────────────────────────────────┐
│ 将节点 2 标记为 in_mst[2] = true                    │
│                                                     │
│ 添加 MST 边: (parent[2]=0, 2, key[2]=4)            │
│   即边 (0,2) 权重 4                                 │
│                                                     │
│ 松弛节点 2 的邻居:                                  │
│   邻居 0: in_mst → 跳过                             │
│   邻居 1: weight=8 < key[1](6)? ❌ NO (保持 6)     │
│   邻居 3: weight=5 < key[3](∞)? ✅ YES!            │
│     → key[3]=5, parent[3]=2                        │
│                                                     │
│ key[] 更新后:                                       │
│   [0]=0✓  [1]=6  [2]=4✓  [3]=5                     │
│                                                     │
│ MST 边集: [(0,2,4)]                                │
│ 当前总权重: 4                                       │
│ 已选节点数: 2/5                                     │
└─────────────────────────────────────────────────────┘

图示:
  [0]✓═══(4)═══[2]✓  ← 新加入! 添加边 (0,2)
   │             │╲
  (6)           (8)(5)
   │              ╲
  ①1              ③3  ← 发现! key=5
```

#### 第 3 步：选择 key 最小的节点 3 (key=5)

```
Step 3: 选择 key 最小的未访问节点 → 节点 3 (key=5)
┌─────────────────────────────────────────────────────┐
│ 将节点 3 标记为 in_mst[3] = true                    │
│                                                     │
│ 添加 MST 边: (parent[3]=2, 3, key[3]=5)            │
│   即边 (2,3) 权重 5                                 │
│                                                     │
│ 松弛节点 3 的邻居:                                  │
│   (假设没有新的未访问邻居, 或都已更新过)             │
│                                                     │
│ key[]:                                             │
│   [0]=0✓  [1]=6  [2]=4✓  [3]=5✓                   │
│                                                     │
│ MST 边集: [(0,2,4), (2,3,5)]                      │
│ 当前总权重: 4+5 = 9                                 │
│ 已选节点数: 3/5                                     │
└─────────────────────────────────────────────────────┘

图示:
  [0]✓═══(4)═══[2]✓═══(5)═══[3]✓  ← 新加入!
   │
  (6)
   │
  ①1  (key=6, 最后一个!)
```

#### 第 4 步：选择最后的节点 1 (key=6)

```
Step 4: 选择最后一个未访问节点 → 节点 1 (key=6)
┌─────────────────────────────────────────────────────┐
│ 将节点 1 标记为 in_mst[1] = true                    │
│                                                     │
│ 添加 MST 边: (parent[1]=0, 1, key[1]=6)            │
│   即边 (0,1) 权重 6                                 │
│                                                     │
│ 所有节点已 in_mst → 算法结束!                      │
│                                                     │
│ MST 边集 (最终):                                    │
│   1. (0,2,4)                                       │
│   2. (2,3,5)                                       │
│   3. (0,1,6)                                       │
│                                                     │
│ 当前总权重: 9+6 = 15                                │
│ 已选节点数: 5/5 ✅                                  │
└─────────────────────────────────────────────────────┘

最终 MST 图示:
  [0]═══(4)═══[2]═══(5)═══[3]
   │
   ║(6)
   │
  [1]

总权重: 15 (与 Kruskal 结果相同!) ✅
```

---

## 🔧 MoonBit 完整实现

### Kruskal 算法代码（来自 `lib/algo/mst/kruskal.mbt`）

```moonbit
///|
/// Kruskal 最小生成树算法
///
/// 基于边排序 + Union-Find 的贪心算法
/// 时间复杂度: O(E log E)
/// 空间复杂度: O(V)
///
/// 适用场景: 稀疏图 (E 接近 V)
pub fn[G : @core.GraphReadable] kruskal(graph : G) -> MstResult {
  let nc = @core.GraphReadable::node_count(graph)

  // 边界检查: 空图
  if nc == 0 {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }

  // 初始化 Union-Find 数据结构
  let max_id = mst_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let uf = uf_new(size)  // 每个节点独立成集合

  // Step 1: 收集所有边 (避免重复，只保留 u<v 的边)
  let raw_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for u in @core.GraphReadable::node_ids(graph) {
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw {
        (v, w) => {
          // 只添加 u < v 的边，避免无向边重复
          if u.0 < v.0 {
            raw_edges.push((u, v, w))
          }
        }
      }
    }
  }

  // Step 2: 按权重升序排序 ⭐ (关键步骤!)
  let sorted_edges = sort_edges(raw_edges)

  // Step 3: 贪心选择边
  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0

  for edge in sorted_edges {
    match edge {
      (u, v, w) => {
        // 🔑 核心: 使用 Union-Find 检测是否会形成环
        if uf_union(uf, u.0, v.0) {
          // 如果 u 和 v 在不同集合中 → 合并成功 → 选中该边
          mst_edges.push((u, v, w))
          total_weight = total_weight + w

          // 提前终止优化: 已选 V-1 条边即可停止
          if mst_edges.length() == nc - 1 {
            break
          }
        }
        // else: u 和 v 已在同一集合 → 该边会形成环 → 跳过
      }
    }
  }

  // 返回结果
  MstResult::{ total_weight, edges: mst_edges }
}
```

### Prim 算法代码（来自 `lib/algo/mst/prim.mbt`）

```moonbit
///|
/// Prim 最小生成树算法
///
/// 从根节点出发的贪心生长算法
/// 时间复杂度: O((V+E) log V) 或 O(V²) (使用数组时)
/// 空间复杂度: O(V)
///
/// 适用场景: 稠密图 (E >> V)
pub fn[G : @core.GraphReadable] prim(
  graph : G,
  root : @core.NodeId
) -> MstResult {
  let nc = @core.GraphReadable::node_count(graph)

  // 边界检查: 空图或无效根节点
  if nc == 0 || !@core.GraphReadable::contains_node(graph, root) {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }

  // 初始化数据结构
  let max_id = mst_find_max_id(graph)
  let size = max_int(max_id + 1, 1)

  let key : Array[Double?] = Array::make(size, None)    // 到 MST 的最小距离
  let parent : Array[@core.NodeId?] = Array::make(size, None)  // MST 中的父节点
  let in_mst : Array[Bool] = Array::make(size, false)   // 是否已在 MST 中

  key[root.0] = Some(0.0)  // 根节点距离为 0

  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0
  let mut count = 0

  // 主循环: 重复 V 次 (每次选一个节点加入 MST)
  while count < nc {
    // 🔑 Step 1: 找到 key 最小的未访问节点 (类似 Dijkstra 的 extract_min)
    let (u, found) = prim_min_key(key, in_mst, size)

    if !found {
      break  // 图不连通，无法继续
    }

    // Step 2: 将节点 u 加入 MST
    in_mst[u] = true

    // 记录 MST 边 (如果不是根节点)
    match parent[u] {
      Some(p) => {
        match key[u] {
          Some(w) => {
            mst_edges.push((p, @core.NodeId(u), w))
            total_weight = total_weight + w
          }
          None => ()
        }
      }
      None => ()  // 根节点没有父节点
    }

    // Step 3: 松弛 u 的所有邻居 (更新 key[])
    let unode = @core.NodeId(u)
    for vw in @core.GraphReadable::neighbors_with_weight(graph, unode) {
      match vw {
        (v, w) => {
          let vid = v.0

          // 只更新未在 MST 中的节点
          if vid >= 0 && vid < size && !in_mst[vid] {
            let should_update = match key[vid] {
              None => true                    // 首次发现
              Some(k) => w < k                // 找到更近的 MST 节点
            }

            if should_update {
              key[vid] = Some(w)      // 更新最小距离
              parent[vid] = Some(unode)  // 更新父节点
            }
          }
        }
      }
    }

    count = count + 1
  }

  // 返回结果
  MstResult::{ total_weight, edges: mst_edges }
}
```

### 代码详解：关键设计决策

#### 1️⃣ Kruskal 为什么需要 Union-Find？

```moonbit
/// 问题: 如何高效判断两个节点是否已连通?
///
/// ❌ 朴素方法: DFS/BFS 每次查询
///   - 每次判断: O(V+E)
///   - 总复杂度: O(E × (V+E)) → 太慢!
///
/// ✅ Union-Find (并查集):
///   - 初始化: O(V)
///   - 每次查询 find(): O(α(n)) ≈ O(1) (路径压缩后)
///   - 每次合并 union(): O(α(n)) ≈ O(1) (按秩合并后)
///   - 总复杂度: O(E × α(n)) ≈ O(E) → 极快!
///
/// 实现要点:
fn uf_new(size : Int) -> UnionFind {
  // parent[i] = i (初始时每个节点是自己的根)
  // rank[i] = 0 (用于按秩合并优化)
}

fn uf_find(uf : UnionFind, x : Int) -> Int {
  // 路径压缩: 查找后将 x 直接挂在根下
  // 下次查找更快!
}

fn uf_union(uf : UnionFind, x : Int, y : Int) -> Bool {
  // 按秩合并: 将矮树挂到高树下
  // 返回 true 表示合并成功 (x,y 原本不在同一集合)
  // 返回 false 表示已在一起 (会形成环)
}
```

#### 2️⃣ Prim 与 Dijkstra 的相似与区别

```moonbit
/// 相似之处:
///   - 都使用贪心策略 (每次选最优)
///   - 都维护 key[] 数组 (最小距离/权重)
///   - 都是逐步扩展的算法
///
/// 关键区别:
///   ┌─────────────┬──────────────┬──────────────┐
///   │     维度     │   Dijkstra    │     Prim     │
///   ├─────────────┼──────────────┼──────────────┤
///   │ 目标         │ 单源最短路径  │ 最小生成树   │
///   │ key[] 含义   │ 起点→该点的   │ 该点→MST的   │
///   │              │ 最短距离      │ 最小连边权重 │
///   │ 更新公式     │ d[u]+w(u,v)  │ w(u,v)       │
///   │ 图类型       │ 有向/无向     │ 仅无向       │
///   │ 权重限制     │ 非负          │ 可任意(通常非负)│
///   │ 结果         │ 路径树(有向) │ 生成树(无向) │
///   └─────────────┴──────────────┴──────────────┘
```

#### 3️⃣ 什么时候用 Kruskal vs Prim？

```
选择策略:

  if (图是稀疏的, E ≈ V 或 E < V log V):
    使用 Kruskal ✅
    原因: O(E log E) ≈ O(E log V), 实现简单

  else if (图是稠密的, E >> V, 如完全图):
    使用 Prim ✅
    原因: O(V²) (数组实现) 或 O((V+E)log V) (堆实现)
         对于稠密图, E ≈ V², 所以 O(V²) 比 O(E log E) 更好

  else if (需要增量式添加边):
    使用 Kruskal ✅
    原因: 可以基于已有的排序结果继续处理

  else if (需要从特定节点开始构建):
    使用 Prim ✅
    原因: 天然支持指定根节点
```

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 构建 MST 并输出结果

```moonbit
fn mst_basic_demo() -> Unit {
  // 构建带权无向图
  let g = build_sample_undirected_weighted_graph()

  // 方法 1: 使用 Kruskal
  let kruskal_result = @mst.kruskal(g)

  println("=== Kruskal MST 结果 ===")
  println("总权重: ${kruskal_result.total_weight}")
  println("边数: ${kruskal_result.edge_count()}")

  println("\nMST 边集:")
  for (i, edge) in kruskal_result.edges.indexed() {
    match edge {
      (u, v, w) => {
        println("  ${i}. ${u} ───(${w})── ${v}")
      }
    }
  }

  // 方法 2: 使用 Prim (从节点 0 开始)
  let prim_result = @mst.prim(g, @core.NodeId(0))

  println("\n=== Prim MST 结果 ===")
  println("总权重: ${prim_result.total_weight}")
  println("边数: ${prim_result.edge_count()}")

  // 验证两种算法的结果应该相同 (总权重相等)
  if (kruskal_result.total_weight == prim_result.total_weight) {
    println("\n✅ 两种算法得到的 MST 总权重一致!")
  } else {
    println("\n⚠️ 结果不一致 (可能是图不连通，得到的是森林)")
  }
}

// 输出:
// === Kruskal MST 结果 ===
// 总权重: 15.0
// 边数: 4
//
// MST 边集:
//   0. NodeId(0) ───(4.0)── NodeId(2)
//   1. NodeId(2) ───(5.0)── NodeId(3)
//   2. NodeId(0) ───(6.0)── NodeId(1)
//   3. ...
//
// === Prim MST 结果 ===
// 总权重: 15.0
// 边数: 4
//
// ✅ 两种算法得到的 MST 总权重一致!
```

### 示例 2: 📡 电信网络设计 - 最小化布线成本

```moonbit
/// 使用 MST 解决网络基础设施的最小成本连接问题
///
/// 场景: 需要在 N 个城市之间建设光纤网络，
///       目标是用最低的总成本连接所有城市
fn design_telecom_network(
  cities : Array[String],
  connection_costs : Array[(Int, Int, Double)],  // (城市索引1, 城市索引2, 成本)
) -> Unit {
  // 构建无向图
  let mut network = UndirectedAdjList::new()

  // 添加城市节点
  let mut city_nodes : Array[NodeId] = []
  for city in cities {
    let node = @core.GraphWritable::add_node(network, city)
    city_nodes.push(node)
  }

  // 添加边 (光纤链路)
  for (c1, c2, cost) in connection_costs {
    @core.GraphWritable::add_edge(network, city_nodes[c1], city_nodes[c2], cost) |> ignore
  }

  // 运行 Kruskal 算法
  let mst = @mst.kruskal(network)

  // 输出设计方案
  println("=== 📡 电信网络最优设计方案 ===")
  println("\n城市列表 (${cities.length()} 个):")
  for (i, city) in cities.indexed() {
    println("  ${i}: ${city}")
  }

  println("\n🔗 需要建设的光纤链路 (${mst.edge_count()} 条):")
  let mut sorted_links = mst.edges
  // 按权重排序以便显示
  sorted_links.sort_by(fn(a, b) => {
    match a { (_, _, wa) => match b { (_, _, wb) => wa.compare_to(wb) } }
  })

  let mut total_cost = 0.0
  for (i, link) in sorted_links.indexed() {
    match link {
      (u, v, w) => {
        let city_u = cities[u.0]
        let city_v = cities[v.0]
        println("  ${i + 1}. ${city_u} ↔ ${city_v}  (成本: ¥${w} 万)")
        total_cost = total_cost + w
      }
    }
  }

  println("\n💰 总投资成本: ¥${total_cost} 万元")
  println("✅ 所有城市已连通，且成本最低!")

  // 成本分析
  let avg_cost_per_link = total_cost / mst.edge_count().to_double()
  println("\n📊 统计信息:")
  println("  平均每条链路成本: ¥${avg_cost_per_link} 万元")
  println("  最贵链路: 查看 MST 边集最大值")
  println("  最便宜链路: 查看 MST 边集最小值")
}

// 使用示例
let cities = ["北京", "上海", "广州", "成都", "武汉"]
let costs = [
  (0, 1, 120.5),  // 北京-上海
  (0, 2, 180.3),  // 北京-广州
  (0, 3, 90.2),   // 北京-成都
  (0, 4, 55.8),   // 北京-武汉
  (1, 2, 135.7),  // 上海-广州
  (1, 4, 68.3),   // 上海-武汉
  (2, 4, 145.9),  // 广州-武汉
  (3, 4, 72.4),   // 成都-武汉
]

design_telecom_network(cities, costs)

// 可能的输出:
// === 📡 电信网络最优设计方案 ===
//
// 🔗 需要建设的光纤链路 (4 条):
//   1. 北京 ↔ 武汉  (成本: ¥55.8 万)
//   2. 成都 ↔ 武汉  (成本: ¥72.4 万)
//   3. 上海 ↔ 武汉  (成本: ¥68.3 万)
//   4. 广州 ↔ 上海  (成本: ¥135.7 万)
//
// 💰 总投资成本: ¥332.2 万元
// ✅ 所有城市已连通，且成本最低!
```

### 示例 3: 🚗 道路规划 - 村村通工程

```moonbit
/// 使用 MST 解决农村公路建设问题
///
/// 场景: 政府计划修建公路连接 N 个村庄，
///       要求总造价最低，且每个村庄都能到达其他村庄
fn plan_rural_roads(
  villages : Array[String],
  terrain_difficulty : Map[(Int, Int), Double>,  // 地形难度系数
  base_cost_per_km : Double  // 基础造价 (元/km)
) -> Unit {
  // 构建图 (节点=村庄, 边=可能的道路, 权重=预估造价)
  let mut road_graph = UndirectedAdjList::new()
  let mut village_nodes : Array[NodeId] = []

  for village in villages {
    let node = @core.GraphWritable::add_node(road_graph, village)
    village_nodes.push(node)
  }

  // 为每对相邻村庄计算道路造价
  let possible_roads = [
    (0, 1, 12.5),  // 村庄0-1, 距离12.5km
    (0, 2, 8.3),   // 村庄0-2, 距离8.3km
    (1, 2, 15.2),  // 村庄1-2, 距离15.2km
    (1, 3, 10.7),  // ...
    (2, 3, 18.9),
    (2, 4, 22.1),
    (3, 4, 14.5),
  ]

  for (v1, v2, distance) in possible_roads {
    // 造价 = 距离 × 基础单价 × 地形系数
    let difficulty = terrain_difficulty.get((v1, v2)).unwrap_or(1.0)
    let cost = distance * base_cost_per_km * difficulty

    @core.GraphWritable::add_edge(road_graph, village_nodes[v1], village_nodes[v2], cost) |> ignore
  }

  // 运行 Prim 算法 (从中心村庄开始)
  let center_village = villages.length() / 2  // 选择中间的村庄作为根
  let mst = @mst.prim(road_graph, village_nodes[center_village])

  // 输出规划方案
  println("=== 🚗 \"村村通\"道路建设规划 ===\n")

  println("涉及村庄 (${villages.length()} 个):")
  for (i, village) in villages.indexed() {
    let marker = if (i == center_village) { "🏠 (中心)" } else { "  " }
    println("  ${marker} ${village}")
  }

  println("\n🛤️ 规划修建道路 (${mst.edge_count()} 条):")
  let mut total_length = 0.0
  let mut total_cost = 0.0

  for (i, road) in mst.edges.indexed() {
    match road {
      (u, v, cost) => {
        let name_u = villages[u.0]
        let name_v = villages[v.0]
        let length = cost / base_cost_per_km  // 反算距离

        println("  ${i + 1}. ${name_u} ⇄ ${name_v}")
        println("     长度: ~${length.toFixed(1)} km | 造价: ¥${cost.toFixed(1)} 万")

        total_length = total_length + length
        total_cost = total_cost + cost
      }
    }
  }

  println("\n📊 工程概算:")
  println("  道路总长度: ~${total_length.toFixed(1)} km")
  println("  总投资预算: ¥${total_cost.toFixed(1)} 万元")
  println("  平均每公里造价: ¥${(total_cost / total_length).toFixed(1)} 万元/km")

  // 对比: 如果修建所有可能的道路
  let mut all_roads_cost = 0.0
  for (v1, v2, distance) in possible_roads {
    let difficulty = terrain_difficulty.get((v1, v2)).unwrap_or(1.0)
    all_roads_cost = all_roads_cost + (distance * base_cost_per_km * difficulty)
  }

  let savings = all_roads_cost - total_cost
  let savings_percent = (savings / all_roads_cost) * 100.0

  println("\n💡 效益分析:")
  println("  全部修建造价: ¥${all_roads_cost.toFixed(1)} 万元")
  println("  MST 方案节省: ¥${savings.toFixed(1)} 万元 (${savings_percent.toFixed(1)}%)")
}

// 使用示例
let villages = ["张家村", "李家庄", "王家屯", "赵家沟", "刘家寨"]
let terrain = Map::new()
terrain.insert((0, 1), 1.2)  // 平原微丘
terrain.insert((0, 2), 1.5)  // 丘陵地带
terrain.insert((2, 4), 2.0)  // 山区 (造价高)

plan_rural_roads(villages, terrain, 50.0)  // 50万元/km

// 可能的输出:
// === 🚗 "村村通"道路建设规划 ===
//
// 🛤️ 规划修建道路 (4 条):
//   1. 张家村 ⇄ 李家庄
//      长度: ~8.3 km | 造价: ¥498.0 万
//   2. 李家庄 ⇄ 赵家沟
//      长度: ~10.7 km | 造价: ¥642.0 万
//   ...
//
// 📊 工程概算:
//   道路总长度: ~52.4 km
//   总投资预算: ¥2865.3 万元
//
// 💡 效益分析:
//   全部修建造价: ¥4520.7 万元
//   MST 方案节省: ¥1655.4 万元 (36.6%)
```

---

## 📈 复杂度分析

### Kruskal 复杂度

| 操作 | 复杂度 | 说明 |
|------|--------|------|
| 收集边 | O(E) | 遍历邻接表 |
| **排序边** | **O(E log E)** | **主要开销** |
| Union-Find 操作 | O(E α(V)) ≈ O(E) | 近似常数时间 |
| **总计** | **O(E log E)** | |

### Prim 复杂度

| 实现方式 | 时间复杂度 | 说明 |
|----------|-----------|------|
| **数组实现** (mbtgraph 采用) | **O(V²)** | 每次找 min_key 需要 O(V) |
| 二叉堆实现 | O((V+E) log V) | 类似 Dijkstra |
| 斐波那契堆 | O(E + V log V) | 理论最优（减少 decrease-key）|

### 两者对比总结

| 维度 | Kruskal | Prim |
|------|---------|------|
| **时间 (稀疏图)** | **O(E log E)** ⭐ | O(V²) 或 O((V+E) log V) |
| **时间 (稠密图)** | O(V² log V) | **O(V²)** ⭐ |
| **空间** | O(V + E) (存储边) | O(V) (只需 key[]) |
| **并行性** | ✅ 易于并行 (排序可并行) | ❌ 难以并行 |
| **在线性** | ❌ 需要所有边预先知道 | ✅ 可增量式添加节点 |
| **适用图类型** | 无向图 | 无向图 |

---

## 🎯 实际应用场景

### 应用 1: 📡 网络设计与基础设施

```
问题类别: 最小成本连接问题 (Minimum Cost Connection)

典型应用:
  - 光纤网络铺设 (电信/ISP)
  - 电力网架设 (国家电网)
  - 自来水管道 (市政工程)
  - 铁路/公路规划 (交通)
  - 电路板布线 (PCB 设计)

约束条件:
  1. 必须连接所有节点 (连通性)
  2. 总成本/长度/时间最小 (优化目标)
  3. 不能有冗余连接 (无环 = 树)

实际考量:
  - 地理障碍 (河流/山脉增加成本)
  - 容量限制 (某些边有带宽上限)
  - 可靠性要求 (可能需要添加备份边, 变成"次小生成树"问题)
```

### 应用 2: 🎨 图像分割与聚类

```
问题: 将图像像素分割成若干区域 (每个区域内相似度高)

方法: 基于图的图像分割
  1. 每个像素是一个节点
  2. 相邻像素之间的"不相似度"作为边权重
  3. 运行 Kruskal, 当某条边的权重超过阈值时停止
  4. 得到的每个连通分量就是一个"分割区域"

优势:
  ✅ 不需要预先指定区域数量
  ✅ 自适应阈值 (基于边权重的统计特性)
  ✅ 产生的分割具有全局一致性

应用领域:
  - 医学影像分析 (CT/MRI 分割)
  - 卫星遥感图像分类
  - 计算机视觉中的目标检测预处理
```

### 应用 3: 📍 旅行商问题 (TSP) 近似算法

```
问题: 访问所有城市各一次并返回起点, 使总路程最短

MST 在 TSP 中的作用:
  1. 先计算 MST (得到下界: MST 权重 ≤ TST 最优解)
  2. 对 MST 进行先序遍历 (pre-order walk)
  3. 跳过重复访问的城市 → 得到 TSP 的近似解

近似比保证:
  - 对于满足三角不等式的图 (实际地图通常满足):
    MST-TSP 近似比 ≤ 2
  - 即: 近似解 ≤ 2 × 最优解

为什么有效?
  - MST 是 TSP 的松弛版本 (去掉"返回起点"和"每个城市一次"的约束)
  - MST 权重提供了最优解的下界
  - 基于 MST 的启发式通常能给出不错的可行解
```

### 应用 4: 🌐 聚类分析 (Hierarchical Clustering)

```
问题: 将 N 个数据点分成 K 个簇 (层次聚类)

算法: 单链接聚类 (Single Linkage Clustering)
  1. 初始时每个点自成一类 (N 个簇)
  2. 重复以下步骤直到只剩 K 个簇:
     a. 找到距离最近的两个簇
     b. 合并它们
  3. 这等价于 Kruskal 的逆过程!

与 MST 的关系:
  - Kruskal 从空图开始, 逐步加边, 直到连通
  - 层次聚类从完全图开始, 逐步去边, 直到分离
  - 两者都是基于"最小权重边"的贪心策略

应用:
  - 生物信息学 (基因序列聚类)
  - 社交网络 (社区发现)
  - 客户细分 (市场营销)
```

---

## 🧪 练习题

### 练习 1: 手动执行 Kruskal ⭐⭐

对于以下带权无向图，使用 Kruskal 算法找到 MST：

1. 写出所有边按权重排序后的顺序
2. 逐步选择边，标注 Union-Find 的变化
3. 给出最终的 MST 边集和总权重
4. 如果存在多个 MST，列出所有可能

```
    A ──(3)── B
   ╱│╲       │╱
 (5)(1)    (3)(4)
 ╱ │  ╲     │ ╱
C──(2)── D ── E
    (6)
```

<details>
<summary>📝 点击查看答案</summary>

```
边排序 (按权重升序):
  1. (A,D,1)  或 (C,D,2)  ← 取决于是否有权重为1的边
  2. (C,D,2)
  3. (A,B,3) 或 (D,E,3)
  4. (B,E,4)
  5. (A,C,5)
  6. (D,E,6)  ← 如果存在

Kruskal 执行过程 (假设边如上图):

  Step 1: 选 (A,D,1) → UF: {A,D}, {B}, {C}, {E}
  Step 2: 选 (C,D,2) → UF: {A,C,D}, {B}, {E}  ← 合并!
  Step 3: 选 (A,B,3) → UF: {A,B,C,D}, {E}   ← 合并!
  Step 4: 选 (D,E,3) → UF: {A,B,C,D,E}      ← 合并! 完成!

MST 边集 (4条, V-1=5-1=4):
  1. (A,D) 权重=1
  2. (C,D) 权重=2
  3. (A,B) 权重=3
  4. (D,E) 权重=3 (或 B,E 权重=4)

总权重: 1+2+3+3 = 9 (如果选 D,E)
      或 1+2+3+4 = 10 (如果选 B,E)

验证: 是否存在权重为 9 的 MST? ✅
```

</details>

### 练习 2: 编程实现 - 判断唯一性 ⭐⭐⭐

给定一个图，判断其最小生成树是否**唯一**。

```moonbit
/// 提示:
/// 1. 先运行 Kruskal 得到一个 MST
/// 2. 对于 MST 中的每条边，尝试用同权重的其他边替换
/// 3. 如果存在替代方案 → MST 不唯一
///
/// 或者更高效的方法:
/// 1. 检查是否存在"割"有多条相同最小权重的横跨边
/// 2. 如果存在这样的割 → MST 可能不唯一
```

<details>
<summary>💻 点击查看解答思路</summary>

```moonbit
/// 判断 MST 唯一性
pub fn[G : @core.GraphReadable] is_mst_unique(graph : G) -> Bool {
  // 方法: 检查是否对于每条被选中的边,
  //       都不存在同样权重的替代边

  let mst = kruskal(graph)

  // 收集 MST 中使用的权重
  let mut used_weights : Set[Double] = Set::new()
  for edge in mst.edges {
    match edge {
      (_, _, w) => used_weights.add(w)
    }
  }

  // 对于每个被使用的权重, 检查有多少条该权重的边
  for target_weight in used_weights {
    let mut same_weight_edges = 0
    let mut used_in_mst = 0

    // 统计...
    // (省略详细实现)

    // 如果存在未被使用的同权重边 → 可能不唯一
    // 需要进一步验证是否能替换而不破坏 MST 性质
  }

  true  // 简化版本: 假设唯一 (实际需要完整实现)
}
```

</details>

### 练习 3: 进阶 - 次小生成树 ⭐⭐⭐⭐

**挑战**: 找到**第二小**的生成树（即严格大于 MST 权重的最小生成树）。

**原理**:
- 对于 MST 中的每条边 e：
  1. 删除 e（图变成两个连通分量）
  2. 在连接这两个分量的边中，找**最小的那条**（称为 e 的"最佳替代"）
  3. 用替代边替换 e → 得到一个候选的次小生成树
- 对所有 e 重复上述过程，取最小值

**提示**:
- 可以利用 MST 的**环性质**: MST + 任何非树边 = 唯一的环
- 次小生成树 = MST - e + e' （其中 e' 是环中除 e 外最大的边？还是最小的？需要仔细思考！）

<details>
<summary>🔧 参考框架</summary>

```moonbit
/// 次小生成树 (Second Best MST)
///
/// 算法:
/// 1. 计算 MST
/// 2. 对于 MST 中的每条边 e:
///    a. 暂时删除 e
///    b. 在剩下的图中, 找连接 e 两端的最小边 e'
///    c. 记录候选: MST - e + e' 的权重
/// 3. 所有候选中最小的即为次小生成树
pub fn[G : @core.GraphReadable] second_best_mst(graph : G) -> MstResult {
  let primary_mst = kruskal(graph)
  let mut best_candidate : Option[MstResult] = None
  let mut best_weight = Double::max_value()

  // 尝试移除 MST 中的每条边
  for (remove_idx, removed_edge) in primary_mst.edges.indexed() {
    match removed_edge {
      (u, v, _) => {
        // 构造不含 removed_edge 的候选 MST
        let mut candidate_edges = []

        for (i, edge) in primary_mst.edges.indexed() {
          if (i != remove_idx) {
            candidate_edges.push(edge)
          }
        }

        // 寻找连接 u 和 v 的最小非树边 (需要遍历原图)
        let replacement = find_min_replacement_edge(graph, candidate_edges, u, v)

        match replacement {
          Some(repl_edge) => {
            let mut new_edges = candidate_edges
            new_edges.push(repl_edge)

            let new_total = calculate_total_weight(new_edges)

            if (new_total < best_weight && new_total > primary_mst.total_weight) {
              best_weight = new_total
              best_candidate = Some(MstResult::{
                total_weight: new_total,
                edges: new_edges
              })
            }
          }
          None => ()  // 无法替换 (图不连通)
        }
      }
    }
  }

  match best_candidate {
    Some(result) => result,
    None => primary_mst  // 不存在次小生成树 (返回 MST 本身)
  }
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/mst | 🏆 业界标杆，支持 Kruskal/Prim 对比模式 |
| Algorithm Visualizer | https://algorithm-visualizer.org/graphs/mst.html | 清晰的 Union-Find 可视化 |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/Kruskal.html | 学术风格，支持手动步进 |

### 理论延伸阅读

- **最短路径**: [Dijkstra 教程](/algorithms/shortest-path/dijkstra/)（另一种图优化问题）
- **网络流**: [Edmonds-Karp](/algorithms/flow/edmonds-karp/)（最大流最小割定理）
- **强连通分量**: [Tarjan SCC](/algorithms/connectivity/tarjan-scc/)（基于 DFS）
- **图着色**: [图着色算法](/algorithms/coloring/greedy/)（NP-hard 问题）

### 经典教材推荐

| 书名 | 作者 | 推荐章节 |
|------|------|----------|
| *Introduction to Algorithms (CLRS)* | Cormen et al. | Ch.23 Minimum Spanning Trees |
| *Algorithms* | Sedgewick & Wayne | Ch.4.3 Minimum Spanning Trees |
| 算法导论（中文版） | 殷建平等译 | 第23章 最小生成树 |

### mbtgraph API 参考

```moonbit
// 核心函数
@mst.kruskal(graph)              // Kruskal 算法 → MstResult
@mst.prim(graph, root)           // Prim 算法 (指定根节点) → MstResult

// 结果查询
result.total_weight               // Double (MST 总权重)
result.edges                      // Array[(NodeId, NodeId, Double)]
result.edge_count()               // Int (边数, 应为 V-1)
result.has_edge(u, v)            // Bool (某条边是否在 MST 中)

// Union-Find (内部使用, 也可独立调用)
@algo.mst.union_find_new(size)    // 创建 UF 结构
@algo.mst.union_find_find(uf, x)  // Int (查找代表元素)
@algo.mst.union_find_union(uf,x,y)// Bool (合并两个集合)
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** MST 的定义和三个关键属性（生成、树、最小）
- [ ] **理解** 割性质 (Cut Property) 及其在 Kruskal 正确性证明中的作用
- [ ] **手动执行** 小规模图的 Kruskal 过程（写出排序、UF 变化、选边序列）
- [ ] **手动执行** 小规模图的 Prim 过程（写出 key[] 变化、生长顺序）
- [ ] **实现** MoonBit 版本的 Kruskal（理解边排序 + Union-Find 环路检测）
- [ ] **实现** MoonBit 版本的 Prim（理解 key[] 维护、min_extract、松弛操作）
- [ ] **区分** Kruskal vs Prim 的适用场景（稀疏图 vs 稠密图）
- [ ] **分析** 两种算法的时间/空间复杂度（O(E log E) vs O(V²)）
- [ ] **应用** MST 到实际问题（网络设计/图像分割/TSP 近似/聚类分析）

> 💡 **下一步**: 尝试实现练习题中的**次小生成树**或 **MST 唯一性判断**，或者回到 [DFS 教程](/algorithms/traversal/dfs/index/) 学习拓扑排序——它也可以通过 MST 的变体来实现！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 MST:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_undirected_weighted_graph()

  // 方法 1: Kruskal
  let kruskal_mst = @mst.kruskal(g)
  println("Kruskal MST 总权重: ${kruskal_mst.total_weight}")

  // 方法 2: Prim
  let prim_mst = @mst.prim(g, @core.NodeId(0))
  println("Prim MST 总权重: ${prim_mst.total_weight}")

  // 验证一致性
  assert(kruskal_mst.total_weight == prim_mst.total_weight)
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看 MST 动画：<a href="https://visualgo.net/en/mst" target="_blank">https://visualgo.net/en/mst</a></p>
    <p>💡 <strong>重点观察</strong>: Kruskal 如何按权重依次选边并用 Union-Find 检测环路；Prim 如何像"生长树"一样从一个根节点逐步扩展到所有节点。</p>
  </div>
</div>
