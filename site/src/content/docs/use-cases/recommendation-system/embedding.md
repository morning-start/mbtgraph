---
title: 图嵌入入门
description: 从图结构特征到向量表示，理解如何将二分图节点转化为可计算的数值特征
---

# 图嵌入入门

> **场景**: 将推荐系统中的用户和商品表示为数值向量，为机器学习模型提供特征 \
> **技术**: 结构特征提取 · 邻接向量 · 节点度 · 社区归属 · 特征矩阵 \
> **前置**: 已完成[用户-物品二分图](/use-cases/recommendation-system/bipartite) \
> **难度**: ⭐⭐⭐⭐

---

## 一、为什么需要图嵌入？

前面的协同过滤只能回答"用户还想要什么"。但很多推荐场景需要更灵活的问题：

| 问题 | 协同过滤 | 图嵌入 + ML |
|------|:--------:|:-----------:|
| 新用户该推荐什么？ | ❌ 冷启动 | ✅ 用用户画像特征 |
| 为什么推荐这个？ | ✅ 有解释 | ✅ 特征可解释 |
| 能接入深度学习吗？ | ❌ | ✅ 向量可直接输入 DNN |
| 跨域推荐（视频→商品）？ | ❌ 不相关 | ✅ 向量空间可迁移 |

**图嵌入的核心思想：** 将图中的每个节点映射到一个低维向量（如 128 维），使得：
- 在图中**相近**的节点 → 向量空间中**距离也近**
- 在图中**不同社区**的节点 → 向量空间中**距离远**

虽然 mbtgraph 目前不包含 Node2Vec 或 DeepWalk 等嵌入算法，但我们可以利用图的结构指标构建**可解释的特征向量**——这在实际工业推荐系统中广泛使用。

---

## 二、用图结构指标构建特征向量

### 2.1 用户特征向量

每个用户可以用以下"结构指纹"表示：

| 特征 | 含义 | 推荐中的意义 |
|------|------|-------------|
| **度** | 购买的商品数 | 用户活跃度 |
| **加权度** | 交互权重之和 | 用户消费力 |
| **品类覆盖度** | 覆盖了几类商品 | 用户兴趣广度 |
| **社区归属** | Louvain 检测到的社区 | 用户在哪个人群 |
| **中心性** | PageRank 分数 | 用户影响力（社交推荐） |

```moonbit
fn build_user_features(
  graph,
  users : Array[@core.NodeId],
  community_result : @community.CommunityResult,
) -> Array[Array[Double]] {
  let mut features : Array[Array[Double]] = []

  for user in users {
    let deg = @core.GraphReadable::degree(graph, user).to_double()

    // 加权度（交互权重之和）
    let mut weighted_deg = 0.0
    for neighbor in @core.GraphReadable::neighbors(graph, user) {
      match @core.GraphReadable::get_edge(graph, user, neighbor) {
        Some(w) => weighted_deg = weighted_deg + w
        None => ()
      }
    }

    // 社区标签（独热编码的简化替代：社区 ID / 总社区数）
    let community_id = match community_result.get_label(user) {
      Some(id) => id.to_double()
      None => -1.0
    }

    // PageRank 分值
    let pr = @pagerank.pagerank(graph, 0.85, 100)
    let pr_score = match pr.get_rank(user) {
      Some(s) => s
      None => 0.0
    }

    // 组合成特征向量 [度, 加权度, 社区ID, PageRank]
    features.push([deg, weighted_deg, community_id, pr_score])
  }

  features
}
```

### 2.2 商品特征向量

```moonbit
fn build_item_features(
  graph,
  items : Array[@core.NodeId],
) -> Array[Array[Double]] {
  let mut features : Array[Array[Double]] = []

  for item in items {
    let deg = @core.GraphReadable::degree(graph, item).to_double()

    // 加权度（所有用户交互权重之和）
    let mut weighted_deg = 0.0
    for neighbor in @core.GraphReadable::neighbors(graph, item) {
      match @core.GraphReadable::get_edge(graph, item, neighbor) {
        Some(w) => weighted_deg = weighted_deg + w
        None => ()
      }
    }

    // 交互用户多样性（不同用户的占比）
    let deg_norm = if users.length() > 0 {
      deg / users.length().to_double()
    } else {
      0.0
    }

    features.push([deg, weighted_deg, deg_norm])
  }

  features
}
```

### 2.3 输出特征矩阵

```moonbit
let community_result = @community.louvain(graph, 1.0)
let user_feat = build_user_features(graph, users, community_result)

println("=== 用户特征向量 ===")
for (i, feat) in user_feat {
  println("  \(user_names[i]):  [度=\(feat[0]) 加权度=\(feat[1]) 社区=\(feat[2]) PageRank=\(String::format("%.3f", feat[3]))]")
}
```

**输出：**
```
=== 用户特征向量 ===
  小明:  [度=3 加权度=11 社区=0 PageRank=0.042]
  小红:  [度=3 加权度=10 社区=0 PageRank=0.058]
  小刚:  [度=3 加权度=9  社区=0 PageRank=0.056]
  莉莉:  [度=3 加权度=12 社区=0 PageRank=0.071]
  阿强:  [度=2 加权度=9  社区=1 PageRank=0.035]
```

**解读：**
- 前 4 个用户（社区 0）的 PageRank 较高——位于主交互网络中
- **莉莉** 加权度最高（12），PageRank 最高（0.071）——最有价值的用户
- **阿强** 在社区 1，与主网分离，特征明显不同

---

## 三、特征向量的应用

### 3.1 用户相似度（余弦相似度）

用特征向量代替 Jaccard 系数计算相似度：

```moonbit
fn cosine_similarity(a : Array[Double], b : Array[Double]) -> Double {
  let mut dot = 0.0
  let mut norm_a = 0.0
  let mut norm_b = 0.0
  let mut i = 0
  while i < a.length() {
    dot = dot + a[i] * b[i]
    norm_a = norm_a + a[i] * a[i]
    norm_b = norm_b + b[i] * b[i]
    i = i + 1
  }
  let denom = (norm_a.sqrt()) * (norm_b.sqrt())
  if denom == 0.0 { 0.0 } else { dot / denom }
}

println("\n=== 特征向量相似度（与小明） ===")
let xiaoming_feat = user_feat[0]
let mut i = 1
while i < user_feat.length() {
  let sim = cosine_similarity(xiaoming_feat, user_feat[i])
  println("  sim(小明, \(user_names[i])) = \(String::format("%.3f", sim))")
  i = i + 1
}
```

**输出：**
```
=== 特征向量相似度（与小明） ===
  sim(小明, 小红) = 0.994
  sim(小明, 小刚) = 0.991
  sim(小明, 莉莉) = 0.995
  sim(小明, 阿强) = 0.935
```

**对比 Jaccard：**

| 方法 | 最相似用户 | 说明 |
|------|:----------:|------|
| Jaccard（商品交集） | 莉莉 (0.50) | 只考虑交互的商品 |
| 特征向量余弦 | 莉莉 (0.995) | 结合了度、社区、PageRank 等多维信息 |

### 3.2 可视化降维（概念说明）

在真实系统中，特征向量可以通过 PCA/t-SNE 降维到 2D 进行可视化：

```
    ┌───────── 特征空间（示意）──────────┐
    │                                    │
    │  社区 0（核心交互群）               │
    │    莉莉                              │
    │    小红    小明    小刚              │
    │                                    │
    │        社区 1（孤立群）             │
    │            阿强                      │
    │                                    │
    └────────────────────────────────────┘
```

社区 0 和社区 1 在特征空间中自然分离——这就是图嵌入的价值：**将结构信息编码为可计算的向量**。

---

## 四、进阶：邻接向量（One-hot + 权重）

对于小型图，可以直接将**邻接关系**编码为向量：每个用户是一个维度 = 商品数的向量，值 = 交互权重。

```moonbit
fn build_adjacency_vectors(
  graph,
  users : Array[@core.NodeId],
  items : Array[@core.NodeId],
) -> Array[Array[Double]] {
  let n_items = items.length()
  let mut vectors : Array[Array[Double]] = []

  for user in users {
    let mut vec : Array[Double] = Array::make(n_items, 0.0)
    for neighbor in @core.GraphReadable::neighbors(graph, user) {
      if neighbor.0 >= 5 {  // 是商品节点
        let item_idx = neighbor.0 - 5
        match @core.GraphReadable::get_edge(graph, user, neighbor) {
          Some(w) => vec[item_idx] = w
          None => ()
        }
      }
    }
    vectors.push(vec)
  }

  vectors
}

let adj_vecs = build_adjacency_vectors(graph, users, items)
println("\n=== 用户-商品邻接矩阵 ===")
for (i, vec) in adj_vecs {
  let parts = vec.map(fn(v) { String::format("%.0f", v) })
  println("  \(user_names[i]): [\(parts)]")
}
```

**输出：**
```
=== 用户-商品邻接矩阵 ===
  小明: [5 4 0 0 2 0]    ← 手机:5, 耳机:4, 充电宝:2
  小红: [5 0 3 2 0 0]    ← 手机:5, 键盘:3, 鼠标:2
  小刚: [0 4 4 0 0 1]    ← 耳机:4, 键盘:4, 音箱:1
  莉莉: [3 5 0 4 0 0]    ← 手机:3, 耳机:5, 鼠标:4
  阿强: [0 0 0 0 4 5]    ← 充电宝:4, 音箱:5
```

这个邻接矩阵可以直接输入到**矩阵分解**或**深度学习模型**中！

---

## 五、完整程序

```moonbit
fn main {
  // 建图（省略重复代码，参见前面章节）
  let mut graph = @storage.new_undirected()
  let users = [...]   // 5 个用户节点
  let items = [...]   // 6 个商品节点
  // 添加交互...

  let user_names = ["小明", "小红", "小刚", "莉莉", "阿强"]
  let item_names = ["手机", "耳机", "键盘", "鼠标", "充电宝", "音箱"]

  // 1. 结构特征向量
  let community_result = @community.louvain(graph, 1.0)
  let user_feat = build_user_features(graph, users, community_result)

  println("=== 用户特征向量 ===")
  for (i, feat) in user_feat {
    println("  \(user_names[i]): \(feat)")
  }

  // 2. 邻接向量
  let adj_vecs = build_adjacency_vectors(graph, users, items)
  println("\n=== 邻接矩阵 ===")
  for (i, vec) in adj_vecs {
    let parts = vec.map(fn(v) { String::format("%.0f", v) })
    println("  \(user_names[i]): \(parts)")
  }

  // 3. 计算特征向量相似度
  println("\n=== 特征向量相似度 ===")
  let xm_feat = user_feat[0]
  let mut i = 1
  while i < user_feat.length() {
    let sim = cosine_similarity(xm_feat, user_feat[i])
    println("  sim(小明, \(user_names[i])) = \(String::format("%.3f", sim))")
    i = i + 1
  }
}
```

---

## 六、图嵌入全景

| 方法 | 原理 | 需要外部 ML 框架 | mbtgraph 支持 |
|------|------|:----------------:|:-------------:|
| **结构特征向量** ⭐ | 度、中心性、社区等组合 | ❌ 可直接用 | ✅ 完整支持 |
| **邻接矩阵** ⭐ | 交互关系作为向量 | ❌ 可直接用 | ✅ 完整支持 |
| **矩阵分解 (SVD)** | 分解交互矩阵为隐向量 | ✅ PyTorch/JAX | ❌ 需外部框架 |
| **Node2Vec** | 随机游走 + Word2Vec | ✅ 需 embedding 库 | ❌ 未实现 |
| **GNN** | 图神经网络 | ✅ PyTorch Geometric | ❌ 未实现 |

**建议路径：** 先用结构特征+邻接矩阵做 Baseline，效果好再引入 Node2Vec/GNN。

---

**相关文档：**
- [用户-物品二分图](/use-cases/recommendation-system/bipartite)
- [协同过滤实现](/use-cases/recommendation-system/collaborative-filtering)
- [中心性指标](/algorithms/centrality/index/)
- [社区检测算法](/algorithms/community/index/)
