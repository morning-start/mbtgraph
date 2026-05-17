// Blackbox tests for DirectedAdjList.
// Tests: basic CRUD, GraphDirected methods, edge operations.

///|
test "new_directed creates empty directed graph" {
  let g = new_directed()
  assert_eq(@core.GraphReadable::node_count(g), 0)
  assert_eq(@core.GraphReadable::edge_count(g), 0)
  assert_true(@core.GraphReadable::is_empty(g))
  assert_true(@core.GraphReadable::is_directed(g))
}

///|
test "add_node returns sequential NodeId starting from 0" {
  let g = new_directed()
  let id0 = @core.GraphWritable::add_node(g, 10.0)
  let id1 = @core.GraphWritable::add_node(g, 20.0)
  let id2 = @core.GraphWritable::add_node(g, 30.0)

  match id0 { @core.NodeId(v) => assert_eq(v, 0) }
  match id1 { @core.NodeId(v) => assert_eq(v, 1) }
  match id2 { @core.NodeId(v) => assert_eq(v, 2) }
  assert_eq(@core.GraphReadable::node_count(g), 3)
}

///|
test "get_node retrieves data by NodeId" {
  let g = new_directed()
  let id = @core.GraphWritable::add_node(g, 42.0)

  match @core.GraphReadable::get_node(g, id) {
    Some(d) => assert_eq(d, 42.0)
    None => assert_true(false)
  }
}

///|
test "get_node returns None for non-existent node" {
  let g = new_directed()
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  let bad = @core.NodeId(99)

  match @core.GraphReadable::get_node(g, bad) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "contains_node after add" {
  let g = new_directed()
  let id = @core.GraphWritable::add_node(g, 5.0)
  assert_true(@core.GraphReadable::contains_node(g, id))
  assert_true(!@core.GraphReadable::contains_node(g, @core.NodeId(999)))
}

///|
test "add_edge creates directed edge retrievable by get_edge" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 3.14) |> ignore

  assert_eq(@core.GraphReadable::edge_count(g), 1)
  assert_true(@core.GraphReadable::contains_edge(g, a, b))

  match @core.GraphReadable::get_edge(g, a, b) {
    Some(w) => assert_eq(w, 3.14)
    None => assert_true(false)
  }
}

///|
test "get_edge returns None for non-existent edge" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)

  match @core.GraphReadable::get_edge(g, a, b) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "neighbors returns outgoing targets only" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, a, c, 2.0) |> ignore

  let nbrs = @core.GraphReadable::neighbors(g, a).to_array()
  assert_eq(nbrs.length(), 2)

  // b has no outgoing edges
  let nbrs_b = @core.GraphReadable::neighbors(g, b).to_array()
  assert_eq(nbrs_b.length(), 0)
}

///|
test "degree counts outgoing edges" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, a, c, 2.0) |> ignore
  @core.GraphWritable::add_edge(g, b, c, 3.0) |> ignore

  assert_eq(@core.GraphReadable::degree(g, a), 2)
  assert_eq(@core.GraphReadable::degree(g, b), 1)
  assert_eq(@core.GraphReadable::degree(g, c), 0)
}

///|
test "remove_edge removes existing directed edge" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 5.0) |> ignore

  assert_true(@core.GraphWritable::remove_edge(g, a, b))
  assert_eq(@core.GraphReadable::edge_count(g), 0)
  assert_true(!@core.GraphReadable::contains_edge(g, a, b))
}

///|
test "remove_edge on non-existent edge returns false" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)

  assert_true(!@core.GraphWritable::remove_edge(g, a, b))
}

///|
test "remove_node removes node and its incident edges" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, b, c, 2.0) |> ignore
  @core.GraphWritable::add_edge(g, a, c, 3.0) |> ignore

  assert_true(@core.GraphWritable::remove_node(g, b))
  assert_eq(@core.GraphReadable::node_count(g), 2)
  assert_eq(@core.GraphReadable::edge_count(g), 1)
}

///|
test "clear empties graph completely" {
  let g = new_directed()
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
test "add_edge with invalid node returns error" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let bad = @core.NodeId(99)

  match @core.GraphWritable::add_edge(g, a, bad, 1.0) {
    Ok(_) => assert_true(false)
    Err(e) => {
      match e {
        @core.GraphError::InvalidNodeId => assert_true(true)
        _ => assert_true(false)
      }
    }
  }
}

///|
test "GraphDirected: in_neighbors and out_neighbors are separate" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, c, b, 2.0) |> ignore

  // b has in-neighbors [a, c]
  let ins = @core.GraphDirected::in_neighbors(g, b).to_array()
  assert_eq(ins.length(), 2)

  // a has out-neighbors [b]
  let outs = @core.GraphDirected::out_neighbors(g, a).to_array()
  assert_eq(outs.length(), 1)
}

///|
test "GraphDirected: in_degree and out_degree differ" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, c, b, 2.0) |> ignore

  assert_eq(@core.GraphDirected::out_degree(g, a), 1)
  assert_eq(@core.GraphDirected::in_degree(g, a), 0)
  assert_eq(@core.GraphDirected::out_degree(g, b), 0)
  assert_eq(@core.GraphDirected::in_degree(g, b), 2)
}

///|
test "GraphDirected: predecessors and successors include weights" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, a, b, 7.7) |> ignore

  let succs = @core.GraphDirected::successors(g, a).to_array()
  assert_eq(succs.length(), 1)

  let preds = @core.GraphDirected::predecessors(g, b).to_array()
  assert_eq(preds.length(), 1)
}

///|
test "multiple edges from same source to different targets" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let c = @core.GraphWritable::add_node(g, 3.0)
  let d = @core.GraphWritable::add_node(g, 4.0)
  @core.GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, a, c, 2.0) |> ignore
  @core.GraphWritable::add_edge(g, a, d, 3.0) |> ignore

  assert_eq(@core.GraphReadable::edge_count(g), 3)
  assert_eq(@core.GraphReadable::degree(g, a), 3)
}

///|
test "self-loop edge is valid" {
  let g = new_directed()
  let a = @core.GraphWritable::add_node(g, 1.0)
  @core.GraphWritable::add_edge(g, a, a, 9.9) |> ignore

  assert_true(@core.GraphReadable::contains_edge(g, a, a))
  assert_eq(@core.GraphReadable::edge_count(g), 1)
  // self-loop contributes to both in and out degree
  assert_eq(@core.GraphDirected::in_degree(g, a), 1)
  assert_eq(@core.GraphDirected::out_degree(g, a), 1)
}
