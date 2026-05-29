/// 密集子图类型定义

///|
/// K-Core 分解结果
///
/// 每个节点的 core number = 最大的 k 使得该节点属于 k-core
pub(all) struct KCoreResult {
  core : Array[Int]
} derive(Debug)

///|
/// 获取指定节点的 core number
pub fn KCoreResult::core_number(self : KCoreResult, node : @core.NodeId) -> Int {
  self.core[node.0]
}

///|
/// K-Truss 分解结果
///
/// 每条边的 truss number = 最大的 k 使得该边属于 k-truss
pub(all) struct KTrussResult {
  truss : @storage.UndirectedAdjList
}

///|
/// 获取指定边的 truss number
pub fn KTrussResult::truss_number(self : KTrussResult, u : @core.NodeId, v : @core.NodeId) -> Int? {
  match @core.GraphReadable::get_edge(self.truss, u, v) {
    Some(w) => Some(w.to_int())
    None => None
  }
}

///|
/// 全局三角形计数结果
pub(all) struct TriangleCountResult {
  total : Int
  per_node : Array[Int]
} derive(Debug)

///|
/// 获取全局三角形总数
pub fn TriangleCountResult::total_triangles(self : TriangleCountResult) -> Int {
  self.total
}

///|
/// 获取指定节点参与的三角形数
pub fn TriangleCountResult::node_triangles(self : TriangleCountResult, node : @core.NodeId) -> Int {
  self.per_node[node.0]
}

///|
/// 聚类系数结果
pub(all) struct ClusteringCoefficientResult {
  locals : Array[Double]
  global : Double
} derive(Debug)

///|
/// 获取指定节点的局部聚类系数
pub fn ClusteringCoefficientResult::local_coefficient(
  self : ClusteringCoefficientResult,
  node : @core.NodeId,
) -> Double {
  self.locals[node.0]
}

///|
/// 获取全局平均聚类系数
pub fn ClusteringCoefficientResult::global_coefficient(self : ClusteringCoefficientResult) -> Double {
  self.global
}
