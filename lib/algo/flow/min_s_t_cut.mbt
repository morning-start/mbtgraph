///|
/// 最小 s-t 割算法
///
/// 基于最大流-最小割定理：最小 s-t 割的容量等于最大流值。
/// 通过计算最大流后，在残差图中从源点 BFS 找出所有可达节点，
/// 这些节点构成 s 侧，其余节点构成 t 侧的割。
///
/// # 参数
///
/// - `graph`: 流网络
/// - `source`: 源点
/// - `sink`: 汇点
///
/// # 返回
///
/// 最小割结果，包含割的容量、s 侧和 t 侧的节点集合

///|
/// 最小 s-t 割结果
pub(all) struct MinCutResult {
  /// 割的容量（最大流值）
  cut_capacity : Double
  /// s 侧节点集合（属于源点一侧的节点）
  s_side : Array[Int]
  /// t 侧节点集合（属于汇点一侧的节点）
  t_side : Array[Int]
  /// 割边集合 (from, to, capacity)
  cut_edges : Array[(Int, Int, Double)]
} derive(Debug)

///|
/// 计算最小 s-t 割
///
/// 基于 Dinic 最大流算法，计算后通过残差图的 BFS 确定割集。
/// 适用于 FlowNetwork 独立类型。
pub fn min_s_t_cut(
  graph : FlowNetwork,
  source : Int,
  sink : Int,
) -> MinCutResult {
  let n = graph.node_count
  if n == 0 || source < 0 || source >= n || sink < 0 || sink >= n {
    return MinCutResult::{
      cut_capacity: 0.0,
      s_side: [],
      t_side: [],
      cut_edges: [],
    }
  }
  if source == sink {
    return MinCutResult::{
      cut_capacity: 0.0,
      s_side: [source],
      t_side: [],
      cut_edges: [],
    }
  }

  // 深拷贝容量和流量矩阵
  let work_cap = mcut_deep_copy(graph.capacity)
  let work_flow = mcut_deep_copy(graph.flow)

  // 使用 Dinic 计算最大流（同时更新 work_flow）
  let max_flow_val = mcut_dinic_internal(n, work_cap, work_flow, source, sink)

  // 在残差图中 BFS 找到所有从 source 可达的节点 → s_side
  let reachable = mcut_bfs_residual(n, work_cap, work_flow, source)
  let s_side : Array[Int] = []
  let t_side : Array[Int] = []
  let mut i = 0
  while i < n {
    if reachable[i] {
      s_side.push(i)
    } else {
      t_side.push(i)
    }
    i = i + 1
  }

  // 收集割边（从 s_side 指向 t_side 的原始正向边）
  let cut_edges : Array[(Int, Int, Double)] = []
  for s_node in s_side {
    for t_node in t_side {
      if graph.capacity[s_node][t_node] > 0.0 {
        cut_edges.push((s_node, t_node, graph.capacity[s_node][t_node]))
      }
    }
  }

  MinCutResult::{ cut_capacity: max_flow_val, s_side, t_side, cut_edges }
}

// ============================================================================
// 内部辅助函数（mcut_ 前缀避免同名冲突）
// ============================================================================

///|
fn mcut_deep_copy(src : Array[Array[Double]]) -> Array[Array[Double]] {
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
fn mcut_bfs_residual(
  n : Int,
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
  source : Int,
) -> Array[Bool] {
  let visited = Array::make(n, false)
  let queue : Array[Int] = [source]
  visited[source] = true
  let mut head = 0
  while head < queue.length() {
    let u = queue[head]
    head = head + 1
    let mut v = 0
    while v < n {
      if !visited[v] {
        let residual = capacity[u][v] - flow[u][v]
        if residual > 0.000001 {
          visited[v] = true
          queue.push(v)
        }
      }
      v = v + 1
    }
  }
  visited
}

///|
fn mcut_dinic_internal(
  n : Int,
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
  source : Int,
  sink : Int,
) -> Double {
  let mut total_flow = 0.0
  while true {
    let level = Array::make(n, -1)
    let q : Array[Int] = [source]
    level[source] = 0
    let mut head = 0
    while head < q.length() {
      let u = q[head]
      head = head + 1
      let mut v = 0
      while v < n {
        if level[v] < 0 {
          let residual = capacity[u][v] - flow[u][v]
          if residual > 0.000001 {
            level[v] = level[u] + 1
            q.push(v)
          }
        }
        v = v + 1
      }
    }
    if level[sink] < 0 {
      break
    }
    let it = Array::make(n, 0)
    while true {
      let pushed = mcut_dinic_dfs(
        n, capacity, flow, level, it, source, sink, 1000000000000000000.0,
      )
      if pushed <= 0.000001 {
        break
      }
      total_flow = total_flow + pushed
    }
  }
  total_flow
}

///|
fn mcut_dinic_dfs(
  n : Int,
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
  level : Array[Int],
  it : Array[Int],
  u : Int,
  sink : Int,
  f : Double,
) -> Double {
  if u == sink {
    return f
  }
  let mut v = it[u]
  while v < n {
    if level[v] == level[u] + 1 {
      let residual = capacity[u][v] - flow[u][v]
      if residual > 0.000001 {
        let pushed = mcut_dinic_dfs(
          n,
          capacity,
          flow,
          level,
          it,
          v,
          sink,
          mcut_min(f, residual),
        )
        if pushed > 0.000001 {
          flow[u][v] = flow[u][v] + pushed
          flow[v][u] = flow[v][u] - pushed
          return pushed
        }
      }
    }
    v = v + 1
  }
  it[u] = v
  0.0
}

///|
fn mcut_min(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}
