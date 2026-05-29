/// Stoer-Wagner 全局最小割算法
///
/// O(VE + V² log V)，无向带权图。

///|
/// Stoer-Wagner 结果
pub(all) struct StoerWagnerResult {
  /// 最小割的权重
  min_cut_weight : Double
  /// 割的一侧 (另一侧为补集)
  partition : Array[Int]
}

///|
/// Stoer-Wagner 全局最小割
///
/// 输入: n x n 邻接矩阵 (对称, 无边为 0)
/// 输出: 最小割的权重和划分
pub fn stoer_wagner(adj : Array[Array[Double]]) -> StoerWagnerResult {
  let n = adj.length()
  if n <= 1 {
    return StoerWagnerResult::{ min_cut_weight: 0.0, partition: [] }
  }

  let weights = deep_copy_matrix(adj)
  let vertices : Array[Array[Int]] = Array::make(n, [])
  let mut i = 0
  while i < n {
    vertices[i] = [i]
    i = i + 1
  }

  let mut best_cut = 1.0e100
  let mut best_partition : Array[Int] = []

  let mut phase = n
  while phase > 1 {
    // 最大邻接搜索 (Maximum Adjacency Search)
    let added : Array[Bool] = Array::make(n, false)
    let ws : Array[Double] = Array::make(n, 0.0)
    let mut prev = -1

    let mut iter = 0
    while iter < phase {
      // 选择与已选集合连接最紧密的未选顶点
      let mut sel = -1
      let mut max_w = -1.0
      let mut v = 0
      while v < n {
        if !added[v] && vertices[v].length() > 0 {
          if ws[v] > max_w {
            max_w = ws[v]
            sel = v
          }
        }
        v = v + 1
      }

      if sel < 0 {
        break
      }

      added[sel] = true
      if iter == phase - 1 {
        // 最后加入的顶点
        let cut_weight = ws[sel]
        if cut_weight < best_cut {
          best_cut = cut_weight
          let part : Array[Int] = []
          for x in vertices[sel] {
            part.push(x)
          }
          best_partition = part
        }

        // 合并 sel 和 prev
        if prev >= 0 && sel >= 0 && prev < n && sel < n {
          for x in vertices[sel] {
            vertices[prev].push(x)
          }
          vertices[sel] = []
          // 更新权重组
          let mut j = 0
          while j < n {
            if j != prev && j != sel && vertices[j].length() > 0 {
              let w_sum = weights[sel][j] + weights[prev][j]
              weights[prev][j] = w_sum
              weights[j][prev] = w_sum
            }
            j = j + 1
          }
          weights[prev][prev] = 0.0
          weights[prev][sel] = 0.0
          weights[sel][prev] = 0.0
          weights[sel][sel] = 0.0
        }
        break
      }

      prev = sel

      // 更新权重: 将 sel 的边权加入 ws
      v = 0
      while v < n {
        if !added[v] && vertices[v].length() > 0 {
          ws[v] = ws[v] + weights[sel][v]
        }
        v = v + 1
      }
      iter = iter + 1
    }

    phase = phase - 1
  }

  StoerWagnerResult::{ min_cut_weight: best_cut, partition: best_partition }
}


