// 最小生成树示例
// 演示 Kruskal 和 Prim 算法的使用


/// 创建示例图：电网连接
///
///     (0)---4---(1)---8---(2)
///     |         |         |
///     2         3         7
///     |         |         |
///     (3)---5---(4)---1---(5)
///
/// 边权重表示建设成本（万元）
fn create_power_grid() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()

  // 添加节点 (0-5)
  let _ = @core.GraphWritable::add_node(g, 0.0)  // 变电站 A
  let _ = @core.GraphWritable::add_node(g, 1.0)  // 变电站 B
  let _ = @core.GraphWritable::add_node(g, 2.0)  // 变电站 C
  let _ = @core.GraphWritable::add_node(g, 3.0)  // 变电站 D
  let _ = @core.GraphWritable::add_node(g, 4.0)  // 变电站 E
  let _ = @core.GraphWritable::add_node(g, 5.0)  // 变电站 F

  // 添加连接（边和成本）
  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n3 = @core.NodeId(3)
  let n4 = @core.NodeId(4)
  let n5 = @core.NodeId(5)

  let _ = @core.GraphWritable::add_edge(g, n0, n1, 4.0)  // A-B: 4万
  let _ = @core.GraphWritable::add_edge(g, n0, n3, 2.0)  // A-D: 2万
  let _ = @core.GraphWritable::add_edge(g, n1, n2, 8.0)  // B-C: 8万
  let _ = @core.GraphWritable::add_edge(g, n1, n4, 3.0)  // B-E: 3万
  let _ = @core.GraphWritable::add_edge(g, n2, n5, 7.0)  // C-F: 7万
  let _ = @core.GraphWritable::add_edge(g, n3, n4, 5.0)  // D-E: 5万
  let _ = @core.GraphWritable::add_edge(g, n4, n5, 1.0)  // E-F: 1万

  g
}

/// 示例 1: Kruskal 最小生成树
fn kruskal_example() -> Unit {
  println("=== Kruskal 最小生成树 ===\n")

  let g = create_power_grid()

  // 运行 Kruskal 算法
  let result = @mst.kruskal(g)

  println("电网连接方案（最小成本）:")
  println("总成本: \{result.total_weight} 万元")
  println("连接数: \{result.edge_count()}")
  println("\n选择的连接:")

  for (from, to, weight) in result.edges {
    let from_id = match from { NodeId(n) => n }
    let to_id = match to { NodeId(n) => n }
    println("  变电站 \{from_id} <-> 变电站 \{to_id}: \{weight}万元")
  }
}

/// 示例 2: Prim 最小生成树
fn prim_example() -> Unit {
  println("\n=== Prim 最小生成树 ===\n")

  let g = create_power_grid()
  let start = @core.NodeId(0)  // 从变电站 A 开始

  // 运行 Prim 算法
  let result = @mst.prim(g, start)

  println("从变电站 A 开始的最小生成树:")
  println("总成本: \{result.total_weight} 万元")
  println("\n添加顺序:")

  for (from, to, weight) in result.edges {
    let from_id = match from { NodeId(n) => n }
    let to_id = match to { NodeId(n) => n }
    println("  连接 \{from_id} -> \{to_id}: \{weight}万元")
  }
}

/// 示例 3: 检查边是否在 MST 中
fn mst_membership_example() -> Unit {
  println("\n=== MST 边成员检查 ===\n")

  let g = create_power_grid()
  let result = @mst.kruskal(g)

  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n5 = @core.NodeId(5)

  println("检查边是否在 MST 中:")
  println("  (0,1) 在 MST 中? \{result.has_edge(n0, n1)}")
  println("  (0,3) 在 MST 中? \{result.has_edge(n0, @core.NodeId(3))}")
  println("  (1,2) 在 MST 中? \{result.has_edge(n1, n2)}")
  println("  (4,5) 在 MST 中? \{result.has_edge(@core.NodeId(4), n5)}")
}

/// 主函数
fn test_mst() -> Unit {
  kruskal_example()
  prim_example()
  mst_membership_example()
}
