///|
/// Edmonds 一般图最大匹配 (Blossom Algorithm / 花算法)
///
/// 处理一般图（非二分图）的最大基数匹配，使用花收缩（blossom contraction）
/// 技术处理奇数环。时间复杂度 O(V³)，空间复杂度 O(V²)。
///
/// ## 参数
/// - `g`: 实现了 GraphReadable 的图结构
///
/// ## 返回
/// MatchingResult 包含匹配边列表和匹配数
pub fn[G : @core.GraphReadable] edmonds_maximum_matching(
  graph : G,
) -> MatchingResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return MatchingResult::{ matching_edges: [], cardinality: 0 }
  }

  // 构建邻接表
  let adj : Array[Array[Int]] = Array::make(n, [])
  let mut init_i = 0
  while init_i < n {
    adj[init_i] = []
    init_i = init_i + 1
  }
  for u_node in @core.GraphReadable::node_ids(graph) {
    let u = u_node.0
    for v_node in @core.GraphReadable::neighbors(graph, u_node) {
      let v = v_node.0
      if u != v {
        adj[u].push(v)
      }
    }
  }

  let match_ : Array[Int] = Array::make(n, -1)
  let mut cardinality = 0

  let mut root = 0
  while root < n {
    if match_[root] == -1 {
      if augment_from(root, n, adj, match_) {
        cardinality = cardinality + 1
      }
    }
    root = root + 1
  }

  // 构建结果
  let visited : Array[Bool] = Array::make(n, false)
  let result_edges : Array[(@core.NodeId, @core.NodeId)] = []
  let mut i = 0
  while i < n {
    if !visited[i] {
      let j = match_[i]
      if j != -1 {
        visited[i] = true
        visited[j] = true
        if i < j {
          result_edges.push((@core.NodeId(i), @core.NodeId(j)))
        } else {
          result_edges.push((@core.NodeId(j), @core.NodeId(i)))
        }
      }
    }
    i = i + 1
  }

  MatchingResult::{ matching_edges: result_edges, cardinality }
}

// ============================================================================
// BFS 增广路搜索
// ============================================================================
// 使用三态标签：
//   label[v] == 0 → 未访问
//   label[v] == 1 → 偶点（S集合，在交替树中距离为偶数）
//   label[v] == 2 → 奇点（T集合，在交替树中距离为奇数）

///|
fn augment_from(
  root : Int,
  n : Int,
  adj : Array[Array[Int]],
  match_ : Array[Int],
) -> Bool {
  let label : Array[Int] = Array::make(n, 0)
  let parent : Array[Int] = Array::make(n, -1)
  let base : Array[Int] = Array::make(n, 0)
  let mut i = 0
  while i < n {
    base[i] = i
    i = i + 1
  }

  let queue : Array[Int] = Array::make(n, 0)
  let mut qh = 0
  let mut qt = 0

  label[root] = 1
  queue[qt] = root
  qt = qt + 1

  while qh != qt {
    let x = queue[qh]
    qh = qh + 1

    let mut j = 0
    while j < adj[x].length() {
      let y = adj[x][j]

      // 在同一花内或通过匹配边到达，跳过
      if base[x] == base[y] {
        j = j + 1
        continue
      }
      if match_[x] == y {
        j = j + 1
        continue
      }

      let by = base[y]

      if label[by] == 0 {
        // y 未访问
        if match_[y] == -1 {
          // 找到增广路
          parent[y] = x
          flip_matching(match_, parent, y)
          return true
        }
        // y 已匹配：y 标记为奇点，其匹配伙伴为偶点
        label[by] = 2
        label[base[match_[y]]] = 1
        parent[y] = x
        queue[qt] = match_[y]
        qt = qt + 1
      } else if label[by] == 1 {
        // 发现花：两个偶点之间有边
        let lca_base = find_lca(x, y, parent, base)

        // 收缩路径 x → lca_base
        contract_blossom(x, lca_base, parent, base, label, queue, qt)
        // 收缩路径 y → lca_base
        contract_blossom(y, lca_base, parent, base, label, queue, qt)
      }
      // label[by] == 2（奇点）：跳过

      j = j + 1
    }
  }

  false
}

// ============================================================================
// LCA（最近公共祖先）
// ============================================================================

///|
/// 在 BFS 树中查找 x 和 y 的最近公共祖先（在基空间中）。
fn find_lca(x : Int, y : Int, parent : Array[Int], base : Array[Int]) -> Int {
  let n = parent.length()
  let mark : Array[Bool] = Array::make(n, false)

  let mut u = x
  while true {
    u = base[u]
    mark[u] = true
    let pu = parent[u]
    if pu == -1 {
      break
    }
    u = pu
  }

  let mut v = y
  while true {
    v = base[v]
    if mark[v] {
      return v
    }
    let pv = parent[v]
    if pv == -1 {
      break
    }
    v = pv
  }

  x
}

// ============================================================================
// 花收缩
// ============================================================================

///|
/// 将路径 v → lca_base 上的节点收缩到 lca_base 中。
/// 路径上标记为奇点的节点变为偶点并入队。
fn contract_blossom(
  v : Int,
  lca_base : Int,
  parent : Array[Int],
  base : Array[Int],
  label : Array[Int],
  queue : Array[Int],
  qt : Int,
) -> Unit {
  // 使用可变本地变量来替代需要重新赋值的参数
  let mut cur = v
  let mut new_qt = qt

  while base[cur] != lca_base {
    // cur 是偶点，其父节点是奇点
    let p = parent[cur]
    if p == -1 {
      break
    }

    // 收缩
    base[cur] = lca_base
    base[p] = lca_base

    // 若奇点变为偶点，加入队列继续探索
    if label[p] == 2 {
      label[p] = 1
      queue[new_qt] = p
      new_qt = new_qt + 1
    }

    // 前进到下一个偶点
    cur = parent[p]
    if cur == -1 {
      break
    }
  }
}

// ============================================================================
// 增广路径翻转
// ============================================================================

///|
/// 沿增广路径从 goal 回溯到根节点，翻转匹配。
/// 增广路径结构：root -> ... -> goal
/// 其中路径上匹配边和未匹配边交替出现。
fn flip_matching(match_ : Array[Int], parent : Array[Int], goal : Int) -> Unit {
  // 路径结构：root = v0 - u1(奇) - v1(偶) - u2(奇) - v2(偶) - ... - goal
  // parent[goal] = 前一个节点(v_k), parent[v_k] = u_k, parent[u_k] = v_{k-1}, ...
  // 翻转后：root 与 v1 匹配, v1 与 v2 匹配, ..., v_k 与 goal 匹配

  let mut cur = goal
  while true {
    let pv = parent[cur]
    if pv == -1 {
      break
    }
    let ppv = parent[pv]
    // 翻转 cur 和 pv 的匹配
    match_[cur] = pv
    match_[pv] = cur
    cur = ppv
    if cur == -1 {
      break
    }
  }
}
