/// PageRank 算法类型定义
///
/// 包含 PageRank 结果结构体和相关类型，
/// 用于返回算法执行结果和排名信息

///|
/// PageRank 计算结果
///
/// 存储每个节点的排名值以及算法执行的元数据，
/// 提供便捷的查询和排序方法
pub(all) struct PageRankResult {
  /// 节点排名值数组，索引对应 NodeId
  ranks : Array[Double]
  /// 实际迭代次数
  iterations : Int
  /// 是否收敛
  converged : Bool
  /// 使用的阻尼系数
  damping_factor : Double
  /// 收敛阈值
  tolerance : Double
} derive(Debug)

///|
/// 获取指定节点的 PageRank 值
///
/// 当 node_id 超出范围时返回 None
pub fn PageRankResult::get_rank(
  self : PageRankResult,
  node_id : @core.NodeId,
) -> Double? {
  let id = node_id.0
  if id < 0 || id >= self.ranks.length() {
    None
  } else {
    Some(self.ranks[id])
  }
}

///|
/// 获取排名前 k 的节点及其得分
///
/// 返回按 rank 值降序排列的前 k 个 (NodeId, Double) 对。
/// 当 k > 节点总数时返回全部节点；k <= 0 时返回空数组
pub fn PageRankResult::top_nodes(
  self : PageRankResult,
  k : Int,
) -> Array[(@core.NodeId, Double)] {
  if k <= 0 {
    return []
  }
  let n = self.ranks.length()
  let indexed : Array[(@core.NodeId, Double)] = []
  let mut i = 0
  while i < n {
    indexed.push((@core.NodeId(i), self.ranks[i]))
    i = i + 1
  }
  let sorted = top_k_sort(indexed, k)
  sorted
}

///|
/// 计算所有节点的 rank 总和
///
/// 正常情况下总和应接近 1.0（允许 tolerance 范围内的误差），
/// 可用于验证结果的正确性
pub fn PageRankResult::total_rank(self : PageRankResult) -> Double {
  let mut sum = 0.0
  for r in self.ranks {
    sum = sum + r
  }
  sum
}

///|
/// 对 (NodeId, Double) 数组按 Double 降序排列，返回前 k 个元素
fn top_k_sort(
  arr : Array[(@core.NodeId, Double)],
  k : Int,
) -> Array[(@core.NodeId, Double)] {
  let es = arr
  let n = es.length()
  let limit = if k < n { k } else { n }
  let mut j = 0
  while j < limit {
    let mut max_idx = j
    let mut p = j + 1
    while p < n {
      let (_, v1) = es[max_idx]
      let (_, v2) = es[p]
      if v2 > v1 {
        max_idx = p
      }
      p = p + 1
    }
    let tmp = es[j]
    es[j] = es[max_idx]
    es[max_idx] = tmp
    j = j + 1
  }
  let result : Array[(@core.NodeId, Double)] = []
  let mut q = 0
  while q < limit {
    result.push(es[q])
    q = q + 1
  }
  result
}
