///|
/// SPFA 最短路径算法（Shortest Path Faster Algorithm）
///
/// Bellman-Ford 的队列优化版本，平均时间复杂度 O(kE)，k 为平均入队次数。
/// 使用队列仅松弛距离被更新的节点的出边，避免无意义的松弛操作。
/// 支持负权边，可检测负环。

///|
/// SPFA 单源最短路径
///
/// 成功返回 ShortestPathResult。
/// 如果检测到负环或源节点不存在，返回 Err。
pub fn[G : @core.GraphReadable] spfa(
  graph : G,
  source : @core.NodeId,
) -> Result[ShortestPathResult, String] {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return Ok(ShortestPathResult::{ distances: [], parents: [] })
  }
  if !@core.GraphReadable::contains_node(graph, source) {
    return Err("source node not found")
  }
  let max_id = @storage.find_max_node_id(graph)
  let size = @storage.int_max(max_id + 1, 1)
  let inf = 1000000000000000000.0
  let distances : Array[Double?] = Array::make(size, None)
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  let in_queue : Array[Bool] = Array::make(size, false)
  let enqueue_count : Array[Int] = Array::make(size, 0)
  distances[source.0] = Some(0.0)
  let queue : Array[@core.NodeId] = [source]
  in_queue[source.0] = true
  enqueue_count[source.0] = 1
  let mut head = 0
  while head < queue.length() {
    let u = queue[head]
    head = head + 1
    in_queue[u.0] = false
    let uid = u.0
    if uid < 0 || uid >= size {
      continue
    }
    let ud_opt = distances[uid]
    let ud = match ud_opt {
      None => continue
      Some(d) => d
    }
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw {
        (v, weight) => {
          let vid = v.0
          if vid < 0 || vid >= size {
            continue
          }
          let new_dist = ud + weight
          let vd_opt = distances[vid]
          let should_update = match vd_opt {
            None => true
            Some(d) => new_dist < d
          }
          if should_update {
            distances[vid] = Some(new_dist)
            parents[vid] = Some(u)
            if !in_queue[vid] {
              queue.push(v)
              in_queue[vid] = true
              enqueue_count[vid] = enqueue_count[vid] + 1
              if enqueue_count[vid] > nc + 1 {
                return Err("negative cycle detected")
              }
            }
          }
        }
      }
    }
  }
  Ok(ShortestPathResult::{ distances, parents })
}
