///|
/// Edmonds-Karp 最大流算法
///
/// 使用 BFS 寻找最短增广路，时间复杂度 O(V E²)。
/// 每次增广沿瓶颈值更新正向流量、减少反向流量（残差图语义）。
fn ek_bfs(
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
  n : Int,
  source : Int,
  sink : Int,
) -> (Array[Int?], Bool) {
  let parent : Array[Int?] = Array::make(n, None)
  let visited : Array[Bool] = Array::make(n, false)
  let queue : Array[Int] = [source]
  visited[source] = true
  let mut head = 0
  while head < queue.length() {
    let u = queue[head]
    head = head + 1
    let mut v = 0
    while v < n {
      if !visited[v] {
        let forward_cap = capacity[u][v] - flow[u][v]
        let backward_cap = flow[v][u]
        if forward_cap > 0.000001 || backward_cap > 0.000001 {
          parent[v] = Some(u)
          visited[v] = true
          if v == sink {
            return (parent, true)
          }
          queue.push(v)
        }
      }
      v = v + 1
    }
  }
  (parent, false)
}

///|
fn ek_find_path_bottleneck(
  parent : Array[Int?],
  sink : Int,
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
) -> Double {
  let mut bottleneck = 1000000000000000000.0
  let mut cur = sink
  while true {
    match parent[cur] {
      None => break
      Some(p) => {
        let residual = capacity[p][cur] - flow[p][cur]
        if residual < bottleneck && residual > 0.0 {
          bottleneck = residual
        }
        cur = p
      }
    }
  }
  bottleneck
}

///|
fn ek_augment(
  parent : Array[Int?],
  source : Int,
  sink : Int,
  _capacity : Array[Array[Double]],
  flow_ref : Array[Array[Double]],
  bottleneck : Double,
) -> Unit {
  let mut v = sink
  while v != source {
    match parent[v] {
      None => break
      Some(u) => {
        flow_ref[u][v] = flow_ref[u][v] + bottleneck
        flow_ref[v][u] = flow_ref[v][u] - bottleneck
        v = u
      }
    }
  }
}

///|
fn deep_copy_matrix(src : Array[Array[Double]]) -> Array[Array[Double]] {
  let result : Array[Array[Double]] = []
  for i in 0..<src.length() {
    let row : Array[Double] = []
    for j in 0..<src[i].length() {
      row.push(src[i][j])
    }
    result.push(row)
  }
  result
}

///|
/// Edmonds-Karp 最大流
///
/// 在流网络上计算从 source 到 sink 的最大流。
/// 使用 BFS 每次找到最短增广路径，保证 O(VE²) 上界。
pub fn edmonds_karp(
  graph : FlowNetwork,
  source : Int,
  sink : Int,
) -> MaxFlowResult {
  let n = graph.node_count
  if n == 0 ||
    source < 0 ||
    source >= n ||
    sink < 0 ||
    sink >= n ||
    source == sink {
    return MaxFlowResult::{ max_flow: 0.0, flow_matrix: [] }
  }
  let work_flow = deep_copy_matrix(graph.flow)
  let mut total_flow = 0.0
  while true {
    let (parent, found) = ek_bfs(graph.capacity, work_flow, n, source, sink)
    if !found {
      break
    }
    let bottleneck = ek_find_path_bottleneck(
      parent,
      sink,
      graph.capacity,
      work_flow,
    )
    if bottleneck <= 0.000001 {
      break
    }
    ek_augment(parent, source, sink, graph.capacity, work_flow, bottleneck)
    total_flow = total_flow + bottleneck
  }
  let result_matrix : Array[Array[Double?]] = []
  for i in 0..<n {
    let row : Array[Double?] = []
    for j in 0..<n {
      if work_flow[i][j] > 0.000001 {
        row.push(Some(work_flow[i][j]))
      } else {
        row.push(None)
      }
    }
    result_matrix.push(row)
  }
  MaxFlowResult::{ max_flow: total_flow, flow_matrix: result_matrix }
}
