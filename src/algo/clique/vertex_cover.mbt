///|
/// 最小顶点覆盖算法
///
/// 提供精确解（基于独立集）和近似解（贪心算法）。

fn[G : @core.GraphReadable] compute_degrees(g : G) -> Array[Int] {
  let n = @core.GraphReadable::node_count(g)
  let degrees : Array[Int] = []
  let mut i = 0
  while i < n {
    degrees.push(@core.GraphReadable::degree(g, @core.NodeId(i)))
    i = i + 1
  }
  degrees
}

fn find_max_degree_node(covered : Array[Bool], degrees : Array[Int]) -> Int {
  let mut max_degree = -1
  let mut best_node = -1
  let mut i = 0
  while i < covered.length() {
    if !covered[i] && degrees[i] > max_degree {
      max_degree = degrees[i]
      best_node = i
    }
    i = i + 1
  }
  best_node
}

fn[G : @core.GraphReadable] mark_neighbors_covered(g : G, node : Int, covered : Array[Bool]) -> Array[Bool] {
  let new_covered = covered
  new_covered[node] = true
  let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(node)).to_array()
  for neighbor in neighbors {
    let ni = neighbor.0
    if ni >= 0 && ni < new_covered.length() {
      new_covered[ni] = true
    }
  }
  new_covered
}

fn[G : @core.GraphReadable] validate_vertex_cover(g : G, cover : Array[@core.NodeId]) -> Bool {
  let n = @core.GraphReadable::node_count(g)

  let in_cover : Array[Bool] = []
  let mut i = 0
  while i < n {
    in_cover.push(false)
    i = i + 1
  }

  for node in cover {
    let ni = node.0
    if ni >= 0 && ni < n {
      in_cover[ni] = true
    }
  }

  i = 0
  while i < n {
    let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(i)).to_array()
    for neighbor in neighbors {
      let j = neighbor.0
      if j > i && j < n {
        if !in_cover[i] && !in_cover[j] {
          return false
        }
      }
    }
    i = i + 1
  }

  true
}

fn sort_cover(cover : Array[Int]) -> Array[@core.NodeId] {
  let sorted = cover
  let mut i = 0
  while i < sorted.length() {
    let mut j = i + 1
    while j < sorted.length() {
      if sorted[j] < sorted[i] {
        let temp = sorted[i]
        sorted[i] = sorted[j]
        sorted[j] = temp
      }
      j = j + 1
    }
    i = i + 1
  }

  let result : Array[@core.NodeId] = []
  for id in sorted {
    result.push(@core.NodeId(id))
  }
  result
}

pub fn[G : @core.GraphReadable] find_minimum_vertex_cover_exact(g : G) -> VertexCoverResult {
  let n = @core.GraphReadable::node_count(g)

  if n == 0 {
    return VertexCoverResult::{ cover: [], size: 0, is_optimal: true }
  }

  let is_result = find_maximum_independent_set(g)

  let in_independent_set : Array[Bool] = []
  let mut i = 0
  while i < n {
    in_independent_set.push(false)
    i = i + 1
  }

  for node in is_result.maximum_set {
    let ni = node.0
    if ni >= 0 && ni < n {
      in_independent_set[ni] = true
    }
  }

  let cover_nodes : Array[Int] = []
  i = 0
  while i < n {
    if !in_independent_set[i] {
      cover_nodes.push(i)
    }
    i = i + 1
  }

  let sorted_cover = sort_cover(cover_nodes)

  VertexCoverResult::{
    cover: sorted_cover,
    size: sorted_cover.length(),
    is_optimal: true,
  }
}

pub fn[G : @core.GraphReadable] find_minimum_vertex_cover_approx(g : G) -> VertexCoverResult {
  let n = @core.GraphReadable::node_count(g)

  if n == 0 {
    return VertexCoverResult::{ cover: [], size: 0, is_optimal: false }
  }

  if @core.GraphReadable::edge_count(g) == 0 {
    return VertexCoverResult::{ cover: [], size: 0, is_optimal: true }
  }

  let degrees = compute_degrees(g)

  let mut covered : Array[Bool] = []
  let mut i = 0
  while i < n {
    covered.push(false)
    i = i + 1
  }

  let cover_set : Array[Int] = []

  let mut finished = false
  while !finished {
    let node = find_max_degree_node(covered, degrees)

    if node == -1 {
      finished = true
    } else {
      cover_set.push(node)
      covered = mark_neighbors_covered(g, node, covered)
    }
  }

  let sorted_cover = sort_cover(cover_set)

  VertexCoverResult::{
    cover: sorted_cover,
    size: sorted_cover.length(),
    is_optimal: false,
  }
}
