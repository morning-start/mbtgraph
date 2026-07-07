// 图算子示例
// 演示图运算（并集、交集、补图、反转等）

///|
/// 创建第一个有向图
///
///  0 → 1 → 2
///
fn create_graph1() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()

  for i in 0..<3 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(0),
    @core.NodeId(1),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(1),
    @core.NodeId(2),
    2.0,
  )

  g
}

///|
/// 创建第二个有向图
///
///  1 → 2 → 3
///
fn create_graph2() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()

  for i in 0..<4 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(1),
    @core.NodeId(2),
    3.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(2),
    @core.NodeId(3),
    4.0,
  )

  g
}

///|
/// 示例 1: 图并集
fn union_example() -> Unit {
  println("=== 图并集 (Union) ===\n")

  let g1 = create_graph1()
  let g2 = create_graph2()

  println("图1 边: 0→1, 1→2")
  println("图2 边: 1→2, 2→3")

  let union_g = @ops.graph_union(g1, g2)
  println("\n并集结果:")
  println("  节点数: \{@core.GraphReadable::node_count(union_g)}")
  println("  边数: \{@core.GraphReadable::edge_count(union_g)}")
  println("  边列表:")
  for e in @core.GraphReadable::edges(union_g) {
    let (u, v, w) = e
    println("    \{u.0} → \{v.0} (权重: \{w})")
  }
  println("  说明: 合并两个图的所有边，去重\n")
}

///|
/// 示例 2: 图交集
fn intersection_example() -> Unit {
  println("=== 图交集 (Intersection) ===\n")

  let g1 = create_graph1()
  let g2 = create_graph2()

  println("图1 边: 0→1, 1→2")
  println("图2 边: 1→2, 2→3")

  let intersect_g = @ops.graph_intersection(g1, g2)
  println("\n交集结果:")
  println("  节点数: \{@core.GraphReadable::node_count(intersect_g)}")
  println("  边数: \{@core.GraphReadable::edge_count(intersect_g)}")
  println("  边列表:")
  for e in @core.GraphReadable::edges(intersect_g) {
    let (u, v, _) = e
    println("    \{u.0} → \{v.0}")
  }
  println("  说明: 只保留两个图共有的边\n")
}

///|
/// 示例 3: 图差集
fn difference_example() -> Unit {
  println("=== 图差集 (Difference) ===\n")

  let g1 = create_graph1()
  let g2 = create_graph2()

  println("图1 边: 0→1, 1→2")
  println("图2 边: 1→2, 2→3")

  let diff_g = @ops.graph_difference(g1, g2)
  println("\n差集结果 (图1 - 图2):")
  println("  节点数: \{@core.GraphReadable::node_count(diff_g)}")
  println("  边数: \{@core.GraphReadable::edge_count(diff_g)}")
  println("  边列表:")
  for e in @core.GraphReadable::edges(diff_g) {
    let (u, v, _) = e
    println("    \{u.0} → \{v.0}")
  }
  println("  说明: 保留图1中有但图2中没有的边\n")
}

///|
/// 示例 4: 补图
fn complement_example() -> Unit {
  println("=== 补图 (Complement) ===\n")

  let g1 = create_graph1()

  println("原图边: 0→1, 1→2")

  let comp_g = @ops.complement(g1)
  println("\n补图结果:")
  println("  节点数: \{@core.GraphReadable::node_count(comp_g)}")
  println("  边数: \{@core.GraphReadable::edge_count(comp_g)}")
  println("  边列表:")
  for e in @core.GraphReadable::edges(comp_g) {
    let (u, v, _) = e
    println("    \{u.0} → \{v.0}")
  }
  println("  说明: 包含原图中不存在的所有边\n")
}

///|
/// 示例 5: 反转图
fn reverse_example() -> Unit {
  println("=== 反转图 (Reverse) ===\n")

  let g1 = create_graph1()

  println("原图边: 0→1, 1→2")

  let rev_g = @ops.reverse(g1)
  println("\n反转图结果:")
  println("  节点数: \{@core.GraphReadable::node_count(rev_g)}")
  println("  边数: \{@core.GraphReadable::edge_count(rev_g)}")
  println("  边列表:")
  for e in @core.GraphReadable::edges(rev_g) {
    let (u, v, _) = e
    println("    \{u.0} → \{v.0}")
  }
  println("  说明: 所有边方向反转\n")
}

///|
/// 示例 6: 笛卡尔积
fn cartesian_product_example() -> Unit {
  println("=== 笛卡尔积 (Cartesian Product) ===\n")

  let g1 = create_graph1()
  let g2 = create_graph2()

  println("图1: 3 节点, 2 边")
  println("图2: 4 节点, 2 边")

  let product_g = @ops.cartesian_product(g1, g2)
  println("\n笛卡尔积结果:")
  println("  节点数: \{@core.GraphReadable::node_count(product_g)}")
  println("  边数: \{@core.GraphReadable::edge_count(product_g)}")
  println("  说明: 结果图有 |V1|×|V2| 个节点\n")
}

///|
/// 主函数
fn test_operators() -> Unit {
  union_example()
  intersection_example()
  difference_example()
  complement_example()
  reverse_example()
  cartesian_product_example()
}
