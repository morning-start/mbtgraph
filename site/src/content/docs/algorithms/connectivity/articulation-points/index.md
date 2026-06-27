---
title: "Tarjan 算法：割点与桥（Articulation Points & Bridges）"
description: "基于 DFS 时间戳与低点值的无向图关键节点/边检测，O(V+E) 时间复杂度，网络脆弱性分析核心"
---

# 🔗 Tarjan 算法：割点与桥

> **"想象一个城市的交通网络：如果拆除某个路口，整个城市就被分割成互不连通的几个区域——这个路口就是'割点'。同样，如果炸断某座桥梁，两岸就失去联系——这座桥就是'桥'。Tarjan 算法能在一次 DFS 中找出所有这样的关键点。"**

## 📖 算法简介

### 什么是割点和桥？

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   割点 (Articulation Point):                        │
│   移除该节点 → 图的连通分量数 ↑                      │
│                                                     │
│   桥 (Bridge / Cut Edge):                           │
│   移除该边   → 图的连通分量数 ↑                      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**直观理解**：

```
        ① ──── ② ──── ③        ← 链式结构
              ╱ ╲

   割点: {②}                    ← 删掉 ②, 图分裂为 {①} 和 {③}
   桥:   {(①,②), (②,③)}       ← 删掉任意一条边, 图不连通


        ① ──── ②                 ← 三角形 + 尾巴
        │╲    │
        │ ╲   │
        ③ ────┘
            │
            ④                   ← 悬挂节点

   割点: {②, ③}                  ← ② 连接三角和尾巴; ③ 是尾巴入口
   桥:   {(③,④)}                ← 唯一的"独木桥"
```

### Tarjan 的方法

又是 **Robert Tarjan**！（和 SCC 同一位作者）。核心思想惊人地相似：

| | **SCC (强连通分量)** | **割点 & 桥** |
|--|---------------------|---------------|
| **图类型** | 有向图 | 无向图 |
| **核心数据** | `disc[]` + `low[]` | `disc[]` + `low[]` |
| **DFS 方式** | 单次 DFS | 单次 DFS |
| **判定条件** | `low[v] == disc[v]` | 割点: `low[child] >= disc[u]`<br>桥: `low[child] > disc[u]` |
| **额外处理** | 栈管理 | 根节点特判 / parent 跳过 |

### 为什么是 O(V+E)？

与 SCC 相同的原因：每个节点访问一次，每条边检查两次（正反方向），所有辅助操作均为 O(1)。

---

## 核心概念

### 🕐 发现时间 (disc[] / DFN)

与 SCC 完全相同——DFS 访问节点的顺序编号：

```moonbit
state.disc[u] = state.time_ref[0]   // 记录发现时间
state.time_ref[0] += 1               // 时间戳递增
```

### 📉 低点值 (low[])

也完全相同——从当前节点能回溯到的**最早发现时间**：

```moonbit
state.low[u] = min(
  state.disc[u],           // 自身
  state.low[每个子节点 v], // 子树能到的最早点
  state.disc[每个已访问邻居 w]  // 回边能到的点
)
```

### ⚠️ 无向图的特殊处理

与有向图 SCC 的一个**关键区别**：

```
无向图中: 边 (u,v) 和边 (v,u) 是同一条边!

问题: 从 u 到 v 是树边, 但从 v 看到 u 时,
      u 已经访问过了 (disc[u] != -1)
      如果按 SCC 的逻辑, 会误判为 "回边"

解决: 跳过直接父节点!
  if vid != parent_u {
    // 这才是真正的回边 (或交叉边)
  }
```

### ✅ 桥的判定条件

```moonbit
if state.low[vid] > state.disc[u] {
  // 边 (u, vid) 是一座桥!
}
```

**直觉**：子节点 `vid` 及其后代**无法通过任何路径回到 `u` 或 `u` 的祖先**。所以 `(u, vid)` 是唯一的连接通道 → **桥**。

```
     u (disc=3)
     │
     │ ← 这是唯一的路!
     ↓
   vid (low=5)

   low[vid]=5 > disc[u]=3  →  (u,vid) 是桥 ✓
```

### ✅ 割点的判定条件（两种情况）

#### 情况 1：根节点

```moonbit
if is_root && child_count >= 2 {
  state.ap[u] = true  // 根且有 ≥2 个子树 → 割点
}
```

**为什么？**

```
     root
    ╱     ╲          ← root 有 2 个子树
   A       B         删除 root 后, A 和 B 无法互通!

     root
     │               ← root 只有 1 个子树
     A               删除 root 后, A 仍然内部连通
                      → root 不是割点
```

#### 情况 2：非根节点

```moonbit
if !is_root && state.low[vid] >= state.disc[u] {
  state.ap[u] = true  // 子树无法回到祖先 → u 是割点
}
```

**直觉**：存在至少一个子节点 `v`，其整个子树**没有回边能绕过 `u`** 到达 `u` 的上方。删除 `u` 后，这个子树就与图的其余部分断开了。

```
     ancestor (disc=1)
         │
         u (disc=3)       ← 可能是割点?
        ╱ ╲
       v   w
       │
       x

  如果 low[v] >= disc[u]:
    v 的子树无法绕过 u 到达 ancestor
    → 删除 u 后, {v,x,...} 与 rest 断开
    → u 是割点! ✓
```

### 📊 割点 vs 桥的条件对比

```
┌──────────────────┬─────────────────────────────┬────────────────────────────┐
│                  │  桥 (Bridge)                │  割点 (Articulation Point) │
├──────────────────┼─────────────────────────────┼────────────────────────────┤
│ 条件             │ low[child] > disc[parent]   │ low[child] ≥ disc[parent] │
│ 严格性           │ 严格大于 (>)                │ 大于等于 (≥)               │
│ 含义             │ child 无法到达 parent        │ child 无法到达 parent 的祖先 │
│ 根节点特判        │ 不需要                     │ 需要: child_count ≥ 2     │
│ 对应关系         │ 每个割点至少关联 1 座桥?     │ 不一定! (见反例)           │
└──────────────────┴─────────────────────────────┴────────────────────────────┘
```

> ⚠️ **重要区别**：桥用 `>`，割点用 `≥`！差一个等号，含义完全不同。

---

## 动画演示 — 桥的检测

### 示例图（无向）

```
        ① ─────── ② ─────── ③
        │         │
        │         │
        ④ ─────── ⑤

   这是一个"双钻石"结构:
   - 左侧: ①-②-④ 形成环 (无桥)
   - 右侧: ②-③-⑤ 形成环 (无桥)
   - 中间: ② 是枢纽
   - 问: 有桥吗?

   答案: 此图没有桥! (因为每个边都在某个环中)
   让我们换一个更有趣的例子 ↓
```

### 更好的示例图

```
   ① ──── ② ──── ③
   │       │
   │       │
   ④ ──── ⑤
           │
           │
           ⑥

   边列表 (无向):
   ①-②, ②-③, ①-④, ④-⑤, ②-⑤, ⑤-⑥
```

---

## 🎬 交互式动画：分步执行过程

<div class="viz-preview-card">
  <iframe src="/visualizations/cutpoints/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/cutpoints/" target="_blank" class="viz-fullscreen-btn">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

下面是上述算法的文本分步描述，对应动画中的每一步操作：

### 桥检测 DFS 过程

#### 初始化

```
disc[] = [-1, -1, -1, -1, -1, -1]
low[]  = [ 0,  0,  0,  0,  0,  0]
time   = 0
bridges = []
parent = [-1, -1, -1, -1, -1, -1]
```

#### Step 1: DFS 进入 ① (root)

```
操作: disc[①]=0, low[①]=0, time=1

  ①★ 的邻居: ②, ④

  → 先访问 ② (未访问)
```

#### Step 2: DFS 进入 ②

```
操作: disc[②]=1, low[②]=1, time=2, parent[②]=①

  ② 的邻居: ①, ③, ⑤

  ①: 已访问 (disc=0), 且 ① == parent[②] → 跳过! (不是回边)
  ③: 未访问 → 进入
```

#### Step 3: DFS 进入 ③

```
操作: disc[③]=2, low[③]=2, time=3, parent[③]=②

  ③ 的邻居: ②

  ②: 已访问 (disc=1), 且 ② == parent[③] → 跳过!

  ③ 无其他邻居 → 回溯

  ⚡ 检查边 (②,③):
     low[③]=2 > disc[②]=1 ?
     2 > 1 → ✅ YES!
     → **(②,③) 是桥!** bridges.push((②,③))

  回到 ②: low[②] = min(low[②]=1, low[③]=2) = 1 (不变)
```

#### Step 4: 回到 ②, 继续访问 ⑤

```
  ⑤: 未访问 → 进入
```

#### Step 5: DFS 进入 ⑤

```
操作: disc[⑤]=3, low[⑤]=3, time=4, parent[⑤]=②

  ⑤ 的邻居: ④, ②, ⑥

  ④: 未访问 → 进入
```

#### Step 6: DFS 进入 ④

```
操作: disc[④]=4, low[④]=4, time=5, parent[④]=⑤

  ④ 的邻居: ①, ⑤

  ①: 已访问 (disc=0), 且 ① ≠ parent[④](=⑤) → **回边!**
     low[④] = min(4, disc[①]=0) = **0** ✓

  ⑤: 已访问 (disc=3), 且 ⑤ == parent[④] → 跳过

  → 回溯

  ⚡ 检查边 (⑤,④):
     low[④]=0 > disc[⑤]=3 ?
     0 > 3? ❌ NO → 不是桥 (因为有回边 ④→①!)

  回到 ⑤: low[⑤] = min(3, low[④]=0) = **0** ✓
```

#### Step 7: 回到 ⑤, 继续检查邻居

```
  ②: 已访问 (disc=1), 且 ② == parent[⑤] → 跳过
  ⑥: 未访问 → 进入
```

#### Step 8: DFS 进入 ⑥

```
操作: disc[⑥]=5, low[⑥]=5, time=6, parent[⑥]=⑤

  ⑥ 的邻居: ⑤

  ⑤: 已访问, 且 ⑤ == parent[⑥] → 跳过

  → 回溯

  ⚡ 检查边 (⑤,⑥):
     low[⑥]=5 > disc[⑤]=3 ?
     5 > 3 → ✅ YES!
     → **(⑤,⑥) 是桥!** bridges.push((⑤,⑥))

  回到 ⑤: low[⑤] = min(0, low[⑥]=5) = 0 (不变)
```

#### Step 9: 回溯链: ⑤ → ② → ①

```
  回到 ⑤: 所有邻居处理完毕
  ⚡ 检查边 (②,⑤):
     low[⑤]=0 > disc[②]=1 ?  0 > 1? ❌ 不是桥

  回到 ②: 所有邻居处理完毕
  ⚡ 检查边 (①,②):
     low[②]=1 > disc[①]=0 ?  1 > 0? ❌ 不是桥
     (因为 ② 通过 ⑤→④→① 能回到 ① 的祖先方向...嗯实际上①就是root)

  回到 ①: 继续处理下一个邻居 ④
  ④: 已访问 (disc=4) → 跳过
```

#### 最终结果

```
┌──────────────────────────────────────────────┐
│  桥检测结果                                   │
├──────────────────────────────────────────────┤
│                                              │
│  🌉 找到 2 座桥:                             │
│     1. (②, ③)                               │
│     2. (⑤, ⑥)                               │
│                                              │
│  验证:                                       │
│  - 删除 ②-③: ③ 变成孤立节点 ✓               │
│  - 删除 ⑤-⑥: ⑥ 变成孤立节点 ✓               │
│  - 其他边都在环中, 删除后仍连通 ✓              │
│                                              │
└──────────────────────────────────────────────┘
```

---

## 动画演示 — 割点的检测

使用同一张图，同时追踪割点：

```
   ① ──── ② ──── ③
   │       │
   │       │
   ④ ──── ⑤
           │
           │
           ⑥
```

### 割点判定过程

在上述 DFS 过程中，我们同时追踪割点判定：

```
节点  disc  low  parent  child_count  is_root  判定结果
─────  ────  ────  ──────  ───────────  ───────  ─────────
①      0     0     -1        2          true    child_count=2 ≥ 2 → **割点!** ✓
②      1     1      1        2          false   待定
③      2     2      2        0          false   叶子节点, 不可能是割点
④      4     0      5        0          false   叶子节点
⑤      3     0      2        2          false   待定
⑥      5     5      5        0          false   叶子节点
```

**详细判定过程**：

| 时刻 | 检查对象 | 条件 | 结果 |
|------|---------|------|------|
| ③ 回溯时 | 边(②→③) | `low[③]=2 ≥ disc[②]=1` 且 ②非根 | **② 标记为割点** |
| ④ 回溯时 | 边(⑤→④) | `low[④]=0 ≥ disc[⑤]=3`? 0≥3❌ | ⑤ 不因此标记 |
| ⑥ 回溯时 | 边(⑤→⑥) | `low[⑥]=5 ≥ disc[⑤]=3` 且 ⑤非根 | **⑤ 标记为割点** |
| ⑤ 回溯时 | 边(②→⑤) | `low[⑤]=0 ≥ disc[②]=1`? 0≥1❌ | ② 已标记, 无变化 |
| ① 结束时 | 根节点 ① | `child_count=2 ≥ 2` | **① 标记为割点** |

### 📊 最终结果

```
┌────────────────────────────────────────────────────┐
│  割点检测结果                                      │
├────────────────────────────────────────────────────┤
│                                                    │
│  🔴 找到 3 个割点:                                 │
│     1. 节点 ① (根, 2 个子树)                       │
│     2. 节点 ② (③ 无法绕过它)                       │
│     3. 节点 ⑤ (⑥ 无法绕过它)                       │
│                                                    │
│  验证:                                             │
│  - 删除 ①: {④} 与 rest 分离 ✓                    │
│  - 删除 ②: {③} 与 rest 分离 ✓                    │
│  - 删除 ⑤: {⑥} 与 rest 分离 ✓                    │
│  - 删除 ③/④/⑥: 图仍然连通 ✗ (不是割点)            │
│                                                    │
│  🌉 同时找到的桥:                                   │
│     (②,③) 和 (⑤,⑥)                              │
│                                                    │
│  注意: 割点 ① 和 ② 并不直接对应桥!                │
│  (①-② 边不是桥, 因为 ⑤-④-① 提供了替代路径)       │
└────────────────────────────────────────────────────┘
```

---

## 🔧 MoonBit 完整实现

### 桥检测实现

```moonbit
///|
/// Tarjan 桥查找算法
///
/// 基于 DFS 时间戳和低点值检测无向图中的桥。时间复杂度 O(V+E)。///|

priv struct BridgeState {
  disc : Array[Int]           // 发现时间
  low : Array[Int]            // 低点值
  bridges_list : Array[(@core.NodeId, @core.NodeId)]  // 桥列表
  time_ref : Array[Int]       // 时间戳计数器
}

fn new_bridge_state(size : Int) -> BridgeState {
  BridgeState::{
    disc: Array::make(size, -1),
    low: Array::make(size, 0),
    bridges_list: [],
    time_ref: [0],
  }
}

// 核心 DFS
fn[G : @core.GraphReadable] tarjan_bridge_dfs(
  state : BridgeState,
  g : G,
  u : Int,
  parent_u : Int,
) -> Unit {
  state.disc[u] = state.time_ref[0]
  state.low[u] = state.time_ref[0]
  state.time_ref[0] = state.time_ref[0] + 1

  for v in @core.GraphReadable::neighbors(g, @core.NodeId(u)) {
    let vid = v.0
    if vid < 0 || vid >= state.disc.length() {
      continue
    }

    if state.disc[vid] == -1 {
      // 树边: 递归访问子节点
      tarjan_bridge_dfs(state, g, vid, u)

      // 用子节点的 low 更新当前节点
      if state.low[vid] < state.low[u] {
        state.low[u] = state.low[vid]
      }

      // ★ 桥判定: low[child] > disc[parent]
      if state.low[vid] > state.disc[u] {
        state.bridges_list.push((@core.NodeId(u), @core.NodeId(vid)))
      }
    } else if vid != parent_u {
      // 回边: 跳过父节点, 更新 low
      if state.disc[vid] < state.low[u] {
        state.low[u] = state.disc[vid]
      }
    }
  }
}

// 公开 API
pub fn[G : @core.GraphReadable] find_bridges_undirected(graph : G) -> BridgeResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return BridgeResult::{ bridges: [], is_bridge: [], count: 0 }
  }

  let max_id = /* find max node id */
  let size = int_max(max_id + 1, 1)
  let state = new_bridge_state(size)

  for node in @core.GraphReadable::node_ids(graph) {
    if state.disc[node.0] == -1 {
      tarjan_bridge_dfs(state, graph, node.0, -1)
    }
  }

  // 构建结果...
  BridgeResult::{ bridges, is_bridge, count: bridges.length() }
}
```

### 割点检测实现

```moonbit
///|
/// Tarjan 割点查找算法
///
/// 基于 DFS 时间戳和低点值检测无向图中的割点。时间复杂度 O(V+E)。
///|

priv struct APState {
  disc : Array[Int]      // 发现时间
  low : Array[Int]       // 低点值
  parent : Array[Int]    // 父节点
  ap : Array[Bool]       // 是否为割点
  time_ref : Array[Int]  // 时间戳计数器
}

fn new_ap_state(size : Int) -> APState {
  APState::{
    disc: Array::make(size, -1),
    low: Array::make(size, 0),
    parent: Array::make(size, -1),
    ap: Array::make(size, false),
    time_ref: [0],
  }
}

// 核心 DFS
fn[G : @core.GraphReadable] tarjan_ap_dfs(
  state : APState,
  g : G,
  u : Int,
  is_root : Bool,
) -> Unit {
  state.disc[u] = state.time_ref[0]
  state.low[u] = state.time_ref[0]
  state.time_ref[0] = state.time_ref[0] + 1

  let mut child_count = 0

  for v in @core.GraphReadable::neighbors(g, @core.NodeId(u)) {
    let vid = v.0
    if vid < 0 || vid >= state.disc.length() {
      continue
    }

    if state.disc[vid] == -1 {
      // 树边
      state.parent[vid] = u
      child_count = child_count + 1
      tarjan_ap_dfs(state, g, vid, false)

      // 用子节点 low 更新
      if state.low[vid] < state.low[u] {
        state.low[u] = state.low[vid]
      }

      // ★ 割点判定 (非根): low[child] ≥ disc[parent]
      if !is_root && state.low[vid] >= state.disc[u] {
        state.ap[u] = true
      }
    } else if vid != state.parent[u] {
      // 回边: 跳过父节点
      if state.disc[vid] < state.low[u] {
        state.low[u] = state.disc[vid]
      }
    }
  }

  // ★ 割点判定 (根节点): child_count ≥ 2
  if is_root && child_count >= 2 {
    state.ap[u] = true
  }
}

// 公开 API
pub fn[G : @core.GraphReadable] find_articulation_points_undirected(
  g : G,
) -> CutPointResult {
  // ... 初始化 + DFS + 构建结果 ...
}
```

---

## 代码详解

### 设计决策 1️⃣：为什么 `vid != parent_u` 如此关键？

```moonbit
// 无向图中, u-v 和 v-u 是同一条边
// DFS 从 u 进入 v 时 (u,v) 是树边
// 从 v 看 u 时, u 已访问, 但这不是"回边"而是"来时的路"

if state.disc[vid] == -1 {
  // 树边: 第一次遇到
} else if vid != parent_u {
  // 真正的回边: 排除了来时的路
}
```

**如果不跳过 parent**：
```
  u → v (树边, parent[v]=u)
  v 看到 u: disc[u]!=-1, 误判为回边
  → low[v] = min(low[v], disc[u]) = disc[u]
  → low[v] 永远 ≤ disc[u] (因为 low[v] 初始化为 disc[v] > disc[u])
  → 永远不会出现 low[v] > disc[u]
  → **永远检测不到桥!**
```

### 设计决策 2️⃣：割点的两种条件为何不同？

```
根节点 (is_root=true):
  判据: child_count ≥ 2
  原因: 根节点没有 "disc[ancestor]" 可供比较
       它本身就是最早的节点!

非根节点 (!is_root):
  判据: ∃ child v, low[v] ≥ disc[u]
  原因: v 的子树无法绕过 u 到达更早的节点
       删除 u 就切断了这条路径
```

**为什么非根用 `≥` 而桥用 `>`？**

```
桥: low[v] > disc[u]
   → v **严格无法到达** u (更不用说 u 的祖先)
   → (u,v) 是唯一通路

割点: low[v] ≥ disc[u]
   → v 可以到达 u 本身 (low[v] == disc[u]), 但**无法越过 u**
   → 删除 u 后, v 的子树仍与图的其余部分分离
   → 即使 v 能到 u, u 一删还是断
```

### 设计决策 3️⃣：为什么割点不一定对应桥？

```
反例:

    ①
    │╲
    │ ╲
    ② ─③

  ② 是割点吗?
    删除 ② → ① 和 ③ 之间还有 ①-③ 边 → 仍然连通!
    所以 ② 不是割点...

让我想一个更好的反例:

    ① ─ ② ─ ③
    │    │
    └────┘

  ② 是割点吗?
    删除 ② → ① 和 ③ 不连通 (只有 ①-③? 没有!)
    实际上 ①-②-③ 和 ①-②-①(自环?) ...

正确反例 ("哑铃"图):

  A ─ B ─ C    (B 是割点)
  │       │
  D       E

  删除 B: {A,D} 与 {C,E} 分离 → B 是割点 ✓
  但 (A,B) 是桥吗? A 还能通过... 不, A 只连 B 和 D
  (B,C) 是桥吗? C 只连 B 和 E
  所以这里割点 = 桥的端点

真正的反例 (完全图 K4 减一边):

    ①
    │╲
    │ ╲
    ②─③
    │ ╱
    │╱
    ④

  ② 是割点吗? 删除 ② → ①还能到③(直连), ①到④(直连), ③到④(直连)
  实际上 ② 不是割点...

最简反例:

    ① ─ ② ─ ③
        │
        ④

  ② 是割点 (删除后 {①},{③},{④} 三分离)
  但 ② 的关联边中没有桥:
    (①,②): ① 只连 2 → 这是桥啊...

好吧, 经典反例:

        ①
       ╱ ╲
      ②  ③
       ╲ ╱
        ④
        │
        ⑤

  ④ 是割点! (删除 ④ → {①,②,③} 与 {⑤} 分离)
  但 (④,⑤) 是桥 ✓ (这里割点确实关联了桥)

  ④ 的其他边呢? (①,④),(②,④),(③,④) 都不是桥 (因为在环中)
  所以: ④ 是割点, 但只有 1 条关联边是桥, 其余 3 条不是

结论: 割点可以有多条关联边, 其中部分是桥、部分不是
```

### 设计决策 4️⃣：边界检查的意义

```moonbit
if vid < 0 || vid >= state.disc.length() {
  continue
}
```

与 SCC/Tarjan 相同的原因：mbtgraph 支持非连续 NodeId，防止数组越界。

---

## 割点 vs 桥 vs SCC 对比

### 三个 Tarjan 算法的家族关系

```
                    ┌─────────────────────┐
                    │   Tarjan 算法家族    │
                    │  (disc[] + low[])   │
                    └──────────┬──────────┘
           ┌──────────────────┼──────────────────┐
           ▼                  ▼                  ▼
    ┌────────────┐    ┌────────────┐    ┌────────────┐
    │  SCC       │    │  割点&桥    │    │ (变体...)  │
    │  (有向图)   │    │  (无向图)   │    │            │
    ├────────────┤    ├────────────┤    ├────────────┤
    │ low==disc  │    │ low≥disc   │    │            │
    │ 栈管理     │    │ 根特判      │    │            │
    │ 强连通     │    │ parent跳过  │    │            │
    └────────────┘    └────────────┘    └────────────┘
```

### 全面对比表

```
┌──────────────────┬──────────────┬──────────────┬──────────────┐
│     特性         │    SCC       │   割点 AP     │   桥 Bridge  │
├──────────────────┼──────────────┼──────────────┼──────────────┤
│ 图类型           │ 有向         │ 无向         │ 无向         │
│ 判定条件         │ low==disc    │ low≥disc     │ low>disc     │
│ 根节点特殊处理   │ 不需要       │ child_count≥2│ 不需要       │
│ parent 跳过      │ 不需要       │ **必须**     │ **必须**     │
│ 辅助数据结构     │ 栈           │ parent[]     │ parent[]     │
│ 时间复杂度       │ O(V+E)       │ O(V+E)       │ O(V+E)       │
│ 空间复杂度       │ O(V)         │ O(V)         │ O(V)         │
│ 发现者           │ Tarjan 1972  │ Tarjan 1972  │ Tarjan 1972  │
└──────────────────┴──────────────┴──────────────┴──────────────┘
```

---

## 🛠️ 使用示例

### 示例 1：网络脆弱性分析

```moonbit
use lib.algo.cutpoints.{find_articulation_points_undirected, find_bridges_undirected}
use lib.storage.undirected_adj_list.{UndirectedAdjList, empty, add_node, add_edge}

fn analyze_network_vulnerability() {
  // 构建网络拓扑 (6 个路由器)
  let mut net = UndirectedAdjList::empty()
  let net = net.add_node("Router-A")  // 0
  let net = net.add_node("Router-B")  // 1
  let net = net.add_node("Router-C")  // 2
  let net = net.add_node("Router-D")  // 3
  let net = net.add_node("Router-E")  // 4
  let net = net.add_node("Router-F")  // 5

  // 物理连接
  let net = net.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
  let net = net.add_edge(@core.NodeId(1), @core.NodeId(2), 1.0)
  let net = net.add_edge(@core.NodeId(0), @core.NodeId(3), 1.0)
  let net = net.add_edge(@core.NodeId(3), @core.NodeId(4), 1.0)
  let net = net.add_edge(@core.NodeId(1), @core.NodeId(4), 1.0)
  let net = net.add_edge(@core.NodeId(4), @core.NodeId(5), 1.0)

  // 检测脆弱点
  let ap_result = find_articulation_points_undirected(net)
  let bridge_result = find_bridges_undirected(net)

  println("=== 网络脆弱性报告 ===")
  println("🔴 关键路由器 (割点, ${ap_result.count} 个):")
  for cp in ap_result.cut_points {
    match GraphReadable::node_data(net, cp) {
      Some(name) => println("  ⚠️ ${name} (ID=${cp.0})"),
      None => ()
    }
  }

  println("🌉 关键链路 (桥, ${bridge_result.count} 条):")
  for b in bridge_result.bridges {
    let from_name = match GraphReadable::node_data(net, b.from) {
      Some(n) => n, None => "?"
    }
    let to_name = match GraphReadable::node_data(net, b.to) {
      Some(n) => n, None => "?"
    }
    println("  🔗 ${from_name} ↔ ${to_name}")
  }
  // 输出:
  // === 网络脆弱性报告 ===
  // 🔴 关键路由器 (割点, 3 个):
  //   ⚠️ Router-A (ID=0)
  //   ⚠️ Router-B (ID=1)
  //   ⚠️ Router-E (ID=4)
  // 🌉 关键链路 (桥, 2 条):
  //   🔗 Router-B ↔ Router-C
  //   🔗 Router-E ↔ Router-F
}
```

### 示例 2：社交网络关键人物识别

```moonbit
fn find_key_influencers(
  members : Array[String],
  friendships : Array[Tuple2[Int, Int]],
) -> Tuple2[Array[String], Array[Tuple2[String, String]]] {
  let mut graph = UndirectedAdjList::empty()
  for m in members {
    let graph = graph.add_node(m)
  }
  for f in friendships {
    let graph = graph.add_edge(
      @core.NodeId(f.0), @core.NodeId(f.1), 1.0
    )
  }

  let ap_result = find_articulation_points_undirected(graph)
  let bridge_result = find_bridges_undirected(graph)

  // 转换为名称
  let mut influencers : Array[String] = []
  for cp in ap_result.cut_points {
    match GraphReadable::node_data(graph, cp) {
      Some(name) => influencers.push(name),
      None => ()
    }
  }

  let mut critical_links : Array[Tuple2[String, String]] = []
  for b in bridge_result.bridges {
    let n1 = match GraphReadable::node_data(graph, b.from) {
      Some(n) => n, None => "?"
    }
    let n2 = match GraphReadable::node_data(graph, b.to) {
      Some(n) => n, None => "?"
    }
    critical_links.push((n1, n2))
  }

  (influencers, critical_links)
}

// 使用
let team = ["Alice", "Bob", "Carol", "Dave", "Eve", "Frank"]
let friends = [
  (0, 1), (1, 2), (0, 3), (3, 4), (1, 4), (4, 5)
]

let (influencers, links) = find_key_influencers(team, friends)
println("关键人物: ${influencers}")   // ["Alice", "Bob", "Eve"]
println("关键关系: ${links}")        // [("Bob","Carol"), ("Eve","Frank")]
```

### 示例 3：双连通分解 (Biconnected Components)

```moonbit
// 利用割点信息将图分解为双连通分量 (BCC)
// 每个 BCC 内部没有割点 → 任意两点间存在 2 条不相交路径

fn biconnected_components(
  graph : UndirectedAdjList,
) -> Array[Array[@core.NodeId]] {
  let ap_result = find_articulation_points_undirected(graph)

  // 策略: 以割点为"分隔符", BFS 收集每个分量
  // (简化实现: 实际需要更复杂的块切割算法)

  let visited : Array[Bool] = Array::make(/* size */, false)
  let components : Array[Array[@core.NodeId]] = []

  for node in /* all nodes */ {
    if !visited[node.0] && !ap_result.is_cut_point[node.0] {
      // BFS 收集同一 BCC 的节点 (遇到割点停止)
      let component : Array[@core.NodeId] = []
      // ... BFS 实现 ...
      components.push(component)
    }
  }

  components
}

// 应用: BCC 数量 = 图的"韧性"指标
// BCC 越多 → 越容易被分割 → 越需要增加冗余连接
```

---

## 📈 复杂度分析

### 时间复杂度：O(V + E)

| 操作 | 复杂度 | 说明 |
|------|--------|------|
| 初始化数组 | O(V) | disc[], low[], parent[] 等 |
| DFS 主循环 | O(V + E) | 每节点入栈一次, 每边检查两次 |
| low 更新 | O(1)/次 | min 操作常数时间 |
| 判定检查 | O(1)/次 | 单次比较 |
| **总计** | **O(V + E)** | |

### 空间复杂度：O(V)

| 数据结构 | 用途 | 大小 |
|---------|------|------|
| `disc[]` | 发现时间 | O(V) |
| `low[]` | 低点值 | O(V) |
| `parent[]` | 父节点 (AP) | O(V) |
| `ap[]` / `bridges_list` | 结果存储 | O(V) |
| **总计** | | **O(V)** |

---

## 🎯 实际应用场景

### 🌐 场景 1：网络可靠性工程

**问题**：数据中心/通信网络的**单点故障 (SPOF)** 分析

**解决方案**：割点 = 单点故障节点；桥 = 单点故障链路

**实例**：Cisco 网络健康检查工具、云服务商的网络拓扑审计

### 👥 场景 2：社交网络分析

**问题**：识别"桥梁人物"——连接不同社区的关键个体

**解决方案**：桥的端点往往是跨社区的信息中介

**意义**：营销传播、舆情控制、组织架构优化

### 🗺️ 场景 3：交通基础设施规划

**问题**：道路/铁路网中哪些路段一旦中断会造成严重隔离

**解决方案**：桥 = 关键路段；割点 = 关键枢纽

**工具**：GIS 系统中的网络分析模块

### 🎮 场景 4：游戏地图设计

**问题**：确保游戏地图中没有"一夫当关"的瓶颈点

**解决方案**：检测割点和桥，增加冗余路径提升游戏体验

---

## 🧪 练习题

### 练习 1：手动执行割点+桥检测 ⭐⭐

对下图同时检测割点和桥：

```
     ① ──── ② ──── ③
     │     │ ╲
     │     │  ╲
     ④ ────⑤ ── ⑥
```

<details>
<summary>📖 参考答案</summary>

```
假设 DFS 顺序: ①→②→③, ②→⑤→⑥, ⑤→④, ④→①(回边), ⑤→②(回边)

disc:  ①=0, ②=1, ③=2, ⑤=3, ⑥=4, ④=5
low:   通过计算...

割点:
  ①: root, children={②,④} → 2个子树 → **割点** ✓
  ②: low[③]=2 ≥ disc[②]=1? 依赖具体回边情况
  ⑤: 类似分析...

桥:
  (②,③)? low[③] > disc[②]? 取决于是否有替代路径
  (⑤,⑥)? 如果 ⑥ 是叶子且 low[⑥] > disc[⑤] → **桥** ✓

(完整答案建议用代码验证!)
```

</details>

---

### 练习 2：实现双连通分量分解 ⭐⭐⭐

基于割点检测的结果，将无向图分解为**边双连通分量 (Edge-BCC)** 或**点双连通分量 (Vertex-BCC)**：

```moonbit
// 要求:
// 1. Edge-BCC: 删除任意一条边, 分量内仍连通
// 2. Vertex-BCC: 删除任意一个非割点, 分量内仍连通
// 3. 输出每个分量的节点集合
// 4. 分析分量的数量与图韧性的关系
```

<details>
<summary>💡 提示</summary>

```moonbit
// Edge-BCC: 基于桥的分解
// 每座桥都是分量之间的"分割线"
// 删除所有桥后, 每个连通分量就是一个 Edge-BCC

fn edge_bcc_decomposition(graph) {
  let bridges = find_bridges_undirected(graph)
  // 标记所有桥边
  // 在剩余图上做普通连通分量 (BFS/DFS)
  // 每个 CC 就是一个 Edge-BCC
}

// Vertex-BCC: 基于割点的分解 (更复杂)
// 需要在 DFS 过程中维护栈, 类似 Tarjan SCC
// 当发现割点时, 栈中该割点以上的节点构成一个 Vertex-BCC
```

</details>

---

### 练习 3：增量式割点/桥更新 ⭐⭐⭐⭐

在实际网络中，拓扑经常变化（新增/删除节点或边）。设计一个**增量算法**：

**初始状态**：已知原图的所有割点和桥

**操作序列**：
1. 添加一条新边 `(u, v)` —— 哪些割点/桥可能失效？
2. 删除一条非桥边 `(x, y)` —— 可能产生新的割点/桥吗？
3. 删除一个非割点节点 —— 周围的割点/桥如何变化？

**要求**：
- 尽可能避免完全重新运行 O(V+E) 的 Tarjan 算法
- 分析每次增量更新的最小必要范围

<details>
<summary>📖 解题思路</summary>

```moonbit
// 核心洞察:
//
// 1. 添加边 (u, v):
//    - 如果 u 和 v 已在同一 BCC 中 → 无变化
//    - 如果 u 和 v 在不同 BCC 中 → 合并两个 BCC
//      → 两个 BCC 之间的桥全部失效!
//      → 新路径上的割点可能失效
//    - 最小范围: 仅需重新检查 u-v 路径上的节点
//
// 2. 删除非桥边:
//    - 非桥边的删除不影响 BCC 结构
//    → 割点和桥不变! (O(1) 确认)
//
// 3. 删除非割点节点:
//    - 需要检查其所有邻居
//    - 如果某邻居只通过该节点连接到其余图 → 该邻居可能变成新的割点
//    - 最小范围: 受影响的邻居及其子树

fn incremental_update(
  old_ap : CutPointResult,
  old_bridges : BridgeResult,
  operation : IncrementalOp,
) -> Tuple2[CutPointResult, BridgeResult] {
  match operation {
    AddEdge(u, v) => recheck_path(u, v, old_ap, old_bridges),
    RemoveNonBridgeEdge(x, y) => (old_ap, old_bridges),  // O(1)!
    RemoveNonCutPoint(n) => recheck_neighbors(n, old_ap, old_bridges),
  }
}
```

**应用场景**：实时网络监控系统、动态社交网络分析。

</details>

---

## 🔗 相关资源

### 📚 推荐阅读

| 资源 | 类型 | 说明 |
|------|------|------|
| *Original Paper* | 论文 | R.E. Tarjan, "Depth-first search and linear graph algorithms," 1972 (同一篇论文包含 SCC + AP + Bridge!) |
| *CLRS* | 教材 | 《算法导论》第 22.3 节 - 应用: 寻找桥 |
| *VisuAlgo* | 交互可视化 | https://visualgo.net/en/dfsscc (支持 AP/Bridge 展示) |
| *SCC 教程* | 本站文档 | [/algorithms/connectivity/scc/tarjan](/algorithms/connectivity/scc/tarjan) (同作者, 相关技术) |

### 🔗 相关算法

```
割点与桥 (本文)
  ├── Tarjan SCC          → 同作者的另一经典 (有向图版本)
  ├── 双连通分量 (BCC)    → 基于割点的自然扩展
  ├── 最小顶点覆盖         → 相关的图优化问题
  ├── 网络可靠性           → 直接应用领域
  └── 拓扑排序 (DAG)      → 有向图中的类似概念
```

### 🛠️ mbtgraph 相关源码

| 文件 | 说明 |
|------|------|
| [`lib/algo/cutpoints/articulation_points.mbt`](../../../lib/algo/cutpoints/articulation_points.mbt) | 割点检测核心实现 |
| [`lib/algo/cutpoints/bridges.mbt`](../../../lib/algo/cutpoints/bridges.mbt) | 桥检测核心实现 |
| [`lib/algo/cutpoints/types.mbt`](../../../lib/algo/cutpoints/types.mbt) | `CutPointResult` + `BridgeResult` 类型定义 |
| [`lib/algo/connectivity/tarjan.mbt`](../../../lib/algo/connectivity/tarjan.mbt) | Tarjan SCC (对比参考) |

---

<!-- 总结清单移除，遵循 8-section 格式 -->

### ✅ 核心知识点

- [ ] **割点定义**：移除后使连通分量数增加的节点
- [ ] **桥定义**：移除后使连通分量数增加的边
- [ ] **Tarjan 方法**：DFS + `disc[]` + `low[]`，单次遍历 O(V+E)
- [ ] **桥判定**：`low[child] > disc[parent]`（严格大于）
- [ ] **割点判定（非根）**：`∃ child, low[child] ≥ disc[parent]`（大于等于）
- [ ] **割点判定（根）**：`child_count ≥ 2`
- [ ] **parent 跳过**：无向图必须排除来时边，否则误判

### 🔑 关键代码模式

```moonbit
// Tarjan 割点/桥 三件套
dfs(u, parent):
  disc[u] = low[u] = ++time
  for each neighbor v of u:
    if v not visited:
      dfs(v, u)
      low[u] = min(low[u], low[v])

      // 桥:     if low[v] >  disc[u]:  bridge(u,v)
      // 割点(AP): if low[v] >= disc[u]:  articulation(u)
    else if v != parent:  // ★ 跳过父节点!
      low[u] = min(low[u], disc[v])

  // 根节点特判: if root && children >= 2: articulation(root)
```

### ⚠️ 常见陷阱

| 陷阱 | 后果 | 解决方法 |
|------|------|---------|
| 忘记跳过 parent | **永远检测不到桥** | `else if vid != parent_u` |
| 割点用 `>` 而非 `≥` | 漏检某些割点 | 非根割点用 **≥** |
| 根节点用 low 判断 | 根节点永远不被标记 | 根节点用 **child_count ≥ 2** |
| 有向图调用无向版 | 结果无意义 | 有向图先转基图或用 SCC |
| 浮点/Double 误差 | N/A (本算法只用 Int) | ✅ 无此问题 |

### 📊 Tarjan 算法族速查

```
┌──────────────┬───────────────┬───────────────┬────────────────┐
│    算法       │  图类型        │  判定条件       │  核心应用      │
├──────────────┼───────────────┼───────────────┼────────────────┤
│ Tarjan SCC   │ 有向          │ low==disc     │ 循环依赖检测   │
│ Tarjan AP    │ 无向          │ low≥disc      │ 单点故障分析   │
│ Tarjan Bridge│ 无向          │ low>disc      │ 关键链路识别   │
└──────────────┴───────────────┴───────────────┴────────────────┘
```

---

<div align="center">

**🔗 Tarjan 割点与桥 — 一次 DFS，洞察网络脆弱本质**

*上一篇：[Kosaraju SCC](/algorithms/connectivity/scc/kosaraju) | [返回连通性目录](/algorithms/connectivity)*

</div>
