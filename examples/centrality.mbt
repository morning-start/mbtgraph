// 中心性分析示例
// 演示 PageRank、介数中心性、接近中心性等算法的使用

///|
/// 创建示例图：社交网络影响力分析
///
///     (0)---(1)---(2)
///      |     |     |
///     (3)---(4)---(5)---(6)
///            |           |
///           (7)---------(8)
///
fn create_influence_network() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()

  // 添加 9 个节点（代表不同影响力的人物）
  for i in 0..<9 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加社交连接
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
    @core.NodeId(2),
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
    @core.NodeId(2),
    @core.NodeId(5),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(3),
    @core.NodeId(4),
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
    @core.NodeId(7),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(5),
    @core.NodeId(6),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(5),
    @core.NodeId(8),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(6),
    @core.NodeId(8),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(7),
    @core.NodeId(8),
    1.0,
  )

  g
}

///|
/// 示例 1: PageRank
fn pagerank_example() -> Unit {
  println("=== PageRank 算法 ===\n")

  let g = create_influence_network()

  // 运行 PageRank 算法
  let result = @pagerank.pagerank(g, 0.85, 100, 0.000001)

  println("PageRank 结果:")
  println("  迭代次数: \{result.iterations}")
  println("  是否收敛: \{result.converged}")
  println("  总 PageRank: \{result.total_rank()}")

  println("\n各节点 PageRank 分数:")
  for i in 0..<9 {
    let node = @core.NodeId(i)
    match result.get_rank(node) {
      Some(rank) => println("  节点 \{i}: \{rank}")
      None => println("  节点 \{i}: N/A")
    }
  }

  // 获取前 3 名
  let top3 = result.top_nodes(3)
  println("\n影响力前 3 名:")
  for i in 0..<top3.length() {
    let (node, rank) = top3[i]
    let node_id = match node {
      NodeId(n) => n
    }
    println("  第 \{i + 1} 名: 节点 \{node_id} (PageRank: \{rank})")
  }
}

///|
/// 示例 2: 度中心性
fn degree_centrality_example() -> Unit {
  println("\n=== 度中心性 ===\n")

  let g = create_influence_network()

  // 计算度中心性（总度数）
  let result = @centrality.degree_centrality(g, Total)

  println("度中心性（总度数）:")
  for i in 0..<9 {
    let node = @core.NodeId(i)
    match result.get_score(node) {
      Some(score) => println("  节点 \{i}: \{score}")
      None => println("  节点 \{i}: N/A")
    }
  }

  // 获取度数最高的节点
  match result.max_node() {
    Some((node, score)) => {
      let node_id = match node {
        NodeId(n) => n
      }
      println("\n度数最高: 节点 \{node_id} (度数: \{score})")
    }
    None => println("无数据")
  }
}

///|
/// 示例 3: 介数中心性
fn betweenness_centrality_example() -> Unit {
  println("\n=== 介数中心性 ===\n")

  let g = create_influence_network()

  // 计算介数中心性（归一化）
  let result = @centrality.betweenness_centrality(g, true)

  println("介数中心性（归一化）:")
  for i in 0..<9 {
    let node = @core.NodeId(i)
    match result.get_score(node) {
      Some(score) => println("  节点 \{i}: \{score}")
      None => println("  节点 \{i}: N/A")
    }
  }

  match result.max_node() {
    Some((node, score)) => {
      let node_id = match node {
        NodeId(n) => n
      }
      println("\n中介性最高: 节点 \{node_id} (介数: \{score})")
      println("  说明: 此节点是信息流动的关键桥梁")
    }
    None => println("无数据")
  }
}

///|
/// 示例 4: 接近中心性
fn closeness_centrality_example() -> Unit {
  println("\n=== 接近中心性 ===\n")

  let g = create_influence_network()

  // 计算接近中心性
  let result = @centrality.closeness_centrality(g, true)

  println("接近中心性:")
  for i in 0..<9 {
    let node = @core.NodeId(i)
    match result.get_score(node) {
      Some(score) => println("  节点 \{i}: \{score}")
      None => println("  节点 \{i}: N/A")
    }
  }

  match result.max_node() {
    Some((node, score)) => {
      let node_id = match node {
        NodeId(n) => n
      }
      println("\n最中心: 节点 \{node_id} (接近度: \{score})")
      println("  说明: 此节点到其他节点的平均距离最短")
    }
    None => println("无数据")
  }
}

///|
/// 示例 5: 特征向量中心性
fn eigenvector_centrality_example() -> Unit {
  println("\n=== 特征向量中心性 ===\n")

  let g = create_influence_network()

  // 计算特征向量中心性
  let result = @centrality.eigenvector_centrality(g, 100, 0.000001)

  println("特征向量中心性:")
  for i in 0..<9 {
    let node = @core.NodeId(i)
    match result.get_score(node) {
      Some(score) => println("  节点 \{i}: \{score}")
      None => println("  节点 \{i}: N/A")
    }
  }

  match result.max_node() {
    Some((node, score)) => {
      let node_id = match node {
        NodeId(n) => n
      }
      println("\n影响力最大: 节点 \{node_id} (特征向量: \{score})")
      println("  说明: 此节点连接了许多高影响力节点")
    }
    None => println("无数据")
  }
}

///|
/// 示例 6: 比较不同中心性指标
fn compare_centrality_metrics() -> Unit {
  println("\n=== 比较中心性指标 ===\n")

  let g = create_influence_network()

  // 计算各种中心性
  let degree = @centrality.degree_centrality(g, Total)
  let betweenness = @centrality.betweenness_centrality(g, true)
  let closeness = @centrality.closeness_centrality(g, true)
  let eigenvector = @centrality.eigenvector_centrality(g, 100, 0.000001)
  let pagerank = @pagerank.pagerank(g, 0.85, 100, 0.000001)

  println("各节点中心性对比:")
  println(
    "节点 | 度中心性 | 介数中心性 | 接近中心性 | 特征向量 | PageRank",
  )
  println("-----|---------|-----------|-----------|---------|--------")

  for i in 0..<9 {
    let node = @core.NodeId(i)
    let d = degree.get_score(node)
    let b = betweenness.get_score(node)
    let c = closeness.get_score(node)
    let e = eigenvector.get_score(node)
    let p = pagerank.get_rank(node)

    let d_str = match d {
      Some(v) => v.to_string()
      None => "N/A"
    }
    let b_str = match b {
      Some(v) => v.to_string()
      None => "N/A"
    }
    let c_str = match c {
      Some(v) => v.to_string()
      None => "N/A"
    }
    let e_str = match e {
      Some(v) => v.to_string()
      None => "N/A"
    }
    let p_str = match p {
      Some(v) => v.to_string()
      None => "N/A"
    }

    println(
      "  \{i}   |  \{d_str}  |    \{b_str}    |    \{c_str}    |  \{e_str}  |  \{p_str}",
    )
  }
}

///|
/// 主函数
fn test_centrality() -> Unit {
  pagerank_example()
  degree_centrality_example()
  betweenness_centrality_example()
  closeness_centrality_example()
  eigenvector_centrality_example()
  compare_centrality_metrics()
}
