// 链接预测示例
// 演示如何使用链接预测算法评估节点间潜在连接

///|
/// 创建社交网络示例图
///
///     (0)---(1)---(2)
///      |     |     |
///     (3)---(4)   (5)---(6)
///            |
///           (7)
///
fn create_social_network() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()

  for i in 0..<8 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 好友关系
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
    @core.NodeId(7),
    1.0,
  )
  let _ = @core.GraphWritable::add_edge(
    g,
    @core.NodeId(5),
    @core.NodeId(6),
    1.0,
  )

  g
}

///|
/// 示例 1: 共同邻居
fn common_neighbors_example() -> Unit {
  println("=== 共同邻居 (Common Neighbors) ===\n")

  let g = create_social_network()

  // 节点 0 和 2 有共同邻居 1
  let score = @lp.common_neighbors(g, @core.NodeId(0), @core.NodeId(2))
  println("节点 0 和 2 的共同邻居得分: \{score}")
  println("  说明: 它们都与节点 1 相连\n")

  // 节点 0 和 6 没有共同邻居
  let score2 = @lp.common_neighbors(g, @core.NodeId(0), @core.NodeId(6))
  println("节点 0 和 6 的共同邻居得分: \{score2}")
  println("  说明: 它们之间没有共同好友\n")
}

///|
/// 示例 2: Jaccard 系数
fn jaccard_example() -> Unit {
  println("=== Jaccard 系数 ===\n")

  let g = create_social_network()

  let score = @lp.jaccard_coefficient(g, @core.NodeId(0), @core.NodeId(2))
  println("节点 0 和 2 的 Jaccard 系数: \{score}")

  let score2 = @lp.jaccard_coefficient(g, @core.NodeId(3), @core.NodeId(7))
  println("节点 3 和 7 的 Jaccard 系数: \{score2}")
  println("  说明: 它们有共同邻居 4\n")
}

///|
/// 示例 3: Adamic-Adar 指数
fn adamic_adar_example() -> Unit {
  println("=== Adamic-Adar 指数 ===\n")

  let g = create_social_network()

  let score = @lp.adamic_adar_index(g, @core.NodeId(0), @core.NodeId(2))
  println("节点 0 和 2 的 Adamic-Adar 指数: \{score}")

  let score2 = @lp.adamic_adar_index(g, @core.NodeId(3), @core.NodeId(7))
  println("节点 3 和 7 的 Adamic-Adar 指数: \{score2}")
  println("  说明: 共同邻居的度数越小，连接可能性越高\n")
}

///|
/// 示例 4: 优先连接
fn preferential_attachment_example() -> Unit {
  println("=== 优先连接 (Preferential Attachment) ===\n")

  let g = create_social_network()

  let score = @lp.preferential_attachment(g, @core.NodeId(0), @core.NodeId(2))
  println("节点 0 和 2 的优先连接得分: \{score}")

  let score2 = @lp.preferential_attachment(g, @core.NodeId(0), @core.NodeId(6))
  println("节点 0 和 6 的优先连接得分: \{score2}")
  println("  说明: 度数高的节点更容易建立连接\n")
}

///|
/// 示例 5: 资源分配
fn resource_allocation_example() -> Unit {
  println("=== 资源分配 (Resource Allocation) ===\n")

  let g = create_social_network()

  let score = @lp.resource_allocation(g, @core.NodeId(0), @core.NodeId(2))
  println("节点 0 和 2 的资源分配得分: \{score}")

  let score2 = @lp.resource_allocation(g, @core.NodeId(3), @core.NodeId(7))
  println("节点 3 和 7 的资源分配得分: \{score2}")
  println("  说明: 类似 Adamic-Adar，但权重函数不同\n")
}

///|
/// 示例 6: 综合评分
fn comprehensive_scoring_example() -> Unit {
  println("=== 综合链接预测评分 ===\n")

  let g = create_social_network()

  // 预测所有未连接节点对的链接概率
  let pairs = [(0, 2), (0, 5), (0, 6), (0, 7), (3, 7), (6, 7)]

  println(
    "节点对 | 共同邻居 | Jaccard | AA 指数 | 优先连接 | 资源分配",
  )
  println("-------|---------|---------|---------|---------|---------")

  for pair in pairs {
    let (u, v) = pair
    let cn = @lp.common_neighbors(g, @core.NodeId(u), @core.NodeId(v))
    let jaccard = @lp.jaccard_coefficient(g, @core.NodeId(u), @core.NodeId(v))
    let aa = @lp.adamic_adar_index(g, @core.NodeId(u), @core.NodeId(v))
    let pa = @lp.preferential_attachment(g, @core.NodeId(u), @core.NodeId(v))
    let ra = @lp.resource_allocation(g, @core.NodeId(u), @core.NodeId(v))

    println("  \{u}-\{v}  |  \{cn}  | \{jaccard} |  \{aa}  |  \{pa}  |  \{ra}")
  }
}

///|
/// 主函数
fn test_link_prediction() -> Unit {
  common_neighbors_example()
  jaccard_example()
  adamic_adar_example()
  preferential_attachment_example()
  resource_allocation_example()
  comprehensive_scoring_example()
}
