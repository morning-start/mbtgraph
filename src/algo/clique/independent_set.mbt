///|
/// 最大独立集算法
///
/// 通过在补图（complement graph）上查找最大团来求解。

pub fn[G : @core.GraphReadable] find_maximum_independent_set(g : G) -> IndependentSetResult {
  let n = @core.GraphReadable::node_count(g)

  if n == 0 {
    return IndependentSetResult::{ maximum_set: [], size: 0 }
  }

  if n == 1 {
    return IndependentSetResult::{ maximum_set: [@core.NodeId(0)], size: 1 }
  }

  let r : Array[Int] = []
  let p : Array[Int] = []
  let mut i = 0
  while i < n {
    p.push(i)
    i = i + 1
  }
  let x : Array[Int] = []

  let max_independent_set = bk_recursive_complement(g, r, p, x, n)

  let sorted = copy_array_int(max_independent_set)
  let mut idx1 = 0
  while idx1 < sorted.length() {
    let mut idx2 = idx1 + 1
    while idx2 < sorted.length() {
      if sorted[idx2] < sorted[idx1] {
        let temp = sorted[idx1]
        sorted[idx1] = sorted[idx2]
        sorted[idx2] = temp
      }
      idx2 = idx2 + 1
    }
    idx1 = idx1 + 1
  }

  let result_nodes : Array[@core.NodeId] = []
  for id in sorted {
    result_nodes.push(@core.NodeId(id))
  }

  IndependentSetResult::{
    maximum_set: result_nodes,
    size: result_nodes.length(),
  }
}

fn[G : @core.GraphReadable] bk_recursive_complement(
  g : G,
  r : Array[Int],
  p : Array[Int],
  x : Array[Int],
  n : Int,
) -> Array[Int] {
  if p.length() == 0 && x.length() == 0 {
    if r.length() > 0 {
      return copy_array_int(r)
    }
    return []
  }

  let mut best : Array[Int] = []

  let mut remaining_p = copy_array_int(p)
  let mut current_x = copy_array_int(x)

  for v in p {
    let new_r = copy_array_int(r)
    new_r.push(v)

    let v_non_neighbors = get_non_neighbor_indices(g, v, n)
    let new_p = intersect_arrays(remaining_p, v_non_neighbors)
    let new_x = intersect_arrays(current_x, v_non_neighbors)

    let candidate = bk_recursive_complement(g, new_r, new_p, new_x, n)
    if candidate.length() > best.length() {
      best = candidate
    }

    remaining_p = remove_from_array(remaining_p, v)
    let updated_x = copy_array_int(current_x)
    updated_x.push(v)
    current_x = updated_x
  }

  best
}

fn[G : @core.GraphReadable] get_non_neighbor_indices(g : G, v : Int, n : Int) -> Array[Int] {
  let result : Array[Int] = []
  let mut i = 0
  while i < n {
    if i != v && !@core.GraphReadable::contains_edge(g, @core.NodeId(v), @core.NodeId(i)) {
      result.push(i)
    }
    i = i + 1
  }
  result
}
