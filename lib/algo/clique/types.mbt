///|
/// 最大团查找结果
pub(all) struct CliqueResult {
  maximum_clique : Array[@core.NodeId] // 最大团的节点列表（按 ID 排序）
  size : Int // 团的大小 ω(G)
}

///|
/// 最大独立集查找结果
pub(all) struct IndependentSetResult {
  maximum_set : Array[@core.NodeId] // 最大独立集的节点列表
  size : Int // 独立数 α(G)
}

///|
/// 顶点覆盖查找结果
pub(all) struct VertexCoverResult {
  cover : Array[@core.NodeId] // 顶点覆盖的节点列表
  size : Int // 覆盖大小 τ(G)
  is_optimal : Bool // 是否为最优解（精确 vs 近似）
}
