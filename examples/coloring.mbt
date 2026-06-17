// 图着色示例
// 演示贪心着色、DSATUR 和精确色数算法的使用

import "morning-start/mbtgraph/lib/core" as @core
import "morning-start/mbtgraph/lib/storage" as @storage
import "morning-start/mbtgraph/lib/algo/coloring" as @coloring

/// 创建示例图：地图着色（澳大利亚）
///
///     WA --- NT --- SA --- Q --- NSW
///      \     |     / \     |     /
///       \    |    /   \    |    /
///        \   |   /     \   |   /
///         \  |  /       \  |  /
///          \ | /         \ | /
///           \|/           \|/
///            V             V
///           WA            VIC
///
/// WA: 西澳大利亚, NT: 北领地, SA: 南澳大利亚
/// Q: 昆士兰, NSW: 新南威尔士, VIC: 维多利亚
fn create_australia_map() -> UndirectedAdjList {
  let g = @storage.new_undirected()

  // 添加 6 个节点（州）
  for i in 0..<6 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加边界（边）
  // WA-NT, WA-SA
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)

  // NT-SA, NT-Q
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0)

  // SA-Q, SA-NSW, SA-VIC
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(4), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(5), 1.0)

  // Q-NSW
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)

  // NSW-VIC
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0)

  g
}

/// 创建示例图：奇环（需要 3 种颜色）
fn create_odd_cycle() -> UndirectedAdjList {
  let g = @storage.new_undirected()

  // 添加 5 个节点（五边形）
  for i in 0..<5 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 添加环边
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(0), 1.0)

  g
}

/// 打印着色结果
fn print_coloring_result(name: String, result: ColoringResult) {
  println("\{name}:")
  println("  使用颜色数: \{result.num_colors}")
  println("  着色有效: \{result.is_valid}")

  let state_names = ["WA", "NT", "SA", "Q", "NSW", "VIC"]
  println("  各州颜色:")
  for i in 0..<result.colors.length() {
    if i < state_names.length() {
      println("    \{state_names[i]}: 颜色 \{result.colors[i]}")
    } else {
      println("    州 \{i}: 颜色 \{result.colors[i]}")
    }
  }
}

/// 示例 1: 贪心着色
fn greedy_coloring_example() {
  println("=== 贪心着色算法 ===\n")

  let g = create_australia_map()

  // 运行贪心着色
  let result = @coloring.greedy_coloring(g)

  print_coloring_result("贪心着色", result)
}

/// 示例 2: Welsh-Powell 着色
fn welsh_powell_example() {
  println("\n=== Welsh-Powell 着色算法 ===\n")

  let g = create_australia_map()

  // 运行 Welsh-Powell 着色
  let result = @coloring.welsh_powell(g)

  print_coloring_result("Welsh-Powell 着色", result)
}

/// 示例 3: DSATUR 着色
fn dsatur_example() {
  println("\n=== DSATUR 着色算法 ===\n")

  let g = create_australia_map()

  // 运行 DSATUR 着色
  let result = @coloring.dsatur_coloring(g)

  print_coloring_result("DSATUR 着色", result)
}

/// 示例 4: 精确色数
fn exact_chromatic_example() {
  println("\n=== 精确色数算法 ===\n")

  // 使用五边形（需要 3 种颜色）
  let g = create_odd_cycle()

  println("五边形图（奇环）:")

  // 运行精确色数算法
  let result = @coloring.exact_chromatic_number(g, 5)

  println("精确色数结果:")
  println("  色数: \{result.chromatic_number}")
  println("  上界: \{result.upper_bound}")
  println("  下界: \{result.lower_bound}")
  println("  是否精确: \{result.exact}")

  match result.optimal_coloring {
    Some(colors) => {
      println("  最优着色: \{colors}")
    }
    None => println("  未找到最优着色")
  }
}

/// 示例 5: 边着色
fn edge_coloring_example() {
  println("\n=== 边着色算法 ===\n")

  // 创建完全图 K4
  let g = @storage.new_undirected()

  for i in 0..<4 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // K4 的所有边
  for i in 0..<4 {
    for j in i + 1..<4 {
      let _ = @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(j), 1.0)
    }
  }

  println("完全图 K4:")

  // 运行边着色
  let result = @coloring.edge_coloring(g)

  println("边着色结果:")
  println("  使用颜色数: \{result.num_colors}")
  println("  最大度数: \{result.max_degree}")
  println("  着色有效: \{result.is_valid}")

  println("\n各边颜色:")
  for i in 0..<4 {
    for j in i + 1..<4 {
      let color = result.edge_color(@core.NodeId(i), @core.NodeId(j))
      println("  (\{i}, \{j}): 颜色 \{color}")
    }
  }
}

/// 示例 6: 比较着色算法
fn compare_coloring_algorithms() {
  println("\n=== 比较着色算法 ===\n")

  let g = create_australia_map()

  // 贪心着色
  let greedy = @coloring.greedy_coloring(g)
  println("贪心着色: \{greedy.num_colors} 种颜色")

  // Welsh-Powell
  let wp = @coloring.welsh_powell(g)
  println("Welsh-Powell: \{wp.num_colors} 种颜色")

  // DSATUR
  let dsatur = @coloring.dsatur_coloring(g)
  println("DSATUR: \{dsatur.num_colors} 种颜色")

  // 精确色数
  let exact = @coloring.exact_chromatic_number(g, 4)
  match exact.chromatic_number {
    Some(n) => println("精确色数: \{n} 种颜色")
    None => println("精确色数: 未确定")
  }
}

/// 主函数
fn main {
  greedy_coloring_example()
  welsh_powell_example()
  dsatur_example()
  exact_chromatic_example()
  edge_coloring_example()
  compare_coloring_algorithms()
}
