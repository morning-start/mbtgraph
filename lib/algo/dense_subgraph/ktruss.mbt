/// K-Truss 分解
///
/// k-truss: 边参与至少 (k-2) 个三角形。
/// 基于三角形计数的边 support 计算。

///|
/// K-Truss 分解
///
/// 计算每条边参与的三角形数量作为 support 值，
/// truss_number = support + 2。k-truss 表示每条边至少参与 (k-2) 个三角形。
///
/// 结果以无向图形式存储，边权重即为 truss number。
/// 高 truss number 的边表示更紧密的连接模式。
///
/// # 参数
///
/// - `graph`: 输入无向图（需实现 GraphReadable trait）
///
/// # 返回
///
/// `KTrussResult` 包含结果图（边权 = truss number）
///
/// # 复杂度
///
/// - 时间: O(V + E × d²)，其中 d 为平均度数
/// - 空间: O(V + E) 用于存储邻居集合和边 support
///
/// # 注意事项
///
/// - 仅适用于无向图
/// - 孤立节点不参与任何 truss
/// - 时间复杂度取决于图的稠密程度
pub fn[G : @core.GraphReadable] k_truss_decomposition(graph : G) -> KTrussResult {
  let n = @core.GraphReadable::node_count(graph)
  let result_graph = @storage.new_undirected()

  if n == 0 {
    return KTrussResult::{ truss: result_graph }
  }

  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(result_graph, 0.0) |> ignore
    i = i + 1
  }

  // 预计算邻居集合
  let neighbor_sets : Array[Array[Int]] = []
  let mut j = 0
  while j < n {
    neighbor_sets.push(sorted_neighbors(graph, @core.NodeId(j)))
    j = j + 1
  }

  // 用 HashMap 记录每条边的 support
  // 编码: key = u * n + v (u < v)
  let edge_support : @hashmap.HashMap[Int, Int] = @hashmap.HashMap([])

  // 初始化所有边为 support = 0
  let mut u2 = 0
  while u2 < n {
    let nu = neighbor_sets[u2]
    let mut vi2 = 0
    while vi2 < nu.length() {
      let v = nu[vi2]
      if v > u2 {
        let key = u2 * n + v
        edge_support.set(key, 0)
      }
      vi2 = vi2 + 1
    }
    u2 = u2 + 1
  }

  // 遍历三角形，每条边参与计数
  // 只计 w > v > u 避免重复
  let mut u = 0
  while u < n {
    let nu = neighbor_sets[u]
    let mut vi = 0
    while vi < nu.length() {
      let v = nu[vi]
      if v > u {
        let nv = neighbor_sets[v]
        let common = intersection_result(nu, nv)
        let mut wi = 0
        while wi < common.length() {
          let w = common[wi]
          if w > v {
            // 三角形 (u, v, w) 唯一计数
            // 三条边各 +1
            let key_uv = u * n + v
            let cur_uv = edge_support.get_or_default(key_uv, 0)
            edge_support.set(key_uv, cur_uv + 1)

            let key_uw = u * n + w
            let cur_uw = edge_support.get_or_default(key_uw, 0)
            edge_support.set(key_uw, cur_uw + 1)

            let key_vw = v * n + w
            let cur_vw = edge_support.get_or_default(key_vw, 0)
            edge_support.set(key_vw, cur_vw + 1)
          }
          wi = wi + 1
        }
      }
      vi = vi + 1
    }
    u = u + 1
  }

  // 将 support 写入结果图作为边权重
  for entry in edge_support.iter() {
    match entry {
      (key, support) => {
        let a = key / n
        let b = key % n
        let weight = (support + 2).to_double()
        @core.GraphWritable::add_edge(
          result_graph,
          @core.NodeId(a),
          @core.NodeId(b),
          weight,
        ) |> ignore
      }
    }
  }

  KTrussResult::{ truss: result_graph }
}
