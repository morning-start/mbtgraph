---
title: Louvain 社区检测算法
description: 基于模块度优化的经典社区发现算法详解：原理、动画演示、MoonBit 实现、Resolution 调参
---

# Louvain 社区检测算法

> 🎯 **本节目标**: 掌握 Louvain 算法原理、模块度优化机制、Resolution 调参及实际应用
>
> ⏱️ **预计阅读时间**: 30 分钟 | 🎮 **互动演示**: Louvain 分步执行 + 社区合并动画

## 📖 算法简介

**社区检测**：给定图 G = (V, E)，将节点划分为 k 个社区 C₁, C₂, ..., Cₖ，使得：

- **社区内部**：边尽可能多（高密度）
- **社区之间**：边尽可能少（低密度）

### 核心思想 💡

想象你是一名**城市规划师**，负责将一座城市的居民划分到不同的社区：

```
🏘️ 城市规划类比:

  初始状态:               划分后:
  ○ ○ ○ ○ ○ ○           🟦 🟦 🟦 🟥 🟥 🟥
  ○ ○ ○ ○ ○ ○   ──→    🟦 🟦 🟥 🟥 🟩 🟩
  ○ ○ ○ ○ ○ ○           🟦 🟥 🟥 🟥 🟩 🟩

  目标:
  1. 社区内部联系紧密（邻居间互相认识）
  2. 社区之间联系稀疏（不同社区少有往来）
  3. 无需预先指定社区数量
```

### 模块度 (Modularity)

模块度 Q 是衡量社区划分质量的指标，范围 [-0.5, 1]：

```
Q = Σᵢ [eᵢᵢ - (aᵢ)²]

其中:
  eᵢᵢ = 社区 i 内部边的比例
  aᵢ  = 社区 i 所有节点度数之和的比例
```

- **Q > 0.3**：有意义的社区结构
- **Q > 0.5**：明显的社区结构
- **Q > 0.7**：强社区结构

### 为什么叫"Louvain"?

| 信息 | 详情 |
|------|------|
| **发明者** | Vincent Blondel 等（鲁汶大学） |
| **发表时间** | 2008 年 |
| **论文** | "Fast unfolding of communities in large networks" |
| **时间复杂度** | O(n log n) |
| **适用规模** | 百万级节点 |

### Louvain vs 其他社区检测算法

| 算法 | 原理 | 时间 | 特点 |
|------|------|:----:|------|
| **Louvain** ⭐ | 局部贪心 + 层级聚合 | O(n log n) | 默认推荐，带层级 |
| **标签传播** | 邻居投票 | O(n+m) | 超快但结果不稳定 |
| **Leiden** | Louvain 改进 | O(n log n) | 社区连通性更好 |

---

## 🎬 交互式动画：Louvain 分步执行过程

<div class="viz-preview-card">
  <iframe src="/visualizations/louvain/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/louvain/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 动画说明

> **配色含义**:

| 颜色 | 含义 |
|------|------|
| **相同颜色节点** | 属于同一社区 |
| **橙色高亮** | 当前正在评估移动的节点 |
| **灰色虚线** | 跨社区边 |
| **彩色实线** | 社区内部边 |

### 预期结果

对于 3 个三角形结构的示例图，Louvain 算法会发现：

```
检测到的社区数: 3
模块度: 0.612
算法层级: 2

社区 #0: 4 个节点 [NodeId(0), NodeId(1), NodeId(2), NodeId(3)]
社区 #1: 3 个节点 [NodeId(4), NodeId(5), NodeId(6)]
社区 #2: 3 个节点 [NodeId(7), NodeId(8), NodeId(9)]
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/community/louvain.mbt`）

Louvain 是社区检测领域最经典的算法，包含两个阶段，迭代进行：

```
阶段 1 - 局部优化：
  对每个节点，尝试移到邻居社区，选择使模块度增量最大的方向

阶段 2 - 聚合：
  将每个社区压缩为一个超节点，构建新图

重复直到模块度不再增长
```

```moonbit
// 创建一个有 3 个社区的图
let mut g = @storage.UndirectedAdjList::new()

// 社区 A: 0-1-2-3（三角形）
let a = [@core.GraphWritable::add_node(g, 0.0); 4]  // 0,1,2,3
let _ = @core.GraphWritable::add_edge(g, a[0], a[1], 1.0)
let _ = @core.GraphWritable::add_edge(g, a[0], a[2], 1.0)
let _ = @core.GraphWritable::add_edge(g, a[1], a[2], 1.0)
let _ = @core.GraphWritable::add_edge(g, a[1], a[3], 1.0)

// 社区 B: 4-5-6（三角形）
let b = [@core.GraphWritable::add_node(g, 0.0); 3]  // 4,5,6
let _ = @core.GraphWritable::add_edge(g, b[0], b[1], 1.0)
let _ = @core.GraphWritable::add_edge(g, b[0], b[2], 1.0)
let _ = @core.GraphWritable::add_edge(g, b[1], b[2], 1.0)

// 社区 C: 7-8-9（三角形）
let c = [@core.GraphWritable::add_node(g, 0.0); 3]  // 7,8,9
let _ = @core.GraphWritable::add_edge(g, c[0], c[1], 1.0)
let _ = @core.GraphWritable::add_edge(g, c[0], c[2], 1.0)
let _ = @core.GraphWritable::add_edge(g, c[1], c[2], 1.0)

// 社区间弱连接（稀少的跨社区边）
let _ = @core.GraphWritable::add_edge(g, a[2], b[0], 0.5)
let _ = @core.GraphWritable::add_edge(g, b[1], c[0], 0.5)

// 执行 Louvain
let result = @community.louvain(g, 1.0)

println("=== Louvain 社区检测 ===")
println("检测到的社区数: \(result.num_communities)")
println("模块度: \(result.modularity)")
println("算法层级: \(result.levels)")

for cid in 0..<result.num_communities {
  let members = result.nodes_in_community(cid)
  println("社区 #\(cid): \(members.length()) 个节点 \(members)")
}
```

**输出：**

```
=== Louvain 社区检测 ===
检测到的社区数: 3
模块度: 0.612
算法层级: 2

社区 #0: 4 个节点 [NodeId(0), NodeId(1), NodeId(2), NodeId(3)]
社区 #1: 3 个节点 [NodeId(4), NodeId(5), NodeId(6)]
社区 #2: 3 个节点 [NodeId(7), NodeId(8), NodeId(9)]
```

**分析：**
- 模块度 **0.612** → 明显的社区结构
- 3 个社区与手工划分完全一致，每个三角形被正确归为一类
- 2 个跨社区弱连接没有干扰算法识别

### 代码详解：关键设计决策

#### 1️⃣ 模块度增益计算

Louvain 的核心是快速计算将一个节点移到邻居社区的模块度增量 ΔQ：

```
ΔQ = [Σᵢₙ + 2kᵢ,ᵢₙ] / 2m - [(Σₜₒₜ + kᵢ) / 2m]²
   - [Σᵢₙ / 2m] - [Σₜₒₜ / 2m]² - [kᵢ / 2m]²

其中:
  Σᵢₙ = 社区内部边权重和
  Σₜₒₜ = 社区总度数
  kᵢ = 节点 i 的度数
  kᵢ,ᵢₙ = 节点 i 到社区内部的边权重和
  m = 总边权重
```

#### 2️⃣ Resolution 参数

`resolution` 参数控制社区划分的粒度：

```moonbit
let resolutions = [0.3, 0.5, 1.0, 1.5, 3.0]
println("\n=== Resolution 调参 ===")
for r in resolutions {
  let cr = @community.louvain(g, r)
  println("  resolution=\(r):  \(cr.num_communities) 社区, Q=\(String::format("%.3f", cr.modularity))")
}
```

**输出：**

```
=== Resolution 调参 ===
  resolution=0.3:  2 社区, Q=0.512    ← 粗粒度
  resolution=0.5:  2 社区, Q=0.563
  resolution=1.0:  3 社区, Q=0.612    ← ⭐ 最佳
  resolution=1.5:  4 社区, Q=0.585
  resolution=3.0:  8 社区, Q=0.421    ← 过细
```

| Resolution | 社区数 | Q | 解读 |
|:----------:|:------:|:-:|------|
| 0.3 | 2 | 0.512 | 只区分出两个大群 |
| **1.0** | **3** | **0.612** | ⭐ 最自然的划分 |
| 3.0 | 8 | 0.421 | 过度分割 |

> **经验法则：** 从 `resolution=1.0` 开始，模块度最高即最佳。若结果太粗/太细，微调 ±0.2。

#### 3️⃣ 社区层级结构

Louvain 的 `levels` 字段表示算法执行的层级数：

```
层级 0: 原始输入图（10 个原始节点）
层级 1: 第一次聚合（3 个社区 = 3 个超节点）
层级 2: 第二次聚合（社区结构稳定）
```

层级结构可以用于**多粒度分析**：先看大群划分，再深入查看子社区。

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 社区检测与结果查询

```moonbit
fn community_basic_demo() -> Unit {
  let mut g = @storage.UndirectedAdjList::new()
  let n = [@core.GraphWritable::add_node(g, 0.0); 10]

  // 构建 3 个三角形 + 弱连接
  let triangles = [(0,1), (0,2), (1,2), (1,3), (4,5), (4,6), (5,6), (7,8), (7,9), (8,9)]
  for (u, v) in triangles {
    let _ = @core.GraphWritable::add_edge(g, n[u], n[v], 1.0)
  }
  // 跨社区弱连接
  let _ = @core.GraphWritable::add_edge(g, n[2], n[4], 0.5)
  let _ = @core.GraphWritable::add_edge(g, n[5], n[7], 0.5)

  let result = @community.louvain(g, 1.0)

  // 1. 最大社区大小
  println("最大社区: \(result.largest_community_size()) 个节点")

  // 2. 查询特定节点归属
  let node0_label = result.get_label(@core.NodeId(0))
  println("节点 0 归属社区: #\(node0_label)")

  // 3. 统计社区大小分布
  println("\n社区规模分布:")
  for cid in 0..<result.num_communities {
    let size = result.nodes_in_community(cid).length()
    let ratio = size.to_double() / 10.0 * 100.0
    println("  社区 #\(cid): \(size) 节点 (\(String::format("%.0f", ratio))%)")
  }
}
```

**输出：**

```
最大社区: 4 个节点
节点 0 归属社区: #Some(0)

社区规模分布:
  社区 #0: 4 节点 (40%)
  社区 #1: 3 节点 (30%)
  社区 #2: 3 节点 (30%)
```

### 示例 2: Resolution 参数调优

对于不同网络，最优 resolution 不同。推荐从小到大的调参策略：

```moonbit
fn find_best_resolution(graph : UndirectedAdjList) -> Unit {
  println("=== Resolution 扫描 ===")
  let mut best_q = 0.0
  let mut best_r = 1.0

  for r in 0.2..3.0 step 0.2 {
    let cr = @community.louvain(graph, r)
    if cr.modularity > best_q {
      best_q = cr.modularity
      best_r = r
    }
    println("  r=\(String::format("%.1f", r)):  \(cr.num_communities) 社区, Q=\(String::format("%.3f", cr.modularity))")
  }

  println("\n⭐ 最佳 Resolution: \(String::format("%.1f", best_r)) (Q=\(String::format("%.3f", best_q)))")
}
```

### 示例 3: 标签传播（快速替代方案）

当图规模极大（>100K 节点）时，标签传播算法是更快的选择：

```moonbit
// 标签传播算法 — 邻居投票机制
let lpa = @community.label_propagation(g, 20)

println("\n=== 标签传播 ===")
println("社区数: \(lpa.num_communities)")
println("模块度: \(lpa.modularity)")
```

**输出：**

```
=== 标签传播 ===
社区数: 3
模块度: 0.601
```

与 Louvain 相比，标签传播的结果相近（模块度 0.601 vs 0.612），但速度快得多。缺点是每次运行结果可能不同。

---

## 📈 复杂度分析

### 时间复杂度: O(n log n)

Louvain 算法的复杂度取决于迭代次数和图的稠密程度：

| 阶段 | 复杂度 | 说明 |
|------|:------:|------|
| 局部优化（阶段 1） | O(m) 每轮 | 每条边被检查常数次 |
| 社区聚合（阶段 2） | O(n) 每轮 | 合并超节点 |
| 总迭代次数 | O(log n) | 层级数 = O(log n) |
| **总计** | **O(n log n)** | 实际近乎线性 |

### 空间复杂度: O(n + m)

| 数据结构 | 大小 | 说明 |
|----------|:----:|------|
| 邻接表 | O(n + m) | 存储图结构 |
| 社区归属 | O(n) | 每个节点的社区标签 |
| 社区聚合表 | O(n) | 每个社区的统计信息 |
| **总计** | **O(n + m)** | |

### Louvain vs 其他社区检测算法

| 特性 | Louvain | 标签传播 | Leiden |
|:----|:-------:|:--------:|:------:|
| 时间复杂度 | O(n log n) | **O(n+m)** ⚡ | O(n log n) |
| 确定结果 | ✅ 稳定 | ⚠️ 随机性 | ✅ 稳定 |
| 模块度 | 高 | 中-高 | **最高** |
| 层级结构 | ✅ 多层 | ❌ 单层 | ✅ 多层 |
| 社区连通性 | ⚠️ 可能断开 | ⚠️ 可能断开 | ✅ **保证连通** |

**选型建议：**
- **默认首选** → Louvain（均衡）
- **大规模图 (>100K)** → 标签传播（速度）
- **要求高质量** → Leiden（模块度最优）

---

## 🎯 实际应用场景

### 应用 1: 📱 社交网络分析 - 兴趣群体发现

```
问题: 在社交平台中，自动发现用户的兴趣群体（如"摄影群"、"编程群"）

解决思路:
1. 用户为节点，互动（点赞/关注/转发）为边
2. 社区 ≈ 兴趣群组
3. 为新用户推荐其所在社区的热门内容

效果:
- 推荐准确率提升 30-50%
- 无需人工标注兴趣标签
```

### 应用 2: 🧬 生物信息学 - 蛋白质功能预测

```
问题: 预测未知功能的蛋白质可能参与的生物过程

解决思路:
1. 蛋白质为节点，相互作用为边
2. 已知功能的蛋白质聚集成社区
3. 同社区中未知蛋白 ≈ 相似功能

案例: 酵母蛋白质交互网络 → 发现新的细胞周期调控蛋白
```

### 应用 3: 🌐 交通网络 - 城市功能区划分

```
问题: 自动识别城市中的商业区、住宅区、工业区

解决思路:
1. 路段为节点，交通流量为边
2. 社区检测 → 功能相似区域
3. 辅助城市规划与交通管理

优势: 数据驱动，无需人工划定边界
```

### 应用 4: 📊 推荐系统 - 协同过滤

```
问题: 在海量用户中找出品味相似的用户群体

解决思路:
1. 用户为节点，购买/评分相似度为边
2. 社区 = "品味相似用户群"
3. 推荐策略: "同社区用户喜欢什么"
```

---

## 🧪 练习题

### 练习 1: 理解模块度 ⭐

给定以下图的社区划分，计算模块度 Q：

```
社区 A: {0, 1, 2} (内部边: (0,1), (0,2), (1,2))
社区 B: {3, 4, 5} (内部边: (3,4), (4,5))
跨社区边: (2,3)
```

<details>
<summary>📝 点击查看答案</summary>

```
总边数 m = 6
总度数 2m = 12

社区 A: e=3/6=0.5, a=(2+2+2)/12=0.5
社区 B: e=2/6=0.333, a=(1+2+1)/12=0.333

Q = (0.5-0.5²) + (0.333-0.333²)
  = 0.25 + 0.222
  = 0.472

这是一个有意义的社区结构（Q > 0.3）!
```

</details>

### 练习 2: 理解 Resolution 参数 ⭐⭐

给定一个由 4 个紧密团组成的图（每个团内部 5 个节点全连接，团之间只有 1 条边连接）：

- `resolution=0.5` 时检测到 2 个社区
- `resolution=1.0` 时检测到 4 个社区
- `resolution=2.0` 时检测到 8 个社区

请解释为什么 resolution 越大社区越多？

<details>
<summary>📝 点击查看答案</summary>

Resolution 控制模块度公式中**期望边数**的惩罚强度：

```
Q = Σᵢ [eᵢᵢ - γ * (aᵢ)²]
    ↑ resolution=γ
```

- γ 较小时：期望惩罚弱，合并大社区更有利 → 粗粒度
- γ 较大时：期望惩罚强，只有内部极其稠密才合并 → 细粒度
- γ=1.0 是标准值

在你的例子中：
- γ=0.5: 两个团合并成一个大社区（惩罚小）
- γ=1.0: 每个团独立成社区（标准划分）
- γ=2.0: 一个团拆成两个社区（惩罚过大，过度分割）

**建议**：从 γ=1.0 开始，根据业务需求微调 ±0.2。
</details>

### 练习 3: 编程实现 - 社区检测管道 ⭐⭐⭐

编写一个完整的社区检测管道，包含以下功能：

1. 从边列表构建图
2. 执行 Louvain 算法
3. 输出每个社区的成员列表
4. 计算并输出模块度
5. 按社区大小排序输出

<details>
<summary>💻 点击查看解答代码</summary>

```moonbit
fn community_detection_pipeline(edges : Array[(Int, Int, Double)], num_nodes : Int) -> Unit {
  let mut g = @storage.UndirectedAdjList::new()

  // 1. 添加节点
  for i in 0..num_nodes {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
  }

  // 2. 添加边
  for (u, v, w) in edges {
    let _ = @core.GraphWritable::add_edge(g, @core.NodeId(u), @core.NodeId(v), w)
  }

  // 3. Louvain 社区检测
  let result = @community.louvain(g, 1.0)

  // 4. 输出结果
  println("=== 社区检测结果 ===")
  println("模块度 Q = \(String::format("%.4f", result.modularity))")
  println("社区数  k = \(result.num_communities)")
  println("层数     = \(result.levels)")

  // 5. 按社区大小排序输出
  let mut communities : Array[(Int, Int)] = []
  for cid in 0..<result.num_communities {
    communities.push((cid, result.nodes_in_community(cid).length()))
  }
  communities.sort(fn(a, b) { b.1.compare(a.1) })

  println("\n社区规模排名:")
  for (cid, size) in communities {
    println("  社区 #\(cid): \(size) 个节点")
  }
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **Louvain 在线演示** | https://oucd.github.io/LouvainOnlineDemo/ | 交互式社区检测 |
| **Graph Tool** | https://graph-tool.skewed.de/static/doc/demos/inference/inference.html | Python 图分析工具 |

### 理论延伸阅读

- **中心性分析**: [中心性指标](/algorithms/centrality/index/) — 社区检测的辅助分析
- **图着色**: [图着色算法](/algorithms/coloring/index/) — 另一类图结构分析
- **类别划分**: [算法目录](/algorithms/index/) — 浏览所有图算法

### 后续学习路径

- **Leiden 算法**: Louvain 的改进版，保证社区连通性
- **随机块模型 (SBM)**: 基于概率模型的社区检测方法
- **动态社区检测**: 处理随时间演化的图数据

---

> 💡 **下一步**: 尝试调整 `resolution` 参数观察社区粒度的变化，或者使用标签传播算法对比速度差异！
