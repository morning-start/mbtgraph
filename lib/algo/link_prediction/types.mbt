/// 链接预测类型定义

///|
/// 两个节点之间的链接预测得分
pub(all) struct LinkPredictionScore {
  u : @core.NodeId
  v : @core.NodeId
  common_neighbors : Int
  jaccard : Double
  adamic_adar : Double
  preferential_attachment : Double
  resource_allocation : Double
} derive(Debug)

///|
pub fn LinkPredictionScore::node_pair(self : LinkPredictionScore) -> (@core.NodeId, @core.NodeId) {
  (self.u, self.v)
}
