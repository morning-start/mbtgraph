// 连通性示例
// 演示连通分量和强连通分量算法的使用

///|
/// 创建示例图：无向图（多个连通分量）
///
///   (0)---(1)     (2)---(3)
///    |     |       |
///   (4)   (5)     (6)
///
fn create_undirected_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()

  // 添加节点
  for i in 0..<7 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加边
  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n3 = @core.NodeId(3)
  let n4 = @core.NodeId(4)
  let n5 = @core.NodeId(5)
  let n6 = @core.NodeId(6)

  // 连通分量 1: {0, 1, 4, 5}
  let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n0, n4, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n1, n5, 1.0)

  // 连通分量 2: {2, 3, 6}
  let _ = @core.GraphWritable::add_edge(g, n2, n3, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n2, n6, 1.0)

  g
}

///|
/// 创建示例图：有向图（强连通分量）
///
///   (0) → (1) → (2)
///   ↑     ↓     ↓
///   (3) ← (4) ← (5)
///
///   (6) → (7)
///
fn create_directed_graph() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()

  // 添加节点
  for i in 0..<8 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加边
  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n3 = @core.NodeId(3)
  let n4 = @core.NodeId(4)
  let n5 = @core.NodeId(5)
  let n6 = @core.NodeId(6)
  let n7 = @core.NodeId(7)

  // 强连通分量 1: {0, 1, 2, 3, 4, 5}
  let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n1, n2, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n2, n5, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n5, n4, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n4, n3, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n3, n0, 1.0)

  // 强连通分量 2: {6, 7}
  let _ = @core.GraphWritable::add_edge(g, n6, n7, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n7, n6, 1.0)

  g
}

///|
/// 示例 1: 无向图连通分量
fn connected_components_example() -> Unit {
  println("=== 无向图连通分量 ===\n")

  let g = create_undirected_graph()

  // 运行连通分量算法
  let result = @connectivity.connected_components(g)

  println("连通分量数量: \{result.count()}")
  println("\n各连通分量:")
  for i in 0..<result.count() {
    let size = result.size(i)
    println("  分量 \{i}: \{size} 个节点")
  }

  println("\n节点所属分量:")
  for i in 0..<7 {
    let node = @core.NodeId(i)
    let component = result.component_of(node)
    println("  节点 \{i}: 分量 \{component}")
  }
}

///|
/// 示例 2: Tarjan 强连通分量
fn tarjan_scc_example() -> Unit {
  println("\n=== Tarjan 强连通分量 ===\n")

  let g = create_directed_graph()

  // 运行 Tarjan SCC 算法
  let result = @connectivity.tarjan_scc(g)

  println("强连通分量数量: \{result.count()}")
  println("\n各强连通分量:")
  for i in 0..<result.count() {
    let component = result.components[i]
    let mut ids = ""
    for j in 0..<component.length() {
      ids = ids + component[j].0.to_string() + " "
    }
    println("  SCC \{i}: [\{ids}]")
  }

  println("\n节点所属 SCC:")
  for i in 0..<8 {
    let node = @core.NodeId(i)
    let component = result.component_of(node)
    println("  节点 \{i}: SCC \{component}")
  }
}

///|
/// 示例 3: Kosaraju 强连通分量
fn kosaraju_scc_example() -> Unit {
  println("\n=== Kosaraju 强连通分量 ===\n")

  let g = create_directed_graph()

  // 运行 Kosaraju SCC 算法
  let result = @connectivity.kosaraju_scc(g)

  println("强连通分量数量: \{result.count()}")
  for i in 0..<result.count() {
    let component = result.components[i]
    let mut ids = ""
    for j in 0..<component.length() {
      ids = ids + component[j].0.to_string() + " "
    }
    println("  SCC \{i}: [\{ids}]")
  }
}

///|
/// 主函数
fn test_connectivity() -> Unit {
  connected_components_example()
  tarjan_scc_example()
  kosaraju_scc_example()
}
