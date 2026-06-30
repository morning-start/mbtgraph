---
title: Prim 算法
description: 基于切分定理的最小生成树算法详解：贪心生长策略、MoonBit 实现、复杂度分析、迷宫生成应用
---

# Prim 算法

> 🎯 **本节目标**: 掌握 Prim 算法的贪心生长思想、切分定理原理、MoonBit 实现及实际应用
>
> ⏱️ **预计阅读时间**: 25 分钟 | 🎮 **互动演示**: 可运行的最小生成树动画

## 📖 算法简介

**Prim 算法**是一种求解**最小生成树（Minimum Spanning Tree, MST）**的经典贪心算法，特别适合**稠密图**。

### 核心思想 💡

想象你在**种树时一颗一颗地接枝**：

```
🌱 Prim 生长过程类比:

步骤 0:   🌱 从种子开始        步骤 1:   🌱 长出最近的枝条
         (选定根节点)                       (选最近邻居加入)

           [A]                                [A]
           (种子)                            ╱
                                            [B] ← 最近!

步骤 2:   🌱 继续向外扩展       步骤 3:   🌱 枝繁叶茂
         总是选最近的节点                     (MST 完成)

           [A]                                [A]
          ╱  ╲                              ╱  ╲
       [B]   [D] ← 最近!                  [B]   [D]
         ╲                              ╱  ╲  ╱
          [C]                         [C]   [E]
```

Prim 就像"生长树"一样，**从根节点开始，逐步向外扩展**，每次选择连接已访问集合和未访问集合的最小权重边。

### 历史背景 📜

| 时间 | 事件 |
|------|------|
| 1930 | **Jarník** 首次提出该算法（又称 Jarník 算法） |
| 1957 | **Prim** 独立发现并发表 |
| 1958 | **Dijkstra** 再次独立发现 |

因此，Prim 算法也被称为 **Jarník-Prim 算法**。

### 切分定理（Cut Property）— 正确性基础

```
切分定理:
  对于图 G = (V, E) 的任意切分 (S, V\S)，
  权重最小的横跨边一定属于某个最小生成树。

直观理解:
  ┌─────────────────────┬─────────────────────┐
  │   集合 S (已访问)    │   集合 V\S (未访问)  │
  │   ┌───┐            │   ┌───┐            │
  │   │ A │            │   │ D │            │
  │   └─┬─┘            │   └─┬─┘            │
  │     ╳──(1)──────────────╳                 │  ← 最轻横跨边!
  │     ╳──(3)──────────────╳                 │  ← 更重的
  │     ╳──(7)───────────╳                    │  ← 最重的
  └─────────────────────┴─────────────────────┘

  Prim 每次选的就是这个"最轻横跨边"!
```

### 与 Kruskal 算法对比

| 维度 | **Prim** | **Kruskal** |
|------|----------|-------------|
| **核心思想** | **点优先**: 从根节点逐步扩展 | **边优先**: 按权重排序选边 |
| **数据结构** | 优先队列 / key[] 数组 | 排序 + Union-Find |
| **时间复杂度** | **O(V²)** (数组) 或 **O((V+E) log V)** (堆) | **O(E log E)** |
| **适用场景** | **稠密图** (E >> V) | **稀疏图** (E ≈ V) |
| **实现特点** | 维护 key[] 数组 + in_mst[] | 维护 Union-Find |
| **直观类比** | 🌱 生长树 (局部视角) | 🧵 选丝成网 (全局视角) |

### 核心操作：min-key 提取

Prim 的核心循环是重复 V 次：
1. **extract-min**: 从未访问节点中选 key 值最小的
2. **加入 MST**: 将该节点标记为已访问
3. **松弛邻居**: 更新该节点所有未访问邻居的 key 值

这就像 Dijkstra 算法的 extract-min 操作，但 key 的含义不同：
- **Prim**: key[v] = 连接 v 到 MST 的最小边权重
- **Dijkstra**: key[v] = 从起点到 v 的最短路径长度

---

## 🎬 交互式动画：Prim 分步执行过程

让我们通过一个具体例子来理解 Prim 的执行流程。**点击 ▶ 播放按钮或使用键盘方向键控制动画！**

### 示例图: 带权无向连通图

考虑以下 5 节点带权无向图：

```
示例图:

  [0] ───(6)─── [1]
   │╲            │╱
  (4) (2)      (8)(7)
   │  ╲         ╱
  [2] ───(5)── [3]
                │
               (9)
                │
               [4]

边列表: (0,1,6), (0,2,4), (0,3,2), (1,2,8), (1,3,7), (2,3,5), (3,4,9)
节点数 V=5, 边数 E=7
目标: 选出 4 条边 (V-1)，无环，总权重最小
```

<div class="viz-preview-card">
  <iframe src="/visualizations/prim/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/prim/" target="_blank" class="viz-fullscreen-btn">
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
| **深棕色** | 根节点（起点） |
| **绿色** | 已在 MST 中的节点 |
| **橙色** | 当前选中的节点（即将加入 MST） |
| **黄色** | 前沿节点（已发现但未访问） |
| **灰色** | 默认未访问状态 |
| **绿色粗线** | MST 边（已选中的边） |
| **黄色虚线** | 前沿边（候选边） |
| **灰色虚线** | 已跳过的边 |

### 预期结果

Prim 从节点 0 开始，贪心地选择最近的节点：

```
执行过程:
  Step 1: 选根节点 0 (key=0)
  Step 2: 选节点 3 (key=2) ← 边 (0,3,2)
  Step 3: 选节点 2 (key=4) ← 边 (0,2,4)
  Step 4: 选节点 1 (key=6) ← 边 (0,1,6)
  Step 5: 选节点 4 (key=9) ← 边 (3,4,9)

最终 MST 边集:
  1. (0, 3) 权重=2
  2. (0, 2) 权重=4
  3. (0, 1) 权重=6
  4. (3, 4) 权重=9

总权重: 2 + 4 + 6 + 9 = 21
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/mst/prim.mbt`）

```moonbit
///|
/// Prim 最小生成树算法
///
/// 从根节点出发的贪心生长算法，时间复杂度 O((V+E) log V)。
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

  // 边界检查：空图或无效根节点
  if nc == 0 || !@core.GraphReadable::contains_node(graph, root) {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }

  // 初始化数据结构
  let max_id = mst_find_max_id(graph)
  let size = max_int(max_id + 1, 1)

  let key : Array[Double?] = Array::make(size, None)    // 到 MST 的最小距离
  let parent : Array[@core.NodeId?] = Array::make(size, None)  // MST 中的父节点
  let in_mst : Array[Bool] = Array::make(size, false)   // 是否已在 MST 中

  key[root.0] = Some(0.0)  // 根节点距离为 0

  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0
  let mut count = 0

  // 主循环：重复 V 次（每次选一个节点加入 MST）
  while count < nc {
    // Step 1: 找到 key 最小的未访问节点
    let (u, found) = prim_min_key(key, in_mst, size)

    if !found {
      break  // 图不连通，无法继续
    }

    // Step 2: 将节点 u 加入 MST
    in_mst[u] = true

    // 记录 MST 边（如果不是根节点）
    match parent[u] {
      Some(p) =>
        match key[u] {
          Some(w) => {
            mst_edges.push((p, @core.NodeId(u), w))
            total_weight = total_weight + w
          }
          None => ()
        }
      None => ()  // 根节点没有父节点
    }

    // Step 3: 松弛 u 的所有邻居（更新 key[]）
    let unode = @core.NodeId(u)
    for vw in @core.GraphReadable::neighbors_with_weight(graph, unode) {
      match vw {
        (v, w) => {
          let vid = v.0
          // 只更新未在 MST 中的节点
          if vid >= 0 && vid < size && !in_mst[vid] {
            let should_update = match key[vid] {
              None => true                    // 首次发现
              Some(k) => w < k                // 找到更近的 MST 节点
            }
            if should_update {
              key[vid] = Some(w)      // 更新最小距离
              parent[vid] = Some(unode)  // 更新父节点
            }
          }
        }
      }
    }

    count = count + 1
  }

  // 返回结果
  MstResult::{ total_weight, edges: mst_edges }
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么用 `Array[Double?]` 而非 `Double` 表示 key？

```moonbit
// 使用 Double? (Option) 而非 Double 的原因:
//
// key[v] = None   → 节点 v 尚未被发现 (相当于 ∞)
// key[v] = Some(w) → 节点 v 到 MST 的最小距离为 w
//
// 这种设计避免了使用"魔法数"表示无穷大:
//   ❌ key[v] = 1e18  (不够大? 可能溢出)
//   ❌ key[v] = -1     (权重可能为负?)
//   ✅ key[v] = None  (语义清晰, 无歧义)
```

#### 2️⃣ 为什么用数组扫描代替优先队列？

```moonbit
// 当前实现: 数组线性扫描 O(V) 每次 → 总 O(V²)
//
// ✅ 优点:
//   - 无跨包依赖 (不需要导入 PriorityQueue 包)
//   - 代码简洁, 易于理解
//   - 对稠密图 (E ≈ V²)，O(V²) 并不比 O((V+E)log V) 差
//
// ❌ 缺点:
//   - 对稀疏图 (E ≈ V)，O(V²) 不如 O((V+E)log V)
//
// 优化方向: 使用二叉堆可将复杂度降至 O((V+E) log V)
```

#### 3️⃣ 为什么需要 `parent[]` 数组？

```moonbit
// parent[] 记录 MST 中的父子关系
//
// 作用:
//   1. 重建 MST 边集 (不用额外存储)
//   2. 查询 MST 中的路径
//   3. 验证 MST 的正确性
//
// 与 Dijkstra 的区别:
//   - Prim: parent[v] 记录的是 MST 中 v 的父节点
//   - Dijkstra: parent[v] 记录的是最短路径中 v 的前驱
```

#### 4️⃣ 结果类型 `MstResult`

```moonbit
/// 最小生成树结果类型
pub(all) struct MstResult {
  total_weight : Double                      // MST 总权重
  edges : Array[(@core.NodeId, @core.NodeId, Double)]  // MST 边集
}

/// 边数 (应为 V-1)
pub fn MstResult::edge_count(self : MstResult) -> Int

/// 判断某条边是否在 MST 中
pub fn MstResult::has_edge(self : MstResult, u : NodeId, v : NodeId) -> Bool
```

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 构建 MST 并输出结果

```moonbit
fn prim_basic_demo() -> Unit {
  // 构建带权无向图（与动画演示相同）
  let g = build_sample_weighted_graph()

  // 执行 Prim 算法（从节点 0 开始）
  let result = @mst.prim(g, @core.NodeId(0))

  // 输出结果
  println("=== Prim MST 结果 ===")
  println("总权重: ${result.total_weight}")
  println("边数: ${result.edge_count()}")

  // 输出 MST 边集
  println("\nMST 边集:")
  for (i, edge) in result.edges.indexed() {
    match edge {
      (u, v, w) => {
        println("  ${i + 1}. ${u} ───(${w})── ${v}")
      }
    }
  }
}

// 输出:
// === Prim MST 结果 ===
// 总权重: 21.0
// 边数: 4
//
// MST 边集:
//   1. NodeId(0) ───(2.0)── NodeId(3)
//   2. NodeId(0) ───(4.0)── NodeId(2)
//   3. NodeId(0) ───(6.0)── NodeId(1)
//   4. NodeId(3) ───(9.0)── NodeId(4)
```

### 示例 2: 🏰 Prim 迷宫生成器

```moonbit
/// 使用 Prim 算法生成随机迷宫
///
/// 思路:
/// 1. 将每个单元格视为节点
/// 2. 相邻单元格之间有边（权重 = 随机值）
/// 3. 运行 Prim 得到 MST
/// 4. MST 的边就是迷宫的通路
fn generate_maze_prim(rows : Int, cols : Int) -> Array[(Int, Int)] {
  // 构建网格图
  let total = rows * cols
  let mut grid = UndirectedAdjList::new_with_capacity(total, 0)

  // 添加节点
  let mut nodes : Array[NodeId] = []
  for r in 0..rows {
    for c in 0..cols {
      let node = @core.GraphWritable::add_node(grid, r * cols + c)
      nodes.push(node)
    }
  }

  // 添加随机权重的边（相邻单元格之间）
  let mut rng = Random::new(42)
  for r in 0..rows {
    for c in 0..cols {
      let idx = r * cols + c
      // 右邻居
      if (c + 1 < cols) {
        let w = rng.next_double()
        @core.GraphWritable::add_edge(grid, nodes[idx], nodes[idx + 1], w) |> ignore
      }
      // 下邻居
      if (r + 1 < rows) {
        let w = rng.next_double()
        @core.GraphWritable::add_edge(grid, nodes[idx], nodes[idx + cols], w) |> ignore
      }
    }
  }

  // 运行 Prim 算法（从左上角开始）
  let mst = @mst.prim(grid, nodes[0])

  // 返回迷宫通路（MST 的边）
  let passages : Array[(Int, Int)] = []
  for edge in mst.edges {
    match edge {
      (u, v, _) => {
        passages.push((u.0, v.0))
      }
    }
  }

  passages
}

// 可视化迷宫
fn print_maze(rows : Int, cols : Int, passages : Array[(Int, Int)]) -> Unit {
  // 构建通路集合以便快速查找
  let passage_set = Set::from_array(passages)

  println("🏰 生成的迷宫 (Prim 算法):")
  println("   入口: 左上角 [0,0]")
  println("   出口: 右下角 [${rows-1},${cols-1}]")
  println("")

  // 输出 ASCII 迷宫
  for r in 0..rows {
    // 上墙
    for c in 0..cols {
      print("+---")
    }
    println("+")

    // 单元格和左右墙
    for c in 0..cols {
      let idx = r * cols + c
      let has_right = passage_set.contains((idx, idx + 1))
      let wall = if (has_right) { " " } else { "|" }
      print("${wall}   ")
    }
    println("|")
  }

  // 底部墙
  for c in 0..cols {
    print("+---")
  }
  println("+")
}
```

### 示例 3: ⚔️ Prim vs Kruskal 对比分析

```moonbit
/// 同一张图，分别用 Prim 和 Kruskal 构建 MST，对比结果
fn compare_prim_vs_kruskal(graph : UndirectedAdjList) -> Unit {
  let nc = @core.GraphReadable::node_count(graph)
  let start = @core.NodeId(0)

  // 运行 Prim
  let prim_result = @mst.prim(graph, start)

  // 运行 Kruskal
  let kruskal_result = @mst.kruskal(graph)

  println("=== ⚔️ Prim vs Kruskal 对比 ===")
  println("")

  // 基本信息
  println("📊 基本信息:")
  println("  节点数: ${nc}")
  println("  Prim 开始节点: ${start}")
  println("")

  // 结果对比
  println("📈 结果对比:")
  println("  ┌────────────┬──────────────┬──────────────┐")
  println("  │    指标    │    Prim      │   Kruskal    │")
  println("  ├────────────┼──────────────┼──────────────┤")
  println("  │ 总权重     │ ${prim_result.total_weight.pad_end(12)} │ ${kruskal_result.total_weight.pad_end(12)} │")
  println("  │ 边数       │ ${prim_result.edge_count().to_string().pad_end(12)} │ ${kruskal_result.edge_count().to_string().pad_end(12)} │")
  println("  └────────────┴──────────────┴──────────────┘")
  println("")

  // 验证一致性
  if (prim_result.total_weight == kruskal_result.total_weight) {
    println("✅ 两种算法得到的 MST 总权重一致! (${prim_result.total_weight})")
  } else {
    println("⚠️ 结果不一致 (可能是图不连通)")
  }

  // 检查边集是否相同（不考虑顺序和方向）
  let prim_edges_normalized = normalize_edges(prim_result.edges)
  let kruskal_edges_normalized = normalize_edges(kruskal_result.edges)

  if (prim_edges_normalized == kruskal_edges_normalized) {
    println("✅ 边集完全相同（MST 唯一）")
  } else {
    println("ℹ️ 边集不同（存在多个等价的 MST）")
  }
}

/// 规范化边集（用于比较）
fn normalize_edges(
  edges : Array[(NodeId, NodeId, Double)]
) -> Array[(Int, Int, Double)] {
  let normalized : Array[(Int, Int, Double)] = []
  for edge in edges {
    match edge {
      (u, v, w) => {
        // 确保 u < v，消除方向影响
        if (u.0 < v.0) {
          normalized.push((u.0, v.0, w))
        } else {
          normalized.push((v.0, u.0, w))
        }
      }
    }
  }
  // 排序以便比较
  normalized.sort_by(fn(a, b) => {
    match a { (ua, va, _) => match b { (ub, vb, _) => {
      if (ua != ub) { ua.compare_to(ub) } else { va.compare_to(vb) }
    }}}
  })
  normalized
}
```

---

## 📈 复杂度分析

### 时间复杂度: O(V²)（数组实现）

| 操作 | 次数 | 复杂度 | 说明 |
|------|------|--------|------|
| 初始化数组 | 1 次 | O(V) | 创建 key/parent/in_mst |
| extract-min | V 次 | O(V) 每次 | 线性扫描找最小 key |
| 松弛邻居 | 总共 E 次 | O(1) 每次 | 每个邻居最多检查一次 |
| **总计** | | **O(V² + E)** ≈ **O(V²)** | E ≤ V²，所以 O(V²) 主导 |

### 不同实现方式的复杂度对比

| 实现方式 | extract-min | 松弛邻居 | 总时间 | 适用场景 |
|----------|-------------|----------|--------|----------|
| **数组扫描** | O(V) | O(1) | **O(V²)** | 稠密图 (mbtgraph 采用) |
| **二叉堆** | O(log V) | O(log V) | **O((V+E) log V)** | 稀疏图 |
| **斐波那契堆** | O(log V) | O(1)* | **O(E + V log V)** | 理论最优 |

> *斐波那契堆的 decrease-key 操作摊还 O(1)

### 空间复杂度: O(V)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `key[]` | O(V) | 到 MST 的最小距离 |
| `parent[]` | O(V) | MST 中的父节点 |
| `in_mst[]` | O(V) | 是否已在 MST 中 |
| **总计** | **O(V)** | |

### 与其他算法对比

| 算法 | 时间 | 空间 | 适用场景 |
|------|------|------|----------|
| **Prim** (数组) | O(V²) | O(V) | **稠密图** MST |
| **Prim** (堆) | O((V+E) log V) | O(V) | 稀疏图 MST |
| **Kruskal** | O(E log E) | O(V+E) | **稀疏图** MST |
| **Borůvka** | O(E log V) | O(V+E) | 并行 MST |

---

## 🎯 实际应用场景

### 应用 1: 🏰 迷宫生成

```
问题: 生成随机迷宫，保证入口到出口有且仅有一条路径

为什么适合 Prim:
  ✅ MST 天然生成树结构（无环 + 连通）
  ✅ 树结构保证任意两点间只有唯一路径
  ✅ 随机权重产生不规则的迷宫结构

算法步骤:
  1. 将网格单元格作为节点
  2. 相邻单元格之间有边（随机权重）
  3. 运行 Prim 得到 MST
  4. MST 的边打通 → 形成迷宫通道

特点:
  - 生成分支较多的迷宫（相比 DFS 生成的迷宫）
  - 路径短且蜿蜒，死胡同少
  - 游戏开发中常用
```

### 应用 2: 📡 网络设计与基础设施

```
问题类别: 最小成本连接问题 (Minimum Cost Connection)

典型应用:
  - 光纤网络铺设 (电信/ISP)
  - 电力网架设 (国家电网)
  - 自来水管道 (市政工程)
  - 铁路/公路规划 (交通)
  - 电路板布线 (PCB 设计)

实际考量:
  - 地理障碍 (河流/山脉增加成本)
  - 容量限制 (某些边有带宽上限)
  - 可靠性要求 (可能需要添加备份边)

为什么选 Prim:
  ✅ 天然支持从指定节点开始（如从中心机房出发）
  ✅ 增量式扩展，可动态添加新节点
  ✅ 适合稠密图（实际网络连接通常较密集）
```

### 应用 3: ⚡ 电路布线

```
问题: 在集成电路板上连接 N 个引脚，使导线总长度最短

建模:
  - 每个引脚 = 节点
  - 两个引脚间可走线 = 边
  - 走线长度 = 边权重 (曼哈顿距离)

为什么选 Prim:
  ✅ 芯片上引脚密集 (稠密图)，Prim O(V²) 优于 Kruskal O(E log E)
  ✅ 无需排序所有边（E 可能很大）
  ✅ 可从指定引脚开始，逐步扩展到所有引脚
```

### 应用 4: 🖼️ 图像分割

```
问题: 将图像像素分割成若干相似区域

方法: 基于图的图像分割
  1. 每个像素是一个节点
  2. 相邻像素的"不相似度"作为边权重
  3. 运行 Prim，在权重超过阈值时停止
  4. 每个连通分量 = 一个分割区域

优势:
  ✅ 不需要预先指定区域数量
  ✅ 自适应阈值
  ✅ 产生的分割具有全局一致性

应用: 医学影像分析、卫星遥感、目标检测预处理
```

---

## 🧪 练习题

### 练习 1: 手动执行 Prim ⭐⭐

对于以下带权无向图，从节点 A 开始执行 Prim 算法，写出：
1. 每一步选择的节点和对应的 key 值
2. key[] 数组的变化过程
3. 最终 MST 边集和总权重

```
    A ──(4)── B
   ╱│╲       │╱
 (2)(5)    (3)(6)
 ╱  │  ╲    ╱
C──(1)── D── E
    (7)
```

<details>
<summary>📝 点击查看答案</summary>

```
执行过程 (从 A 开始):

  Step 1: 选 A (key=0)
    key: A=0✓  B=4  C=2  D=5  E=∞

  Step 2: 选 C (key=2) ← 最小
    边: (A, C, 2)
    key: A=0✓  B=4  C=2✓  D=1  E=∞

  Step 3: 选 D (key=1) ← 最小
    边: (C, D, 1)
    key: A=0✓  B=3  C=2✓  D=1✓  E=6

  Step 4: 选 B (key=3)
    边: (D, B, 3)
    key: A=0✓  B=3✓  C=2✓  D=1✓  E=6

  Step 5: 选 E (key=6)
    边: (D, E, 6)

MST 边集:
  1. (A, C) 权重=2
  2. (C, D) 权重=1
  3. (D, B) 权重=3
  4. (D, E) 权重=6

总权重: 2 + 1 + 3 + 6 = 12
```

</details>

### 练习 2: 编程实现 - 验证 MST 唯一性 ⭐⭐⭐

给定一个图，判断其最小生成树是否**唯一**。

**提示**:
- 方法 1: 运行 Prim 和 Kruskal，比较边集是否相同
- 方法 2: 检查是否存在某个"割"有多条相同权重的横跨边
- 方法 3: 对 MST 中的每条边，尝试用同权重的非树边替换

<details>
<summary>💻 点击查看解答思路</summary>

```moonbit
/// 判断 MST 唯一性
/// 方法: 比较 Prim 和 Kruskal 的边集
fn is_mst_unique(graph : UndirectedAdjList) -> Bool {
  let prim_result = @mst.prim(graph, @core.NodeId(0))
  let kruskal_result = @mst.kruskal(graph)

  // 如果总权重不同 → 图不连通，得到森林
  if (prim_result.total_weight != kruskal_result.total_weight) {
    return false
  }

  // 规范化边集后比较
  let prim_edges = normalize_edges(prim_result.edges)
  let kruskal_edges = normalize_edges(kruskal_result.edges)

  prim_edges == kruskal_edges
}

/// 更严格的方法: 检查是否存在可替换的同权重边
fn has_alternative_mst(graph : UndirectedAdjList) -> Bool {
  let mst = @mst.prim(graph, @core.NodeId(0))

  // 对于 MST 中的每条边 e:
  //   找到权重相同的非树边，检查是否能替换
  for edge in mst.edges {
    match edge {
      (u, v, w) => {
        // 检查是否存在同权重的替代边
        // (需要遍历原图的所有边)
        // 如果存在 → MST 不唯一
      }
    }
  }

  false
}
```

</details>

### 练习 3: 进阶 - 使用 Prim 生成迷宫并可视化 ⭐⭐⭐⭐

**挑战**: 实现一个 10×10 的迷宫生成器，使用 Prim 算法，并以 ASCII 格式输出结果。

**要求**:
1. 构建 10×10 网格图，随机权重
2. 运行 Prim 得到 MST
3. 以 ASCII 格式打印迷宫（墙壁用 `│─` 表示，通道用空格表示）
4. 标记入口（左上角）和出口（右下角）
5. 验证从入口到出口有且仅有一条路径

**提示**:
- MST 是树结构，所以任意两点间只有唯一路径
- 入口和出口一定在 MST 中（MST 包含所有节点）
- 通道 = MST 的边，墙壁 = 非 MST 的边

<details>
<summary>🔧 参考实现框架</summary>

```moonbit
/// Prim 迷宫生成器
fn generate_and_print_maze() -> Unit {
  let rows = 10
  let cols = 10
  let total = rows * cols

  // 构建网格图
  let mut grid = UndirectedAdjList::new_with_capacity(total, 0)
  let mut nodes : Array[NodeId] = []

  for i in 0..total {
    let node = @core.GraphWritable::add_node(grid, i)
    nodes.push(node)
  }

  // 添加随机权重边
  let rng = Random::new(12345)
  for r in 0..rows {
    for c in 0..cols {
      let idx = r * cols + c
      if (c + 1 < cols) {
        let w = rng.next_double()
        @core.GraphWritable::add_edge(grid, nodes[idx], nodes[idx + 1], w) |> ignore
      }
      if (r + 1 < rows) {
        let w = rng.next_double()
        @core.GraphWritable::add_edge(grid, nodes[idx], nodes[idx + cols], w) |> ignore
      }
    }
  }

  // 运行 Prim
  let mst = @mst.prim(grid, nodes[0])

  // 转换为通道集合
  let passages = Set::new()
  for edge in mst.edges {
    match edge {
      (u, v, _) => {
        passages.add((u.0, v.0))
        passages.add((v.0, u.0))  // 双向
      }
    }
  }

  // 打印迷宫
  print_maze_ascii(rows, cols, passages)
  println("\n🏰 迷宫生成完成!")
  println("   入口: 左上角 | 出口: 右下角")
  println("   总通道数: ${mst.edge_count()}")
}

/// ASCII 打印迷宫
fn print_maze_ascii(
  rows : Int,
  cols : Int,
  passages : Set[(Int, Int)]
) -> Unit {
  // 上边界
  for c in 0..cols {
    print("+───")
  }
  println("+")

  for r in 0..rows {
    // 左墙 + 单元格
    for c in 0..cols {
      let idx = r * cols + c
      let has_right = passages.contains((idx, idx + 1))
      let has_bottom = passages.contains((idx, idx + cols))

      // 左墙
      if (c == 0) { print("│") }
      print("   ")

      // 右墙
      if (!has_right && c < cols - 1) { print("│") }
      else if (c < cols - 1) { print(" ") }
    }
    println("│")

    // 下墙
    for c in 0..cols {
      let idx = r * cols + c
      let has_bottom = passages.contains((idx, idx + cols))
      if (!has_bottom && r < rows - 1) { print("├───") }
      else if (r < rows - 1) { print("┐   ") }  // 简化版
      else { print("└───") }  // 最后一行底部
    }

    if (r == rows - 1) {
      println("┘")
    }
  }
}
```

</details>

---

## 🔗 相关文档

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/mst | 🏆 业界标杆，支持 Kruskal/Prim 对比模式 |
| Algorithm Visualizer | https://algorithm-visualizer.org/graphs/mst.html | 清晰的逐步执行动画 |
| USFCA Animation | https://www.cs.usfca.edu/~galles/visualization/Kruskal.html | 学术风格，支持手动步进 |

### 理论延伸阅读

- **最小生成树对比**: [Kruskal & Prim 对比详解](/algorithms/mst/kruskal-prim/)
- **Kruskal 算法**: [Kruskal 教程](/algorithms/mst/kruskal/)
- **最短路径**: [Dijkstra 教程](/algorithms/shortest-path/dijkstra/)（与 Prim 思想相似）
- **网络流**: [Edmonds-Karp](/algorithms/flow/edmonds-karp/)（最大流最小割定理）
- **连通性**: [Tarjan SCC](/algorithms/connectivity/tarjan-scc/)（基于 DFS）

### 经典教材推荐

| 书名 | 作者 | 推荐章节 |
|------|------|----------|
| *Introduction to Algorithms (CLRS)* | Cormen et al. | Ch.23 Minimum Spanning Trees |
| *Algorithms* | Sedgewick & Wayne | Ch.4.3 Minimum Spanning Trees |
| 算法导论（中文版） | 殷建平等译 | 第23章 最小生成树 |

### mbtgraph API 参考

```moonbit
// 核心函数
@mst.prim(graph, root)               // Prim 算法 (指定根节点) → MstResult
@mst.kruskal(graph)                  // Kruskal 算法 → MstResult

// 结果查询
result.total_weight                   // Double (MST 总权重)
result.edges                          // Array[(NodeId, NodeId, Double)]
result.edge_count()                   // Int (边数, 应为 V-1)
result.has_edge(u, v)                 // Bool (某条边是否在 MST 中)
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** Prim 的核心思想（生长树类比）
- [ ] **理解** 切分定理（Cut Property）及其在正确性证明中的作用
- [ ] **手动执行** 小规模图的 Prim 过程（写出 key[] 变化、选择顺序）
- [ ] **实现** MoonBit 版本的 Prim（理解 key[] 维护、min-key 提取、松弛操作）
- [ ] **区分** Prim vs Kruskal 的适用场景（稠密图 vs 稀疏图）
- [ ] **分析** Prim 的时间/空间复杂度（O(V²) / O(V)）
- [ ] **应用** Prim 到实际问题（迷宫生成/网络设计/电路布线/图像分割）

> 💡 **下一步**: 尝试实现练习题中的**迷宫生成器**，或者进入 [Kruskal 算法](/algorithms/mst/kruskal/) 学习另一种 MST 算法，对比两者的异同！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 Prim 算法:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_weighted_graph()
  let mst = @mst.prim(g, @core.NodeId(0))
  println("MST 总权重: ${mst.total_weight}")
  println("MST 边数: ${mst.edge_count()}")
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看 MST 动画：<a href="https://visualgo.net/en/mst" target="_blank">https://visualgo.net/en/mst</a></p>
    <p>💡 <strong>重点观察</strong>: Prim 如何像"生长树"一样从根节点逐步扩展到所有节点，每次选择的都是连接已访问集合和未访问集合的最小权重边。</p>
  </div>
</div>