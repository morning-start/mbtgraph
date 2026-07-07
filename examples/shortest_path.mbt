// 最短路径示例
// 演示 Dijkstra 和 A* 算法的使用

///|
/// 创建示例图：城市道路网络
///
///     (0)---5---(1)---3---(2)
///     |         |         |
///     2         1         4
///     |         |         |
///     (3)---6---(4)---2---(5)
///
fn create_road_network() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()

  // 添加节点 (0-5)
  let _ = @core.GraphWritable::add_node(g, 0.0) // 城市 A
  let _ = @core.GraphWritable::add_node(g, 1.0) // 城市 B
  let _ = @core.GraphWritable::add_node(g, 2.0) // 城市 C
  let _ = @core.GraphWritable::add_node(g, 3.0) // 城市 D
  let _ = @core.GraphWritable::add_node(g, 4.0) // 城市 E
  let _ = @core.GraphWritable::add_node(g, 5.0) // 城市 F

  // 添加道路（边和距离）
  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n3 = @core.NodeId(3)
  let n4 = @core.NodeId(4)
  let n5 = @core.NodeId(5)

  let _ = @core.GraphWritable::add_edge(g, n0, n1, 5.0) // A -> B: 5km
  let _ = @core.GraphWritable::add_edge(g, n0, n3, 2.0) // A -> D: 2km
  let _ = @core.GraphWritable::add_edge(g, n1, n2, 3.0) // B -> C: 3km
  let _ = @core.GraphWritable::add_edge(g, n1, n4, 1.0) // B -> E: 1km
  let _ = @core.GraphWritable::add_edge(g, n2, n5, 4.0) // C -> F: 4km
  let _ = @core.GraphWritable::add_edge(g, n3, n4, 6.0) // D -> E: 6km
  let _ = @core.GraphWritable::add_edge(g, n4, n5, 2.0) // E -> F: 2km

  g
}

///|
/// 示例 1: Dijkstra 单源最短路径
///
/// 计算从节点 0 (城市 A) 到所有其他城市的最短距离
fn dijkstra_example() -> Unit {
  println("=== Dijkstra 单源最短路径 ===\n")

  let g = create_road_network()
  let source = @core.NodeId(0)

  // 运行 Dijkstra 算法
  let result = @shortest_path.dijkstra(g, source)

  // 输出结果
  println("从城市 A 出发的最短距离:")
  for i in 0..<6 {
    let target = @core.NodeId(i)
    if result.is_reachable(target) {
      let dist = result.distance_to(target)
      let path = result.path_to(target)
      println("  到城市 \{i}: \{dist}km, 路径: \{path}")
    } else {
      println("  到城市 \{i}: 不可达")
    }
  }
}

///|
/// 示例 2: Dijkstra 两节点间最短路径
fn dijkstra_targeted_example() -> Unit {
  println("\n=== Dijkstra 两节点间最短路径 ===\n")

  let g = create_road_network()
  let source = @core.NodeId(0) // 城市 A
  let target = @core.NodeId(5) // 城市 F

  // 查找从 A 到 F 的最短路径
  let path = @shortest_path.dijkstra_targeted(g, source, target)

  println("从城市 A 到城市 F 的最短路径:")
  if path.length() > 0 {
    println("  路径: \{path}")
    println("  经过 \{path.length() - 1} 条道路")
  } else {
    println("  不可达")
  }
}

///|
/// 示例 3: A* 启发式搜索
///
/// 使用欧几里得距离作为启发函数
fn a_star_example() -> Unit {
  println("\n=== A* 启发式搜索 ===\n")

  let g = create_road_network()
  let source = @core.NodeId(0) // 城市 A
  let target = @core.NodeId(5) // 城市 F

  // 定义启发函数：估算到目标的距离
  // 这里使用简单的启发：距离目标越远，估计值越大
  let heuristic = fn(node : NodeId) -> Double {
    let n = match node {
      NodeId(n) => n
    }
    // 简单启发：节点编号差的绝对值
    (n - 5).abs().to_double()
  }

  // 运行 A* 算法
  let path = @shortest_path.a_star(g, source, target, heuristic)

  println("从城市 A 到城市 F 的 A* 路径:")
  if path.length() > 0 {
    println("  路径: \{path}")
  } else {
    println("  不可达")
  }
}

///|
/// 示例 4: Floyd-Warshall 全源最短路径
fn floyd_warshall_example() -> Unit {
  println("\n=== Floyd-Warshall 全源最短路径 ===\n")

  let g = create_road_network()

  // 运行 Floyd-Warshall 算法
  let result = @shortest_path.floyd_warshall(g)

  match result {
    Ok(fw) => {
      println("所有城市间的最短距离矩阵:")
      println("     A   B   C   D   E   F")
      for i in 0..<6 {
        println("  \{['A', 'B', 'C', 'D', 'E', 'F'][i]} ")
        for j in 0..<6 {
          let dist = fw.distance(@core.NodeId(i), @core.NodeId(j))
          if dist == Double::infinity {
            println("  ∞ ")
          } else {
            println(" \{dist} ")
          }
        }
        println("")
      }
    }
    Err(msg) => println("错误: \{msg}")
  }
}

///|
/// 示例 5: Bellman-Ford 负权最短路径
fn bellman_ford_example() -> Unit {
  println("\n=== Bellman-Ford 负权最短路径 ===\n")

  // 创建带负权边的图
  let g = @storage.new_directed()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 1.0)
  let _ = @core.GraphWritable::add_node(g, 2.0)

  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)

  let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)
  let _ = @core.GraphWritable::add_edge(g, n1, n2, -2.0) // 负权边
  let _ = @core.GraphWritable::add_edge(g, n0, n2, 5.0)

  // 运行 Bellman-Ford 算法
  let result = @shortest_path.bellman_ford(g, n0)

  match result {
    Ok(sp) => {
      println("从节点 0 出发:")
      println("  到节点 1: \{sp.distance_to(n1)}")
      println("  到节点 2: \{sp.distance_to(n2)}")
    }
    Err(msg) => println("存在负环: \{msg}")
  }
}

///|
/// 主函数
fn test_shortest_path() -> Unit {
  dijkstra_example()
  dijkstra_targeted_example()
  a_star_example()
  floyd_warshall_example()
  bellman_ford_example()
}
