///|
/// Prim 最小生成树算法
///
/// 从根节点出发的贪心生长算法，时间复杂度 O((V+E)log V)。
/// 使用数组模拟优先队列（避免跨包依赖）。
fn prim_min_key(
  key : Array[Double?],
  in_mst : Array[Bool],
  size : Int,
) -> (Int, Bool) {
  let mut min_val = 1000000000000000000.0
  let mut min_idx = -1
  let mut found = false
  let mut i = 0
  while i < size {
    if !in_mst[i] {
      match key[i] {
        Some(k) =>
          if k < min_val {
            min_val = k
            min_idx = i
            found = true
          }
        None => ()
      }
    }
    i = i + 1
  }
  (min_idx, found)
}

///|
/// Prim 最小生成树
///
/// 从 root 节点开始构建最小生成树。
pub fn[G : @core.GraphReadable] prim(g : G, root : @core.NodeId) -> MstResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 || !@core.GraphReadable::contains_node(g, root) {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }
  let max_id = mst_find_max_id(g)
  let size = max_int(max_id + 1, 1)
  let key : Array[Double?] = Array::make(size, None)
  let parent : Array[@core.NodeId?] = Array::make(size, None)
  let in_mst : Array[Bool] = Array::make(size, false)
  key[root.0] = Some(0.0)
  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0
  let mut count = 0
  while count < nc {
    let (u, found) = prim_min_key(key, in_mst, size)
    if !found {
      break
    }
    in_mst[u] = true
    match parent[u] {
      Some(p) =>
        match key[u] {
          Some(w) => {
            mst_edges.push((p, @core.NodeId(u), w))
            total_weight = total_weight + w
          }
          None => ()
        }
      None => ()
    }
    let unode = @core.NodeId(u)
    for v in @core.GraphReadable::neighbors(g, unode) {
      let vid = v.0
      if vid >= 0 && vid < size && !in_mst[vid] {
        match @core.GraphReadable::get_edge(g, unode, v) {
          Some(w) => {
            let should_update = match key[vid] {
              None => true
              Some(k) => w < k
            }
            if should_update {
              key[vid] = Some(w)
              parent[vid] = Some(unode)
            }
          }
          None => ()
        }
      }
    }
    count = count + 1
  }
  MstResult::{ total_weight, edges: mst_edges }
}
