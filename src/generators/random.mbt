///|
/// 随机图生成器
///
/// 使用内置 LCG（线性同余生成器）提供可复现的随机图生成。
///
/// LCG 参数: a=1664525, c=1013904223, m=2^32 (Minimal Standard)

priv struct LcgState {
  state : Int
}

fn lcg_new(seed : Int) -> LcgState {
  let s = if seed == 0 { 1 } else { seed }
  LcgState::{ state: s }
}

fn lcg_next(lcg : LcgState) -> (LcgState, Double) {
  let new_state = (1664525 * lcg.state + 1013904223) % 2147483647
  let rng = LcgState::{ state: new_state }
  let val = new_state.to_double() / 2147483647.0
  (rng, val)
}

// ============================================================================
// Erdos-Renyi 随机图 G(n, p)
// ============================================================================

///|
/// 有向 Erdos-Reyni 随机图 G(n, p)
///
/// n 个节点，每条可能的有向边 (i,j) (i≠j) 以概率 p 独立存在。
/// 使用 seed 参数控制随机种子，保证可复现性。
pub fn[G : @core.GraphWritable] random_erdos_renyi_directed(
  g : G,
  n : Int,
  p : Double,
  seed : Int,
  weight : Double,
) -> G {
  if n <= 0 || p <= 0.0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  let mut rng = lcg_new(seed)
  for i in 0..<n {
    for j in 0..<n {
      if i != j {
        let (rng_next, prob) = lcg_next(rng)
        rng = rng_next
        if prob < p {
          @core.GraphWritable::add_edge(gg, @core.NodeId(i), @core.NodeId(j), weight) |> ignore
        }
      }
    }
  }
  gg
}

///|
/// 无向 Erdos-Reyni 随机图 G(n, p)
///
/// n 个节点，每条可能的无向边 {i,j} (i<j) 以概率 p 独立存在。
/// 使用 seed 参数控制随机种子，保证可复现性。
pub fn[G : @core.GraphWritable] random_erdos_renyi_undirected(
  g : G,
  n : Int,
  p : Double,
  seed : Int,
  weight : Double,
) -> G {
  if n <= 0 || p <= 0.0 {
    return g
  }
  let gg = g
  for i in 0..<n {
    @core.GraphWritable::add_node(gg, 0.0) |> ignore
  }
  let mut rng = lcg_new(seed)
  for i in 0..<n {
    for j in (i + 1)..<n {
      let (rng_next, prob) = lcg_next(rng)
      rng = rng_next
      if prob < p {
        @core.GraphWritable::add_edge(gg, @core.NodeId(i), @core.NodeId(j), weight) |> ignore
      }
    }
  }
  gg
}
