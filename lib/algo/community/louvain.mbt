/// Louvain 社区检测算法实现

///|
/// 执行 Louvain 社区检测
pub fn[G : @core.GraphReadable] louvain(
  graph : G,
  resolution : Double,
) -> CommunityResult {
  let n = @core.GraphReadable::node_count(graph)

  if n == 0 {
    return CommunityResult::{
      labels: [],
      modularity: 0.0,
      num_communities: 0,
      levels: 0,
    }
  }

  if n == 1 {
    return CommunityResult::{
      labels: [0],
      modularity: 0.0,
      num_communities: 1,
      levels: 1,
    }
  }

  let edges_info = build_edge_info(graph, n)
  let m_edges = edges_info.edge_count
  let adjacency = edges_info.adjacency

  let total_weight = int_to_double(m_edges)
  let inv_2m = 1.0 / (2.0 * total_weight)

  let community_of : Array[Int] = Array::make(n, 0)
  let degree = edges_info.degree
  let self_loop = edges_info.self_loop
  let mut i = 0
  while i < n {
    community_of[i] = i
    i = i + 1
  }

  let sum_tot : Array[Double] = Array::make(n, 0.0)
  let fine_internal : Array[Double] = Array::make(n, 0.0)
  let mut k = 0
  while k < n {
    sum_tot[k] = degree[k]
    fine_internal[k] = self_loop[k]
    k = k + 1
  }

  let res_factor = if resolution <= 0.0 { 1.0 } else { resolution }
  let max_passes = 20

  let mut improved = true
  let mut pass = 0

  while improved && pass < max_passes {
    improved = false
    pass = pass + 1

    let mut idx = 0
    while idx < n {
      let node_i = idx
      let curr_comm = community_of[node_i]
      let deg_i = degree[node_i]
      let neigh_communities = find_neighbor_communities(
        adjacency, community_of, node_i, n,
      )

      let mut best_comm = curr_comm
      let mut best_gain = 0.0

      let mut nc = 0
      while nc < neigh_communities.length() {
        let target_comm = neigh_communities[nc]
        if target_comm == curr_comm {
          nc = nc + 1
          continue
        }

        let k_i_in_tgt = int_to_double(
          count_edges_to_community(adjacency, node_i, community_of, target_comm),
        )
        let k_i_in_curr = int_to_double(
          count_edges_to_community(adjacency, node_i, community_of, curr_comm),
        )

        let curr_int = fine_internal[curr_comm]
        let curr_sum = sum_tot[curr_comm]
        let tgt_int = fine_internal[target_comm]
        let tgt_sum = sum_tot[target_comm]

        let gain = compute_gain(
          curr_int, curr_sum, tgt_int, tgt_sum, deg_i, k_i_in_curr, k_i_in_tgt, total_weight,
          res_factor,
        )

        if gain > best_gain {
          best_gain = gain
          best_comm = target_comm
        }
        nc = nc + 1
      }

      if best_gain > 0.0 && best_comm != curr_comm {
        improved = true
        let edges_to_curr = int_to_double(
          count_edges_to_community(adjacency, node_i, community_of, curr_comm),
        )
        let edges_to_best = int_to_double(
          count_edges_to_community(adjacency, node_i, community_of, best_comm),
        )

        fine_internal[curr_comm] = fine_internal[curr_comm] -
          edges_to_curr * 2.0 -
          self_loop[node_i]
        fine_internal[best_comm] = fine_internal[best_comm] +
          edges_to_best * 2.0 +
          self_loop[node_i]
        sum_tot[curr_comm] = sum_tot[curr_comm] - deg_i
        sum_tot[best_comm] = sum_tot[best_comm] + deg_i
        community_of[node_i] = best_comm
      }
      idx = idx + 1
    }
  }

  let relabeled = relabel_communities(community_of, n)
  let num_comms = count_unique_comms(relabeled, n)
  let mod_val = compute_modularity(
    adjacency, self_loop, relabeled, degree, total_weight, n,
  )

  CommunityResult::{
    labels: relabeled,
    modularity: mod_val,
    num_communities: num_comms,
    levels: 1,
  }
}

///|
/// 计算将节点 i 从 curr_comm 移到 target_comm 的模块度增益
fn compute_gain(
  _curr_int : Double,
  curr_sum : Double,
  _tgt_int : Double,
  tgt_sum : Double,
  deg_i : Double,
  deg_to_curr : Double,
  deg_to_tgt : Double,
  total_weight : Double,
  res_factor : Double,
) -> Double {
  let m = total_weight
  let two_m_sq = 2.0 * m * (2.0 * m)
  let four_m_sq = 4.0 * m * m

  let gain_remove = -deg_to_curr / m +
    curr_sum * deg_i / two_m_sq -
    deg_i * deg_i / four_m_sq
  let gain_add = deg_to_tgt / m -
    tgt_sum * deg_i / two_m_sq -
    deg_i * deg_i / four_m_sq

  (gain_remove + gain_add) * res_factor
}

///|
priv struct EdgeInfo {
  edge_count : Int
  adjacency : Array[Array[Int]]
  self_loop : Array[Double]
  degree : Array[Double]
}

///|
fn[G : @core.GraphReadable] build_edge_info(graph : G, n : Int) -> EdgeInfo {
  let adj : Array[Array[Int]] = []
  let mut i = 0
  while i < n {
    adj.push([])
    i = i + 1
  }
  let self_loop : Array[Double] = Array::make(n, 0.0)
  let degree : Array[Double] = Array::make(n, 0.0)
  let mut ui = 0
  while ui < n {
    for vi in @core.GraphReadable::neighbors(graph, @core.NodeId(ui)) {
      if vi.0 != ui {
        adj[ui].push(vi.0)
        degree[ui] = degree[ui] + 1.0
      } else {
        self_loop[ui] = self_loop[ui] + 1.0
      }
    }
    ui = ui + 1
  }
  let mut ec = 0
  let edges = @core.GraphReadable::edges(graph)
  for edge in edges {
    ec = ec + 1
  }
  EdgeInfo::{ edge_count: ec, adjacency: adj, self_loop, degree }
}

///|
fn find_neighbor_communities(
  adjacency : Array[Array[Int]],
  community_of : Array[Int],
  node : Int,
  n : Int,
) -> Array[Int] {
  let seen : Array[Bool] = Array::make(n, false)
  let result : Array[Int] = []
  for nb in adjacency[node] {
    let comm = community_of[nb]
    if !seen[comm] {
      seen[comm] = true
      result.push(comm)
    }
  }
  result
}

///|

///|
fn count_edges_to_community(
  adjacency : Array[Array[Int]],
  node : Int,
  community_of : Array[Int],
  target_comm : Int,
) -> Int {
  let mut count = 0
  for nb in adjacency[node] {
    if community_of[nb] == target_comm {
      count = count + 1
    }
  }
  count
}

///|
fn relabel_communities(labels : Array[Int], n : Int) -> Array[Int] {
  let mapping : Array[Int] = Array::make(n, -1)
  let mut next_id = 0
  let result : Array[Int] = []
  let mut i = 0
  while i < n {
    let lbl = labels[i]
    if mapping[lbl] < 0 {
      mapping[lbl] = next_id
      next_id = next_id + 1
    }
    result.push(mapping[lbl])
    i = i + 1
  }
  result
}

///|
fn count_unique_comms(labels : Array[Int], n : Int) -> Int {
  let mut max_id = 0
  let mut p = 0
  while p < n {
    if labels[p] > max_id {
      max_id = labels[p]
    }
    p = p + 1
  }
  max_id + 1
}

///|
fn compute_modularity(
  adjacency : Array[Array[Int]],
  self_loop : Array[Double],
  labels : Array[Int],
  degree : Array[Double],
  total_weight : Double,
  n : Int,
) -> Double {
  let inv_2m = 1.0 / (2.0 * total_weight)
  let mut q = 0.0
  let mut i = 0
  while i < n {
    for j in adjacency[i] {
      if labels[i] == labels[j] {
        q = q + 1.0 - degree[i] * degree[j] * inv_2m
      }
    }
    if self_loop[i] > 0.0 {
      q = q + self_loop[i] - degree[i] * degree[i] * self_loop[i] * inv_2m
    }
    i = i + 1
  }
  q * inv_2m
}
