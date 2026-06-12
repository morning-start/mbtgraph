///|
/// Tarjan 双连通分量（Biconnected Components）算法
///
/// 基于 DFS 时间戳和 lowlink 值的无向图双连通分量检测算法。
/// 时间复杂度 O(V+E)，同时检测割点和双连通分量。
///|

priv struct BccState {
  disc : Array[Int]
  low : Array[Int]
  parent : Array[Int]
  visited : Array[Bool]
  stack : Array[@core.NodeId]
  components : Array[Array[@core.NodeId]]
  articulation_points : Array[@core.NodeId]
  time : Array[Int]
}

///|
fn new_bcc_state(size : Int) -> BccState {
  BccState::{
    disc: Array::make(size, -1),
    low: Array::make(size, -1),
    parent: Array::make(size, -1),
    visited: Array::make(size, false),
    stack: [],
    components: [],
    articulation_points: [],
    time: [0],
  }
}

///|
fn[G : @core.GraphReadable] bcc_dfs(
  state : BccState,
  graph : G,
  u : @core.NodeId,
  children_count : Array[Int],
) -> Unit {
  let uid = u.0
  state.visited[uid] = true
  state.disc[uid] = state.time[0]
  state.low[uid] = state.time[0]
  state.time[0] = state.time[0] + 1
  state.stack.push(u)
  for v in @core.GraphReadable::neighbors(graph, u) {
    let vid = v.0
    if vid < 0 || vid >= state.disc.length() {
      continue
    }
    if !state.visited[vid] {
      state.parent[vid] = uid
      children_count[uid] = children_count[uid] + 1
      bcc_dfs(state, graph, v, children_count)
      if state.low[vid] < state.low[uid] {
        state.low[uid] = state.low[vid]
      }
      if state.low[vid] >= state.disc[uid] && uid != state.parent[uid] {
        let mut found = false
        for ap in state.articulation_points {
          if ap == u {
            found = true
          }
        }
        if !found {
          state.articulation_points.push(u)
        }
        let component : Array[@core.NodeId] = []
        let mut done = false
        while !done && state.stack.length() > 0 {
          match state.stack.pop() {
            Some(w) => {
              component.push(w)
              if w.0 == uid {
                done = true
              }
            }
            None => { done = true }
          }
        }
        if component.length() > 0 {
          state.components.push(component)
        }
      }
    } else if vid != state.parent[uid] {
      if state.disc[vid] < state.low[uid] {
        state.low[uid] = state.disc[vid]
      }
    }
  }
}

///|
/// Tarjan 双连通分量算法
///
/// 检测无向图的双连通分量和割点。
/// 使用 DFS 时间戳 + lowlink 值检测割点和双连通分量。
pub fn[G : @core.GraphReadable] biconnected_components(
  graph : G,
) -> BiconnectedComponentsResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return BiconnectedComponentsResult::{
      components: [],
      articulation_points: [],
    }
  }
  let max_id = @storage.find_max_node_id(graph)
  let size = if max_id + 1 > 1 { max_id + 1 } else { 1 }
  let state = new_bcc_state(size)
  let root_children = Array::make(size, 0)
  for node in @core.GraphReadable::node_ids(graph) {
    if !state.visited[node.0] {
      state.parent[node.0] = node.0
      bcc_dfs(state, graph, node, root_children)
      if root_children[node.0] > 1 {
        let mut found = false
        for ap in state.articulation_points {
          if ap == node {
            found = true
          }
        }
        if !found {
          state.articulation_points.push(node)
        }
      }
    }
  }
  if state.stack.length() > 0 {
    state.components.push(state.stack)
  }
  BiconnectedComponentsResult::{
    components: state.components,
    articulation_points: state.articulation_points,
  }
}
