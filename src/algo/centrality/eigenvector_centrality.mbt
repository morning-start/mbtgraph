///|
/// 特征向量中心性算法实现
pub fn[G : @core.GraphReadable] eigenvector_centrality(
  graph : G,
  max_iterations : Int,
  tolerance : Double,
) -> CentralityResult {
  let n = @core.GraphReadable::node_count(graph)

  if n == 0 {
    return CentralityResult::{ scores: [], normalized: true }
  }

  if n == 1 {
    let single_scores : Array[Double] = [1.0]
    return CentralityResult::{ scores: single_scores, normalized: true }
  }

  let mut scores : Array[Double] = []
  let inv_n = 1.0 / int_to_double(n)
  let mut i = 0
  while i < n {
    scores.push(inv_n)
    i = i + 1
  }

  let in_adj = build_eigenvector_adjacency_ev(graph, n)

  let mut iter = 0
  while iter < max_iterations {
    let new_scores = eigenvector_iterate_ev(scores, in_adj, n)
    let norm = normalize_vector_ev(new_scores)
    new_scores |> ignore

    let diff = max_diff_eigen_ev(scores, norm, n)

    scores = norm
    iter = iter + 1

    if diff < tolerance {
      break
    }
  }

  CentralityResult::{ scores, normalized: true }
}

///|
fn[G : @core.GraphReadable] build_eigenvector_adjacency_ev(
  graph : G,
  n : Int,
) -> Array[Array[Int]] {
  let adj : Array[Array[Int]] = []
  let a : Array[Array[Int]] = Array::make(n, [])

  let edges = @core.GraphReadable::edges(graph)
  for edge in edges {
    match edge {
      (u, v, _) => {
        let ui = u.0
        let vi = v.0
        if ui >= 0 && ui < n && vi >= 0 && vi < n {
          a[vi].push(ui)
        }
      }
    }
  }
  a
}

///|
fn eigenvector_iterate_ev(
  old_scores : Array[Double],
  in_adj : Array[Array[Int]],
  n : Int,
) -> Array[Double] {
  let ns : Array[Double] = []
  let mut i = 0
  while i < n {
    let mut sum_in = 0.0
    let nbrs = in_adj[i]
    for src in nbrs {
      if src >= 0 && src < n {
        sum_in = sum_in + old_scores[src]
      }
    }
    ns.push(sum_in)
    i = i + 1
  }
  ns
}

///|
fn normalize_vector_ev(vec : Array[Double]) -> Array[Double] {
  let mut norm_sq = 0.0
  for v in vec {
    norm_sq = norm_sq + v * v
  }
  let norm = if norm_sq > 0.0 { sqrt_double_ev(norm_sq) } else { 1.0 }

  let result : Array[Double] = []
  for v in vec {
    result.push(v / norm)
  }
  result
}

///|
fn max_diff_eigen_ev(a : Array[Double], b : Array[Double], n : Int) -> Double {
  let mut md = 0.0
  let mut i = 0
  while i < n {
    let mut delta = a[i] - b[i]
    if delta < 0.0 {
      delta = -delta
    }
    if delta > md {
      md = delta
    }
    i = i + 1
  }
  md
}

///|
fn sqrt_double_ev(x : Double) -> Double {
  if x <= 0.0 {
    return 0.0
  }
  let mut guess = x / 2.0
  let mut j = 0
  while j < 20 {
    guess = (guess + x / guess) / 2.0
    j = j + 1
  }
  guess
}
