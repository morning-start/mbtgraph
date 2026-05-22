///|
/// Clique 模块测试套件
///
/// 测试覆盖：最大团、最大独立集、最小顶点覆盖算法

fn create_empty_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  g
}

fn create_complete_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = create_empty_graph(n)
  let mut i = 0
  while i < n {
    let mut j = i + 1
    while j < n {
      @storage.UndirectedAdjList::add_edge(g, @core.NodeId(i), @core.NodeId(j), 1.0) |> ignore
      j = j + 1
    }
    i = i + 1
  }
  g
}

fn create_cycle_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = create_empty_graph(n)
  let mut i = 0
  while i < n {
    let next = (i + 1) % n
    @storage.UndirectedAdjList::add_edge(g, @core.NodeId(i), @core.NodeId(next), 1.0) |> ignore
    i = i + 1
  }
  g
}

fn create_path_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = create_empty_graph(n)
  let mut i = 0
  while i < n - 1 {
    @storage.UndirectedAdjList::add_edge(g, @core.NodeId(i), @core.NodeId(i + 1), 1.0) |> ignore
    i = i + 1
  }
  g
}

fn create_petersen_graph() -> @storage.UndirectedAdjList {
  let g = create_empty_graph(10)
  let edges : Array[(Int, Int)] = [
    (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),
    (5, 6), (6, 7), (7, 8), (8, 9), (9, 5),
    (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),
  ]
  for edge in edges {
    let (u, v) = edge
    @storage.UndirectedAdjList::add_edge(g, @core.NodeId(u), @core.NodeId(v), 1.0) |> ignore
  }
  g
}

fn create_star_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = create_empty_graph(n)
  if n >= 2 {
    let mut i = 1
    while i < n {
      @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(i), 1.0) |> ignore
      i = i + 1
    }
  }
  g
}

test "clique_empty_graph_size_one" {
  let g = create_empty_graph(5)
  let result = find_maximum_clique(g)
  assert_eq(result.size, 1)
  assert_eq(result.maximum_clique.length(), 1)
}

test "clique_complete_graph_k5" {
  let g = create_complete_graph(5)
  let result = find_maximum_clique(g)
  assert_eq(result.size, 5)
  assert_eq(result.maximum_clique.length(), 5)
}

test "independent_set_empty_graph_all_nodes" {
  let g = create_empty_graph(5)
  let result = find_maximum_independent_set(g)
  assert_eq(result.size, 5)
  assert_eq(result.maximum_set.length(), 5)
}

test "independent_set_complete_graph_size_one" {
  let g = create_complete_graph(5)
  let result = find_maximum_independent_set(g)
  assert_eq(result.size, 1)
  assert_eq(result.maximum_set.length(), 1)
}

test "clique_cycle_5_size_two" {
  let g = create_cycle_graph(5)
  let result = find_maximum_clique(g)
  assert_eq(result.size, 2)
}

test "clique_petersen_graph_size_two" {
  let g = create_petersen_graph()
  let result = find_maximum_clique(g)
  assert_eq(result.size, 2)
}

test "clique_path_4_size_two" {
  let g = create_path_graph(4)
  let result = find_maximum_clique(g)
  assert_eq(result.size, 2)
}

test "clique_star_graph_size_two" {
  let g = create_star_graph(5)
  let result = find_maximum_clique(g)
  assert_eq(result.size, 2)
}

test "clique_single_node_size_one" {
  let g = create_empty_graph(1)
  let result = find_maximum_clique(g)
  assert_eq(result.size, 1)
}

test "vertex_cover_empty_graph_zero" {
  let g = create_empty_graph(5)
  let exact_result = find_minimum_vertex_cover_exact(g)
  assert_eq(exact_result.size, 0)
  assert_true(exact_result.is_optimal)

  let approx_result = find_minimum_vertex_cover_approx(g)
  assert_eq(approx_result.size, 0)
}

test "vertex_cover_complete_graph_n_minus_one" {
  let g = create_complete_graph(4)
  let exact_result = find_minimum_vertex_cover_exact(g)
  assert_eq(exact_result.size, 3)
  assert_true(exact_result.is_optimal)
}

test "complementarity_clique_independent_set_cycle" {
  let g = create_cycle_graph(5)
  let clique_result = find_maximum_clique(g)
  let is_result = find_maximum_independent_set(g)

  let n = @core.GraphReadable::node_count(g)
  assert_true(clique_result.size >= 1)
  assert_true(is_result.size >= 1)
  assert_true(clique_result.size + is_result.size <= n + 1)
}

test "complementarity_is_vertex_cover_path" {
  let g = create_path_graph(4)
  let is_result = find_maximum_independent_set(g)
  let vc_result = find_minimum_vertex_cover_exact(g)

  let n = @core.GraphReadable::node_count(g)
  assert_eq(is_result.size + vc_result.size, n)
}

test "vertex_cover_approximation_ratio_valid" {
  let g = create_cycle_graph(10)

  let exact_result = find_minimum_vertex_cover_exact(g)
  let approx_result = find_minimum_vertex_cover_approx(g)

  assert_true(approx_result.size >= exact_result.size)
  assert_true(approx_result.size <= 2 * exact_result.size)
}
