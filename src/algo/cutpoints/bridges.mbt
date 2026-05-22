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
/// 在无向图中查找所有桥（关键边）
///
/// 使用 **Tarjan DFS 算法**，基于 discovery time（发现时间）和 low link value（低点值）判定桥。
///
/// ## 功能描述
///
/// 桥（Bridge）是指从图中移除该边后，图的连通分量数会增加的边。
/// 本算法通过一次 DFS 遍历即可找出所有桥。
///
/// ## 时间复杂度
///
/// - **O(V + E)**，其中 V 是节点数，E 是边数
///
/// ## 参数说明
///
/// - `g`: 实现了 `GraphReadable` trait 的图结构（如 `UndirectedAdjList`）
///
/// ## 返回值语义
///
/// 返回 `BridgeResult` 结构体，包含：
/// - `bridges`: 所有桥的边列表（`Array[Edge]`）
/// - `is_bridge`: 布尔数组，`is_bridge[i]` 表示第 i 条边是否为桥
/// - `count`: 桥的总数
///
/// ## 桥判定条件
///
/// 边 (u, v) 是桥当且仅当 **low[v] > disc[u]**，
/// 即 v 无法通过其他路径回到 u 或 u 的祖先。
///
/// ## 使用示例
///
/// ```moonbit nocheck
/// let g = make_chain_graph(5)  // 创建链图 0-1-2-3-4
/// let result = find_bridges_undirected(g)
///
/// for bridge in result.bridges {
///   println("桥: ${bridge.from.id.value()} -> ${bridge.to.id.value()}")
/// }
/// println("总桥数: ${result.count}")
/// ```
pub fn[G : @core.GraphReadable] find_bridges_undirected(g : G) -> BridgeResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return BridgeResult::{ bridges: [], is_bridge: [], count: 0 }
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
        let weight = match @core.GraphReadable::get_edge(g, from, to) {
          Some(w) => w
          None => 0.0
        }
        bridges.push(@core.Edge::{ from, to, data: weight })
      }
    }
  }

  let total_edges = @core.GraphReadable::edge_count(g)
  let is_bridge = Array::make(total_edges, false)

  BridgeResult::{ bridges, is_bridge, count: bridges.length() }
}

///|
/// 在有向图中查找所有桥（基于基图）
///
/// 将有向图视为无向图（忽略边的方向），运行桥检测算法。
///
/// ## 功能描述
///
/// 对于有向图，本函数先将其转换为**基图**（underlying undirected graph），
/// 即忽略所有边的方向，然后在基图上执行 Tarjan 桥检测算法。
///
/// ## 时间复杂度
///
/// - **O(V + E)**，其中 V 是节点数，E 是边数
///
/// ## 参数说明
///
/// - `g`: 实现了 `GraphDirected` trait 的有向图结构（如 `DirectedAdjList`）
///
/// ## 返回值语义
///
/// 返回 `BridgeResult` 结构体，包含：
/// - `bridges`: 所有桥的边列表（`Array[Edge]`）
/// - `is_bridge`: 布尔数组，表示每条边是否为桥
/// - `count`: 桥的总数
///
/// ## 使用示例
///
/// ```moonbit nocheck
/// let mut g = @storage.DirectedAdjList::new(3)
/// g = @storage.DirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
/// g = @storage.DirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
/// let result = find_bridges_directed(g)
/// println("桥的数量: ${result.count}")
/// ```
pub fn[G : @core.GraphDirected] find_bridges_directed(g : G) -> BridgeResult {
  find_bridges_undirected(g)
}
