///|
/// 基础遍历结果（BFS / DFS 共用）
///
/// 存储遍历过程中的核心元数据，支持路径重建和可达性查询。
pub(all) struct TraversalResult {
  visited : Array[Bool]
  order : Array[@core.NodeId]
  parents : Array[@core.NodeId?]
}

///|
/// 查询节点是否被访问过
pub fn TraversalResult::is_visited(
  self : TraversalResult,
  id : @core.NodeId,
) -> Bool {
  let idx = id.0
  if idx < 0 || idx >= self.visited.length() {
    false
  } else {
    self.visited[idx]
  }
}

///|
/// 获取可达节点数量
pub fn TraversalResult::reachable_count(self : TraversalResult) -> Int {
  self.order.length()
}

///|
/// 重建从起点到 target 的路径（通过 parents[] 回溯）
///
/// 返回 [start, ..., target]，如果 target 不可达则返回空数组
pub fn TraversalResult::path_to(
  self : TraversalResult,
  target : @core.NodeId,
) -> Array[@core.NodeId] {
  let idx = target.0
  if idx < 0 || idx >= self.parents.length() {
    return []
  }
  match self.parents[idx] {
    None => if self.is_visited(target) { [target] } else { [] }
    Some(_) => {
      let path : Array[@core.NodeId] = []
      let mut cur = target
      let mut done = false
      while !done {
        path.push(cur)
        let cidx = cur.0
        if cidx < 0 || cidx >= self.parents.length() {
          done = true
        } else {
          match self.parents[cidx] {
            None => done = true
            Some(p) => cur = p
          }
        }
      }
      let rev : Array[@core.NodeId] = []
      let mut j = path.length() - 1
      while j >= 0 {
        rev.push(path[j])
        j = j - 1
      }
      rev
    }
  }
}

///|
/// BFS 遍历扩展结果
///
/// 在 TraversalResult 基础上增加层级距离信息。
pub(all) struct BfsResult {
  base : TraversalResult
  levels : Array[Int]
}

///|
/// 获取 start 到 id 的最短距离（边数）
///
/// 不可达返回 -1
pub fn BfsResult::distance(self : BfsResult, id : @core.NodeId) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.levels.length() {
    -1
  } else if !self.base.is_visited(id) {
    -1
  } else {
    self.levels[idx]
  }
}

///|
/// DFS 遍历扩展结果
///
/// 在 TraversalResult 基础上增加时间戳信息，
/// 可用于拓扑排序、强连通分量等高级算法。
pub(all) struct DfsResult {
  base : TraversalResult
  entry_time : Array[Int]
  exit_time : Array[Int]
}
