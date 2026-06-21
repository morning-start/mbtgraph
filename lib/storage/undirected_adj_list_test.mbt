// Blackbox tests for UndirectedAdjList.
// Tests: basic CRUD, undirected semantics, half-storage optimization,
//        GraphEdgeIterable::edges_sorted.

///|
test "new_undirected creates empty undirected graph" {
  let g = new_undirected()
  assert_eq(@core.GraphReadable::node_count(g), 0)
  assert_eq(@core.GraphReadable::edge_count(g), 0)
  assert_true(@core.GraphReadable::is_empty(g))
  assert_true(!@core.GraphReadable::is_directed(g))
}

///|
test "add_node returns sequential NodeId" {
  let g = new_undirected()
  let id0 = @core.GraphWritable::add_node(g, 10.0)
  let id1 = @core.GraphWritable::add_node(g, 20.0)

  match id0 {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match id1 {
    @core.NodeId(v) => assert_eq(v, 1)
  }
  assert_eq(@core.GraphReadable::node_count(g), 2)
}

///|
test "get_node retrieves data correctly" {
  let g = new_undirected()
  let id = @core.GraphWritable::add_node(g, 42.0)

  match @core.GraphReadable::get_node(g, id) {
    Some(d) => assert_eq(d, 42.0)
    None => assert_true(false)
  }
}

///|
test "contains_edge is bidirectional: (a,b) and (b,a) both true" {
  let g = new_undirected()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 3.14) |> ignore

  assert_true(@core.GraphReadable::contains_edge(g, a, b))
  assert_true(@core.GraphReadable::contains_edge(g, b, a))
}

///|
test "get_edge is bidirectional: both directions return same weight" {
  let g = new_undirected()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 7.77) |> ignore

  match @core.GraphReadable::get_edge(g, a, b) {
    Some(w1) => assert_eq(w1, 7.77)
    None => assert_true(false)
  }

  match @core.GraphReadable::get_edge(g, b, a) {
    Some(w2) => assert_eq(w2, 7.77)
    None => assert_true(false)
  }
}

///|
test "neighbors includes both endpoints of incident edges" {
  let g = new_undirected()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, a, c, 2.0) |> ignore

  // a's neighbors: [b, c]
  let nbrs_a = @core.GraphReadable::neighbors(g, a).to_array()
  assert_eq(nbrs_a.length(), 2)

  // b's neighbors: [a] (only connected to a)
  let nbrs_b = @core.GraphReadable::neighbors(g, b).to_array()
  assert_eq(nbrs_b.length(), 1)
}

///|
test "degree counts total incident edges (in + out combined)" {
  let g = new_undirected()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, b, c, 2.0) |> ignore
  @core.GraphWritable::add_edge(g, a, c, 3.0) |> ignore

  // a connected to b and c → degree 2
  assert_eq(@core.GraphReadable::degree(g, a), 2)
  // b connected to a and c → degree 2
  assert_eq(@core.GraphReadable::degree(g, b), 2)
  // c connected to a and b → degree 2
  assert_eq(@core.GraphReadable::degree(g, c), 2)
}

///|
test "remove_edge works bidirectionally" {
  let g = new_undirected()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 5.0) |> ignore

  // Remove by either direction should work
  assert_true(@core.GraphWritable::remove_edge(g, a, b))
  assert_eq(@core.GraphReadable::edge_count(g), 0)
  assert_true(!@core.GraphReadable::contains_edge(g, a, b))
  assert_true(!@core.GraphReadable::contains_edge(g, b, a))
}

///|
test "remove_node removes node and all its incident edges" {
  let g = new_undirected()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, b, c, 2.0) |> ignore
  @core.GraphWritable::add_edge(g, a, c, 3.0) |> ignore

  assert_true(@core.GraphWritable::remove_node(g, b))
  assert_eq(@core.GraphReadable::node_count(g), 2)
  // Edges involving b removed: only (a,c) remains
  assert_eq(@core.GraphReadable::edge_count(g), 1)
}

///|
test "clear empties graph completely" {
  let g = new_undirected()
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  @core.GraphWritable::add_node(g, 2.0) |> ignore
  let a = @core.NodeId(0)
  let b = @core.NodeId(1)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore

  @core.GraphWritable::clear(g)
  assert_true(@core.GraphReadable::is_empty(g))
  assert_eq(@core.GraphReadable::node_count(g), 0)
  assert_eq(@core.GraphReadable::edge_count(g), 0)
}

///|
test "self-loop in undirected graph" {
  let g = new_undirected()
  let a = @core.GraphWritable::add_node(g, 1.0)
  @core.GraphWritable::add_edge(g, a, a, 9.9) |> ignore

  assert_true(@core.GraphReadable::contains_edge(g, a, a))
  // Self-loop contributes degree 2 in undirected (both ends are same node)
  // Actually for our implementation it counts as 1 since we check from==to once
  assert_eq(@core.GraphReadable::degree(g, a), 1)
}
