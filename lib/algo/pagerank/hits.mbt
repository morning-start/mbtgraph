///|
/// HITS (Hyperlink-Induced Topic Search) 算法
///
/// 计算每个节点的 Hub 值和 Authority 值。
/// Hub: 指向高质量权威节点的节点（出边质量）
/// Authority: 被高质量 Hub 节点指向的节点（入边质量）
///
/// # 迭代公式
///
///   a(v) = Σ h(u), for all u → v
///   h(v) = Σ a(u), for all v → u
///
/// 每轮迭代后归一化（L2 范数），保证收敛。
///
/// # 参数
///
/// - `graph`: 有向图（需实现 GraphReadable）
/// - `max_iterations`: 最大迭代次数，默认 100
/// - `tolerance`: 收敛阈值，默认 1e-6
///
/// # 返回
///
/// HITS 结果，包含 hub 和 authority 评分

///|
/// HITS 计算结果
pub(all) struct HitsResult {
  /// 每个节点的 Authority 评分
  authority : Array[Double]
  /// 每个节点的 Hub 评分
  hub : Array[Double]
  /// 实际迭代次数
  iterations : Int
  /// 是否收敛
  converged : Bool
} derive(Debug)

///|
/// HITS 算法主函数
pub fn[G : @core.GraphReadable] hits(
  graph : G,
  max_iterations : Int,
  tolerance : Double,
) -> HitsResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return HitsResult::{
      authority: [],
      hub: [],
      iterations: 0,
      converged: true,
    }
  }

  let inv_sqrt_n = 1.0 / f64_sqrt(int_to_double(n))

  let mut auth = Array::make(n, inv_sqrt_n)
  let mut hub = Array::make(n, inv_sqrt_n)

  // 预计算出边列表（每个节点指向的邻居）
  let out_adj = build_out_adj(graph, n)
  // 预计算入边列表（每个节点被哪些节点指向）
  let in_adj = build_in_adj(graph, n)

  let mut iter = 0
  let mut converged = false
  while iter < max_iterations {
    // 计算新的 Authority: a(v) = Σ h(u), u → v
    let new_auth = Array::make(n, 0.0)
    let mut i = 0
    while i < n {
      let mut sum = 0.0
      for src in in_adj[i] {
        sum = sum + hub[src]
      }
      new_auth[i] = sum
      i = i + 1
    }

    // 计算新的 Hub: h(v) = Σ a(u), v → u
    let new_hub = Array::make(n, 0.0)
    let mut j = 0
    while j < n {
      let mut sum = 0.0
      for dst in out_adj[j] {
        sum = sum + new_auth[dst]
      }
      new_hub[j] = sum
      j = j + 1
    }

    // L2 归一化
    let auth_norm = l2_norm(new_auth, n)
    let hub_norm = l2_norm(new_hub, n)

    let mut p = 0
    while p < n {
      new_auth[p] = new_auth[p] / auth_norm
      new_hub[p] = new_hub[p] / hub_norm
      p = p + 1
    }

    // 检查收敛
    let auth_diff = max_abs_diff(auth, new_auth, n)
    let hub_diff = max_abs_diff(hub, new_hub, n)
    auth = new_auth
    hub = new_hub
    iter = iter + 1
    if auth_diff < tolerance && hub_diff < tolerance {
      converged = true
      break
    }
  }
  HitsResult::{ authority: auth, hub, iterations: iter, converged }
}

///|
/// 构建出边邻接表
fn[G : @core.GraphReadable] build_out_adj(
  graph : G,
  n : Int,
) -> Array[Array[Int]] {
  let adj : Array[Array[Int]] = Array::make(n, [])
  for u in @core.GraphReadable::node_ids(graph) {
    let ui = u.0
    if ui < 0 || ui >= n {
      continue
    }
    let nbrs : Array[Int] = []
    for nid in @core.GraphReadable::neighbors(graph, u) {
      let ni = nid.0
      if ni >= 0 && ni < n {
        nbrs.push(ni)
      }
    }
    adj[ui] = nbrs
  }
  adj
}

///|
/// 构建入边邻接表
fn[G : @core.GraphReadable] build_in_adj(
  graph : G,
  n : Int,
) -> Array[Array[Int]] {
  let adj : Array[Array[Int]] = Array::make(n, [])
  for triple in @core.GraphReadable::edges(graph) {
    match triple {
      (u, v, _) => {
        let ui = u.0
        let vi = v.0
        if ui >= 0 && ui < n && vi >= 0 && vi < n {
          adj[vi].push(ui)
        }
      }
    }
  }
  adj
}

///|
/// 计算 L2 范数
fn l2_norm(arr : Array[Double], n : Int) -> Double {
  let mut sum = 0.0
  let mut i = 0
  while i < n {
    sum = sum + arr[i] * arr[i]
    i = i + 1
  }
  f64_sqrt(sum)
}

///|
/// 计算两个数组的最大绝对差
fn max_abs_diff(a : Array[Double], b : Array[Double], n : Int) -> Double {
  let mut md = 0.0
  let mut i = 0
  while i < n {
    let mut d = a[i] - b[i]
    if d < 0.0 {
      d = -d
    }
    if d > md {
      md = d
    }
    i = i + 1
  }
  md
}

///|
fn f64_sqrt(x : Double) -> Double {
  x.sqrt()
}

///|
fn int_to_double(x : Int) -> Double {
  x.to_double()
}
