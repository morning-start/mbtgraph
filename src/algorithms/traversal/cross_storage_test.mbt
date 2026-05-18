// Cross-storage compatibility tests.
//
// 验证 BFS / DFS / 环检测 / 拓扑排序 在不同存储结构上行为一致。
// 核心原则：算法只依赖 @core.GraphReadable，不应因存储实现差异导致结果不同。

// ============================================================================
// 图构建工厂：用不同存储结构构建相同拓扑的图
// ============================================================================

/// 构建线性有向图: 0 → 1 → 2 → 3 (4 节点, 3 边)
fn make_linear_adjlist() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let n3 = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore
  g
}

fn make_linear_matrix() -> @storage.DirectedMatrix {
  let g = @storage.new_directed_matrix(10)
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let n3 = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore
  g
}

fn make_linear_edgelist() -> @storage.EdgeListGraph {
  let g = @storage.new_edge_list()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let n3 = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore
  g
}

fn make_linear_csr() -> @storage.CSRGraph {
  let b = @storage.CSRBuilder::new()
  let b1 = b.add_node(@core.NodeId(0), 0.0)
  let b2 = b1.add_node(@core.NodeId(1), 1.0)
  let b3 = b2.add_node(@core.NodeId(2), 2.0)
  let b4 = b3.add_node(@core.NodeId(3), 3.0)
  let b5 = b4.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
  let b6 = b5.add_edge(@core.NodeId(1), @core.NodeId(2), 1.0)
  let b7 = b6.add_edge(@core.NodeId(2), @core.NodeId(3), 1.0)
  b7.build()
}

/// 构建 DAG: 0→1, 0→2, 1→3, 2→3 (4 节点, 4 边, 无环)
fn make_dag_adjlist() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let n3 = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n0, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n3, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore
  g
}

fn make_dag_csr() -> @storage.CSRGraph {
  let b = @storage.CSRBuilder::new()
  let b1 = b.add_node(@core.NodeId(0), 0.0)
  let b2 = b1.add_node(@core.NodeId(1), 1.0)
  let b3 = b2.add_node(@core.NodeId(2), 2.0)
  let b4 = b3.add_node(@core.NodeId(3), 3.0)
  let b5 = b4.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
  let b6 = b5.add_edge(@core.NodeId(0), @core.NodeId(2), 1.0)
  let b7 = b6.add_edge(@core.NodeId(1), @core.NodeId(3), 1.0)
  let b8 = b7.add_edge(@core.NodeId(2), @core.NodeId(3), 1.0)
  b8.build()
}

/// 构建有环有向图: 0→1→2→0 (三角形)
fn make_cycle_adjlist() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n0, 1.0) |> ignore
  g
}

fn make_cycle_csr() -> @storage.CSRGraph {
  let b = @storage.CSRBuilder::new()
  let b1 = b.add_node(@core.NodeId(0), 0.0)
  let b2 = b1.add_node(@core.NodeId(1), 1.0)
  let b3 = b2.add_node(@core.NodeId(2), 2.0)
  let b4 = b3.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
  let b5 = b4.add_edge(@core.NodeId(1), @core.NodeId(2), 1.0)
  let b6 = b5.add_edge(@core.NodeId(2), @core.NodeId(0), 1.0)
  b6.build()
}

/// 构建无向树 (无环): 0-1-2-3
fn make_undirected_tree_adjlist() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let n3 = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore
  g
}

// ============================================================================
// 跨存储 BFS 一致性测试
// ============================================================================

///|
test "BFS on AdjList vs Matrix visits same count" {
  let g_al = make_linear_adjlist()
  let g_mat = make_linear_matrix()

  let r_al = bfs(g_al, @core.NodeId(0))
  let r_mat = bfs(g_mat, @core.NodeId(0))

  assert_eq(r_al.base.reachable_count(), r_mat.base.reachable_count())
  assert_true(r_al.base.reachable_count() == 4)
}

///|
test "BFS distance consistency: AdjList vs Matrix" {
  let g_al = make_linear_adjlist()
  let g_mat = make_linear_matrix()

  let r_al = bfs(g_al, @core.NodeId(0))
  let r_mat = bfs(g_mat, @core.NodeId(0))

  assert_eq(r_al.distance(@core.NodeId(3)), r_mat.distance(@core.NodeId(3)))
  assert_eq(r_al.distance(@core.NodeId(3)), 3)
}

///|
test "BFS shortest path: AdjList vs EdgeList" {
  let p_al = bfs_shortest_path(make_linear_adjlist(), @core.NodeId(0), @core.NodeId(3))
  let p_el = bfs_shortest_path(make_linear_edgelist(), @core.NodeId(0), @core.NodeId(3))

  assert_eq(p_al.length(), p_el.length())
  assert_eq(p_al.length(), 4)
}

///|
test "BFS on CSR produces same reachable count as AdjList" {
  let g_al = make_linear_adjlist()
  let g_csr = make_linear_csr()

  let r_al = bfs(g_al, @core.NodeId(0))
  let r_csr = bfs(g_csr, @core.NodeId(0))

  assert_eq(r_al.base.reachable_count(), r_csr.base.reachable_count())
  assert_eq(r_csr.base.reachable_count(), 4)
}

///|
test "BFS path_to works on CSR storage" {
  let g_csr = make_linear_csr()
  let result = bfs(g_csr, @core.NodeId(0))
  let path = result.base.path_to(@core.NodeId(3))

  assert_eq(path.length(), 4)
  assert_true(path[0] == @core.NodeId(0))
  assert_true(path[3] == @core.NodeId(3))
}

///|
test "BFS all: AdjList vs Matrix on disconnected graph" {
  let g_al = @storage.new_directed()
  @core.GraphWritable::add_node(g_al, 1.0) |> ignore
  @core.GraphWritable::add_node(g_al, 2.0) |> ignore

  let g_mat = @storage.new_directed_matrix(10)
  @core.GraphWritable::add_node(g_mat, 1.0) |> ignore
  @core.GraphWritable::add_node(g_mat, 2.0) |> ignore

  let r_al = bfs_all(g_al)
  let r_mat = bfs_all(g_mat)

  assert_eq(r_al.base.reachable_count(), r_mat.base.reachable_count())
  assert_eq(r_al.base.reachable_count(), 2)
}

// ============================================================================
// 跨存储 DFS 一致性测试
// ============================================================================

///|
test "DFS reachable count: AdjList == Matrix == EdgeList" {
  let g_al = make_linear_adjlist()
  let g_mat = make_linear_matrix()
  let g_el = make_linear_edgelist()

  let r_al = dfs(g_al, @core.NodeId(0))
  let r_mat = dfs(g_mat, @core.NodeId(0))
  let r_el = dfs(g_el, @core.NodeId(0))

  assert_eq(r_al.base.reachable_count(), r_mat.base.reachable_count())
  assert_eq(r_mat.base.reachable_count(), r_el.base.reachable_count())
  assert_eq(r_el.base.reachable_count(), 4)
}

///|
test "DFS entry < exit invariant holds on all storages" {
  // AdjList
  let r_al = dfs(make_linear_adjlist(), @core.NodeId(0))
  check_entry_exit_invariant(r_al)

  // Matrix
  let r_mat = dfs(make_linear_matrix(), @core.NodeId(0))
  check_entry_exit_invariant(r_mat)

  // CSR
  let r_csr = dfs(make_linear_csr(), @core.NodeId(0))
  check_entry_exit_invariant(r_csr)
}

///|
test "DFS on CSR: same reachability as AdjList" {
  let g_al = make_linear_adjlist()
  let g_csr = make_linear_csr()

  let r_al = dfs_all(g_al)
  let r_csr = dfs_all(g_csr)

  assert_eq(r_al.base.reachable_count(), r_csr.base.reachable_count())
}

///|
test "DFS path_to on Matrix reconstructs correctly" {
  let g = make_linear_matrix()
  let result = dfs(g, @core.NodeId(0))
  let path = result.base.path_to(@core.NodeId(3))

  assert_eq(path.length(), 4)
  assert_true(path[0] == @core.NodeId(0))
}

// ============================================================================
// 跨存储环检测一致性测试
// ============================================================================

///|
test "cycle detection: DAG is acyclic on AdjList and CSR" {
  let g_al = make_dag_adjlist()
  let g_csr = make_dag_csr()

  assert_true(!has_cycle(g_al))
  assert_true(!has_directed_cycle(g_al))
  assert_true(!has_cycle(g_csr))
  assert_true(!has_directed_cycle(g_csr))
}

///|
test "cycle detection: cyclic graph detected on AdjList and CSR" {
  let g_al = make_cycle_adjlist()
  let g_csr = make_cycle_csr()

  assert_true(has_cycle(g_al))
  assert_true(has_directed_cycle(g_al))
  assert_true(has_cycle(g_csr))
  assert_true(has_directed_cycle(g_csr))
}

///|
test "cycle detection: undirected tree no cycle on UndirectedAdjList" {
  let g = make_undirected_tree_adjlist()
  assert_true(!has_cycle(g))
  assert_true(!has_undirected_cycle(g))
}

///|
test "cycle detection: single node self-loop on Matrix" {
  let g = @storage.new_directed_matrix(10)
  let n0 = @core.GraphWritable::add_node(g, 1.0)
  @core.GraphWritable::add_edge(g, n0, n0, 1.0) |> ignore
  assert_true(has_cycle(g))
}

///|
test "cycle detection: empty graph always false on all types" {
  let al = @storage.new_directed()
  let mat = @storage.new_directed_matrix(10)
  let el = @storage.new_edge_list()

  assert_true(!has_cycle(al))
  assert_true(!has_cycle(mat))
  assert_true(!has_cycle(el))
}

// ============================================================================
// 跨存储拓扑排序一致性测试
// ============================================================================

///|
test "topo_sort_kahn: AdjList and CSR produce valid orderings for DAG" {
  let g_al = make_dag_adjlist()
  let g_csr = make_dag_csr()

  match topo_sort_kahn(g_al) {
    Ok(order_al) => {
      assert_eq(order_al.length(), 4)
    }
    Err(_) => assert_true(false)
  }

  match topo_sort_kahn(g_csr) {
    Ok(order_csr) => {
      assert_eq(order_csr.length(), 4)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "topo_sort_dfs: AdjList and CSR both succeed on DAG" {
  let g_al = make_dag_adjlist()
  let g_csr = make_dag_csr()

  match topo_sort_dfs(g_al) {
    Ok(_) => ()
    Err(_) => assert_true(false)
  }

  match topo_sort_dfs(g_csr) {
    Ok(_) => ()
    Err(_) => assert_true(false)
  }
}

///|
test "topo_sort: cyclic graph returns error on AdjList and CSR" {
  let g_al = make_cycle_adjlist()
  let g_csr = make_cycle_csr()

  match topo_sort_kahn(g_al) {
    Ok(_) => assert_true(false)
    Err(_) => ()
  }
  match topo_sort_kahn(g_csr) {
    Ok(_) => assert_true(false)
    Err(_) => ()
  }
  match topo_sort_dfs(g_al) {
    Ok(_) => assert_true(false)
    Err(_) => ()
  }
  match topo_sort_dfs(g_csr) {
    Ok(_) => assert_true(false)
    Err(_) => ()
  }
}

///|
test "topo_sort on Matrix: single node returns that node" {
  let g = @storage.new_directed_matrix(10)
  let n0 = @core.GraphWritable::add_node(g, 42.0)
  match topo_sort_kahn(g) {
    Ok(order) => {
      assert_eq(order.length(), 1)
      assert_true(order[0] == n0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "topo_sort Kahn vs DFS: same length on AdjList and CSR" {
  let g_al = make_dag_adjlist()
  let g_csr = make_dag_csr()

  let kahn_al = match topo_sort_kahn(g_al) { Ok(o) => o; Err(_) => [] }
  let dfs_al = match topo_sort_dfs(g_al) { Ok(o) => o; Err(_) => [] }
  let kahn_csr = match topo_sort_kahn(g_csr) { Ok(o) => o; Err(_) => [] }
  let dfs_csr = match topo_sort_dfs(g_csr) { Ok(o) => o; Err(_) => [] }

  assert_eq(kahn_al.length(), dfs_al.length())
  assert_eq(kahn_al.length(), kahn_csr.length())
  assert_eq(dfs_al.length(), dfs_csr.length())
  assert_eq(kahn_al.length(), 4)
}

// ============================================================================
// 验证辅助函数
// ============================================================================

fn check_entry_exit_invariant(result : DfsResult) -> Unit raise {
  let nc = result.base.order.length()
  let mut i = 0
  while i < nc {
    let nid = result.base.order[i]
    if result.base.is_visited(nid) {
      let e = result.entry_time[nid.0]
      let x = result.exit_time[nid.0]
      assert_true(e < x)
    }
    i = i + 1
  }
}
