/// 密集子图测试

// ============================================================================
// 辅助: 构建测试图
// ============================================================================

///|
/// 三角形: 0-1, 1-2, 2-0
fn make_triangle() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore
  g
}

///|
/// 完全图 K4: 4 节点全连接
fn make_k4() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  // 所有 6 条边
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  g
}

///|
/// 路径图: 0-1-2-3 (4 节点线性链)
fn make_path4() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  g
}

///|
/// 带三角形和桥的混合图:
/// 0-1-2-0 (三角形) + 2-3-4 (链)
fn make_mixed_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 5 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0) |> ignore
  g
}

///|
/// 空图
fn make_empty() -> @storage.UndirectedAdjList {
  @storage.new_undirected()
}

// ============================================================================
// K-Core 测试
// ============================================================================

///|
test "kcore_triangle" {
  let g = make_triangle()
  let result = k_core_decomposition(g)
  // 三角形中所有节点度数为 2 → core = 2
  assert_eq(result.core_number(@core.NodeId(0)), 2)
  assert_eq(result.core_number(@core.NodeId(1)), 2)
  assert_eq(result.core_number(@core.NodeId(2)), 2)
}

///|
test "kcore_k4" {
  let g = make_k4()
  let result = k_core_decomposition(g)
  // K4 中所有节点度数为 3 → core = 3
  assert_eq(result.core_number(@core.NodeId(0)), 3)
  assert_eq(result.core_number(@core.NodeId(1)), 3)
  assert_eq(result.core_number(@core.NodeId(2)), 3)
  assert_eq(result.core_number(@core.NodeId(3)), 3)
}

///|
test "kcore_path4" {
  let g = make_path4()
  let result = k_core_decomposition(g)
  // 路径图中所有节点 deg <= 2
  // 端点 0 和 3 度数为 1 → core = 1
  // 中间点 1 和 2 度数为 2, 但去掉端点后度降为 1 → core = 1
  assert_eq(result.core_number(@core.NodeId(0)), 1)
  assert_eq(result.core_number(@core.NodeId(1)), 1)
  assert_eq(result.core_number(@core.NodeId(2)), 1)
  assert_eq(result.core_number(@core.NodeId(3)), 1)
}

///|
test "kcore_mixed" {
  let g = make_mixed_graph()
  let result = k_core_decomposition(g)
  // 节点 0,1,2 在三角形中 → core = 2
  // 节点 3,4 在链上 → core = 1
  assert_eq(result.core_number(@core.NodeId(0)), 2)
  assert_eq(result.core_number(@core.NodeId(1)), 2)
  assert_eq(result.core_number(@core.NodeId(2)), 2)
  assert_eq(result.core_number(@core.NodeId(3)), 1)
  assert_eq(result.core_number(@core.NodeId(4)), 1)
}

///|
test "kcore_empty" {
  let g = make_empty()
  let result = k_core_decomposition(g)
  // 空图: core 数组为空
  assert_eq(result.core.length(), 0)
}

// ============================================================================
// 三角形计数测试
// ============================================================================

///|
test "triangle_count_empty" {
  let g = make_empty()
  let result = count_triangles(g)
  assert_eq(result.total, 0)
}

///|
test "triangle_count_triangle" {
  let g = make_triangle()
  let result = count_triangles(g)
  // 1 个三角形, 每个节点参与 1 个
  assert_eq(result.total, 1)
  assert_eq(result.node_triangles(@core.NodeId(0)), 1)
  assert_eq(result.node_triangles(@core.NodeId(1)), 1)
  assert_eq(result.node_triangles(@core.NodeId(2)), 1)
}

///|
test "triangle_count_k4" {
  let g = make_k4()
  let result = count_triangles(g)
  // K4 有 4 个三角形, 每个节点参与 3 个
  assert_eq(result.total, 4)
  assert_eq(result.node_triangles(@core.NodeId(0)), 3)
  assert_eq(result.node_triangles(@core.NodeId(1)), 3)
  assert_eq(result.node_triangles(@core.NodeId(2)), 3)
  assert_eq(result.node_triangles(@core.NodeId(3)), 3)
}

///|
test "triangle_count_path4" {
  let g = make_path4()
  let result = count_triangles(g)
  // 路径图无三角形
  assert_eq(result.total, 0)
  assert_eq(result.node_triangles(@core.NodeId(0)), 0)
  assert_eq(result.node_triangles(@core.NodeId(1)), 0)
}

///|
test "triangle_count_mixed" {
  let g = make_mixed_graph()
  let result = count_triangles(g)
  // 只有节点 0,1,2 组成的一个三角形
  assert_eq(result.total, 1)
  assert_eq(result.node_triangles(@core.NodeId(0)), 1)
  assert_eq(result.node_triangles(@core.NodeId(1)), 1)
  assert_eq(result.node_triangles(@core.NodeId(2)), 1)
  assert_eq(result.node_triangles(@core.NodeId(3)), 0)
  assert_eq(result.node_triangles(@core.NodeId(4)), 0)
}

// ============================================================================
// K-Truss 测试
// ============================================================================

///|
test "ktruss_triangle" {
  let g = make_triangle()
  let result = k_truss_decomposition(g)
  // 三角形每条边参与 1 个三角形 → support = 1 → truss = 3
  let s01 = result.truss_number(@core.NodeId(0), @core.NodeId(1))
  let s12 = result.truss_number(@core.NodeId(1), @core.NodeId(2))
  let s20 = result.truss_number(@core.NodeId(2), @core.NodeId(0))
  match (s01, s12, s20) {
    (Some(a), Some(b), Some(c)) => {
      assert_eq(a, 3)
      assert_eq(b, 3)
      assert_eq(c, 3)
    }
    _ => assert_true(false)
  }
}

///|
test "ktruss_k4" {
  let g = make_k4()
  let result = k_truss_decomposition(g)
  // K4: 每条边参与 2 个三角形 → support = 2 → truss = 4
  let s01 = result.truss_number(@core.NodeId(0), @core.NodeId(1))
  match s01 {
    Some(v) => assert_eq(v, 4)
    _ => assert_true(false)
  }
}

///|
test "ktruss_path4" {
  let g = make_path4()
  let result = k_truss_decomposition(g)
  // 路径图无三角形 → support = 0 → truss = 2
  let s01 = result.truss_number(@core.NodeId(0), @core.NodeId(1))
  match s01 {
    Some(v) => assert_eq(v, 2)
    _ => assert_true(false)
  }
}

///|
test "ktruss_empty" {
  let g = make_empty()
  let result = k_truss_decomposition(g)
  let s01 = result.truss_number(@core.NodeId(0), @core.NodeId(1))
  assert_eq(s01, None)
}

// ============================================================================
// 聚类系数测试
// ============================================================================

///|
test "clustering_triangle" {
  let g = make_triangle()
  let cc = local_clustering_coefficient(g, @core.NodeId(0))
  // deg = 2, triangles = 1 → 1 / C(2,2) = 1/1 = 1.0
  assert_true((cc - 1.0).abs() < 0.0000000001)
}

///|
test "clustering_path4_endpoint" {
  let g = make_path4()
  let cc = local_clustering_coefficient(g, @core.NodeId(0))
  // deg = 1 → 0.0
  assert_true(cc < 0.0000000001)
}

///|
test "clustering_path4_middle" {
  let g = make_path4()
  let cc = local_clustering_coefficient(g, @core.NodeId(1))
  // deg = 2, triangles = 0 → 0/1 = 0.0
  assert_true(cc < 0.0000000001)
}

///|
test "clustering_k4" {
  let g = make_k4()
  // 所有节点 deg = 3, triangles = 3 → 3 / C(3,2) = 3/3 = 1.0
  let result = clustering_coefficients(g)
  assert_true((result.local_coefficient(@core.NodeId(0)) - 1.0).abs() < 0.0000000001)
  assert_true((result.global_coefficient() - 1.0).abs() < 0.0000000001)
}

///|
test "clustering_mixed" {
  let g = make_mixed_graph()
  // node 0: deg=2, triangles=1 → 1.0
  // node 1: deg=2, triangles=1 → 1.0
  // node 2: deg=3 (0,1,3), triangles=1 → 1/3
  // node 3: deg=1 → 0.0
  // node 4: deg=1 → 0.0
  // global: (1 + 1 + 0.333... + 0 + 0) / 5 = 0.4666...
  let result = clustering_coefficients(g)
  assert_true((result.local_coefficient(@core.NodeId(0)) - 1.0).abs() < 0.0000000001)
  assert_true((result.local_coefficient(@core.NodeId(2)) - 1.0 / 3.0).abs() < 0.0000000001)
  assert_true(result.local_coefficient(@core.NodeId(3)) < 0.0000000001)
  assert_true(result.local_coefficient(@core.NodeId(4)) < 0.0000000001)
  let expected_global = (1.0 + 1.0 + 1.0 / 3.0 + 0.0 + 0.0) / 5.0
  assert_true((result.global_coefficient() - expected_global).abs() < 0.0000000001)
}

///|
test "clustering_empty" {
  let g = make_empty()
  let result = clustering_coefficients(g)
  assert_eq(result.locals.length(), 0)
  assert_true(result.global < 0.0000000001)
}
