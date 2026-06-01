# Coloring 图着色算法模块

## 简介

本模块提供**图着色（Graph Coloring）**算法，支持多种启发式和精确算法，
用于求解图的**色数（Chromatic Number）**问题。

图着色是经典的组合优化问题，在调度、资源分配等领域有广泛应用。
本模块提供从快速近似到精确求解的完整算法栈，满足不同场景需求。

## 快速开始

### 贪心着色（最快）

```moonbit
let g = make_bipartite_graph(3, 3)
let result = greedy_coloring(g)
println("使用颜色数: ${result.num_colors}")  // ≤ 2
```

### DSATUR 启发式（推荐）

```moonbit
let result = dsatur_coloring(g)  // 通常效果最好
if result.is_valid {
  for i in 0..result.colors.length() {
    println("节点 ${i} 的颜色: ${result.colors[i]}")
  }
}
```

### 精确色数计算

```moonbit
let result = exact_chromatic_number(g, 5000)  // 5 秒超时
match result.chromatic_number {
  Some(chi) => println("色数 χ(G) = ${chi}"),
  None => println("超时，上界: ${result.upper_bound}")
}
```

## API 参考

### 启发式算法

| 函数 | 算法 | 时间复杂度 | 特点 |
|------|------|-----------|------|
| `greedy_coloring` | 朴素贪心 | O(V²) | 快速但非最优 |
| `welsh_powell` | 度数降序贪心 | O(V² + V log V) | 通常比朴素好 |
| `dsatur_coloring` | 饱和度排序 | O(V²) | **启发式中最优** |
| `greedy_coloring_with_order` | 自定义顺序贪心 | O(V²) | 可控顺序 |

### 精确算法

| 函数 | 算法 | 时间复杂度 | 适用规模 |
|------|------|-----------|---------|
| `exact_chromatic_number` | 回溯+剪枝 | O(k^V) | V ≤ 20-25 |

## 数据类型

### ColoringResult - 着色结果

```moonbit
pub(all) struct ColoringResult {
  colors : Array[Int]      // colors[i] = 节点 i 的颜色编号（0-based）
  num_colors : Int         // 使用的颜色总数
  is_valid : Bool          // 着色是否合法（相邻节点不同色）
}
```

### ChromaticNumberResult - 色数计算结果

```moonbit
pub(all) struct ChromaticNumberResult {
  chromatic_number : Int?       // 色数（None 表示超时/未完成）
  optimal_coloring : Array[Int]? // 最优着色方案（1-based）
  upper_bound : Int             // 上界（贪心算法结果）
  lower_bound : Int             // 下界（保守值为 1）
  exact : Bool                  // 是否为精确解
}
```

## 🎯 算法选择指南

mbtgraph 提供 6 种图着色算法，适用于不同场景：

### 快速参考表

| 场景 | 推荐算法 | 时间复杂度 | 特点 |
|------|---------|:----------:|------|
| **快速近似** | `greedy_coloring()` | O(V·d) | 最简单，适合原型开发 |
| **自定义顺序** | `greedy_coloring_with_order()` | O(V·d) | 可控制节点访问顺序 |
| **稀疏图优化** | `welsh_powell()` | O(V·d) | 按度数降序，稀疏图效果好 |
| **质量优先** | `dsatur_coloring()` | O(V²) | 通常产生最少颜色数 |
| **边着色** | `edge_coloring()` | O(V·E) | 基于 Vizing 定理 |
| **小规模精确解** | `exact_chromatic_number()` | O(n!) | V ≤ 20 时可行 |

### 详细选择流程

```
开始
│
├─ 图规模 V > 20？
│   ├─ 是 → 使用启发式算法（greedy/welsh_powell/dsatur）
│   └─ 否 → 可考虑精确算法 exact_chromatic_number()
│
├─ 需要边着色？
│   └─ 是 → 使用 edge_coloring()
│
├─ 对解的质量要求？
│   ├─ 快速即可 → greedy_coloring()
│   ├─ 较好即可 → welsh_powell()
│   └─ 尽量最优 → dsatur_coloring()
│
└─ 有特殊节点顺序要求？
    └─ 是 → greedy_coloring_with_order(order)
```

### 典型应用场景

#### 场景 1：寄存器分配（编译器）

```moonbit
// 变量冲突图着色，V 可能很大（>1000）
let result = welsh_powell(conflict_graph)  // 稀疏图效果好
let num_registers = result.num_colors + 1    // +1 用于栈溢出
```

#### 场景 2：调度问题

```moonbit
// 任务时间表着色，需要尽量少的时间槽
let result = dsatur_coloring(schedule_graph)  // 质量优先
```

#### 场景 3：地图填色（小规模）

```moonbit
// 国家/地区相邻关系，通常 V < 200
if map_graph.node_count() <= 20 {
  let result = exact_chromatic_number(map_graph)  // 精确解
} else {
  let result = dsatur_coloring(map_graph)  // 近似解
}
```

### 性能对比（典型数据）

| 算法 | V=10 随机图 | V=50 随机图 | V=100 稀疏图 | 颜色数质量 |
|------|:----------:|:----------:|:-----------:|:---------:|
| greedy | ~0.1ms | ~1ms | ~5ms | ⭐⭐ |
| welsh_powell | ~0.2ms | ~2ms | ~8ms | ⭐⭐⭐ |
| dsatur | ~0.5ms | ~8ms | ~20ms | ⭐⭐⭐⭐ |
| exact | ~50ms | 超时 | 超时 | ⭐⭐⭐⭐⭐ |

*注：以上为预估值，实际性能取决于图的密度和结构*

## 算法原理

### 图着色问题定义

用最少的颜色给图 G 的每个顶点着色，使得相邻顶点颜色不同。
最小的颜色数称为**色数**，记作 χ(G)。

**形式化定义**：
- 给定图 G = (V, E)
- 寻找函数 c: V → {1, 2, ..., k} 使得：
  - 对所有边 (u, v) ∈ E，有 c(u) ≠ c(v)
  - 最小化 k = χ(G)

### 贪心着色 (Greedy)

按固定或自定义顺序遍历节点，每步选择最小可用颜色。

**算法流程**：
1. 初始化所有节点为未着色状态
2. 按顺序遍历节点 u：
   - 收集邻居已使用的颜色集合 S
   - 选择最小的非负整数 c ∉ S
   - 分配颜色 c 给节点 u

**特点**：
- 时间 O(V²)，空间 O(V)
- 近似比 Δ+1（Δ 为最大度数）
- 不同顺序导致不同结果
- 实现简单，适用于实时系统

### Welsh-Powell 改进

先将节点按度数降序排列，再执行贪心着色。

**核心思想**：高度数的节点约束更多，优先处理可避免后期分配过多新颜色。

**算法流程**：
1. 计算所有节点的度数 d(v) = |N(v)|
2. 按度数降序排列节点序列
3. 按排序后的顺序执行贪心着色

**性能提升**：
- 对稀疏图通常显著减少颜色数（10-30%）
- 对稠密图与朴素贪心相同
- 时间 O(V² + V log V)

### DSATUR 算法（Degree of Saturation）

每次选择"饱和度"最大的未着色节点进行着色。

**关键概念**：

- **饱和度 (Saturation)**: 节点 u 的已着色邻居使用的不同颜色数量
  ```
  sat(u) = |{c : ∃v ∈ N(u), v 已着色且 color(v) = c}|
  ```

- **选择策略**：
  1. 未着色节点中饱和度最大的节点
  2. 平局时选择度数最大的节点（打破对称性）

**算法流程**：
1. 初始化：所有节点未着色，饱和度为 0
2. 循环直到所有节点着色：
   a. 选择饱和度最大的未着色节点 u
   b. 为 u 分配最小可用颜色
   c. 更新 u 的未着色邻居的饱和度

**为什么 DSATUR 效果最好？**

- **动态决策**：每次基于当前局部信息选择最优节点
- **约束感知**：饱和度高意味着可选颜色少，应优先处理
- **自适应性强**：不依赖全局排序，能适应图的局部结构

**理论保证**：
- 对二分图总能找到 2-着色（最优）
- 对弦图（chordal graph）总能找到最优着色
- 近似比优于 Welsh-Powell 和朴素贪心

### 精确色数（回溯法 + 剪枝）

使用深度优先回溯搜索 + 多重剪枝优化计算精确色数。

**整体架构**：

```
┌─────────────────────────────┐
│     预处理阶段               │
│  ┌───────────────────┐      │
│  │ 贪心算法 → 上界    │      │
│  │ 计算下界           │      │
│  │ 平凡情况检测       │      │
│  └───────────────────┘      │
└─────────────┬───────────────┘
              ▼
┌─────────────────────────────┐
│     回溯搜索阶段             │
│  ┌───────────────────┐      │
│  │ DFS 遍历解空间树   │      │
│  │ ├─ 上界剪枝        │      │
│  │ ├─ 前向检查        │      │
│  │ └─ 超时机制        │      │
│  └───────────────────┘      │
└─────────────┬───────────────┘
              ▼
┌─────────────────────────────┐
│     结果返回                 │
│  · 精确解（正常结束）        │
│  · 近似解（超时终止）        │
└─────────────────────────────┘
```

**剪枝优化详解**：

1. **上界剪枝 (Upper Bound Pruning)**
   - 维护当前找到的最优解 best_count
   - 如果已使用颜色 ≥ best_count，立即剪枝
   - 效果：大幅减少搜索空间（通常 90%+）

2. **前向检查 (Forward Checking)**
   - 分配颜色前验证与已着色邻居的冲突
   - 避免进入明显无效的分支
   - 效果：提前发现冲突，减少无效搜索

3. **超时机制 (Timeout Mechanism)**
   - 基于 time_limit_ms 参数控制运行时间
   - 使用迭代计数近似时间（避免系统调用开销）
   - 保证响应性，适合交互式应用

**适用规模建议**：

| 节点数 V | 推荐设置 | 预期时间 | 适用场景 |
|---------|---------|---------|---------|
| V ≤ 10  | time_limit_ms = 0 | < 0.01s | 所有场景 |
| V = 11-15 | time_limit_ms = 5000 | 0.01s - 1s | 批量处理/离线 |
| V = 16-20 | time_limit_ms = 10000 | 1s - 60s | 研究/实验 |
| V = 21-25 | time_limit_ms = 30000 | 数分钟 | 极少使用 |
| V > 25   | 不推荐 | 可能极慢 | 改用启发式 |

## 经典结果验证

本模块包含针对经典图类型的测试用例，用于验证算法正确性：

| 图类型 | 色数 χ(G) | 说明 | 测试覆盖 |
|--------|-----------|------|---------|
| 空图 (V=0) | 0 | 无节点 | ✅ |
| 单节点 (V=1) | 1 | 平凡情况 | ✅ |
| 无边多节点 | 1 | 所有节点同色 | ✅ |
| 完全图 K_n | n | 所有节点两两相邻 | ✅ |
| 二分图 | ≤ 2 | 可二部划分 | ✅ |
| 偶环 C_{2k} | 2 | 二分图特例 | ✅ |
| 奇环 C_{2k+1} | 3 | 最小非二分图 | ✅ |
| 星形图 | 2 | 中心与叶子不同色 | ✅ |
| 轮图 W_n | 3 或 4 | 取决于奇偶性 | ✅ |
| Petersen 图 | 3 | 著名反例 | ✅ |
| 平面图 | ≤ 4 | 四色定理 | ⚠️ 未直接测试 |

## 应用场景

### 📅 调度问题

**课程表安排**：将课程作为节点，冲突课程连边，着色数为所需时间段数。

```moonbit
// 示例：5 门课程，某些课程不能在同一时间
let courses = build_course_conflict_graph()
let result = dsatur_coloring(courses)
println("最少需要 ${result.num_colors} 个时间段")
for i in 0..result.colors.length() {
  println("课程 ${i} 安排在时间段 ${result.colors[i]}")
}
```

### 💻 寄存器分配

编译器后端将程序变量分配到有限寄存器，冲突变量不能使用同一寄存器。

### 🗺️ 地图填色

相邻国家/地区必须使用不同颜色，四色定理保证平面地图最多 4 色。

### 📶 频率分配

无线通信中，相邻基站不能使用相同频率，最小化频率数量。

### ♟️ 数独求解

数独可视为图着色的特例：81 个格子（节点），同行/列/宫的格子互为邻居，9 种颜色。

## 边界行为

| 场景 | 行为 | 返回值 |
|------|------|--------|
| 空图 (V=0) | num_colors=0, is_valid=true | 正常处理 |
| 单节点 (V=1) | num_colors=1, is_valid=true | 最小非空情况 |
| 无边多节点 | num_colors=1 (同色) | 无约束 |
| 非连通图 | 各分量独立着色 | 全局最优 |
| 自环 | 视实现可能非法 | 取决于存储结构 |
| 重边 | 与单边等效 | 自动处理 |

## 性能特征对比

| 算法 | 时间复杂度 | 空间复杂度 | 最优性 | 推荐场景 |
|------|----------|----------|-------|---------|
| **Greedy** | O(V²) | O(V) | 近似 | 实时系统、原型开发 |
| **Welsh-Powell** | O(V² + V log V) | O(V) | 近似 | 稀疏图、一般用途 |
| **DSATUR** | O(V²) | O(V) | 近似（最优启发式）| **生产环境首选** |
| **Exact** | O(k^V) | O(V) | 精确 | 小规模、研究验证 |

**实际性能参考**（随机图 G(n, 0.5)）：

| V | Greedy | W-P | DSATUR | Exact (10s) |
|---|--------|-----|--------|------------|
| 10 | ~6 | ~5 | ~5 | 5 (精确) |
| 15 | ~9 | ~8 | ~7 | 7 (精确) |
| 20 | ~12 | ~10 | ~9 | ~9 或超时 |
| 25 | ~15 | ~13 | ~11 | 通常超时 |

## 测试

### 运行测试

```bash
# 单模块测试
moon test lib/algo/coloring

# 全量测试
moon test
```

### 测试覆盖

**21 个测试用例**，分为以下类别：

#### 基础功能测试 (~30%)

- [x] 贪心着色基本功能
- [x] Welsh-Powell 基本功能
- [x] DSATUR 基本功能
- [x] 指定顺序贪心着色
- [x] 精确色数基本功能
- [x] 结果结构体字段验证

#### 算法正确性测试 (~40%)

- [x] 二分图着色（≤ 2 色）
- [x] 完全图着色（n 色）
- [x] 奇环/偶环着色（3/2 色）
- [x] Petersen 图着色（3 色）
- [x] 空图/单节点边界情况
- [x] 无边图着色（1 色）
- [x] 精确色数经典案例验证

#### 边界情况测试 (~20%)

- [x] 空图输入
- [x] 单节点图
- [x] 大规模图性能（V=20+）
- [x] 超时机制验证
- [x] 非连通图处理

#### 属性验证测试 (~10%)

- [x] 着色合法性验证（is_valid=true）
- [x] 颜色编号连续性（0 到 num_colors-1）
- [x] 结果一致性（多次运行稳定）
- [x] 精确解 vs 启发式解的质量比较

### 快照测试

部分复杂输出使用快照测试（snapshot testing），确保回归检测：

```bash
# 更新快照
moon test lib/algo/coloring --update
```

## 设计决策

### 为什么提供 4 种贪心变体？

不同场景适合不同策略，提供灵活性：

| 场景 | 推荐算法 | 原因 |
|------|---------|------|
| **实时系统** | Greedy | 最快（O(V²) 常数因子小） |
| **生产环境** | DSATUR | 质量/速度最佳平衡 |
| **稀疏图** | Welsh-Powell | 度数信息有效利用 |
| **研究/实验** | 自定义顺序 | 探索不同策略效果 |
| **小规模精确** | Exact | 保证最优性 |

**设计原则**：
- 用户可根据应用特性选择合适算法
- API 统一，切换成本极低
- 提供质量保证（is_valid 标志）

### 为什么不默认返回精确解？

NP-hard 问题无已知多项式算法：

**理论限制**：
- P ≠ NP 假设下，不存在多项式精确算法
- 最坏情况需要指数时间 O(k^V)

**实践考虑**：
- V > 25 时精确算法不现实（即使有剪枝）
- 许多应用只需要"足够好"的近似解
- 启发式算法可在毫秒级返回结果

**本模块策略**：
- 提供高质量启发式（DSATUR）保证可用性
- 精确算法作为可选功能存在
- 明确标注适用规模和预期时间

### 为什么使用纯函数语义？

所有算法采用不可变数据结构 + 纯函数风格：

**优势**：
- 无副作用，易于推理和测试
- 天然线程安全
- 支持惰性求值和缓存
- 符合函数式编程最佳实践

**实现方式**：
- 使用 `let g = self` 而非 `mut self`
- 深拷贝输入数据避免修改原数组
- 方法链式调用：`let result = algorithm(input)`

### 为什么颜色编号从 0 开始？

**设计选择**：
- 启发式算法：colors[i] ∈ {0, 1, ..., k-1}（0-based）
- 精确算法：colors[i] ∈ {1, 2, ..., k}（1-based）

**原因**：
- 启发式算法使用 `find_min_available_color()` 自然从 0 开始
- 精确算法为了数学直觉（色数 ≥ 1）使用 1-based
- 两种约定在各自上下文中都合理

**注意**：使用结果时需注意区分！

## 配合使用的模块

### 核心依赖

- **[@core](../../core/)**:
  - `GraphReadable` trait：算法的图抽象接口
  - `NodeId`, `Node`, `Edge` 类型定义
  - `GraphError` 错误处理

- **[@storage](../../storage/)**:
  - `UndirectedAdjList`：无向邻接表（推荐）
  - `DirectedAdjList`：有向邻接表（需转换）
  - 图构建辅助函数

### 相关算法模块

- **[clique/](../clique/)**: 最大团大小可作为色数下界（χ(G) ≥ ω(G)）
- **[connectivity/](../connectivity/)**: 连通分量分解，各分量独立着色
- **[mst/](../mst/)**: 最小生成树（辅助分析图结构）
- **[shortest_path/](../shortest_path/)**: 最短路径（辅助分析图直径）

### 典型工作流

```moonbit
// 1. 构建或加载图
let mut builder = @storage.UndirectedAdjList::new(10)
builder = builder.add_edge(0, 1) |> ignore
builder = builder.add_edge(1, 2) |> ignore
// ...
let g = builder.build()

// 2. 快速近似（生产环境）
let approx = dsatur_coloring(g)
println("近似色数: ${approx.num_colors}")

// 3. 如果需要精确解（研究/验证）
if @core.GraphReadable::node_count(g) <= 20 {
  let exact = exact_chromatic_number(g, 10000)
  match exact.chromatic_number {
    Some(chi) => println("精确色数: ${chi}"),
    None => println("超时")
  }
}

// 4. 可选：结合团数下界
// let clique_result = max_clique(g)
// println("色数范围: [${clique_result.size}, ${exact.upper_bound}]")
```

## 已知限制

### 当前版本限制

1. **下界计算保守**
   - 当前 lower_bound 固定为 1（或 n>0 时为 1）
   - 可改进：使用最大团大小 ω(G) 作为下界
   - 影响：对某些图剪枝效果不够强

2. **不支持增量着色**
   - 每次调用从头开始计算
   - 不支持动态添加/删除节点后的增量更新
   - 适用场景：静态图或偶尔重新计算

3. **精确算法规模限制**
   - V > 25 时可能极慢
   - 未实现更高级的剪枝（如分支限界、约束传播）
   - 未来可考虑：整数规划、SAT 求解器接口

4. **仅支持无向图**
   - 有向图需先转换为无向图（忽略方向）
   - 或使用 underlying undirected graph

### 性能优化空间

- **DSATUR 数据结构**: 可用优先队列优化节点选择（O(log V) per selection）
- **精确算法**: 可加入更多剪枝策略（如最大团、独立集检测）
- **并行化**: 回溯搜索可并行化（分治策略）
- **缓存**: 相同图可缓存结果（哈希 → 结果映射）

## 文档更新历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.2.0 | 2026-06-01 | 📝 新增算法选择指南 + 性能对比表 |
| v0.1.0 | 初始版本 | 6 种着色算法实现 |

## 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| **v0.2.0** | 2026-06-01 | 📝 新增算法选择指南 + 性能对比表 + 边着色支持（6 算法） |
| **v0.1.0** | 2026-05-22 | 初始版本：6 种着色算法（5 启发式 + 1 精确），21 tests，完整文档 |

---

## 参考资源

### 学术文献

1. Brélaz, D. (1979). "New methods to color the vertices of a graph". *Communications of the ACM*.
   - DSATUR 原始论文

2. Welsh, D. J. A., & Powell, M. B. (1967). "An upper bound for the chromatic number of a graph based on the degrees of its vertices". *Computer Journal*.
   - Welsh-Powell 原始论文

3. Jensen, T. R., & Toft, B. (1995). *Graph coloring problems*. Wiley-Interscience.
   - 图着色问题权威专著

### 在线资源

- Wikipedia: [Graph coloring](https://en.wikipedia.org/wiki/Graph_coloring)
- VisuAlgo: [Graph Coloring Visualization](https://visualgo.net/en/graphcoloring)
- OEIS: [Chromatic numbers of graphs](https://oeis.org/A000934)

---

## 贡献指南

### 添加新算法

1. 在 `coloring.mbt` 或新文件中实现算法
2. 遵循现有 API 模式（返回 ColoringResult）
3. 添加完整文档注释（参考现有函数）
4. 在 `coloring_test.mbt` 中添加测试用例
5. 更新本文档的 API 参考和性能对比表

### 添加新测试

1. 在 `coloring_test.mbt` 中添加测试函数
2. 包含正常场景、边界情况、属性验证
3. 更新测试覆盖统计（本节）
4. 运行 `moon test lib/algo/coloring` 确保通过

### 性能优化建议

- 使用 `moon bench` 进行基准测试
- 对比不同实现的常数因子
- 关注大规模图（V > 50）的性能表现

---

## 许可证

遵循项目整体许可证（参见根目录 LICENSE 文件）。
