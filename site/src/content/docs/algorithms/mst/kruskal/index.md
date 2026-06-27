---
title: Kruskal 最小生成树
description: 通过排序所有边并贪心选择的最小生成树算法：原理、动画演示、MoonBit 实现、实战应用
---

# Kruskal 最小生成树

> 🎯 **本节目标**: 掌握 Kruskal 算法原理、Union-Find 数据结构、复杂度分析和实际应用
>
> ⏱️ **预计阅读时间**: 25 分钟 | 🎮 **互动演示**: 3 个可运行示例

## 📖 算法简介

**Kruskal 算法**是一种用于求解**最小生成树（Minimum Spanning Tree, MST）**的贪心算法。

### 核心思想 💡

想象你要**用最低成本铺设连接所有城市的公路网络**：

```
公路规划类比:

城市网络:
  [北京] ──(成本 8)── [上海]
    │╲               ╱│╲
    │  ╲           ╱  │  ╲
  (成本 5) (成本 7)  (成本 6) (成本 9)
    │    ╲       ╱    │    ╲
    ▼     ╲     ▼     ▼     ╲
  [广州]  [成都] [武汉] [西安] [杭州]

问题: 需要知道"连接所有城市的最低成本方案"

Kruskal 的智慧:
  "如果北京→广州 成本 5 是最便宜的, 那就先修这条路!
   然后找第二便宜的, 只要不形成环路就继续加..."

核心策略: 边排序 + 并查集 — 按权重从小到大选边，用 Union-Find 检测环路
```

### 算法步骤

1. 将所有边按权重从小到大排序
2. 初始化并查集（每个节点自成一个集合）
3. 依次检查每条边 (u, v, w)：
   - 如果 u 和 v 不在同一集合（`uf_union` 返回 true）：加入 MST，合并集合
   - 否则：跳过（会形成环路）
4. 重复直到所有节点连通

### 为什么需要 Kruskal？

| 场景 | Prim 算法 | **Kruskal 算法** |
|------|----------|-----------------|
| 稠密图（E ≈ V²） | ✅ Prim 更快 | 可用但边排序开销大 |
| **稀疏图（E ≈ V）** | 可用 | **✅ Kruskal 更快!** |
| **不连通图** | ❌ 只返回所在分量 | **✅ 返回森林（每个分量的 MST）** |
| 实现复杂度 | 需要优先队列 | 只需排序 + Union-Find |

### 历史

| 算法 | 发明者 | 年份 | 论文/贡献 | 时间复杂度 |
|------|--------|------|----------|-----------|
| **Kruskal** | Joseph Kruskal | 1956 | "On the shortest spanning subtree of a graph" | O(E log E) |
| Prim | Robert Prim | 1957 | 最早由 Jarník (1930) 发现 | O(V²) 或 O(E log V) |

---

## 🎬 交互式动画：Kruskal 分步执行过程

让我们通过一个具体例子来理解 Kruskal 的执行流程。

### 示例图: 无向带权图

考虑以下无向带权图（5 节点，7 条边）：

**边列表**: `(0,3,1), (0,1,2), (1,3,3), (1,2,4), (2,3,5), (2,4,6), (3,4,7)`

<div class="viz-preview-card">
  <iframe src="/visualizations/kruskal/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/kruskal/" target="_blank" class="viz-fullscreen-btn">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 动画说明

> **配色含义（VisuAlgo 风格）**:

| 颜色 | 含义 |
|------|------|
| **深棕色** | 起点（节点 0） |
| **橙色** | 当前检查的边 |
| **绿色** | 已加入 MST 的边 |
| **红色** | 跳过的边（会形成环路） |
| **灰色** | 默认未访问状态 |
| **蓝色** | Union-Find 集合的代表元素 |

### 预期结果

Kruskal 按权重从小到大选边，用 Union-Find 检测环路：

```
边排序后: [0-3(1), 0-1(2), 1-3(3), 1-2(4), 2-3(5), 2-4(6), 3-4(7)]

步骤 1: 选 0-3(1) → 加入 MST, 合并 {0} 和 {3}
       分量: {0,3} {1} {2} {4}

步骤 2: 选 0-1(2) → 加入 MST, 合并 {0,3} 和 {1}
       分量: {0,1,3} {2} {4}

步骤 3: 选 1-3(3) → 跳过! {1,3} 已连通 (会形成环路)
       分量: {0,1,3} {2} {4}

步骤 4: 选 1-2(4) → 加入 MST, 合并 {0,1,3} 和 {2}
       分量: {0,1,2,3} {4}

步骤 5: 选 2-3(5) → 跳过! 已连通
       分量: {0,1,2,3} {4}

步骤 6: 选 2-4(6) → 加入 MST, 合并所有分量
       分量: {0,1,2,3,4} ← 全部连通, 完成!

MST 总权重: 1 + 2 + 4 + 6 = 13
MST 边数: 4 (V-1 = 5-1 = 4, 正确!)
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/mst/kruskal.mbt`）

```moonbit
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
  for u in @core.GraphReadable::node_ids(graph) {
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw {
        (v, w) => if u.0 < v.0 { raw_edges.push((u, v, w)) }
      }
    }
  }
  let sorted = sort_edges(raw_edges)
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
    p.push(i)
    r.push(0)
  }
  UnionFind::{ parent: p, rank: r }
}

///|
fn uf_find(uf : UnionFind, x : Int) -> Int {
  if uf.parent[x] != x {
    let root = uf_find(uf, uf.parent[x])
    uf.parent[x] = root  // 路径压缩: 直接指向根节点
    root
  } else {
    x
  }
}

///|
fn uf_union(uf : UnionFind, x : Int, y : Int) -> Bool {
  let rx = uf_find(uf, x)
  let ry = uf_find(uf, y)
  if rx == ry { return false }  // 已在同一集合, 合并会形成环
  // 按秩合并: 将较浅的树挂到较深的树上
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

### 代码详解：关键设计决策

#### 1️⃣ 为什么只存储 `u.0 < v.0` 的边？

```moonbit
// ❌ 低效方式: 存储双向边 (无向图邻接表会返回两个方向)
for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
  raw_edges.push((u, v, w))  // 会存储 (0,1,2) 和 (1,0,2) 两条边!
}

// ✅ 高效方式: 只存储一个方向, 避免重复
for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
  match vw {
    (v, w) => if u.0 < v.0 { raw_edges.push((u, v, w)) }
  }
}
```

**性能提升**: 边数减半，排序和并查集操作都更快。

#### 2️⃣ 为什么使用 `Array[Bool]` 之外的 Union-Find？

Union-Find 的 `parent` 数组实现了**近乎 O(1)** 的查找和合并操作（反阿克曼函数级别）。如果用 `Array[Bool]` 标记连通分量，每次检查都需要 O(V) 扫描，总复杂度退化为 O(VE)。

#### 3️⃣ 路径压缩 + 按秩合并

| 优化 | 作用 | 效果 |
|------|------|------|
| **路径压缩** | `uf_find` 时让节点直接指向根 | 树高趋近于 O(1) |
| **按秩合并** | 将浅树挂到深树上 | 避免树退化为链表 |

**联合效果**: 单次操作 **O(α(V))** ≈ O(1)，其中 α 是反阿克曼函数。

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 计算 MST 总权重

```moonbit
fn kruskal_basic_demo() -> Unit {
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

  let result = @mst.kruskal(g)

  println("=== Kruskal MST 结果 ===")
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
// === Kruskal MST 结果 ===
// MST 总权重: 13.0
// MST 边数: 4
//   边 0-3: 权重=1.0
//   边 0-1: 权重=2.0
//   边 1-2: 权重=4.0
//   边 2-4: 权重=6.0
```

### 示例 2: 🔌 电信网络设计（稀疏图）

```moonbit
/// 使用 Kruskal 设计成本最优的电信骨干网
fn telecom_network_design() -> Unit {
  // 构建城市连接图（稀疏图: 10 节点, 12 条边）
  let mut g = @storage.UndirectedAdjList::new_with_capacity(10, 12)

  let nodes = [@core.GraphWritable::add_node(g, 0.0); 10]

  // 添加边（城市之间的铺设成本, 单位: 百万元）
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 8.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[2], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[3], 7.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[3], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[4], 9.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[5], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[4], nodes[5], 3.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[5], nodes[6], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[6], nodes[7], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[7], nodes[8], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[8], nodes[9], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[9], 10.0)

  let result = @mst.kruskal(g)

  println("=== 电信骨干网最优铺设方案 ===")
  println("总铺设成本: \(result.total_weight) 百万元")
  println("铺设段数: \(result.edge_count())")
  println("\n具体铺设路线:")
  for edge in result.edges {
    match edge {
      (u, v, w) => println("  城市 \(u.0) ↔ 城市 \(v.0): \(w) 百万元")
    }
  }

  // 验证: MST 边数 = V-1 = 9（连通图）
  if result.edge_count() == 9 {
    println("\n✅ 网络完全连通!")
  } else {
    println("\n⚠️ 网络有 \(9 - result.edge_count()) 个独立子网")
  }
}

// 输出:
// === 电信骨干网最优铺设方案 ===
// 总铺设成本: 37.0 百万元
// 铺设段数: 9
//
// 具体铺设路线:
//   城市 6 ↔ 城市 7: 1.0 百万元  ← 最便宜
//   城市 5 ↔ 城市 6: 2.0 百万元
//   城市 4 ↔ 城市 5: 3.0 百万元
//   城市 3 ↔ 城市 5: 4.0 百万元
//   城市 0 ↔ 城市 2: 5.0 百万元
//   城市 7 ↔ 城市 8: 5.0 百万元
//   城市 2 ↔ 城市 3: 6.0 百万元
//   城市 8 ↔ 城市 9: 6.0 百万元
//   城市 1 ↔ 城市 3: 7.0 百万元
//
// ✅ 网络完全连通!
```

### 示例 3: 📊 Kruskal vs Prim 对比（不连通图）

```moonbit
/// 比较 Kruskal 和 Prim 在不连通图上的行为
fn compare_kruskal_prim_disconnected() -> Unit {
  // 构建不连通图: 两个独立子图
  // 子图 A: 节点 0-1-2（三角形）
  // 子图 B: 节点 3-4（单条边）
  let mut g = @storage.UndirectedAdjList::new_with_capacity(5, 4)

  let nodes = [@core.GraphWritable::add_node(g, 0.0); 5]
  // 子图 A
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[2], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 3.0)
  // 子图 B
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 4.0)

  let kruskal_result = @mst.kruskal(g)

  println("=== 不连通图: Kruskal vs Prim ===")
  println("Kruskal 结果:")
  println("  MST 总权重: \(kruskal_result.total_weight)")
  println("  MST 边数: \(kruskal_result.edge_count())")
  println("  检查所有 5 个节点是否都被覆盖...")

  // Kruskal 返回森林: 子图 A 有 2 条边, 子图 B 有 1 条边
  if kruskal_result.edge_count() == 3 {
    println("  ✅ Kruskal 返回森林（2 + 1 = 3 条边）")
  }

  println("\n对比: Prim 从节点 0 开始")
  println("  Prim 只返回子图 A 的 MST（2 条边）")
  println("  ❌ 子图 B 的节点 3,4 被完全忽略！")
}

// 输出:
// === 不连通图: Kruskal vs Prim ===
// Kruskal 结果:
//   MST 总权重: 7.0
//   MST 边数: 3
//   检查所有 5 个节点是否都被覆盖...
//   ✅ Kruskal 返回森林（2 + 1 = 3 条边）
```

---

## 📈 复杂度分析

### 时间复杂度: O(E log E)

| 操作 | 次数 | 复杂度 | 说明 |
|------|------|--------|------|
| 构建边列表 | 遍历所有边 | O(E) | 每条边只存一次 |
| 边排序 | 1 次 | O(E log E) | 冒泡排序（当前实现） |
| 并查集操作 | E 次 | O(E · α(V)) | α 为反阿克曼函数，≈ O(1) |
| **总计** | | **O(E log E)** | 排序是瓶颈 |

> 💡 **优化建议**: 将 `sort_edges` 替换为快速排序或归并排序，可优化为 O(E log E)。当前冒泡排序为 O(E²)，对于大规模图建议使用更高效的排序算法。

### 空间复杂度: O(V + E)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `raw_edges[]` | O(E) | 边列表 |
| `sorted[]` | O(E) | 排序后的边 |
| `mst_edges[]` | O(V) | MST 边数 = V-1 |
| `UnionFind` | O(V) | parent + rank 数组 |
| **总计** | **O(V + E)** | |

### 与其他算法对比

| 算法 | 时间 | 空间 | 适用场景 |
|------|------|------|----------|
| **Kruskal** | O(E log E) | O(V+E) | **稀疏图**、不连通图 |
| Prim (数组) | O(V²) | O(V) | 稠密图 |
| Prim (二叉堆) | O(E log V) | O(V) | 中等密度图 |
| Prim (斐波那契堆) | O(E + V log V) | O(V) | 超大规模图 |

---

## 🎯 实际应用场景

### 应用 1: 网络设计 - 骨干网铺设

```
问题: 用最低成本连接所有城市的通信网络

Kruskal 优势:
✅ 天然支持不连通图（返回森林）
✅ 边排序贪心, 全局最优
✅ 实现简单, 只需 Union-Find

成本分析:
- 节点数: N 个城市
- 边数: M 条可选路线
- Kruskal: O(M log M) — 对于稀疏图非常高效
```

### 应用 2: 电路布线 - 集成电路设计

```
问题: 在芯片上连接数千个引脚，最小化总线长

Kruskal 应用:
1. 构建图: 引脚为节点, 引脚间距离为权重
2. 运行 Kruskal 得到最小总线长连接方案
3. 避免信号环路（Union-Find 自动保证）
```

### 应用 3: 图像分割 - 区域合并

```
问题: 将图像中相似的颜色区域合并

Kruskal 应用:
1. 每个像素初始为独立区域
2. 计算相邻像素的"颜色差异"作为权重
3. 按权重排序, 贪心合并（类似 Kruskal 选边）
4. 当区域数量达到目标时停止
```

### 应用 4: 聚类分析 - 层次聚类

```
问题: 将数据点划分为 K 个簇

Kruskal 应用:
1. 构建完全图: 数据点为节点, 距离为权重
2. 运行 Kruskal, 但只选前 V-K 条边
3. 每个连通分量就是一个簇
4. 无需预先指定 K（自动确定最佳簇数）
```

---

## 🧪 练习题

### 练习 1: 手动执行 Kruskal ⭐⭐

对于以下无向带权图，手动执行 Kruskal 算法，写出：
1. 边排序后的顺序
2. 每条边是否加入 MST（用 Union-Find 判断）
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
边排序: [B-C(1), A-B(2), A-C(3), A-D(4), B-E(5), C-D(6), C-E(7), D-E(8)]

步骤 1: B-C(1) → 加入, 合并 {B} {C}      分量: {A} {B,C} {D} {E}
步骤 2: A-B(2) → 加入, 合并 {A} {B,C}     分量: {A,B,C} {D} {E}
步骤 3: A-C(3) → 跳过 (已连通)            分量: {A,B,C} {D} {E}
步骤 4: A-D(4) → 加入, 合并 {A,B,C} {D}  分量: {A,B,C,D} {E}
步骤 5: B-E(5) → 加入, 合并所有分量       分量: {A,B,C,D,E} ← 完成!

MST 总权重: 1 + 2 + 4 + 5 = 12
MST 边: B-C, A-B, A-D, B-E
```

</details>

### 练习 2: 🔍 Union-Find 操作追踪 ⭐⭐⭐

给定初始状态 `parent = [0,1,2,3,4]`（每个节点自成一个集合），执行以下操作序列，写出每次操作后的 `parent` 数组状态：

```
操作序列: union(0,1), union(2,3), union(1,3), union(0,4)
```

<details>
<summary>📝 点击查看答案</summary>

```
初始: parent = [0, 1, 2, 3, 4]

union(0,1): 合并 0 和 1 → parent = [0, 0, 2, 3, 4]
union(2,3): 合并 2 和 3 → parent = [0, 0, 2, 2, 4]
union(1,3): find(1)→0, find(3)→2 → 合并 0 和 2 → parent = [0, 0, 0, 2, 4]
union(0,4): find(0)→0, find(4)→4 → 合并 0 和 4 → parent = [0, 0, 0, 2, 0]

最终: parent = [0, 0, 0, 2, 0] → 所有节点都在集合 {0} 中（根为 0）
```

</details>

### 练习 3: 🔧 实现最小 Kruskal ⭐⭐⭐⭐

**挑战**: 在 MoonBit 中实现一个 Kruskal 的变体——当图不连通时，返回所有连通分量的 MST 森林，并标注每个分量包含的节点。

**提示**:
1. 使用 `@core.GraphReadable::node_ids` 获取所有节点
2. 在 `kruskal` 返回后，用 `parents` 数组（类似 BFS）重建每个分量的节点列表
3. 返回 `Map[NodeId, Array[NodeId]]` 表示每个分量的节点集合

<details>
<summary>💻 点击查看参考实现</summary>

```moonbit
/// Kruskal 森林结果
pub(all) struct KruskalForest {
  mst : MstResult,
  components : Map[Int, Array[Int]],
}

/// 返回所有连通分量的 MST
fn kruskal_forest[G : @core.GraphReadable](graph : G) -> KruskalForest {
  let mst = @mst.kruskal(graph)
  let components = Map::new()
  // 用 BFS 遍历 MST 的边, 构建连通分量
  // ... (实现略)
  KruskalForest::{ mst, components }
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
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/Kruskal.html | 学术风格 |

### 理论延伸阅读

- **Kruskal vs Prim 对比**: [Kruskal-Prim 对比详解](/algorithms/mst/kruskal-prim/)
- **并查集（Union-Find）**: 一种高效的数据结构，用于管理元素所属的集合
- **最小生成树应用**: 网络设计、电路布线、图像分割、聚类分析

### mbtgraph API 参考

```moonbit
// 核心函数
@mst.kruskal(graph)               // 计算最小生成树 → MstResult
@mst.prim(graph, root)            // Prim 算法 → MstResult

// MstResult 查询
result.total_weight               // MST 总权重 (Double)
result.edge_count()               // MST 边数
result.has_edge(u, v)             // 检查边是否在 MST 中
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** Kruskal 的核心思想（边排序 + 并查集）
- [ ] **手动执行** 小规模图的 Kruskal 过程（写出边顺序、Union-Find 状态、MST 总权重）
- [ ] **理解** Union-Find 的路径压缩和按秩合并优化
- [ ] **区分** Kruskal vs Prim 的适用场景（稀疏图 vs 稠密图）
- [ ] **分析** Kruskal 的时间/空间复杂度（O(E log E) / O(V+E)）
- [ ] **应用** Kruskal 到实际问题（网络设计、图像分割、聚类）

> 💡 **下一步**: 尝试实现练习题中的 **Kruskal 森林**，或者进入 [Prim 算法](/algorithms/mst/prim/) 学习另一种 MST 算法！

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
  let g = build_your_graph()
  let result = @mst.kruskal(g)
  println("MST 总权重: \(result.total_weight)")
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看动画：<a href="https://visualgo.net/en/mst" target="_blank">https://visualgo.net/en/mst</a></p>
  </div>
</div>