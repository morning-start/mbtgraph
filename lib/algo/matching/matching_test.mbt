///|
/// 图匹配算法测试

// ============================================================================
// 辅助函数：构建二分图边集
// ============================================================================

fn make_empty_bipartite() -> (Int, Int, Array[(Int, Int)]) {
  (0, 0, [])
}

///|
fn make_single_edge() -> (Int, Int, Array[(Int, Int)]) {
  let edges : Array[(Int, Int)] = [(0, 0)]
  (1, 1, edges)
}

///|
fn make_k22() -> (Int, Int, Array[(Int, Int)]) {
  let edges : Array[(Int, Int)] = [(0, 0), (0, 1), (1, 0), (1, 1)]
  (2, 2, edges)
}

///|
fn make_k33() -> (Int, Int, Array[(Int, Int)]) {
  let edges : Array[(Int, Int)] = [
    (0, 0),
    (0, 1),
    (0, 2),
    (1, 0),
    (1, 1),
    (1, 2),
    (2, 0),
    (2, 1),
    (2, 2),
  ]
  (3, 3, edges)
}

///|
fn make_path_bipartite() -> (Int, Int, Array[(Int, Int)]) {
  let edges : Array[(Int, Int)] = [(0, 0), (1, 1)]
  (2, 2, edges)
}

///|
fn make_star_bipartite() -> (Int, Int, Array[(Int, Int)]) {
  let edges : Array[(Int, Int)] = [(0, 0), (0, 1), (0, 2), (0, 3)]
  (1, 4, edges)
}

///|
fn make_asymmetric_left() -> (Int, Int, Array[(Int, Int)]) {
  let edges : Array[(Int, Int)] = [(0, 0), (1, 0), (2, 0), (3, 1)]
  (4, 2, edges)
}

///|
fn make_asymmetric_right() -> (Int, Int, Array[(Int, Int)]) {
  let edges : Array[(Int, Int)] = [(0, 0), (0, 1), (0, 2), (0, 3)]
  (1, 4, edges)
}

///|
fn make_disconnected() -> (Int, Int, Array[(Int, Int)]) {
  let edges : Array[(Int, Int)] = [(0, 0), (2, 1)]
  (4, 2, edges)
}

///|
fn make_multi_path() -> (Int, Int, Array[(Int, Int)]) {
  let edges : Array[(Int, Int)] = [
    (0, 0),
    (0, 1),
    (1, 2),
    (1, 3),
    (2, 0),
    (2, 2),
    (3, 1),
    (3, 3),
  ]
  (4, 4, edges)
}

// ============================================================================
// MatchingResult 类型基础测试
// ============================================================================

///|
test "matching_result_size" {
  let r = MatchingResult::{ matching_edges: [], cardinality: 5 }
  assert_true(r.size() == 5)
}

///|
test "matching_result_is_matched_empty" {
  let r = MatchingResult::{ matching_edges: [], cardinality: 0 }
  assert_true(!r.is_matched(@core.NodeId(0)))
}

///|
test "matching_result_is_matched_found" {
  let edges : Array[(@core.NodeId, @core.NodeId)] = [
    (@core.NodeId(0), @core.NodeId(3)),
  ]
  let r = MatchingResult::{ matching_edges: edges, cardinality: 1 }
  assert_true(r.is_matched(@core.NodeId(0)))
  assert_true(r.is_matched(@core.NodeId(3)))
}

///|
test "matching_result_get_partner_found" {
  let edges : Array[(@core.NodeId, @core.NodeId)] = [
    (@core.NodeId(0), @core.NodeId(3)),
  ]
  let r = MatchingResult::{ matching_edges: edges, cardinality: 1 }
  match r.get_partner(@core.NodeId(0)) {
    Some(p) => assert_true(p == @core.NodeId(3))
    None => assert_true(false)
  }
}

///|
test "matching_result_get_partner_not_found" {
  let r = MatchingResult::{ matching_edges: [], cardinality: 0 }
  match r.get_partner(@core.NodeId(0)) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

// ============================================================================
// 空图和边界情况
// ============================================================================

///|
test "bipartite_matching_empty_graph" {
  let result = bipartite_matching(0, 0, [])
  assert_true(result.cardinality == 0)
  assert_true(result.matching_edges.length() == 0)
}

///|
test "bipartite_matching_no_edges" {
  let result = bipartite_matching(3, 3, [])
  assert_true(result.cardinality == 0)
  assert_true(result.matching_edges.length() == 0)
}

///|
test "bipartite_matching_zero_left" {
  let edges : Array[(Int, Int)] = []
  let result = bipartite_matching(0, 5, edges)
  assert_true(result.cardinality == 0)
}

///|
test "bipartite_matching_zero_right" {
  let edges : Array[(Int, Int)] = []
  let result = bipartite_matching(5, 0, edges)
  assert_true(result.cardinality == 0)
}

// ============================================================================
// 正常场景测试
// ============================================================================

///|
test "bipartite_matching_single_edge" {
  let (n_l, n_r, edges) = make_single_edge()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality == 1)
  assert_true(result.size() == 1)
}

///|
test "bipartite_matching_k22_complete" {
  let (n_l, n_r, edges) = make_k22()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality == 2)
}

///|
test "bipartite_matching_k33_complete" {
  let (n_l, n_r, edges) = make_k33()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality == 3)
}

///|
test "bipartite_matching_path_4" {
  let (n_l, n_r, edges) = make_path_bipartite()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality == 2)
}

///|
test "bipartite_matching_star_graph" {
  let (n_l, n_r, edges) = make_star_bipartite()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality == 1)
}

// ============================================================================
// 非对称二分图
// ============================================================================

///|
test "bipartite_matching_asymmetric_left_larger" {
  let (n_l, n_r, edges) = make_asymmetric_left()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality == 2)
  assert_true(result.cardinality <= n_r)
}

///|
test "bipartite_matching_asymmetric_right_larger" {
  let (n_l, n_r, edges) = make_asymmetric_right()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality == 1)
  assert_true(result.cardinality <= n_l)
}

// ============================================================================
// 复杂场景
// ============================================================================

///|
test "bipartite_matching_disconnected_components" {
  let (n_l, n_r, edges) = make_disconnected()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality == 2)
}

///|
test "bipartite_matching_multi_path_complex" {
  let (n_l, n_r, edges) = make_multi_path()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality == 4)
}

// ============================================================================
// 属性验证测试
// ============================================================================

///|
test "property_cardinality_leq_min" {
  let (n_l, n_r, edges) = make_k33()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.cardinality <= n_l)
  assert_true(result.cardinality <= n_r)
}

///|
test "property_no_duplicate_nodes_in_matching" {
  let (n_l, n_r, edges) = make_multi_path()
  let result = bipartite_matching(n_l, n_r, edges)

  let left_seen : Array[Bool] = Array::make(n_l, false)
  let right_seen : Array[Bool] = Array::make(n_r, false)

  for edge in result.matching_edges {
    match edge {
      (u, v) => {
        assert_true(!left_seen[u.0])
        assert_true(!right_seen[v.0 - n_l])
        left_seen[u.0] = true
        right_seen[v.0 - n_l] = true
      }
    }
  }
}

///|
test "property_matching_edges_count_equals_cardinality" {
  let (n_l, n_r, edges) = make_k33()
  let result = bipartite_matching(n_l, n_r, edges)
  assert_true(result.matching_edges.length() == result.cardinality)
}

// ============================================================================
// Hopcroft-Karp 算法测试辅助函数
// ============================================================================

///|
fn make_hk_simple() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  for i in 0..<4 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0)
  |> ignore
  g
}

///|
fn make_hk_k33() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  for i in 0..<6 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  for i in 0..<3 {
    for j in 3..<6 {
      @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(j), 1.0)
      |> ignore
    }
  }
  g
}

///|
fn make_hk_multi() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  for i in 0..<8 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(6), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(7), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(6), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(7), 1.0)
  |> ignore
  g
}

///|
fn make_hk_star() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  for i in 0..<5 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0)
  |> ignore
  g
}

///|
fn make_hk_all_to_one() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  for i in 0..<4 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  g
}

// ============================================================================
// Hopcroft-Karp 基础正确性测试 (6)
// ============================================================================

///|
test "hopcroft_karp_simple_matching" {
  let g = make_hk_simple()
  let left = [@core.NodeId(0), @core.NodeId(1)]
  let right = [@core.NodeId(2), @core.NodeId(3)]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 2)
  assert_true(result.size() == 2)
}

///|
test "hopcroft_karp_complete_bipartite" {
  let g = make_hk_k33()
  let left = [@core.NodeId(0), @core.NodeId(1), @core.NodeId(2)]
  let right = [@core.NodeId(3), @core.NodeId(4), @core.NodeId(5)]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 3)
}

///|
test "hopcroft_karp_chain_graph" {
  let g = make_hk_multi()
  let left = [
    @core.NodeId(0),
    @core.NodeId(1),
    @core.NodeId(2),
    @core.NodeId(3),
  ]
  let right = [
    @core.NodeId(4),
    @core.NodeId(5),
    @core.NodeId(6),
    @core.NodeId(7),
  ]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 4)
}

// ============================================================================
// Edmonds 一般图最大匹配 — 测试辅助函数
// ============================================================================

///|
fn make_edmonds_simple() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_triangle() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<3 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_square() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<4 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_house() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<5 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // 4-cycle with one diagonal: two triangles 0-1-3 and 0-2-3, plus tail 3-4
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_butterfly() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<5 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // Two triangles sharing node 0: triangle 0-1-2 and triangle 0-3-4
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_pentagon() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<5 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // 5-cycle: 0-1-2-3-4-0
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(0), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_k4() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<4 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  for i in 0..<4 {
    let mut j = i + 1
    while j < 4 {
      @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(j), 1.0)
      |> ignore
      j = j + 1
    }
  }
  g
}

///|
fn make_edmonds_p4() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<4 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // Path: 0-1-2-3
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_star_k13() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<4 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // Center node 0, leaves 1,2,3
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_two_components() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<5 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // Component 1: path 0-1-2
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  // Component 2: edge 3-4
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_maximum_possible() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<4 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // Two disjoint edges: 0-1, 2-3 (perfect matching on 4 nodes)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_odd_path() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<3 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // Path: 0-1-2 (3 nodes, odd count)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  g
}

///|
fn make_edmonds_ugraph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  for i in 0..<6 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // A general graph with odd cycles:
  // Triangle 0-1-2 plus triangle 3-4-5, with a bridge 2-3
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0)
  |> ignore
  g
}

// ============================================================================
// Edmonds 基础正确性测试 (8)
// ============================================================================

///|
test "edmonds_simple_edge" {
  let g = make_edmonds_simple()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 1)
  assert_true(result.size() == 1)
}

///|
test "edmonds_triangle" {
  let g = make_edmonds_triangle()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 1)
}

///|
test "edmonds_square" {
  let g = make_edmonds_square()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 2)
}

///|
test "edmonds_house_graph" {
  let g = make_edmonds_house()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 2)
}

///|
test "edmonds_butterfly" {
  let g = make_edmonds_butterfly()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 2)
}

///|
test "edmonds_pentagon" {
  let g = make_edmonds_pentagon()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 2)
}

///|
test "edmonds_complete_graph_k4" {
  let g = make_edmonds_k4()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 2)
}

///|
test "edmonds_path_graph_p4" {
  let g = make_edmonds_p4()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 2)
}

// ============================================================================
// Edmonds 边界情况测试 (6)
// ============================================================================

///|
test "edmonds_empty_graph" {
  let g = @storage.new_undirected()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 0)
  assert_true(result.matching_edges.length() == 0)
}

///|
test "edmonds_single_node" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 0)
}

///|
test "edmonds_star_graph_k13" {
  let g = make_edmonds_star_k13()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 1)
}

///|
test "edmonds_two_components" {
  let g = make_edmonds_two_components()
  let result = edmonds_maximum_matching(g)
  // Component 1 (3 nodes path): max 1, Component 2 (2 nodes edge): max 1
  assert_true(result.cardinality == 2)
}

///|
test "edmonds_maximum_possible" {
  let g = make_edmonds_maximum_possible()
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 2)
  assert_true(result.cardinality * 2 == 4)
}

///|
test "edmonds_odd_node_count" {
  let g = make_edmonds_odd_path()
  let result = edmonds_maximum_matching(g)
  // 3 nodes, max matching = floor(3/2) = 1
  assert_true(result.cardinality == 1)
}

// ============================================================================
// Edmonds 跨存储测试 (3)
// ============================================================================

///|
test "edmonds_cross_storage_adjlist" {
  let g = @storage.new_undirected()
  for i in 0..<5 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // Butterfly: two triangles sharing node 0
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 2)
}

///|
test "edmonds_cross_storage_matrix" {
  let g = @storage.new_undirected_matrix(5)
  for i in 0..<5 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // Triangle 0-1-2
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  // Tail: 2-3-4 path
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  let result = edmonds_maximum_matching(g)
  // Triangle can give 1 pair, and 3-4 can give another pair
  assert_true(result.cardinality == 2)
}

///|
test "edmonds_cross_storage_edgelist" {
  let g = @storage.new_undirected_edge_list()
  for i in 0..<5 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  // Same graph as matrix test
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  let result = edmonds_maximum_matching(g)
  assert_true(result.cardinality == 2)
}

///|
test "hopcroft_karp_result_equals_hungarian" {
  let g = make_hk_multi()
  let left = [
    @core.NodeId(0),
    @core.NodeId(1),
    @core.NodeId(2),
    @core.NodeId(3),
  ]
  let right = [
    @core.NodeId(4),
    @core.NodeId(5),
    @core.NodeId(6),
    @core.NodeId(7),
  ]
  let hk_result = hopcroft_karp(g, left, right)
  let hg_result = bipartite_matching_graph(g, left, right)
  assert_true(hk_result.cardinality == hg_result.cardinality)
}

///|
test "hopcroft_karp_no_edges" {
  let g = @storage.new_directed()
  for i in 0..<6 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  let left = [@core.NodeId(0), @core.NodeId(1), @core.NodeId(2)]
  let right = [@core.NodeId(3), @core.NodeId(4), @core.NodeId(5)]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 0)
  assert_true(result.matching_edges.length() == 0)
}

///|
test "hopcroft_karp_single_left" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  let left = [@core.NodeId(0)]
  let right : Array[@core.NodeId] = []
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 0)
}

// ============================================================================
// Hopcroft-Karp 边界情况测试 (4)
// ============================================================================

///|
test "hopcroft_karp_empty_left" {
  let g = @storage.new_directed()
  for i in 0..<3 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  let left : Array[@core.NodeId] = []
  let right = [@core.NodeId(0), @core.NodeId(1), @core.NodeId(2)]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 0)
}

///|
test "hopcroft_karp_empty_right" {
  let g = @storage.new_directed()
  for i in 0..<3 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  let left = [@core.NodeId(0), @core.NodeId(1), @core.NodeId(2)]
  let right : Array[@core.NodeId] = []
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 0)
}

///|
test "hopcroft_karp_all_connected_to_one" {
  let g = make_hk_all_to_one()
  let left = [@core.NodeId(0), @core.NodeId(1), @core.NodeId(2)]
  let right = [@core.NodeId(3)]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 1)
}

///|
test "hopcroft_karp_star_graph" {
  let g = make_hk_star()
  let left = [@core.NodeId(0)]
  let right = [
    @core.NodeId(1),
    @core.NodeId(2),
    @core.NodeId(3),
    @core.NodeId(4),
  ]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 1)
}

// ============================================================================
// Hopcroft-Karp 跨存储测试 (3)
// ============================================================================

///|
test "hopcroft_karp_cross_storage_adjlist" {
  let g = @storage.new_directed()
  for i in 0..<8 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(6), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(7), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(6), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(7), 1.0)
  |> ignore

  let left = [
    @core.NodeId(0),
    @core.NodeId(1),
    @core.NodeId(2),
    @core.NodeId(3),
  ]
  let right = [
    @core.NodeId(4),
    @core.NodeId(5),
    @core.NodeId(6),
    @core.NodeId(7),
  ]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 4)
}

///|
test "hopcroft_karp_cross_storage_matrix" {
  let g = @storage.new_directed_matrix(8)
  for i in 0..<8 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(6), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(7), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(6), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(7), 1.0)
  |> ignore

  let left = [
    @core.NodeId(0),
    @core.NodeId(1),
    @core.NodeId(2),
    @core.NodeId(3),
  ]
  let right = [
    @core.NodeId(4),
    @core.NodeId(5),
    @core.NodeId(6),
    @core.NodeId(7),
  ]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 4)
}

///|
test "hopcroft_karp_cross_storage_edgelist" {
  let g = @storage.new_edge_list()
  for i in 0..<8 {
    @core.GraphWritable::add_node(g, i.to_double()) |> ignore
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(4), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(6), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(5), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(7), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(6), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(7), 1.0)
  |> ignore

  let left = [
    @core.NodeId(0),
    @core.NodeId(1),
    @core.NodeId(2),
    @core.NodeId(3),
  ]
  let right = [
    @core.NodeId(4),
    @core.NodeId(5),
    @core.NodeId(6),
    @core.NodeId(7),
  ]
  let result = hopcroft_karp(g, left, right)
  assert_true(result.cardinality == 4)
}
// ============================================================
// Kuhn-Munkres 测试 (5 tests)
// ============================================================

///|
test "km_2x2_identity" {
  let w : Array[Array[Double]] = [[1.0, 0.0], [0.0, 1.0]]
  let r = kuhn_munkres(w)
  assert_eq(r.matching.length(), 2)
  assert_true(r.total_weight > 1.99)
}

///|
test "km_2x2_cross" {
  let w : Array[Array[Double]] = [[0.0, 2.0], [3.0, 0.0]]
  let r = kuhn_munkres(w)
  assert_eq(r.matching.length(), 2)
  assert_true(r.total_weight > 4.99)
}

///|
test "km_3x3_uniform" {
  let w : Array[Array[Double]] = [[1.0, 1.0, 1.0], [1.0, 1.0, 1.0], [1.0, 1.0, 1.0]]
  let r = kuhn_munkres(w)
  assert_eq(r.matching.length(), 3)
  assert_true(r.total_weight > 2.99)
}

///|
test "km_3x3_diag_prefer" {
  let w : Array[Array[Double]] = [[5.0, 1.0, 1.0], [1.0, 5.0, 1.0], [1.0, 1.0, 5.0]]
  let r = kuhn_munkres(w)
  assert_eq(r.matching.length(), 3)
  assert_true(r.total_weight > 14.99)
}

///|
test "km_empty" {
  let w : Array[Array[Double]] = []
  let r = kuhn_munkres(w)
  assert_eq(r.matching.length(), 0)
  assert_true(r.total_weight < 1.0e-9)
}
