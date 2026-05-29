/// K-Core 分解
///
/// 实现 Batagelj & Zaversnik O(n+m) 算法。
/// 适用于无向图。

///|
/// 辅助: 将邻居收集为 Array[Int]
fn[G : @core.GraphReadable] collect_neighbors(graph : G, node : @core.NodeId) -> Array[Int] {
  let ns : Array[Int] = []
  for n in @core.GraphReadable::neighbors(graph, node) {
    ns.push(n.0)
  }
  ns
}

///|
/// K-Core 分解
///
/// 返回每个节点的 core number。
/// 对于无向图，core number k 表示该节点属于 k-core 但不属于 (k+1)-core。
pub fn[G : @core.GraphReadable] k_core_decomposition(graph : G) -> KCoreResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return KCoreResult::{ core: [] }
  }

  // 计算初始度数并收集邻居
  let deg : Array[Int] = []
  let neighbors_list : Array[Array[Int]] = []
  let mut i = 0
  while i < n {
    let nd = @core.GraphReadable::degree(graph, @core.NodeId(i))
    deg.push(nd)
    neighbors_list.push(collect_neighbors(graph, @core.NodeId(i)))
    i = i + 1
  }

  // 找出最大度数
  let mut max_deg = 0
  let mut j = 0
  while j < n {
    if deg[j] > max_deg {
      max_deg = deg[j]
    }
    j = j + 1
  }

  // bin 排序
  let bin : Array[Int] = []
  let mut d = 0
  while d <= max_deg {
    bin.push(0)
    d = d + 1
  }

  let mut k = 0
  while k < n {
    let dval = deg[k]
    bin[dval] = bin[dval] + 1
    k = k + 1
  }

  // 累积和: bin[d] = 度数 >= d 的节点起始位置
  let mut start = 0
  let mut d2 = 0
  while d2 <= max_deg {
    let cnt = bin[d2]
    bin[d2] = start
    start = start + cnt
    d2 = d2 + 1
  }

  // vert = 按度数排序的节点, pos = 节点在 vert 中的位置
  let vert : Array[Int] = []
  let pos : Array[Int] = []
  let mut p = 0
  while p < n {
    vert.push(0)
    pos.push(0)
    p = p + 1
  }

  let mut v = 0
  while v < n {
    let dval = deg[v]
    pos[v] = bin[dval]
    vert[pos[v]] = v
    bin[dval] = bin[dval] + 1
    v = v + 1
  }

  // 恢复 bin 起始位置
  let mut d3 = max_deg
  while d3 > 0 {
    bin[d3] = bin[d3 - 1]
    d3 = d3 - 1
  }
  bin[0] = 0

  // 核心算法: 按度数递增顺序处理节点
  let core : Array[Int] = []
  let mut c = 0
  while c < n {
    core.push(0)
    c = c + 1
  }

  let mut processed = 0
  while processed < n {
    let node = vert[processed]
    let cur_deg = deg[node]
    core[node] = cur_deg

    let nbrs = neighbors_list[node]
    let mut nb_idx = 0
    while nb_idx < nbrs.length() {
      let nb = nbrs[nb_idx]
      if deg[nb] > cur_deg {
        // 减少邻居的度数并移动到正确的 bin
        let nb_deg = deg[nb]
        let nb_new_deg = nb_deg - 1
        deg[nb] = nb_new_deg

        // 在 vert 数组中交换位置
        let nb_pos = pos[nb]
        let first_of_bin = bin[nb_deg]
        if nb_pos != first_of_bin {
          let other = vert[first_of_bin]
          vert[nb_pos] = other
          pos[other] = nb_pos
          vert[first_of_bin] = nb
          pos[nb] = first_of_bin
        }
        bin[nb_deg] = bin[nb_deg] + 1
      }
      nb_idx = nb_idx + 1
    }
    processed = processed + 1
  }

  KCoreResult::{ core }
}
