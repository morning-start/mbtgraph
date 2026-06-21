/// 聚类系数
///
/// 计算局部（每个节点）和全局（平均）聚类系数。

///|
/// 局部聚类系数
///
/// 计算单个节点的局部聚类系数，衡量其邻居之间的连接紧密程度。
///
/// # 数学公式
///
/// C(u) = (2 × T(u)) / (deg(u) × (deg(u) - 1))
///
/// 其中 T(u) 是节点 u 参与的三角形数，deg(u) 是节点度数。
/// 当 deg(u) < 2 时，聚类系数为 0.0（无法形成三角形）。
///
/// # 参数
///
/// - `graph`: 输入无向图（需实现 GraphReadable trait）
/// - `node`: 目标节点 ID
///
/// # 返回
///
/// 节点的局部聚类系数（[0.0, 1.0] 范围）
///
/// # 复杂度
///
/// - 时间: O(deg(u)²)
/// - 空间: O(deg(u)) 用于存储排序后的邻居列表
pub fn[G : @core.GraphReadable] local_clustering_coefficient(
  graph : G,
  node : @core.NodeId,
) -> Double {
  let deg = @core.GraphReadable::degree(graph, node)
  if deg < 2 {
    return 0.0
  }
  // 计算该节点的三角形数
  let nu = sorted_neighbors(graph, node)
  let mut triangles = 0
  let mut vi = 0
  while vi < nu.length() {
    let v = nu[vi]
    let nv = sorted_neighbors(graph, @core.NodeId(v))
    // 计算 nu 和 nv 的交集，但只计 w > node 和 w > v 的不重复三角形
    // 简化: 对每个邻居 v，找到共同邻居 w，只计 w > v
    let mut ni = 0
    let mut nj = 0
    while ni < nu.length() && nj < nv.length() {
      if nu[ni] == nv[nj] {
        let w = nu[ni]
        if w > v {
          triangles = triangles + 1
        }
        ni = ni + 1
        nj = nj + 1
      } else if nu[ni] < nv[nj] {
        ni = ni + 1
      } else {
        nj = nj + 1
      }
    }
    vi = vi + 1
  }
  let possible = deg.to_double() * (deg.to_double() - 1.0) / 2.0
  triangles.to_double() / possible
}

///|
/// 全局平均聚类系数
///
/// 计算所有节点局部聚类系数的算术平均值，
/// 用于衡量整个图的聚集程度。
///
/// # 参数
///
/// - `graph`: 输入无向图（需实现 GraphReadable trait）
///
/// # 返回
///
/// 全局平均聚类系数（[0.0, 1.0] 范围）
///
/// # 复杂度
///
/// - 时间: O(V × d²)，其中 d 为平均度数
/// - 空间: O(1)
pub fn[G : @core.GraphReadable] average_clustering_coefficient(
  graph : G,
) -> Double {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return 0.0
  }
  let mut sum = 0.0
  let mut i = 0
  while i < n {
    sum = sum + local_clustering_coefficient(graph, @core.NodeId(i))
    i = i + 1
  }
  sum / n.to_double()
}

///|
/// 批量计算聚类系数
///
/// 一次性计算所有节点的局部聚类系数和全局平均聚类系数，
/// 避免重复遍历图，提高效率。
///
/// # 参数
///
/// - `graph`: 输入无向图（需实现 GraphReadable trait）
///
/// # 返回
///
/// `ClusteringCoefficientResult` 包含：
/// - `locals`: 每个节点的局部聚类系数数组
/// - `global`: 全局平均聚类系数
///
/// # 复杂度
///
/// - 时间: O(V × d²)，其中 d 为平均度数
/// - 空间: O(V) 用于存储结果数组
pub fn[G : @core.GraphReadable] clustering_coefficients(
  graph : G,
) -> ClusteringCoefficientResult {
  let n = @core.GraphReadable::node_count(graph)
  let locals : Array[Double] = []
  let mut i = 0
  while i < n {
    locals.push(local_clustering_coefficient(graph, @core.NodeId(i)))
    i = i + 1
  }
  let global = average_clustering_coefficient(graph)
  ClusteringCoefficientResult::{ locals, global }
}
