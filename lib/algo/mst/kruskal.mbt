///|
/// Kruskal 最小生成树算法
///
/// 基于边排序 + Union-Find 的贪心算法，时间复杂度 O(E log E)。
/// 适用于无向图。
fn[G : @core.GraphReadable] mst_find_max_id(g : G) -> Int {
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
fn sort_edges(
  edges : Array[(@core.NodeId, @core.NodeId, Double)],
) -> Array[(@core.NodeId, @core.NodeId, Double)] {
  let n = edges.length()
  if n <= 1 {
    return edges
  }
  let result = edges
  let mut i = 0
  while i < n - 1 {
    let mut j = i + 1
    while j < n {
      if result[j].2 < result[i].2 {
        let tmp = result[i]
        result[i] = result[j]
        result[j] = tmp
      }
      j = j + 1
    }
    i = i + 1
  }
  result
}

///|
/// Kruskal 最小生成树
///
/// 返回无向图的最小生成树。如果图不连通，返回森林（每个连通分量的 MST）。
pub fn[G : @core.GraphReadable] kruskal(g : G) -> MstResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }
  let max_id = mst_find_max_id(g)
  let size = max_int(max_id + 1, 1)
  let uf = uf_new(size)
  let raw_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for u in @core.GraphReadable::node_ids(g) {
    for v in @core.GraphReadable::neighbors(g, u) {
      match @core.GraphReadable::get_edge(g, u, v) {
        Some(w) => if u.0 < v.0 { raw_edges.push((u, v, w)) }
        None => ()
      }
    }
  }
  let sorted = sort_edges(raw_edges)
  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0
  for edge in sorted {
    match edge {
      (u, v, w) =>
        if uf_union(uf, u.0, v.0) {
          mst_edges.push((u, v, w))
          total_weight = total_weight + w
        }
    }
  }
  MstResult::{ total_weight, edges: mst_edges }
}
