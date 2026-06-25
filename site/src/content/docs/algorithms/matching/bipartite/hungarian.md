---
title: "匈牙利算法 (Hungarian Algorithm)：二分图最大匹配入门"
description: "DFS 增广路搜索，O(VE) 时间复杂度，二分图匹配的经典入门算法"
---

# 🎯 匈牙利算法 (Hungarian Algorithm)：二分图最大匹配入门

> **"想象你是月老（或 HR），面前有 N 位单身男士和 M 位单身女士，每人都有自己心仪的对象列表。你的任务是：撮合尽可能多的情侣，且每个人只能配对一次。匈牙利算法就是这位'月老'的工作流程——每次为一个人安排对象，如果遇到冲突就递归调整已有的配对，直到所有人都尝试过或者找不到更好的方案。"**

## 📖 目录

- [算法简介](#算法简介)
- [核心概念](#核心概念)
- [动画演示](#动画演示)
- [MoonBit 完整实现](#moonbit-完整实现)
- [代码详解](#代码详解)
- [使用示例](#使用示例)
- [复杂度分析](#复杂度分析)
- [实际应用场景](#实际应用场景)
- [Hungarian vs Hopcroft-Karp 对比](#hungarian-vs-hopcroft-karp-对比)
- [练习题](#练习题)
- [相关资源](#相关资源)
- [总结清单](#总结清单)

---

## 算法简介

### 匈牙利算法是什么？

**匈牙利算法**（也称 **Kuhn's Algorithm**）用于求解**二分图的最大匹配（Maximum Bipartite Matching）**问题。它是理解二分图匹配的**最佳入门算法**，由 Harold Kuhn 于 1955 年提出（基于匈牙利数学家 Dénes Kőnig 和 Jenő Egerváry 的早期工作）。

```
┌─────────────────────────────────────────────────────────────┐
│                 匈牙利算法核心思想                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ① 逐个尝试 (Greedy + Backtracking)                         │
│     └─ 从左部每个节点出发, 尝试寻找增广路                      │
│                                                             │
│  ② DFS 增广 (Depth-First Search)                            │
│     └─ 用 DFS 搜索从当前节点出发的增广路                       │
│                                                             │
│  ③ 递归调整 (Recursive Reallocation)                        │
│     └─ 如果目标已被占用, 递归尝试让占用者让位                   │
│                                                             │
│  结果: 找到最大匹配, 时间 O(VE), 空间 O(V+E)                 │
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
│    U₂ 王五 ───┬──→ V₀ 小红                               │
│              └──→ V₂ 小丽                               │
│                                                         │
│   目标: 撮合尽可能多的配对!                               │
│   约束: 每人只能配对一次                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘

匈牙利算法的做法:
  第 1 轮 (为张三找对象):
    张三 → 先试小红, 小红没对象? 成功! ✓ 配对 #1
           match_right[小红] = 张三

  第 2 轮 (为李四找对象):
    李四 → 先试小芳, 小芳没对象? 成功! ✓ 配对 #2
           match_right[小芳] = 李四

  第 3 轮 (为王五找对象) — 冲突来了!
    王五 → 先试小红, 但小红已经跟张三在一起了!
           → 问张三: "你能换个人吗?"
             张三 → 试其他人...没有其他选择 😢
           → 红线! 这条路走不通
    王五 → 再试小丽, 小丽没对象? 成功! ✓ 配对 #3

  最终结果: 3 对配对! (完美匹配 💎)
```

### 为什么叫"匈牙利算法"?

**历史趣闻**：

```
时间线:
  1931: Dénes Kőnig (匈牙利数学家) 提出二分图匹配理论框架
  1931: Jenő Egerváry (匈牙利数学家) 将问题转化为矩阵形式
  1955: Harold Kuhn (美国数学家) 基于 Kőnig-Egerváry 的工作
        提出实用的算法实现, 命名为 "Hungarian Method"

注: 虽然名字叫 "Hungarian", 但 Kuhn 是美国人!
    这个命名是为了致敬两位匈牙利数学家的开创性工作。
    
另: 本文讨论的是二分图最大匹配版本 (Kuhn's Algorithm),
    还有一个同名的 "Kuhn-Munkres 算法" 用于带权二分图完美匹配,
    不要混淆哦!
```

### 算法主流程

```
┌──────────────────────────────────────────────────────────┐
│              匈牙利算法主循环                              │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  初始化: match_right[] = None (所有右侧节点都自由)         │
│                                                          │
│  for each u in U (左侧节点):                             │
│    visited[] = false  (本轮搜索标记, 防止重复访问)          │
│    if dfs_find_augmenting_path(u):                       │
│      matching_count += 1   ← 找到一条增广路, 匹配数+1      │
│                                                          │
│  返回 MatchingResult { matching_edges, cardinality }     │
│                                                          │
│  核心: dfs_find_augmenting_path(u):                      │
│    for each v in adj[u]:                                 │
│      if !visited[v]:                                     │
│        visited[v] = true                                 │
│        if match_right[v] == None:                        │
│          match_right[v] = u  // 直接配对                  │
│          return true                                     │
│        else if dfs(match_right[v]):  // 递归让位!         │
│          match_right[v] = u  // 抢占成功                  │
│          return true                                     │
│    return false  // 找不到增广路                           │
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
  └─────┘      │       └─────┘
               │
  关键性质: U 内部无边, V 内部也无边
            所有边都是跨集合的!

  判定方法: 二分图当且仅当不包含奇数长度的环 (奇环)
```

### 🔗 匹配 (Matching)

**匹配** M 是一组边的集合，满足：**任意两条边没有公共端点**。

```
  匹配 M = {(U₀,V₀), (U₂,V₂)}  ← 合法的匹配 (无公共端点)

  U₀ ━━━ V₀     ← 匹配边 (粗线)
  U₁ ── V₁
  U₂ ━━━ V₂     ← 匹配边 (粗线)

  cardinality(M) = |M| = 2  (匹配数/基数)

  完美匹配 (Perfect Matching):
    所有节点都被匹配 (|M| = min(|U|, |V|))
    上例中如果 |U|=|V|=3 且 |M|=3, 就是完美匹配

  最大匹配 (Maximum Matching):
    边数最多的匹配 (可能有多个, 但基数相同)
```

### 🛣️ 增广路 (Augmenting Path)

**增广路**是一条交替经过**非匹配边**和**匹配边**的路径，且：
- 起点**和终点都是未匹配节点**
- 路径长度为**奇数**（边数为奇数）

```
  增广路示例:

  U₀(自由) ──→ V₁(已匹配) ━━ U₁(已匹配) ──→ V₂(自由)

  边的类型交替:
    U₀→V₁ : 非匹配边 (实线, 正向)
    V₁━U₁ : 匹配边   (粗线, 反向回溯)
    U₁→V₂ : 非匹配边 (实线, 正向)

  操作: 沿增广路翻转匹配状态!
    原来: (V₁,U₁) 是匹配边
    翻转后: (U₀,V₁) 和 (U₁,V₂) 变成匹配边
    结果: 匹配数 +1! ✨

  直觉: 就像"击鼓传花"——让已有配对的人换对象,
        从而腾出位置给新人!
```

**增广路定理（Berge 定理）**：
> 当且仅当图中**不存在增广路**时，当前匹配是**最大匹配**。

这是所有匹配类算法的理论基础！匈牙利算法的本质就是**反复寻找增广路并翻转**，直到找不到为止。

### 🔀 交替路 (Alternating Path)

**交替路**是增广路的推广概念——一条路径上**匹配边和非匹配边交替出现**，但端点不一定都未匹配：

```
  交替路示例:

  已匹配起点 → 非匹配边 → 已匹配节点 → 匹配边 → ...

  U₀(已匹配) ━━ V₀(已匹配) ──→ U₁(自由) ──→ V₁(自由)

  这是交替路, 但不是增广路 (因为起点 U₀ 已匹配)

  增广路是特殊的交替路:
    - 两端都必须是未匹配节点
    - 可以通过翻转增加匹配数
```

### 👥 match_right[] 数组

匈牙利算法的核心数据结构，记录右侧节点的配对情况：

```moonbit
match_right : Array[Int?]   // match_right[j] = i 表示 Vⱼ 与 Uᵢ 配对
                              // match_right[j] = None 表示 Vⱼ 自由

// 示例状态:
// match_right = [Some(0), Some(1), None]
//   → V₀↔U₀, V₁↔U₁, V₂自由
//
// 注意: 匈牙利算法只维护 match_right[],
//       不需要维护 match_left[] (可以通过遍历 match_right 推断)
//
// 不变式: match_right[j] == Some(i) ⇔ Uᵢ 与 Vⱼ 配对
```

### 🚫 visited[] 数组

防止在同一轮 DFS 中重复访问同一右侧节点：

```moonbit
visited : Array[Bool]   // visited[j] = true 表示 Vⱼ 在本轮已尝试过

// 为什么需要?
//  假设 U₀ 和 U₁ 都连接到 V₀
//  处理 U₀ 时: 访问 V₀, 发现被占, 递归尝试让位...
//  处理 U₁ 时: 如果不标记 visited, 可能再次访问 V₀
//              导致无限循环或错误计数!
//
// 关键: visited[] 在每一轮 (每个左侧节点) 开始时重置!
```

---

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/hungarian/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/hungarian/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 示例二分图

使用一个 **3×3 二分图**，完整展示匈牙利算法的执行过程：

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
        └──────────┘  │           └──────────┘
                     │
                     └──→ V₀ (也连向 V₀!)

   边集 (7 条边):
     U₀ → V₀
     U₁ → V₀, U₁ → V₁
     U₂ → V₁, U₂ → V₂, U₂ → V₀

   最大匹配数预期: 3 (完美匹配!)
   可能方案之一: (U₀,V₀), (U₁,V₁), (U₂,V₂)
```

---

### 🎬 第 1 轮：为 U₀ 寻找增广路

```
═════════════════════════════════════════════
  初始化状态
═════════════════════════════════════════════

  match_right = [None, None, None]   // 所有人都单身
  visited     = [false, false, false]
  cardinality = 0

═════════════════════════════════════════════
  第 1 轮: 为 U₀ (张三) 找对象
═════════════════════════════════════════════

  重置 visited: visited = [false, false, false]

  调用 hungarian_dfs(u=0, adj, match_right, visited):

  ┌─ Step 1: 遍历 adj[0] = [0], 即检查 V₀ ──────────────────┐
  │                                                           │
  │  v = 0                                                    │
  │  visited[0] == false? ✅ 未访问过                          │
  │    → visited[0] = true  (标记 V₀ 已访问)                   │
  │                                                           │
  │  检查 match_right[0]:                                     │
  │    match_right[0] == None ? ✅ 是! V₀ 自由!               │
  │                                                           │
  │    → match_right[0] = Some(0)  // U₀ ↔ V₀ 配对成功!      │
  │    → return true ✅                                       │
  │                                                           │
  │  🎉 配对 #1: (U₀, V₀)                                    │
  │                                                           │
  └───────────────────────────────────────────────────────────┘

  cardinality = 0 + 1 = 1

  当前状态:
    match_right = [Some(0), None, None]   // V₀↔U₀, 其他自由
    matching_edges = [(U₀, V₀)]
```

---

### 🎬 第 2 轮：为 U₁ 寻找增广路

```
═════════════════════════════════════════════
  第 2 轮: 为 U₁ (李四) 找对象
═════════════════════════════════════════════

  重置 visited: visited = [false, false, false]

  调用 hungarian_dfs(u=1, adj, match_right, visited):

  ┌─ Step 1: 遍历 adj[1] = [0, 1], 先检查 V₀ ───────────────┐
  │                                                           │
  │  v = 0                                                    │
  │  visited[0] == false? ✅                                  │
  │    → visited[0] = true                                   │
  │                                                           │
  │  检查 match_right[0]:                                     │
  │    match_right[0] == Some(0) ❌ V₀ 已经被 U₀ 占了!        │
  │                                                           │
  │    → 进入 else 分支: matched_u = 0 (V₀ 的现任是 U₀)       │
  │                                                           │
  │    → 递归调用: hungarian_dfs(u=0, ...)                   │
  │      问 U₀: "你能换个对象吗?"                              │
  │                                                           │
  │      【递归层 2】hungarian_dfs(u=0):                      │
  │        遍历 adj[0] = [0], 检查 V₀:                        │
  │          visited[0] == true? ✅ 已访问! → 跳过!            │
  │        无其他邻居                                         │
  │        → return false ❌ (U₀ 无法换对象)                   │
  │                                                           │
  │    → 递归返回 false, 这条路走不通                          │
  │                                                           │
  └───────────────────────────────────────────────────────────┘

  ┌─ Step 2: 继续检查 V₁ ────────────────────────────────────┐
  │                                                           │
  │  v = 1                                                    │
  │  visited[1] == false? ✅                                  │
  │    → visited[1] = true                                   │
  │                                                           │
  │  检查 match_right[1]:                                     │
  │    match_right[1] == None ? ✅ 是! V₁ 自由!               │
  │                                                           │
  │    → match_right[1] = Some(1)  // U₁ ↔ V₁ 配对成功!      │
  │    → return true ✅                                       │
  │                                                           │
  │  🎉 配对 #2: (U₁, V₁)                                    │
  │                                                           │
  └───────────────────────────────────────────────────────────┘

  cardinality = 1 + 1 = 2

  当前状态:
    match_right = [Some(0), Some(1), None]  // V₀↔U₀, V₁↔U₁
    matching_edges = [(U₀, V₀), (U₁, V₁)]

  可视化:
    U₀ ━━━ V₀  ✓
    U₁ ━━━ V₁  ✓
    U₂ ── V₀  (冲突, 但 U₁ 选了 V₁)
    U₂ ── V₁  (冲突, 但 U₁ 选了 V₁)
    U₂ ── V₂  (还没轮到 U₂)
```

---

### 🎬 第 3 轮：为 U₂ 寻找增广路（关键的一轮！）

这是最精彩的一轮！U₂ 的所有邻居（V₀, V₁, V₂）都可能被占用，需要**递归调整**。

```
═════════════════════════════════════════════
  第 3 轮: 为 U₂ (王五) 找对象 — 冲突解决!
═════════════════════════════════════════════

  重置 visited: visited = [false, false, false]

  当前状态回顾:
    match_right = [Some(0), Some(1), None]  // V₀↔U₀, V₁↔U₁, V₂自由

  调用 hungarian_dfs(u=2, adj, match_right, visited):

  ┌─ Step 1: 检查 V₀ (adj[2][0] = 0) ───────────────────────┐
  │                                                           │
  │  v = 0                                                    │
  │  visited[0] = true                                        │
  │                                                           │
  │  match_right[0] == Some(0) ❌ 被 U₀ 占了!                │
  │  → 递归: hungarian_dfs(u=0, ...) 问 U₀ 能否让位          │
  │                                                           │
  │    【递归层 2】hungarian_dfs(u=0):                        │
  │      visited[0] == true? ✅ 已访问 → 跳过 V₀              │
  │      adj[0] 只有 [0], 无其他邻居                          │
  │      → return false ❌ U₀ 不愿意(无法)换对象               │
  │                                                           │
  │  → V₀ 这条路失败                                          │
  │                                                           │
  └───────────────────────────────────────────────────────────┘

  ┌─ Step 2: 检查 V₁ (adj[2][1] = 1) ───────────────────────┐
  │                                                           │
  │  v = 1                                                    │
  │  visited[1] = true                                        │
  │                                                           │
  │  match_right[1] == Some(1) ❌ 被 U₁ 占了!                │
  │  → 递归: hungarian_dfs(u=1, ...) 问 U₁ 能否让位          │
  │                                                           │
  │    【递归层 2】hungarian_dfs(u=1):                        │
  │      遍历 adj[1] = [0, 1]:                                │
  │                                                           │
  │      检查 V₀ (i=0):                                       │
  │        visited[0] == true? ✅ 已访问 → 跳过!              │
  │                                                           │
  │      检查 V₁ (i=1):                                       │
  │        visited[1] == true? ✅ 已访问 → 跳过!              │
  │                                                           │
  │      → return false ❌ U₁ 也无法换对象                     │
  │                                                           │
  │  → V₁ 这条路也失败                                        │
  │                                                           │
  └───────────────────────────────────────────────────────────┘

  ┌─ Step 3: 检查 V₂ (adj[2][2] = 2) — 最后的机会! ────────┐
  │                                                           │
  │  v = 2                                                    │
  │  visited[2] = true                                        │
  │                                                           │
  │  match_right[2] == None ? ✅ 是! V₂ 自由!                 │
  │                                                           │
  │  → match_right[2] = Some(2)  // U₂ ↔ V₂ 直接配对!        │
  │  → return true ✅                                        │
  │                                                           │
  │  🎉 配对 #3: (U₂, V₂)                                    │
  │                                                           │
  └───────────────────────────────────────────────────────────┘

  cardinality = 2 + 1 = 3

  最终状态:
    match_right = [Some(0), Some(1), Some(2)]  // 全部配对!
    matching_edges = [(U₀, V₀), (U₁, V₁), (U₂, V₂)]

  🎉 这是一个完美匹配! 💎
```

---

### 🎬 更复杂的例子：必须"抢对象"的场景

上面的例子太理想化了，让我们看一个**必须通过递归让位才能成功**的例子：

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

#### 第 1 轮：U₀ → V₀ ✓

```
  match_right = [None, None]
  visited = [false, false]

  DFS(U₀):
    V₀: 自由 → match_right[0] = Some(0) ✅
  cardinality = 1
  match_right = [Some(0), None]
```

#### 第 2 轮：U₁ → V₀ (冲突!) → 让位失败 → 失败

```
  visited = [false, false]  (重置!)

  DFS(U₁):
    V₀: 被 U₀ 占了 (match_right[0]=Some(0))

    → 递归问 U₀: "能换吗?"
      DFS(U₀):
        V₀: visited[0]=true → 跳过!
        无其他邻居
        → return false ❌

    → U₀ 不肯让, U₁ 没其他选择
    → return false ❌

  cardinality = 1 (不变!)
  ⚠️ U₁ 本轮未能配对
```

#### 第 3 轮：U₂ → V₁ ✓

```
  visited = [false, false]  (重置!)

  DFS(U₂):
    V₁: 自由 → match_right[1] = Some(2) ✅
  cardinality = 2
  match_right = [Some(0), Some(1)]
```

#### 最终结果

```
  MAX_MATCHING = 2 (最优解, 因为右侧只有 2 个节点)
  匹配: (U₀, V₀), (U₂, V₁)
  U₁ 未能配对 (遗憾 😢)

  注: 虽然 U₁ 未能配对, 但这已经是理论最大值了!
      匈牙利算法保证找到的就是最大匹配。
```

---

### 🎬 最精彩的例子：成功的"连环抢亲"

这个例子展示了**多层递归让位**的威力：

```
          左侧 (U)                  右侧 (V)
        ┌──────────┐              ┌──────────┐
        │   U₀    ─┼──────────→   │   V₀     │
        │          │              │          │
        │   U₁    ─┼──┬────────→  │   V₁     │
        │          │  │           │          │
        │   U₂    ─┼──┴───────→  │   V₀     │  ← 也想要 V₀!
        └──────────┘              └──────────┘

   边集: U₀→V₀, U₁→V₁, U₂→V₀
   最大匹配 = 2
```

#### 执行过程

```
第 1 轮 - U₀:
  DFS(U₀): V₀ 自由 → match_right[0]=Some(0) ✅
  cardinality = 1, match_right = [Some(0), None]

第 2 轮 - U₁:
  DFS(U₁): V₁ 自由 → match_right[1]=Some(1) ✅
  cardinality = 2, match_right = [Some(0), Some(1)]

第 3 轮 - U₂ (高潮!):
  visited = [false, false]

  DFS(U₂):
    V₀: 被 U₀ 占了 (match_right[0]=Some(0))

    → 递归 DFS(U₀):  "U₀, 你能让出 V₀ 吗?"
      visited[0] = true
      U₀ 的邻居只有 V₀, visited[0]=true → 跳过
      → return false ❌ ("我不愿意!")

    → U₀ 不让, U₂ 无其他邻居
    → return false ❌

  cardinality = 2 (不变!)

最终: MAX_MATCHING = 2
  匹配: (U₀, V₀), (U₁, V₁)
  U₂ 未能配对
```

---

### 📊 完整执行过程汇总

```
═══════════════════════════════════════════════════════
        匈牙利算法执行总览 (3×3 完美匹配)
═══════════════════════════════════════════════════════

  【第 1 轮】— U₀ (张三)
  ┌─────────────────────────────────────────────────┐
  │                                                  │
  │  DFS(U₀):                                        │
  │    V₀: 自由 → match_right[0] = Some(0) ✅       │
  │                                                  │
  │  cardinality = 1                                 │
  │  匹配: (U₀, V₀)                                  │
  │                                                  │
  └─────────────────────────────────────────────────┘

  【第 2 轮】— U₁ (李四)
  ┌─────────────────────────────────────────────────┐
  │                                                  │
  │  DFS(U₁):                                        │
  │    V₀: 被U₀占 → 递归DFS(U₀) → U₀无替代 → 失败   │
  │    V₁: 自由 → match_right[1] = Some(1) ✅       │
  │                                                  │
  │  cardinality = 2                                 │
  │  匹配: (U₀, V₀), (U₁, V₁)                       │
  │                                                  │
  └─────────────────────────────────────────────────┘

  【第 3 轮】— U₂ (王五)
  ┌─────────────────────────────────────────────────┐
  │                                                  │
  │  DFS(U₂):                                        │
  │    V₀: 被U₀占 → 递归DFS(U₀) → 失败              │
  │    V₁: 被U₁占 → 递归DFS(U₁) → 失败              │
  │    V₂: 自由 → match_right[2] = Some(2) ✅       │
  │                                                  │
  │  cardinality = 3                                 │
  │  匹配: (U₀, V₀), (U₁, V₁), (U₂, V₂)            │
  │                                                  │
  └─────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════
  最终结果: MAX_MATCHING = 3 (完美匹配 💎)
  匹配边: (U₀,V₀), (U₁,V₁), (U₂,V₂)
  总轮数: 3 (每个左节点一轮)
═══════════════════════════════════════════════════════


═══════════════════════════════════════════════════════
      匈牙利算法执行总览 (3×2 冲突图)
═══════════════════════════════════════════════════════

  【第 1 轮】— U₀
  ┌─────────────────────────────────────────────────┐
  │  DFS(U₀): V₀ 自由 → ✅ 配对 #1                   │
  │  cardinality = 1                                 │
  └─────────────────────────────────────────────────┘

  【第 2 轮】— U₁ (冲突!)
  ┌─────────────────────────────────────────────────┐
  │  DFS(U₁): V₀ 被占 → 递归U₀ → U₀不让 → ❌       │
  │  cardinality = 1 (不变)                          │
  └─────────────────────────────────────────────────┘

  【第 3 轮】— U₂
  ┌─────────────────────────────────────────────────┐
  │  DFS(U₂): V₁ 自由 → ✅ 配对 #2                   │
  │  cardinality = 2                                 │
  └─────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════
  最终结果: MAX_MATCHING = 2 (最优解)
  U₁ 未能配对 (右侧容量不足)
═══════════════════════════════════════════════════════
```

---

## MoonBit 完整实现

以下是 mbtgraph 中匈牙利算法的完整实现：

```moonbit
///|
/// 匈牙利算法 (Hungarian / Kuhn's Algorithm)
///
/// 二分图最大匹配算法，基于 DFS 增广路搜索。
/// 时间复杂度 O(VE)，空间复杂度 O(V+E)。
///
/// 适用于二分图最大匹配场景，是 P4 图匹配模块的核心算法。

// ============================================================================
// 私有辅助函数：DFS 增广路搜索
// ============================================================================

fn hungarian_dfs(
  u : Int,
  adj : Array[Array[Int]],
  match_right : Array[Int?],
  visited : Array[Bool],
) -> Bool {
  let mut i = 0
  while i < adj[u].length() {
    let v = adj[u][i]
    if !visited[v] {
      visited[v] = true
      match match_right[v] {
        None => {
          match_right[v] = Some(u)
          return true
        }
        Some(matched_u) =>
          if hungarian_dfs(matched_u, adj, match_right, visited) {
            match_right[v] = Some(u)
            return true
          }
      }
    }
    i = i + 1
  }
  false
}

// ============================================================================
// 公开 API：二分图最大匹配（邻接表输入）
// ============================================================================

///|
/// 二分图最大匹配 — 邻接表版本
///
/// 使用匈牙利算法求解二分图的最大基数匹配。
///
/// ## 参数
/// - `n_left`: 左部节点数 (U 分区，编号 0..n_left-1)
/// - `n_right`: 右部节点数 (V 分区，编号 0..n_right-1)
/// - `edges`: 边列表，每条边 `(u, v)` 表示 U 中节点 u 连向 V 中节点 v
///
/// ## 返回
/// `MatchingResult` 包含匹配边列表和匹配数
///
/// ## 复杂度
/// - 时间: O(VE)，其中 V = n_left，E = edges.length()
/// - 空间: O(V + E)
pub fn bipartite_matching(
  n_left : Int,
  n_right : Int,
  edges : Array[(Int, Int)],
) -> MatchingResult {
  if n_left == 0 || n_right == 0 || edges.length() == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  let adj : Array[Array[Int]] = Array::make(n_left, [])
  for edge in edges {
    match edge {
      (u, v) =>
        if u >= 0 && u < n_left && v >= 0 && v < n_right {
          adj[u].push(v)
        }
    }
  }

  let match_right : Array[Int?] = Array::make(n_right, None)
  let result_edges : Array[(@core.NodeId, @core.NodeId)] = []
  let mut cardinality = 0

  let mut u = 0
  while u < n_left {
    let visited : Array[Bool] = Array::make(n_right, false)
    if hungarian_dfs(u, adj, match_right, visited) {
      cardinality = cardinality + 1
    }
    u = u + 1
  }

  let mut v = 0
  while v < n_right {
    match match_right[v] {
      Some(u_val) =>
        result_edges.push((@core.NodeId(u_val), @core.NodeId(n_left + v)))
      None => ()
    }
    v = v + 1
  }

  MatchingResult::{ matching_edges: result_edges, cardinality }
}

// ============================================================================
// 私有辅助：在数组中查找 NodeId 对应的索引
// ============================================================================

fn find_node_index(node : @core.NodeId, nodes : Array[@core.NodeId]) -> Int? {
  let mut i = 0
  while i < nodes.length() {
    if nodes[i] == node {
      return Some(i)
    }
    i = i + 1
  }
  None
}

// ============================================================================
// 公开 API：基于 GraphReadable trait 的通用版本
// ============================================================================

///|
/// 二分图最大匹配 — GraphReadable 版本
///
/// 给定一个二分图（通过左右分区指定），计算最大匹配。
///
/// ## 参数
/// - `g`: 实现了 GraphReadable 的图结构
/// - `left_nodes`: 左分区节点集合 (U)
/// - `right_nodes`: 右分区节点集合 (V)
///
/// ## 前置条件
/// 图必须是二分图，所有边的端点分别属于 left_nodes 和 right_nodes。
pub fn[G : @core.GraphReadable] bipartite_matching_graph(
  graph : G,
  left_nodes : Array[@core.NodeId],
  right_nodes : Array[@core.NodeId],
) -> MatchingResult {
  if left_nodes.length() == 0 || right_nodes.length() == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  let n_left = left_nodes.length()
  let n_right = right_nodes.length()

  let edges : Array[(Int, Int)] = []
  let mut u_idx = 0
  while u_idx < n_left {
    let u_node = left_nodes[u_idx]
    for v_node in @core.GraphReadable::neighbors(graph, u_node) {
      match find_node_index(v_node, right_nodes) {
        Some(v_idx) => edges.push((u_idx, v_idx))
        None => ()
      }
    }
    u_idx = u_idx + 1
  }

  bipartite_matching(n_left, n_right, edges)
}
```

---

## 代码详解

### 设计决策 1️⃣：为什么只维护 `match_right[]` 而不是双向数组？

```moonbit
let match_right : Array[Int?] = Array::make(n_right, None)
// 只记录右侧节点的配对情况
// match_right[j] = Some(i) 表示 Vⱼ 与 Uᵢ 配对
```

**原因**：匈牙利算法的搜索方向是**从左到右**，只需要快速查询"右侧节点是否已被占用"以及"被谁占用"。左侧节点的配对状态可以在最后通过遍历 `match_right[]` 推断出来。

**对比 Hopcroft-Karp**：
- Hungarian: 只需 `match_right[]`（单向搜索）
- HC-Karp: 需要 `pair_u[]` + `pair_v[]`（双向 BFS 分层需要）

**优势**：
- 减少一半的数组维护开销
- 降低代码复杂度
- 减少出错概率（只需维护一个数组的不变式）

**输出时的重建**：
```moonbit
let mut v = 0
while v < n_right {
  match match_right[v] {
    Some(u_val) =>
      result_edges.push((@core.NodeId(u_val), @core.NodeId(n_left + v)))
    None => ()
  }
  v = v + 1
}
// 遍历所有右侧节点, 如果有配对就加入结果
```

---

### 设计决策 2️⃣：`visited[]` 数组的重置策略

```moonbit
let mut u = 0
while u < n_left {
  let visited : Array[Bool] = Array::make(n_right, false)  // 每轮重置!
  if hungarian_dfs(u, adj, match_right, visited) {
    cardinality = cardinality + 1
  }
  u = u + 1
}
```

**为什么每轮都要重置 `visited[]`？**

```
核心原因: 防止"错误剪枝"

假设场景:
  U₀ 连向 {V₀, V₁}
  U₁ 连向 {V₀}

第 1 轮 (处理 U₀):
  visited = [false, false]
  DFS(U₀): 尝试 V₀ → 成功! visited[0]=true
           (虽然没用上 visited[1])

第 2 轮 (处理 U₁):
  如果不重置 visited:
    visited = [true, false]  (带着上一轮的痕迹!)
    DFS(U₁): 尝试 V₀ → visited[0]=true → 跳过!
              无其他邻居 → return false ❌
    错误! U₁ 本来可以尝试让 U₀ 让位的!

正确做法: 每轮重置 visited
  visited = [false, false]  (全新的开始)
  DFS(U₀): 尝试 V₀ → 被占 → 递归 DFS(U₀)
           DFS(U₀): V₀ 已访问 → 跳过 → return false
           → U₁ 失败 (这次是真的找不到增广路)
```

**直觉类比**：每一轮代表"为一个新的男士安排相亲"，上一轮的"尝试记录"不应该影响这一轮的判断。

---

### 设计决策 3️⃣：DFS 的"抢占式"更新策略

```moonbit
fn hungarian_dfs(u, adj, match_right, visited) -> Bool {
  // ...
  match match_right[v] {
    None => {
      match_right[v] = Some(u)  // 直接占领!
      return true
    }
    Some(matched_u) =>
      if hungarian_dfs(matched_u, adj, match_right, visited) {
        match_right[v] = Some(u)  // 抢占成功!
        return true
      }
  }
  // ...
}
```

**精妙之处**：当递归调用返回 `true` 时（说明原来的配对者找到了新对象），**立即更新** `match_right[v] = Some(u)`，而不是等到所有邻居都尝试完。

**效果**：
- **贪心性**：一旦找到可行的增广路就立即返回，不浪费时间尝试其他可能
- **正确性保证**：即使这条增广路不是"最优的"，最终结果仍然是最大匹配（增广路定理保证）
- **效率提升**：避免不必要的遍历

**类比**：就像相亲时，一旦对方同意就立刻确定关系，不会继续见下一个（即使下一个可能更合适也不影响"最大匹配数"这个目标）。

---

### 设计决策 4️⃣：为什么时间复杂度是 O(VE)？

```
详细分析:

外层循环: for each u in U  →  O(|U|) 次
  每次 DFS:
    最坏情况: 遍历所有右侧节点  →  O(|V|)
    每个右侧节点可能触发递归:
      递归深度最多 O(|U|) (沿匹配边回溯)
      每层递归遍历该节点的邻居  →  O(deg(u))

  单次 DFS 复杂度: O(E)  (每条边最多访问一次, 因为 visited[])
  
  为什么每条边只访问一次?
    → 因为 visited[] 保证每个右节点在一轮 DFS 中只进入一次
    → 即使递归也不会重复访问同一个右节点

总计: O(|U| × E) = O(VE)

特殊情况:
  稠密图 (E ≈ V²): O(V³)
  稀疏图 (E ≈ V):  O(V²)

对比 Hopcroft-Karp: O(E√V)
  当 V 较大时, HC-Karp 明显更快
  例如 V=10000: Hungarian ≈ 10⁸, HC-Karp ≈ 10⁶
```

---

## 使用示例

### 示例 1：基础用法 — 求职者与岗位匹配

```moonbit
use lib.algo.matching.{bipartite_matching, MatchingResult}

fn main {
  // 场景: 3 名求职者申请 3 个岗位
  // 求职者: U₀=张三, U₁=李四, U₂=王五
  // 岗位:   V₀=前端, V₁=后端, V₂=算法

  let edges : Array[(Int, Int)] = [
    (0, 0),  // 张三擅长前端
    (0, 1),  // 张三也能做后端
    (1, 1),  // 李四擅长后端
    (1, 2),  // 李四也能做算法
    (2, 0),  // 王五擅长前端
    (2, 2),  // 王五也能做算法
  ]

  let result = bipartite_matching(3, 3, edges)

  println("最大匹配数: ${result.cardinality}")
  // 输出: 最大匹配数: 3

  println("匹配详情:")
  let names_u = ["张三", "李四", "王五"]
  let names_v = ["前端", "后端", "算法"]
  for edge in result.matching_edges {
    match edge {
      (u, v) => {
        println("  ${names_u[u.0]} → ${names_v[v.0 - 3]}")
      }
    }
  }
  // 输出示例:
  //   张三 → 前端
  //   李四 → 后端
  //   王五 → 算法

  // 使用辅助方法
  println("\n查询功能:")
  println("  匹配总数: ${result.size()}")  // 3

  match result.get_partner(@core.NodeId(0)) {
    Some(p) => println("  张三的岗位: ${names_v[p.0 - 3]}")
    None => println("  张三未匹配")
  }

  if result.is_matched(@core.NodeId(4)) {
    println("  后端岗位已有人选")
  }
}
```

---

### 示例 2：课程与学生选课冲突检测

```moonbit
// 使用匈牙利算法检测课程安排中的冲突
// 左侧: 学生, 右侧: 课程时间段
// 目标: 最大化不冲突的选课安排

fn schedule_courses(
  student_count : Int,
  time_slot_count : Int,
  preferences : Array[(Int, Int)],
) -> MatchingResult {
  bipartite_matching(student_count, time_slot_count, preferences)
}

// 4 名学生, 3 个时间段, 各自偏好
let prefs : Array[(Int, Int)] = [
  (0, 0), (0, 1),       // 学生0: 偏好时段0, 1
  (1, 1), (1, 2),       // 学生1: 偏好时段1, 2
  (2, 0), (2, 2),       // 学生2: 偏好时段0, 2
  (3, 0), (3, 1),       // 学生3: 偏好时段0, 1
]

let result = schedule_courses(4, 3, prefs)
println("可安排的最大选课数: ${result.cardinality}")
// 输出: 3 (只有 3 个时间段, 最多 3 人不冲突)

// 查看哪些学生未能选课
let mut unmatched : Array[Int] = []
let mut idx = 0
while idx < 4 {
  if !result.is_matched(@core.NodeId(idx)) {
    unmatched.push(idx)
  }
  idx = idx + 1
}
println("未安排的学生索引: ${unmatched}")
// 输出示例: 未安排的学生索引: [1] (或其他, 取决于具体匹配)
```

---

### 示例 3：基于 GraphReadable 的通用用法

```moonbit
use lib.algo.matching.{bipartite_matching_graph, MatchingResult}
use lib.storage.{new_directed_undirected}
use lib.core.{GraphWritable, GraphReadable}

fn job_assignment_example() -> Unit {
  // 构建一个二分图表示工人与任务的适配关系
  let g = new_directed_undirected()

  // 添加节点: 0-2 为工人, 3-5 为任务
  for i in 0..<6 {
    GraphWritable::add_node(g, i.to_double()) |> ignore
  }

  // 工人 0 能完成任务 0, 3
  GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0) |> ignore
  GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0) |> ignore

  // 工人 1 能完成任务 3, 4
  GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(4), 1.0) |> ignore
  GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(5), 1.0) |> ignore

  // 工人 2 能完成任务 0, 5
  GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(5), 1.0) |> ignore

  // 定义左右分区
  let left : Array[@core.NodeId] = [
    @core.NodeId(0), @core.NodeId(1), @core.NodeId(2),
  ]
  let right : Array[@core.NodeId] = [
    @core.NodeId(3), @core.NodeId(4), @core.NodeId(5),
  ]

  // 运行匈牙利算法
  let result = bipartite_matching_graph(g, left, right)

  println("任务分配结果:")
  println("  最大分配数: ${result.cardinality}")

  let worker_names = ["工人A", "工人B", "工人C"]
  let task_names = ["任务X", "任务Y", "任务Z"]

  for edge in result.matching_edges {
    match edge {
      (worker, task) => {
        println("  ${worker_names[worker.0]} → ${task_names[task.0 - 3]}")
      }
    }
  }
  // 输出示例:
  //   任务分配结果:
  //     最大分配数: 3
  //     工人A → 任务X
  //     工人B → 任务Y
  //     工人C → 任务Z
}
```

---

## 复杂度分析

### 时间复杂度：O(VE)

| 操作 | 复杂度 | 次数 | 说明 |
|------|--------|------|------|
| **外层循环** | 遍历左侧节点 | O(\|U\|) 次 | 每个 U 节点触发一轮 DFS |
| **单次 DFS** | 搜索增广路 | O(E) 次 | 每条边因 `visited[]` 最多访问一次 |
| **总计** | | **O(VE)** | |

**详细推导**：

```
对于每个左侧节点 u ∈ U:
  1. 初始化 visited[]: O(|V|)
  2. 调用 hungarian_dfs(u):
     - 遍历 u 的所有邻接边: O(deg(u))
     - 对于每个被占用的 v, 递归调用 hungarian_dfs(match_right[v]):
       * 递归深度 ≤ O(|U|) (沿匹配边链回溯)
       * 每层递归中, 因 visited[], 每个 v 只处理一次
     - 总计: 所有右侧节点最多访问一次 → O(|V| + E_u)
       其中 E_u 是从可达节点出发的边数

  单次 DFS 上界: O(E)  (保守估计, 实际通常更快)

总时间: O(|U| × E) = O(VE)
```

### 空间复杂度：O(V + E)

| 数据结构 | 用途 | 大小 |
|---------|------|------|
| `adj[][]` | 邻接表 | O(E) |
| `match_right[]` | 右侧匹配关系 | O(\|V\|) |
| `visited[]` | 访问标记 | O(\|V\|) |
| `result_edges` | 结果存储 | O(\|V\|) |
| **总计** | | **O(V + E)** |

### 与其他匹配算法对比

```
┌──────────────────┬───────────────┬───────────────┬──────────────────────────┐
│     算法         │  时间复杂度    │  空间复杂度    │  特点                    │
├──────────────────┼───────────────┼───────────────┼──────────────────────────┤
│ **Hungarian**    │ **O(VE)**     │ **O(V)**      │ **★ 入门首选, 简单直观**  │
│ Hopcroft-Karp    │ O(E√V)        │ O(V+E)        │ 生产级, 大规模数据       │
│ Kuhn-Munkres     │ O(V³)         │ O(V²)         │ 带权完美匹配             │
│ Edmonds (一般图)  │ O(V²E)        │ O(V²)         │ 一般图 (含奇环)          │
└──────────────────┴───────────────┴───────────────┴──────────────────────────┘
```

---

## 实际应用场景

### 👔 场景 1：求职平台智能匹配

**问题**：将 N 名求职者匹配到 M 个岗位，每人只能应聘一个岗位，每个岗位只招一人

**解决方案**：
- 左侧 = 求职者，右侧 = 岗位
- 边 = 求职者具备该岗位的技能要求
- 匈牙利算法在毫秒级完成千级匹配

**实例**：小型招聘系统、实习岗位分配

### 🎮 场景 2：游戏服务器玩家匹配

**问题**：MOBA/FPS 游戏中将玩家公平分配到两队（简化版）

**解决方案**：
- 左侧 = 玩家，右侧 = 队伍位置
- 边 = 该玩家可以填充该位置（基于技能评分范围）

**注意**：大规模生产环境推荐使用 Hopcroft-Karp

### 📚 场景 3：大学选课系统冲突检测

**问题**：数百名学生选课，检测时间冲突并最大化满足选课意愿

**解决方案**：
- 左侧 = 学生选课请求，右侧 = 课程时间段
- 边 = 该学生在该时间段想选这门课
- 最大匹配 = 最多能满足多少选课请求

### 🏠 场景 4：宿舍分配问题

**问题**：将学生分配到宿舍，考虑学生的住宿偏好

**解决方案**：
- 左侧 = 学生，右侧 = 宿舍床位
- 边 = 该学生愿意入住该宿舍
- 匈牙利算法快速找到最大满意度的分配方案

### 🎯 场景 5：考试座位安排

**问题**：N 个考生，M 个座位，某些考生不能相邻（避免作弊）

**解决方案**：
- 将问题转化为二分图匹配（通过适当的图构造）
- 匈牙利算法求解可行安排

---

## Hungarian vs Hopcroft-Karp 对比

### 关系定位

```
┌─────────────────────────────────────────────────────────────┐
│                  二分图匹配算法家族                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  入门级 (学习用)                                             │
│  ┌─────────────────────────┐                               │
│  │   ★ Hungarian (本文)    │  ← 你在这里!                  │
│  │   O(VE), 简单易懂       │                               │
│  │   最佳教学算法           │                               │
│  └─────────────────────────┘                               │
│            ↓ 进阶升级                                        │
│  ┌─────────────────────────┐                               │
│  │   Hopcroft-Karp         │  ← 生产级选择                 │
│  │   O(E√V), 批量增广      │                               │
│  │   大规模数据标准算法     │                               │
│  └─────────────────────────┘                               │
│                                                             │
│  特殊需求                                                   │
│  ├── Kuhn-Munkres  → 带权完美匹配 (任务指派问题)             │
│  └── Edmonds       → 一般图最大匹配 (含奇环)                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 全面对比表

| 方面 | **Hungarian (Kuhn)** | **Hopcroft-Karp** |
|------|---------------------|-------------------|
| **别名** | Kuhn's Algorithm | HK 算法 |
| **提出年份** | 1955 (Kuhn) | 1973 (Hopcroft & Karp) |
| **时间复杂度** | **O(VE)** | **O(E√V)** |
| **空间复杂度** | **O(V)** | O(V+E) |
| **搜索策略** | 每次找 **1 条**增广路 | BFS 分层 + **多条**增广路 |
| **核心数据结构** | `match_right[]`, `visited[]` | `pair_u[]`, `pair_v[]`, `dist[]` |
| **增广方式** | 逐条增广 (贪心+回溯) | **批量增广** (Phase 制) |
| **实现难度** | ⭐ **简单** (30 行核心代码) | ⭐⭐ 中等 (80 行核心代码) |
| **适用规模** | **V < 5,000** | **V > 5,000** |
| **Phase 概念** | 无 (每轮独立) | **有** (BFS+DFS 组合) |
| **最优性** | 保证最大匹配 | 保证最大匹配 |
| **教学价值** | ⭐⭐⭐⭐⭐ **极高** | ⭐⭐⭐⭐ 高 |
| **代码可读性** | ⭐⭐⭐⭐⭐ **极好** | ⭐⭐⭐ 好 |

### 性能实测对比（直觉）

```
假设二分图: V=10,000 (每侧 5000), E=50,000

Hungarian:
  外层循环: 5000 次 (每个左节点)
  每次 DFS: 平均 O(E) = O(50000)
  总计 ≈ 5000 × 50000 = 2.5 × 10⁸ 次操作
  预期耗时: ~100-500 ms (取决于常数因子)

Hopcroft-Karp:
  Phase 数: √V ≈ 100 个
  每个 Phase 内: BFS O(E) + DFS O(k·E), k≈50 条增广路
  每个 Phase 工作量 ≈ O(E) = O(50000)
  总计 ≈ 100 × 50000 = 5 × 10⁶ 次操作
  预期耗时: ~2-10 ms

提速比: 2.5×10⁸ / 5×10⁶ = 50 倍! 🚀

结论:
  小数据 (< 1000 节点): 差异不明显, 都很快
  中等数据 (1K-5K): Hungarian 可接受
  大数据 (> 5K): 强烈推荐 Hopcroft-Karp
```

### 选型决策树

```
你需要二分图最大匹配?
  │
  ├─ 学习/教学/面试准备?
  │   └─ ★★★★★ 使用 Hungarian (本文)!
  │       理解原理最重要, 代码简洁易调试
  │
  ├─ 生产环境 / 数据规模 > 5000?
  │   └─ ★★★★★ 使用 Hopcroft-Karp
  │       性能优先, O(E√V) vs O(VE)
  │
  ├─ 数据规模 < 1000 且追求简单?
  │   └─ ★★★★☆ 使用 Hungarian
  │       够用且好维护
  │
  ├─ 需要带权匹配 (最小/最大权值和)?
  │   └─ 使用 Kuhn-Munkres 算法
  │       不同的问题类型!
  │
  └─ 一般图 (可能有奇环)?
      └─ 使用 Edmonds Blossom 算法
          二分图算法会给出错误结果!
```

### 代码风格对比

```
╔════════════════════════════════════════════════════════╗
║              Hungarian 代码风格 (简洁优雅)              ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  // 核心: 一个 DFS + 一个循环                           ║
║  for u in 0..n_left:                                   ║
║    visited[] = false                                   ║
║    if dfs(u): count++                                  ║
║                                                        ║
║  fn dfs(u):                                            ║
║    for v in adj[u]:                                    ║
║      if !visited[v]:                                   ║
║        visited[v] = true                               ║
║        if free(v): occupy(v); return true              ║
║        elif dfs(owner(v)): steal(v); return true       ║
║    return false                                        ║
║                                                        ║
║  特点:                                                 ║
║    ✅ 逻辑清晰, 一目了然                                ║
║    ✅ 易于手动模拟执行过程                              ║
║    ✅ 方便添加调试输出                                  ║
║    ✅ 适合作为教学范例                                  ║
║                                                        ║
╚════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════╗
║           Hopcroft-Karp 代码风格 (工程化)               ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  // 核心: 双层循环 (BFS Phase + DFS Phase)             ║
║  while true:                                           ║
║    bfs_layer() → dist[]                                ║
║    if !found: break                                    ║
║    for free_u in U:                                    ║
║      if dfs_augment(free_u): count++                   ║
║                                                        ║
║  fn bfs():  // 构建分层图                               ║
║  fn dfs():  // 约束搜索                                ║
║                                                        ║
║  特点:                                                 ║
║    ✅ 性能优异, 适合大数据                              ║
║    ✅ Phase 概念清晰                                   ║
║    ⚠️ 代码稍长, 需要理解分层思想                       ║
║    ⚠️ 调试相对复杂                                     ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

---

## 练习题

### 练习 1：手动执行匈牙利算法 ⭐⭐

对以下二分图手动执行匈牙利算法，写出完整过程：

```
  U₀ ──→ V₀
  │     ↑
  ├──→ V₁
  │
  U₁ ──→ V₀
  │
  ├──→ V₂
  │
  U₂ ──→ V₁
  └──→ V₂
```

要求写出：
1. 每轮的 `match_right[]` 初始状态和最终状态
2. 每次调用的 `hungarian_dfs()` 详细过程（包括递归调用栈）
3. 是否发生了"让位"操作？如果有，描述完整过程
4. 最终匹配及匹配数

<details>
<summary>📖 参考答案</summary>

```
初始: match_right = [None, None, None]

═══ 第 1 轮: U₀ ═══
visited = [F, F, F]
DFS(U₀):
  V₀: 自由 → match_right[0]=Some(0) ✅
cardinality = 1
match_right = [Some(0), None, None]
匹配: (U₀, V₀)

═══ 第 2 轮: U₁ ═══
visited = [F, F, F]
DFS(U₁):
  V₀: 被U₀占(match_right[0]=Some(0))
    → 递归 DFS(U₀):
      visited[0]=T
      V₀: visited[0]=T → 跳过
      → return false ❌
  V₂: 自由 → match_right[2]=Some(1) ✅
cardinality = 2
match_right = [Some(0), None, Some(1)]
匹配: (U₀, V₀), (U₁, V₂)

═══ 第 3 轮: U₂ ═══
visited = [F, F, F]
DFS(U₂):
  V₁: 自由 → match_right[1]=Some(2) ✅
cardinality = 3
match_right = [Some(0), Some(2), Some(1)]
匹配: (U₀, V₀), (U₂, V₁), (U₁, V₂)

🎉 最终: MAX_MATCHING = 3 (完美匹配!)
本次未发生让位操作 (比较简单的例子)
```

</details>

---

### 练习 2：必须"连环让位"的例子 ⭐⭐⭐

构造一个二分图，使得匈牙利算法在执行过程中**至少发生 2 层递归让位**才能成功增广：

```moonbit
// 要求:
// 1. 设计边集使得某个左侧节点在尝试配对时,
//    需要让已配对的节点 A 让位,
//    而 A 又需要让 B 让位, 以此类推
// 2. 写出完整的执行过程
// 3. 分析递归深度和让位链条长度

fn design_chaining_example() -> Array[(Int, Int)] {
  // TODO: 你的设计
  // 提示: 至少 4 个左侧节点, 4 个右侧节点
}
```

<details>
<summary>💡 提示与参考答案</summary>

```moonbit
// 经典的"链条让位"例子:

let edges : Array[(Int, Int)] = [
  (0, 0),  // U₀ → V₀
  (1, 0),  // U₁ → V₀  (与 U₀ 冲突!)
  (1, 1),  // U₁ → V₁
  (2, 1),  // U₂ → V₁  (与 U₁ 冲突!)
  (2, 2),  // U₂ → V₂
  (3, 2),  // U₃ → V₂  (与 U₂ 冲突!)
  (3, 3),  // U₃ → V₃
]

// 执行过程:

// 第 1 轮 U₀: V₀ 自由 → ✅ (U₀, V₀)
// 第 2 轮 U₁: V₀ 被占 → 递归 U₀ → U₀ 无替代 → ❌
//             V₁ 自由 → ✅ (U₁, V₁)
// 第 3 轮 U₂: V₁ 被占 → 递归 U₁ → U₁ 可换到 V₀?
//                  ├─ 递归 U₀: V₀ 被自己占... visited[0]=T → 跳过 → ❌
//                  └─ U₁ 无法让位 → ❌
//             V₂ 自由 → ✅ (U₂, V₂)
// 第 4 轮 U₃: V₂ 被占 → 递归 U₂ → U₂ 可换到 V₁?
//                  ├─ 递归 U₁: V₁ 被自己占 → 尝试 V₀?
//                  │   └─ 递归 U₀: V₀ visited → ❌
//                  └─ U₁ 无法让位 → ❌
//             V₃ 自由 → ✅ (U₃, V₃)

// 结果: 4 对匹配, 但没有发生真正的"连环让位"!
//      (因为这个设计中每个节点都有"退路"——自由节点)

// 真正的连环让位需要更巧妙的设计:
// 让某些节点"无路可退", 强制深层递归

let chain_edges : Array[(Int, Int)] = [
  (0, 0),           // U₀ 只有 V₀
  (1, 0), (1, 1),   // U₁ 有 V₀, V₁
  (2, 1), (2, 2),   // U₂ 有 V₁, V₂
  (3, 2),           // U₃ 只有 V₂ (逼迫连环让位!)
]

// 第 1 轮 U₀: V₀ → ✅
// 第 2 轮 U₁: V₀ 被占 → 递归 U₀ → U₀ 无其他邻居 → ❌
//             V₁ → ✅
// 第 3 轮 U₂: V₁ 被占 → 递归 U₁ → U₁ 可换到 V₀?
//                  └─ 递归 U₀: V₀ visited → ❌
//                  → U₁ 不让 → ❌
//             V₂ → ✅
// 第 4 轮 U₃: V₂ 被占 → 递归 U₂ → U₂ 可换到 V₁?
//                  └─ 递归 U₁ → U₁ 可换到 V₀?
//                      └─ 递归 U₀: V₀ visited → ❌
//                  → 整条链失败 → ❌
//             U₃ 无其他邻居 → ❌

// 最终: 3 对匹配 (U₃ 未能配对)
// 递归深度达到 3 层! (U₃→U₂→U₁→U₀)
```

**应用场景**：理解递归深度的 worst case、分析算法在实际数据上的行为特征

</details>

---

### 练习 3：利用匈牙利算法求最小路径覆盖 ⭐⭐⭐⭐

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
//   左侧 U = 每个节点的"出点" (U_i 表示节点 i 作为前驱)
//   右侧 V = 每个节点的"入点" (V_j 表示节点 j 作为后继)
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

  // 2. 运行匈牙利算法
  let matching_result = bipartite_matching(n, n, adj_to_edges(adj, n))

  // 3. 计算最小路径数
  let path_count = n - matching_result.cardinality

  // 4. 从匹配重构路径 (略, 需要根据 match_right[] 追踪链路)
  let paths : Array[Array[Int]] = reconstruct_paths(n, matching_result)

  (path_count, paths)
}

// 辅助函数: 将邻接表转为边列表
fn adj_to_edges(adj : Array[Array[Int]], n : Int) -> Array[(Int, Int)] {
  let edges : Array[(Int, Int)] = []
  let mut u = 0
  while u < n {
    let mut i = 0
    while i < adj[u].length() {
      edges.push((u, adj[u][i]))
      i = i + 1
    }
    u = u + 1
  }
  edges
}

// 应用实例:
// 7 个任务, 依赖关系如下:
//   0→1, 0→2, 1→3, 2→3, 3→4, 4→5, 4→6
//
// 最小路径覆盖 = 7 - max_matching
// 如果 max_matching = 5, 则只需 2 条路径:
//   路径1: 0→1→3→4→5
//   路径2: 2→3→4→6  (注意: 3 和 4 被共享是不对的,
//                      实际需要拆点或重新思考)
//
// 更准确的例子:
//   6 个节点, 边: 0→1, 0→2, 1→3, 2→4, 3→5, 4→5
//   max_matching = 4 (例如: 0→1, 1→3, 2→4, 3→5 或类似)
//   最小路径数 = 6 - 4 = 2
//   路径: [0,1,3,5] 和 [2,4,5]? 还是其他组合?
```

**经典竞赛题目来源**：POJ 1422、HDU 3862、洛谷 P2764

**进阶挑战**：实现路径重构函数 `reconstruct_paths()`，输出具体的路径方案。

</details>

---

## 相关资源

### 📚 推荐阅读

| 资源 | 类型 | 说明 |
|------|------|------|
| *Kuhn's Algorithm* | 教程 | CP-Algorithms 上的权威讲解，多种语言实现 |
| *VisuAlgo* | 交互式可视化 | https://visualgo.net/en/matching — 强烈推荐的动画演示! |
| *Wikipedia* | 百科 | Bipartite matching & Hungarian algorithm |
| *Hopcroft-Karp 教程* | 本站文档 | [/algorithms/matching/bipartite/hopcroft-karp](/algorithms/matching/bipartite/hopcroft-karp) （进阶版） |
| *Original Paper (Kuhn)* | 论文 | H. W. Kuhn, "The Hungarian Method for the Assignment Problem," Naval Research Logistics, 1955 |

### 🔗 相关算法

```
Hungarian (本文/Kuhn's) — 二分图最大匹配 ★ 入门版
  ├── Hopcroft-Karp         → 进阶版, O(E√V), 生产级选择
  ├── Kuhn-Munkres          → 带权完美匹配 (分配问题), O(V³)
  ├── Edmonds Blossom       → 一般图最大匹配 (含奇环), O(V²E)
  ├── Dinic (网络流转化)    → 二分图匹配 = 单位容量最大流
  └── 最小路径覆盖          → DAG 应用: N - max_matching

匹配算法家族树:
  图匹配
  ├── 二分图匹配
  │   ├── 无权 (本文重点):
  │   │   ├── Hungarian (Kuhn) ⭐ 入门
  │   │   └── Hopcroft-Karp ⭐ 进阶
  │   └── 带权:
  │       └── Kuhn-Munkres, 最小/最大权匹配
  └── 一般图匹配
      ├── 最大匹配: Edmonds (花算法)
      └── 完美匹配: 带权版本
```

### 🛠️ mbtgraph 相关源码

| 文件 | 说明 |
|------|------|
| [`lib/algo/matching/hungarian.mbt`](../../../lib/algo/matching/hungarian.mbt) | 匈牙利算法核心实现 (本文讲解的源码) |
| [`lib/algo/matching/types.mbt`](../../../lib/algo/matching/types.mbt) | `MatchingResult` 类型定义及辅助方法 |
| [`lib/algo/matching/hopcroft_karp.mbt`](../../../lib/algo/matching/hopcroft_karp.mbt) | Hopcroft-Karp 算法 (进阶对比) |
| [`lib/algo/matching/kuhn_munkres.mbt`](../../../lib/algo/matching/kuhn_munkres.mbt) | Kuhn-Munkres 带权匹配 |
| [`lib/algo/matching/matching_test.mbt`](../../../lib/algo/matching/matching_test.mbt) | 完整测试套件 (17 tests) |

### 🎥 视频资源

| 资源 | 平台 | 说明 |
|------|------|------|
| *Bipartite Matching* | YouTube | William Fiset 的可视化讲解 (英文) |
| *二分图匹配* | Bilibili | 国内优质算法视频 (中文) |
| *匈牙利算法* | 网易公开课 | 大学算法课程片段 |

---

## 总结清单

### ✅ 核心知识点

- [ ] **二分图**：两侧节点独立，边只跨越两侧，不含奇环
- [ ] **匹配**：无公共端点的边集，cardinality = 匹配数
- [ ] **增广路**：两端自由的交替路，翻转可增加匹配数
- [ ] **Berge 定理**：无增广路 ⇔ 最大匹配（理论基础）
- [ ] **DFS 增广**：递归搜索 + 占领/让位机制
- [ ] **visited[] 重置**：每轮 DFS 前必须清空，防止跨轮干扰
- [ ] **时间复杂度**：O(VE)，适合中小规模数据（V < 5000）
- [ ] **vs HC-Karp**：入门版 vs 进阶版，简单 vs 快速

### 🔑 关键代码模式

```moonbit
// 匈牙利算法标准模板
pub fn bipartite_matching(n_left, n_right, edges) -> MatchingResult {
  // 1. 构建邻接表
  let adj = build_adj_list(n_left, n_right, edges)

  // 2. 初始化匹配数组
  let match_right = Array::make(n_right, None)

  // 3. 主循环: 为每个左节点找增广路
  let mut cardinality = 0
  for u in 0..<n_left {
    let visited = Array::make(n_right, false)  // 每轮重置!
    if hungarian_dfs(u, adj, match_right, visited) {
      cardinality = cardinality + 1
    }
  }

  // 4. 收集结果
  collect_results(match_right, n_left)
}

// DFS 增广核心逻辑
fn hungarian_dfs(u, adj, match_right, visited) -> Bool {
  for v in adj[u] {
    if !visited[v] {
      visited[v] = true
      match match_right[v] {
        None => {
          match_right[v] = Some(u)  // 直接占领
          return true
        }
        Some(matched_u) =>
          if hungarian_dfs(matched_u, adj, match_right, visited) {
            match_right[v] = Some(u)  // 抢占成功
            return true
          }
      }
    }
  }
  false  // 找不到增广路
}
```

### ⚠️ 常见陷阱

| 陷阱 | 后果 | 解决方法 |
|------|------|---------|
| **忘记重置 `visited[]`** | 错误剪枝，丢失合法增广路 | 每轮 DFS 前 `visited = [false, ...]` |
| **混淆 `match_right` 索引** | 匹配结果错乱 | `match_right[j] = i` 表示 Vⱼ↔Uᵢ |
| **忽略边界条件** | 空图崩溃 | 开头检查 `n_left==0 \|\| n_right==0` |
| **递归无限循环** | 栈溢出 | `visited[]` 保证每个右节点只访问一次 |
| **NodeId 与 Int 混用** | 类型错误 | 内部统一用 Int 索引，输出时转换 |
| **认为"贪心最优"** | 理解偏差 | 匈牙利不是纯贪心，增广路定理保证最优 |

### 📊 二分图匹配算法选型速查

```
┌──────────────┬───────────┬───────────┬──────────────────────────┐
│    场景        │  推荐      │  备选      │  避免使用              │
├──────────────┼───────────┼───────────┼──────────────────────────┤
│ 学习/教学     │ Hungarian │ HC-Karp   │ Edmonds (过于复杂)     │
│ 面试准备     │ Hungarian │ HC-Karp   │ 过于复杂的优化          │
│ 小项目(<1K)  │ Hungarian │ HC-Karp   │ 引入不必要的复杂度      │
│ 生产环境(>5K) │ HC-Karp ⭐ │ Hungarian │ 太慢!                 │
│ 带权匹配      │ KM        │ 匈牙利+权  │ 无权算法               │
│ 一般图(奇环)  │ Edmonds   │ 转化为流   │ 二分图算法 (错误!)      │
│ DAG路径覆盖   │ Hungarian │ HC-Karp   │ 暴力枚举               │
└──────────────┴───────────┴───────────┴──────────────────────────┘
```

### 🎯 一句话记忆

> **匈牙利算法 = 月老红线：每次牵一对，遇到冲突就让别人"换对象"腾位置，直到所有人都尝试过为止。**

### 🔄 下一步学习路径

```
你已经掌握了 Hungarian (本文) ↓

  [可选] 深入理解
    ├── 手动模拟更多例子 (练习 1-3)
    ├── 阅读 CP-Algorithms 详细证明
    └─ 在 VisuAlgo 上交互式实验

  [推荐] 进阶升级
    └── 学习 Hopcroft-Karp 算法
        ├── 理解 BFS 分层思想
        ├── 掌握多路增广机制
        └─ 实现 O(E√V) 版本

  [扩展] 相关领域
    ├── Kuhn-Munkres (带权匹配)
    ├── 网络流 (Dinic/Edmonds-Karp)
    └─ 一般图匹配 (Edmonds Blossom)
```

---

<div align="center">

**🎯 匈牙利算法 — DFS 增广路搜索，二分图最大匹配的最佳入门选择**

*上一篇：[二分图匹配概述](/algorithms/matching) | [下一篇：Hopcroft-Karp 算法](/algorithms/matching/bipartite/hopcroft-karp) | [返回算法目录](/algorithms/index)*

</div>
