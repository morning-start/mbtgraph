///|
/// Dinic 最大流算法测试

// ============================================================================
// 辅助构建函数（复用 FlowNetwork 模式）
// ============================================================================

fn dinic_make_simple() -> FlowNetwork {
  let net = FlowNetwork::new(2)
  net.add_edge(0, 1, 10.0)
}

///|
fn dinic_make_4node() -> FlowNetwork {
  let net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 3.0)
  let net = net.add_edge(0, 2, 2.0)
  let net = net.add_edge(1, 3, 2.0)
  let net = net.add_edge(2, 3, 3.0)
  net
}

///|
fn dinic_make_clrs() -> FlowNetwork {
  let net = FlowNetwork::new(6)
  let net = net.add_edge(0, 1, 16.0)
  let net = net.add_edge(0, 2, 13.0)
  let net = net.add_edge(1, 2, 10.0)
  let net = net.add_edge(1, 3, 12.0)
  let net = net.add_edge(2, 1, 4.0)
  let net = net.add_edge(2, 4, 14.0)
  let net = net.add_edge(3, 2, 9.0)
  let net = net.add_edge(3, 5, 20.0)
  let net = net.add_edge(4, 3, 7.0)
  let net = net.add_edge(4, 5, 4.0)
  net
}

///|
fn dinic_make_parallel() -> FlowNetwork {
  let net = FlowNetwork::new(3)
  let net = net.add_edge(0, 1, 5.0)
  let net = net.add_edge(0, 1, 3.0)
  let net = net.add_edge(1, 2, 8.0)
  net
}

///|
fn dinic_make_diamond() -> FlowNetwork {
  let net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0)
  let net = net.add_edge(0, 2, 10.0)
  let net = net.add_edge(1, 3, 5.0)
  let net = net.add_edge(2, 3, 5.0)
  net
}

///|
fn dinic_make_bottleneck() -> FlowNetwork {
  let net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 100.0)
  let net = net.add_edge(0, 2, 100.0)
  let net = net.add_edge(1, 3, 1.0)
  let net = net.add_edge(2, 3, 1.0)
  net
}

// ============================================================================
// 基础功能测试：与 Edmonds-Karp 结果一致性
// ============================================================================

///|
test "dinic_simple_two_nodes" {
  let net = dinic_make_simple()
  let result = dinic(net, 0, 1)

  assert_true(result.max_flow > 9.9 && result.max_flow < 10.1)
}

///|
test "dinic_4node_multi_path" {
  let net = dinic_make_4node()
  let result = dinic(net, 0, 3)

  assert_true(result.max_flow > 3.9 && result.max_flow < 4.1)
}

///|
test "dinic_clrs_classic" {
  let net = dinic_make_clrs()
  let result = dinic(net, 0, 5)

  assert_true(result.max_flow > 22.9 && result.max_flow < 23.1)
}

///|
test "dinic_parallel_edges" {
  let net = dinic_make_parallel()
  let result = dinic(net, 0, 2)

  assert_true(result.max_flow > 2.9 && result.max_flow < 3.1)
}

///|
test "dinic_diamond_topology" {
  let net = dinic_make_diamond()
  let result = dinic(net, 0, 3)

  assert_true(result.max_flow > 9.9 && result.max_flow < 10.1)
}

///|
test "dinic_bottleneck" {
  let net = dinic_make_bottleneck()
  let result = dinic(net, 0, 3)

  assert_true(result.max_flow > 1.9 && result.max_flow < 2.1)
}

// ============================================================================
// 与 Edmonds-Karp 一致性验证
// ============================================================================

///|
test "dinic_vs_ek_consistency_simple" {
  let net = dinic_make_simple()

  let ek_result = edmonds_karp(net, 0, 1)
  let dinic_result = dinic(net, 0, 1)

  let diff = ek_result.max_flow - dinic_result.max_flow
  if diff < 0.0 {
    assert_true(-diff < 0.001)
  } else {
    assert_true(diff < 0.001)
  }
}

///|
test "dinic_vs_ek_consistency_clrs" {
  let net = dinic_make_clrs()

  let ek_result = edmonds_karp(net, 0, 5)
  let dinic_result = dinic(net, 0, 5)

  let diff = ek_result.max_flow - dinic_result.max_flow
  if diff < 0.0 {
    assert_true(-diff < 0.01)
  } else {
    assert_true(diff < 0.01)
  }
}

///|
test "dinic_vs_ek_consistency_parallel" {
  let net = dinic_make_parallel()

  let ek_result = edmonds_karp(net, 0, 2)
  let dinic_result = dinic(net, 0, 2)

  let diff = ek_result.max_flow - dinic_result.max_flow
  if diff < 0.0 {
    assert_true(-diff < 0.001)
  } else {
    assert_true(diff < 0.001)
  }
}

// ============================================================================
// 边界情况测试
// ============================================================================

///|
test "dinic_empty_network" {
  let net = FlowNetwork::new(0)
  let result = dinic(net, 0, 0)

  assert_true(result.max_flow == 0.0)
  assert_true(result.flow_matrix.length() == 0)
}

///|
test "dinic_source_equals_sink" {
  let net = dinic_make_simple()
  let result = dinic(net, 0, 0)

  assert_true(result.max_flow == 0.0)
  assert_true(result.flow_matrix.length() == 0)
}

///|
test "dinic_no_path_exists" {
  let net = FlowNetwork::new(3)
  let net = net.add_edge(0, 1, 10.0)
  let result = dinic(net, 0, 2)

  assert_true(result.max_flow < 0.0001)
}

///|
test "dinic_single_node" {
  let net = FlowNetwork::new(1)
  let result = dinic(net, 0, 0)

  assert_true(result.max_flow == 0.0)
  assert_true(result.flow_matrix.length() == 0)
}

// ============================================================================
// 属性验证测试
// ============================================================================

///|
test "property_dinic_pure_function_input_unchanged" {
  let net = dinic_make_clrs()
  let original_cap_01 = net.capacity[0][1]
  let original_flow_01 = net.flow[0][1]

  let _result = dinic(net, 0, 5)

  assert_true(net.capacity[0][1] == original_cap_01)
  assert_true(net.flow[0][1] == original_flow_01)
}

///|
test "property_dinic_flow_matrix_dimensions" {
  let net = dinic_make_4node()
  let result = dinic(net, 0, 3)

  assert_true(result.flow_matrix.length() == 4)
  assert_true(result.flow_matrix[0].length() == 4)
}

///|
test "property_dinic_max_flow_non_negative" {
  let nets : Array[FlowNetwork] = [
    dinic_make_simple(),
    dinic_make_4node(),
    dinic_make_clrs(),
  ]
  for net in nets {
    let result = dinic(net, 0, net.node_count - 1)
    assert_true(result.max_flow >= 0.0)
  }
}
