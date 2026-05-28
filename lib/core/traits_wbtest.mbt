// Whitebox tests for core Traits.
// Uses a MockGraph struct to verify all 6 trait implementations and constraints.
// Validates: method signatures, inheritance chains, type constraints.

// ============================================================================
// MockGraph: implements ALL traits for comprehensive verification
// ============================================================================

///|
struct MockGraph {
  mut node_cnt : Int
  mut nodes : Array[Node]
  mut edges : Array[(NodeId, NodeId, Double)]
  directed : Bool
}

///|
fn new_mock(directed : Bool) -> MockGraph {
  { node_cnt: 0, nodes: [], edges: [], directed }
}

// --- GraphReadable (12 methods) ---

///|
impl GraphReadable for MockGraph with node_count(self) -> Int {
  self.node_cnt
}

///|
impl GraphReadable for MockGraph with edge_count(self) -> Int {
  self.edges.length()
}

///|
impl GraphReadable for MockGraph with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length()
}

///|
impl GraphReadable for MockGraph with contains_edge(self, from, to) -> Bool {
  for e in self.edges {
    match e {
      (f, t, _) => if f == from && t == to { return true }
    }
  }
  false
}

///|
impl GraphReadable for MockGraph with get_node(self, id) -> Double? {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    None
  } else {
    Some(self.nodes[idx].data)
  }
}

///|
impl GraphReadable for MockGraph with get_edge(self, from, to) -> Double? {
  for e in self.edges {
    match e {
      (f, t, w) => if f == from && t == to { return Some(w) }
    }
  }
  None
}

///|
impl GraphReadable for MockGraph with neighbors(self, id) -> Iter[NodeId] {
  let r : Array[NodeId] = []
  for e in self.edges {
    match e {
      (f, t, _) => if f == id { r.push(t) }
    }
  }
  r.iter()
}

///|
impl GraphReadable for MockGraph with degree(self, id) -> Int {
  let mut c = 0
  for e in self.edges {
    match e {
      (f, _, _) => if f == id { c = c + 1 }
    }
  }
  c
}

///|
impl GraphReadable for MockGraph with is_directed(self) -> Bool {
  self.directed
}

///|
impl GraphReadable for MockGraph with is_empty(self) -> Bool {
  self.nodes.length() == 0
}

///|
impl GraphReadable for MockGraph with node_ids(self) -> Iter[NodeId] {
  let r : Array[NodeId] = []
  for i in 0..<self.nodes.length() {
    r.push(self.nodes[i].id)
  }
  r.iter()
}

///|
impl GraphReadable for MockGraph with edges(self) -> Iter[
  (NodeId, NodeId, Double),
] {
  self.edges.iter()
}

// --- GraphWritable (+5 methods, inherits Readable) ---

///|
impl GraphWritable for MockGraph with add_node(self, data) -> NodeId {
  let g = self
  let idx = g.nodes.length()
  let id = NodeId(idx)
  g.nodes.push({ id, data })
  g.node_cnt = g.node_cnt + 1
  id
}

///|
impl GraphWritable for MockGraph with remove_node(self, id) -> Bool {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    return false
  }
  let ne : Array[(NodeId, NodeId, Double)] = []
  for e in self.edges {
    match e {
      (f, t, w) => if f != id && t != id { ne.push((f, t, w)) }
    }
  }
  let g = self
  g.edges = ne
  g.node_cnt = g.node_cnt - 1
  true
}

///|
impl GraphWritable for MockGraph with add_edge(self, from, to, data) -> Result[
  Unit,
  GraphError,
] {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.nodes.length() {
    Err(GraphError::InvalidNodeId)
  } else if ti < 0 || ti >= self.nodes.length() {
    Err(GraphError::InvalidNodeId)
  } else {
    let g = self
    g.edges.push((from, to, data))
    Ok(())
  }
}

///|
impl GraphWritable for MockGraph with remove_edge(self, from, to) -> Bool {
  let ne : Array[(NodeId, NodeId, Double)] = []
  let mut found = false
  for e in self.edges {
    match e {
      (f, t, w) =>
        if f == from && t == to {
          found = true
        } else {
          ne.push((f, t, w))
        }
    }
  }
  let g = self
  g.edges = ne
  found
}

///|
impl GraphWritable for MockGraph with clear(self) -> Unit {
  let g = self
  g.nodes = []
  g.edges = []
  g.node_cnt = 0
}

// --- GraphDirected (+6 methods, inherits Readable) ---

///|
impl GraphDirected for MockGraph with in_neighbors(self, id) -> Iter[NodeId] {
  let r : Array[NodeId] = []
  for e in self.edges {
    match e {
      (_, t, _) => if t == id { r.push(e.0) }
    }
  }
  r.iter()
}

///|
impl GraphDirected for MockGraph with out_neighbors(self, id) -> Iter[NodeId] {
  GraphReadable::neighbors(self, id)
}

///|
impl GraphDirected for MockGraph with in_degree(self, id) -> Int {
  let mut c = 0
  for e in self.edges {
    match e {
      (_, t, _) => if t == id { c = c + 1 }
    }
  }
  c
}

///|
impl GraphDirected for MockGraph with out_degree(self, id) -> Int {
  GraphReadable::degree(self, id)
}

///|
impl GraphDirected for MockGraph with predecessors(self, id) -> Iter[
  (NodeId, Double),
] {
  let r : Array[(NodeId, Double)] = []
  for e in self.edges {
    match e {
      (f, t, w) => if t == id { r.push((f, w)) }
    }
  }
  r.iter()
}

///|
impl GraphDirected for MockGraph with successors(self, id) -> Iter[
  (NodeId, Double),
] {
  let r : Array[(NodeId, Double)] = []
  for e in self.edges {
    match e {
      (f, t, w) => if f == id { r.push((t, w)) }
    }
  }
  r.iter()
}

// --- GraphBatchReadable (+2 methods, inherits Readable) ---

///|
impl GraphBatchReadable for MockGraph with batch_neighbors(
  self,
  ids : Array[NodeId],
) -> Array[Array[NodeId]] {
  let r : Array[Array[NodeId]] = []
  for nid in ids {
    let nb : Array[NodeId] = []
    for e in self.edges {
      match e {
        (f, t, _) => if f == nid { nb.push(t) }
      }
    }
    r.push(nb)
  }
  r
}

///|
impl GraphBatchReadable for MockGraph with batch_edges(
  self,
  pairs : Array[(NodeId, NodeId)],
) -> Array[Double?] {
  let r : Array[Double?] = []
  for p in pairs {
    match p {
      (f, t) => r.push(GraphReadable::get_edge(self, f, t))
    }
  }
  r
}

// ============================================================================
// Test cases
// ============================================================================

///|
/// GraphReadable: empty graph basics
test "MockGraph empty graph has zero nodes and edges" {
  let g = new_mock(true)
  assert_eq(GraphReadable::node_count(g), 0)
  assert_eq(GraphReadable::edge_count(g), 0)
  assert_true(GraphReadable::is_empty(g))
}

///|
/// GraphReadable: is_directed flag
test "MockGraph is_directed reflects constructor parameter" {
  let dg = new_mock(true)
  assert_true(GraphReadable::is_directed(dg))

  let ug = new_mock(false)
  assert_true(!GraphReadable::is_directed(ug))
}

///|
/// GraphReadable: add node via Writable and query via Readable
test "MockGraph add_node returns correct ID and get_node retrieves data" {
  let g = new_mock(true)
  let id0 = GraphWritable::add_node(g, 10.0)
  let id1 = GraphWritable::add_node(g, 20.0)

  assert_eq(GraphReadable::node_count(g), 2)
  assert_true(GraphReadable::contains_node(g, id0))
  assert_true(GraphReadable::contains_node(g, id1))

  match GraphReadable::get_node(g, id0) {
    Some(v) => assert_eq(v, 10.0)
    None => assert_true(false)
  }

  match GraphReadable::get_node(g, id1) {
    Some(v) => assert_eq(v, 20.0)
    None => assert_true(false)
  }
}

///|
/// GraphReadable: get_node returns None for missing node
test "MockGraph get_node returns None for non-existent node" {
  let g = new_mock(true)
  GraphWritable::add_node(g, 1.0) |> ignore
  let bad_id = NodeId(99)
  match GraphReadable::get_node(g, bad_id) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
/// GraphReadable: contains_node for invalid IDs
test "MockGraph contains_node returns false for negative and out-of-range IDs" {
  let g = new_mock(true)
  GraphWritable::add_node(g, 1.0) |> ignore

  assert_true(!GraphReadable::contains_node(g, NodeId(-1)))
  assert_true(!GraphReadable::contains_node(g, NodeId(999)))
}

///|
/// GraphReadable + Writable: add edge and query
test "MockGraph add_edge creates edge retrievable by get_edge" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  GraphWritable::add_edge(g, a, b, 3.5) |> ignore

  assert_eq(GraphReadable::edge_count(g), 1)
  assert_true(GraphReadable::contains_edge(g, a, b))

  match GraphReadable::get_edge(g, a, b) {
    Some(w) => assert_eq(w, 3.5)
    None => assert_true(false)
  }
}

///|
/// GraphReadable: neighbors returns correct adjacency
test "MockGraph neighbors returns target nodes of outgoing edges" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  let c = GraphWritable::add_node(g, 3.0)
  GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  GraphWritable::add_edge(g, a, c, 2.0) |> ignore

  let nbrs = GraphReadable::neighbors(g, a).to_array()
  assert_eq(nbrs.length(), 2)

  // node 'a' should have no incoming neighbors in its neighbor list
  let nbrs_b = GraphReadable::neighbors(g, b).to_array()
  assert_eq(nbrs_b.length(), 0)
}

///|
/// GraphReadable: degree counts outgoing edges
test "MockGraph degree counts outgoing edges for directed graph" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  let c = GraphWritable::add_node(g, 3.0)
  GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  GraphWritable::add_edge(g, a, c, 2.0) |> ignore
  GraphWritable::add_edge(g, b, c, 3.0) |> ignore

  assert_eq(GraphReadable::degree(g, a), 2)
  assert_eq(GraphReadable::degree(g, b), 1)
  assert_eq(GraphReadable::degree(g, c), 0)
}

///|
/// GraphReadable: node_ids iterates all nodes
test "MockGraph node_ids returns all node IDs" {
  let g = new_mock(true)
  let id0 = GraphWritable::add_node(g, 1.0)
  let id1 = GraphWritable::add_node(g, 2.0)
  let ids = GraphReadable::node_ids(g).to_array()
  assert_eq(ids.length(), 2)
}

///|
/// GraphReadable: edges iterates all edges
test "MockGraph edges returns all edges as triples" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  GraphWritable::add_edge(g, a, b, 4.2) |> ignore

  let es = GraphReadable::edges(g).to_array()
  assert_eq(es.length(), 1)
}

///|
/// GraphWritable: remove_edge works correctly
test "MockGraph remove_edge removes existing edge and returns true" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  GraphWritable::add_edge(g, a, b, 5.0) |> ignore

  assert_true(GraphWritable::remove_edge(g, a, b))
  assert_eq(GraphReadable::edge_count(g), 0)
  assert_true(!GraphReadable::contains_edge(g, a, b))
}

///|
/// GraphWritable: remove_edge on non-existent edge returns false
test "MockGraph remove_edge returns false for non-existent edge" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)

  assert_true(!GraphWritable::remove_edge(g, a, b))
}

///|
/// GraphWritable: remove_node removes node and associated edges
test "MockGraph remove_node removes node and its incident edges" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  let c = GraphWritable::add_node(g, 3.0)
  GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  GraphWritable::add_edge(g, b, c, 2.0) |> ignore
  GraphWritable::add_edge(g, a, c, 3.0) |> ignore

  assert_true(GraphWritable::remove_node(g, b))
  assert_eq(GraphReadable::node_count(g), 2)
  assert_eq(GraphReadable::edge_count(g), 1)
}

///|
/// GraphWritable: clear empties the graph
test "MockGraph clear removes all nodes and edges" {
  let g = new_mock(true)
  GraphWritable::add_node(g, 1.0) |> ignore
  GraphWritable::add_node(g, 2.0) |> ignore
  let a = NodeId(0)
  let b = NodeId(1)
  GraphWritable::add_edge(g, a, b, 1.0) |> ignore

  GraphWritable::clear(g)
  assert_true(GraphReadable::is_empty(g))
  assert_eq(GraphReadable::node_count(g), 0)
  assert_eq(GraphReadable::edge_count(g), 0)
}

///|
/// GraphWritable: add_edge with invalid node returns error
test "MockGraph add_edge with invalid node ID returns InvalidNodeId error" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let bad = NodeId(99)

  match GraphWritable::add_edge(g, a, bad, 1.0) {
    Ok(_) => assert_true(false)
    Err(e) =>
      match e {
        GraphError::InvalidNodeId => assert_true(true)
        _ => assert_true(false)
      }
  }
}

///|
/// GraphDirected: in_neighbors / out_neighbors
test "MockGraph Directed: in_neighbors and out_neighbors separate correctly" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  let c = GraphWritable::add_node(g, 3.0)
  GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  GraphWritable::add_edge(g, c, b, 2.0) |> ignore

  // b's in_neighbors: [a, c]
  let ins = GraphDirected::in_neighbors(g, b).to_array()
  assert_eq(ins.length(), 2)

  // a's out_neighbors: [b]
  let outs = GraphDirected::out_neighbors(g, a).to_array()
  assert_eq(outs.length(), 1)
}

///|
/// GraphDirected: in_degree / out_degree
test "MockGraph Directed: in_degree and out_degree are distinct" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  GraphWritable::add_edge(g, a, b, 2.0) |> ignore

  assert_eq(GraphDirected::out_degree(g, a), 2)
  assert_eq(GraphDirected::in_degree(g, a), 0)
  assert_eq(GraphDirected::out_degree(g, b), 0)
  assert_eq(GraphDirected::in_degree(g, b), 2)
}

///|
/// GraphDirected: predecessors / successors return weighted edges
test "MockGraph Directed: predecessors and successors include weights" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  GraphWritable::add_edge(g, a, b, 7.7) |> ignore

  let succs = GraphDirected::successors(g, a).to_array()
  assert_eq(succs.length(), 1)

  let preds = GraphDirected::predecessors(g, b).to_array()
  assert_eq(preds.length(), 1)
}

///|
/// GraphBatchReadable: batch_neighbors
test "MockGraph BatchReadable: batch_neighbors returns per-node neighbor lists" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  let c = GraphWritable::add_node(g, 3.0)
  GraphWritable::add_edge(g, a, b, 1.0) |> ignore
  GraphWritable::add_edge(g, a, c, 2.0) |> ignore

  let result = GraphBatchReadable::batch_neighbors(g, [a, b, c])
  assert_eq(result.length(), 3)
  assert_eq(result[0].length(), 2) // a has 2 outgoing
  assert_eq(result[1].length(), 0) // b has 0 outgoing
  assert_eq(result[2].length(), 0) // c has 0 outgoing
}

///|
/// GraphBatchReadable: batch_edges
test "MockGraph BatchReadable: batch_edges returns per-pair weights" {
  let g = new_mock(true)
  let a = GraphWritable::add_node(g, 1.0)
  let b = GraphWritable::add_node(g, 2.0)
  GraphWritable::add_edge(g, a, b, 9.9) |> ignore

  let result = GraphBatchReadable::batch_edges(g, [(a, b), (b, a)])
  assert_eq(result.length(), 2)

  match result[0] {
    Some(w) => assert_eq(w, 9.9)
    None => assert_true(false) // reverse direction doesn't exist
  }

  match result[1] {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}


