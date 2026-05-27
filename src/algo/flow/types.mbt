///|
/// 最大流结果类型
pub(all) struct MaxFlowResult {
  max_flow : Double
  flow_matrix : Array[Array[Double?]]
}

///|
/// 最小费用最大流结果
pub(all) struct MinCostMaxFlowResult {
  max_flow : Double
  min_cost : Double
  flow_matrix : Array[Array[Double?]]
}
