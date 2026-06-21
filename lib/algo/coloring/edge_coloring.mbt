///|
/// 边着色算法（贪心 + Vizing 定理）
///
/// 使用贪心策略为每条边分配颜色，保证相邻边不同色。
/// 基于简单贪心：对每条边选择两端点都未使用的最小颜色。
/// 时间复杂度 O(VE)，空间复杂度 O(V²)。
/// 保证使用 ≤ 2Δ-1 种颜色完成合法边着色。

// ============================================================================
// 私有辅助函数
// ============================================================================

///|
/// 查找节点 u 的已使用颜色集合（返回 Bool 数组，used[c]=true 表示颜色 c 已用）
fn collect_edge_used_colors(
  ec : Array[Array[Int?]],
  max_c : Int,
  u : Int,
) -> Array[Bool] {
  let used : Array[Bool] = Array::make(max_c + 1, false)
  for j in 0..<ec.length() {
    match ec[u][j] {
      Some(c) => if c >= 0 && c <= max_c { used[c] = true }
      None => ()
    }
  }
  used
}

///|
/// 查找两个节点共同可用的最小颜色编号
fn find_common_free_color(
  ec : Array[Array[Int?]],
  max_c : Int,
  u : Int,
  v : Int,
) -> Int {
  let used_u = collect_edge_used_colors(ec, max_c, u)
  let used_v = collect_edge_used_colors(ec, max_c, v)
  let mut c = 0
  while c <= max_c {
    if !used_u[c] && !used_v[c] {
      return c
    }
    c = c + 1
  }
  -1
}

///|
/// 验证边着色合法性（相邻边不同色）
fn[G : @core.GraphReadable] validate_edge_coloring(
  g : G,
  ec : Array[Array[Int?]],
) -> Bool {
  let n = @core.GraphReadable::node_count(g)
  let mut u = 0
  while u < n {
    let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(u))
    let seen_colors : Array[Int] = []
    for neighbor in neighbors {
      let vi = neighbor.0
      if vi < 0 || vi >= n || vi == u {
        continue
      }
      match ec[u][vi] {
        Some(c) => {
          if c < 0 {
            return false
          }
          for sc in seen_colors {
            if sc == c {
              return false
            }
          }
          seen_colors.push(c)
        }
        None => ()
      }
    }
    u = u + 1
  }
  true
}

///|
/// 统计已使用的颜色总数
fn count_used_colors(ec : Array[Array[Int?]]) -> Int {
  let mut max_c = -1
  for row in ec {
    for cell in row {
      match cell {
        Some(c) => if c > max_c { max_c = c }
        None => ()
      }
    }
  }
  if max_c < 0 {
    0
  } else {
    max_c + 1
  }
}

// ============================================================================
// 贪心边着色算法
// ============================================================================

///|
/// 边着色算法（贪心）
///
/// 对每条边按顺序分配最小可用颜色（两端点均未使用）。
/// 时间复杂度 O(VE)，保证合法着色，使用颜色数 ≤ 2Δ-1。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable trait 的无向图结构
///
/// # 返回值
///
/// EdgeColoringResult 结构体：
/// - `edge_colors`: 边颜色矩阵
/// - `num_colors`: 使用的颜色总数
/// - `max_degree`: 图的最大度数 Δ
/// - `is_valid`: 是否为合法边着色
pub fn[G : @core.GraphReadable] edge_coloring(graph : G) -> EdgeColoringResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return EdgeColoringResult::{
      edge_colors: [],
      num_colors: 0,
      max_degree: 0,
      is_valid: true,
    }
  }
  let mut max_deg = 0
  let mut i = 0
  while i < n {
    let d = @core.GraphReadable::degree(graph, @core.NodeId(i))
    if d > max_deg {
      max_deg = d
    }
    i = i + 1
  }
  if max_deg == 0 {
    let empty_ec : Array[Array[Int?]] = []
    for _ in 0..<n {
      let row : Array[Int?] = []
      for _ in 0..<n {
        row.push(None)
      }
      empty_ec.push(row)
    }
    return EdgeColoringResult::{
      edge_colors: empty_ec,
      num_colors: 0,
      max_degree: 0,
      is_valid: true,
    }
  }
  let k = 2 * max_deg
  let ec : Array[Array[Int?]] = []
  for _ in 0..<n {
    let row : Array[Int?] = []
    for _ in 0..<n {
      row.push(None)
    }
    ec.push(row)
  }
  let mut ui = 0
  while ui < n {
    let neighbors = @core.GraphReadable::neighbors(graph, @core.NodeId(ui))
    for neighbor in neighbors {
      let vi = neighbor.0
      if vi > ui && vi >= 0 && vi < n {
        let c = find_common_free_color(ec, k, ui, vi)
        if c >= 0 {
          ec[ui][vi] = Some(c)
          ec[vi][ui] = Some(c)
        } else {
          ec[ui][vi] = Some(k + 1)
          ec[vi][ui] = Some(k + 1)
        }
      }
    }
    ui = ui + 1
  }
  let num_c = count_used_colors(ec)
  let valid = validate_edge_coloring(graph, ec)
  EdgeColoringResult::{
    edge_colors: ec,
    num_colors: num_c,
    max_degree: max_deg,
    is_valid: valid,
  }
}
