///|
/// 图只读接口
///
/// 所有存储实现的最低要求，符合接口隔离原则 (ISP)。
/// 只包含所有实现都能提供的方法。
///
/// # 实现要求
///
/// - 邻接表、邻接矩阵、CSR、边集数组等所有存储都必须实现此 trait
/// - 算法应使用此 trait 作为约束，而非依赖具体存储类型
pub(open) trait GraphReadable {
  /// 节点数量
  node_count(Self) -> Int

  /// 边数量
  edge_count(Self) -> Int

  /// 检查节点是否存在
  contains_node(Self, NodeId) -> Bool

  /// 检查边是否存在
  contains_edge(Self, NodeId, NodeId) -> Bool

  /// 获取节点数据
  get_node(Self, NodeId) -> Double?

  /// 获取边数据
  get_edge(Self, NodeId, NodeId) -> Double?

  /// 获取邻居节点（出边目标）
  neighbors(Self, NodeId) -> Iter[NodeId]

  /// 获取邻居节点及边权重（优化用，避免 get_edge 二次查找）
  neighbors_with_weight(Self, NodeId) -> Iter[(NodeId, Double)]

  /// 节点度（无向图）或出度（有向图）
  degree(Self, NodeId) -> Int

  /// 是否为有向图
  is_directed(Self) -> Bool

  /// 是否为空图
  is_empty(Self) -> Bool

  /// 迭代所有节点 ID
  node_ids(Self) -> Iter[NodeId]

  /// 迭代所有边 (from, to, weight)
  edges(Self) -> Iter[(NodeId, NodeId, Double)]
}

///|
/// 图可写接口
///
/// 仅适用于支持动态修改的存储（邻接表、邻接矩阵）。
/// CSR 等只读存储**不实现**此 trait，符合里氏替换原则 (LSP)。
///
/// # 继承关系
///
/// 继承自 `GraphReadable`，实现此 trait 必须同时实现 `GraphReadable`
pub(open) trait GraphWritable: GraphReadable {
  /// 添加节点，返回其 ID
  add_node(Self, Double) -> NodeId

  /// 删除节点及其关联的所有边
  remove_node(Self, NodeId) -> Bool

  /// 添加边
  ///
  /// # 错误
  ///
  /// - `NodeNotFound`: 起点或终点节点不存在
  /// - `EdgeAlreadyExists`: 边已存在
  add_edge(Self, NodeId, NodeId, Double) -> Result[Unit, GraphError]

  /// 删除边
  remove_edge(Self, NodeId, NodeId) -> Bool

  /// 清空图
  clear(Self) -> Unit
}

///|
/// 有向图扩展接口
///
/// 提供入边查询能力。邻接表需维护反向索引以支持此 trait。
/// 无向图实现可通过返回相同的邻居列表来适配。
///
/// # 继承关系
///
/// 继承自 `GraphReadable`
pub(open) trait GraphDirected: GraphReadable {
  /// 获取前驱节点（入边源）
  in_neighbors(Self, NodeId) -> Iter[NodeId]

  /// 获取后继节点（出边目标）
  out_neighbors(Self, NodeId) -> Iter[NodeId]

  /// 入度
  in_degree(Self, NodeId) -> Int

  /// 出度
  out_degree(Self, NodeId) -> Int

  /// 前驱边 (源节点, 边数据)
  predecessors(Self, NodeId) -> Iter[(NodeId, Double)]

  /// 后继边 (目标节点, 边数据)
  successors(Self, NodeId) -> Iter[(NodeId, Double)]
}

///|
/// 完整图接口
///
/// 组合可写 + 有向图能力，适用于邻接表等通用实现。
///
/// # 继承关系
///
/// 继承自 `GraphWritable + GraphDirected`
pub(open) trait GraphFull: GraphWritable + GraphDirected {
  // 无需额外方法，仅作类型约束的便捷别名
}

///|
/// CSR 批量读取接口
///
/// 提供批量处理优化，适合大图计算。
/// 仅 CSR 等支持连续内存访问的存储实现此 trait。
///
/// # 继承关系
///
/// 继承自 `GraphReadable`
pub(open) trait GraphBatchReadable: GraphReadable {
  /// 批量获取邻居
  batch_neighbors(Self, Array[NodeId]) -> Array[Array[NodeId]]

  /// 批量获取边数据
  batch_edges(Self, Array[(NodeId, NodeId)]) -> Array[Double?]
}


