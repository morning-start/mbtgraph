---
title: "欧拉路径与回路算法"
description: "从哥尼斯堡七桥到 Hierholzer 算法：无向图欧拉路径/回路判定与查找的完整指南，含动画演示、MoonBit 实现与邮递员路线等实际应用"
---

# 欧拉路径与回路算法

> 🎯 **本节目标**: 掌握欧拉路径/回路的判定条件、Hierholzer 查找算法及其实际应用
>
> ⏱️ **预计阅读时间**: 40 分钟 | 🎮 **互动演示**: 判定过程动画 + Hierholzer 栈操作追踪

## 📖 算法简介

**欧拉路径与回路**是图论中最经典的问题之一，起源于 **1736 年欧拉对哥尼斯堡七桥问题的研究**——这也被认为是**图论诞生的标志**。

### 核心思想 💡

想象你是**一名尽职的邮递员**：

```
📮 邮递员路线类比:

  🏠 ────── 🏫 ────── 🏥
   │ ╲       │        │
   │  ╲      │        │
   │   ╲     │        │
   │    ╲    │        │
  🏪     🏢 ────── 🏨

邮递员的工作:
1. 📬 从邮局出发，需要经过每条街道恰好一次
2. ✉️ 把邮件投递到每个街区
3. 🏁 最终回到邮局（回路）或停在某个地点（路径）

关键规则:
  ⛔ 每条街道只能走一次（不能重复！）
  ✅ 但可以多次经过同一个路口（交叉点）
  ❓ 能否找到这样的路线？这就是欧拉问题！
```

欧拉路径/回路的核心就是回答：**能否不重复地遍历图中的所有边？**

### 为什么叫"欧拉"?

| 信息 | 详情 |
|------|------|
| **发明者** | Leonhard Euler（瑞士数学家） |
| **发表时间** | 1736 年 |
| **论文标题** | "Solutio problematis ad geometriam situs pertinentis"（关于位置几何问题的解法） |
| **历史意义** | **图论的第一篇论文**，开创了拓扑学和图论两个领域 |
| **原始问题** | 哥尼斯堡七桥问题（Königsberg Bridge Problem） |

### 欧拉路径 vs 欧拉回路

| 特性 | **欧拉路径 (Eulerian Path)** | **欧拉回路 (Eulerian Circuit)** |
|------|------------------------------|---------------------------------|
| **定义** | 访问每条边**恰好一次**的路径 | 访问每条边**恰好一次**并**回到起点**的闭合路径 |
| **起点/终点** | 可以不同（奇度节点） | 必须相同 |
| **存在条件** | 连通 + 0 或 2 个奇度节点 | 连通 + 所有节点偶数度 |
| **特例关系** | 回路是路径的特例（0 个奇度节点时） | — |
| **类比** | 一笔画（起点≠终点） | 一笔画（起点=终点） |

### 核心概念：度数 (Degree) 与奇偶性

```
🔑 度数是理解欧拉问题的关键！

定义:
  节点的度数 = 与该节点相连的边数

  对于无向图:
    degree(v) = v 的邻居数量

奇偶性分类:
  ├── 偶度节点 (Even Degree): degree(v) 是偶数 (0, 2, 4, 6, ...)
  └── 奇度节点 (Odd Degree):  degree(v) 是奇数  (1, 3, 5, 7, ...)

重要定理 (握手定理 Handshaking Lemma):
  任何无向图中，奇度节点的个数一定是偶数！
  （因为所有度数之和 = 2 × 边数，必然是偶数）

示例图:

    A —— B —— C
    |         |
    D —— E —— F

  节点 A: degree=2 (连接 B, D) → 偶度 ✓
  节点 B: degree=2 (连接 A, C) → 偶度 ✓
  节点 C: degree=2 (连接 B, F) → 偶度 ✓
  节点 D: degree=2 (连接 A, E) → 偶度 ✓
  节点 E: degree=3 (连接 D, F, ?) → 奇度!
  节点 F: degree=2 (连接 C, E) → 偶度 ✓

  结果: 1 个奇度节点? ❌ 不可能! (违反握手定理)
  实际上应该检查是否有遗漏的边...
```

---

## 🎬 动画演示一：欧拉路径/回路判定过程

在运行 Hierholzer 算法之前，我们需要先**判断图中是否存在欧拉路径或回路**。这个过程包含两个步骤：**连通性检查**和**度数奇偶性统计**。

### 示例图: 经典"房子图"

让我们使用一个经典的例子——**房子图 (House Graph)** 来演示完整的判定过程：

```
        0
       / \
      /   \
     1 --- 2
     |\   /|
     | \ / |
     |  3  |
     | / \ |
     |/   \|
     4 --- 5

边列表 (7 条边):
  e0: 0 - 1
  e1: 0 - 2
  e2: 1 - 2
  e3: 1 - 3
  e4: 1 - 4
  e5: 2 - 3
  e6: 2 - 5
  e7: 3 - 4
  e8: 4 - 5
```

> 💡 这个图有 **6 个节点、9 条边**，结构对称，非常适合演示欧拉算法！

### 第一步：度数统计与奇偶性分析

```
Step 1: 统计每个节点的度数
┌──────────────────────────────────────────────────────────┐
│                                                           │
│  遍历所有节点，计算 degree(v):                            │
│                                                           │
│  ┌────┬────────────────┬────────┬──────────┐             │
│  │ 节点│ 相邻边         │ 度数   │ 奇偶性   │             │
│  ├────┼────────────────┼────────┼──────────┤             │
│  │  0 │ [e0(0-1), e1(0-2)]  │   2    │ 偶数 ✓  │             │
│  │  1 │ [e0, e2, e3, e4]    │   4    │ 偶数 ✓  │             │
│  │  2 │ [e1, e2, e5, e6]    │   4    │ 偶数 ✓  │             │
│  │  3 │ [e3, e5, e7]        │   3    │ 奇数! ⚠️ │             │
│  │  4 │ [e4, e7, e8]        │   3    │ 奇数! ⚠️ │             │
│  │  5 │ [e6, e8]            │   2    │ 偶数 ✓  │             │
│  └────┴────────────────┴────────┴──────────┘             │
│                                                           │
│  统计结果:                                                │
│    odd_count = 2                                          │
│    first_odd = NodeId(3)                                  │
│    second_odd = NodeId(4)                                 │
│                                                           │
│  📊 判定结论:                                              │
│    ✅ 奇度节点数为 2 → 可能存在欧拉路径!                   │
│    ❌ 奇度节点数 ≠ 0 → 不存在欧拉回路                      │
│                                                           │
│  🔑 如果存在欧拉路径:                                      │
│    起点 = first_odd = 节点 3                              │
│    终点 = second_odd = 节点 4                             │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

### 第二步：BFS 连通性检查

```
Step 2: 检查图的连通性（忽略孤立节点）
┌──────────────────────────────────────────────────────────┐
│                                                           │
│  目标: 从第一个非孤立节点出发，用 BFS 检查是否            │
│        能到达所有非孤立节点                                │
│                                                           │
│  选择起始节点: NodeId(0) (degree=2 > 0)                  │
│                                                           │
│  BFS 执行过程:                                             │
│  ─────────────────────────────────────────                │
│                                                           │
│  初始化:                                                  │
│    queue = [NodeId(0)]                                    │
│    visited[0] = true                                      │
│    visited_non_isolated = 1                               │
│                                                           │
│  Step 2.1: 弹出 NodeId(0)                                 │
│    邻居: NodeId(1), NodeId(2)                             │
│    → 入队并标记 visited                                   │
│    queue = [NodeId(1), NodeId(2)]                         │
│    visited_non_isolated = 3                               │
│                                                           │
│  Step 2.2: 弹出 NodeId(1)                                 │
│    邻居: NodeId(0)✓, NodeId(2)✓, NodeId(3), NodeId(4)    │
│    → 新发现: NodeId(3), NodeId(4)                         │
│    queue = [NodeId(2), NodeId(3), NodeId(4)]             │
│    visited_non_isolated = 5                               │
│                                                           │
│  Step 2.3: 弹出 NodeId(2)                                 │
│    邻居: NodeId(0)✓, NodeId(1)✓, NodeId(3)✓, NodeId(5)   │
│    → 新发现: NodeId(5)                                    │
│    queue = [NodeId(3), NodeId(4), NodeId(5)]             │
│    visited_non_isolated = 6                               │
│                                                           │
│  Step 2.4-2.6: 弹出 NodeId(3), (4), (5)                  │
│    所有邻居都已 visited → 无新发现                        │
│    queue = []                                            │
│                                                           │
│  最终结果:                                                 │
│    visited_non_isolated = 6                               │
│    total_non_isolated = 6 (所有节点 degree > 0)           │
│    6 == 6? ✅ YES! 图是连通的!                           │
│                                                           │
│  📊 最终判定:                                              │
│    ✅ 图是连通的                                          │
│    ✅ 奇度节点数 = 2                                      │
│    ════════════════════════════                          │
│    🎯 结论: 存在欧拉路径! (但不存在欧拉回路)              │
│    📍 路径必须从节点 3 开始，到节点 4 结束                 │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

### 对比示例: 存在欧拉回路的图

为了对比，让我们看一个**存在欧拉回路**的图——**三角形加中心点**：

```
    1
   / \
  /   \
 0 --- 2
  \   /
   \ /
    3

边列表 (6 条边):
  e0: 0 - 1
  e1: 1 - 2
  e2: 2 - 0    ← 外圈三角形
  e3: 0 - 3
  e4: 1 - 3
  e5: 2 - 3    ← 到中心点的边

度数统计:
  节点 0: degree=3? 让我重新算...
  实际上: 0 连接 [1, 2, 3] → degree=3 (奇数)
  节点 1: 连接 [0, 2, 3] → degree=3 (奇数)
  节点 2: 连接 [0, 1, 3] → degree=3 (奇数)
  节点 3: 连接 [0, 1, 2] → degree=3 (奇数)

  ❌ 奇度节点数 = 4 ≠ 0, 2 → 既没有路径也没有回路!

正确的欧拉链示例 - 矩形图:

  0 --- 1
  |     |
  3 --- 2

边列表 (4 条边):
  e0: 0 - 1
  e1: 1 - 2
  e2: 2 - 3
  e3: 3 - 0

度数统计:
  节点 0: degree=2 (偶数)
  节点 1: degree=2 (偶数)
  节点 2: degree=2 (偶数)
  节点 3: degree=2 (偶数)

  ✅ 奇度节点数 = 0 → 存在欧拉回路!
  ✅ 也是欧拉路径的特例!

  一个可能的欧拉回路: 0 → 1 → 2 → 3 → 0
```

---

## 🎬 动画演示二：Hierholzer 算法执行过程

<div class="viz-preview-card">
  <iframe src="/visualizations/euler/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/euler/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

一旦确认存在欧拉路径/回路，我们使用 **Hierholzer 算法**来找出具体的路径。这是本教程的**核心内容**！

### Hierholzer 算法的核心直觉

```
💡 Hierholzer 算法的核心思想:

想象你在走迷宫:

1. 🚶 从起点出发，随意地沿着未走过的边前进
2. 🔒 当你走到"死胡同"（没有未访问的边）时，停下来
3. 📝 记录你走的这条"子路径"（称为 circuit）
4. 🔙 回溯到你还有未访问边的位置
5. 🔄 从那里开始新的探索，重复步骤 1-4
6. 🧩 最后把所有的"子路径"拼接起来就是完整的欧拉路径！

关键洞察:
  - 你一定会在起点结束（如果是欧拉回路）
  - 或者在一个奇度节点结束（如果是欧拉路径）
  - 拼接顺序很重要：后找到的子路径要插入到先找到的中间
```

### 示例图: 简化的三角形（用于清晰演示）

为了清晰地展示栈操作过程，我们使用一个更简单的图：

```
  0
  |\
  | \
  |  \
  1---2

边列表 (3 条边):
  e0: 0 - 1  (索引 0)
  e1: 0 - 2  (索引 1)
  e2: 1 - 2  (索引 2)

邻接表 (带边索引):
  adj[0] = [(1, 0), (2, 1)]
  adj[1] = [(0, 0), (2, 2)]
  adj[2] = [(0, 1), (1, 2)]

这是一个欧拉回路图 (所有节点 degree=2)!
起始节点: 0 (任意非孤立节点)
```

### Hierholzer 详细执行过程（显式栈模拟）

> 🎮 **注意观察**: 栈的 push/pop 操作和 `visited[]` 数组的变化

#### 初始化阶段

```
Step 0: 初始化数据结构
┌──────────────────────────────────────────────────────────┐
│                                                           │
│ 输入:                                                     │
│   adj = [[(1,0),(2,1)], [(0,0),(2,2)], [(0,1),(1,2)]]  │
│   edge_count = 3                                          │
│   start_node = 0                                          │
│                                                           │
│ 数据结构初始化:                                            │
│   visited[] = [false, false, false]  // 边访问标记        │
│   path[] = []                       // 结果路径（边索引）  │
│   stack = [(0, 0)]                  // 栈: (当前节点, 边位)│
│                                                           │
│ 栈元素说明:                                                │
│   (cur_node, edge_pos)                                    │
│   - cur_node: 当前所在的节点                               │
│   - edge_pos: 下一条要尝试的边在 adj[cur_node] 中的索引   │
│                                                           │
│ 初始状态:                                                 │
│   位于节点 0，准备尝试第 0 条邻接边                        │
│                                                           │
│ 图示:                                                     │
│     0 ●                                                    │
│    /|\                                                     │
│   / | \   stack: [(0,0)]                                  │
│  /  |  \  visited: [F, F, F]                              │
│ 1 ●-+-● 2  path: []                                       │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

#### 第 1 步：处理节点 0 的第 0 条边 (0→1)

```
Step 1: 处理栈顶 (0, 0)
┌──────────────────────────────────────────────────────────┐
│                                                           │
│ 栈顶: (cur_node=0, edge_pos=0)                           │
│                                                           │
│ 检查: edge_pos (0) < adj[0].length() (2)? ✅ YES          │
│                                                           │
│ 获取边: adj[0][0] = (next_node=1, edge_idx=0)            │
│                                                           │
│ 操作:                                                     │
│   1. 更新栈顶: (0, 0) → (0, 1)  // 下次尝试第 1 条边    │
│   2. 检查 visited[0]? false → 未访问!                    │
│   3. 标记 visited[0] = true                              │
│   4. Push (1, 0) 到栈顶  // 移动到节点 1                 │
│                                                           │
│ 栈状态变化:                                               │
│   Before: [(0, 0)]                                       │
│   After:  [(0, 1), (1, 0)]  ← 新栈顶!                   │
│                                                           │
│ visited[]: [true, false, false]  // e0 已访问            │
│                                                           │
│ 图示:                                                     │
│     0 ●━━━● 1  ← 刚走过 e0                              │
│    /       \   stack: [(0,1), (1,0)]                     │
│   /         \  visited: [T, F, F]                        │
│  /           \ path: []                                   │
│ ● 2                                                   │
│                                                           │
│ 💡 解释: 我们从节点 0 走到了节点 1，使用了边 e0           │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

#### 第 2 步：处理节点 1 的第 0 条边 (1→0)

```
Step 2: 处理栈顶 (1, 0)
┌──────────────────────────────────────────────────────────┐
│                                                           │
│ 栈顶: (cur_node=1, edge_pos=0)                           │
│                                                           │
│ 检查: edge_pos (0) < adj[1].length() (2)? ✅ YES          │
│                                                           │
│ 获取边: adj[1][0] = (next_node=0, edge_idx=0)            │
│                                                           │
│ 操作:                                                     │
│   1. 更新栈顶: (1, 0) → (1, 1)                          │
│   2. 检查 visited[0]? true → 已访问! 跳过!               │
│                                                           │
│ 栈状态: 无变化                                            │
│   Stack: [(0, 1), (1, 1)]                                │
│   visited: [true, false, false]                           │
│                                                           │
│ ⚠️ 关键: 边 e0 是无向边，虽然 1→0 和 0→1 都指向 e0，     │
│    但我们只标记一次！所以第二次遇到时跳过。                │
│                                                           │
│ 图示:                                                     │
│     0 ●━━━● 1  e0 已走，跳过 1→0                        │
│    /    ×    \   stack: [(0,1), (1,1)]                   │
│   /           \  visited: [T, F, F]                      │
│  /             \ path: []                                 │
│ ● 2                                                     │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

#### 第 3 步：处理节点 1 的第 1 条边 (1→2)

```
Step 3: 处理栈顶 (1, 1)
┌──────────────────────────────────────────────────────────┐
│                                                           │
│ 栈顶: (cur_node=1, edge_pos=1)                           │
│                                                           │
│ 检查: edge_pos (1) < adj[1].length() (2)? ✅ YES          │
│                                                           │
│ 获取边: adj[1][1] = (next_node=2, edge_idx=2)            │
│                                                           │
│ 操作:                                                     │
│   1. 更新栈顶: (1, 1) → (1, 2)                          │
│   2. 检查 visited[2]? false → 未访问!                    │
│   3. 标记 visited[2] = true                              │
│   4. Push (2, 0) 到栈顶  // 移动到节点 2                 │
│                                                           │
│ 栈状态:                                                   │
│   Before: [(0, 1), (1, 1)]                               │
│   After:  [(0, 1), (1, 2), (2, 0)]                       │
│                                                           │
│ visited: [true, false, true]  // e0, e2 已访问           │
│                                                           │
│ 图示:                                                     │
│     0 ●                                                   │
│    / \                                                    │
│   /   \   stack: [(0,1), (1,2), (2,0)]                  │
│  /     \  visited: [T, F, T]                             │
│ ● 1 ━━━ ● 2  ← 刚走过 e2                                │
│                                                           │
│ 当前路径: 0 → 1 → 2 (已使用 e0, e2)                     │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

#### 第 4 步：处理节点 2 的第 0 条边 (2→0)

```
Step 4: 处理栈顶 (2, 0)
┌──────────────────────────────────────────────────────────┐
│                                                           │
│ 栈顶: (cur_node=2, edge_pos=0)                           │
│                                                           │
│ 检查: edge_pos (0) < adj[2].length() (2)? ✅ YES          │
│                                                           │
│ 获取边: adj[2][0] = (next_node=0, edge_idx=1)            │
│                                                           │
│ 操作:                                                     │
│   1. 更新栈顶: (2, 0) → (2, 1)                          │
│   2. 检查 visited[1]? false → 未访问!                    │
│   3. 标记 visited[1] = true                              │
│   4. Push (0, 0) 到栈顶  // 回到节点 0!                  │
│                                                           │
│ 栈状态:                                                   │
│   Before: [(0, 1), (1, 2), (2, 0)]                       │
│   After:  [(0, 1), (1, 2), (2, 1), (0, 0)]              │
│                                                           │
│ visited: [true, true, true]  // 所有边都已访问!          │
│                                                           │
│ 图示:                                                     │
│     0 ● ←── 返回!                                        │
│    /|\                                                     │
│   / | \   stack: [(0,1), (1,2), (2,1), (0,0)]           │
│  /  |  \  visited: [T, T, T]  全部访问完毕!              │
│ ● 1 └── ● 2  当前路径: 0→1→2→0 (使用 e0,e2,e1)        │
│                                                           │
│ ⭐ 重要: 我们回到了起点 0，形成了一个环!                  │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

#### 第 5-7 步：回溯阶段（记录路径）

```
Step 5-7: 回溯并记录边
┌──────────────────────────────────────────────────────────┐
│                                                           │
│ Step 5: 处理栈顶 (0, 0)                                  │
│   检查: edge_pos (0) < adj[0].length() (2)? ✅ YES       │
│   获取边: adj[0][0] = (1, 0)                             │
│   更新栈顶: (0, 0) → (0, 1)                              │
│   visited[0] == true → 跳过!                              │
│                                                           │
│ Step 6: 处理栈顶 (0, 1)                                  │
│   检查: edge_pos (1) < adj[0].length() (2)? ✅ YES       │
│   获取边: adj[0][1] = (2, 1)                             │
│   更新栈顶: (0, 1) → (0, 2)                              │
│   visited[1] == true → 跳过!                              │
│                                                           │
│ Step 7: 处理栈顶 (0, 2)  ⭐ 回溯!                        │
│   检查: edge_pos (2) < adj[0].length() (2)? ❌ NO!       │
│   → 所有的边都试过了，弹出栈顶!                           │
│                                                           │
│   回溯操作:                                               │
│   1. 弹出 (0, 2)，stack 变为 [(0,1), (1,2), (2,1)]      │
│   2. 检查前一个栈顶 (2, 1):                               │
│      prev_edge_pos = 1 > 0? ✅ YES                        │
│   3. 记录边: adj[2][1-1] = adj[2][0] = (0, 1)            │
│   4. path.push(1)  // 记录边索引 e1!                     │
│                                                           │
│   类似地继续回溯...                                       │
│                                                           │
│ 最终 path (回溯过程中收集):                                │
│   path = [1, 2, 0]  // 注意: 这是反向的!                 │
│                                                           │
│ 反转后得到最终结果:                                        │
│   result = [0, 2, 1]                                     │
│                                                           │
│ 对应的边序列:                                             │
│   edges[0] = Edge{from:0, to:1}  (e0: 0→1)              │
│   edges[2] = Edge{from:1, to:2}  (e2: 1→2)              │
│   edges[1] = Edge{from:0, to:2}  (e1: 2→0 或 0→2)      │
│                                                           │
│ 🎯 最终欧拉回路:                                          │
│   0 → 1 → 2 → 0  ✅ 回到起点!                           │
│   使用了全部 3 条边，每条恰好一次!                        │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

### 最终结果汇总

```
✅ Hierholzer 算法完成!

═════════════════════════════════════════════════
📊 欧拉回路查找结果
═════════════════════════════════════════════════

  图结构: 三角形 (3 节点, 3 边)

  判定结果:
    ├─ 连通性: ✅ 通过 (BFS)
    ├─ 奇度节点: 0 个 (全是偶数度)
    └─ 结论: ✅ 存在欧拉回路!

  查找结果:
    exists: true
    start_node: Some(NodeId(0))
    circuit: [e0, e2, e1]

  回路可视化:

    0 ──e0──→ 1
    ↑         │
    │         e2
    │         ↓
    ←──e1─── 2

    完整路径: 0 → 1 → 2 → 0


📈 栈操作时间线:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  操作    栈状态                        action
  ────    ──────────────────────────    ─────────────
  Init    [(0,0)]                       初始化
  Push    [(0,1),(1,0)]                 走 e0: 0→1
  Skip    [(0,1),(1,1)]                 跳过 e0(反向)
  Push    [(0,1),(1,2),(2,0)]           走 e2: 1→2
  Push    [(0,1),(1,2),(2,1),(0,0)]     走 e1: 2→0
  Skip    [(0,1),(1,2),(2,1),(0,1)]     跳过 e0
  Skip    [(0,1),(1,2),(2,1),(0,2)]     跳过 e1
  Pop     [(0,1),(1,2),(2,1)]           回溯! path+=[1]
  Pop     [(0,1),(1,2)]                 回溯! path+=[2]
  Pop     [(0,1)]                       回溯! path+=[0]
  Pop     []                            栈空! 结束!


🔄 边访问顺序:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  时间线:  e0 ──→ e2 ──→ e1
  边状态:  [===]  [===]  [===]

  visited 数组演变:
    初始: [F, F, F]
    走e0: [T, F, F]
    走e2: [T, F, T]
    走e1: [T, T, T]  ← 全部访问!
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/euler/euler_undirected.mbt`）

```moonbit
///|
/// 检查节点的度数奇偶性
///
/// 遍历所有节点统计度数，返回 (奇度节点数, 第一个奇度节点, 第二个奇度节点)
fn[G : @core.GraphReadable] check_degree_parity(g : G) -> (Int, Int?, Int?) {
  let mut odd_count = 0
  let mut first_odd : Int? = None
  let mut second_odd : Int? = None
  for nid in @core.GraphReadable::node_ids(g) {
    let deg = @core.GraphReadable::degree(g, nid)
    if deg % 2 != 0 {
      odd_count = odd_count + 1
      match first_odd {
        None => first_odd = Some(nid.0)
        Some(_) =>
          match second_odd {
            None => second_odd = Some(nid.0)
            Some(_) => () |> ignore
          }
      }
    }
  }
  (odd_count, first_odd, second_odd)
}

///|
/// 检查无向图的连通性（忽略孤立节点）
///
/// 使用 BFS 从第一个非孤立节点开始遍历，
/// 检查所有非孤立节点是否可达
fn[G : @core.GraphReadable] is_connected_undirected(g : G) -> Bool {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return true
  }
  if nc == 1 {
    return true
  }
  let mut start : @core.NodeId? = None
  for nid in @core.GraphReadable::node_ids(g) {
    let deg = @core.GraphReadable::degree(g, nid)
    if deg > 0 {
      start = Some(nid)
      break
    }
  }
  match start {
    None => true
    Some(start_node) => {
      let max_id = find_max_node_id(g)
      let size = Int::max(max_id + 1, 1)
      let visited : Array[Bool] = Array::make(size, false)
      let queue : Array[@core.NodeId] = [start_node]
      visited[start_node.0] = true
      let mut visited_non_isolated = 1
      let mut head = 0
      while head < queue.length() {
        let cur = queue[head]
        head = head + 1
        for nbr in @core.GraphReadable::neighbors(g, cur) {
          if !visited[nbr.0] {
            visited[nbr.0] = true
            queue.push(nbr)
            let nbr_deg = @core.GraphReadable::degree(g, nbr)
            if nbr_deg > 0 {
              visited_non_isolated = visited_non_isolated + 1
            }
          }
        }
      }
      let mut total_non_isolated = 0
      for nid in @core.GraphReadable::node_ids(g) {
        let deg = @core.GraphReadable::degree(g, nid)
        if deg > 0 {
          total_non_isolated = total_non_isolated + 1
        }
      }
      visited_non_isolated == total_non_isolated
    }
  }
}

///|
/// 判定无向图是否存在欧拉路径
pub fn[G : @core.GraphReadable] has_euler_path_undirected(graph : G) -> Bool {
  if !is_connected_undirected(graph) {
    return false
  }
  let (odd_count, _, _) = check_degree_parity(graph)
  odd_count == 0 || odd_count == 2
}

///|
/// 判定无向图是否存在欧拉回路
pub fn[G : @core.GraphReadable] has_euler_circuit_undirected(graph : G) -> Bool {
  if !is_connected_undirected(graph) {
    return false
  }
  let (odd_count, _, _) = check_degree_parity(graph)
  odd_count == 0
}

///|
/// 从 Graph trait 构建内部邻接表（带边索引）
fn[G : @core.GraphReadable] build_adjacency_with_edges(
  g : G,
) -> (Array[Array[(Int, Int)]], Int, Array[@core.Edge]) {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return ([], 0, [])
  }
  let max_id = find_max_node_id(g)
  let size = Int::max(max_id + 1, 1)
  let adj : Array[Array[(Int, Int)]] = Array::make(size, [])
  let edges : Array[@core.Edge] = []
  let mut edge_index = 0
  for nid in @core.GraphReadable::node_ids(g) {
    for nbr in @core.GraphReadable::neighbors(g, nid) {
      if nbr.0 > nid.0 {
        let weight_opt = @core.GraphReadable::get_edge(g, nid, nbr)
        let weight = match weight_opt {
          Some(w) => w
          None => 0.0
        }
        let edge = @core.Edge::{ from: nid, to: nbr, data: weight }
        adj[nid.0].push((nbr.0, edge_index))
        adj[nbr.0].push((nid.0, edge_index))
        edges.push(edge)
        edge_index = edge_index + 1
      } else {
        ()
      }
    }
  }
  (adj, edge_index, edges)
}

///|
/// Hierholzer 核心算法实现（无向图）
///
/// 使用栈模拟递归避免栈溢出
/// 栈元素类型: (current_node, next_edge_index_to_try)
/// 返回边索引序列（需要反转）
fn hierholzer_undirected_full(
  adj : Array[Array[(Int, Int)]],
  edge_count : Int,
  start_node : Int,
) -> Array[Int] {
  if edge_count == 0 {
    return []
  }
  let visited : Array[Bool] = Array::make(edge_count, false)
  let mut stack : Array[(Int, Int)] = [(start_node, 0)]
  let path : Array[Int] = []
  while stack.length() > 0 {
    let top_idx = stack.length() - 1
    let (cur_node, edge_pos) = stack[top_idx]
    if edge_pos < adj[cur_node].length() {
      let (next_node, edge_idx) = adj[cur_node][edge_pos]
      stack[top_idx] = (cur_node, edge_pos + 1)
      if !visited[edge_idx] {
        visited[edge_idx] = true
        stack.push((next_node, 0))
      } else {
        ()
      }
    } else {
      let new_stack : Array[(Int, Int)] = []
      let mut i = 0
      while i < top_idx {
        new_stack.push(stack[i])
        i = i + 1
      }
      stack = new_stack
      if top_idx > 0 {
        let new_top_idx = top_idx - 1
        let (_, prev_edge_pos) = stack[new_top_idx]
        if prev_edge_pos > 0 {
          let (prev_node, _) = stack[new_top_idx]
          let actual_edge_idx = adj[prev_node][prev_edge_pos - 1].1
          path.push(actual_edge_idx)
        } else {
          ()
        }
      } else {
        ()
      }
    }
  }
  let result : Array[Int] = []
  let mut i = path.length() - 1
  while i >= 0 {
    result.push(path[i])
    i = i - 1
  }
  result
}

///|
/// 查找无向图的欧拉路径
pub fn[G : @core.GraphReadable] find_euler_path_undirected(
  graph : G,
) -> EulerPathResult {
  if !has_euler_path_undirected(graph) {
    return EulerPathResult::{
      exists: false,
      path: [],
      start_node: None,
      end_node: None,
    }
  }
  let (adj, edge_count, edges) = build_adjacency_with_edges(graph)
  if edge_count == 0 {
    return EulerPathResult::{
      exists: true,
      path: [],
      start_node: None,
      end_node: None,
    }
  }
  let (odd_count, first_odd, second_odd) = check_degree_parity(graph)
  let start_node = match first_odd {
    Some(n) => n
    None => find_first_non_isolated(graph)
  }
  let edge_indices = hierholzer_undirected_full(adj, edge_count, start_node)
  let path_edges : Array[@core.Edge] = []
  for idx in edge_indices {
    if idx >= 0 && idx < edges.length() {
      path_edges.push(edges[idx])
    } else {
      ()
    }
  }
  let end_node_id = if path_edges.length() > 0 {
    Some(path_edges[path_edges.length() - 1].to)
  } else {
    None
  }
  EulerPathResult::{
    exists: true,
    path: path_edges,
    start_node: Some(@core.NodeId(start_node)),
    end_node: end_node_id,
  }
}

///|
/// 查找无向图的欧拉回路
pub fn[G : @core.GraphReadable] find_euler_circuit_undirected(
  graph : G,
) -> EulerCircuitResult {
  if !has_euler_circuit_undirected(graph) {
    return EulerCircuitResult::{ exists: false, circuit: [], start_node: None }
  }
  let (adj, edge_count, edges) = build_adjacency_with_edges(graph)
  if edge_count == 0 {
    return EulerCircuitResult::{ exists: true, circuit: [], start_node: None }
  }
  let start_node = find_first_non_isolated(graph)
  let edge_indices = hierholzer_undirected_full(adj, edge_count, start_node)
  let circuit_edges : Array[@core.Edge] = []
  for idx in edge_indices {
    if idx >= 0 && idx < edges.length() {
      circuit_edges.push(edges[idx])
    } else {
      ()
    }
  }
  EulerCircuitResult::{
    exists: true,
    circuit: circuit_edges,
    start_node: Some(@core.NodeId(start_node)),
  }
}
```

---

## 🔍 代码详解：4 个关键设计决策

### 设计决策 1️⃣ 为什么使用显式栈而非递归？

```moonbit
// ❌ 方式 A: 朴素递归实现
// 问题: 对于大规模图（如 10 万条边），递归深度可能导致栈溢出!
// MoonBit 的调用栈大小有限，深度嵌套会崩溃

fn hierholzer_recursive(adj, node, visited, path) {
  for each (neighbor, edge_idx) in adj[node] {
    if !visited[edge_idx] {
      visited[edge_idx] = true
      hierholzer_recursive(adj, neighbor, visited, path)  // 递归调用!
      path.push(edge_idx)
    }
  }
}

// ✅ 方式 B: 显式栈模拟（mbtgraph 采用）
// 优势:
//   - 不受调用栈深度限制，可处理任意规模的图
//   - 栈的状态完全可控，便于调试和理解
//   - 内存使用更可预测（堆内存 vs 栈内存）

// 栈元素设计:
let mut stack : Array[(Int, Int)] = [(start_node, 0)]
// (current_node, next_edge_position_to_try)
//
// - current_node: 当前所在的节点
// - next_edge_position: 下一条要尝试的边在邻接表中的索引
//
// 这个设计的关键:
//   我们不仅记录"在哪里"，还记录"下一步该试哪条边"
//   这样就能在回溯时正确恢复状态!
```

**为什么这个设计很巧妙？**

```
传统 DFS 栈只保存节点:
  stack = [0, 1, 2, 0]  // 只知道"经过了这些节点"

mbtgraph 的栈保存 (节点, 边位置):
  stack = [(0,1), (1,2), (2,1), (0,0)]
  // 不仅知道"在哪里"，还知道"下次该试第几条边"

当回溯发生时:
  传统方式: 不知道该从哪条边继续尝试 → 需要额外的辅助数组
  mbtgraph方式: 直接读取 edge_pos 就知道! → 状态完全自包含!
```

### 设计决策 2️⃣ 如何处理无向图的边索引去重？

```moonbit
/// 核心挑战: 无向图的每条物理边在邻接表中出现两次!
///
/// 例如边 u-v (索引为 3):
///   adj[u] 包含 (v, 3)   ← 正向引用
///   adj[v] 包含 (u, 3)   ← 反向引用
///
/// 我们必须确保: 无论从 u 还是 v 出发，
/// 这条边只被"使用"一次!

// 解决方案: visited[] 数组 + 边级索引

let visited : Array[Bool] = Array::make(edge_count, false)
// visited[i] = true 表示第 i 条物理边已被使用

// 在构建邻接表时:
if nbr.0 > nid.0 {  // 只处理一次! 避免重复添加
  let edge = @core.Edge::{ from: nid, to: nbr, data: weight }
  adj[nid.0].push((nbr.0, edge_index))   // u → v, 共享索引
  adj[nbr.0].push((nid.0, edge_index))   // v → u, 相同索引!
  edges.push(edge)
  edge_index = edge_index + 1
}

// 在搜索时:
if !visited[edge_idx] {  // 检查这条物理边是否用过
  visited[edge_idx] = true  // 标记为已用
  stack.push((next_node, 0))  // 继续前进
} else {
  ()  // 跳过! 这条边已经从另一端走过了
}
```

**为什么用 `nbr.0 > nid.0` 而不是 `!=`？**

```
遍历邻居时:
  节点 0 的邻居: [1, 2, 3]
  节点 1 的邻居: [0, 2, 4]
  ...

如果用 != (不等于):
  处理 0 的邻居 1 时: 1 > 0? Yes → 添加边 (0,1)
  处理 1 的邻居 0 时: 0 != 1? Yes → 又添加边 (1,0)! 重复了!

如果用 > (大于):
  处理 0 的邻居 1 时: 1 > 0? Yes → 添加边 (0,1)
  处理 1 的邻居 0 时: 0 > 1? No → 跳过!  ✅ 避免重复!

这保证了每条无向边只被添加一次到 edges[] 数组中。
```

### 设计决策 3️⃣ 如何确定欧拉路径的起点？

```moonbit
/// 欧拉路径的起点选择至关重要!
///
/// 规则:
///   - 有 2 个奇度节点 → 必须从一个奇度节点开始
///   - 有 0 个奇度节点（欧拉回路）→ 从任意非孤立节点开始

let (odd_count, first_odd, second_odd) = check_degree_parity(graph)
let start_node = match first_odd {
  Some(n) => n           // 有奇度节点 → 从第一个奇度节点开始
  None => find_first_non_isolated(graph)  // 全偶度 → 从任意非孤立节点开始
}

/// 为什么必须从奇度节点开始?
///
/// 直观解释 (握手定理的推论):
///
///   想象你走在路径上:
///   - 每经过一个"中间节点"，你需要"进入"再"离开"
///     → 消耗 2 条边（度数 -2）
///   - 只有"起点"和"终点"例外:
///     起点只"离开"不"进入"（度数 -1）
///     终点只"进入"不"离开"（度数 -1）
///
///   所以:
///     奇度节点数 = 0 → 起点=终点（回路），可以在任何地方开始
///     奇度节点数 = 2 → 一个是起点，一个是终点!
///
/// 数学证明:
///   设路径为 v0 → v1 → ... → vk
///   内部节点 v1...v(k-1) 各出现 2 次 → 贡献偶数度
///   v0 和 vk 各出现 1 次 → 贡献奇数度
///   ∴ 奇度节点只能是 v0 和 vk（如果它们不同的话）
```

### 设计决策 4️⃣ 为什么最终结果需要反转？

```moonbit
/// Hierholzer 算法的一个反直觉特性:
/// 收集到的边顺序是"反向"的!

/// 原因分析:
///
/// 算法的工作方式类似于"后序遍历":
///
///   1. 深入探索直到死胡同
///   2. 在"回溯"时才记录边
///   3. 最先走完的边最后被记录
///
/// 具体例子 (三角形 0-1-2-0):
///
///   探索顺序: 0 → 1 → 2 → 0 (死胡同!)
///   回溯顺序: 在 0 记录 e1, 在 2 记录 e2, 在 1 记录 e0
///   path = [1, 2, 0]  (反向的!)
///
///   反转后: result = [0, 2, 1]
///   对应: e0(0-1) → e2(1-2) → e1(2-0)  ✅ 正确!

// 代码实现:
let result : Array[Int] = []
let mut i = path.length() - 1
while i >= 0 {
  result.push(path[i])  // 从后往前复制
  i = i - 1
}
result

/// 性能影响:
///   反转操作的时间复杂度: O(E)
///   相对于整体 O(E) 的复杂度，这只是常数因子
///   所以不会影响渐进复杂度
```

**类比理解：**

```
想象你在走迷宫并留下 breadcrumbs（面包屑）:

  进入迷宫时: 你往前走，不留痕迹
  遇到死胡同: 开始往回走，一边走一边放面包屑
  最终结果: 面包屑的顺序是从"最深处"到"入口"的
  要得到正确顺序: 需要把面包屑列表反转!

Hierholzer 的 path[] 就是这些面包屑:
  - 在回溯时"放下"（push）边索引
  - 所以顺序是反的
  - 最后反转得到正确答案
```

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 判定与查找

```moonbit
fn euler_basic_demo() -> Unit {
  // 构建一个简单的无向图（矩形 + 对角线）
  let g = UndirectedAdjList::new()

  let g = @core.GraphWritable::add_node(g, @core.Node::{ id: @core.NodeId(0), data: "A" }) |> ignore
  let g = @core.GraphWritable::add_node(g, @core.Node::{ id: @core.NodeId(1), data: "B" }) |> ignore
  let g = @core.GraphWritable::add_node(g, @core.Node::{ id: @core.NodeId(2), data: "C" }) |> ignore
  let g = @core.GraphWritable::add_node(g, @core.Node::{ id: @core.NodeId(3), data: "D" }) |> ignore

  // 构成矩形: 0-1-2-3-0
  let g = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  let g = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  let g = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  let g = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0) |> ignore

  println("=== 欧拉路径/回路基础演示 ===")
  println("图结构: 矩形 (4 节点, 4 边)")

  // 判定是否存在欧拉路径
  let has_path = @euler.has_euler_path_undirected(g)
  let has_circuit = @euler.has_euler_circuit_undirected(g)

  println("\n📊 判定结果:")
  println("  存在欧拉路径: ${has_path}")
  println("  存在欧拉回路: ${has_circuit}")

  // 查找欧拉回路
  match has_circuit {
    true => {
      let result = @euler.find_euler_circuit_undirected(g)

      println("\n🔄 欧拉回路:")
      println("  起点: ${result.start_node}")
      println("  边数: ${result.circuit.length()}")

      println("\n  详细路径:")
      for (i, edge) in result.circuit.indexed() {
        println("    ${i}. ${edge.from} → ${edge.to}")
      }

      println("\n  节点访问序列:")
      let mut node_seq : Array[String] = []
      if result.circuit.length() > 0 {
        node_seq.push(result.start_node.unwrap().to_string())
        for edge in result.circuit {
          node_seq.push(edge.to.to_string())
        }
      }
      println("  ${node_seq.join(" → ")}")
    }
    false => println("  ❌ 不存在欧拉回路")
  }
}

// 可能的输出:
// === 欧拉路径/回路基础演示 ===
// 图结构: 矩形 (4 节点, 4 边)
//
// 📊 判定结果:
//   存在欧拉路径: true
//   存在欧拉回路: true
//
// 🔄 欧拉回路:
//   起点: Some(NodeId(0))
//   边数: 4
//
//   详细路径:
//     0. NodeId(0) → NodeId(1)
//     1. NodeId(1) → NodeId(2)
//     2. NodeId(2) → NodeId(3)
//     3. NodeId(3) → NodeId(0)
//
//   节点访问序列:
//   NodeId(0) → NodeId(1) → NodeId(2) → NodeId(3) → NodeId(0)
```

### 示例 2: 📮 中国邮递员问题 (Chinese Postman Problem)

```moonbit
/// 使用欧拉回路解决邮递员路线规划问题
///
/// 场景: 邮递员需要覆盖投递区域的所有街道，
///       每条街道至少经过一次，希望总路程最短。
///       如果图本身存在欧拉回路，则最优解就是欧拉回路！
fn plan_postman_route(
  street_map : UndirectedAdjList,
  location_names : Map[Int, String],
) -> Unit {
  println("\n=== 📮 中国邮递员问题 ===")

  // 检查街道图是否可以直接一笔画
  let has_circuit = @euler.has_euler_circuit_undirected(street_map)
  let has_path = @euler.has_euler_path_undirected(street_map)

  match has_circuit {
    true => {
      println("✅ 太棒了! 这个街道图存在欧拉回路!")
      println("   邮递员可以不重复地走完所有街道并回到邮局!\n")

      let route = @euler.find_euler_circuit_undirected(street_map)

      println("🗺️ 最优投递路线:")
      println("   总边数: ${route.circuit.length()} 条街道")

      let start_name = location_names.get(route.start_node.unwrap().0).unwrap_or("?")
      println("   起点(邮局): ${start_name}")

      println("\n   街道遍历顺序:")
      for (step, edge) in route.circuit.indexed() {
        let from_name = location_names.get(edge.from.0).unwrap_or("?")
        let to_name = location_names.get(edge.to.0).unwrap_or("?")
        println("   ${step + 1}. ${from_name} → ${to_name}  (街道 #${step})")
      }

      println("\n💡 这是理论上最优的路线:")
      println("   ✅ 每条街道恰好经过一次")
      println("   ✅ 总路程 = 所有街道长度之和（无法更短！）")
      println("   ✅ 最终回到邮局，准备第二天的工作")
    }
    false => {
      match has_path {
        true => {
          println("⚠️ 存在欧拉路径，但不存在欧拉回路")
          println("   邮递员可以从一个端点走到另一个端点")
          println("   但需要在某些街道重复走才能回到起点\n")

          let route = @euler.find_euler_path_undirected(street_map)

          let start_name = location_names.get(route.start_node.unwrap().0).unwrap_or("?")
          let end_name = location_names.get(route.end_node.unwrap().0).unwrap_or("?")

          println("📍 路径信息:")
          println("   起点: ${start_name}")
          println("   终点: ${end_name}")
          println("   建议: 在 ${end_name} 设置临时邮局，或在往返路线上增加重复路段")
        }
        false => {
          println("❌ 该街道图既不存在欧拉路径也不存在欧拉回路")
          println("   需要通过添加重复边来转化为欧拉图")
          println("   (这是完整的中国邮递员问题的 NP-hard 部分)")
        }
      }
    }
  }
}

// 使用示例
let city_streets = build_street_network()
let names = Map::new()
names.insert(0, "邮局")
names.insert(1, "主街")
names.insert(2, "商业区")
names.insert(3, "住宅区")
names.insert(4, "学校")

plan_postman_route(city_streets, names)

// 可能的输出:
// === 📮 中国邮递员问题 ===
// ✅ 太棒了! 这个街道图存在欧拉回路!
//    邮递员可以不重复地走完所有街道并回到邮局!
//
// 🗺️ 最优投递路线:
//    总边数: 8 条街道
//    起点(邮局): 邮局
//
//    街道遍历顺序:
//    1. 邮局 → 主街  (街道 #0)
//    2. 主街 → 商业区  (街道 #1)
//    3. 商业区 → 住宅区  (街道 #2)
//    4. 住宅区 → 学校  (街道 #3)
//    5. 学校 → 邮局  (街道 #4)
//    6. 邮局 → 住宅区  (街道 #5)
//    7. 住宅区 → 主街  (街道 #6)
//    8. 主街 → 商业区  (街道 #7)
//
// 💡 这是理论上最优的路线:
//    ✅ 每条街道恰好经过一次
//    ✅ 总路程 = 所有街道长度之和（无法更短！）
//    ✅ 最终回到邮局，准备第二天的工作
```

### 示例 3: 🎨 图案绘制与 DNA 测序

```moonbit
/// 应用欧拉路径解决实际问题:
/// 1. 图案绘制: 一笔画画成检测
/// 2. De Bruijn 序列构建 (简化版 DNA 测序)
fn euler_applications_demo() -> Unit {

  // ========== 应用 1: 一笔画游戏验证 ==========

  println("=== 🎨 应用 1: 一笔画游戏验证 ===\n")

  // 创建一个"房子"图案的一笔画谜题
  let drawing = UndirectedAdjList::new()
  let drawing = add_drawing_nodes(drawing, 5)
  // 房子的轮廓: 5 条边
  let drawing = @core.GraphWritable::add_edge(drawing, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore  // 左墙
  let drawing = @core.GraphWritable::add_edge(drawing, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore  // 屋顶右
  let drawing = @core.GraphWritable::add_edge(drawing, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore  // 屋顶左
  let drawing = @core.GraphWritable::add_edge(drawing, @core.NodeId(0), @core.NodeId(3), 1.0) |> ignore  // 左边
  let drawing = @core.GraphWritable::add_edge(drawing, @core.NodeId(3), @core.NodeId(4), 1.0) |> ignore  // 底边
  let drawing = @core.GraphWritable::add_edge(drawing, @core.NodeId(4), @core.NodeId(0), 1.0) |> ignore  // 右边

  println("图案: 房子 (三角屋顶 + 正方形主体)")
  println("节点: 5 个, 边: 6 条")

  let can_draw = @euler.has_euler_path_undirected(drawing)

  match can_draw {
    true => {
      let result = @euler.find_euler_path_undirected(drawing)

      println("\n✅ 这个图案可以一笔画成!")

      let start = result.start_node.unwrap().0
      let end_opt = result.end_node

      match end_opt {
        Some(end) => {
          if start == end.0 {
            println("   类型: 欧拉回路 (起终点相同)")
          } else {
            println("   类型: 欧拉路径 (起点=${start}, 终点=${end.0})")
          }
        }
        None => ()
      }

      println("\n   笔画顺序 (${result.path.length()} 笔):")
      for (i, edge) in result.path.indexed() {
        println("   第${i + 1}笔: ${edge.from} → ${edge.to}")
      }
    }
    false => {
      println("❌ 这个图案无法一笔画成")
      println("   提示: 尝试添加或删除一些线条")
    }
  }


  // ========== 应用 2: De Bruijn 图与序列重组 ==========

  println("\n\n=== 🧬 应用 2: De Bruijn 序列 (简化版) ===\n")

  /// 构建 k 阶 De Bruijn 图的简化版本
  /// 用于理解欧拉路径在序列组装中的应用
  ///
  /// 原理: DNA 测序产生的短片段（reads）可以通过
  ///       De Bruijn 图组装成完整序列，而寻找欧拉路径
  ///       就是组装过程的核心步骤!

  // 示例: 假设我们有以下 3-mer 片段 (k=3)
  // ABC, BCD, CDE, DEF, EFG
  // 它们可以组装成: ABCDEFG

  let de_bruijn = UndirectedAdjList::new()

  // 创建节点 (2-mer 前缀/后缀)
  let nodes = ["AB", "BC", "CD", "DE", "EF", "FG"]
  for (i, name) in nodes.indexed() {
    let de_bruijn = @core.GraphWritable::add_node(
      de_bruijn,
      @core.Node::{ id: @core.NodeId(i), data: name }
    ) |> ignore
  }

  // 添加边 (代表 3-mers)
  // AB→BC (ABC), BC→CD (BCD), CD→DE (CDE), DE→DEF, EF→EFG
  let edges = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)]
  for (u, v) in edges {
    let de_bruijn = @core.GraphWritable::add_edge(
      de_bruijn,
      @core.NodeId(u),
      @core.NodeId(v),
      1.0
    ) |> ignore
  }

  println("De Bruijn 图 (k=3):")
  println("  节点 (2-mers): ${nodes.join(", ")}")
  println("  边 (3-mers): ABC, BCD, CDE, DEF, EFG")

  let has_euler = @euler.has_euler_path_undirected(de_bruijn)

  match has_euler {
    true => {
      let assembly = @euler.find_euler_path_undirected(de_bruijn)

      println("\n✅ 可以通过欧拉路径组装序列!")

      // 重建序列
      let mut sequence = ""
      if assembly.path.length() > 0 {
        let first_node = assembly.start_node.unwrap().0
        sequence = nodes[first_node]
        for edge in assembly.path {
          let next_char = nodes[edge.to.0].chars()[1]  // 取最后一个字符
          sequence = sequence + next_char.to_string()
        }
      }

      println("  组装结果: ${sequence}")
      println("  原始长度: ${sequence.length()} 个字符")
      println("  覆盖片段数: ${assembly.path.length() + 1}")

      println("\n💡 实际应用:")
      println("  - 基因组测序 (Genome Sequencing)")
      println("  - 蛋白质序列组装")
      println("  - 自然语言处理 (N-gram 模型)")
    }
    false => println("❌ 无法线性组装 (可能存在分支或循环)")
  }
}

// 可能的输出:
// === 🎨 应用 1: 一笔画游戏验证 ===
//
// 图案: 房子 (三角屋顶 + 正方形主体)
// 节点: 5 个, 边: 6 条
//
// ✅ 这个图案可以一笔画成!
//    类型: 欧拉路径 (起点=0, 终点=3)
//
//    笔画顺序 (6 笔):
//    第1笔: NodeId(0) → NodeId(1)
//    第2笔: NodeId(1) → NodeId(2)
//    第3笔: NodeId(2) → NodeId(0)
//    第4笔: NodeId(0) → NodeId(4)
//    第5笔: NodeId(4) → NodeId(3)
//    第6笔: NodeId(3) → NodeId(0)
//
//
// === 🧬 应用 2: De Bruijn 序列 (简化版) ===
//
// De Bruijn 图 (k=3):
//   节点 (2-mers): AB, BC, CD, DE, EF, FG
//   边 (3-mers): ABC, BCD, CDE, DEF, EFG
//
// ✅ 可以通过欧拉路径组装序列!
//   组装结果: ABCDEFG
//   原始长度: 7 个字符
//   覆盖片段数: 6
//
// 💡 实际应用:
//   - 基因组测序 (Genome Sequencing)
//   - 蛋白质序列组装
//   - 自然语言处理 (N-gram 模型)
```

---

## 📈 复杂度分析

### 时间复杂度

| 操作 | 次数 | 单次复杂度 | 总复杂度 | 说明 |
|------|------|-----------|----------|------|
| **判定阶段** | | | |
| 度数统计 (`check_degree_parity`) | 1 次 | O(V + E) | O(V + E) | 遍历所有节点和边 |
| BFS 连通性检查 | 1 次 | O(V + E) | O(V + E) | 最坏情况遍历全图 |
| **查找阶段** (Hierholzer) | | | |
| 构建邻接表 (`build_adjacency`) | 1 次 | O(V + E) | O(V + E) | 双向添加边 |
| 栈操作 (push/pop) | O(E) 次 | O(1) 均摊 | O(E) | 每条边至多入栈出栈各一次 |
| 边访问检查 | O(E) 次 | O(1) | O(E) | `visited` 数组查询 |
| 路径反转 | 1 次 | O(E) | O(E) | 最终结果反转 |
| **总计** | | **O(V + E)** | | |

### 空间复杂度

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `adj[][]` | O(V + E) | 带边索引的邻接表 |
| `edges[]` | O(E) | 边对象数组 |
| `visited[]` | O(E) | 边访问标记 |
| `stack` | O(E) | 显式栈（最坏情况） |
| `path[]` | O(E) | 结果路径（反转前） |
| **总计** | **O(V + E)** | |

### 与其他欧拉算法实现的对比

| 实现方式 | 时间复杂度 | 空间复杂度 | 优点 | 缺点 |
|----------|-----------|-----------|------|------|
| **Hierholzer (显式栈)** ⭐ | **O(V + E)** | **O(V + E)** | **无递归深度限制，适合大规模图** | 代码稍复杂 |
| Hierholzer (递归) | O(V + E) | O(V + E) | 代码简洁直观 | 可能栈溢出（深图） |
| Fleury 算法 | O(V + E) | O(V + E) | 思想简单（避免桥） | 需要高效判断"桥"，常数大 |
| 朴素枚举 | O(E × E!) | O(E) | 理论可行 | 完全不可行！ |

### 什么时候应该用欧拉算法？

```
✅ 使用欧拉路径/回路算法的场景:
  - 需要不重复地遍历所有边（一笔画问题）
  - 图是无向的且已知连通
  - 需要最优的边遍历顺序（中国邮递员的特殊情况）
  - 应用: 邮递员路线、图案绘制、DNA 组装、网络诊断

❌ 不适用的场景:
  - 只需遍历所有节点（不是边！）→ 用 DFS/BFS
  - 需要最短路径 → 用 Dijkstra/Bellman-Ford
  - 图是有向的 → 用有向图版本的欧拉算法
  - 边有权重且需要最小化总权重 → 用中国邮递员完整版
```

---

## 🎯 实际应用场景

### 应用 1: 📮 中国邮递员问题 (Chinese Postman Problem, CPP)

```
问题: 邮递员需要走过负责区域的所有街道进行投递，
      每条街道至少走一次，如何使总路程最短？

欧拉算法的作用:
  如果街道图本身存在欧拉回路:
    ✅ 直接使用 Hierholzer 找到的回路就是最优解!
    ✅ 总路程 = 所有街道长度之和（理论下界达到!）

  如果不存在欧拉回路（有奇度节点）:
    ⚠️ 需要在某些街道上重复走（"重复边"）
    🔧 这变成了 CPP 的完整版本（需要最小化重复边的总长）
    💡 欧拉算法仍然是核心子程序!

实际系统:
  - 垃圾收集路线优化
  - 扫雪车路线规划
  - 快递配送路径设计
  - 城市巡检路线（水电煤气表读取）

变体问题:
  - Rural Postman Problem: 只需覆盖部分边
  - Windy Postman Problem: 正向/反向遍历代价不同
  - Mixed Postman Problem: 有向边和无向边混合
```

### 应用 2: 🎨 图案绘制与制造工艺

```
问题: CNC 雕刻机、3D 打印机、电路板钻孔机需要
      按照特定路径移动工具头，如何最小化"空行程"?

欧拉算法的应用:
  当加工任务可以建模为"访问所有边"时:
    ✅ 欧拉路径提供了最优的访问顺序
    ✅ 减少工具头的抬起/落下次数
    ✅ 缩短总的加工时间

具体场景:
  1. 服装裁剪: 激光切割机按轮廓裁剪布料
     → 轮廓线集合 = 边集，求欧拉路径
  2. PCB 钻孔: 电路板上需要钻一系列孔
     → 如果孔之间有连线需求，可转化为边遍历
  3. 喷绘/刺绣: 图案由连续线条组成
     → 一笔画 = 欧拉路径，减少换色次数

工业案例:
  - AutoCAD 的"最优路径"功能
  - 服装 CAD 软件 (OptTex, Gerber)
  - 印刷电路板 CAM 软件
```

### 应用 3: 🧬 生物信息学：基因组组装

```
问题: DNA 测序技术只能产生短的序列片段（reads），
      如何将这些片段组装成完整的基因组序列?

De Bruijn 图方法:
  1. 将 reads 分解为 k-mers (长度为 k 的子串)
  2. 构建 De Bruijn 图:
     - 节点 = (k-1)-mers
     - 边 = k-mers (连接其前缀和后缀)
  3. 在图中寻找欧拉路径 → 就是组装结果!

示例:
  Reads: [ABCD, BCDE, CDEF, DEFG, EFGH]
  k=4, (k-1)=3

  节点 (3-mers): ABC, BCD, CDE, DEF, EFG, FGH
  边 (4-mers):
    ABC→BCD (ABCD)
    BCD→CDE (BCDE)
    CDE→DEF (CDEF)
    DEF→DEFG (DEFG)
    EFG→FGH (EFGH)

  欧拉路径: ABC → BCD → CDE → DEF → EFG → FGH
  组装结果: ABCDEFGH  ✅

实际复杂性:
  - 真实基因组有数十亿碱基对
  - 存在重复序列（导致图中有环）
  - 测序错误（导致图中有噪声）
  - 基于欧拉的组装器: Velvet, SPAdes, ABySS

vs Hamilton 路径方法:
  - 旧方法: 节点 = reads, 边 = 重叠 → 寻找 Hamilton 路径
  - 问题: Hamilton 路径是 NPC 问题！计算不可行
  - De Bruijn + 欧拉: P 问题！多项式时间可解 ⭐
```

### 应用 4: 🌐 网络诊断与测试

```
问题: 如何全面测试网络中的所有链路？
      如何生成覆盖所有连接的测试用例?

欧拉算法在网络领域的应用:

1. 全链路测试 (All-Links Test):
   - 网络设备之间的物理/逻辑连接 = 边
   - 需要发送测试包经过每条链路
   - 欧拉路径提供最优的测试顺序

2. 拓扑发现验证:
   - 发现的网络拓扑声称是某种结构
   - 通过尝试找欧拉路径来验证连通性和一致性

3. SDN (软件定义网络) 流规则安装:
   - 控制器需要在交换机上安装转发规则
   - 规则之间的依赖关系可以建模为图
   - 安装顺序优化 ≈ 边遍历问题

具体协议/工具:
  - SNMP 遍历: 发现网络设备的链路层连接
  - TRILL / SPB: 以太网路由协议的环路测试
  - Network Atlas: 自动化网络映射工具
```

---

## 🧪 练习题

### 练习 1: 手动判定欧拉路径/回路 ⭐⭐

对于以下无向图，判断是否存在欧拉路径和/或欧拉回路。如果存在，写出起点和终点。

```
    A ------- B
    | \     / |
    |   \ /   |
    |    X    |
    |   / \   |
    | /     \ |
    C ------- D
    |
    E

边列表:
  A-B, A-C, A-D, B-C, B-D, C-D, C-E
```

<details>
<summary>📝 点击查看答案</summary>

```
第一步: 统计每个节点的度数

  节点 A: 连接 [B, C, D] → degree = 3 (奇数)
  节点 B: 连接 [A, C, D] → degree = 3 (奇数)
  节点 C: 连接 [A, B, D, E] → degree = 4 (偶数)
  节点 D: 连接 [A, B, C] → degree = 3 (奇数)
  节点 E: 连接 [C] → degree = 1 (奇数)

第二步: 分析奇偶性

  奇度节点: A(3), B(3), D(3), E(1)
  odd_count = 4

第三步: 应用判定定理

  欧拉路径条件: odd_count == 0 或 2
    4 ≠ 0 且 4 ≠ 2 → ❌ 不存在欧拉路径

  欧拉回路条件: odd_count == 0
    4 ≠ 0 → ❌ 不存在欧拉回路

第四步: 连通性检查（快速目测）

  从任何节点都可以到达其他节点 → 图是连通的

结论:
  ❌ 该图既不存在欧拉路径，也不存在欧拉回路
  原因: 奇度节点数为 4（超过了允许的最大值 2）

如何修改使其存在欧拉路径?
  方案 1: 删除边 C-E (去掉节点 E)
    → 奇度节点变为 A, B, D (3个) → 还是不行!
  方案 2: 删除边 C-E 并删除边 A-D
    → A(2), B(3), C(3), D(2) → 奇度节点 = 2 (B, C) ✅
    → 存在欧拉路径! 起点=B, 终点=C (或反之)
  方案 3: 添加边 E-F (新节点) 并添加边 E-F
    → E 的度变为 2 (偶数), F 的度为 1 (奇数)
    → 奇度节点 = A, B, D, F (还是 4个!) → 需要更多调整...
```

</details>

### 练习 2: 编程实现 - 找出所有欧拉回路 ⭐⭐⭐

基于 mbtgraph 的 `find_euler_circuit_undirected` 函数，实现一个函数，找出图中**所有不同的欧拉回路**（考虑旋转对称性后的唯一回路）。

```moonbit
/// 提示:
/// 1. 欧拉回路的不确定性来自于: 起点选择 + 邻居访问顺序
/// 2. 可以通过固定起点 + 枚举不同的邻接表排列来生成不同回路
/// 3. 需要去重: 回路 A-B-C-A 和 B-C-A-B 是相同的（旋转等价）
```

<details>
<summary>💻 点击查看解答框架</summary>

```moonbit
/// 查找所有唯一的欧拉回路（旋转归一化后）
pub fn[G : @core.GraphReadOnly] find_all_unique_euler_circuits(
  graph : G,
) -> Array[Array[@core.Edge]] {
  // 前置检查: 必须存在欧拉回路
  if !has_euler_circuit_undirected(graph) {
    return []
  }

  let (adj, edge_count, edges) = build_adjacency_with_edges(graph)
  let circuits : Array[Array[@core.Edge]] = []

  // 固定起点为第一个非孤立节点
  let start_node = find_first_non_isolated(graph)

  // 对起点的邻接表进行全排列，每种排列产生不同的回路
  let permutations = generate_permutations(adj[start_node])

  for perm in permutations {
    // 修改邻接表使用当前的排列顺序
    let modified_adj = deep_copy_adjacency(adj)
    modified_adj[start_node] = perm

    // 运行 Hierholzer
    let edge_indices = hierholzer_undirected_full(modified_adj, edge_count, start_node)

    // 转换为边序列
    let circuit = indices_to_edges(edge_indices, edges)

    // 旋转归一化: 找到字典序最小的旋转作为代表
    let normalized = normalize_circuit_rotation(circuit)

    // 去重检查
    if !circuits.contains(normalized) {
      circuits.push(normalized)
    }
  }

  circuits
}

/// 旋转归一化: 将回路旋转到字典序最小的形式
fn normalize_circuit_rotation(circuit : Array[Edge]) -> Array[Edge] {
  if circuit.length() == 0 {
    return circuit
  }

  let mut best = circuit
  let mut best_str = circuit_to_string(circuit)

  for i in 1..circuit.length() {
    // 旋转: 把前 i 个元素移到末尾
    let rotated = rotate_left(circuit, i)
    let rotated_str = circuit_to_string(rotated)

    if rotated_str < best_str {
      best = rotated
      best_str = rotated_str
    }
  }

  best
}
```

</details>

### 练习 3: 进阶 - 有向图欧拉算法 ⭐⭐⭐⭐

**挑战**: 扩展 mbtgraph 的欧拉算法以支持**有向图**。

**有向图的判定条件差异**:
- **欧拉路径**: 图弱连通 + 最多一个节点的 `out_deg - in_deg = 1`（起点）+ 最多一个节点的 `in_deg - out_deg = 1`（终点）+ 其余节点 `in_deg = out_deg`
- **欧拉回路**: 图弱连通 + 所有节点 `in_deg = out_deg`

**提示**:
- 需要分别统计入度和出度
- Hierholzer 算法基本不变，但邻接表只需单向构建
- 注意有向图的连通性需要用"弱连通"（忽略方向）

<details>
<summary>🔧 参考实现框架</summary>

```moonbit
/// 有向图欧拉路径判定
pub fn[G : @core.GraphDirected] has_euler_path_directed(graph : G) -> Bool {
  // 1. 检查弱连通性（将边视为无向）
  if !is_weakly_connected(graph) {
    return false
  }

  // 2. 统计入度和出度的差值
  let mut start_candidates = 0  // out - in = 1 的节点数
  let mut end_candidates = 0    // in - out = 1 的节点数

  for nid in @core.GraphReadable::node_ids(graph) {
    let out_deg = @core.GraphDirected::out_degree(graph, nid)
    let in_deg = @core.GraphDirected::in_degree(graph, nid)
    let diff = out_deg - in_deg

    if diff == 1 {
      start_candidates = start_candidates + 1
    } else if diff == -1 {
      end_candidates = end_candidates + 1
    } else if diff != 0 {
      return false  // 差值不为 -1, 0, 1 → 不可能
    }
  }

  // 3. 判定条件
  (start_candidates == 1 && end_candidates == 1) ||
  (start_candidates == 0 && end_candidates == 0)  // 回路也是路径的特例
}

/// 有向图 Hierholzer 算法
fn hierholzer_directed(
  adj : Array[Array[(Int, Int)]],  // 单向邻接表
  edge_count : Int,
  start_node : Int,
) -> Array[Int] {
  // 基本结构与无向版本相同
  // 主要区别: 邻接表不需要双向添加
  //           不需要 visited 去重（有向边只有一个方向）

  let visited : Array[Bool] = Array::make(edge_count, false)
  let mut stack : Array[(Int, Int)] = [(start_node, 0)]
  let path : Array[Int] = []

  while stack.length() > 0 {
    let top_idx = stack.length() - 1
    let (cur_node, edge_pos) = stack[top_idx]

    if edge_pos < adj[cur_node].length() {
      let (next_node, edge_idx) = adj[cur_node][edge_pos]
      stack[top_idx] = (cur_node, edge_pos + 1)

      if !visited[edge_idx] {
        visited[edge_idx] = true
        stack.push((next_node, 0))
      }
    } else {
      // 回溯逻辑与无向版本相同
      // ...
    }
  }

  // 反转并返回
  reverse_array(path)
}

// 使用示例: 有向图的典型应用
// - 有限状态机的状态转换遍历
// - 函数调用图的分析
// - 死锁检测（寻找环路）
// - 数据流分析
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo - Eulerian Tour** | https://visualgo.net/en/eulertour | 🏆 业界标杆，支持欧拉路径/回路动画 |
| Algorithm Visualizer | https://algorithm-visualizer.org/graphs/hierholzer.html | 清晰的栈状态追踪 |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/Euler.html | 学术风格，支持手动步进 |
| Geogebra Euler Path | https://www.geogebra.org/m/eqtqxy6h | 交互式一笔画体验 |

### 理论延伸阅读

- **哈密顿路径/回路**: [Hamiltonian 教程](/algorithms/hamiltonian/)（遍历节点而非边，NPC 问题）
- **最短路径**: [Dijkstra 教程](/algorithms/shortest-path/dijkstra/)（另一种重要的图遍历）
- **广度优先搜索**: [BFS 教程](/algorithms/traversal/bfs/index/)（用于连通性检查）
- **深度优先搜索**: [DFS 教程](/algorithms/traversal/dfs/index/)（Hierholzer 基于 DFS）
- **连通性算法**: [Tarjan SCC](/algorithms/connectivity/scc/tarjan.md) / [Kosaraju](/algorithms/connectivity/scc/kosaraju.md)
- **割点与桥**: [Articulation Points](/algorithms/connectivity/articulation-points/)（Fleury 算法需要识别桥）

### 经典教材推荐

| 书名 | 作者 | 推荐章节 |
|------|------|----------|
| *Introduction to Algorithms (CLRS)* | Cormen et al. | Ch.22 Elementary Graph Algorithms, Ch.35 Eulerian and Hamiltonian Paths |
| *Algorithm Design* | Kleinberg & Tardos | Ch.7.3 Eulerian Walks (应用: DNA sequencing) |
| *Graph Theory* | Diestel | Ch.1.8 Euler Tours |
| 图论及其应用 | Bondy & Murty | 第4章 通路、圈和连通性 |
| 算法导论（中文版） | 殷建平等译 | 第22章 基本的图算法 |

### 历史与哲学阅读

- **Euler's Original Paper**: "Solutio problematis ad geometriam situs pertinentis" (1736)
  - [英译版](https://math.dartmouth.edu/~euler/docs/translations/E053trans.pdf)
- **The Seven Bridges of Königsberg**: 维基百科上的详细介绍
  - [中文](https://zh.wikipedia.org/wiki/哥尼斯堡七桥问题) | [English](https://en.wikipedia.org/wiki/Seven_Bridges_of_Königsberg)
- **A Brief History of Graph Theory**: 从欧拉到现代网络科学

### mbtgraph API 参考

```moonbit
// ========== 判定函数 ==========

@euler.has_euler_path_undirected(graph)
  // → Bool: 无向图是否存在欧拉路径

@euler.has_euler_circuit_undirected(graph)
  // → Bool: 无向图是否存在欧拉回路

// ========== 查找函数 ==========

@euler.find_euler_path_undirected(graph)
  // → EulerPathResult:
  //    {
  //      exists: Bool,
  //      path: Array[Edge],       // 边序列
  //      start_node: NodeId?,     // 起点
  //      end_node: NodeId?        // 终点
  //    }

@euler.find_euler_circuit_undirected(graph)
  // → EulerCircuitResult:
  //    {
  //      exists: Bool,
  //      circuit: Array[Edge],    // 回路边序列
  //      start_node: NodeId?      // 起点（也是终点）
  //    }

// ========== 结果类型定义 ==========

pub(all) struct EulerPathResult {
  exists : Bool,
  path : Array[@core.Edge],
  start_node : @core.NodeId?,
  end_node : @core.NodeId?,
}

pub(all) struct EulerCircuitResult {
  exists : Bool,
  circuit : Array[@core.Edge],
  start_node : @core.NodeId?,
}

// ========== 内部辅助函数 (供高级用户) ==========

check_degree_parity(graph)     // → (Int, Int?, Int?) 奇度节点统计
is_connected_undirected(graph) // → Bool BFS 连通性检查
build_adjacency_with_edges(g)   // → (adj[][], count, edges[]) 邻接表构建
hierholzer_undirected_full(...) // → Array[Int] 核心算法
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** 欧拉路径与回路的定义和区别（路径 vs 回路，起点/终点约束）
- [ ] **掌握** 判定条件（连通性 + 奇度节点数：0 或 2）
- [ ] **理解** 度数奇偶性的作用（握手定理、奇度节点必成对）
- [ ] **手动执行** 小规模图的 Hierholzer 过程（写出栈状态/visited/path 变化）
- [ ] **实现** MoonBit 版本的欧拉算法（理解显式栈模拟、边索引去重、路径反转）
- [ ] **区分** Hierholzer vs Fleury vs 朴素的优劣（时间复杂度都是 O(V+E)，但常数和适用性不同）
- [ ] **知道** 欧拉算法的局限性（仅适用于无向/有向图，不支持带权/部分边覆盖）
- [ ] **分析** 欧拉算法的时间/空间复杂度（O(V+E) / O(V+E)，线性时间！）
- [ ] **应用** 欧拉算法到实际问题（邮递员路线/图案绘制/DNA 组装/网络诊断）

### 核心公式速查

```
欧拉路径判定 (无向图):
  ✅ exists ⇔ is_connected(G) AND (odd_count ∈ {0, 2})

欧拉回路判定 (无向图):
  ✅ exists ⇔ is_connected(G) AND (odd_count = 0)

Hierholzer 算法复杂度:
  Time: O(V + E)
  Space: O(V + E)

关键定理:
  握手定理: Σ degree(v) = 2|E|  ⇒  奇度节点数必为偶数
```

> 💡 **下一步**:
> - 尝试实现练习题中的**有向图欧拉算法**，理解入度/出度的约束差异
> - 或者进入 [Hamiltonian 路径](/algorithms/hamiltonian/) 学习 NPC 版本的"遍历所有节点"问题
> - 或者深入了解 [中国邮递员问题](https://en.wikipedia.org/wiki/Chinese_postman_problem)的完整版（需要最小权匹配！）

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行欧拉算法:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  // 创建一个矩形图（存在欧拉回路）
  let g = UndirectedAdjList::new()
  let g = add_nodes(g, 4)
  let g = g.add_edge(0, 1, 1.0) |> ignore
  let g = g.add_edge(1, 2, 1.0) |> ignore
  let g = g.add_edge(2, 3, 1.0) |> ignore
  let g = g.add_edge(3, 0, 1.0) |> ignore

  // 判定
  println("存在欧拉回路: ${@euler.has_euler_circuit_undirected(g)}")

  // 查找
  let result = @euler.find_euler_circuit_undirected(g)
  println("回路边数: ${result.circuit.length()}")

  // 输出路径
  for edge in result.circuit {
    println("${edge.from} → ${edge.to}")
  }
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看欧拉算法动画：<a href="https://visualgo.net/en/eulertour" target="_blank">https://visualgo.net/en/eulertour</a></p>
    <p><strong>重点观察：</strong></p>
    <ul>
      <li>判定阶段如何快速排除不可能的图（度数统计 + 连通性检查）</li>
      <li>Hierholzer 算法的"深入→死胡同→回溯→记录"模式</li>
      <li>为什么最终结果需要反转（后序遍历的特性）</li>
      <li>无向图如何处理边的双向引用（visited 数组的妙用）</li>
    </ul>
  </div>
</div>

<div class="callout" data-color="note">
  <div class="callout-header">
    <span class="callout-icon">📜</span>
    <p class="callout-title">历史注脚</p>
  </div>
  <div class="callout-content">
    <p><strong>1736 年，29 岁的欧拉在圣彼得堡科学院发表论文，证明了哥尼斯堡七桥问题无解。</strong></p>
    <p>这不仅解决了一个市民的娱乐谜题，更重要的是：</p>
    <ul>
      <li><strong>开创了图论</strong>：首次用抽象的"点和线"来建模现实问题</li>
      <li><strong>开创了拓扑学</strong>：研究几何图形在连续变形下保持不变的性质</li>
      <li><strong>建立了数学建模范式</strong>：将实际问题抽象为数学结构进行分析</li>
    </ul>
    <p>近 300 年后的今天，欧拉的这一工作仍在指导着邮递员送信、科学家测序基因、工程师设计芯片。这，就是数学的魅力！</p>
  </div>
</div>
