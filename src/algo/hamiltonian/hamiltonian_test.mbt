///|
/// Hamiltonian 模块测试套件
///
/// 测试覆盖：哈密顿路径/回路、TSP 算法

// ============================================================================
// 辅助构建函数
// ============================================================================

fn create_complete_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let mut i = 0
  while i < n {
    let mut j = i + 1
    while j < n {
      @storage.UndirectedAdjList::add_edge(g, @core.NodeId(i), @core.NodeId(j), 1.0) |> ignore
      j = j + 1
    }
    i = i + 1
  }
  g
}

fn create_cycle_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let mut i = 0
  while i < n {
    let next = (i + 1) % n
    @storage.UndirectedAdjList::add_edge(g, @core.NodeId(i), @core.NodeId(next), 1.0) |> ignore
    i = i + 1
  }
  g
}

fn create_path_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let mut i = 0
  while i < n - 1 {
    @storage.UndirectedAdjList::add_edge(g, @core.NodeId(i), @core.NodeId(i + 1), 1.0) |> ignore
    i = i + 1
  }
  g
}

fn create_star_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  if n >= 2 {
    let mut i = 1
    while i < n {
      @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(i), 1.0) |> ignore
      i = i + 1
    }
  }
  g
}

fn create_tsp_weights() -> Array[Array[Double]] {
  // 4 城市对称 TSP 示例
  [
    [0.0, 10.0, 15.0, 20.0],
    [10.0, 0.0, 35.0, 25.0],
    [15.0, 35.0, 0.0, 30.0],
    [20.0, 25.0, 30.0, 0.0],
  ]
}

// ============================================================================
// 快速检查测试
// ============================================================================

test "quick_check_empty_graph" {
  let g = create_complete_graph(0)
  assert_true(!has_hamiltonian_circuit_quick_check(g))
}

test "quick_check_single_node" {
  let g = create_complete_graph(1)
  assert_true(!has_hamiltonian_circuit_quick_check(g))
}

test "quick_check_two_nodes" {
  let g = create_complete_graph(2)
  assert_true(!has_hamiltonian_circuit_quick_check(g))
}

test "quick_check_complete_graph_k3" {
  let g = create_complete_graph(3)
  assert_true(has_hamiltonian_circuit_quick_check(g))
}

test "quick_check_cycle_5" {
  let g = create_cycle_graph(5)
  assert_true(has_hamiltonian_circuit_quick_check(g))
}

test "quick_check_star_graph" {
  // 星形图的叶子节点度数为 1，不满足条件
  let g = create_star_graph(5)
  assert_true(!has_hamiltonian_circuit_quick_check(g))
}

// ============================================================================
// 哈密顿路径测试
// ============================================================================

test "hamiltonian_path_empty" {
  let g = create_complete_graph(0)
  let result = find_hamiltonian_path_backtrack(g)
  assert_true(!result.exists)
  assert_eq(result.path.length(), 0)
}

test "hamiltonian_path_single_node" {
  let g = create_complete_graph(1)
  let result = find_hamiltonian_path_backtrack(g)
  assert_true(result.exists)
  assert_eq(result.path.length(), 1)
  assert_true(!result.is_circuit)
}

test "hamiltonian_path_complete_k4" {
  let g = create_complete_graph(4)
  let result = find_hamiltonian_path_backtrack(g)
  assert_true(result.exists)
  assert_eq(result.path.length(), 4)
}

test "hamiltonian_path_cycle_5" {
  let g = create_cycle_graph(5)
  let result = find_hamiltonian_path_backtrack(g)
  assert_true(result.exists)
  assert_eq(result.path.length(), 5)
}

test "hamiltonian_path_path_4" {
  let g = create_path_graph(4)
  let result = find_hamiltonian_path_backtrack(g)
  assert_true(result.exists)
  assert_eq(result.path.length(), 4)
}

// ============================================================================
// 哈密顿回路测试
// ============================================================================

test "hamiltonian_circuit_empty" {
  let g = create_complete_graph(0)
  let result = find_hamiltonian_circuit_backtrack(g)
  assert_true(!result.exists)
}

test "hamiltonian_circuit_complete_k4" {
  let g = create_complete_graph(4)
  let result = find_hamiltonian_circuit_backtrack(g)
  assert_true(result.exists)
  assert_true(result.is_circuit)
  assert_eq(result.path.length(), 4)
}

test "hamiltonian_circuit_cycle_5" {
  let g = create_cycle_graph(5)
  let result = find_hamiltonian_circuit_backtrack(g)
  assert_true(result.exists)
  assert_true(result.is_circuit)
  assert_eq(result.path.length(), 5)
}

test "hamiltonian_circuit_no_circuit_path_4" {
  // 路径图没有哈密顿回路
  let g = create_path_graph(4)
  let result = find_hamiltonian_circuit_backtrack(g)
  assert_true(!result.exists)
}

test "hamiltonian_circuit_no_circuit_star" {
  // 星形图没有哈密顿回路
  let g = create_star_graph(5)
  let result = find_hamiltonian_circuit_backtrack(g)
  assert_true(!result.exists)
}

// ============================================================================
// TSP 测试
// ============================================================================

test "tsp_nearest_neighbor_basic" {
  let weights = create_tsp_weights()
  let result = tsp_nearest_neighbor(weights)
  assert_eq(result.tour.length(), 4)
  assert_true(result.total_cost > 0.0)
  assert_true(!result.is_optimal)
  assert_eq(result.algorithm, "最近邻")
}

test "tsp_exact_small" {
  let weights = create_tsp_weights()
  let result = tsp_exact_held_karp(weights)
  assert_eq(result.tour.length(), 4)
  assert_true(result.total_cost > 0.0)
  assert_true(result.is_optimal)
  assert_eq(result.algorithm, "Held-Karp")
}

test "tsp_exact_cost_reasonable" {
  // 已知最优解: 0-1-3-2-0 = 10+25+30+15 = 80
  let weights = create_tsp_weights()
  let result = tsp_exact_held_karp(weights)
  assert_true(result.total_cost <= 85.0)
  assert_true(result.total_cost >= 75.0)
}

test "tsp_nearest_neighbor_valid_tour" {
  let weights = create_tsp_weights()
  let result = tsp_nearest_neighbor(weights)

  // 验证 tour 包含所有节点
  let visited : Array[Bool] = []
  let mut i = 0
  while i < 4 {
    visited.push(false)
    i = i + 1
  }

  for node in result.tour {
    if node >= 0 && node < 4 {
      visited[node] = true
    }
  }

  let mut all_visited = true
  i = 0
  while i < 4 {
    if !visited[i] {
      all_visited = false
    }
    i = i + 1
  }
  assert_true(all_visited)
}
