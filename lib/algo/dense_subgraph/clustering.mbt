/// 聚类系数
///
/// 计算局部（每个节点）和全局（平均）聚类系数。

///|
/// 局部聚类系数
///
/// 对于节点 u: 实际三角形数 / 可能三角形数
/// 可能三角形数 = C(deg(u), 2) = deg(u) * (deg(u) - 1) / 2
/// 当 deg(u) < 2 时，聚类系数为 0.0
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
/// 所有节点局部聚类系数的平均值
pub fn[G : @core.GraphReadable] average_clustering_coefficient(graph : G) -> Double {
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
/// 计算所有节点的局部聚类系数和全局平均聚类系数
pub fn[G : @core.GraphReadable] clustering_coefficients(graph : G) -> ClusteringCoefficientResult {
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
