---
title: "连通分量 (Connected Components)"
description: "无向图基础连通性分析，DFS/BFS/Union-Find 三种解法，O(V+E) 时间复杂度"
---

# 🔗 连通分量（Connected Components）

> **"想象一个由若干岛屿组成的世界：每个岛屿内部有桥梁相连（可以互相到达），但岛屿之间没有桥梁。每个'岛屿'就是一个连通分量——找出它们就是连通性分析的本质。"**

## 📖 目录

- [算法简介](#算法简介)
- [核心概念](#核心概念)
- [动画演示 — DFS 方式](#动画演示----dfs-方式)
- [动画演示 — Union-Find 方式](#动画演示----union-find-方式)
- [MoonBit 完整实现](#moonbit-完整实现)
- [三种方法对比](#三种方法对比)
- [使用示例](#使用示例)
- [复杂度分析](#复杂度分析)
- [实际应用场景](#实际应用场景)
- [练习题](#练习题)
- [相关资源](#相关资源)
- [总结清单](#总结清单)

---

## 算法简介

### 什么是连通分量？

在**无向图**中，**连通分量（Connected Component, CC）** 是最大的节点子集，其中**任意两个节点之间都存在路径**。

```
        ① ──── ②       ③ ──── ④
        │                 │
        │                 │
        ⑤                ⑥

   连通分量 #1: {①, ②, ⑤}    ← 内部互相可达
   连通分量 #2: {③, ④, ⑥}    ← 内部互相可达

   注意: ① 无法到达 ③ (无路径) → 不同分量
```

### 为什么连通分量是"最基础"的图算法？

```
算法依赖关系树:

图论基础
├── 连通分量 (CC)          ← 你在这里 ★
│   ├── 割点与桥            ← 需要 CC 的概念
│   ├── 双连通分量 (BCC)    ← CC 的进阶
│   ├── 社区检测             ← 加权/有向版 CC
│   └── 图着色              ← 每个 CC 独立着色
│
├── 最短路径
│   └── ...
├── 最小生成树
│   └── 需要 CC 判断连通性
└── 网络流
    └── 需要源汇在同一 CC
```

### 三种经典解法

| 方法 | 思路 | 时间 | 空间 |
|------|------|------|------|
| **DFS** | 深度优先遍历标记 | O(V+E) | O(V) |
| **BFS** | 广度优先遍历标记 | O(V+E) | O(V) |
| **Union-Find** | 逐边合并集合 | O(E·α(V)) ≈ O(E) | O(V) |

---

## 核心概念

### 🌲 DFS 方法

从每个未访问节点出发进行 DFS，能访问到的所有节点构成一个 CC：

```moonbit
for each node v in graph:
  if not visited[v]:
    // 发现一个新的连通分量!
    dfs_collect(v, current_component)
    components.push(current_component)
```

**关键洞察**：DFS 自然地探索一个 CC 的全部范围——因为 CC 定义就是"互相可达"，而 DFS 正好访问所有可达节点。

### 🌊 BFS 方法

与 DFS 完全对称，只是用队列代替栈：

```moonbit
for each node v in graph:
  if not visited[v]:
    bfs_collect(v, current_component)
    components.push(current_component)
```

**DFS vs BFS 对于 CC 的区别**：
- **结果完全相同**！CC 不关心遍历顺序
- DFS 可能更节省内存（递归深度 vs 队列大小）
- BFS 在极深链状图中更安全（避免栈溢出）

### 🔗 Union-Find 方法

与前两者思路完全不同——**按边合并**而非**按点遍历**：

```moonbit
// 初始化: 每个节点自成一个集合
for each node v:
  make_set(v)

// 合并: 每条边的两个端点属于同一 CC
for each edge (u, v):
  union(u, v)

// 收集: 同一代表元的节点属于同一 CC
for each node v:
  root = find(v)
  components[root].push(v)
```

**Union-Find 的独特优势**：
- 可以**增量更新**（动态加边）
- 不需要邻接表/矩阵，只需边列表
- 天然支持**离线查询**（先处理所有询问再回答）

---

## 动画演示 — DFS 方式

<div class="viz-preview-card">
  <iframe src="/visualizations/connected_components/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/connected_components/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 示例图

```
   ① ──── ②       ④ ──── ⑤
   │                 │ ╲
   │                 │  ╲
   ③                ⑥ ──⑦

   节点数: 7, 边数: 6
   预期: 2 个连通分量
```

---

### 🎬 DFS 过程

#### 初始化

```
visited[] = [F, F, F, F, F, F, F]  (①~⑦)
components = []
current_cc = []
counter = 0
```

#### 第 1 个连通分量 — 从 ① 开始

```
Step 1: 访问 ① (未访问)
  visited[①] = T
  current_cc = [①]
  counter = 1

  ① 的邻居: ②, ③

  → DFS 进入 ②
```

```
Step 2: 访问 ② (未访问)
  visited[②] = T
  current_cc = [①, ②]

  ② 的邻居: ①(已访问), 无其他

  → 回溯到 ①
```

```
Step 3: 从 ① 继续, 进入 ③
  visited[③] = T
  current_cc = [①, ②, ③]

  ③ 的邻居: ①(已访问)

  → 回溯到 ①, ① 的邻居全部处理完毕

✅ CC #1 收集完成: {①, ②, ③}
  components.push([①, ②, ③])
  current_cc = []
```

#### 第 2 个连通分量 — 从 ④ 开始（下一个未访问）

```
Step 4: 扫描到 ④ (未访问!)
  → 发现新的连通分量!

  visited[④] = T
  current_cc = [④]

  ④ 的邻居: ⑤, ⑥

  → DFS 进入 ⑤
```

```
Step 5: 访问 ⑤ (未访问)
  visited[⑤] = T
  current_cc = [④, ⑤]

  ⑤ 的邻居: ④(已访问)

  → 回溯到 ④
```

```
Step 6: 从 ④ 继续, 进入 ⑥
  visited[⑥] = T
  current_cc = [④, ⑤, ⑥]

  ⑥ 的邻居: ④(已访问), ⑦

  → DFS 进入 ⑦
```

```
Step 7: 访问 ⑦ (未访问)
  visited[⑦] = T
  current_cc = [④, ⑤, ⑥, ⑦]

  ⑦ 的邻居: ⑤(已访问), ⑥(已访问)

  → 回溯到 ⑥ → 回溯到 ④

✅ CC #2 收集完成: {④, ⑤, ⑥, ⑦}
  components.push([④, ⑤, ⑥, ⑦])
```

#### 结束扫描

```
Step 8: 继续扫描 ⑤~⑦, 全部已访问
  → 算法结束!

最终结果:
  CC #1: {①, ②, ③}
  CC #2: {④, ⑤, ⑥, ⑦}

总计: 2 个连通分量 ✓
```

---

### 📊 DFS 执行时间线

```
═══════════════════════════════════════════════════
           DFS 连通分量检测时间线
═══════════════════════════════════════════════════

  t=1  DFS(①)         入栈, 标记
  t=2    DFS(②)         入栈, 标记, 叶子→回溯
  t=3    DFS(③)         入栈, 标记, 叶子→回溯
  t=4  ① 完成!          CC#1 = {①,②,③} ✅

  t=5  扫描: ②③已访, ④未访 → 新CC!
  t=6  DFS(④)         入栈, 标记
  t=7    DFS(⑤)         入栈, 标记, 叶子→回溯
  t=8    DFS(⑥)         入栈, 标记
  t=9      DFS(⑦)       入栈, 标记, 叶子→回溯
  t=10   ⑥ 完成 → ④ 完成
  t=11  CC#2 = {④,⑤,⑥,⑦} ✅

  t=12 扫描 ⑤~⑦: 全部已访 → 结束

═══════════════════════════════════════════════════
  结果: 2 个连通分量
═══════════════════════════════════════════════════
```

---

## 动画演示 — Union-Find 方式

### 同一示例图

```
   ① ──── ②       ④ ──── ⑤
   │                 │ ╲
   │                 │  ╲
   ③                ⑥ ──⑦
```

### 🎬 Union-Find 过程

#### 初始化

```
parent[] = [0, 1, 2, 3, 4, 5, 6]   (每个节点自成一集)
rank[]   = [0, 0, 0, 0, 0, 0, 0]

边列表: (①,②), (①,③), (④,⑤), (④,⑥), (⑤,⑦), (⑥,⑦)
```

#### 处理每条边

```
Edge 1: (①, ②)
  find(①)=0, find(②)=1 → 不同!
  union(0, 1): parent[1]=0
  parent = [0, 0, 2, 3, 4, 5, 6]


Edge 2: (①, ③)
  find(①)=0, find(③)=2 → 不同!
  union(0, 2): parent[2]=0
  parent = [0, 0, 0, 3, 4, 5, 6]

  → {①,②,③} 已合并为一个集合!


Edge 3: (④, ⑤)
  find(④)=4, find(⑤)=5 → 不同!
  union(4, 5): parent[5]=4
  parent = [0, 0, 0, 3, 4, 4, 6]


Edge 4: (④, ⑥)
  find(④)=4, find(⑥)=6 → 不同!
  union(4, 6): parent[6]=4
  parent = [0, 0, 0, 3, 4, 4, 4]


Edge 5: (⑤, ⑦)
  find(⑤): ⑤→parent[5]=4→parent[4]=4 → root=4
  find(⑦): ⑦→parent[7]=7 → root=7
  不同! union(4, 7): parent[7]=4
  parent = [0, 0, 0, 3, 4, 4, 4, 4]

  → {④,⑤,⑥,⑦} 已合并为另一个集合!


Edge 6: (⑥, ⑦)
  find(⑥): ⑥→4, find(⑦): ⑦→4 → 相同! (root 都是 4)
  → 跳过 (已在同一集合)
```

#### 收集结果

```
find 各节点的根:
  ① → 0    ② → 0    ③ → 0     ← 根=0
  ④ → 4    ⑤ → 4    ⑥ → 4    ⑦ → 4  ← 根=4

按根分组:
  CC #1 (root=0): {①, ②, ③}
  CC #2 (root=4): {④, ⑤, ⑥, ⑦}

✅ 与 DFS 结果一致!
```

---

## MoonBit 完整实现

以下是 mbtgraph 中连通分量的完整实现：

```moonbit
///|
/// 连通分量算法 (DFS 版本)
///
/// 使用深度优先搜索检测无向图的连通分量。
/// 时间复杂度 O(V+E)，空间复杂度 O(V)。

fn[G : @core.GraphReadable] cc_dfs_visit(
  g : G,
  start : @core.NodeId,
  visited : Array[Bool],
  component : Array[@core.NodeId],
) -> Unit {
  let stack : Array[@core.NodeId] = [start]
  visited[start.0] = true
  let mut head = 0

  while head < stack.length() {
    let cur = stack[head]
    component.push(cur)
    head = head + 1

    for nbr in @core.GraphReadable::neighbors(g, cur) {
      if !visited[nbr.0] {
        visited[nbr.0] = true
        stack.push(nbr)
      }
    }
  }
}

pub fn[G : @core.GraphReadable] connected_components(g : G) -> ConnectedComponentsResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return ConnectedComponentsResult::{
      components: [], count: 0, is_connected: false,
      largest_component_size: 0
    }
  }

  let max_id = /* find max node id */
  let size = int_max(max_id + 1, 1)
  let visited : Array[Bool] = Array::make(size, false)
  let result : Array[Array[@core.NodeId]] = []

  for node in @core.GraphReadable::node_ids(g) {
    if !visited[node.0] {
      let component : Array[@core.NodeId] = []
      cc_dfs_visit(g, node, visited, component)
      result.push(component)
    }
  }

  let mut largest = 0
  for comp in result {
    if comp.length() > largest {
      largest = comp.length()
    }
  }

  ConnectedComponentsResult::{
    components: result,
    count: result.length(),
    is_connected: result.length() == 1,
    largest_component_size: largest,
  }
}
```

---

## 代码详解

### 设计决策 1️⃣：为什么使用显式栈 DFS？

```moonbit
// 递归 DFS (概念上简单):
fn dfs_recursive(v) {
  for neighbor in neighbors(v) {
    if !visited[neighbor] {
      dfs_recursive(neighbor)
    }
  }
}

// 显式栈 DFS (mbtgraph 实现):
let stack = [start]
while head < stack.length() {
  cur = stack[head++]   // FIFO = BFS风格, 但这里只做收集
  for nbr in neighbors(cur) {
    if !visited[nbr] {
      visited[nbr] = true
      stack.push(nbr)
    }
  }
}
```

**原因**：MoonBit 对递归深度有限制。对于**链式图**（V 个节点排成一条线），递归深度 = V，可能溢出。显式栈版本对任何图结构都安全。

### 设计决策 2️⃣：为什么 `visited` 在入队时标记？

```moonbit
visited[nbr.0] = true   // 入队时立即标记!
stack.push(nbr)

// vs 出队时标记:
// cur = stack[head++]
// visited[cur] = true   // 出队时才标记
```

**入队标记的优势**：
- 避免同一节点被多次入队（当多个邻居同时发现它时）
- 保证每个节点最多进入队列 **1 次**
- 这也是 BFS 的标准写法

### 设计决策 3️⃣：`ConnectedComponentsResult` 的丰富信息

```moonbit
pub(all) struct ConnectedComponentsResult {
  components : Array[Array[@core.NodeId]]  // 所有分量
  count : Int                               // 分量数量
  is_connected : Bool                       // 是否全连通 (count == 1?)
  largest_component_size : Int              // 最大分量大小
}
```

**设计理由**：调用者通常不仅需要分量列表，还需要快速判断：
- "这个图是连通的吗？" → `is_connected`
- "最大的社区有多大？" → `largest_component_size`
- "有多少个独立集群？" → `count`

一次计算返回所有常用指标，避免重复遍历。

### 设计决策 4️⃣：边界检查与孤立节点

```moonbit
if nc == 0 {
  return empty_result  // 空图: 0 个分量
}
```

**特殊情况处理**：
- **空图**：0 个节点 → 0 个 CC（不是 1 个空 CC）
- **全孤立节点图**：N 个节点 0 条边 → N 个 CC（每个节点自成一分量）
- **单节点图**：1 个节点 → 1 个 CC（`is_connected = true`）

---

## 三种方法对比

### 代码结构对比

```
┌─────────────────────────────────────────────────────┐
│                  DFS / BFS 方法                      │
├─────────────────────────────────────────────────────┤
│                                                     │
│  for v in nodes:                                    │
│    if !visited[v]:                                  │
│      new_component = []                             │
│      traverse(v, new_component)  // DFS 或 BFS      │
│      results.push(new_component)                    │
│                                                     │
│  → 直觉: "遍历到一个新区域就记录下来"               │
│  → 需要邻接表/邻接矩阵                              │
│  → 在线/离线均可                                   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│               Union-Find 方法                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  init: 每个节点自成一集                              │
│  for (u, v) in edges:                               │
│    union(find(u), find(v))                          │
│                                                     │
│  按 find(root) 分组                                 │
│                                                     │
│  → 直觉: "有边就连起来"                             │
│  → 只需边列表, 不需邻接结构                         │
│  → 天然支持动态增量                                 │
└─────────────────────────────────────────────────────┘
```

### 全面对比表

```
┌──────────────────┬──────────────┬──────────────┬────────────────┐
│     特性         │  DFS/BFS      │  Union-Find   │               │
├──────────────────┼──────────────┼──────────────┼────────────────┤
│ 时间复杂度       │ O(V+E)       │ O(E·α(V))    │ UF 略优(常数小)│
│ 空间复杂度       │ O(V)         │ O(V)         │ 相同           │
│ 数据结构需求     │ 邻接表/矩阵   │ 仅边列表      │ UF 更灵活      │
│ 动态增边支持     │ 需重跑       │ ✅ 天然支持   │ UF 胜出       │
│ 分量大小排序     │ 需后处理     │ 需后处理      │ 平局           │
│ 实现复杂度       │ ⭐ 简单       │ ⭐⭐ 中等     │ DFS 更直观    │
│ 并行化潜力       │ 较难         │ 较易          │ UF 胜出       │
│ 适用场景         │ 通用首选     │ 边列表输入    │ 按需选择       │
└──────────────────┴──────────────┴──────────────┴────────────────┘
```

---

## 使用示例

### 示例 1：社交网络社群发现

```moonbit
use lib.algo.connectivity.{connected_components}
use lib.storage.undirected_adj_list.{UndirectedAdjList, empty, add_node, add_edge}

fn main {
  // 构建社交关系图 (朋友关系是无向的)
  let mut graph = UndirectedAdjList::empty()
  let graph = graph.add_node("Alice")     // 0
  let graph = graph.add_node("Bob")       // 1
  let graph = graph.add_node("Carol")     // 2
  let graph = graph.add_node("Dave")      // 3
  let graph = graph.add_node("Eve")       // 4
  let graph = graph.add_node("Frank")     // 5

  // 朋友圈
  let graph = graph.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)  // Alice-Bob
  let graph = graph.add_edge(@core.NodeId(0), @core.NodeId(2), 1.0)  // Alice-Carol
  let graph = graph.add_edge(@core.NodeId(3), @core.NodeId(4), 1.0)  // Dave-Eve
  let graph = graph.add_edge(@core.NodeId(4), @core.NodeId(5), 1.0)  // Eve-Frank

  let result = connected_components(graph)

  println("社群数量: ${result.count}")
  println("是否全连通: ${result.is_connected}")
  println("最大社群规模: ${result.largest_component_size}")

  let mut i = 0
  while i < result.count {
    println("社群 #${i}: ${result.components[i]}")
    i = i + 1
  }
  // 输出:
  // 社群数量: 2
  // 是否全连通: false
  // 最大社群规模: 3
  // 社群 #0: [NodeId(0), NodeId(1), NodeId(2)]   ← Alice圈
  // 社群 #1: [NodeId(3), NodeId(4), NodeId(5)]   ← Dave圈
}
```

### 示例 2：网络分区检测

```moonbit
fn check_network_partition(
  graph : UndirectedAdjList,
) -> String {
  let cc = connected_components(graph)

  if cc.is_connected {
    return "✅ 网络全连通, 无分区"
  }

  let mut report : Array[String] = []
  report.push("⚠️ 网络存在 ${cc.count} 个分区:")

  let mut i = 0
  while i < cc.count {
    let size = cc.components[i].length()
    let status = if size == 1 {
      "🔴 孤立节点"
    } else if size <= 3 {
      "🟡 小型分区"
    } else {
      "🟢 大型分区"
    }
    report.push("  分区 #${i}: ${size} 节点 ${status}")
    i = i + 1
  }

  if cc.largest_component_size < cc.count * 2 {
    report.push("⚠️ 警告: 最大分区过小, 可能存在严重的网络碎片化!")
  }

  report.join("\n")
}
```

### 示例 3：图像区域标记（Connected Components Labeling）

```moonbit
// 将二值图像中的连通区域标记为不同 ID
// 应用: 物体识别、OCR 预处理

fn label_image_regions(
  pixels : Array[Array[Bool]],  // true=前景, false=背景
  width : Int,
  height : Int,
) -> Array[Array[Int?]] {
  // 将像素图转化为图: 每个前景像素是一个节点
  // 上下左右相邻的前景像素之间有边

  let mut graph = UndirectedAdjList::empty()
  let pixel_to_node : Array[Array[Int?]] = []

  // 创建节点
  let mut y = 0
  while y < height {
    let row : Array[Int?] = []
    let mut x = 0
    while x < width {
      if pixels[y][x] {
        let graph = graph.add_node("pixel_${y}_${x}")
        row.push(Some(graph.node_count - 1))
      } else {
        row.push(None)
      }
      x = x + 1
    }
    pixel_to_node.push(row)
    y = y + 1
  }

  // 创建边 (四邻域连接)
  let mut y = 0
  while y < height {
    let mut x = 0
    while x < width {
      match pixel_to_node[y][x] {
        Some(node_id) => {
          // 右邻居
          if x + 1 < width {
            match pixel_to_node[y][x + 1] {
              Some(right_id) => {
                let graph = graph.add_edge(
                  @core.NodeId(node_id),
                  @core.NodeId(right_id),
                  1.0
                )
              }
              None => ()
            }
          }
          // 下邻居
          if y + 1 < height {
            match pixel_to_node[y + 1][x] {
              Some(bottom_id) => {
                let graph = graph.add_edge(
                  @core.NodeId(node_id),
                  @core.NodeId(bottom_id),
                  1.0
                )
              }
              None => ()
            }
          }
        }
        None => ()
      }
      x = x + 1
    }
    y = y + 1
  }

  // 运行连通分量
  let cc_result = connected_components(graph)

  // 构建标签图
  let labels : Array[Array[Int?]] = []
  let mut comp_id = 0
  while comp_id < cc_result.count {
    for node in cc_result.components[comp_id] {
      // 反查像素坐标... (简化: 需要维护反向映射)
    }
    comp_id = comp_id + 1
  }

  labels
}
```

---

## 复杂度分析

### 时间复杂度

| 方法 | 操作 | 复杂度 |
|------|------|--------|
| **DFS/BFS** | 每节点访问 1 次, 每边检查 2 次 | **O(V + E)** |
| **Union-Find** | 每次 union/find 近似 O(α(V)) | **O(E · α(V)) ≈ O(E)** |

> 💡 **α(V)** 是反阿克曼函数，增长极慢：α(10⁶⁰⁰) ≤ 5。实践中可视为 **O(1)**。

### 空间复杂度

| 数据结构 | 用途 | 大小 |
|---------|------|------|
| `visited[]` | 访问标记 | O(V) |
| `stack/queue` | DFS/BFS 辅助 | O(V) |
| `components` | 结果存储 | O(V) |
| **总计 (DFS/BFS)** | | **O(V)** |

| 数据结构 | 用途 | 大小 |
|---------|------|------|
| `parent[]` | UF 父节点 | O(V) |
| `rank[]` | UF 按秩合并 | O(V) |
| **总计 (UF)** | | **O(V)** |

---

## 实际应用场景

### 🌐 场景 1：社交网络社群发现

**问题**：微博/Twitter 中自动识别互相关注的用户群体

**解决方案**：关注关系为边，运行 CC 发现独立的社交圈子

**价值**：精准营销、舆情分析、推荐系统冷启动

### 🗺️ 场景 2：地理信息系统 (GIS)

**问题**：地图上的陆地/水域分离、行政区划连通性检查

**解决方案**：相邻网格单元为边，CC 标识每个独立区域

**实例**：洪水淹没模拟（连通水域区域）、GPS 导航离线地图分割

### 🖼️ 场景 3：计算机视觉

**问题**：二值图像中分离不同的物体/字符

**解决方案**：像素邻接图为输入，CC 标记 = 连通区域标记（CCL）

**实例**：OCR 文字分割、医学图像细胞计数、卫星图像目标提取

### 🎮 场景 4：游戏开发

**问题**：开放世界游戏中动态加载区域划分

**解决方案**：地图格子为节点，传送门/通道为边，CC 确定可步行区域的边界

**实例**：《塞尔达传说》王国之泪的地下迷宫连通性、《Minecraft》矿洞生成验证

---

## 练习题

### 练习 1：手动执行 CC 检测 ⭐⭐

对下图分别用 DFS 和 Union-Find 找出所有连通分量：

```
     ① ──②      ③ ──④ ──⑤
     │              │
     └─⑥           └─⑦
```

<details>
<summary>📖 参考答案</summary>

```
DFS (假设顺序 ①→②→...→⑦):

  CC #1: 从 ① 开始
    ①→②→... ② 只有邻居 ①
    ①→⑥ → 叶子
    → CC#1 = {①, ②, ⑥}

  CC #2: 下一个未访问是 ③
    ③→④→⑤ → ⑤ 叶子
    ③→⑦ → 叶子
    → CC#2 = {③, ④, ⑤, ⑦}

Union-Find:

  边: (①,②), (①,⑥), (③,④), (④,⑤), (③,⑦)

  (①,②): union → {①,②}
  (①,⑥): union → {①,②,⑥}
  (③,④): union → {③,④}
  (④,⑤): union → {③,④,⑤}
  (③,⑦): union → {③,④,⑤,⑦}

  结果: CC#1={①,②,⑥}, CC#2={③,④,⑤,⑦} ✅ 一致!
```

</details>

---

### 练习 2：实现 BFS 版本的连通分量 ⭐⭐

补充以下代码，使用 BFS 替代 DFS：

```moonbit
pub fn[G : @core.GraphReadable] connected_components_bfs(
  g : G,
) -> ConnectedComponentsResult {
  // TODO: 用队列实现 BFS 遍历
  // 提示: 与 DFS 版本几乎相同, 只需将 stack 改为 queue (FIFO)
}
```

<details>
<summary>💡 提示</summary>

```moonbit
pub fn[G : @core.GraphReadable] connected_components_bfs(
  g : G,
) -> ConnectedComponentsResult {
  let nc = @core.GraphReadable::node_count(g)
  // ... 边界检查 ...

  let visited : Array[Bool] = Array::make(size, false)
  let result : Array[Array[@core.NodeId]] = []

  for node in @core.GraphReadable::node_ids(g) {
    if !visited[node.0] {
      let component : Array[@core.NodeId] = []
      let queue : Array[@core.NodeId] = [node]
      visited[node.0] = true
      let mut qhead = 0

      while qhead < queue.length() {
        let cur = queue[qhead]
        component.push(cur)
        qhead = qhead + 1
        for nbr in @core.GraphReadable::neighbors(g, cur) {
          if !visited[nbr.0] {
            visited[nbr.0] = true
            queue.push(nbr)
          }
        }
      }
      result.push(component)
    }
  }
  // ... 构建 result struct ...
}
```

**核心差异**：只有一行——`stack` 改名为 `queue`，语义从 LIFO 变为 FIFO。对于 CC 来说，两种遍历方式的结果完全一致！

</details>

---

### 练习 3：动态连通性维护 ⭐⭐⭐⭐

实现一个支持**动态操作**的连通分量系统：

**操作类型**：
1. `add_node(id)` — 添加节点
2. `add_edge(u, v)` — 添加边
3. `remove_edge(u, v)` — 删除边
4. `query_count()` — 返回当前 CC 数量
5. `query_same(u, v)` — u 和 v 是否在同一 CC

**要求**：
- `add_edge` 后必须正确更新 CC 数量
- `query_*` 操作必须 O(α(V)) 或更快
- 分析 `remove_edge` 的实现难度

<details>
<summary>📖 解题思路</summary>

```moonbit
// 核心选择: Union-Find 是唯一能高效支持动态增边的方案
//
// add_node:   O(1) — 新建集合
// add_edge:   O(α(V)) — union 两个集合 (若在不同集合则 count--)
// query_count: O(1) — 维护一个 counter 变量
// query_same:  O(α(V)) — find(u) == find(v)
//
// remove_edge: ❌ 这是难点!
//   Union-Find 不支持高效的 split/删除操作!
//   解决方案:
//   A) 完全重建: O(V+E) — 删除后从头跑 UF
//   B) Link-Cut Tree: O(log V) — 复杂但完美
//   C) 记录删除日志, 定期重建 — 工程折中

struct DynamicCC {
  uf : UnionFind           // Union-Find 结构
  count : Int              // 当前 CC 数量
  edge_list : Array[(Int, Int)]  // 用于重建
}

fn(DynamicCC self) .add_node(id : Int) -> Unit {
  self.uf.make_set(id)
  self.count = self.count + 1
}

fn(DynamicCC self) .add_edge(u : Int, v : Int) -> Bool {
  self.edge_list.push((u, v))
  if self.uf.find(u) != self.uf.find(v) {
    self.uf.union(u, v)
    self.count = self.count - 1
    true  // 成功合并了两个 CC
  } else {
    false  // 边在 CC 内部, 数量不变
  }
}

fn(DynamicCC self) .remove_edge(_u : Int, _v : Int) -> Unit {
  // ⚠️ Union-Find 不支持高效删除!
  // 只能选择完全重建:
  self.rebuild()
}

fn(DynamicCC self) .rebuild() -> Unit {
  // 重置 UF
  self.uf.reset()
  self.count = self.uf.size()  // 初始: 每个节点一个 CC
  for (u, v) in self.edge_list {
    // 重新添加所有边 (跳过被删的边)
    self.internal_add_edge(u, v)
  }
}
```

**应用场景**：实时网络监控、动态社交图谱、游戏服务器状态同步。

</details>

---

## 相关资源

### 📚 推荐阅读

| 资源 | 类型 | 说明 |
|------|------|------|
| *CLRS* | 教材 | 《算法导论》第 22.3 节 - 连通分量 |
| *Sedgewick* | 教材 | 《算法》(第4版) 图基础章节 |
| *Tarjan 1972* | 论文 | "Depth-first search and linear graph algorithms" (同一篇论文包含 SCC/AP/CC) |
| *割点与桥教程* | 本站文档 | [/algorithms/connectivity/articulation-points](/algorithms/connectivity/articulation-points) (基于 CC 的进阶) |

### 🔗 相关算法

```
连通分量 (本文)
  ├── 强连通分量 (SCC)    → 有向图版本 (Tarjan/Kosaraju)
  ├── 双连通分量 (BCC)    → 删除任一点仍连通
  ├── 割点与桥            → CC 的关键脆弱点
  ├── 社区检测 (Louvain)  → 加权/带方向的扩展
  └── Union-Find 数据结构 → CC 的另一种解法
```

### 🛠️ mbtgraph 相关源码

| 文件 | 说明 |
|------|------|
| [`lib/algo/connectivity/components.mbt`](../../../lib/algo/connectivity/components.mbt) | CC 核心实现 (DFS) |
| [`lib/algo/connectivity/types.mbt`](../../../lib/algo/connectivity/types.mbt) | `ConnectedComponentsResult` 类型定义 |
| [`lib/core/traits.mbt`](../../../lib/core/traits.mbt) | `GraphReadable` trait 定义 |

---

## 总结清单

### ✅ 核心知识点

- [ ] **连通分量定义**：无向图中最大可达节点子集
- [ ] **DFS/BFS 方法**：遍历标记，O(V+E)，需要邻接结构
- [ ] **Union-Find 方法**：按边合并，O(E·α(V))，只需边列表
- [ ] **三种方法的取舍**：通用性 vs 动态性 vs 实现难度
- [ ] **特殊情形**：空图(0 CC)、全孤立(N CC)、单节点(1 CC, connected=true)

### 🔑 关键代码模式

```moonbit
// DFS/BFS 连通分量三件套
for node in all_nodes:
  if !visited[node]:
    new_cc = []
    traverse(node, new_cc)   // DFS 或 BFS
    result.push(new_cc)

// Union-Find 三件套
init_uf()                     // 每个节点独立
for (u, v) in edges:
  union(u, v)                // 有边就合并
group_by_find_root()         // 按根分组
```

### ⚠️ 常见陷阱

| 陷阱 | 后果 | 解决方法 |
|------|------|---------|
| 忽略孤立节点 | CC 数量偏少 | 确保遍历**所有**节点（包括 degree=0） |
| 有向图调用无向版 | 结果语义错误 | 有向图应使用 SCC |
| `visited` 标记时机错 | 节点重复入队 | **入队/入栈时**立即标记 |
| Union-Find 忘记路径压缩 | 退化到 O(V)/次查询 | 始终在 `find` 中执行路径压缩 |
| 混淆 `count` 和 `size` | 语义不清 | `count`=CC 数量, `size`=总节点数 |

### 📊 连通性算法速查

```
┌────────────────┬──────────────┬──────────────┬──────────────────┐
│    问题         │  无向图       │  有向图       │  推荐算法        │
├────────────────┼──────────────┼──────────────┼──────────────────┤
│ 连通分量       │ CC           │ SCC          │ DFS/UF / Tarjan  │
│ 可达性查询     │ CC → O(1)    │ Transitive   │ Floyd-Warshall  │
│               │              │ Closure      │                 │
│ 动态增边       │ Union-Find   │ 难           │ UF / 完全重建    │
│ 动态删边       │ 困难          │ 更难         │ Link-Cut Tree   │
└────────────────┴──────────────┴──────────────┴──────────────────┘
```

---

<div align="center">

**🔗 连通分量 — 图算法的基石，一切由此开始**

*下一篇：[割点与桥](/algorithms/connectivity/articulation-points) | [强连通分量 (SCC)](/algorithms/connectivity/scc/tarjan)*

</div>
