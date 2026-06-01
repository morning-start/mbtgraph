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
/// 三角形是图中最小的环结构（3 个节点两两相连），
/// 在社交网络分析、聚类系数计算等领域有重要应用。
///
/// 使用枚举法：对每条边 (u, v)，统计共同邻居 w > v 形成的三角形。
/// 避免重复计数，保证每个三角形只被统计一次。
///
/// # 参数
///
/// - `graph`: 输入无向图（需实现 GraphReadable trait）
///
/// # 返回
///
/// `TriangleCountResult` 包含：
/// - `total_triangles`: 图中三角形总数
/// - `node_triangles`: 每个节点参与的三角形数
///
/// # 复杂度
///
/// - 时间: O(Σ_{v} deg(v)²)，稀疏图近似 O(V × d²)
/// - 空间: O(V + E) 用于存储排序后的邻接表
///
/// # 应用场景
///
/// - 社交网络紧密社群检测
/// - 聚类系数计算的基础
/// - 网络传递性分析
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
