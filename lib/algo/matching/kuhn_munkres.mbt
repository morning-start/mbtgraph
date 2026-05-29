/// Kuhn-Munkres (匈牙利算法加权版)
///
/// 二分图最大权完美匹配，O(n³)。

///|
/// Kuhn-Munkres 结果
pub(all) struct KMMatchingResult {
  /// 匹配数组: matching[i] = j 表示左部节点 i 匹配右部节点 j
  matching : Array[Int]
  /// 匹配总权重
  total_weight : Double
}

///|
/// Kuhn-Munkres 算法 (最大权完美匹配)
///
/// 输入: 完全二分图 K_{n,n} 的权重矩阵 (n x n)
/// 输出: 使总权重最大的完美匹配
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

      if km_dfs(u, visited_x, visited_y, lx, ly, match_y, slack, weights, n, eps) {
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
        if match_y[v] < 0 || km_dfs(match_y[v], visited_x, visited_y, lx, ly, match_y, slack, w, n, eps) {
          match_y[v] = u
          return true
        }
      } else {
        if gap < slack[v] {
          slack[v] = gap
        }
      }
    }
    v = v + 1
  }
  return false
}
