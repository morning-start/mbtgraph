/// 欧拉路径算法结果类型定义
///
/// 包含欧拉路径和欧拉回路的结果结构体，
/// 用于返回算法执行结果和相关信息

///|
/// 欧拉路径结果
///
/// 表示图中是否存在欧拉路径以及具体的路径信息
pub(all) struct EulerPathResult {
  /// 是否存在欧拉路径
  exists : Bool
  /// 欧拉路径的边序列（按遍历顺序）
  path : Array[@core.Edge]
  /// 路径起点（欧拉路径存在时有值）
  start_node : @core.NodeId?
  /// 路径终点（欧拉路径存在时有值）
  end_node : @core.NodeId?
} derive(Debug)

///|
/// 欧拉回路结果
///
/// 表示图中是否存在欧拉回路以及具体的回路信息
pub(all) struct EulerCircuitResult {
  /// 是否存在欧拉回路
  exists : Bool
  /// 欧拉回路的边序列（按遍历顺序，形成闭环）
  circuit : Array[@core.Edge]
  /// 回路起点（欧拉回路存在时有值，也是终点）
  start_node : @core.NodeId?
} derive(Debug)
