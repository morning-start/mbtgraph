///|
/// 环检测算法
///
/// 支持有向图和无向图的环检测。
///
/// - **有向图**: 使用 DFS 三色标记法（白/灰/黑）
/// - **无向图**: 使用 DFS + 父节点排除法（忽略回边到父节点）

///|
/// 自动分派：根据 is_directed() 选择对应实现
pub fn[G : @core.GraphReadable] has_cycle(graph : G) -> Bool {
  if @core.GraphReadable::is_directed(graph) {
    directed_cycle_impl(graph)
  } else {
    undirected_cycle_impl(graph)
  }
}

///|
/// 有向环检测（DFS 三色标记法）
///
/// 白(0)=未访问, 灰(1)=访问中, 黑(2)=已完成
/// 遇到灰节点即发现反向边 → 存在环
pub fn[G : @core.GraphDirected] has_directed_cycle(graph : G) -> Bool {
  directed_cycle_impl(graph)
}

///|
/// 无向环检测（DFS + 父节点排除）
///
/// 无向图中，遇到已访问且非父节点的邻居 → 存在环
pub fn[G : @core.GraphReadable] has_undirected_cycle(graph : G) -> Bool {
  undirected_cycle_impl(graph)
}

// ============================================================================
// 内部实现：有向环检测（三色标记法）
// ============================================================================

///|
fn[G : @core.GraphReadable] directed_cycle_impl(g : G) -> Bool {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return false
  }
  let max_id = cycle_find_max_id(g)
  let size = max(max_id + 1, 1)
  let color = Array::make(size, 0)
  for nid in @core.GraphReadable::node_ids(g) {
    let idx = nid.0
    if color[idx] != 0 {
      continue
    }
    if dfs_detect_cycle(g, nid, color, size) {
      return true
    }
  }
  false
}

///|
fn[G : @core.GraphReadable] dfs_detect_cycle(
  g : G,
  cur : @core.NodeId,
  color : Array[Int],
  size : Int,
) -> Bool {
  color[cur.0] = 1
  for nid in @core.GraphReadable::neighbors(g, cur) {
    let idx = nid.0
    if idx < 0 || idx >= size {
      continue
    }
    if color[idx] == 1 {
      return true
    }
    if color[idx] == 0 && dfs_detect_cycle(g, nid, color, size) {
      return true
    }
  }
  color[cur.0] = 2
  false
}

// ============================================================================
// 内部实现：无向环检测（父节点排除法）
// ============================================================================

///|
fn[G : @core.GraphReadable] undirected_cycle_impl(g : G) -> Bool {
  let nc = @core.GraphReadable::node_count(g)
  if nc <= 1 {
    return false
  }
  let max_id = cycle_find_max_id(g)
  let size = max(max_id + 1, 1)
  let visited = Array::make(size, false)
  for nid in @core.GraphReadable::node_ids(g) {
    let idx = nid.0
    if visited[idx] {
      continue
    }
    if dfs_undirected_cycle(g, nid, @core.NodeId(-1), visited, size) {
      return true
    }
  }
  false
}

///|
fn[G : @core.GraphReadable] dfs_undirected_cycle(
  g : G,
  cur : @core.NodeId,
  parent : @core.NodeId,
  visited : Array[Bool],
  size : Int,
) -> Bool {
  visited[cur.0] = true
  for nid in @core.GraphReadable::neighbors(g, cur) {
    let idx = nid.0
    if idx < 0 || idx >= size {
      continue
    }
    if !visited[idx] {
      if dfs_undirected_cycle(g, nid, cur, visited, size) {
        return true
      }
    } else if nid != parent {
      return true
    }
  }
  false
}

///|
fn[G : @core.GraphReadable] cycle_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}
