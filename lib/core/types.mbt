///|
/// 节点唯一标识符（整数索引）
pub(all) struct NodeId(Int) derive(Debug, Eq)

///|
/// 转换为字符串（直接数字表示）
pub fn NodeId::to_string(self : NodeId) -> String {
  let NodeId(val) = self
  val.to_string()
}

///|
impl Show for NodeId with fn output(self : NodeId, logger : &Logger) -> Unit {
  let NodeId(val) = self
  logger.write_string(val.to_string())
}

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
