///|
/// 欧拉路径算法测试

// ============================================================================
// 辅助函数：构建测试图
// ============================================================================

///|
/// 创建三角形图（3节点完全图）
///
/// 结构：0-1, 1-2, 2-0
/// 所有节点度数为 2（偶数），存在欧拉回路
fn make_triangle_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
    |> ignore
  g
}

///|
/// 创建房子图（5节点）
///
/// 结构：正方形(0-1-2-3-0) + 屋顶(2-4-3)
/// 边：0-1, 1-2, 2-3, 3-0, 2-4, 4-3
/// 度数：节点0=2, 节点1=2, 节点2=3, 节点3=3, 节点4=2
/// 奇度节点：2和3（共2个），存在欧拉路径但无欧拉回路
fn make_house_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(4), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(3), 1.0)
    |> ignore
  g
}

///|
/// 创建"领结"图（4个奇度节点，无欧拉路径）
///
/// 结构：两个三角形共享一个节点
/// 节点：0-1-2-0 (三角形1) 和 0-3-4-0 (三角形2)
/// 度数：节点0=4(偶), 节点1=2(偶), 节点2=2(偶), 节点3=2(偶), 节点4=2(偶)
/// 实际上这个图所有节点都是偶度，需要重新设计
fn make_bowtie_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(0), 1.0)
    |> ignore
  g
}

///|
/// 创建简单路径图（2个奇度节点，有欧拉路径但无回路）
///
/// 结构：0-1-2-3（线性链）
/// 度数：节点0=1(奇), 节点1=2(偶), 节点2=2(偶), 节点3=1(奇)
fn make_path_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
    |> ignore
  g
}

///|
/// 创建不连通图（两个独立三角形，无欧拉路径/回路）
///
/// 三角形1: 0-1-2-0
/// 三角形2: 3-4-5-3
fn make_disconnected_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0)
    |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(5), @core.NodeId(3), 1.0)
    |> ignore
  g
}

// ============================================================================
// 三角形图测试（欧拉回路存在）
// ============================================================================

///|
test "triangle_has_euler_circuit_undirected" {
  let g = make_triangle_graph()
  assert_true(has_euler_circuit_undirected(g))
}

///|
test "triangle_has_euler_path_undirected" {
  let g = make_triangle_graph()
  assert_true(has_euler_path_undirected(g))
}

// ============================================================================
// 房子图测试（有欧拉路径但无欧拉回路）
// ============================================================================

///|
test "house_graph_no_euler_circuit_undirected" {
  let g = make_house_graph()
  assert_true(!has_euler_circuit_undirected(g))
}

///|
test "house_graph_has_euler_path_undirected" {
  let g = make_house_graph()
  assert_true(has_euler_path_undirected(g))
}

// ============================================================================
// 领结图测试（欧拉回路存在 - 所有节点偶度）
// ============================================================================

///|
test "bowtie_has_euler_circuit_undirected" {
  let g = make_bowtie_graph()
  assert_true(has_euler_circuit_undirected(g))
}

///|
test "bowtie_has_euler_path_undirected" {
  let g = make_bowtie_graph()
  assert_true(has_euler_path_undirected(g))
}

// ============================================================================
// 简单路径图测试（有欧拉路径但无欧拉回路）
// ============================================================================

///|
test "path_graph_no_euler_circuit_undirected" {
  let g = make_path_graph()
  assert_true(!has_euler_circuit_undirected(g))
}

///|
test "path_graph_has_euler_path_undirected" {
  let g = make_path_graph()
  assert_true(has_euler_path_undirected(g))
}

// ============================================================================
// 不连通图测试（无欧拉路径和回路）
// ============================================================================

///|
test "disconnected_no_euler_path_undirected" {
  let g = make_disconnected_graph()
  assert_true(!has_euler_path_undirected(g))
}

///|
test "disconnected_no_euler_circuit_undirected" {
  let g = make_disconnected_graph()
  assert_true(!has_euler_circuit_undirected(g))
}
