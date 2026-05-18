///|
/// 深度优先搜索 (DFS)
///
/// 从起点开始沿一条路径尽可能深入，回溯后探索其他分支。
/// 时间复杂度 O(V+E)，空间复杂度 O(V)。

///|
/// 单源 DFS：从 start 节点开始遍历（迭代式，显式栈）
pub fn[G : @core.GraphReadable] dfs(g : G, start : @core.NodeId) -> DfsResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 || !@core.GraphReadable::contains_node(g, start) {
    let empty_v : Array[Bool] = []
    let empty_o : Array[@core.NodeId] = []
    let empty_p : Array[@core.NodeId?] = []
    let empty_e : Array[Int] = []
    let empty_x : Array[Int] = []
    return DfsResult::{
      base: TraversalResult::{ visited: empty_v, order: empty_o, parents: empty_p },
      entry_time: empty_e,
      exit_time: empty_x,
    }
  }
  let max_id = dfs_find_max_id(g)
  let size = max(max_id + 1, 1)
  let visited = Array::make(size, false)
  let order : Array[@core.NodeId] = []
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  let entry = Array::make(size, -1)
  let exit = Array::make(size, -1)
  let mut time = 0
  let stack : Array[@core.NodeId] = [start]
  visited[start.0] = true
  entry[start.0] = time
  time = time + 1
  let mut stack_len = 1
  while stack_len > 0 {
    let cur = stack[stack_len - 1]
    let mut found = false
    for nid in @core.GraphReadable::neighbors(g, cur) {
      let idx = nid.0
      if idx >= 0 && idx < size && !visited[idx] {
        visited[idx] = true
        parents[idx] = Some(cur)
        entry[idx] = time
        time = time + 1
        stack.push(nid)
        stack_len = stack_len + 1
        found = true
        break
      }
    }
    if !found {
      order.push(cur)
      exit[cur.0] = time
      time = time + 1
      stack_len = stack_len - 1
    }
  }
  DfsResult::{
    base: TraversalResult::{ visited: visited, order: order, parents: parents },
    entry_time: entry,
    exit_time: exit,
  }
}

///|
/// 全图 DFS：遍历所有连通分量（迭代式）
pub fn[G : @core.GraphReadable] dfs_all(g : G) -> DfsResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    let empty_v : Array[Bool] = []
    let empty_o : Array[@core.NodeId] = []
    let empty_p : Array[@core.NodeId?] = []
    let empty_e : Array[Int] = []
    let empty_x : Array[Int] = []
    return DfsResult::{
      base: TraversalResult::{ visited: empty_v, order: empty_o, parents: empty_p },
      entry_time: empty_e,
      exit_time: empty_x,
    }
  }
  let max_id = dfs_find_max_id(g)
  let size = max(max_id + 1, 1)
  let visited = Array::make(size, false)
  let order : Array[@core.NodeId] = []
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  let entry = Array::make(size, -1)
  let exit = Array::make(size, -1)
  let mut time = 0
  for start in @core.GraphReadable::node_ids(g) {
    if visited[start.0] {
      continue
    }
    let stack : Array[@core.NodeId] = [start]
    visited[start.0] = true
    entry[start.0] = time
    time = time + 1
    let mut stack_len = 1
    while stack_len > 0 {
      let cur = stack[stack_len - 1]
      let mut found = false
      for nid in @core.GraphReadable::neighbors(g, cur) {
        let idx = nid.0
        if idx >= 0 && idx < size && !visited[idx] {
          visited[idx] = true
          parents[idx] = Some(cur)
          entry[idx] = time
          time = time + 1
          stack.push(nid)
          stack_len = stack_len + 1
          found = true
          break
        }
      }
      if !found {
        order.push(cur)
        exit[cur.0] = time
        time = time + 1
        stack_len = stack_len - 1
      }
    }
  }
  DfsResult::{
    base: TraversalResult::{ visited: visited, order: order, parents: parents },
    entry_time: entry,
    exit_time: exit,
  }
}

fn[G : @core.GraphReadable] dfs_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}
