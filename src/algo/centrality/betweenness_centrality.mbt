/// 介数中心性算法实现 (Brandes 算法)

pub fn[G : @core.GraphReadable] betweenness_centrality(
  graph : G,
  normalized : Bool,
) -> CentralityResult {
  let n = @core.GraphReadable::node_count(graph)

  if n <= 2 {
    let zero_scores : Array[Double] = []
    let mut i = 0
    while i < n {
      zero_scores.push(0.0)
      i = i + 1
    }
    return CentralityResult::{ scores: zero_scores, normalized: normalized }
  }

  let is_directed = @core.GraphReadable::is_directed(graph)
  let betweenness : Array[Double] = Array::make(n, 0.0)

  let mut s = 0
  while s < n {
    brandes_accumulate(graph, s, n, betweenness)
    s = s + 1
  }

  if normalized {
    let scale = if is_directed {
      1.0 / int_to_double((n - 1) * (n - 2))
    } else {
      2.0 / int_to_double((n - 1) * (n - 2))
    }
    let mut k = 0
    while k < n {
      betweenness[k] = betweenness[k] * scale
      k = k + 1
    }
  }

  CentralityResult::{ scores: betweenness, normalized: normalized }
}

///|
/// Brandes 单源 BFS + 累积，直接修改 betweenness 数组
fn[G : @core.GraphReadable] brandes_accumulate(
  graph : G,
  source : Int,
  n : Int,
  betweenness : Array[Double],
) -> Unit {
  let dist : Array[Int] = []
  let sigma : Array[Double] = []
  let delta : Array[Double] = []
  let pred : Array[Array[Int]] = []

  let mut di = 0
  while di < n {
    dist.push(-1)
    sigma.push(0.0)
    delta.push(0.0)
    pred.push([])
    di = di + 1
  }

  dist[source] = 0
  sigma[source] = 1.0

  let queue : Array[Int] = [source]
  let stack : Array[Int] = []
  let mut head = 0
  while head < queue.length() {
    let v = queue[head]
    head = head + 1
    stack.push(v)

    let nbrs = get_neighbor_list_br(graph, @core.NodeId(v), n)
    for w in nbrs {
      if dist[w] < 0 {
        dist[w] = dist[v] + 1
        queue.push(w)
      }
      if dist[w] == dist[v] + 1 {
        sigma[w] = sigma[w] + sigma[v]
        pred[w].push(v)
      }
    }
  }

  let mut si = stack.length() - 1
  while si >= 0 {
    let w = stack[si]
    for v in pred[w] {
      if sigma[w] > 0.0 {
        delta[v] = delta[v] + (sigma[v] / sigma[w]) * (1.0 + delta[w])
      }
    }
    if w != source {
      betweenness[w] = betweenness[w] + delta[w]
    }
    si = si - 1
  }
}

fn[G : @core.GraphReadable] get_neighbor_list_br(
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
