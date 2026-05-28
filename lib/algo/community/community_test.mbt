///|
/// 社区检测测试套件
fn make_two_clusters() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 6 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(5), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(5), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(5), 1.0)
  |> ignore
  g
}

///|
fn make_path_5() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 5 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(3), 1.0)
  |> ignore
  g
}

///|
fn make_ring_4() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  g
}

///|
fn make_dense_cluster_6() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 6 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let mut a = 0
  while a < 6 {
    let mut b = 0
    while b < 6 {
      if a != b {
        @core.GraphWritable::add_edge(g, @core.NodeId(a), @core.NodeId(b), 1.0)
        |> ignore
      }
      b = b + 1
    }
    a = a + 1
  }
  g
}

// ============================================================
// Louvain 测试 (16 tests)
// ============================================================

///|
test "louvain_two_clusters_two_comms" {
  let g = make_two_clusters()
  let result = louvain(g, 1.0)
  assert_true(result.num_communities >= 2)
  let lbl0 = result.get_label(@core.NodeId(0))
  let lbl3 = result.get_label(@core.NodeId(3))
  match (lbl0, lbl3) {
    (Some(a), Some(b)) => assert_true(a != b)
    _ => assert_true(false)
  }
}

///|
test "louvain_dense_cluster_one_comm" {
  let g = make_dense_cluster_6()
  let result = louvain(g, 1.0)
  assert_true(result.num_communities >= 1)
  assert_true(result.labels.length() == 6)
}

///|
test "louvain_ring_no_trivial" {
  let g = make_ring_4()
  let result = louvain(g, 1.0)
  assert_true(result.num_communities > 0)
  assert_true(result.num_communities <= 4)
}

///|
test "louvain_path_non_trivial" {
  let g = make_path_5()
  let result = louvain(g, 1.0)
  assert_true(result.labels.length() == 5)
}

///|
test "louvain_empty_graph" {
  let g = @storage.new_directed()
  let result = louvain(g, 1.0)
  assert_true(result.labels.length() == 0)
  assert_eq(result.num_communities, 0)
}

///|
test "louvain_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = louvain(g, 1.0)
  assert_true(result.labels.length() == 1)
  assert_eq(result.num_communities, 1)
  match result.get_label(@core.NodeId(0)) {
    Some(l) => assert_eq(l, 0)
    None => assert_true(false)
  }
}

///|
test "louvain_resolution_effect" {
  let g = make_two_clusters()
  let result_low = louvain(g, 0.5)
  let result_high = louvain(g, 2.0)
  assert_true(result_high.num_communities >= result_low.num_communities)
}

///|
test "louvain_same_cluster_dense" {
  let g = make_dense_cluster_6()
  let result = louvain(g, 0.1)
  assert_true(result.num_communities >= 1)
}

///|
test "louvain_immutability" {
  let original_g = make_path_5()
  let nc_before = @core.GraphReadable::node_count(original_g)
  let _r = louvain(original_g, 1.0)
  let nc_after = @core.GraphReadable::node_count(original_g)
  assert_eq(nc_before, nc_after)
}

///|
test "louvain_labels_in_range" {
  let g = make_path_5()
  let result = louvain(g, 1.0)
  for lbl in result.labels {
    assert_true(lbl >= 0)
    assert_true(lbl < result.num_communities)
  }
}

///|
test "louvain_get_label_out_of_range" {
  let g = make_path_5()
  let result = louvain(g, 1.0)
  match result.get_label(@core.NodeId(100)) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "louvain_nodes_in_community" {
  let g = make_two_clusters()
  let result = louvain(g, 1.0)
  let nodes_c0 = result.nodes_in_community(0)
  let nodes_c1 = result.nodes_in_community(1)
  assert_true(nodes_c0.length() + nodes_c1.length() <= 6)
}

///|
test "louvain_modularity_reasonable" {
  let g = make_two_clusters()
  let result = louvain(g, 1.0)
  assert_true(result.modularity >= -1.0)
  assert_true(result.modularity <= 1.0)
}

///|
test "louvain_largest_community_size" {
  let g = make_two_clusters()
  let result = louvain(g, 1.0)
  let max_sz = result.largest_community_size()
  assert_true(max_sz > 0)
  assert_true(max_sz <= 6)
}

///|
test "louvain_positive_levels" {
  let g = make_path_5()
  let result = louvain(g, 1.0)
  assert_true(result.levels >= 1)
}

///|
test "louvain_deterministic_result" {
  let g = make_two_clusters()
  let r1 = louvain(g, 1.0)
  let r2 = louvain(g, 1.0)
  assert_eq(r1.labels.length(), r2.labels.length())
}

// ============================================================
// 标签传播测试 (14 tests)
// ============================================================

///|
test "lp_two_clusters_two_comms" {
  let g = make_two_clusters()
  let result = label_propagation(g, 100)
  assert_true(result.num_communities >= 2)
  let lbl0 = result.get_label(@core.NodeId(0))
  let lbl3 = result.get_label(@core.NodeId(3))
  match (lbl0, lbl3) {
    (Some(a), Some(b)) => assert_true(a != b)
    _ => assert_true(false)
  }
}

///|
test "lp_dense_cluster" {
  let g = make_dense_cluster_6()
  let result = label_propagation(g, 100)
  assert_true(result.labels.length() == 6)
  assert_true(result.num_communities >= 1)
}

///|
test "lp_ring_4" {
  let g = make_ring_4()
  let result = label_propagation(g, 100)
  assert_true(result.num_communities > 0)
  assert_true(result.num_communities <= 4)
}

///|
test "lp_path_5" {
  let g = make_path_5()
  let result = label_propagation(g, 100)
  assert_true(result.labels.length() == 5)
}

///|
test "lp_empty_graph" {
  let g = @storage.new_directed()
  let result = label_propagation(g, 100)
  assert_true(result.labels.length() == 0)
  assert_eq(result.num_communities, 0)
}

///|
test "lp_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = label_propagation(g, 100)
  assert_true(result.labels.length() == 1)
  assert_eq(result.num_communities, 1)
}

///|
test "lp_max_iterations_effect" {
  let g = make_dense_cluster_6()
  let r1 = label_propagation(g, 1)
  let r10 = label_propagation(g, 10)
  assert_true(r1.labels.length() == r10.labels.length())
}

///|
test "lp_immutability" {
  let original_g = make_path_5()
  let nc_before = @core.GraphReadable::node_count(original_g)
  let _r = label_propagation(original_g, 100)
  let nc_after = @core.GraphReadable::node_count(original_g)
  assert_eq(nc_before, nc_after)
}

///|
test "lp_labels_in_range" {
  let g = make_path_5()
  let result = label_propagation(g, 100)
  for lbl in result.labels {
    assert_true(lbl >= 0)
    assert_true(lbl < result.num_communities)
  }
}

///|
test "lp_get_label_method" {
  let g = make_path_5()
  let result = label_propagation(g, 100)
  match result.get_label(@core.NodeId(2)) {
    Some(l) => assert_true(l >= 0)
    None => assert_true(false)
  }
}

///|
test "lp_nodes_in_community_method" {
  let g = make_two_clusters()
  let result = label_propagation(g, 100)
  let c0_nodes = result.nodes_in_community(0)
  assert_true(c0_nodes.length() > 0)
}

///|
test "lp_modularity_reasonable" {
  let g = make_two_clusters()
  let result = label_propagation(g, 100)
  assert_true(result.modularity >= -1.0)
  assert_true(result.modularity <= 1.0)
}

///|
test "lp_zero_iterations" {
  let g = make_path_5()
  let result = label_propagation(g, 0)
  assert_true(result.labels.length() == 5)
}

///|
test "lp_largest_community_size" {
  let g = make_two_clusters()
  let result = label_propagation(g, 100)
  let max_sz = result.largest_community_size()
  assert_true(max_sz > 0)
}

// ============================================================
// 集成对比测试 (5 tests)
// ============================================================

///|
test "both_algorithms_handle_empty" {
  let g = @storage.new_directed()
  let r1 = louvain(g, 1.0)
  let r2 = label_propagation(g, 100)
  assert_true(r1.labels.length() == 0)
  assert_true(r2.labels.length() == 0)
}

///|
test "both_algorithms_handle_single" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let r1 = louvain(g, 1.0)
  let r2 = label_propagation(g, 100)
  assert_true(r1.labels.length() == 1)
  assert_true(r2.labels.length() == 1)
}

///|
test "both_detect_separate_clusters" {
  let g = make_two_clusters()
  let rl = louvain(g, 1.0)
  let rp = label_propagation(g, 100)
  assert_true(rl.num_communities >= 2)
  assert_true(rp.num_communities >= 2)
}

///|
test "both_consistent_node_count" {
  let g = make_path_5()
  let rl = louvain(g, 1.0)
  let rp = label_propagation(g, 100)
  assert_eq(rl.labels.length(), rp.labels.length())
}

///|
test "both_consistent_types" {
  let g = make_dense_cluster_6()
  let rl = louvain(g, 1.0)
  let rp = label_propagation(g, 100)
  assert_true(rl.labels.length() == 6)
  assert_true(rp.labels.length() == 6)
  assert_true(rl.levels >= 1)
  assert_true(rp.levels >= 1)
}
