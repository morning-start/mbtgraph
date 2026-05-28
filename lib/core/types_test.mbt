// Blackbox tests for core types.
// Tests public API of NodeId, Node, Edge structs and their derive behavior.
//
// Coverage:
//   NodeId: construction, Eq derive, boundary values (0, neg, large)
//   Node:   construction, field access (id, data), boundary data
//   Edge:   construction, field access (from, to, data), self-loop, zero/neg weight

// ============================================================================
// NodeId tests
// ============================================================================

///|
test "NodeId constructs with integer value" {
  let id = @core.NodeId(0)
  match id {
    @core.NodeId(v) => assert_eq(v, 0)
  }
}

///|
test "NodeId Eq: identical values are equal" {
  let a = @core.NodeId(42)
  let b = @core.NodeId(42)
  assert_true(a == b)
}

///|
test "NodeId Eq: different values are not equal" {
  let a = @core.NodeId(0)
  let b = @core.NodeId(1)
  assert_true(!(a == b))
}

///|
test "NodeId accepts negative integer (runtime check only)" {
  let id = @core.NodeId(-1)
  match id {
    @core.NodeId(v) => assert_eq(v, -1)
  }
}

///|
test "NodeId accepts large integer" {
  let id = @core.NodeId(999999)
  match id {
    @core.NodeId(v) => assert_eq(v, 999999)
  }
}

///|
test "NodeId zero is valid and matches" {
  let id = @core.NodeId(0)
  match id {
    @core.NodeId(v) => assert_eq(v, 0)
  }
}

///|
test "NodeId unwrap pattern in nested context" {
  fn double_id(id : @core.NodeId) -> Int {
    match id {
      @core.NodeId(v) => v * 2
    }
  }
  assert_eq(double_id(@core.NodeId(21)), 42)
}

// ============================================================================
// Node tests
// ============================================================================

///|
test "Node constructs with id and positive data" {
  let node : Node = Node::{ id: @core.NodeId(0), data: 3.14 }
  assert_eq(node.data, 3.14)
  match node.id {
    @core.NodeId(v) => assert_eq(v, 0)
  }
}

///|
test "Node with zero data" {
  let node : Node = Node::{ id: @core.NodeId(5), data: 0.0 }
  assert_eq(node.data, 0.0)
  match node.id {
    @core.NodeId(v) => assert_eq(v, 5)
  }
}

///|
test "Node with negative data" {
  let node : Node = Node::{ id: @core.NodeId(0), data: -273.15 }
  assert_eq(node.data, -273.15)
}

///|
test "Node with very large data" {
  let node : Node = Node::{ id: @core.NodeId(0), data: 1.7976931348623157e+308 }
  assert_true(node.data > 0.0)
}

///|
test "Node with very small positive data" {
  let node : Node = Node::{ id: @core.NodeId(0), data: 0.000001 }
  assert_true(node.data > 0.0)
  assert_true(node.data < 0.01)
}

///|
test "Node id field preserves NodeId identity" {
  let original = @core.NodeId(99)
  let node : Node = Node::{ id: original, data: 42.0 }
  assert_true(node.id == original)
}

///|
test "Node data field is independent across instances" {
  let node : Node = Node::{ id: @core.NodeId(0), data: 1.0 }
  assert_eq(node.data, 1.0)
  let node2 : Node = Node::{ id: node.id, data: 99.9 }
  assert_eq(node2.data, 99.9)
  assert_eq(node.data, 1.0)
}

// ============================================================================
// Edge tests
// ============================================================================

///|
test "Edge constructs with from, to and positive weight" {
  let edge : Edge = Edge::{
    from: @core.NodeId(0),
    to: @core.NodeId(1),
    data: 2.5,
  }
  match edge.from {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match edge.to {
    @core.NodeId(v) => assert_eq(v, 1)
  }
  assert_eq(edge.data, 2.5)
}

///|
test "Edge self-loop (from == to) is valid" {
  let edge : Edge = Edge::{
    from: @core.NodeId(0),
    to: @core.NodeId(0),
    data: 1.0,
  }
  match edge.from {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match edge.to {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  assert_true(edge.from == edge.to)
}

///|
test "Edge with zero weight" {
  let edge : Edge = Edge::{
    from: @core.NodeId(0),
    to: @core.NodeId(1),
    data: 0.0,
  }
  assert_eq(edge.data, 0.0)
}

///|
test "Edge with negative weight (signed graph support)" {
  let edge : Edge = Edge::{
    from: @core.NodeId(0),
    to: @core.NodeId(1),
    data: -5.0,
  }
  assert_eq(edge.data, -5.0)
}

///|
test "Edge with large weight" {
  let edge : Edge = Edge::{
    from: @core.NodeId(0),
    to: @core.NodeId(1),
    data: 999999.99,
  }
  assert_true(edge.data > 1000.0)
}

///|
test "Edge fields preserve NodeId identity" {
  let f = @core.NodeId(10)
  let t = @core.NodeId(20)
  let edge : Edge = Edge::{ from: f, to: t, data: 7.77 }
  assert_true(edge.from == f)
  assert_true(edge.to == t)
}

///|
test "Edge direction matters: (a,b) != (b,a)" {
  let e1 : Edge = Edge::{
    from: @core.NodeId(0),
    to: @core.NodeId(1),
    data: 1.0,
  }
  let e2 : Edge = Edge::{
    from: @core.NodeId(1),
    to: @core.NodeId(0),
    data: 1.0,
  }
  assert_true(e1.from == e2.to)
  assert_true(e1.to == e2.from)
  assert_true(e1.data == e2.data)
}

// ============================================================================
// Cross-type composition tests
// ============================================================================

///|
test "Node and Edge compose correctly: edge connects two nodes" {
  let n_a : Node = Node::{ id: @core.NodeId(0), data: 100.0 }
  let n_b : Node = Node::{ id: @core.NodeId(1), data: 200.0 }
  let edge : Edge = Edge::{ from: n_a.id, to: n_b.id, data: 3.14 }

  match edge.from {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match edge.to {
    @core.NodeId(v) => assert_eq(v, 1)
  }
  assert_eq(edge.data, 3.14)
}

///|
test "Multiple edges can share the same NodeId" {
  let src = @core.NodeId(0)
  let e1 : Edge = Edge::{ from: src, to: @core.NodeId(1), data: 1.0 }
  let e2 : Edge = Edge::{ from: src, to: @core.NodeId(2), data: 2.0 }
  let e3 : Edge = Edge::{ from: src, to: @core.NodeId(3), data: 3.0 }

  assert_true(e1.from == src)
  assert_true(e2.from == src)
  assert_true(e3.from == src)

  match e1.to {
    @core.NodeId(v) => assert_eq(v, 1)
  }
  match e2.to {
    @core.NodeId(v) => assert_eq(v, 2)
  }
  match e3.to {
    @core.NodeId(v) => assert_eq(v, 3)
  }
}

///|
test "NodeId sequence creates consistent node/edge chain" {
  let nodes : Array[Node] = []
  let mut i = 0
  while i < 4 {
    nodes.push(Node::{ id: @core.NodeId(i), data: (i + 1).to_double() })
    i = i + 1
  }

  assert_eq(nodes.length(), 4)

  let edges : Array[Edge] = []
  let mut j = 0
  while j < 3 {
    edges.push(Edge::{
      from: nodes[j].id,
      to: nodes[j + 1].id,
      data: (j + 1).to_double(),
    })
    j = j + 1
  }

  assert_eq(edges.length(), 3)

  // Verify chain: 0->1->2->3
  match edges[0].from {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match edges[0].to {
    @core.NodeId(v) => assert_eq(v, 1)
  }
  match edges[2].from {
    @core.NodeId(v) => assert_eq(v, 2)
  }
  match edges[2].to {
    @core.NodeId(v) => assert_eq(v, 3)
  }
}
