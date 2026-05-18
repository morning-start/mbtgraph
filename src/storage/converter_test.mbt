// Blackbox tests for Converter functions.
//
// 架构设计：三层转换，语义安全
// - 有向组: [G : GraphDirected] 编译期约束
// - 无向组: [G : GraphReadable] + 运行时断言
// - 语义转换: as_undirected / as_directed 显式跨边界

// ============================================================================
// 有向图存储结构互转（5 个函数）
// ============================================================================

///|
test "to_directed_adj_list from DirectedAdjList preserves data" {
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
test "to_directed_matrix from DirectedAdjList with capacity" {
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
test "to_csr from DirectedAdjList produces read-only graph" {
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
test "to_csc from DirectedAdjList produces column-compressed graph" {
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
test "to_edge_list from DirectedAdjList preserves direction" {
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
test "directed round-trip: adj_list → csr → adj_list preserves data" {
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
test "directed conversion of empty graph produces valid empty targets" {
  let empty = new_directed()

  let al = to_directed_adj_list(empty)
  assert_true(@core.GraphReadable::is_empty(al))

  let mat = to_directed_matrix(empty, 10)
  assert_true(@core.GraphReadable::is_empty(mat))

  let csr_graph = to_csr(empty)
  assert_true(@core.GraphReadable::is_empty(csr_graph))

  let csc_graph = to_csc(empty)
  assert_true(@core.GraphReadable::is_empty(csc_graph))

  let el = to_edge_list(empty)
  assert_true(@core.GraphReadable::is_empty(el))
}

///|
test "directed converters accept CSR as source (GraphDirected)" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 9.9) |> ignore

  let csr = to_csr(src)
  // CSR 实现 GraphDirected，可以作为有向转换组的源
  let mat = to_directed_matrix(csr, 20)
  assert_eq(@core.GraphReadable::edge_count(mat), 1)

  let el = to_edge_list(csr)
  assert_eq(@core.GraphReadable::edge_count(el), 1)
}

// ============================================================================
// 无向图存储结构互转（3 个函数）
// ============================================================================

///|
test "to_undirected_adj_list from UndirectedAdjList preserves data" {
  let src = new_undirected()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 5.0) |> ignore

  let dst = to_undirected_adj_list(src)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_eq(@core.GraphReadable::edge_count(dst), 1)
  assert_true(!@core.GraphReadable::is_directed(dst))
  // 无向边双向可达
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
  assert_true(@core.GraphReadable::contains_edge(dst, b, a))
}

///|
test "to_undirected_matrix from UndirectedAdjList with capacity" {
  let src = new_undirected()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 9.9) |> ignore

  let dst = to_undirected_matrix(src, 30)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_true(!@core.GraphReadable::is_directed(dst))
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
  assert_true(@core.GraphReadable::contains_edge(dst, b, a))
}

///|
test "to_undirected_edge_list from UndirectedAdjList preserves data" {
  let src = new_undirected()
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
test "undirected round-trip: adj_list → edge_list → adj_list preserves data" {
  let original = new_undirected()
  let a = @core.GraphWritable::add_node(original, 50.0)
  let b = @core.GraphWritable::add_node(original, 60.0)
  @core.GraphWritable::add_edge(original, a, b, 77.0) |> ignore

  let el = to_undirected_edge_list(original)
  let back = to_undirected_adj_list(el)

  assert_eq(@core.GraphReadable::node_count(back), 2)
  assert_eq(@core.GraphReadable::edge_count(back), 1)
  assert_true(!@core.GraphReadable::is_directed(back))
  assert_true(@core.GraphReadable::contains_edge(back, a, b))
  assert_true(@core.GraphReadable::contains_edge(back, b, a))
}

///|
test "undirected conversion of empty graph produces valid empty targets" {
  let empty = new_undirected()

  let ual = to_undirected_adj_list(empty)
  assert_true(@core.GraphReadable::is_empty(ual))

  let umat = to_undirected_matrix(empty, 10)
  assert_true(@core.GraphReadable::is_empty(umat))

  let uel = to_undirected_edge_list(empty)
  assert_true(@core.GraphReadable::is_empty(uel))
}

// ============================================================================
// 显式语义转换（as_undirected / as_directed）
// ============================================================================

///|
test "as_undirected converts directed to undirected (single edge)" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 5.0) |> ignore

  let dst = as_undirected(src)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_eq(@core.GraphReadable::edge_count(dst), 1)
  assert_true(!@core.GraphReadable::is_directed(dst))
  // 有向边 a→b 变成无向边 {a-b}
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
  assert_true(@core.GraphReadable::contains_edge(dst, b, a))
}

///|
test "as_undirected deduplicates bidirectional edges" {
  let src = new_directed()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 3.0) |> ignore
  @core.GraphWritable::add_edge(src, b, a, 4.0) |> ignore // 反向边

  let dst = as_undirected(src)

  // a→b 和 b→a 变成同一条无向边，第二条被 EdgeAlreadyExists 跳过
  assert_eq(@core.GraphReadable::edge_count(dst), 1)
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
}

///|
test "as_directed converts undirected to directed (no reverse edges)" {
  let src = new_undirected()
  let a = @core.GraphWritable::add_node(src, 1.0)
  let b = @core.GraphWritable::add_node(src, 2.0)
  @core.GraphWritable::add_edge(src, a, b, 6.0) |> ignore

  let dst = as_directed(src)

  assert_eq(@core.GraphReadable::node_count(dst), 2)
  assert_eq(@core.GraphReadable::edge_count(dst), 1)
  assert_true(@core.GraphReadable::is_directed(dst))
  // 无向边 {a-b} 变成有向边 a→b（不生成反向边）
  assert_true(@core.GraphReadable::contains_edge(dst, a, b))
  assert_true(!@core.GraphReadable::contains_edge(dst, b, a))
  // out_degree == degree （无入边）
  assert_eq(@core.GraphDirected::out_degree(dst, a), 1)
  assert_eq(@core.GraphDirected::in_degree(dst, a), 0)
}
