/// 图度量: 直径/半径/Wiener指数/网络效率/三元组计数

///|
/// 图距离度量结果
pub(all) struct DistanceMetrics {
  /// 直径 (最长最短路径)
  diameter : Int
  /// 半径 (最小离心率)
  radius : Int
  /// Wiener 指数 (所有节点对最短路径长度之和)
  wiener_index : Int
  /// 平均最短路径长度
  avg_path_length : Double
}

///|
/// 网络效率结果
pub(all) struct NetworkEfficiency {
  /// 全局效率 E_glob = 1/(n*(n-1)) * Σ_{i≠j} 1/dist(i,j)
  global_efficiency : Double
  /// 局部效率 (每个节点的效率均值)
  local_efficiency : Double
}

///|
/// 三元组计数结果
pub(all) struct TriadCount {
  /// 连通三元组数 (开放三角形)
  open_triads : Int
  /// 闭合三元组数 (三角形)
  closed_triads : Int
  /// 全局聚类系数 = 3*三角形数 / 连通三元组数
  global_clustering : Double
}

///|
/// 计算图的直径/半径/Wiener指数/平均路径长度
pub fn[G : @core.GraphReadable] distance_metrics(graph : G) -> DistanceMetrics {
  let n = @core.GraphReadable::node_count(graph)

  if n <= 1 {
    return DistanceMetrics::{
      diameter: 0,
      radius: 0,
      wiener_index: 0,
      avg_path_length: 0.0,
    }
  }

  let mut diameter = 0
  let mut radius = -1
  let mut wiener = 0
  let mut total_paths = 0
  let mut path_sum = 0.0

  let mut s = 0
  while s < n {
    let dists = graph_metrics_bfs(graph, s, n)
    let mut eccentricity = 0
    let mut t = 0
    while t < n {
      if t > s && dists[t] > 0 {
        wiener = wiener + dists[t]
        path_sum = path_sum + dists[t].to_double()
        total_paths = total_paths + 1
      }
      if t != s && dists[t] > eccentricity {
        eccentricity = dists[t]
      }
      t = t + 1
    }
    if eccentricity > diameter {
      diameter = eccentricity
    }
    if eccentricity > 0 && (radius < 0 || eccentricity < radius) {
      radius = eccentricity
    }
    s = s + 1
  }

  if radius < 0 {
    radius = 0
  }

  DistanceMetrics::{
    diameter,
    radius,
    wiener_index: wiener,
    avg_path_length: if total_paths > 0 {
      path_sum / total_paths.to_double()
    } else {
      0.0
    },
  }
}

///|
/// 计算网络效率 (全局 + 局部)
pub fn[G : @core.GraphReadable] network_efficiency(
  graph : G,
) -> NetworkEfficiency {
  let n = @core.GraphReadable::node_count(graph)

  if n <= 1 {
    return NetworkEfficiency::{ global_efficiency: 0.0, local_efficiency: 0.0 }
  }

  let mut global_sum = 0.0
  let mut local_sum = 0.0
  let mut global_pairs = 0.0

  let mut s = 0
  while s < n {
    let dists = graph_metrics_bfs(graph, s, n)
    let mut eg = 0.0
    let mut t = 0
    while t < n {
      if t != s && dists[t] > 0 {
        let inv = 1.0 / dists[t].to_double()
        eg = eg + inv
        global_sum = global_sum + inv
        global_pairs = global_pairs + 1.0
      }
      t = t + 1
    }
    // 局部效率 = 邻居子图的效率
    let neighbor_eff = neighbor_subgraph_efficiency(graph, s, dists, n)
    local_sum = local_sum + neighbor_eff
    s = s + 1
  }

  NetworkEfficiency::{
    global_efficiency: if global_pairs > 0.0 {
      global_sum / global_pairs
    } else {
      0.0
    },
    local_efficiency: local_sum / n.to_double(),
  }
}

///|
/// 计算邻居子图的效率
fn[G : @core.GraphReadable] neighbor_subgraph_efficiency(
  graph : G,
  node : Int,
  dists : Array[Int],
  n : Int,
) -> Double {
  // 收集邻居
  let nbrs : Array[Int] = []
  let mut i = 0
  while i < n {
    if i != node && dists[i] == 1 {
      nbrs.push(i)
    }
    i = i + 1
  }

  let m = nbrs.length()
  if m <= 1 {
    return 0.0
  }

  let mut sum = 0.0
  let mut pairs = 0.0
  let mut a = 0
  while a < m {
    let na = nbrs[a]
    let sub_dists = graph_metrics_bfs_with_exclude(graph, na, n, node)
    let mut b = a + 1
    while b < m {
      let nb = nbrs[b]
      if sub_dists[nb] > 0 {
        sum = sum + 1.0 / sub_dists[nb].to_double()
      }
      pairs = pairs + 1.0
      b = b + 1
    }
    a = a + 1
  }

  if pairs > 0.0 {
    sum / pairs
  } else {
    0.0
  }
}

///|
/// 三元组计数 + 全局聚类系数
pub fn[G : @core.GraphReadable] triad_counting(graph : G) -> TriadCount {
  let n = @core.GraphReadable::node_count(graph)
  if n < 3 {
    return TriadCount::{
      open_triads: 0,
      closed_triads: 0,
      global_clustering: 0.0,
    }
  }

  // 构建邻接集合 (使用无重复邻居)
  let adj = build_triad_adjacency(graph, n)

  let mut triangles = 0
  let mut connected_triples = 0

  let mut i = 0
  while i < n {
    let nbrs = adj[i]
    let d = nbrs.length()
    if d >= 2 {
      connected_triples = connected_triples + d * (d - 1) / 2
      let mut j_idx = 0
      while j_idx < d {
        let j = nbrs[j_idx]
        let mut k_idx = j_idx + 1
        while k_idx < d {
          let k = nbrs[k_idx]
          if has_edge_triad(adj[j], k) {
            triangles = triangles + 1
          }
          k_idx = k_idx + 1
        }
        j_idx = j_idx + 1
      }
    }
    i = i + 1
  }

  // 每个三角形被计数3次 (每个顶点一次)
  let true_triangles = triangles / 3
  let open = connected_triples - 3 * true_triangles
  let gc = if connected_triples > 0 {
    (3 * true_triangles).to_double() / connected_triples.to_double()
  } else {
    0.0
  }

  TriadCount::{
    open_triads: open,
    closed_triads: true_triangles,
    global_clustering: gc,
  }
}

///|
fn[G : @core.GraphReadable] graph_metrics_bfs(
  graph : G,
  source : Int,
  n : Int,
) -> Array[Int] {
  let dist : Array[Int] = Array::make(n, -1)
  dist[source] = 0
  let queue : Array[Int] = [source]
  let mut head = 0
  while head < queue.length() {
    let v = queue[head]
    head = head + 1
    for w in @core.GraphReadable::neighbors(graph, @core.NodeId(v)) {
      let wi = w.0
      if wi >= 0 && wi < n && dist[wi] < 0 {
        dist[wi] = dist[v] + 1
        queue.push(wi)
      }
    }
  }
  dist
}

///|
fn[G : @core.GraphReadable] graph_metrics_bfs_with_exclude(
  graph : G,
  source : Int,
  n : Int,
  exclude : Int,
) -> Array[Int] {
  let dist : Array[Int] = Array::make(n, -1)
  dist[source] = 0
  let queue : Array[Int] = [source]
  let mut head = 0
  while head < queue.length() {
    let v = queue[head]
    head = head + 1
    for w in @core.GraphReadable::neighbors(graph, @core.NodeId(v)) {
      let wi = w.0
      if wi == exclude {
        continue
      }
      if wi >= 0 && wi < n && dist[wi] < 0 {
        dist[wi] = dist[v] + 1
        queue.push(wi)
      }
    }
  }
  dist
}

///|
fn[G : @core.GraphReadable] build_triad_adjacency(
  graph : G,
  n : Int,
) -> Array[Array[Int]] {
  let adj : Array[Array[Int]] = Array::make(n, [])
  let mut i = 0
  while i < n {
    for nb in @core.GraphReadable::neighbors(graph, @core.NodeId(i)) {
      let ni = nb.0
      if ni >= 0 && ni < n && ni != i && !has_edge_triad(adj[i], ni) {
        adj[i].push(ni)
      }
    }
    i = i + 1
  }
  adj
}

///|
fn has_edge_triad(arr : Array[Int], val : Int) -> Bool {
  for x in arr {
    if x == val {
      return true
    }
  }
  false
}
