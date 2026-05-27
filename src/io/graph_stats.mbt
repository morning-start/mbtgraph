///|
/// 计算图的基本统计信息
pub fn[G : @core.GraphReadable] basic_stats(graph : G) -> GraphStats {
  let directed = @core.GraphReadable::is_directed(graph)
  let n = @core.GraphReadable::node_count(graph)
  let m = @core.GraphReadable::edge_count(graph)

  let max_norm = if n > 1 { n - 1 } else { 1 }
  let max_possible_edges : Double = if directed {
    (n * max_norm).to_double()
  } else {
    (n * max_norm / 2).to_double()
  }
  let density : Double = if max_possible_edges > 0.0 {
    m.to_double() / max_possible_edges
  } else {
    0.0
  }

  let mut total_degree = 0
  let mut min_deg = -1
  let mut max_deg = 0
  let mut self_loops = 0

  let mut ni = 0
  while ni < n {
    let nid = @core.NodeId(ni)
    let deg = @core.GraphReadable::degree(graph, nid)
    total_degree = total_degree + deg
    if min_deg < 0 || deg < min_deg {
      min_deg = deg
    }
    if deg > max_deg {
      max_deg = deg
    }
    ni = ni + 1
  }

  let edges_iter = @core.GraphReadable::edges(graph)
  for e in edges_iter {
    let (from, to, _) = e
    if from.0 == to.0 {
      self_loops = self_loops + 1
    }
  }

  let avg_degree : Double = if n > 0 {
    total_degree.to_double() / n.to_double()
  } else {
    0.0
  }

  let actual_min = if min_deg < 0 { 0 } else { min_deg }

  GraphStats::{
    node_count: n,
    edge_count: m,
    is_directed: directed,
    density,
    avg_degree,
    min_degree: actual_min,
    max_degree: max_deg,
    self_loop_count: self_loops,
  }
}

///|
/// 计算图的度分布直方图
pub fn[G : @core.GraphReadable] degree_distribution(
  graph : G,
) -> DegreeDistribution {
  let n = @core.GraphReadable::node_count(graph)
  let mut min_deg = -1
  let mut max_deg = 0

  let degrees : Array[Int] = Array::make(n, 0)
  let mut ni = 0
  while ni < n {
    let nid = @core.NodeId(ni)
    let deg = @core.GraphReadable::degree(graph, nid)
    degrees[ni] = deg
    if min_deg < 0 || deg < min_deg {
      min_deg = deg
    }
    if deg > max_deg {
      max_deg = deg
    }
    ni = ni + 1
  }

  let actual_min = if min_deg < 0 { 0 } else { min_deg }
  let hist_len = max_deg - actual_min + 1
  let histogram : Array[Int] = Array::make(hist_len, 0)

  let mut j = 0
  while j < n {
    let idx = degrees[j] - actual_min
    if idx >= 0 && idx < hist_len {
      histogram[idx] = histogram[idx] + 1
    }
    j = j + 1
  }

  DegreeDistribution::{ min_degree: actual_min, max_degree: max_deg, histogram }
}

///|
/// 使用 BFS 计算连通分量信息
pub fn[G : @core.GraphReadable] connectivity_stats(
  graph : G,
) -> ConnectivityStats {
  let n = @core.GraphReadable::node_count(graph)
  if n <= 0 {
    return ConnectivityStats::{
      component_count: 0,
      largest_component_size: 0,
      component_sizes: [],
    }
  }

  let visited : Array[Bool] = Array::make(n, false)
  let queue : Array[Int] = Array::make(n, 0)
  let mut component_sizes : Array[Int] = []
  let mut largest = 0

  let mut start = 0
  while start < n {
    if visited[start] {
      start = start + 1
      continue
    }

    let mut head = 0
    let mut tail = 0
    queue[tail] = start
    tail = tail + 1
    visited[start] = true
    let mut comp_size = 0

    while head < tail {
      let curr = queue[head]
      head = head + 1
      comp_size = comp_size + 1
      let curr_id = @core.NodeId(curr)

      let neighbors_iter = @core.GraphReadable::neighbors(graph, curr_id)
      for nb in neighbors_iter {
        let nb_id = nb.0
        if !visited[nb_id] {
          visited[nb_id] = true
          queue[tail] = nb_id
          tail = tail + 1
        }
      }
    }

    if comp_size > largest {
      largest = comp_size
    }
    component_sizes = array_push(component_sizes, comp_size)
    start = start + 1
  }

  ConnectivityStats::{
    component_count: component_sizes.length(),
    largest_component_size: largest,
    component_sizes,
  }
}

///|
fn array_push(arr : Array[Int], val : Int) -> Array[Int] {
  let len = arr.length()
  if len == 0 {
    return [val]
  }
  let new_arr = Array::make(len + 1, arr[0])
  let mut i = 0
  while i < len {
    new_arr[i] = arr[i]
    i = i + 1
  }
  new_arr[len] = val
  new_arr
}
