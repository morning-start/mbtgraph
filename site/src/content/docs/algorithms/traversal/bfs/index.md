---
title: 广度优先搜索 (BFS)
description: 图的层级遍历算法详解：原理、动画演示、MoonBit 实现、实战应用
---

# 广度优先搜索 (BFS)

> 🎯 **本节目标**: 掌握 BFS 算法原理、实现步骤、复杂度分析和实际应用
>
> ⏱️ **预计阅读时间**: 25 分钟 | 🎮 **互动演示**: 3 个可运行示例

## 📖 算法简介

**广度优先搜索（Breadth-First Search, BFS）** 是一种用于**逐层遍历或搜索图/树数据结构**的算法。

### 核心思想 💡

想象你在**向水中投入一颗石子**：

```
🌊 第 0 层 (中心):        ● 起点 S
                         │╲ ╱│
🌊 第 1 层 (涟漪):      ●─●─●   ← 距离 S 为 1 步的节点
                       ╱│╲ ╱│╲
🌊 第 2 层 (扩散):    ●─●─●─●─● ← 距离 S 为 2 步的节点
                        ...
```

BFS 就像这圈涟漪一样，**从起点开始，一层一层向外扩展**，先访问所有距离为 1 的节点，再访问距离为 2 的节点，依此类推。

### 为什么叫"广度优先"?

对比两种遍历策略：

| 策略 | 类比 | 访问顺序 | 数据结构 |
|------|------|---------|----------|
| **BFS** 广度优先 | 涟漪扩散 | **横向逐层** | 📦 队列 (Queue) |
| **DFS** 深度优先 | 走迷宫 | **纵向深入** | 📚 栈 (Stack) |

---

## 🎬 交互式动画：BFS 分步执行过程

让我们通过一个具体例子来理解 BFS 的执行流程。**点击 ▶ 播放按钮或使用键盘方向键控制动画！**

### 示例图: 无向简单图

考虑以下无权无向图（6 节点，7 条边）：

**边列表**: `(0,1), (0,4), (0,2), (1,2), (2,4), (2,5), (3,5)`

<div class="viz-preview-card">
  <iframe src="/visualizations/bfs.html" width="100%" height="340" frameborder="0"></iframe>
  <a href="/visualizations/bfs.html" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 动画说明

> **操作指南**: 使用底部控制栏或键盘快捷键操控动画
>
> | 操作 | 按钮 | 快捷键 |
> |------|:----:|:------:|
> | 播放 / 暂停 | ▶ / ⏸ | `Space` |
> | 单步前进 | → | `→` |
> | 单步后退 | ← | `←` |
> | 跳到开始 | ⏮ | `Home` |
> | 跳到末尾 | ⏭ | `End` |
> | 重置 | ↺ | `R` |
> | 调节速度 | 滑块 | — |

**配色含义（VisuAlgo 风格）**:

| 颜色 | 含义 |
|------|------|
| **深棕色** | 起点（节点 0） |
| **橙色** | 正在处理（当前出队节点） |
| **黄色** | 刚发现的新节点 |
| **绿色** | 已处理完毕 |
| **灰色** | 默认未访问状态 |
| **红色粗线** | 树边（首次发现邻居的边） |
| **灰色虚线** | 已跳过的边（邻居已访问） |

### 预期结果

BFS 从节点 0 开始，按层级逐层遍历：

```
访问顺序: [0, 1, 4, 2, 5, 3]
层级分布: L0:[0]  L1:[1,4,2]  L2:[5]  L3:[3]
最短路径: 0→3 = [0, 2, 5, 3] (长度=3)
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/traversal/bfs.mbt`）

```moonbit
///|
/// 单源 BFS：从 start 节点开始遍历
///
/// 时间复杂度: O(V + E)
/// 空间复杂度: O(V)
pub fn[G : @core.GraphReadable] bfs(
  graph : G,
  start : @core.NodeId
) -> BfsResult {
  let nc = @core.GraphReadable::node_count(graph)

  // 边界检查：空图或无效起点
  if nc == 0 || !@core.GraphReadable::contains_node(graph, start) {
    return empty_bfs_result()
  }

  // 初始化数据结构
  let max_id = find_max_node_id(graph)  // 找最大 NodeId 用于数组大小
  let size = max(max_id + 1, 1)

  let visited = Array::make(size, false)   // 访问标记
  let order : Array[@core.NodeId] = []     // 访问顺序
  let parents : Array[@core.NodeId?] = Array::make(size, None)  // 父节点（路径重建用）
  let levels = Array::make(size, -1)      // 层级距离
  let queue : Array[@core.NodeId] = []     // BFS 队列

  // 起点初始化
  visited[start.0] = true
  levels[start.0] = 0                      // 起点层级 = 0
  parents[start.0] = None                  // 起点无父节点
  queue.push(start)                        // 入队

  let mut head = 0                         // 队列头指针（避免 shift() 的 O(n) 开销）

  // 主循环：当队列不为空时继续
  while head < queue.length() {
    let cur = queue[head]                // 取出队首元素
    head = head + 1                     // 头指针后移
    order.push(cur)                     // 记录访问顺序

    // 遍历当前节点的所有邻居
    for nid in @core.GraphReadable::neighbors(graph, cur) {
      let idx = nid.0

      // 边界检查 + 是否已访问
      if idx >= 0 && idx < size && !visited[idx] {
        visited[idx] = true             // 标记为已访问
        parents[idx] = Some(cur)        // 记录父节点
        levels[idx] = levels[cur.0] + 1 // 层级 = 父层级 + 1
        queue.push(nid)                // 入队（等待后续处理）
      }
    }
  }

  // 返回完整结果
  BfsResult::{
    base: TraversalResult::{ visited, order, parents },
    levels: levels,
  }
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么使用 `head` 指针而非 `shift()`？

```moonbit
// ❌ 低效方式: 每次 shift() 需要 O(n) 移动元素
while queue.length() > 0 {
  let cur = queue.shift_unsafe()  // O(n) 操作!
  // ...
}

// ✅ 高效方式: 使用头指针，O(1) 出队
let mut head = 0
while head < queue.length() {
  let cur = queue[head]  // O(1) 直接索引
  head = head + 1
}
```

**性能提升**: 对于 V 个节点的图，从 **O(V²)** 降至 **O(V)**！

#### 2️⃣ 数组大小的确定：`find_max_node_id()`

```moonbit
fn[G : @core.GraphReadable] find_max_node_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m { m = nid.0 }  // 找到最大的整数 ID
  }
  m
}

// 使用场景:
// 如果节点 ID 是 [0, 1, 5, 100]，则 size = 101（而非 4）
// 这样可以直接用 ID 作为数组下标，实现 O(1) 访问
```

> ⚠️ **权衡**: 如果 NodeId 不连续（如删除过节点），会浪费一些空间，但换取了查询速度。

#### 3️⃣ 结果类型的设计

```moonbit
/// BFS 返回结果包含 4 种信息:
pub(all) struct BfsResult {
  base : TraversalResult {  // 基础遍历信息
    visited : Array[Bool],        // 节点是否被访问
    order   : Array[NodeId],      // 访问顺序
    parents : Array[NodeId?],     // 父节点（用于重建路径）
  },
  levels : Array[Int],            // 层级距离（BFS 专属）
}
```

**为什么返回这么多信息？**

| 字段 | 用途 | 示例方法 |
|------|------|----------|
| `visited` | 可达性查询 | `result.is_visited(target)` |
| `order` | 拓扑排序依据 | `result.base.order` |
| `parents` | **最短路径重建** | `result.base.path_to(target)` |
| `levels` | **距离查询** | `result.distance(target)` |

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 遍历并输出层级

```moonbit
fn bfs_basic_demo() -> Unit {
  // 构建示例图（与动画演示相同）
  let g = build_sample_undirected_graph()

  // 执行 BFS
  let result = @traversal.bfs(g, @core.NodeId(0))

  // 输出结果
  println("=== BFS 遍历结果 ===")
  println("访问顺序: ${result.base.order}")
  println("可达节点数: ${result.base.reachable_count()}")

  // 按层级输出
  let max_level = result.levels.iter().max()
  for level in 0..max_level+1 {
    let nodes_at_level : Array[String] = []
    for (i, is_visited) in result.base.visited.indexed() {
      if (is_visited && result.levels[i] == level) {
        nodes_at_level.push(NodeId(i).to_string())
      }
    }
    println("第 ${level} 层: [${nodes_at_level.join(", ")}]")
  }
}

// 输出:
// === BFS 遍历结果 ===
// 访问顺序: [NodeId(0), NodeId(1), NodeId(4), NodeId(2), NodeId(5), NodeId(3)]
// 可达节点数: 6
// 第 0 层: [NodeId(0)]
// 第 1 层: [NodeId(1), NodeId(4), NodeId(2)]
// 第 2 层: [NodeId(5)]
// 第 3 层: [NodeId(3)]
```

### 示例 2: 🔍 最短路径查询（社交网络的"六度分隔"）

```moonbit
/// 查找两个用户之间的最短关系链
fn find_shortest_connection(
  social_graph : DirectedAdjList,
  user_a : String,
  user_b : String,
  name_to_id : Map[String, NodeId],
  id_to_name : Map[NodeId, String]
) -> Unit {
  let id_a = name_to_id.get(user_a).unwrap()
  let id_b = name_to_id.get(user_b).unwrap()

  // 执行 BFS
  let result = @traversal.bfs(social_graph, id_a)

  // 重建最短路径
  let path = result.base.path_to(id_b)

  match path.length() {
    0 => println("${user_a} 和 ${user_b} 之间没有关系路径 😢")
    _ => {
      let distance = path.length() - 1
      println("\n🔗 ${user_a} ↔ ${user_b} 的最短路径:")
      println("   距离: ${distance} 步 (${distance + 1} 人)")

      // 输出路径上的用户名
      let names = path.map(fn(id) { id_to_name.get(id).unwrap_or("?") })
      println("   路径: ${names.join(" → ")}")

      if (distance <= 6) {
        println("   ✅ 符合「六度分隔」理论!")
      } else {
        println("   ⚠️ 超过了六度分隔")
      }
    }
  }
}

// 使用示例
let twitter = build_twitter_network()
find_shortest_connection(twitter, "Alice", "Charlie", name_map, id_map)
// 输出:
// 🔗 Alice ↔ Charlie 的最短路径:
//    距离: 2 步 (3 人)
//    路径: Alice → Bob → Charlie
//    ✅ 符合「六度分隔」理论!
```

### 示例 3: 📊 连通分量分析（多源 BFS）

```moonbit
/// 使用 BFS 分析图的连通性
fn analyze_connectivity_components(graph : UndirectedAdjList) -> Unit {
  // 使用 bfs_all 遍历全图（自动处理多个连通分量）
  let result = @traversal.bfs_all(graph)

  let total_nodes = @core.GraphReadable::node_count(graph)
  let visited_count = result.base.reachable_count()

  println("=== 连通分量分析 ===")
  println("总节点数: ${total_nodes}")
  println("可达节点: ${visited_count}")

  if (visited_count == total_nodes) {
    println("✅ 图是**完全连通**的（只有一个连通分量）")
  } else {
    let components = count_connected_components(result)
    println("⚠️ 图有 ${components} 个**独立的连通分量**")

    // 列出每个分量的代表节点
    println("\n各分量入口节点:")
    // （可以通过 parents == None 的节点识别每个分量的根）
  }
}

/// 从 bfs_all 结果中统计连通分量数量
fn count_connected_components(result : BfsResult) -> Int {
  let mut component_roots : Array[NodeId] = []

  for (i, parent_opt) in result.base.parents.indexed() {
    if (result.base.visited[i]) {
      match parent_opt {
        None => component_roots.push(NodeId(i))  // 根节点（无父节点）
        _ => ()
      }
    }
  }

  component_roots.length()
}
```

---

## 📈 复杂度分析

### 时间复杂度: O(V + E)

| 操作 | 次数 | 复杂度 | 说明 |
|------|------|--------|------|
| 初始化数组 | 1 次 | O(V) | 创建 visited/parents/levels |
| 入队操作 | V 次 | O(1) 每次 | 每个节点恰好入队一次 |
| 出队操作 | V 次 | O(1) 每次 | 每个节点恰好出队一次 |
| 邻居遍历 | 总共 2E 次* | O(E) 总计 | 每条边被检查两次（有向）/ 一次（无向） |
| **总计** | | **O(V + E)** | |

> \* 无向图中每条边存储一次，但在邻接表中会被两端节点各遍历一次。

### 空间复杂度: O(V)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `visited[]` | O(V) | 布尔标记数组 |
| `parents[]` | O(V) | 父节点指针 |
| `levels[]` | O(V) | 层级距离 |
| `queue` | O(V) | 最坏情况所有节点同时在队列中 |
| **总计** | **O(V)** | |

### 与其他算法对比

| 算法 | 时间 | 空间 | 适用场景 |
|------|------|------|----------|
| **BFS** | O(V+E) | O(V) | **无权图最短路径**、层级遍历 |
| DFS | O(V+E) | O(V) | **拓扑排序**、环检测、路径查找 |
| Dijkstra | O((V+E)logV) | O(V) | **非负权重图**最短路径 |
| Bellman-Ford | O(VE) | O(V) | 含**负权边**的最短路径 |

---

## 🎯 实际应用场景

### 应用 1: 社交网络 - "你可能认识的人"

```
问题: 推荐用户可能认识的人（二度好友）

解决思路:
1. 以当前用户 U 为起点执行 BFS
2. 收集所有第 2 层的节点（距离=2 的用户）
3. 过滤掉已经是好友的用户
4. 按共同好友数量排序推荐

时间复杂度: O(V + E) — 非常快，适合实时推荐
```

### 应用 2: 网络爬虫 - 网页抓取

```
问题: 从种子 URL 开始，按广度优先顺序抓取网页

BFS 特性的优势:
✅ 保证优先抓取"离家近"的页面（同域名优先）
✅ 可以限制爬取深度（levels <= max_depth）
✅ 自然形成层次化的 URL 队列

伪代码:
queue = [seed_url]
visited = {seed_url}

while queue not empty:
  url = dequeue(queue)
  if depth[url] > MAX_DEPTH: continue
  
  page = fetch(url)
  for link in extract_links(page):
    if link not in visited:
      visited.add(link)
      enqueue(link)
      depth[link] = depth[url] + 1
```

### 应用 3: 垃圾回收 (GC) - 标记阶段

```
问题: 找出所有从根对象可达的对象（存活对象）

BFS/DFS 都可用于 GC 的标记阶段:
- 起点: 全局变量、栈上的引用
- 遍历: 沿着引用链标记所有可达对象
- 清理: 未标记的对象可被回收

BFS 在 GC 中的优势:
✅ 层级信息有助于优化回收策略（先回收深层对象）
```

### 应用 4: GPS 导航 - 地图搜索

```
问题: 在道路网中找到最近的加油站/餐厅/充电站

解决方案:
1. 将当前位置作为 BFS 起点
2. 逐层扩展（每层 = 1 公里范围）
3. 第一层找到目标即停止（保证最近）

vs Dijkstra:
- BFS: O(V+E)，适用于**无权/等权图**
- Dijkstra: O((V+E)logV)，适用于**有权图**（不同路段长度不同）
```

---

## 🧪 练习题

### 练习 1: 手动执行 BFS ⭐⭐

对于以下有向图，从节点 A 开始执行 BFS，写出：
1. 访问顺序 (Order)
2. 每个节点的层级 (Level)
3. 从 A 到 F 的最短路径

```
  A → B → D
  ↓   ↘   ↓
  C → E → F
```

<details>
<summary>📝 点击查看答案</summary>

```
Order:  [A, B, C, D, E, F]
Level:  L[A]=0, L[B]=1, L[C]=1, L[D]=2, L[E]=2, L[F]=3

A → F 的最短路径: [A, B, D, F] 或 [A, C, E, F] (长度=3)
```

</details>

### 练习 2: 编程实现 - 二叉树层序遍历 ⭐⭐⭐

将以下二叉树转换为图，然后用 BFS 实现层序遍历：

```
      1
     / \
    2   3
   / \   \
  4   5   6
```

期望输出: `[1, 2, 3, 4, 5, 6]`（按层级输出）

<details>
<summary>💻 点击查看解答代码</summary>

```moonbit
fn binary_tree_level_order_traversal() -> Array[Int] {
  // 将二叉树构建为邻接表形式的无向图
  let mut tree = @storage.UndirectedAdjList::new_with_capacity(7, 6)

  // 添加节点（值为节点数据）
  let n1 = @core.GraphWritable::add_node(tree, 1)
  let n2 = @core.GraphWritable::add_node(tree, 2)
  let n3 = @core.GraphWritable::add_node(tree, 3)
  let n4 = @core.GraphWritable::add_node(tree, 4)
  let n5 = @core.GraphWritable::add_node(tree, 5)
  let n6 = @core.GraphWritable::add_node(tree, 6)

  // 添加边（父子关系）
  @core.GraphWritable::add_edge(tree, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(tree, n1, n3, 1.0) |> ignore
  @core.GraphWritable::add_edge(tree, n2, n4, 1.0) |> ignore
  @core.GraphWritable::add_edge(tree, n2, n5, 1.0) |> ignore
  @core.GraphWritable::add_edge(tree, n3, n6, 1.0) |> ignore

  // BFS 遍历
  let result = @traversal.bfs(tree, n1)

  // 提取节点数据（按访问顺序）
  result.base.order.map(fn(node_id) => {
    match @core.GraphReadable::get_node(tree, node_id) {
      Some(data) => data.to_int(),
      None => 0
    }
  })
}

// 测试
let level_order = binary_tree_level_order_traversal()
println("层序遍历结果: ${level_order}")  // [1, 2, 3, 4, 5, 6]
```

</details>

### 练习 3: 进阶 - 双向 BFS 优化 ⭐⭐⭐⭐

**挑战**: 实现双向 BFS（Bi-directional BFS），同时从起点和终点出发，在中间相遇时停止。

**提示**:
- 维护两个队列：`queue_forward` 和 `queue_backward`
- 当某一层的节点被另一方向访问过时，说明找到了最短路径
- 理论上可将时间复杂度降至 **O(2^(d/2))**（d 为最短路径长度）

<details>
<summary>🔧 参考实现框架</summary>

```moonbit
pub fn[G : @core.GraphReadable] bidirectional_bfs(
  graph : G,
  start : NodeId,
  target : NodeId
) -> Int {
  if start == target { return 0 }

  let mut forward_visited : Map[NodeId, Int] = Map::new()
  let mut backward_visited : Map[NodeId, Int] = Map::new()

  forward_visited.insert(start, 0)
  backward_visited.insert(target, 0)

  let mut fwd_queue : Array[NodeId] = [start]
  let mut bwd_queue : Array[NodeId] = [target]

  let mut meeting_node : Option[NodeId] = None

  while fwd_queue.length() > 0 || bwd_queue.length() > 0 {
    // 正向 BFS 一层
    if fwd_queue.length() > 0 && meeting_node.is_none() {
      let new_fwd_queue : Array[NodeId] = []
      for cur in fwd_queue {
        let cur_dist = forward_visited.get(cur).unwrap()
        for nbr in @core.GraphReadable::neighbors(graph, cur) {
          if (backward_visited.contains_key(nbr)) {
            meeting_node = Some(nbr)
            break
          }
          if (!forward_visited.contains_key(nbr)) {
            forward_visited.insert(nbr, cur_dist + 1)
            new_fwd_queue.push(nbr)
          }
        }
      }
      fwd_queue = new_fwd_queue
    }

    // 反向 BFS 一层（类似...）
    // ... (对称实现)

    // 检查是否相遇
    match meeting_node {
      Some(node) => {
        let fwd_dist = forward_visited.get(node).unwrap()
        let bwd_dist = backward_visited.get(node).unwrap()
        return fwd_dist + bwd_dist
      }
      None => ()
    }
  }

  -1  // 不可达
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/dfsbfs | 🏆 业界标杆，新加坡国立大学开发 |
| Algorithm Visualizer | https://algorithm-visualizer.org/graphs/bfs.html | 简洁直观 |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/BFS.html | 学术风格 |

### 理论延伸阅读

- **最短路径进阶**: [Dijkstra 教程](/algorithms/shortest-path/dijkstra/)
- **深度优先搜索**: [DFS 教程](/algorithms/traversal/dfs/index/)
- **高级应用**: [拓扑排序](/algorithms/traversal/topo-sort/)（基于 DFS）
- **网络流**: [Edmonds-Karp](/algorithms/flow/edmonds-karp/)（基于 BFS 寻增广路）

### mbtgraph API 参考

```moonbit
// 核心函数
@traversal.bfs(graph, start)              // 单源 BFS → BfsResult
@traversal.bfs_all(graph)               // 多源 BFS → BfsResult
@traversal.bfs_shortest_path(graph, s, t)  // 快捷方法: 返回路径数组

// 结果查询
result.base.is_visited(id)               // Bool
result.base.path_to(target)             // Array[NodeId]
result.base.reachable_count()          // Int
result.distance(target)                 // Int (层级距离)
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** BFS 的核心思想（涟漪扩散类比）
- [ ] **手动执行** 小规模图的 BFS 过程（写出 Order/Level/Parent）
- [ ] **实现** MoonBit 版本的 BFS（理解队列、visited、parents 的作用）
- [ ] **使用** `bfs_shortest_path()` 解决无权图最短路径问题
- [ ] **区分** BFS vs DFS vs Dijkstra 的适用场景
- [ ] **分析** BFS 的时间/空间复杂度（O(V+E) / O(V)）
- [ ] **应用** BFS 到实际问题（社交网络/GC/爬虫/地图搜索）

> 💡 **下一步**: 尝试实现练习题中的**双向 BFS**，或者直接进入 [DFS 深度优先搜索](/algorithms/traversal/dfs/index/) 学习另一种重要的遍历策略！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 BFS:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_graph()
  let result = @traversal.bfs(g, @core.NodeId(0))
  println("访问顺序: ${result.base.order}")
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看动画：<a href="https://visualgo.net/en/dfsbfs" target="_blank">https://visualgo.net/en/dfsbfs</a></p>
  </div>
</div>
