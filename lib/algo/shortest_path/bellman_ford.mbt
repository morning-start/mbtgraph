///|
/// Bellman-Ford 最短路径算法
///
/// 支持负权边的单源最短路径算法，时间复杂度 O(VE)。
/// 可检测图中是否存在负环。

///|
/// Bellman-Ford 单源最短路径（支持负权边）
///
/// 成功返回 ShortestPathResult。
/// 如果检测到负环，返回 Err。
pub fn[G : @core.GraphReadable] bellman_ford(
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
  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let inf = 1000000000000000000.0
  let distances : Array[Double?] = Array::make(size, None)
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  distances[source.0] = Some(0.0)
  let node_list : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(graph) {
    node_list.push(nid)
  }
  let edge_list : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for u in node_list {
    for v in @core.GraphReadable::neighbors(graph, u) {
      match @core.GraphReadable::get_edge(graph, u, v) {
        Some(w) => edge_list.push((u, v, w))
        None => ()
      }
    }
  }
  for _ in 0..<nc {
    let mut relaxed = false
    for edge in edge_list {
      match edge {
        (u, v, w) => {
          let uid = u.0
          let vid = v.0
          if uid < 0 || uid >= size || vid < 0 || vid >= size {
            continue
          }
          let ud = match distances[uid] {
            None => continue
            Some(d) => d
          }
          let new_dist = ud + w
          let should_update = match distances[vid] {
            None => true
            Some(d) => new_dist < d
          }
          if should_update {
            distances[vid] = Some(new_dist)
            parents[vid] = Some(u)
            relaxed = true
          }
        }
      }
    }
  }
  for edge in edge_list {
    match edge {
      (u, v, w) => {
        let uid = u.0
        let vid = v.0
        if uid < 0 || uid >= size || vid < 0 || vid >= size {
          continue
        }
        match distances[uid] {
          None => continue
          Some(ud) =>
            match distances[vid] {
              Some(vd) =>
                if ud + w < vd {
                  return Err("negative cycle detected")
                }
              None => ()
            }
        }
      }
    }
  }
  Ok(ShortestPathResult::{ distances, parents })
}
