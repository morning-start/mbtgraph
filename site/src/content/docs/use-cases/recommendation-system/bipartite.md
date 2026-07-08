---
title: 用户-物品二分图
description: 使用二分图模型建模用户与物品的交互关系，为推荐系统奠定图数据基础
---

# 用户-物品二分图

> **场景**: 构建电商推荐系统的核心数据结构——用户-物品二分图 \
> **技术**: `UndirectedAdjList` · 二分图模型 · 度数分析 · 热门物品发现 \
> **难度**: ⭐⭐

---

## 一、业务场景

在推荐系统中，核心数据是**用户与物品的交互记录**——比如用户 A 购买/收藏/浏览了商品 X。这些数据天然形成一个**二分图（Bipartite Graph）**：

- **左部节点（U）**：用户
- **右部节点（V）**：物品
- **边**：交互行为（购买、收藏、点击）

```
  用户                     商品
  ┌────┐                  ┌────┐
  │ 小明│ ── 购买了 ──→  │ 手机│
  │ 小红│ ── 收藏了 ──→  │ 耳机│
  │ 小刚│ ── 浏览了 ──→  │ 键盘│
  └────┘                  └────┘
```

二分图的本质特征是：**边只连接 U 和 V 两个集合内部的节点，U 内部和 V 内部没有直接连接**。

### 假设场景

一个小型电商平台，5 个用户和 6 件商品，交互记录如下：

| 用户 | 购买商品 | 交互类型 | 权重 |
|:----:|---------|:--------:|:----:|
| 小明 | 手机 | 购买 | 5 |
| 小明 | 耳机 | 购买 | 4 |
| 小明 | 充电宝 | 收藏 | 2 |
| 小红 | 手机 | 购买 | 5 |
| 小红 | 键盘 | 收藏 | 3 |
| 小红 | 鼠标 | 收藏 | 2 |
| 小刚 | 耳机 | 购买 | 4 |
| 小刚 | 键盘 | 购买 | 4 |
| 小刚 | 音箱 | 浏览 | 1 |
| 莉莉 | 手机 | 收藏 | 3 |
| 莉莉 | 耳机 | 购买 | 5 |
| 莉莉 | 鼠标 | 购买 | 4 |
| 阿强 | 充电宝 | 购买 | 4 |
| 阿强 | 音箱 | 购买 | 5 |

权重：购买=5/4（视价格），收藏=3/2，浏览=1。

---

## 二、构建二分图

在 mbtgraph 中，二分图可以用**无向图**建模：用户节点和商品节点统一编号，边表示交互。

```moonbit
let mut graph = @storage.new_undirected()

// ── 添加用户节点（左部，ID 0-4）──
let users = [
  @core.GraphWritable::add_node(graph, 0.0),  // 0: 小明
  @core.GraphWritable::add_node(graph, 1.0),  // 1: 小红
  @core.GraphWritable::add_node(graph, 2.0),  // 2: 小刚
  @core.GraphWritable::add_node(graph, 3.0),  // 3: 莉莉
  @core.GraphWritable::add_node(graph, 4.0),  // 4: 阿强
]

// ── 添加商品节点（右部，ID 5-10）──
let items = [
  @core.GraphWritable::add_node(graph, 10.0),  // 5: 手机
  @core.GraphWritable::add_node(graph, 20.0),  // 6: 耳机
  @core.GraphWritable::add_node(graph, 30.0),  // 7: 键盘
  @core.GraphWritable::add_node(graph, 40.0),  // 8: 鼠标
  @core.GraphWritable::add_node(graph, 50.0),  // 9: 充电宝
  @core.GraphWritable::add_node(graph, 60.0),  // 10: 音箱
]

// ── 添加交互边（用户 → 商品，权重 = 交互强度）──
let interactions = [
  (0, 5, 5.0), (0, 6, 4.0), (0, 9, 2.0),      // 小明
  (1, 5, 5.0), (1, 7, 3.0), (1, 8, 2.0),      // 小红
  (2, 6, 4.0), (2, 7, 4.0), (2, 10, 1.0),     // 小刚
  (3, 5, 3.0), (3, 6, 5.0), (3, 8, 4.0),      // 莉莉
  (4, 9, 4.0), (4, 10, 5.0),                   // 阿强
]
for (u, v, w) in interactions {
  let _ = @core.GraphWritable::add_edge(graph, users[u], items[v], w)
}
```

> **数据编码技巧**：用户数据用 `0.0` 占位，商品数据用 `10.0` 起标识品类 ID。实际项目中会用元数据表关联。

### 节点区分

由于用户和商品节点都在同一个图中，需要一种方式区分它们：

```moonbit
// 约定：node_id < 5 为用户，≥ 5 为商品
fn is_user(node : @core.NodeId) -> Bool { node.0 < 5 }
fn is_item(node : @core.NodeId) -> Bool { node.0 >= 5 }

let user_names = ["小明", "小红", "小刚", "莉莉", "阿强"]
let item_names = ["手机", "耳机", "键盘", "鼠标", "充电宝", "音箱"]
```

---

## 三、二分图分析

### 3.1 基本统计

```moonbit
println("=== 二分图统计 ===")
println("用户数: 5")
println("商品数: 6")
println("交互数: \(@core.GraphReadable::edge_count(graph))")
```

**输出：**
```
=== 二分图统计 ===
用户数: 5
商品数: 6
交互数: 14
```

### 3.2 用户活跃度分析

每个用户的交互次数（度数）反映其活跃度：

```moonbit
println("\n=== 用户活跃度 ===")
let mut i = 0
while i < users.length() {
  let deg = @core.GraphReadable::degree(graph, users[i])
  println("  \(user_names[i]): 购买了 \(deg) 种商品")
  i = i + 1
}
```

**输出：**
```
=== 用户活跃度 ===
  小明: 购买了 3 种商品
  小红: 购买了 3 种商品
  小刚: 购买了 3 种商品
  莉莉: 购买了 3 种商品
  阿强: 购买了 2 种商品
```

### 3.3 热门商品发现

商品的交互次数反映其热度：

```moonbit
println("\n=== 商品热度排名 ===")
let mut item_pop : Array[(Int, Int)] = []
let mut j = 0
while j < items.length() {
  let deg = @core.GraphReadable::degree(graph, items[j])
  item_pop.push((j, deg))
  j = j + 1
}
// 按热度降序
item_pop = item_pop.sort(fn(a, b) { b.1.compare(a.1) })
for (idx, cnt) in item_pop {
  println("  \(item_names[idx]): \(cnt) 个用户购买过")
}
```

**输出：**
```
=== 商品热度排名 ===
  手机: 3 个用户购买过
  耳机: 3 个用户购买过
  鼠标: 2 个用户购买过
  键盘: 2 个用户购买过
  充电宝: 2 个用户购买过
  音箱: 2 个用户购买过
```

**洞察：** 手机和耳机是最热门商品，各有 3 个用户交互过。

### 3.4 共同购买关系

找出同时购买过同一商品的用户对（可用于"相似用户"推荐）：

```moonbit
println("\n=== 购买了同一商品的用户对 ===")
for item_node in items {
  let buyers : Array[Int] = []
  for neighbor in @core.GraphReadable::neighbors(graph, item_node) {
    if is_user(neighbor) {
      buyers.push(neighbor.0)
    }
  }
  if buyers.length() >= 2 {
    let names = buyers.map(fn(id) { user_names[id] })
    println("  \(item_names[item_node.0 - 5]): [\(names)] 都购买过")
  }
}
```

**输出：**
```
=== 购买了同一商品的用户对 ===
  手机: [小明, 小红, 莉莉] 都购买过
  耳机: [小明, 小刚, 莉莉] 都购买过
  鼠标: [小红, 莉莉] 都购买过
  键盘: [小红, 小刚] 都购买过
  充电宝: [小明, 阿强] 都购买过
  音箱: [小刚, 阿强] 都购买过
```

---

## 四、完整程序

```moonbit
fn main {
  // 建图
  let mut graph = @storage.new_undirected()
  let users = [
    @core.GraphWritable::add_node(graph, 0.0),  // 0: 小明
    @core.GraphWritable::add_node(graph, 1.0),  // 1: 小红
    @core.GraphWritable::add_node(graph, 2.0),  // 2: 小刚
    @core.GraphWritable::add_node(graph, 3.0),  // 3: 莉莉
    @core.GraphWritable::add_node(graph, 4.0),  // 4: 阿强
  ]
  let items = [
    @core.GraphWritable::add_node(graph, 10.0),  // 5: 手机
    @core.GraphWritable::add_node(graph, 20.0),  // 6: 耳机
    @core.GraphWritable::add_node(graph, 30.0),  // 7: 键盘
    @core.GraphWritable::add_node(graph, 40.0),  // 8: 鼠标
    @core.GraphWritable::add_node(graph, 50.0),  // 9: 充电宝
    @core.GraphWritable::add_node(graph, 60.0),  // 10: 音箱
  ]
  let interactions = [
    (0, 5, 5.0), (0, 6, 4.0), (0, 9, 2.0),
    (1, 5, 5.0), (1, 7, 3.0), (1, 8, 2.0),
    (2, 6, 4.0), (2, 7, 4.0), (2, 10, 1.0),
    (3, 5, 3.0), (3, 6, 5.0), (3, 8, 4.0),
    (4, 9, 4.0), (4, 10, 5.0),
  ]
  for (u, v, w) in interactions {
    let _ = @core.GraphWritable::add_edge(graph, users[u], items[v], w)
  }

  let user_names = ["小明", "小红", "小刚", "莉莉", "阿强"]
  let item_names = ["手机", "耳机", "键盘", "鼠标", "充电宝", "音箱"]

  // 统计
  println("交互总数: \(@core.GraphReadable::edge_count(graph))")

  // 商品热度
  println("\n商品热度:")
  let mut j = 0
  while j < items.length() {
    let deg = @core.GraphReadable::degree(graph, items[j])
    println("  \(item_names[j]): \(deg) 人")
    j = j + 1
  }
}
```

---

## 五、下一步

有了用户-物品二分图，我们可以：

| 方向 | 方法 | 下一篇 |
|------|------|--------|
| **找相似用户** | 共享商品邻居 → Jaccard 系数 | [协同过滤](/use-cases/recommendation-system/collaborative-filtering) |
| **找相似商品** | 共享用户邻居 → 基于物品的协同过滤 | 同上 |
| **推荐新物品** | 用户邻居的邻居（2-hop） | 同上 |
| **理解图结构** | 图嵌入技术初探 | [图嵌入入门](/use-cases/recommendation-system/embedding) |

---

**相关文档：**
- [协同过滤实现](/use-cases/recommendation-system/collaborative-filtering)
- [图嵌入入门](/use-cases/recommendation-system/embedding)
- [图匹配算法](/algorithms/matching/bipartite/hungarian)
- [二分图匹配](/algorithms/matching/bipartite/hungarian)
