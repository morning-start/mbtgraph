/// Leiden 社区检测算法
///
/// Louvain 的改进版本，增加了 Refinement 阶段，
/// 避免产生内部不连通的社区。

///|
/// Leiden 社区检测算法
///
/// Louvain 算法的改进版本，通过引入 Refinement 阶段解决了 Louvain
/// 可能产生内部不连通社区的问题。算法分为两个阶段：Phase 1 执行局部移动
/// 优化模块度（与 Louvain 相同），Phase 2 在每个社区内部进行细化处理，
/// 确保最终划分的每个社区都是连通的。相比 Louvain，Leiden 能产生更高质量、
/// 更具可解释性的社区结构。
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `resolution`: 分辨率参数，控制社区粒度。值越大社区越小越精细，
///   默认为 1.0，建议范围 (0, 2]。当 ≤ 0 时自动使用 1.0
///
/// # 返回
///
/// `CommunityResult` 包含：
/// - `labels`: 每个节点的社区标签数组（从 0 开始连续编号）
/// - `modularity`: 最终划分的模块度值（越高表示社区质量越好）
/// - `num_communities`: 检测到的社区数量
/// - `levels`: 算法执行的层次数（当前实现固定为 1）
///
/// # 复杂度
///
/// - 时间: O(n × m × p)，n 为节点数，m 为边数，p 为迭代轮数（通常 < 15）
/// - 空间: O(n + m)，用于存储邻接表和辅助数组（度数、自环、社区归属等）
///
/// # 应用场景
///
/// - 社交网络社区发现（识别朋友圈、兴趣群体）
/// - 生物网络分析（蛋白质相互作用网络、基因共表达网络）
/// - 引文网络聚类（发现研究主题和学术共同体）
/// - 推荐系统用户分群（基于用户关系图的精准营销）
/// - 与 Louvain 对比：需要更高质量、保证社区连通性的场景
pub fn[G : @core.GraphReadable] leiden(
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
  let degree = edges_info.degree
  let self_loop = edges_info.self_loop

  let community_of : Array[Int] = Array::make(n, 0)
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
  let max_passes = 15

  // Phase 1: Local moving (同 Louvain)
  let mut pass = 0
  while pass < max_passes {
    let mut improved = false
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
        let gain = compute_gain(
          fine_internal[curr_comm],
          sum_tot[curr_comm],
          fine_internal[target_comm],
          sum_tot[target_comm],
          deg_i,
          k_i_in_curr,
          k_i_in_tgt,
          total_weight,
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
    if !improved {
      break
    }
  }

  // Phase 2: Refinement
  // 在每个社区内部运行局部移动，避免内部不连通
  let refined = refine_partition(
    adjacency, community_of, n, degree, self_loop, total_weight, res_factor,
  )

  let relabeled = relabel_communities(refined, n)
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
/// Refinement 阶段：在每个社区内部运行局部移动
///
/// 对于每个社区，将其内部的"子社区"候选（初始化成单个节点）进行合并尝试，
/// 确保社区内部是强连通的
fn refine_partition(
  adjacency : Array[Array[Int]],
  community_of : Array[Int],
  n : Int,
  degree : Array[Double],
  self_loop : Array[Double],
  total_weight : Double,
  res_factor : Double,
) -> Array[Int] {
  // 初始 refined = 每个节点自身作为一个子社区
  let refined : Array[Int] = Array::make(n, 0)
  let mut i = 0
  while i < n {
    refined[i] = i
    i = i + 1
  }

  // 在每个社区内部运行局部移动
  let mut community_id = 0
  while community_id < n {
    // 找到属于这个社区的节点
    let community_nodes : Array[Int] = []
    let mut j = 0
    while j < n {
      if community_of[j] == community_id {
        community_nodes.push(j)
      }
      j = j + 1
    }

    if community_nodes.length() <= 2 {
      community_id = community_id + 1
      continue
    }

    // 在当前社区内部进行局部移动
    // 使用子社区标签进行优化
    let sub_comm : Array[Int] = Array::make(n, -1)
    let mut ci = 0
    while ci < community_nodes.length() {
      let node = community_nodes[ci]
      sub_comm[node] = node
      ci = ci + 1
    }

    let sub_sum : Array[Double] = Array::make(n, 0.0)
    let sub_int : Array[Double] = Array::make(n, 0.0)
    let mut si = 0
    while si < community_nodes.length() {
      let node = community_nodes[si]
      sub_sum[node] = degree[node]
      sub_int[node] = self_loop[node]
      si = si + 1
    }

    let mut improved = true
    let mut iter = 0
    while improved && iter < 10 {
      improved = false
      iter = iter + 1

      let mut ni = 0
      while ni < community_nodes.length() {
        let node_i = community_nodes[ni]
        let curr_sub = sub_comm[node_i]
        let deg_i = degree[node_i]

        // 查找邻居中属于同一社区的子社区
        let neigh_subs : Array[Int] = []
        let seen_sub : Array[Bool] = Array::make(n, false)
        for nb in adjacency[node_i] {
          if community_of[nb] == community_id {
            let ns = sub_comm[nb]
            if ns >= 0 && !seen_sub[ns] && ns != curr_sub {
              seen_sub[ns] = true
              neigh_subs.push(ns)
            }
          }
        }

        let mut best_sub = curr_sub
        let mut best_gain = 0.0
        let mut si2 = 0
        while si2 < neigh_subs.length() {
          let target_sub = neigh_subs[si2]
          let k_to_target = int_to_double(
            count_edges_to_community(adjacency, node_i, sub_comm, target_sub),
          )
          let k_from_curr = int_to_double(
            count_edges_to_community(adjacency, node_i, sub_comm, curr_sub),
          )

          let gain = compute_gain(
            sub_int[curr_sub],
            sub_sum[curr_sub],
            sub_int[target_sub],
            sub_sum[target_sub],
            deg_i,
            k_from_curr,
            k_to_target,
            total_weight,
            res_factor,
          )

          if gain > best_gain {
            best_gain = gain
            best_sub = target_sub
          }
          si2 = si2 + 1
        }

        if best_gain > 0.0 && best_sub != curr_sub {
          improved = true
          let k_from_curr2 = int_to_double(
            count_edges_to_community(adjacency, node_i, sub_comm, curr_sub),
          )
          let k_to_target2 = int_to_double(
            count_edges_to_community(adjacency, node_i, sub_comm, best_sub),
          )

          sub_int[curr_sub] = sub_int[curr_sub] -
            k_from_curr2 * 2.0 -
            self_loop[node_i]
          sub_int[best_sub] = sub_int[best_sub] +
            k_to_target2 * 2.0 +
            self_loop[node_i]
          sub_sum[curr_sub] = sub_sum[curr_sub] - deg_i
          sub_sum[best_sub] = sub_sum[best_sub] + deg_i
          sub_comm[node_i] = best_sub
        }
        ni = ni + 1
      }
    }

    // 将 refine 结果写回
    let mut ci2 = 0
    while ci2 < community_nodes.length() {
      let node = community_nodes[ci2]
      refined[node] = sub_comm[node]
      ci2 = ci2 + 1
    }

    community_id = community_id + 1
  }

  refined
}
