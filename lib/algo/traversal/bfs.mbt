///|
/// 广度优先搜索 (BFS)
///
/// 从起点开始逐层向外遍历，保证按最短路径顺序访问节点。
/// 时间复杂度 O(V+E)，空间复杂度 O(V)。

///|
/// 单源 BFS：从 start 节点开始遍历
pub fn[G : @core.GraphReadable] bfs(graph : G, start : @core.NodeId) -> BfsResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 || !@core.GraphReadable::contains_node(graph, start) {
    let empty_visited : Array[Bool] = []
    let empty_order : Array[@core.NodeId] = []
    let empty_parents : Array[@core.NodeId?] = []
    let empty_levels : Array[Int] = []
    return BfsResult::{
      base: TraversalResult::{
        visited: empty_visited,
        order: empty_order,
        parents: empty_parents,
      },
      levels: empty_levels,
    }
  }
  let max_id = bfs_find_max_id(graph)
  let size = max(max_id + 1, 1)
  let visited = Array::make(size, false)
  let order : Array[@core.NodeId] = []
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  let levels = Array::make(size, -1)
  let queue : Array[@core.NodeId] = []
  visited[start.0] = true
  levels[start.0] = 0
  parents[start.0] = None
  queue.push(start)
  let mut head = 0
  while head < queue.length() {
    let cur = queue[head]
    head = head + 1
    order.push(cur)
    for nid in @core.GraphReadable::neighbors(graph, cur) {
      let idx = nid.0
      if idx >= 0 && idx < size && !visited[idx] {
        visited[idx] = true
        parents[idx] = Some(cur)
        levels[idx] = levels[cur.0] + 1
        queue.push(nid)
      }
    }
  }
  BfsResult::{ base: TraversalResult::{ visited, order, parents }, levels }
}

///|
/// 多源 BFS：遍历全图所有连通分量
pub fn[G : @core.GraphReadable] bfs_all(graph : G) -> BfsResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    let empty_visited : Array[Bool] = []
    let empty_order : Array[@core.NodeId] = []
    let empty_parents : Array[@core.NodeId?] = []
    let empty_levels : Array[Int] = []
    return BfsResult::{
      base: TraversalResult::{
        visited: empty_visited,
        order: empty_order,
        parents: empty_parents,
      },
      levels: empty_levels,
    }
  }
  let max_id = bfs_find_max_id(graph)
  let size = max(max_id + 1, 1)
  let visited = Array::make(size, false)
  let order : Array[@core.NodeId] = []
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  let levels = Array::make(size, -1)
  for start in @core.GraphReadable::node_ids(graph) {
    if visited[start.0] {
      continue
    }
    let queue : Array[@core.NodeId] = []
    visited[start.0] = true
    levels[start.0] = 0
    parents[start.0] = None
    queue.push(start)
    let mut head = 0
    while head < queue.length() {
      let cur = queue[head]
      head = head + 1
      order.push(cur)
      for nid in @core.GraphReadable::neighbors(graph, cur) {
        let idx = nid.0
        if idx >= 0 && idx < size && !visited[idx] {
          visited[idx] = true
          parents[idx] = Some(cur)
          levels[idx] = levels[cur.0] + 1
          queue.push(nid)
        }
      }
    }
  }
  BfsResult::{ base: TraversalResult::{ visited, order, parents }, levels }
}

///|
/// BFS 最短路径（无权图）
///
/// 返回从 start 到 target 的最短路径节点序列（含首尾）。
/// 如果 target 不可达，返回空数组。
///
/// ⚠️ **重要限制**: 此函数仅适用于**无权图**（所有边权重相同）。
/// 对于**有权图**，请使用 `dijkstra()` 或 `dijkstra_targeted()` 以获得正确结果。
///
/// **时间复杂度**: O(V+E)
/// **空间复杂度**: O(V)
///
/// **使用场景**:
/// - 社交网络中的"六度分隔"查询
/// - 网页链接的最短点击距离
/// - 无权图的最短路径快速计算
pub fn[G : @core.GraphReadable] bfs_shortest_path(
  graph : G,
  start : @core.NodeId,
  target : @core.NodeId,
) -> Array[@core.NodeId] {
  if start == target && @core.GraphReadable::contains_node(graph, start) {
    return [start]
  }
  let result = bfs(graph, start)
  result.base.path_to(target)
}

///|
fn max(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn[G : @core.GraphReadable] bfs_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}
