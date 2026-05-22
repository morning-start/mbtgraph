///|
/// Tarjan 桥查找算法
///
/// 基于 DFS 时间戳和低点值检测无向图中的桥（bridges）。
/// 时间复杂度 O(V+E)。

///|
/// 查找最大节点 ID
fn[G : @core.GraphReadable] bridge_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
/// Tarjan DFS 状态（用于桥检测）
priv struct BridgeState {
  disc : Array[Int]
  low : Array[Int]
  bridges_list : Array[(@core.NodeId, @core.NodeId)]
  time_ref : Array[Int]
}

///|
fn new_bridge_state(size : Int) -> BridgeState {
  BridgeState::{
    disc: Array::make(size, -1),
    low: Array::make(size, 0),
    bridges_list: [],
    time_ref: [0],
  }
}

///|
/// 核心 Tarjan DFS 用于桥检测
fn[G : @core.GraphReadable] tarjan_bridge_dfs(
  state : BridgeState,
  g : G,
  u : Int,
  parent_u : Int,
) -> Unit {
  state.disc[u] = state.time_ref[0]
  state.low[u] = state.time_ref[0]
  state.time_ref[0] = state.time_ref[0] + 1

  for v in @core.GraphReadable::neighbors(g, @core.NodeId(u)) {
    let vid = v.0
    if vid < 0 || vid >= state.disc.length() {
      continue
    }

    if state.disc[vid] == -1 {
      tarjan_bridge_dfs(state, g, vid, u)

      if state.low[vid] < state.low[u] {
        state.low[u] = state.low[vid]
      }

      if state.low[vid] > state.disc[u] {
        state.bridges_list.push((@core.NodeId(u), @core.NodeId(vid)))
      }
    } else if vid != parent_u {
      if state.disc[vid] < state.low[u] {
        state.low[u] = state.disc[vid]
      }
    }
  }
}

///|
/// 在无向图中查找所有桥
///
/// 使用 Tarjan DFS 算法，基于 discovery time 和 low link value 判定桥。
/// 桥是移除后会增加连通分量数的边。
pub fn[G : @core.GraphReadable] find_bridges_undirected(g : G) -> BridgeResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return BridgeResult::{
      bridges: [],
      is_bridge: [],
      count: 0,
    }
  }

  let max_id = bridge_find_max_id(g)
  let size = if max_id + 1 > 1 { max_id + 1 } else { 1 }

  let state = new_bridge_state(size)

  for node in @core.GraphReadable::node_ids(g) {
    if state.disc[node.0] == -1 {
      tarjan_bridge_dfs(state, g, node.0, -1)
    }
  }

  let bridges : Array[@core.Edge] = []
  for pair in state.bridges_list {
    match pair {
      (from, to) => {
        let weight =
          match @core.GraphReadable::get_edge(g, from, to) {
            Some(w) => w
            None => 0.0
          }
        bridges.push(@core.Edge::{ from: from, to: to, data: weight })
      }
    }
  }

  let total_edges = @core.GraphReadable::edge_count(g)
  let is_bridge = Array::make(total_edges, false)

  BridgeResult::{
    bridges: bridges,
    is_bridge: is_bridge,
    count: bridges.length(),
  }
}

///|
/// 在有向图中查找所有桥（基于基图）
///
/// 将有向图视为无向图（忽略方向），运行桥检测算法。
pub fn[G : @core.GraphDirected] find_bridges_directed(g : G) -> BridgeResult {
  find_bridges_undirected(g)
}
