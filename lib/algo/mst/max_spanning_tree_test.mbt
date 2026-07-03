// ============================================================================
// 最大生成树/森林 测试
// ============================================================================

///|
fn make_small_graph() -> @storage.UndirectedAdjList {
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
  g
}

///|
test "max_spanning_tree: finds max weight edges" {
  let g = make_small_graph()
  let result = max_spanning_tree(g)
  // MaxST: 0-3(4) + 2-3(3) + 1-2(2) = 9
  assert_eq(result.edge_count(), 3)
  assert_true(result.total_weight - 9.0 < 0.0001)
  assert_true(result.has_edge(@core.NodeId(0), @core.NodeId(3)))
  assert_true(result.has_edge(@core.NodeId(2), @core.NodeId(3)))
  assert_true(result.has_edge(@core.NodeId(1), @core.NodeId(2)))
}

///|
test "max_spanning_tree: empty graph" {
  let g = @storage.new_undirected()
  let result = max_spanning_tree(g)
  assert_eq(result.edge_count(), 0)
  assert_true(result.total_weight < 0.0001)
}

///|
test "max_spanning_tree: disconnected graph produces forest" {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  // 0-1 connected, 2-3 connected
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 5.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 6.0)
  |> ignore
  let result = max_spanning_tree(g)
  assert_eq(result.edge_count(), 2)
  assert_true(result.total_weight - 11.0 < 0.0001)
}

///|
test "max_spanning_tree: single node" {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let result = max_spanning_tree(g)
  assert_eq(result.edge_count(), 0)
}
