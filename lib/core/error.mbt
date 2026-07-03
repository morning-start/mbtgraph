///|
/// 图操作错误类型
///
/// # 变体
///
/// - `NodeNotFound`: 尝试访问不存在的节点
/// - `EdgeAlreadyExists`: 尝试添加已存在的边
/// - `InvalidNodeId`: 节点 ID 无效（如负数）
/// - `NodeAlreadyExists`: 尝试添加已存在的节点
/// - `NodeIdOutOfBounds`: 节点 ID 超出范围
pub(all) enum GraphError {
  /// 节点不存在
  NodeNotFound(NodeId)
  /// 边已存在
  EdgeAlreadyExists(NodeId, NodeId)
  /// 节点 ID 无效
  InvalidNodeId
  /// 节点已存在（添加重复节点）
  NodeAlreadyExists(NodeId)
  /// 节点 ID 越界
  NodeIdOutOfBounds(Int)
} derive(Debug, Eq)
