///|
/// TSP (旅行商问题) 算法
///
/// 提供 Held-Karp 精确算法和最近邻启发式近似算法。

// ============================================================================
// 最近邻启发式算法
// ============================================================================

fn find_nearest_unvisited(
  weights : Array[Array[Double]],
  current : Int,
  visited : Array[Bool],
  n : Int,
) -> Int {
  let mut nearest = -1
  let mut min_dist : Double = -1.0
  let mut i = 0
  while i < n {
    if !visited[i] && i != current {
      let dist = weights[current][i]
      if dist >= 0.0 && (nearest == -1 || dist < min_dist) {
        nearest = i
        min_dist = dist
      }
    }
    i = i + 1
  }
  nearest
}

///|
pub fn tsp_nearest_neighbor(weights : Array[Array[Double]]) -> TSPResult {
  let n = weights.length()

  if n == 0 {
    return TSPResult::{
      tour: [],
      total_cost: 0.0,
      is_optimal: false,
      algorithm: "最近邻",
    }
  }

  if n == 1 {
    return TSPResult::{
      tour: [0],
      total_cost: 0.0,
      is_optimal: true,
      algorithm: "最近邻",
    }
  }

  let visited : Array[Bool] = []
  let mut i = 0
  while i < n {
    visited.push(false)
    i = i + 1
  }

  let tour : Array[Int] = [0]
  visited[0] = true

  let mut total_cost : Double = 0.0
  let mut current = 0

  let mut count = 1
  while count < n {
    let next = find_nearest_unvisited(weights, current, visited, n)
    if next == -1 {
      break
    }
    tour.push(next)
    total_cost = total_cost + weights[current][next]
    visited[next] = true
    current = next
    count = count + 1
  }

  if n > 1 {
    total_cost = total_cost + weights[current][0]
  }

  TSPResult::{ tour, total_cost, is_optimal: false, algorithm: "最近邻" }
}

// ============================================================================
// Held-Karp 精确算法（排列枚举，适用于小规模 V <= 12）
// ============================================================================

///|
priv struct TSPState {
  tour : Array[Int]
  cost : Double
}

///|
fn tsp_permute(
  weights : Array[Array[Double]],
  current_path : Array[Int],
  remaining : Array[Int],
  current_cost : Double,
  best_cost : Double,
  best_tour : Array[Int],
  n : Int,
) -> TSPState {
  if remaining.length() == 0 {
    let last = current_path[current_path.length() - 1]
    let total_cost = current_cost + weights[last][0]
    if best_cost < 0.0 || total_cost < best_cost {
      return TSPState::{ tour: copy_array_int(current_path), cost: total_cost }
    }
    return TSPState::{ tour: copy_array_int(best_tour), cost: best_cost }
  }

  let mut new_best_cost = best_cost
  let mut new_best_tour = copy_array_int(best_tour)

  for next_node in remaining {
    let last = current_path[current_path.length() - 1]
    let add_cost = weights[last][next_node]

    if add_cost < 0.0 {
      continue
    }

    let new_cost = current_cost + add_cost

    if new_best_cost >= 0.0 && new_cost >= new_best_cost {
      continue
    }

    let new_path = copy_array_int(current_path)
    new_path.push(next_node)

    let new_remaining = remove_from_array(remaining, next_node)

    let result = tsp_permute(
      weights, new_path, new_remaining, new_cost, new_best_cost, new_best_tour, n,
    )

    if result.cost < new_best_cost || new_best_cost < 0.0 {
      new_best_cost = result.cost
      new_best_tour = result.tour
    }
  }

  TSPState::{ tour: new_best_tour, cost: new_best_cost }
}

///|
pub fn tsp_exact_held_karp(weights : Array[Array[Double]]) -> TSPResult {
  let n = weights.length()

  if n == 0 {
    return TSPResult::{
      tour: [],
      total_cost: 0.0,
      is_optimal: true,
      algorithm: "Held-Karp",
    }
  }

  if n == 1 {
    return TSPResult::{
      tour: [0],
      total_cost: 0.0,
      is_optimal: true,
      algorithm: "Held-Karp",
    }
  }

  // 规模限制：V <= 12 时使用精确算法，否则回退到最近邻
  if n > 12 {
    return tsp_nearest_neighbor(weights)
  }

  let nodes : Array[Int] = []
  let mut i = 1
  while i < n {
    nodes.push(i)
    i = i + 1
  }

  let initial_tour : Array[Int] = []
  let result = tsp_permute(weights, [0], nodes, 0.0, -1.0, initial_tour, n)

  TSPResult::{
    tour: result.tour,
    total_cost: result.cost,
    is_optimal: true,
    algorithm: "Held-Karp",
  }
}

// ============================================================================
// 从图构建权重矩阵
// ============================================================================

///|
pub fn[G : @core.GraphReadable] build_weight_matrix(
  graph : G,
) -> Array[Array[Double]] {
  let n = @core.GraphReadable::node_count(graph)

  let matrix : Array[Array[Double]] = []
  let mut i = 0
  while i < n {
    let row : Array[Double] = []
    let mut j = 0
    while j < n {
      if i == j {
        row.push(0.0)
      } else if @core.GraphReadable::contains_edge(
          graph,
          @core.NodeId(i),
          @core.NodeId(j),
        ) {
        match
          @core.GraphReadable::get_edge(graph, @core.NodeId(i), @core.NodeId(j)) {
          Some(w) => row.push(w)
          None => row.push(-1.0)
        }
      } else {
        row.push(-1.0)
      }
      j = j + 1
    }
    matrix.push(row)
    i = i + 1
  }

  matrix
}
