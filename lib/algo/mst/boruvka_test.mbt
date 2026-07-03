// ============================================================================
// Borůvka 算法测试
// ============================================================================

///|
fn make_boruvka_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 2.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 3.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 4.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 5.0)
  |> ignore
  g
}

///|
test "boruvka: basic MST" {
  let g = make_boruvka_graph()
  let result = boruvka(g)
  assert_eq(result.edge_count(), 3)
  // Correct MST: 0-1(1) + 1-2(2) + 2-3(3) = 6
  assert_true(result.total_weight - 6.0 < 0.0001)
}

///|
test "boruvka: matches kruskal result" {
  let g = make_boruvka_graph()
  let res_b = boruvka(g)
  let res_k = kruskal(g)
  assert_eq(res_b.edge_count(), res_k.edge_count())
  assert_true(res_b.total_weight - res_k.total_weight < 0.0001)
}

///|
test "boruvka: empty graph" {
  let g = @storage.new_undirected()
  let result = boruvka(g)
  assert_eq(result.edge_count(), 0)
  assert_true(result.total_weight < 0.0001)
}

///|
test "boruvka: disconnected graph" {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 3.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 4.0)
  |> ignore
  let result = boruvka(g)
  assert_eq(result.edge_count(), 2)
}

///|
test "boruvka: single node" {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let result = boruvka(g)
  assert_eq(result.edge_count(), 0)
}

///|
test "boruvka: equal weights" {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  let result = boruvka(g)
  assert_eq(result.edge_count(), 2)
  assert_true(result.total_weight - 2.0 < 0.0001)
}
