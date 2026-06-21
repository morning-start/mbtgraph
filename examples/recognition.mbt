// 图识别示例
// 演示图类型识别（二部图、正则图、完全图、树等）

import "morning-start/mbtgraph/lib/core" as @core
import "morning-start/mbtgraph/lib/storage" as @storage
import "morning-start/mbtgraph/lib/algo/recognition" as @rec

/// 创建二部图示例（用户-商品匹配）
///
///  用户: 0, 1, 2
///  商品: 3, 4, 5
///
///  0---3, 0---4
///  1---4, 1---5
///  2---5
///
fn create_bipartite_graph() -> UndirectedAdjList {
  let g = @storage.new_undirected()

  for i in 0..<6 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 用户-商品连接（没有用户-用户或商品-商品连接）
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(4), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(5), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(5), 1.0)

  g
}

/// 创建完全图示例
///
///  0---1
///  |\ /|
///  | X |
///  |/ \|
///  2---3
///
fn create_complete_graph() -> UndirectedAdjList {
  let g = @storage.new_undirected()

  for i in 0..<4 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 所有节点对都有边
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)

  g
}

/// 创建正则图示例（每个节点度数相同）
///
///  0---1
///  |   |
///  3---2
///
fn create_regular_graph() -> UndirectedAdjList {
  let g = @storage.new_undirected()

  for i in 0..<4 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 每个节点度数为 2
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0)

  g
}

/// 创建树图示例
///
///      0
///     / \
///    1   2
///   / \
///  3   4
///
fn create_tree_graph() -> UndirectedAdjList {
  let g = @storage.new_undirected()

  for i in 0..<5 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(4), 1.0)

  g
}

/// 示例 1: 二部图检测
fn bipartite_example() {
  println("=== 二部图检测 (Bipartite) ===\n")

  let g = create_bipartite_graph()
  let is_bipartite = @rec.is_bipartite(g)
  println("用户-商品图是否为二部图: \{is_bipartite}")
  println("  说明: 二部图的节点可以分为两组，边只在组间连接\n")
}

/// 示例 2: 完全图检测
fn complete_example() {
  println("=== 完全图检测 (Complete) ===\n")

  let g1 = create_complete_graph()
  let is_complete1 = @rec.is_complete(g1)
  println("4 节点完全图是否为完全图: \{is_complete1}")

  let g2 = create_bipartite_graph()
  let is_complete2 = @rec.is_complete(g2)
  println("二部图是否为完全图: \{is_complete2}")
  println("  说明: 完全图中每对不同节点之间都有边\n")
}

/// 示例 3: 正则图检测
fn regular_example() {
  println("=== 正则图检测 (Regular) ===\n")

  let g1 = create_regular_graph()
  let is_regular1 = @rec.is_regular(g1)
  println("环形图是否为正则图: \{is_regular1}")

  let g2 = create_complete_graph()
  let is_regular2 = @rec.is_regular(g2)
  println("完全图是否为正则图: \{is_regular2}")
  println("  说明: 正则图中所有节点的度数相同\n")
}

/// 示例 4: 树检测
fn tree_example() {
  println("=== 树检测 (Tree) ===\n")

  let g1 = create_tree_graph()
  let is_tree1 = @rec.is_tree(g1)
  println("树形图是否为树: \{is_tree1}")

  let g2 = create_regular_graph()
  let is_tree2 = @rec.is_tree(g2)
  println("环形图是否为树: \{is_tree2}")
  println("  说明: 树是连通且无环的图\n")
}

/// 示例 5: 森林检测
fn forest_example() {
  println("=== 森林检测 (Forest) ===\n")

  // 创建森林（两个不相连的树）
  let g = @storage.new_undirected()
  for i in 0..<6 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 第一棵树: 0-1-2
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)

  // 第二棵树: 3-4-5
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0)

  let is_forest = @rec.is_forest(g)
  println("两个不相连的树是否为森林: \{is_forest}")
  println("  说明: 森林是无环图（可以不连通）\n")
}

/// 示例 6: 综合识别
fn comprehensive_recognition() {
  println("=== 综合图类型识别 ===\n")

  let bipartite_g = create_bipartite_graph()
  let complete_g = create_complete_graph()
  let regular_g = create_regular_graph()
  let tree_g = create_tree_graph()

  let graphs = [
    ("二部图", bipartite_g),
    ("完全图", complete_g),
    ("正则图", regular_g),
    ("树", tree_g),
  ]

  println("图类型    | 二部图 | 完全图 | 正则图 | 树   | 森林")
  println("----------|--------|--------|--------|------|------")

  for item in graphs {
    let (name, g) = item
    let b = @rec.is_bipartite(g)
    let c = @rec.is_complete(g)
    let r = @rec.is_regular(g)
    let t = @rec.is_tree(g)
    let f = @rec.is_forest(g)

    let b_str = if b { "  ✓  " } else { "  ✗  " }
    let c_str = if c { "  ✓  " } else { "  ✗  " }
    let r_str = if r { "  ✓  " } else { "  ✗  " }
    let t_str = if t { "  ✓ " } else { "  ✗ " }
    let f_str = if f { "  ✓ " } else { "  ✗ " }

    println("\{name}    | \{b_str} | \{c_str} | \{r_str} | \{t_str} | \{f_str}")
  }
}

/// 主函数
fn main {
  bipartite_example()
  complete_example()
  regular_example()
  tree_example()
  forest_example()
  comprehensive_recognition()
}
