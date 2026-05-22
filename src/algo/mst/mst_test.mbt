///|
/// 最小生成树测试
fn make_undirected_test_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 2.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 3.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 7.0)
  |> ignore
  g
}

///|
fn make_disconnected_undirected() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 5.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 3.0)
  |> ignore
  g
}

// ============================================================================
// Kruskal 测试
// ============================================================================

///|
test "kruskal_simple_path_weight" {
  let g = make_undirected_test_graph()
  let mst = kruskal(g)
  assert_true(mst.total_weight == 6.0)
}

///|
test "kruskal_simple_path_edge_count" {
  let g = make_undirected_test_graph()
  let mst = kruskal(g)
  assert_true(mst.edge_count() == 3)
}

///|
test "kruskal_has_expected_edges" {
  let g = make_undirected_test_graph()
  let mst = kruskal(g)
  assert_true(mst.has_edge(@core.NodeId(0), @core.NodeId(1)))
  assert_true(mst.has_edge(@core.NodeId(1), @core.NodeId(2)))
  assert_true(mst.has_edge(@core.NodeId(2), @core.NodeId(3)))
}

///|
test "kruskal_no_heavy_edge" {
  let g = make_undirected_test_graph()
  let mst = kruskal(g)
  assert_true(!mst.has_edge(@core.NodeId(0), @core.NodeId(3)))
}

///|
test "kruskal_empty_graph" {
  let g = @storage.new_undirected()
  let mst = kruskal(g)
  assert_true(mst.total_weight == 0.0)
  assert_true(mst.edge_count() == 0)
}

///|
test "kruskal_single_node" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let mst = kruskal(g)
  assert_true(mst.edge_count() == 0)
}

///|
test "kruskal_disconnected_forest" {
  let g = make_disconnected_undirected()
  let mst = kruskal(g)
  assert_true(mst.edge_count() == 2)
  assert_true(mst.total_weight == 8.0)
}

// ============================================================================
// Prim 测试
// ============================================================================

///|
test "prim_simple_path_weight" {
  let g = make_undirected_test_graph()
  let mst = prim(g, @core.NodeId(0))
  assert_true(mst.total_weight == 6.0)
}

///|
test "prim_simple_path_edge_count" {
  let g = make_undirected_test_graph()
  let mst = prim(g, @core.NodeId(0))
  assert_true(mst.edge_count() == 3)
}

///|
test "prim_different_root_same_weight" {
  let g = make_undirected_test_graph()
  let mst0 = prim(g, @core.NodeId(0))
  let mst3 = prim(g, @core.NodeId(3))
  assert_true(mst0.total_weight == mst3.total_weight)
}

///|
test "prim_empty_graph" {
  let g = @storage.new_undirected()
  let mst = prim(g, @core.NodeId(0))
  assert_true(mst.edge_count() == 0)
}

///|
test "prim_root_not_in_graph" {
  let g = make_undirected_test_graph()
  let mst = prim(g, @core.NodeId(99))
  assert_true(mst.edge_count() == 0)
}

// ============================================================================
// Kruskal vs Prim 一致性
// ============================================================================

///|
test "kruskal_prim_same_weight" {
  let g = make_undirected_test_graph()
  let kmst = kruskal(g)
  let pmst = prim(g, @core.NodeId(0))
  assert_true(kmst.total_weight == pmst.total_weight)
  assert_true(kmst.edge_count() == pmst.edge_count())
}

// ============================================================================
// 跨存储兼容性
// ============================================================================

///|
test "cross_storage_kruskal_adjlist" {
  let g = make_undirected_test_graph()
  let mst = kruskal(g)
  assert_true(mst.edge_count() == 3)
}

///|
test "cross_storage_kruskal_matrix" {
  let g = @storage.new_undirected_matrix(10)
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 2.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 4.0)
  |> ignore
  let mst = kruskal(g)
  assert_true(mst.total_weight == 6.0)
}

///|
test "cross_storage_prim_edgelist" {
  let g = @storage.new_undirected_edge_list()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 3.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 5.0)
  |> ignore
  let mst = prim(g, @core.NodeId(0))
  assert_true(mst.total_weight == 4.0)
}
