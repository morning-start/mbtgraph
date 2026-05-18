// Blackbox tests for DirectedMatrix + UndirectedMatrix.
// Tests: capacity-based creation, O(1) edge query, matrix-specific behavior.

// ============================================================================
// DirectedMatrix tests
// ============================================================================

///|
test "new_directed_matrix creates empty matrix with given capacity" {
  let g = new_directed_matrix(10)
  assert_eq(@core.GraphReadable::node_count(g), 0)
  assert_eq(@core.GraphReadable::edge_count(g), 0)
  assert_true(@core.GraphReadable::is_empty(g))
  assert_true(@core.GraphReadable::is_directed(g))
}

///|
test "directed matrix add_node within capacity" {
  let g = new_directed_matrix(10)
  let id0 = @core.GraphWritable::add_node(g, 1.0)
  let id1 = @core.GraphWritable::add_node(g, 2.0)

  match id0 {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match id1 {
    @core.NodeId(v) => assert_eq(v, 1)
  }
  assert_eq(@core.GraphReadable::node_count(g), 2)
}

///|
test "directed matrix get_node after add" {
  let g = new_directed_matrix(10)
  let id = @core.GraphWritable::add_node(g, 42.0)

  match @core.GraphReadable::get_node(g, id) {
    Some(d) => assert_eq(d, 42.0)
    None => assert_true(false)
  }
}

///|
test "directed matrix contains_edge is O(1)" {
  let g = new_directed_matrix(10)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 5.0) |> ignore
  @core.GraphWritable::add_edge(g, b, c, 3.0) |> ignore

  assert_true(@core.GraphReadable::contains_edge(g, a, b))
  assert_true(!@core.GraphReadable::contains_edge(g, b, a))
  assert_true(!@core.GraphReadable::contains_edge(g, a, c))
}

///|
test "directed matrix get_edge returns correct weight" {
  let g = new_directed_matrix(50)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 99.9) |> ignore

  match @core.GraphReadable::get_edge(g, a, b) {
    Some(w) => assert_eq(w, 99.9)
    None => assert_true(false)
  }
}

///|
test "directed matrix get_edge None for non-existent" {
  let g = new_directed_matrix(50)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)

  match @core.GraphReadable::get_edge(g, a, b) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "directed matrix remove_edge sets back to None" {
  let g = new_directed_matrix(50)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 7.0) |> ignore

  assert_true(@core.GraphWritable::remove_edge(g, a, b))
  match @core.GraphReadable::get_edge(g, a, b) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "directed matrix neighbors iterates all columns" {
  let g = new_directed_matrix(20)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, a, c, 2.0) |> ignore

  let nbrs = @core.GraphReadable::neighbors(g, a).to_array()
  assert_eq(nbrs.length(), 2)
}

///|
test "directed matrix clear removes all data" {
  let g = new_directed_matrix(50)
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  @core.GraphWritable::add_node(g, 2.0) |> ignore
  let a = @core.NodeId(0)
  let b = @core.NodeId(1)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore

  @core.GraphWritable::clear(g)
  assert_true(@core.GraphReadable::is_empty(g))
}

///|
test "directed matrix GraphDirected methods work" {
  let g = new_directed_matrix(10)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore

  assert_eq(@core.GraphDirected::out_degree(g, a), 1)
  assert_eq(@core.GraphDirected::in_degree(g, a), 0)
  assert_eq(@core.GraphDirected::in_degree(g, b), 1)
  assert_eq(@core.GraphDirected::out_degree(g, b), 0)
}

// ============================================================================
// UndirectedMatrix tests
// ============================================================================

///|
test "new_undirected_matrix creates empty undirected matrix" {
  let g = new_undirected_matrix(10)
  assert_eq(@core.GraphReadable::node_count(g), 0)
  assert_true(!@core.GraphReadable::is_directed(g))
}

///|
test "undirected matrix contains_edge is symmetric" {
  let g = new_undirected_matrix(50)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 4.2) |> ignore

  assert_true(@core.GraphReadable::contains_edge(g, a, b))
  assert_true(@core.GraphReadable::contains_edge(g, b, a))
}

///|
test "undirected matrix get_edge is symmetric" {
  let g = new_undirected_matrix(50)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 8.8) |> ignore

  match @core.GraphReadable::get_edge(g, a, b) {
    Some(w1) => assert_eq(w1, 8.8)
    None => assert_true(false)
  }

  match @core.GraphReadable::get_edge(g, b, a) {
    Some(w2) => assert_eq(w2, 8.8)
    None => assert_true(false)
  }
}

///|
test "undirected matrix neighbors include both directions" {
  let g = new_undirected_matrix(10)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore

  let nbrs_a = @core.GraphReadable::neighbors(g, a).to_array()
  let nbrs_b = @core.GraphReadable::neighbors(g, b).to_array()
  assert_true(nbrs_a.contains(b))
  assert_true(nbrs_b.contains(a))
}

///|
test "undirected matrix clear empties graph" {
  let g = new_undirected_matrix(50)
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  @core.GraphWritable::clear(g)
  assert_true(@core.GraphReadable::is_empty(g))
}
