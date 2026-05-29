/// 三角形计数
///
/// 统计无向图中每个节点参与的三角形数量。

///|
/// 辅助: 将邻居收集为排序数组
fn[G : @core.GraphReadable] sorted_neighbors(graph : G, node : @core.NodeId) -> Array[Int] {
  let ns : Array[Int] = []
  for n in @core.GraphReadable::neighbors(graph, node) {
    ns.push(n.0)
  }
  ns.sort()
  ns
}

///|
/// 辅助: 计算排序数组的交集并将共同元素收集到结果数组
fn intersection_result(a : Array[Int], b : Array[Int]) -> Array[Int] {
  let res : Array[Int] = []
  let mut i = 0
  let mut j = 0
  while i < a.length() && j < b.length() {
    if a[i] == b[j] {
      res.push(a[i])
      i = i + 1
      j = j + 1
    } else if a[i] < b[j] {
      i = i + 1
    } else {
      j = j + 1
    }
  }
  res
}

///|
/// 全局三角形计数
///
/// 统计图中所有三角形的数量以及每个节点参与的三角形数。
/// 适用于无向图。
pub fn[G : @core.GraphReadable] count_triangles(graph : G) -> TriangleCountResult {
  let n = @core.GraphReadable::node_count(graph)
  let per_node : Array[Int] = []
  let mut i = 0
  while i < n {
    per_node.push(0)
    i = i + 1
  }

  // 提前计算所有节点的邻居集合
  let neighbor_sets : Array[Array[Int]] = []
  let mut j = 0
  while j < n {
    neighbor_sets.push(sorted_neighbors(graph, @core.NodeId(j)))
    j = j + 1
  }

  let mut total = 0
  let mut u = 0
  while u < n {
    let nu = neighbor_sets[u]
    let mut vi = 0
    while vi < nu.length() {
      let v = nu[vi]
      if v > u {
        let nv = neighbor_sets[v]
        let common = intersection_result(nu, nv)
        let common_len = common.length()
        let mut wi = 0
        while wi < common_len {
          let w = common[wi]
          // 只计 w > v, 保证每个三角形 (u,v,w) 只被计数一次
          if w > v {
            total = total + 1
            per_node[u] = per_node[u] + 1
            per_node[v] = per_node[v] + 1
            per_node[w] = per_node[w] + 1
          }
          wi = wi + 1
        }
      }
      vi = vi + 1
    }
    u = u + 1
  }

  TriangleCountResult::{ total, per_node }
}
