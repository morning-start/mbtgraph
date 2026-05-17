///|
/// 节点唯一标识符（整数索引）
pub struct NodeId(Int) derive(Debug, Eq)

///|
/// NodeId Show 实现
impl Show for NodeId with to_string(self : NodeId) -> String {
  self.0.to_string()
}

///|
/// 带数据的节点
pub(all) struct Node {
  id : NodeId
  data : Double
} derive(Debug)

///|
/// Node Show 实现
pub impl Show for Node with to_string(self : Node) -> String {
  "Node { id: \{self.id}, data: \{self.data} }"
}

///|
/// 带数据的边
pub(all) struct Edge {
  from : NodeId
  to : NodeId
  data : Double
} derive(Debug)

///|
/// Edge Show 实现
pub impl Show for Edge with to_string(self : Edge) -> String {
  "Edge { from: \{self.from}, to: \{self.to}, data: \{self.data} }"
}
