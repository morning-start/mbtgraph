///|
/// Floyd-Warshall 全源最短路径算法
///
/// 计算所有节点对之间的最短路径，时间复杂度 O(V³)。
/// 支持负权边，可检测负环。

///|
/// Floyd-Warshall 全源最短路径
///
/// 成功返回 FloydWarshallResult（含距离矩阵和路径重建信息）。
/// 如果检测到负环，返回 Err。
pub fn[G : @core.GraphReadable] floyd_warshall(
  g : G,
) -> Result[FloydWarshallResult, String] {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return Ok(FloydWarshallResult::{ distances: [], next: [] })
  }
  let max_id = sp_find_max_id(g)
  let size = max_int(max_id + 1, 1)
  let inf = 1000000000000000000.0
  let dist : Array[Array[Double?]] = []
  let nxt : Array[Array[@core.NodeId?]] = []
  for i in 0..<size {
    let row_d : Array[Double?] = []
    let row_n : Array[@core.NodeId?] = []
    for j in 0..<size {
      if i == j {
        row_d.push(Some(0.0))
      } else {
        row_d.push(None)
      }
      row_n.push(None)
    }
    dist.push(row_d)
    nxt.push(row_n)
  }
  for u in @core.GraphReadable::node_ids(g) {
    for v in @core.GraphReadable::neighbors(g, u) {
      match @core.GraphReadable::get_edge(g, u, v) {
        Some(w) => {
          let ui = u.0
          let vi = v.0
          if ui >= 0 && ui < size && vi >= 0 && vi < size {
            dist[ui][vi] = Some(w)
            nxt[ui][vi] = Some(v)
          }
        }
        None => ()
      }
    }
  }
  for k in 0..<size {
    for i in 0..<size {
      for j in 0..<size {
        match dist[i][k] {
          Some(dik) =>
            match dist[k][j] {
              Some(dkj) => {
                let through = dik + dkj
                let should_update = match dist[i][j] {
                  None => true
                  Some(dij) => through < dij
                }
                if should_update {
                  dist[i][j] = Some(through)
                  nxt[i][j] = nxt[i][k]
                }
              }
              None => ()
            }
          None => ()
        }
      }
    }
  }
  for i in 0..<size {
    match dist[i][i] {
      Some(d) => if d < 0.0 { return Err("negative cycle detected") }
      None => ()
    }
  }
  Ok(FloydWarshallResult::{ distances: dist, next: nxt })
}
