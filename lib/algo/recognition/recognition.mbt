/// 特殊图识别模块
///
/// 提供二分图、完全图、正则图、弦图、树、森林等图性质的判定。
/// 所有判定统一返回 Bool。

// ============================================================================
// 二分图判定
// ============================================================================

///|
/// 二分图判定
///
/// 使用 BFS 进行 2-染色。若图中存在奇环则返回 false。
///
/// 复杂度: O(V + E)
pub fn[G : @core.GraphReadable] is_bipartite(g : G) -> Bool {
  let n = @core.GraphReadable::node_count(g)
  if n <= 1 {
    return true
  }
  let color : Array[Int] = Array::make(n, -1)
  for start in @core.GraphReadable::node_ids(g) {
    if color[start.0] >= 0 {
      continue
    }
    color[start.0] = 0
    let queue : Array[@core.NodeId] = Array::make(n, @core.NodeId(0))
    let mut head = 0
    let mut tail = 0
    queue[tail] = start
    tail = tail + 1
    while head < tail {
      let cur = queue[head]
      head = head + 1
      for nxt in @core.GraphReadable::neighbors(g, cur) {
        if color[nxt.0] < 0 {
          color[nxt.0] = 1 - color[cur.0]
          queue[tail] = nxt
          tail = tail + 1
        } else if color[nxt.0] == color[cur.0] {
          return false
        }
      }
    }
  }
  true
}

// ============================================================================
// 完全图判定
// ============================================================================

///|
/// 完全图判定
///
/// 检查是否所有不同节点对之间都有边。
///
/// 复杂度: O(V²)
pub fn[G : @core.GraphReadable] is_complete(g : G) -> Bool {
  let n = @core.GraphReadable::node_count(g)
  if n <= 1 {
    return true
  }
  let nodes : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(g) {
    nodes.push(nid)
  }
  let mut i = 0
  while i < nodes.length() {
    let mut j = i + 1
    while j < nodes.length() {
      if !@core.GraphReadable::contains_edge(g, nodes[i], nodes[j]) {
        return false
      }
      j = j + 1
    }
    i = i + 1
  }
  true
}

// ============================================================================
// 正则图判定
// ============================================================================

///|
/// 正则图判定
///
/// 检查所有节点的度数是否相同。
///
/// 复杂度: O(V)
pub fn[G : @core.GraphReadable] is_regular(g : G) -> Bool {
  let mut deg : Int? = None
  for nid in @core.GraphReadable::node_ids(g) {
    let d = @core.GraphReadable::degree(g, nid)
    match deg {
      Some(d0) => if d != d0 { return false }
      None => deg = Some(d)
    }
  }
  true
}

// ============================================================================
// 树与森林判定
// ============================================================================

///|
/// 树判定
///
/// 无边图不是树。树是无环连通图，满足 |E| = |V| - 1。
///
/// 复杂度: O(V + E)
pub fn[G : @core.GraphReadable] is_tree(g : G) -> Bool {
  let n = @core.GraphReadable::node_count(g)
  if n <= 0 {
    return false
  }
  if n == 1 {
    return @core.GraphReadable::edge_count(g) == 0
  }
  if @core.GraphReadable::edge_count(g) != n - 1 {
    return false
  }
  // 检查连通性
  let visited : Array[Bool] = Array::make(n, false)
  let nodes : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(g) {
    nodes.push(nid)
  }
  if nodes.length() == 0 {
    return false
  }
  let queue : Array[@core.NodeId] = Array::make(n, @core.NodeId(0))
  let mut head = 0
  let mut tail = 0
  queue[tail] = nodes[0]
  tail = tail + 1
  visited[nodes[0].0] = true
  let mut count = 1
  while head < tail {
    let cur = queue[head]
    head = head + 1
    for nxt in @core.GraphReadable::neighbors(g, cur) {
      if !visited[nxt.0] {
        visited[nxt.0] = true
        queue[tail] = nxt
        tail = tail + 1
        count = count + 1
      }
    }
  }
  count == n
}

///|
/// 森林判定
///
/// 森林是无环图。检查每个连通分量是否满足 |E| < |V|。
///
/// 复杂度: O(V + E)
pub fn[G : @core.GraphReadable] is_forest(g : G) -> Bool {
  let n = @core.GraphReadable::node_count(g)
  if n <= 0 {
    return true
  }
  let visited : Array[Bool] = Array::make(n, false)
  for start in @core.GraphReadable::node_ids(g) {
    if visited[start.0] {
      continue
    }
    // BFS 统计该分量的节点数和边数
    let queue : Array[@core.NodeId] = Array::make(n, @core.NodeId(0))
    let mut head = 0
    let mut tail = 0
    queue[tail] = start
    tail = tail + 1
    visited[start.0] = true
    let mut verts = 1
    let mut edges = 0
    while head < tail {
      let cur = queue[head]
      head = head + 1
      for nxt in @core.GraphReadable::neighbors(g, cur) {
        edges = edges + 1
        if !visited[nxt.0] {
          visited[nxt.0] = true
          queue[tail] = nxt
          tail = tail + 1
          verts = verts + 1
        }
      }
    }
    // 每个分量: 无向边统计了两次 (cur -> nxt 和 nxt -> cur)
    edges = edges / 2
    if edges >= verts {
      return false
    }
  }
  true
}

// ============================================================================
// 弦图判定
// ============================================================================

///|
/// 弦图判定
///
/// 使用 Maximum Cardinality Search (MCS) 生成排序，
/// 然后验证是否为完美消除序 (PEO)。
///
/// 复杂度: O(V + E)
pub fn[G : @core.GraphReadable] is_chordal(g : G) -> Bool {
  let n = @core.GraphReadable::node_count(g)
  if n <= 2 {
    return true
  }
  let peo = mcs_ordering(g)
  check_peo(g, peo, n)
}

///|
/// Maximum Cardinality Search 排序
///
/// 从任意顶点开始，每次选择与已选集合邻接最多的未选顶点。
fn[G : @core.GraphReadable] mcs_ordering(g : G) -> Array[@core.NodeId] {
  let n = @core.GraphReadable::node_count(g)
  let nodes : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(g) {
    nodes.push(nid)
  }
  let order : Array[@core.NodeId] = Array::make(n, @core.NodeId(0))
  let weight : Array[Int] = Array::make(n, 0)
  let used : Array[Bool] = Array::make(n, false)
  let mut idx = n - 1
  while idx >= 0 {
    // 选权重最大的未用节点
    let mut sel = -1
    let mut max_w = -1
    for nid in nodes {
      if !used[nid.0] && weight[nid.0] > max_w {
        max_w = weight[nid.0]
        sel = nid.0
      }
    }
    if sel < 0 {
      break
    }
    let sel_id = @core.NodeId(sel)
    order[idx] = sel_id
    used[sel] = true
    idx = idx - 1
    // 更新邻居权重
    for nxt in @core.GraphReadable::neighbors(g, sel_id) {
      if !used[nxt.0] {
        weight[nxt.0] = weight[nxt.0] + 1
      }
    }
  }
  order
}

///|
/// 验证完美消除序 (PEO)
///
/// 对每个 v，检查 v 的后续邻居集合是否构成团。
fn[G : @core.GraphReadable] check_peo(
  g : G,
  order : Array[@core.NodeId],
  n : Int,
) -> Bool {
  // 记录每个节点的位置
  let pos : Array[Int] = Array::make(n, -1)
  let mut i = 0
  while i < n {
    pos[order[i].0] = i
    i = i + 1
  }
  // 对每个节点 v
  for v in order {
    let v_pos = pos[v.0]
    // 收集 v 的后续邻居（在 PEO 中排在后继的邻居）
    let later : Array[@core.NodeId] = []
    for nxt in @core.GraphReadable::neighbors(g, v) {
      if pos[nxt.0] > v_pos {
        later.push(nxt)
      }
    }
    // 如果后续邻居少于 2 个，无需检查
    if later.length() < 2 {
      continue
    }
    // 取第一个后续邻居作为基准
    let first = later[0]
    // 检查是否所有后续邻居都与 first 相邻
    let mut j = 1
    while j < later.length() {
      if !@core.GraphReadable::contains_edge(g, first, later[j]) {
        return false
      }
      j = j + 1
    }
  }
  true
}

// ============================================================================
// Havel-Hakimi 算法
// ============================================================================

///|
/// Havel-Hakimi 算法：判断非增序列是否为可图化序列
///
/// 即是否存在一个简单图，其度数序列等于给定序列。
///
/// 复杂度: O(V²)
pub fn is_graphic_sequence(seq : Array[Int]) -> Bool {
  let degs : Array[Int] = []
  for d in seq {
    if d < 0 {
      return false
    }
    degs.push(d)
  }
  if degs.length() == 0 {
    return true
  }
  // 重复 Havel-Hakimi 步骤
  while true {
    // 降序排序
    degs.sort()
    let tmp : Array[Int] = []
    let mut i = degs.length() - 1
    while i >= 0 {
      tmp.push(degs[i])
      i = i - 1
    }
    for j in 0..<tmp.length() {
      degs[j] = tmp[j]
    }
    // 去除前导零
    while degs.length() > 0 && degs[0] == 0 {
      degs.remove(0) |> ignore
    }
    if degs.length() == 0 {
      return true
    }
    let d = degs[0]
    if d > degs.length() - 1 {
      return false
    }
    degs.remove(0) |> ignore
    let mut k = 0
    while k < d {
      if degs[k] <= 0 {
        return false
      }
      degs[k] = degs[k] - 1
      k = k + 1
    }
  }
  true
}
