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

///|
/// 创建简单路径图（2个奇度节点，有欧拉路径但无回路）
///
/// 结构：0-1-2（线性链，3节点2边）
/// 度数：节点0=1(奇), 节点1=2(偶), 节点2=1(奇)
fn make_simple_path_graph() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
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
/// 创建偶数度图（用于测试欧拉回路边覆盖属性）
///
/// 结构：矩形 + 两条对角线（但调整使所有节点度数为偶数）
/// 使用"沙漏"形状：两个三角形共享一个节点
/// 节点：0-1-2-0 (三角形1) 和 0-3-4-0 (三角形2)
/// 度数：节点0=4(偶), 节点1=2(偶), 节点2=2(偶), 节点3=2(偶), 节点4=2(偶)
/// 总边数 = 6 条
fn make_six_edge_even_graph() -> @storage.UndirectedAdjList {
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

// ============================================================================
// Hierholzer 算法 - 欧拉回路查找测试
// ============================================================================

///|
test "find_euler_circuit_triangle" {
  let g = make_triangle_graph()
  let result = find_euler_circuit_undirected(g)
  assert_true(result.exists)
  assert_eq(result.circuit.length(), 3)
}

///|
test "find_euler_path_simple_path" {
  let g = make_simple_path_graph()
  let result = find_euler_path_undirected(g)
  assert_true(result.exists)
  assert_true(result.path.length() > 0)
}

///|
test "edge_coverage_property" {
  let g = make_six_edge_even_graph()
  let result = find_euler_circuit_undirected(g)
  assert_true(result.exists)
  assert_eq(result.circuit.length(), 6)
}

// ============================================================================
// 有向图欧拉路径/回路测试
// ============================================================================

///|
/// 创建有向环图（n 个节点）
///
/// 结构：0→1→2→...→(n-1)→0
/// 所有节点入度=出度=1，存在欧拉回路
fn make_directed_cycle(n : Int) -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let mut j = 0
  while j < n {
    let next = (j + 1) % n
    @core.GraphWritable::add_edge(g, @core.NodeId(j), @core.NodeId(next), 1.0)
      |> ignore
    j = j + 1
  }
  g
}

///|
/// 创建有向链图（3 个节点）
///
/// 结构：0→1, 1→2
/// 节点0: 出度=1, 入度=0（起点候选）
/// 节点1: 出度=1, 入度=1（平衡）
/// 节点2: 出度=0, 入度=1（终点候选）
fn make_directed_chain() -> @storage.DirectedAdjList {
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
test "directed_cycle_has_euler_circuit" {
  let g = make_directed_cycle(3)
  assert_true(has_euler_circuit_directed(g))
}

///|
test "directed_chain_has_euler_path" {
  let g = make_directed_chain()
  assert_true(has_euler_path_directed(g))
  assert_true(!has_euler_circuit_directed(g))
}

///|
test "find_directed_cycle_circuit" {
  let g = make_directed_cycle(4)
  let result = find_euler_circuit_directed(g)
  assert_true(result.exists)
  assert_eq(result.circuit.length(), 4)
}

///|
test "find_directed_chain_path" {
  let g = make_directed_chain()
  let result = find_euler_path_directed(g)
  assert_true(result.exists)
  assert_true(result.path.length() == 2)
}
