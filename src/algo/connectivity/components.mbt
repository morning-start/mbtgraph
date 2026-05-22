///|
/// 无向连通分量提取
///
/// 基于 BFS/DFS 的 visited[] 数组分组。
fn[G : @core.GraphReadable] conn_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
/// 提取无向图的连通分量
///
/// 返回每个连通分量包含的节点列表。
pub fn[G : @core.GraphReadable] connected_components(
  g : G,
) -> ConnectedComponents {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return ConnectedComponents::{ components: [] }
  }
  let max_id = conn_find_max_id(g)
  let size = max_int(max_id + 1, 1)
  let visited : Array[Bool] = Array::make(size, false)
  let result : Array[Array[@core.NodeId]] = []
  for start in @core.GraphReadable::node_ids(g) {
    if visited[start.0] {
      continue
    }
    let component : Array[@core.NodeId] = []
    let queue : Array[@core.NodeId] = [start]
    visited[start.0] = true
    let mut head = 0
    while head < queue.length() {
      let cur = queue[head]
      component.push(cur)
      head = head + 1
      for nbr in @core.GraphReadable::neighbors(g, cur) {
        if !visited[nbr.0] {
          visited[nbr.0] = true
          queue.push(nbr)
        }
      }
    }
    result.push(component)
  }
  ConnectedComponents::{ components: result }
}
