///|
/// 连通性分析测试
fn make_dag_for_scc() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  g
}

///|
fn make_scc_cycle_with_tail() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  g
}

// ============================================================================
// 无向连通分量测试
// ============================================================================

///|
test "connected_components_fully_connected" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  let cc = connected_components(g)
  assert_true(cc.count() == 1)
  assert_true(cc.size(0) == 3)
}

///|
test "connected_components_two_components" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  let cc = connected_components(g)
  assert_true(cc.count() == 2)
  assert_true(cc.size(0) == 2)
  assert_true(cc.size(1) == 2)
}

///|
test "connected_components_isolated_nodes" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let cc = connected_components(g)
  assert_true(cc.count() == 3)
}

///|
test "connected_components_empty" {
  let g = @storage.new_undirected()
  let cc = connected_components(g)
  assert_true(cc.count() == 0)
}

///|
test "connected_component_of" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  let cc = connected_components(g)
  assert_true(cc.component_of(@core.NodeId(0)) == 0)
  assert_true(cc.component_of(@core.NodeId(1)) == 0)
  assert_true(cc.component_of(@core.NodeId(2)) == 1)
}

// ============================================================================
// Tarjan SCC 测试
// ============================================================================

///|
test "tarjan_scc_cycle" {
  let g = make_scc_cycle_with_tail()
  let scc = tarjan_scc(g)
  assert_true(scc.count() == 2)
}

///|
test "tarjan_scc_cycle_size" {
  let g = make_scc_cycle_with_tail()
  let scc = tarjan_scc(g)
  let mut found_cycle = false
  let mut i = 0
  while i < scc.count() {
    if scc.components[i].length() == 3 {
      found_cycle = true
    }
    i = i + 1
  }
  assert_true(found_cycle)
}

///|
test "tarjan_scc_dag_all_singletons" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  let scc = tarjan_scc(g)
  assert_true(scc.count() == 3)
}

///|
test "tarjan_scc_empty" {
  let g = @storage.new_directed()
  let scc = tarjan_scc(g)
  assert_true(scc.count() == 0)
}

///|
test "tarjan_self_loop_is_scc" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(0), 1.0)
  |> ignore
  let scc = tarjan_scc(g)
  assert_true(scc.count() == 1)
  assert_true(scc.components[0].length() == 1)
}
// Kosaraju SCC 测试
// ============================================================================

///|
test "kosaraju_scc_cycle" {
  let g = make_scc_cycle_with_tail()
  let scc = kosaraju_scc(g)
  assert_true(scc.count() == 2)
}

///|
test "kosaraju_scc_dag_all_singletons" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  let scc = kosaraju_scc(g)
  assert_true(scc.count() == 3)
}

///|
test "kosaraju_scc_empty" {
  let g = @storage.new_directed()
  let scc = kosaraju_scc(g)
  assert_true(scc.count() == 0)
}

// ============================================================================
// Tarjan vs Kosaraju 一致性
// ============================================================================

///|
test "tarjan_kosaraju_same_count" {
  let g = make_dag_for_scc()
  let tscc = tarjan_scc(g)
  let kscc = kosaraju_scc(g)
  assert_true(tscc.count() == kscc.count())
}

// ============================================================================
// 跨存储兼容性
// ============================================================================

///|
test "cross_storage_cc_adjlist" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  let cc = connected_components(g)
  assert_true(cc.count() == 2)
}

///|
test "cross_storage_tarjan_matrix" {
  let g = @storage.new_directed_matrix(10)
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  |> ignore
  let scc = tarjan_scc(g)
  assert_true(scc.count() == 1)
}

///|
test "cross_storage_kosaraju_edgelist" {
  let g = @storage.new_edge_list()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  let scc = kosaraju_scc(g)
  assert_true(scc.count() == 2)
}
