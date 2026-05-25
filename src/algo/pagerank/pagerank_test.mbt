/// PageRank 算法测试套件
///
/// 覆盖基础功能、参数验证、属性验证和性能基准测试

// ============================================================================
// 辅助函数：构建测试图
// ============================================================================

///|
/// 创建简单有向链图 (3 节点)
///
/// 结构: 0 → 1 → 2
/// 预期: 节点0 rank 最高（无入边），节点2 rank 最低（无出边的 dangling）
fn make_simple_chain() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  g
}

///|
/// 创建星形图 (4 节点，中心为节点0)
///
/// 结构: 1→0, 2→0, 3→0 （所有叶子指向中心）
/// 预期: 节点0 rank 最高（汇聚所有入边）
fn make_star_graph() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0)
  |> ignore
  g
}

///|
/// 创建完全有向图 (3 节点，每对节点双向连接)
///
/// 结构: 0↔1, 1↔2, 2↔0
/// 预期: 所有节点 rank 均等（对称结构）
fn make_complete_directed_3() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 3 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  g
}

///|
/// 创建含 dangling node 的图 (3 节点)
///
/// 结构: 0 → 1, 0 → 2 （节点1和2都是 dangling nodes）
/// 预期: dangling rank 被均匀分配回所有节点
fn make_dangling_graph() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 3 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  |> ignore
  g
}

///|
/// 创建随机稀疏图用于性能测试 (n 节点, 约 2n 条边)
fn make_random_sparse_graph(n : Int) -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, int_to_double(i)) |> ignore
    i = i + 1
  }
  let mut j = 0
  while j < n {
    let src = j
    let dst = (j * 7 + 3) % n
    if src != dst {
      @core.GraphWritable::add_edge(g, @core.NodeId(src), @core.NodeId(dst), 1.0)
      |> ignore
    }
    let dst2 = (j * 13 + 7) % n
    if src != dst2 && dst2 != dst {
      @core.GraphWritable::add_edge(g, @core.NodeId(src), @core.NodeId(dst2), 1.0)
      |> ignore
    }
    j = j + 1
  }
  g
}

///|
/// 近似相等比较（浮点数容差）
fn approx_eq(a : Double, b : Double, eps : Double) -> Bool {
  let d = a - b
  if d < 0.0 {
    -d < eps
  } else {
    d < eps
  }
}

///|
/// Int 转 Double 辅助函数
fn int_to_double(x : Int) -> Double {
  x.to_double()
}

// ============================================================================
// 基础功能测试 (5 tests)
// ============================================================================

///|
test "simple_chain_correctness" {
  let g = make_simple_chain()
  let result = pagerank(g, 0.85, 100, 0.000001)
  assert_true(result.converged)
  assert_true(result.ranks.length() == 3)

  let r0 = result.get_rank(@core.NodeId(0))
  let r1 = result.get_rank(@core.NodeId(1))

  match (r0, r1) {
    (Some(a), Some(b)) => {
      assert_true(a > 0.0)
      assert_true(b > 0.0)
      assert_true(approx_eq(result.total_rank(), 1.0, 0.001))
    }
    _ => assert_true(false)
  }

  let r2 = result.get_rank(@core.NodeId(2))
  match r2 {
    Some(_) => assert_true(true)
    None => assert_true(false)
  }
}

///|
test "star_graph_center_highest" {
  let g = make_star_graph()
  let result = pagerank(g, 0.85, 100, 0.000001)
  assert_true(result.converged)

  let top = result.top_nodes(1)
  assert_true(top.length() == 1)
  let (node_id, _) = top[0]
  assert_eq(node_id.0, 0)
}

///|
test "complete_graph_uniform" {
  let g = make_complete_directed_3()
  let result = pagerank(g, 0.85, 100, 0.000001)
  assert_true(result.converged)
  assert_true(result.ranks.length() == 3)

  let r0 = result.get_rank(@core.NodeId(0))
  let r1 = result.get_rank(@core.NodeId(1))
  let r2 = result.get_rank(@core.NodeId(2))

  match (r0, r1, r2) {
    (Some(a), Some(b), Some(c)) => {
      assert_true(approx_eq(a, b, 0.01))
      assert_true(approx_eq(b, c, 0.01))
      assert_true(approx_eq(a, 1.0 / 3.0, 0.01))
    }
    _ => assert_true(false)
  }
}

///|
test "single_node_graph" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = pagerank(g, 0.85, 100, 0.000001)
  assert_true(result.ranks.length() == 1)
  assert_eq(result.iterations, 0)
  assert_true(result.converged)

  let r0 = result.get_rank(@core.NodeId(0))
  match r0 {
    Some(v) => assert_true(approx_eq(v, 1.0, 0.0000000001))
    None => assert_true(false)
  }
}

///|
test "empty_graph" {
  let g = @storage.new_directed()
  let result = pagerank(g, 0.85, 100, 0.000001)
  assert_true(result.ranks.length() == 0)
  assert_eq(result.iterations, 0)
  assert_true(result.converged)
  assert_true(approx_eq(result.total_rank(), 0.0, 0.0000000001))
}

// ============================================================================
// 参数验证测试 (3 tests)
// ============================================================================

///|
test "damping_factor_effect" {
  let g = make_simple_chain()

  let result_high = pagerank(g, 0.99, 100, 0.000001)
  let result_low = pagerank(g, 0.50, 100, 0.000001)

  let r0_high = result_high.get_rank(@core.NodeId(0))
  let r0_low = result_low.get_rank(@core.NodeId(0))

  match (r0_high, r0_low) {
    (Some(h), Some(l)) => {
      assert_true(h < l)
    }
    _ => assert_true(false)
  }
}

///|
test "max_iterations_truncation" {
  let g = make_simple_chain()

  let result_loose = pagerank(g, 0.85, 100, 0.000001)
  result_loose |> ignore

  let result_strict = pagerank(g, 0.85, 3, 0.0000000001)
  assert_true(!result_strict.converged || result_strict.iterations <= 3)
}

///|
test "tolerance_sensitivity" {
  let g = make_simple_chain()

  let result_tight = pagerank(g, 0.85, 200, 0.0000000001)
  let result_loose = pagerank(g, 0.85, 200, 0.01)

  assert_true(result_tight.iterations >= result_loose.iterations)
}

// ============================================================================
// 属性验证测试 (4 tests)
// ============================================================================

///|
test "rank_sum_approx_one" {
  let g = make_star_graph()
  let result = pagerank(g, 0.85, 100, 0.000001)
  let total = result.total_rank()
  assert_true(approx_eq(total, 1.0, 0.001))
}

///|
test "symmetric_graph_uniform_distribution" {
  let g = make_complete_directed_3()
  let result = pagerank(g, 0.85, 100, 0.000001)

  let expected = 1.0 / 3.0
  for r in result.ranks {
    assert_true(approx_eq(r, expected, 0.02))
  }
}

///|
test "dangling_nodes_handled" {
  let g = make_dangling_graph()
  let result = pagerank(g, 0.85, 100, 0.000001)
  assert_true(result.converged)

  let total = result.total_rank()
  assert_true(approx_eq(total, 1.0, 0.001))

  for r in result.ranks {
    assert_true(r > 0.0)
    assert_true(r < 1.0)
  }
}

///|
test "immutability_property" {
  let original_g = make_simple_chain()
  let nc_before = @core.GraphReadable::node_count(original_g)
  let ec_before = @core.GraphReadable::edge_count(original_g)
  let _result = pagerank(original_g, 0.85, 100, 0.000001)
  let nc_after = @core.GraphReadable::node_count(original_g)
  let ec_after = @core.GraphReadable::edge_count(original_g)
  assert_eq(nc_before, nc_after)
  assert_eq(ec_before, ec_after)
}

// ============================================================================
// 性能基准测试 (3 tests)
// ============================================================================

///|
test "performance_100_nodes" {
  let g = make_random_sparse_graph(100)
  let result = pagerank(g, 0.85, 100, 0.000001)
  assert_true(result.converged)
  assert_true(result.ranks.length() == 100)
}

///|
test "performance_top_nodes_ordering" {
  let g = make_star_graph()
  let result = pagerank(g, 0.85, 100, 0.000001)
  let top3 = result.top_nodes(3)
  assert_true(top3.length() == 3)

  let (_, v0) = top3[0]
  let (_, v1) = top3[1]
  let (_, v2) = top3[2]
  assert_true(v0 >= v1)
  assert_true(v1 >= v2)
}

///|
test "performance_reasonable_iterations" {
  let g = make_dangling_graph()
  let result = pagerank(g, 0.85, 100, 0.000001)
  assert_true(result.iterations > 0)
  assert_true(result.iterations <= 100)
  assert_true(result.converged)
}
