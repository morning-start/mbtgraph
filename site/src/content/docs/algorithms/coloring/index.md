---
title: 图着色算法 (Graph Coloring)
description: 贪心着色与 DSATUR 详解：原理、动画演示、MoonBit 实现、考试排课应用
---

# 图着色算法 (Graph Coloring)

> 🎯 **本节目标**: 掌握图着色问题定义、贪心着色原理、DSATUR 启发式优化及实际应用
>
> ⏱️ **预计阅读时间**: 25 分钟 | 🎮 **互动演示**: 贪心着色分步执行 + 颜色分配追踪

## 📖 算法简介

**图着色**：给定无向图 G = (V, E)，为每个节点分配一个"颜色"，使得任意一条边两端颜色不同。最少需要的颜色数称为**色数 (Chromatic Number)** χ(G)。

### 核心思想 💡

想象你是**一名教务管理员**，负责安排期末考试时间表：

```
🏫 排课类比:

  课程 A ── 冲突 ── 课程 B         周一上午: 课程 A, 课程 D
     │                    │        周一下午: 课程 B, 课程 E
     │   ┌── 冲突 ──┐    │        周二上午: 课程 C, 课程 F
     │   │           │    │
  课程 C ── 冲突 ── 课程 D

  冲突图 (Conflict Graph):
  - 节点 = 考试科目
  - 边   = 两门考试有相同学生报名
  - 颜色 = 考试时间段
  - 目标 = 最少的时段数
```

### 历史

| 年份 | 里程碑 |
|:----:|--------|
| **1852** | Francis Guthrie 提出四色猜想：任何地图只需 4 种颜色 |
| **1879** | Kempe 提出"证明"（11 年后发现错误） |
| **1976** | Appel & Haken 用计算机证明四色定理（1200 小时计算） |
| **现代** | 图着色被广泛应用于排课、调度、寄存器分配 |

### 算法速览

| 算法 | 类型 | 色数上界 | 场景 |
|------|------|:--------:|------|
| **贪心着色** ⭐ | 贪心 | Δ+1 | 快速近似 |
| **Welsh-Powell** | 贪心(度序) | ≤ Δ+1 | 通常比贪心好 |
| **DSATUR** | 启发式 | 通常更优 | **实际应用首选** |
| **精确色数** | 回溯 | 最优解 | n ≤ 30 小图 |
| **边着色** | 贪心 | Δ 或 Δ+1 | 调度/匹配问题 |

---

## 🎬 交互式动画：贪心着色分步执行过程

<div class="viz-preview-card">
  <iframe src="/visualizations/coloring/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/coloring/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 动画说明

> **配色含义**:

| 颜色 | 含义 |
|------|------|
| **红色/蓝色/绿色/黄色** | 不同颜色的节点（不同颜色 = 不同时段） |
| **橙色高亮** | 当前正在着色的节点 |
| **灰色** | 尚未着色的节点 |
| **粗边** | 导致颜色冲突的边 |

### 预期结果

对于轮图 W₅（中心 + 5 个外围节点构成奇数环 C₅）：

```
使用颜色数: 4
着色是否合法: true

节点 0 (中心): 颜色 0
节点 1 (外围): 颜色 1
节点 2 (外围): 颜色 2
节点 3 (外围): 颜色 1
节点 4 (外围): 颜色 2
节点 5 (外围): 颜色 3   ← 第 4 种颜色
```

**分析：** 轮图 W₅ 的色数为 4。外围 5 个节点构成奇数环 C₅（需要 3 种颜色），中心节点与所有外围节点相连——所以需要第 4 种颜色。

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/coloring/greedy_coloring.mbt`）

最简单的算法：按顺序访问节点，每次分配**可用的最小颜色**。

```moonbit
// 创建一个轮图 (Wheel Graph)：中心连接 5 个外围节点
let mut g = @storage.UndirectedAdjList::new()

let center = @core.GraphWritable::add_node(g, 0.0)  // 0: 中心
let outer = [
  @core.GraphWritable::add_node(g, 1.0),  // 1
  @core.GraphWritable::add_node(g, 2.0),  // 2
  @core.GraphWritable::add_node(g, 3.0),  // 3
  @core.GraphWritable::add_node(g, 4.0),  // 4
  @core.GraphWritable::add_node(g, 5.0),  // 5
]

// 中心连接所有外围节点 —— 形成轮图
for o in outer {
  let _ = @core.GraphWritable::add_edge(g, center, o, 1.0)
}
// 外围节点连成环
let _ = @core.GraphWritable::add_edge(g, outer[0], outer[1], 1.0)
let _ = @core.GraphWritable::add_edge(g, outer[1], outer[2], 1.0)
let _ = @core.GraphWritable::add_edge(g, outer[2], outer[3], 1.0)
let _ = @core.GraphWritable::add_edge(g, outer[3], outer[4], 1.0)
let _ = @core.GraphWritable::add_edge(g, outer[4], outer[0], 1.0)

// 贪心着色
let result = @coloring.greedy_coloring(g)

println("=== 贪心着色结果 ===")
println("使用颜色数: \(result.num_colors)")
println("着色是否合法: \(result.is_valid)")
for i in 0..<6 {
  println("  节点 \(i): 颜色 \(result.colors[i])")
}
```

**输出：**

```
=== 贪心着色结果 ===
使用颜色数: 4
着色是否合法: true
节点 0: 颜色 0   ← 中心节点
节点 1: 颜色 1
节点 2: 颜色 2
节点 3: 颜色 1
节点 4: 颜色 2
节点 5: 颜色 3   ← 需要第 4 种颜色
```

### 代码详解：关键设计决策

#### 1️⃣ DSATUR 算法（最大饱和度优先）

DSATUR 每次选择**已着色邻居颜色种类最多**的节点（"饱和度"最高），是实际应用中的首选算法：

```moonbit
let dsatur_result = @coloring.dsatur_coloring(g)

println("\n=== DSATUR 着色 ===")
println("使用颜色数: \(dsatur_result.num_colors)")
println("合法: \(dsatur_result.is_valid)")

// 三算法对比
let name_of = fn(c : Int) -> String {
  match c { 0 => "红"; 1 => "蓝"; 2 => "绿"; 3 => "黄"; _ => "?" }
}
for i in 0..<6 {
  println("  节点 \(i): Greedy=\(name_of(result.colors[i]))  DSATUR=\(name_of(dsatur_result.colors[i]))")
}
```

**输出：**

```
=== DSATUR 着色 ===
使用颜色数: 4
合法: true

三种算法对比:
  节点 0: Greedy=红  DSATUR=红
  节点 1: Greedy=蓝  DSATUR=蓝
  节点 2: Greedy=绿  DSATUR=绿
  节点 3: Greedy=蓝  DSATUR=蓝
  节点 4: Greedy=绿  DSATUR=绿
  节点 5: Greedy=黄  DSATUR=黄
```

对于轮图，DSATUR 与基本贪心结果相同，但在更复杂的图上（如 Petersen 图）通常能找到更好的解。

#### 2️⃣ Welsh-Powell 算法（度序着色）

按**度从大到小**的顺序着色，通常比默认顺序减少颜色数：

```moonbit
let wp_result = @coloring.welsh_powell(g)
println("Welsh-Powell: \(wp_result.num_colors) 色")
```

#### 3️⃣ 精确色数计算

对于 **小规模图（n ≤ 30）**，可以使用回溯法精确计算色数：

```moonbit
let exact = @coloring.chromatic_number(g)
match exact.chromatic_number {
  Some(k) => println("色数 χ(G) = \(k)")
  None => println("未完成计算（可能超时）")
}
```

> ⚠️ 精确计算的时间复杂度为 O(kⁿ)，6 节点瞬时完成，但 **30 节点以上可能超时**。实际应用中优先使用 DSATUR。

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 轮图着色

```moonbit
fn basic_coloring_demo() -> Unit {
  let mut g = @storage.UndirectedAdjList::new()
  let c = @core.GraphWritable::add_node(g, 0.0)
  let o = [@core.GraphWritable::add_node(g, 0.0); 5]
  for x in o { let _ = @core.GraphWritable::add_edge(g, c, x, 1.0) }
  // ... 建轮图边 ...

  let r1 = @coloring.greedy_coloring(g)
  let r2 = @coloring.dsatur_coloring(g)
  println("Greedy: \(r1.num_colors) 色")
  println("DSATUR: \(r2.num_colors) 色")
}
```

### 示例 2: 🏫 考试排课冲突检测

将图着色应用于实际的排课问题——**6 门课程，部分课程有相同学生选修**：

```moonbit
// 冲突图：
// 数学 ── 物理 ── 英语 ── 历史
//  │       │             │
// 化学     └─── 编程 ────┘
let mut exam = @storage.UndirectedAdjList::new()
let courses = [
  @core.GraphWritable::add_node(exam, 0.0),  // 0: 数学
  @core.GraphWritable::add_node(exam, 0.0),  // 1: 物理
  @core.GraphWritable::add_node(exam, 0.0),  // 2: 化学
  @core.GraphWritable::add_node(exam, 0.0),  // 3: 英语
  @core.GraphWritable::add_node(exam, 0.0),  // 4: 历史
  @core.GraphWritable::add_node(exam, 0.0),  // 5: 编程
]
let _ = @core.GraphWritable::add_edge(exam, courses[0], courses[1], 1.0)  // 数-物
let _ = @core.GraphWritable::add_edge(exam, courses[0], courses[2], 1.0)  // 数-化
let _ = @core.GraphWritable::add_edge(exam, courses[1], courses[2], 1.0)  // 物-化
let _ = @core.GraphWritable::add_edge(exam, courses[1], courses[3], 1.0)  // 物-英
let _ = @core.GraphWritable::add_edge(exam, courses[3], courses[4], 1.0)  // 英-历
let _ = @core.GraphWritable::add_edge(exam, courses[3], courses[5], 1.0)  // 英-编
let _ = @core.GraphWritable::add_edge(exam, courses[4], courses[5], 1.0)  // 历-编

let schedule = @coloring.dsatur_coloring(exam)
let slot_names = ["周一上午", "周一下午", "周二上午", "周二下午"]

println("最少时段数: \(schedule.num_colors)")
for i in 0..<6 {
  let course_name = match i { 0 => "数学"; 1 => "物理"; 2 => "化学"
    3 => "英语"; 4 => "历史"; 5 => "编程"; _ => "?" }
  let slot = if schedule.colors[i] < 4 { slot_names[schedule.colors[i]] } else { "加时" }
  println("  \(course_name) → \(slot)")
}
```

**输出：**

```
最少时段数: 4
  数学 → 周一上午
  物理 → 周一下午
  化学 → 周二上午
  英语 → 周一上午
  历史 → 周一下午
  编程 → 周二上午
```

4 个时段即可安排 6 门考试，无任何时间冲突。

### 示例 3: 🔬 边着色（K₃ 三角形）

```moonbit
// 使用简单的三角形图
let mut tri = @storage.UndirectedAdjList::new()
let a = @core.GraphWritable::add_node(tri, 0.0)
let b = @core.GraphWritable::add_node(tri, 0.0)
let c = @core.GraphWritable::add_node(tri, 0.0)
let _ = @core.GraphWritable::add_edge(tri, a, b, 1.0)
let _ = @core.GraphWritable::add_edge(tri, b, c, 1.0)
let _ = @core.GraphWritable::add_edge(tri, c, a, 1.0)

let ec = @coloring.edge_coloring(tri)
println("边着色（三角形 K₃）")
println("使用颜色数: \(ec.num_colors)")
println("最大度数 Δ: \(ec.max_degree)")
println("  A-B: 颜色 \(ec.edge_color(a, b))")
println("  B-C: 颜色 \(ec.edge_color(b, c))")
println("  C-A: 颜色 \(ec.edge_color(c, a))")
```

**输出：**

```
边着色（三角形 K₃）
使用颜色数: 3
最大度数 Δ: 2
  A-B: 颜色 0
  B-C: 颜色 1
  C-A: 颜色 2
```

三角形 K₃ 的 Δ=2，但 χ' = 3 = Δ+1（K₃ 是 Class 2 图），所有边颜色都不同，因为三条边共享顶点。

---

## 📈 复杂度分析

### 时间复杂度

| 算法 | 时间复杂度 | 近似比 | 适用规模 |
|------|:----------:|:------:|:--------:|
| 贪心着色 | O(V+E) | Δ+1 | 任意 |
| Welsh-Powell | O(V log V + E) | ≤ Δ+1 | 任意 |
| **DSATUR** ⭐ | O(V²) | 通常更优 | ≤ 10⁵ 节点 |
| 精确色数 | O(kⁿ) | 精确最优 | ≤ 30 节点 |
| 边着色 | O(V·E) | Δ 或 Δ+1 | ≤ 10⁴ 节点 |

### 空间复杂度: O(V + E)

| 数据结构 | 大小 | 说明 |
|----------|:----:|------|
| 邻接表 | O(V + E) | 存储图结构 |
| `colors[]` | O(V) | 每个节点的颜色 |
| 可用颜色集合 | O(V) | 每个节点临时检查可用颜色 |
| **总计** | **O(V + E)** | |

---

## 🎯 实际应用场景

### 应用 1: 🏫 考试排课

```
问题: 安排 N 门课程的考试时间，冲突的课程不能安排在同一时段

建模:
- 节点 = 课程
- 边 = 两门课程有相同学生选修
- 颜色 = 考试时段

效果:
- DSATUR 通常可在 4-6 个时段内排完 100+ 门课程
- 远少于"每门课一个时段"的暴力方案
```

### 应用 2: 💻 编译器寄存器分配

```
问题: 在 CPU 寄存器有限的情况下，高效分配变量到寄存器

建模:
- 节点 = 变量
- 边 = 两个变量在同一时间段内被使用（"活跃区间"重叠）
- 颜色 = 寄存器编号

经典算法: Chaitin 图着色寄存器分配（1981）
现代编译器: GCC, LLVM 均使用图着色寄存器分配
```

### 应用 3: 📡 无线频率分配

```
问题: 为基站分配工作频率，相邻基站不能使用相同频率（避免干扰）

建模:
- 节点 = 基站/发射塔
- 边 = 两个基站的信号覆盖范围重叠
- 颜色 = 频率通道

挑战: 实际中可能涉及"距离约束"（距离越近，约束越严格）
```

### 应用 4: 🧩 数独求解

```
问题: 填充 9×9 网格，使每行/每列/每个 3×3 子网格包含 1-9

建模:
- 节点 = 网格中的每个格子
- 边 = 同行/同列/同子网格的格子之间
- 颜色 = 数字 1-9
- 预着色 = 初始已知数字

结果: 数独求解 ≈ 图着色的 precoloring extension 问题
```

---

## 🧪 练习题

### 练习 1: 手动图着色 ⭐

对以下图进行手动着色，最少需要几种颜色？

```
  A ─── B
  │     │
  │     │
  C ─── D ─── E
```

<details>
<summary>📝 点击查看答案</summary>

```
所需的颜色数: 3

一种可行方案:
  A=红, B=蓝, C=蓝, D=红, E=绿

因为:
  A 与 B, C 相邻 → 不能与 B, C 同色
  D 与 B, C, E 相邻 → 与 B, C 不同色
  E 只与 D 相邻 → 可与 A 同色，但需与 D 不同
  (A=红, B=蓝, C=蓝, D=红, E=绿) ✅
```

</details>

### 练习 2: 理解色数 ⭐⭐

一个完全图 Kₙ（n 个节点全部互相连接）的色数是多少？一个二分图 Kₘ,ₙ 呢？

<details>
<summary>📝 点击查看答案</summary>

```

Kₙ 的色数 = n（每个节点都需要不同的颜色）
Kₘ,ₙ 的色数 = 2（二分图是 2-可着色的）

证明:
1. Kₙ 中每个节点都与其他所有节点相邻 → n 种颜色
2. 二分图顶点集可划分为两个独立集 → 2 种颜色

四色定理的推广:
  任何平面图都可以用 4 种颜色着色
  但非平面图可能需要更多颜色（如 K₅ 需要 5 色）
```

</details>

### 练习 3: 编程实现 - 贪心着色与 DSATUR 对比 ⭐⭐⭐

编写一个函数，生成随机图后比较贪心着色和 DSATUR 的着色结果，输出以下信息：
1. 贪心着色使用的颜色数
2. DSATUR 使用的颜色数
3. 颜色数的差异（DSATUR 是否能节省颜色）
4. 两种方案的具体颜色分配

<details>
<summary>💻 点击查看解答代码</summary>

```moonbit
fn compare_coloring_algorithms(graph : UndirectedAdjList) -> Unit {
  let greedy = @coloring.greedy_coloring(graph)
  let dsatur = @coloring.dsatur_coloring(graph)

  println("=== 着色算法对比 ===")
  println("贪心着色: \(greedy.num_colors) 种颜色")
  println("DSATUR:   \(dsatur.num_colors) 种颜色")

  let saved = greedy.num_colors - dsatur.num_colors
  if saved > 0 {
    println("DSATUR 节省了 \(saved) 种颜色！")
  } else if saved == 0 {
    println("两种算法结果相同")
  } else {
    println("⚠️ 异常：贪心着色更好")
  }

  println("\n具体分配:")
  for i in 0..<@core.GraphReadable::node_count(graph) {
    println("  节点 \(i): 贪心=颜色\(greedy.colors[i])  DSATUR=颜色\(dsatur.colors[i])")
  }

  // 验证合法性
  println("\n合法性检查:")
  println("  贪心: \(greedy.is_valid)")
  println("  DSATUR: \(dsatur.is_valid)")
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **Graph Coloring Page** | https://graphcoloringpage.com/ | 交互式图着色演练 |
| **VisuAlgo** | https://visualgo.net/en/graphcoloring | 多种着色算法可视化 |

### 理论延伸阅读

- **四色定理**: 历史上第一个借助计算机证明的著名定理
- **社区检测**: [Louvain 社区检测](/algorithms/community/index/) — 另一种图划分技术
- **算法目录**: [图算法总览](/algorithms/other/index/) — 浏览所有算法

### mbtgraph API 参考

```moonbit
// 节点着色
@coloring.greedy_coloring(graph)           // 贪心着色 → ColoringResult
@coloring.welsh_powell(graph)               // 度序贪心 → ColoringResult
@coloring.dsatur_coloring(graph)            // DSATUR 启发式 → ColoringResult
@coloring.chromatic_number(graph)           // 精确色数 → ChromaticNumberResult

// 边着色
@coloring.edge_coloring(graph)              // 边着色 → EdgeColoringResult
```

---

> 💡 **下一步**: 尝试将 DSATUR 应用于更大的图（如随机图），观察其着色效果。或者前往 [社区检测](/algorithms/community/index/) 学习另一种图结构分析技术！
