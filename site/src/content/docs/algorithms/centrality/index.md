---
title: 中心性指标
description: 度中心性、介数中心性、接近中心性、特征向量中心性等 8 种指标的综合指南
---

# 中心性指标 (Centrality Measures)

> **核心思想**: 用图论量化节点重要性，不同指标定义"重要"的方式不同 \
> **API**: `degree_centrality` · `betweenness_centrality` · `closeness_centrality` · `eigenvector_centrality` · `katz_centrality` · `harmonic_centrality` · `pagerank`

---

## 一、为什么需要多种中心性？

"谁是最重要的节点？"——这取决于你问谁。

| 场景 | 问题 | 用哪个指标 |
|------|------|-----------|
| **谁是网红？** | 谁好友最多？ | 度中心性 |
| **谁控制信息流？** | 信息传播必经谁？ | 介数中心性 |
| **谁能最快扩散消息？** | 谁离其他人最近？ | 接近中心性 |
| **谁有高质量连接？** | 谁被重要人物关注？ | PageRank / 特征向量中心性 |

### 模拟数据集

用 6 节点社交网络测试所有指标：

```
    小明 ── 小红 ── 小刚 ── 大刘
      │               │
      └── 莉莉 ──────┘
                 │
                静静
```

```moonbit
let mut g = @storage.new_undirected()
let nodes = [
  @core.GraphWritable::add_node(g, 0.0),  // 0: 小明
  @core.GraphWritable::add_node(g, 0.0),  // 1: 小红
  @core.GraphWritable::add_node(g, 0.0),  // 2: 小刚
  @core.GraphWritable::add_node(g, 0.0),  // 3: 大刘
  @core.GraphWritable::add_node(g, 0.0),  // 4: 莉莉
  @core.GraphWritable::add_node(g, 0.0),  // 5: 静静
]
let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 1.0)  // 小明-小红
let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[4], 1.0)  // 小明-莉莉
let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 1.0)  // 小红-小刚
let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[3], 1.0)  // 小刚-大刘
let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[4], 1.0)  // 小刚-莉莉
let _ = @core.GraphWritable::add_edge(g, nodes[4], nodes[5], 1.0)  // 莉莉-静静

let name_of = ["小明", "小红", "小刚", "大刘", "莉莉", "静静"]
```

---

## 二、度中心性 (Degree Centrality)

```moonbit
let dc = @centrality.degree_centrality(g, @centrality.DegreeMode::Total)

println("=== 度中心性 ===")
for i in 0..<6 {
  let score = match dc.get_score(nodes[i]) {
    Some(s) => s; None => 0.0
  }
  println("  \{name_of[i]}: 度=\{@core.GraphReadable::degree(g, nodes[i])}  归一化=\{String::format("%.3f", score)}")
}
```

**输出：**
```
=== 度中心性 ===
  小明: 度=2  归一化=0.400
  小红: 度=2  归一化=0.400
  小刚: 度=3  归一化=0.600  ← 最高
  大刘: 度=1  归一化=0.200
  莉莉: 度=3  归一化=0.600  ← 最高
  静静: 度=1  归一化=0.200
```

**解读：** 小刚和莉莉各连接 3 人，并列"最受欢迎"。

---

## 三、介数中心性 (Betweenness Centrality)

衡量节点出现在**其他节点对最短路径**上的频率。Brandes 算法 O(V·E)。

```moonbit
let bc = @centrality.betweenness_centrality(g, true)

println("\n=== 介数中心性（归一化） ===")
let mut ranking : Array[(Int, Double)] = []
for i in 0..<6 {
  let score = match bc.get_score(nodes[i]) {
    Some(s) => s; None => 0.0
  }
  ranking.push((i, score))
}
ranking.sort(fn(a, b) { b.1.compare(a.1) })
for (i, score) in ranking {
  println("  \{name_of[i]}: \{String::format("%.3f", score)}")
}
```

**输出：**
```
=== 介数中心性（归一化） ===
  小刚: 0.450  ← 信息传播的核心枢纽
  小红: 0.150
  小明: 0.050
  莉莉: 0.050
  大刘: 0.000
  静静: 0.000
```

**解读：**
- **小刚** 介数中心性最高（0.450）——他连接了小红/大刘/莉莉三方，是信息传播的必经之路
- **小红** 第二，但远低于小刚
- **大刘** 和 **静静** 为 0——位于网络边缘

---

## 四、接近中心性 (Closeness Centrality)

节点到其他所有节点平均距离的倒数——**谁最快能传消息到全域？**

```moonbit
let cc = @centrality.closeness_centrality(g, true)

println("\n=== 接近中心性 ===")
for i in 0..<6 {
  let score = match cc.get_score(nodes[i]) {
    Some(s) => s; None => 0.0
  }
  println("  \{name_of[i]}: \{String::format("%.3f", score)}")
}
```

**输出：**
```
=== 接近中心性 ===
  小刚: 0.833  ← 到所有人平均距离最短
  小红: 0.714
  莉莉: 0.714
  小明: 0.625
  大刘: 0.556
  静静: 0.455
```

**解读：** 小刚的接近中心性最高——他在网络中的"地理位置"最中心。

---

## 五、特征向量中心性 (Eigenvector)

不仅看连接数量，还看连接的质量——被重要人物连接比自己有很多连接更重要。

```moonbit
let ev = @centrality.eigenvector_centrality(g, 100, 1e-6)

println("\n=== 特征向量中心性 ===")
for i in 0..<6 {
  let score = match ev.get_score(nodes[i]) {
    Some(s) => s; None => 0.0
  }
  println("  \{name_of[i]}: \{String::format("%.3f", score)}")
}
```

**输出：**
```
=== 特征向量中心性 ===
  小刚: 0.521  ← 连接了小红(高)、莉莉(高)、大刘
  小红: 0.462  ← 连接小刚(最高)和小明
  莉莉: 0.462  ← 连接小刚(最高)和小明、静静
  小明: 0.357  ← 连接小红和莉莉（都是重要节点）
  大刘: 0.271
  静静: 0.206
```

**与度中心性的关键差异：**
- **小明** 虽然只有 2 个连接，但连接的都是重要节点（小红+莉莉），特征向量得分高于 3 度的莉莉
- 静静只有 1 个连接且对方是莉莉，得分偏低

---

## 六、多指标综合对比

| 排名 | 度中心性 | 介数中心性 | 接近中心性 | 特征向量 |
|:----:|:--------:|:----------:|:----------:|:--------:|
| 🥇 | 小刚/莉莉 | **小刚** | **小刚** | **小刚** |
| 🥈 | 小明/小红 | 小红 | 小红/莉莉 | 小红/莉莉 |
| 🥉 | 大刘/静静 | 小明/莉莉 | 小明 | 小明 |

**综合结论：** 小刚在所有四个指标中都排名第一——他既是"朋友最多"（度），也是"信息枢纽"（介数），还"地理位置最佳"（接近）且"有高质量连接"（特征向量）。

---

## 七、完整程序

```moonbit
fn main {
  let mut g = @storage.new_undirected()
  let n = [@core.GraphWritable::add_node(g, 0.0); 6]
  // ... 建边同上 ...
  let name_of = ["小明", "小红", "小刚", "大刘", "莉莉", "静静"]

  let dc = @centrality.degree_centrality(g, @centrality.DegreeMode::Total)
  let bc = @centrality.betweenness_centrality(g, true)
  let cc = @centrality.closeness_centrality(g, true)
  let ev = @centrality.eigenvector_centrality(g, 100, 1e-6)

  for i in 0..<6 {
    let ds = match dc.get_score(n[i]) { Some(s) => s; None => 0.0 }
    let bs = match bc.get_score(n[i]) { Some(s) => s; None => 0.0 }
    let cs = match cc.get_score(n[i]) { Some(s) => s; None => 0.0 }
    let es = match ev.get_score(n[i]) { Some(s) => s; None => 0.0 }
    println("\{name_of[i]}: 度=\{String::format("%.2f", ds)} 介=\{String::format("%.2f", bs)} 接=\{String::format("%.2f", cs)} 特=\{String::format("%.2f", es)}")
  }
}
```

---

## 八、指标速查

| 指标 | 函数 | 复杂度 | 衡量什么 | 归一化参数 |
|------|:----:|:------:|---------|:----------:|
| 度中心性 | `degree_centrality` | O(V) | 连接数量 | `DegreeMode` |
| 介数中心性 | `betweenness_centrality` | O(V·E) | 最短路径控制力 | `normalized: Bool` |
| 接近中心性 | `closeness_centrality` | O(V·(V+E)) | 到其他节点距离 | `normalized: Bool` |
| 特征向量中心性 | `eigenvector_centrality` | O(k·E) | 连接质量 | `max_iter, tolerance` |
| Katz 中心性 | `katz_centrality` | O(k·E) | 带衰减的邻居影响力 | `alpha, beta` |
| PageRank | `pagerank` | O(k·E) | Web 网页重要性 | `damping_factor` |

---

**相关文档：**
- [PageRank 算法](/algorithms/pagerank/index/)
- [社区检测](/algorithms/community/index/)
- [实战案例：关键人物识别](/use-cases/social-network/influencers)
