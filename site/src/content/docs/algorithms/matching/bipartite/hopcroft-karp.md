---
title: "Hopcroft-Karp 算法：二分图最大匹配"
description: "BFS 分层 + DFS 增广，O(E√V) 时间复杂度，大规模二分图匹配的生产级选择"
---

# ⚡ Hopcroft-Karp 算法：二分图最大匹配

> **"如果说匈牙利算法是每次只给一个人安排相亲对象（一条一条找增广路），那 Hopcroft-Karp 就是先举办一场大型相亲会——把所有单身的人都按'距离'排好队，然后一次性撮合多对情侣。效率提升 √V 倍！"**

## 📖 目录

- [算法简介](#算法简介)
- [核心概念](#核心概念)
- [动画演示](#动画演示)
- [MoonBit 完整实现](#moonbit-完整实现)
- [代码详解](#代码详解)
- [Hopcroft-Karp vs Hungarian 深度对比](#hopcroft-karp-vs-hungarian-深度对比)
- [使用示例](#使用示例)
- [复杂度分析](#复杂度分析)
- [实际应用场景](#实际应用场景)
- [练习题](#练习题)
- [相关资源](#相关资源)
- [总结清单](#总结清单)

---

## 算法简介

### Hopcroft-Karp 是什么？

**Hopcroft-Karp 算法**（1973 年由 John Hopcroft 和 Richard Karp 提出）用于求解**二分图的最大匹配（Maximum Bipartite Matching）**问题。它在经典匈牙利算法的基础上做了关键优化：

```
┌─────────────────────────────────────────────────────────────┐
│                 HOPCROFT-KARP 三大优化                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ① BFS 分层 (Layered BFS)                                   │
│     └─ 一次 BFS 构建所有未匹配左节点的最短距离图               │
│                                                             │
│  ② 批量增广 (Multi-path Augmenting)                         │
│     └─ 一个 Phase 内找到多条不相交的最短增广路                │
│                                                             │
│  ③ 阶段迭代 (Phase-based Iteration)                         │
│     └─ 反复执行 BFS+DFS 直到不存在增广路                      │
│                                                             │
│  结果: O(VE) → O(E√V)，快 √V 倍!                           │
└─────────────────────────────────────────────────────────────┘
```

### 核心隐喻：相亲配对 🎎

想象一个**相亲场景**：

```
┌─────────────────────────────────────────────────────────┐
│                    相亲配对隐喻                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   左侧: 单身男士 (U 集合)          右侧: 单身女士 (V 集合) │
│                                                         │
│    U₀ 张三 ───┬──→ V₀ 小红                               │
│              ├──→ V₁ 小芳                               │
│    U₁ 李四 ───┼──→ V₁ 小芳                               │
│              └──→ V₂ 小丽                               │
│    U₂ 王五 ───┬──→ V₂ 小丽                               │
│              └──→ V₃ 小美                               │
│    U₃ 赵六 ───┴──→ V₃ 小美                               │
│                                                         │
│   目标: 撮合尽可能多的配对!                               │
│   约束: 每人只能配对一次                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘

匈牙利算法的做法:
  张三 → 先试小红, 成功! ✓ 配对 #1
  李四 → 试小芳, 成功! ✓ 配对 #2
  王五 → 试小丽, 但小丽没被占? 成功! ✓ 配对 #3
  赵六 → 试小美, 成功! ✓ 配对 #4
  (简单情况一次就搞定)

但如果有冲突:
  张三 → 小红 ✓
  李四 → 想要小芳, 但小芳也喜欢王五?
         → 需要递归调整已有的配对...
         → 一条一条地找增广路, 效率低!

Hopcroft-Karp 的做法:
  Phase 1: BFS 把所有男士按"距离自由女士的步数"分层
           dist[张三]=0, dist[李四]=0, dist[王五]=0, dist[赵六]=0
  Phase 1: DFS 在分层图上同时为多人找对象!
           一次可能撮合多对! ✨
```

### 为什么比匈牙利算法快？

```
匈牙利算法 (Hungarian / Kuhn's Algorithm):
  每次找 1 条增广路 → DFS/BFS → 增广 → 再 DFS → 再增广 ...
  问题: 增广路长度逐次增加, 后期每条路都很长!

Hopcroft-Karp:
  1 次 BFS 分层 → 在上面反复 DFS 增广多条路 → 直到本层阻塞
       → 再 BFS 重建分层图 → 再 DFS ...
  优势: 每次 BFS 的"成果"被多条增广路共享利用!

关键洞察:
  匈牙利: 每次增广 O(E), 共 O(V) 次增广 → O(VE)
  HC-Karp: 每个 phase 内可增广 O(√V) 条路, 仅需 O(√V) 个 phase
         → O(√V × E) = O(E√V)
```

### 算法主流程

```
┌──────────────────────────────────────────────────────────┐
│              HOPCROFT-KARP 主循环                          │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  初始化: pair_u[] = None, pair_v[] = None                │
│                                                          │
│  while true:                                             │
│    Phase 1: BFS 构建 dist[]                              │
│      ├─ 所有未匹配的 U 节点入队 (dist=0)                  │
│      ├─ BFS 遍历, 记录到每个 U 节点的最短距离              │
│      └─ 若遇到未匹配的 V 节点 → found_augment = true     │
│      若 !found_augment → break (无增广路, 结束!)         │
│                                                          │
│    Phase 2: DFS 多路增广                                 │
│      ├─ 对每个未匹配的 U 节点                             │
│      │   └─ 沿 dist[] 分层约束搜索增广路                  │
│      │       └─ 找到则更新 pair_u[], pair_v[]             │
│      └─ cardinality += 本轮成功数                        │
│                                                          │
│  返回 MatchingResult { matching_edges, cardinality }     │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 核心概念

### 📐 二分图 (Bipartite Graph)

图的顶点可分为两个**不相交**的集合 **U** 和 **V**，每条边连接 U 中的一个顶点和 V 中的一个顶点：

```
  U (左侧)              V (右侧)
  ┌─────┐              ┌─────┐
  │ U₀  │────────────→│ V₀  │
  │     │              │     │
  │ U₁  │──────┬──────→│ V₁  │
  │     │      │       │     │
  │ U₂  │──────┼───→   │ V₂  │
  │     │      │       │     │
  │ U₃  │──────┴───→   │ V₃  │
  └─────┘              └─────┘

  关键性质: U 内部无边, V 内部也无边
            所有边都是跨集合的!
```

### 🔗 匹配 (Matching)

**匹配** M 是一组边的集合，满足：**任意两条边没有公共端点**。

```
  匹配 M = {(U₀,V₀), (U₂,V₂)}  ← 合法的匹配 (无公共端点)

  U₀ ━━━ V₀     ← 匹配边 (粗线)
  U₁ ── V₁
  U₂ ━━━ V₂     ← 匹配边 (粗线)
  U₃ ── V₃

  cardinality(M) = |M| = 2  (匹配数/基数)
```

### 🛣️ 增广路 (Augmenting Path)

**增广路**是一条交替经过**非匹配边**和**匹配边**的路径，且：
- 起点**和终点都是未匹配节点**
- 路径长度为**奇数**（边数为奇数）

```
  增广路示例:

  U₀(自由) ──→ V₁(已匹配) ━━ U₁(已匹配) ──→ V₂(自由)

  边的类型交替:
    U₀→V₁ : 非匹配边 (实线)
    V₁━U₁ : 匹配边   (粗线/虚线)
    U₁→V₂ : 非匹配边 (实线)

  操作: 沿增广路翻转匹配状态!
    原来: (V₁,U₁) 是匹配边
    翻转后: (U₀,V₁) 和 (U₁,V₂) 变成匹配边
    结果: 匹配数 +1! ✨
```

**增广路定理（Berge 定理）**：
> 当且仅当图中**不存在增广路**时，当前匹配是**最大匹配**。

这是所有匹配类算法的理论基础！

### 📊 BFS 分层图 (Layered Graph)

Hopcroft-Karp 的核心创新！通过 BFS 给左侧每个节点分配一个**距离标记**：

```
原始二分图:                    BFS 分层后 (dist[]):

  U₀ ──→ V₀                     dist[U₀] = 0  (未匹配, 入队起点)
  │     ↑                        dist[U₁] = 0  (未匹配, 入队起点)
  ↓     │ 匹配                   dist[U₂] = -1 (已匹配, 暂不处理)
  U₁ ━━ V₁                       dist[U₃] = 0  (未匹配, 入队起点)
  │                              (dist 只记录 U 侧节点的层级)
  ↓
  U₂ ──→ V₁
  │
  ↓
  U₃ ──→ V₂

BFS 规则:
  1. 未匹配的 U 节点 dist=0, 作为 BFS 起点
  2. 从 Uᵢ 出发走非匹配边到 Vⱼ:
     - 如果 Vⱼ 未匹配 → 发现增广路! found=true
     - 如果 Vⱼ 已匹配(配对 Uₖ) 且 dist[Uₖ]=-1:
       → dist[Uₖ] = dist[Uᵢ] + 1, Uₖ 入队
  3. DFS 时只允许从 dist=d 的 U 走到 dist=d+1 的 U
     → 保证沿最短增广路前进!
```

### 👥 匹配数组 (pair_u[] 和 pair_v[])

两个核心数据结构，分别记录左右两侧节点的配对情况：

```moonbit
pair_u : Array[Int?]   // pair_u[i] = j 表示 Uᵢ 与 Vⱼ 配对
pair_v : Array[Int?]   // pair_v[j] = i 表示 Vⱼ 与 Uᵢ 配对

// 示例状态:
// pair_u = [Some(1), Some(0), None, Some(3)]
//   → U₀↔V₁, U₁↔V₀, U₂自由, U₃↔V₃
// pair_v = [Some(1), Some(0), None, Some(3)]
//   → V₀↔U₁, V₁↔U₀, V₂自由, V₃↔U₃
//
// 不变式: pair_u[i] == Some(j) ⇔ pair_v[j] == Some(i)
```

---

## 动画演示

### 示例二分图

使用一个 **4×4 二分图**，完整展示 Hopcroft-Karp 的执行过程：

```
          左侧 (U)                  右侧 (V)
        ┌──────────┐              ┌──────────┐
        │          │              │          │
        │   U₀    ─┼──────────→   │   V₀     │
        │          │              │          │
        │   U₁    ─┼──┬────────→  │   V₁     │
        │          │  │           │     ↑    │
        │   U₂    ─┼──┼───────→  │   V₂ ────┘
        │          │  │           │          │
        │   U₃    ─┼──┴───────→  │   V₃     │
        │          │              │          │
        └──────────┘              └──────────┘

   边集 (8 条边):
     U₀ → V₀
     U₁ → V₀, U₁ → V₁
     U₂ → V₁, U₂ → V₂
     U₃ → V₂, U₃ → V₃

   最大匹配数预期: 4 (完美匹配!)
   可能方案之一: (U₀,V₀), (U₁,V₁), (U₂,V₂), (U₃,V₃)
```

---

### 🎬 第 1 阶段：BFS 分层

```
初始状态:
  pair_u = [None, None, None, None]   // 所有人都单身
  pair_v = [None, None, None, None]
  dist   = [?, ?, ?, ?]
  cardinality = 0

═════════════════════════════════════════════
  BFS 开始 — Step 1: 初始化队列
═════════════════════════════════════════════

  遍历所有 U 节点:
    U₀: pair_u[0] = None → dist[0] = 0, 入队
    U₁: pair_u[1] = None → dist[1] = 0, 入队
    U₂: pair_u[2] = None → dist[2] = 0, 入队
    U₃: pair_u[3] = None → dist[3] = 0, 入队

  queue = [0, 1, 2, 3]    // 所有未匹配 U 节点
  q_head = 0
  found_augment = false

═════════════════════════════════════════════
  BFS — Step 2: 处理 U₀ (dist=0)
═════════════════════════════════════════════

  cur_u = 0, 遍历 adj[0] = [0] (即 U₀→V₀)

  检查 V₀:
    pair_v[0] = None (V₀ 自由!)
    → found_augment = true ⚡  (发现潜在增广!)

  q_head = 1

═════════════════════════════════════════════
  BFS — Step 3: 处理 U₁ (dist=0)
═════════════════════════════════════════════

  cur_u = 1, 遍历 adj[1] = [0, 1] (即 U₁→V₀, U₁→V₁)

  检查 V₀:
    pair_v[0] = None → found_augment 已为 true (不变)

  检查 V₁:
    pair_v[1] = None → found_augment 已为 true (不变)

  q_head = 2

═════════════════════════════════════════════
  BFS — Step 4: 处理 U₂ (dist=0)
═════════════════════════════════════════════

  cur_u = 2, 遍历 adj[2] = [1, 2] (即 U₂→V₁, U₂→V₂)

  检查 V₁: pair_v[1] = None → 不变
  检查 V₂: pair_v[2] = None → 不变

  q_head = 3

═════════════════════════════════════════════
  BFS — Step 5: 处理 U₃ (dist=0)
═════════════════════════════════════════════

  cur_u = 3, 遍历 adj[3] = [2, 3] (即 U₃→V₂, U₃→V₃)

  检查 V₂: pair_v[2] = None → 不变
  检查 V₃: pair_v[3] = None → 不变

  q_head = 4, 队列空!

  found_augment = true → 继续 DFS 阶段!

📋 BFS 结果汇总:
  dist = [0, 0, 0, 0]    // 第一轮所有人都是第 0 层
                          // (因为初始时所有人都未匹配,
                          //   所以没有"通过匹配边回溯"的过程)

可视化分层图:
  Layer 0:  U₀  U₁  U₂  U₃    ← 全部未匹配, 都是起点
               ↘  ↓  ↙  ↓
  (直接到达) V₀  V₁  V₂  V₃    ← 全部自由, 都能终止增广路
```

---

### 🎬 第 1 阶段：DFS 多路增广

```
═════════════════════════════════════════════
  DFS — 处理 U₀ (pair_u[0] = None, 可尝试)
═════════════════════════════════════════════

  hopcroft_karp_dfs(u=0):
    遍历 adj[0] = [0], 即检查 V₀:

    pair_v[0] = None (V₀ 自由!)
    → 直接配对!
      pair_u[0] = Some(0)   // U₀ ↔ V₀
      pair_v[0] = Some(0)
    → return true ✅

  cardinality = 0 + 1 = 1

  🎉 第 1 对配对: (U₀, V₀)

═════════════════════════════════════════════
  DFS — 处理 U₁ (pair_u[1] = None, 可尝试)
═════════════════════════════════════════════

  hopcroft_karp_dfs(u=1):
    遍历 adj[1] = [0, 1]:

    检查 V₀ (i=0):
      pair_v[0] = Some(0) (V₀ 已被 U₀ 占了!)

      → 尝试让 U₀ 让出 V₀?
        u2 = 0 (V₀ 的现任搭档)
        需要: dist[0] == dist[1] + 1 ?
              即: 0 == 0 + 1 ? → 0 == 1 ? ❌ 不满足!

        → 跳过 V₀ (不满足分层约束)

    检查 V₁ (i=1):
      pair_v[1] = None (V₁ 自由!)
      → 直接配对!
        pair_u[1] = Some(1)   // U₁ ↔ V₁
        pair_v[1] = Some(1)
      → return true ✅

  cardinality = 1 + 1 = 2

  🎉 第 2 对配对: (U₁, V₁)

═════════════════════════════════════════════
  DFS — 处理 U₂ (pair_u[2] = None, 可尝试)
═════════════════════════════════════════════

  hopcroft_karp_dfs(u=2):
    遍历 adj[2] = [1, 2]:

    检查 V₁ (i=0):
      pair_v[1] = Some(1) (V₁ 被 U₁ 占了!)
      u2 = 1
      需要: dist[1] == dist[2] + 1 ? → 0 == 1 ? ❌ 跳过

    检查 V₂ (i=1):
      pair_v[2] = None (V₂ 自由!)
      → 直接配对!
        pair_u[2] = Some(2)   // U₂ ↔ V₂
        pair_v[2] = Some(2)
      → return true ✅

  cardinality = 2 + 1 = 3

  🎉 第 3 对配对: (U₂, V₂)

═════════════════════════════════════════════
  DFS — 处理 U₃ (pair_u[3] = None, 可尝试)
═════════════════════════════════════════════

  hopcroft_karp_dfs(u=3):
    遍历 adj[3] = [2, 3]:

    检查 V₂ (i=0):
      pair_v[2] = Some(2) (V₂ 被 U₂ 占了!)
      u2 = 2
      需要: dist[2] == dist[3] + 1 ? → 0 == 1 ? ❌ 跳过

    检查 V₃ (i=1):
      pair_v[3] = None (V₃ 自由!)
      → 直接配对!
        pair_u[3] = Some(3)   // U₃ ↔ V₃
        pair_v[3] = Some(3)
      → return true ✅

  cardinality = 3 + 1 = 4

  🎉 第 4 对配对: (U₃, V₃)

═════════════════════════════════════════════
  Phase 1 完成!
═════════════════════════════════════════════

  当前匹配状态:
    pair_u = [Some(0), Some(1), Some(2), Some(3)]  // 全部配对!
    pair_v = [Some(0), Some(1), Some(2), Some(3)]  // 全部配对!
    cardinality = 4

  匹配边: (U₀,V₀), (U₁,V₁), (U₂,V₂), (U₃,V₃)
  这是一个完美匹配! 💎
```

---

### 🎬 第 2 阶段：BFS 分层（验证无更多增广路）

```
═════════════════════════════════════════════
  Phase 2: BFS 再次分层
═════════════════════════════════════════════

  遍历所有 U 节点初始化:
    U₀: pair_u[0] = Some(0) → dist[0] = -1 (已匹配, 不是起点)
    U₁: pair_u[1] = Some(1) → dist[1] = -1
    U₂: pair_u[2] = Some(2) → dist[2] = -1
    U₃: pair_u[3] = Some(3) → dist[3] = -1

  queue = []  ← 空! 没有未匹配的 U 节点可以入队!

  BFS 立即结束, found_augment = false

⛔ found_augment = false → 算法终止!

🎉 最终结果: MAXIMUM MATCHING = 4 (完美匹配!)
   匹配边: [(U₀,V₀), (U₁,V₁), (U₂,V₂), (U₃,V₃)]

✨ 这个例子太理想了, 一次 Phase 就完成了!
   下面看一个需要多 Phase 的例子...
```

---

### 🎬 更复杂的例子：需要多 Phase 的场景

让我们用一个更有趣的图来展示**真正的增广过程**：

```
          左侧 (U)                  右侧 (V)
        ┌──────────┐              ┌──────────┐
        │          │              │          │
        │   U₀    ─┼──────────→   │   V₀     │
        │          │              │          │
        │   U₁    ─┼──────────→   │   V₀     │  ← 冲突!
        │          │              │     ↑    │
        │   U₂    ─┼──────────→   │   V₁ ────┘
        │          │              │          │
        └──────────┘              └──────────┘

   边集: U₀→V₀, U₁→V₀, U₂→V₁
   最大匹配 = 2 (不是 3, 因为只有 2 个右侧节点)
```

#### Phase 1 — BFS 分层

```
初始: pair_u = [None, None, None], pair_v = [None, None]

BFS 初始化:
  U₀: 未匹配 → dist[0]=0, 入队
  U₁: 未匹配 → dist[1]=0, 入队
  U₂: 未匹配 → dist[2]=0, 入队
  queue = [0, 1, 2]

处理 U₀ (dist=0):
  adj[0]=[0], 检查 V₀: pair_v[0]=None → found_augment=true

处理 U₁ (dist=0):
  adj[1]=[0], 检查 V₀: pair_v[0]=None → found_augment=true (不变)

处理 U₂ (dist=0):
  adj[2]=[1], 检查 V₁: pair_v[1]=None → found_augment=true (不变)

dist = [0, 0, 0], found_augment = true
```

#### Phase 1 — DFS 增广

```
DFS(U₀): adj[0]=[0], V₀ 自由 → pair_u[0]=Some(0), pair_v[0]=Some(0) ✅
  cardinality = 1  匹配: (U₀,V₀)

DFS(U₁): adj[1]=[0], V₀ 被 U₀ 占了(u2=0)
  需要 dist[0]==dist[1]+1? 0==1? ❌ → 跳过
  无更多邻居 → dist[1]=-1, return false ❌
  cardinality = 1 (不变)

DFS(U₂): adj[2]=[1], V₁ 自由 → pair_u[2]=Some(1), pair_v[1]=Some(2) ✅
  cardinality = 2  匹配: (U₀,V₀), (U₂,V₁)

Phase 1 结果: cardinality = 2
  pair_u = [Some(0), None, Some(1)]
  pair_v = [Some(0), Some(2)]
```

#### Phase 2 — BFS 分层（尝试为 U₁ 找对象）

```
BFS 初始化:
  U₀: pair_u[0]=Some(0) → dist[0]=-1
  U₁: pair_u[1]=None    → dist[1]=0, 入队  ⭐ U₁ 还单身!
  U₂: pair_u[2]=Some(1) → dist[2]=-1
  queue = [1]

处理 U₁ (dist=0):
  adj[1]=[0], 检查 V₀:
    pair_v[0] = Some(0) (V₀ 被 U₀ 占了!)
    u2 = 0, dist[0] == -1 → 可以扩展!
    dist[0] = dist[1] + 1 = 1
    queue.push(0)

处理 U₀ (dist=1):
  adj[0]=[0], 检查 V₀:
    pair_v[0] = Some(0) (还是被 U₀ 自己占了...等等)
    
    实际上这里 U₀ 通过匹配边 "属于" V₀
    我们在找的是: U₁→V₀(非匹配)→U₀(匹配边回溯)→?

    U₀ 的邻居只有 V₀, 而 V₀ 已经被检查过了
    → U₀ 没有其他非匹配边可以走
    → dist[0] 保持 = 1, 但无法继续扩展

  队列空! found_augment = false

⛔ 无增广路 → 算法终止!

🎉 最终结果: MAX_MATCHING = 2
   这是最优解! (右侧只有 2 个节点, 最多匹配 2 对)
   U₁ 无法配对, 因为 V₀ 和 V₁ 都已被占用
```

---

### 📊 完整执行过程汇总

```
═══════════════════════════════════════════════════════
           HOPCROFT-KARP 执行总览 (4×4 完美匹配)
═══════════════════════════════════════════════════════

  【Phase 1】— 初始全自由状态
  ┌─────────────────────────────────────────────────┐
  │                                                  │
  │  BFS 分层:                                       │
  │    dist = [0, 0, 0, 0]  (全部未匹配)             │
  │    found_augment = true                         │
  │                                                  │
  │  DFS 增广:                                       │
  │    U₀ → V₀ (自由) ✅  配对 #1                    │
  │    U₁ → V₁ (自由) ✅  配对 #2                    │
  │    U₂ → V₂ (自由) ✅  配对 #3                    │
  │    U₃ → V₃ (自由) ✅  配对 #4                    │
  │                                                  │
  │  Phase 1 贡献: +4                                │
  │  cardinality = 4 (完美匹配!)                     │
  │                                                  │
  └─────────────────────────────────────────────────┘

  【Phase 2】— 验证阶段
  ┌─────────────────────────────────────────────────┐
  │                                                  │
  │  BFS 分层:                                       │
  │    所有 U 节点均已匹配 → queue 为空              │
  │    found_augment = false                        │
  │                                                  │
  │  ⛔ 终止! 无增广路存在                           │
  │                                                  │
  │  Phase 2 贡献: +0                                │
  │                                                  │
  └─────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════
  最终结果: MAX_MATCHING = 4 (完美匹配 💎)
  匹配边: (U₀,V₀), (U₁,V₁), (U₂,V₂), (U₃,V₃)
  总 Phase 数: 1 (最优情况!)
═══════════════════════════════════════════════════════


═══════════════════════════════════════════════════════
        HOPCROFT-KARP 执行总览 (3×2 冲突图)
═══════════════════════════════════════════════════════

  【Phase 1】
  ┌─────────────────────────────────────────────────┐
  │  BFS: dist=[0,0,0], found=true                  │
  │                                                  │
  │  DFS:                                            │
  │    U₀ → V₀ ✅ 配对 #1                            │
  │    U₁ → V₀ ❌ 被占, 无替代                       │
  │    U₂ → V₁ ✅ 配对 #2                            │
  │                                                  │
  │  cardinality = 2                                 │
  └─────────────────────────────────────────────────┘

  【Phase 2】
  ┌─────────────────────────────────────────────────┐
  │  BFS: 只有 U₁ 未匹配, 入队                       │
  │    U₁→V₀(被U₀占)→dist[U₀]=1                     │
  │    U₀ 无其他自由邻居可达                         │
  │    found=false → 终止!                          │
  │                                                  │
  │  cardinality = 2 (已达最大!)                     │
  └─────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════
  最终结果: MAX_MATCHING = 2 (最优解)
  U₁ 无法配对 (右侧容量不足)
═══════════════════════════════════════════════════════
```

---

## MoonBit 完整实现

以下是 mbtgraph 中 Hopcroft-Karp 的完整实现：

```moonbit
///|
/// Hopcroft-Karp 二分图最大匹配算法
///
/// 时间复杂度 O(E√V)，比匈牙利算法(VE)更快，适合大规模稀疏二分图。
/// 使用 BFS 分层 + DFS 增广，交替进行。
///
/// ## 参数
/// - `g`: 实现了 GraphReadable 的图结构
/// - `left_nodes`: 左部节点集合 (U 分区)
/// - `right_nodes`: 右部节点集合 (V 分区)
///
/// ## 返回
/// MatchingResult 包含匹配边列表和匹配数
pub fn[G : @core.GraphReadable] hopcroft_karp(
  graph : G,
  left_nodes : Array[@core.NodeId],
  right_nodes : Array[@core.NodeId],
) -> MatchingResult {
  if left_nodes.length() == 0 || right_nodes.length() == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  let n_left = left_nodes.length()
  let n_right = right_nodes.length()

  let adj : Array[Array[Int]] = Array::make(n_left, [])
  let mut u_idx = 0
  while u_idx < n_left {
    let u_node = left_nodes[u_idx]
    for v_node in @core.GraphReadable::neighbors(graph, u_node) {
      match find_node_index(v_node, right_nodes) {
        Some(v_idx) => adj[u_idx].push(v_idx)
        None => ()
      }
    }
    u_idx = u_idx + 1
  }

  hopcroft_karp_impl(n_left, n_right, adj)
}

///|
/// Hopcroft-Karp 核心实现（索引版本）
fn hopcroft_karp_impl(
  n_left : Int,
  n_right : Int,
  adj : Array[Array[Int]],
) -> MatchingResult {
  if n_left == 0 || n_right == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  let pair_u : Array[Int?] = Array::make(n_left, None)
  let pair_v : Array[Int?] = Array::make(n_right, None)
  let dist : Array[Int] = Array::make(n_left, 0)
  let mut cardinality = 0

  while true {
    // === BFS Phase: 构建分层图 ===
    let queue : Array[Int] = []
    let mut q_head = 0

    let mut u = 0
    while u < n_left {
      match pair_u[u] {
        None => {
          dist[u] = 0
          queue.push(u)
        }
        Some(_) => dist[u] = -1
      }
      u = u + 1
    }

    let mut found_augment = false

    while q_head < queue.length() {
      let cur_u = queue[q_head]
      q_head = q_head + 1

      let mut i = 0
      while i < adj[cur_u].length() {
        let v = adj[cur_u][i]
        match pair_v[v] {
          None => found_augment = true
          Some(u2) =>
            if dist[u2] == -1 {
              dist[u2] = dist[cur_u] + 1
              queue.push(u2)
            }
        }
        i = i + 1
      }
    }

    if !found_augment {
      break
    }

    // === DFS Phase: 在分层图上搜索增广路 ===
    let mut u = 0
    while u < n_left {
      match pair_u[u] {
        None =>
          if hopcroft_karp_dfs(u, adj, pair_u, pair_v, dist) {
            cardinality = cardinality + 1
          }
        Some(_) => ()
      }
      u = u + 1
    }
  }

  // 转换结果：pair_v 中的匹配转回 (NodeId, NodeId)
  let result_edges : Array[(@core.NodeId, @core.NodeId)] = []
  let mut v = 0
  while v < n_right {
    match pair_v[v] {
      Some(u_val) =>
        result_edges.push((@core.NodeId(u_val), @core.NodeId(n_left + v)))
      None => ()
    }
    v = v + 1
  }

  MatchingResult::{ matching_edges: result_edges, cardinality }
}

///|
/// DFS 增广路搜索（基于 BFS 分层图）
fn hopcroft_karp_dfs(
  u : Int,
  adj : Array[Array[Int]],
  pair_u : Array[Int?],
  pair_v : Array[Int?],
  dist : Array[Int],
) -> Bool {
  let mut i = 0
  while i < adj[u].length() {
    let v = adj[u][i]
    match pair_v[v] {
      None => {
        pair_u[u] = Some(v)
        pair_v[v] = Some(u)
        return true
      }
      Some(u2) =>
        if dist[u2] == dist[u] + 1 &&
          hopcroft_karp_dfs(u2, adj, pair_u, pair_v, dist) {
          pair_u[u] = Some(v)
          pair_v[v] = Some(u)
          return true
        }
    }
    i = i + 1
  }
  dist[u] = -1
  false
}
```

---

## 代码详解

### 设计决策 1️⃣：为什么使用索引而非 NodeId？

```moonbit
let adj : Array[Array[Int]] = Array::make(n_left, [])
// adj[i] 存储的是右侧节点的索引 (0..n_right-1)，而非 NodeId
```

**原因**：内部计算使用连续整数索引比 `NodeId` 类型更高效：
- 数组下标直接访问：`O(1)` vs `find_node_index` 的线性查找
- 减少类型包装开销
- `pair_u[]`, `pair_v[]`, `dist[]` 都使用 Int 索引，保持一致

**转换时机**：仅在最终输出时将索引转回 `NodeId`：
```moonbit
result_edges.push((@core.NodeId(u_val), @core.NodeId(n_left + v)))
// 左侧: NodeId(u_val), 右侧: NodeId(n_left + v)
```

### 设计决策 2️⃣：BFS 中 `found_augment` 的提前发现机制

```moonbit
match pair_v[v] {
  None => found_augment = true    // 遇到自由 V 节点即可标记
  Some(u2) =>                     // V 已匹配, 尝试通过匹配边扩展
    if dist[u2] == -1 {
      dist[u2] = dist[cur_u] + 1
      queue.push(u2)
    }
}
```

**精妙之处**：BFS **不需要走到增广路的终点**，只要确认存在至少一个自由 V 节点可达即可设置 `found_augment = true`。

**效果**：
- BFS 的目标是构建 `dist[]` 分层图，而非寻找单条路径
- 即使找到了自由 V 节点也**继续完成整个 BFS**（保证 `dist[]` 完整）
- `found_augment` 只是告诉外层循环"是否还有必要做 DFS"

### 设计决策 3️⃣：DFS 中的 `dist[u] = -1` 剪枝

```moonbit
fn hopcroft_karp_dfs(u, adj, pair_u, pair_v, dist) -> Bool {
  // ... 遍历所有邻接 V 节点 ...
  // 所有路径都失败后:
  dist[u] = -1   // 标记此节点在本 Phase 中不可达
  false
}
```

**作用**：当从节点 `u` 出发找不到任何增广路时，将 `dist[u]` 设为 `-1`。

**效果**：
- 同一 Phase 内后续的 DFS 调用会跳过此节点（因为 `dist[u2] == dist[u] + 1` 条件不满足）
- 避免**重复搜索**已知失败的路径
- 这是 HC-Karp 达到 O(E√V) 的关键剪枝之一

**类比**：就像相亲时如果某个人已经尝试过所有可能的配对对象都失败了，本轮就不必再为他/她安排相亲了。

### 设计决策 4️⃣：为什么 HC-Karp 比 Hungarian 快 √V 倍？

```
理论分析 (核心证明直觉):

Hungarian (Kuhn) 算法:
  每次找 1 条增广路, 每条路使匹配数 +1
  最短增广路长度随匹配增大而增长
  增广次数 = O(V) (最多 V/2 次, 每次增加 1 条边)
  每次增广 = O(E)
  总计 = O(VE)

Hopcroft-Karp:
  关键引理: 连续两次 Phase 之间, 最短增广路长度严格增加!
  
  证明直觉:
    Phase k 找到了所有长度 ≤ d_k 的最短增广路
    Phase k+1 的最短增广路长度 ≥ d_k + 1
    
  推论:
    最短增广路最长 = O(√V)  (Phase 数量上限)
    为什么是 √V 而不是 V?
      → 每个 Phase 至少找到 ⌊d/2⌋ 条不相交增广路 (Dilworth 定理相关)
      → 或更直观地: 短路被快速消耗, 长路不需要太多 Phase
  
  每个 Phase 的工作量:
    BFS: O(V+E)
    DFS: O(所有增广路上的边) = O(V·phase_path_length)
    单个 Phase ≈ O(E)
  
  总计 = O(√V × E) = O(E√V)

速度提升倍数: VE / (E√V) = √V
  当 V=10000 时, 快 100 倍!
  当 V=1000000 时, 快 1000 倍!
```

---

## Hopcroft-Karp vs Hungarian 深度对比

### 代码结构对比

```
┌─────────────────────────────────────────────────────────────┐
│                  HUNGARIAN 结构                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  for each u in U:                                          │
│    visited[] = false                                       │
│    if dfs_find_augmenting_path(u):                         │
│      matching_count += 1     ← 每次 1 条路                 │
│                                                             │
│  → 简单直观, 但每条路独立搜索                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                 HOPCROFT-KARP 结构                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  while true:                                                │
│    bfs_layer() → (dist[], found)  ← 构建全局分层图         │
│    if !found: break                                        │
│                                                             │
│    for each free_u in U:                                   │
│      if dfs_augment(free_u):       ← 多条路并行搜索!       │
│        matching_count += 1                                │
│                                                             │
│  → BFS 共享, DFS 批量, 分层加速                            │
└─────────────────────────────────────────────────────────────┘
```

### 全面对比表

| 方面 | Hungarian (Kuhn) | Hopcroft-Karp |
|------|-------------------|---------------|
| **时间复杂度** | O(VE) | **O(E√V)** |
| **空间复杂度** | O(V) | O(V+E) |
| **搜索策略** | 每次找 1 条增广路 | BFS 分层 + 多路增广 |
| **路径记录** | `visited[]` (单次) | `dist[]` (全局分层) |
| **增广方式** | 逐条增广 | **批量增广** |
| **实现难度** | ⭐ 简单 | ⭐⭐ 中等 |
| **适用规模** | V < 5,000 | **V > 5,000** |
| **Phase 概念** | 无 | **有 (BFS+DFS 组合)** |
| **最优性** | 保证 | **保证** |

### 性能实测对比（直觉）

```
假设二分图: V=10,000 (每侧 5000), E=50,000

Hungarian:
  增广次数 ≈ V/2 = 5000 次
  每次 O(E) = O(50000)
  总计 ≈ 5000 × 50000 = 2.5 × 10⁸ 次操作

Hopcroft-Karp:
  Phase 数 ≈ √V ≈ 100 次
  每个 Phase 内增广 ≈ √V ≈ 50 条
  每个 Phase 工作量 ≈ O(E) = O(50000)
  总计 ≈ 100 × 50000 = 5 × 10⁶ 次操作

提速比: 2.5×10⁸ / 5×10⁶ = 50 倍! 🚀
```

### 选型指南

```
选择 Hungarian 当:
  ✅ 学习匹配算法概念 (最易理解)
  ✅ 图规模很小 (V < 1000)
  ✅ 代码简洁性优先
  ✅ 需要逐步调试中间过程

选择 Hopcroft-Karp 当:
  ✅ 生产环境 / 大规模数据 (V > 5000)
  ✅ 二分图匹配的标准选择
  ✅ 需要多次求解匹配问题
  ✅ 性能至关重要

选择 Kuhn-Munkres 当:
  ✅ 带权二分图完美匹配 (分配问题)
  ✅ 需要最小/最大权值和
  ✅ 任务调度、指派问题
```

---

## 使用示例

### 示例 1：基础用法 — 求职者与岗位匹配

```moonbit
use lib.algo.matching.{hopcroft_karp, MatchingResult}
use lib.storage.{new_directed}
use lib.core.{GraphWritable, GraphReadable}

fn main {
  // 场景: 4 名求职者申请 4 个岗位
  // 求职者: U₀=张三, U₁=李四, U₂=王五, U₃=赵六
  // 岗位:   V₀=前端, V₁=后端, V₂=算法, V₃=测试

  let g = new_directed()
  for i in 0..<8 {
    GraphWritable::add_node(g, i.to_double()) |> ignore
  }

  // 张三擅长前端和后端
  GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0) |> ignore
  GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(5), 1.0) |> ignore

  // 李四擅长后端和算法
  GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(5), 1.0) |> ignore
  GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(6), 1.0) |> ignore

  // 王五擅长算法和测试
  GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(6), 1.0) |> ignore
  GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(7), 1.0) |> ignore

  // 赵六擅长测试和前端
  GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(7), 1.0) |> ignore
  GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0) |> ignore

  let left = [
    @core.NodeId(0), @core.NodeId(1),
    @core.NodeId(2), @core.NodeId(3),
  ]
  let right = [
    @core.NodeId(4), @core.NodeId(5),
    @core.NodeId(6), @core.NodeId(7),
  ]

  let result = hopcroft_karp(g, left, right)

  println("最大匹配数: ${result.cardinality}")
  // 输出: 最大匹配数: 4

  println("匹配详情:")
  for edge in result.matching_edges {
    match edge {
      (u, v) => {
        let names_u = ["张三", "李四", "王五", "赵六"]
        let names_v = ["前端", "后端", "算法", "测试"]
        println("  ${names_u[u.0]} → ${names_v[v.0 - 4]}")
      }
    }
  }
  // 输出示例:
  //   张三 → 前端
  //   李四 → 后端
  //   王五 → 算法
  //   赵六 → 测试
}
```

### 示例 2：课程与学生选课冲突检测

```moonbit
// 使用 Hopcroft-Karp 检测课程安排中的冲突
// 左侧: 学生, 右侧: 课程时间段
// 目标: 最大化不冲突的选课安排

fn schedule_courses(
  student_count : Int,
  time_slot_count : Int,
  preferences : Array[(Int, Int)],  // (学生索引, 时间段索引)
) -> MatchingResult {
  let g = new_directed()
  let total_nodes = student_count + time_slot_count
  for i in 0..<total_nodes {
    GraphWritable::add_node(g, i.to_double()) |> ignore
  }

  for pref in preferences {
    let (s, t) = pref
    GraphWritable::add_edge(
      g, @core.NodeId(s), @core.NodeId(student_count + t), 1.0
    ) |> ignore
  }

  let left : Array[@core.NodeId] = []
  let mut s = 0
  while s < student_count {
    left.push(@core.NodeId(s))
    s = s + 1
  }

  let right : Array[@core.NodeId] = []
  let mut t = 0
  while t < time_slot_count {
    right.push(@core.NodeId(student_count + t))
    t = t + 1
  }

  hopcroft_karp(g, left, right)
}

// 5 名学生, 3 个时间段, 各自偏好
let prefs : Array[(Int, Int)] = [
  (0, 0), (0, 1),       // 学生0: 偏好时段0, 1
  (1, 1), (1, 2),       // 学生1: 偏好时段1, 2
  (2, 0), (2, 2),       // 学生2: 偏好时段0, 2
  (3, 0), (3, 1),       // 学生3: 偏好时段0, 1
  (4, 1), (4, 2),       // 学生4: 偏好时段1, 2
]

let result = schedule_courses(5, 3, prefs)
println("可安排的最大选课数: ${result.cardinality}")
// 输出: 3 (只有 3 个时间段, 最多 3 人不冲突)

// 查看哪些学生未能选课
let mut unmatched : Array[Int] = []
let mut idx = 0
while idx < 5 {
  if !result.is_matched(@core.NodeId(idx)) {
    unmatched.push(idx)
  }
  idx = idx + 1
}
println("未安排的学生: ${unmatched}")
```

### 示例 3：大规模社交网络推荐 — 用户与兴趣标签匹配

```moonbit
// 大规模二分图匹配实战
// 场景: 将用户推荐到兴趣小组 (一人一组)

fn recommend_groups(
  user_count : Int,
  group_count : Int,
  user_interests : Array[(Int, Int)],
) -> (Int, Array[(@core.NodeId, @core.NodeId)]) {
  let g = new_directed()
  let total = user_count + group_count
  for i in 0..<total {
    GraphWritable::add_node(g, i.to_double()) |> ignore
  }

  for (u, grp) in user_interests {
    GraphWritable::add_edge(
      g, @core.NodeId(u), @core.NodeId(user_count + grp), 1.0
    ) |> ignore
  }

  let left : Array[@core.NodeId] = []
  let mut i = 0
  while i < user_count {
    left.push(@core.NodeId(i))
    i = i + 1
  }

  let right : Array[@core.NodeId] = []
  let mut j = 0
  while j < group_count {
    right.push(@core.NodeId(user_count + j))
    j = j + 1
  }

  let result = hopcroft_karp(g, left, right)
  (result.cardinality, result.matching_edges)
}

// 大规模测试: 1000 用户 × 500 兴趣小组, 5000 条兴趣关联
let large_interests : Array[(Int, Int)] = []
let mut k = 0
while k < 5000 {
  large_interests.push((k % 1000, (k * 7 + 13) % 500))
  k = k + 1
}

let (match_count, edges) = recommend_groups(1000, 500, large_interests)
println("成功推荐: ${match_count}/${1000} 用户")
println("推荐率: ${match_count * 100 / 1000}%")

// 利用 MatchingResult 的辅助方法查询
let full_result = MatchingResult::{
  matching_edges: edges,
  cardinality: match_count,
}

// 查询某用户的推荐小组
match full_result.get_partner(@core.NodeId(42)) {
  Some(partner) => println("用户 42 → 小组 ${partner.0 - 1000}")
  None => println("用户 42 暂无推荐小组")
}
```

---

## 复杂度分析

### 时间复杂度：O(E√V)

| 阶段 | 操作 | 复杂度 | 次数 |
|------|------|--------|------|
| **BFS 分层** | 构建分层图 `dist[]` | O(V + E) | O(√V) 次 |
| **DFS 增广** | 搜索多条增广路 | O(V·E) 每个 Phase | O(√V) 个 Phase |
| **总计** | | **O(E√V)** | |

**为什么是 √V 个 Phase？**

```
核心引理 (Hopcroft-Karp 1973):

设 l_k 为第 k 个 Phase 中最短增广路的长度, 则:
  l_{k+1} > l_k    (严格递增!)

进一步分析:
  前 √V 个 Phase: 每个 Phase 至少找到 1 条增广路
  → 匹配数增加 ≥ √V

  后续 Phase: 最短增广路长度 > √V
  → 每条增广路贡献 ≥ √V/2 条新匹配边
  → 剩余未匹配节点 < √V
  → 最多再需要 √V 个 Phase

总 Phase 数 ≤ 2√V = O(√V)  ✅
```

### 空间复杂度：O(V + E)

| 数据结构 | 用途 | 大小 |
|---------|------|------|
| `adj[][]` | 邻接表 (压缩后的) | O(E) |
| `pair_u[]` | 左侧匹配关系 | O(\|U\|) |
| `pair_v[]` | 右侧匹配关系 | O(\|V\|) |
| `dist[]` | BFS 分层距离 | O(\|U\|) |
| BFS 队列 | O(\|U\|) | O(\|U\|) |
| **总计** | | **O(V + E)** |

### 与其他匹配算法全面对比

```
┌──────────────────┬───────────────┬───────────────┬──────────────────────────┐
│     算法         │  时间复杂度    │  空间复杂度    │  适用场景                │
├──────────────────┼───────────────┼───────────────┼──────────────────────────┤
│ Hungarian (Kuhn) │ O(VE)         │ O(V)          │ 小图, 学习入门           │
│ **Hopcroft-Karp**│ **O(E√V)**    │ **O(V+E)**    │ **大规模二分图 ★**       │
│ Kuhn-Munkres     │ O(V³)         │ O(V²)         │ 带权完美匹配             │
│ Edmonds (一般图)  │ O(V²E)        │ O(V²)         │ 一般图 (含奇环)          │
│ Bloom (带容量)    │ O(VE log V)   │ O(V+E)        │ b-匹配, 有容量约束       │
└──────────────────┴───────────────┴───────────────┴──────────────────────────┘
```

---

## 实际应用场景

### 🎓 场景 1：求职平台智能匹配

**问题**：将 N 名求职者匹配到 M 个岗位，每人只能应聘一个岗位，每个岗位只招一人

**解决方案**：
- 左侧 = 求职者，右侧 = 岗位
- 边 = 求职者具备该岗位的技能要求
- Hopcroft-Karp 在毫秒级完成万级匹配

**实例**：BOSS 直聘、拉勾网的核心匹配引擎

### 🎮 场景 2：游戏服务器玩家匹配

**问题**：MOBA/FPS 游戏中将玩家公平分配到两队

**解决方案**：
- 左侧 = 玩家，右侧 = 队伍位置
- 边 = 该玩家可以填充该位置（基于技能评分范围）
- 每秒需要处理数千次匹配请求

### 📚 场景 3：大学选课系统冲突检测

**问题**：数千名学生选课，检测时间冲突并最大化满足选课意愿

**解决方案**：
- 左侧 = 学生选课请求，右侧 = 课程时间段
- 边 = 该学生在该时间段想选这门课
- 最大匹配 = 最多能满足多少选课请求

### 🏥 场景 4：器官移植 donor-patient 匹配

**问题**：将器官捐献者与等待移植的患者进行匹配（血型兼容等约束）

**解决方案**：
- 左侧 = 捐献者，右侧 = 受赠者
- 边 = 医学兼容（血型、组织相容性等）
- 这是真正拯救生命的算法应用！

### 🌐 场景 5：网络广告投放优化

**问题**：将广告位分配给广告主，最大化有效曝光

**解决方案**：
- 左侧 = 广告主，右侧 = 广告位（按受众群体分类）
- 边 = 广告主的目标受众与广告位的受众重叠
- Google AdSense、Facebook Ads 的底层技术之一

---

## 练习题

### 练习 1：手动执行 Hopcroft-Karp ⭐⭐

对以下二分图手动执行 Hopcroft-Karp 算法，写出完整过程：

```
  U₀ ──→ V₀
  │     ↑
  ├──→ V₁
  │
  U₁ ──→ V₀
  │
  ├──→ V₂

  U₂ ──→ V₁
  └──→ V₂
```

要求写出：
1. Phase 1 的 BFS `dist[]` 结果
2. Phase 1 的 DFS 详细过程（包括每次配对操作）
3. 是否需要 Phase 2？如果需要，写出完整过程
4. 最终匹配及匹配数

<details>
<summary>📖 参考答案</summary>

```
Phase 1 - BFS:
  初始: pair_u=[None,None,None], pair_v=[None,None,None]

  U₀: 未匹配 → dist[0]=0, 入队
  U₁: 未匹配 → dist[1]=0, 入队
  U₂: 未匹配 → dist[2]=0, 入队
  queue = [0, 1, 2]

  处理 U₀: adj=[0,1]
    V₀: pair_v[0]=None → found=true
    V₁: pair_v[1]=None → found=true

  处理 U₁: adj=[0,2]
    V₀: pair_v[0]=None → (不变)
    V₂: pair_v[2]=None → (不变)

  处理 U₂: adj=[1,2]
    V₁: pair_v[1]=None → (不变)
    V₂: pair_v[2]=None → (不变)

  dist = [0, 0, 0], found = true

Phase 1 - DFS:
  DFS(U₀): adj=[0,1]
    V₀: 自由 → pair_u[0]=Some(0), pair_v[0]=Some(0) ✅
    cardinality = 1  (U₀↔V₀)

  DFS(U₁): adj=[0,2]
    V₀: 被U₀占(u2=0), dist[0]==dist[1]+1? 0==1? ❌
    V₂: 自由 → pair_u[1]=Some(2), pair_v[2]=Some(1) ✅
    cardinality = 2  (U₁↔V₂)

  DFS(U₂): adj=[1,2]
    V₁: 自由 → pair_u[2]=Some(1), pair_v[1]=Some(2) ✅
    cardinality = 3  (U₂↔V₁)

Phase 1 结果: cardinality = 3 (完美匹配!)
  匹配: (U₀,V₀), (U₁,V₂), (U₂,V₁)

Phase 2 - BFS:
  U₀: 已匹配 → dist[0]=-1
  U₁: 已匹配 → dist[1]=-1
  U₂: 已匹配 → dist[2]=-1
  queue = [] → found=false → 终止!

最终: MAX_MATCHING = 3 (完美匹配 💎)
```

</details>

---

### 练习 2：实现带容量的 Hopcroft-Karp 变体 ⭐⭐⭐

标准 Hopcroft-Karp 每个节点最多参与 1 条匹配边。请改写为支持**节点容量**的版本：

```moonbit
// 要求:
// 1. 每个 U 节点可以匹配 cap_u[i] 个 V 节点
// 2. 每个 V 节点可以匹配 cap_v[j] 个 U 节点
// 3. 分析时间复杂度的变化

fn hopcroft_karp_with_capacity(
  n_left : Int,
  n_right : Int,
  adj : Array[Array[Int]],
  cap_u : Array[Int],    // 每个 U 节点的容量
  cap_v : Array[Int],    // 每个 V 节点的容量
) -> MatchingResult {
  // TODO: 你的实现
}
```

<details>
<summary>💡 提示</summary>

```moonbit
// 核心思路: 拆点法
//
// 原始: U₀ (容量=3) ──→ V₀ (容量=2)
//
// 拆点后:
//   U₀ → U₀_1, U₀_2, U₀_3   (拆成 3 个副本)
//   V₀ → V₀_1, V₀_2         (拆成 2 个副本)
//   边: U₀_i → V₀_j  for all valid i,j
//
// 然后在扩大的二分图上运行标准 Hopcroft-Karp!
//
// 复杂度变化:
//   新图大小: Σcap_u + Σcap_v (节点数)
//   新边数:   O(Σ(cap_u[i] × deg(i)))  (可能膨胀很多!)
//   时间: O(E' × √V') 其中 E', V' 是拆点后的规模
```

**应用场景**：教师排课（每位老师最多教 N 门课，每门课最多 M 个老师）、服务器负载均衡等。

</details>

---

### 练习 3：利用 Hopcroft-Karp 求最小路径覆盖 ⭐⭐⭐⭐

给定一个**有向无环图 (DAG)**，用最少的路径覆盖所有节点（每个节点恰好属于一条路径）。

**输入**：DAG 的节点数 N 和边集
**输出**：
1. 最少需要的路径数
2. 一组具体的路径方案

**提示**：这是一个经典的 DAG 最小路径覆盖问题，可以通过二分图最大匹配转化求解。

<details>
<summary>📖 解题思路</summary>

```moonbit
// 核心转化: DAG 最小路径覆盖 = N - 二分图最大匹配
//
// 构造二分图:
//   左侧 U = 每个节点的"出点" (U_i 表示节点 i 作为路径起点/中间)
//   右侧 V = 每个节点的"入点" (V_j 表示节点 j 作为路径终点/中间)
//   边 (U_i, V_j) ∈ 二分图 ⟺ 原图中有边 i → j
//
// 直觉解释:
//   每条匹配边 (U_i, V_j) 表示 "路径中 ... → i → j → ..."
//   即两条路径在 i→j 处被"连接"起来了
//   每条匹配边使路径数减少 1
//   所以: 最小路径数 = N - 最大匹配数

fn dag_minimum_path_cover(
  n : Int,
  edges : Array[(Int, Int)],
) -> (Int, Array[Array[Int]]) {
  // 1. 构建二分图: U={0..n-1}, V={0..n-1}
  //    边: (i, j) in edges → (U_i, V_j) in bipartite
  let adj : Array[Array[Int]] = Array::make(n, [])
  for e in edges {
    let (from, to) = e
    adj[from].push(to)
  }

  let left : Array[Int] = []
  let right : Array[Int] = []
  let mut i = 0
  while i < n {
    left.push(i)
    right.push(i)
    i = i + 1
  }

  // 2. 运行 Hopcroft-Karp
  let matching_result = hopcroft_karp_impl(n, n, adj)

  // 3. 从匹配构造路径
  //    匹配边 (U_i, V_j) 表示 i→j 在同一条路径中
  //    用拓扑排序或 DFS 串联
  let path_count = n - matching_result.cardinality

  // ... (路径重构逻辑略, 需要根据 pair_u[] 追踪链路)

  (path_count, [])  // 返回路径数和具体路径
}

// 应用: 任务调度、指令序列优化、DNA 序列组装
// 例: 7 个任务, 10 个依赖关系
//   最小路径覆盖 = 7 - max_matching
//   如果 max_matching = 5, 则只需 2 条路径覆盖所有任务
```

**经典竞赛题目来源**：POJ 1422、HDU 3862、洛谷 P2764

</details>

---

## 相关资源

### 📚 推荐阅读

| 资源 | 类型 | 说明 |
|------|------|------|
| *Original Paper* | 论文 | J. Hopcroft, R. Karp, "An n^(5/2) algorithm for maximum matchings in bipartite graphs," SIAM J. Comput., 1973 |
| *VisuAlgo* | 交互式可视化 | https://visualgo.net/en/matching — 强烈推荐的动画演示! |
| *CP-Algorithms* | 教程 | Hopcroft-Karp 详细讲解与多种语言实现 |
| *Wikipedia* | 百科 | Bipartite matching & Hopcroft–Karp algorithm |
| *Hungarian 教程* | 本站文档 | [/algorithms/matching/bipartite/hungarian](/algorithms/matching/bipartite/hungary) (入门版) |

### 🔗 相关算法

```
Hopcroft-Karp (本文) — 二分图最大匹配 ★
  ├── Hungarian (Kuhn)     → 入门版, O(VE)
  ├── Kuhn-Munkres         → 带权完美匹配, O(V³)
  ├── Edmonds Blossom      → 一般图最大匹配 (含奇环)
  ├── Dinic (网络流转化)    → 二分图匹配 = 单位容量最大流
  └── 最小路径覆盖          → DAG 应用: N - max_matching

匹配算法家族树:
  图匹配
  ├── 二分图匹配
  │   ├── 无权: Hungarian, Hopcroft-Karp ⭐
  │   └── 带权: Kuhn-Munkres, 最小/最大权匹配
  └── 一般图匹配
      ├── 最大匹配: Edmonds (花算法)
      └── 完美匹配: 带权版本
```

### 🛠️ mbtgraph 相关源码

| 文件 | 说明 |
|------|------|
| [`lib/algo/matching/hopcroft_karp.mbt`](../../../lib/algo/matching/hopcroft_karp.mbt) | Hopcroft-Karp 核心实现 |
| [`lib/algo/matching/types.mbt`](../../../lib/algo/matching/types.mbt) | `MatchingResult` 类型定义 |
| [`lib/algo/matching/hungarian.mbt`](../../../lib/algo/matching/hungarian.mbt) | Hungarian 算法 (对比参考) |
| [`lib/algo/matching/kuhn_munkres.mbt`](../../../lib/algo/matching/kuhn_munkres.mbt) | Kuhn-Munkres 带权匹配 |
| [`lib/algo/matching/matching_test.mbt`](../../../lib/algo/matching/matching_test.mbt) | 完整测试套件 (17 tests) |

---

## 总结清单

### ✅ 核心知识点

- [ ] **二分图匹配**：两侧节点独立，边只跨越两侧
- [ ] **增广路定理**：无增广路 ⇔ 最大匹配（Berge 定理）
- [ ] **BFS 分层**：`dist[]` 记录到每个 U 节点的最短距离
- [ ] **DFS 增广**：沿 `dist[]` 约束搜索，找到则更新 `pair_u[]`/`pair_v[]`
- [ ] **时间复杂度**：O(E√V)，比 Hungarian 的 O(VE) 快 √V 倍
- [ ] **Phase 迭代**：BFS+DFS 为一个 Phase，共 O(√V) 个 Phase

### 🔑 关键代码模式

```moonbit
// Hopcroft-Karp 双层循环
while true {
  // Phase 1: BFS 分层
  let (dist, found) = bfs_layer(pair_u, pair_v, adj)
  if !found { break }  // 无增广路, 结束

  // Phase 2: DFS 多路增广
  for u in free_vertices {
    if dfs_augment(u, adj, pair_u, pair_v, dist) {
      cardinality += 1
    }
  }
}

// DFS 增广核心逻辑
fn dfs(u, ...) -> Bool {
  for v in adj[u] {
    match pair_v[v] {
      None => { pair_u[u]=Some(v); pair_v[v]=Some(u); return true; }
      Some(u2) =>
        if dist[u2]==dist[u]+1 && dfs(u2, ...) {
          pair_u[u]=Some(v); pair_v[v]=Some(u); return true;
        }
    }
  }
  dist[u] = -1  // 剪枝: 标记不可达
  false
}
```

### ⚠️ 常见陷阱

| 陷阱 | 后果 | 解决方法 |
|------|------|---------|
| DFS 忽略 `dist` 约束 | 可能找到非最短增广路 | 必须 `dist[u2] == dist[u] + 1` |
| 忘记 `dist[u] = -1` 剪枝 | 重复搜索失败路径 | DFS 失败时设置 `dist[u] = -1` |
| 混淆 `pair_u` 和 `pair_v` 的索引 | 匹配结果错误 | `pair_u[i]=j` ⇔ Uᵢ↔Vⱼ ⇔ `pair_v[j]=i` |
| NodeId 与索引混淆 | 数组越界或查找失败 | 内部统一用 Int 索引，仅在输出时转换 |
| 空图边界检查缺失 | 崩溃或死循环 | 开头检查 `n_left==0 \|\| n_right==0` |

### 📊 二分图匹配算法选型速查

```
┌──────────────┬───────────┬───────────┬──────────────────────────┐
│    场景        │  推荐      │  备选      │  避免使用              │
├──────────────┼───────────┼───────────┼──────────────────────────┤
│ 学习/教学     │ Hungarian │ HC-Karp   │ Edmonds (过于复杂)     │
│ 生产环境       │ HC-Karp ⭐ │ Hungarian │ Hungarian (太慢)       │
│ 带权匹配       │ KM        │ HC-Karp+权 │ 无权算法               │
│ 一般图(有奇环) │ Edmonds   │ 转化为流   │ 二分图算法 (错误!)      │
│ 超大规模(>10⁵) │ HC-Karp   │ 网络流(Dinic)│ Hungarian            │
│ DAG路径覆盖    │ HC-Karp   │ DP        │ 暴力枚举               │
└──────────────┴───────────┴───────────┴──────────────────────────┘
```

### 🎯 一句话记忆

> **Hopcroft-Karp = BFS 画地图 + GPS 导航（多条路线同时规划），而 Hungarian = 每次只派一个人出门问路。**

---

<div align="center">

**⚡ Hopcroft-Karp 算法 — BFS 分层 + DFS 增广，大规模二分图匹配的生产级选择**

*上一篇：[Hungarian 算法](/algorithms/matching/bipartite/hungary) | [返回匹配算法目录](/algorithms/matching) | [下一篇：Edmonds 一般图匹配](/algorithms/matching/general/edmonds)*

</div>
