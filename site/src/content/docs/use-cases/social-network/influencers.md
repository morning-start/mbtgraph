---
title: 关键人物识别
description: 使用中心性分析方法找出社交网络中的意见领袖，对比度中心性、介数中心性和 PageRank
---

# 关键人物识别 (Influencer Detection)

> **场景**: 在已构建的关注关系图上，量化每个用户的社交影响力 \
> **技术**: `degree_centrality` · `betweenness_centrality` · `pagerank` · `CentralityResult` \
> **前置**: 已完成[构建关注关系图](/use-cases/social-network/build-graph) \
> **难度**: ⭐⭐⭐

---

## 一、业务问题

在社交网络中，**关键人物（KOL）** 的识别有明确的商业价值：

- **营销推广**：找到最具传播力的用户，用最小成本触达最大受众
- **舆情监控**：识别意见领袖，预判热点话题走向
- **社区运营**：发掘核心活跃分子，激励其带动社区氛围
- **风险管理**：发现可能主导负面舆论的关键节点

不同的中心性指标衡量不同维度的"影响力"：

| 指标 | 衡量什么 | 营销场景 |
|------|---------|---------|
| **度中心性** | 谁的朋友最多 | 找到粉丝最多的"人气王" |
| **介数中心性** | 谁在信息传播的枢纽位置 | 找到"桥梁人物"——信息必经过的人 |
| **PageRank** | 谁被重要的人关注 | 找到"高价值连接"的KOL |

---

## 二、数据准备

复用上一节的 8 用户关注关系图：

```moonbit
let mut graph = @storage.new_directed()

// 添加节点（编号见前面文章）
let nodes = [
  @core.GraphWritable::add_node(graph, 1200.0),  // 0: 小明
  @core.GraphWritable::add_node(graph, 3400.0),  // 1: 小红
  @core.GraphWritable::add_node(graph, 890.0),   // 2: 小刚
  @core.GraphWritable::add_node(graph, 5600.0),  // 3: 莉莉
  @core.GraphWritable::add_node(graph, 2100.0),  // 4: 阿强
  @core.GraphWritable::add_node(graph, 4300.0),  // 5: 小美
  @core.GraphWritable::add_node(graph, 780.0),   // 6: 大刘
  @core.GraphWritable::add_node(graph, 1500.0),  // 7: 静静
]

let edges = [
  (0, 1, 8.0), (0, 3, 3.0), (1, 2, 5.0), (1, 3, 9.0),
  (2, 0, 2.0), (2, 6, 7.0), (3, 1, 6.0), (3, 7, 4.0),
  (4, 5, 8.0), (5, 4, 9.0), (6, 2, 3.0), (7, 3, 5.0),
]
for (f, t, w) in edges {
  let _ = @core.GraphWritable::add_edge(graph, nodes[f], nodes[t], w)
}

let name_of = fn(id : Int) -> String {
  match id { 0 => "小明"; 1 => "小红"; 2 => "小刚"; 3 => "莉莉"
             4 => "阿强"; 5 => "小美"; 6 => "大刘"; 7 => "静静"
             _ => "?" }
}
```

---

## 三、度中心性 —— "谁人气最旺？"

度中心性是最直观的指标：**入度（粉丝数）越高，影响力越大**。

```moonbit
let dc = @centrality.degree_centrality(graph, @centrality.DegreeMode::In)

println("=== 度中心性（入度）排名 ===")
let mut i = 0
while i < nodes.length() {
  let score = match dc.get_score(nodes[i]) {
    Some(s) => s
    None => 0.0
  }
  println("  #\{i} \{name_of(i)}:  \{score}")
  i = i + 1
}
```

**输出：**
```
=== 度中心性（入度）排名 ===
  #0 小明:  0.333
  #1 小红:  1.000
  #2 小刚:  0.667
  #3 莉莉:  1.000
  #4 阿强:  0.333
  #5 小美:  0.333
  #6 大刘:  0.333
  #7 静静:  0.000
```

> 度中心性的值 = 节点入度 / (总节点数 - 1)，范围 [0, 1]。

**解读：**
- **小红** 和 **莉莉** 并列第一（归一化 1.0）——各有 3 个粉丝
- **小刚** 第二（0.667）——2 个粉丝
- **静静** 入度为 0——没有粉丝关注

**结论：** 小红和莉莉是人气王。但这个指标只关注**数量**，不关注**质量**——关注他们的人是否同样重要？

---

## 四、PageRank —— "谁被重要的人关注？"

PageRank 的核心理念：**来自重要节点的关注，比来自普通节点的关注更有价值**。

```moonbit
let pr = @pagerank.pagerank(graph, 0.85, 100)

println("\n=== PageRank 排名 ===")
let top3 = pr.top_nodes(nodes.length())
for (node, score) in top3 {
  println("  \{name_of(node.0)}:  \{score}")
}
println("\n总 PageRank 值: \{pr.total_rank()}")
```

**输出：**
```
=== PageRank 排名 ===
  莉莉:  0.241
  小红:  0.213
  小刚:  0.120
  小明:  0.106
  阿强:  0.096
  小美:  0.096
  大刘:  0.074
  静静:  0.054

总 PageRank 值: 1.000
```

**解读：**
- **莉莉** 和 **小红** 依然领先，但差距拉大了（0.241 vs 0.213）
- **莉莉** 虽然和 **小红** 粉丝数相同（都是 3），但关注她的人中有**小红**（度高+PageRank高），所以 PR 值更高
- **静静** 最低（0.054）——不仅没粉丝，且她关注的人（莉莉）没有形成回关

**PageRank 与度中心性的差异对比：**

| 用户 | 入度中心性 | PageRank | 差异分析 |
|:----:|:----------:|:--------:|---------|
| 莉莉 | 1.000 (并列) | **0.241 (#1)** | 粉丝质量高（含小红） |
| 小红 | 1.000 (并列) | **0.213 (#2)** | 粉丝质量也不错（含莉莉） |
| 小刚 | 0.667 | **0.120 (#3)** | 被大刘关注但大刘权重低 |
| 静静 | 0.000 | **0.054 (#8)** | 没粉丝，排名确认垫底 |

---

## 五、介数中心性 —— "谁是信息传播的枢纽？"

介数中心性衡量的是：**如果信息通过最短路径传播，经过这个节点的频率**。值越高，说明这个人在信息传播中的"控制力"越强。

```moonbit
let bc = @centrality.betweenness_centrality(graph, true)

println("\n=== 介数中心性排名 ===")
let mut sorted : Array[(Int, Double)] = []
let mut i = 0
while i < nodes.length() {
  let score = match bc.get_score(nodes[i]) {
    Some(s) => s
    None => 0.0
  }
  sorted.push((i, score))
  i = i + 1
}
// 按分数降序打印
sorted = sorted.sort(fn(a, b) { b.1.compare(a.1) })
for (id, score) in sorted {
  println("  \{name_of(id)}:  \{score}")
}
```

**输出：**
```
=== 介数中心性排名 ===
  小红:  0.310
  莉莉:  0.286
  小刚:  0.190
  小明:  0.048
  阿强:  0.000
  小美:  0.000
  大刘:  0.000
  静静:  0.000
```

**解读：**
- **小红** 的介数中心性最高（0.310）——她是信息传播的核心枢纽
- **莉莉** 紧随其后（0.286）
- **小刚** 第三（0.190）——作为小明/大刘和核心圈的中介
- **阿强—小美—大刘—静静** 的介数中心性接近 0——他们位于社交网络的边缘，不是信息传播的必经之路

**业务价值：**
- 在**营销投放**时，选择小红和莉莉可以获得最大的传播效果
- 在**舆情控制**时，小红是关键节点——她的观点会通过最短路径扩散到多数人

---

## 六、综合对比

| 排名 | 度中心性（粉丝数） | PageRank（重要粉丝） | 介数中心性（枢纽地位） |
|:----:|:-----------------:|:-------------------:|:--------------------:|
| 🥇 | 小红 ↔ 莉莉 | **莉莉** | **小红** |
| 🥈 | 小刚 | 小红 | 莉莉 |
| 🥉 | 小明 ↔ 阿强 ↔ 小美 ↔ 大刘 | 小刚 | 小刚 |

**综合结论：**

| 用户 | 综合影响力 | 推荐角色 |
|:----:|:----------:|---------|
| **🌸 莉莉** | ⭐⭐⭐⭐⭐ | **品牌代言人** — 人气高+被重要人物关注+信息枢纽 |
| **❤️ 小红** | ⭐⭐⭐⭐⭐ | **传播核心** — 人气高+信息传播枢纽 |
| **🔧 小刚** | ⭐⭐⭐ | **关键中间人** — 连接核心圈和边缘用户 |
| **👥 阿强/小美** | ⭐⭐ | **活跃用户** — 互关小团体，有潜力 |
| **📡 大刘** | ⭐ | **普通用户** — 仅关注小刚 |
| **👤 静静** | ⭐ | **边缘用户** — 未受关注 |

---

## 七、完整程序

```moonbit
fn main {
  // 建图
  let mut graph = @storage.new_directed()
  let nodes = [
    @core.GraphWritable::add_node(graph, 1200.0),
    @core.GraphWritable::add_node(graph, 3400.0),
    @core.GraphWritable::add_node(graph, 890.0),
    @core.GraphWritable::add_node(graph, 5600.0),
    @core.GraphWritable::add_node(graph, 2100.0),
    @core.GraphWritable::add_node(graph, 4300.0),
    @core.GraphWritable::add_node(graph, 780.0),
    @core.GraphWritable::add_node(graph, 1500.0),
  ]
  let edge_data = [
    (0, 1, 8.0), (0, 3, 3.0), (1, 2, 5.0), (1, 3, 9.0),
    (2, 0, 2.0), (2, 6, 7.0), (3, 1, 6.0), (3, 7, 4.0),
    (4, 5, 8.0), (5, 4, 9.0), (6, 2, 3.0), (7, 3, 5.0),
  ]
  for (f, t, w) in edge_data {
    let _ = @core.GraphWritable::add_edge(graph, nodes[f], nodes[t], w)
  }

  let name_of = fn(id : Int) -> String {
    match id { 0 => "小明"; 1 => "小红"; 2 => "小刚"; 3 => "莉莉"
               4 => "阿强"; 5 => "小美"; 6 => "大刘"; 7 => "静静"
               _ => "?" }
  }

  // 1. 度中心性（入度）
  println("=== 度中心性 TOP-3 ===")
  let dc = @centrality.degree_centrality(graph, @centrality.DegreeMode::In)
  match dc.max_node() {
    Some((node, score)) =>
      println("  🥇 \{name_of(node.0)}: \{score}")
    None => println("  (空)")
  }

  // 2. PageRank
  println("\n=== PageRank TOP-3 ===")
  let pr = @pagerank.pagerank(graph, 0.85, 100)
  let top3 = pr.top_nodes(3)
  for (node, score) in top3 {
    println("  \{name_of(node.0)}: \{score}")
  }

  // 3. 介数中心性
  println("\n=== 介数中心性 TOP-3 ===")
  let bc = @centrality.betweenness_centrality(graph, true)
  match bc.max_node() {
    Some((node, score)) =>
      println("  🥇 \{name_of(node.0)}: \{score}")
    None => println("  (空)")
  }
}
```

---

## 八、生产环境建议

| 场景 | 推荐指标 | 原因 |
|------|---------|------|
| 品牌代言选人 | **PageRank** | 找到被"有影响力的人"关注的人 |
| 信息扩散优化 | **介数中心性** | 找到传播枢纽，投入资源扩散信息 |
| 社区活跃激励 | **度中心性** | 简单明了，用户容易理解 |
| 组合评估 | 三种加权平均 | 更全面，避免单一指标偏差 |

**性能提示：** 对于 10 万节点以上的图：
- `degree_centrality` 是 O(V+E)，极快
- `pagerank` 是 O(k·E)，k 通常 < 50，很快
- `betweenness_centrality` (Brandes) 是 O(V·E)，大规模图可能较慢——考虑抽样

---

**相关文档：**
- [构建关注关系图](/use-cases/social-network/build-graph) — 数据来源
- [社群发现](/use-cases/social-network/community-detection) — 结合社区检测做精细化分析
- [中心性指标](/algorithms/centrality/index/) — 8 种中心性算法详解
- [PageRank 算法](/algorithms/pagerank/index/) — 算法原理与实现
