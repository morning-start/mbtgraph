///|
/// 匈牙利算法 (Hungarian / Kuhn's Algorithm)
///
/// 二分图最大匹配算法，基于 DFS 增广路搜索。
/// 时间复杂度 O(VE)，空间复杂度 O(V+E)。
///
/// 适用于二分图最大匹配场景，是 P4 图匹配模块的核心算法。

// ============================================================================
// 私有辅助函数：DFS 增广路搜索
// ============================================================================

fn hungarian_dfs(
  u : Int,
  adj : Array[Array[Int]],
  match_right : Array[Int?],
  visited : Array[Bool],
) -> Bool {
  let mut i = 0
  while i < adj[u].length() {
    let v = adj[u][i]
    if !visited[v] {
      visited[v] = true
      match match_right[v] {
        None => {
          match_right[v] = Some(u)
          return true
        }
        Some(matched_u) =>
          if hungarian_dfs(matched_u, adj, match_right, visited) {
            match_right[v] = Some(u)
            return true
          }
      }
    }
    i = i + 1
  }
  false
}

// ============================================================================
// 公开 API：二分图最大匹配（邻接表输入）
// ============================================================================

///|
/// 二分图最大匹配 — 邻接表版本
///
/// 使用匈牙利算法求解二分图的最大基数匹配。
///
/// ## 参数
/// - `n_left`: 左部节点数 (U 分区，编号 0..n_left-1)
/// - `n_right`: 右部节点数 (V 分区，编号 0..n_right-1)
/// - `edges`: 边列表，每条边 `(u, v)` 表示 U 中节点 u 连向 V 中节点 v
///
/// ## 返回
/// `MatchingResult` 包含匹配边列表和匹配数
///
/// ## 复杂度
/// - 时间: O(VE)，其中 V = n_left，E = edges.length()
/// - 空间: O(V + E)
pub fn bipartite_matching(
  n_left : Int,
  n_right : Int,
  edges : Array[(Int, Int)],
) -> MatchingResult {
  if n_left == 0 || n_right == 0 || edges.length() == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  let adj : Array[Array[Int]] = Array::make(n_left, [])
  for edge in edges {
    match edge {
      (u, v) =>
        if u >= 0 && u < n_left && v >= 0 && v < n_right {
          adj[u].push(v)
        }
    }
  }

  let match_right : Array[Int?] = Array::make(n_right, None)
  let result_edges : Array[(@core.NodeId, @core.NodeId)] = []
  let mut cardinality = 0

  let mut u = 0
  while u < n_left {
    let visited : Array[Bool] = Array::make(n_right, false)
    if hungarian_dfs(u, adj, match_right, visited) {
      cardinality = cardinality + 1
    }
    u = u + 1
  }

  let mut v = 0
  while v < n_right {
    match match_right[v] {
      Some(u_val) =>
        result_edges.push((@core.NodeId(u_val), @core.NodeId(n_left + v)))
      None => ()
    }
    v = v + 1
  }

  MatchingResult::{ matching_edges: result_edges, cardinality }
}

// ============================================================================
// 私有辅助：在数组中查找 NodeId 对应的索引
// ============================================================================

///|
fn find_node_index(node : @core.NodeId, nodes : Array[@core.NodeId]) -> Int? {
  let mut i = 0
  while i < nodes.length() {
    if nodes[i] == node {
      return Some(i)
    }
    i = i + 1
  }
  None
}

// ============================================================================
// 公开 API：基于 GraphReadable trait 的通用版本
// ============================================================================

///|
/// 二分图最大匹配 — GraphReadable 版本
///
/// 给定一个二分图（通过左右分区指定），计算最大匹配。
///
/// ## 参数
/// - `g`: 实现了 GraphReadable 的图结构
/// - `left_nodes`: 左分区节点集合 (U)
/// - `right_nodes`: 右分区节点集合 (V)
///
/// ## 前置条件
/// 图必须是二分图，所有边的端点分别属于 left_nodes 和 right_nodes。
pub fn[G : @core.GraphReadable] bipartite_matching_graph(
  graph : G,
  left_nodes : Array[@core.NodeId],
  right_nodes : Array[@core.NodeId],
) -> MatchingResult {
  if left_nodes.length() == 0 || right_nodes.length() == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  let n_left = left_nodes.length()
  let n_right = right_nodes.length()

  let edges : Array[(Int, Int)] = []
  let mut u_idx = 0
  while u_idx < n_left {
    let u_node = left_nodes[u_idx]
    for v_node in @core.GraphReadable::neighbors(graph, u_node) {
      match find_node_index(v_node, right_nodes) {
        Some(v_idx) => edges.push((u_idx, v_idx))
        None => ()
      }
    }
    u_idx = u_idx + 1
  }

  bipartite_matching(n_left, n_right, edges)
}
