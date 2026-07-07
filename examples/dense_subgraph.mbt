// 稠密子图分析示例
// 演示 K-Core 分解、聚类系数、三角形计数等算法

///|
/// 创建社交网络示例图
///
///     (0)---(1)---(2)
///      |   / |   / |
///     (3)---(4)---(5)
///            |
///           (6)---(7)
///
fn dense_create_social_network() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()

  for i in 0..<8 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 创建密集连接区域 (0-1-3-4 完全连接)
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(0),
    @core.NodeId(1),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(0),
    @core.NodeId(3),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(1),
    @core.NodeId(3),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(1),
    @core.NodeId(4),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(3),
    @core.NodeId(4),
    1.0,
  )

  // 扩展连接
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(1),
    @core.NodeId(2),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(2),
    @core.NodeId(4),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(2),
    @core.NodeId(5),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(4),
    @core.NodeId(5),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(4),
    @core.NodeId(6),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(6),
    @core.NodeId(7),
    1.0,
  )

  g
}

///|
/// 示例 1: K-Core 分解
fn kcore_example() -> Unit {
  println("=== K-Core 分解 ===\n")

  let g = dense_create_social_network()
  let result = @dense_subgraph.k_core_decomposition(g)

  println("各节点的核心编号:")
  for i in 0..<8 {
    let node = @core.NodeId(i)
    let core_num = result.core_number(node)
    println("  节点 \{i}: K-Core = \{core_num}")
  }

  // 找出 2-Core 节点
  let k2_nodes : Array[Int] = []
  for i in 0..<8 {
    let node = @core.NodeId(i)
    if result.core_number(node) >= 2 {
      k2_nodes.push(i)
    }
  }
  println("\n2-Core 节点: \{k2_nodes}")
  println("  说明: 这些节点至少与 2 个核心节点相连\n")
}

///|
/// 示例 2: 聚类系数
fn clustering_example() -> Unit {
  println("=== 聚类系数 ===\n")

  let g = dense_create_social_network()

  // 局部聚类系数
  let local_result = @dense_subgraph.clustering_coefficients(g)

  println("局部聚类系数:")
  for i in 0..<8 {
    let node = @core.NodeId(i)
    let c = local_result.local_coefficient(node)
    println("  节点 \{i}: \{c}")
  }

  // 全局聚类系数
  let global_coeff = local_result.global_coefficient()
  println("\n全局聚类系数: \{global_coeff}")
  println("  说明: 衡量图中三角形的密度\n")

  // 平均聚类系数
  let avg = @dense_subgraph.average_clustering_coefficient(g)
  println("平均聚类系数: \{avg}")
  println("  说明: 所有节点局部聚类系数的平均值\n")
}

///|
/// 示例 3: 三角形计数
fn triangle_example() -> Unit {
  println("=== 三角形计数 ===\n")

  let g = dense_create_social_network()
  let result = @dense_subgraph.count_triangles(g)

  println("三角形总数: \{result.total_triangles()}")

  println("\n各节点参与的三角形数:")
  for i in 0..<8 {
    let node = @core.NodeId(i)
    let count = result.node_triangles(node)
    println("  节点 \{i}: \{count} 个三角形")
  }
  println("  说明: 三角形是社交网络中稳定关系的标志\n")
}

///|
/// 示例 4: K-Truss 分解
fn ktruss_example() -> Unit {
  println("=== K-Truss 分解 ===\n")

  let g = dense_create_social_network()
  let result = @dense_subgraph.k_truss_decomposition(g)

  println("各边的 Truss 编号:")
  for e in @core.GraphReadable::edges(g) {
    let (u, v, _) = e
    let truss = result.truss_number(u, v)
    println("  (\{u.0}, \{v.0}): Truss = \{truss}")
  }

  println("\n  说明: K-Truss 是边的密集子图，")
  println("  每条边至少参与 (K-2) 个三角形\n")
}

///|
/// 示例 5: 综合分析
fn comprehensive_analysis() -> Unit {
  println("=== 综合稠密子图分析 ===\n")

  let g = dense_create_social_network()

  let kcore_result = @dense_subgraph.k_core_decomposition(g)
  let cluster_result = @dense_subgraph.clustering_coefficients(g)
  let tri_result = @dense_subgraph.count_triangles(g)
  println("图统计:")
  println("  节点数: \{8}")
  println("  边数: \{@core.GraphReadable::edge_count(g)}")
  println("  三角形数: \{tri_result.total_triangles()}")
  println("  全局聚类系数: \{cluster_result.global_coefficient()}")

  println("\n核心结构:")
  for i in 0..<8 {
    let node = @core.NodeId(i)
    let core = kcore_result.core_number(node)
    let tri = tri_result.node_triangles(node)
    println("  节点 \{i}: K-Core=\{core}, 三角形=\{tri}")
  }
}

///|
/// 主函数
fn test_dense_subgraph() -> Unit {
  kcore_example()
  clustering_example()
  triangle_example()
  ktruss_example()
  comprehensive_analysis()
}
