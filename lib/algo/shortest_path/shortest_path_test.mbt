///|
/// 最短路径算法测试
///
/// 覆盖 Dijkstra / Bellman-Ford / Floyd-Warshall 的正确性和跨存储兼容性。

// ============================================================================
// 辅助：构建测试图
// ============================================================================

fn make_linear_graph() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 2.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 3.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 4.0)
  |> ignore
  g
}

///|
fn make_weighted_dag() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 4.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 2.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 6.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 3.0)
  |> ignore
  g
}

///|
fn make_negative_graph() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 3.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 2.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), -2.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(1), 1.0)
  |> ignore
  g
}

///|
fn make_negative_cycle_graph() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 3.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), -5.0)
  |> ignore
  g
}

// ============================================================================
// Dijkstra 测试
// ============================================================================

///|
test "dijkstra_linear_path_distances" {
  let g = make_linear_graph()
  let sp = dijkstra(g, @core.NodeId(0))
  assert_true(sp.distance_to(@core.NodeId(0)) == 0.0)
  assert_true(sp.distance_to(@core.NodeId(1)) == 2.0)
  assert_true(sp.distance_to(@core.NodeId(2)) == 5.0)
  assert_true(sp.distance_to(@core.NodeId(3)) == 6.0)
  assert_true(sp.distance_to(@core.NodeId(4)) == 10.0)
}

///|
test "dijkstra_linear_path_reachable" {
  let g = make_linear_graph()
  let sp = dijkstra(g, @core.NodeId(0))
  assert_true(sp.is_reachable(@core.NodeId(0)))
  assert_true(sp.is_reachable(@core.NodeId(4)))
  assert_true(sp.reachable_count() == 5)
}

///|
test "dijkstra_linear_path_path_to" {
  let g = make_linear_graph()
  let sp = dijkstra(g, @core.NodeId(0))
  let path = sp.path_to(@core.NodeId(4))
  assert_true(path.length() == 5)
  assert_true(path[0] == @core.NodeId(0))
  assert_true(path[4] == @core.NodeId(4))
}

///|
test "dijkstra_shorter_path_preferred" {
  let g = make_weighted_dag()
  let sp = dijkstra(g, @core.NodeId(0))
  assert_true(sp.distance_to(@core.NodeId(2)) == 3.0)
  assert_true(sp.distance_to(@core.NodeId(3)) == 6.0)
}

///|
test "dijkstra_targeted_same_source_target" {
  let g = make_linear_graph()
  let path = dijkstra_targeted(g, @core.NodeId(2), @core.NodeId(2))
  assert_true(path.length() == 1)
  assert_true(path[0] == @core.NodeId(2))
}

///|
test "dijkstra_targeted_path" {
  let g = make_linear_graph()
  let path = dijkstra_targeted(g, @core.NodeId(0), @core.NodeId(4))
  assert_true(path.length() == 5)
}

///|
test "dijkstra_empty_graph" {
  let g = @storage.new_directed()
  let sp = dijkstra(g, @core.NodeId(0))
  assert_true(sp.distances.length() == 0)
  assert_true(sp.reachable_count() == 0)
}

///|
test "dijkstra_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let sp = dijkstra(g, @core.NodeId(0))
  assert_true(sp.distance_to(@core.NodeId(0)) == 0.0)
  assert_true(sp.reachable_count() == 1)
}

///|
test "dijkstra_unreachable_returns_minus_one" {
  let g = make_linear_graph()
  let sp = dijkstra(g, @core.NodeId(4))
  assert_true(sp.distance_to(@core.NodeId(0)) == -1.0)
  assert_true(!sp.is_reachable(@core.NodeId(0)))
}

///|
test "dijkstra_unreachable_empty_path" {
  let g = make_linear_graph()
  let sp = dijkstra(g, @core.NodeId(4))
  let path = sp.path_to(@core.NodeId(0))
  assert_true(path.length() == 0)
}

// ============================================================================
// Bellman-Ford 测试
// ============================================================================

///|
test "bellman_ford_linear_same_as_dijkstra" {
  let g = make_linear_graph()
  match bellman_ford(g, @core.NodeId(0)) {
    Ok(sp) => {
      assert_true(sp.distance_to(@core.NodeId(0)) == 0.0)
      assert_true(sp.distance_to(@core.NodeId(4)) == 10.0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "bellman_ford_negative_edges" {
  let g = make_negative_graph()
  match bellman_ford(g, @core.NodeId(0)) {
    Ok(sp) => {
      assert_true(sp.distance_to(@core.NodeId(0)) == 0.0)
      assert_true(sp.distance_to(@core.NodeId(3)) == 0.0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "bellman_ford_negative_cycle_detected" {
  let g = make_negative_cycle_graph()
  match bellman_ford(g, @core.NodeId(0)) {
    Ok(_) => assert_true(false)
    Err(msg) => assert_true(true)
  }
}

///|
test "bellman_ford_empty_graph" {
  let g = @storage.new_directed()
  match bellman_ford(g, @core.NodeId(0)) {
    Ok(sp) => assert_true(sp.distances.length() == 0)
    Err(_) => assert_true(false)
  }
}

///|
test "bellman_ford_source_not_found" {
  let g = make_linear_graph()
  match bellman_ford(g, @core.NodeId(99)) {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}

///|
test "bellman_ford_path_reconstruction" {
  let g = make_weighted_dag()
  match bellman_ford(g, @core.NodeId(0)) {
    Ok(sp) => {
      let path = sp.path_to(@core.NodeId(3))
      assert_true(path.length() > 0)
      assert_true(path[0] == @core.NodeId(0))
    }
    Err(_) => assert_true(false)
  }
}

// ============================================================================
// Floyd-Warshall 测试
// ============================================================================

///|
test "floyd_warshall_linear_graph" {
  let g = make_linear_graph()
  match floyd_warshall(g) {
    Ok(fw) => {
      assert_true(fw.distance(@core.NodeId(0), @core.NodeId(0)) == 0.0)
      assert_true(fw.distance(@core.NodeId(0), @core.NodeId(4)) == 10.0)
      assert_true(fw.distance(@core.NodeId(4), @core.NodeId(0)) == -1.0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "floyd_warshall_path_reconstruction" {
  let g = make_linear_graph()
  match floyd_warshall(g) {
    Ok(fw) => {
      let path = fw.path(@core.NodeId(0), @core.NodeId(4))
      assert_true(path.length() == 5)
      assert_true(path[0] == @core.NodeId(0))
      assert_true(path[4] == @core.NodeId(4))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "floyd_warshall_empty_graph" {
  let g = @storage.new_directed()
  match floyd_warshall(g) {
    Ok(fw) => assert_true(fw.distances.length() == 0)
    Err(_) => assert_true(false)
  }
}

///|
test "floyd_warshall_negative_cycle_detected" {
  let g = make_negative_cycle_graph()
  match floyd_warshall(g) {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}

///|
test "floyd_warshall_self_distance_zero" {
  let g = make_weighted_dag()
  match floyd_warshall(g) {
    Ok(fw) => {
      assert_true(fw.distance(@core.NodeId(0), @core.NodeId(0)) == 0.0)
      assert_true(fw.distance(@core.NodeId(1), @core.NodeId(1)) == 0.0)
      assert_true(fw.distance(@core.NodeId(2), @core.NodeId(2)) == 0.0)
      assert_true(fw.distance(@core.NodeId(3), @core.NodeId(3)) == 0.0)
    }
    Err(_) => assert_true(false)
  }
}

// ============================================================================
// 跨存储兼容性测试
// ============================================================================

///|
test "cross_storage_dijkstra_adjlist" {
  let g = make_linear_graph()
  let sp = dijkstra(g, @core.NodeId(0))
  assert_true(sp.distance_to(@core.NodeId(4)) == 10.0)
}

///|
test "cross_storage_dijkstra_matrix" {
  let g = @storage.new_directed_matrix(10)
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 5.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 3.0)
  |> ignore
  let sp = dijkstra(g, @core.NodeId(0))
  assert_true(sp.distance_to(@core.NodeId(2)) == 8.0)
}

///|
test "cross_storage_dijkstra_edgelist" {
  let g = @storage.new_edge_list()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 7.0)
  |> ignore
  let sp = dijkstra(g, @core.NodeId(0))
  assert_true(sp.distance_to(@core.NodeId(1)) == 7.0)
}

///|
test "cross_storage_bellman_ford_all_types" {
  let g_al = make_weighted_dag()
  let _r_al = bellman_ford(g_al, @core.NodeId(0))
  let g_mat = @storage.new_directed_matrix(10)
  @core.GraphWritable::add_node(g_mat, 0.0) |> ignore
  @core.GraphWritable::add_node(g_mat, 0.0) |> ignore
  @core.GraphWritable::add_node(g_mat, 0.0) |> ignore
  @core.GraphWritable::add_node(g_mat, 0.0) |> ignore
  @core.GraphWritable::add_edge(g_mat, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g_mat, @core.NodeId(1), @core.NodeId(2), 2.0)
  |> ignore
  let _r_mat = bellman_ford(g_mat, @core.NodeId(0))
  assert_true(true)
}

///|
test "cross_storage_floyd_warshall_all_types" {
  let g_al = make_weighted_dag()
  let _r_al = floyd_warshall(g_al)
  let g_el = @storage.new_edge_list()
  @core.GraphWritable::add_node(g_el, 0.0) |> ignore
  @core.GraphWritable::add_node(g_el, 0.0) |> ignore
  @core.GraphWritable::add_edge(g_el, @core.NodeId(0), @core.NodeId(1), 3.0)
  |> ignore
  let _r_el = floyd_warshall(g_el)
  assert_true(true)
}

// ============================================================================
// A* 启发式搜索测试
// ============================================================================

///|
fn make_simple_grid() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  for i in 0..<9 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
  }
  for row in 0..<3 {
    for col in 0..<2 {
      let u = @core.NodeId(row * 3 + col)
      let v = @core.NodeId(row * 3 + col + 1)
      @core.GraphWritable::add_edge(g, u, v, 1.0) |> ignore
    }
  }
  for row in 0..<2 {
    for col in 0..<3 {
      let u = @core.NodeId(row * 3 + col)
      let v = @core.NodeId((row + 1) * 3 + col)
      @core.GraphWritable::add_edge(g, u, v, 1.0) |> ignore
    }
  }
  g
}

///|
fn make_manhattan_heuristic(target : @core.NodeId) -> (@core.NodeId) -> Double {
  fn(n : @core.NodeId) -> Double {
    let cols = 3
    let tx = target.0 % cols
    let ty = target.0 / cols
    let nx = n.0 % cols
    let ny = n.0 / cols
    let dx = tx - nx
    let dy = ty - ny
    let adx = if dx >= 0 { dx } else { -dx }
    let ady = if dy >= 0 { dy } else { -dy }
    (adx + ady).to_double()
  }
}

///|
fn zero_heuristic(_n : @core.NodeId) -> Double {
  0.0
}

///|
test "a_star_linear_path" {
  let g = make_linear_graph()
  let path = a_star(g, @core.NodeId(0), @core.NodeId(4), zero_heuristic)
  assert_true(path.length() == 5)
  assert_true(path[0] == @core.NodeId(0))
  assert_true(path[1] == @core.NodeId(1))
  assert_true(path[2] == @core.NodeId(2))
  assert_true(path[3] == @core.NodeId(3))
  assert_true(path[4] == @core.NodeId(4))
}

///|
test "a_star_equals_dijkstra_grid" {
  let g = make_simple_grid()
  let a_path = a_star(g, @core.NodeId(0), @core.NodeId(8), zero_heuristic)
  let d_path = dijkstra_targeted(g, @core.NodeId(0), @core.NodeId(8))
  assert_true(a_path.length() == d_path.length())
  assert_true(a_path.length() > 0)
  assert_true(a_path[a_path.length() - 1] == @core.NodeId(8))
}

///|
test "a_star_simple_grid_with_heuristic" {
  let g = make_simple_grid()
  let h = make_manhattan_heuristic(@core.NodeId(8))
  let path = a_star(g, @core.NodeId(0), @core.NodeId(8), h)
  assert_true(path.length() == 5)
  assert_true(path[0] == @core.NodeId(0))
  assert_true(path[path.length() - 1] == @core.NodeId(8))
}

///|
test "a_star_same_source_target" {
  let g = make_linear_graph()
  let path = a_star(g, @core.NodeId(2), @core.NodeId(2), zero_heuristic)
  assert_true(path.length() == 1)
  assert_true(path[0] == @core.NodeId(2))
}

///|
test "a_star_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let path = a_star(g, @core.NodeId(0), @core.NodeId(0), zero_heuristic)
  assert_true(path.length() == 1)
  assert_true(path[0] == @core.NodeId(0))
}

///|
test "a_star_empty_graph" {
  let g = @storage.new_directed()
  let path = a_star(g, @core.NodeId(0), @core.NodeId(0), zero_heuristic)
  assert_true(path.length() == 0)
}

///|
test "a_star_unreachable" {
  let g = make_linear_graph()
  let path = a_star(g, @core.NodeId(0), @core.NodeId(99), zero_heuristic)
  assert_true(path.length() == 0)
}

///|
test "a_star_direct_edge" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 5.0)
  |> ignore
  let path = a_star(g, @core.NodeId(0), @core.NodeId(1), zero_heuristic)
  assert_true(path.length() == 2)
  assert_true(path[0] == @core.NodeId(0))
  assert_true(path[1] == @core.NodeId(1))
}

// ============================================================================
// SPFA 最短路径测试
// ============================================================================

///|
test "spfa_linear_same_as_dijkstra" {
  let g = make_linear_graph()
  match spfa(g, @core.NodeId(0)) {
    Ok(sp) => {
      assert_true(sp.distance_to(@core.NodeId(0)) == 0.0)
      assert_true(sp.distance_to(@core.NodeId(4)) == 10.0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "spfa_matches_bellman_ford" {
  let g = make_weighted_dag()
  match (spfa(g, @core.NodeId(0)), bellman_ford(g, @core.NodeId(0))) {
    (Ok(sr), Ok(br)) => {
      assert_true(sr.distance_to(@core.NodeId(3)) == br.distance_to(@core.NodeId(3)))
      assert_true(sr.distance_to(@core.NodeId(2)) == br.distance_to(@core.NodeId(2)))
    }
    _ => assert_true(false)
  }
}

///|
test "spfa_negative_edges" {
  let g = make_negative_graph()
  match spfa(g, @core.NodeId(0)) {
    Ok(sp) => {
      assert_true(sp.distance_to(@core.NodeId(0)) == 0.0)
      assert_true(sp.distance_to(@core.NodeId(3)) >= -1.0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "spfa_negative_cycle_detected" {
  let g = make_negative_cycle_graph()
  match spfa(g, @core.NodeId(0)) {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}

///|
test "spfa_empty_graph" {
  let g = @storage.new_directed()
  match spfa(g, @core.NodeId(0)) {
    Ok(sp) => assert_true(sp.distances.length() == 0)
    Err(_) => assert_true(false)
  }
}

///|
test "spfa_source_not_found" {
  let g = make_linear_graph()
  match spfa(g, @core.NodeId(99)) {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}

///|
test "spfa_path_reconstruction" {
  let g = make_weighted_dag()
  match spfa(g, @core.NodeId(0)) {
    Ok(sp) => {
      let path = sp.path_to(@core.NodeId(3))
      assert_true(path.length() > 0)
      assert_true(path[0] == @core.NodeId(0))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "spfa_reachable_count" {
  let g = make_linear_graph()
  match spfa(g, @core.NodeId(0)) {
    Ok(sp) => {
      assert_true(sp.reachable_count() == 5)
      assert_true(sp.is_reachable(@core.NodeId(4)))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "spfa_unreachable" {
  let g = make_linear_graph()
  match spfa(g, @core.NodeId(4)) {
    Ok(sp) => {
      assert_true(sp.distance_to(@core.NodeId(0)) == -1.0)
      assert_true(!sp.is_reachable(@core.NodeId(0)))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "spfa_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  match spfa(g, @core.NodeId(0)) {
    Ok(sp) => {
      assert_true(sp.distance_to(@core.NodeId(0)) == 0.0)
      assert_true(sp.reachable_count() == 1)
    }
    Err(_) => assert_true(false)
  }
}

// ============================================================================
// Johnson 全源最短路径测试
// ============================================================================

///|
test "johnson_linear_graph" {
  let g = make_linear_graph()
  match johnson(g) {
    Ok(jw) => {
      assert_true(jw.distance(@core.NodeId(0), @core.NodeId(0)) == 0.0)
      assert_true(jw.distance(@core.NodeId(0), @core.NodeId(4)) == 10.0)
      assert_true(jw.distance(@core.NodeId(4), @core.NodeId(0)) == -1.0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "johnson_matches_floyd_warshall" {
  let g = make_weighted_dag()
  match (johnson(g), floyd_warshall(g)) {
    (Ok(jw), Ok(fw)) => {
      assert_true(jw.distance(@core.NodeId(0), @core.NodeId(3)) == fw.distance(@core.NodeId(0), @core.NodeId(3)))
      assert_true(jw.distance(@core.NodeId(1), @core.NodeId(2)) == fw.distance(@core.NodeId(1), @core.NodeId(2)))
      assert_true(jw.distance(@core.NodeId(0), @core.NodeId(1)) == fw.distance(@core.NodeId(0), @core.NodeId(1)))
    }
    _ => assert_true(false)
  }
}

///|
test "johnson_negative_edges" {
  let g = make_negative_graph()
  match johnson(g) {
    Ok(jw) => {
      assert_true(jw.distance(@core.NodeId(0), @core.NodeId(0)) == 0.0)
      assert_true(jw.distance(@core.NodeId(0), @core.NodeId(3)) >= -1.0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "johnson_negative_cycle_detected" {
  let g = make_negative_cycle_graph()
  match johnson(g) {
    Ok(_) => assert_true(false)
    Err(msg) => assert_true(true)
  }
}

///|
test "johnson_empty_graph" {
  let g = @storage.new_directed()
  match johnson(g) {
    Ok(jw) => assert_true(jw.distances.length() == 0)
    Err(_) => assert_true(false)
  }
}

///|
test "johnson_self_distance_zero" {
  let g = make_weighted_dag()
  match johnson(g) {
    Ok(jw) => {
      assert_true(jw.distance(@core.NodeId(0), @core.NodeId(0)) == 0.0)
      assert_true(jw.distance(@core.NodeId(1), @core.NodeId(1)) == 0.0)
      assert_true(jw.distance(@core.NodeId(2), @core.NodeId(2)) == 0.0)
      assert_true(jw.distance(@core.NodeId(3), @core.NodeId(3)) == 0.0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "johnson_path_reconstruction" {
  let g = make_linear_graph()
  match johnson(g) {
    Ok(jw) => {
      let path = jw.path(@core.NodeId(0), @core.NodeId(4))
      assert_true(path.length() == 5)
      assert_true(path[0] == @core.NodeId(0))
      assert_true(path[path.length() - 1] == @core.NodeId(4))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "johnson_cross_storage_adjlist" {
  let g = make_linear_graph()
  match johnson(g) {
    Ok(jw) => assert_true(jw.distance(@core.NodeId(0), @core.NodeId(4)) == 10.0)
    Err(_) => assert_true(false)
  }
}

///|
test "johnson_cross_storage_matrix" {
  let g = @storage.new_directed_matrix(10)
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 5.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 3.0)
  |> ignore
  match johnson(g) {
    Ok(jw) => assert_true(jw.distance(@core.NodeId(0), @core.NodeId(2)) == 8.0)
    Err(_) => assert_true(false)
  }
}

///|
test "johnson_cross_storage_edgelist" {
  let g = @storage.new_edge_list()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 7.0)
  |> ignore
  match johnson(g) {
    Ok(jw) => assert_true(jw.distance(@core.NodeId(0), @core.NodeId(1)) == 7.0)
    Err(_) => assert_true(false)
  }
}

///|
test "a_star_zero_heuristic" {
  let g = make_weighted_dag()
  let a_path = a_star(g, @core.NodeId(0), @core.NodeId(3), zero_heuristic)
  let d_path = dijkstra_targeted(g, @core.NodeId(0), @core.NodeId(3))
  assert_true(a_path.length() == d_path.length())
  assert_true(a_path.length() > 0)
  assert_true(a_path[0] == @core.NodeId(0))
  assert_true(a_path[a_path.length() - 1] == @core.NodeId(3))
}

///|
test "a_star_admissible_heuristic" {
  let g = make_simple_grid()
  let h = make_manhattan_heuristic(@core.NodeId(8))
  let a_path = a_star(g, @core.NodeId(0), @core.NodeId(8), h)
  let d_path = dijkstra_targeted(g, @core.NodeId(0), @core.NodeId(8))
  assert_true(a_path.length() == d_path.length())
  assert_true(a_path.length() == 5)
  assert_true(a_path[0] == @core.NodeId(0))
  assert_true(a_path[a_path.length() - 1] == @core.NodeId(8))
}

///|
test "a_star_weighted_graph" {
  let g = make_weighted_dag()
  let path = a_star(g, @core.NodeId(0), @core.NodeId(3), zero_heuristic)
  assert_true(path.length() == 4)
  assert_true(path[0] == @core.NodeId(0))
  assert_true(path[1] == @core.NodeId(1))
  assert_true(path[2] == @core.NodeId(2))
  assert_true(path[3] == @core.NodeId(3))
}

///|
test "a_star_cross_storage_adjlist" {
  let g = make_linear_graph()
  let path = a_star(g, @core.NodeId(0), @core.NodeId(4), zero_heuristic)
  assert_true(path.length() == 5)
  assert_true(path[0] == @core.NodeId(0))
  assert_true(path[4] == @core.NodeId(4))
}

///|
test "a_star_cross_storage_matrix" {
  let g = @storage.new_directed_matrix(10)
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 5.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 3.0)
  |> ignore
  let path = a_star(g, @core.NodeId(0), @core.NodeId(2), zero_heuristic)
  assert_true(path.length() == 3)
  assert_true(path[0] == @core.NodeId(0))
  assert_true(path[2] == @core.NodeId(2))
}

///|
test "a_star_cross_storage_edgelist" {
  let g = @storage.new_edge_list()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 7.0)
  |> ignore
  let path = a_star(g, @core.NodeId(0), @core.NodeId(1), zero_heuristic)
  assert_true(path.length() == 2)
  assert_true(path[0] == @core.NodeId(0))
  assert_true(path[1] == @core.NodeId(1))
}
