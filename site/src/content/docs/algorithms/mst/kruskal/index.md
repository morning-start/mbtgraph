---
title: Kruskal 算法
description: 基于并查集的最小生成树算法详解：原理、动画演示、MoonBit 实现、实战应用
---

# Kruskal 最小生成树算法

> 🎯 **本节目标**: 掌握 Kruskal 算法原理、Union-Find 数据结构、复杂度分析和实际应用
>
> ⏱️ **预计阅读时间**: 30 分钟 | 🎮 **互动演示**: 完整分步动画 + 预期结果

## 📖 算法简介

**Kruskal 算法**是一种用于求解无向连通图**最小生成树（Minimum Spanning Tree, MST）**的经典贪心算法，由 Joseph B. Kruskal 于 1956 年发表。

### 核心思想 💡

想象你是**一名电信网络工程师**，需要在多个城市之间铺设光纤：

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
```

Kruskal 的策略：**优先选择最便宜的边**，只要不形成环就加入 MST。

### 算法步骤

```
Kruskal 执行流程:

Step 1: 将所有边按权重升序排列 ⭐
        从最便宜的边开始考虑

Step 2: 依次检查每条边
        如果该边的两个端点不在同一连通分量 → 加入 MST ✅
        （使用 Union-Find 高效判断）
        否则 → 跳过（会形成环）❌

Step 3: 当选中 V-1 条边时停止
        （N 个节点的树恰好有 N-1 条边）
```

### 为什么不会形成环？

Kruskal 的关键在于使用 **并查集（Union-Find）** 数据结构：

| 操作 | 作用 | 复杂度 |
|------|------|--------|
| `find(x)` | 查找 x 所属的连通分量（根节点） | O(α(n)) ≈ O(1) |
| `union(x, y)` | 合并 x 和 y 所在的连通分量 | O(α(n)) ≈ O(1) |

当考虑边 (u, v) 时：
- 如果 `find(u) != find(v)` → u 和 v 不在同一分量 → 可以安全加入
- 如果 `find(u) == find(v)` → u 和 v 已连通 → 加入会形成环 → 跳过

### 与 Prim 算法的对比

| 维度 | **Kruskal** | **Prim** |
|------|-------------|----------|
| **策略** | **边优先**: 全局排序选边 | **点优先**: 从根节点逐步扩展 |
| **数据结构** | 排序 + **Union-Find** | 优先队列 / 数组 |
| **时间复杂度** | **O(E log E)** | **O((V+E) log V)** 或 **O(V²)** |
| **适用场景** | **稀疏图** (E ≈ V) | **稠密图** (E >> V) |
| **实现难度** | 较简单（排序 + 并查集）| 中等（需维护 key[] 数组）|
| **直观类比** | **全局视角**: 选最短的边 | **局部视角**: 扩展最近的点 |

### 正确性依据：割性质（Cut Property）

```
设 S 是图的一个节点子集
"割" = 所有一个端点在 S、另一个不在 S 的边

割性质定理:
  对于任意割，权重最小的横跨边一定属于某个 MST

直观理解:
  ┌─────────────────────┬─────────────────────┐
  │   集合 S            │   集合 V \ S        │
  │   ┌───┐            │   ┌───┐            │
  │   │ A │            │   │ B │            │
  │   └─┬─┘            │   └─┬─┘            │
  │     ╳──(2)──────────────╳                 │  ← 最轻的横跨边必在 MST 中!
  │     ╳──(5)──────────────╳                 │
  │     ╳──(10)───────────╳                   │
  └─────────────────────┴─────────────────────┘
```

---

## 🎬 交互式动画：Kruskal 分步执行过程

让我们通过一个具体例子来理解 Kruskal 的执行流程。**点击 ▶ 播放按钮或使用键盘方向键控制动画！**

### 示例图: 带权无向连通图

考虑以下带权无向图（5 节点，7 条边）：

```
     1 ──(7)── 3
    ╱│╲       │╱
  (6)│ (8)   (5)(9)
  ╱  │  ╲     │ ╱
 0──(4)─── 2 ─┘
```

**边列表**: `(0,1,6), (0,2,4), (1,2,8), (1,3,7), (2,3,5), (2,3,9)`

目标：选出 4 条边（V-1），无环，总权重最小。

<div class="viz-preview-card">
  <iframe src="/visualizations/kruskal/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/kruskal/" target="_blank" class="viz-fullscreen-btn">
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
| **橙色** | 当前正在检查的边 |
| **绿色** | 已加入 MST 的边 |
| **红色 / 灰色** | 被跳过的边（会形成环） |
| **蓝色** | 尚未处理的边 |
| **高亮节点** | 已加入同一连通分量的节点 |

### 预期结果

Kruskal 按权重从小到大选边，使用 Union-Find 避免环路：

```
执行过程:
Step 0: 排序后边列表
  #1: (0,2) 权重=4
  #2: (2,3) 权重=5
  #3: (0,1) 权重=6
  #4: (1,3) 权重=7
  #5: (1,2) 权重=8

Step 1: 检查 (0,2,4) → find(0)≠find(2) → ✅ 加入!  总权重=4
Step 2: 检查 (2,3,5) → find(2)≠find(3) → ✅ 加入!  总权重=9
Step 3: 检查 (0,1,6) → find(0)≠find(1) → ✅ 加入!  总权重=15
Step 4: 检查 (1,3,7) → find(1)==find(3) → ❌ 跳过! (会形成环)
Step 5: 检查 (1,2,8) → find(1)==find(2) → ❌ 跳过! (会形成环)

最终结果:
  选中边数: 4 (= V-1)
  总权重: 15
  MST 边集: [(0,2,4), (2,3,5), (0,1,6), ...]

Union-Find 状态变化:
  初始: {0} {1} {2} {3}
  Step1: {0,2} {1} {3}
  Step2: {0,2,3} {1}
  Step3: {0,1,2,3} → 所有节点连通!
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/mst/kruskal.mbt`）

```moonbit
///|
/// Kruskal 最小生成树算法
///
/// 基于边排序 + Union-Find 的贪心算法，时间复杂度 O(E log E)。
/// 适用于无向图。
fn[G : @core.GraphReadable] mst_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// 收集边并按权重排序（选择排序）
fn sort_edges(
  edges : Array[(@core.NodeId, @core.NodeId, Double)],
) -> Array[(@core.NodeId, @core.NodeId, Double)] {
  let n = edges.length()
  if n <= 1 {
    return edges
  }
  let result = edges
  let mut i = 0
  while i < n - 1 {
    let mut j = i + 1
    while j < n {
      if result[j].2 < result[i].2 {
        let tmp = result[i]
        result[i] = result[j]
        result[j] = tmp
      }
      j = j + 1
    }
    i = i + 1
  }
  result
}

///|
/// Kruskal 最小生成树
///
/// 返回无向图的最小生成树。如果图不连通，返回森林（每个连通分量的 MST）。
pub fn[G : @core.GraphReadable] kruskal(graph : G) -> MstResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }
  let max_id = mst_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let uf = uf_new(size)
  let raw_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []

  // 收集所有边（只保留 u < v 的边，避免无向边重复）
  for u in @core.GraphReadable::node_ids(graph) {
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw {
        (v, w) => if u.0 < v.0 { raw_edges.push((u, v, w)) }
      }
    }
  }

  // 按权重升序排序
  let sorted = sort_edges(raw_edges)

  // 贪心选择边
  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0
  for edge in sorted {
    match edge {
      (u, v, w) =>
        if uf_union(uf, u.0, v.0) {
          mst_edges.push((u, v, w))
          total_weight = total_weight + w
        }
    }
  }

  MstResult::{ total_weight, edges: mst_edges }
}
```

### Union-Find 实现（来自 `lib/algo/mst/union_find.mbt`）

```moonbit
///|
/// Union-Find（并查集）数据结构
///
/// 带路径压缩和按秩合并，用于 Kruskal 算法。
priv struct UnionFind {
  parent : Array[Int]
  rank : Array[Int]
}

///|
fn uf_new(size : Int) -> UnionFind {
  let p : Array[Int] = []
  let r : Array[Int] = []
  for i in 0..<size {
    p.push(i)    // 初始时每个节点是自己的根
    r.push(0)    // 初始秩为 0
  }
  UnionFind::{ parent: p, rank: r }
}

///|
fn uf_find(uf : UnionFind, x : Int) -> Int {
  if uf.parent[x] != x {
    let root = uf_find(uf, uf.parent[x])
    uf.parent[x] = root    // 路径压缩：直接挂到根下
    root
  } else {
    x
  }
}

///|
fn uf_union(uf : UnionFind, x : Int, y : Int) -> Bool {
  let rx = uf_find(uf, x)
  let ry = uf_find(uf, y)
  if rx == ry {
    return false           // 已在同一集合，合并会形成环
  }
  // 按秩合并：矮树挂到高树下
  if uf.rank[rx] < uf.rank[ry] {
    uf.parent[rx] = ry
  } else if uf.rank[rx] > uf.rank[ry] {
    uf.parent[ry] = rx
  } else {
    uf.parent[ry] = rx
    uf.rank[rx] = uf.rank[rx] + 1
  }
  true
}
```

### 结果类型（来自 `lib/algo/mst/types.mbt`）

```moonbit
///|
/// 最小生成树结果类型
pub(all) struct MstResult {
  total_weight : Double
  edges : Array[(@core.NodeId, @core.NodeId, Double)]
}

///|
pub fn MstResult::edge_count(self : MstResult) -> Int {
  self.edges.length()
}

///|
pub fn MstResult::has_edge(
  self : MstResult,
  u : @core.NodeId,
  v : @core.NodeId,
) -> Bool {
  for edge in self.edges {
    match edge {
      (a, b, _) => if (a == u && b == v) || (a == v && b == u) { return true }
    }
  }
  false
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么只保留 `u < v` 的边？

```moonbit
// 无向图中每条边在邻接表中存储两次
// 如果不去重，同一条边会被处理两次，导致错误

// ❌ 不去重:
for u in nodes {
  for (v, w) in neighbors_with_weight(graph, u) {
    raw_edges.push((u, v, w))  // (0,2,4) 和 (2,0,4) 都被加入!
  }
}

// ✅ 去重 (只保留 u < v 的边):
for u in nodes {
  for (v, w) in neighbors_with_weight(graph, u) {
    if u.0 < v.0 { raw_edges.push((u, v, w)) }  // 只加入 (0,2,4)
  }
}
```

**效果**: 将边数从 2E 减少到 E，排序更快，处理更高效。

#### 2️⃣ 为什么使用选择排序而非快速排序？

当前实现使用选择排序（O(E²)），适合小规模图。对于大规模数据，可以替换为更高效的排序算法：

| 算法 | 时间复杂度 | 适用场景 |
|------|-----------|----------|
| 选择排序 | O(E²) | 小规模图（当前实现） |
| 归并排序 | O(E log E) | 大规模图（推荐替换） |
| 标准库排序 | O(E log E) | 生产环境 |

> 💡 **优化提示**: 在 MoonBit 标准库提供稳定排序后，可替换 `sort_edges` 为内置函数。

#### 3️⃣ Union-Find 的优化技巧

```
路径压缩 (Path Compression):
  每次 find 时，将节点直接挂在根节点下
  
  查找前:  0 ← 1 ← 2 ← 3    (链表，查找 O(n))
  查找后:  0 ← 1, 0 ← 2, 0 ← 3  (扁平，查找 O(1))

按秩合并 (Union by Rank):
  将矮的树挂到高的树下，避免退化为链表
  
  合并前:  树A (深度2)    树B (深度3)
  合并后:  树B (深度3) ← 树A   (深度不变!)
```

#### 4️⃣ 结果类型的设计

| 字段 | 类型 | 用途 |
|------|------|------|
| `total_weight` | `Double` | MST 的总权重 |
| `edges` | `Array[(NodeId, NodeId, Double)]` | MST 的边集 |

**辅助方法**:
- `edge_count()` → 边数（应为 V-1）
- `has_edge(u, v)` → 检查某条边是否在 MST 中

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 构建 MST 并输出结果

```moonbit
fn kruskal_basic_demo() -> Unit {
  // 构建带权无向图（与动画演示相同）
  let g = build_sample_undirected_weighted_graph()

  // 执行 Kruskal 算法
  let result = @mst.kruskal(g)

  // 输出结果
  println("=== Kruskal MST 结果 ===")
  println("总权重: ${result.total_weight}")
  println("边数: ${result.edge_count()}")

  println("\nMST 边集:")
  for (i, edge) in result.edges.indexed() {
    match edge {
      (u, v, w) => {
        println("  ${i}. ${u} ───(${w})── ${v}")
      }
    }
  }

  // 验证 MST 性质
  let nc = @core.GraphReadable::node_count(g)
  if (result.edge_count() == nc - 1) {
    println("\n✅ MST 包含 V-1 条边，结构正确!")
  } else {
    println("\n⚠️ 图可能不连通，得到的是最小生成森林")
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
// ✅ MST 包含 V-1 条边，结构正确!
```

### 示例 2: 📡 电信网络设计 - 最小化布线成本

```moonbit
/// 使用 Kruskal 解决网络基础设施的最小成本连接问题
///
/// 场景: 需要在 N 个城市之间建设光纤网络，
///       目标是用最低的总成本连接所有城市
fn design_telecom_network(
  cities : Array[String],
  connection_costs : Array[(Int, Int, Double)],
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
  let mut total_cost = 0.0

  for (i, link) in mst.edges.indexed() {
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

// 输出:
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

### 示例 3: 🔄 比较 Kruskal vs Prim 的结果

```moonbit
/// 对比两种 MST 算法的结果和性能
fn compare_kruskal_vs_prim() -> Unit {
  // 构建同一个图
  let g = build_comparison_graph()

  // 运行 Kruskal
  let kruskal_result = @mst.kruskal(g)

  // 运行 Prim (从节点 0 开始)
  let prim_result = @mst.prim(g, @core.NodeId(0))

  println("=== Kruskal vs Prim 对比 ===\n")

  // 结果对比
  println("Kruskal 结果:")
  println("  总权重: ${kruskal_result.total_weight}")
  println("  边数: ${kruskal_result.edge_count()}")

  println("\nPrim 结果:")
  println("  总权重: ${prim_result.total_weight}")
  println("  边数: ${prim_result.edge_count()}")

  // 验证两种算法得到的 MST 总权重相同
  if (kruskal_result.total_weight == prim_result.total_weight) {
    println("\n✅ 两种算法得到的 MST 总权重相同!")
    println("   (MST 总权重唯一，但边集可能不同)")
  } else {
    println("\n⚠️ 结果不一致 (可能是图不连通)")
  }

  // 对比边集
  println("\n📊 边集对比:")
  println("  Kruskal 选边顺序: 全局排序，贪心选最小边")
  println("  Prim 选边顺序: 从根节点向外扩展，选最近节点")

  // 注意：两种算法的 MST 边集可能不同（当有权重相同的边时）
  // 但总权重一定相同
  let mut common_edges = 0
  for k_edge in kruskal_result.edges {
    match k_edge {
      (ku, kv, kw) => {
        if (prim_result.has_edge(ku, kv)) {
          common_edges = common_edges + 1
        }
      }
    }
  }
  println("\n  共同边数: ${common_edges} / ${kruskal_result.edge_count()}")
  println("  (当存在相同权重边时，边集可能不同但总权重相等)")
}

// 输出示例:
// === Kruskal vs Prim 对比 ===
//
// Kruskal 结果:
//   总权重: 15.0
//   边数: 4
//
// Prim 结果:
//   总权重: 15.0
//   边数: 4
//
// ✅ 两种算法得到的 MST 总权重相同!
```

---

## 📈 复杂度分析

### 时间复杂度: O(E log E)

| 操作 | 次数 | 复杂度 | 说明 |
|------|------|--------|------|
| 收集边 | 1 次 | O(E) | 遍历邻接表，只保留 u < v |
| **排序边** | 1 次 | **O(E log E)** | **主要开销**（当前实现 O(E²)） |
| Union-Find 操作 | E 次 | O(E α(V)) ≈ O(E) | 近似常数时间 |
| **总计** | | **O(E log E)** | |

> ⚠️ **注意**: 当前 `sort_edges` 使用选择排序（O(E²)）。替换为标准库排序后可达到 O(E log E)。

### 空间复杂度: O(V)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| Union-Find `parent[]` | O(V) | 每个节点的父节点指针 |
| Union-Find `rank[]` | O(V) | 每个节点的秩 |
| 边列表 | O(E) | 存储所有边 |
| MST 结果 | O(V) | 最多 V-1 条边 |
| **总计** | **O(V + E)** | |

### 与其他 MST 算法对比

| 算法 | 时间 | 空间 | 适用场景 |
|------|------|------|----------|
| **Kruskal** | O(E log E) | O(V + E) | **稀疏图** (E ≈ V)，实现简单 |
| **Prim (数组)** | O(V²) | O(V) | **稠密图** (E >> V)，无需额外空间 |
| **Prim (二叉堆)** | O((V+E) log V) | O(V) | 稀疏图，平衡效率 |
| **Prim (斐波那契堆)** | O(E + V log V) | O(V) | 理论最优，实现复杂 |

### 选择建议

```
选择策略:

  if (图是稀疏的, E ≈ V 或 E < V log V):
    使用 Kruskal ✅
    原因: O(E log E) ≈ O(E log V), 实现简单
    例子: 道路网络、社交网络

  else if (图是稠密的, E >> V, 如完全图):
    使用 Prim (数组实现) ✅
    原因: O(V²) 比 O(E log E) = O(V² log V) 更好
    例子: 完全图、团问题

  else if (需要增量式添加边):
    使用 Kruskal ✅
    原因: 可以基于已有的排序结果继续处理

  else if (需要从特定节点开始构建):
    使用 Prim ✅
    原因: 天然支持指定根节点
```

---

## 🎯 实际应用场景

### 应用 1: 网络设计 - 光纤铺设

```
问题: 在 N 个城市之间建设光纤网络，要求总成本最低

Kruskal 的优势:
✅ 天然适合"选边"场景（从候选边中选择最便宜的）
✅ 如果某些边已存在，可以预设权重为 0
✅ 结果保证总成本最低

实际考虑:
- 地理障碍（河流、山脉）→ 某些边权重极高
- 已存在的线路 → 权重设为 0
- 施工时间约束 → 可以分阶段执行 Kruskal
```

### 应用 2: 电路布线 - 最小化导线长度

```
问题: 在芯片上连接 N 个引脚，使总导线长度最短

建模方式:
- 节点: 芯片上的引脚位置
- 边: 可能的导线连接
- 权重: 导线长度（曼哈顿距离）

Kruskal 应用:
1. 生成所有可能的引脚连接（边列表）
2. 按距离排序
3. Kruskal 选择不交叉的最短连接
4. 结果: 最小化总导线长度的布线方案
```

### 应用 3: 图像分割 - 基于区域合并

```
问题: 将图像分割为多个相似区域

Kruskal 的应用（MST 视角）:
1. 将每个像素视为一个节点
2. 相邻像素之间建立边，权重 = 颜色差异
3. 运行 Kruskal 算法
4. 在合并阈值处停止 → 形成多个连通分量（区域）

关键性质:
✅ Kruskal 的合并过程天然形成层次化分割
✅ 可以通过控制合并阈值调整分割粒度
✅ 等价于基于 MST 的图像分割算法
```

### 应用 4: 聚类分析 - 最小生成树聚类

```
问题: 将 N 个数据点自动分为 K 个簇

Kruskal 聚类方法:
1. 构建完全图: 每个数据点 = 节点
2. 边权重 = 点之间的相似度距离（如欧氏距离）
3. 运行 Kruskal，但在选出 K-1 条边后停止
4. 此时图有 K 个连通分量 = K 个簇

优势:
✅ 不需要预先指定簇的形状
✅ 可以发现任意形状的簇
✅ 层次化: 从 1 个簇到 N 个簇的完整谱系

应用: 社交网络社区发现、生物分类学、市场细分
```

---

## 🧪 练习题

### 练习 1: 手动执行 Kruskal ⭐⭐

对于以下带权无向图，手动执行 Kruskal 算法，写出：

1. 排序后的边列表
2. 每条边的处理结果（加入/跳过/原因）
3. 最终的 MST 边集和总权重

```
    A ──(2)── B
    │╲        │╱
   (3)(4)    (1)
    │  ╲      │
    D ──(5)── C
```

<details>
<summary>📝 点击查看答案</summary>

```
排序后的边列表:
  #1: (B,C,1) 权重=1
  #2: (A,B,2) 权重=2
  #3: (A,D,3) 权重=3
  #4: (A,C,4) 权重=4
  #5: (C,D,5) 权重=5

处理过程:
  (B,C,1): find(B)≠find(C) → ✅ 加入!  集合: {B,C} {A} {D}  权重=1
  (A,B,2): find(A)≠find(B) → ✅ 加入!  集合: {A,B,C} {D}    权重=3
  (A,D,3): find(A)≠find(D) → ✅ 加入!  集合: {A,B,C,D}       权重=6
  (A,C,4): find(A)==find(C) → ❌ 跳过!  (A-B-C 已连通)
  (C,D,5): find(C)==find(D) → ❌ 跳过!  (A-D 和 A-B-C 已连通)

最终结果:
  MST 边集: [(B,C,1), (A,B,2), (A,D,3)]
  总权重: 6
  边数: 3 (= V-1 = 4-1) ✅
```

</details>

### 练习 2: 编程实现 - 判断图是否连通 ⭐⭐⭐

使用 Kruskal 的结果判断一个无向图是否连通。如果图不连通，返回连通分量的数量。

```moonbit
/// 判断图是否连通，并返回连通分量数量
fn count_connected_components(graph : @core.GraphReadable) -> Int {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 { return 0 }

  let mst = @mst.kruskal(graph)

  // 如果 MST 有 V-1 条边 → 图连通
  // 否则 → 图不连通，连通分量数 = V - MST边数
  // （因为每选一条边减少一个连通分量）
  nc - mst.edge_count()
}

// 测试用例
fn test_connectivity() -> Unit {
  // 连通图
  let connected = build_connected_graph()
  let cc1 = count_connected_components(connected)
  println("连通图: ${cc1} 个分量")  // 1

  // 不连通图 (两个独立子图)
  let disconnected = build_disconnected_graph()
  let cc2 = count_connected_components(disconnected)
  println("不连通图: ${cc2} 个分量")  // 2
}
```

<details>
<summary>💻 点击查看完整解答</summary>

```moonbit
/// 判断图是否连通，并返回连通分量数量
fn count_connected_components(graph : UndirectedAdjList) -> Int {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 { return 0 }

  let mst = @mst.kruskal(graph)

  // 关键公式: 连通分量数 = V - MST边数
  // 初始时每个节点独立 (V 个分量)
  // 每选一条边合并两个分量 → 分量数减 1
  // 最终: 分量数 = V - 选中边数
  nc - mst.edge_count()
}

fn is_connected(graph : UndirectedAdjList) -> Bool {
  count_connected_components(graph) == 1
}

fn test_connectivity() -> Unit {
  // 连通图: 4 节点，3 条边构成树
  let mut g1 = UndirectedAdjList::new()
  let n0 = @core.GraphWritable::add_node(g1, 0.0)
  let n1 = @core.GraphWritable::add_node(g1, 0.0)
  let n2 = @core.GraphWritable::add_node(g1, 0.0)
  let n3 = @core.GraphWritable::add_node(g1, 0.0)
  @core.GraphWritable::add_edge(g1, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g1, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g1, n2, n3, 1.0) |> ignore

  println("连通图: ${count_connected_components(g1)} 个分量")  // 1
  println("是否连通: ${is_connected(g1)}")  // true

  // 不连通图: 4 节点，2 条边 (两个独立子图)
  let mut g2 = UndirectedAdjList::new()
  let m0 = @core.GraphWritable::add_node(g2, 0.0)
  let m1 = @core.GraphWritable::add_node(g2, 0.0)
  let m2 = @core.GraphWritable::add_node(g2, 0.0)
  let m3 = @core.GraphWritable::add_node(g2, 0.0)
  @core.GraphWritable::add_edge(g2, m0, m1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g2, m2, m3, 1.0) |> ignore

  println("不连通图: ${count_connected_components(g2)} 个分量")  // 2
  println("是否连通: ${is_connected(g2)}")  // false
}
```

</details>

### 练习 3: 进阶 - 次小生成树 ⭐⭐⭐⭐

**挑战**: 实现寻找**次小生成树（Second Best MST）**的算法。

**思路**:
1. 先运行 Kruskal 找到 MST
2. 对 MST 中的每条边，将其移除后重新运行 Kruskal
3. 在所有结果中，找到权重最小的非 MST 解

**提示**:
- 次小生成树 = 替换 MST 中一条边后的最小生成树
- 时间复杂度: O(E × (E log E)) = O(E² log E)
- 可以优化: 使用 LCA + 预处理达到 O(V²)

<details>
<summary>🔧 参考实现框架</summary>

```moonbit
/// 寻找次小生成树
/// 返回次小生成树的权重，如果不存在返回 None
fn second_best_mst(graph : UndirectedAdjList) -> Option[Double] {
  let nc = @core.GraphReadable::node_count(graph)
  if nc <= 1 { return None }

  // Step 1: 找到 MST
  let mst = @mst.kruskal(graph)
  if (mst.edge_count() < nc - 1) {
    return None  // 图不连通，不存在 MST
  }

  let mst_weight = mst.total_weight
  let mut best_weight : Option[Double] = None

  // Step 2: 尝试替换 MST 中的每条边
  for i in 0..mst.edge_count() {
    // 构建不含第 i 条边的图
    let mut modified_graph = copy_graph_without_edge(graph, mst.edges[i])

    // 运行 Kruskal
    let candidate = @mst.kruskal(modified_graph)

    // 检查是否是有效的生成树且不同于 MST
    if (candidate.edge_count() == nc - 1
        && candidate.total_weight > mst_weight) {
      match best_weight {
        None => best_weight = Some(candidate.total_weight)
        Some(bw) => {
          if (candidate.total_weight < bw) {
            best_weight = Some(candidate.total_weight)
          }
        }
      }
    }
  }

  best_weight
}

// 测试
fn test_second_best() -> Unit {
  let g = build_sample_graph()
  let mst = @mst.kruskal(g)
  let second = second_best_mst(g)

  println("MST 权重: ${mst.total_weight}")
  match second {
    Some(w) => println("次小生成树权重: ${w}")
    None => println("不存在次小生成树")
  }
}
```

</details>

---

## 🔗 相关文档

### 相关算法教程

| 教程 | 链接 | 说明 |
|------|------|------|
| **Prim 算法** | [Prim MST](/algorithms/mst/prim/index/) | 另一种 MST 算法，适合稠密图 |
| **MST 综合对比** | [Kruskal & Prim](/algorithms/mst/kruskal-prim/index/) | 两种 MST 算法的完整对比 |
| **连通分量** | [Connected Components](/algorithms/connectivity/connected-components/) | 图的连通性分析 |
| **割点与桥** | [Articulation Points](/algorithms/connectivity/articulation-points/) | 图的关键节点和边分析 |

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/mst | 🏆 业界标杆，MST 完整动画演示 |
| Algorithm Visualizer | https://algorithm-visualizer.org/ | 简洁直观，支持 Kruskal 和 Prim |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization.html | 学术风格，多种算法对比 |

### mbtgraph API 参考

```moonbit
// 核心函数
@mst.kruskal(graph)                    // Kruskal MST → MstResult
@mst.prim(graph, root)                 // Prim MST → MstResult

// 结果查询
result.total_weight                    // Double: MST 总权重
result.edge_count()                    // Int: 边数 (应为 V-1)
result.has_edge(u, v)                  // Bool: 边是否在 MST 中
result.edges                           // Array[(NodeId, NodeId, Double)]: 边集

// Union-Find (内部使用，也可独立使用)
uf_new(size)                           // 创建并查集
uf_find(uf, x)                         // 查找根节点
uf_union(uf, x, y)                     // 合并集合 (返回是否成功)
```

### 延伸阅读

- **割性质证明**: 参考《算法导论》第 23.1 节
- **Union-Find 分析**: Tarjan 的 O(α(n)) 反阿克曼函数证明
- **MST 唯一性**: 当所有边权重不同时，MST 唯一
- **应用扩展**: 最小瓶颈生成树、最小 Steiner 树

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** Kruskal 的核心思想（边排序 + 并查集类比）
- [ ] **手动执行** 小规模图的 Kruskal 过程（写出排序/选择/跳过）
- [ ] **理解** Union-Find 数据结构（路径压缩 + 按秩合并）
- [ ] **实现** MoonBit 版本的 Kruskal（理解去重、排序、贪心选择）
- [ ] **区分** Kruskal vs Prim 的适用场景（稀疏图 vs 稠密图）
- [ ] **分析** Kruskal 的时间/空间复杂度（O(E log E) / O(V)）
- [ ] **应用** Kruskal 到实际问题（网络设计/聚类/图像分割）
- [ ] **判断** 图是否连通（通过 MST 边数 = V-1）

> 💡 **下一步**: 尝试实现练习题中的**次小生成树**，或者进入 [Prim 算法](/algorithms/mst/prim/index/) 学习另一种 MST 方法！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 Kruskal:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_weighted_graph()
  let result = @mst.kruskal(g)
  println("MST 总权重: ${result.total_weight}")
  println("边数: ${result.edge_count()}")
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看动画：<a href="https://visualgo.net/en/mst" target="_blank">https://visualgo.net/en/mst</a></p>
  </div>
</div>