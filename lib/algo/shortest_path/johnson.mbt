///|
/// Johnson 全源最短路径算法
///
/// 结合 Bellman-Ford + Dijkstra 的稀疏图全源最短路径算法。
/// 时间复杂度 O(V²logV + VE)，比 Floyd-Warshall O(V³) 更适合稀疏图。
/// 支持负权边（但无负权环）。

///|
/// Johnson 全源最短路径
///
/// 对每个节点运行 Dijkstra，使用 Bellman-Ford 计算的重权重保证非负性。
/// 返回 FloydWarshallResult，与 floyd_warshall 接口一致。
pub fn[G : @core.GraphReadable] johnson(
  g : G,
) -> Result[FloydWarshallResult, String] {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return Ok(FloydWarshallResult::{ distances: [], next: [] })
  }
  let max_id = @storage.find_max_node_id(g)
  let size = @storage.int_max(max_id + 1, 1)
  let node_list : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(g) {
    node_list.push(nid)
  }
  let inf = 1000000000000000000.0
  let h : Array[Double?] = Array::make(size, None)
  for i in 0..<size {
    h[i] = Some(inf)
  }
  match node_list.length() > 0 {
    true => h[node_list[0].0] = Some(0.0)
    false => ()
  }
  for _ in 0..<nc {
    let mut updated = false
    for u in node_list {
      for v in @core.GraphReadable::neighbors(g, u) {
        let uid = u.0
        let vid = v.0
        if uid < 0 || uid >= size || vid < 0 || vid >= size {
          continue
        }
        let uh_opt = h[uid]
        let uh = match uh_opt {
          None => continue
          Some(x) => x
        }
        if uh >= inf {
          continue
        }
        match @core.GraphReadable::get_edge(g, u, v) {
          Some(w) => {
            let new_h = uh + w
            let hv_opt = h[vid]
            let should_update = match hv_opt {
              None => true
              Some(hv) => new_h < hv
            }
            if should_update {
              h[vid] = Some(new_h)
              updated = true
            }
          }
          None => ()
        }
      }
    }
    if !updated {
      break
    }
  }
  for u in node_list {
    for v in @core.GraphReadable::neighbors(g, u) {
      let uid = u.0
      let vid = v.0
      if uid < 0 || uid >= size || vid < 0 || vid >= size {
        continue
      }
      let uh_opt = h[uid]
      match uh_opt {
        None => continue
        Some(uh) =>
          if uh >= inf {
            continue
          } else {
            match @core.GraphReadable::get_edge(g, u, v) {
              Some(w) => {
                let vh_opt = h[vid]
                match vh_opt {
                  Some(vh) => if uh + w < vh { return Err("negative cycle detected") }
                  None => ()
                }
              }
              None => ()
            }
          }
      }
    }
  }
  let dist : Array[Array[Double?]] = []
  let nxt : Array[Array[@core.NodeId?]] = []
  for _ in 0..<size {
    let row_d : Array[Double?] = []
    let row_n : Array[@core.NodeId?] = []
    for j in 0..<size {
      row_d.push(None)
      row_n.push(None)
    }
    dist.push(row_d)
    nxt.push(row_n)
  }
  for s_idx in 0..<node_list.length() {
    let source = node_list[s_idx]
    let local_d : Array[Double?] = Array::make(size, None)
    let local_p : Array[@core.NodeId?] = Array::make(size, None)
    local_d[source.0] = Some(0.0)
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
          for v in @core.GraphReadable::neighbors(g, u) {
            let vid = v.0
            if vid < 0 || vid >= size || visited[vid] {
              continue
            }
            match @core.GraphReadable::get_edge(g, u, v) {
              Some(weight) => {
                let uw_opt = h[uid]
                let uw = match uw_opt {
                  None => continue
                  Some(x) => x
                }
                let vw_opt = h[vid]
                let vw = match vw_opt {
                  None => continue
                  Some(y) => y
                }
                let ud_opt = local_d[uid]
                let ud = match ud_opt {
                  None => continue
                  Some(d) => d
                }
                let rew = weight + uw - vw
                let new_dist = ud + rew
                let vd_opt = local_d[vid]
                let should_update = match vd_opt {
                  None => true
                  Some(d) => new_dist < d
                }
                if should_update {
                  local_d[vid] = Some(new_dist)
                  local_p[vid] = Some(u)
                  pq = heap_push(pq, new_dist, v)
                }
              }
              None => ()
            }
          }
        }
        None => ()
      }
    }
    for t_idx in 0..<node_list.length() {
      let target = node_list[t_idx]
      let td_opt = local_d[target.0]
      match td_opt {
        Some(d_prime) => {
          let hs_opt = h[source.0]
          let hs = match hs_opt {
            None => 0.0
            Some(x) => x
          }
          let ht_opt = h[target.0]
          let ht = match ht_opt {
            None => 0.0
            Some(y) => y
          }
          dist[source.0][target.0] = Some(d_prime - hs + ht)
          let mut trace_cur = target
          let forward_path : Array[@core.NodeId] = [target]
          while true {
            let cidx = trace_cur.0
            if cidx < 0 || cidx >= size {
              break
            }
            match local_p[cidx] {
              None => break
              Some(parent) => {
                forward_path.push(parent)
                trace_cur = parent
                if parent == source {
                  break
                }
              }
            }
          }
          let mut pi = forward_path.length() - 1
          while pi > 0 {
            let from_node = forward_path[pi]
            let to_node = forward_path[pi - 1]
            nxt[from_node.0][target.0] = Some(to_node)
            pi = pi - 1
          }
        }
        None => ()
      }
    }
  }
  for i in 0..<size {
    dist[i][i] = Some(0.0)
  }
  Ok(FloydWarshallResult::{ distances: dist, next: nxt })
}
