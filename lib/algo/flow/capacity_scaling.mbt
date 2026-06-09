///|
/// 容量缩放最大流算法 (Capacity Scaling)
///
/// Capacity Scaling 是一种基于缩放技术的最大流算法，
/// 通过从大到小逐步降低容量阈值，将大规模容量网络的最大流问题
/// 分解为若干轮小规模子问题，显著减少增广路搜索次数。
///
/// # 核心思想
///
/// ```
/// Δ ← 2^{⌊log₂(maxCap)⌋}          // 最大容量位
/// while Δ ≥ 1:
///   while 残量≥Δ 的增广路存在:
///     沿该路增广
///   Δ ← Δ / 2
/// ```
///
/// 从高到低的缩放策略确保：
/// 1. 大容量通道优先饱和，快速逼近最大流值
/// 2. 每轮 Δ 中最多增广 O(E) 次
/// 3. 整体复杂度 O(E² · log U)，对超大容量网络友好
///
/// # 复杂度
///
/// - 时间: O(E² · log U)，其中 U = max capacity
/// - 空间: O(V²)（矩阵表示）
///
/// # 对比其他最大流算法
///
/// | 算法 | 时间复杂度 | 特点 |
/// |------|:---------:|------|
/// | Edmonds-Karp | O(VE²) | BFS 最短增广路，实现最简单 |
/// | Dinic | O(E√V) | 分层图+阻塞流，通用性能最优 |
/// | Push-Relabel | O(V²E) | 预流推进，理论最优界 |
/// | **容量缩放** | **O(E²logU)** | **大容量友好，分治缩放策略** |
///
/// # 参数
///
/// - `graph`: 流网络（FlowNetwork 类型）
/// - `source`: 源点索引
/// - `sink`: 汇点索引
///
/// # 返回
///
/// `MaxFlowResult` 包含最大流量值和流量矩阵

// ============================================================================
// 私有辅助：BFS 在 Δ 残量图中找增广路
// ============================================================================

///|
/// BFS 搜索残量 ≥ Δ 的增广路。
/// 只考虑 residual_capacity ≥ delta 的边，确保大通道优先。
fn cs_bfs(
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
  n : Int,
  source : Int,
  sink : Int,
  delta : Double,
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
        let residual = capacity[u][v] - flow[u][v]
        if residual >= delta {
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

// ============================================================================
// 私有辅助：找路径瓶颈值
// ============================================================================

///|
fn cs_bottleneck(
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

// ============================================================================
// 私有辅助：沿路径增广流量
// ============================================================================

///|
fn cs_augment(
  parent : Array[Int?],
  source : Int,
  sink : Int,
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

// ============================================================================
// 私有辅助：计算初始缩放因子 Δ
// ============================================================================

///|
/// 找到网络中最大容量边，取最接近的 2 的幂作为初始 Δ。
fn find_initial_delta(capacity : Array[Array[Double]], n : Int) -> Double {
  let mut max_cap = 0.0
  for i in 0..<n {
    for j in 0..<n {
      if capacity[i][j] > max_cap {
        max_cap = capacity[i][j]
      }
    }
  }
  if max_cap <= 0.0 {
    return 1.0
  }
  // 找到最接近的 2 的幂
  let mut delta = 1.0
  while delta * 2.0 <= max_cap {
    delta = delta * 2.0
  }
  delta
}

// ============================================================================
// 私有辅助：深拷贝矩阵
// ============================================================================

///|
fn cs_deep_copy(src : Array[Array[Double]]) -> Array[Array[Double]] {
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
// 公开 API：容量缩放最大流
// ============================================================================

///|
pub fn capacity_scaling(
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

  let work_flow = cs_deep_copy(graph.flow)
  let mut total_flow = 0.0
  let mut delta = find_initial_delta(graph.capacity, n)

  while delta >= 1.0 {
    // 在当前 Δ 残量图中反复增广
    while true {
      let (parent, found) = cs_bfs(
        graph.capacity, work_flow, n, source, sink, delta,
      )
      if !found {
        break
      }
      let bottleneck = cs_bottleneck(
        parent, sink, graph.capacity, work_flow,
      )
      if bottleneck < delta {
        break
      }
      cs_augment(parent, source, sink, work_flow, bottleneck)
      total_flow = total_flow + bottleneck
    }
    delta = delta / 2.0
  }

  // 转化为 Option 矩阵输出
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