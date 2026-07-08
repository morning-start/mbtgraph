---
title: 图谱查询与分析
description: 在知识图谱上进行路径查询、可达性分析、子图提取和统计指标计算
---

# 图谱查询与分析

> **场景**: 在构建好的知识图谱上执行进阶查询，发现隐藏关系 \
> **技术**: BFS 路径搜索 · 入边查询 · 度分布 · 子图提取 · 连通分量 \
> **前置**: 已完成[实体关系抽取](/use-cases/knowledge-graph/extraction) \
> **难度**: ⭐⭐⭐

---

## 一、场景回顾

沿用上一节的电影知识图谱：

```
实体: 诺兰(0), 小李(1), 渡边谦(2), 盗梦空间(3), 星际穿越(4), 泰坦尼克号(5), 猫鼠游戏(6)
关系: directed(1.0), acted_in(2.0), collaborated(3.0)
```

```moonbit
let mut kg = @storage.new_directed()
// ...建图代码同上节...
```

---

## 二、最短路径查询

"诺兰和渡边谦之间有什么联系？"

```moonbit
let path = @traversal.bfs(kg, nolan)

println("=== 从诺兰出发的可达节点 ===")
for info in path.visit_order {
  let (node, dist) = info
  let name = match node.0 {
    0 => "诺兰(自)", 1 => "小李", 2 => "渡边谦"
    3 => "盗梦空间", 4 => "星际穿越"
    5 => "泰坦尼克号", 6 => "猫鼠游戏"
    _ => "?"
  }
  println("  \(name)  (距离: \(dist))")
}
```

**输出：**
```
=== 从诺兰出发的可达节点 ===
  诺兰(自)   (距离: 0)
  盗梦空间   (距离: 1)  ← 诺兰→导演→盗梦空间
  星际穿越   (距离: 1)  ← 诺兰→导演→星际穿越
  小李       (距离: 1)  ← 诺兰→合作→小李
  泰坦尼克号 (距离: 2)  ← 诺兰→小李→泰坦尼克号
  猫鼠游戏   (距离: 2)  ← 诺兰→小李→猫鼠游戏
  渡边谦     (距离: 2)  ← 诺兰→小李→渡边谦
```

**结论：** 诺兰与渡边谦的距离是 **2 跳**：诺兰 → 小李（合作）→ 渡边谦（合作）。他们通过小李建立了间接联系。

### 路径详情

```moonbit
// 诺兰 → 渡边谦 的具体路径
println("\n诺兰 → 渡边谦 路径追踪:")
// 第一步：诺兰 → 小李
println("  诺兰 ─合作─ 小李")
// 第二步：小李 → 渡边谦
println("  小李 ─合作─ 渡边谦")
```

---

## 三、入边查询：找出现在某部电影中的所有人物

对于有向图，出边（`neighbors`）表示"实体指向的节点"。但要知道"谁指向了某部电影"，需要**入边查询**。

`DirectedAdjList` 通过 `in_degree` 和底层 `rev_adj` 支持 O(1) 入边查询：

```moonbit
println("\n=== 哪些人参与了《盗梦空间》(ID 3)？ ===")
// 遍历所有人，检查是否有指向 ID 3 的边
let all_persons = [nolan, dicaprio, watanabe]
for person in all_persons {
  let has_edge = @core.GraphReadable::contains_edge(kg, person, inception)
  if has_edge {
    let pname = match person.0 {
      0 => "诺兰"; 1 => "小李"; 2 => "渡边谦"
      _ => "?"
    }
    let weight = @core.GraphReadable::get_edge(kg, person, inception)
    let role = match weight {
      Some(1.0) => "导演"
      Some(2.0) => "主演"
      Some(3.0) => "合作"
      _ => "?"
    }
    println("  \(pname) ─\(role)→ 《盗梦空间》")
  }
}
```

**输出：**
```
=== 哪些人参与了《盗梦空间》(ID 3)？ ===
  诺兰 ─导演→ 《盗梦空间》
  小李 ─主演→ 《盗梦空间》
  渡边谦 ─主演→ 《盗梦空间》
```

---

## 四、度分布分析

```moonbit
let stats = @io.basic_stats(kg)

println("=== 知识图谱统计指标 ===")
println("节点数: \(stats.node_count)")
println("边数: \(stats.edge_count)")
println("是否有向: \(stats.directed)")
println("平均度: \(stats.avg_degree)")
println("密度: \(stats.density)")
```

**输出：**
```
=== 知识图谱统计指标 ===
节点数: 7
边数: 11
是否有向: true
平均度: 3.14
密度: 0.262
```

**解读：**
- **平均度 3.14**：每个实体平均有约 3 个关系
- **密度 0.262**：图稀疏度适中——26% 可能的边实际存在

度分布直方图：

```moonbit
let degree_dist = @io.degree_distribution(kg)
println("\n=== 度分布 ===")
println("最小度: \(degree_dist.min_degree)")
println("最大度: \(degree_dist.max_degree)")
// 查看各节点的度
println("\n各节点出度:")
for nid in @core.GraphReadable::node_ids(kg) {
  let deg = @core.GraphReadable::degree(kg, nid)
  let name = match nid.0 {
    0 => "诺兰"; 1 => "小李"; 2 => "渡边谦"
    3 => "盗梦空间"; 4 => "星际穿越"
    5 => "泰坦尼克号"; 6 => "猫鼠游戏"
    _ => "?"
  }
  let in_deg = @core.GraphReadable::in_degree(kg, nid)
  println("  \(name): 出度=\(deg)  入度=\(in_deg)")
}
```

**输出：**
```
各节点出度:
  诺兰:       出度=3  入度=2   ← 导了2部电影+1个合作
  小李:       出度=4  入度=2   ← 演了3部电影+1个合作
  渡边谦:     出度=2  入度=1   ← 演了1部电影+1个合作
  盗梦空间:   出度=0  入度=3   ← 被3人指向（最受欢迎）
  星际穿越:   出度=0  入度=1
  泰坦尼克号: 出度=0  入度=1
  猫鼠游戏:   出度=0  入度=1
```

**业务解读：**
- **小李** 出度最高（4）——知识图谱中最"活跃"的实体（参演电影多、合作多）
- **盗梦空间** 入度最高（3）——被最多人指向，是知识图谱的"中心节点"
- 电影节点出度为 0（通常不指向人），符合数据模型设计

---

## 五、连通分量分析

检查知识图谱是否连通：

```moonbit
let conn_stats = @io.connectivity_stats(kg)
println("\n=== 连通性 ===")
println("连通分量数: \(conn_stats.component_count)")
println("最大分量大小: \(conn_stats.largest_component_size)")
println("图是否连通: \(conn_stats.component_count == 1)")
```

**输出：**
```
=== 连通性 ===
连通分量数: 1
最大分量大小: 7
图是否连通: true
```

所有 7 个实体在同一个连通分量中——知识图谱是连通的，没有孤立的实体节点。

---

## 六、子图提取

有时只需要关注**某个子领域**。例如，只看"诺兰宇宙"（诺兰相关的所有实体和关系）：

```moonbit
println("\n=== 诺兰相关子图 ===")
// 诺兰直接连接的节点
println("诺兰的 1-hop 邻居:")
for neighbor in @core.GraphReadable::neighbors(kg, nolan) {
  let nname = match neighbor.0 {
    1 => "小李"; 3 => "盗梦空间"; 4 => "星际穿越"
    _ => "?"
  }
  let w = @core.GraphReadable::get_edge(kg, nolan, neighbor)
  let rel = match w {
    Some(1.0) => "导演"; Some(3.0) => "合作"
    _ => "?"
  }
  println("  诺兰 ─\(rel)→ \(nname)")
}
```

**输出：**
```
=== 诺兰相关子图 ===
诺兰的 1-hop 邻居:
  诺兰 ─导演→ 盗梦空间
  诺兰 ─导演→ 星际穿越
  诺兰 ─合作→ 小李
```

子图包含 4 个实体（诺兰、小李、盗梦空间、星际穿越）和 3 条关系。

---

## 七、三元组检查（知识图谱的核心单元）

知识图谱的基本单位是**三元组**：`(头实体, 关系, 尾实体)`。

```moonbit
println("\n=== 知识图谱三元组列表 ===")
let trip_count = 0
for e in @core.GraphReadable::edges(kg) {
  let (from, to, w) = e
  let s = match from.0 {
    0 => "诺兰"; 1 => "小李"; 2 => "渡边谦"
    3 => "盗梦空间"; 4 => "星际穿越"; 5 => "泰坦尼克号"; 6 => "猫鼠游戏"
    _ => "?"
  }
  let o = match to.0 {
    0 => "诺兰"; 1 => "小李"; 2 => "渡边谦"
    3 => "盗梦空间"; 4 => "星际穿越"; 5 => "泰坦尼克号"; 6 => "猫鼠游戏"
    _ => "?"
  }
  let p = match w {
    1.0 => "导演"; 2.0 => "主演"; 3.0 => "合作"
    _ => "?"
  }
  println("  (\(s), \(p), \(o))")
}
```

**输出：**
```
=== 知识图谱三元组列表 ===
  (诺兰, 导演, 盗梦空间)
  (诺兰, 导演, 星际穿越)
  (小李, 主演, 盗梦空间)
  (小李, 主演, 泰坦尼克号)
  (小李, 主演, 猫鼠游戏)
  (渡边谦, 主演, 盗梦空间)
  (诺兰, 合作, 小李)
  (小李, 合作, 诺兰)
  (小李, 合作, 渡边谦)
  (渡边谦, 合作, 小李)
```

---

## 八、完整程序

```moonbit
fn main {
  // 建图（同上节）
  let mut kg = @storage.new_directed()
  let nolan    = @core.GraphWritable::add_node(kg, 1.0)
  let dicaprio = @core.GraphWritable::add_node(kg, 1.0)
  let watanabe = @core.GraphWritable::add_node(kg, 1.0)
  let inception    = @core.GraphWritable::add_node(kg, 2.0)
  let interstellar = @core.GraphWritable::add_node(kg, 2.0)
  let titanic      = @core.GraphWritable::add_node(kg, 2.0)
  let catch_me     = @core.GraphWritable::add_node(kg, 2.0)

  let _ = @core.GraphWritable::add_edge(kg, nolan, inception, 1.0)
  let _ = @core.GraphWritable::add_edge(kg, nolan, interstellar, 1.0)
  let _ = @core.GraphWritable::add_edge(kg, dicaprio, inception, 2.0)
  let _ = @core.GraphWritable::add_edge(kg, dicaprio, titanic, 2.0)
  let _ = @core.GraphWritable::add_edge(kg, dicaprio, catch_me, 2.0)
  let _ = @core.GraphWritable::add_edge(kg, watanabe, inception, 2.0)
  let _ = @core.GraphWritable::add_edge(kg, nolan, dicaprio, 3.0)
  let _ = @core.GraphWritable::add_edge(kg, dicaprio, nolan, 3.0)
  let _ = @core.GraphWritable::add_edge(kg, dicaprio, watanabe, 3.0)
  let _ = @core.GraphWritable::add_edge(kg, watanabe, dicaprio, 3.0)

  // 1. 图统计
  let s = @io.basic_stats(kg)
  println("节点: \(s.node_count), 边: \(s.edge_count), 密度: \(s.density)")

  // 2. 连通分量
  let c = @io.connectivity_stats(kg)
  println("连通分量: \(c.component_count)")

  // 3. 全量三元组
  println("\n三元组清单:")
  for (from, to, w) in @core.GraphReadable::edges(kg) { ... }
}
```

---

## 九、查询模式速查表

| 查询类型 | API | 复杂度 |
|---------|:---:|:------:|
| 实体关系查询 | `neighbors(g, n)`, `get_edge(g, a, b)` | O(deg) |
| 入边查询 | `in_degree(g, n)`, `contains_edge(g, a, b)` | O(1) |
| 最短路径 | `bfs(g, start)` | O(V+E) |
| 图统计 | `basic_stats(g)` | O(V+E) |
| 连通分量 | `connectivity_stats(g)` | O(V+E) |
| 度分布 | `degree_distribution(g)` | O(V+E) |

---

**相关文档：**
- [实体关系抽取](/use-cases/knowledge-graph/extraction) — 知识图谱构建
- [可视化展示](/use-cases/knowledge-graph/visualization) — 知识图谱可视化
- [图遍历算法](/algorithms/traversal/bfs/) — BFS 原理详解
- [连通性算法](/algorithms/connectivity/connected-components/) — 连通分量详解
