/// 链接预测测试

// ============================================================================
// 辅助: 构建小规模测试图
// ============================================================================

///|
/// 无向星形图: 0-1, 0-2, 0-3, 0-4
fn make_star_undirected() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(4), 1.0) |> ignore
  g
}

///|
/// 无向三角形: 0-1, 1-2, 2-0
fn make_triangle_undirected() -> @storage.UndirectedAdjList {
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
/// 空无向图
fn make_empty() -> @storage.UndirectedAdjList {
  @storage.new_undirected()
}

///|
/// 两个独立节点（无边）
fn make_disconnected_pair() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let _ = @core.GraphWritable::add_node(g, 0.0)
  let _ = @core.GraphWritable::add_node(g, 0.0)
  g
}

// ============================================================================
// 公共邻居测试
// ============================================================================

///|
test "common_neighbors_star" {
  let g = make_star_undirected()
  // N(1)={0}, N(2)={0} → common={0} → 1
  assert_eq(common_neighbors(g, @core.NodeId(1), @core.NodeId(2)), 1)
}

///|
test "common_neighbors_triangle" {
  let g = make_triangle_undirected()
  // N(0)={1,2}, N(1)={0,2} → common={2} → 1
  assert_eq(common_neighbors(g, @core.NodeId(0), @core.NodeId(1)), 1)
  // N(1)={0,2}, N(2)={0,1} → common={0} → 1
  assert_eq(common_neighbors(g, @core.NodeId(1), @core.NodeId(2)), 1)
}

///|
test "common_neighbors_same_node" {
  let g = make_star_undirected()
  // N(0)={1,2,3,4}, self intersection → 4
  assert_eq(common_neighbors(g, @core.NodeId(0), @core.NodeId(0)), 4)
}

///|
test "common_neighbors_disconnected" {
  let g = make_disconnected_pair()
  assert_eq(common_neighbors(g, @core.NodeId(0), @core.NodeId(1)), 0)
}

// ============================================================================
// Jaccard 系数测试
// ============================================================================

///|
test "jaccard_star" {
  let g = make_star_undirected()
  let j = jaccard_coefficient(g, @core.NodeId(1), @core.NodeId(2))
  // N(1)={0}, N(2)={0} → inter=1, union=1 → 1.0
  assert_true((j - 1.0).abs() < 0.0000000001)
}

///|
test "jaccard_triangle" {
  let g = make_triangle_undirected()
  let j = jaccard_coefficient(g, @core.NodeId(0), @core.NodeId(1))
  // N(0)={1,2}, N(1)={0,2} → inter={2}=1, union={0,1,2}=3 → 1/3
  assert_true((j - 1.0 / 3.0).abs() < 0.0000000001)
}

///|
test "jaccard_same_node" {
  let g = make_star_undirected()
  let j = jaccard_coefficient(g, @core.NodeId(0), @core.NodeId(0))
  assert_true((j - 1.0).abs() < 0.0000000001)
}

///|
test "jaccard_disconnected" {
  let g = make_disconnected_pair()
  let j = jaccard_coefficient(g, @core.NodeId(0), @core.NodeId(1))
  assert_true(j < 0.0000000001)
}

// ============================================================================
// Adamic-Adar 测试
// ============================================================================

///|
test "adamic_adar_star" {
  let g = make_star_undirected()
  let aa = adamic_adar_index(g, @core.NodeId(1), @core.NodeId(2))
  // common={0}, deg(0)=4 → 1/ln(4)
  let expected = 1.0 / @math.ln(4.0)
  assert_true((aa - expected).abs() < 0.0000000001)
}

///|
test "adamic_adar_triangle" {
  let g = make_triangle_undirected()
  let aa = adamic_adar_index(g, @core.NodeId(0), @core.NodeId(1))
  // common={2}, deg(2)=2 → 1/ln(2)
  let expected = 1.0 / @math.ln(2.0)
  assert_true((aa - expected).abs() < 0.0000000001)
}

///|
test "adamic_adar_disconnected" {
  let g = make_disconnected_pair()
  let aa = adamic_adar_index(g, @core.NodeId(0), @core.NodeId(1))
  assert_true(aa < 0.0000000001)
}

// ============================================================================
// 优先连接测试
// ============================================================================

///|
test "preferential_attachment_star" {
  let g = make_star_undirected()
  // deg(1)=1, deg(2)=1 → 1*1=1
  let pa = preferential_attachment(g, @core.NodeId(1), @core.NodeId(2))
  assert_true((pa - 1.0).abs() < 0.0000000001)
}

///|
test "preferential_attachment_center" {
  let g = make_star_undirected()
  // deg(0)=4 → 4*4=16
  let pa = preferential_attachment(g, @core.NodeId(0), @core.NodeId(0))
  assert_true((pa - 16.0).abs() < 0.0000000001)
}

///|
test "preferential_attachment_disconnected" {
  let g = make_disconnected_pair()
  let pa = preferential_attachment(g, @core.NodeId(0), @core.NodeId(1))
  assert_true(pa < 0.0000000001)
}

// ============================================================================
// 资源分配测试
// ============================================================================

///|
test "resource_allocation_star" {
  let g = make_star_undirected()
  let ra = resource_allocation(g, @core.NodeId(1), @core.NodeId(2))
  // common={0}, deg(0)=4 → 1/4=0.25
  assert_true((ra - 0.25).abs() < 0.0000000001)
}

///|
test "resource_allocation_triangle" {
  let g = make_triangle_undirected()
  let ra = resource_allocation(g, @core.NodeId(0), @core.NodeId(1))
  // common={2}, deg(2)=2 → 1/2=0.5
  assert_true((ra - 0.5).abs() < 0.0000000001)
}

///|
test "resource_allocation_disconnected" {
  let g = make_disconnected_pair()
  let ra = resource_allocation(g, @core.NodeId(0), @core.NodeId(1))
  assert_true(ra < 0.0000000001)
}

// ============================================================================
// 集成测试
// ============================================================================

///|
test "link_prediction_score_all_metrics" {
  let g = make_star_undirected()
  let score = link_prediction_score(g, @core.NodeId(1), @core.NodeId(2))
  assert_eq(score.common_neighbors, 1)
  assert_true((score.jaccard - 1.0).abs() < 0.0000000001)
  assert_true(score.adamic_adar > 0.0)
  assert_true((score.preferential_attachment - 1.0).abs() < 0.0000000001)
  assert_true((score.resource_allocation - 0.25).abs() < 0.0000000001)
  let (u, v) = score.node_pair()
  assert_eq(u.0, 1)
  assert_eq(v.0, 2)
}

///|
test "link_prediction_empty_graph" {
  let g = make_empty()
  let cn = common_neighbors(g, @core.NodeId(0), @core.NodeId(1))
  assert_eq(cn, 0)
  let j = jaccard_coefficient(g, @core.NodeId(0), @core.NodeId(1))
  assert_true(j < 0.0000000001)
  let pa = preferential_attachment(g, @core.NodeId(0), @core.NodeId(1))
  assert_true(pa < 0.0000000001)
}
