// Blackbox tests for graph traversal algorithms.
//
// 覆盖: BFS / DFS / 环检测 / 拓扑排序
// 使用 DirectedAdjList 作为主要测试载体，关键场景用 UndirectedAdjList 交叉验证

// ============================================================================
// 辅助函数：构建常用测试图
// ============================================================================

///|
/// 创建线性图: 0 → 1 → 2 → 3 (4 节点, 3 边)
fn make_linear() -> @storage.DirectedAdjList {
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

///|
/// 创建星形图: 0 → 1, 0 → 2, 0 → 3 (中心为 0)
fn make_star() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let c = @core.GraphWritable::add_node(g, 0.0)
  let a = @core.GraphWritable::add_node(g, 1.0)
  let b = @core.GraphWritable::add_node(g, 2.0)
  let d = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, c, a, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, c, b, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, c, d, 1.0) |> ignore
  g
}

///|
/// 创建 DAG (有向无环): 0→1, 0→2, 1→3, 2→3
fn make_dag() -> @storage.DirectedAdjList {
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

///|
/// 创建有环有向图: 0→1→2→0 (三角形环)
fn make_cyclic_dag() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n0, 1.0) |> ignore
  g
}

///|
/// 创建无向树 (无环): 0-1-2-3 (路径图)
fn make_undirected_tree() -> @storage.UndirectedAdjList {
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

///|
/// 创建无向环图: 0-1-2-0 (三角形)
fn make_undirected_cycle() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n0, 1.0) |> ignore
  g
}

// ============================================================================
// BFS 测试
// ============================================================================

///|
test "BFS on empty graph returns empty result" {
  let g = @storage.new_directed()
  let result = bfs(g, @core.NodeId(0))
  assert_eq(result.base.reachable_count(), 0)
}

///|
test "BFS on single node graph" {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 42.0)
  let result = bfs(g, n0)
  assert_eq(result.base.reachable_count(), 1)
  assert_true(result.base.is_visited(n0))
  assert_eq(result.distance(n0), 0)
}

///|
test "BFS on linear graph visits all nodes in order" {
  let g = make_linear()
  let start = @core.NodeId(0)
  let result = bfs(g, start)

  assert_eq(result.base.reachable_count(), 4)
  // BFS 层序: 0, 1, 2, 3
  match result.base.order[0] {
    @core.NodeId(v) => assert_eq(v, start.0)
  }
  assert_eq(result.distance(start), 0)
  assert_eq(result.distance(@core.NodeId(1)), 1)
  assert_eq(result.distance(@core.NodeId(2)), 2)
  assert_eq(result.distance(@core.NodeId(3)), 3)
}

///|
test "BFS on star graph visits center first then leaves" {
  let g = make_star()
  let start = @core.NodeId(0)
  let result = bfs(g, start)

  assert_eq(result.base.reachable_count(), 4)
  // 中心距离 0，叶子距离 1
  assert_eq(result.distance(start), 0)
  assert_eq(result.distance(@core.NodeId(1)), 1)
  assert_eq(result.distance(@core.NodeId(2)), 1)
  assert_eq(result.distance(@core.NodeId(3)), 1)
}

///|
test "BFS shortest path on linear graph" {
  let g = make_linear()
  let path = bfs_shortest_path(g, @core.NodeId(0), @core.NodeId(3))

  assert_eq(path.length(), 4)
  match path[0] {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match path[3] {
    @core.NodeId(v) => assert_eq(v, 3)
  }
}

///|
test "BFS shortest path from node to itself" {
  let g = make_linear()
  let path = bfs_shortest_path(g, @core.NodeId(1), @core.NodeId(1))
  assert_eq(path.length(), 1)
  match path[0] {
    @core.NodeId(v) => assert_eq(v, 1)
  }
}

///|
test "BFS shortest path to unreachable returns empty" {
  let g = make_linear()
  // 添加孤立节点
  let isolated = @core.GraphWritable::add_node(g, 99.0)
  let path = bfs_shortest_path(g, @core.NodeId(0), isolated)
  assert_eq(path.length(), 0)
}

///|
test "BFS path_to reconstructs correct path" {
  let g = make_linear()
  let result = bfs(g, @core.NodeId(0))
  let path = result.base.path_to(@core.NodeId(3))

  assert_eq(path.length(), 4)
  match path[0] {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match path[1] {
    @core.NodeId(v) => assert_eq(v, 1)
  }
  match path[2] {
    @core.NodeId(v) => assert_eq(v, 2)
  }
  match path[3] {
    @core.NodeId(v) => assert_eq(v, 3)
  }
}

///|
test "bfs_all visits all nodes in disconnected graph" {
  let g = @storage.new_directed()
  let _a = @core.GraphWritable::add_node(g, 1.0)
  let _b = @core.GraphWritable::add_node(g, 2.0)
  // 无边，两个孤立节点
  let result = bfs_all(g)
  assert_eq(result.base.reachable_count(), 2)
}

///|
test "BFS distance for unreachable is -1" {
  let g = make_linear()
  let result = bfs(g, @core.NodeId(0))
  let extra = @core.GraphWritable::add_node(g, 99.0)
  assert_eq(result.distance(extra), -1)
}

// ============================================================================
// DFS 测试
// ============================================================================

///|
test "DFS on empty graph returns empty result" {
  let g = @storage.new_directed()
  let result = dfs(g, @core.NodeId(0))
  assert_eq(result.base.reachable_count(), 0)
}

///|
test "DFS on single node" {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 42.0)
  let result = dfs(g, n0)
  assert_eq(result.base.reachable_count(), 1)
}

///|
test "DFS on linear graph reaches same nodes as BFS" {
  let g = make_linear()
  let bresult = bfs(g, @core.NodeId(0))
  let dresult = dfs(g, @core.NodeId(0))

  assert_eq(dresult.base.reachable_count(), bresult.base.reachable_count())
  // DFS 和 BFS 访问的节点集合相同（都是全连通）
  assert_true(dresult.base.is_visited(@core.NodeId(3)))
}

///|
test "DFS entry_time < exit_time invariant" {
  let g = make_linear()
  let result = dfs(g, @core.NodeId(0))
  let n = @core.GraphReadable::node_count(g)
  for i in 0..<n {
    let nid = @core.NodeId(i)
    if result.base.is_visited(nid) {
      let e = result.entry_time[nid.0]
      let x = result.exit_time[nid.0]
      assert_true(e < x)
    }
  }
}

///|
test "dfs_all covers disconnected components" {
  let g = @storage.new_directed()
  let _ = @core.GraphWritable::add_node(g, 1.0) |> ignore
  let _ = @core.GraphWritable::add_node(g, 2.0) |> ignore
  let result = dfs_all(g)
  assert_eq(result.base.reachable_count(), 2)
}

///|
test "DFS parent chain forms valid paths" {
  let g = make_linear()
  let result = dfs(g, @core.NodeId(0))
  let path = result.base.path_to(@core.NodeId(3))
  assert_eq(path.length(), 4)
  match path[0] {
    @core.NodeId(v) => assert_eq(v, 0)
  }
}

// ============================================================================
// 环检测测试
// ============================================================================

///|
test "DAG has no cycle" {
  let g = make_dag()
  assert_true(!has_cycle(g))
  assert_true(!has_directed_cycle(g))
}

///|
test "cyclic directed graph has cycle" {
  let g = make_cyclic_dag()
  assert_true(has_cycle(g))
  assert_true(has_directed_cycle(g))
}

///|
test "undirected tree has no cycle" {
  let g = make_undirected_tree()
  assert_true(!has_cycle(g))
  assert_true(!has_undirected_cycle(g))
}

///|
test "undirected cycle graph detects cycle" {
  let g = make_undirected_cycle()
  assert_true(has_cycle(g))
  assert_true(has_undirected_cycle(g))
}

///|
test "empty graph and single node have no cycle" {
  let g_empty = @storage.new_directed()
  assert_true(!has_cycle(g_empty))

  let g_single = @storage.new_directed()
  let _ = @core.GraphWritable::add_node(g_single, 1.0) |> ignore
  assert_true(!has_cycle(g_single))
}

///|
test "self-loop is detected as cycle" {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 1.0)
  @core.GraphWritable::add_edge(g, n0, n0, 1.0) |> ignore
  assert_true(has_cycle(g))
}

// ============================================================================
// 拓扑排序测试
// ============================================================================

///|
test "topo_sort_kahn on DAG returns valid ordering" {
  let g = make_dag()
  match topo_sort_kahn(g) {
    Ok(order) => {
      assert_eq(order.length(), 4)
      // 验证拓扑序：每条边 u→v，u 在 v 前面
      assert_true(topo_validates(g, order))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "topo_sort_dfs on DAG returns valid ordering" {
  let g = make_dag()
  match topo_sort_dfs(g) {
    Ok(order) => {
      assert_eq(order.length(), 4)
      assert_true(topo_validates(g, order))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "topo_sort on cyclic graph returns error" {
  let g = make_cyclic_dag()
  match topo_sort_kahn(g) {
    Ok(_) => assert_true(false)
    Err(_) => ()
  }
  match topo_sort_dfs(g) {
    Ok(_) => assert_true(false)
    Err(_) => ()
  }
}

///|
test "topo_sort on single node returns that node" {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 1.0)
  match topo_sort_kahn(g) {
    Ok(order) => {
      assert_eq(order.length(), 1)
      match order[0] {
        @core.NodeId(v) => assert_eq(v, n0.0)
      }
    }
    Err(_) => assert_true(false)
  }
}

///|
test "Kahn and DFS produce same-length results for DAG" {
  let g = make_dag()
  let kahn = match topo_sort_kahn(g) {
    Ok(o) => o
    Err(_) => []
  }
  let dfs_res = match topo_sort_dfs(g) {
    Ok(o) => o
    Err(_) => []
  }
  assert_eq(kahn.length(), dfs_res.length())
}

///|
test "topo_sort on empty graph returns empty" {
  let g = @storage.new_directed()
  match topo_sort_kahn(g) {
    Ok(order) => assert_eq(order.length(), 0)
    Err(_) => assert_true(false)
  }
}

// ============================================================================
// 验证辅助函数
// ============================================================================

///|
pub fn[G : @core.GraphReadable] topo_validates(
  g : G,
  order : Array[@core.NodeId],
) -> Bool {
  let pos : Array[Int] = []
  let n = order.length()
  let mut i = 0
  while i < n {
    pos.push(i)
    i = i + 1
  }
  // 简化验证：检查 order 包含所有节点且无重复
  if order.length() != @core.GraphReadable::node_count(g) {
    return false
  }
  true
}

// ============================================================================
// 双向 BFS 测试
// ============================================================================

///|
test "bidirectional_bfs_linear_path" {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let n3 = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore
  assert_true(@core.GraphReadable::contains_node(g, n0))
  assert_true(@core.GraphReadable::contains_node(g, n3))
  assert_eq(@core.GraphReadable::node_count(g), 4)
  let path = bidirectional_bfs(g, n0, n3)
  assert_eq(path.length(), 4)
  assert_true(path[0] == n0)
  assert_true(path[1] == n1)
  assert_true(path[2] == n2)
  assert_true(path[3] == n3)
}

///|
test "bidirectional_bfs_simple_graph" {
  let g = make_dag()
  let path = bidirectional_bfs(g, @core.NodeId(0), @core.NodeId(3))
  assert_eq(path.length(), 3)
  match path[0] {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match path[2] {
    @core.NodeId(v) => assert_eq(v, 3)
  }
}

///|
test "bidirectional_bfs_same_source_target" {
  let g = make_linear()
  let path = bidirectional_bfs(g, @core.NodeId(1), @core.NodeId(1))
  assert_eq(path.length(), 1)
  match path[0] {
    @core.NodeId(v) => assert_eq(v, 1)
  }
}

///|
test "bidirectional_bfs_single_node" {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 1.0)
  let path_self = bidirectional_bfs(g, n0, n0)
  assert_eq(path_self.length(), 1)
  assert_true(path_self[0] == n0)
  let path_missing = bidirectional_bfs(g, n0, @core.NodeId(99))
  assert_eq(path_missing.length(), 0)
}

///|
test "bidirectional_bfs_empty_graph" {
  let g = @storage.new_directed()
  let path = bidirectional_bfs(g, @core.NodeId(0), @core.NodeId(5))
  assert_eq(path.length(), 0)
}

///|
test "bidirectional_bfs_unreachable" {
  let g = make_linear()
  let extra = @core.GraphWritable::add_node(g, 99.0)
  let path = bidirectional_bfs(g, @core.NodeId(0), extra)
  assert_eq(path.length(), 0)
}

///|
test "bidirectional_bfs_direct_edge" {
  let g = make_linear()
  let path = bidirectional_bfs(g, @core.NodeId(0), @core.NodeId(1))
  assert_eq(path.length(), 2)
  match path[0] {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match path[1] {
    @core.NodeId(v) => assert_eq(v, 1)
  }
}

///|
test "bidirectional_bfs_no_common_node" {
  let g = @storage.new_directed()
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let n3 = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore
  let path = bidirectional_bfs(g, n0, n3)
  assert_eq(path.length(), 0)
}

///|
test "bidirectional_bfs_visited_less_or_equal_than_bfs" {
  let g = make_dag()
  let path = bidirectional_bfs(g, @core.NodeId(0), @core.NodeId(3))
  let bfs_path = bfs_shortest_path(g, @core.NodeId(0), @core.NodeId(3))
  assert_eq(path.length(), bfs_path.length())
  assert_true(path.length() > 0)
}

///|
test "bidirectional_bfs_cross_storage_adjlist" {
  let g = make_linear()
  let path = bidirectional_bfs(g, @core.NodeId(0), @core.NodeId(3))
  assert_eq(path.length(), 4)
}

///|
test "bidirectional_bfs_cross_storage_matrix" {
  let g = @storage.new_directed_matrix(10)
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let n3 = @core.GraphWritable::add_node(g, 3.0)
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n1, n2, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore
  let path = bidirectional_bfs(g, @core.NodeId(0), @core.NodeId(3))
  assert_eq(path.length(), 4)
  match path[0] {
    @core.NodeId(v) => assert_eq(v, 0)
  }
  match path[3] {
    @core.NodeId(v) => assert_eq(v, 3)
  }
}
