/// 链接预测类型定义

///|
/// 两个节点之间的链接预测结果
pub(all) struct LinkPredictionResult {
  u : @core.NodeId
  v : @core.NodeId
  common_neighbors : Int
  jaccard : Double
  adamic_adar : Double
  preferential_attachment : Double
  resource_allocation : Double
} derive(Debug)

///|
pub fn LinkPredictionResult::node_pair(self : LinkPredictionResult) -> (@core.NodeId, @core.NodeId) {
  (self.u, self.v)
}
