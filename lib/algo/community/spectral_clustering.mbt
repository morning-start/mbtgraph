/// 谱聚类 (Spectral Clustering)
///
/// 使用图拉普拉斯的特征向量进行聚类。
/// 基于 Luna-Flow/linear-algebra 的特征分解。

///|
/// 谱聚类
///
/// 将图节点划分为 k 个簇。
/// 使用非归一化拉普拉斯 L = D - A 的特征向量。
pub fn[G : @core.GraphReadable] spectral_clustering(
  graph : G,
  k : Int,
) -> CommunityResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return CommunityResult::{ labels: [], modularity: 0.0, num_communities: 0, levels: 0 }
  }
  if n == 1 || k <= 1 {
    return CommunityResult::{ labels: Array::make(n, 0), modularity: 0.0, num_communities: 1, levels: 1 }
  }
  if k > n {
    return spectral_clustering(graph, n)
  }

  // 构建邻接矩阵 A
  let adj = build_adjacency_matrix(graph, n)
  // L = D - A
  let laplacian = build_laplacian(adj, n)

  // 特征分解 (eigenvalues, eigenvectors)
  // eigenvectors 的列是对应特征向量
  let (eigenvalues, eigenvectors) = laplacian.eigen()

  // 将 (eigenvalue, column_index) 配对并按特征值排序
  let indexed : Array[(Double, Int)] = []
  let mut i = 0
  while i < n {
    indexed.push((eigenvalues[i], i))
    i = i + 1
  }
  indexed.sort()

  // 取 k 个最小特征值对应的特征向量 (跳过 trivial eigenvector)
  // 如果 k >= n, 取 n-1
  let n_components = if k < n { k } else { n - 1 }

  // 构建 n x n_components 矩阵 U，每行对应一个节点
  let u_matrix = build_u_matrix(eigenvectors, indexed, n, n_components)

  // 在 U 的行上运行 k-means
  let labels = k_means(u_matrix, n, n_components, k)

  // 重新标记社区
  let relabeled = relabel_communities(labels, n)
  let num_comms = count_unique_comms(relabeled, n)

  CommunityResult::{ labels: relabeled, modularity: 0.0, num_communities: num_comms, levels: 1 }
}

///|
/// 构建邻接矩阵 A
fn[G : @core.GraphReadable] build_adjacency_matrix(graph : G, n : Int) -> @la.Matrix[Double] {
  let a = @la.Matrix::new(n, n, 0.0)
  let mut u = 0
  while u < n {
    for v in @core.GraphReadable::neighbors(graph, @core.NodeId(u)) {
      let vi = v.0
      if vi != u {
        a.set(u, vi, 1.0)
        a.set(vi, u, 1.0)
      }
    }
    u = u + 1
  }
  a
}

///|
/// 构建拉普拉斯矩阵 L = D - A
fn build_laplacian(a : @la.Matrix[Double], n : Int) -> @la.Matrix[Double] {
  let l = @la.Matrix::new(n, n, 0.0)
  let mut i = 0
  while i < n {
    let mut deg = 0.0
    let mut j = 0
    while j < n {
      if a.get(i, j) > 0.0 {
        deg = deg + a.get(i, j)
        l.set(i, j, -a.get(i, j))
      }
      j = j + 1
    }
    l.set(i, i, deg)
    i = i + 1
  }
  l
}

///|
/// 构建 U 矩阵: n x n_components 的特征向量矩阵
/// 每行是节点在特征空间中的表示
fn build_u_matrix(
  eigenvectors : @la.Matrix[Double],
  sorted : Array[(Double, Int)],
  n : Int,
  n_components : Int,
) -> @la.Matrix[Double] {
  let u = @la.Matrix::new(n, n_components, 0.0)
  let mut c = 0
  while c < n_components {
    let col_idx = sorted[c].1
    let mut r = 0
    while r < n {
      let val = eigenvectors.get(r, col_idx)
      u.set(r, c, val)
      r = r + 1
    }
    c = c + 1
  }
  u
}

///|
/// K-Means 聚类
///
/// 对 n 个 d 维向量进行 k 个簇的划分
fn k_means(
  data : @la.Matrix[Double],
  n : Int,
  d : Int,
  k : Int,
) -> Array[Int] {
  let labels : Array[Int] = Array::make(n, 0)
  if k <= 0 { return labels }
  if k == 1 {
    let mut i = 0
    while i < n {
      labels[i] = 0
      i = i + 1
    }
    return labels
  }

  // 初始化质心: 使用前 k 个点
  let centroids : @la.Matrix[Double] = @la.Matrix::new(k, d, 0.0)
  let mut ci = 0
  while ci < k && ci < n {
    let mut dj = 0
    while dj < d {
      centroids.set(ci, dj, data.get(ci, dj))
      dj = dj + 1
    }
    ci = ci + 1
  }

  let max_iters = 50
  let mut iter = 0
  while iter < max_iters {
    let mut changed = false
    let mut pi = 0
    while pi < n {
      let mut best_c = 0
      let mut best_dist = -1.0
      let mut cj = 0
      while cj < k {
        let mut dist = 0.0
        let mut dim = 0
        while dim < d {
          let diff = data.get(pi, dim) - centroids.get(cj, dim)
          dist = dist + diff * diff
          dim = dim + 1
        }
        if best_dist < 0.0 || dist < best_dist {
          best_dist = dist
          best_c = cj
        }
        cj = cj + 1
      }
      if labels[pi] != best_c {
        changed = true
        labels[pi] = best_c
      }
      pi = pi + 1
    }

    if !changed {
      break
    }

    // 更新步骤
    let counts : Array[Int] = Array::make(k, 0)
    let sums : @la.Matrix[Double] = @la.Matrix::new(k, d, 0.0)
    let mut pi2 = 0
    while pi2 < n {
      let cl = labels[pi2]
      counts[cl] = counts[cl] + 1
      let mut dim = 0
      while dim < d {
        let cur = sums.get(cl, dim) + data.get(pi2, dim)
        sums.set(cl, dim, cur)
        dim = dim + 1
      }
      pi2 = pi2 + 1
    }

    let mut ck = 0
    while ck < k {
      if counts[ck] > 0 {
        let mut dim = 0
        while dim < d {
          centroids.set(ck, dim, sums.get(ck, dim) / counts[ck].to_double())
          dim = dim + 1
        }
      }
      ck = ck + 1
    }

    iter = iter + 1
  }

  labels
}
