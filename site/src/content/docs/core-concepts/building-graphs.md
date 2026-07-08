---
title: 创建节点和边
description: 从零开始构建图结构：创建空图、添加节点、构建边、设置权重
---

# 创建节点和边

本章将教你如何从零开始构建一个完整的图。我们将覆盖**所有 8 种存储类型**的建图方式，以及**批量操作**和**复杂图模式**。

## 快速入门：5 步创建第一个图

```moonbit
// Step 1: 选择存储类型并创建空图
let mut g = @storage.new_directed()

// Step 2: 添加节点（返回 NodeId）
let node_a = @core.GraphWritable::add_node(g, 1.0)
let node_b = @core.GraphWritable::add_node(g, 2.0)

// Step 3: 添加边（自动维护索引）
let result = @core.GraphWritable::add_edge(g, node_a, node_b, 10.0)

// Step 4: 验证结果
match result {
  Ok(_) => println("✅ 图构建成功!")
  Err(e) => println("❌ 错误: \{e}")
}

// Step 5: 使用图
println("节点数: \{@core.GraphReadable::node_count(g)}")
println("边数: \{@core.GraphReadable::edge_count(g)}")
```

---

## 一、创建空图

### 1.1 有向图存储

#### DirectedAdjList - 默认推荐

```moonbit
// 方式 A: 默认构造（无预分配）
let g1 = @storage.new_directed()

// 方式 B: 带容量预分配（性能更优）
let g2 = @storage.DirectedAdjList::new_with_capacity(1000, 5000)
// 参数: 预估节点数, 预估边数
// 优势: 减少动态扩容次数，提升批量建图性能 20-30%
```

#### DirectedMatrix - 稠密小图

```moonbit
// 必须指定初始大小（矩阵固定）
let g = @storage.DirectedMatrix::new_with_capacity(10) // 10×10 矩阵
// 后续可通过 add_node 扩容，但会触发 O(V) 重分配
```

#### EdgeList - 边集数组

```moonbit
let g = @storage.new_edge_list()
// 无需预分配，动态增长
```

#### CSR/CSC - 大规模静态图（Builder 模式）

```moonbit
// CSR 使用 Builder 模式（不可变）
let mut builder = @storage.CSRBuilder::new()

// 添加节点和边到 Builder
builder = builder.add_node(@core.NodeId(0), 0.9)
builder = builder.add_edge(@core.NodeId(0), @core.NodeId(1), 2.5)

// 最终构建（一次性优化排序+去重）
match builder.build() {
  Ok(csr_graph) => { /* 使用 csr_graph */ }
  Err(e) => println("构建失败: \{e}")
}
```

### 1.2 无向图存储

```moonbit
// 无向邻接表（空间减半！）
let undirected_g = @storage.new_undirected()

// 无向边集（Kruskal 友好）
let edge_list_g = @storage.new_undirected_edge_list()
```

### 1.3 如何选择？

| 场景 | 推荐存储 | 构造方式 |
|------|---------|----------|
| **通用开发** | `DirectedAdjList` | `new()` 或 `new_with_capacity(n, m)` |
| **已知规模的大图** | `DirectedAdjList` | `new_with_capacity(n, m)` ✅ 推荐 |
| **稠密小图 (<1000)** | `DirectedMatrix` | `new_with_capacity(n)` |
| **静态大规模 (>10万)** | `CSR` | `CSRBuilder::new()` + `.build()` |
| **MST 算法** | `EdgeList` | `new()` |

---

## 二、添加节点

### 2.1 单个节点添加

```moonbit
let mut g = @storage.new_directed()

// 基本用法
let id0 = @core.GraphWritable::add_node(g, 100.0)   // 返回 NodeId(0)
let id1 = @core.GraphWritable::add_node(g, 200.0)   // 返回 NodeId(1)
let id2 = @core.GraphWritable::add_node(g, 300.0)   // 返回 NodeId(2)

// 节点 ID 自动递增（从 0 开始）
println("新节点 ID: \{id0}, \{id1}, \{id2}")  // 输出: 0, 1, 2
```

**`data` 参数的含义**取决于你的应用场景：

```moonbit
// 场景 1: 社交网络 - 用户影响力分数 [0, 1]
let user_id = @core.GraphWritable::add_node(g, 0.95)

// 场景 2: 地理信息 - 海拔高度（米）
let city_id = @core.GraphWritable::add_node(g, 43.5)

// 场景 3: 网络设备 - 处理能力（Gbps）
let router_id = @core.GraphWritable::add_node(g, 1000.0)

// 场景 4: 不需要数据时使用占位符
let placeholder_id = @core.GraphWritable::add_node(g, 0.0)
```

### 2.2 批量节点添加

当需要添加大量节点时，使用循环或高阶函数：

```moonbit
/// 方式 1: for 循环（推荐，最直观）
fn create_nodes_for_loop(g : DirectedAdjList, n : Int) -> DirectedAdjList {
  let mut result = g
  for i in 0..n {
    let new_id = @core.GraphWritable::add_node(result, i.to_double())
    // 可以在这里记录 new_id 的映射关系
    ()
  }
  result
}

/// 方式 2: Array::fold（函数式风格）
fn create_nodes_fold(g : DirectedAdjList, n : Int) -> DirectedAdjList {
  Array::range(0, n)
    |> Array::fold(g, fn(acc, i) {
      @core.GraphWritable::add_node(acc, i.to_double()) |> ignore
      acc
    })
}

/// 方式 3: 带 ID 映射的批量创建（实用）
struct NodeMapping {
  name_to_id : Map[String, NodeId]  // 名称 → NodeId 映射
  graph : DirectedAdjList           // 最终图
}

fn create_named_nodes(
  names : Array[String]
) -> NodeMapping {
  let mut mapping : Map[String, NodeId] = Map::new()
  let mut g = @storage.DirectedAdjList::new_with_capacity(names.length, 0)

  for name in names {
    let id = @core.GraphWritable::add_node(g, 0.0)
    mapping.insert(name, id)
  }

  { name_to_id: mapping, graph: g }
}

// 使用示例
let result = create_named_nodes(["Alice", "Bob", "Charlie"])
let alice_id = result.name_to_id.get("Alice")  // Option[NodeId]
```

### 2.3 节点 ID 管理

mbtgraph 自动分配连续的整数 ID（从 0 开始）：

```moonbit
let mut g = @storage.new_directed()

let id_a = @core.GraphWritable::add_node(g, 1.0)  // NodeId(0)
let id_b = @core.GraphWritable::add_node(g, 2.0)  // NodeId(1)
let id_c = @core.GraphWritable::add_node(g, 3.0)  // NodeId(2)

// 删除节点后，ID 不会重用！（避免混淆）
@core.GraphWritable::remove_node(g, id_b) |> ignore

let id_d = @core.GraphWritable::add_node(g, 4.0)  // NodeId(3)，不是 1！

// 当前节点数 vs 最大 ID
println("当前节点数: \{@core.GraphReadable::node_count(g)}")     // 3 (A, C, D)
println("最大 NodeId: \{id_d}")                                   // 3
```

> ⚠️ **重要**: 删除节点后其 ID 不会回收复用，这是为了保证历史引用的有效性。

---

## 三、添加边

### 3.1 有向边

```moonbit
let mut g = @storage.new_directed()
let a = @core.GraphWritable::add_node(g, 0.0)
let b = @core.GraphWritable::add_node(g, 0.0)

// 基本用法
match @core.GraphWritable::add_edge(g, a, b, 10.5) {
  Ok(_) => println("✅ 边 A→B 添加成功")
  Err(e) =>
    match e {
      NodeNotFound(id) => println("❌ 节点 \{id} 不存在")
      EdgeAlreadyExists(from, to) => println("⚠️ 边 (\{from}→\{to}) 已存在")
      InvalidNodeId => println("❌ 无效的 NodeId")
    }
}
```

### 3.2 无向边

对于无向存储，只需添加一次边（内部自动处理对称性）：

```moonbit
let mut g = @storage.new_undirected()
let x = @core.GraphWritable::add_node(g, 0.0)
let y = @core.GraphWritable::add_node(g, 0.0)

// 只需一条边！
@core.GraphWritable::add_edge(g, x, y, 5.0) |> ignore

// 验证：x 和 y 互为邻居
@core.GraphReadable::neighbors(g, x) |> iter::each(fn(nbr) {
  println("X 的邻居: \{nbr}")  // 输出: Y
})
```

如果你使用**有向存储**来模拟无向图，需要手动添加两条边：

```moonbit
// ❌ 不推荐：浪费空间
@core.GraphWritable::add_edge(g, x, y, 5.0) |> ignore  // X→Y
@core.GraphWritable::add_edge(g, y, x, 5.0) |> ignore  // Y→X

// ✅ 推荐：直接使用 UndirectedAdjList
let mut undirected_g = @storage.new_undirected()
@core.GraphWritable::add_edge(undirected_g, x, y, 5.0) |> ignore  // 仅一条
```

### 3.3 边权重的语义

`data` 参数（边权重）在不同算法中有不同含义：

| 场景 | data 含义 | 典型值范围 | 示例 |
|------|----------|-----------|------|
| **最短路径** | 距离/成本 | 正实数 | `10.5` km |
| **网络流** | 容量 | 非负实数 | `100.0` Gbps |
| **PageRank** | 初始贡献 | [0, 1] | `0.25` |
| **推荐系统** | 相似度/强度 | [0, 1] 或任意正数 | `0.85` |
| **依赖分析** | 强度 | 整数或正实数 | `1.0`, `2.0` |
| **默认/无权重** | 占位符 | 固定值 | `1.0` |

```moonbit
// 最短路径示例：道路距离
@core.GraphWritable::add_edge(g, beijing, shanghai, 1200.0) |> ignore  // km

// 网络流示例：带宽容量
@core.GraphWritable::add_edge(g, server_a, server_b, 10000.0) |> ignore  // Mbps

// PageRank 示例：均匀分布
@core.GraphWritable::add_edge(g, page_i, page_j, 1.0 / out_degree) |> ignore

// 无权图：统一权重
@core.GraphWritable::add_edge(g, u, v, 1.0) |> ignore  // 所有边权重相同
```

### 3.4 批量添加边

#### AdjList 的批量优化

DirectedAdjList 提供了 `add_edges_batch` 方法，跳过重复检查以提升性能：

```moonbit
let mut g = @storage.DirectedAdjList::new_with_capacity(4, 6)

// 先添加所有节点
for i in 0..4 {
  @core.GraphWritable::add_node(g, i.to_double()) |> ignore
}

// 批量添加边（假设你知道这些边都不存在）
let edges : Array[(@core.NodeId, @core.NodeId, Double)] = [
  (@core.NodeId(0), @core.NodeId(1), 2.0),
  (@core.NodeId(0), @core.NodeId(2), 5.0),
  (@core.NodeId(1), @core.NodeId(2), 1.0),
  (@core.NodeId(1), @core.NodeId(3), 7.0),
  (@core.NodeId(2), @core.NodeId(3), 3.0),
  (@core.NodeId(3), @core.NodeId(0), 4.0),
]

match g.add_edges_batch(edges) {
  Ok(count) => println("✅ 成功添加 \{count} 条边")
  Err(e) => println("❌ 批量添加失败: \{e}")
}
```

**性能对比**:

| 方法 | 10 万条边耗时 | 适用场景 |
|------|-------------|----------|
| 逐条 `add_edge` | ~150ms | 边可能重复 |
| `add_edges_batch` | ~50ms | ✅ 确保边不重复时使用 |

#### CSR Builder 的批量构建

```moonbit
let mut builder = @storage.CSRBuilder::new()

// 添加节点
for i in 0..10000 {
  builder = builder.add_node(@core.NodeId(i), i.to_double() / 10000.0)
}

// 添加边（可乱序！Builder 内部会排序优化）
for _ in 0..50000 {
  let from = @core.NodeId(Random::int(0, 10000))
  let to = @core.NodeId(Random::int(0, 10000))
  if (from != to) {
    builder = builder.add_edge(from, to, Random::double(0.1, 10.0))
  }
}

// 一次性构建（内部排序去重 O(E log E)）
let start_time = Time::now()
match builder.build() {
  Ok(csr) => {
    let elapsed = Time::now() - start_time
    println("✅ CSR 构建完成! 耗时: \{elapsed}ms")
    println("节点: \{@core.GraphReadable::node_count(csr)}")
    println("边数: \{@core.GraphReadable::edge_count(csr)}")
  }
  Err(e) => println("❌ 构建失败: \{e}")
}
```

---

## 四、完整实战示例

### 示例 1: 构建社交网络图

```moonbit
/// 构建一个 Twitter 风格的关注关系图
fn build_twitter_graph() -> DirectedAdjList {
  // 用户列表：(用户名, 影响力分数)
  let users : Array[(String, Double)] = [
    ("alice", 0.95),    // 高影响力用户
    ("bob", 0.72),
    ("charlie", 0.88),
    ("diana", 0.65),
    ("eve", 0.78),
  ]

  // Step 1: 创建图并添加节点
  let mut g = @storage.DirectedAdjList::new_with_capacity(users.length, 20)
  let mut user_ids : Map[String, NodeId] = Map::new()

  for (name, influence) in users {
    let id = @core.GraphWritable::add_node(g, influence)
    user_ids.insert(name, id)
  }

  // Step 2: 添加关注关系（有向边）
  let follow_relations : Array[(String, String)] = [
    ("alice", "bob"),       // Alice 关注 Bob
    ("alice", "charlie"),   // Alice 关注 Charlie
    ("bob", "charlie"),     // Bob 关注 Charlie
    ("charlie", "diana"),   // Charlie 关注 Diana
    ("diana", "eve"),       // Diana 关注 Eve
    ("eve", "alice"),       // Eve 回关 Alice（互关）
    ("bob", "diana"),       // Bob 关注 Diana
    ("charlie", "eve"),     // Charlie 关注 Eve
  ]

  for (follower, followee) in follow_relations {
    let from_id = user_ids.get(follower).unwrap()
    let to_id = user_ids.get(followee).unwrap()

    @core.GraphWritable::add_edge(g, from_id, to_id, 1.0) |> ignore
  }

  g
}

// 使用示例
fn main() {
  let twitter = build_twitter_graph()

  println("=== Twitter 社交网络统计 ===")
  println("用户数量: \{@core.GraphReadable::node_count(twitter)}")
  println("关注关系数: \{@core.GraphReadable::edge_count(twitter)}")

  // 分析每个用户的连接特征
  @core.GraphReadable::node_ids(twitter) |> iter::each(fn(user_id) {
    let out_deg = @core.GraphDirected::out_degree(twitter, user_id)
    let in_deg = @core.GraphDirected::in_degree(twitter, user_id)

    println("\n用户 \{user_id}:")
    println("  关注了 \{out_deg} 人")
    println("  被 \{in_deg} 人关注")

    if (in_deg > out_deg * 2) {
      println("  🌟 该用户是影响力节点")
    } else if (out_deg > in_deg * 2) {
      println("  📢 该用户是活跃用户")
    }
  })
}
```

**输出**:
```
undefined```

### 示例 2: 构建道路网络（无向加权图）

```moonbit
/// 构建城市间道路网络（用于最短路径计算）
fn build_road_network() -> UndirectedAdjList {
  // 城市定义：(名称, 人口百万)
  let cities : Array[(String, Double)] = [
    ("北京", 21.5),
    ("上海", 24.3),
    ("广州", 15.3),
    ("深圳", 12.6),
    ("成都", 16.3),
  ]

  // Step 1: 创建无向图
  let mut g = @storage.UndirectedAdjList::new_with_capacity(cities.length, 12)
  let mut city_ids : Map[String, NodeId] = Map::new()

  for (city, population) in cities {
    let id = @core.GraphWritable::add_node(g, population)
    city_ids.insert(city, id)
  }

  // Step 2: 添加道路（无向边，权重=距离km）
  let roads : Array[(String, String, Double)] = [
    ("北京", "上海", 1200.0),   // 高铁
    ("北京", "广州", 2100.0),   // 飞机
    ("上海", "广州", 1300.0),   // 高铁
    ("上海", "深圳", 1200.0),   // 高铁
    ("广州", "深圳", 140.0),    // 城际高铁
    ("成都", "北京", 1600.0),   // 飞机
    ("成都", "广州", 1700.0),   // 飞机
  ]

  for (city_a, city_b, distance) in roads {
    let id_a = city_ids.get(city_a).unwrap()
    let id_b = city_ids.get(city_b).unwrap()

    @core.GraphWritable::add_edge(g, id_a, id_b, distance) |> ignore
  }

  g
}

// 查询两个城市的最短路径
fn find_shortest_path(network : UndirectedAdjList, from_city : String, to_city : String) {
  // 这里可以调用 Dijkstra 算法...
  println("查找 \{from_city} → \{to_city} 的最短路径...")
}
```

### 示例 3: 从文件/数据构建图

```moonbit
/// 从邻接表格式字符串解析构建图
///
/// 格式示例:
/// ```
/// A B 10.0
/// A C 5.0
/// B D 3.0
/// ```
fn parse_adjacency_list(input : String) -> DirectedAdjList {
  let lines = input.split("\n")
  let mut g = @storage.new_directed()
  let mut node_map : Map[String, NodeId] = Map::new()

  for line in lines {
    let parts = line.trim().split_whitespace()
    if (parts.length >= 3) {
      let from_name = parts[0]
      let to_name = parts[1]
      let weight = parts[2].to_double()

      // 自动创建节点（如果不存在）
      if (not node_map.contains(from_name)) {
        let id = @core.GraphWritable::add_node(g, 0.0)
        node_map.insert(from_name, id)
      }

      if (not node_map.contains(to_name)) {
        let id = @core.GraphWritable::add_node(g, 0.0)
        node_map.insert(to_name, id)
      }

      // 添加边
      let from_id = node_map.get(from_name).unwrap()
      let to_id = node_map.get(to_name).unwrap()
      @core.GraphWritable::add_edge(g, from_id, to_id, weight) |> ignore
    }
  }

  g
}

// 使用示例
let graph_data = "
  Beijing Shanghai 1200.0
  Beijing Guangzhou 2100.0
  Shanghai Hangzhou 180.0
"

let road_graph = parse_adjacency_list(graph_data)
println("从文本构建的图: \{@core.GraphReadable::node_count(road_graph)} 节点")
```

---

## 五、高级模式

### 5.1 工厂函数模式

封装复杂的建图逻辑为可复用的工厂函数：

```moonbit
/// 工厂函数：创建完全有向图（每对节点都有双向边）
fn create_complete_digraph(n : Int) -> DirectedAdjList {
  let mut g = @storage.DirectedAdjList::new_with_capacity(n, n * (n - 1))

  // 添加节点
  let ids : Array[NodeId] = []
  for i in 0..n {
    let id = @core.GraphWritable::add_node(g, i.to_double())
    ids.push(id)
  }

  // 添加所有可能的边（不包括自环）
  for i in 0..n {
    for j in 0..n {
      if (i != j) {
        @core.GraphWritable::add_edge(g, ids[i], ids[j], 1.0) |> ignore
      }
    }
  }

  g
}

/// 工厂函数：创建随机图（Erdős–Rényi 模型）
fn create_random_graph(
  n : Int,
  p : Double,  // 边存在概率 [0, 1]
  seed : Int? = None
) -> DirectedAdjList {
  let mut rng = Random::with_seed(seed.unwrap_or(42))
  let mut g = @storage.DirectedAdjList::new_with_capacity(n, (n * n * p).to_int())

  let ids : Array[NodeId] = []
  for i in 0..n {
    let id = @core.GraphWritable::add_node(g, i.to_double())
    ids.push(id)
  }

  for i in 0..n {
    for j in 0..n {
      if (i != j && rng.double() < p) {
        @core.GraphWritable::add_edge(g, ids[i], ids[j], rng.double(0.1, 10.0)) |> ignore
      }
    }
  }

  g
}

// 使用
let complete = create_complete_digraph(5)
let random_g = create_random_graph(100, 0.05)  // 100 节点，5% 边概率
```

### 5.2 Builder 模式（链式调用）

对于 CSR 等需要 Builder 的存储，可以使用链式 API：

```moonbit
let csr = @storage.CSRBuilder::new()
  .add_node(@core.NodeId(0), 1.0)
  .add_node(@core.NodeId(1), 2.0)
  .add_node(@core.NodeId(2), 3.0)
  .add_edge(@core.NodeId(0), @core.NodeId(1), 10.0)
  .add_edge(@core.NodeId(1), @core.NodeId(2), 20.0)
  .add_edge(@core.NodeId(0), @core.NodeId(2), 30.0)
  .build()  // 返回 Result[CSRGraph, GraphError]
```

### 5.3 从其他存储转换

使用转换器在存储之间迁移：

```moonbit
// 从 AdjList 构建 CSR（适用于大规模静态分析）
let adj = build_dynamic_graph()
let csr = @storage.converter::adj_list_to_csr(adj)

// 从 EdgeList 转 AdjList（适用于需要动态修改的 MST 结果）
let edges = kruskal_mst_result
let adj_mst = @storage.converter::edge_list_to_adj_list(edges)

// 所有 8 种转换函数见「存储转换器」章节
```

---

## 六、常见错误与解决方案

### ❌ 错误 1: 在边之前忘记添加节点

```moonbit
let mut g = @storage.new_directed()
// 忘记 add_node!

match @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) {
  Err(NodeNotFound(_)) => println("⚠️ 必须先添加节点!")
  _ => ()
}
```

**修复**: 总是先添加所有节点，再添加边。

### ❌ 错误 2: 忽略 add_edge 的返回值

```moonbit
@core.GraphWritable::add_edge(g, a, b, 1.0)  // 编译警告!
// MoonBit 要求消费返回值
```

**修复**: 
```moonbit
// 方式 1: 显式忽略
@core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore

// 方式 2: 处理错误
match @core.GraphWritable::add_edge(g, a, b, 1.0) {
  Ok(_) => ...
  Err(e) => ...
}
```

### ❌ 错误 3: 对 CSR 尝试动态修改

```moonbit
let csr = build_csr_graph()
// let csr = csr.add_node(...)  // ❌ 编译错误！CSR 是只读的
```

**修复**: CSR 只能通过 Builder 构建，如需修改请使用 AdjList。

### ❌ 错误 4: 混淆有向和无向存储

```moonbit
// 想要无向图但用了有向存储
let mut g = @storage.new_directed()
@core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore  // 只有 A→B
// 缺少 B→A！

// ✅ 正确做法
let mut g = @storage.new_undirected()
@core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore  // 自动双向
```

---

## 性能优化建议

### 1. 预分配容量

```moonbit
// ❌ 慢: 动态扩容（多次 realloc）
let g = @storage.new_directed()

// ✅ 快: 预分配已知规模
let g = @storage.DirectedAdjList::new_with_capacity(10000, 50000)
```

**提升**: 批量建图速度 **+20-30%**

### 2. 批量添加边

```moonbit
// ❌ 慢: 逐条检查重复
for (from, to, w) in edges {
  @core.GraphWritable::add_edge(g, from, to, w) |> ignore
}

// ✅ 快: 批量跳过检查（确保无重复时）
g.add_edges_batch(edges) |> ignore
```

**提升**: 10 万条边从 ~150ms 降至 ~50ms

### 3. 选择合适的存储

```moonbit
// 如果图是静态的且规模大，直接用 CSR
if (node_count > 100000 && is_static) {
  use_csr_builder_mode()
} else {
  use_adj_list_mode()
}
```

---

## 下一步

掌握了图的构建后，接下来学习：

- **[图的读写操作](/core-concepts/graph-operations/)** - CRUD 操作完整指南
- **[错误处理机制](/core-concepts/error-handling/)** - 正确处理 Result 和 Option
- **[BFS/DFS 遍历教程](/algorithms/traversal/bfs/)** - 第一个图算法实践

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">💡</span>
    <p class="callout-title">动手练习</p>
  </div>
  <div class="callout-content">
    <p><strong>尝试实现以下任务：</strong></p>
    <ol>
      <li>构建一个 10 节点的完全图（每对节点都相连）</li>
      <li>实现一个函数，从 CSV 文件读取边列表并构建图</li>
      <li>对比 <code>new()</code> 和 <code>new_with_capacity()</code> 在 1 万节点图上的性能差异</li>
    </ol>
  </div>
</div>

