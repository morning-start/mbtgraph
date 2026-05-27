///|
/// 最小费用最大流 — SSP (Successive Shortest Path) 算法
///
/// 每次在残差图中找费用最短的增广路，使用 Bellman-Ford 处理负边费用。
/// 时间复杂度 O(F * E * V)，其中 F 是最大流量。
///
/// ## 算法流程
/// 1. 深拷贝 capacity/cost/flow 矩阵，保证纯函数语义
/// 2. 在残差图上运行 Bellman-Ford 找最短费用路径
///    - 正向边：容量 > 0，费用 = cost[u][v]
///    - 反向边：流量 > 0（可撤销），费用 = -cost[v][u]
/// 3. 沿路径找到瓶颈值并增广
/// 4. 重复直到源点到汇点不可达
///
/// ## 参数
/// - `net`: 费用流网络（CostFlowNetwork 类型）
/// - `source`: 源点索引
/// - `sink`: 汇点索引
///
/// ## 返回
/// `MinCostMaxFlowResult` 包含最大流量、最小费用和流量矩阵
fn mcmf_deep_copy(src : Array[Array[Double]]) -> Array[Array[Double]] {
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
fn bellman_ford(
  capacity : Array[Array[Double]],
  cost : Array[Array[Double]],
  flow : Array[Array[Double]],
  n : Int,
  source : Int,
  sink : Int,
) -> (Array[Int], Array[Bool], Bool) {
  let eps = 0.000001
  let dist : Array[Double] = Array::make(n, 1000000000000000000.0)
  let parent : Array[Int] = Array::make(n, -1)
  let is_forward : Array[Bool] = Array::make(n, false)
  let in_queue : Array[Bool] = Array::make(n, false)
  let count : Array[Int] = Array::make(n, 0)
  dist[source] = 0.0
  let queue : Array[Int] = [source]
  in_queue[source] = true
  let mut head = 0

  while head < queue.length() {
    let u = queue[head]
    head = head + 1
    in_queue[u] = false
    let mut v = 0
    while v < n {
      let fwd_residual = capacity[u][v] - flow[u][v]
      if fwd_residual > eps {
        let new_dist = dist[u] + cost[u][v]
        if new_dist < dist[v] - eps {
          dist[v] = new_dist
          parent[v] = u
          is_forward[v] = true
          if !in_queue[v] {
            queue.push(v)
            in_queue[v] = true
            count[v] = count[v] + 1
          }
        }
      }
      if flow[v][u] > eps {
        let new_dist = dist[u] - cost[v][u]
        if new_dist < dist[v] - eps {
          dist[v] = new_dist
          parent[v] = u
          is_forward[v] = false
          if !in_queue[v] {
            queue.push(v)
            in_queue[v] = true
            count[v] = count[v] + 1
          }
        }
      }
      v = v + 1
    }
  }

  (parent, is_forward, parent[sink] != -1)
}

///|
fn find_bottleneck(
  parent : Array[Int],
  is_forward : Array[Bool],
  sink : Int,
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
) -> Double {
  let mut bottleneck = 1000000000000000000.0
  let mut cur = sink
  let eps = 0.000001
  while true {
    let p = parent[cur]
    if p == -1 {
      break
    }
    let available = if is_forward[cur] {
      capacity[p][cur] - flow[p][cur]
    } else {
      flow[cur][p]
    }
    if available < bottleneck && available > eps {
      bottleneck = available
    }
    cur = p
  }
  bottleneck
}

///|
fn augment_flow(
  parent : Array[Int],
  source : Int,
  sink : Int,
  flow_ref : Array[Array[Double]],
  bottleneck : Double,
) -> Unit {
  let mut cur = sink
  while cur != source {
    let p = parent[cur]
    flow_ref[p][cur] = flow_ref[p][cur] + bottleneck
    flow_ref[cur][p] = flow_ref[cur][p] - bottleneck
    cur = p
  }
}

///|
/// 最小费用最大流 — SSP 算法
///
/// 在费用流网络上计算从 source 到 sink 的最小费用最大流。
///
/// ## 复杂度
/// - 时间: O(F * V²)，其中 F = 最大流量, V = 节点数
/// - 空间: O(V²)（矩阵表示）
///
/// ## 参数
/// - `net`: 费用流网络
/// - `source`: 源点索引
/// - `sink`: 汇点索引
///
/// ## 返回
/// `MinCostMaxFlowResult` 包含最大流量、最小费用和流量矩阵
pub fn min_cost_max_flow(
  net : CostFlowNetwork,
  source : Int,
  sink : Int,
) -> MinCostMaxFlowResult {
  let n = net.node_count
  if n == 0 ||
    source < 0 ||
    source >= n ||
    sink < 0 ||
    sink >= n ||
    source == sink {
    return MinCostMaxFlowResult::{
      max_flow: 0.0,
      min_cost: 0.0,
      flow_matrix: [],
    }
  }

  let work_flow = mcmf_deep_copy(net.flow)
  let mut total_flow = 0.0
  let eps = 0.000001

  while true {
    let (parent, is_forward, found) = bellman_ford(
      net.capacity,
      net.cost,
      work_flow,
      n,
      source,
      sink,
    )
    if !found {
      break
    }
    let bottleneck = find_bottleneck(
      parent,
      is_forward,
      sink,
      net.capacity,
      work_flow,
    )
    if bottleneck <= eps {
      break
    }
    augment_flow(parent, source, sink, work_flow, bottleneck)
    total_flow = total_flow + bottleneck
  }

  let mut total_cost = 0.0
  for i in 0..<n {
    for j in 0..<n {
      if work_flow[i][j] > eps {
        total_cost = total_cost + work_flow[i][j] * net.cost[i][j]
      }
    }
  }

  let result_matrix : Array[Array[Double?]] = []
  for i in 0..<n {
    let row : Array[Double?] = []
    for j in 0..<n {
      if work_flow[i][j] > eps {
        row.push(Some(work_flow[i][j]))
      } else {
        row.push(None)
      }
    }
    result_matrix.push(row)
  }

  MinCostMaxFlowResult::{
    max_flow: total_flow,
    min_cost: total_cost,
    flow_matrix: result_matrix,
  }
}
