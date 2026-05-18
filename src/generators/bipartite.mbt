///|
/// 二分图生成器
///
/// 提供完全二分图 K_{m,n} 的构建能力。

///|
/// 有向完全二分图 K_{m,n}
///
/// 左部节点 0..(m-1)，右部节点 m..(m+n-1)。
/// 左部每个节点到右部每个节点都有有向边。
/// 边数 = m × n
pub fn[G : @core.GraphWritable] bipartite_complete_directed(
  g : G,
  m : Int,
  n : Int,
  weight : Double,
) -> G {
  if m <= 0 || n <= 0 {
    return g
  }
  let total = m + n
  let gg = g
  for i in 0..<total {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 0..<m {
    for j in 0..<n {
      @core.GraphWritable::add_edge(
        gg,
        @core.NodeId(i),
        @core.NodeId(m + j),
        weight,
      )
      |> ignore
    }
  }
  gg
}

///|
/// 无向完全二分图 K_{m,n}
///
/// 左部节点 0..(m-1)，右部节点 m..(m+n-1)。
/// 左部每个节点与右部每个节点间有无向边。
/// 边数 = m × n
pub fn[G : @core.GraphWritable] bipartite_complete_undirected(
  g : G,
  m : Int,
  n : Int,
  weight : Double,
) -> G {
  if m <= 0 || n <= 0 {
    return g
  }
  let total = m + n
  let gg = g
  for i in 0..<total {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 0..<m {
    for j in 0..<n {
      @core.GraphWritable::add_edge(
        gg,
        @core.NodeId(i),
        @core.NodeId(m + j),
        weight,
      )
      |> ignore
    }
  }
  gg
}
