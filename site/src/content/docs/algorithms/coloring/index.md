---
title: 图着色算法 (Graph Coloring)
description: 图的贪心着色算法详解：原理、动画演示、MoonBit 实现、实战应用
---

# 图着色算法 (Graph Coloring)

> 🎯 **本节目标**: 掌握贪心着色算法原理、实现步骤、复杂度分析和实际应用
>
> ⏱️ **预计阅读时间**: 20 分钟 | 🎮 **互动演示**: 可运行可视化示例

## 📖 算法简介

**图着色（Graph Coloring）** 是为图的每个节点分配一种颜色，使得任意两个相邻节点的颜色不同。目标是使用**最少**的颜色数（称为**色数 χ(G)**）。

### 核心思想 💡

想象你在**给一张地图涂色**：

```
    WA ─── NT ─── SA ─── Q ─── NSW
     \     |     / \     |     /
      \    |    /   \    |    /
       \   |   /     \   |   /
        \  |  /       \  |  /
         \ | /         \ | /
          \|/           \|/
           V             V
          WA            VIC

目标: 相邻区域颜色不同，且使用最少颜色数
```

图着色就像给地图涂色一样 — **相邻节点（区域）必须使用不同颜色**，我们的目标是用尽可能少的颜色完成着色。

### 历史背景 📜

| 年份 | 事件 |
|------|------|
| 1852 年 | Francis Guthrie 提出**四色定理**：任何地图最多只需 4 种颜色 |
| 1879 年 | Kempe 发表第一个证明（后被发现有误） |
| 1976 年 | Appel & Haken 借助计算机首次证明四色定理（1200 小时计算） |
| 1996 年 | Robertson 等人给出更简洁的计算机证明 |
| 2005 年 | Gonthier 形式化验证四色定理（Coq 证明助手） |

> 🎨 **四色定理**: 任何平面图的色数 ≤ 4。但图着色问题的一般形式（判断 χ(G) ≤ k）是 **NP-Complete** 的！

### 贪心着色 vs 回溯精确着色

| 特性 | 贪心着色 (Greedy) | 回溯法 (Backtracking) |
|------|-------------------|----------------------|
| **时间复杂度** | O(V²) — 多项式 | O(k^V) — 指数级 |
| **解的质量** | 近似解（≤ Δ+1 种颜色） | **最优解**（真实色数） |
| **适用规模** | 任意规模（百万节点） | 小规模图（~30 节点） |
| **实现难度** | 简单 | 较复杂（剪枝优化） |
| **使用场景** | 实时应用、大规模图 | 小规模精确求解 |

### 核心操作：贪心策略

贪心着色的规则非常简单：

```
对于每个节点（按某种顺序）:
  1. 查看所有邻居已经使用的颜色
  2. 选择最小的、未被邻居使用的颜色
  3. 分配给当前节点
```

> 💡 **关键洞察**: 贪心着色**保证合法着色**（相邻不同色），但颜色数**不一定最优**。最坏情况下使用 **Δ+1** 种颜色（Δ 为图的最大度数）。

---

## 🎬 交互式动画：贪心着色分步执行过程

让我们通过一个具体例子来理解贪心着色的执行流程。**点击 ▶ 播放按钮观察动画！**

### 示例图: 澳大利亚地图着色

考虑澳大利亚 6 个州/领地的邻接关系（经典地图着色案例）：

**边列表**: `(0,1), (0,2), (1,2), (1,3), (2,3), (2,4), (2,5), (3,4), (4,5)`

> 0=WA(西澳), 1=NT(北领地), 2=SA(南澳), 3=Q(昆士兰), 4=NSW(新州), 5=VIC(维州)

<div class="viz-preview-card">
  <iframe src="/visualizations/coloring/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/coloring/" target="_blank" class="viz-fullscreen-btn">
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
| **灰色** | 未着色（尚未处理） |
| **橙色** | 正在处理（当前着色节点） |
| **绿色** | 已着色完成 |
| **红色标记** | 冲突检测（如果相邻同色会出现） |
| **彩色节点** | 已分配的颜色（不同颜色代表不同编号） |

### 预期结果

贪心着色按节点 ID 顺序 0,1,2,3,4,5 依次处理：

```
着色顺序: WA→NT→SA→Q→NSW→VIC
颜色分配: WA:0, NT:1, SA:2, Q:1, NSW:0, VIC:2
使用颜色数: 3 种
```

> ⚠️ **注意**: 澳大利亚地图实际只需 3 种颜色（因为它是 3-可着色的），贪心着色在此恰好达到最优。但对于其他图，贪心可能使用比最优更多的颜色。

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/coloring/coloring.mbt`）

```moonbit
///|
/// 贪心着色算法（按节点 ID 自然顺序）
///
/// 按 0, 1, 2, ..., V-1 的顺序依次为每个节点选择最小可用颜色。
/// 这是最简单快速的着色启发式，适用于对解的质量要求不高的场景。
pub fn[G : @core.GraphReadable] greedy_coloring(graph : G) -> ColoringResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return build_result([], graph)
  }
  let colors : Array[Int] = Array::make(n, -1)
  let mut u = 0
  while u < n {
    let used = collect_used_colors(graph, colors, u)
    colors[u] = find_min_available_color(used)
    u = u + 1
  }
  build_result(colors, graph)
}
```

### 辅助函数详解

#### 1. 收集邻居已使用颜色 — `collect_used_colors`

```moonbit
/// 收集节点 u 的邻居中已使用的颜色集合
fn[G : @core.GraphReadable] collect_used_colors(
  g : G,
  colors : Array[Int],
  u : Int,
) -> Array[Bool] {
  let used : Array[Bool] = []
  let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(u))
  for neighbor in neighbors {
    let vi = neighbor.0
    if vi >= 0 && vi < colors.length() && colors[vi] >= 0 {
      let c = colors[vi]
      while used.length() <= c {
        used.push(false)
      }
      used[c] = true
    }
  }
  used
}
```

> 💡 **设计技巧**: 使用 `Array[Bool]` 作为哈希集合，索引即颜色编号，实现 O(1) 查询。动态扩容（`while used.length() <= c`）保证不会越界。

#### 2. 找到最小可用颜色 — `find_min_available_color`

```moonbit
/// 找到最小可用颜色（不在 used 集合中的最小非负整数）
fn find_min_available_color(used : Array[Bool]) -> Int {
  let mut c = 0
  while c < used.length() {
    if !used[c] {
      return c
    }
    c = c + 1
  }
  c
}
```

> 🎯 **核心逻辑**: 从 0 开始逐个检查，找到第一个 `used[c] == false` 的位置。如果所有 0..n-1 都被占用，返回 n（新颜色）。

#### 3. 验证着色合法性 — `validate_coloring`

```moonbit
/// 验证着色方案是否合法（相邻节点不同色）
fn[G : @core.GraphReadable] validate_coloring(
  g : G,
  colors : Array[Int],
) -> Bool {
  let n = @core.GraphReadable::node_count(g)
  let mut u = 0
  while u < n {
    if colors[u] < 0 {
      return false
    }
    let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(u))
    for neighbor in neighbors {
      let vi = neighbor.0
      if vi >= 0 && vi < n && colors[u] == colors[vi] {
        return false
      }
    }
    u = u + 1
  }
  true
}
```

#### 4. 结果类型定义

```moonbit
/// 图着色结果
pub(all) struct ColoringResult {
  colors : Array[Int],     // colors[i] = 节点 i 的颜色编号（0-based）
  num_colors : Int,        // 使用的颜色总数
  is_valid : Bool,         // 着色是否合法（相邻节点不同色）
}
```

### 代码详解：关键设计决策

#### 1️⃣ 为什么用 `Array[Bool]` 而不是 `Set`？

```moonbit
// ✅ 当前方案: 用布尔数组当哈希集合
// 颜色编号是 0..n-1 的整数，直接用数组索引
let used : Array[Bool] = []
// used[c] == true 表示颜色 c 已被邻居使用
// 查询: O(1)  插入: O(1)（动态扩容）

// ❌ 如果用 Set 结构
// 查询: O(1) 平均但常数更大
// 对于这种密集整数键，Array[Bool] 更快更省
```

**优势**: 颜色编号天然是连续整数，用数组做哈希是最优选择。

#### 2️⃣ 贪心着色的顺序变体

```moonbit
// 变体 1: 按 ID 自然顺序（最简单）
pub fn[G : @core.GraphReadable] greedy_coloring(graph : G) -> ColoringResult { ... }

// 变体 2: 按指定顺序（可自定义优化）
pub fn[G : @core.GraphReadable] greedy_coloring_with_order(
  graph : G,
  order : Array[Int],
) -> ColoringResult { ... }

// 变体 3: Welsh-Powell（按度数降序）
pub fn[G : @core.GraphReadable] welsh_powell(graph : G) -> ColoringResult { ... }

// 变体 4: DSATUR（饱和度优先，质量最高）
pub fn[G : @core.GraphReadable] dsatur_coloring(graph : G) -> ColoringResult { ... }
```

#### 3️⃣ 为什么不保证最优？

```
反例：W_6 轮图（5 个外围节点 + 1 个中心节点）

  1 ─── 2
 / \   / \
5   0   3
 \ /   /
  4 ───

按顺序 0,1,2,3,4,5:
  节点 0 → 颜色 0
  节点 1 → 颜色 1（邻接 0）
  节点 2 → 颜色 2（邻接 0,1）
  节点 3 → 颜色 1（邻接 0,2，不邻接 1）
  节点 4 → 颜色 2（邻接 0,3，不邻接 2）
  节点 5 → 颜色 3（邻接 0,1,2,4）

结果: 用了 4 种颜色，但最优只需 3 种！
```

> ⚠️ **贪心着色的近似比**: 最多使用 **Δ+1** 种颜色（Δ 为最大度数）。实际效果通常远好于这个上界。

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 贪心着色并输出结果

```moonbit
import "morning-start/mbtgraph/lib/core" as @core
import "morning-start/mbtgraph/lib/storage" as @storage
import "morning-start/mbtgraph/lib/algo/coloring" as @coloring

fn greedy_coloring_basic() -> Unit {
  // 构建示例图：五边形（奇环，需要 3 种颜色）
  let g = @storage.new_undirected()

  // 添加 5 个节点
  for i in 0..<5 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加环边
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(0), 1.0)

  // 执行贪心着色
  let result = @coloring.greedy_coloring(g)

  println("=== 贪心着色结果 ===")
  println("使用颜色数: ${result.num_colors}")
  println("着色合法: ${result.is_valid}")

  // 输出每个节点的颜色
  for i in 0..result.colors.length() {
    println("节点 ${i} → 颜色 ${result.colors[i]}")
  }
}

// 输出:
// === 贪心着色结果 ===
// 使用颜色数: 3
// 着色合法: true
// 节点 0 → 颜色 0
// 节点 1 → 颜色 1
// 节点 2 → 颜色 2
// 节点 3 → 颜色 0
// 节点 4 → 颜色 1
```

### 示例 2: 🗺️ 地图着色（澳大利亚六州）

```moonbit
/// 创建澳大利亚地图图
///     WA(0) --- NT(1) --- SA(2) --- Q(3) --- NSW(4)
///       \        |        / \         |       /
///        \       |       /   \        |      /
///         \      |      /     \       |     /
///             VIC(5) ———————————————
fn create_australia_map() -> UndirectedAdjList {
  let g = @storage.new_undirected()

  // 添加 6 个州/领地
  for i in 0..<6 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加边界（边）
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) // WA-NT
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0) // WA-SA
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) // NT-SA
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0) // NT-Q
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) // SA-Q
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(4), 1.0) // SA-NSW
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(5), 1.0) // SA-VIC
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0) // Q-NSW
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0) // NSW-VIC

  g
}

/// 比较不同着色算法的效果
fn compare_coloring_algorithms() -> Unit {
  let g = create_australia_map()
  let state_names = ["WA", "NT", "SA", "Q", "NSW", "VIC"]

  println("=== 澳大利亚地图着色 ===\n")

  // 贪心着色
  let greedy = @coloring.greedy_coloring(g)
  println("贪心着色: ${greedy.num_colors} 种颜色")
  for i in 0..greedy.colors.length() {
    println("  ${state_names[i]}: 颜色 ${greedy.colors[i]}")
  }

  // Welsh-Powell
  let wp = @coloring.welsh_powell(g)
  println("\nWelsh-Powell: ${wp.num_colors} 种颜色")

  // DSATUR
  let dsatur = @coloring.dsatur_coloring(g)
  println("DSATUR: ${dsatur.num_colors} 种颜色")
}

// 输出:
// === 澳大利亚地图着色 ===
//
// 贪心着色: 3 种颜色
//   WA: 颜色 0
//   NT: 颜色 1
//   SA: 颜色 2
//   Q: 颜色 1
//   NSW: 颜色 0
//   VIC: 颜色 2
//
// Welsh-Powell: 3 种颜色
// DSATUR: 3 种颜色
```

### 示例 3: 💻 寄存器分配（编译器应用）

```moonbit
/// 模拟编译器中的寄存器分配问题
///
/// 问题描述:
/// - 有 N 个变量需要在寄存器中存活
/// - 如果两个变量的生命周期重叠，它们不能共享同一寄存器
/// - 目标: 用最少的寄存器容纳所有变量
///
/// 方法: 构建冲突图，用图着色分配寄存器
fn register_allocation_demo() -> Unit {
  // 变量生命周期（起始行, 结束行）
  // 变量: a, b, c, d, e, f
  // 如果两个变量的生命周期重叠，它们冲突（连边）

  // 构建冲突图
  let g = @storage.new_undirected()
  for i in 0..<6 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 根据生命周期重叠添加冲突边
  // a: [1,4], b: [2,6], c: [3,5], d: [4,7], e: [5,8], f: [1,3]
  // 重叠关系 → 边
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) // a-b
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0) // a-c
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(5), 1.0) // a-f
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) // b-c
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0) // b-d
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(5), 1.0) // b-f
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) // c-d
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(4), 1.0) // c-e
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0) // d-e

  // 使用 DSATUR（通常给出最优或接近最优的着色）
  let result = @coloring.dsatur_coloring(g)

  let var_names = ["a", "b", "c", "d", "e", "f"]
  let reg_names = ["R0", "R1", "R2", "R3", "R4", "R5"]

  println("=== 寄存器分配结果 ===")
  println("需要寄存器数: ${result.num_colors}")

  for i in 0..result.colors.length() {
    let reg = result.colors[i]
    println("变量 ${var_names[i]} → 寄存器 ${reg_names[reg]}")
  }
}

// 输出:
// === 寄存器分配结果 ===
// 需要寄存器数: 4
// 变量 a → 寄存器 R0
// 变量 b → 寄存器 R1
// 变量 c → 寄存器 R2
// 变量 d → 寄存器 R0
// 变量 e → 寄存器 R1
// 变量 f → 寄存器 R2
```

---

## 📈 复杂度分析

### 时间复杂度: O(V²)

| 操作 | 次数 | 复杂度 | 说明 |
|------|------|--------|------|
| 初始化颜色数组 | 1 次 | O(V) | 创建 colors 数组 |
| 外层循环（遍历节点） | V 次 | O(V) | 每个节点着色一次 |
| 收集邻居颜色 | 每节点 O(degree) | O(E) 总计 | 遍历邻居找已用颜色 |
| 找最小可用颜色 | 每节点 O(Δ) | O(V×Δ) 总计 | Δ 为最大度数 |
| 验证着色（可选） | 1 次 | O(V+E) | 检查相邻不同色 |
| **总计** | | **O(V²)** | 最坏情况 Δ ≈ V |

> 📝 **简化分析**: 对于稠密图（E ≈ V²），复杂度为 O(V²)。对于稀疏图（E ≈ V），复杂度接近 O(V×Δ)。

### 空间复杂度: O(V)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `colors[]` | O(V) | 每个节点的颜色编号 |
| `used[]`（临时） | O(Δ) | 邻居颜色集合，Δ ≤ V |
| **总计** | **O(V)** | |

### 与其他着色算法对比

| 算法 | 时间 | 空间 | 解的质量 | 适用场景 |
|------|------|------|----------|----------|
| **贪心着色** | O(V²) | O(V) | ≤ Δ+1 色 | 快速近似、大规模图 |
| Welsh-Powell | O(V² + VlogV) | O(V) | 通常优于贪心 | 稀疏图效果显著 |
| DSATUR | O(V²) | O(V) | 启发式最优 | 实际应用首选 |
| 回溯精确着色 | O(k^V) | O(V) | **最优解** | 小规模图 (~30) |

### 近似比分析

```
贪心着色的上界: χ_greedy ≤ Δ + 1

其中:
  χ_greedy = 贪心着色使用的颜色数
  Δ        = 图的最大度数
  χ(G)      = 真实色数（最优解）

 Brooks 定理: 对于连通图（非完全图/非奇环），χ(G) ≤ Δ
 → 贪心最多使用 Δ+1 种颜色，而最优可能只需 Δ 或更少

示例:
  完全图 K_n: Δ = n-1, χ(K_n) = n → 贪心使用 n 种（最优！）
  二分图:     Δ 可能很大, χ = 2 → 贪心可能用 Δ+1 种（最差）
```

---

## 🎯 实际应用场景

### 应用 1: 🗺️ 地图着色

```
问题: 为地图上的区域着色，相邻区域颜色不同

为什么贪心着色适用:
✅ 平面图保证 ≤ 4 种颜色（四色定理）
✅ 贪心着色最多用 Δ+1 种，对平面图通常 ≤ 6
✅ 速度极快，可实时渲染大型地图

实际流程:
1. 将地图转为图（区域=节点，边界=边）
2. 运行贪心着色或 Welsh-Powell
3. 将颜色映射回地图区域
```

### 应用 2: 💻 编译器寄存器分配

```
问题: 为程序中的变量分配 CPU 寄存器
- 两个同时存活的变量不能共享同一寄存器
- CPU 寄存器数量有限（通常 16-32 个）

为什么贪心着色适用:
✅ 变量冲突 → 图的边，寄存器 → 颜色
✅ DSATUR 在实际编译器中广泛使用（GCC, LLVM）
✅ O(V²) 足够快，即使对数千变量的函数

实际流程:
1. 分析变量生命周期（liveness analysis）
2. 构建干涉图（interference graph）
3. 运行图着色分配寄存器
4. 无法着色的变量溢出到内存（spill）
```

### 应用 3: 📅 调度与资源分配

```
问题: 将任务分配到时间槽，冲突任务不能同时执行
- 课程排课：相邻课程（共享学生/教室）不能同时段
- 会议安排：有人员重叠的会议不能同时段

为什么贪心着色适用:
✅ 冲突任务 → 图的边，时间段 → 颜色
✅ 贪心给出可行调度（不一定最优但够用）
✅ 对大规模调度问题非常快

伪代码:
conflict_graph = build_conflict_graph(tasks)
coloring = greedy_coloring(conflict_graph)
for task, color in zip(tasks, coloring.colors):
    schedule[task] = time_slot[color]
```

### 应用 4: 🎮 数独求解

```
问题: 为 9×9 数独网格填充数字 1-9

为什么可以用图着色:
1. 将每个格子视为图的一个节点（共 81 个节点）
2. 同行/同列/同宫格的格子连边（不能同色）
3. 颜色 = 数字 1-9
4. 预填格子 = 已着色的节点（约束传播）

贪心着色的角色:
- 先贪心着色缩小搜索空间
- 再用回溯精确求解剩余部分
- 结合两种方法的优点
```

---

## 🧪 练习题

### 练习 1: 手动执行贪心着色 ⭐⭐

对于以下无向图，按节点顺序 0,1,2,3,4 执行贪心着色，写出：
1. 每个节点的颜色编号
2. 使用的颜色总数
3. 是否为最优着色

```
  0 ─── 1
  |   / |
  |  /  |
  | /   |
  2 ─── 3
   \   /
    \ /
     4
```

**边列表**: `(0,1), (0,2), (1,2), (1,3), (2,3), (2,4), (3,4)`

<details>
<summary>📝 点击查看答案</summary>

```
着色过程:
  节点 0: 邻居无色 → 颜色 0
  节点 1: 邻居 {0:0} → 最小可用 1
  节点 2: 邻居 {0:0, 1:1} → 最小可用 2
  节点 3: 邻居 {1:1, 2:2} → 最小可用 0
  节点 4: 邻居 {2:2, 3:0} → 最小可用 1

结果: [0, 1, 2, 0, 1]
使用颜色数: 3

是否最优? ❌ 不是。该图是轮图 W_5，色数为 3，
但贪心恰好达到了 3，所以这次是最优的！

注意: 如果换个顺序可能用更多颜色。
```

</details>

### 练习 2: 编程实现 - 比较着色顺序 ⭐⭐⭐

构建一个星形图（1 个中心节点连接 5 个外围节点），比较以下着色顺序的结果：
1. 中心节点优先: `[0, 1, 2, 3, 4, 5]`
2. 外围节点优先: `[1, 2, 3, 4, 5, 0]`

```moonbit
fn compare_ordering_star_graph() -> Unit {
  let g = @storage.new_undirected()
  for i in 0..<6 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }
  // 中心节点 0 连接所有外围节点
  for i in 1..<6 {
    let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(i), 1.0)
  }

  // 顺序 1: 中心优先
  let order1 = [0, 1, 2, 3, 4, 5]
  let result1 = @coloring.greedy_coloring_with_order(g, order1)
  println("中心优先: ${result1.num_colors} 种颜色")

  // 顺序 2: 外围优先
  let order2 = [1, 2, 3, 4, 5, 0]
  let result2 = @coloring.greedy_coloring_with_order(g, order2)
  println("外围优先: ${result2.num_colors} 种颜色")
}
```

期望输出: 中心优先用 2 种颜色（最优），外围优先也用 2 种颜色（星形图是二分图，两种顺序都是最优）

<details>
<summary>💻 点击查看完整解答</summary>

```moonbit
fn compare_ordering_star_graph() -> Unit {
  let g = @storage.new_undirected()
  for i in 0..<6 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }
  // 中心节点 0 连接所有外围节点
  for i in 1..<6 {
    let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(i), 1.0)
  }

  // 顺序 1: 中心优先
  let order1 = [0, 1, 2, 3, 4, 5]
  let result1 = @coloring.greedy_coloring_with_order(g, order1)
  println("中心优先: ${result1.num_colors} 种颜色")
  // 中心 → 颜色 0, 所有外围 → 颜色 1

  // 顺序 2: 外围优先
  let order2 = [1, 2, 3, 4, 5, 0]
  let result2 = @coloring.greedy_coloring_with_order(g, order2)
  println("外围优先: ${result2.num_colors} 种颜色")
  // 所有外围 → 颜色 0, 中心 → 颜色 1
}

// 两种顺序都使用 2 种颜色（最优）
// 星形图是二分图，色数 = 2
```

</details>

### 练习 3: 进阶 - 实现 Welsh-Powell 算法 ⭐⭐⭐⭐

**挑战**: 实现 Welsh-Powell 算法 — 按度数降序排列节点后执行贪心着色。

**提示**:
- 先计算每个节点的度数
- 按度数降序排序（可用冒泡排序）
- 用 `greedy_coloring_with_order()` 执行着色

<details>
<summary>🔧 参考实现框架</summary>

```moonbit
fn welsh_powell_manual(graph : UndirectedAdjList) -> ColoringResult {
  let n = @core.GraphReadable::node_count(graph)

  // 1. 计算每个节点的度数
  let degrees : Array[(Int, Int)] = []  // (节点ID, 度数)
  for i in 0..<n {
    let d = @core.GraphReadable::degree(graph, @core.NodeId(i))
    degrees.push((i, d))
  }

  // 2. 按度数降序排序（冒泡排序）
  let sorted = bubble_sort_desc(degrees)

  // 3. 提取排序后的节点顺序
  let order : Array[Int] = []
  for (node_id, _) in sorted {
    order.push(node_id)
  }

  // 4. 执行贪心着色
  @coloring.greedy_coloring_with_order(graph, order)
}

fn bubble_sort_desc(nodes : Array[(Int, Int)]) -> Array[(Int, Int)] {
  let result = []
  for node in nodes { result.push(node) }

  let mut i = 0
  while i < result.length() {
    let mut j = i + 1
    while j < result.length() {
      let (_, di) = result[i]
      let (_, dj) = result[j]
      if dj > di {
        let temp = result[i]
        result[i] = result[j]
        result[j] = temp
      }
      j = j + 1
    }
    i = i + 1
  }
  result
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **VisuAlgo** | https://visualgo.net/en/graphds | 🏆 业界标杆，支持多种图算法可视化 |
| Algorithm Visualizer | https://algorithm-visualizer.org/ | 简洁直观，代码可视化 |
| CS Academy Graph Coloring | https://csacademy.com/app/graph_editor/ | 可自定义图并着色 |

### 理论延伸阅读

- **图遍历**: [BFS 教程](/algorithms/traversal/bfs/index/)（图算法的基础）
- **社区检测**: [社区发现算法](/algorithms/community/index/)（另一种图分析任务）
- **图匹配**: 最大匹配与最小着色是对偶问题
- **四色定理**: 任何平面图 χ(G) ≤ 4（1976 年计算机证明）

### mbtgraph API 参考

```moonbit
// 核心函数
@greedy.greedy_coloring(graph)              // 贪心着色（自然顺序）→ ColoringResult
@greedy.greedy_coloring_with_order(graph, order)  // 贪心着色（指定顺序）
@coloring.welsh_powell(graph)              // Welsh-Powell 算法
@coloring.dsatur_coloring(graph)           // DSATUR 算法（启发式最优）

// 结果查询
result.colors          // Array[Int]  — 每个节点的颜色
result.num_colors      // Int         — 使用的颜色总数
result.is_valid        // Bool        — 着色是否合法
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** 图着色的核心思想（地图涂色类比）
- [ ] **手动执行** 小规模图的贪心着色过程（写出颜色分配）
- [ ] **实现** MoonBit 版本的贪心着色（理解 used 数组和最小可用颜色）
- [ ] **使用** `greedy_coloring()` 和 `greedy_coloring_with_order()` 解决实际问题
- [ ] **区分** 贪心着色 vs Welsh-Powell vs DSATUR 的适用场景
- [ ] **分析** 贪心着色的时间/空间复杂度（O(V²) / O(V)）
- [ ] **应用** 图着色到地图着色、寄存器分配、调度等实际问题
- [ ] **评估** 贪心着色的近似比（≤ Δ+1）和局限性

> 💡 **下一步**: 尝试实现练习题中的 **Welsh-Powell 算法**，或者深入学习 [DSATUR 算法](https://en.wikipedia.org/wiki/DSatur) 了解更高级的启发式策略！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行贪心着色:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_graph()
  let result = @coloring.greedy_coloring(g)
  println("使用颜色数: ${result.num_colors}")
  println("着色方案: ${result.colors}")
}</code></pre>
    <p>然后访问 <strong>VisuAlgo</strong> 观看更多图算法动画：<a href="https://visualgo.net/en/graphds" target="_blank">https://visualgo.net/en/graphds</a></p>
  </div>
</div>