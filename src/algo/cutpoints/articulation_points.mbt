///|
/// Tarjan 割点查找算法
///
/// 基于 DFS 时间戳和低点值检测无向图中的割点（articulation points）。
/// 时间复杂度 O(V+E)。

///|
/// 查找最大节点 ID
fn[G : @core.GraphReadable] ap_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
/// Tarjan DFS 状态（用于割点检测）
priv struct APState {
  disc : Array[Int]
  low : Array[Int]
  parent : Array[Int]
  ap : Array[Bool]
  time_ref : Array[Int]
}

///|
fn new_ap_state(size : Int) -> APState {
  APState::{
    disc: Array::make(size, -1),
    low: Array::make(size, 0),
    parent: Array::make(size, -1),
    ap: Array::make(size, false),
    time_ref: [0],
  }
}

///|
/// 核心 Tarjan DFS 用于割点检测
fn[G : @core.GraphReadable] tarjan_ap_dfs(
  state : APState,
  g : G,
  u : Int,
  is_root : Bool,
) -> Unit {
  state.disc[u] = state.time_ref[0]
  state.low[u] = state.time_ref[0]
  state.time_ref[0] = state.time_ref[0] + 1

  let mut child_count = 0

  for v in @core.GraphReadable::neighbors(g, @core.NodeId(u)) {
    let vid = v.0
    if vid < 0 || vid >= state.disc.length() {
      continue
    }

    if state.disc[vid] == -1 {
      state.parent[vid] = u
      child_count = child_count + 1
      tarjan_ap_dfs(state, g, vid, false)

      if state.low[vid] < state.low[u] {
        state.low[u] = state.low[vid]
      }

      if !is_root && state.low[vid] >= state.disc[u] {
        state.ap[u] = true
      }
    } else if vid != state.parent[u] {
      if state.disc[vid] < state.low[u] {
        state.low[u] = state.disc[vid]
      }
    }
  }

  if is_root && child_count >= 2 {
    state.ap[u] = true
  }
}

///|
/// 在无向图中查找所有割点
///
/// 使用 Tarjan DFS 算法，基于 discovery time 和 low link value 判定割点。
pub fn[G : @core.GraphReadable] find_articulation_points_undirected(
  g : G,
) -> CutPointResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return CutPointResult::{
      cut_points: [],
      is_cut_point: [],
      count: 0,
    }
  }

  let max_id = ap_find_max_id(g)
  let size = if max_id + 1 > 1 { max_id + 1 } else { 1 }

  let state = new_ap_state(size)

  for node in @core.GraphReadable::node_ids(g) {
    if state.disc[node.0] == -1 {
      tarjan_ap_dfs(state, g, node.0, true)
    }
  }

  let cut_points : Array[@core.NodeId] = []
  let mut count = 0
  for i in 0..<size {
    if state.ap[i] {
      cut_points.push(@core.NodeId(i))
      count = count + 1
    }
  }

  CutPointResult::{
    cut_points: cut_points,
    is_cut_point: state.ap,
    count: count,
  }
}

///|
/// 在有向图中查找所有割点（基于基图）
///
/// 将有向图视为无向图（忽略方向），运行割点检测算法。
pub fn[G : @core.GraphDirected] find_articulation_points_directed(
  g : G,
) -> CutPointResult {
  find_articulation_points_undirected(g)
}
