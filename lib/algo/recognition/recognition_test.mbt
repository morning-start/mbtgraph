/// 特殊图识别模块测试

// ============================================================================
// 辅助函数：构建测试图
// ============================================================================

fn make_empty_undirected() -> @storage.UndirectedAdjList {
  @storage.new_undirected()
}

fn make_single_node() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  g
}

fn make_two_node_edge() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  g
}

fn make_complete_k3() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore
  g
}

fn make_path3() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  g
}

fn make_odd_cycle() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(0), 1.0) |> ignore
  g
}

fn make_even_cycle() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0) |> ignore
  g
}

// ============================================================================
// 二分图测试
// ============================================================================

///|
test "is_bipartite_empty" {
  assert_true(is_bipartite(make_empty_undirected()))
}

///|
test "is_bipartite_single_node" {
  assert_true(is_bipartite(make_single_node()))
}

///|
test "is_bipartite_single_edge" {
  assert_true(is_bipartite(make_two_node_edge()))
}

///|
test "is_bipartite_even_cycle" {
  assert_true(is_bipartite(make_even_cycle()))
}

///|
test "is_bipartite_odd_cycle" {
  assert_false(is_bipartite(make_odd_cycle()))
}

///|
test "is_bipartite_triangle" {
  assert_false(is_bipartite(make_complete_k3()))
}

///|
test "is_bipartite_path3" {
  assert_true(is_bipartite(make_path3()))
}

// ============================================================================
// 完全图测试
// ============================================================================

///|
test "is_complete_empty" {
  assert_true(is_complete(make_empty_undirected()))
}

///|
test "is_complete_single_node" {
  assert_true(is_complete(make_single_node()))
}

///|
test "is_complete_triangle" {
  assert_true(is_complete(make_complete_k3()))
}

///|
test "is_complete_path3" {
  assert_false(is_complete(make_path3()))
}

// ============================================================================
// 正则图测试
// ============================================================================

///|
test "is_regular_empty" {
  assert_true(is_regular(make_empty_undirected()))
}

///|
test "is_regular_single_node" {
  assert_true(is_regular(make_single_node()))
}

///|
test "is_regular_triangle" {
  // K3: all degrees = 2
  assert_true(is_regular(make_complete_k3()))
}

///|
test "is_regular_path3" {
  // Path3: deg 0=1, deg 1=2, deg 2=1, not all same
  assert_false(is_regular(make_path3()))
}

///|
test "is_regular_even_cycle" {
  // C4: all degrees = 2
  assert_true(is_regular(make_even_cycle()))
}

// ============================================================================
// 树测试
// ============================================================================

///|
test "is_tree_empty" {
  assert_false(is_tree(make_empty_undirected()))
}

///|
test "is_tree_single_node" {
  assert_true(is_tree(make_single_node()))
}

///|
test "is_tree_single_edge" {
  assert_true(is_tree(make_two_node_edge()))
}

///|
test "is_tree_path3" {
  assert_true(is_tree(make_path3()))
}

///|
test "is_tree_triangle" {
  assert_false(is_tree(make_complete_k3()))
}

///|
test "is_tree_odd_cycle" {
  assert_false(is_tree(make_odd_cycle()))
}

// ============================================================================
// 森林测试
// ============================================================================

///|
test "is_forest_empty" {
  assert_true(is_forest(make_empty_undirected()))
}

///|
test "is_forest_single_node" {
  assert_true(is_forest(make_single_node()))
}

///|
test "is_forest_single_edge" {
  assert_true(is_forest(make_two_node_edge()))
}

///|
test "is_forest_path3" {
  assert_true(is_forest(make_path3()))
}

///|
test "is_forest_triangle" {
  assert_false(is_forest(make_complete_k3()))
}

// ============================================================================
// 弦图测试
// ============================================================================

///|
test "is_chordal_empty" {
  assert_true(is_chordal(make_empty_undirected()))
}

///|
test "is_chordal_single_node" {
  assert_true(is_chordal(make_single_node()))
}

///|
test "is_chordal_triangle" {
  assert_true(is_chordal(make_complete_k3()))
}

///|
test "is_chordal_even_cycle" {
  // C4 has no chord, not chordal
  assert_false(is_chordal(make_even_cycle()))
}

///|
test "is_chordal_odd_cycle" {
  // C5 has no chord, not chordal
  assert_false(is_chordal(make_odd_cycle()))
}

// ============================================================================
// Havel-Hakimi 测试
// ============================================================================

///|
test "is_graphic_sequence_empty" {
  assert_true(is_graphic_sequence([]))
}

///|
test "is_graphic_sequence_valid" {
  // 3-cycle
  assert_true(is_graphic_sequence([2, 2, 2]))
}

///|
test "is_graphic_sequence_path3" {
  // 1-2-1
  assert_true(is_graphic_sequence([2, 1, 1]))
}

///|
test "is_graphic_sequence_negative" {
  assert_false(is_graphic_sequence([-1, 2, 1]))
}

///|
test "is_graphic_sequence_odd_sum" {
  // Odd sum: handshake lemma violation
  assert_false(is_graphic_sequence([3, 3, 3]))
}

///|
test "is_graphic_sequence_too_large" {
  // Degree exceeds possible
  assert_false(is_graphic_sequence([5, 2, 1, 1]))
}
