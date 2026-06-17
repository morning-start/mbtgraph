// 匹配算法示例
// 演示匈牙利算法、Hopcroft-Karp 算法和 Edmonds Blossom 算法的使用

import "morning-start/mbtgraph/lib/core" as @core
import "morning-start/mbtgraph/lib/storage" as @storage
import "morning-start/mbtgraph/lib/algo/matching" as @matching

/// 创建示例图：二部图匹配（任务分配）
///
/// 左部（工人）: {0, 1, 2, 3}
/// 右部（任务）: {4, 5, 6, 7}
///
///     0 --- 4
///     |   / |
///     0 --- 5
///     |   / |
///     1 --- 6
///     |   / |
///     2 --- 7
///     |   /
///     3 --- 5
///
fn create_bipartite_graph() -> UndirectedAdjList {
  let g = @storage.new_undirected()

  // 添加 8 个节点
  for i in 0..<8 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加二部边（工人-任务连接）
  // 工人 0 可以做任务 4, 5
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(5), 1.0)

  // 工人 1 可以做任务 5, 6
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(5), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(6), 1.0)

  // 工人 2 可以做任务 6, 7
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(6), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(7), 1.0)

  // 工人 3 可以做任务 5
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(5), 1.0)

  g
}

/// 示例 1: Hopcroft-Karp 二部图匹配
fn hopcroft_karp_example() {
  println("=== Hopcroft-Karp 二部图匹配 ===\n")

  let g = create_bipartite_graph()

  // 定义左右部节点
  let left_nodes = [@core.NodeId(0), @core.NodeId(1), @core.NodeId(2), @core.NodeId(3)]
  let right_nodes = [@core.NodeId(4), @core.NodeId(5), @core.NodeId(6), @core.NodeId(7)]

  // 运行 Hopcroft-Karp 算法
  let result = @matching.hopcroft_karp(g, left_nodes, right_nodes)

  println("匹配结果:")
  println("  匹配大小: \{result.size()}")
  println("  匹配边数: \{result.cardinality}")

  println("\n匹配的边:")
  for (u, v) in result.matching_edges {
    let u_id = match u { NodeId(n) => n }
    let v_id = match v { NodeId(n) => n }
    println("  工人 \{u_id} -> 任务 \{v_id}")
  }

  println("\n检查匹配状态:")
  for i in 0..<8 {
    let node = @core.NodeId(i)
    let is_matched = result.is_matched(node)
    let partner = result.get_partner(node)
    match partner {
      Some(p) => {
        let p_id = match p { NodeId(n) => n }
        println("  节点 \{i}: 已匹配 -> \{p_id}")
      }
      None => println("  节点 \{i}: 未匹配")
    }
  }
}

/// 示例 2: 加权二部图匹配（Hungarian/KM）
fn hungarian_example() {
  println("\n=== Hungarian (Kuhn-Munkres) 加权匹配 ===\n")

  println("权重矩阵（工人-任务效率）:")
  println("     T0  T1  T2  T3")
  println("  W0  4   3   2   1")
  println("  W1  1   2   3   4")
  println("  W2  3   1   4   2")
  println("  W3  2   4   1   3")

  // 创建权重矩阵
  let weights = [
    [4.0, 3.0, 2.0, 1.0],  // 工人 0
    [1.0, 2.0, 3.0, 4.0],  // 工人 1
    [3.0, 1.0, 4.0, 2.0],  // 工人 2
    [2.0, 4.0, 1.0, 3.0],  // 工人 3
  ]

  // 运行 Hungarian 算法
  let result = @matching.kuhn_munkres(weights)

  println("\n最优匹配:")
  println("  总权重: \{result.total_weight}")
  println("  匹配方案:")

  for i in 0..<4 {
    let task = result.matching[i]
    println("  工人 \{i} -> 任务 \{task} (效率: \{weights[i][task]})")
  }
}

/// 示例 3: 一般图最大匹配（Edmonds Blossom）
fn edmonds_example() {
  println("\n=== Edmonds Blossom 一般图最大匹配 ===\n")

  // 创建一般图（非二部图）
  let g = @storage.new_undirected()

  // 添加 6 个节点
  for i in 0..<6 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加边（形成奇环）
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)  // 奇环
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(5), @core.NodeId(3), 1.0)  // 另一个奇环

  // 运行 Edmonds 算法
  let result = @matching.edmonds_maximum_matching(g)

  println("一般图最大匹配:")
  println("  匹配大小: \{result.size()}")

  println("\n匹配的边:")
  for (u, v) in result.matching_edges {
    let u_id = match u { NodeId(n) => n }
    let v_id = match v { NodeId(n) => n }
    println("  \{u_id} -- \{v_id}")
  }
}

/// 示例 4: 比较匹配算法
fn compare_matching_algorithms() {
  println("\n=== 比较匹配算法 ===\n")

  let g = create_bipartite_graph()
  let left_nodes = [@core.NodeId(0), @core.NodeId(1), @core.NodeId(2), @core.NodeId(3)]
  let right_nodes = [@core.NodeId(4), @core.NodeId(5), @core.NodeId(6), @core.NodeId(7)]

  // Hopcroft-Karp
  let hk = @matching.hopcroft_karp(g, left_nodes, right_nodes)
  println("Hopcroft-Karp: 匹配大小 = \{hk.size()}")

  // 基于边列表的匹配
  let bm = @matching.bipartite_matching(4, 4, [(0, 4), (0, 5), (1, 5), (1, 6), (2, 6), (2, 7), (3, 5)])
  println("边列表匹配:   匹配大小 = \{bm.size()}")

  // Hungarian（加权）
  let weights = [
    [4.0, 3.0, 2.0, 1.0],
    [1.0, 2.0, 3.0, 4.0],
    [3.0, 1.0, 4.0, 2.0],
    [2.0, 4.0, 1.0, 3.0],
  ]
  let km = @matching.kuhn_munkres(weights)
  println("Hungarian:    总权重 = \{km.total_weight}")
}

/// 主函数
fn main {
  hopcroft_karp_example()
  hungarian_example()
  edmonds_example()
  compare_matching_algorithms()
}
