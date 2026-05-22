///|
/// Bron-Kerbosch 最大团算法（简化版本）
pub fn[G : @core.GraphReadable] find_maximum_clique(g : G) -> CliqueResult {
  let n = @core.GraphReadable::node_count(g)

  if n == 0 {
    return CliqueResult::{ maximum_clique: [], size: 0 }
  }

  if n == 1 {
    return CliqueResult::{ maximum_clique: [@core.NodeId(0)], size: 1 }
  }

  let r : Array[Int] = []
  let p : Array[Int] = []
  let mut i = 0
  while i < n {
    p.push(i)
    i = i + 1
  }
  let x : Array[Int] = []

  let result = bk_recursive(g, r, p, x, n)

  let size = result.length()
  let clique_nodes : Array[@core.NodeId] = []
  for idx in result {
    clique_nodes.push(@core.NodeId(idx))
  }

  CliqueResult::{
    maximum_clique: clique_nodes,
    size: size,
  }
}

fn[G : @core.GraphReadable] bk_recursive(
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

    let v_neighbors = get_neighbor_indices(g, v, n)
    let new_p = intersect_arrays(remaining_p, v_neighbors)
    let new_x = intersect_arrays(current_x, v_neighbors)

    let candidate = bk_recursive(g, new_r, new_p, new_x, n)
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

fn[G : @core.GraphReadable] get_neighbor_indices(g : G, v : Int, n : Int) -> Array[Int] {
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
