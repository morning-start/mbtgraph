///|
/// 图只读接口
/// 所有存储实现的最低要求，符合接口隔离原则 (ISP)
/// 只包含所有实现都能提供的方法
pub(open) trait GraphReadable {
  /// 节点数量
  node_count(self : Self) -> Int

  /// 边数量
  edge_count(self : Self) -> Int

  /// 检查节点是否存在
  contains_node(self : Self, node_id : NodeId) -> Bool

  /// 检查边是否存在
  contains_edge(self : Self, from : NodeId, to : NodeId) -> Bool

  /// 获取节点数据
  get_node(self : Self, node_id : NodeId) -> Double?

  /// 获取边数据
  get_edge(self : Self, from : NodeId, to : NodeId) -> Double?

  /// 获取邻居节点（出边目标）
  neighbors(self : Self, node_id : NodeId) -> Iter[NodeId]

  /// 节点度（无向图）或出度（有向图）
  degree(self : Self, node_id : NodeId) -> Int

  /// 是否为有向图
  is_directed(self : Self) -> Bool

  /// 是否为空图
  is_empty(self : Self) -> Bool

  /// 迭代所有节点 ID
  node_ids(self : Self) -> Iter[NodeId]

  /// 迭代所有边 (from, to, weight)
  edges(self : Self) -> Iter[(NodeId, NodeId, Double)]
}

///|
/// 图可写接口
/// 仅适用于支持动态修改的存储（邻接表、邻接矩阵、混合图）
/// CSR 等只读存储不实现此 trait，符合里氏替换原则 (LSP)
pub(open) trait GraphWritable: GraphReadable {
  /// 添加节点，返回其 ID
  add_node(self : Self, data : Double) -> NodeId

  /// 删除节点及其关联的所有边
  remove_node(self : Self, node_id : NodeId) -> Bool

  /// 添加边
  add_edge(self : Self, from : NodeId, to : NodeId, data : Double) -> Result[
    Unit,
    GraphError,
  ]

  /// 删除边
  remove_edge(self : Self, from : NodeId, to : NodeId) -> Bool

  /// 清空图
  clear(self : Self) -> Unit
}

///|
/// 有向图扩展接口
/// 提供入边查询能力，邻接表需维护反向索引
pub(open) trait GraphDirected: GraphReadable {
  /// 获取前驱节点（入边源）
  in_neighbors(self : Self, node_id : NodeId) -> Iter[NodeId]

  /// 获取后继节点（出边目标）
  out_neighbors(self : Self, node_id : NodeId) -> Iter[NodeId]

  /// 入度
  in_degree(self : Self, node_id : NodeId) -> Int

  /// 出度
  out_degree(self : Self, node_id : NodeId) -> Int

  /// 前驱边 (源节点, 边数据)
  predecessors(self : Self, node_id : NodeId) -> Iter[(NodeId, Double)]

  /// 后继边 (目标节点, 边数据)
  successors(self : Self, node_id : NodeId) -> Iter[(NodeId, Double)]
}

///|
/// 完整图接口别名
/// 组合可写 + 有向图能力，适用于邻接表等通用实现
pub(open) trait GraphFull: GraphWritable + GraphDirected {
  // 无需额外方法，仅作类型约束的便捷别名
}

///|
/// CSR 批量读取接口
/// 提供批量处理优化，适合大图计算
pub(open) trait GraphBatchReadable: GraphReadable {
  /// 批量获取邻居
  batch_neighbors(self : Self, node_ids : Array[NodeId]) -> Array[Array[NodeId]]

  /// 批量获取边数据
  batch_edges(self : Self, edge_pairs : Array[(NodeId, NodeId)]) -> Array[
    Double?,
  ]
}

///|
/// 边遍历优化接口
/// 适用于边集数组，提供边排序能力 
pub(open) trait GraphEdgeIterable: GraphReadable {
  /// 按权重排序的边迭代器
  edges_sorted(self : Self) -> Iter[(NodeId, NodeId, Double)]
}
