///|
/// 割点查找结果
pub(all) struct CutPointResult {
  cut_points : Array[@core.NodeId] // 所有割点的有序列表
  is_cut_point : Array[Bool] // is_cut_point[i] = 节点 i 是否为割点
  count : Int // 割点总数
}

///|
/// 桥查找结果
pub(all) struct BridgeResult {
  bridges : Array[@core.Edge] // 所有桥的边列表
  is_bridge : Array[Bool] // is_bridge[i] = 边 i 是否为桥
  count : Int // 桥的总数
}
