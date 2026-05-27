/// PageRank 算法实现
///
/// 基于幂法迭代的 PageRank 算法，
/// 支持 damping factor、dangling nodes 处理和个人化 PageRank

///|
/// 计算 PageRank 排名（幂法迭代）
///
/// 使用标准 PageRank 公式:
///   PR(v) = (1-d)/N + d * Σ(PR(u)/out_degree(u))  for u → v
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `damping_factor`: 阻尼系数，默认 0.85，范围 (0, 1)
/// - `max_iterations`: 最大迭代次数，默认 100
/// - `tolerance`: 收敛阈值（无穷范数），默认 1e-6
///
/// # 返回
///
/// `PageRankResult` 包含每个节点的排名值和算法元数据
///
/// # Dangling Nodes 处理
///
/// 无出边节点（dangling nodes）的 rank 值均匀分配给所有节点，
/// 保证 rank 总和收敛到 1.0。
///
/// # 复杂度
///
/// - 时间: O(k * E)，k 为实际迭代次数（通常 < 50）
/// - 空间: O(N + E)，用于存储反向邻接表
pub fn[G : @core.GraphReadable] pagerank(
  graph : G,
  damping_factor : Double,
  max_iterations : Int,
  tolerance : Double,
) -> PageRankResult {
  let n = @core.GraphReadable::node_count(graph)

  if n == 0 {
    return PageRankResult::{
      ranks: [],
      iterations: 0,
      converged: true,
      damping_factor,
      tolerance,
    }
  }

  if n == 1 {
    let single_rank : Array[Double] = [1.0]
    return PageRankResult::{
      ranks: single_rank,
      iterations: 0,
      converged: true,
      damping_factor,
      tolerance,
    }
  }

  let inv_n = 1.0 / double_int(n)
  let d = damping_factor

  let out_deg = build_out_degrees(graph, n)
  let in_neighbors = build_reverse_adjacency(graph, n)

  let mut ranks : Array[Double] = []
  let mut i = 0
  while i < n {
    ranks.push(inv_n)
    i = i + 1
  }

  let mut iter = 0
  let mut converged = false

  while iter < max_iterations {
    let dangling_sum = compute_dangling_sum(ranks, out_deg, n)

    let new_ranks = compute_new_ranks(
      ranks, in_neighbors, out_deg, n, d, inv_n, dangling_sum,
    )

    let diff = max_diff(ranks, new_ranks, n)

    ranks = new_ranks
    iter = iter + 1

    if diff < tolerance {
      converged = true
      break
    }
  }

  PageRankResult::{
    ranks,
    iterations: iter,
    converged,
    damping_factor,
    tolerance,
  }
}

///|
/// 计算所有节点的出度数组
fn[G : @core.GraphReadable] build_out_degrees(graph : G, n : Int) -> Array[Int] {
  let deg : Array[Int] = []
  let mut i = 0
  while i < n {
    deg.push(0)
    i = i + 1
  }
  let edges = @core.GraphReadable::edges(graph)
  for edge in edges {
    match edge {
      (u, _, _) => {
        let ui = u.0
        if ui >= 0 && ui < n {
          deg[ui] = deg[ui] + 1
        }
      }
    }
  }
  deg
}

///|
/// 构建反向邻接表（入边邻居列表）
fn[G : @core.GraphReadable] build_reverse_adjacency(
  graph : G,
  n : Int,
) -> Array[Array[Int]] {
  let in_adj : Array[Array[Int]] = []
  let mut j = 0
  while j < n {
    in_adj.push([])
    j = j + 1
  }
  let edges = @core.GraphReadable::edges(graph)
  for edge in edges {
    match edge {
      (u, v, _) => {
        let ui = u.0
        let vi = v.0
        if ui >= 0 && ui < n && vi >= 0 && vi < n {
          in_adj[vi].push(ui)
        }
      }
    }
  }
  in_adj
}

///|
/// 计算 dangling nodes 的 rank 总和（无出边节点）
fn compute_dangling_sum(
  ranks : Array[Double],
  out_deg : Array[Int],
  n : Int,
) -> Double {
  let mut sum = 0.0
  let mut k = 0
  while k < n {
    if out_deg[k] == 0 {
      sum = sum + ranks[k]
    }
    k = k + 1
  }
  sum
}

///|
/// 执行一轮 PageRank 迭代，计算新的 rank 值
fn compute_new_ranks(
  old_ranks : Array[Double],
  in_adj : Array[Array[Int]],
  out_deg : Array[Int],
  n : Int,
  d : Double,
  inv_n : Double,
  dangling_sum : Double,
) -> Array[Double] {
  let base = (1.0 - d) * inv_n + d * inv_n * dangling_sum
  let new_ranks : Array[Double] = []
  let mut i = 0
  while i < n {
    let mut sum_in = 0.0
    let in_nbrs = in_adj[i]
    for src in in_nbrs {
      if src >= 0 && src < n && out_deg[src] > 0 {
        sum_in = sum_in + old_ranks[src] / double_int(out_deg[src])
      }
    }
    new_ranks.push(base + d * sum_in)
    i = i + 1
  }
  new_ranks
}

///|
/// 计算两个 rank 数组的无穷范数差值（最大绝对差）
fn max_diff(a : Array[Double], b : Array[Double], n : Int) -> Double {
  let mut md = 0.0
  let mut i = 0
  while i < n {
    let mut delta = a[i] - b[i]
    if delta < 0.0 {
      delta = -delta
    }
    if delta > md {
      md = delta
    }
    i = i + 1
  }
  md
}

///|
/// 将 Int 转换为 Double
fn double_int(x : Int) -> Double {
  x.to_double()
}
