///|
/// 图操作错误类型
pub enum GraphError {
  NodeNotFound(NodeId)
  EdgeAlreadyExists(NodeId, NodeId)
  InvalidNodeId
} derive(Debug, Eq)

///|
/// GraphError Show 实现
pub impl Show for GraphError with to_string(self : GraphError) -> String {
  match self {
    NodeNotFound(id) => "NodeNotFound(\{id})"
    EdgeAlreadyExists(from, to) => "EdgeAlreadyExists(\{from}, \{to})"
    InvalidNodeId => "InvalidNodeId"
  }
}
