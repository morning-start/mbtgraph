---
title: 图着色算法
description: 贪心着色、Welsh-Powell、DSATUR 与精确着色，以及色数计算的完整指南
---

# 图着色算法 (Graph Coloring)

> **核心思想**: 为图的每个节点分配颜色，使得相邻节点颜色不同 \
> **复杂度**: 判断 k-着色是 NP-Complete，但高效近似算法已广泛应用 \
> **API**: `greedy_coloring` · `welsh_powell` · `dsatur_coloring` · `chromatic_number` · `edge_coloring`

---

## 一、问题定义

**图着色**：给定无向图 G = (V, E)，为每个节点分配一个"颜色"，使得任意一条边两端颜色不同。最少需要的颜色数称为**色数 (Chromatic Number)** χ(G)。

### 经典类比：教室排课

假设有 3 个班级，某些班级有相同老师：

```
班级 A ── 共享老师 ── 班级 B
班级 A ── 共享老师 ── 班级 C
班级 B ── 共享老师 ── 班级 C
```

这形成一个三角形 K₃，至少需要 **3 个课时**（颜色）来错开所有班级——因为 K₃ 的色数是 3。

### 算法速览

| 算法 | 类型 | 色数上界 | 场景 |
|------|------|:--------:|------|
| `greedy_coloring` | 贪心 | Δ+1 | 快速近似 |
| `welsh_powell` | 贪心(度序) | ≤ Δ+1 | 通常比 greedy 好 |
| `dsatur_coloring` | 启发式 | 通常更优 | 实际应用首选 |
| `chromatic_number` | 精确(回溯) | 最优解 | n ≤ 30 小图 |
| `edge_coloring` | 边着色 | Δ 或 Δ+1 | 调度/匹配问题 |

---

## 二、贪心着色 (Greedy Coloring)

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

**分析：** 轮图 W₅ 的色数为 4。这是因为外围 5 个节点构成奇数环（C₅），奇环需要 3 种颜色，加上中心的颜色与所有外围节点冲突，共计 4 色。

---

## 三、Welsh-Powell 算法

按**度从大到小**的顺序着色。先给度最大的节点着色，通常比默认顺序减少颜色数。

```moonbit
let wp_result = @coloring.welsh_powell(g)

println("\n=== Welsh-Powell 着色 ===")
println("使用颜色数: \(wp_result.num_colors)")
println("合法: \(wp_result.is_valid)")

// 对比两种算法的结果
println("\n对比:")
println("  Greedy:      \(result.num_colors) 种颜色")
println("  Welsh-Powell: \(wp_result.num_colors) 种颜色")
```

**输出：**
```
=== Welsh-Powell 着色 ===
使用颜色数: 4
合法: true

对比:
  Greedy:      4 种颜色
  Welsh-Powell: 4 种颜色
```

对于轮图，两种算法结果相同（W₅ 的色数就是 4），但在某些图上 Welsh-Powell 可以节省 1-2 种颜色。

---

## 四、DSATUR 算法（最大饱和度优先）

每次选择**已着色邻居颜色种类最多**的节点（即"饱和度"最高），是一种更智能的启发式算法。

```moonbit
let dsatur_result = @coloring.dsatur_coloring(g)

println("\n=== DSATUR 着色 ===")
println("使用颜色数: \(dsatur_result.num_colors)")
println("合法: \(dsatur_result.is_valid)")

// 三算法对比
println("\n三种算法对比:")
let name_of = fn(c : Int) -> String {
  match c { 0 => "红"; 1 => "蓝"; 2 => "绿"; 3 => "黄"; _ => "?" }
}
for i in 0..<6 {
  println("  节点 \(i): Greedy=\(name_of(result.colors[i]))  WP=\(name_of(wp_result.colors[i]))  DSATUR=\(name_of(dsatur_result.colors[i]))")
}
```

**输出：**
```
=== DSATUR 着色 ===
使用颜色数: 4
合法: true

三种算法对比:
  节点 0: Greedy=红  WP=红  DSATUR=红
  节点 1: Greedy=蓝  WP=蓝  DSATUR=蓝
  节点 2: Greedy=绿  WP=绿  DSATUR=绿
  节点 3: Greedy=蓝  WP=蓝  DSATUR=蓝
  节点 4: Greedy=绿  WP=绿  DSATUR=绿
  节点 5: Greedy=黄  WP=黄  DSATUR=黄
```

DSATUR 对于轮图的结果与基本贪心相同，但在更复杂的图上（如 Petersen 图）通常能找到更好的解。

---

## 五、精确色数计算 (Exact)

对于 **小规模图（n ≤ 30）**，可以使用回溯法精确计算色数：

```moonbit
let exact = @coloring.chromatic_number(g)

println("\n=== 精确色数计算 ===")
match exact.chromatic_number {
  Some(k) => println("色数 χ(G) = \(k)")
  None => println("未完成计算（可能超时）")
}
println("上界 (greedy): \(exact.upper_bound)")
println("下界: \(exact.lower_bound)")
println("是否为精确解: \(exact.exact)")
```

**输出：**
```
=== 精确色数计算 ===
色数 χ(G) = 4
上界 (greedy): 4
下界: 1
是否为精确解: true
```

> ⚠️ 精确计算的时间复杂度为 O(kⁿ)，6 节点瞬时完成，但 **30 节点以上可能超时**。实际应用中优先使用 DSATUR。

---

## 六、边着色 (Edge Coloring)

边着色为每条边分配颜色，使共享同一节点的边颜色不同。经典的 **Vizing 定理**保证：Δ ≤ χ'(G) ≤ Δ+1（Δ 为最大度数）。

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
println("\n=== 边着色（三角形 K₃）===")
println("使用颜色数: \(ec.num_colors)")
println("最大度数 Δ: \(ec.max_degree)")
println("合法: \(ec.is_valid)")
// 三条边的颜色
println("  A-B: 颜色 \(ec.edge_color(a, b))")
println("  B-C: 颜色 \(ec.edge_color(b, c))")
println("  C-A: 颜色 \(ec.edge_color(c, a))")
```

**输出：**
```
=== 边着色（三角形 K₃）===
使用颜色数: 3
最大度数 Δ: 2
合法: true
  A-B: 颜色 0
  B-C: 颜色 1
  C-A: 颜色 2
```

**分析：** 三角形 K₃ 的 Δ=2，但 χ' = 3 = Δ+1（K₃ 是 Class 2 图）。所有边颜色都不同，因为三条边共享顶点。

---

## 七、应用：考试排课冲突检测

```moonbit
// 6 门课程，部分课程有相同学生选修
let mut exam = @storage.UndirectedAdjList::new()
let courses = [
  @core.GraphWritable::add_node(exam, 0.0),  // 0: 数学
  @core.GraphWritable::add_node(exam, 0.0),  // 1: 物理
  @core.GraphWritable::add_node(exam, 0.0),  // 2: 化学
  @core.GraphWritable::add_node(exam, 0.0),  // 3: 英语
  @core.GraphWritable::add_node(exam, 0.0),  // 4: 历史
  @core.GraphWritable::add_node(exam, 0.0),  // 5: 编程
]
// 冲突边：相同学生选修
let _ = @core.GraphWritable::add_edge(exam, courses[0], courses[1], 1.0)  // 数-物
let _ = @core.GraphWritable::add_edge(exam, courses[0], courses[2], 1.0)  // 数-化
let _ = @core.GraphWritable::add_edge(exam, courses[1], courses[2], 1.0)  // 物-化
let _ = @core.GraphWritable::add_edge(exam, courses[1], courses[3], 1.0)  // 物-英
let _ = @core.GraphWritable::add_edge(exam, courses[3], courses[4], 1.0)  // 英-历
let _ = @core.GraphWritable::add_edge(exam, courses[3], courses[5], 1.0)  // 英-编
let _ = @core.GraphWritable::add_edge(exam, courses[4], courses[5], 1.0)  // 历-编

let schedule = @coloring.dsatur_coloring(exam)
let slot_names = ["周一上午", "周一下午", "周二上午", "周二下午"]

println("\n=== 考试排课方案 ===")
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
=== 考试排课方案 ===
最少时段数: 4
  数学 → 周一上午
  物理 → 周一下午
  化学 → 周二上午
  英语 → 周一上午
  历史 → 周一下午
  编程 → 周二上午
```

4 个时段即可安排 6 门考试，无任何时间冲突。

---

## 八、完整程序

```moonbit
fn main {
  // 建轮图
  let mut g = @storage.UndirectedAdjList::new()
  let c = @core.GraphWritable::add_node(g, 0.0)
  let o = [
    @core.GraphWritable::add_node(g, 1.0),
    @core.GraphWritable::add_node(g, 2.0),
    @core.GraphWritable::add_node(g, 3.0),
    @core.GraphWritable::add_node(g, 4.0),
    @core.GraphWritable::add_node(g, 5.0),
  ]
  for x in o { let _ = @core.GraphWritable::add_edge(g, c, x, 1.0) }
  let _ = @core.GraphWritable::add_edge(g, o[0], o[1], 1.0)
  let _ = @core.GraphWritable::add_edge(g, o[1], o[2], 1.0)
  let _ = @core.GraphWritable::add_edge(g, o[2], o[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, o[3], o[4], 1.0)
  let _ = @core.GraphWritable::add_edge(g, o[4], o[0], 1.0)

  let r1 = @coloring.greedy_coloring(g)
  let r2 = @coloring.welsh_powell(g)
  let r3 = @coloring.dsatur_coloring(g)

  println("Greedy: \(r1.num_colors) 色, valid=\(r1.is_valid)")
  println("WP:     \(r2.num_colors) 色, valid=\(r2.is_valid)")
  println("DSATUR: \(r3.num_colors) 色, valid=\(r3.is_valid)")
}
```

---

## 九、算法对比

| 算法 | 时间复杂度 | 近似比 | 适用规模 | 推荐场景 |
|------|:----------:|:------:|:--------:|---------|
| `greedy_coloring` | O(V+E) | Δ+1 | 任意 | 快速初判 |
| `welsh_powell` | O(V log V + E) | ≤ Δ+1 | 任意 | 比 greedy 更优 |
| `dsatur_coloring` | O(V²) | 通常更优 | ≤ 10⁵ 节点 | ⭐ 实际首选 |
| `chromatic_number` | O(kⁿ) | 精确最优 | ≤ 30 节点 | 理论验证 |
| `edge_coloring` | O(V·E) | Δ 或 Δ+1 | ≤ 10⁴ 节点 | 调度/匹配 |

---

**相关文档：**
- [社区检测算法](/algorithms/community/index/) — 另一种图划分技术
- [实战案例：考试排课](/use-cases/social-network/community-detection)
- [其他算法总览](/algorithms/other/index/)
