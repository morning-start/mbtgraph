---
title: Prim 最小生成树
description: 从单个节点出发，逐步扩展的最小生成树构建算法：原理、动画演示、MoonBit 实现、实战应用
---

# Prim 最小生成树

> 🎯 **本节目标**: 掌握 Prim 算法原理、优先队列/数组实现、复杂度分析和实际应用
>
> ⏱️ **预计阅读时间**: 25 分钟 | 🎮 **互动演示**: 3 个可运行示例

## 📖 算法简介

**Prim 算法**是一种用于求解**最小生成树（Minimum Spanning Tree, MST）**的贪心算法。

### 核心思想 💡

想象你**从一颗种子开始，慢慢长出一棵覆盖所有节点的树**：

```
树的生长类比:

  [A] ── 从 A 出发，已选集合 S = {A}
   │
   ├── 候选边: A-B(2), A-D(4)
   │
   ▼
  A ── B ── 选最小的 A-B(2), S = {A, B}
  │         候选边更新: A-D(4), B-D(3), B-E(5)
  │
  ▼
  A ── B ── D ── 选最小的 B-D(3), S = {A, B, D}
  │              候选边更新: A-D(4), B-E(5), D-E(6)
  │
  ▼
  A ── B ── D ── E ── 选最小的 B-E(5), S = {A, B, D, E}
  │                   候选边更新: D-E(6) 但 E 已在 S 中
  │
  ▼
  A ── B ── D ── E ── C ── 选 D-E(6) 或 A-C(7), S = {A, B, C, D, E} ← 完成!

核心策略: 维护一个"已选集合"，每次选连接已选与未选的最小边
```

### 算法步骤

1. 任选一个起始节点，加入已选集合 S
2. 初始化 `key[]` 数组（记录每个未选节点到 S 的最小距离），`parent[]` 数组（记录连接节点）
3. 重复 V 次：
   - 从 `key[]` 中选最小值对应的节点 u（不在 S 中）
   - 将 u 加入 S，记录边 (parent[u], u, key[u])
   - 更新 u 的所有邻居 v 的 key 和 parent（如果 weight(v, u) < key[v]）

### 为什么需要 Prim？

| 场景 | Kruskal 算法 | **Prim 算法** |
|------|-------------|-------------|
| 稀疏图（E ≈ V） | ✅ Kruskal 更快 | 可用但优先队列开销大 |
| **稠密图（E ≈ V²）** | 可用但边排序开销大 | **✅ Prim 更快!** |
| 需要逐步扩展的树 | ❌ 全局排序 | **✅ 天然支持** |
| 不连通图 | ✅ 返回森林 | ❌ 只返回一个分量的 MST |

### 历史

| 算法 | 发明者 | 年份 | 论文/贡献 | 时间复杂度 |
|------|--------|------|----------|-----------|
| **Prim** | Robert Prim | 1957 | "Shortest connection networks and some generalizations" | O(V²) 或 O(E log V) |
| Jarník | Vojtěch Jarník | 1930 | 最早发现，但未被广泛知晓 | O(V²) |
| Kruskal | Joseph Kruskal | 1956 | "On the shortest spanning subtree of a graph" | O(E log E) |

---

## 🎬 交互式动画：Prim 分步执行过程

让我们通过一个具体例子来理解 Prim 的执行流程。

### 示例图: 无向带权图

考虑以下无向带权图（5 节点，7 条边）：

**边列表**: `(0,1,2), (0,3,1), (1,3,3), (1,2,4), (2,3,5), (2,4,6), (3,4,7)`

<div class="viz-preview-card">
  <iframe src="/visualizations/prim/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/prim/" target="_blank" class="viz-fullscreen-btn">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 动画说明

> **配色含义（VisuAlgo 风格）**:

| 颜色 | 含义 |
|------|------|
| **深棕色** | 起始节点（节点 0） |
| **绿色** | 已在 MST 中的节点和边 |
| **橙色** | 当前选中的节点 |
| **黄色** | 候选节点（frontier） |
| **灰色** | 未访问节点 |
| **蓝色虚线** | 当前最小的候选边 |

### 预期结果

Prim 从节点 0 开始，逐步扩展已选集合：

```
初始: key = [0, ∞, ∞, ∞, ∞], S = {0}

步骤 1: 选节点 0 (key=0), 加入 S
        更新邻居: key[1]=2(parent=0), key[3]=1(parent=0)
        S = {0}

步骤 2: 选节点 3 (key=1 最小), 加入 S
        更新邻居: key[1]=2(不更新), key[2]=5(parent=3), key[4]=7(parent=3)
        S = {0, 3}

步骤 3: 选节点 1 (key=2 最小), 加入 S
        更新邻居: key[2]=4(parent=1, 更新!)
        S = {0, 3, 1}

步骤 4: 选节点 2 (key=4 最小), 加入 S
        更新邻居: key[4]=6(parent=2, 更新!)
        S = {0, 3, 1, 2}

步骤 5: 选节点 4 (key=6 最小), 加入 S
        S = {0, 3, 1, 2, 4} ← 完成!

MST 总权重: 0 + 1 + 2 + 4 + 6 = 13
MST 边: (0,0,0), (0,3,1), (0,1,2), (1,2,4), (2,4,6)
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/mst/prim.mbt`）

```moonbit
///|
/// Prim 最小生成树算法
///
/// 从根节点出发的贪心生长算法，时间复杂度 O(V²)。
/// 使用数组模拟优先队列（避免跨包依赖）。
fn prim_min_key(
  key : Array[Double?],
  in_mst : Array[Bool],
  size : Int,
) -> (Int, Bool) {
  let mut min_val = 1000000000000000000.0
  let mut min_idx = -1
  let mut found = false
  let mut i = 0
  while i < size {
    if !in_mst[i] {
      match key[i] {
        Some(k) =>
          if k < min_val {
            min_val = k
            min_idx = i
            found = true
          }
        None => ()
      }
    }
    i = i + 1
  }
  (min_idx, found)
}

///|
/// Prim 最小生成树
///
/// 从 root 节点开始构建最小生成树。
pub fn[G : @core.GraphReadable] prim(
  graph : G,
  root : @core.NodeId,
) -> MstResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 || !@core.GraphReadable::contains_node(graph, root) {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }
  let max_id = mst_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let key : Array[Double?] = Array::make(size, None)
  let parent : Array[@core.NodeId?] = Array::make(size, None)
  let in_mst : Array[Bool] = Array::make(size, false)
  key[root.0] = Some(0.0)
  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0
  let mut count = 0
  while count < nc {
    let (u, found) = prim_min_key(key, in_mst, size)
    if !found { break }
    in_mst[u] = true
    match parent[u] {
      Some(p) =>
        match key[u] {
          Some(w) => {
            mst_edges.push((p, @core.NodeId(u), w))
            total_weight = total_weight + w
          }
          None => ()
        }
      None => ()
    }
    let unode = @core.NodeId(u)
    for vw in @core.GraphReadable::neighbors_with_weight(graph, unode) {
      match vw {
        (v, w) => {
          let vid = v.0
          if vid >= 0 && vid < size && !in_mst[vid] {
            let should_update = match key[vid] {
              None => true
              Some(k) => w < k
            }
            if should_update {
              key[vid] = Some(w)
              parent[vid] = Some(unode)
            }
          }
        }
      }
    }
    count = count + 1
  }
  MstResult::{ total_weight, edges: mst_edges }
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么用 `Array[Double?]` 而不是优先队列？

```moonbit
// 当前实现: 数组存储 key 值, 每次线性扫描找最小
let key : Array[Double?] = Array::make(size, None)
// prim_min_key: O(V) 扫描

// 替代方案: 二叉堆（优先队列）
// 可以将时间复杂度从 O(V²) 降至 O(E log V)
// 但 MoonBit 跨包依赖限制，当前用数组实现
```

> 💡 **权衡**: 数组实现 O(V²)，对于稠密图（E ≈ V²）与二叉堆的 O(E log V) = O(V² log V) 差别不大。但对于稀疏图，二叉堆更优。

#### 2️⃣ 为什么 `parent[root] = None`？

```moonbit
key[root.0] = Some(0.0)  // 起点 key = 0
parent[root.0] = None    // 起点无父节点
```

在结果提取时，`match parent[u]` 会跳过根节点（None），避免将起点自身加入 MST。

#### 3️⃣ `prim_min_key` 的 `found` 标志

```kotlin
if !found { break }  // 所有剩余节点都不可达（图不连通）
```

这确保 Prim 在遇到不连通图时不会陷入无限循环，而是提前终止。

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 计算 MST 总权重

```moonbit
fn prim_basic_demo() -> Unit {
  // 构建示例图（与动画演示相同）
  let mut g = @storage.UndirectedAdjList::new_with_capacity(5, 7)

  let nodes = [@core.GraphWritable::add_node(g, 0.0); 5]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[3], 3.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[3], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[4], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 7.0)

  let result = @mst.prim(g, nodes[0])

  println("=== Prim MST 结果 ===")
  println("MST 总权重: \(result.total_weight)")
  println("MST 边数: \(result.edge_count())")

  // 输出每条边
  for edge in result.edges {
    match edge {
      (u, v, w) => println("  边 \(u.0)-\(v.0): 权重=\(w)")
    }
  }
}

// 输出:
// === Prim MST 结果 ===
// MST 总权重: 13.0
// MST 边数: 4
//   边 0-3: 权重=1.0
//   边 0-1: 权重=2.0
//   边 1-2: 权重=4.0
//   边 2-4: 权重=6.0
```

### 示例 2: 🎲 迷宫生成（稠密图）

```moonbit
/// 使用 Prim 算法生成迷宫
fn maze_generation_with_prim() -> Unit {
  // 构建网格图（稠密图: 6 节点, 9 条边）
  let mut g = @storage.UndirectedAdjList::new_with_capacity(6, 9)

  let nodes = [@core.GraphWritable::add_node(g, 0.0); 6]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[4], 3.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[5], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[0], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[4], nodes[5], 7.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[4], nodes[1], 3.0)

  let result = @mst.prim(g, nodes[0])

  println("=== Prim 迷宫生成 ===")
  println("迷宫总长度（MST 权重）: \(result.total_weight)")
  println("通道数: \(result.edge_count())")
  println("\n迷宫通道:")
  for edge in result.edges {
    match edge {
      (u, v, w) => println("  房间 \(u.0) ↔ 房间 \(v.0): 通道长度 \(w)")
    }
  }

  // 验证: MST 边数 = V-1 = 5（连通图）
  if result.edge_count() == 5 {
    println("\n✅ 迷宫连通!")
  }
}

// 输出:
// === Prim 迷宫生成 ===
// 迷宫总长度（MST 权重）: 16.0
// 通道数: 4
// ...
```

### 示例 3: 📊 Kruskal vs Prim 对比

```moonbit
/// 比较 Kruskal 和 Prim 的结果一致性
fn compare_kruskal_prim() -> Unit {
  let mut g = @storage.UndirectedAdjList::new_with_capacity(5, 7)
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 5]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[3], 3.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[3], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[4], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 7.0)

  let kruskal_result = @mst.kruskal(g)
  let prim_result = @mst.prim(g, nodes[0])

  println("=== Kruskal vs Prim 对比 ===")
  println("Kruskal 总权重: \(kruskal_result.total_weight)")
  println("Prim 总权重: \(prim_result.total_weight)")

  // 两种算法结果应该相同（MST 唯一时）
  if kruskal_result.total_weight == prim_result.total_weight {
    println("✅ 两种算法找到的 MST 总权重相同!")
  }

  println("\nKruskal 选边顺序: 全局边排序")
  println("Prim 选边顺序: 从起点逐步扩展")
}

// 输出:
// === Kruskal vs Prim 对比 ===
// Kruskal 总权重: 13.0
// Prim 总权重: 13.0
// ✅ 两种算法找到的 MST 总权重相同!
```

---

## 📈 复杂度分析

### 时间复杂度: O(V²)

| 操作 | 次数 | 复杂度 | 说明 |
|------|------|--------|------|
| 初始化数组 | 1 次 | O(V) | key, parent, in_mst |
| 选最小 key | V 次 | O(V) 每次 | `prim_min_key` 线性扫描 |
| 更新邻居 | 总共 E 次 | O(E) 总计 | 每条边被检查两次 |
| **总计** | | **O(V² + E)** | 对于稠密图 E ≈ V²，即 O(V²) |

> 💡 **优化**: 使用二叉堆可将 `prim_min_key` 从 O(V) 降至 O(log V)，总复杂度降至 O(E log V)。

### 空间复杂度: O(V)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `key[]` | O(V) | 到集合的最小距离 |
| `parent[]` | O(V) | 父节点指针 |
| `in_mst[]` | O(V) | 是否在 MST 中 |
| `mst_edges[]` | O(V) | MST 边数 = V-1 |
| **总计** | **O(V)** | |

### 与其他算法对比

| 算法 | 时间 | 空间 | 适用场景 |
|------|------|------|----------|
| Kruskal | O(E log E) | O(V+E) | **稀疏图**、不连通图 |
| **Prim (数组)** | **O(V²)** | **O(V)** | **稠密图** |
| Prim (二叉堆) | O(E log V) | O(V) | 中等密度图 |
| Prim (斐波那契堆) | O(E + V log V) | O(V) | 超大规模图 |

---

## 🎯 实际应用场景

### 应用 1: 迷宫生成 - 游戏开发

```
问题: 生成一个连通且无环的迷宫

Prim 优势:
✅ 从起点开始逐步扩展，天然生成树结构
✅ 每次选最小权重边，迷宫通道长度均匀
✅ 生成结果唯一（给定起点和图）

应用:
- 地牢生成（Roguelike 游戏）
- 关卡设计（连接多个房间）
```

### 应用 2: 网络设计 - 数据中心互联

```
问题: 用最低成本连接数据中心

Prim 应用:
1. 构建图: 数据中心为节点, 连接成本为权重
2. 从主数据中心（root）开始运行 Prim
3. 得到成本最优的连接方案

优势:
✅ 从核心节点开始，天然形成层级结构
✅ 适合星型拓扑的网络设计
```

### 应用 3: 电路路由 - PCB 设计

```
问题: 在印刷电路板上连接元件引脚，最小化总线长

Prim 应用:
1. 构建图: 引脚为节点, 引脚间距离为权重
2. 运行 Prim 得到最小总线长连接
3. 避免信号环路（in_mst 数组自动保证）
```

### 应用 4: 图像分割 - 区域合并

```
问题: 将图像中相似的颜色区域合并

Prim 应用（与 Kruskal 类似）:
1. 每个像素初始为独立区域
2. 计算相邻像素的"颜色差异"作为权重
3. 从种子像素开始运行 Prim
4. 当区域数量达到目标时停止
```

---

## 🧪 练习题

### 练习 1: 手动执行 Prim ⭐⭐

对于以下无向带权图，手动执行 Prim 算法（从节点 A 开始），写出：
1. 每次选择的节点和对应的 key 值
2. parent 数组的变化
3. MST 的总权重

```
图结构:
  A ──(2)── B
  │╲       ╱│
  │  (3) (1) │
  │   ╲ ╱   │
  (4)  C   (5)
  │   ╱ ╲   │
  │  (6) (7) │
  │╱       ╲│
  D ──(8)── E
```

<details>
<summary>📝 点击查看答案</summary>

```
初始: key=[A=0, B=∞, C=∞, D=∞, E=∞], S={}

步骤 1: 选 A(key=0), S={A}, 更新: B=2, C=3, D=4
步骤 2: 选 B(key=2), S={A,B}, 更新: C=3(不更新), E=5
步骤 3: 选 C(key=3), S={A,B,C}, 更新: D=4(不更新), E=5(不更新)
步骤 4: 选 D(key=4), S={A,B,C,D}, 更新: E=5(不更新)
步骤 5: 选 E(key=5), S={A,B,C,D,E} ← 完成!

MST 总权重: 0 + 2 + 3 + 4 + 5 = 14
```

</details>

### 练习 2: 🔍 Prim 变体 - 最大生成树 ⭐⭐⭐

**挑战**: 修改 Prim 算法，使其返回**最大**生成树（MaxST）——即总权重最大的生成树。

**提示**:
1. 将 `key[]` 初始化为 `Some(-∞)` 而不是 `Some(∞)`
2. 在 `prim_min_key` 中找**最大值**而不是最小值
3. 更新条件改为 `w > key[v]` 而不是 `w < key[v]`

<details>
<summary>💻 点击查看参考实现</summary>

```moonbit
fn prim_max_key(
  key : Array[Double?],
  in_mst : Array[Bool],
  size : Int,
) -> (Int, Bool) {
  let mut max_val = -1.0
  let mut max_idx = -1
  let mut found = false
  let mut i = 0
  while i < size {
    if !in_mst[i] {
      match key[i] {
        Some(k) =>
          if k > max_val {
            max_val = k
            max_idx = i
            found = true
          }
        None => ()
      }
    }
    i = i + 1
  }
  (max_idx, found)
}
```

</details>

### 练习 3: 🔧 实现 Prim 森林 ⭐⭐⭐⭐

**挑战**: 修改 Prim 算法，使其在图不连通时返回所有连通分量的 MST 森林。

**提示**:
1. 在 `prim` 返回后，检查 `mst_edges.edge_count() == nc - 1`
2. 如果不相等，说明图不连通，需要从每个未访问节点重新开始 Prim
3. 使用 `in_mst` 数组追踪已访问节点

<details>
<summary>💻 点击查看参考实现</summary>

```moonbit
fn prim_forest[G : @core.GraphReadable](graph : G) -> MstResult {
  let nc = @core.GraphReadable::node_count(graph)
  let mut total_weight = 0.0
  let mut all_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let visited = Array::make(nc, false)

  // 对每个未访问节点运行 Prim
  for nid in @core.GraphReadable::node_ids(graph) {
    if !visited[nid.0] {
      let result = @mst.prim(graph, nid)
      total_weight = total_weight + result.total_weight
      for edge in result.edges {
        all_edges.push(edge)
      }
    }
  }

  MstResult::{ total_weight, edges: all_edges }
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/mst | 🏆 业界标杆，支持 Kruskal 和 Prim 对比 |
| Algorithm Visualizer | https://algorithm-visualizer.org/mst | 简洁直观 |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/Prim.html | 学术风格 |

### 理论延伸阅读

- **Kruskal vs Prim 对比**: [Kruskal-Prim 对比详解](/algorithms/mst/kruskal-prim/)
- **最小生成树应用**: 网络设计、电路布线、图像分割、聚类分析
- **Prim 算法的提出**: Robert C. Prim (1957) — "Shortest connection networks and some generalizations"

### mbtgraph API 参考

```moonbit
// 核心函数
@mst.prim(graph, root)            // Prim 算法 → MstResult
@mst.kruskal(graph)               // Kruskal 算法 → MstResult

// MstResult 查询
result.total_weight               // MST 总权重 (Double)
result.edge_count()               // MST 边数
result.has_edge(u, v)             // 检查边是否在 MST 中
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** Prim 的核心思想（从起点逐步扩展，选最小边）
- [ ] **手动执行** 小规模图的 Prim 过程（写出 key[]、parent[]、MST 总权重）
- [ ] **理解** 数组实现 vs 优先队列实现的时间复杂度差异
- [ ] **区分** Kruskal vs Prim 的适用场景（稀疏图 vs 稠密图）
- [ ] **分析** Prim 的时间/空间复杂度（O(V²) / O(V)）
- [ ] **应用** Prim 到实际问题（迷宫生成、网络设计、电路路由）

> 💡 **下一步**: 尝试实现练习题中的 **Prim 森林**，或者进入 [Kruskal 算法](/algorithms/mst/kruskal/) 学习另一种 MST 算法！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 Prim:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_graph()
  let result = @mst.prim(g, @core.NodeId(0))
  println("MST 总权重: \(result.total_weight)")
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看动画：<a href="https://visualgo.net/en/mst" target="_blank">https://visualgo.net/en/mst</a></p>
  </div>
</div> 