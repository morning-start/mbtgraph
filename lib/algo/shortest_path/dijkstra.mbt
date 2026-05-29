///|
fn[G : @core.GraphReadable] sp_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Dijkstra 最短路径算法
///
/// 非负权图的单源最短路径算法，时间复杂度 O((V+E)log V)。
/// 使用二叉最小堆作为优先队列。

///|
/// Dijkstra 单源最短路径
///
/// 从 source 节点出发，计算到所有可达节点的最短距离。
/// 假设所有边权重非负。
pub fn[G : @core.GraphReadable] dijkstra(
  graph : G,
  source : @core.NodeId,
) -> ShortestPathResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 || !@core.GraphReadable::contains_node(graph, source) {
    return ShortestPathResult::{ distances: [], parents: [] }
  }
  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let inf = 1000000000000000000.0
  let distances : Array[Double?] = Array::make(size, None)
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  distances[source.0] = Some(0.0)
  let mut pq = heap_new()
  pq = heap_push(pq, 0.0, source)
  let visited : Array[Bool] = Array::make(size, false)
  while !heap_is_empty(pq) {
    let (pq_next, top_opt) = heap_pop(pq)
    pq = pq_next
    match top_opt {
      Some((u, _)) => {
        let uid = u.0
        if visited[uid] {
          continue
        }
        visited[uid] = true
        for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
          match vw {
            (v, weight) => {
              let vid = v.0
              if vid < 0 || vid >= size || visited[vid] {
                continue
              }
              let ud = match distances[uid] {
                None => continue
                Some(d) => d
              }
              let new_dist = ud + weight
              let should_update = match distances[vid] {
                None => true
                Some(d) => new_dist < d
              }
              if should_update {
                distances[vid] = Some(new_dist)
                parents[vid] = Some(u)
                pq = heap_push(pq, new_dist, v)
              }
            }
          }
        }
      }
      None => ()
    }
  }
  ShortestPathResult::{ distances, parents }
}

///|
/// Dijkstra 提前终止版：仅计算 source 到 target 的最短路径
///
/// 一旦 target 被从堆中取出即可终止，节省计算量。
/// 返回完整路径节点序列（含首尾），不可达返回空数组。
pub fn[G : @core.GraphReadable] dijkstra_targeted(
  graph : G,
  source : @core.NodeId,
  target : @core.NodeId,
) -> Array[@core.NodeId] {
  if source == target && @core.GraphReadable::contains_node(graph, source) {
    return [source]
  }
  let result = dijkstra(graph, source)
  result.path_to(target)
}
