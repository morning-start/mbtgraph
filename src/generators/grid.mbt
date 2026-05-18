///|
/// 网格图生成器
///
/// 提供 m×n 二维网格拓扑的构建能力。

///|
/// 有向网格图 m×n
///
/// 每个内部节点连接右邻居和下邻居。
/// 边数 = (m-1)×n + m×(n-1) = 2mn - m - n
pub fn[G : @core.GraphWritable] grid_directed(
  g : G,
  rows : Int,
  cols : Int,
  weight : Double,
) -> G {
  if rows <= 0 || cols <= 0 {
    return g
  }
  let total = rows * cols
  let gg = g
  for i in 0..<total {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for r in 0..<rows {
    for c in 0..<cols {
      let idx = r * cols + c
      if c + 1 < cols {
        @core.GraphWritable::add_edge(
          gg,
          @core.NodeId(idx),
          @core.NodeId(idx + 1),
          weight,
        )
        |> ignore
      }
      if r + 1 < rows {
        @core.GraphWritable::add_edge(
          gg,
          @core.NodeId(idx),
          @core.NodeId(idx + cols),
          weight,
        )
        |> ignore
      }
    }
  }
  gg
}

///|
/// 无向网格图 m×n
///
/// 每个内部节点与右邻居和下邻居双向连接。
/// 边数 = (m-1)×n + m×(n-1)（无向边计数）
pub fn[G : @core.GraphWritable] grid_undirected(
  g : G,
  rows : Int,
  cols : Int,
  weight : Double,
) -> G {
  if rows <= 0 || cols <= 0 {
    return g
  }
  let total = rows * cols
  let gg = g
  for i in 0..<total {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for r in 0..<rows {
    for c in 0..<cols {
      let idx = r * cols + c
      if c + 1 < cols {
        @core.GraphWritable::add_edge(
          gg,
          @core.NodeId(idx),
          @core.NodeId(idx + 1),
          weight,
        )
        |> ignore
      }
      if r + 1 < rows {
        @core.GraphWritable::add_edge(
          gg,
          @core.NodeId(idx),
          @core.NodeId(idx + cols),
          weight,
        )
        |> ignore
      }
    }
  }
  gg
}
