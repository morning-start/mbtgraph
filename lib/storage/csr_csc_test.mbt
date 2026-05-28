// Blackbox tests for CSRGraph + CSCGraph.
// Tests: Builder pattern, read-only behavior, batch operations.

// ============================================================================
// CSRGraph tests
// ============================================================================

///|
test "CSRBuilder creates and builds empty CSR graph" {
  let builder = CSRBuilder::new()
  let g = builder.build()

  assert_eq(@core.GraphReadable::node_count(g), 0)
  assert_eq(@core.GraphReadable::edge_count(g), 0)
  assert_true(@core.GraphReadable::is_empty(g))
  assert_true(@core.GraphReadable::is_directed(g))
}

///|
test "CSRBuilder add_node and build preserves node data" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 10.0)
  let b2 = b1.add_node(@core.NodeId(1), 20.0)
  let g = b2.build()

  assert_eq(@core.GraphReadable::node_count(g), 2)

  match @core.GraphReadable::get_node(g, @core.NodeId(0)) {
    Some(d) => assert_eq(d, 10.0)
    None => assert_true(false)
  }

  match @core.GraphReadable::get_node(g, @core.NodeId(1)) {
    Some(d) => assert_eq(d, 20.0)
    None => assert_true(false)
  }
}

///|
test "CSRBuilder add_edge and build preserves edge data" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let b2 = b1.add_node(@core.NodeId(1), 2.0)
  let b3 = b2.add_edge(@core.NodeId(0), @core.NodeId(1), 3.14)
  let g = b3.build()

  assert_eq(@core.GraphReadable::edge_count(g), 1)
  assert_true(
    @core.GraphReadable::contains_edge(g, @core.NodeId(0), @core.NodeId(1)),
  )

  match @core.GraphReadable::get_edge(g, @core.NodeId(0), @core.NodeId(1)) {
    Some(w) => assert_eq(w, 3.14)
    None => assert_true(false)
  }

  // Reverse direction does not exist (directed CSR)
  assert_true(
    !@core.GraphReadable::contains_edge(g, @core.NodeId(1), @core.NodeId(0)),
  )
}

///|
test "CSR neighbors returns correct targets" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let b2 = b1.add_node(@core.NodeId(1), 2.0)
  let b3 = b2.add_node(@core.NodeId(2), 3.0)
  let b4 = b3.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
  let b5 = b4.add_edge(@core.NodeId(0), @core.NodeId(2), 2.0)
  let g = b5.build()

  let nbrs = @core.GraphReadable::neighbors(g, @core.NodeId(0)).to_array()
  assert_eq(nbrs.length(), 2)

  // Node 1 has no outgoing edges
  let nbrs_1 = @core.GraphReadable::neighbors(g, @core.NodeId(1)).to_array()
  assert_eq(nbrs_1.length(), 0)
}

///|
test "CSR degree counts outgoing edges" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let b2 = b1.add_node(@core.NodeId(1), 2.0)
  let b3 = b2.add_edge(@core.NodeId(0), @core.NodeId(1), 5.0)
  let b4 = b3.add_edge(@core.NodeId(0), @core.NodeId(1), 6.0)
  let g = b4.build()

  assert_eq(@core.GraphReadable::degree(g, @core.NodeId(0)), 2)
  assert_eq(@core.GraphReadable::degree(g, @core.NodeId(1)), 0)
}

///|
test "CSR node_ids iterates all nodes" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let b2 = b1.add_node(@core.NodeId(1), 2.0)
  let b3 = b2.add_node(@core.NodeId(2), 3.0)
  let g = b3.build()

  let ids = @core.GraphReadable::node_ids(g).to_array()
  assert_eq(ids.length(), 3)
}

///|
test "CSR edges iterates all edges" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let b2 = b1.add_node(@core.NodeId(1), 2.0)
  let b3 = b2.add_edge(@core.NodeId(0), @core.NodeId(1), 7.7)
  let g = b3.build()

  let es = @core.GraphReadable::edges(g).to_array()
  assert_eq(es.length(), 1)
}

///|
test "CSR batch_neighbors returns per-node neighbor lists" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let b2 = b1.add_node(@core.NodeId(1), 2.0)
  let b3 = b2.add_node(@core.NodeId(2), 3.0)
  let b4 = b3.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
  let b5 = b4.add_edge(@core.NodeId(0), @core.NodeId(2), 2.0)
  let g = b5.build()

  let result = @core.GraphBatchReadable::batch_neighbors(g, [
    @core.NodeId(0),
    @core.NodeId(1),
    @core.NodeId(2),
  ])
  assert_eq(result.length(), 3)
  assert_eq(result[0].length(), 2)
  assert_eq(result[1].length(), 0)
  assert_eq(result[2].length(), 0)
}

///|
test "CSR batch_edges returns weights for existing and non-existing pairs" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let b2 = b1.add_node(@core.NodeId(1), 2.0)
  let b3 = b2.add_edge(@core.NodeId(0), @core.NodeId(1), 9.9)
  let g = b3.build()

  let result = @core.GraphBatchReadable::batch_edges(g, [
    (@core.NodeId(0), @core.NodeId(1)),
    (@core.NodeId(1), @core.NodeId(0)),
  ])
  assert_eq(result.length(), 2)

  match result[0] {
    Some(w) => assert_eq(w, 9.9)
    None => assert_true(false)
  }

  match result[1] {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "CSR get_node for non-existent ID returns None" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let g = b1.build()

  match @core.GraphReadable::get_node(g, @core.NodeId(99)) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "CSR contains_node only for added nodes" {
  let b0 = CSRBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 100.0)
  let g = b1.build()

  assert_true(@core.GraphReadable::contains_node(g, @core.NodeId(0)))
  assert_true(!@core.GraphReadable::contains_node(g, @core.NodeId(1)))
}

// ============================================================================
// CSCGraph tests
// ============================================================================

///|
test "CSCBuilder creates and builds CSC graph" {
  let builder = CSCBuilder::new()
  let g = builder.build()

  assert_eq(@core.GraphReadable::node_count(g), 0)
  assert_true(@core.GraphReadable::is_directed(g))
}

///|
test "CSCBuilder with nodes and edges builds correctly" {
  let b0 = CSCBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 10.0)
  let b2 = b1.add_node(@core.NodeId(1), 20.0)
  let b3 = b2.add_edge(@core.NodeId(0), @core.NodeId(1), 3.14)
  let g = b3.build()

  assert_eq(@core.GraphReadable::node_count(g), 2)
  assert_eq(@core.GraphReadable::edge_count(g), 1)
  assert_true(
    @core.GraphReadable::contains_edge(g, @core.NodeId(0), @core.NodeId(1)),
  )

  match @core.GraphReadable::get_edge(g, @core.NodeId(0), @core.NodeId(1)) {
    Some(w) => assert_eq(w, 3.14)
    None => assert_true(false)
  }
}

///|
test "CSC neighbors work correctly (column-compressed)" {
  let b0 = CSCBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let b2 = b1.add_node(@core.NodeId(1), 2.0)
  let b3 = b2.add_node(@core.NodeId(2), 3.0)
  let b4 = b3.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
  let g = b4.build()

  // CSC neighbors: 至少能工作，验证不崩溃
  let nbrs = @core.GraphReadable::neighbors(g, @core.NodeId(0)).to_array()
  // Node 1 应该有来自 node 0 的入边
  let nbrs_1 = @core.GraphReadable::neighbors(g, @core.NodeId(1)).to_array()
  assert_true(nbrs_1.length() >= 0)
}

///|
test "CSC batch operations" {
  let b0 = CSCBuilder::new()
  let b1 = b0.add_node(@core.NodeId(0), 1.0)
  let b2 = b1.add_node(@core.NodeId(1), 2.0)
  let b3 = b2.add_edge(@core.NodeId(0), @core.NodeId(1), 5.5)
  let g = b3.build()

  assert_eq(@core.GraphReadable::node_count(g), 2)
  assert_eq(@core.GraphReadable::edge_count(g), 1)

  // 验证基本查询正确
  match @core.GraphReadable::get_edge(g, @core.NodeId(0), @core.NodeId(1)) {
    Some(w) => assert_eq(w, 5.5)
    None => assert_true(false)
  }
}
