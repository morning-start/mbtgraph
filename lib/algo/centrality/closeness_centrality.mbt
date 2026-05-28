///|
/// 接近中心性算法实现
pub fn[G : @core.GraphReadable] closeness_centrality(
  graph : G,
  normalized : Bool,
) -> CentralityResult {
  let n = @core.GraphReadable::node_count(graph)

  if n <= 1 {
    let scores : Array[Double] = []
    let mut i = 0
    while i < n {
      scores.push(0.0)
      i = i + 1
    }
    return CentralityResult::{ scores, normalized }
  }

  let closeness : Array[Double] = Array::make(n, 0.0)

  let mut source = 0
  while source < n {
    let dists = bfs_distances_cl(graph, source, n)
    let mut sum_dist = 0.0
    let mut reachable = 0
    let mut d = 0
    while d < dists.length() {
      if d != source && dists[d] >= 0 {
        sum_dist = sum_dist + int_to_double(dists[d])
        reachable = reachable + 1
      }
      d = d + 1
    }
    if sum_dist > 0.0 && reachable > 0 {
      closeness[source] = int_to_double(reachable) / sum_dist
    } else {
      closeness[source] = 0.0
    }
    source = source + 1
  }

  if normalized && n > 2 {
    let scale = int_to_double(n - 1)
    let mut k = 0
    while k < n {
      closeness[k] = closeness[k] / scale
      k = k + 1
    }
  }

  CentralityResult::{ scores: closeness, normalized }
}

///|
fn[G : @core.GraphReadable] bfs_distances_cl(
  graph : G,
  source : Int,
  n : Int,
) -> Array[Int] {
  let dist : Array[Int] = []
  let mut i = 0
  while i < n {
    dist.push(-1)
    i = i + 1
  }

  dist[source] = 0

  let queue : Array[Int] = [source]
  let mut head = 0
  while head < queue.length() {
    let v = queue[head]
    head = head + 1
    let nbrs = get_neighbor_list_cl(graph, @core.NodeId(v), n)
    for w in nbrs {
      if dist[w] < 0 {
        dist[w] = dist[v] + 1
        queue.push(w)
      }
    }
  }
  dist
}

///|
fn[G : @core.GraphReadable] get_neighbor_list_cl(
  graph : G,
  node_id : @core.NodeId,
  n : Int,
) -> Array[Int] {
  let result : Array[Int] = []
  let neighbors = @core.GraphReadable::neighbors(graph, node_id)
  for neighbor in neighbors {
    let ni = neighbor.0
    if ni >= 0 && ni < n {
      result.push(ni)
    }
  }
  result
}
