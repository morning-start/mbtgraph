// Blackbox tests for EdgeListGraph + UndirectedEdgeListGraph.
// Tests: basic CRUD, directed vs undirected semantics, GraphEdgeIterable.

// ============================================================================
// EdgeListGraph (directed) tests
// ============================================================================

///|
test "new_edge_list creates empty directed edge list" {
  let g = new_edge_list()
  assert_eq(@core.GraphReadable::node_count(g), 0)
  assert_eq(@core.GraphReadable::edge_count(g), 0)
  assert_true(@core.GraphReadable::is_directed(g))
}

///|
test "edge list add_node and get_node" {
  let g = new_edge_list()
  let id = @core.GraphWritable::add_node(g, 42.0)

  match @core.GraphReadable::get_node(g, id) {
    Some(d) => assert_eq(d, 42.0)
    None => assert_true(false)
  }
}

///|
test "edge list add_edge and contains_edge (directed)" {
  let g = new_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 3.14) |> ignore

  assert_true(@core.GraphReadable::contains_edge(g, a, b))
  assert_true(!@core.GraphReadable::contains_edge(g, b, a))
}

///|
test "edge list get_edge (directed only)" {
  let g = new_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 5.5) |> ignore

  match @core.GraphReadable::get_edge(g, a, b) {
    Some(w) => assert_eq(w, 5.5)
    None => assert_true(false)
  }

  match @core.GraphReadable::get_edge(g, b, a) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "edge list neighbors returns outgoing targets" {
  let g = new_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, a, c, 2.0) |> ignore

  let nbrs = @core.GraphReadable::neighbors(g, a).to_array()
  assert_eq(nbrs.length(), 2)
}

///|
test "edge list remove_edge removes exact direction" {
  let g = new_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 7.0) |> ignore

  assert_true(@core.GraphWritable::remove_edge(g, a, b))
  assert_eq(@core.GraphReadable::edge_count(g), 0)
}

///|
test "edge list remove_node removes node and incident edges" {
  let g = new_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, b, c, 2.0) |> ignore

  assert_true(@core.GraphWritable::remove_node(g, b))
  assert_eq(@core.GraphReadable::node_count(g), 2)
  assert_eq(@core.GraphReadable::edge_count(g), 0)
}




///|
test "edge list clear empties everything" {
  let g = new_edge_list()
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  @core.GraphWritable::clear(g)
  assert_true(@core.GraphReadable::is_empty(g))
}

// ============================================================================
// UndirectedEdgeListGraph tests
// ============================================================================

///|
test "new_undirected_edge_list creates empty undirected edge list" {
  let g = new_undirected_edge_list()
  assert_eq(@core.GraphReadable::node_count(g), 0)
  assert_true(!@core.GraphReadable::is_directed(g))
}

///|
test "undirected edge list contains_edge is bidirectional" {
  let g = new_undirected_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 6.6) |> ignore

  assert_true(@core.GraphReadable::contains_edge(g, a, b))
  assert_true(@core.GraphReadable::contains_edge(g, b, a))
}

///|
test "undirected edge list get_edge is bidirectional" {
  let g = new_undirected_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 8.8) |> ignore

  match @core.GraphReadable::get_edge(g, a, b) {
    Some(w) => assert_eq(w, 8.8)
    None => assert_true(false)
  }

  match @core.GraphReadable::get_edge(g, b, a) {
    Some(w) => assert_eq(w, 8.8)
    None => assert_true(false)
  }
}

///|
test "undirected edge list neighbors include both endpoints" {
  let g = new_undirected_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore

  let nbrs_a = @core.GraphReadable::neighbors(g, a).to_array()
  let nbrs_b = @core.GraphReadable::neighbors(g, b).to_array()
  assert_eq(nbrs_a.length(), 1)
  assert_eq(nbrs_b.length(), 1)
}

///|
test "undirected edge list degree counts total incident edges" {
  let g = new_undirected_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, b, c, 2.0) |> ignore

  assert_eq(@core.GraphReadable::degree(g, a), 1)
  assert_eq(@core.GraphReadable::degree(g, b), 2)
  assert_eq(@core.GraphReadable::degree(g, c), 1)
}

///|
test "undirected edge list remove_edge works bidirectionally" {
  let g = new_undirected_edge_list()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 9.0) |> ignore

  assert_true(@core.GraphWritable::remove_edge(g, a, b))
  assert_true(!@core.GraphReadable::contains_edge(g, a, b))
  assert_true(!@core.GraphReadable::contains_edge(g, b, a))
}



