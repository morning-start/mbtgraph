// ============================================================================
// 最小 s-t 割测试
// ============================================================================

///|
fn make_cut_network() -> FlowNetwork {
  let net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0)
  let net = net.add_edge(0, 2, 10.0)
  let net = net.add_edge(1, 3, 10.0)
  let net = net.add_edge(2, 3, 10.0)
  let net = net.add_edge(1, 2, 1.0)
  net
}

///|
test "min_s_t_cut: basic 4-node network" {
  let net = make_cut_network()
  let result = min_s_t_cut(net, 0, 3)
  assert_true(result.cut_capacity > 0.0)
  // Max flow = 20, so min cut capacity = 20
  assert_true(result.cut_capacity - 20.0 < 0.001)
  // s_side should contain 0 (and maybe others)
  assert_true(result.s_side.length() > 0)
  assert_true(result.t_side.length() > 0)
  // Source in s_side, sink in t_side
  let s_has_source = gn_contains_int(result.s_side, 0)
  let t_has_sink = gn_contains_int(result.t_side, 3)
  assert_true(s_has_source)
  assert_true(t_has_sink)
}

///|
test "min_s_t_cut: empty network" {
  let net = FlowNetwork::new(0)
  let result = min_s_t_cut(net, 0, 1)
  assert_true(result.cut_capacity < 0.0001)
  assert_eq(result.s_side.length(), 0)
}

///|
test "min_s_t_cut: same source and sink" {
  let net = FlowNetwork::new(3)
  let net = net.add_edge(0, 1, 5.0)
  let result = min_s_t_cut(net, 0, 0)
  assert_true(result.cut_capacity < 0.0001)
  assert_eq(result.s_side.length(), 1)
}

///|
test "min_s_t_cut: bottleneck edge" {
  let net = FlowNetwork::new(3)
  let net = net.add_edge(0, 1, 100.0)
  let net = net.add_edge(1, 2, 1.0)
  let result = min_s_t_cut(net, 0, 2)
  // Max flow = 1 (bottleneck), so min cut capacity = 1
  assert_true(result.cut_capacity - 1.0 < 0.001)
}

///|
fn gn_contains_int(arr : Array[Int], val : Int) -> Bool {
  for x in arr {
    if x == val {
      return true
    }
  }
  false
}
