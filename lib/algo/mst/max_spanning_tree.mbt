///|
/// 最大生成树/森林算法
///
/// 通过反转 Kruskal 的排序顺序（降序排列边权），
/// 用并查集贪心选取权重最大的不形成环的边。
///
/// - **连通图**: 返回最大生成树 (MaxST)
/// - **不连通图**: 返回每个连通分量的最大生成树（最大生成森林）
///
/// 时间复杂度 O(E log E)，空间复杂度 O(V+E)

///|
/// 降序排序辅助（用于最大生成树）
fn sort_edges_desc(
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
      if result[j].2 > result[i].2 {
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
/// 最大生成树/森林
///
/// 返回无向图的最大生成树。如果图不连通，返回森林。
/// 原理：Kruskal 算法以**降序**排列边权，贪心选取最大权重的不形成环的边。
pub fn[G : @core.GraphReadable] max_spanning_tree(graph : G) -> MstResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }
  let max_id = mst_find_max_id(graph)
  let size = max_int(max_id + 1, 1)
  let uf = uf_new(size)
  let raw_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for u in @core.GraphReadable::node_ids(graph) {
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw {
        (v, w) => if u.0 < v.0 { raw_edges.push((u, v, w)) }
      }
    }
  }
  let sorted = sort_edges_desc(raw_edges)
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
