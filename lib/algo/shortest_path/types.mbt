///|
/// 最短路径结果类型
///
/// 存储单源最短路径算法的计算结果，支持距离查询和路径重建。

///|
/// 单源最短路径结果（Dijkstra / Bellman-Ford 共用）
pub(all) struct ShortestPathResult {
  distances : Array[Double?]
  parents : Array[@core.NodeId?]
}

///|
/// 查询到目标节点的最短距离
///
/// 不可达返回 -1
pub fn ShortestPathResult::distance_to(
  self : ShortestPathResult,
  id : @core.NodeId,
) -> Double {
  let idx = id.0
  if idx < 0 || idx >= self.distances.length() {
    -1.0
  } else {
    match self.distances[idx] {
      Some(d) => d
      None => -1.0
    }
  }
}

///|
/// 查询节点是否可达
pub fn ShortestPathResult::is_reachable(
  self : ShortestPathResult,
  id : @core.NodeId,
) -> Bool {
  let idx = id.0
  if idx < 0 || idx >= self.distances.length() {
    false
  } else {
    match self.distances[idx] {
      Some(_) => true
      None => false
    }
  }
}

///|
/// 获取可达节点数量
pub fn ShortestPathResult::reachable_count(self : ShortestPathResult) -> Int {
  let mut count = 0
  for d in self.distances {
    match d {
      Some(_) => count = count + 1
      None => ()
    }
  }
  count
}

///|
/// 重建从 source 到 target 的最短路径
///
/// 返回 [source, ..., target]，如果 target 不可达则返回空数组
pub fn ShortestPathResult::path_to(
  self : ShortestPathResult,
  target : @core.NodeId,
) -> Array[@core.NodeId] {
  let idx = target.0
  if idx < 0 || idx >= self.parents.length() {
    return []
  }
  match self.distances[idx] {
    None => []
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

// ============================================================================
// K 最短路径结果类型（Yen's 算法）
// ============================================================================

///|
/// K 最短路径结果
pub(all) struct KShortestPathsResult {
  paths : Array[Array[@core.NodeId]]
  distances : Array[Double]
  k : Int
}

///|
/// 获取第 i 条路径
pub fn KShortestPathsResult::path(
  self : KShortestPathsResult,
  index : Int,
) -> Array[@core.NodeId] {
  if index < 0 || index >= self.paths.length() {
    return []
  }
  self.paths[index]
}

///|
/// 获取第 i 条距离
pub fn KShortestPathsResult::distance(
  self : KShortestPathsResult,
  index : Int,
) -> Double {
  if index < 0 || index >= self.distances.length() {
    return -1.0
  }
  self.distances[index]
}

// ============================================================================
// Floyd-Warshall 全源结果类型
// ============================================================================

///|
/// 全源最短路径结果（Floyd-Warshall）
pub(all) struct FloydWarshallResult {
  distances : Array[Array[Double?]]
  next : Array[Array[@core.NodeId?]]
}

///|
/// 查询 from 到 to 的最短距离
///
/// 不可达返回 -1
pub fn FloydWarshallResult::distance(
  self : FloydWarshallResult,
  from : @core.NodeId,
  to : @core.NodeId,
) -> Double {
  let fi = from.0
  let ti = to.0
  if fi < 0 ||
    fi >= self.distances.length() ||
    ti < 0 ||
    ti >= self.distances.length() {
    return -1.0
  }
  match self.distances[fi][ti] {
    Some(d) => d
    None => -1.0
  }
}

///|
/// 重建 from 到 to 的最短路径
///
/// 不可达返回空数组
pub fn FloydWarshallResult::path(
  self : FloydWarshallResult,
  from : @core.NodeId,
  to : @core.NodeId,
) -> Array[@core.NodeId] {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.next.length() || ti < 0 || ti >= self.next.length() {
    return []
  }
  match self.next[fi][ti] {
    None => []
    Some(_) => {
      let path : Array[@core.NodeId] = [from]
      let mut cur = from
      while cur != to {
        let cidx = cur.0
        let tidx = to.0
        if cidx < 0 ||
          cidx >= self.next.length() ||
          tidx < 0 ||
          tidx >= self.next[cidx].length() {
          break
        }
        match self.next[cidx][tidx] {
          None => break
          Some(nxt) => {
            path.push(nxt)
            cur = nxt
          }
        }
      }
      path
    }
  }
}
