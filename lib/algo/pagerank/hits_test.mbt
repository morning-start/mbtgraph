// ============================================================================
// HITS 算法测试
// ============================================================================

///|
fn make_hits_graph() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  // 0 → 1, 1 → 2, 2 → 0 (三角环)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  |> ignore
  g
}

///|
test "hits: basic authority and hub scores" {
  let g = make_hits_graph()
  let result = hits(g, 100, 0.0001)
  assert_eq(result.authority.length(), 3)
  assert_eq(result.hub.length(), 3)
  assert_true(result.converged)
  // 三角环：所有节点的 authority 和 hub 应相等
  let a0 = result.authority[0]
  let a1 = result.authority[1]
  let a2 = result.authority[2]
  assert_true((a0 - a1).abs() < 0.001)
  assert_true((a1 - a2).abs() < 0.001)
  let h0 = result.hub[0]
  let h1 = result.hub[1]
  let h2 = result.hub[2]
  assert_true((h0 - h1).abs() < 0.001)
  assert_true((h1 - h2).abs() < 0.001)
}

///|
test "hits: empty graph" {
  let g = @storage.new_directed()
  let result = hits(g, 100, 0.0001)
  assert_eq(result.authority.length(), 0)
  assert_eq(result.hub.length(), 0)
  assert_true(result.converged)
}

///|
test "hits: single node" {
  let g = @storage.new_directed()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let result = hits(g, 100, 0.0001)
  assert_eq(result.authority.length(), 1)
  assert_eq(result.hub.length(), 1)
  assert_true(result.converged)
}

///|
fn make_star_hits_graph() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  // 0 → 1, 0 → 2, 0 → 3 (0 是 hub, 1,2,3 是 authority)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  g
}

///|
test "hits: star graph hub is node 0" {
  let g = make_star_hits_graph()
  let result = hits(g, 100, 0.0001)
  // Node 0 should have the highest hub score
  let mut max_hub_idx = 0
  let mut max_hub = result.hub[0]
  let mut i = 1
  while i < result.hub.length() {
    if result.hub[i] > max_hub {
      max_hub = result.hub[i]
      max_hub_idx = i
    }
    i = i + 1
  }
  assert_eq(max_hub_idx, 0)
}
