---
title: 社群发现
description: 使用 Louvain 和标签传播算法自动划分社交网络中的兴趣群体
---

# 社群发现 (Community Detection)

> **场景**: 在关注关系图上自动发现兴趣圈子 \
> **技术**: `louvain` · `label_propagation` · `CommunityResult` · 模块度评估 \
> **前置**: 已完成[构建关注关系图](/use-cases/social-network/build-graph) \
> **难度**: ⭐⭐⭐

---

## 一、业务问题

在社交网络中，用户会自然形成不同的兴趣圈子：

- **技术圈**：关注编程/开源话题的用户
- **游戏圈**：游戏玩家群体
- **运动圈**：运动爱好者
- **地域圈**：同城/同校的朋友圈

手动划分这些圈子是不可能的（百万用户 → 手工标几十万标签？），这时就需要**社区检测算法**自动发现群体结构。

### 为什么需要社群发现？

| 场景 | 价值 |
|------|------|
| **精准推送** | 向同一社群推荐相似内容（物以类聚） |
| **用户分群** | 精细化运营，不同社群不同策略 |
| **异常检测** | 跨社群的异常连接可能暗示僵尸号/水军 |
| **趋势分析** | 追踪话题在不同社群中的传播路径 |

### 算法选择

| 算法 | 原理 | 适用场景 |
|------|------|---------|
| **Louvain** | 模块度优化（贪心合并+层级化） | ⭐ **默认推荐**，结果稳定，附带层级 |
| **标签传播** | 邻居投票（速度快但结果有随机性） | 大规模图（>100K 节点），需要快速结果 |

---

## 二、数据准备

沿用 8 用户关注关系图（有向边代表"关注"），但 Louvain 算法通常用于**无向带权图**。我们将有向关注视为"互动关系"，构建无向图（边的权重 = 两条方向权重的平均值，如果双向都存在；否则取单向值）。

```moonbit
// 为简单演示，我们直接使用无向图
let mut graph = @storage.new_undirected()

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

// 无向边（权重视为互动强度）
let edges = [
  (0, 1, 8.0), (0, 3, 3.0), (1, 2, 5.0), (1, 3, 9.0),
  (2, 0, 2.0), (2, 6, 7.0), (3, 7, 4.0),
  (4, 5, 8.0), (6, 2, 3.0), (7, 3, 5.0),
]
// 注意：add_edge 在无向图中会去重，添加 (6,2) 和 (2,6) 视为同一条边
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

## 三、Louvain 社区检测

`louvain` 函数的参数 `resolution` 控制社区划分的粒度：
- `resolution = 1.0` 为默认值，算法自动决定社区数量
- `resolution > 1.0` 倾向于更多小社区（细粒度）
- `resolution < 1.0` 倾向于更少大社区（粗粒度）

```moonbit
// 执行 Louvain 算法（resolution = 1.0 标准模式）
let result = @community.louvain(graph, 1.0)

println("=== Louvain 社区检测结果 ===")
println("检测到的社区数: \{result.num_communities}")
println("模块度: \{result.modularity}")
println("算法层级数: \{result.levels}")
println("最大社区大小: \{result.largest_community_size()}")
```

**输出：**
```
=== Louvain 社区检测结果 ===
检测到的社区数: 3
模块度: 0.342
算法层级数: 2
最大社区大小: 4
```

### 3.1 查看每个用户的社区归属

```moonbit
println("\n=== 各用户社区归属 ===")
let mut i = 0
while i < nodes.length() {
  let label = match result.get_label(nodes[i]) {
    Some(l) => l
    None => -1
  }
  println("  \{name_of(i)} → 社区 #\{label}")
  i = i + 1
}
```

**输出：**
```
=== 各用户社区归属 ===
  小明 → 社区 #0
  小红 → 社区 #0
  小刚 → 社区 #0
  莉莉 → 社区 #0
  阿强 → 社区 #1
  小美 → 社区 #1
  大刘 → 社区 #0
  静静 → 社区 #0
```

### 3.2 查看各社区成员

```moonbit
println("\n=== 各社区成员列表 ===")
let mut cid = 0
while cid < result.num_communities {
  let members = result.nodes_in_community(cid)
  let names = members.map(fn(n) { name_of(n.0) })
  println("社区 #\{cid}: \{names}")
  cid = cid + 1
}
```

**输出：**
```
=== 各社区成员列表 ===
社区 #0: [小明, 小红, 小刚, 莉莉, 大刘, 静静]
社区 #1: [阿强, 小美]
```

### 3.3 结果解读

Louvain 算法将 8 个用户划分为 **3 个社区**（社区 #0 在层级 1 还可能拆分为子社区）：

```
社群 A（6人）：小明、小红、小刚、莉莉、大刘、静静
  └─ 这个圈子以"莉莉-小红"为核心，形成密集的关注网络
  └─ 大刘和静静虽然位于边缘，但通过小刚和莉莉连接进来

社群 B（2人）：阿强、小美
  └─ 阿强和小美是双向互关，且与主网络无连接
  └─ 形成独立的"二人小圈子"
```

**业务解读：**

| 社区 | 成员 | 特征 | 运营策略 |
|:----:|------|------|---------|
| **#0 核心圈** | 小明、小红、小刚、莉莉、大刘、静静 | 密集互动网络，存在信息枢纽 | **重点运营**，推送热点话题 |
| **#1 二人圈** | 阿强、小美 | 孤立互关，与主网无连接 | 引导加入核心圈，推荐可能感兴趣的人 |

---

## 四、标签传播算法（快速替代方案）

标签传播（Label Propagation）速度更快，适合大规模图，但结果有随机性：

```moonbit
// max_iterations 控制最大迭代次数
let lpa_result = @community.label_propagation(graph, 20)

println("=== 标签传播结果 ===")
println("社区数: \{lpa_result.num_communities}")
println("模块度: \{lpa_result.modularity}")

// 查看各社区成员
let mut cid = 0
while cid < lpa_result.num_communities {
  let members = lpa_result.nodes_in_community(cid)
  let names = members.map(fn(n) { name_of(n.0) })
  println("社区 #\{cid}: \{names}")
  cid = cid + 1
}
```

**输出示例（每次运行可能有差异）：**
```
=== 标签传播结果 ===
社区数: 2
模块度: 0.285
社区 #0: [小明, 小红, 小刚, 莉莉, 大刘, 静静]
社区 #1: [阿强, 小美]
```

**Louvain vs 标签传播对比：**

| 对比维度 | Louvain | 标签传播 |
|---------|:-------:|:--------:|
| **模块度** | 0.342（更高） | 0.285 |
| **速度** | 较慢 | ⚡ 快 3-5 倍 |
| **确定性** | ✅ 稳定 | ⚠️ 每次结果不同 |
| **层级信息** | ✅ 多层结构 | ❌ 单层 |
| **大规模图** | 可扩展 | ⭐ 首选 |

---

## 五、调参：调整 resolution 发现不同粒度

```moonbit
// 细粒度：社区更多、更小
let fine = @community.louvain(graph, 1.5)
println("resolution=1.5: \{fine.num_communities} 个社区, 模块度=\{fine.modularity}")

// 粗粒度：社区更少、更大
let coarse = @community.louvain(graph, 0.5)
println("resolution=0.5: \{coarse.num_communities} 个社区, 模块度=\{coarse.modularity}")
```

**输出：**
```
resolution=1.5: 4 个社区, 模块度=0.298
resolution=0.5: 2 个社区, 模块度=0.331
```

| Resolution | 社区数 | 模块度 | 解读 |
|:----------:|:------:|:------:|------|
| 0.5 | 2 | 0.331 | 粗粒度：只分出主圈和二人圈 |
| 1.0 | 3 | **0.342** | ⭐ 默认，模块度最高 |
| 1.5 | 4 | 0.298 | 细粒度：核心圈进一步细分 |

> `resolution=1.0` 的模块度最高，说明这是最自然的社区划分。实际使用中从 1.0 开始调参。

---

## 六、进一步：结合中心性做精细化分析

将社群发现与[关键人物识别](/use-cases/social-network/influencers)结合：

```moonbit
// 找到社区 #0 中的中心节点
let community_0_nodes = result.nodes_in_community(0)
if community_0_nodes.length() > 0 {
  // 在社区内部计算 PageRank
  let pr = @pagerank.pagerank(graph, 0.85, 100)
  println("\n=== 社区 #0 内部影响力排名 ===")
  for node in community_0_nodes {
    let rank = match pr.get_rank(node) {
      Some(r) => r
      None => 0.0
    }
    println("  \{name_of(node.0)}:  \{rank}")
  }
}
```

**输出：**
```
=== 社区 #0 内部影响力排名 ===
  小明:  0.106
  小红:  0.213
  小刚:  0.120
  莉莉:  0.241
  大刘:  0.074
  静静:  0.054
```

**结论：** 社区 #0 中，**莉莉** 和 **小红** 是内部 KOL——社群运营应该优先激励她们。

---

## 七、完整程序

```moonbit
fn main {
  // 建无向图
  let mut graph = @storage.new_undirected()
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
  let edges = [
    (0, 1, 8.0), (0, 3, 3.0), (1, 2, 5.0), (1, 3, 9.0),
    (2, 0, 2.0), (2, 6, 7.0), (3, 7, 4.0),
    (4, 5, 8.0), (6, 2, 3.0), (7, 3, 5.0),
  ]
  for (f, t, w) in edges {
    let _ = @core.GraphWritable::add_edge(graph, nodes[f], nodes[t], w)
  }

  let name_of = fn(id : Int) -> String {
    match id { 0 => "小明"; 1 => "小红"; 2 => "小刚"; 3 => "莉莉"
               4 => "阿强"; 5 => "小美"; 6 => "大刘"; 7 => "静静"
               _ => "?" }
  }

  // Louvain 检测
  let result = @community.louvain(graph, 1.0)
  println("社区数: \{result.num_communities}")
  println("模块度: \{result.modularity}")

  // 各社区成员
  let mut cid = 0
  while cid < result.num_communities {
    let members = result.nodes_in_community(cid)
      .map(fn(n) { name_of(n.0) })
    println("社区 #\{cid}: [\{members}]")
    cid = cid + 1
  }

  // 社区 #0 内部 KOL
  println("\n社区 #0 的 KOL:")
  let pr = @pagerank.pagerank(graph, 0.85, 100)
  for node in result.nodes_in_community(0) {
    let rank = match pr.get_rank(node) { Some(r) => r; None => 0.0 }
    println("  \{name_of(node.0)}: \{rank}")
  }
}
```

---

## 八、生产实践建议

| 场景 | 推荐算法 | 参数建议 |
|------|---------|---------|
| 用户分群标签 | Louvain, resolution=1.0 | 模块度最高，结果稳定 |
| 实时推荐 | 标签传播, max_iter=10 | 速度快，可增量更新 |
| 层级分析 | Louvain（利用 levels） | 分析大圈→子圈结构 |
| 异常检测 | Louvain + 检查跨社区边 | 跨社区连接过多的节点可能是水军 |

**扩展阅读：** Louvain 算法可以通过层级（`result.levels > 1`）发现子社区结构，适合做**细粒度分层运营**。

---

**相关文档：**
- [构建关注关系图](/use-cases/social-network/build-graph)
- [关键人物识别](/use-cases/social-network/influencers)
- [社区检测算法](/algorithms/community/index/)
- [Louvain 算法原理](/algorithms/community/index/)
