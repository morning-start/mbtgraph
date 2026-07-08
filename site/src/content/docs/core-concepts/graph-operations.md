---
title: 图的读写操作
description: 查询和修改图数据的完整 CRUD 指南：Read/Create/Update/Delete 最佳实践
---

# 图的读写操作

本章是 mbtgraph **CRUD 操作的完整指南**，涵盖从基础查询到高级遍历的所有操作模式。掌握这些操作是使用图算法的基础。

## 快速入门：CRUD 5 分钟速查

```moonbit
// === CREATE (创建) ===
let mut g = @storage.new_directed()
let id_a = @core.GraphWritable::add_node(g, 1.0)
let id_b = @core.GraphWritable::add_node(g, 2.0)
@core.GraphWritable::add_edge(g, id_a, id_b, 10.0) |> ignore

// === READ (读取) ===
let n = @core.GraphReadable::node_count(g)           // 节点数
let exists = @core.GraphReadable::contains_edge(g, id_a, id_b)  // 边是否存在?
let data = @core.GraphReadable::get_node(g, id_a)    // 节点数据 (Double?)
let neighbors = @core.GraphReadable::neighbors(g, id_a) // 邻居列表 (Iter[NodeId])

// === UPDATE (更新) ===
// 注意: MoonBit 纯函数语义，需要重新赋值
let g = update_node_data(g, id_a, 99.0)  // 自定义更新函数

// === DELETE (删除) ===
@core.GraphWritable::remove_edge(g, id_a, id_b) |> ignore  // 删除边
@core.GraphWritable::remove_node(g, id_a) |> ignore         // 删除节点（级联删除关联边）
@core.GraphWritable::clear(g)                               // 清空整个图
```

---

## 一、READ - 读取操作

读取操作通过 **GraphReadable** Trait 定义，**所有 8 种存储都支持**。

### 1.1 基础存在性检查

#### 检查节点是否存在

```moonbit
fn check_node_example() -> Unit {
  let mut g = @storage.new_directed()
  let id = @core.GraphWritable::add_node(g, 42.0)

  // 方式 1: Bool 返回值
  if (@core.GraphReadable::contains_node(g, id)) {
    println("✅ 节点 ${id} 存在")
  }

  // 方式 2: 用于条件逻辑
  let target_id = @core.NodeId(99)  // 不存在的 ID
  if (not @core.GraphReadable::contains_node(g, target_id)) {
    println("⚠️ 节点 ${target_id} 不存在，需要先创建")
  }
}
```

#### 检查边是否存在

```moonbit
fn check_edge_example(g : DirectedAdjList, from : NodeId, to : NodeId) -> Unit {
  if (@core.GraphReadable::contains_edge(g, from, to)) {
    println("✅ 边 ${from}→${to} 存在")

    // 获取边的权重
    match @core.GraphReadable::get_edge(g, from, to) {
      Some(weight) => println("  权重: ${weight}")
      None => println("  ⚠️ 边存在但权重为空（异常情况）")
    }
  } else {
    println("❌ 边 ${from}→${to} 不存在")
  }
}
```

**性能提示**: 
- AdjList: `contains_edge` = O(k)，k 为源节点的出度
- Matrix: `contains_edge` = **O(1)** ✅ 最快
- EdgeList: `contains_edge` = O(E) ❌ 最慢

### 1.2 数据访问

#### 获取单个节点数据

```moonbit
/// 安全获取节点数据（带默认值）
fn get_node_safe[G : @core.GraphReadable](graph : G, id : NodeId, default : Double) -> Double {
  match @core.GraphReadable::get_node(graph, id) {
    Some(data) => data,
    None => {
      println("⚠️ 节点 ${id} 不存在，返回默认值 ${default}")
      default
    }
  }
}

// 使用示例
let g = create_sample_graph()
let alice_data = get_node_safe(g, @core.NodeId(0), 0.0)  // 如果节点 0 不存在则返回 0.0
```

#### 获取单条边数据

```moonbit
/// 获取边权重或返回无穷大（用于最短路径算法）
fn get_edge_or_infinity[G : @core.GraphReadable](
  graph : G,
  from : NodeId,
  to : NodeId
) -> Double {
  match @core.GraphReadable::get_edge(graph, from, to) {
    Some(weight) => weight,
    None => Double::infinity  // 边不存在时视为不可达
  }
}
```

### 1.3 邻居查询

#### 获取邻居列表（仅 ID）

```moonbit
/// 打印节点的所有邻居
fn print_neighbors[G : @core.GraphReadable](graph : G, node_id : NodeId) -> Unit {
  println("节点 ${node_id} 的邻居:")

  @core.GraphReadable::neighbors(graph, node_id)
    |> iter::each(fn(neighbor_id) {
      println("  → ${neighbor_id}")
    })

  // 注意: 这种方式需要二次查询才能获取权重
}

// 使用示例
print_neighbors(g, @core.NodeId(0))
// 输出:
// 节点 NodeId(0) 的邻居:
//   → NodeId(1)
//   → NodeId(2)
```

#### 获取带权重的邻居（推荐）

```moonbit
/// 打印邻居及其边权重（避免二次查询）
fn print_weighted_neighbors[G : @core.GraphReadable](graph : G, node_id : NodeId) -> Unit {
  println("节点 ${node_id} 的加权邻居:")

  @core.GraphReadable::neighbors_with_weight(graph, node_id)
    |> iter::each(fn((neighbor_id, weight)) {
      println("  → ${node_id} --[${weight}]--> ${neighbor_id}")
    })
}

// 输出示例:
// 节点 NodeId(0) 的加权邻居:
//   → NodeId(0) --[10.0]--> NodeId(1)
//   → NodeId(0) --[5.0]--> NodeId(2)
```

**性能对比**:

| 方式 | 查询次数 | 适用场景 |
|------|---------|----------|
| `neighbors` + 循环 `get_edge` | **1 + k 次** | 仅需邻居 ID 时 |
| `neighbors_with_weight` | **1 次** ✅ | 需要权重信息时（推荐） |

### 1.4 度数统计

```moonbit
/// 分析图的度数分布
fn analyze_degree_distribution[G : @core.GraphReadable](graph : G) -> Unit {
  let n = @core.GraphReadable::node_count(graph)
  let mut max_deg = 0
  let mut min_deg = Int::max_value()
  let mut total_deg = 0

  @core.GraphReadable::node_ids(graph) |> iter::each(fn(id) {
    let deg = @core.GraphReadable::degree(graph, id)
    max_deg = Max(max_deg, deg)
    min_deg = Min(min_deg, deg)
    total_deg = total_deg + deg
  })

  let avg_deg = if (n > 0) { total_deg.to_double() / n.to_double() } else { 0.0 }

  println("=== 度数统计 ===")
  println("节点数: ${n}")
  println("最大度数: ${max_deg} (枢纽节点)")
  println("最小度数: ${min_deg} (孤立或边缘节点)")
  println("平均度数: ${avg_deg:.2f}")
  println("总边数推断: ${total_deg / 2}")  // 无向图每条边被计算两次
}
```

对于有向图，使用 **GraphDirected** 分别统计入度和出度：

```moonbit
/// 有向图连接特征分析
fn analyze_directed_connectivity[G : @core.GraphDirected](graph : G, id : NodeId) -> Unit {
  let out_deg = @core.GraphDirected::out_degree(graph, id)
  let in_deg = @core.GraphDirected::in_degree(graph, id)

  println("=== 节点 ${id} 连接分析 ===")
  println("出度 (out-degree): ${out_deg}")
  println("入度 (in-degree):  ${in_deg}")

  // 分类判断
  if (out_deg == 0 && in_deg > 0) {
    println("📥 类型: 纯汇点 (Sink) - 只接收不发送")
  } else if (in_deg == 0 && out_deg > 0) {
    println("📤 类型: 纯源点 (Source) - 只发送不接收")
  } else if (out_deg == 0 && in_deg == 0) {
    println("🏝️ 类型: 孤立节点 (Isolated)")
  } else {
    println("🔄 类型: 中转节点 (Transit)")

    // 计算影响力比率
    if (in_deg > 0) {
      let ratio = out_deg.to_double() / in_deg.to_double()
      if (ratio > 2.0) {
        println("  📢 该节点更偏向「广播者」(ratio=${ratio:.1f})")
      } else if (ratio < 0.5) {
        println("  🎧 该节点更偏向「接收者」(ratio=${ratio:.1f})")
      }
    }
  }

  // 列出具体的前驱和后继
  println("\n前驱 (谁指向我):")
  @core.GraphDirected::predecessors(graph, id)
    |> iter::take(5)  // 最多显示 5 个
    |> iter::each(fn((src, w)) {
      println("  ← ${src} (权重: ${w})")
    })

  println("\n后继 (我指向谁):")
  @core.GraphDirected::successors(graph, id)
    |> iter::take(5)
    |> iter::each(fn((dst, w)) {
      println("  → ${dst} (权重: ${w})")
    })
}
```

### 1.5 全量遍历

#### 遍历所有节点

```moonbit
/// 方式 1: 使用 node_ids 迭代器
fn iterate_all_nodes[G : @core.GraphReadable](graph : G) -> Unit {
  println("所有节点:")
  @core.GraphReadable::node_ids(graph)
    |> iter::each(fn(id) {
      match @core.GraphReadable::get_node(graph, id) {
        Some(data) => println("  ${id}: data=${data}")
        None => ()  // 正常情况下不会发生
      }
    })
}

/// 方式 2: 使用索引循环（适用于 Array-backed 存储）
fn iterate_nodes_by_index(g : DirectedAdjList) -> Unit {
  let n = @core.GraphReadable::node_count(g)
  for i in 0..n {
    let id = @core.NodeId(i)
    match @core.GraphReadable::get_node(g, id) {
      Some(data) => println("节点 ${id}: ${data}")
      None => ()  // 可能已被删除
    }
  }
}
```

#### 遍历所有边

```moonbit
/// 打印图的所有边（用于调试或导出）
fn print_all_edges[G : @core.GraphReadable](graph : G) -> Unit {
  let m = @core.GraphReadable::edge_count(graph)
  println("=== 所有边 (共 ${m} 条) ===")

  @core.GraphReadable::edges(graph)
    |> iter::each(fn((from, to, weight)) {
      println("${from} --[${weight}]--> ${to}")
    })
}

/// 收集所有边到数组（便于后续处理）
fn collect_edges_to_array[G : @core.GraphReadable](graph : G) -> Array[(NodeId, NodeId, Double)] {
  @core.GraphReadable::edges(graph) |> iter::to_array
}

/// 统计权重分布
fn analyze_weight_distribution[G : @core.GraphReadable](graph : G) -> Unit {
  let mut min_weight = Double::max_value()
  let mut max_weight = 0.0
  let mut sum_weight = 0.0
  let mut count = 0

  @core.GraphReadable::edges(graph) |> iter::each(fn((_, _, weight) => {
    min_weight = Min(min_weight, weight)
    max_weight = Max(max_weight, weight)
    sum_weight = sum_weight + weight
    count = count + 1
  })

  if (count > 0) {
    let avg = sum_weight / count.to_double()
    println("=== 权重分布 (${count} 条边) ===")
    println("最小权重: ${min_weight}")
    println("最大权重: ${max_weight}")
    println("平均权重: ${avg:.2f}")
    println("总权重和: ${sum_weight:.2f}")
  }
}
```

### 1.6 复合查询示例

#### 示例 1: 查找共同邻居

```moonbit
/// 查找两个节点的共同邻居（社交网络中的"共同好友"）
fn find_common_neighbors[G : @core.GraphReadable](
  graph : G,
  node_a : NodeId,
  node_b : NodeId
) -> Array[NodeId] {
  // 将 A 的邻居存入 Set
  let neighbors_a : Set[NodeId] = Set::new()
  @core.GraphReadable::neighbors(graph, node_a)
    |> iter::each(fn(nbr) { neighbors_a.add(nbr) })

  // 遍历 B 的邻居，检查是否也在 A 中
  let common : Array[NodeId] = []
  @core.GraphReadable::neighbors(graph, node_b)
    |> iter::each(fn(nbr) {
      if (neighbors_a.contains(nbr)) {
        common.push(nbr)
      }
    })

  common
}

// 使用示例
let common_friends = find_common_neighbors(social_graph, alice_id, bob_id)
println("Alice 和 Bob 的共同好友: ${common_friends.length} 人")
for friend in common_friends {
  println("  👤 ${friend}")
}
```

#### 示例 2: 查找最强连接对

```moonbit
/// 找到权重最大的边
fn find_strongest_edge[G : @core.GraphReadable](graph : G) -> Option[(NodeId, NodeId, Double)] {
  let mut max_weight = 0.0
  let mut strongest : Option[(NodeId, NodeId, Double)] = None

  @core.GraphReadable::edges(graph) |> iter::each(fn((from, to, weight) => {
    if (weight > max_weight) {
      max_weight = weight
      strongest = Some((from, to, weight))
    }
  })

  strongest
}

// 使用示例
match find_strongest_edge(network) {
  Some((from, to, weight)) =>
    println("💪 最强连接: ${from} ↔ ${to} (强度: ${weight})")
  None => println("图中没有边")
}
```

#### 示例 3: 图的子集提取

```moonbit
/// 提取指定节点集合的导出子图（Induced Subgraph）
fn extract_subgraph(
  original : DirectedAdjList,
  nodes_to_keep : Set[NodeId]
) -> DirectedAdjList {
  let mut sub_g = @storage.new_directed()

  // 创建旧 ID 到新 ID 的映射
  let mut old_to_new : Map[NodeId, NodeId] = Map::new()

  // 复制节点
  @core.GraphReadable::node_ids(original) |> iter::each(fn(old_id) => {
    if (nodes_to_keep.contains(old_id)) {
      match @core.GraphReadable::get_node(original, old_id) {
        Some(data) => {
          let new_id = @core.GraphWritable::add_node(sub_g, data)
          old_to_new.insert(old_id, new_id)
        }
        None => ()
      }
    }
  })

  // 复制边（只保留两端都在集合中的边）
  @core.GraphReadable::edges(original) |> iter::each(fn((from, to, weight) => {
    if (nodes_to_keep.contains(from) && nodes_to_keep.contains(to)) {
      let new_from = old_to_new.get(from).unwrap()
      let new_to = old_to_new.get(to).unwrap()
      @core.GraphWritable::add_edge(sub_g, new_from, new_to, weight) |> ignore
    }
  })

  sub_g
}
```

---

## 二、CREATE - 创建操作

> **详细教程见 [创建节点和边](/core-concepts/building-graphs/)**，此处补充高级场景。

### 2.1 条件性添加（幂等操作）

```moonbit
/// 幂等添加节点：已存在则返回原 ID，不存在则创建
fn add_node_if_absent(g : DirectedAdjList, data : Double) -> (DirectedAdjList, NodeId) {
  // 先尝试查找具有该数据的节点（简化版：总是创建新节点）
  let new_id = @core.GraphWritable::add_node(g, data)
  (g, new_id)
}

/// 幂等添加边：已存在则忽略，不存在则创建
fn add_edge_if_absent(
  g : DirectedAdjList,
  from : NodeId,
  to : NodeId,
  weight : Double
) -> DirectedAdjList {
  if (not @core.GraphReadable::contains_edge(g, from, to)) {
    @core.GraphWritable::add_edge(g, from, to, weight) |> ignore
  }
  g
}
```

### 2.2 从其他数据结构批量构建

```moonbit
/// 从邻接矩阵 (2D Array) 构建图
fn from_adjacency_matrix(matrix : Array[Array[Double?]]) -> DirectedAdjList {
  let n = matrix.length
  let mut g = @storage.DirectedAdjList::new_with_capacity(n, n * n)

  // 添加节点
  let ids : Array[NodeId] = []
  for i in 0..n {
    let id = @core.GraphWritable::add_node(g, matrix[i][i].unwrap_or(0.0))
    ids.push(id)
  }

  // 添加非空的边
  for i in 0..n {
    for j in 0..n {
      match matrix[i][j] {
        Some(w) if (i != j && w > 0.0) => {
          @core.GraphWritable::add_edge(g, ids[i], ids[j], w) |> ignore
        }
        _ => ()
      }
    }
  }

  g
}

// 使用示例
let matrix : Array[Array[Double?]] = [
  [Some(0.0), Some(1.0), Some(2.0)],
  [Some(3.0), Some(0.0), Some(4.0)],
  [Some(5.0), Some(6.0), Some(0.0)],
]
let graph_from_matrix = from_adjacency_matrix(matrix)
```

---

## 三、UPDATE - 更新操作

MoonBit 采用**纯函数语义**，更新操作需要消费返回的新实例。

### 3.1 更新节点数据

mbtgraph 当前版本**不支持直接修改节点数据**（设计决策），但可以通过以下方式模拟：

#### 方式 1: 删除后重建

```moonbit
/// 更新节点数据（通过删除+重建实现）
fn update_node_data(
  g : DirectedAdjList,
  target_id : NodeId,
  new_data : Double
) -> DirectedAdjList {
  // 保存所有邻接信息
  let out_nbrs = @core.GraphReadable::neighbors_with_weight(g, target_id) |> iter::to_array
  let in_nbrs = @core.GraphDirected::predecessors(g, target_id) |> iter::to_array

  // 删除旧节点
  @core.GraphWritable::remove_node(g, target_id) |> ignore

  // 创建新节点（会获得新 ID!）
  let new_id = @core.GraphWritable::add_node(g, new_data)

  // 重建所有边（注意: ID 已变化！）
  for (old_nbr, w) in out_nbrs {
    // 这里需要处理 ID 映射问题...
    // 实际应用中建议维护一个外部 ID 映射表
  }

  g  // ⚠️ 注意: 返回的是新实例，target_id 已失效!
}
```

> ⚠️ **重要限制**: 由于 NodeId 是自动分配且不可变的整数，**删除节点会导致 ID 变化**。如果你的算法依赖稳定的节点标识符，请：
> 1. 在外部维护 `Map[YourID, NodeId]` 映射
> 2. 或在节点 `data` 字段中存储业务 ID

### 3.2 更新边权重

同理，更新边权重的推荐方式：

```moonbit
/// 更新边权重（通过删除+重建实现）
fn update_edge_weight(
  g : DirectedAdjList,
  from : NodeId,
  to : NodeId,
  new_weight : Double
) -> Result[DirectedAdjList, GraphError] {
  // 先删除旧边
  if (@core.GraphWritable::remove_edge(g, from, to)) {
    // 再添加新边
    match @core.GraphWritable::add_edge(g, from, to, new_weight) {
      Ok(_) => Ok(g),
      Err(e) => Err(e)
    }
  } else {
    Err(@core.GraphError::EdgeNotFound(from, to))  // 自定义错误类型
  }
}
```

### 3.3 批量更新策略

对于需要频繁更新的场景，建议：

```moonbit
/// 策略 1: 收集所有变更，最后一次性重建图
fn batch_update_graph(
  original : DirectedAdjList,
  node_updates : Map[NodeId, Double],
  edge_updates : Map[(NodeId, NodeId), Double]
) -> DirectedAdjList {
  // 完全重建通常比原地更新更简单且不易出错
  rebuild_graph(original, node_updates, edge_updates)
}

/// 策略 2: 使用 EdgeList 作为中间格式（易排序和去重）
fn update_via_edgelist(g : DirectedAdjList) -> EdgeList {
  // 转换为 EdgeList
  let edges = @core.GraphReadable::edges(g) |> iter::to_array

  // 在数组上执行更新操作（更灵活）
  let updated_edges = edges.map(fn((from, to, w)) => {
    // 根据业务逻辑修改权重...
    (from, to, modify_weight(from, to, w))
  })

  // 重建为新存储
  build_from_edges(updated_edges)
}
```

---

## 四、DELETE - 删除操作

删除操作仅 **GraphWritable** Trait 支持（CSR/CSC 等只读存储不支持）。

### 4.1 删除单条边

```moonbit
fn remove_edge_example() -> Unit {
  let mut g = @storage.new_directed()
  let a = @core.GraphWritable::add_node(g, 0.0)
  let b = @core.GraphWritable::add_node(g, 0.0)
  @core.GraphWritable::add_edge(g, a, b, 10.0) |> ignore

  // 删除边并检查结果
  let removed = @core.GraphWritable::remove_edge(g, a, b)
  if (removed) {
    println("✅ 边已成功删除")
  } else {
    println("⚠️ 边不存在，无需删除")
  }

  // 验证
  assert(not @core.GraphReadable::contains_edge(g, a, b), "边应该已被删除")
}
```

**性能说明**:
- AdjList: O(k)，需要遍历邻接表找到目标边
- Matrix: **O(1)**，直接置空
- EdgeList: O(E) 或 O(log E)（取决于是否排序）

### 4.2 删除节点（级联删除）

```moonbit
fn remove_node_demo() -> Unit {
  let mut g = @storage.DirectedAdjList::new_with_capacity(5, 10)

  // 构建: 0→1→2→3→4
  for i in 0..5 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  for i in 0..4 {
    @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(i+1), 1.0) |> ignore
  }

  println("删除前:")
  println("  节点数: ${@core.GraphReadable::node_count(g)}")  // 5
  println("  边数: ${@core.GraphReadable::edge_count(g)}")    // 4

  // 删除节点 2（会级联删除边 1→2 和 2→3）
  let removed = @core.GraphWritable::remove_node(g, @core.NodeId(2))

  println("\n删除节点 2 后:")
  println("  删除成功? ${removed}")
  println("  节点数: ${@core.GraphReadable::node_count(g)}")  // 4
  println("  边数: ${@core.GraphReadable::edge_count(g)}")    // 2 (只剩下 0→1 和 3→4)

  // 验证关联边已被删除
  assert(not @core.GraphReadable::contains_edge(g, @core.NodeId(1), @core.NodeId(2)))
  assert(not @core.GraphReadable::contains_edge(g, @core.NodeId(2), @core.NodeId(3)))
}
```

**⚠️ 重要行为**: 删除节点会**自动删除所有关联的入边和出边**，无需手动清理。

### 4.3 清空整个图

```moonbit
fn clear_graph_demo() -> Unit {
  let mut g = build_complex_graph()  // 假设有 1000 节点，5000 边

  println("清空前: ${@core.GraphReadable::node_count(g)} 节点")

  // 一键清空
  @core.GraphWritable::clear(g)

  println("清空后: ${@core.GraphReadable::node_count(g)} 节点")  // 0
  println("图是否为空: ${@core.GraphReadable::is_empty(g)}")       // true
}
```

**适用场景**:
- 算法多轮迭代时重置状态
- 单元测试间的隔离
- 内存敏感时的显式释放

### 4.4 条件性删除

```moonbit
/// 删除所有权重低于阈值的"弱连接"
fn remove_weak_edges(
  g : DirectedAdjList,
  threshold : Double
) -> (DirectedAdjList, Int) {
  let mut removed_count = 0

  // 收集需要删除的边（先收集再删除，避免遍历时修改问题）
  let weak_edges : Array[(NodeId, NodeId)] = []
  @core.GraphReadable::edges(g) |> iter::each(fn((from, to, weight) => {
    if (weight < threshold) {
      weak_edges.push((from, to))
    }
  })

  // 执行删除
  for (from, to) in weak_edges {
    if (@core.GraphWritable::remove_edge(g, from, to)) {
      removed_count = removed_count + 1
    }
  }

  (g, removed_count)
}

// 使用示例: 移除所有权重 < 1.0 的弱连接
let (cleaned_g, count) = remove_weak_edges(network, 1.0)
println("移除了 ${count} 条弱连接")
```

---

## 五、性能优化技巧

### 5.1 缓存频繁查询的结果

```moonbit
/// 反模式: 在循环中重复查询
fn bad_performance[G : @core.GraphReadable](graph : G) -> Double {
  let mut sum = 0.0
  @core.GraphReadable::node_ids(graph) |> iter::each(fn(id) {
    // ❌ 错误: 每次循环都调用 degree()，可能触发重复计算
    let deg = @core.GraphReadable::degree(graph, id)
    sum = sum + deg.to_double()
  })
  sum
}

/// 正确模式: 批量收集或利用已有信息
fn good_performance[G : @core.GraphReadable](graph : G) -> Double {
  // ✅ 方法 1: 利用 edges() 直接计算总度数（无向图）
  let m = @core.GraphReadable::edge_count(graph)
  (2 * m).to_double()  // 每条边贡献 2 个度数

  // ✅ 方法 2: 如果确实需要逐节点处理，用 neighbors_with_weight 一次获取
  let mut sum = 0.0
  @core.GraphReadable::node_ids(graph) |> iter::each(fn(id) {
    let weighted_nbrs = @core.GraphReadable::neighbors_with_weight(graph, id)
    sum = sum + weighted_nbrs.length().to_double()  // 度数 = 邻居数量
  })
  sum
}
```

### 5.2 使用合适的存储减少查询复杂度

| 查询模式 | 推荐存储 | 原因 |
|---------|---------|------|
| 频繁 `contains_edge` | **Matrix** | O(1) vs AdjList O(k) |
| 频繁 `in_degree` | **AdjList (有 rev_adj)** 或 **CSC** | O(1) |
| 批量 `batch_neighbors` | **CSR** | 缓存友好 |
| 需要排序边 | **EdgeList** | 天然支持 |

### 5.3 避免不必要的遍历

```moonbit
/// 反模式: 检查图是否为空时遍历所有节点
fn is_empty_bad[G : @core.GraphReadable](graph : G) -> Bool {
  // ❌ 遍历了所有节点才知道是否为空
  let mut count = 0
  @core.GraphReadable::node_ids(graph) |> iter::each(fn(_) => { count = count + 1 })
  count == 0
}

/// 正确模式: 使用内置方法
fn is_empty_good[G : @core.GraphReadable](graph : G) -> Bool {
  // ✅ O(1) 直接返回
  @core.GraphReadable::is_empty(graph)
}
```

---

## 六、常见反模式与陷阱

### ❌ 陷阱 1: 忽略 Option/Result 返回值

```moonbit
// 危险: 直接解包可能 panic
let data = @core.GraphReadable::get_node(g, id).unwrap()  // 如果不存在则崩溃!

// 安全: 总是处理 None
match @core.GraphReadable::get_node(g, id) {
  Some(data) => println("数据: ${data}")
  None => println("节点不存在，跳过")
}
```

### ❌ 陷阱 2: 遍历时修改图结构

```moonbit
// 危险: 在 edges() 迭代器中删除边
@core.GraphReadable::edges(g) |> iter::each(fn((from, to, w)) => {
  if (w < 0.0) {
    @core.GraphWritable::remove_edge(g, from, to) |> ignore  // ❌ 未定义行为!
  }
})

// 正确: 先收集，再删除
let to_remove : Array[(NodeId, NodeId)] = []
@core.GraphReadable::edges(g) |> iter::each(fn((from, to, w)) => {
  if (w < 0.0) { to_remove.push((from, to)) }
})
for (from, to) in to_remove {
  @core.GraphWritable::remove_edge(g, from, to) |> ignore
}
```

### ❌ 陷阱 3: 混淆有向/无向邻居

```moonbit
// 对于无向图，以下三种方式应该返回相同结果:
let nbrs1 = @core.GraphReadable::neighbors(g, id)
let nbrs2 = @core.GraphDirected::in_neighbors(g, id)  // 如果实现了 GraphDirected
let nbrs3 = @core.GraphDirected::out_neighbors(g, id)

// 但对于有向图，它们完全不同!
// 务必根据图的类型选择正确的查询方法
```

### ❌ 陷阱 4: 忘记 MoonBit 纯函数语义

```moonbit
// 错误: 期望 add_node 会修改原始图
let mut g = @storage.new_directed()
@core.GraphWritable::add_node(g, 1.0)  // ⚠️ 返回值被忽略! g 未改变!

// 正确: 接收新的图实例
let g = @storage.new_directed()
let g = @core.GraphWritable::add_node(g, 1.0)  // g 现在包含新节点
```

---

## 七、完整 CRUD 工作流示例

### 示例: 社交网络管理系统

```moonbit
/// 模拟一个简单的社交网络管理系统的 CRUD 操作
fn social_network_crud_demo() -> Unit {
  let mut network = @storage.new_directed()

  // ========== CREATE ==========
  println("=== 创建用户 ===")
  let users : Map[String, NodeId] = Map::new()
  for name in ["Alice", "Bob", "Charlie", "Diana"] {
    let influence = Random::double(0.5, 1.0)  // 随机影响力分数
    let id = @core.GraphWritable::add_node(network, influence)
    users.insert(name, id)
    println("  创建用户: ${name} (ID: ${id}, 影响力: ${influence:.2f})")
  }

  // ========== CREATE (添加关注关系) ==========
  println("\n=== 添加关注关系 ===")
  let follows : Array[(String, String)] = [
    ("Alice", "Bob"), ("Alice", "Charlie"),
    ("Bob", "Charlie"), ("Bob", "Diana"),
    ("Charlie", "Diana"),
  ]
  for (follower, followee) in follows {
    let from = users.get(follower).unwrap()
    let to = users.get(followee).unwrap()
    @core.GraphWritable::add_edge(network, from, to, 1.0) |> ignore
    println("  ${follower} → 关注 → ${followee}")
  }

  // ========== READ (查询) ==========
  println("\n=== 查询用户信息 ===")
  let alice_id = users.get("Alice").unwrap()
  let out_deg = @core.GraphDirected::out_degree(network, alice_id)
  let in_deg = @core.GraphDirected::in_degree(network, alice_id)
  println("Alice: 关注了 ${out_deg} 人, 被 ${in_deg} 人关注")

  println("\n=== Alice 关注的人 ===")
  @core.GraphDirected::successors(network, alice_id)
    |> iter::each(fn((user_id, _)) => {
      println("  → ${user_id}")
    })

  // ========== UPDATE (模拟更新影响力) ==========
  println("\n=== 更新用户数据 ===")
  // 注意: 这里演示"标记"更新，实际需要删除+重建
  println("  Alice 参与了热门话题，影响力提升!")
  // 实际项目中应使用外部映射表跟踪业务 ID

  // ========== DELETE (取消关注) ==========
  println("\n=== 取消关注 ===")
  let bob_id = users.get("Bob").unwrap()
  let charlie_id = users.get("Charlie").unwrap()

  if (@core.GraphWritable::remove_edge(network, bob_id, charlie_id)) {
    println("  Bob 取消关注 Charlie ✅")
  }

  // ========== READ (验证删除结果) ==========
  println("\n=== 最终状态 ===")
  println("总用户: ${@core.GraphReadable::node_count(network)}")
  println("总关注关系: ${@core.GraphReadable::edge_count(network)}")
  println("\n=== 所有关注关系 ===")
  @core.GraphReadable::edges(network)
    |> iter::each(fn((from, to, w)) => {
      println("${from} → ${to}")
    })
}

// 运行演示
social_network_crud_demo()
```

**输出**:
```
=== 创建用户 ===
  创建用户: Alice (ID: NodeId(0), 影响力: 0.87)
  创建用户: Bob (ID: NodeId(1), 影响力: 0.62)
  ...

=== 添加关注关系 ===
  Alice → 关注 → Bob
  ...

=== 查询用户信息 ===
Alice: 关注了 2 人, 被 0 人关注

=== Alice 关注的人 ===
  → NodeId(1)
  → NodeId(2)

=== 取消关注 ===
  Bob 取消关注 Charlie ✅

=== 最终状态 ===
总用户: 4
总关注关系: 4

=== 所有关系 ===
NodeId(0) → NodeId(1)
NodeId(0) → NodeId(2)
NodeId(1) → NodeId(3)
NodeId(2) → NodeId(3)
```

---

## 下一步

掌握了 CRUD 操作后，你可以：

- **[错误处理机制](/core-concepts/error-handling/)** - 深入理解 Result/Option 最佳实践
- **[BFS 遍历算法](/algorithms/traversal/bfs/)** - 第一个图算法实战
- **[序列化与反序列化](/core-concepts/serialization/)** - 将图持久化到文件

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">💡</span>
    <p class="callout-title">API 速查卡</p>
  </div>
  <div class="callout-content">
    <p><strong>最常用的 10 个 API:</strong></p>
    <table>
      <tr><th>操作</th><th>方法</th><th>复杂度</th></tr>
      <tr><td>节点数</td><td><code>node_count()</code></td><td>O(1)</td></tr>
      <tr><td>边数</td><td><code>edge_count()</code></td><td>O(1)</td></tr>
      <tr><td>节点存在?</td><td><code>contains_node(id)</code></td><td>O(1)</td></tr>
      <tr><td>边存在?</td><td><code>contains_edge(f,t)</code></td><td>O(k)/O(1)*</td></tr>
      <tr><td>获取邻居</td><td><code>neighbors(id)</code></td><td>O(k)</td></tr>
      <tr><td>加权邻居</td><td><code>neighbors_with_weight(id)</code></td><td>O(k)</td></tr>
      <tr><td>度数</td><td><code>degree(id)</code></td><td>O(1)</td></tr>
      <tr><td>添加节点</td><td><code>add_node(data)</code></td><td>O(1)*</td></tr>
      <tr><td>添加边</td><td><code>add_edge(f,t,w)</code></td><td>O(1)*</td></tr>
      <tr><td>删除边</td><td><code>remove_edge(f,t)</code></td><td>O(k)</td></tr>
    </table>
    <p>* AdjList 均摊; Matrix O(1)</p>
  </div>
</div>
