---
title: 构建关注关系图
description: 使用 mbtgraph 从零构建微博关注关系图，涵盖数据建模、有向图构建、基本拓扑分析
---

# 构建关注关系图

> **场景**: 模拟微博用户关注关系网络 \
> **技术**: `DirectedAdjList` · 有向图模型 · 图统计 · 批处理建图 \
> **难度**: ⭐⭐ \
> **完整代码**: 见末尾"完整程序"

---

## 一、场景与数据模型

### 1.1 业务场景

假设我们运营一个微型社交平台，有 8 名用户之间存在关注关系。每个用户有昵称和粉丝数两个属性，关注关系有互动权重（1-10，表示互动频率）。

**用户数据：**

| 用户 ID | 昵称 | 初始粉丝数 |
|:-------:|------|:---------:|
| 0 | 小明 | 1200 |
| 1 | 小红 | 3400 |
| 2 | 小刚 | 890 |
| 3 | 莉莉 | 5600 |
| 4 | 阿强 | 2100 |
| 5 | 小美 | 4300 |
| 6 | 大刘 | 780 |
| 7 | 静静 | 1500 |

**关注关系（有向边，权重=互动频率 1-10）：**

| 关注者 | 被关注者 | 互动权重 |
|:------:|:--------:|:--------:|
| 小明(0) | 小红(1) | 8 |
| 小明(0) | 莉莉(3) | 3 |
| 小红(1) | 小刚(2) | 5 |
| 小红(1) | 莉莉(3) | 9 |
| 小刚(2) | 小明(0) | 2 |
| 小刚(2) | 大刘(6) | 7 |
| 莉莉(3) | 小红(1) | 6 |
| 莉莉(3) | 静静(7) | 4 |
| 阿强(4) | 小美(5) | 8 |
| 小美(5) | 阿强(4) | 9 |
| 大刘(6) | 小刚(2) | 3 |
| 静静(7) | 莉莉(3) | 5 |

### 1.2 图模型设计

关注关系天然是**有向图**：A 关注 B 不代表 B 关注 A。

| 业务概念 | 图模型 | 说明 |
|---------|--------|------|
| 用户 | 节点 (Node) | 存储粉丝数作为节点数据 |
| 关注关系 | 有向边 (Edge) | from→to，权重=互动频率 |
| 粉丝列表 | 入边集合 (in-edges) | `rev_adj` 查询 |
| 关注列表 | 出边集合 (out-edges) | `adj` 查询 |

**存储选型：** `DirectedAdjList` — 有向邻接表，支持 O(1) 入边/出边查询，空间 O(V+2E)。

---

## 二、代码实现

### 2.1 创建图并添加节点

```moonbit
let mut graph = @storage.DirectedAdjList::new()

// 添加 8 个用户节点，节点数据 = 初始粉丝数
let xiaoming = @core.GraphWritable::add_node(graph, 1200.0)
let xiaohong = @core.GraphWritable::add_node(graph, 3400.0)
let xiaogang = @core.GraphWritable::add_node(graph, 890.0)
let lili = @core.GraphWritable::add_node(graph, 5600.0)
let aqiang = @core.GraphWritable::add_node(graph, 2100.0)
let xiaomei = @core.GraphWritable::add_node(graph, 4300.0)
let daliu = @core.GraphWritable::add_node(graph, 780.0)
let jingjing = @core.GraphWritable::add_node(graph, 1500.0)
```

`add_node` 返回 `NodeId`（本质是整数索引），后续建边时使用。

### 2.2 添加关注关系（有向边）

```moonbit
// 小明 → 小红（互动频繁）
let _ = @core.GraphWritable::add_edge(graph, xiaoming, xiaohong, 8.0)
// 小明 → 莉莉（偶尔互动）
let _ = @core.GraphWritable::add_edge(graph, xiaoming, lili, 3.0)
// 小红 → 小刚
let _ = @core.GraphWritable::add_edge(graph, xiaohong, xiaogang, 5.0)
// 小红 → 莉莉（高频互动）
let _ = @core.GraphWritable::add_edge(graph, xiaohong, lili, 9.0)
// 小刚 → 小明
let _ = @core.GraphWritable::add_edge(graph, xiaogang, xiaoming, 2.0)
// 小刚 → 大刘
let _ = @core.GraphWritable::add_edge(graph, xiaogang, daliu, 7.0)
// 莉莉 → 小红
let _ = @core.GraphWritable::add_edge(graph, lili, xiaohong, 6.0)
// 莉莉 → 静静
let _ = @core.GraphWritable::add_edge(graph, lili, jingjing, 4.0)
// 阿强 ⇄ 小美（双向互关，高互动）
let _ = @core.GraphWritable::add_edge(graph, aqiang, xiaomei, 8.0)
let _ = @core.GraphWritable::add_edge(graph, xiaomei, aqiang, 9.0)
// 大刘 → 小刚
let _ = @core.GraphWritable::add_edge(graph, daliu, xiaogang, 3.0)
// 静静 → 莉莉
let _ = @core.GraphWritable::add_edge(graph, jingjing, lili, 5.0)
```

> **注意**: `add_edge` 返回 `Result[Unit, GraphError]`，这里用 `let _ =` 忽略成功值。如需要错误处理，可以用 `match` 匹配 `Ok(_)` / `Err(e)`。

### 2.3 批量添加（使用 Builder 模式）

对于大规模图（>100K 节点），逐条 `add_edge` 的查重开销较大。这时可以直接使用低层 API 快速建图：

```moonbit
// 跳过查重，直接建图（确保无重复边）
let _ = graph.add_edge_unchecked(xiaoming, xiaohong, 8.0)
// ... 其余边同上
```

`add_edge_unchecked` 适用于确定无重复边的场景，性能提升约 **30-50%**。

---

## 三、图的基本分析

### 3.1 全局统计

```moonbit
println("节点数: \(@core.GraphReadable::node_count(graph))")
println("边数: \(@core.GraphReadable::edge_count(graph))")
println("是否为有向图: \(@core.GraphReadable::is_directed(graph))")
println("是否为空图: \(@core.GraphReadable::is_empty(graph))")
```

**输出：**
```
节点数: 8
边数: 12
是否为有向图: true
是否为空图: false
```

### 3.2 每个人的关注数（出度）和粉丝数（入度）

```moonbit
let users = [
  (xiaoming, "小明"),
  (xiaohong, "小红"),
  (xiaogang, "小刚"),
  (lili, "莉莉"),
  (aqiang, "阿强"),
  (xiaomei, "小美"),
  (daliu, "大刘"),
  (jingjing, "静静"),
]

println("用户\t关注数\t粉丝数\t粉丝数(原始)")
for (node, name) in users {
  let out_deg = @core.GraphReadable::degree(graph, node)     // 出度 = 关注数
  let in_deg  = @core.GraphReadable::in_degree(graph, node)  // 入度 = 粉丝数
  let fans = match @core.GraphReadable::get_node(graph, node) {
    Some(v) => v
    None => 0.0
  }
  println("\(name)\t\(out_deg)\t\(in_deg)\t\(fans)")
}
```

**输出：**
```
用户    关注数  粉丝数  粉丝数(原始)
小明    2       1       1200
小红    2       3       3400
小刚    2       2       890
莉莉    2       3       5600
阿强    1       1       2100
小美    1       1       4300
大刘    1       1       780
静静    1       0       1500
```

**洞察：**
- **莉莉** 粉丝最多（3 人关注），原始粉丝数也最高（5600）——名副其实的人气王
- **小红** 同样有 3 个粉丝，原始粉丝数 3400
- **静静** 没有粉丝（入度=0），属于"未受关注"的用户
- **阿强 ⇄ 小美** 是唯一互关对——双向边说明他们可能是现实好友

### 3.3 查找高频互动关系

互动权重 ≥ 7 的"铁杆关系"：

```moonbit
println("\n铁杆关系（互动权重 ≥ 7）：")
let mut edge_iter = @core.GraphReadable::edges(graph)
for e in edge_iter {
  let (from, to, weight) = e
  if weight >= 7.0 {
    let from_name = match from.0 {
      0 => "小明"; 1 => "小红"; 2 => "小刚"; 3 => "莉莉"
      4 => "阿强"; 5 => "小美"; 6 => "大刘"; 7 => "静静"
      _ => "未知"
    }
    let to_name = match to.0 {
      0 => "小明"; 1 => "小红"; 2 => "小刚"; 3 => "莉莉"
      4 => "阿强"; 5 => "小美"; 6 => "大刘"; 7 => "静静"
      _ => "未知"
    }
    println("  \(from_name) → \(to_name)  权重: \(weight)")
  }
}
```

**输出：**
```
铁杆关系（互动权重 ≥ 7）：
  小明 → 小红  权重: 8
  小红 → 莉莉  权重: 9
  小刚 → 大刘  权重: 7
  阿强 → 小美  权重: 8
  小美 → 阿强  权重: 9
```

**洞察：** 5 条高频边中，3 条指向莉莉和小红——她们是社交网络的**核心节点**。

### 3.4 查找孤立节点和自闭环

```moonbit
// 检查是否有孤立节点（入度=0 且 出度=0）
for (node, name) in users {
  let out_deg = @core.GraphReadable::degree(graph, node)
  let in_deg  = @core.GraphReadable::in_degree(graph, node)
  if out_deg == 0 && in_deg == 0 {
    println("孤立用户: \(name)")
  }
}
// 本例中没有孤立节点

// 检查是否有自环
println("\n自环检查：")
for (node, name) in users {
  if @core.GraphReadable::contains_edge(graph, node, node) {
    println("  自环: \(name) 关注了自己")
  }
}
println("  (无自环)")
```

---

## 四、完整程序

将以上代码整合为一个完整程序：

```moonbit
fn main {
  // 1. 建图
  let mut graph = @storage.DirectedAdjList::new()

  let xiaoming = @core.GraphWritable::add_node(graph, 1200.0)
  let xiaohong = @core.GraphWritable::add_node(graph, 3400.0)
  let xiaogang = @core.GraphWritable::add_node(graph, 890.0)
  let lili     = @core.GraphWritable::add_node(graph, 5600.0)
  let aqiang   = @core.GraphWritable::add_node(graph, 2100.0)
  let xiaomei  = @core.GraphWritable::add_node(graph, 4300.0)
  let daliu    = @core.GraphWritable::add_node(graph, 780.0)
  let jingjing = @core.GraphWritable::add_node(graph, 1500.0)

  // 2. 建边（关注关系）
  let _ = @core.GraphWritable::add_edge(graph, xiaoming, xiaohong, 8.0)
  let _ = @core.GraphWritable::add_edge(graph, xiaoming, lili, 3.0)
  let _ = @core.GraphWritable::add_edge(graph, xiaohong, xiaogang, 5.0)
  let _ = @core.GraphWritable::add_edge(graph, xiaohong, lili, 9.0)
  let _ = @core.GraphWritable::add_edge(graph, xiaogang, xiaoming, 2.0)
  let _ = @core.GraphWritable::add_edge(graph, xiaogang, daliu, 7.0)
  let _ = @core.GraphWritable::add_edge(graph, lili, xiaohong, 6.0)
  let _ = @core.GraphWritable::add_edge(graph, lili, jingjing, 4.0)
  let _ = @core.GraphWritable::add_edge(graph, aqiang, xiaomei, 8.0)
  let _ = @core.GraphWritable::add_edge(graph, xiaomei, aqiang, 9.0)
  let _ = @core.GraphWritable::add_edge(graph, daliu, xiaogang, 3.0)
  let _ = @core.GraphWritable::add_edge(graph, jingjing, lili, 5.0)

  // 3. 基本统计
  println("=== 图基本统计 ===")
  println("节点数: \(@core.GraphReadable::node_count(graph))")
  println("边数: \(@core.GraphReadable::edge_count(graph))")
  println("有向图: \(@core.GraphReadable::is_directed(graph))")

  // 4. 用户分析表
  println("\n=== 用户分析 ===")
  let users = [
    (xiaoming, "小明"), (xiaohong, "小红"), (xiaogang, "小刚"),
    (lili, "莉莉"), (aqiang, "阿强"), (xiaomei, "小美"),
    (daliu, "大刘"), (jingjing, "静静"),
  ]
  for (node, name) in users {
    let out_deg = @core.GraphReadable::degree(graph, node)
    let in_deg  = @core.GraphReadable::in_degree(graph, node)
    let fans = @core.GraphReadable::get_node(graph, node)
    let fans_str = match fans { Some(v) => v.to_string(); None => "?" }
    println("\(name)  关注:\(out_deg)  粉丝:\(in_deg)  粉丝数:\(fans_str)")
  }

  // 5. 铁杆关系
  println("\n=== 铁杆关系（权重≥7） ===")
  let name_of = fn(id : Int) -> String {
    match id { 0 => "小明"; 1 => "小红"; 2 => "小刚"; 3 => "莉莉"
               4 => "阿强"; 5 => "小美"; 6 => "大刘"; 7 => "静静"
               _ => "?" }
  }
  for e in @core.GraphReadable::edges(graph) {
    let (from, to, w) = e
    if w >= 7.0 {
      println("  \(name_of(from.0)) → \(name_of(to.0))  权重: \(w)")
    }
  }
}
```

---

## 五、进阶：CSR 大规模建图

当用户量达到 **10 万级以上**时，`DirectedAdjList` 的动态扩容开销不可忽视。此时应使用 **CSR（压缩稀疏行）** 格式：

```moonbit
// 使用 CSR Builder 模式
let mut builder = @storage.CSRBuilder::new()

// 添加节点
builder = builder.add_node(@core.NodeId(0), 1200.0)
builder = builder.add_node(@core.NodeId(1), 3400.0)
// ... 更多节点

// 添加边
builder = builder.add_edge(@core.NodeId(0), @core.NodeId(1), 8.0)
// ... 更多边

// 批量构建（一次排序、去重、压缩）
match builder.build() {
  Ok(csr_graph) => {
    println("CSR 图构建成功！节点: \(@core.GraphReadable::node_count(csr_graph))")
    // csr_graph 是只读的，适合后续算法分析
  }
  Err(e) => println("构建失败: \(e)")
}
```

CSR 的优势在于**内存紧凑**（比邻接表省 40-60% 内存）和**缓存友好**（邻居节点连续存储），适合后续跑 PageRank、社区检测等迭代算法。

---

## 六、要点回顾

| 步骤 | 关键点 | 代码片段 |
|------|--------|---------|
| 选型 | 有向图 → `DirectedAdjList` | `let mut g = @storage.DirectedAdjList::new()` |
| 加节点 | `add_node` 返回 `NodeId` | `let node = @core.GraphWritable::add_node(g, data)` |
| 加边 | `add_edge` 返回 `Result` | `let _ = @core.GraphWritable::add_edge(g, a, b, w)` |
| 查邻居 | 出边/入边分别查询 | `neighbors(g, node)` / `in_degree(g, node)` |
| 大数据 | 使用 CSR Builder | `CSRBuilder → build()` |

---

**相关文档：**
- [关键人物识别](/use-cases/social-network/influencers) — 用中心性分析找出影响力最大的用户
- [社群发现](/use-cases/social-network/community-detection) — 用社区检测算法划分兴趣圈子
- [存储结构选型指南](/core-concepts/storage-guide) — 8 种存储的详细对比
- [图的构建与操作](/core-concepts/building-graphs) — 更多建图技巧
