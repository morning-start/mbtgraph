///|
/// Borůvka 最小生成树算法
///
/// 每轮为每个连通分量选择权值最小的出边，然后合并分量。
/// 天然支持并行化，是三种经典 MST 算法之一（Kruskal/Prim/Borůvka）。
///
/// 时间复杂度 O(E log V)，空间复杂度 O(V + E)
///
/// # 算法步骤
///
/// 1. 每个顶点自成一个连通分量
/// 2. 对每个分量，找到连接其他分量的最小权边
/// 3. 将所有这样的边加入 MST（合并分量）
/// 4. 重复直到只有一个分量（连通图）或没有更多边
///
/// # 参数
///
/// - `graph`: 无向图（需实现 GraphReadable）
///
/// # 返回
///
/// 最小生成树/森林结果

///|
fn[G : @core.GraphReadable] boruvka_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
/// Borůvka 最小生成树
pub fn[G : @core.GraphReadable] boruvka(graph : G) -> MstResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 {
    return MstResult::{ total_weight: 0.0, edges: [] }
  }
  let max_id = boruvka_find_max_id(graph)
  let size = max_int(max_id + 1, 1)

  let uf = uf_new(size)
  let mst_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let mut total_weight = 0.0

  // 预取所有无向边（u < v）
  let all_edges : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for u in @core.GraphReadable::node_ids(graph) {
    for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
      match vw {
        (v, w) => if u.0 < v.0 { all_edges.push((u, v, w)) }
      }
    }
  }

  let mut num_components = nc
  while num_components > 1 {
    // cheapest[comp] = (u, v, w) 分量 comp 的最小出边
    let cheapest : Array[(@core.NodeId, @core.NodeId, Double)?] = Array::make(
      size,
      None,
    )
    // 为每个连通分量找最小出边
    for edge in all_edges {
      match edge {
        (u, v, w) => {
          let ru = uf_find(uf, u.0)
          let rv = uf_find(uf, v.0)
          if ru != rv {
            // 更新分量 ru 的最小出边
            match cheapest[ru] {
              None => cheapest[ru] = Some((u, v, w))
              Some((_, _, cw)) => if w < cw { cheapest[ru] = Some((u, v, w)) }
            }
            // 更新分量 rv 的最小出边
            match cheapest[rv] {
              None => cheapest[rv] = Some((u, v, w))
              Some((_, _, cw)) => if w < cw { cheapest[rv] = Some((u, v, w)) }
            }
          }
        }
      }
    }
    // 添加所有最小出边并合并分量
    let mut added = false
    let mut i = 0
    while i < size {
      match cheapest[i] {
        Some((u, v, w)) =>
          if uf_union(uf, u.0, v.0) {
            mst_edges.push((u, v, w))
            total_weight = total_weight + w
            num_components = num_components - 1
            added = true
          }
        None => ()
      }
      i = i + 1
    }
    if !added {
      break
    }
  }
  MstResult::{ total_weight, edges: mst_edges }
}
