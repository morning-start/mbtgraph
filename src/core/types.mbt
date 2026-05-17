///|
/// 节点唯一标识符（整数索引）
pub(all) struct NodeId(Int) derive(Debug, Eq)

///|
/// 带数据的节点
///
/// MVP 阶段数据固定为 `Double`，后续可泛型化为 `Node[T]`
pub(all) struct Node {
  id : NodeId
  data : Double
} derive(Debug)

///|
/// 带数据的边
///
/// MVP 阶段数据固定为 `Double`，后续可泛型化为 `Edge[T]`
pub(all) struct Edge {
  from : NodeId
  to : NodeId
  data : Double
} derive(Debug)
