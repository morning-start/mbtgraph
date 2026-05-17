// Blackbox tests for Converter functions.
// Tests: all 8 conversion functions preserve data correctly.

///|
test "to_directed_adj_list from DirectedAdjList is identity-like" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 3.14) |> ignore

  let dst = to_directed_adj_list(src)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_eq(@core.GraphReadable::edge_count(dst), 1)
  assert_true(@core.GraphReadable::is_directed(dst))

  match @core.GraphReadable::get_edge(dst, a, b) {
    Some(w) => assert_eq(w, 3.14)
    None => assert_true(false)
  }
}

///|
test "to_undirected_adj_list converts directed to undirected" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 5.0) |> ignore

  let dst = to_undirected_adj_list(src)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_eq(@core.GraphReadable::edge_count(dst), 1)
  assert_true(!@core.GraphReadable::is_directed(dst))
  // Undirected: both directions should find edge
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
  assert_true(@core.GraphReadable::contains_edge(dst, b, a))
}

///|
test "to_directed_matrix converts with capacity" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 10.0)
  let b = @core.GraphWritable::add_node(src, 20.0)
  @core.GraphWritable::add_edge(src, a, b, 7.7) |> ignore

  let dst = to_directed_matrix(src, 50)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_eq(@core.GraphReadable::edge_count(dst), 1)
  assert_true(@core.GraphReadable::is_directed(dst))

  match @core.GraphReadable::get_edge(dst, a, b) {
    Some(w) => assert_eq(w, 7.7)
    None => assert_true(false)
  }
}

///|
test "to_undirected_matrix converts with capacity" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 9.9) |> ignore

  let dst = to_undirected_matrix(src, 50)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_true(!@core.GraphReadable::is_directed(dst))
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
  assert_true(@core.GraphReadable::contains_edge(dst, b, a))
}

///|
test "to_csr converts to read-only CSR graph" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  let c = @core.GraphWritable::add_node(src, 3.0)
  @core.GraphWritable::add_edge(src, a, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(src, b, c, 2.0) |> ignore
  @core.GraphWritable::add_edge(src, a, c, 3.0) |> ignore

  let dst = to_csr(src)

  assert_eq(@core.GraphReadable::node_count(dst), 3)
  assert_eq(@core.GraphReadable::edge_count(dst), 3)
  assert_true(@core.GraphReadable::is_directed(dst))
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
  assert_true(!@core.GraphReadable::contains_edge(dst, b, a))
}

///|
test "to_csc converts to read-only CSC graph" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 4.2) |> ignore

  let dst = to_csc(src)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_eq(@core.GraphReadable::edge_count(dst), 1)
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
}

///|
test "to_edge_list converts to directed edge list" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 11.0)
  let b = @core.GraphWritable::add_node(src, 22.0)
  @core.GraphWritable::add_edge(src, a, b, 6.6) |> ignore

  let dst = to_edge_list(src)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_eq(@core.GraphReadable::edge_count(dst), 1)
  assert_true(@core.GraphReadable::is_directed(dst))
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
  assert_true(!@core.GraphReadable::contains_edge(dst, b, a))
}

///|
test "to_undirected_edge_list converts to undirected edge list" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 8.8) |> ignore

  let dst = to_undirected_edge_list(src)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_true(!@core.GraphReadable::is_directed(dst))
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
  assert_true(@core.GraphReadable::contains_edge(dst, b, a))
}

///|
test "round-trip conversion: directed → csr → adj_list preserves data" {
  let original = new_directed()
  let a = @core.GraphWritable::add_node(original, 100.0)
  let b = @core.GraphWritable::add_node(original, 200.0)
  @core.GraphWritable::add_edge(original, a, b, 42.0) |> ignore

  let csr = to_csr(original)
  let back = to_directed_adj_list(csr)

  assert_eq(@core.GraphReadable::node_count(back), 2)
  assert_eq(@core.GraphReadable::edge_count(back), 1)

  match @core.GraphReadable::get_node(back, a) {
    Some(d) => assert_eq(d, 100.0)
    None => assert_true(false)
  }

  match @core.GraphReadable::get_edge(back, a, b) {
    Some(w) => assert_eq(w, 42.0)
    None => assert_true(false)
  }
}

///|
test "conversion of empty graph produces valid empty target" {
  let empty = new_directed()

  let al = to_directed_adj_list(empty)
  assert_true(@core.GraphReadable::is_empty(al))

  let mat = to_directed_matrix(empty, 10)
  assert_true(@core.GraphReadable::is_empty(mat))

  let csr_graph = to_csr(empty)
  assert_true(@core.GraphReadable::is_empty(csr_graph))

  let el = to_edge_list(empty)
  assert_true(@core.GraphReadable::is_empty(el))
}
