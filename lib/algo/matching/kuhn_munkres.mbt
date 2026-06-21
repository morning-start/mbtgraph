/// Kuhn-Munkres (匈牙利算法加权版)
///
/// 二分图最大权完美匹配算法，基于 Kuhn（1955）和 Munkres（1957）提出的
/// 顶点标号方法。通过维护可行顶点标号 (feasible vertex labeling) 和相等子图，
/// 在相等子图中寻找增广路来逐步扩展匹配，直至获得完美匹配。
///
/// # 核心思想
///
/// 对于完全二分图 K_{n,n} 的权重矩阵 W，定义可行顶点标号 l(x) 和 l'(y)
/// 满足: l(x) + l'(y) ≥ W[x][y]。在满足等号的边构成的相等子图中寻找匹配。
/// 若无法找到增广路，则调整标号使更多边进入相等子图。
///
/// # 算法流程
///
/// 1. 初始化: l(x) = max_j(W[x][j]), l'(y) = 0
/// 2. 对每个左部节点 x_i，尝试在相等子图中找增广路 (DFS)
/// 3. 若失败，计算松弛量 δ 并调整标号:
///    - l(x) -= δ （对已访问的左部节点）
///    - l'(y) += δ （对已访问的右部节点）
/// 4. 重复步骤 2-3 直到找到增广路
/// 5. 输出匹配及总权重

///|
/// Kuhn-Munkres 结果
pub(all) struct KMMatchingResult {
  /// 匹配数组: matching[i] = j 表示左部节点 i 匹配右部节点 j
  matching : Array[Int]
  /// 匹配总权重
  total_weight : Double
}

///|
/// Kuhn-Munkres 算法 (二分图最大权完美匹配)
///
/// 求解完全二分图 K_{n,n} 的最大权完美匹配问题。
///
/// # 数学形式
///
/// 给定 n × n 权重矩阵 W，求排列 π 使得:
///   max Σ_{i=0}^{n-1} W[i][π(i)]
///
/// 对偶形式 — 可行顶点标号:
///   max Σ_{i} l(x_i) + Σ_{j} l'(y_j)
///   s.t. l(x_i) + l'(y_j) ≥ W[i][j]
///
/// 当 Σ(l(x) + l'(y)) = Σ W[i][π(i)] 时达到最优（互补松弛性）。
///
/// # 参数
///
/// - `weights`: n × n 权重矩阵，weights[i][j] 表示左部节点 i 与右部节点 j
///   之间的边权重。要求 n ≥ 0，空矩阵返回空结果。
///
/// # 返回
///
/// `KMMatchingResult` 包含:
/// - `matching`: 匹配数组，matching[i] = j 表示左部 i 匹配右部 j
/// - `total_weight`: 所有匹配边的权重之和（最优值）
///
/// # 复杂度
///
/// - 时间: O(n³)，每轮增广最多 O(n²)，共 n 轮
/// - 空间: O(n)，用于存储标号数组、匹配数组和访问标记
///
/// # 应用场景
///
/// - 任务分配问题：将 n 个任务分配给 n 个工人，最大化总效率
/// - 二分图最优匹配：任何可建模为完全二分图加权的场景
/// - 组合优化：作为子程序用于更复杂的优化问题
///
/// # 注意事项
///
/// - 输入应为方阵（n × n），非方阵行为未定义
/// - 支持负权重边（算法自动处理）
/// - 时间复杂度对 n > 1000 可能较慢，大规模场景建议用 Jonker-Volgenant 算法
pub fn kuhn_munkres(weights : Array[Array[Double]]) -> KMMatchingResult {
  let n = weights.length()
  if n == 0 {
    return KMMatchingResult::{ matching: [], total_weight: 0.0 }
  }

  let lx : Array[Double] = Array::make(n, 0.0)
  let ly : Array[Double] = Array::make(n, 0.0)
  let match_y : Array[Int] = Array::make(n, -1)
  let eps = 1.0e-9

  let mut i = 0
  while i < n {
    let mut max_w = -1.0e100
    let mut j = 0
    while j < n {
      let w_val = weights[i][j]
      if w_val > max_w {
        max_w = w_val
      }
      j = j + 1
    }
    lx[i] = max_w
    i = i + 1
  }

  let mut u = 0
  while u < n {
    while true {
      let visited_x : Array[Bool] = Array::make(n, false)
      let visited_y : Array[Bool] = Array::make(n, false)
      let slack : Array[Double] = Array::make(n, 1.0e100)

      if km_dfs(
          u, visited_x, visited_y, lx, ly, match_y, slack, weights, n, eps,
        ) {
        break
      }

      let mut d = 1.0e100
      let mut j = 0
      while j < n {
        if !visited_y[j] && slack[j] < d {
          d = slack[j]
        }
        j = j + 1
      }

      i = 0
      while i < n {
        if visited_x[i] {
          lx[i] = lx[i] - d
        }
        i = i + 1
      }
      j = 0
      while j < n {
        if visited_y[j] {
          ly[j] = ly[j] + d
        }
        j = j + 1
      }
    }
    u = u + 1
  }

  let matching : Array[Int] = Array::make(n, -1)
  let mut total = 0.0
  let mut v = 0
  while v < n {
    if match_y[v] >= 0 {
      matching[match_y[v]] = v
      total = total + weights[match_y[v]][v]
    }
    v = v + 1
  }

  KMMatchingResult::{ matching, total_weight: total }
}

///|
fn km_dfs(
  u : Int,
  visited_x : Array[Bool],
  visited_y : Array[Bool],
  lx : Array[Double],
  ly : Array[Double],
  match_y : Array[Int],
  slack : Array[Double],
  w : Array[Array[Double]],
  n : Int,
  eps : Double,
) -> Bool {
  visited_x[u] = true
  let mut v = 0
  while v < n {
    if !visited_y[v] {
      let gap = lx[u] + ly[v] - w[u][v]
      if gap <= eps {
        visited_y[v] = true
        if match_y[v] < 0 ||
          km_dfs(
            match_y[v],
            visited_x,
            visited_y,
            lx,
            ly,
            match_y,
            slack,
            w,
            n,
            eps,
          ) {
          match_y[v] = u
          return true
        }
      } else if gap < slack[v] {
        slack[v] = gap
      }
    }
    v = v + 1
  }
  return false
}
