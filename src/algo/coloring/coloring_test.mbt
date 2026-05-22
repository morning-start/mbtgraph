///|
/// 图着色算法测试套件

// ============================================================================
// 辅助函数：构建测试图
// ============================================================================

///|
/// 创建完全图 K_n（每对节点间都有边）
fn make_complete_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  i = 0
  while i < n {
    let mut j = i + 1
    while j < n {
      @storage.UndirectedAdjList::add_edge(
        g,
        @core.NodeId(i),
        @core.NodeId(j),
        1.0,
      )
      |> ignore
      j = j + 1
    }
    i = i + 1
  }
  g
}

///|
/// 创建二分图 K_{left,right}
fn make_bipartite_graph(left : Int, right : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < left + right {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  i = 0
  while i < left {
    let mut j = left
    while j < left + right {
      @storage.UndirectedAdjList::add_edge(
        g,
        @core.NodeId(i),
        @core.NodeId(j),
        1.0,
      )
      |> ignore
      j = j + 1
    }
    i = i + 1
  }
  g
}

///|
/// 创建环图 C_n（n 个节点首尾相连）
fn make_cycle_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  i = 0
  while i < n {
    @storage.UndirectedAdjList::add_edge(
      g,
      @core.NodeId(i),
      @core.NodeId((i + 1) % n),
      1.0,
    )
    |> ignore
    i = i + 1
  }
  g
}

///|
/// 创建奇环图（n 为奇数）
fn make_odd_cycle(n : Int) -> @storage.UndirectedAdjList {
  make_cycle_graph(n)
}

///|
/// 创建星形图（中心节点 0 连接所有叶子节点）
fn make_star_graph(leaves : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let mut i = 1
  while i <= leaves {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    @storage.UndirectedAdjList::add_edge(
      g,
      @core.NodeId(0),
      @core.NodeId(i),
      1.0,
    )
    |> ignore
    i = i + 1
  }
  g
}

// ============================================================================
// 基础功能测试
// ============================================================================

///|
test "complete_graph_k4_uses_4_colors" {
  let g = make_complete_graph(4)
  let result = greedy_coloring(g)
  assert_eq(result.num_colors, 4)
  assert_true(result.is_valid)
}

///|
test "bipartite_graph_uses_at_most_2_colors" {
  let g = make_bipartite_graph(3, 3)
  let result = greedy_coloring(g)
  assert_true(result.num_colors <= 2)
  assert_true(result.is_valid)
}

///|
test "odd_cycle_needs_3_colors" {
  let g = make_odd_cycle(5)
  let result = greedy_coloring(g)
  assert_eq(result.num_colors, 3)
  assert_true(result.is_valid)
}

///|
test "star_graph_uses_2_colors" {
  let g = make_star_graph(5)
  let result = greedy_coloring(g)
  assert_true(result.num_colors <= 2)
  assert_true(result.is_valid)
}

// ============================================================================
// 算法对比测试
// ============================================================================

///|
test "welsh_powell_better_than_naive" {
  let g = make_cycle_graph(10)
  let naive = greedy_coloring(g)
  let wp = welsh_powell(g)
  assert_true(wp.num_colors <= naive.num_colors)
  assert_true(wp.is_valid)
}

///|
test "dsatur_best_among_heuristics" {
  let g = make_complete_graph(6)
  let naive = greedy_coloring(g)
  let wp = welsh_powell(g)
  let dsatur = dsatur_coloring(g)
  assert_eq(dsatur.num_colors, 6)
  assert_true(dsatur.is_valid)
}

///|
test "dsatur_valid_on_complex_graph" {
  let g = make_bipartite_graph(4, 4)
  let result = dsatur_coloring(g)
  assert_true(result.num_colors <= 2)
  assert_true(result.is_valid)
}

///|
test "welsh_powell_complete_graph" {
  let g = make_complete_graph(5)
  let result = welsh_powell(g)
  assert_eq(result.num_colors, 5)
  assert_true(result.is_valid)
}

// ============================================================================
// 边界情况测试
// ============================================================================

///|
test "empty_graph_0_colors" {
  let g = @storage.new_undirected()
  let result = greedy_coloring(g)
  assert_eq(result.num_colors, 0)
  assert_true(result.is_valid)
}

///|
test "single_node_1_color" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = greedy_coloring(g)
  assert_eq(result.num_colors, 1)
  assert_true(result.is_valid)
}

///|
test "single_edge_2_colors_or_1" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  let result = greedy_coloring(g)
  assert_true(result.is_valid)
  assert_true(result.num_colors <= 2)
}

///|
test "empty_graph_all_algorithms" {
  let g = @storage.new_undirected()
  let r1 = greedy_coloring(g)
  let r2 = welsh_powell(g)
  let r3 = dsatur_coloring(g)
  assert_eq(r1.num_colors, 0)
  assert_eq(r2.num_colors, 0)
  assert_eq(r3.num_colors, 0)
}

///|
test "custom_order_coloring" {
  let g = make_complete_graph(3)
  let order : Array[Int] = [2, 1, 0]
  let result = greedy_coloring_with_order(g, order)
  assert_eq(result.num_colors, 3)
  assert_true(result.is_valid)
}

// ============================================================================
// 属性验证测试
// ============================================================================

///|
test "coloring_validity_no_adjacent_same_color" {
  let g = make_complete_graph(5)
  let result = dsatur_coloring(g)
  assert_true(result.is_valid)
  let n = @core.GraphReadable::node_count(g)
  let mut i = 0
  while i < n {
    let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(i))
    for neighbor in neighbors {
      let ni = neighbor.0
      assert_true(result.colors[i] != result.colors[ni])
    }
    i = i + 1
  }
}

///|
test "color_count_does_not_exceed_vertex_count" {
  let g = make_star_graph(10)
  let result = welsh_powell(g)
  assert_true(result.num_colors <= @core.GraphReadable::node_count(g))
}

///|
test "all_nodes_colored" {
  let g = make_cycle_graph(7)
  let result = dsatur_coloring(g)
  let n = @core.GraphReadable::node_count(g)
  assert_eq(result.colors.length(), n)
  let mut i = 0
  while i < n {
    assert_true(result.colors[i] >= 0)
    i = i + 1
  }
}

///|
test "greedy_order_preserved" {
  let g = make_bipartite_graph(2, 2)
  let result = greedy_coloring(g)
  assert_true(result.colors[0] == 0)
  assert_true(result.is_valid)
}

// ============================================================================
// 精确色数算法测试
// ============================================================================

///|
test "exact_chromatic_empty_graph" {
  let g = @storage.new_undirected()
  let result = exact_chromatic_number(g, 5000)
  match result.chromatic_number {
    Some(c) => assert_eq(c, 0)
    None => assert_true(false)
  }
  assert_true(result.exact)
}

///|
test "exact_chromatic_single_node" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = exact_chromatic_number(g, 5000)
  match result.chromatic_number {
    Some(c) => assert_eq(c, 1)
    None => assert_true(false)
  }
  assert_true(result.exact)
}

///|
test "exact_chromatic_bipartite" {
  let g = make_bipartite_graph(3, 3)
  let result = exact_chromatic_number(g, 5000)
  match result.chromatic_number {
    Some(c) => assert_true(c <= 2)
    None => assert_true(false)
  }
  assert_true(result.exact)
}

///|
test "exact_chromatic_complete_graph_k4" {
  let g = make_complete_graph(4)
  let result = exact_chromatic_number(g, 5000)
  match result.chromatic_number {
    Some(c) => assert_eq(c, 4)
    None => assert_true(false)
  }
  assert_true(result.exact)
}
