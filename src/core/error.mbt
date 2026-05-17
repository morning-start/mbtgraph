///|
/// 图操作错误类型
///
/// # 变体
///
/// - `NodeNotFound`: 尝试访问不存在的节点
/// - `EdgeAlreadyExists`: 尝试添加已存在的边
/// - `InvalidNodeId`: 节点 ID 无效（如负数）
pub enum GraphError {
  /// 节点不存在
  NodeNotFound(NodeId)
  /// 边已存在
  EdgeAlreadyExists(NodeId, NodeId)
  /// 节点 ID 无效
  InvalidNodeId
} derive(Debug, Eq)
