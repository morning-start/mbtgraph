/// Katz 中心性, Harmonic 中心性, 通信能力, 集团中心性
///
/// 对不连通图使用 harmonic 风格计算
pub(all) struct CommunicationResult {
  /// 节点通信能力得分
  scores : Array[Double]
} derive(Debug)

///|
/// 获取指定节点的通信能力得分
pub fn CommunicationResult::get_score(
  self : CommunicationResult,
  node_id : @core.NodeId,
) -> Double? {
  let id = node_id.0
  if id < 0 || id >= self.scores.length() {
    None
  } else {
    Some(self.scores[id])
  }
}

///|
/// Katz 中心性 (Katz Centrality)
///
/// 通过衰减路径计数衡量节点影响力，综合考虑直接连接和间接路径。
/// 相比度中心性，Katz 中心性能够识别通过长路径影响他人的重要节点。
///
/// # 数学公式
///
/// x = α · Aᵀ · x + β
///
/// 其中：
/// - α: 衰减因子（控制长路径的影响权重），必须 < 1/λ_max(A)
/// - β: 偏置项（通常为 1.0）
/// - A: 邻接矩阵的转置
///
/// 使用幂迭代法求解线性方程组。
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `alpha`: 衰减因子，推荐范围 (0, 0.1)，典型值 0.01-0.05
/// - `beta`: 偏置项，通常为 1.0
/// - `max_iterations`: 最大迭代次数，推荐 100-500
/// - `tolerance`: 收敛阈值，推荐 1e-6
///
/// # 返回
///
/// `CentralityResult` 包含每个节点的 Katz 中心性得分
///
/// # 复杂度
///
/// - 时间: O(k × E)，k 为实际迭代次数
/// - 空间: O(V + E) 用于存储反向邻接表
///
/// # 注意事项
///
/// - alpha 过大可能导致不收敛或数值溢出
/// - 对于有向图，考虑入边和出边的差异
/// - 结果未归一化（normalized = false）
pub fn[G : @core.GraphReadable] katz_centrality(
  graph : G,
  alpha : Double,
  beta : Double,
  max_iterations : Int,
  tolerance : Double,
) -> CentralityResult {
  let n = @core.GraphReadable::node_count(graph)

  if n == 0 {
    return CentralityResult::{ scores: [], normalized: true }
  }

  if n == 1 {
    let single : Array[Double] = if beta > 0.0 { [beta] } else { [0.0] }
    return CentralityResult::{ scores: single, normalized: false }
  }

  let mut scores : Array[Double] = Array::make(n, 1.0 / n.to_double())
  let in_adj = build_katz_adjacency(graph, n)

  let mut iter = 0
  while iter < max_iterations {
    let new_scores = katz_iterate(scores, in_adj, n, alpha, beta)
    scores = new_scores
    iter = iter + 1
  }

  CentralityResult::{ scores, normalized: false }
}

///|
fn[G : @core.GraphReadable] build_katz_adjacency(
  graph : G,
  n : Int,
) -> Array[Array[Int]] {
  let a : Array[Array[Int]] = Array::make(n, [])
  let edges = @core.GraphReadable::edges(graph)
  for edge in edges {
    match edge {
      (u, v, _) => {
        let ui = u.0
        let vi = v.0
        if ui >= 0 && ui < n && vi >= 0 && vi < n {
          a[vi].push(ui)
        }
      }
    }
  }
  a
}

///|
fn katz_iterate(
  old : Array[Double],
  in_adj : Array[Array[Int]],
  n : Int,
  alpha : Double,
  beta : Double,
) -> Array[Double] {
  let result : Array[Double] = Array::make(n, beta)
  let mut i = 0
  while i < n {
    let nbrs = in_adj[i]
    for src in nbrs {
      if src >= 0 && src < n {
        result[i] = result[i] + alpha * old[src]
      }
    }
    i = i + 1
  }
  result
}

///|
/// Harmonic 中心性 (Harmonic Centrality)
///
/// 接近中心性的变体，对不连通图友好。使用距离的调和平均，
/// 不可达节点贡献为 0 而非无穷大。
///
/// # 数学公式
///
/// H(v) = Σ_{u ≠ v} 1 / dist(v, u)
///
/// 归一化版本：H_norm(v) = H(v) / (n - 1)
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `normalized`: 是否归一化到 [0, 1] 区间
///
/// # 返回
///
/// `CentralityResult` 包含每个节点的 Harmonic 中心性得分
///
/// # 复杂度
///
/// - 时间: O(V × (V + E))，需对每个节点运行 BFS
/// - 空间: O(V) 用于存储距离数组
///
/// # 应用场景
///
/// - 社交网络影响力分析
/// - 不连通图的中心性比较
/// - 信息传播效率评估
pub fn[G : @core.GraphReadable] harmonic_centrality(
  graph : G,
  normalized : Bool,
) -> CentralityResult {
  let n = @core.GraphReadable::node_count(graph)

  if n <= 1 {
    let scores : Array[Double] = Array::make(n, 0.0)
    return CentralityResult::{ scores, normalized }
  }

  let harmonic : Array[Double] = Array::make(n, 0.0)

  let mut source = 0
  while source < n {
    let dists = harmonic_bfs(graph, source, n)
    let mut sum = 0.0
    let mut d = 0
    while d < dists.length() {
      if d != source && dists[d] > 0 {
        sum = sum + 1.0 / dists[d].to_double()
      }
      d = d + 1
    }
    harmonic[source] = sum
    source = source + 1
  }

  if normalized && n > 1 {
    let mut i = 0
    while i < n {
      harmonic[i] = harmonic[i] / (n - 1).to_double()
      i = i + 1
    }
  }

  CentralityResult::{ scores: harmonic, normalized }
}

///|
fn[G : @core.GraphReadable] harmonic_bfs(
  graph : G,
  source : Int,
  n : Int,
) -> Array[Int] {
  let dist : Array[Int] = Array::make(n, -1)
  dist[source] = 0
  let queue : Array[Int] = [source]
  let mut head = 0
  while head < queue.length() {
    let v = queue[head]
    head = head + 1
    for w in @core.GraphReadable::neighbors(graph, @core.NodeId(v)) {
      let wi = w.0
      if wi >= 0 && wi < n && dist[wi] < 0 {
        dist[wi] = dist[v] + 1
        queue.push(wi)
      }
    }
  }
  dist
}

///|
/// 通信能力中心性 (Communication Centrality)
///
/// 衡量节点移除后对网络整体效率的影响程度。
/// 得分越高表示该节点对网络连通性越关键。
///
/// # 数学公式
///
/// C(v) = [E(G) - E(G \ {v})] / E(G)
///
/// 其中 E(G) 是网络的全局效率（Global Efficiency）：
/// E(G) = (1 / n(n-1)) × Σ_{i≠j} 1/dist(i,j)
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
///
/// # 返回
///
/// `CommunicationResult` 包含每个节点的通信能力得分（[0, 1] 范围）
///
/// # 复杂度
///
/// - 时间: O(V² × (V + E))，需计算 V 次全源最短路径
/// - 空间: O(V) 用于存储距离数组
///
/// # 应用场景
///
/// - 网络关键节点识别
/// - 基础设施脆弱性分析
/// - 故障影响范围评估
pub fn[G : @core.GraphReadable] communication_centrality(
  graph : G,
) -> CommunicationResult {
  let n = @core.GraphReadable::node_count(graph)

  if n <= 2 {
    let scores : Array[Double] = Array::make(n, 0.0)
    return CommunicationResult::{ scores }
  }

  let base_efficiency = compute_network_efficiency(graph, n, -1)

  let scores : Array[Double] = Array::make(n, 0.0)
  let mut v = 0
  while v < n {
    let eff_without = compute_network_efficiency(graph, n, v)
    if base_efficiency > 0.0 {
      let raw = (base_efficiency - eff_without) / base_efficiency
      scores[v] = if raw < 0.0 { 0.0 } else { raw }
    }
    v = v + 1
  }

  CommunicationResult::{ scores }
}

///|
/// 计算网络效率 E(G) = 1/(n*(n-1)) * Σ_{i≠j} 1/dist(i,j)
/// exclude 为排除节点（-1 表示不排除）
fn[G : @core.GraphReadable] compute_network_efficiency(
  graph : G,
  n : Int,
  exclude : Int,
) -> Double {
  let mut total = 0.0
  let mut count = 0
  let mut i = 0
  while i < n {
    if i == exclude {
      i = i + 1
      continue
    }
    let dists = all_pairs_bfs_comm(graph, i, n, exclude)
    let mut j = 0
    while j < dists.length() {
      if j != i && j != exclude && dists[j] > 0 {
        total = total + 1.0 / dists[j].to_double()
        count = count + 1
      }
      j = j + 1
    }
    i = i + 1
  }
  if count > 0 { total / count.to_double() } else { 0.0 }
}

///|
fn[G : @core.GraphReadable] all_pairs_bfs_comm(
  graph : G,
  source : Int,
  n : Int,
  exclude : Int,
) -> Array[Int] {
  let dist : Array[Int] = Array::make(n, -1)
  dist[source] = 0
  let queue : Array[Int] = [source]
  let mut head = 0
  while head < queue.length() {
    let v = queue[head]
    head = head + 1
    for w in @core.GraphReadable::neighbors(graph, @core.NodeId(v)) {
      let wi = w.0
      if wi == exclude { continue }
      if wi >= 0 && wi < n && dist[wi] < 0 {
        dist[wi] = dist[v] + 1
        queue.push(wi)
      }
    }
  }
  dist
}

///|
/// 集团中心性 (Group Betweenness Centrality)
///
/// 衡量一个节点集合（group）的整体连通重要性，
/// 定义为经过该集合的最短路径比例。
///
/// 通过比较移除 group 前后所有节点对之间最短路径的变化来计算：
/// 如果某对节点 (s, t) 的最短路径在移除 group 后变长或不可达，
/// 则认为该路径经过 group。
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `group`: 目标节点集合（Array[NodeId]）
///
/// # 返回
///
/// 集团中心性得分（[0, 1] 范围的浮点数）
/// 表示经过该 group 的最短路径占总可达路径的比例
///
/// # 复杂度
///
/// - 时间: O(|V_group| × V × (V + E))
/// - 空间: O(V) 用于 BFS 标记数组
///
/// # 应用场景
///
/// - 团队/部门重要性评估
/// - 关键基础设施群组分析
/// - 组织结构优化
pub fn[G : @core.GraphReadable] group_betweenness_centrality(
  graph : G,
  group : Array[@core.NodeId],
) -> Double {
  let n = @core.GraphReadable::node_count(graph)
  if n <= 2 || group.length() == 0 {
    return 0.0
  }

  let in_group : Array[Bool] = Array::make(n, false)
  for g in group {
    let gi = g.0
    if gi >= 0 && gi < n {
      in_group[gi] = true
    }
  }

  let mut total_pairs = 0.0
  let mut pairs_via_group = 0.0

  let mut s = 0
  while s < n {
    if in_group[s] { s = s + 1; continue }
    let mut t = s + 1
    while t < n {
      if in_group[t] { t = t + 1; continue }
      // 计算完整图上 s->t 的最短距离
      let dist_full = group_bfs_to_target(graph, s, t, n, [])
      if dist_full > 0 {
        total_pairs = total_pairs + 1.0
        // 如果移除 group 后距离改变或不可达，则经过 group
        let dist_after = group_bfs_to_target(graph, s, t, n, in_group)
        if dist_after != dist_full {
          pairs_via_group = pairs_via_group + 1.0
        }
      }
      t = t + 1
    }
    s = s + 1
  }

  if total_pairs > 0.0 {
    pairs_via_group / total_pairs
  } else {
    0.0
  }
}

///|
/// BFS 到目标节点，可排除指定集合
fn[G : @core.GraphReadable] group_bfs_to_target(
  graph : G,
  source : Int,
  target : Int,
  n : Int,
  blocked : Array[Bool],
) -> Int {
  if source == target { return 0 }
  let visited : Array[Bool] = Array::make(n, false)
  visited[source] = true
  let queue : Array[(Int, Int)] = [(source, 0)]
  let mut head = 0
  while head < queue.length() {
    let (v, d) = queue[head]
    head = head + 1
    for w in @core.GraphReadable::neighbors(graph, @core.NodeId(v)) {
      let wi = w.0
      if wi == target { return d + 1 }
      if wi >= 0 && wi < n && !visited[wi] {
        if blocked.length() > wi && blocked[wi] { continue }
        visited[wi] = true
        queue.push((wi, d + 1))
      }
    }
  }
  -1
}
