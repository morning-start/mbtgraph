///|
/// Tarjan 强连通分量算法
///
/// 基于 DFS 时间戳和栈的单次遍历算法，时间复杂度 O(V+E)。

///|
priv struct TarjanState {
  index : Array[Int]
  low_link : Array[Int]
  on_stack : Array[Bool]
  stack : Array[@core.NodeId]
  stack_top : Array[Int]
  idx_counter : Array[Int]
  components : Array[Array[@core.NodeId]]
}

///|
fn new_tarjan_state(size : Int) -> TarjanState {
  TarjanState::{
    index: Array::make(size, -1),
    low_link: Array::make(size, -1),
    on_stack: Array::make(size, false),
    stack: Array::make(size, @core.NodeId(0)),
    stack_top: [-1],
    idx_counter: [0],
    components: [],
  }
}

///|
fn[G : @core.GraphDirected] tarjan_strongconnect(
  state : TarjanState,
  g : G,
  v : @core.NodeId,
) -> Unit {
  let vid = v.0
  state.index[vid] = state.idx_counter[0]
  state.low_link[vid] = state.idx_counter[0]
  state.idx_counter[0] = state.idx_counter[0] + 1
  state.stack_top[0] = state.stack_top[0] + 1
  state.stack[state.stack_top[0]] = v
  state.on_stack[vid] = true
  for w in @core.GraphReadable::neighbors(g, v) {
    let wid = w.0
    if wid < 0 || wid >= state.index.length() {
      continue
    }
    if state.index[wid] == -1 {
      tarjan_strongconnect(state, g, w)
      if state.low_link[wid] < state.low_link[vid] {
        state.low_link[vid] = state.low_link[wid]
      }
    } else if state.on_stack[wid] {
      if state.index[wid] < state.low_link[vid] {
        state.low_link[vid] = state.index[wid]
      }
    }
  }
  if state.low_link[vid] == state.index[vid] {
    let component : Array[@core.NodeId] = []
    let mut done = false
    while !done {
      let w = state.stack[state.stack_top[0]]
      state.stack_top[0] = state.stack_top[0] - 1
      state.on_stack[w.0] = false
      component.push(w)
      if w.0 == vid {
        done = true
      }
    }
    state.components.push(component)
  }
}

///|
/// Tarjan 强连通分量
///
/// 使用 DFS 时间戳 + 低点（lowlink）检测强连通分量。
pub fn[G : @core.GraphDirected] tarjan_scc(
  graph : G,
) -> StronglyConnectedComponentsResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return StronglyConnectedComponentsResult::{ components: [] }
  }
  let max_id = @storage.find_max_node_id(graph)
  let size = if max_id + 1 > 1 { max_id + 1 } else { 1 }
  let state = new_tarjan_state(size)
  for node in @core.GraphReadable::node_ids(graph) {
    if state.index[node.0] == -1 {
      tarjan_strongconnect(state, graph, node)
    }
  }
  StronglyConnectedComponentsResult::{ components: state.components }
}
