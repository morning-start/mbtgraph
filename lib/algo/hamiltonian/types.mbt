///|
/// 哈密顿路径/回路查找结果
pub(all) struct HamiltonianResult {
  exists : Bool // 是否存在
  path : Array[@core.NodeId] // 路径/回路的节点序列（空表示不存在）
  is_circuit : Bool // 是否为回路（起点=终点）
  start_node : @core.NodeId? // 起点（None 表示无路径）
}

///|
/// TSP 结果
pub(all) struct TSPResult {
  tour : Array[Int] // 最优/近似路径（节点索引序列）
  total_cost : Double // 总代价（权重之和）
  is_optimal : Bool // 是否为最优解
  algorithm : String // 使用的算法名称
}
