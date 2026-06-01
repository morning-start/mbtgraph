/// 特殊图识别模块
///
/// 提供二分图、完全图、正则图、弦图、树、森林等图性质的判定。
/// 所有判定统一返回 Bool。

// ============================================================================
// 二分图判定
// ============================================================================

///|
/// 二分图（Bipartite Graph）判定
///
/// 使用 BFS 对图进行 2-染色：从每个未访问节点出发，交替标记 0/1。
/// 若发现相邻节点颜色相同，则存在奇环，返回 false。
/// 空图、单节点图、无环图均为二分图。
///
/// **参数**
/// - `graph`: 实现 GraphReadable trait 的任意图结构
///
/// **返回值**
/// - `true`: 图是二分图（可 2-染色）
/// - `false`: 图不是二分图（含奇环）
///
/// **时间复杂度**: O(V + E)
pub fn[G : @core.GraphReadable] is_bipartite(graph : G) -> Bool {
  let n = @core.GraphReadable::node_count(graph)
  if n <= 1 {
    return true
  }
  let color : Array[Int] = Array::make(n, -1)
  for start in @core.GraphReadable::node_ids(graph) {
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
      for nxt in @core.GraphReadable::neighbors(graph, cur) {
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
/// 完全图（Complete Graph）判定
///
/// 检查图中是否每对不同的节点之间都存在边（无向情形含双向边）。
/// n 个节点的完全图记为 K_n，边数为 n(n-1)/2（无向）或 n(n-1)（有向）。
///
/// **参数**
/// - `graph`: 实现 GraphReadable trait 的任意图结构
///
/// **返回值**
/// - `true`: 图是完全图
/// - `false`: 图不是完全图（存在至少一对无直接连边的节点）
///
/// **时间复杂度**: O(V²)
pub fn[G : @core.GraphReadable] is_complete(graph : G) -> Bool {
  let n = @core.GraphReadable::node_count(graph)
  if n <= 1 {
    return true
  }
  let nodes : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(graph) {
    nodes.push(nid)
  }
  let mut i = 0
  while i < nodes.length() {
    let mut j = i + 1
    while j < nodes.length() {
      if !@core.GraphReadable::contains_edge(graph, nodes[i], nodes[j]) {
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
/// 正则图（Regular Graph）判定
///
/// 检查图中所有节点的度数是否全部相同。
/// k-正则图中每个节点的度数均为 k。完全图 K_n 是 (n-1)-正则图。
///
/// **参数**
/// - `graph`: 实现 GraphReadable trait 的任意图结构
///
/// **返回值**
/// - `true`: 图是正则图（所有节点度数相等）
/// - `false`: 图不是正则图（存在度数不同的节点）
///
/// **时间复杂度**: O(V)
pub fn[G : @core.GraphReadable] is_regular(graph : G) -> Bool {
  let mut deg : Int? = None
  for nid in @core.GraphReadable::node_ids(graph) {
    let d = @core.GraphReadable::degree(graph, nid)
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
/// 树（Tree）判定
///
/// 判定图是否为树：无环连通图，满足 |E| = |V| - 1。
/// 先检查边数条件（快速剪枝），再用 BFS 验证连通性。
/// 空图不是树；单节点无边图为树。
///
/// **参数**
/// - `graph`: 实现 GraphReadable trait 的任意图结构
///
/// **返回值**
/// - `true`: 图是树（无环且连通）
/// - `false`: 图不是树（含环或不连通或为空）
///
/// **时间复杂度**: O(V + E)
pub fn[G : @core.GraphReadable] is_tree(graph : G) -> Bool {
  let n = @core.GraphReadable::node_count(graph)
  if n <= 0 {
    return false
  }
  if n == 1 {
    return @core.GraphReadable::edge_count(graph) == 0
  }
  if @core.GraphReadable::edge_count(graph) != n - 1 {
    return false
  }
  // 检查连通性
  let visited : Array[Bool] = Array::make(n, false)
  let nodes : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(graph) {
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
    for nxt in @core.GraphReadable::neighbors(graph, cur) {
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
/// 森林（Forest）判定
///
/// 判定图是否为森林：无环图（每个连通分量都是树）。
/// 对每个连通分量分别 BFS 统计节点数 V_i 和边数 E_i，
/// 检查是否均满足 E_i < V_i（即不含环）。空图为森林。
///
/// **参数**
/// - `graph`: 实现 GraphReadable trait 的任意图结构
///
/// **返回值**
/// - `true`: 图是森林（无环，可能不连通）
/// - `false`: 图不是森林（至少含一个环）
///
/// **时间复杂度**: O(V + E)
pub fn[G : @core.GraphReadable] is_forest(graph : G) -> Bool {
  let n = @core.GraphReadable::node_count(graph)
  if n <= 0 {
    return true
  }
  let visited : Array[Bool] = Array::make(n, false)
  for start in @core.GraphReadable::node_ids(graph) {
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
      for nxt in @core.GraphReadable::neighbors(graph, cur) {
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
/// 弦图（Chordal Graph）判定
///
/// 使用 Maximum Cardinality Search (MCS) 算法生成节点消除序，
/// 再验证该序是否为完美消除序（Perfect Elimination Ordering, PEO）。
/// 弦图等价于：任意长度 ≥ 4 的环都至少有一条弦（连接环上非相邻节点）。
/// 树、区间图、分裂图均为弦图的子类。
///
/// **参数**
/// - `graph`: 实现 GraphReadable trait 的任意图结构
///
/// **返回值**
/// - `true`: 图是弦图（存在完美消除序）
/// - `false`: 图不是弦图（含无弦环）
///
/// **时间复杂度**: O(V + E)
pub fn[G : @core.GraphReadable] is_chordal(graph : G) -> Bool {
  let n = @core.GraphReadable::node_count(graph)
  if n <= 2 {
    return true
  }
  let peo = mcs_ordering(graph)
  check_peo(graph, peo, n)
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
/// Havel-Hakimi 定理：判断度数序列是否可图化（Graphic Sequence）
///
/// 给定一个非负整数序列，判定是否存在一个简单无向图（无自环、无重边），
/// 使得各节点的度数恰好等于该序列。
///
/// 算法流程：反复取最大度数 d，将其后 d 个元素各减 1，再重新排序，
/// 直到全零（可图化）或出现矛盾（不可图化）。
///
/// **参数**
/// - `seq`: 度数序列（整数数组），无需预先排序
///
/// **返回值**
/// - `true`: 序列是可图化的（存在对应简单图）
/// - `false`: 序列不可图化
///
/// **示例**: [3, 3, 2, 2, 1, 1] → true（对应某简单图）
///          [5, 3, 0, 1] → false（度数和为奇数，必不可图化）
///
/// **时间复杂度**: O(V²)（每轮排序 O(V log V)，共 O(V) 轮）
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
