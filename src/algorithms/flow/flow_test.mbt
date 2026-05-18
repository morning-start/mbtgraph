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

fn make_classic_network() -> FlowNetwork {
  let net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 3.0)
  let net = net.add_edge(0, 2, 2.0)
  let net = net.add_edge(1, 2, 5.0)
  let net = net.add_edge(1, 3, 2.0)
  let net = net.add_edge(2, 3, 3.0)
  net
}

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

test "flow_network_new_empty" {
  let net = FlowNetwork::new(0)
  assert_true(net.node_count == 0)
  assert_true(net.capacity.length() == 0)
  assert_true(net.flow.length() == 0)
}

test "flow_network_new_normal" {
  let net = FlowNetwork::new(3)
  assert_true(net.node_count == 3)
  assert_true(net.capacity.length() == 3)
  assert_true(net.flow.length() == 3)
}

test "flow_network_add_edge_basic" {
  let net = make_simple_network()
  assert_true(net.capacity[0][1] == 10.0)
  assert_true(net.capacity[1][0] == 0.0)
  assert_true(net.flow[0][1] == 0.0)
  assert_true(net.flow[1][0] == 0.0)
}

test "flow_network_add_edge_out_of_bounds" {
  let net = FlowNetwork::new(2)
  let result = net.add_edge(0, 5, 10.0)
  assert_true(result.node_count == 2)
}

test "flow_network_add_edge_self_loop" {
  let net = FlowNetwork::new(3)
  let result = net.add_edge(1, 1, 5.0)
  assert_true(result.capacity[1][1] == 0.0)
}

// ============================================================================
// Edmonds-Karp 算法测试
// ============================================================================

test "edmonds_karp_simple_two_nodes" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 1)
  assert_true(result.max_flow == 10.0)
}

test "edmonds_karp_simple_flow_matrix_size" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 1)
  assert_true(result.flow_matrix.length() == 2)
  assert_true(result.flow_matrix[0].length() == 2)
}

test "edmonds_karp_simple_has_flow" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 1)
  match result.flow_matrix[0][1] {
    Some(flow) => { assert_true(flow > 9.9) }
    None => { assert_true(false) }
  }
}

test "edmonds_karp_classic_network_maxflow" {
  let net = make_classic_network()
  let result = edmonds_karp(net, 0, 3)
  assert_true(result.max_flow == 5.0)
}

test "edmonds_karp_classic_network_matrix_size" {
  let net = make_classic_network()
  let result = edmonds_karp(net, 0, 3)
  assert_true(result.flow_matrix.length() == 4)
  for i in 0..<4 {
    assert_true(result.flow_matrix[i].length() == 4)
  }
}

test "edmonds_karp_multi_path_clique" {
  let net = make_multi_path_network()
  let result = edmonds_karp(net, 0, 5)
  assert_true(result.max_flow == 23.0)
}

test "edmonds_karp_empty_graph" {
  let net = FlowNetwork::new(0)
  let result = edmonds_karp(net, 0, 1)
  assert_true(result.max_flow == 0.0)
  assert_true(result.flow_matrix.length() == 0)
}

test "edmonds_karp_source_equals_sink" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 0)
  assert_true(result.max_flow == 0.0)
  assert_true(result.flow_matrix.length() == 0)
}

test "edmonds_karp_invalid_source_negative" {
  let net = make_simple_network()
  let result = edmonds_karp(net, -1, 1)
  assert_true(result.max_flow == 0.0)
}

test "edmonds_karp_invalid_sink_out_of_bounds" {
  let net = make_simple_network()
  let result = edmonds_karp(net, 0, 99)
  assert_true(result.max_flow == 0.0)
}

test "edmonds_karp_no_path_exists" {
  let net = FlowNetwork::new(3)
  let net = net.add_edge(0, 1, 5.0)
  let result = edmonds_karp(net, 0, 2)
  assert_true(result.max_flow == 0.0)
}

test "edmonds_karp_result_immutability" {
  let net = make_simple_network()
  let _result = edmonds_karp(net, 0, 1)
  assert_true(net.flow[0][1] == 0.0)
}
