///|
/// 哈密顿路径/回路算法
///
/// 提供快速检查、回溯搜索两种方法。

// ============================================================================
// 快速检查（必要条件）
// ============================================================================

pub fn[G : @core.GraphReadable] has_hamiltonian_circuit_quick_check(
  graph : G,
) -> Bool {
  let n = @core.GraphReadable::node_count(graph)

  if n < 3 {
    return false
  }

  let mut i = 0
  while i < n {
    if @core.GraphReadable::degree(graph, @core.NodeId(i)) < 2 {
      return false
    }
    i = i + 1
  }

  true
}

// ============================================================================
// 回溯算法 - 哈密顿路径
// ============================================================================

///|
fn[G : @core.GraphReadable] get_neighbors_list(
  g : G,
  v : Int,
  n : Int,
) -> Array[Int] {
  let result : Array[Int] = []
  let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(v))
  for neighbor in neighbors {
    let ni = neighbor.0
    if ni >= 0 && ni < n {
      result.push(ni)
    }
  }
  result
}

///|
fn[G : @core.GraphReadable] backtrack_path(
  g : G,
  current_path : Array[Int],
  remaining : Array[Int],
  n : Int,
) -> Array[Int] {
  if remaining.length() == 0 {
    return copy_array_int(current_path)
  }

  let last_node = current_path[current_path.length() - 1]
  let neighbors = get_neighbors_list(g, last_node, n)

  for next_node in remaining {
    if array_contains(neighbors, next_node) {
      let new_path = copy_array_int(current_path)
      new_path.push(next_node)
      let new_remaining = remove_from_array(remaining, next_node)

      let result = backtrack_path(g, new_path, new_remaining, n)
      if result.length() > 0 {
        return result
      }
    }
  }

  []
}

///|
pub fn[G : @core.GraphReadable] find_hamiltonian_path_backtrack(
  graph : G,
) -> HamiltonianResult {
  let n = @core.GraphReadable::node_count(graph)

  if n == 0 {
    return HamiltonianResult::{
      exists: false,
      path: [],
      is_circuit: false,
      start_node: None,
    }
  }

  if n == 1 {
    return HamiltonianResult::{
      exists: true,
      path: [@core.NodeId(0)],
      is_circuit: false,
      start_node: Some(@core.NodeId(0)),
    }
  }

  let mut start = 0
  while start < n {
    let remaining : Array[Int] = []
    let mut i = 0
    while i < n {
      if i != start {
        remaining.push(i)
      }
      i = i + 1
    }

    let result = backtrack_path(graph, [start], remaining, n)
    if result.length() == n {
      let path_nodes : Array[@core.NodeId] = []
      for idx in result {
        path_nodes.push(@core.NodeId(idx))
      }
      return HamiltonianResult::{
        exists: true,
        path: path_nodes,
        is_circuit: false,
        start_node: Some(@core.NodeId(start)),
      }
    }
    start = start + 1
  }

  HamiltonianResult::{
    exists: false,
    path: [],
    is_circuit: false,
    start_node: None,
  }
}

// ============================================================================
// 回溯算法 - 哈密顿回路
// ============================================================================

///|
fn[G : @core.GraphReadable] backtrack_circuit(
  g : G,
  current_path : Array[Int],
  remaining : Array[Int],
  start : Int,
  n : Int,
) -> Array[Int] {
  if remaining.length() == 0 {
    let last_node = current_path[current_path.length() - 1]
    let neighbors = get_neighbors_list(g, last_node, n)
    if array_contains(neighbors, start) {
      return copy_array_int(current_path)
    }
    return []
  }

  let last_node = current_path[current_path.length() - 1]
  let neighbors = get_neighbors_list(g, last_node, n)

  for next_node in remaining {
    if array_contains(neighbors, next_node) {
      let new_path = copy_array_int(current_path)
      new_path.push(next_node)
      let new_remaining = remove_from_array(remaining, next_node)

      let result = backtrack_circuit(g, new_path, new_remaining, start, n)
      if result.length() > 0 {
        return result
      }
    }
  }

  []
}

///|
pub fn[G : @core.GraphReadable] find_hamiltonian_circuit_backtrack(
  graph : G,
) -> HamiltonianResult {
  let n = @core.GraphReadable::node_count(graph)

  if n < 3 {
    return HamiltonianResult::{
      exists: false,
      path: [],
      is_circuit: true,
      start_node: None,
    }
  }

  let remaining : Array[Int] = []
  let mut i = 1
  while i < n {
    remaining.push(i)
    i = i + 1
  }

  let result = backtrack_circuit(graph, [0], remaining, 0, n)
  if result.length() == n {
    let path_nodes : Array[@core.NodeId] = []
    for idx in result {
      path_nodes.push(@core.NodeId(idx))
    }
    return HamiltonianResult::{
      exists: true,
      path: path_nodes,
      is_circuit: true,
      start_node: Some(@core.NodeId(0)),
    }
  }

  HamiltonianResult::{
    exists: false,
    path: [],
    is_circuit: true,
    start_node: None,
  }
}
