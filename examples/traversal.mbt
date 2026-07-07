// 图遍历示例
// 演示 BFS 和 DFS 算法的使用

///|
/// 创建示例图：社交网络
///
///       (0)
///      / | \
///    (1) (2) (3)
///    / \   |   \
///  (4) (5) (6) (7)
///
fn create_social_network() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()

  // 添加节点
  for i in 0..<8 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加关注关系
  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n3 = @core.NodeId(3)
  let n4 = @core.NodeId(4)
  let n5 = @core.NodeId(5)
  let n6 = @core.NodeId(6)
  let n7 = @core.NodeId(7)

  let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n0, n2, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n0, n3, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n1, n4, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n1, n5, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n2, n6, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n3, n7, 1.0)

  g
}

///|
/// 创建带环的图
fn create_graph_with_cycle() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()

  // 添加节点
  for i in 0..<5 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加边（包含环）
  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n3 = @core.NodeId(3)
  let n4 = @core.NodeId(4)

  let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n1, n2, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n2, n3, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n3, n4, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n4, n1, 1.0) // 环: 1->2->3->4->1

  g
}

///|
/// 示例 1: BFS 广度优先搜索
fn bfs_example() -> Unit {
  println("=== BFS 广度优先搜索 ===\n")

  let g = create_social_network()
  let start = @core.NodeId(0)

  // 运行 BFS
  let result = @traversal.bfs(g, start)

  println("从节点 0 开始的 BFS 遍历:")
  println("  遍历顺序: \{result.base.order}")
  println("  访问节点数: \{result.base.reachable_count()}")

  println("\n层级信息:")
  for i in 0..<8 {
    let node = @core.NodeId(i)
    let level = result.distance(node)
    println("  节点 \{i}: 层级 \{level}")
  }

  // 重建路径
  let target = @core.NodeId(7)
  let path = result.path_to(target)
  println("\n到节点 7 的路径: \{path}")
}

///|
/// 示例 2: BFS 最短路径
fn bfs_shortest_path_example() -> Unit {
  println("\n=== BFS 最短路径（无权图） ===\n")

  let g = create_social_network()
  let source = @core.NodeId(0)
  let target = @core.NodeId(6)

  // 使用 BFS 查找最短路径
  let path = @traversal.bfs_shortest_path(g, source, target)

  println("从节点 0 到节点 6 的最短路径:")
  if path.length() > 0 {
    println("  路径: \{path}")
    println("  跳数: \{path.length() - 1}")
  } else {
    println("  不可达")
  }
}

///|
/// 示例 3: DFS 深度优先搜索
fn dfs_example() -> Unit {
  println("\n=== DFS 深度优先搜索 ===\n")

  let g = create_social_network()
  let start = @core.NodeId(0)

  // 运行 DFS
  let result = @traversal.dfs(g, start)

  println("从节点 0 开始的 DFS 遍历:")
  println("  遍历顺序: \{result.base.order}")
  println("  访问节点数: \{result.base.reachable_count()}")

  println("\n时间戳信息:")
  for i in 0..<8 {
    let node = @core.NodeId(i)
    if result.base.is_visited(node) {
      println(
        "  节点 \{i}: 进入=\{result.entry_time[i]}, 退出=\{result.exit_time[i]}",
      )
    }
  }
}

///|
/// 示例 4: 环检测
fn cycle_detection_example() -> Unit {
  println("\n=== 环检测 ===\n")

  // 无环图
  let g1 = create_social_network()
  let has_cycle1 = @traversal.has_cycle(g1)
  println("社交网络有环? \{has_cycle1}")

  // 有环图
  let g2 = create_graph_with_cycle()
  let has_cycle2 = @traversal.has_cycle(g2)
  println("带环图有环? \{has_cycle2}")

  // 有向图特定检测
  let has_directed_cycle = @traversal.has_directed_cycle(g2)
  println("有向图有环? \{has_directed_cycle}")
}

///|
/// 示例 5: 拓扑排序
fn topological_sort_example() -> Unit {
  println("\n=== 拓扑排序 ===\n")

  // 创建 DAG（有向无环图）
  let g = @storage.new_directed()

  // 添加课程依赖关系
  // 0: 先修课, 1: 基础课, 2: 进阶课, 3: 实践课
  for i in 0..<4 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n3 = @core.NodeId(3)

  let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0) // 0 -> 1
  let _ = @core.GraphWritable::add_edge(g, n0, n2, 1.0) // 0 -> 2
  let _ = @core.GraphWritable::add_edge(g, n1, n3, 1.0) // 1 -> 3
  let _ = @core.GraphWritable::add_edge(g, n2, n3, 1.0) // 2 -> 3

  // Kahn 算法
  match @traversal.topo_sort_kahn(g) {
    Ok(order) => {
      println("Kahn 拓扑排序结果: \{order}")
      println("学习顺序: \{order}")
    }
    Err(msg) => println("图有环: \{msg}")
  }

  // DFS 算法
  match @traversal.topo_sort_dfs(g) {
    Ok(order) => println("DFS 拓扑排序结果: \{order}")
    Err(msg) => println("图有环: \{msg}")
  }
}

///|
/// 主函数
fn main {
  bfs_example()
  bfs_shortest_path_example()
  dfs_example()
  cycle_detection_example()
  topological_sort_example()
}
