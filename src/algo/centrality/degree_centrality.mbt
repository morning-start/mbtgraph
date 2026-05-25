/// 度中心性算法实现

pub fn[G : @core.GraphReadable] degree_centrality(
  graph : G,
  mode : DegreeMode,
) -> CentralityResult {
  let n = @core.GraphReadable::node_count(graph)

  if n == 0 {
    return CentralityResult::{ scores: [], normalized: true }
  }

  if n == 1 {
    let single_scores : Array[Double] = [0.0]
    return CentralityResult::{ scores: single_scores, normalized: true }
  }

  let is_directed = @core.GraphReadable::is_directed(graph)
  let scores : Array[Double] = []
  let mut i = 0
  while i < n {
    let node_id = @core.NodeId(i)
    let deg = match mode {
      DegreeMode::In => {
        if is_directed { count_in_neighbors_dc(graph, node_id) }
        else { @core.GraphReadable::degree(graph, node_id) }
      }
      DegreeMode::Out => { @core.GraphReadable::degree(graph, node_id) }
      DegreeMode::Total => {
        if is_directed {
          @core.GraphReadable::degree(graph, node_id) + count_in_neighbors_dc(graph, node_id)
        } else {
          @core.GraphReadable::degree(graph, node_id)
        }
      }
    }
    scores.push(int_to_double(deg) / int_to_double(n - 1))
    i = i + 1
  }

  CentralityResult::{ scores: scores, normalized: true }
}

fn[G : @core.GraphReadable] count_in_neighbors_dc(
  graph : G,
  target : @core.NodeId,
) -> Int {
  let mut count = 0
  let edges = @core.GraphReadable::edges(graph)
  for edge in edges {
    match edge {
      (_, v, _) => { if v == target { count = count + 1 } }
    }
  }
  count
}
