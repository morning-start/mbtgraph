// ============================================================================
// Girvan-Newman 社区检测测试
// ============================================================================

///|
fn make_gn_simple_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  // 三角形: 0-1-2-0
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  g
}

///|
test "girvan_newman: triangle graph produces levels" {
  let g = make_gn_simple_graph()
  let result = girvan_newman(g, 0)
  assert_true(result.total_levels > 0)
  assert_true(result.levels.length() > 0)
}

///|
test "girvan_newman: empty graph" {
  let g = @storage.new_undirected()
  let result = girvan_newman(g, 0)
  assert_eq(result.total_levels, 0)
}

///|
test "girvan_newman: single node" {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let result = girvan_newman(g, 0)
  assert_eq(result.total_levels, 1)
}

///|
test "girvan_newman: two nodes" {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  let result = girvan_newman(g, 0)
  assert_eq(result.total_levels, 1)
}

///|
fn make_gn_two_communities() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  // 社区 A: 0-1-2 (三角)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  // 社区 B: 3-4 (edge)
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  // 桥接边: 2-3
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  g
}

///|
test "girvan_newman: two communities detection" {
  let g = make_gn_two_communities()
  let result = girvan_newman(g, 0)
  assert_true(result.total_levels > 1)
  // 桥接边介数应最高，最先被移除
  assert_true(result.best_modularity >= 0.0)
  let last_level = result.levels[result.levels.length() - 1]
  assert_true(last_level.communities.length() >= 2)
}
