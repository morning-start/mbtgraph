---
title: 深度优先搜索 (DFS)
description: 图的纵深遍历算法详解：原理、栈可视化动画、时间戳分析、MoonBit 实现、拓扑排序应用
---

# 深度优先搜索 (DFS)

> 🎯 **本节目标**: 掌握 DFS 算法原理、显式栈实现、时间戳含义及实际应用
>
> ⏱️ **预计阅读时间**: 30 分钟 | 🎮 **互动演示**: 3 个可运行示例 + 栈状态追踪

## 📖 算法简介

**深度优先搜索（Depth-First Search, DFS）** 是一种用于**深入探索图/树数据结构**的算法。

### 核心思想 💡

想象你在**走一个复杂的迷宫**：

```
🏰 迷宫探索类比:

  入口 ●───────────────┐
       │ ╲             │
       │  ╲            │
       │   ●───●       │  ← 选择一条路，一直走到死胡同！
       │   │           │
       │   ●───●───🚪出口
       │       │
       └───────┘

策略:
1. 🚶 从入口出发，**选择一条路径一直走到底**
2. 🔄 到达死胡同 → **回溯**到上一个分岔口
3. 🔀 尝试另一条未走过的路径
4. ✅ 直到所有可能的路径都探索完毕
```

DFS 就像这位探险家，**沿着一条路径尽可能深入，遇到无路可走时才回溯**，然后尝试其他分支。

### 为什么叫"深度优先"?

对比两种遍历策略：

| 策略 | 类比 | 访问顺序 | 数据结构 | 核心特征 |
|------|------|---------|----------|----------|
| **BFS** 广度优先 | 涟漪扩散 | **横向逐层** | 📦 队列 Queue | 先访问"近处"节点 |
| **DFS** 深度优先 | 走迷宫 | **纵向深入** | 📚 栈 Stack | 先访问"远处"节点 |

### DFS 的两大"超能力"

与 BFS 相比，DFS 拥有两个独特的能力：

```
🔥 能力 1: 时间戳系统 (entry_time / exit_time)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

每个节点被记录两个时刻:
  entry_time[u] = 第几次"进入"节点 u
  exit_time[u]  = 第几次"离开"节点 u

用途:
  ✅ 拓扑排序 → 按 exit_time 降序排列
  ✅ 环检测   → 存在回边 (back edge) 则有环
  ✅ 强连通分量 → Tarjan/Kosaraju 算法基础


🔥 能力 2: 回溯路径记录 (parents + order)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

parents[] 记录 DFS 树的父子关系:
  - 构成 DFS Forest (可能多棵树，针对不连通图)
  - 可用于路径重建

order[] 记录节点的"完成顺序" (post-order):
  - 退出时才加入 order
  - 这是拓扑排序的关键!
```

---

## 🎬 交互式动画：DFS 分步执行过程

让我们通过一个具体例子来理解 DFS 的执行流程。**点击 ▶ 播放按钮或使用方向键控制动画！**

### 示例图: 无向简单图

考虑以下无向图（6 节点，7 条边）：

<div class="viz-preview-card">
  <iframe src="/visualizations/dfs/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/dfs/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

---

让我们通过一个具体例子来理解 DFS 的执行流程，特别关注**栈的变化**和**时间戳的更新**。

### 示例图: 有向无环图 (DAG)

考虑以下有向图（非常适合展示 DFS 的时间戳特性）：

```
     0 ──→ 1 ──→ 3
     ↓     ↘     ↓
     4      2 ──→ 5
```

**边列表**: `(0,1), (0,4), (1,2), (1,3), (2,5), (3,5)`

> 💡 **这是一个 DAG（有向无环图）**，DFS 的时间戳将直接给出拓扑排序！

### 从节点 0 开始的 DFS 执行过程

> 🎮 **点击每个步骤查看栈状态变化**（模拟 VisuAlgo 动画）

#### 初始化阶段

```
Step 0: 初始化
┌─────────────────────────────────────────────────────┐
│ Stack: [0]                                         │  ← 将起点压栈
│ Visited: {0} ✓                                     │  ← 标记已访问
│ entry[0] = 0                                       │  ← 时间戳 = 0 (首次进入!)
│ Time: 1                                            │
│ Parents[0] = None                                  │  ← 起点无父节点
│                                                     │
│ 当前状态: 准备探索节点 0 的邻居                      │
└─────────────────────────────────────────────────────┘

图示 (●=在栈中, ○=未访问, ✓=已完成):
  [0]●───→○1
   │↓
   ○4
```

#### 第一次深入 (0 → 1)

```
Step 1: 探索节点 0 的第一个邻居 → 节点 1
┌─────────────────────────────────────────────────────┐
│ Stack: [0, 1]                                      │  ← 1 压栈 (深入!)
│ Visited: {0, 1} ✓                                  │
│ entry[1] = 1                                       │  ← 时间戳 = 1
│ Time: 2                                            │
│ Parents[1] = 0                                     │  ← 1 的父节点是 0
│                                                     │
│ ⭐ 关键: 还没有处理完 0，先去处理 1!                 │
│    这就是"深度优先"的含义                            │
└─────────────────────────────────────────────────────┘

图示:
  [0]●───→①1  ← 新发现! 正在处理中...
   │↓
   ○4
```

#### 继续深入 (1 → 2)

```
Step 2: 探索节点 1 的第一个邻居 → 节点 2
┌─────────────────────────────────────────────────────┐
│ Stack: [0, 1, 2]                                   │  ← 继续深入!
│ Visited: {0, 1, 2} ✓                               │
│ entry[2] = 2                                       │  ← 时间戳 = 2
│ Time: 3                                            │
│ Parents[2] = 1                                     │
│                                                     │
│ 当前路径: 0 → 1 → 2 (深度=3)                       │
└─────────────────────────────────────────────────────┘

图示:
  [0]●───→①●───→②2  ← 一路深入到底!
   │↓        ↘
   ○4         ○5
```

#### 到达叶节点 (2 → 5)

```
Step 3: 探索节点 2 的唯一邻居 → 节点 5
┌─────────────────────────────────────────────────────┐
│ Stack: [0, 1, 2, 5]                                │  ← 到达最深处!
│ Visited: {0, 1, 2, 5} ✓                            │
│ entry[5] = 3                                       │  ← 时间戳 = 3
│ Time: 4                                            │
│ Parents[5] = 2                                     │
│                                                     │
│ ⚠️ 节点 5 没有出边!                                 │
│    即将触发第一次"回溯"...                          │
└─────────────────────────────────────────────────────┘

图示 (到达最深处):
  [0]●───→①●───→②●───→⑤5  ← 死胡同!
   │↓        ↘
   ○4
```

#### 🔄 第一次回溯 (5 完成)

```
Step 4: 节点 5 无未访问邻居 → 弹栈 (回溯!)
┌─────────────────────────────────────────────────────┐
│ Pop: 5                                              │  ← 5 弹栈
│ exit[5] = 4                                        │  ← ⭐ 退出时间戳 = 4
│ Order: [5]                                         │  ← 5 加入完成列表
│ Time: 5                                            │
│ Stack: [0, 1, 2]                                   │  ← 回到上一层
│                                                     │
│ 💡 "回溯"意味着:                                    │
│    节点 5 的所有后代都已处理完毕                      │
└─────────────────────────────────────────────────────┘

图示:
  [0]●───→①●───→②●          ⑤✓ 已完成!
   │↓        ↘
   ○4
```

#### 第二次回溯 (2 完成)

```
Step 5: 节点 2 也无其他邻居 → 再次弹栈
┌─────────────────────────────────────────────────────┐
│ Pop: 2                                              │
│ exit[2] = 5                                        │  ← 退出时间戳 = 5
│ Order: [5, 2]                                      │  ← 2 加入完成列表
│ Time: 6                                            │
│ Stack: [0, 1]                                      │  ← 回到节点 1
│                                                     │
│ 📍 现在回到分岔口!                                   │
│    节点 1 还有另一个邻居 3 未探索                    │
└─────────────────────────────────────────────────────┘
```

#### 新分支探索 (1 → 3)

```
Step 6: 回到节点 1，探索下一个邻居 → 节点 3
┌─────────────────────────────────────────────────────┐
│ Stack: [0, 1, 3]                                   │  ← 新分支!
│ Visited: {..., 3} ✓                                │
│ entry[3] = 6                                       │  ← 时间戳 = 6
│ Time: 7                                            │
│ Parents[3] = 1                                     │
│                                                     │
│ 🔀 典型的"回溯后换方向"行为                         │
└─────────────────────────────────────────────────────┘

图示:
  [0]●───→①●───→③3  ← 新分支!
   │↓        ╲     ↓
   ○4         ✓2   ○5(✓)
                  ↘
                   ✓5
```

#### 继续深入 (3 → 5，但 5 已访问!)

```
Step 7: 探索节点 3 的邻居 → 节点 5 (已访问!)
┌─────────────────────────────────────────────────────┐
│ Neighbors of 3: {5 ✓}                              │
│ → 5 已经 visited，跳过!                             │
│                                                     │
│ ⚠️ 重要: 这里形成了一个"交叉边"(cross edge)         │
│    但不是"回边"(back edge)，所以图仍然无环!         │
│                                                     │
│ 节点 3 无其他邻居 → 准备弹栈                        │
└─────────────────────────────────────────────────────┘
```

#### 第三次回溯 (3 完成)

```
Step 8: 节点 3 完成 → 弹栈
┌─────────────────────────────────────────────────────┐
│ Pop: 3                                              │
│ exit[3] = 7                                        │  ← 退出时间戳 = 7
│ Order: [5, 2, 3]                                   │
│ Time: 8                                            │
│ Stack: [0, 1]                                      │
│                                                     │
│ 节点 1 的邻居全部探索完毕                           │
└─────────────────────────────────────────────────────┘
```

#### 第四次回溯 (1 完成)

```
Step 9: 节点 1 完成 → 弹栈
┌─────────────────────────────────────────────────────┐
│ Pop: 1                                              │
│ exit[1] = 8                                        │  ← 退出时间戳 = 8
│ Order: [5, 2, 3, 1]                                │
│ Time: 9                                            │
│ Stack: [0]                                         │  ← 回到起点 0
│                                                     │
│ 📍 节点 0 还有邻居 4 未探索!                        │
└─────────────────────────────────────────────────────┘
```

#### 最后一个分支 (0 → 4)

```
Step 10: 回到起点 0，探索最后一个邻居 → 节点 4
┌─────────────────────────────────────────────────────┐
│ Stack: [0, 4]                                      │  ← 最后一个分支
│ Visited: {..., 4} ✓                                │
│ entry[4] = 9                                       │  ← 时间戳 = 9
│ Time: 10                                           │
│ Parents[4] = 0                                     │
│                                                     │
│ 节点 4 是孤立节点 (无出边)                          │
└─────────────────────────────────────────────────────┘
```

#### 最终回溯 (4 和 0 完成)

```
Step 11-12: 节点 4 和 0 依次完成
┌─────────────────────────────────────────────────────┐
│ Step 11: Pop 4  → exit[4]=10, Order=[5,2,3,1,4]   │
│ Step 12: Pop 0  → exit[0]=11, Order=[5,2,3,1,4,0] │
│ Stack: []                                         │  ← 栈空! DFS 结束!
│ Time: 12                                           │
└─────────────────────────────────────────────────────┘
```

### 最终结果汇总

```
✅ DFS 完成!

═══════════════════════════════════════════════
📊 完整结果数据
═══════════════════════════════════════════════

访问顺序 (Order):     [5, 2, 3, 1, 4, 0]
                     ↑ 后序遍历 (post-order)

父节点 (Parents):
  P[1]=0, P[2]=1, P[5]=2, P[3]=1, P[4]=0

⏰ 时间戳表 (重要!):
  ┌──────┬────────────┬───────────┐
  │ 节点 │ entry_time │ exit_time │
  ├──────┼────────────┼───────────┤
  │  0   │     0      │    11     │  ← 最晚完成 (根节点)
  │  1   │     1      │     8     │
  │  2   │     2      │     5     │
  │  3   │     6      │     7     │
  │  4   │     9      │    10     │
  │  5   │     3      │     4     │  ← 最早完成 (叶子)
  └──────┴────────────┴───────────┘


🎯 关键发现: 拓扑排序!
━━━━━━━━━━━━━━━━━━━━━━━━━━

将节点按 exit_time **降序排列**:
  exit_time: 11 > 10 > 8 > 7 > 5 > 4
  节点顺序: [0, 4, 1, 3, 2, 5]

验证: 对于每条边 u→v，都有 exit[u] > exit[v]
  ✅ 0→1: exit[0]=11 > exit[1]=8  ✓
  ✅ 0→4: exit[0]=11 > exit[4]=10 ✓
  ✅ 1→2: exit[1]=8  > exit[2]=5  ✓
  ✅ 1→3: exit[1]=8  > exit[3]=7  ✓
  ✅ 2→5: exit[2]=5  > exit[5]=4  ✓
  ✅ 3→5: exit[3]=7  > exit[5]=4  ✓

结论: [0, 4, 1, 3, 2, 5] 是一个合法的拓扑排序!


🌲 DFS 树结构:
━━━━━━━━━━━━━━━━━━━━━━━━━━

      0 (root)
     / \
    1   4
   / \
  2   3
  |
  5

边分类:
  ✅ 树边 (Tree Edge):     0→1, 0→4, 1→2, 1→3, 2→5
  ➡️ 交叉边 (Cross Edge):  3→5  (连接不同子树)
  ❌ 回边 (Back Edge):     无! (所以是无环图)
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/traversal/dfs.mbt`）

```moonbit
///|
/// 单源 DFS：从 start 节点开始遍历（迭代式，显式栈）
///
/// 时间复杂度: O(V + E)
/// 空间复杂度: O(V)
///
/// 返回 DfsResult 包含:
///   - base.visited/order/parents (基础遍历信息)
///   - entry_time[] (进入时间戳，用于拓扑排序/SCC)
///   - exit_time[]  (退出时间戳，用于拓扑排序/SCC)
pub fn[G : @core.GraphReadable] dfs(
  graph : G,
  start : @core.NodeId
) -> DfsResult {
  let nc = @core.GraphReadable::node_count(graph)

  // 边界检查：空图或无效起点
  if nc == 0 || !@core.GraphReadable::contains_node(graph, start) {
    return empty_dfs_result()
  }

  // 初始化数据结构
  let max_id = dfs_find_max_id(graph)  // 找最大 NodeId 用于数组大小
  let size = max(max_id + 1, 1)

  let visited = Array::make(size, false)              // 访问标记
  let order : Array[@core.NodeId] = []                // 完成顺序 (post-order)
  let parents : Array[@core.NodeId?] = Array::make(size, None)  // 父节点
  let entry = Array::make(size, -1)                   // 进入时间戳
  let exit = Array::make(size, -1)                    // 退出时间戳
  let mut time = 0                                    // 全局时钟

  // 初始化栈（注意: 不是递归调用栈，而是显式数组模拟的栈）
  let stack : Array[@core.NodeId] = [start]
  visited[start.0] = true
  entry[start.0] = time   // 记录入口时间
  time = time + 1
  let mut stack_len = 1   // 栈长度（避免 pop() 的开销）

  // 主循环：当栈不为空时继续
  while stack_len > 0 {
    let cur = stack[stack_len - 1]  // 查看栈顶元素（不弹出!）

    // 在当前节点的邻居中寻找第一个未访问的节点
    let mut found = false
    for nid in @core.GraphReadable::neighbors(graph, cur) {
      let idx = nid.0

      // 边界检查 + 是否已访问
      if idx >= 0 && idx < size && !visited[idx] {
        visited[idx] = true               // 标记为已访问
        parents[idx] = Some(cur)          // 记录父节点
        entry[idx] = time                 // 记录进入时间戳 ⭐
        time = time + 1
        stack.push(nid)                   // 压栈（深入!）
        stack_len = stack_len + 1
        found = true
        break                             // ⚠️ 只找一个邻居就停止!
      }
    }

    // 如果当前节点没有未访问的邻居 → 回溯（弹栈）
    if !found {
      order.push(cur)                     // 加入完成顺序 (post-order)
      exit[cur.0] = time                 // 记录退出时间戳 ⭐⭐
      time = time + 1
      stack_len = stack_len - 1           // 弹栈（回溯!）
    }
  }

  // 返回完整结果（包含时间戳信息）
  DfsResult::{
    base: TraversalResult::{ visited, order, parents },
    entry_time: entry,
    exit_time: exit,
  }
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么使用"显式栈"而非递归？

```moonbit
// ❌ 递归方式（概念上直观，但有问题）:
fn dfs_recursive(u : NodeId) {
  for v in neighbors(u) {
    if (!visited[v]) {
      dfs_recursive(v)  // 递归调用
    }
  }
  order.push(u)  // 后序位置
}
// 问题:
//   - MoonBit 对递归深度有限制（可能导致栈溢出）
//   - 无法精确控制时间戳
//   - 调试困难

// ✅ 迭代式显式栈（mbtgraph 采用的方式）:
while stack_len > 0 {
  let cur = stack[stack_len - 1]  // 查看栈顶（peek）
  // ... 寻找未访问邻居 ...
  if found {
    stack.push(neighbor)  // 压栈 = 递归调用
  } else {
    stack.pop()           // 弹栈 = 递归返回
  }
}
// 优势:
//   - ✅ 无递归深度限制（支持超大图）
//   - ✅ 可以精确控制 entry/exit 时间戳
//   - ✅ 更容易调试和可视化
```

#### 2️⃣ 为什么用 `stack[stack_len - 1]` peek 而非 pop？

```moonbit
// ⚠️ 关键区别:

// 方式 A: 先 pop 再处理（错误! 会丢失当前节点信息）
while stack not empty:
  cur = stack.pop()        // ❌ 当前节点已经不在栈中了!
  for neighbor in neighbors(cur):
    if not visited:
      stack.push(neighbor)
  // 问题: 无法知道何时记录 exit_time!

// 方式 B: peek 后按需 pop（正确! mbtgraph 的方式）
while stack_len > 0:
  cur = stack[stack_len - 1]  // ✅ 查看但不移除
  found_unvisited_neighbor = false
  for neighbor in neighbors(cur):
    if not visited:
      stack.push(neighbor)   // 深入
      found = true
      break
  if not found:
    // 所有邻居都处理完了 → 真正离开该节点
    record_exit_time(cur)    // ✅ 此时才能记录退出时间!
    stack_len -= 1           // 真正弹栈
```

**核心思想**: 一个节点只有在**所有后代都处理完毕后**才会被弹出，这时才能安全地记录 `exit_time`。

#### 3️⃣ 时间戳系统的设计哲学

```moonbit
/// DFS 的时间戳是整个算法的"灵魂"
///
/// 直观理解:
///   time 就像一个全局计数器，每次"事件"发生时 +1
///   - "进入节点" 事件 → 记录到 entry_time[]
///   - "离开节点" 事件 → 记录到 exit_time[]
///
/// 性质（非常重要！）:
///
/// 1. 区间嵌套性质:
///    如果 u 是 v 的祖先，则:
///      entry[u] < entry[v] < exit[v] < exit[u]
///    （类似括号匹配: ( ... (v) ... ) ）
///
/// 2. 拓扑排序:
///    对于 DAG，按 exit_time 降序排列即为拓扑序
///    原因: 父节点一定比子节点更晚"完成"
///
/// 3. 环检测:
///    如果存在边 u→v 且 entry[u] > entry[v]（即 v 是 u 的祖先），
///    则这条边是"回边"(back edge)，说明图中存在环!

let mut time = 0  // 全局时钟，从 0 开始

// 进入节点时:
entry[node] = time
time += 1

// 离开节点时:
exit[node] = time
time += 1
```

#### 4️⃣ 结果类型的设计

```moonbit
/// DFS 返回结果包含 5 种信息:
pub(all) struct DfsResult {
  base : TraversalResult {  // 基础遍历信息（与 BFS 共享）
    visited : Array[Bool],        // 节点是否被访问
    order   : Array[NodeId],      // 完成顺序 (post-order) ⭐
    parents : Array[NodeId?],     // 父节点（用于重建路径）
  },
  entry_time : Array[Int],        // 进入时间戳 ⭐⭐ (DFS 独有)
  exit_time  : Array[Int],        // 退出时间戳 ⭐⭐ (DFS 独有)
}

/// BFS vs DFS 结果对比:
///
/// BfsResult 额外字段: levels[]     (层级距离)
/// DfsResult 额外字段: entry_time[], exit_time[] (时间戳)
///
/// 设计原因:
///   - BFS 关注"距离" → 层级信息最重要
///   - DFS 关注"顺序" → 时间戳信息最重要
///   - 两者都保留 parents 用于路径重建
```

**为什么返回这么多信息？**

| 字段 | 用途 | 示例方法 |
|------|------|----------|
| `visited` | 可达性查询 | `result.is_visited(target)` |
| `order` | **拓扑排序** | `result.base.order.reverse()` 即为拓扑序! |
| `parents` | 路径重建 | `result.base.path_to(target)` |
| `entry_time` | **SCC/Tarjan** | 判断节点间的祖孙关系 |
| `exit_time` | **拓扑排序/环检测** | 按 exit_time 降序 = 拓扑序 |

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 输出时间戳和 DFS 树

```moonbit
fn dfs_basic_demo() -> Unit {
  // 构建 DAG（与动画演示相同）
  let g = build_sample_dag()

  // 执行 DFS
  let result = @traversal.dfs(g, @core.NodeId(0))

  // 输出结果
  println("=== DFS 遍历结果 ===")
  println("访问顺序 (post-order): ${result.base.order}")
  println("可达节点数: ${result.base.reachable_count()}")

  // 输出每个节点的时间戳
  println("\n⏰ 时间戳详情:")
  for (i, is_visited) in result.base.visited.indexed() {
    if (is_visited) {
      let node_id = @core.NodeId(i)
      let entry_t = result.entry_time[i]
      let exit_t = result.exit_time[i]

      // 格式化输出
      let parent_str = match result.base.parents[i] {
        Some(p) => "NodeId(" + p.to_string() + ")",
        None => "None (root)"
      }

      println("  Node ${i}: entry=${entry_t}, exit=${exit_t}, parent=${parent_str}")
    }
  }

  // 从 post-order 得到拓扑排序
  let topo_order = result.base.order.reverse()
  println("\n🎯 拓扑排序 (按 exit_time 降序):")
  println("  ${topo_order}")
}

// 输出:
// === DFS 遍历结果 ===
// 访问顺序 (post-order): [NodeId(5), NodeId(2), NodeId(3), NodeId(1), NodeId(4), NodeId(0)]
// 可达节点数: 6
//
// ⏰ 时间戳详情:
//   Node 0: entry=0, exit=11, parent=None (root)
//   Node 1: entry=1, exit=8, parent=NodeId(0)
//   Node 2: entry=2, exit=5, parent=NodeId(1)
//   Node 3: entry=6, exit=7, parent=NodeId(1)
//   Node 4: entry=9, exit=10, parent=NodeId(0)
//   Node 5: entry=3, exit=4, parent=NodeId(2)
//
// 🎯 拓扑排序 (按 exit_time 降序):
//   [NodeId(0), NodeId(4), NodeId(1), NodeId(3), NodeId(2), NodeId(5)]
```

### 示例 2: 🔍 环检测 - 判断有向图是否包含环路

```moonbit
/// 使用 DFS 的时间戳检测有向图中的环
///
/// 原理: 如果存在"回边"(back edge)，即从节点指向其祖先的边，
///       则说明图中存在环。
fn detect_cycle_in_dag(
  graph : DirectedAdjList
) -> Result[Unit, String] {
  // 执行 DFS（假设图是连通的，否则需要 dfs_all）
  let result = @traversal.dfs_all(graph)

  // 检查每条边是否是"回边"
  for u_id in @core.GraphReadable::node_ids(graph) {
    for v_id in @core.GraphReadable::neighbors(graph, u_id) {
      let u_idx = u_id.0
      let v_idx = v_id.0

      // 回边判定条件:
      //   v 是 u 的祖先 ↔ entry[v] < entry[u] AND exit[v] > exit[u]（尚未完成）
      //   或者更简单: v 在当前递归栈上（即 entry[v] 已记录但 exit[v] 尚未记录）
      //
      // 注意: 这里我们简化判断，只检查 entry/exit 的嵌套关系
      if (result.entry_time[v_idx] != -1 &&
          result.exit_time[v_idx] != -1 &&
          result.entry_time[v_idx] < result.entry_time[u_idx] &&
          result.exit_time[v_idx] > result.exit_time[u_idx]) {

        return Error("检测到环! 存在回边: " +
                     u_id.to_string() + " → " + v_id.to_string())
      }
    }
  }

  Ok(())
}

// 使用示例
fn cycle_detection_demo() -> Unit {
  // 构建 DAG (无环)
  let dag = build_valid_dag()
  match detect_cycle_in_dag(dag) {
    Ok(_) => println("✅ 图是 DAG (无环) — 可以进行拓扑排序"),
    Err(msg) => println("❌ ${msg}")
  }

  // 构建有环图
  let cyclic_graph = build_cyclic_graph()
  match detect_cycle_in_dag(cyclic_graph) {
    Ok(_) => println("✅ 图是 DAG"),
    Err(msg) => println("❌ ${msg}")
    // 输出: ❌ 检测到环! 存在回边: NodeId(2) → NodeId(0)
  }
}

/// 构建一个简单的有环图用于测试
fn build_cyclic_graph() -> DirectedAdjList {
  let mut g = DirectedAdjList::new_with_capacity(3, 3)

  let n0 = @core.GraphWritable::add_node(g, "A")
  let n1 = @core.GraphWritable::add_node(g, "B")
  let n2 = @core.GraphWritable::add_node(g, "C")

  // 形成环: 0 → 1 → 2 → 0
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n0, 1.0) |> ignore  // ← 回边!

  g
}
```

### 示例 3: 🗺️ 迷宫求解 - 使用 DFS 寻找路径

```moonbit
/// 使用 DFS 解决迷宫问题（寻找任意一条从入口到出口的路径）
///
/// 迷宫表示为网格图:
///   - 每个格子是一个节点
///   - 相邻的可通行格子之间有边
///   - 障碍物不生成节点或边
fn solve_maze_using_dfs(
  maze_grid : Array[Array[Int]],  // 0=通路, 1=墙壁
  start_row : Int,
  start_col : Int,
  target_row : Int,
  target_col : Int
) -> Array[(Int, Int)] {
  let rows = maze_grid.length()
  let cols = maze_grid[0].length()

  // 将 2D 坐标转换为 1D NodeId
  fn coord_to_node(r : Int, c : Int) -> NodeId {
    NodeId(r * cols + c)
  }

  fn node_to_coord(id : NodeId) -> (Int, Int) {
    (id.0 / cols, id.0 % cols)
  }

  // 构建迷宫图（只包含通路格子）
  let mut maze_graph = UndirectedAdjList::new()

  // 添加所有通路节点
  for r in 0..rows {
    for c in 0..cols {
      if (maze_grid[r][c] == 0) {
        let node_id = coord_to_node(r, c)
        @core.GraphWritable::add_node(maze_graph, (r, c)) |> ignore
      }
    }
  }

  // 添加边（上下左右四个方向）
  let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]

  for r in 0..rows {
    for c in 0..cols {
      if (maze_grid[r][c] == 0) {
        let current = coord_to_node(r, c)

        for (dr, dc) in directions {
          let nr = r + dr
          let nc = c + dc

          // 检查边界和可行性
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols &&
              maze_grid[nr][nc] == 0) {
            let neighbor = coord_to_node(nr, nc)

            // 只添加向右和向下的边（避免重复添加无向边）
            if ((dr == 0 && dc == 1) || (dr == 1 && dc == 0)) {
              @core.GraphWritable::add_edge(maze_graph, current, neighbor, 1.0) |> ignore
            }
          }
        }
      }
    }
  }

  // 执行 DFS
  let start_node = coord_to_node(start_row, start_col)
  let target_node = coord_to_node(target_row, target_col)

  let result = @traversal.dfs(maze_graph, start_node)

  // 重建路径
  let path_nodes = result.base.path_to(target_node)

  // 转换回坐标
  path_nodes.map(fn(id) => { node_to_coord(id) })
}

// 使用示例
fn maze_demo() -> Unit {
  // 定义一个简单迷宫 (0=通路, 1=墙)
  // S = 起点 (0,0), E = 终点 (4,4)
  let maze = [
    [0, 0, 1, 0, 0],  // S . # . .
    [1, 0, 1, 0, 1],  // # . # . #
    [0, 0, 0, 0, 1],  // . . . . #
    [0, 1, 1, 0, 0],  // . # # . .
    [0, 0, 0, 0, 0],  // . . . . E
  ]

  println("=== 迷宫求解 (DFS) ===")
  let path = solve_maze_using_dfs(maze, 0, 0, 4, 4)

  match path.length() {
    0 => println("😢 无法找到从起点到终点的路径!")
    _ => {
      println("✅ 找到路径! 长度: ${path.length()} 步")
      println("\n路径坐标:")
      for (step, (r, c)) in path.indexed() {
        println("  ${step}. (${r}, ${c})")
      }

      // 可视化迷宫
      println("\n迷宫可视化 (#=墙, .=路, *=路径, S=起点, E=终点):")
      let mut visual_maze : Array[Array[String]] = []

      for r in 0..maze.length() {
        let row : Array[String] = []
        for c in 0..maze[0].length() {
          if (maze[r][c] == 1) {
            row.push("#")
          } else if (r == 0 && c == 0) {
            row.push("S")  // 起点
          } else if (r == 4 && c == 4) {
            row.push("E")  // 终点
          } else if (path.contains((r, c))) {
            row.push("*")  // 路径
          } else {
            row.push(".")  // 通路
          }
        }
        visual_maze.push(row)
      }

      for row in visual_maze {
        println("  ${row.join(" ")}")
      }
    }
  }
}

// 可能的输出:
// === 迷宫求解 (DFS) ===
// ✅ 找到路径! 长度: 8 步
//
// 路径坐标:
//   0. (0, 0)  S
//   1. (1, 0)  ↓
//   2. (2, 0)  ↓
//   3. (2, 1)  →
//   4. (2, 2)  →
//   5. (2, 3)  →
//   6. (3, 3)  ↓
//   7. (4, 3)  ↓
//   8. (4, 4)  → E
//
// 迷宫可视化:
//   S * # . .
//   * . # . #
//   * * * * #
//   . # # * .
//   . . . * E
```

---

## 📈 复杂度分析

### 时间复杂度: O(V + E)

| 操作 | 次数 | 复杂度 | 说明 |
|------|------|--------|------|
| 初始化数组 | 1 次 | O(V) | 创建 visited/parents/entry/exit |
| 压栈操作 | V 次 | O(1) 每次 | 每个节点恰好压栈一次 |
| 弹栈操作 | V 次 | O(1) 每次 | 每个节点恰好弹栈一次 |
| 邻居遍历 | 总共 2E 次* | O(E) 总计 | 每条边被检查一次（有向）/ 两次（无向） |
| **总计** | | **O(V + E)** | |

> \* 无向图中每条边会在两端的邻居迭代器中各出现一次。

### 空间复杂度: O(V)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `visited[]` | O(V) | 布尔标记数组 |
| `parents[]` | O(V) | 父节点指针 |
| `entry[]` | O(V) | 进入时间戳 |
| `exit[]` | O(V) | 退出时间戳 |
| `stack` | O(V) | 最坏情况: 单链图的所有节点同时在栈上 |
| `order` | O(V) | 完成顺序列表 |
| **总计** | **O(V)** | |

### 与 BFS 对比

| 维度 | BFS | DFS |
|------|-----|-----|
| **数据结构** | 队列 (FIFO) | 栈 (LIFO) |
| **时间复杂度** | O(V+E) | O(V+E) |
| **空间复杂度** | O(V) | O(V) (最坏情况) |
| **核心产出** | 层级 (levels[]) | 时间戳 (entry/exit[]) |
| **最短路径** | ✅ 保证（无权图） | ❌ 不保证 |
| **拓扑排序** | ❌ 不适用 | ✅ 直接得到 (reverse order) |
| **环检测** | 间接（需要额外逻辑） | ✅ 通过回边判断 |
| **内存占用** | 通常较小（层级均匀扩展） | 可能较大（单链深入） |
| **适用场景** | 最短路径、层级遍历 | 拓扑排序、环检测、路径查找 |

### 与其他算法对比

| 算法 | 时间 | 空间 | 特色能力 |
|------|------|------|----------|
| **DFS** | O(V+E) | O(V) | **时间戳**、拓扑排序、环检测 |
| **BFS** | O(V+E) | O(V) | **层级**、无权最短路径 |
| **Dijkstra** | O((V+E)logV) | O(V) | **非负权重**最短路径 |
| **Bellman-Ford** | O(VE) | O(V) | 含**负权边**的最短路径 |
| **Tarjan SCC** | O(V+E) | O(V) | 基于 DFS 的**强连通分量** |
| **Kosaraju** | O(V+E) | O(V) | 基于 DFS 的**强连通分量**（两次 DFS） |

---

## 🎯 实际应用场景

### 应用 1: 📚 拓扑排序 - 课程依赖规划

```
问题: 大学课程有先修要求，如何安排学习顺序?

示例课程依赖关系:
  数据结构 (DS)  → 算法 (Algo) → 高级算法 (AdvAlgo)
       ↓              ↓
  离散数学 (Discrete)  操作系统 (OS)

边 A → B 表示 "A 是 B 的先修课"

解决方案: DFS + 按退出时间降序排列

执行过程:
  1. 对依赖图执行 DFS
  2. 记录每个课程的 exit_time
  3. 按 exit_time 降序排列 → 即为合法的学习顺序

结果:
  TopoOrder: [离散数学, 数据结构, OS, 算法, 高级算法]

验证: 每门课的先修课都在它前面出现 ✅
```

### 应用 2: 🔗 环检测 - 编译器/构建系统

```
问题: 检查模块/文件之间的依赖是否存在循环依赖

场景 1: Makefile / 构建系统
  main.o 依赖  utils.o
  utils.o 依赖  config.o
  config.o 依赖  utils.o  ← ⚠️ 循环依赖!

场景 2: 编译器的 import 检测
  module_a imports module_b
  module_b imports module_c
  module_c imports module_a  ← ⚠️ 循环导入!

DFS 检测方法:
  1. 对依赖图执行 DFS
  2. 遇到指向"仍在递栈中"的节点的边 → 回边 → 有环
  3. 报告错误并指出循环路径

优势:
  ✅ O(V+E) 线性时间，适合大型项目
  ✅ 可以精确定位哪些文件形成了环
```

### 应用 3: 🗺️ 迷宫求解 / 路径搜索

```
问题: 在迷宫/游戏中寻找从起点到终点的任意路径

DFS 特性在此场景的优势:
  ✅ 实现简单（只需栈，不需要优先队列）
  ✅ 内存占用可控（不像 BFS 需要存储整层节点）
  ✅ 可以快速找到"一条"路径（不一定是最短的）

vs BFS:
  - DFS: 找到的路径通常较长（不是最短路径）
  - BFS: 保证找到最短路径，但内存消耗更大

典型应用:
  - 游戏AI: NPC寻路（允许非最优路径）
  - 自动化测试: 状态空间探索
  - 电路板布线: 寻找可行路径
```

### 应用 4: 🌐 网页爬虫 - 深度优先抓取

```
问题: 从种子 URL 开始，沿着链接深度优先抓取网页

DFS 抓取策略:
  1. 从种子页面开始
  2. 点击第一个链接，进入新页面
  3. 继续点击该页面的第一个链接...
  4. 到达死胡同（无新链接或达到深度限制）→ 回溯
  5. 尝试上一个页面的下一个链接

应用实例:
  - Google 早期的网页爬虫（部分采用 DFS 策略）
  - 站点地图生成器（深度优先便于生成层次化结构）

注意事项:
  ⚠️ 需要设置最大深度限制（防止无限递归）
  ⚠️ 需要 visited 集合（防止重复抓取同一页面）
  ⚠️ 需要 robots.txt 检查（遵守爬虫协议）
```

---

## 🧪 练习题

### 练习 1: 手动执行 DFS ⭐⭐

对于以下有向图，从节点 A 开始执行 DFS（迭代式），写出：

1. 栈的变化过程（每步的栈内容）
2. 每个节点的 entry_time 和 exit_time
3. 最终的 order（post-order）序列
4. 是否存在环？如果存在，指出回边

```
  A → B → D
  ↓   ↘   ↓
  C → E → F
```

<details>
<summary>📝 点击查看答案</summary>

```
假设邻居顺序: 字母顺序 (A: [B,C], B: [D,E], C: [E], D: [F], E: [F])

Step  Stack        Action              Time  Entry  Exit  Order
───── ──────────── ──────────────────   ────  ─────  ────  ──────
 0    [A]          push A, entry[A]=0    1     0      -     -
 1    [A,B]        push B, entry[B]=1    2     1      -     -
 2    [A,B,D]      push D, entry[D]=2    3     2      -     -
 3    [A,B,D,F]    push F, entry[F]=3    4     3      -     -
 4    [A,B,D]      pop F,  exit[F]=4     5     -      4     [F]
 5    [A,B]        pop D,  exit[D]=5     6     -      5     [F,D]
 6    [A,B,E]      push E, entry[E]=6    7     6      -     [F,D]
 7    [A,B,E,F]    F已访问, skip         -     -      -     [F,D]
 8    [A,B]        pop E,  exit[E]=8     9     -      8     [F,D,E]
 9    [A]          pop B,  exit[B]=9    10     -      9     [F,D,E,B]
10    [A,C]        push C, entry[C]=10   11    10      -     [F,D,E,B]
11    [A,C,E]      push E, E已访问      -     -      -     [F,D,E,B]
12    [A]          pop C,  exit[C]=12   13     -     12     [F,D,E,B,C]
13    []           pop A,  exit[A]=13   14     -     13     [F,D,E,B,C,A]


最终结果:
  entry_time:  A=0, B=1, D=2, F=3, E=6, C=10
  exit_time:   F=4, D=5, E=8, B=9, C=12, A=13
  order:       [F, D, E, B, C, A]

环检测结果:
  检查边 E→F: entry[E]=6 > entry[F]=3, exit[E]=8 > exit[F]=4
  → 这是交叉边 (cross edge)，不是回边 ✅
  结论: 该图无环 (DAG)
```

</details>

### 练习 2: 编程实现 - 拓扑排序 ⭐⭐⭐

基于 DFS 的 `DfsResult`，实现一个函数，返回图的拓扑排序序列。如果图中有环，返回错误。

```moonbit
/// 提示:
/// 1. 使用 dfs_all() 遍历全图
/// 2. 将 order 反转即为拓扑序
/// 3. 可选: 添加环检测逻辑
```

<details>
<summary>💻 点击查看解答代码</summary>

```moonbit
/// 使用 DFS 实现拓扑排序
///
/// 参数:
///   graph - 有向图（假设为 DAG 或需要检测环）
///
/// 返回:
///   Ok(topo_order) - 成功时的拓扑排序序列
///   Err(message)   - 检测到环时的错误信息
pub fn[G : @core.GraphReadable] topological_sort_dfs(
  graph : G
) -> Result[Array[@core.NodeId], String] {
  // 执行全图 DFS
  let result = dfs_all(graph)

  // 方法 1: 简单版本（假设输入是 DAG）
  // 直接反转 post-order 即可得到拓扑排序
  let topo_order = result.base.order.reverse()

  // 方法 2: 完整版本（带环检测）
  // 检查是否存在回边 (back edge)
  for u_id in @core.GraphReadable::node_ids(graph) {
    for v_id in @core.GraphReadable::neighbors(graph, u_id) {
      let u_idx = u_id.0
      let v_idx = v_id.0

      // 回边判断: v 是 u 的祖先且 v 尚未完成
      if (result.entry_time[v_idx] < result.entry_time[u_idx] &&
          result.exit_time[v_idx] > result.exit_time[u_idx]) {
        return Error("检测到环: " +
                     u_id.to_string() + " → " + v_id.to_string())
      }
    }
  }

  Ok(topo_order)
}

/// 使用示例
fn topo_sort_demo() -> Unit {
  // 构建课程依赖图
  let course_deps = build_course_dependency_graph()

  match topological_sort_dfs(course_deps) {
    Ok(order) => {
      println("✅ 拓扑排序成功! 学习顺序:")
      for (rank, course_id) in order.indexed() {
        let course_name = get_course_name(course_id)
        println("  ${rank + 1}. ${course_name}")
      }
    }
    Err(msg) => {
      println("❌ ${msg}")
      println("提示: 请检查课程依赖关系中是否存在循环依赖")
    }
  }
}

// 可能的输出:
// ✅ 拓扑排序成功! 学习顺序:
//   1. 离散数学
//   2. 数据结构
//   3. 操作系统
//   4. 算法
//   5. 高级算法
```

</details>

### 练习 3: 进阶 - 双色图检测（DFS 变体）⭐⭐⭐

**挑战**: 使用 DFS 判断一个无向图是否是**二部图（Bipartite Graph）**（也称双色图）。

**原理**:
- 二部图可以用两种颜色着色，使得相邻节点颜色不同
- 类似于"棋盘染色"问题
- 应用: 任务调度、冲突检测

**提示**:
- 在 DFS 过程中为每个节点分配颜色（0 或 1）
- 如果发现相邻节点颜色相同 → 不是二部图
- 需要处理不连通的情况（多个起始点）

<details>
<summary>🔧 参考实现框架</summary>

```moonbit
/// 使用 DFS 检测二部图
///
/// 原理: 尝试用两种颜色对图进行着色，
///       如果相邻节点必须同色则失败
pub fn[G : @core.GraphReadable] is_bipartite_dfs(
  graph : G
) -> Bool {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 { return true }

  let max_id = dfs_find_max_id(graph)
  let size = max(max_id + 1, 1)

  // 颜色数组: -1=未染色, 0/1=两种颜色
  let color = Array::make(size, -1)
  let visited = Array::make(size, false)

  // 处理所有连通分量
  for start in @core.GraphReadable::node_ids(graph) {
    if visited[start.0] { continue }

    // 从该分量开始 DFS，初始颜色为 0
    color[start.0] = 0
    visited[start.0] = true

    let stack : Array[@core.NodeId] = [start]
    let mut stack_len = 1

    while stack_len > 0 {
      let cur = stack[stack_len - 1]
      let mut found = false

      for nbr in @core.GraphReadable::neighbors(graph, cur) {
        let idx = nbr.0

        if idx >= 0 && idx < size {
          if !visited[idx] {
            // 未访问 → 染成相反颜色
            visited[idx] = true
            color[idx] = 1 - color[cur.0]  // ⭐ 核心: 取反!
            stack.push(nbr)
            stack_len = stack_len + 1
            found = true
            break
          } else if color[idx] == color[cur.0] {
            // 已访问且颜色相同 → 冲突!
            return false  // ❌ 不是二部图
          }
          // else: 颜色不同，继续检查其他邻居
        }
      }

      if !found {
        stack_len = stack_len - 1
      }
    }
  }

  true  // ✅ 成功二着色，是二部图
}

/// 使用示例
fn bipartite_demo() -> Unit {
  // 示例 1: 完全二部图 K_{2,3}
  let k23 = build_complete_bipartite_graph(2, 3)
  println("K_{{2,3}} 是二部图? ${is_bipartite_dfs(k23)}")
  // 输出: K_{2,3} 是二部图? true

  // 示例 2: 含奇环的图（三角形）
  let triangle = build_triangle_graph()
  println("三角形是二部图? ${is_bipartite_dfs(triangle)}")
  // 输出: 三角形是二部图? false (因为奇环无法二着色)
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/dfsbfs | 🏆 业界标杆，新加坡国立大学开发，DFS/BFS 对比模式 |
| Algorithm Visualizer | https://algorithm-visualizer.org/graphs/dfs.html | 清晰的递归栈可视化 |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/DFS.html | 学术风格，支持递归展示 |

### 理论延伸阅读

- **广度优先搜索**: [BFS 教程](/algorithms/traversal/bfs/index/)（对比学习）
- **拓扑排序**: [拓扑排序算法](/algorithms/traversal/topo-sort/)（基于 DFS 的时间戳）
- **强连通分量**: [Tarjan 算法](/algorithms/connectivity/tarjan-scc/)（基于 DFS 的 SCC 检测）
- **Kosaraju 算法**: [Kosaraju SCC](/algorithms/connectivity/kosaraju-scc/)（两次 DFS 的经典应用）
- **最短路径**: [Dijkstra 教程](/algorithms/shortest-path/dijkstra/)（另一种重要的图算法）

### 经典教材推荐

| 书名 | 作者 | 推荐章节 |
|------|------|----------|
| *Introduction to Algorithms (CLRS)* | Cormen et al. | Ch.22 Elementary Graph Algorithms |
| *Algorithms* | Sedgewick & Wayne | Ch.4 Graphs |
| 算法导论（中文版） | 殷建平等译 | 第22章 基本的图算法 |

### mbtgraph API 参考

```moonbit
// 核心函数
@traversal.dfs(graph, start)    // 单源 DFS → DfsResult (含时间戳!)
@traversal.dfs_all(graph)       // 全图 DFS → DfsResult (遍历所有连通分量)

// 结果查询
result.base.is_visited(id)               // Bool
result.base.path_to(target)             // Array[NodeId]
result.base.reachable_count()           // Int
result.entry_time[node_idx]             // Int (进入时间戳)
result.exit_time[node_idx]              // Int (退出时间戳)

// 高级用法
result.base.order.reverse()             // Array[NodeId] → 拓扑排序!
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** DFS 的核心思想（迷宫探索类比）
- [ ] **手动执行** 小规模图的 DFS 过程（写出栈变化/entry/exit/order）
- [ ] **理解** 时间戳系统的含义（区间嵌套性质、拓扑排序依据）
- [ ] **实现** MoonBit 版本的 DFS（理解显式栈、peek vs pop、break 机制）
- [ ] **区分** DFS vs BFS 的适用场景（拓扑排序 vs 最短路径）
- [ ] **应用** DFS 到实际问题（环检测/拓扑排序/迷宫求解/二部图检测）
- [ ] **分析** DFS 的时间/空间复杂度（O(V+E) / O(V)）
- [ ] **推导** DFS 树的边分类（树边/回边/前向边/交叉边）

> 💡 **下一步**: 尝试实现练习题中的**拓扑排序**或**二部图检测**，或者直接进入 [Dijkstra 最短路径](/algorithms/shortest-path/dijkstra/) 学习带权图的最优路径算法！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 DFS:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_graph()
  let result = @traversal.dfs(g, @core.NodeId(0))
  println("Post-order: ${result.base.order}")

  // 快速获取拓扑排序
  let topo = result.base.order.reverse()
  println("拓扑排序: ${topo}")
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看 DFS 动画：<a href="https://visualgo.net/en/dfsbfs" target="_blank">https://visualgo.net/en/dfsbfs</a></p>
    <p>💡 <strong>重点观察</strong>: 栈的 LIFO 行为 vs BFS 队列的 FIFO 行为，以及时间戳是如何随着"进入"和"离开"节点而更新的。</p>
  </div>
</div>
