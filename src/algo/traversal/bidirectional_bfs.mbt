///|
/// 双向广度优先搜索
///
/// 从起点和终点同时进行 BFS，交替扩展节点（每层扩展一层，不是单个节点），
/// 当两个方向的搜索相遇时停止并重建最短路径。
///
/// 时间复杂度 O(b^(d/2))，空间复杂度 O(V)，比普通 BFS 搜索空间小很多。
/// 对于有权图，仍使用无权 BFS 逻辑（不利用边权重）。
///
/// ## 参数
/// - `g`: 实现了 GraphReadable 的图结构
/// - `start`: 起点
/// - `target`: 终点
///
/// ## 返回
/// 最短路径节点序列（含首尾），不可达返回空数组。
pub fn[G : @core.GraphReadable] bidirectional_bfs(
  g : G,
  start : @core.NodeId,
  target : @core.NodeId,
) -> Array[@core.NodeId] {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return []
  }
  let has_start = @core.GraphReadable::contains_node(g, start)
  let has_target = @core.GraphReadable::contains_node(g, target)
  if !has_start || !has_target {
    return []
  }
  if start == target {
    return [start]
  }
  let max_id = bfs_find_max_id(g)
  let size = max(max_id + 1, 1)
  let visited_f = Array::make(size, false)
  let visited_b = Array::make(size, false)
  let parent_f : Array[@core.NodeId?] = Array::make(size, None)
  let parent_b : Array[@core.NodeId?] = Array::make(size, None)
  let queue_f : Array[@core.NodeId] = []
  let queue_b : Array[@core.NodeId] = []
  visited_f[start.0] = true
  visited_b[target.0] = true
  queue_f.push(start)
  queue_b.push(target)
  let mut head_f = 0
  let mut head_b = 0
  while head_f < queue_f.length() || head_b < queue_b.length() {
    let layer_end_f = queue_f.length()
    while head_f < layer_end_f {
      let cur = queue_f[head_f]
      head_f = head_f + 1
      let nbrs = @core.GraphReadable::neighbors(g, cur)
      for nid in nbrs {
        let idx = nid.0
        if idx >= 0 && idx < size {
          if !visited_f[idx] {
            visited_f[idx] = true
            parent_f[idx] = Some(cur)
            queue_f.push(nid)
            if visited_b[idx] {
              return bidir_reconstruct(nid, parent_f, parent_b)
            }
          }
        }
      }
    }
    let layer_end_b = queue_b.length()
    while head_b < layer_end_b {
      let cur = queue_b[head_b]
      head_b = head_b + 1
      let nbrs = @core.GraphReadable::neighbors(g, cur)
      for nid in nbrs {
        let idx = nid.0
        if idx >= 0 && idx < size {
          if !visited_b[idx] {
            visited_b[idx] = true
            parent_b[idx] = Some(cur)
            queue_b.push(nid)
            if visited_f[idx] {
              return bidir_reconstruct(nid, parent_f, parent_b)
            }
          }
        }
      }
    }
  }
  []
}

///|
/// 重建双向 BFS 的最短路径
///
/// 从相遇点出发，沿 forward 侧 parent 回溯到 start，
/// 再沿 backward 侧 parent 延伸到 target。
fn bidir_reconstruct(
  meeting : @core.NodeId,
  parent_f : Array[@core.NodeId?],
  parent_b : Array[@core.NodeId?],
) -> Array[@core.NodeId] {
  let rev_forward : Array[@core.NodeId] = []
  let mut cur = meeting
  rev_forward.push(cur)
  let mut done = false
  while !done {
    let idx = cur.0
    match parent_f[idx] {
      None => done = true
      Some(p) => {
        cur = p
        rev_forward.push(cur)
      }
    }
  }
  let path : Array[@core.NodeId] = []
  let mut j = rev_forward.length() - 1
  while j >= 0 {
    path.push(rev_forward[j])
    j = j - 1
  }
  cur = meeting
  done = false
  while !done {
    let idx = cur.0
    match parent_b[idx] {
      None => done = true
      Some(p) => {
        path.push(p)
        cur = p
      }
    }
  }
  path
}