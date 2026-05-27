///|
/// Hopcroft-Karp 二分图最大匹配算法
///
/// 时间复杂度 O(E√V)，比匈牙利算法(VE)更快，适合大规模稀疏二分图。
/// 使用 BFS 分层 + DFS 增广，交替进行。
///
/// ## 参数
/// - `g`: 实现了 GraphReadable 的图结构
/// - `left_nodes`: 左部节点集合 (U 分区)
/// - `right_nodes`: 右部节点集合 (V 分区)
///
/// ## 返回
/// MatchingResult 包含匹配边列表和匹配数
pub fn[G : @core.GraphReadable] hopcroft_karp(
  g : G,
  left_nodes : Array[@core.NodeId],
  right_nodes : Array[@core.NodeId],
) -> MatchingResult {
  if left_nodes.length() == 0 || right_nodes.length() == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  let n_left = left_nodes.length()
  let n_right = right_nodes.length()

  let adj : Array[Array[Int]] = Array::make(n_left, [])
  let mut u_idx = 0
  while u_idx < n_left {
    let u_node = left_nodes[u_idx]
    for v_node in @core.GraphReadable::neighbors(g, u_node) {
      match find_node_index(v_node, right_nodes) {
        Some(v_idx) => adj[u_idx].push(v_idx)
        None => ()
      }
    }
    u_idx = u_idx + 1
  }

  hopcroft_karp_impl(n_left, n_right, adj)
}

///|
/// Hopcroft-Karp 核心实现（索引版本）
fn hopcroft_karp_impl(
  n_left : Int,
  n_right : Int,
  adj : Array[Array[Int]],
) -> MatchingResult {
  if n_left == 0 || n_right == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  let pair_u : Array[Int?] = Array::make(n_left, None)
  let pair_v : Array[Int?] = Array::make(n_right, None)
  let dist : Array[Int] = Array::make(n_left, 0)
  let mut cardinality = 0

  while true {
    // === BFS Phase: 构建分层图 ===
    let queue : Array[Int] = []
    let mut q_head = 0

    let mut u = 0
    while u < n_left {
      match pair_u[u] {
        None => {
          dist[u] = 0
          queue.push(u)
        }
        Some(_) => dist[u] = -1
      }
      u = u + 1
    }

    let mut found_augment = false

    while q_head < queue.length() {
      let cur_u = queue[q_head]
      q_head = q_head + 1

      let mut i = 0
      while i < adj[cur_u].length() {
        let v = adj[cur_u][i]
        match pair_v[v] {
          None => found_augment = true
          Some(u2) =>
            if dist[u2] == -1 {
              dist[u2] = dist[cur_u] + 1
              queue.push(u2)
            }
        }
        i = i + 1
      }
    }

    if !found_augment {
      break
    }

    // === DFS Phase: 在分层图上搜索增广路 ===
    let mut u = 0
    while u < n_left {
      match pair_u[u] {
        None =>
          if hopcroft_karp_dfs(u, adj, pair_u, pair_v, dist) {
            cardinality = cardinality + 1
          }
        Some(_) => ()
      }
      u = u + 1
    }
  }

  // 转换结果：pair_v 中的匹配转回 (NodeId, NodeId)
  let result_edges : Array[(@core.NodeId, @core.NodeId)] = []
  let mut v = 0
  while v < n_right {
    match pair_v[v] {
      Some(u_val) =>
        result_edges.push((@core.NodeId(u_val), @core.NodeId(n_left + v)))
      None => ()
    }
    v = v + 1
  }

  MatchingResult::{ matching_edges: result_edges, cardinality }
}

///|
/// DFS 增广路搜索（基于 BFS 分层图）
fn hopcroft_karp_dfs(
  u : Int,
  adj : Array[Array[Int]],
  pair_u : Array[Int?],
  pair_v : Array[Int?],
  dist : Array[Int],
) -> Bool {
  let mut i = 0
  while i < adj[u].length() {
    let v = adj[u][i]
    match pair_v[v] {
      None => {
        pair_u[u] = Some(v)
        pair_v[v] = Some(u)
        return true
      }
      Some(u2) =>
        if dist[u2] == dist[u] + 1 && hopcroft_karp_dfs(u2, adj, pair_u, pair_v, dist) {
          pair_u[u] = Some(v)
          pair_v[v] = Some(u)
          return true
        }
    }
    i = i + 1
  }
  dist[u] = -1
  false
}