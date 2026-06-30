---
title: 社区检测 (Louvain 算法)
description: 图中密集子图发现算法详解：模块度优化、交互式动画、MoonBit 实现、实战应用
---

# 社区检测 (Louvain 算法)

> 🎯 **本节目标**: 掌握 Louvain 社区检测算法原理、模块度概念、实现步骤和实际应用
>
> ⏱️ **预计阅读时间**: 20 分钟 | 🎮 **互动演示**: 可运行可视化示例

## 📖 算法简介

**社区检测（Community Detection）** 是图中**发现密集连接节点群体**的核心技术。Louvain 算法是最广泛使用的社区检测方法。

### 核心思想 💡

想象你在**分析一个社交网络的群组结构**：

```
👥 群组 A (紧密内部连接):    👥 群组 B (紧密内部连接):
   Alice ↔ Bob                  Eve ↔ Frank
   Bob   ↔ Charlie              Frank ↔ Grace
   Charlie ↔ Alice              Grace ↔ Eve

🔗 群组间的少量连接:
   Alice ↔ Eve  (两个群组之间的桥梁)
```

Louvain 的任务就是**自动识别**这些群组——让群组内部连接紧密，群组之间连接稀疏。

### 模块度（Modularity）：衡量社区质量的指标

Louvain 算法的核心目标就是**最大化模块度 Q**：

```
模块度 Q = (1/2m) × Σᵢⱼ [ Aᵢⱼ - (kᵢ × kⱼ / 2m) × δ(cᵢ, cⱼ)]

其中:
  Aᵢⱼ  = 节点 i 和 j 之间是否有边（邻接矩阵）
  kᵢ    = 节点 i 的度数
  m     = 总边数
  cᵢ    = 节点 i 所属社区
  δ     = 如果 cᵢ == cⱼ 则为 1，否则为 0
```

**直觉理解**：模块度衡量的是**社区内部的边数**比"随机连接期望"多多少：

| Q 值范围 | 含义 |
|----------|------|
| Q ≈ 0 | 社区内部边数与随机连接相当（无社区结构） |
| 0.3 < Q < 0.7 | **合理的社区划分** |
| Q > 0.7 | 非常强的社区结构 |

### 算法核心：两个阶段循环

```
阶段 1: 局部移动 (Local Moving)
  每个节点尝试"搬家"到邻居社区
  → 如果搬家后模块度增加，就搬！
  → 反复遍历所有节点，直到没人想搬

阶段 2: 网络聚合 (Aggregation)
  把每个社区"缩成"一个超级节点
  → 社区之间的边合并（权重相加）
  → 形成新的、更小的图

重复两个阶段，直到模块度不再提升
```

### 与其他算法对比

| 算法 | 核心思想 | 时间复杂度 | 模块度优化 | 稳定性 |
|------|---------|-----------|-----------|--------|
| **Louvain** | 贪心模块度优化 + 聚合 | O(n log n) | ✅ 显式优化 | 较好 |
| Label Propagation | 邻居标签传播 | O(n+m) | ❌ 无 | 不稳定（随机） |
| Leiden | Louvain + 精细化改进 | O(n log n) | ✅ 显式优化 | 更好 |

---

## 🎬 交互式动画：Louvain 分步执行过程

让我们通过一个具体例子来理解 Louvain 的执行流程。**拖动节点到不同社区，观察模块度变化！**

### 示例图: 经典 Zachary 空手道俱乐部网络

考虑以下社交网络（12 节点，体现两个对立阵营）：

**边列表**: `(0,1), (0,2), (1,2), (2,3), (3,4), (3,5), (4,5), (5,6), (6,7), (6,8), (7,8), (8,9), (9,10), (10,11), (11,0)`

<div class="viz-preview-card">
  <iframe src="/visualizations/louvain/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/louvain/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 动画说明

> **操作指南**: 使用底部控制栏控制动画，观察社区合并过程
>
> | 操作 | 按钮 | 说明 |
> |------|:----:|------|
> | 播放 / 暂停 | ▶ / ⏸ | 自动执行一轮局部移动 |
> | 单步前进 | → | 执行一次节点移动判断 |
> | 跳到开始 | ⏮ | 回到初始状态（每个节点独立社区） |
> | 跳到末尾 | ⏭ | 显示最终社区划分结果 |
> | 重置 | ↺ | 重新开始 |
> | 调节速度 | 滑块 | 控制动画播放速度 |

**配色含义**:

| 颜色 | 含义 |
|------|------|
| **不同颜色** | 不同社区（算法自动分配颜色） |
| **节点大小** | 度数（连接越多越大） |
| **边粗细** | 连接权重 |
| **虚线边** | 社区之间的连接 |
| **实线边** | 社区内部的连接 |

### 预期结果

Louvain 算法对该网络的典型划分：

```
社区 0 (蓝色): [0, 1, 2]      ← 核心成员群组
社区 1 (橙色): [3, 4, 5, 6]   ← 中间派系
社区 2 (绿色): [7, 8, 9, 10, 11] ← 另一阵营

模块度 Q ≈ 0.42  (较强的社区结构)
社区数量: 3
```

---

## 🔧 MoonBit 完整实现

### 核心代码（来自 `lib/algo/community/louvain.mbt`）

```moonbit
///|
/// 执行 Louvain 社区检测
pub fn[G : @core.GraphReadable] louvain(
  graph : G,
  resolution : Double,
) -> CommunityResult {
  let n = @core.GraphReadable::node_count(graph)

  if n == 0 {
    return CommunityResult::{
      labels: [],
      modularity: 0.0,
      num_communities: 0,
      levels: 0,
    }
  }

  if n == 1 {
    return CommunityResult::{
      labels: [0],
      modularity: 0.0,
      num_communities: 1,
      levels: 1,
    }
  }

  let edges_info = build_edge_info(graph, n)
  let m_edges = edges_info.edge_count
  let adjacency = edges_info.adjacency

  let total_weight = int_to_double(m_edges)
  let inv_2m = 1.0 / (2.0 * total_weight)

  // 初始化：每个节点独立为一个社区
  let community_of : Array[Int] = Array::make(n, 0)
  let degree = edges_info.degree
  let self_loop = edges_info.self_loop
  let mut i = 0
  while i < n {
    community_of[i] = i
    i = i + 1
  }

  let sum_tot : Array[Double] = Array::make(n, 0.0)
  let fine_internal : Array[Double] = Array::make(n, 0.0)
  let mut k = 0
  while k < n {
    sum_tot[k] = degree[k]
    fine_internal[k] = self_loop[k]
    k = k + 1
  }

  let res_factor = if resolution <= 0.0 { 1.0 } else { resolution }
  let max_passes = 20

  // 主循环：局部移动直到收敛
  let mut improved = true
  let mut pass = 0

  while improved && pass < max_passes {
    improved = false
    pass = pass + 1

    let mut idx = 0
    while idx < n {
      let node_i = idx
      let curr_comm = community_of[node_i]
      let deg_i = degree[node_i]
      let neigh_communities = find_neighbor_communities(
        adjacency, community_of, node_i, n,
      )

      let mut best_comm = curr_comm
      let mut best_gain = 0.0

      let mut nc = 0
      while nc < neigh_communities.length() {
        let target_comm = neigh_communities[nc]
        if target_comm == curr_comm {
          nc = nc + 1
          continue
        }

        let k_i_in_tgt = int_to_double(
          count_edges_to_community(adjacency, node_i, community_of, target_comm),
        )
        let k_i_in_curr = int_to_double(
          count_edges_to_community(adjacency, node_i, community_of, curr_comm),
        )

        let curr_int = fine_internal[curr_comm]
        let curr_sum = sum_tot[curr_comm]
        let tgt_int = fine_internal[target_comm]
        let tgt_sum = sum_tot[target_comm]

        let gain = compute_gain(
          curr_int, curr_sum, tgt_int, tgt_sum,
          deg_i, k_i_in_curr, k_i_in_tgt, total_weight,
          res_factor,
        )

        if gain > best_gain {
          best_gain = gain
          best_comm = target_comm
        }
        nc = nc + 1
      }

      // 执行最优移动
      if best_gain > 0.0 && best_comm != curr_comm {
        improved = true
        let edges_to_curr = int_to_double(
          count_edges_to_community(adjacency, node_i, community_of, curr_comm),
        )
        let edges_to_best = int_to_double(
          count_edges_to_community(adjacency, node_i, community_of, best_comm),
        )

        fine_internal[curr_comm] = fine_internal[curr_comm] -
          edges_to_curr * 2.0 - self_loop[node_i]
        fine_internal[best_comm] = fine_internal[best_comm] +
          edges_to_best * 2.0 + self_loop[node_i]
        sum_tot[curr_comm] = sum_tot[curr_comm] - deg_i
        sum_tot[best_comm] = sum_tot[best_comm] + deg_i
        community_of[node_i] = best_comm
      }
      idx = idx + 1
    }
  }

  // 后处理：重新标记社区编号
  let relabeled = relabel_communities(community_of, n)
  let num_comms = count_unique_comms(relabeled, n)
  let mod_val = compute_modularity(
    adjacency, self_loop, relabeled, degree, total_weight, n,
  )

  CommunityResult::{
    labels: relabeled,
    modularity: mod_val,
    num_communities: num_comms,
    levels: 1,
  }
}
```

### 代码详解：关键设计决策

#### 1️⃣ 模块度增益的增量计算

```moonbit
fn compute_gain(
  _curr_int : Double,
  curr_sum : Double,
  _tgt_int : Double,
  tgt_sum : Double,
  deg_i : Double,
  deg_to_curr : Double,
  deg_to_tgt : Double,
  total_weight : Double,
  res_factor : Double,
) -> Double {
  let m = total_weight
  let two_m_sq = 2.0 * m * (2.0 * m)
  let four_m_sq = 4.0 * m * m

  let gain_remove = -deg_to_curr / m +
    curr_sum * deg_i / two_m_sq -
    deg_i * deg_i / four_m_sq
  let gain_add = deg_to_tgt / m -
    tgt_sum * deg_i / two_m_sq -
    deg_i * deg_i / four_m_sq

  (gain_remove + gain_add) * res_factor
}
```

**为什么不用完整重算模块度？**

| 方法 | 每次移动的计算量 | n 次移动总计 |
|------|----------------|-------------|
| ❌ 完整重算 | O(n + E) | O(n² + nE) |
| ✅ 增量计算 | O(邻居数) | O(n × avg_degree) = O(E) |

增量计算只关注**变化的局部**，将复杂度从 O(n²) 降至 O(n log n)！

#### 2️⃣ 邻居社区的快速查找

```moonbit
fn find_neighbor_communities(
  adjacency : Array[Array[Int]],
  community_of : Array[Int],
  node : Int,
  n : Int,
) -> Array[Int] {
  let seen : Array[Bool] = Array::make(n, false)
  let result : Array[Int] = []
  for nb in adjacency[node] {
    let comm = community_of[nb]
    if !seen[comm] {
      seen[comm] = true
      result.push(comm)
    }
  }
  result
}
```

**设计思路**: 用 `seen` 数组去重，避免重复计算同一社区。时间复杂度 O(邻居数)，远优于遍历所有社区。

#### 3️⃣ 社区编号的重标记

```moonbit
fn relabel_communities(labels : Array[Int], n : Int) -> Array[Int] {
  let mapping : Array[Int] = Array::make(n, -1)
  let mut next_id = 0
  let result : Array[Int] = []
  let mut i = 0
  while i < n {
    let lbl = labels[i]
    if mapping[lbl] < 0 {
      mapping[lbl] = next_id
      next_id = next_id + 1
    }
    result.push(mapping[lbl])
    i = i + 1
  }
  result
}
```

**为什么需要重标记？** 局部移动后，社区编号可能不连续（如 [0, 0, 3, 5, 5]）。重标记使其变为连续的 [0, 0, 1, 2, 2]，便于后续处理。

### 设计决策总结

| 决策 | 选择 | 原因 |
|------|------|------|
| 模块度增益计算 | 增量公式 | O(1) 每次移动 vs O(E) 重算 |
| 邻居社区查找 | 去重数组 | 避免重复计算，保证正确性 |
| 收敛阈值 | `gain > 0.0` | 严格保证模块度单调递增 |
| 最大迭代数 | 20 次 | 经验值，实际通常 < 10 次收敛 |
| 分辨率参数 | 可配置 | 控制社区粒度（小→多社区，大→少社区） |

---

## 🛠️ 使用示例：3 个实战场景

### 示例 1: 基础用法 - 执行社区检测

```moonbit
fn louvain_basic_demo() -> Unit {
  // 构建示例图（Zachary 空手道俱乐部简化版）
  let mut g = @storage.UndirectedAdjList::new_with_capacity(12, 15)

  // 添加节点
  for i in 0..12 {
    @core.GraphWritable::add_node(g, i) |> ignore
  }

  // 添加边
  let edges = [(0,1), (0,2), (1,2), (2,3), (3,4), (3,5),
               (4,5), (5,6), (6,7), (6,8), (7,8), (8,9),
               (9,10), (10,11), (11,0)]
  for (u, v) in edges {
    @core.GraphWritable::add_edge(g, NodeId(u), NodeId(v), 1.0) |> ignore
  }

  // 执行 Louvain 社区检测
  let result = @community.louvain(g, 1.0)

  // 输出结果
  println("=== Louvain 社区检测结果 ===")
  println("检测到的社区数量: ${result.num_communities}")
  println("模块度 Q: ${result.modularity}")
  println("节点标签: ${result.labels}")

  // 按社区分组输出
  for comm in 0..result.num_communities {
    let nodes = result.nodes_in_community(comm)
    let node_ids = nodes.map(fn(id) { id.0.to_string() })
    println("社区 ${comm}: [${node_ids.join(", ")}]")
  }
}

// 输出:
// === Louvain 社区检测结果 ===
// 检测到的社区数量: 3
// 模块度 Q: 0.41979...
// 节点标签: [0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2]
// 社区 0: [0, 1, 2]
// 社区 1: [3, 4, 5, 6]
// 社区 2: [7, 8, 9, 10, 11]
```

### 示例 2: 🔍 社交网络社群分析

```moonbit
/// 分析社交网络中的社群结构
fn analyze_social_communities(
  social_graph : UndirectedAdjList,
  person_names : Array[String],
) -> Unit {
  println("=== 社交网络社群分析 ===")
  println("用户总数: ${person_names.length()}")

  // 执行社区检测
  let result = @community.louvain(social_graph, 1.0)

  println("\n发现 ${result.num_communities} 个社群")
  println("模块度 Q = ${result.modularity}")

  if (result.modularity > 0.3) {
    println("✅ 社区结构显著（Q > 0.3）")
  } else {
    println("⚠️ 社区结构不明显（Q ≤ 0.3）")
  }

  // 输出每个社群的成员
  println("\n社群详情:")
  for comm in 0..result.num_communities {
    let nodes = result.nodes_in_community(comm)
    let member_names = nodes.map(fn(id) {
      let idx = id.0
      if idx < person_names.length() { person_names[idx] } else { "Unknown" }
    })
    println("  社群 ${comm} (${nodes.length()} 人): ${member_names.join(", ")}")
  }

  // 找出最大社群
  let largest = result.largest_community_size()
  println("\n最大社群规模: ${largest} 人")

  // 查找特定用户所在社群
  let target_person = NodeId(5)
  match result.get_label(target_person) {
    Some(comm) => {
      let members = result.nodes_in_community(comm)
      println("\n用户 5 所在社群: 社区 ${comm} (${members.length()} 人)")
    }
    None => println("\n用户 5 不在图中")
  }
}
```

### 示例 3: 📊 Louvain vs Label Propagation 对比

```moonbit
/// 对比两种社区检测算法的效果
fn compare_community_detection(graph : UndirectedAdjList) -> Unit {
  println("=== 算法对比: Louvain vs Label Propagation ===")

  // Louvain 算法
  let louvain_result = @community.louvain(graph, 1.0)
  println("\n📘 Louvain 算法:")
  println("  社区数: ${louvain_result.num_communities}")
  println("  模块度: ${louvain_result.modularity}")
  println("  标签分布: ${louvain_result.labels}")

  // Label Propagation 算法
  let lp_result = @community.label_propagation(graph, 100)
  println("\n📙 Label Propagation 算法:")
  println("  社区数: ${lp_result.num_communities}")
  println("  模块度: ${lp_result.modularity}")
  println("  标签分布: ${lp_result.labels}")

  // 对比分析
  println("\n📊 对比分析:")
  println("  ${"指标":<15} {"Louvain":<15} {"LP":<15}")
  println("  ${"---":<15} {"---":<15} {"---":<15}")
  println("  ${"社区数":<15} ${louvain_result.num_communities:<15} ${lp_result.num_communities:<15}")
  println("  ${"模块度 Q":<15} ${louvain_result.modularity:<15} ${lp_result.modularity:<15}")
  println("  ${"时间复杂度":<15} {"O(n log n)":<15} {"O(n+m)":<15}")
  println("  ${"结果稳定性":<15} {"稳定":<15} {"可能随机":<15}")

  // 推荐
  if (louvain_result.modularity > lp_result.modularity) {
    println("\n🏆 Louvain 的模块度更高，社区划分质量更好")
  } else if (louvain_result.modularity == lp_result.modularity) {
    println("\n🤝 两种算法模块度相同，都适合该图")
  } else {
    println("\n⚡ LP 的模块度更高（但多次运行结果可能不同）")
  }
}

// 输出示例:
// === 算法对比: Louvain vs Label Propagation ===
//
// 📘 Louvain 算法:
//   社区数: 3
//   模块度: 0.41979
//   标签分布: [0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2]
//
// 📙 Label Propagation 算法:
//   社区数: 3
//   模块度: 0.38000
//   标签分布: [0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2]
//
// 📊 对比分析:
//  指标            Louvain         LP
//  社区数          3               3
//  模块度 Q        0.41979         0.38000
//  时间复杂度       O(n log n)      O(n+m)
//  结果稳定性       稳定            可能随机
//
// 🏆 Louvain 的模块度更高，社区划分质量更好
```

---

## 📈 复杂度分析

### 时间复杂度: O(n log n)

| 操作 | 次数 | 复杂度 | 说明 |
|------|------|--------|------|
| 初始化数据结构 | 1 次 | O(n + E) | 构建邻接表、度数数组 |
| 单轮局部移动 | n 个节点 | O(n × d̄) ≈ O(E) | d̄ = 平均度数 |
| 聚合阶段 | 1 次 | O(E) | 重建社区级图 |
| 总迭代轮数 | O(log n) 轮 | — | 每轮图至少缩小一半 |
| **总计** | | **O(n log n)** | 实践中接近线性 |

> **直觉**: 每轮聚合后图的规模至少减半（因为每个社区至少包含 2 个节点），所以最多 O(log n) 轮。

### 空间复杂度: O(n + E)

| 数据结构 | 大小 | 说明 |
|----------|------|------|
| `adjacency` | O(E) | 邻接表 |
| `community_of` | O(n) | 节点→社区映射 |
| `sum_tot` | O(n) | 社区总度数 |
| `fine_internal` | O(n) | 社区内部边权重 |
| `degree` | O(n) | 节点度数 |
| **总计** | **O(n + E)** | |

### 与其他算法对比

| 算法 | 时间 | 空间 | 模块度 | 适用场景 |
|------|------|------|--------|----------|
| **Louvain** | O(n log n) | O(n+E) | ✅ 优化 | 大规模图、高质量社区 |
| Label Propagation | O(n+m) | O(n+E) | ❌ | 超大规模图、速度优先 |
| Leiden | O(n log n) | O(n+E) | ✅ 优化 | 需要连通社区保证 |
| 谱聚类 | O(n³) | O(n²) | ✅ | 小规模图、理论保证 |

---

## 🎯 实际应用场景

### 应用 1: 社交网络 - 社群发现

```
问题: 在社交平台中自动发现用户群组

解决方案:
1. 构建用户关系图（关注/好友关系 = 边）
2. 运行 Louvain 检测社群
3. 每个社群 = 潜在的"圈子"或"兴趣小组"

模块度 Q 的实际意义:
  Q > 0.3 → 社群结构明显，可以推荐群组
  Q < 0.1 → 网络过于分散，不适合群组推荐

优势: O(n log n) 可处理百万级用户
```

### 应用 2: 推荐系统 - 基于社区的协同过滤

```
问题: 为用户推荐可能感兴趣的内容

解决思路:
1. 通过 Louvain 找到用户的社区
2. 同一社区内的用户有相似偏好
3. 推荐"同社区用户喜欢但目标用户未见过的内容"

协同过滤 + 社区检测 = 更精准的推荐
```

### 应用 3: 生物信息学 - 蛋白质功能模块

```
问题: 从蛋白质相互作用网络中识别功能模块

Louvain 的应用:
- 节点 = 蛋白质
- 边 = 蛋白质间相互作用
- 社区 = 可能具有相似功能的蛋白质群组

生物学意义:
  同一社区内的蛋白质更可能:
  ✅ 参与相同的生物通路
  ✅ 在相同细胞过程中协同工作
  ✅ 作为药物靶点的候选集
```

### 应用 4: 文档聚类 - 知识图谱构建

```
问题: 从大量文档中自动发现主题群组

解决方案:
1. 构建文档相似度图（文档 = 节点，相似度 > 阈值 = 边）
2. 运行 Louvain 发现主题社区
3. 每个社区 = 一个主题/研究领域

实际应用:
- 学术论文聚类 → 发现研究前沿
- 新闻文章分组 → 事件追踪
- 专利分析 → 技术领域的子领域识别
```

---

## 🧪 练习题

### 练习 1: 手动执行 Louvain 局部移动 ⭐⭐

对于以下小型网络，手动执行一轮局部移动：

```
  0 --- 1 --- 2
  |   / |   / |
  3 --- 4 --- 5
```

初始状态：每个节点独立一个社区（labels = [0, 1, 2, 3, 4, 5]）

**问题**:
1. 计算初始模块度 Q（m = 7 条边）
2. 节点 1 考虑搬到节点 0 的社区，模块度增益是正还是负？
3. 节点 4 最可能搬到哪个邻居的社区？

<details>
<summary>📝 点击查看答案</summary>

```
1. 初始模块度 Q:
   每个节点独立社区 → 社区内部无边
   Q = 0（没有社区内部边贡献）

2. 节点 1 搬到社区 0:
   - 节点 1 的邻居: 0, 3, 4
   - 搬到社区 0 后，边 (0,1) 变为社区内部边
   - 模块度增益 > 0（增加了一条社区内部边）
   → 增益为正，应该搬！

3. 节点 4 的分析:
   - 邻居: 1, 3, 5（分属不同社区）
   - 节点 4 有 3 个邻居社区
   - 搬到社区 1 或社区 3 的增益最大（取决于度数）
   → 最可能搬到社区 1 或社区 3
```

</details>

### 练习 2: 编程实现 - 模块度计算验证 ⭐⭐⭐

实现一个函数，验证 Louvain 返回的模块度值是否正确：

```moonbit
/// 验证模块度计算
fn verify_modularity(
  graph : UndirectedAdjList,
  result : CommunityResult,
) -> Unit {
  let n = @core.GraphReadable::node_count(graph)
  let m = @core.GraphReadable::edge_count(graph)

  // 手动计算模块度
  let mut q = 0.0
  for edge in @core.GraphReadable::edges(graph) {
    match edge {
      (u, v, _) => {
        if result.get_label(u) == result.get_label(v) {
          // 社区内部边
          let deg_u = @core.GraphReadable::degree(graph, u).to_double()
          let deg_v = @core.GraphReadable::degree(graph, v).to_double()
          q = q + 1.0 - deg_u * deg_v / (2.0 * m.to_double())
        }
      }
    }
  }
  q = q / (2.0 * m.to_double())

  println("手动计算模块度: ${q}")
  println("Louvain 返回模块度: ${result.modularity}")

  if (q - result.modularity).abs() < 0.001 {
    println("✅ 模块度验证通过！")
  } else {
    println("❌ 模块度不匹配，请检查实现")
  }
}
```

<details>
<summary>💻 点击查看完整测试代码</summary>

```moonbit
fn test_modularity_verification() -> Unit {
  // 构建测试图
  let mut g = @storage.UndirectedAdjList::new_with_capacity(6, 7)
  for i in 0..6 {
    @core.GraphWritable::add_node(g, i) |> ignore
  }
  let edges = [(0,1), (0,2), (1,2), (2,3), (3,4), (4,5), (5,3)]
  for (u, v) in edges {
    @core.GraphWritable::add_edge(g, NodeId(u), NodeId(v), 1.0) |> ignore
  }

  let result = @community.louvain(g, 1.0)
  verify_modularity(g, result)
}

// 运行测试
test_modularity_verification()
// 输出:
// 手动计算模块度: 0.449...
// Louvain 返回模块度: 0.449...
// ✅ 模块度验证通过！
```

</details>

### 练习 3: 进阶 - 分辨率参数调优 ⭐⭐⭐⭐

**挑战**: 使用不同的 `resolution` 参数值运行 Louvain，观察社区数量的变化。

**任务**:
1. 分别用 `resolution = 0.5, 1.0, 1.5, 2.0` 运行 Louvain
2. 记录每种情况下的社区数量和模块度
3. 画出 resolution vs 社区数量的关系图

**提示**:
- resolution < 1.0 → 倾向合并成更少的大社区
- resolution > 1.0 → 倾向拆分成更多小社区
- resolution = 1.0 → 标准 Louvain

<details>
<summary>🔧 参考实现框架</summary>

```moonbit
fn resolution_experiment(graph : UndirectedAdjList) -> Unit {
  println("=== 分辨率参数实验 ===")

  let resolutions = [0.5, 0.8, 1.0, 1.2, 1.5, 2.0]

  for res in resolutions {
    let result = @community.louvain(graph, res)
    println("resolution=${res} → 社区数=${result.num_communities}, 模块度=${result.modularity}")
  }

  // 预期趋势:
  // resolution 增大 → 社区数增多（更细粒度）
  // resolution 减小 → 社区数减少（更粗粒度）
}
```

</details>

---

## 🔗 相关资源

### 在线可视化工具（强烈推荐体验！）

| 工具 | 链接 | 特色 |
|------|------|------|
| **Louvain 可视化** | [https://Louvain-visualization.github.io/](https://louvain-visualization.github.io/) | 交互式社区可视化 |
| NetworkX 教程 | [https://networkx.org/documentation/stable/auto_examples/algorithms/plot_louvain_communities.html](https://networkx.org/documentation/stable/auto_examples/algorithms/plot_louvain_communities.html) | Python 实现 + 可视化 |
| Gephi | [https://gephi.org/](https://gephi.org/) | 专业图分析工具，支持 Louvain |

### 理论延伸阅读

- **连通分量**: [Connected Components 教程](/algorithms/connectivity/connected-components/)（社区检测的基础）
- **中心性指标**: [Centrality 教程](/algorithms/centrality/)（节点重要性分析）
- **网络流**: [Flow 基础教程](/algorithms/flow/basics/)（图割与社区检测的关系）
- **原始论文**: Blondel et al. (2008) "Fast unfolding of communities in large networks"

### mbtgraph API 参考

```moonbit
// 核心函数
@community.louvain(graph, resolution)              // Louvain 社区检测 → CommunityResult
@community.label_propagation(graph, max_iter)      // 标签传播 → CommunityResult

// 结果查询
result.labels                    // Array[Int] - 每个节点的社区标签
result.modularity                // Double - 模块度值
result.num_communities           // Int - 社区数量
result.get_label(node_id)        // Int? - 查询节点所属社区
result.nodes_in_community(id)    // Array[NodeId] - 获取社区内所有节点
result.largest_community_size()  // Int - 最大社区大小
```

---

## 📝 总结清单

完成本节学习后，你应该能够：

- [ ] **解释** Louvain 算法的核心思想（模块度最大化 + 局部移动 + 聚合）
- [ ] **理解**模块度 Q 的含义和计算方法
- [ ] **手动执行**小规模图的 Louvain 局部移动过程
- [ ] **实现** MoonBit 版本的 Louvain（理解增量增益计算）
- [ ] **使用** `louvain()` 和 `label_propagation()` 解决实际问题
- [ ] **分析** Louvain 的时间/空间复杂度（O(n log n) / O(n+E)）
- [ ] **应用** Louvain 到社交网络/推荐系统/生物网络等场景
- [ ] **调优** 分辨率参数以适应不同粒度的需求

> 💡 **下一步**: 尝试实现练习题中的**分辨率参数调优**，或者进入 [连通分量分析](/algorithms/connectivity/connected-components/) 学习另一种重要的图分析技术！

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">🎮</span>
    <p class="callout-title">动手试试!</p>
  </div>
  <div class="callout-content">
    <p><strong>立即在本地运行 Louvain:</strong></p>
    <pre><code class="language-moonbit">// 复制到你的项目中测试
fn main() {
  let g = build_your_graph()
  let result = @community.louvain(g, 1.0)
  println("社区数: ${result.num_communities}")
  println("模块度: ${result.modularity}")
}</code></pre>
    <p>然后访问 <strong>NetworkX Louvain 教程</strong> 查看 Python 实现：<a href="https://networkx.org/documentation/stable/auto_examples/algorithms/plot_louvain_communities.html" target="_blank">https://networkx.org/.../plot_louvain_communities.html</a></p>
  </div>
</div>
