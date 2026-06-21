///|
/// 双向 Dijkstra 最短路径算法
///
/// 同时从源点和目标点进行搜索，相遇时终止。
/// 平均比单向 Dijkstra 快约 2 倍，时间复杂度 O((V+E)log V)。
/// 适用于正权图，不支持负权边。

///|
/// 双向 Dijkstra：计算 source 到 target 的最短路径
///
/// 返回 ShortestPathResult，包含距离和路径信息。
/// - source == target 时直接返回距离 0
/// - source 或 target 不存在时返回 Err
/// - 不可达时 distance_to 返回 -1，path_to 返回空数组
pub fn[G : @core.GraphReadable] bidirectional_dijkstra(
  graph : G,
  source : @core.NodeId,
  target : @core.NodeId,
) -> Result[ShortestPathResult, String] {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return Err("Empty graph")
  }
  if !@core.GraphReadable::contains_node(graph, source) {
    return Err("Source node not found")
  }
  if !@core.GraphReadable::contains_node(graph, target) {
    return Err("Target node not found")
  }

  if source == target {
    let max_id = sp_find_max_id(graph)
    let size = max_int(max_id + 1, 1)
    let distances : Array[Double?] = Array::make(size, None)
    let parents : Array[@core.NodeId?] = Array::make(size, None)
    distances[source.0] = Some(0.0)
    return Ok(ShortestPathResult::{ distances, parents })
  }

  let max_id = sp_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let inf = 1000000000000000000.0

  let forward_dist : Array[Double?] = Array::make(size, None)
  let backward_dist : Array[Double?] = Array::make(size, None)
  let forward_parents : Array[@core.NodeId?] = Array::make(size, None)
  let backward_parents : Array[@core.NodeId?] = Array::make(size, None)
  let forward_visited : Array[Bool] = Array::make(size, false)
  let backward_visited : Array[Bool] = Array::make(size, false)

  forward_dist[source.0] = Some(0.0)
  backward_dist[target.0] = Some(0.0)

  let mut fwd_pq = heap_new()
  fwd_pq = heap_push(fwd_pq, 0.0, source)

  let mut bwd_pq = heap_new()
  bwd_pq = heap_push(bwd_pq, 0.0, target)

  let mut best_distance = inf
  let mut meeting_node : @core.NodeId? = None

  while !heap_is_empty(fwd_pq) || !heap_is_empty(bwd_pq) {
    if !heap_is_empty(fwd_pq) {
      let (fwd_next, fwd_top_opt) = heap_pop(fwd_pq)
      fwd_pq = fwd_next
      match fwd_top_opt {
        Some((u, d_u)) => {
          let uid = u.0
          if forward_visited[uid] {
            continue
          }
          forward_visited[uid] = true

          match backward_dist[uid] {
            Some(bd) => {
              let total = d_u + bd
              if total < best_distance {
                best_distance = total
                meeting_node = Some(u)
              }
            }
            None => ()
          }

          if d_u > best_distance {
            continue
          }

          for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
            match vw {
              (v, weight) => {
                let vid = v.0
                if vid < 0 || vid >= size || forward_visited[vid] {
                  continue
                }
                let new_dist = d_u + weight
                let should_update = match forward_dist[vid] {
                  None => true
                  Some(cd) => new_dist < cd
                }
                if should_update {
                  forward_dist[vid] = Some(new_dist)
                  forward_parents[vid] = Some(u)
                  fwd_pq = heap_push(fwd_pq, new_dist, v)
                }
              }
            }
          }
        }
        None => ()
      }
    }

    if !heap_is_empty(bwd_pq) {
      let (bwd_next, bwd_top_opt) = heap_pop(bwd_pq)
      bwd_pq = bwd_next
      match bwd_top_opt {
        Some((v, d_v)) => {
          let vid = v.0
          if backward_visited[vid] {
            continue
          }
          backward_visited[vid] = true

          match forward_dist[vid] {
            Some(fd) => {
              let total = fd + d_v
              if total < best_distance {
                best_distance = total
                meeting_node = Some(v)
              }
            }
            None => ()
          }

          if d_v > best_distance {
            continue
          }

          for u in @core.GraphReadable::neighbors(graph, v) {
            let uid = u.0
            if uid < 0 || uid >= size || backward_visited[uid] {
              continue
            }
            match @core.GraphReadable::get_edge(graph, u, v) {
              Some(weight) => {
                let new_dist = d_v + weight
                let should_update = match backward_dist[uid] {
                  None => true
                  Some(cd) => new_dist < cd
                }
                if should_update {
                  backward_dist[uid] = Some(new_dist)
                  backward_parents[uid] = Some(v)
                  bwd_pq = heap_push(bwd_pq, new_dist, u)
                }
              }
              None => ()
            }
          }
        }
        None => ()
      }
    }
  }

  match meeting_node {
    None => {
      let distances : Array[Double?] = Array::make(size, None)
      let parents : Array[@core.NodeId?] = Array::make(size, None)
      Ok(ShortestPathResult::{ distances, parents })
    }
    Some(meet) => {
      let final_distances : Array[Double?] = Array::make(size, None)
      let final_parents : Array[@core.NodeId?] = Array::make(size, None)

      final_distances[source.0] = Some(0.0)
      let mut cur = meet
      let mut done = false
      while !done {
        let cidx = cur.0
        match forward_parents[cidx] {
          Some(p) => {
            final_parents[cidx] = Some(p)
            let pd = match final_distances[p.0] {
              None =>
                match forward_dist[p.0] {
                  Some(d) => d
                  None => break
                }
              Some(d) => d
            }
            let cd = match forward_dist[cidx] {
              Some(d) => d
              None => break
            }
            final_distances[cidx] = Some(cd)
            cur = p
          }
          None => done = true
        }
      }

      final_distances[target.0] = Some(best_distance)
      let mut cur2 = meet
      let mut done2 = false
      while !done2 {
        let cidx2 = cur2.0
        if cidx2 == target.0 {
          done2 = true
        } else {
          match backward_parents[cidx2] {
            Some(p) => {
              final_parents[p.0] = Some(cur2)
              let cd2 = match backward_dist[cidx2] {
                Some(d) => d
                None => break
              }
              final_distances[cidx2] = Some(
                best_distance -
                (match backward_dist[p.0] {
                  Some(d) => d
                  None => break
                }),
              )
              cur2 = p
            }
            None => done2 = true
          }
        }
      }

      Ok(ShortestPathResult::{
        distances: final_distances,
        parents: final_parents,
      })
    }
  }
}
