/// 链接预测算法
///
/// 基于图拓扑结构计算两个节点之间的相似度/连接可能性，
/// 用于预测未来可能出现的边。

///|
/// 辅助: 将邻居 Iter 收集为 Array[Int]（NodeId 的内部值）
fn[G : @core.GraphReadable] neighbors_to_ids(graph : G, node : @core.NodeId) -> Array[Int] {
  let ids : Array[Int] = []
  for n in @core.GraphReadable::neighbors(graph, node) {
    ids.push(n.0)
  }
  ids
}

///|
/// 辅助: 将 Array[Int] 转为 HashSet（通过排序去重）
fn to_set(arr : Array[Int]) -> Array[Int] {
  let sorted = arr
  sorted.sort()
  let result : Array[Int] = []
  let mut i = 0
  while i < sorted.length() {
    if result.length() == 0 || result[result.length() - 1] != sorted[i] {
      result.push(sorted[i])
    }
    i = i + 1
  }
  result
}

///|
/// 辅助: 计算两个排序数组的交集
fn intersection(a : Array[Int], b : Array[Int]) -> Array[Int] {
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
/// 辅助: 计算两个排序数组的并集大小
fn union_size(a : Array[Int], b : Array[Int]) -> Int {
  let mut i = 0
  let mut j = 0
  let mut count = 0
  while i < a.length() || j < b.length() {
    if i < a.length() && (j >= b.length() || a[i] < b[j]) {
      count = count + 1
      i = i + 1
    } else if j < b.length() && (i >= a.length() || b[j] < a[i]) {
      count = count + 1
      j = j + 1
    } else {
      count = count + 1
      i = i + 1
      j = j + 1
    }
  }
  count
}

///|
/// 公共邻居 (Common Neighbors)
///
/// 计算两个节点共享的邻居数量，是最基础的链接预测指标。
/// 值越大表示两个节点越可能建立连接。
///
/// # 数学公式
///
/// |N(u) ∩ N(v)|
///
/// 其中 N(u) 和 N(v) 分别是节点 u 和 v 的邻居集合。
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `u`: 第一个节点 ID
/// - `v`: 第二个节点 ID
///
/// # 返回
///
/// 共享邻居数量（非负整数）
///
/// # 复杂度
///
/// - 时间: O(deg(u) + deg(v))，其中 deg 为节点度数
/// - 空间: O(deg(u) + deg(v)) 用于存储邻居集合
///
/// # 示例
///
/// ```moonbit
/// let graph = new_directed()
/// let graph = GraphWritable::add_node(graph, 0.0) |> ignore
/// let graph = GraphWritable::add_node(graph, 1.0) |> ignore
/// let graph = GraphWritable::add_node(graph, 2.0) |> ignore
/// let graph = GraphWritable::add_edge(graph, NodeId(0), NodeId(2), 1.0) |> ignore
/// let graph = GraphWritable::add_edge(graph, NodeId(1), NodeId(2), 1.0) |> ignore
/// let cn = common_neighbors(graph, NodeId(0), NodeId(1))
/// // cn == 1 (节点 2 是公共邻居)
/// ```
pub fn[G : @core.GraphReadable] common_neighbors(
  graph : G,
  u : @core.NodeId,
  v : @core.NodeId,
) -> Int {
  let nu = to_set(neighbors_to_ids(graph, u))
  let nv = to_set(neighbors_to_ids(graph, v))
  intersection(nu, nv).length()
}

///|
/// Jaccard 系数
///
/// 计算共享邻居与总邻居的比率，归一化到 [0, 1] 区间。
/// 相比公共邻居指标，Jaccard 系数考虑了节点度数的影响，
/// 对高度节点的偏好较低。
///
/// # 数学公式
///
/// |N(u) ∩ N(v)| / |N(u) ∪ N(v)|
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `u`: 第一个节点 ID
/// - `v`: 第二个节点 ID
///
/// # 返回
///
/// Jaccard 相似系数（[0.0, 1.0] 范围的浮点数）
///
/// # 复杂度
///
/// - 时间: O(deg(u) + deg(v))
/// - 空间: O(deg(u) + deg(v))
pub fn[G : @core.GraphReadable] jaccard_coefficient(
  graph : G,
  u : @core.NodeId,
  v : @core.NodeId,
) -> Double {
  let nu = to_set(neighbors_to_ids(graph, u))
  let nv = to_set(neighbors_to_ids(graph, v))
  let inter = intersection(nu, nv)
  let inter_len = inter.length()
  let union_len = union_size(nu, nv)
  if union_len == 0 {
    0.0
  } else {
    inter_len.to_double() / union_len.to_double()
  }
}

///|
/// Adamic-Adar 指数
///
/// 对每个共享邻居按其度数的对数倒数加权。
/// 该指标给予稀有连接（低度数邻居）更高的权重，
/// 在实际应用中通常表现优于简单计数方法。
///
/// # 数学公式
///
/// Σ_{w ∈ N(u)∩N(v)} 1/log(|N(w)|)
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `u`: 第一个节点 ID
/// - `v`: 第二个节点 ID
///
/// # 返回
///
/// Adamic-Adar 相似度得分（非负浮点数）
///
/// # 复杂度
///
/// - 时间: O(deg(u) + deg(v) + |common| * log(deg))
/// - 空间: O(deg(u) + deg(v))
pub fn[G : @core.GraphReadable] adamic_adar_index(
  graph : G,
  u : @core.NodeId,
  v : @core.NodeId,
) -> Double {
  let nu = to_set(neighbors_to_ids(graph, u))
  let nv = to_set(neighbors_to_ids(graph, v))
  let common = intersection(nu, nv)
  let mut score = 0.0
  for w_id in common {
    let w = @core.NodeId(w_id)
    let deg = @core.GraphReadable::degree(graph, w)
    if deg > 1 {
      score = score + 1.0 / @math.ln(deg.to_double())
    }
  }
  score
}

///|
/// 优先连接 (Preferential Attachment)
///
/// 基于无标度网络理论，计算两个节点度数的乘积。
/// 高度节点更可能建立新连接（富者愈富效应）。
/// 计算简单但预测精度一般，适合作为基线方法。
///
/// # 数学公式
///
/// deg(u) × deg(v)
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `u`: 第一个节点 ID
/// - `v`: 第二个节点 ID
///
/// # 返回
///
/// 优先连接得分（非负浮点数）
///
/// # 复杂度
///
/// - 时间: O(1)
/// - 空间: O(1)
pub fn[G : @core.GraphReadable] preferential_attachment(
  graph : G,
  u : @core.NodeId,
  v : @core.NodeId,
) -> Double {
  let du = @core.GraphReadable::degree(graph, u).to_double()
  let dv = @core.GraphReadable::degree(graph, v).to_double()
  du * dv
}

///|
/// 资源分配 (Resource Allocation)
///
/// 对每个共享邻居按其度数倒数加权（无需对数）。
/// 与 Adamic-Adar 类似但对高度邻居惩罚更强，
/// 适用于资源有限场景的链接预测。
///
/// # 数学公式
///
/// Σ_{w ∈ N(u)∩N(v)} 1/|N(w)|
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `u`: 第一个节点 ID
/// - `v`: 第二个节点 ID
///
/// # 返回
///
/// 资源分配指数（非负浮点数）
///
/// # 复杂度
///
/// - 时间: O(deg(u) + deg(v))
/// - 空间: O(deg(u) + deg(v))
pub fn[G : @core.GraphReadable] resource_allocation(
  graph : G,
  u : @core.NodeId,
  v : @core.NodeId,
) -> Double {
  let nu = to_set(neighbors_to_ids(graph, u))
  let nv = to_set(neighbors_to_ids(graph, v))
  let common = intersection(nu, nv)
  let mut score = 0.0
  for w_id in common {
    let w = @core.NodeId(w_id)
    let deg = @core.GraphReadable::degree(graph, w)
    if deg > 0 {
      score = score + 1.0 / deg.to_double()
    }
  }
  score
}

///|
/// 综合链接预测评分
///
/// 一次性计算两个节点的所有链接预测指标（5 种），
/// 返回包含所有得分的结构体，便于批量分析和比较。
///
/// # 包含指标
///
/// - `common_neighbors`: 公共邻居数量
/// - `jaccard`: Jaccard 相似系数 [0, 1]
/// - `adamic_adar`: Adamic-Adar 指数
/// - `preferential_attachment`: 优先连接得分
/// - `resource_allocation`: 资源分配指数
///
/// # 参数
///
/// - `graph`: 输入图（需实现 GraphReadable trait）
/// - `u`: 第一个节点 ID
/// - `v`: 第二个节点 ID
///
/// # 返回
///
/// `LinkPredictionResult` 包含所有指标的完整结果
///
/// # 复杂度
///
/// - 时间: O(5 × (deg(u) + deg(v))) = O(deg(u) + deg(v))
/// - 空间: O(deg(u) + deg(v))
///
/// # 示例
///
/// ```moonbit
/// let result = link_prediction_score(graph, node_a, node_b)
/// // 可通过 result.common_neighbors, result.jaccard 等访问各指标
/// ```
pub fn[G : @core.GraphReadable] link_prediction_score(
  graph : G,
  u : @core.NodeId,
  v : @core.NodeId,
) -> LinkPredictionResult {
  let cn = common_neighbors(graph, u, v)
  let jc = jaccard_coefficient(graph, u, v)
  let aa = adamic_adar_index(graph, u, v)
  let pa = preferential_attachment(graph, u, v)
  let ra = resource_allocation(graph, u, v)
  LinkPredictionResult::{ u, v, common_neighbors: cn, jaccard: jc, adamic_adar: aa, preferential_attachment: pa, resource_allocation: ra }
}
