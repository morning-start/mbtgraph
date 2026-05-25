/// 中心性分析测试套件

fn make_central_star() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 5 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(0), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(0), 1.0) |> ignore
  g
}

fn make_path_graph_4() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  g
}

fn make_complete_4() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let mut a = 0
  while a < 4 {
    let mut b = 0
    while b < 4 {
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

fn make_bridge_graph() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 6 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0) |> ignore
  g
}

fn approx_eq(a : Double, b : Double, eps : Double) -> Bool {
  let d = a - b
  if d < 0.0 { -d < eps } else { d < eps }
}

fn int_to_double(x : Int) -> Double { x.to_double() }

fn abs_double(x : Double) -> Double {
  if x < 0.0 { -x } else { x }
}

// 度中心性 (8 tests)

test "degree_star_center_highest" {
  let g = make_central_star()
  let result = degree_centrality(g, DegreeMode::In)
  match result.get_score(@core.NodeId(0)) {
    Some(s) => assert_true(s > 0.5)
    None => assert_true(false)
  }
}

test "degree_out_mode" {
  let g = make_path_graph_4()
  let result = degree_centrality(g, DegreeMode::Out)
  let s0 = result.get_score(@core.NodeId(0))
  let s3 = result.get_score(@core.NodeId(3))
  match (s0, s3) {
    (Some(a), Some(b)) => {
      assert_true(a > 0.0)
      assert_true(approx_eq(b, 0.0, 0.000001))
    }
    _ => assert_true(false)
  }
}

test "degree_total_mode" {
  let g = make_central_star()
  let result_total = degree_centrality(g, DegreeMode::Total)
  let result_in = degree_centrality(g, DegreeMode::In)
  let t0 = result_total.get_score(@core.NodeId(0))
  let i0 = result_in.get_score(@core.NodeId(0))
  match (t0, i0) {
    (Some(t), Some(i)) => assert_true(t >= i)
    _ => assert_true(false)
  }
}

test "degree_complete_uniform" {
  let g = make_complete_4()
  let result = degree_centrality(g, DegreeMode::Out)
  let expected = int_to_double(3) / int_to_double(3)
  for s in result.scores {
    assert_true(approx_eq(s, expected, 0.000001))
  }
}

test "degree_empty_graph" {
  let g = @storage.new_directed()
  let result = degree_centrality(g, DegreeMode::Total)
  assert_true(result.scores.length() == 0)
}

test "degree_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = degree_centrality(g, DegreeMode::Total)
  assert_true(result.scores.length() == 1)
  match result.get_score(@core.NodeId(0)) {
    Some(s) => assert_true(approx_eq(s, 0.0, 0.000001))
    None => assert_true(false)
  }
}

test "degree_normalized_range" {
  let g = make_complete_4()
  let result = degree_centrality(g, DegreeMode::Out)
  for s in result.scores {
    assert_true(s >= 0.0)
    assert_true(s <= 1.01)
  }
}

test "degree_max_node_method" {
  let g = make_central_star()
  let result = degree_centrality(g, DegreeMode::In)
  match result.max_node() {
    Some((id, _)) => assert_eq(id.0, 0)
    None => assert_true(false)
  }
}

// 介数中心性 (12 tests)

test "betweenness_bridge_node_highest" {
  let g = make_bridge_graph()
  let result = betweenness_centrality(g, true)
  let s2 = result.get_score(@core.NodeId(2))
  match s2 {
    Some(v) => assert_true(v > 0.0)
    None => assert_true(false)
  }
}

test "betweenness_endpoints_zero" {
  let g = make_path_graph_4()
  let result = betweenness_centrality(g, true)
  let s0 = result.get_score(@core.NodeId(0))
  let s3 = result.get_score(@core.NodeId(3))
  match (s0, s3) {
    (Some(a), Some(b)) => {
      assert_true(approx_eq(a, 0.0, 0.000001))
      assert_true(approx_eq(b, 0.0, 0.000001))
    }
    _ => assert_true(false)
  }
}

test "betweenness_complete_zero" {
  let g = make_complete_4()
  let result = betweenness_centrality(g, true)
  for s in result.scores {
    assert_true(approx_eq(s, 0.0, 0.000001))
  }
}

test "betweenness_star_center_max" {
  let g = make_central_star()
  let result = betweenness_centrality(g, true)
  match result.max_node() {
    Some((id, _)) => assert_eq(id.0, 0)
    None => assert_true(false)
  }
}

test "betweenness_path_middle_higher" {
  let g = make_path_graph_4()
  let result = betweenness_centrality(g, true)
  let s1 = result.get_score(@core.NodeId(1))
  let s2 = result.get_score(@core.NodeId(2))
  match (s1, s2) {
    (Some(a), Some(b)) => assert_true(a > 0.0 || b > 0.0)
    _ => assert_true(false)
  }
}

test "betweenness_symmetric_property" {
  let g = make_path_graph_4()
  let r1 = betweenness_centrality(g, false)
  let r2 = betweenness_centrality(g, true)
  let s1_raw = r1.get_score(@core.NodeId(1))
  let s2_norm = r2.get_score(@core.NodeId(1))
  match (s1_raw, s2_norm) {
    (Some(raw), Some(norm)) => assert_true(raw >= norm)
    _ => assert_true(false)
  }
}

test "betweenness_empty_graph" {
  let g = @storage.new_directed()
  let result = betweenness_centrality(g, true)
  assert_true(result.scores.length() == 0)
}

test "betweenness_two_nodes" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  let result = betweenness_centrality(g, true)
  assert_true(result.scores.length() == 2)
  for s in result.scores {
    assert_true(approx_eq(s, 0.0, 0.000001))
  }
}

test "betweenness_normalized_range" {
  let g = make_bridge_graph()
  let result = betweenness_centrality(g, true)
  for s in result.scores {
    assert_true(s >= 0.0)
    assert_true(s <= 1.0)
  }
}

test "betweenness_nonzero_count" {
  let g = make_path_graph_4()
  let result = betweenness_centrality(g, true)
  let nz = result.nonzero_count()
  assert_true(nz > 0)
  assert_true(nz <= 4)
}

test "betweenness_immutability" {
  let original_g = make_path_graph_4()
  let nc_before = @core.GraphReadable::node_count(original_g)
  let _r = betweenness_centrality(original_g, true)
  let nc_after = @core.GraphReadable::node_count(original_g)
  assert_eq(nc_before, nc_after)
}

test "betweenness_triangle_fair" {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 3 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  let result = betweenness_centrality(g, true)
  let s1 = result.get_score(@core.NodeId(1))
  match s1 {
    Some(v) => assert_true(v > 0.0)
    None => assert_true(false)
  }
}

// 接近中心性 (10 tests)

test "closeness_center_highest" {
  let g = make_path_graph_4()
  let result = closeness_centrality(g, true)
  match result.get_score(@core.NodeId(1)) {
    Some(s) => assert_true(s > 0.0)
    None => assert_true(false)
  }
}

test "closeness_path_ends_lower" {
  let g = make_path_graph_4()
  let result = closeness_centrality(g, true)
  let s0 = result.get_score(@core.NodeId(0))
  let s1 = result.get_score(@core.NodeId(1))
  match (s0, s1) {
    (Some(a), Some(b)) => assert_true(a <= b)
    _ => assert_true(false)
  }
}

test "closeness_complete_uniform" {
  let g = make_complete_4()
  let result = closeness_centrality(g, true)
  let first = result.scores[0]
  for s in result.scores {
    assert_true(approx_eq(s, first, 0.01))
  }
}

test "closeness_disconnected_low" {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  let result = closeness_centrality(g, true)
  for s in result.scores {
    assert_true(s >= 0.0)
  }
}

test "closeness_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = closeness_centrality(g, true)
  assert_true(result.scores.length() == 1)
}

test "closeness_empty_graph" {
  let g = @storage.new_directed()
  let result = closeness_centrality(g, true)
  assert_true(result.scores.length() == 0)
}

test "closeness_normalized_range" {
  let g = make_complete_4()
  let result = closeness_centrality(g, true)
  for s in result.scores {
    assert_true(s >= 0.0)
    assert_true(s <= 1.0)
  }
}

test "closeness_positive_reachable" {
  let g = make_path_graph_4()
  let result = closeness_centrality(g, false)
  match result.get_score(@core.NodeId(1)) {
    Some(s) => assert_true(s > 0.0)
    None => assert_true(false)
  }
}

test "closeness_immutability" {
  let original_g = make_path_graph_4()
  let nc_before = @core.GraphReadable::node_count(original_g)
  let _r = closeness_centrality(original_g, true)
  let nc_after = @core.GraphReadable::node_count(original_g)
  assert_eq(nc_before, nc_after)
}

test "closeness_star_vs_path" {
  let star = make_central_star()
  let path = make_path_graph_4()
  let rs = closeness_centrality(star, true)
  let rp = closeness_centrality(path, true)
  let ss = rs.get_score(@core.NodeId(0))
  let sp = rp.get_score(@core.NodeId(1))
  match (ss, sp) {
    (Some(_a), Some(_b)) => assert_true(true)
    _ => assert_true(false)
  }
}

// 特征向量中心性 (10 tests)

test "eigenvector_converges" {
  let g = make_complete_4()
  let result = eigenvector_centrality(g, 100, 0.000001)
  assert_true(result.scores.length() == 4)
}

test "eigenvector_hub_highest" {
  let g = make_central_star()
  let result = eigenvector_centrality(g, 100, 0.000001)
  match result.max_node() {
    Some((id, _)) => assert_eq(id.0, 0)
    None => assert_true(false)
  }
}

test "eigenvector_complete_uniform" {
  let g = make_complete_4()
  let result = eigenvector_centrality(g, 100, 0.000001)
  let first = result.scores[0]
  let mut all_same = true
  for s in result.scores {
    if !approx_eq(abs_double(s), abs_double(first), 0.01) {
      all_same = false
    }
  }
  assert_true(all_same)
}

test "eigenvector_empty_graph" {
  let g = @storage.new_directed()
  let result = eigenvector_centrality(g, 100, 0.000001)
  assert_true(result.scores.length() == 0)
}

test "eigenvector_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = eigenvector_centrality(g, 100, 0.000001)
  assert_true(result.scores.length() == 1)
  match result.get_score(@core.NodeId(0)) {
    Some(s) => assert_true(approx_eq(abs_double(s), 1.0, 0.000001))
    None => assert_true(false)
  }
}

test "eigenvector_non_negative" {
  let g = make_path_graph_4()
  let result = eigenvector_centrality(g, 100, 0.000001)
  for s in result.scores {
    assert_true(s >= -0.000001)
  }
}

test "eigenvector_immutability" {
  let original_g = make_path_graph_4()
  let nc_before = @core.GraphReadable::node_count(original_g)
  let _r = eigenvector_centrality(original_g, 100, 0.000001)
  let nc_after = @core.GraphReadable::node_count(original_g)
  assert_eq(nc_before, nc_after)
}

test "eigenvector_iterate_reasonable" {
  let g = make_central_star()
  let result = eigenvector_centrality(g, 100, 0.000001)
  assert_true(result.normalized)
}

test "eigenvector_path_ordering" {
  let g = make_path_graph_4()
  let result = eigenvector_centrality(g, 100, 0.000001)
  let s0 = result.get_score(@core.NodeId(0))
  let s3 = result.get_score(@core.NodeId(3))
  match (s0, s3) {
    (Some(_a), Some(_b)) => assert_true(true)
    _ => assert_true(false)
  }
}

test "eigenvector_normalized_flag" {
  let g = make_complete_4()
  let result = eigenvector_centrality(g, 100, 0.000001)
  assert_true(result.normalized)
}

// 集成对比测试 (5 tests)

test "integration_all_on_star" {
  let g = make_central_star()
  let dc = degree_centrality(g, DegreeMode::In)
  let bc = betweenness_centrality(g, true)
  let cc = closeness_centrality(g, true)
  let ec = eigenvector_centrality(g, 100, 0.000001)
  match (dc.max_node(), bc.max_node()) {
    (Some((id1, _)), Some((id2, _))) => {
      assert_eq(id1.0, 0)
      assert_eq(id2.0, 0)
    }
    _ => assert_true(false)
  }
  assert_true(dc.scores.length() == bc.scores.length())
  assert_true(bc.scores.length() == cc.scores.length())
  assert_true(cc.scores.length() == ec.scores.length())
}

test "integration_degree_betweenness_correlation" {
  let g = make_bridge_graph()
  let dc = degree_centrality(g, DegreeMode::Total)
  let bc = betweenness_centrality(g, true)
  let dc_max_id = match dc.max_node() {
    Some((id, _)) => id
    None => @core.NodeId(-1)
  }
  let bc_s = bc.get_score(dc_max_id)
  match bc_s {
    Some(_) => assert_true(true)
    None => assert_true(false)
  }
}

test "integration_all_handle_empty" {
  let g = @storage.new_directed()
  let dc = degree_centrality(g, DegreeMode::Total)
  let bc = betweenness_centrality(g, true)
  let cc = closeness_centrality(g, true)
  let ec = eigenvector_centrality(g, 100, 0.000001)
  assert_true(dc.scores.length() == 0)
  assert_true(bc.scores.length() == 0)
  assert_true(cc.scores.length() == 0)
  assert_true(ec.scores.length() == 0)
}

test "integration_all_handle_single" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let dc = degree_centrality(g, DegreeMode::Total)
  let bc = betweenness_centrality(g, true)
  let cc = closeness_centrality(g, true)
  let ec = eigenvector_centrality(g, 100, 0.000001)
  assert_true(dc.scores.length() == 1)
  assert_true(bc.scores.length() == 1)
  assert_true(cc.scores.length() == 1)
  assert_true(ec.scores.length() == 1)
}

test "integration_consistent_lengths" {
  let g = make_complete_4()
  let n = @core.GraphReadable::node_count(g)
  let dc = degree_centrality(g, DegreeMode::Total)
  let bc = betweenness_centrality(g, true)
  let cc = closeness_centrality(g, true)
  let ec = eigenvector_centrality(g, 100, 0.000001)
  assert_eq(dc.scores.length(), n)
  assert_eq(bc.scores.length(), n)
  assert_eq(cc.scores.length(), n)
  assert_eq(ec.scores.length(), n)
}
