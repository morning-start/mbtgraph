///|
/// Dinic 最大流算法
///
/// 使用 BFS 构建层次图 + DFS 寻找阻塞流，时间复杂度 O(E√V)。
/// 比 Edmonds-Karp (O(VE²)) 快一个数量级，适合大规模密集网络。
///
/// 核心优化:
/// 1. BFS 分层 — 每次只沿最短路径增广
/// 2. 阻塞流 — DFS 一次找到多条增广路
/// 3. 当前弧优化 — 跳过已饱和的边，避免重复检查

// ============================================================================
// 私有辅助：深拷贝流量矩阵（保证纯函数语义）
// ============================================================================

fn dinic_deep_copy(src : Array[Array[Double]]) -> Array[Array[Double]] {
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

// ============================================================================
// 私有辅助：BFS 构建层次图
// ============================================================================

///|
fn dinic_bfs(
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
  n : Int,
  source : Int,
  sink : Int,
) -> (Array[Int], Bool) {
  let level : Array[Int] = Array::make(n, -1)
  level[source] = 0
  let queue : Array[Int] = [source]
  let mut head = 0

  while head < queue.length() {
    let u = queue[head]
    head = head + 1
    let mut v = 0
    while v < n {
      if level[v] == -1 {
        let residual = capacity[u][v] - flow[u][v]
        if residual > 0.000001 {
          level[v] = level[u] + 1
          if v == sink {
            return (level, true)
          }
          queue.push(v)
        }
      }
      v = v + 1
    }
  }

  (level, level[sink] != -1)
}

// ============================================================================
// 私有辅助：DFS 在层次图上寻找阻塞流（含当前弧优化）
// ============================================================================

///|
fn dinic_dfs(
  u : Int,
  sink : Int,
  min_cap : Double,
  capacity : Array[Array[Double]],
  flow_ref : Array[Array[Double]],
  level : Array[Int],
  current_arc : Array[Int],
  n : Int,
) -> Double {
  if u == sink {
    return min_cap
  }
  let mut total_sent = 0.0
  let mut remaining = min_cap
  let mut i = current_arc[u]

  while i < n {
    let v = i
    let residual = capacity[u][v] - flow_ref[u][v]

    if residual > 0.000001 && level[v] == level[u] + 1 {
      let send_cap = if remaining < residual { remaining } else { residual }
      let pushed = dinic_dfs(
        v, sink, send_cap, capacity, flow_ref, level, current_arc, n,
      )
      if pushed > 0.000001 {
        flow_ref[u][v] = flow_ref[u][v] + pushed
        flow_ref[v][u] = flow_ref[v][u] - pushed
        total_sent = total_sent + pushed
        remaining = remaining - pushed
        if remaining <= 0.000001 {
          current_arc[u] = i
          return total_sent
        }
      }
    }
    i = i + 1
  }

  current_arc[u] = i
  total_sent
}

// ============================================================================
// 公开 API：Dinic 最大流
// ============================================================================

///|
/// Dinic 最大流算法
///
/// 在流网络上计算从 source 到 sink 的最大流。
///
/// ## 算法流程
/// 1. **BFS 分层**: 从 source 出发 BFS，构建层次图（level graph）
/// 2. **DFS 增广**: 在层次图上反复 DFS 找阻塞流（blocking flow）
/// 3. **重复**: 直到 BFS 无法到达 sink 为止
///
/// ## 复杂度
/// - 时间: O(E√V)，其中 V=节点数, E=边数
/// - 空间: O(V²)（矩阵表示）
///
/// ## 对比 Edmonds-Karp
/// | 算法 | 时间复杂度 | 核心改进 |
/// |------|:---------:|---------|
/// | Edmonds-Karp | O(VE²) | 每次 BFS 一条增广路 |
/// | **Dinic** | **O(E√V)** | **BFS 分层 + DFS 阻塞流** |
///
/// ## 参数
/// - `net`: 流网络（FlowNetwork 类型）
/// - `source`: 源点索引
/// - `sink`: 汇点索引
///
/// ## 返回
/// `MaxFlowResult` 包含最大流量值和流量矩阵
pub fn dinic(graph : FlowNetwork, source : Int, sink : Int) -> MaxFlowResult {
  let n = graph.node_count
  if n == 0 ||
    source < 0 ||
    source >= n ||
    sink < 0 ||
    sink >= n ||
    source == sink {
    return MaxFlowResult::{ max_flow: 0.0, flow_matrix: [] }
  }

  let work_flow = dinic_deep_copy(graph.flow)
  let mut total_flow = 0.0

  while true {
    let (level, can_reach) = dinic_bfs(graph.capacity, work_flow, n, source, sink)

    if !can_reach {
      break
    }

    let current_arc : Array[Int] = Array::make(n, 0)

    while true {
      let pushed = dinic_dfs(
        source,
        sink,
        1000000000000000000.0,
        graph.capacity,
        work_flow,
        level,
        current_arc,
        n,
      )
      if pushed <= 0.000001 {
        break
      }
      total_flow = total_flow + pushed
    }
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
