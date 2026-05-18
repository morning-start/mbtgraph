///|
/// 经典图结构生成器
///
/// 提供完全图、环图、路径图、星型图的构建能力。
/// 所有函数通过 GraphWritable trait 泛型支持任意可写存储类型。

// ============================================================================
// 完全图 K_n：所有节点两两相连
// ============================================================================

///|
/// 有向完全图 K_n
///
/// 每对节点 (i, j) 且 i ≠ j 都有一条有向边 i→j。
/// 边数 = n × (n - 1)
pub fn[G : @core.GraphWritable] complete_directed(
  g : G,
  n : Int,
  weight : Double,
) -> G {
  if n <= 0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 0..<n {
    for j in 0..<n {
      if i != j {
        @core.GraphWritable::add_edge(
          gg,
          @core.NodeId(i),
          @core.NodeId(j),
          weight,
        )
        |> ignore
      }
    }
  }
  gg
}

///|
/// 无向完全图 K_n
///
/// 每对节点 (i, j) 且 i < j 之间有一条无向边。
/// 边数 = n × (n - 1) / 2
pub fn[G : @core.GraphWritable] complete_undirected(
  g : G,
  n : Int,
  weight : Double,
) -> G {
  if n <= 0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 0..<n {
    for j in (i + 1)..<n {
      @core.GraphWritable::add_edge(
        gg,
        @core.NodeId(i),
        @core.NodeId(j),
        weight,
      )
      |> ignore
    }
  }
  gg
}

// ============================================================================
// 环图 C_n：单一环路
// ============================================================================

///|
/// 有向环图 C_n
///
/// 节点 0 → 1 → 2 → ... → (n-1) → 0 形成单向环。
/// 边数 = n（n ≥ 3），n=1 时为自环，n=2 时为双向边
pub fn[G : @core.GraphWritable] cycle_directed(
  g : G,
  n : Int,
  weight : Double,
) -> G {
  if n <= 0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 0..<n {
    let next = (i + 1) % n
    @core.GraphWritable::add_edge(
      gg,
      @core.NodeId(i),
      @core.NodeId(next),
      weight,
    )
    |> ignore
  }
  gg
}

///|
/// 无向环图 C_n
///
/// 节点 0 — 1 — 2 — ... — (n-1) — 0 形成环。
/// 边数 = n（n ≥ 3）
pub fn[G : @core.GraphWritable] cycle_undirected(
  g : G,
  n : Int,
  weight : Double,
) -> G {
  if n <= 0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 0..<n {
    let next = (i + 1) % n
    @core.GraphWritable::add_edge(
      gg,
      @core.NodeId(i),
      @core.NodeId(next),
      weight,
    )
    |> ignore
  }
  gg
}

// ============================================================================
// 路径图 P_n：线性链式
// ============================================================================

///|
/// 有向路径图 P_n
///
/// 节点 0 → 1 → 2 → ... → (n-1) 形成线性链。
/// 边数 = n - 1
pub fn[G : @core.GraphWritable] path_directed(
  g : G,
  n : Int,
  weight : Double,
) -> G {
  if n <= 0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 0..<(n - 1) {
    @core.GraphWritable::add_edge(
      gg,
      @core.NodeId(i),
      @core.NodeId(i + 1),
      weight,
    )
    |> ignore
  }
  gg
}

///|
/// 无向路径图 P_n
///
/// 节点 0 — 1 — 2 — ... — (n-1) 形成线性链。
/// 边数 = n - 1
pub fn[G : @core.GraphWritable] path_undirected(
  g : G,
  n : Int,
  weight : Double,
) -> G {
  if n <= 0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 0..<(n - 1) {
    @core.GraphWritable::add_edge(
      gg,
      @core.NodeId(i),
      @core.NodeId(i + 1),
      weight,
    )
    |> ignore
  }
  gg
}

// ============================================================================
// 星型图 S_n：中心辐射
// ============================================================================

///|
/// 有向星型图 S_n（中心向外）
///
/// 节点 0 为中心，节点 1..(n-1) 为叶节点。
/// 边: 0 → i 对所有 i ∈ [1, n)。
/// 边数 = n - 1
pub fn[G : @core.GraphWritable] star_directed(
  g : G,
  n : Int,
  weight : Double,
) -> G {
  if n <= 0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 1..<n {
    @core.GraphWritable::add_edge(gg, @core.NodeId(0), @core.NodeId(i), weight)
    |> ignore
  }
  gg
}

///|
/// 无向星型图 S_n
///
/// 节点 0 为中心，节点 1..(n-1) 为叶节点。
/// 边: 0 — i 对所有 i ∈ [1, n)。
/// 边数 = n - 1
pub fn[G : @core.GraphWritable] star_undirected(
  g : G,
  n : Int,
  weight : Double,
) -> G {
  if n <= 0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  for i in 1..<n {
    @core.GraphWritable::add_edge(gg, @core.NodeId(0), @core.NodeId(i), weight)
    |> ignore
  }
  gg
}
