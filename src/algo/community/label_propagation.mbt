/// 标签传播算法 (Label Propagation) 实现

///|
/// 执行标签传播社区检测
///
/// 标签传播算法通过让节点采用其邻居中最多的标签来发现社区。
/// 速度极快（O(kE)）但结果可能因运行顺序而略有不同。
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `max_iterations`: 最大迭代次数，默认 100
///
/// # 返回
///
/// `CommunityResult` 包含社区标签和模块度计算值
///
/// # 复杂度
///
/// O(k × E)，k 通常 < 10
pub fn[G : @core.GraphReadable] label_propagation(
  graph : G,
  max_iterations : Int,
) -> CommunityResult {
  let n = @core.GraphReadable::node_count(graph)

  if n == 0 {
    return CommunityResult::{
      labels: [], modularity: 0.0, num_communities: 0, levels: 1,
    }
  }

  if n == 1 {
    return CommunityResult::{
      labels: [0], modularity: 0.0, num_communities: 1, levels: 1,
    }
  }

  let adjacency = build_lp_adjacency(graph, n)
  let labels : Array[Int] = Array::make(n, 0)
  let mut i = 0
  while i < n {
    labels[i] = i
    i = i + 1
  }

  let max_iter = if max_iterations <= 0 { 100 } else { max_iterations }
  let mut iter = 0
  let mut changed = true

  while changed && iter < max_iter {
    changed = false
    iter = iter + 1

    let mut node_idx = 0
    while node_idx < n {
      let nbrs = adjacency[node_idx]
      if nbrs.length() > 0 {
        let best_label = find_most_frequent_label(labels, nbrs)
        if best_label != labels[node_idx] {
          labels[node_idx] = best_label
          changed = true
        }
      }
      node_idx = node_idx + 1
    }
  }

  let relabeled = relabel_communities_lp(labels, n)
  let num_comms = count_unique_comms_lp(relabeled, n)
  let mod_val = compute_lp_modularity(adjacency, relabeled, n)

  CommunityResult::{
    labels: relabeled,
    modularity: mod_val,
    num_communities: num_comms,
    levels: 1,
  }
}

///|
/// 构建邻接表（每个节点保存其邻居列表）
fn[G : @core.GraphReadable] build_lp_adjacency(
  graph : G,
  n : Int,
) -> Array[Array[Int]] {
  let adj : Array[Array[Int]] = Array::make(n, [])
  let edges = @core.GraphReadable::edges(graph)
  for edge in edges {
    match edge {
      (u, v, _) => {
        let ui = u.0
        let vi = v.0
        if ui >= 0 && ui < n && vi >= 0 && vi < n {
          add_neighbor_to_list(adj, ui, vi)
          add_neighbor_to_list(adj, vi, ui)
        }
      }
    }
  }
  adj
}

fn add_neighbor_to_list(adj : Array[Array[Int]], from : Int, to : Int) -> Unit {
  let old_list = adj[from]
  let new_list : Array[Int] = []
  for x in old_list {
    new_list.push(x)
  }
  new_list.push(to)
  adj[from] = new_list
}

///|
/// 在邻居标签中找到出现最频繁的标签（平局取最小值）
fn find_most_frequent_label(
  labels : Array[Int],
  neighbors : Array[Int],
) -> Int {
  let max_label = find_max_label(labels, neighbors)
  let count_arr : Array[Int] = Array::make(max_label + 1, 0)

  for nbr in neighbors {
    let lbl = labels[nbr]
    count_arr[lbl] = count_arr[lbl] + 1
  }

  let mut best_label = 0
  let mut best_count = 0
  let mut c = 0
  while c < count_arr.length() {
    if count_arr[c] > best_count {
      best_count = count_arr[c]
      best_label = c
    }
    c = c + 1
  }
  best_label
}

fn find_max_label(labels : Array[Int], neighbors : Array[Int]) -> Int {
  let mut max_lbl = 0
  for nbr in neighbors {
    if labels[nbr] > max_lbl {
      max_lbl = labels[nbr]
    }
  }
  max_lbl
}

fn relabel_communities_lp(labels : Array[Int], n : Int) -> Array[Int] {
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

fn count_unique_comms_lp(labels : Array[Int], n : Int) -> Int {
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
/// 计算标签传播结果的近似模块度
fn compute_lp_modularity(
  adjacency : Array[Array[Int]],
  labels : Array[Int],
  n : Int,
) -> Double {
  let mut m = 0.0
  let mut internal = 0.0
  let degree : Array[Double] = Array::make(n, 0.0)

  let mut u = 0
  while u < n {
    let nbrs = adjacency[u]
    for v in nbrs {
      if v >= 0 && v < n {
        degree[u] = degree[u] + 1.0
        m = m + 0.5
        if labels[u] == labels[v] {
          internal = internal + 1.0
        }
      }
    }
    u = u + 1
  }

  if m <= 0.0 {
    return 0.0
  }

  let inv_2m = 1.0 / (2.0 * m)
  let mut q = 0.0
  let mut v = 0
  while v < n {
    let nbrs2 = adjacency[v]
    for w in nbrs2 {
      if w >= 0 && w < n && labels[v] == labels[w] {
        q = q + 1.0 - degree[v] * degree[w] * inv_2m
      }
    }
    v = v + 1
  }
  q * inv_2m
}