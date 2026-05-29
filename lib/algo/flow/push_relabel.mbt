/// Push-Relabel 最大流算法 (Simple)
///
/// 使用全局重标记策略，简单可靠。

///|
/// Push-Relabel 最大流
///
/// 通过重复扫描活动节点直到所有超额被推送至 sink。
pub fn push_relabel(net : FlowNetwork, source : Int, sink : Int) -> MaxFlowResult {
  let n = net.node_count
  if n <= 1 || source == sink {
    return MaxFlowResult::{ max_flow: 0.0, flow_matrix: [] }
  }
  if source < 0 || source >= n || sink < 0 || sink >= n {
    return MaxFlowResult::{ max_flow: 0.0, flow_matrix: [] }
  }

  let cap = deep_copy_matrix(net.capacity)
  let flow_matrix = deep_copy_matrix(net.flow)
  let height : Array[Int] = Array::make(n, 0)
  let excess : Array[Double] = Array::make(n, 0.0)
  height[source] = n

  // 从 source 推送初始流量
  let mut v = 0
  while v < n {
    if cap[source][v] > 0.0 {
      let f = cap[source][v]
      flow_matrix[source][v] = flow_matrix[source][v] + f
      flow_matrix[v][source] = flow_matrix[v][source] - f
      cap[source][v] = 0.0
      cap[v][source] = cap[v][source] + f
      excess[v] = f
    }
    v = v + 1
  }

  // 只要有活动节点就继续
  let mut active = true
  while active {
    active = false
    let mut u = 0
    while u < n {
      if u != source && u != sink && excess[u] > 1.0e-12 {
        active = true
        let old_h = height[u]
        // 尝试推送
        v = 0
        while v < n {
          if cap[u][v] > 1.0e-12 && height[u] == height[v] + 1 {
            let f = if excess[u] < cap[u][v] { excess[u] } else { cap[u][v] }
            flow_matrix[u][v] = flow_matrix[u][v] + f
            flow_matrix[v][u] = flow_matrix[v][u] - f
            cap[u][v] = cap[u][v] - f
            cap[v][u] = cap[v][u] + f
            excess[u] = excess[u] - f
            excess[v] = excess[v] + f
            if excess[u] <= 1.0e-12 {
              break
            }
          }
          v = v + 1
        }

        if excess[u] > 1.0e-12 {
          // Relabel
          let mut min_h = n * 2
          v = 0
          while v < n {
            if cap[u][v] > 1.0e-12 && height[v] < min_h {
              min_h = height[v]
            }
            v = v + 1
          }
          if min_h < n * 2 {
            height[u] = min_h + 1
          } else {
            height[u] = n * 2
          }
        }
      }
      u = u + 1
    }
  }

  let max_flow_val = excess[sink]

  // 转换为 Array[Double?]
  let fm : Array[Array[Double?]] = Array::make(n, [])
  let mut ii = 0
  while ii < n {
    let row : Array[Double?] = Array::make(n, None)
    let mut jj = 0
    while jj < n {
      row[jj] = Some(flow_matrix[ii][jj])
      jj = jj + 1
    }
    fm[ii] = row
    ii = ii + 1
  }

  MaxFlowResult::{ max_flow: max_flow_val, flow_matrix: fm }
}
