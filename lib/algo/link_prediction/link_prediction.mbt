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
/// 计算两个节点共享的邻居数量: |N(u) ∩ N(v)|
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
/// 共享邻居与总邻居的比率: |N(u) ∩ N(v)| / |N(u) ∪ N(v)|
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
/// 对每个共享邻居按其度数的对数倒数加权: Σ 1/log(|N(w)|)
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
/// 两个节点度数乘积: deg(u) × deg(v)
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
/// 对每个共享邻居按其度数倒数加权: Σ 1/|N(w)|
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
/// 计算两个节点的所有链接预测指标
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
