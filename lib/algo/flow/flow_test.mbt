///|
/// 网络流算法测试

// ============================================================================
// 辅助函数：构建测试流网络
// ============================================================================

fn make_simple_network() -> FlowNetwork {
  let net = FlowNetwork::new(2)
  let net = net.add_edge(0, 1, 10.0)
  net
}

///|
fn make_classic_network() -> FlowNetwork {
  let net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 3.0)
  let net = net.add_edge(0, 2, 2.0)
  let net = net.add_edge(1, 2, 5.0)
  let net = net.add_edge(1, 3, 2.0)
  let net = net.add_edge(2, 3, 3.0)
  net
}

///|
fn make_multi_path_network() -> FlowNetwork {
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

// ============================================================================
// FlowNetwork 基础测试
// ============================================================================

///|
test "flow_network_new_empty" {
  let net = FlowNetwork::new(0)
  assert_true(net.node_count == 0)
  assert_true(net.capacity.length() == 0)
  assert_true(net.flow.length() == 0)
}

///|
test "flow_network_new_normal" {
  let net = FlowNetwork::new(3)
  assert_true(net.node_count == 3)
  assert_true(net.capacity.length() == 3)
  assert_true(net.flow.length() == 3)
}

///|
test "flow_network_add_edge_basic" {
  let net = make_simple_network()
  assert_true(net.capacity[0][1] == 10.0)
  assert_true(net.capacity[1][0] == 0.0)
  assert_true(net.flow[0][1] == 0.0)
  assert_true(net.flow[1][0] == 0.0)
}

///|
test "flow_network_add_edge_out_of_bounds" {
  let net = FlowNetwork::new(2)
  let result = net.add_edge(0, 5, 10.0)
  assert_true(result.node_count == 2)
}

///|
test "flow_network_add_edge_self_loop" {
  let net = FlowNetwork::new(3)
  let result = net.add_edge(1, 1, 5.0)
  assert_true(result.capacity[1][1] == 0.0)
}

// ============================================================================
// Edmonds-Karp 算法测试
// ============================================================================

///|
test "edmonds_karp_simple_two_nodes" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 1)
  assert_true(result.max_flow == 10.0)
}

///|
test "edmonds_karp_simple_flow_matrix_size" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 1)
  assert_true(result.flow_matrix.length() == 2)
  assert_true(result.flow_matrix[0].length() == 2)
}

///|
test "edmonds_karp_simple_has_flow" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 1)
  match result.flow_matrix[0][1] {
    Some(flow) => assert_true(flow > 9.9)
    None => assert_true(false)
  }
}

///|
test "edmonds_karp_classic_network_maxflow" {
  let net = make_classic_network()
  let result = edmonds_karp(net, 0, 3)
  assert_true(result.max_flow == 5.0)
}

///|
test "edmonds_karp_classic_network_matrix_size" {
  let net = make_classic_network()
  let result = edmonds_karp(net, 0, 3)
  assert_true(result.flow_matrix.length() == 4)
  for i in 0..<4 {
    assert_true(result.flow_matrix[i].length() == 4)
  }
}

///|
test "edmonds_karp_multi_path_clique" {
  let net = make_multi_path_network()
  let result = edmonds_karp(net, 0, 5)
  assert_true(result.max_flow == 23.0)
}

///|
test "edmonds_karp_empty_graph" {
  let net = FlowNetwork::new(0)
  let result = edmonds_karp(net, 0, 1)
  assert_true(result.max_flow == 0.0)
  assert_true(result.flow_matrix.length() == 0)
}

///|
test "edmonds_karp_source_equals_sink" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 0)
  assert_true(result.max_flow == 0.0)
  assert_true(result.flow_matrix.length() == 0)
}

///|
test "edmonds_karp_invalid_source_negative" {
  let net = make_simple_network()
  let result = edmonds_karp(net, -1, 1)
  assert_true(result.max_flow == 0.0)
}

///|
test "edmonds_karp_invalid_sink_out_of_bounds" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 99)
  assert_true(result.max_flow == 0.0)
}

///|
test "edmonds_karp_no_path_exists" {
  let net = FlowNetwork::new(3)
  let net = net.add_edge(0, 1, 5.0)
  let result = edmonds_karp(net, 0, 2)
  assert_true(result.max_flow == 0.0)
}

///|
test "edmonds_karp_result_immutability" {
  let net = make_simple_network()
  let _result = edmonds_karp(net, 0, 1)
  assert_true(net.flow[0][1] == 0.0)
}

// ============================================================================
// 辅助函数：构建费用流网络
// ============================================================================

///|
fn make_simple_cost_network() -> CostFlowNetwork {
  let net = CostFlowNetwork::new(2)
  let net = net.add_edge(0, 1, 10.0, 5.0)
  net
}

///|
fn make_three_node_chain_network() -> CostFlowNetwork {
  let net = CostFlowNetwork::new(3)
  let net = net.add_edge(0, 1, 10.0, 5.0)
  let net = net.add_edge(1, 2, 10.0, 3.0)
  net
}

///|
fn make_parallel_cost_network() -> CostFlowNetwork {
  let net = CostFlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0, 1.0)
  let net = net.add_edge(0, 2, 10.0, 10.0)
  let net = net.add_edge(1, 3, 10.0, 1.0)
  net
}

///|
fn make_serial_parallel_cost_network() -> CostFlowNetwork {
  let net = CostFlowNetwork::new(5)
  let net = net.add_edge(0, 1, 10.0, 1.0)
  let net = net.add_edge(0, 2, 5.0, 10.0)
  let net = net.add_edge(1, 3, 10.0, 1.0)
  let net = net.add_edge(2, 3, 5.0, 10.0)
  let net = net.add_edge(3, 4, 15.0, 1.0)
  net
}

///|
fn make_zero_cost_network() -> CostFlowNetwork {
  let net = CostFlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0, 0.0)
  let net = net.add_edge(0, 2, 10.0, 5.0)
  let net = net.add_edge(1, 3, 10.0, 0.0)
  let net = net.add_edge(2, 3, 10.0, 5.0)
  net
}

///|
fn make_flow_split_network() -> CostFlowNetwork {
  let net = CostFlowNetwork::new(4)
  let net = net.add_edge(0, 1, 5.0, 1.0)
  let net = net.add_edge(0, 2, 10.0, 1.0)
  let net = net.add_edge(1, 3, 5.0, 1.0)
  let net = net.add_edge(2, 3, 10.0, 1.0)
  net
}

///|
fn make_asymmetric_cost_network() -> CostFlowNetwork {
  let net = CostFlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0, 3.0)
  let net = net.add_edge(0, 2, 10.0, 10.0)
  let net = net.add_edge(1, 3, 5.0, 1.0)
  let net = net.add_edge(2, 3, 10.0, 10.0)
  net
}

///|
fn make_saturation_network() -> CostFlowNetwork {
  let net = CostFlowNetwork::new(3)
  let net = net.add_edge(0, 1, 8.0, 2.0)
  let net = net.add_edge(0, 2, 7.0, 3.0)
  let net = net.add_edge(1, 2, 5.0, 1.0)
  net
}

// ============================================================================
// 最小费用最大流 — 基础正确性测试
// ============================================================================

///|
test "mcmf_simple_two_node" {
  let net = make_simple_cost_network()
  let result = min_cost_max_flow(net, 0, 1)
  assert_true(result.max_flow == 10.0)
  assert_true(result.min_cost == 50.0)
}

///|
test "mcmf_three_node_chain" {
  let net = make_three_node_chain_network()
  let result = min_cost_max_flow(net, 0, 2)
  assert_true(result.max_flow == 10.0)
  assert_true(result.min_cost == 80.0)
}

///|
test "mcmf_parallel_paths" {
  let net = make_parallel_cost_network()
  let result = min_cost_max_flow(net, 0, 3)
  assert_true(result.max_flow == 10.0)
  assert_true(result.min_cost == 20.0)
}

///|
test "mcmf_serial_parallel" {
  let net = make_serial_parallel_cost_network()
  let result = min_cost_max_flow(net, 0, 4)
  assert_true(result.max_flow == 15.0)
  assert_true(result.min_cost == 135.0)
}

///|
test "mcmf_zero_cost_edge" {
  let net = make_zero_cost_network()
  let result = min_cost_max_flow(net, 0, 3)
  assert_true(result.max_flow == 20.0)
  assert_true(result.min_cost == 100.0)
}

///|
test "mcmf_zero_flow_no_demand" {
  let net = CostFlowNetwork::new(3)
  let net = net.add_edge(0, 1, 5.0, 3.0)
  let result = min_cost_max_flow(net, 0, 2)
  assert_true(result.max_flow == 0.0)
  assert_true(result.min_cost == 0.0)
  assert_true(result.flow_matrix.length() == 3)
}

///|
test "mcmf_single_node" {
  let net = CostFlowNetwork::new(1)
  let result = min_cost_max_flow(net, 0, 0)
  assert_true(result.max_flow == 0.0)
  assert_true(result.min_cost == 0.0)
  assert_true(result.flow_matrix.length() == 0)
}

///|
test "mcmf_two_nodes_no_edge" {
  let net = CostFlowNetwork::new(2)
  let result = min_cost_max_flow(net, 0, 1)
  assert_true(result.max_flow == 0.0)
  assert_true(result.min_cost == 0.0)
  assert_true(result.flow_matrix.length() == 2)
}

// ============================================================================
// 最小费用最大流 — 边界情况测试
// ============================================================================

///|
test "mcmf_high_cost_path_preferred_over_low_cost" {
  let net = CostFlowNetwork::new(4)
  let net = net.add_edge(0, 1, 5.0, 1.0)
  let net = net.add_edge(0, 2, 10.0, 10.0)
  let net = net.add_edge(1, 3, 5.0, 1.0)
  let net = net.add_edge(2, 3, 10.0, 10.0)
  let result = min_cost_max_flow(net, 0, 3)
  assert_true(result.max_flow == 15.0)
  assert_true(result.min_cost == 210.0)
}

///|
test "mcmf_flow_must_split" {
  let net = make_flow_split_network()
  let result = min_cost_max_flow(net, 0, 3)
  assert_true(result.max_flow == 15.0)
  assert_true(result.min_cost == 30.0)
}

///|
test "mcmf_asymmetric_cost" {
  let net = make_asymmetric_cost_network()
  let result = min_cost_max_flow(net, 0, 3)
  assert_true(result.max_flow == 15.0)
  match result.flow_matrix[0][1] {
    Some(v) => assert_true(v > 4.0 && v < 6.0)
    None => assert_true(false)
  }
  match result.flow_matrix[1][3] {
    Some(v) => assert_true(v > 4.0 && v < 6.0)
    None => assert_true(false)
  }
  assert_true(result.min_cost > 219.0)
  assert_true(result.min_cost < 221.0)
}

///|
test "mcmf_saturation_behavior" {
  let net = make_saturation_network()
  let result = min_cost_max_flow(net, 0, 2)
  assert_true(result.max_flow == 12.0)
  assert_true(result.min_cost == 36.0)
}

///|
test "mcmf_larger_cost_flow_network" {
  let net = CostFlowNetwork::new(6)
  let net = net.add_edge(0, 1, 10.0, 2.0)
  let net = net.add_edge(0, 2, 8.0, 5.0)
  let net = net.add_edge(1, 3, 6.0, 1.0)
  let net = net.add_edge(1, 2, 4.0, 3.0)
  let net = net.add_edge(2, 4, 10.0, 2.0)
  let net = net.add_edge(3, 5, 6.0, 4.0)
  let net = net.add_edge(4, 5, 10.0, 1.0)
  let net = net.add_edge(3, 4, 5.0, 1.0)
  let result = min_cost_max_flow(net, 0, 5)
  assert_true(result.max_flow > 0.0)
  assert_true(result.min_cost > 0.0)
  assert_true(result.flow_matrix.length() == 6)
}

// ============================================================================
// 最小费用最大流 — 性能验证测试
// ============================================================================

///|
test "mcmf_flow_value_valid" {
  let net = make_simple_cost_network()
  let result = min_cost_max_flow(net, 0, 1)
  assert_true(result.max_flow <= 10.0)
  match result.flow_matrix[0][1] {
    Some(f) => {
      assert_true(f <= 10.0)
      assert_true(f == result.max_flow)
    }
    None => assert_true(false)
  }
}

///|
test "mcmf_cost_non_negative" {
  let net = make_simple_cost_network()
  let result = min_cost_max_flow(net, 0, 1)
  assert_true(result.min_cost >= 0.0)
}

///|
test "mcmf_conservation" {
  let net = make_serial_parallel_cost_network()
  let result = min_cost_max_flow(net, 0, 4)
  // Verify flow conservation at intermediate nodes
  // Node 1: incoming from 0, outgoing to 3
  let mut in_1 = 0.0
  let mut out_1 = 0.0
  for i in 0..<result.flow_matrix.length() {
    match result.flow_matrix[i][1] {
      Some(v) => in_1 = in_1 + v
      None => ()
    }
    match result.flow_matrix[1][i] {
      Some(v) => out_1 = out_1 + v
      None => ()
    }
  }
  assert_true((in_1 - out_1).abs() < 0.001)
}
