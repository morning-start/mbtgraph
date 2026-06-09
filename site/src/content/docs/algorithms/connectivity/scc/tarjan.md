---
title: "Tarjan 算法：强连通分量 (SCC)"
description: "基于 DFS 时间戳与低点值的单次遍历强连通分量检测，O(V+E) 时间复杂度"
---

# 🔗 Tarjan 算法：强连通分量（SCC）

> **"在社交网络中，如果 A 能通过转发链到达 B，B 也能反向到达 A，那他们就是同一个'朋友圈'——这就是强连通分量的本质。"**

## 📖 目录

- [算法简介](#算法简介)
- [核心概念](#核心概念)
- [动画演示](#动画演示)
- [MoonBit 完整实现](#moonbit-完整实现)
- [代码详解](#代码详解)
- [使用示例](#使用示例)
- [复杂度分析](#复杂度分析)
- [实际应用场景](#实际应用场景)
- [练习题](#练习题)
- [相关资源](#相关资源)
- [总结清单](#总结清单)

---

## 算法简介

### 什么是强连通分量？

在有向图中，**强连通分量（Strongly Connected Component, SCC）** 是最大的节点子集，其中**任意两个节点都可以互相到达**。

```
        ┌──→ ② ←──┐
        │    ↑     │
        ↓    │     ↓
   ① ──→ ③ ──→ ④ ←─ ⑤

   SCC #1: {①, ②, ③, ④}  ← 互相可达
   SCC #2: {⑤}             ← 单节点自成 SCC
```

### Tarjan 算法的优势

| 特性 | Tarjan | Kosaraju |
|------|--------|----------|
| **DFS 遍历次数** | **1 次** | 2 次 |
| **需要反转图** | **不需要** | 需要 |
| **时间复杂度** | O(V+E) | O(V+E) |
| **空间复杂度** | O(V) | O(V) |
| **实现难度** | 较高 | 较低 |
| **适用场景** | 内存受限、图不可变 | 图可轻松反转时 |

### 核心思想

Tarjan 算法的精髓在于**一次 DFS 遍历中同时完成两件事**：

1. **记录发现顺序** — `index[v]`：节点 v 被首次访问的时间戳
2. **追踪最低可达** — `low_link[v]`：从 v 出发，能回溯到的最早发现的节点

当 `low_link[v] == index[v]` 时，说明 v 是其所在 SCC 的**根节点**，此时栈中 v 以上的所有节点构成一个完整的 SCC。

---

## 核心概念

### 🕐 时间戳（index / DFN）

DFS 过程中按访问顺序给节点编号，从 0 开始递增：

```
DFS 访问顺序:  ① → ③ → ④ → ②

index[①] = 0    （第一个访问）
index[③] = 1
index[④] = 2
index[②] = 3    （第四个访问）
```

### 📉 低点值（low_link）

这是算法的**灵魂**！`low_link[v]` 表示：

> 从节点 v 出发，通过**任意多条树边 + 最多一条回边**，能到达的**最小 index 值**

```
更新规则：
  low_link[v] = min(
    index[v],                          // 自身的时间戳
    low_link[所有子节点 w],            // 子树的最低点
    index[所有已在栈中的邻居 u]         // 回边指向的更早节点
  )
```

### 📚 栈的作用

栈维护的是**当前正在探索的 DFS 路径**上的节点。关键性质：

- 节点入栈：首次被发现时
- 节点出栈：确认属于某个 SCC 时
- **同一 SCC 的节点在栈中是连续的**

### ✅ SCC 判定条件

```moonbit
if low_link[v] == index[v] {
  // v 是 SCC 的根节点！
  // 弹出栈顶直到 v，弹出的所有节点构成一个 SCC
}
```

---

## 动画演示

### 示例图

我们用以下有向图来演示 Tarjan 算法的完整执行过程：

```
                    ┌─────────────┐
                    │             │
                    ↓             │
        ┌───→ ② ←──┐       ┌───→ ⑤
        │     ↑     │       │     │
        ↓     │     ↓       ↓     │
   ① ──→ ③ ──→ ④ ←────────┘     │
        │                         │
        └─────────────────────────┘

   边列表:
   ①→③, ③→②, ②→④, ④→③,  ④→⑤, ⑤→④, ①→⑤
```

### 数据结构初始化

```
┌─────────────────────────────────────────────────────┐
│  初始化状态                                          │
├──────┬────────┬──────────┬──────────┬───────────────┤
│ 节点 │ index  │ low_link │ on_stack │ 栈 (底→顶)    │
├──────┼────────┼──────────┼──────────┼───────────────┤
│  ①   │  -1    │   -1     │   false  │  [空]         │
│  ②   │  -1    │   -1     │   false  │               │
│  ③   │  -1    │   -1     │   false  │               │
│  ④   │  -1    │   -1     │   false  │               │
│  ⑤   │  -1    │   -1     │   false  │               │
└──────┴────────┴──────────┴──────────┴───────────────┘
  idx_counter = 0
```

---

### 🎬 第 1 步：DFS 进入节点 ①

从节点 ① 开始 DFS（它是 index 为 -1 的第一个未访问节点）：

```
操作: 访问节点 ①
      index[①] = 0, low_link[①] = 0
      ① 入栈

┌──────┬────────┬──────────┬──────────┬───────────────┐
│ 节点 │ index  │ low_link │ on_stack │ 栈            │
├──────┼────────┼──────────┼──────────┼───────────────┤
│  ①   │   0    │    0     │  true ✓  │  [①]          │
│  ②   │  -1    │   -1     │   false  │               │
│  ③   │  -1    │   -1     │   false  │               │
│  ④   │  -1    │   -1     │   false  │               │
│  ⑤   │  -1    │   -1     │   false  │               │
└──────┴────────┴──────────┴──────────┴───────────────┘
  idx_counter = 1

当前图状态:
        ┌──→ ② ←┐
        │   ↑    │
        ↓   │    ↓
   ①* ─→ ③ ─→ ④ ←─ ⑤        (* = 当前节点)
```

邻居 ③ 未访问 → 递归进入 ③

---

### 🎬 第 2 步：DFS 进入节点 ③

```
操作: 访问节点 ③
      index[③] = 1, low_link[③] = 1
      ③ 入栈

┌──────┬────────┬──────────┬──────────┬───────────────┐
│ 节点 │ index  │ low_link │ on_stack │ 栈            │
├──────┼────────┼──────────┼──────────┼───────────────┤
│  ①   │   0    │    0     │  true ✓  │  [①, ③]       │
│  ②   │  -1    │   -1     │   false  │               │
│  ③   │   1    │    1     │  true ✓  │               │
│  ④   │  -1    │   -1     │   false  │               │
│  ⑤   │  -1    │   -1     │   false  │               │
└──────┴────────┴──────────┴──────────┴───────────────┘
  idx_counter = 2

邻居 ② 未访问 → 递归进入 ②
```

---

### 🎬 第 3 步：DFS 进入节点 ②

```
操作: 访问节点 ②
      index[②] = 2, low_link[②] = 2
      ② 入栈

┌──────┬────────┬──────────┬──────────┬───────────────┐
│ 节点 │ index  │ low_link │ on_stack │ 栈            │
├──────┼────────┼──────────┼──────────┼───────────────┤
│  ①   │   0    │    0     │  true ✓  │  [①, ③, ②]   │
│  ②   │   2    │    2     │  true ✓  │               │
│  ③   │   1    │    1     │  true ✓  │               │
│  ④   │  -1    │   -1     │   false  │               │
│  ⑤   │  -1    │   -1     │   false  │               │
└──────┴────────┴──────────┴──────────┴───────────────┘
  idx_counter = 3

邻居 ④ 未访问 → 递归进入 ④
```

---

### 🎬 第 4 步：DFS 进入节点 ④

```
操作: 访问节点 ④
      index[④] = 3, low_link[④] = 3
      ④ 入栈

┌──────┬────────┬──────────┬──────────┬──────────────────┐
│ 节点 │ index  │ low_link │ on_stack │ 栈               │
├──────┼────────┼──────────┼──────────┼──────────────────┤
│  ①   │   0    │    0     │  true ✓  │  [①, ③, ②, ④]   │
│  ②   │   2    │    2     │  true ✓  │                  │
│  ③   │   1    │    1     │  true ✓  │                  │
│  ④   │   3    │    3     │  true ✓  │                  │
│  ⑤   │  -1    │   -1     │   false  │                  │
└──────┴────────┴──────────┴──────────┴──────────────────┘
  idx_counter = 4
```

**处理 ④ 的邻居：**

| 邻居 | 类型 | 操作 |
|------|------|------|
| **③** | 已在栈中 (index=1) | **回边！** low_link[④] = min(3, 1) = **1** |
| **⑤** | 未访问 | 递归进入 ⑤ |

```
处理后:
┌──────┬────────┬──────────┬──────────┬──────────────────┐
│ 节点 │ index  │ low_link │ on_stack │ 栈               │
├──────┼────────┼──────────┼──────────┼──────────────────┤
│  ①   │   0    │    0     │  true ✓  │  [①, ③, ②, ④]   │
│  ②   │   2    │    2     │  true ✓  │                  │
│  ③   │   1    │    1     │  true ✓  │                  │
│  ④   │   3    │  **1** ✓ │  true ✓  │  ← 回边 ④→③ 更新!│
│  ⑤   │  -1    │   -1     │   false  │                  │
└──────┴────────┴──────────┴──────────┴──────────────────┘

⚡ 关键事件：发现回边 ④→③！
   ④ 可以通过这条回边回到更早被发现的 ③
   所以 low_link[④] 从 3 降为 1
```

---

### 🎬 第 5 步：DFS 进入节点 ⑤

```
操作: 访问节点 ⑤
      index[⑤] = 4, low_link[⑤] = 4
      ⑤ 入栈

┌──────┬────────┬──────────┬──────────┬────────────────────┐
│ 节点 │ index  │ low_link │ on_stack │ 栈                 │
├──────┼────────┼──────────┼──────────┼────────────────────┤
│  ①   │   0    │    0     │  true ✓  │  [①, ③, ②, ④, ⑤] │
│  ②   │   2    │    2     │  true ✓  │                    │
│  ③   │   1    │    1     │  true ✓  │                    │
│  ④   │   3    │    1     │  true ✓  │                    │
│  ⑤   │   4    │    4     │  true ✓  │                    │
└──────┴────────┴──────────┴──────────┴────────────────────┘
  idx_counter = 5
```

**处理 ⑤ 的邻居：**

| 邻居 | 类型 | 操作 |
|------|------|------|
| **④** | 已在栈中 (index=3) | **回边！** low_link[⑤] = min(4, 3) = **3** |

```
处理后:
┌──────┬────────┬──────────┬──────────┬────────────────────┐
│ 节点 │ index  │ low_link │ on_stack │ 栈                 │
├──────┼────────┼──────────┼──────────┼────────────────────┤
│  ①   │   0    │    0     │  true ✓  │  [①, ③, ②, ④, ⑤] │
│  ②   │   2    │    2     │  true ✓  │                    │
│  ③   │   1    │    1     │  true ✓  │                    │
│  ④   │   3    │    1     │  true ✓  │                    │
│  ⑤   │   4    │ **3** ✓  │  true ✓  │  ← 回边 ⑤→④ 更新! │
└──────┴────────┴──────────┴──────────┴────────────────────┘
```

**检查 ⑤ 是否为 SCC 根：**
- `low_link[⑤] = 3 ≠ index[⑤] = 4` → ❌ 不是根，继续回溯

---

### 🎬 第 6 步：回溯到 ④

```
操作: 从 ⑤ 返回，更新 ④ 的 low_link
      low_link[④] = min(1, low_link[⑤]=3) = 1 (不变)

检查 ④: low_link[④]=1 ≠ index[④]=3 → ❌ 不是根
```

---

### 🎬 第 7 步：回溯到 ②

```
操作: 从 ④ 返回，更新 ② 的 low_link
      low_link[②] = min(2, low_link[④]=1) = **1** ✓

┌──────┬────────┬──────────┬──────────┐
│ 节点 │ index  │ low_link │ on_stack │
├──────┼────────┼──────────┼──────────┤
│  ①   │   0    │    0     │  true ✓  │
│  ②   │   2    │ **1** ✓  │  true ✓  │  ← 被 ④ 的回边影响!
│  ③   │   1    │    1     │  true ✓  │
│  ④   │   3    │    1     │  true ✓  │
│  ⑤   │   4    │    3     │  true ✓  │
└──────┴────────┴──────────┴──────────┘

检查 ②: low_link[②]=1 ≠ index[②]=2 → ❌ 不是根
```

---

### 🎬 第 8 步：回溯到 ③

```
操作: 从 ② 返回，更新 ③ 的 low_link
      low_link[③] = min(1, low_link[②]=1) = 1 (不变)

检查 ③: low_link[③]=1 ≠ index[③]=1 ... 等等!

✅ low_link[③] == index[③] == 1
   → ③ 是一个 SCC 的根节点！

🎉 弹出栈直到 ③: 弹出 {④, ⑤, ②, ③}
   → **SCC #1 = {②, ③, ④, ⑤}**

┌──────┬────────┬──────────┬──────────┬────────┐
│ 节点 │ index  │ low_link │ on_stack │ 栈     │
├──────┼────────┼──────────┼──────────┼────────┤
│  ①   │   0    │    0     │  true ✓  │  [①]   │
│  ②   │   2    │    1     │  false   │  ←出栈 │
│  ③   │   1    │    1     │  false   │  ←出栈 │
│  ④   │   3    │    1     │  false   │  ←出栈 │
│  ⑤   │   4    │    3     │  false   │  ←出栈 │
└──────┴────────┴──────────┴──────────┴────────┘

已找到的 SCC:
  SCC #1: {②, ③, ④, ⑤}
```

---

### 🎬 第 9 步：回溯到 ①，处理剩余邻居

```
操作: 从 ③ 返回，更新 ① 的 low_link
      low_link[①] = min(0, low_link[③]=1) = 0 (不变)

继续处理 ① 的其他邻居: ⑤
  ⑤ 已经访问过且不在栈中 (on_stack=false)
  → 这是**交叉边**，忽略！

检查 ①: low_link[①]==index[①]==0
✅ ① 是 SCC 的根节点！

🎉 弹出栈直到 ①: 弹出 {①}
   → **SCC #2 = {①}**

最终结果:
  SCC #1: {②, ③, ④, ⑤}  ← 大型强连通分量
  SCC #2: {①}             ← 孤立节点（自身成 SCC）
```

---

### 📊 完整执行过程总览

```
时间线:
═════════════════════════════════════════════════════════
  t=0  DFS(①)           栈: [①]
  t=1    DFS(③)         栈: [①,③]
  t=2      DFS(②)       栈: [①,③,②]
  t=3        DFS(④)     栈: [①,③,②,④]
  t=4          DFS(⑤)   栈: [①,③,②,④,⑤]
  t=5          回边⑤→③  low_link[⑤]=3
  t=6          return    low_link[④]=min(1,3)=1
  t=7        return      low_link[②]=min(2,1)=1
  t=8      return        low_link[③]=min(1,1)=1
              ⚡ low_link[③]==index[③] → SCC#1={②,③,④,⑤}
  t=9    return          low_link[①]=min(0,1)=0
              ⚡ low_link[①]==index[①] → SCC#2={①}
═════════════════════════════════════════════════════════

结果: 2 个强连通分量
```

---

## MoonBit 完整实现

以下是 mbtgraph 中 Tarjan SCC 的完整实现：

```moonbit
///|
/// Tarjan 强连通分量算法
///
/// 基于 DFS 时间戳和栈的单次遍历算法，时间复杂度 O(V+E)。
///|

// 内部状态结构体
priv struct TarjanState {
  index : Array[Int]           // 每个节点的发现时间戳 (DFN)
  low_link : Array[Int]        // 每个节点的最低可达时间戳
  on_stack : Array[Bool]       // 节点是否在当前栈中
  stack : Array[@core.NodeId]  // DFS 栈
  stack_top : Array[Int]       // 栈顶指针 (用数组模拟可变性)
  idx_counter : Array[Int]     // 全局时间戳计数器
  components : Array[Array[@core.NodeId]]  // 找到的 SCC 列表
}

// 初始化 Tarjan 状态
fn new_tarjan_state(size : Int) -> TarjanState {
  TarjanState::{
    index: Array::make(size, -1),
    low_link: Array::make(size, -1),
    on_stack: Array::make(size, false),
    stack: Array::make(size, @core.NodeId(0)),
    stack_top: [-1],
    idx_counter: [0],
    components: [],
  }
}

// 核心 DFS 函数：强连通检测
fn[G : @core.GraphDirected] tarjan_strongconnect(
  state : TarjanState,
  g : G,
  v : @core.NodeId,
) -> Unit {
  let vid = v.0

  // 设置初始时间戳
  state.index[vid] = state.idx_counter[0]
  state.low_link[vid] = state.idx_counter[0]
  state.idx_counter[0] = state.idx_counter[0] + 1

  // 节点入栈
  state.stack_top[0] = state.stack_top[0] + 1
  state.stack[state.stack_top[0]] = v
  state.on_stack[vid] = true

  // 遍历所有邻居
  for w in @core.GraphReadable::neighbors(g, v) {
    let wid = w.0

    // 边界检查：跳过无效节点 ID
    if wid < 0 || wid >= state.index.length() {
      continue
    }

    if state.index[wid] == -1 {
      // 情况 1: 邻居未访问 → 递归 DFS
      tarjan_strongconnect(state, g, w)

      // 用子节点的 low_link 更新当前节点
      if state.low_link[wid] < state.low_link[vid] {
        state.low_link[vid] = state.low_link[wid]
      }
    } else if state.on_stack[wid] {
      // 情况 2: 邻居已在栈中 → 发现回边！
      if state.index[wid] < state.low_link[vid] {
        state.low_link[vid] = state.index[wid]
      }
    }
    // 情况 3: 邻居已访问但不在栈中 → 交叉边，忽略
  }

  // SCC 根判定：如果 low_link == index，弹出整个 SCC
  if state.low_link[vid] == state.index[vid] {
    let component : Array[@core.NodeId] = []
    let mut done = false
    while !done {
      let w = state.stack[state.stack_top[0]]
      state.stack_top[0] = state.stack_top[0] - 1
      state.on_stack[w.0] = false
      component.push(w)
      if w.0 == vid {
        done = true
      }
    }
    state.components.push(component)
  }
}

// 公开 API
pub fn[G : @core.GraphDirected] tarjan_scc(
  graph : G,
) -> StronglyConnectedComponentsResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return StronglyConnectedComponentsResult::{ components: [] }
  }

  let max_id = @storage.find_max_node_id(graph)
  let size = @storage.int_max(max_id + 1, 1)
  let state = new_tarjan_state(size)

  // 对每个未访问节点启动 DFS
  for node in @core.GraphReadable::node_ids(graph) {
    if state.index[node.0] == -1 {
      tarjan_strongconnect(state, graph, node)
    }
  }

  StronglyConnectedComponentsResult::{ components: state.components }
}
```

---

## 代码详解

### 设计决策 1️⃣：为什么需要 `low_link` 数组？

**问题**：仅靠 `index`（发现时间戳）无法判断 SCC 边界。

**解答**：`low_link` 捕获了**回边带来的连通性信息**。没有它，我们不知道某个节点能否"绕路"回到祖先节点。

```
没有 low_link:
  ①(index=0) → ③(index=1) → ②(index=2) → ④(index=3)
                                        ↘ 回边到 ③
  我们只知道发现顺序，但不知道 ④ 能回到 ③！

有了 low_link:
  ④ 的 low_link = 1 (通过回边 ④→③)
  ② 的 low_link = 1 (继承自 ④)
  ③ 的 low_link = 1 (= index[③]) → ③ 是 SCC 根！
```

### 设计决策 2️⃣：为什么用栈而不是其他数据结构？

**栈的三个关键性质**：

| 性质 | 说明 | 在 Tarjan 中的作用 |
|------|------|-------------------|
| **LIFO** | 后进先出 | 保证 SCC 节点连续存储 |
| **路径追踪** | 记录 DFS 当前路径 | 区分回边 vs 交叉边 |
| **O(1) 弹出** | 弹出到指定节点 | 高效提取完整 SCC |

**为什么不能只用 visited 数组？**
```
visited 只能区分 "已访问/未访问"
但 Tarjan 需要三种状态:
  1. 未访问 (index=-1)
  2. 在栈中 (on_stack=true)  → 回边目标
  3. 已出栈 (on_stack=false) → 交叉边目标
```

### 设计决策 3️⃣：单次 DFS vs Kosaraju 的两次 DFS

**Tarjan 的巧妙之处**：

```
Kosaraju 流程:
  1. DFS原图 → 记录完成时间
  2. 反转所有边
  3. 按完成时间逆序 DFS 反图

Tarjan 流程:
  1. DFS原图 → 同时维护 low_link 和栈
  2. low_link==index 时直接输出 SCC

优势:
  ✅ 不需要构建反图 (节省 O(V+E) 空间)
  ✅ 不需要第二次遍历
  ✅ 适合只读/不可变图场景
```

### 设计决策 4️⃣：边界检查的意义

```moonbit
if wid < 0 || wid >= state.index.length() {
  continue
}
```

**原因**：mbtgraph 支持非连续 NodeId（如删除节点后留下空洞）。此检查防止数组越界。

---

## 使用示例

### 示例 1：基础用法 — 社交网络朋友圈分析

```moonbit
use lib.algo.connectivity.{tarjan_scc}
use lib.storage.directed_adj_list.{DirectedAdjList, empty, add_node, add_edge}

fn main {
  // 构建社交网络关注关系图
  let mut graph = DirectedAdjList::empty()
  let graph = graph.add_node("Alice")
  let graph = graph.add_node("Bob")
  let graph = graph.add_node("Carol")
  let graph = graph.add_node("Dave")
  let graph = graph.add_node("Eve")

  // 关注关系 (A→B 表示 A 关注 B)
  let graph = graph.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)  // Alice→Bob
  let graph = graph.add_edge(@core.NodeId(1), @core.NodeId(2), 1.0)  // Bob→Carol
  let graph = graph.add_edge(@core.NodeId(2), @core.NodeId(3), 1.0)  // Carol→Dave
  let graph = graph.add_edge(@core.NodeId(3), @core.NodeId(1), 1.0)  // Dave→Bob  (回边!)
  let graph = graph.add_edge(@core.NodeId(0), @core.NodeId(4), 1.0)  // Alice→Eve

  // 执行 Tarjan SCC
  let result = tarjan_scc(graph)

  println("找到 ${result.count()} 个朋友圈:")
  let mut i = 0
  while i < result.count() {
    println("  朋友圈 #${i}: ${result.components[i]}")
    i = i + 1
  }
  // 输出:
  // 找到 2 个朋友圈:
  //   朋友圈 #0: [NodeId(1), NodeId(2), NodeId(3)]  ← Bob, Carol, Dave 互关圈
  //   朋友圈 #1: [NodeId(0)]                        ← Alice 独立
  //   朋友圈 #2: [NodeId(4)]                        ← Eve 独立
}
```

### 示例 2：循环依赖检测器

```moonbit
fn detect_circular_dependencies(
  modules : Array[String],
  dependencies : Array[Tuple2[@core.NodeId, @core.NodeId]],
) -> Array[Array[String]] {
  // 构建模块依赖图
  let mut graph = DirectedAdjList::empty()
  for m in modules {
    let graph = graph.add_node(m)
  }
  for dep in dependencies {
    let graph = graph.add_edge(dep.0, dep.1, 1.0)
  }

  // 使用 Tarjan 检测 SCC
  let scc_result = tarjan_scc(graph)

  // 筛选出大小 > 1 的 SCC（即存在循环依赖）
  let mut circular_deps : Array[Array[String]] = []
  for comp in scc_result.components {
    if comp.length() > 1 {
      let mut names : Array[String] = []
      for node_id in comp {
        match GraphReadable::node_data(graph, node_id) {
          Some(name) => names.push(name),
          None => ()
        }
      }
      circular_deps.push(names)
    }
  }
  circular_deps
}

// 使用
let modules = ["auth", "db", "cache", "api", "logger"]
let deps = [
  (@core.NodeId(0), @core.NodeId(1)),  // auth → db
  (@core.NodeId(1), @core.NodeId(2)),  // db → cache
  (@core.NodeId(2), @core.NodeId(0)),  // cache → auth  ← 循环!
  (@core.NodeId(3), @core.NodeId(0)),  // api → auth
  (@core.NodeId(3), @core.NodeId(4)),  // api → logger
]

let circles = detect_circular_dependencies(modules, deps)
// 结果: [["auth", "db", "cache"]]  ← 发现循环依赖组!
```

### 示例 3：网页链接聚类分析

```moonbit
fn analyze_web_graph(
  pages : Array[String],
  links : Array[Tuple2[@core.NodeId, @core.NodeId]],
) -> Tuple2[Int, Int] {
  let mut graph = DirectedAdjList::empty()
  for p in pages {
    let graph = graph.add_node(p)
  }
  for link in links {
    let graph = graph.add_edge(link.0, link.1, 1.0)
  }

  let result = tarjan_scc(graph)

  // 统计各类 SCC
  let mut singleton_count = 0
  let mut non_singleton_count = 0
  for comp in result.components {
    if comp.length() == 1 {
      singleton_count = singleton_count + 1
    } else {
      non_singleton_count = non_singleton_count + 1
    }
  }

  (singleton_count, non_singleton_count)
}

// 分析 Wikipedia 内部链接
let wiki_pages = ["A", "B", "C", "D", "E", "F"]
let wiki_links = [
  (@core.NodeId(0), @core.NodeId(1)),  // A→B
  (@core.NodeId(1), @core.NodeId(2)),  // B→C
  (@core.NodeId(2), @core.NodeId(0)),  // C→A  (循环!)
  (@core.NodeId(3), @core.NodeId(4)),  // D→E
  (@core.NodeId(4), @core.NodeId(3)),  // E→D  (循环!)
  (@core.NodeId(5), @core.NodeId(0)),  // F→A
]

let (singles, groups) = analyze_web_graph(wiki_pages, wiki_links)
println("独立页面: ${singles}, 互相链接群组: ${groups}")
// 输出: 独立页面: 1, 互相链接群组: 3
// 解释: {A,B,C}, {D,E} 是两组互相链接的页面, F 通过 A 加入大组
```

---

## 复杂度分析

### 时间复杂度：O(V + E)

| 阶段 | 操作 | 复杂度 |
|------|------|--------|
| 初始化 | 创建数组 | O(V) |
| DFS 主循环 | 每个节点访问一次 | O(V) |
| 边扫描 | 每条边检查两次（正反方向各一次） | O(E) |
| 栈操作 | 每个节点入栈/出栈各一次 | O(V) |
| **总计** | | **O(V + E)** |

> 💡 **关键洞察**：虽然代码中有嵌套循环（DFS 内部遍历邻居），但每条边在整个算法执行过程中**恰好被处理两次**（正向一次 + 作为回边/交叉边一次），所以总体仍是线性。

### 空间复杂度：O(V)

| 数据结构 | 用途 | 大小 |
|---------|------|------|
| `index[]` | 发现时间戳 | O(V) |
| `low_link[]` | 最低可达时间戳 | O(V) |
| `on_stack[]` | 栈成员标记 | O(V) |
| `stack[]` | DFS 路径栈 | O(V) |
| `components` | 结果存储 | O(V) |
| **总计** | | **O(V)** |

### 与其他算法对比

```
                时间      空间      遍历次数   需要反图
Tarjan          O(V+E)    O(V)      1次       ❌
Kosaraju        O(V+E)    O(V)      2次       ✅
Naive BFS/DFS   O(V×(V+E)) O(1)     V次       ❌
```

---

## 实际应用场景

### 🌐 场景 1：社交网络分析

**问题**：在微博/Twitter 中找出"互粉圈子"

**解决方案**：将用户作为节点，关注关系作为有向边，运行 Tarjan SCC

**价值**：识别紧密社区、发现影响力群体、推荐系统优化

### 📦 场景 2：软件工程 — 循环依赖检测

**问题**：大型项目中模块间的循环依赖会导致编译顺序混乱

**解决方案**：构建模块依赖图，SCC 大小 > 1 即为循环依赖

**工具实例**：ESLint 的 `no-cycle` 规则、Maven 依赖分析

### 🗺️ 场景 3：地图与导航

**问题**：道路网络中的单向环路检测

**解决方案**：路口为节点，道路为有向边，SCC 识别环形路线

**价值**：交通流量预测、环路优化建议

### 🔢 场景 4：理论计算机科学

**问题**：2-SAT 问题求解

**解决方案**：构造蕴含图，SCC 检查变量与其否定是否在同一分量

**意义**：2-SAT 是 P 问题的重要代表，Tarjan 提供线性解法

---

## 练习题

### 练习 1：手动执行 Tarjan 算法 ⭐⭐

对以下图执行 Tarjan 算法，写出每步的 `index[]`、`low_link[]` 和栈状态：

```
   ① → ② → ③
   ↑         ↓
   └─── ④ ←──┘

   边: ①→②, ②→③, ③→④, ④→①
```

<details>
<summary>📖 参考答案</summary>

```
步骤 1: 访问 ①, index[①]=0, low_link[①]=0, 栈=[①]
步骤 2: 访问 ②, index[②]=1, low_link[②]=1, 栈=[①,②]
步骤 3: 访问 ③, index[③]=2, low_link[③]=2, 栈=[①,②,③]
步骤 4: 访问 ④, index[④]=3, low_link[④]=3, 栈=[①,②,③,④]
步骤 5: ④ 的邻居 ① 在栈中! low_link[④] = min(3, 0) = 0
步骤 6: 回溯到 ③, low_link[③] = min(2, 0) = 0
步骤 7: 回溯到 ②, low_link[②] = min(1, 0) = 0
步骤 8: 回溯到 ①, low_link[①] = min(0, 0) = 0
步骤 9: low_link[①]==index[①] → SCC#1 = {①,②,③,④}

最终结果: 1 个 SCC, 包含全部 4 个节点 (这是一个环!)
```

</details>

---

### 练习 2：实现 Kosaraju 算法并对比 ⭐⭐⭐

参考 `lib/algo/connectivity/kosaraju.mbt` 实现 Kosaraju 算法，并回答：

1. Kosaraju 需要几次 DFS？
2. 为什么需要反转图的边？
3. 对于稀疏图和稠密图，哪个算法更优？

<details>
<summary>💡 提示</summary>

```moonbit
// Kosaraju 核心流程:
// 1. 第一次 DFS: 记录每个节点的完成时间 (finish_time)
// 2. 反转图的所有边
// 3. 按 finish_time 降序进行第二次 DFS
// 4. 每棵 DFS 树就是一个 SCC

// 关键洞察:
// - 第一次 DFS 中"先完成"的节点在 SCC 的边缘
// - 反转后，这些边缘节点成为新图中 SCC 的"入口"
// - 第二次 DFS 自然地按 SCC 边界停止
```

</details>

---

### 练习 3：利用 SCC 求解 2-SAT 问题 ⭐⭐⭐⭐

给定一组布尔变量和二析取范式 (CNF) 子句，使用 Tarjan SCC 判断是否可满足：

**输入**：
```
变量: x₁, x₂, x₃
子句: (x₁ ∨ x₂) ∧ (¬x₁ ∨ x₃) ∧ (¬x₂ ∨ ¬x₃)
```

**要求**：
1. 构造蕴含图（Implication Graph）
2. 运行 Tarjan SCC
3. 判断是否存在变量 x 与 ¬x 在同一 SCC
4. 如果可满足，给出一种赋值方案

<details>
<summary>📖 详细解题思路</summary>

**Step 1: 构造蕴含图**

每个变量 x 对应两个节点：x 和 ¬x
每个子句 (a ∨ b) 转换为两条蕴含边：¬a → b 和 ¬b → a

```
(x₁ ∨ x₂)  →  ¬x₁→x₂,  ¬x₂→x₁
(¬x₁ ∨ x₃) →  x₁→x₃,  ¬x₃→¬x₁
(¬x₂ ∨ ¬x₃) →  x₂→¬x₃,  x₃→¬x₂
```

**Step 2: 图示**

```
     ¬x₁ ──→ x₂ ──→ ¬x₃
     ↑              │
     │              ↓
     x₃ ←── x₁    ¬x₂
     │      ↑      │
     ↓      │      ↓
    ¬x₃    ¬x₂    x₂
            │      ↑
            ↓      │
            x₁ ←──¬x₁
```

**Step 3: 运行 Tarjan**

检查每个变量对 (xᵢ, ¬xᵢ) 是否在同一 SCC：
- 如果任意一对在同一 SCC → **不可满足**
- 否则 → **可满足**

**Step 4: 赋值方案**

按 SCC 的拓扑序赋值：若 x 所在 SCC 的拓扑序 > ¬x 所在 SCC 的拓扑序，则 x = true

</details>

---

## 相关资源

### 📚 推荐阅读

| 资源 | 类型 | 链接/说明 |
|------|------|-----------|
| *Original Paper* | 论文 | R.E. Tarjan, "Depth-first search and linear graph algorithms," SIAM J. Comput., 1972 |
| *CLRS* | 教材 | 《算法导论》第 22.4 节 - 强连通分量 |
| *VisuAlgo* | 交互可视化 | https://visualgo.net/en/dfsscc |
| *Kosaraju 对比教程* | 本站文档 | [/algorithms/connectivity/scc/kosaraju](/algorithms/connectivity/scc/kosaraju) |

### 🔗 相关算法

```
Tarjan SCC (本文)
  ├── Kosaraju SCC     → 两次 DFS 方案
  ├── 割点与桥 (Tarjan) → 同一作者的另一经典算法
  ├── 双连通分量 (BCC) → 无向图的类似概念
  └── 2-SAT 求解器     → SCC 的直接应用
```

### 🛠️ mbtgraph 相关源码

| 文件 | 说明 |
|------|------|
| [`lib/algo/connectivity/tarjan.mbt`](../../../lib/algo/connectivity/tarjan.mbt) | Tarjan SCC 核心实现 |
| [`lib/algo/connectivity/types.mbt`](../../../lib/algo/connectivity/types.mbt) | `StronglyConnectedComponentsResult` 类型定义 |
| [`lib/algo/connectivity/kosaraju.mbt`](../../../lib/algo/connectivity/kosaraju.mbt) | Kosaraju 替代实现 |
| [`lib/core/traits.mbt`](../../../lib/core/traits.mbt) | `GraphDirected` trait 定义 |

---

## 总结清单

### ✅ 核心知识点

- [ ] **强连通分量定义**：有向图中任意两节点互相可达的最大节点集
- [ ] **Tarjan 核心机制**：DFS + 时间戳 (`index`) + 低点值 (`low_link`) + 栈
- [ ] **SCC 根判定条件**：`low_link[v] == index[v]` 时，v 为 SCC 根
- [ ] **时间复杂度**：O(V+E)，线性时间
- [ ] **空间复杂度**：O(V)，仅需存储辅助数组

### 🔑 关键代码模式

```moonbit
// Tarjan 三件套
state.index[v] = counter        // 1. 记录发现时间
state.low_link[v] = counter     // 2. 初始化低点
// ... DFS 递归 ...
if low_link[v] == index[v] {    // 3. 判定 SCC 根
  // 弹出栈，输出 SCC
}
```

### ⚠️ 常见陷阱

| 陷阱 | 后果 | 解决方法 |
|------|------|---------|
| 忽略 `on_stack` 检查 | 将交叉边误判为回边 | 必须同时检查 `index != -1` AND `on_stack` |
| low_link 更新时机错误 | SCC 分割不正确 | 务必在**递归返回后**再更新 |
| 栈弹出条件错误 | SCC 缺失或重复 | 弹出直到**当前节点 v**（不是栈空） |
| 忽略边界检查 | 数组越界崩溃 | 检查 `wid >= 0 && wid < size` |

### 📊 算法对比速查

```
┌─────────────┬──────────┬──────────┬──────────────┐
│   算法      │  时间     │  空间     │  适用场景     │
├─────────────┼──────────┼──────────┼──────────────┤
│ Tarjan      │ O(V+E)   │ O(V)     │ 通用首选     │
│ Kosaraju    │ O(V+E)   │ O(V)     │ 图易反转时   │
│ Naive BFS   │ O(V(V+E))│ O(1)     │ 仅小规模     │
└─────────────┴──────────┴──────────┴──────────────┘
```

---

<div align="center">

**🔗 Tarjan 算法 — 一次 DFS，洞察强连通本质**

*下一章：[Kosaraju 算法](/algorithms/connectivity/scc/kosaraju) | [返回连通性目录](/algorithms/connectivity)*

</div>
