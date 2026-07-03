// Blackbox tests for GraphError enum.
// Tests all variants, derive behavior (Debug + Eq), pattern matching exhaustiveness,
// and integration with Result type.
//
// Coverage:
//   3 variants × construction + match + Eq = 9 core tests
//   Result integration (Ok + Err branches)
//   Edge case: self-loop edge in EdgeAlreadyExists
//   Boundary: NodeId(0) as payload

// ============================================================================
// Variant construction & pattern matching
// ============================================================================

///|
test "GraphError NodeNotFound: constructs with NodeId and matches correctly" {
  let err = GraphError::NodeNotFound(@core.NodeId(5))
  match err {
    GraphError::NodeNotFound(id) =>
      match id {
        @core.NodeId(v) => assert_eq(v, 5)
      }
    _ => assert_true(false)
  }
}

///|
test "GraphError NodeNotFound with zero NodeId" {
  let err = GraphError::NodeNotFound(@core.NodeId(0))
  match err {
    GraphError::NodeNotFound(id) =>
      match id {
        @core.NodeId(v) => assert_eq(v, 0)
      }
    _ => assert_true(false)
  }
}

///|
test "GraphError NodeNotFound with large NodeId" {
  let err = GraphError::NodeNotFound(@core.NodeId(999999))
  match err {
    GraphError::NodeNotFound(id) =>
      match id {
        @core.NodeId(v) => assert_eq(v, 999999)
      }
    _ => assert_true(false)
  }
}

///|
test "GraphError EdgeAlreadyExists: constructs with two NodeIds" {
  let err = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(1))
  match err {
    GraphError::NodeNotFound(_) => assert_true(false)
    GraphError::EdgeAlreadyExists(f, t) => {
      match f {
        @core.NodeId(fv) => assert_eq(fv, 0)
      }
      match t {
        @core.NodeId(tv) => assert_eq(tv, 1)
      }
    }
    _ => assert_true(false)
  }
}

///|
test "GraphError EdgeAlreadyExists with self-loop (from == to)" {
  let err = GraphError::EdgeAlreadyExists(@core.NodeId(3), @core.NodeId(3))
  match err {
    GraphError::EdgeAlreadyExists(f, t) => {
      match f {
        @core.NodeId(fv) => assert_eq(fv, 3)
      }
      match t {
        @core.NodeId(tv) => assert_eq(tv, 3)
      }
      // Self-loop: from and to are the same NodeId
      assert_true(f == t)
    }
    _ => assert_true(false)
  }
}

///|
test "GraphError EdgeAlreadyExists with zero NodeIds" {
  let err = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(0))
  match err {
    GraphError::EdgeAlreadyExists(f, t) => {
      match f {
        @core.NodeId(fv) => assert_eq(fv, 0)
      }
      match t {
        @core.NodeId(tv) => assert_eq(tv, 0)
      }
    }
    _ => assert_true(false)
  }
}

///|
test "GraphError InvalidNodeId: unit variant matches correctly" {
  let err = GraphError::InvalidNodeId
  match err {
    GraphError::InvalidNodeId => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "GraphError InvalidNodeId can be constructed repeatedly (value semantics)" {
  let a = GraphError::InvalidNodeId
  let b = GraphError::InvalidNodeId
  // Both should be valid and equal
  assert_true(a == b)
}

// ============================================================================
// Eq derive tests
// ============================================================================

///|
test "GraphError Eq: identical NodeNotFound are equal" {
  let a = GraphError::NodeNotFound(@core.NodeId(1))
  let b = GraphError::NodeNotFound(@core.NodeId(1))
  assert_true(a == b)
}

///|
test "GraphError Eq: identical EdgeAlreadyExists are equal" {
  let a = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(2))
  let b = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(2))
  assert_true(a == b)
}

///|
test "GraphError Eq: InvalidNodeId equals itself" {
  let a = GraphError::InvalidNodeId
  let b = GraphError::InvalidNodeId
  assert_true(a == b)
}

///|
test "GraphError Eq: different variants are not equal (NodeNotFound vs InvalidNodeId)" {
  let a = GraphError::NodeNotFound(@core.NodeId(0))
  let b = GraphError::InvalidNodeId
  assert_true(!(a == b))
}

///|
test "GraphError Eq: different variants are not equal (NodeNotFound vs EdgeAlreadyExists)" {
  let a = GraphError::NodeNotFound(@core.NodeId(0))
  let c = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(1))
  assert_true(!(a == c))
}

///|
test "GraphError Eq: different variants are not equal (EdgeAlreadyExists vs InvalidNodeId)" {
  let b = GraphError::InvalidNodeId
  let c = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(1))
  assert_true(!(b == c))
}

///|
test "GraphError Eq: same variant different payloads - NodeNotFound" {
  let a = GraphError::NodeNotFound(@core.NodeId(0))
  let b = GraphError::NodeNotFound(@core.NodeId(99))
  assert_true(!(a == b))
}

///|
test "GraphError Eq: same variant different payloads - EdgeAlreadyExists from differs" {
  let c = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(1))
  let d = GraphError::EdgeAlreadyExists(@core.NodeId(2), @core.NodeId(1))
  assert_true(!(c == d))
}

///|
test "GraphError Eq: same variant different payloads - EdgeAlreadyExists to differs" {
  let c = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(1))
  let d = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(3))
  assert_true(!(c == d))
}

///|
test "GraphError Eq: swapped edge endpoints are not equal" {
  let c = GraphError::EdgeAlreadyExists(@core.NodeId(0), @core.NodeId(1))
  let d = GraphError::EdgeAlreadyExists(@core.NodeId(1), @core.NodeId(0))
  assert_true(!(c == d))
}

// ============================================================================
// Result type integration
// ============================================================================

///|
test "GraphError in Result: Ok branch returns successfully" {
  fn make_ok() -> Result[Int, GraphError] {
    Ok(42)
  }

  match make_ok() {
    Ok(v) => assert_eq(v, 42)
    Err(_) => assert_true(false)
  }
}

///|
test "GraphError in Result: Err branch carries NodeNotFound" {
  fn make_err_notfound() -> Result[Unit, GraphError] {
    Err(GraphError::NodeNotFound(@core.NodeId(7)))
  }

  match make_err_notfound() {
    Ok(_) => assert_true(false)
    Err(e) =>
      match e {
        GraphError::NodeNotFound(id) =>
          match id {
            @core.NodeId(v) => assert_eq(v, 7)
          }
        _ => assert_true(false)
      }
  }
}

///|
test "GraphError in Result: Err branch carries EdgeAlreadyExists" {
  fn make_err_edge() -> Result[Unit, GraphError] {
    Err(GraphError::EdgeAlreadyExists(@core.NodeId(10), @core.NodeId(20)))
  }

  match make_err_edge() {
    Ok(_) => assert_true(false)
    Err(e) =>
      match e {
        GraphError::NodeNotFound(_) => assert_true(false)
        GraphError::EdgeAlreadyExists(f, t) => {
          match f {
            @core.NodeId(fv) => assert_eq(fv, 10)
          }
          match t {
            @core.NodeId(tv) => assert_eq(tv, 20)
          }
        }
        _ => assert_true(false)
      }
  }
}

///|
test "GraphError in Result: Err branch carries InvalidNodeId" {
  fn make_err_invalid() -> Result[Unit, GraphError] {
    Err(GraphError::InvalidNodeId)
  }

  match make_err_invalid() {
    Ok(_) => assert_true(false)
    Err(e) =>
      match e {
        GraphError::InvalidNodeId => assert_true(true)
        _ => assert_true(false)
      }
  }
}

///|
test "GraphError in Result: nested function returning different errors" {
  fn validate_edge(from : Int, to : Int) -> Result[Unit, GraphError] {
    if from < 0 || to < 0 {
      Err(GraphError::InvalidNodeId)
    } else if from == to {
      Err(GraphError::EdgeAlreadyExists(@core.NodeId(from), @core.NodeId(to)))
    } else {
      Ok(())
    }
  }

  // Valid edge → Ok
  match validate_edge(0, 1) {
    Ok(_) => ()
    Err(_) => assert_true(false)
  }

  // Same node → EdgeAlreadyExists
  match validate_edge(5, 5) {
    Ok(_) => assert_true(false)
    Err(GraphError::EdgeAlreadyExists(f, t)) => {
      match f {
        @core.NodeId(v) => assert_eq(v, 5)
      }
      match t {
        @core.NodeId(v) => assert_eq(v, 5)
      }
    }
    Err(_) => assert_true(false)
  }

  // Negative → InvalidNodeId
  match validate_edge(-1, 0) {
    Ok(_) => assert_true(false)
    Err(GraphError::InvalidNodeId) => ()
    Err(_) => assert_true(false)
  }
}

// ============================================================================
// 新增变体测试 (v1.1.0+)
// ============================================================================

///|
test "GraphError NodeAlreadyExists: constructs with NodeId and matches" {
  let err = GraphError::NodeAlreadyExists(@core.NodeId(3))
  match err {
    GraphError::NodeAlreadyExists(id) =>
      match id {
        @core.NodeId(v) => assert_eq(v, 3)
      }
    _ => assert_true(false)
  }
}

///|
test "GraphError NodeIdOutOfBounds: constructs with Int and matches" {
  let err = GraphError::NodeIdOutOfBounds(999)
  match err {
    GraphError::NodeIdOutOfBounds(v) => assert_eq(v, 999)
    _ => assert_true(false)
  }
}

///|
test "GraphError Eq: NodeAlreadyExists identical are equal" {
  let a = GraphError::NodeAlreadyExists(@core.NodeId(0))
  let b = GraphError::NodeAlreadyExists(@core.NodeId(0))
  assert_true(a == b)
}

///|
test "GraphError Eq: NodeIdOutOfBounds identical are equal" {
  let a = GraphError::NodeIdOutOfBounds(5)
  let b = GraphError::NodeIdOutOfBounds(5)
  assert_true(a == b)
}

///|
test "GraphError Eq: new variants differ from old variants" {
  let a = GraphError::NodeAlreadyExists(@core.NodeId(0))
  let b = GraphError::NodeNotFound(@core.NodeId(0))
  assert_true(!(a == b))
}

///|
test "GraphError Eq: NodeIdOutOfBounds different payloads differ" {
  let a = GraphError::NodeIdOutOfBounds(0)
  let b = GraphError::NodeIdOutOfBounds(99)
  assert_true(!(a == b))
}

///|
test "GraphError in Result: Err branch carries NodeAlreadyExists" {
  fn make_err() -> Result[Unit, GraphError] {
    Err(GraphError::NodeAlreadyExists(@core.NodeId(7)))
  }
  match make_err() {
    Ok(_) => assert_true(false)
    Err(GraphError::NodeAlreadyExists(id)) =>
      match id {
        @core.NodeId(v) => assert_eq(v, 7)
      }
    Err(_) => assert_true(false)
  }
}

///|
test "GraphError in Result: Err branch carries NodeIdOutOfBounds" {
  fn make_err() -> Result[Unit, GraphError] {
    Err(GraphError::NodeIdOutOfBounds(42))
  }
  match make_err() {
    Ok(_) => assert_true(false)
    Err(GraphError::NodeIdOutOfBounds(v)) => assert_eq(v, 42)
    Err(_) => assert_true(false)
  }
}
