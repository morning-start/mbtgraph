/// 图算子模块测试

// ============================================================================
// 辅助函数：构建测试图
// ============================================================================

fn make_triangle() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore
  g
}

fn make_path3() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  g
}

fn make_directed_triangle() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 2.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 3.0) |> ignore
  g
}

// ============================================================================
// 补图测试
// ============================================================================

///|
test "complement_empty_graph" {
  let g = @storage.new_undirected()
  let c = complement(g)
  assert_true(@core.GraphReadable::edge_count(c) == 0)
}

///|
test "complement_triangle" {
  let g = make_triangle()
  let c = complement(g)
  // Triangle has 3 edges, complement of K3 has 0 edges
  assert_true(@core.GraphReadable::edge_count(c) == 0)
}

///|
test "complement_path3" {
  let g = make_path3()
  let c = complement(g)
  // Path3 has 2 edges (0-1, 1-2), complement should have 1 edge (0-2)
  assert_true(@core.GraphReadable::edge_count(c) == 1)
  assert_true(@core.GraphReadable::contains_edge(c, @core.NodeId(0), @core.NodeId(2)))
}

///|
test "complement_twice_is_original" {
  let g = make_path3()
  // Need to handle that complement returns UndirectedAdjList
  let c1 = complement(g)
  let c2 = complement(c1)
  // Middle edge count of double complement should equal original
  // For path3: original=2, complement=1, double-complement=2
  assert_true(@core.GraphReadable::edge_count(c2) == @core.GraphReadable::edge_count(g))
}

// ============================================================================
// 反转图测试
// ============================================================================

///|
test "reverse_empty_graph" {
  let g = @storage.new_directed()
  let r = reverse(g)
  assert_true(@core.GraphReadable::edge_count(r) == 0)
}

///|
test "reverse_directed_triangle" {
  let g = make_directed_triangle()
  let r = reverse(g)
  assert_true(@core.GraphReadable::edge_count(r) == 3)
  assert_true(@core.GraphReadable::contains_edge(r, @core.NodeId(1), @core.NodeId(0)))
  assert_true(@core.GraphReadable::contains_edge(r, @core.NodeId(0), @core.NodeId(2)))
  assert_true(@core.GraphReadable::contains_edge(r, @core.NodeId(2), @core.NodeId(1)))
}

///|
test "reverse_twice_is_original" {
  let g = make_directed_triangle()
  let r1 = reverse(g)
  let r2 = reverse(r1)
  assert_true(@core.GraphReadable::edge_count(r2) == @core.GraphReadable::edge_count(g))
  assert_true(@core.GraphReadable::contains_edge(r2, @core.NodeId(0), @core.NodeId(1)))
}

// ============================================================================
// 并图测试
// ============================================================================

///|
test "union_empty_with_triangle" {
  let empty = @storage.new_undirected()
  let t = make_triangle()
  let u = graph_union(empty, t)
  assert_true(@core.GraphReadable::edge_count(u) == 3)
}

///|
test "union_path_with_path" {
  let a = make_path3()
  let b = make_path3()
  let u = graph_union(a, b)
  // Same graph, union = same graph
  assert_true(@core.GraphReadable::edge_count(u) == 2)
}

///|
test "union_different_vertices" {
  let a = @storage.new_undirected()
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_edge(a, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  let b = @storage.new_undirected()
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  // add_node in b assigns NodeId(0), NodeId(1), NodeId(2)
  // So b has nodes 0,1,2 with edge 1-2
  @core.GraphWritable::add_edge(b, @core.NodeId(1), @core.NodeId(2), 2.0) |> ignore
  let u = graph_union(a, b)
  // a has edge 0-1, b has edge 1-2
  assert_true(@core.GraphReadable::edge_count(u) == 2)
}

// ============================================================================
// 交图测试
// ============================================================================

///|
test "intersection_empty_with_triangle" {
  let empty = @storage.new_undirected()
  let t = make_triangle()
  let i = graph_intersection(empty, t)
  assert_true(@core.GraphReadable::edge_count(i) == 0)
}

///|
test "intersection_same" {
  let a = make_path3()
  let i = graph_intersection(a, a)
  assert_true(@core.GraphReadable::edge_count(i) == 2)
}

///|
test "intersection_partial" {
  let a = @storage.new_undirected()
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_edge(a, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(a, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  let b = @storage.new_undirected()
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  @core.GraphWritable::add_edge(b, @core.NodeId(0), @core.NodeId(1), 2.0) |> ignore
  @core.GraphWritable::add_edge(b, @core.NodeId(0), @core.NodeId(2), 3.0) |> ignore
  let i = graph_intersection(a, b)
  // Only 0-1 is common
  assert_true(@core.GraphReadable::edge_count(i) == 1)
}

// ============================================================================
// 差图测试
// ============================================================================

///|
test "difference_same" {
  let a = make_triangle()
  let d = graph_difference(a, a)
  assert_true(@core.GraphReadable::edge_count(d) == 0)
}

///|
test "difference_path_minus_triangle" {
  let p = make_path3()
  let t = make_triangle()
  // Path3 edges: 0-1, 1-2. Triangle edges: 0-1, 1-2, 2-0.
  // Difference = empty
  let d = graph_difference(p, t)
  assert_true(@core.GraphReadable::edge_count(d) == 0)
}

// ============================================================================
// 笛卡尔积测试
// ============================================================================

///|
test "cartesian_product_empty" {
  let empty = @storage.new_undirected()
  let t = make_triangle()
  let p = cartesian_product(empty, t)
  assert_true(@core.GraphReadable::node_count(p) == 0)
}

///|
test "cartesian_product_single_edge" {
  let a = @storage.new_undirected()
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_edge(a, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  let b = @storage.new_undirected()
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  @core.GraphWritable::add_edge(b, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  // P2 □ P2 = C4 (4-cycle)
  let p = cartesian_product(a, b)
  assert_true(@core.GraphReadable::node_count(p) == 4)
  assert_true(@core.GraphReadable::edge_count(p) == 4)
}

// ============================================================================
// 张量积测试
// ============================================================================

///|
test "tensor_product_empty" {
  let empty = @storage.new_undirected()
  let t = make_triangle()
  let p = tensor_product(empty, t)
  assert_true(@core.GraphReadable::node_count(p) == 0)
}

///|
test "tensor_product_single_edge" {
  let a = @storage.new_undirected()
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_node(a, 0.0) |> ignore
  @core.GraphWritable::add_edge(a, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  let b = @storage.new_undirected()
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  @core.GraphWritable::add_node(b, 0.0) |> ignore
  @core.GraphWritable::add_edge(b, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  // P2 × P2 = two disjoint edges
  let p = tensor_product(a, b)
  assert_true(@core.GraphReadable::node_count(p) == 4)
  assert_true(@core.GraphReadable::edge_count(p) == 2)
}

// ============================================================================
// 字典序积测试
// ============================================================================

///|
test "lexicographic_product_empty" {
  let empty = @storage.new_undirected()
  let t = make_triangle()
  let p = lexicographic_product(empty, t)
  assert_true(@core.GraphReadable::node_count(p) == 0)
}

// ============================================================================
// 线图测试
// ============================================================================

///|
test "line_graph_empty" {
  let g = @storage.new_undirected()
  let l = line_graph(g)
  assert_true(@core.GraphReadable::node_count(l) == 0)
}

///|
test "line_graph_triangle" {
  let g = make_triangle()
  let l = line_graph(g)
  // L(K3) = K3
  assert_true(@core.GraphReadable::node_count(l) == 3)
  assert_true(@core.GraphReadable::edge_count(l) == 3)
}

///|
test "line_graph_path3" {
  let g = make_path3()
  let l = line_graph(g)
  // L(path3) = single edge (2 edges in path -> 2 nodes, connected because they share middle vertex)
  assert_true(@core.GraphReadable::node_count(l) == 2)
  assert_true(@core.GraphReadable::edge_count(l) == 1)
}

// ============================================================================
// 收缩测试
// ============================================================================

///|
test "contract_empty" {
  let g = @storage.new_undirected()
  let c = contract(g, @core.NodeId(0), @core.NodeId(1))
  assert_true(@core.GraphReadable::edge_count(c) == 0)
}

///|
test "contract_path3" {
  let g = make_path3()
  // Contract 1 into 0: edges become 0-2
  let c = contract(g, @core.NodeId(1), @core.NodeId(0))
  assert_true(@core.GraphReadable::node_count(c) == 3)
  assert_true(@core.GraphReadable::contains_edge(c, @core.NodeId(0), @core.NodeId(2)))
  assert_false(@core.GraphReadable::contains_edge(c, @core.NodeId(0), @core.NodeId(1)))
  assert_false(@core.GraphReadable::contains_edge(c, @core.NodeId(1), @core.NodeId(2)))
}

// ============================================================================
// 幂图测试
// ============================================================================

///|
test "power_graph_empty" {
  let g = @storage.new_undirected()
  let p = power_graph(g, 2)
  assert_true(@core.GraphReadable::edge_count(p) == 0)
}

///|
test "power_graph_path_k1" {
  let g = make_path3()
  // G^1 should equal G
  let p = power_graph(g, 1)
  assert_true(@core.GraphReadable::edge_count(p) == 2)
}

///|
test "power_graph_path_k2" {
  let g = make_path3()
  // G^2: distance ≤ 2 = complete graph K3
  let p = power_graph(g, 2)
  assert_true(@core.GraphReadable::edge_count(p) == 3)
}
