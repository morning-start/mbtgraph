///|
/// Girvan-Newman 社区检测算法
///
/// 基于边介数（Edge Betweenness）的分裂式层次聚类：
/// 迭代移除网络中边介数最高的边，直到没有边剩余。
/// 通过 Dendrogram（层次树）记录社区结构的演化过程。
///
/// # 算法步骤
///
/// 1. 计算每条边的边介数（Brandes 算法，O(VE)）
/// 2. 移除边介数最高的边
/// 3. 重新计算剩余边的边介数
/// 4. 重复直到没有边剩余
///
/// # 参数
///
/// - `graph`: 无向图（需实现 GraphReadable）
/// - `num_levels`: 返回的层次数（从高到低，0=全部分解）
///
/// # 返回值
///
/// 每个层次对应的社区划分结果

///|
/// Girvan-Newman 单层结果
pub(all) struct GnLevelResult {
  /// 该层次检测到的社区列表（每个社区是一组节点 ID）
  communities : Array[Array[Int]]
  /// 该层次的模块度
  modularity : Double
  /// 当前层次移除的边介数值
  removed_edge_betweenness : Double
} derive(Debug)

///|
/// Girvan-Newman 完整结果
pub(all) struct GnResult {
  /// 每个层次的社区划分（层次从高到低）
  levels : Array[GnLevelResult]
  /// 最优模块度对应的层次索引
  best_level : Int
  /// 最优模块度值
  best_modularity : Double
  /// 总层数
  total_levels : Int
} derive(Debug)

///|
/// 执行 Girvan-Newman 社区检测
///
/// 每次迭代移除边介数最高的边，直到图被完全分解。
/// 可用 num_levels 限制返回的最大层数（0=全部）。
pub fn[G : @core.GraphReadable] girvan_newman(
  graph : G,
  num_levels : Int,
) -> GnResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return GnResult::{
      levels: [],
      best_level: 0,
      best_modularity: 0.0,
      total_levels: 0,
    }
  }
  if n <= 2 {
    // 只有全为一个社区才合理
    let single_comm : Array[Array[Int]] = []
    let all_nodes : Array[Int] = []
    let mut i = 0
    while i < n {
      all_nodes.push(i)
      i = i + 1
    }
    single_comm.push(all_nodes)
    return GnResult::{
      levels: [
        GnLevelResult::{
          communities: single_comm,
          modularity: 0.0,
          removed_edge_betweenness: 0.0,
        },
      ],
      best_level: 0,
      best_modularity: 0.0,
      total_levels: 1,
    }
  }

  // 预取所有无向边列表（去重）
  let edge_list = gn_collect_edges(graph, n)
  // 残差边集合（未被移除的边）
  let mut remaining = gn_copy_edge_list(edge_list)

  let level_results : Array[GnLevelResult] = []
  let mut level_idx = 0
  let mut best_mod = -1.0
  let mut best_level_idx = 0
  let limit = if num_levels > 0 { num_levels } else { 1000000 }

  while remaining.length() > 0 && level_idx < limit {
    // 计算当前残差图中所有边的边介数
    let edge_betw = gn_compute_edge_betweenness(n, remaining)

    // 找到边介数最高的边
    let max_edge = gn_find_max_betweenness(edge_betw)
    match max_edge {
      None => break
      Some((max_idx, _max_betw)) => {
        // 移除该边
        let removed = remaining[max_idx]
        remaining = gn_remove_at(remaining, max_idx)

        // 计算当前社区划分
        let communities = gn_find_components(n, remaining)
        // 计算模块度
        let mod_val = gn_modularity(n, edge_list, communities)

        if mod_val > best_mod {
          best_mod = mod_val
          best_level_idx = level_idx
        }

        level_results.push(GnLevelResult::{
          communities,
          modularity: mod_val,
          removed_edge_betweenness: _max_betw,
        })
        level_idx = level_idx + 1
      }
    }
  }

  GnResult::{
    levels: level_results,
    best_level: best_level_idx,
    best_modularity: best_mod,
    total_levels: level_idx,
  }
}

// ============================================================================
// 内部辅助函数
// ============================================================================

///|
/// 收集图中所有无向边（去重，u < v）
fn[G : @core.GraphReadable] gn_collect_edges(
  graph : G,
  _n : Int,
) -> Array[(Int, Int, Double)] {
  let edges : Array[(Int, Int, Double)] = []
  for u in @core.GraphReadable::node_ids(graph) {
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw {
        (v, w) => if u.0 < v.0 { edges.push((u.0, v.0, w)) }
      }
    }
  }
  edges
}

///|
fn gn_copy_edge_list(
  src : Array[(Int, Int, Double)],
) -> Array[(Int, Int, Double)] {
  let result : Array[(Int, Int, Double)] = []
  for e in src {
    result.push(e)
  }
  result
}

///|
fn gn_remove_at(
  arr : Array[(Int, Int, Double)],
  idx : Int,
) -> Array[(Int, Int, Double)] {
  let result : Array[(Int, Int, Double)] = []
  let mut i = 0
  while i < arr.length() {
    if i != idx {
      result.push(arr[i])
    }
    i = i + 1
  }
  result
}

///|
/// 计算边介数（Brandes 算法适配版）
///
/// 对每个源节点 s 运行 BFS，记录最短路径数和依赖值，
/// 最后累加每条边作为最短路径桥的次数。
fn gn_compute_edge_betweenness(
  n : Int,
  edges : Array[(Int, Int, Double)],
) -> Array[Double] {
  let m = edges.length()
  if m == 0 {
    return []
  }
  // edge_betweenness[i] 表示 edges[i] 的介数值
  let edge_betw = Array::make(m, 0.0)

  // 构建邻接表（基于当前残差边）
  let adj = gn_build_adj(n, edges)

  // 对每个节点作为源点
  let mut s = 0
  while s < n {
    // BFS: 层级、最短路径数
    let level = Array::make(n, -1)
    let sigma = Array::make(n, 0.0)
    let order : Array[Int] = []
    let queue : Array[Int] = [s]
    level[s] = 0
    sigma[s] = 1.0
    let mut head = 0
    while head < queue.length() {
      let v = queue[head]
      head = head + 1
      order.push(v)
      for w in adj[v] {
        if level[w] < 0 {
          level[w] = level[v] + 1
          queue.push(w)
        }
        if level[w] == level[v] + 1 {
          sigma[w] = sigma[w] + sigma[v]
        }
      }
    }
    // 依赖累积
    let delta = Array::make(n, 0.0)
    let mut k = order.length() - 1
    while k >= 0 {
      let w = order[k]
      for v in adj[w] {
        if level[v] == level[w] - 1 {
          let contribution = sigma[v] / sigma[w] * (1.0 + delta[w])
          delta[v] = delta[v] + contribution
          // 找到边 (v, w) 并累加介数
          let ei = gn_find_edge_index(edges, v, w)
          if ei >= 0 {
            edge_betw[ei] = edge_betw[ei] + contribution
          }
        }
      }
      if w != s {
        // delta[w] already accumulated for edges
      }
      k = k - 1
    }
    s = s + 1
  }
  // 无向图每条边被正反计算两次，除以 2
  let mut ei2 = 0
  while ei2 < m {
    edge_betw[ei2] = edge_betw[ei2] / 2.0
    ei2 = ei2 + 1
  }
  edge_betw
}

///|
/// 构建邻接表（基于残差边）
fn gn_build_adj(
  n : Int,
  edges : Array[(Int, Int, Double)],
) -> Array[Array[Int]] {
  let adj : Array[Array[Int]] = Array::make(n, [])
  for e in edges {
    match e {
      (u, v, _) => {
        adj[u].push(v)
        adj[v].push(u)
      }
    }
  }
  adj
}

///|
/// 在边列表中找到 (u, v) 或 (v, u) 的索引
fn gn_find_edge_index(
  edges : Array[(Int, Int, Double)],
  u : Int,
  v : Int,
) -> Int {
  let mut i = 0
  while i < edges.length() {
    match edges[i] {
      (a, b, _) => if (a == u && b == v) || (a == v && b == u) { return i }
    }
    i = i + 1
  }
  -1
}

///|
/// 找到边介数数组中的最大值索引
fn gn_find_max_betweenness(betw : Array[Double]) -> (Int, Double)? {
  if betw.length() == 0 {
    return None
  }
  let mut max_idx = 0
  let mut max_val = betw[0]
  let mut i = 1
  while i < betw.length() {
    if betw[i] > max_val {
      max_val = betw[i]
      max_idx = i
    }
    i = i + 1
  }
  Some((max_idx, max_val))
}

///|
/// 基于残差边列表找连通分量
fn gn_find_components(
  n : Int,
  edges : Array[(Int, Int, Double)],
) -> Array[Array[Int]] {
  let adj = gn_build_adj(n, edges)
  let visited = Array::make(n, false)
  let comps : Array[Array[Int]] = []
  let mut i = 0
  while i < n {
    if !visited[i] {
      let comp : Array[Int] = []
      let queue : Array[Int] = [i]
      visited[i] = true
      let mut head = 0
      while head < queue.length() {
        let v = queue[head]
        head = head + 1
        comp.push(v)
        for w in adj[v] {
          if !visited[w] {
            visited[w] = true
            queue.push(w)
          }
        }
      }
      comps.push(comp)
    }
    i = i + 1
  }
  comps
}

///|
/// 计算模块度（Modularity）
///
/// Q = (1/2m) * Σ[ A_uv - (deg(u)·deg(v))/(2m) ] * δ(cu, cv)
fn gn_modularity(
  n : Int,
  all_edges : Array[(Int, Int, Double)],
  communities : Array[Array[Int]],
) -> Double {
  if n == 0 || all_edges.length() == 0 {
    return 0.0
  }
  let m = int_to_double(all_edges.length())
  // 计算每个节点的度
  let deg = Array::make(n, 0)
  for e in all_edges {
    match e {
      (u, v, _) => {
        deg[u] = deg[u] + 1
        deg[v] = deg[v] + 1
      }
    }
  }
  // 建立社区映射
  let comm_of = Array::make(n, -1)
  let mut ci = 0
  while ci < communities.length() {
    for node in communities[ci] {
      comm_of[node] = ci
    }
    ci = ci + 1
  }
  let mut q = 0.0
  for e in all_edges {
    match e {
      (u, v, _) =>
        if comm_of[u] == comm_of[v] && comm_of[u] >= 0 {
          q = q +
            1.0 -
            int_to_double(deg[u]) * int_to_double(deg[v]) / (2.0 * m)
        }
    }
  }
  q = q / (2.0 * m)
  if q < 0.0 {
    0.0
  } else {
    q
  }
}
