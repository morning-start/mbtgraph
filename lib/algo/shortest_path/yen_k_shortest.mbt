///|
/// Yen's K 最短路径算法
///
/// 在非负权图中找到从 source 到 target 的 K 条最短路径（允许重复节点）。
/// 时间复杂度 O(K * V * (E + V) log V)。
///
/// # 算法原理
///
/// 1. 使用 Dijkstra 找到第 1 条最短路径
/// 2. 对每条已找到的路径，尝试在每个节点处偏离产生候选路径
/// 3. 用最小堆管理候选路径，每次取最优
/// 4. 重复直到找到 K 条路径或无更多候选

// ============================================================================
// 候选路径类型（用于最小堆）
// ============================================================================

///|
/// 候选路径（存储在堆中）
priv struct Candidate {
  path : Array[@core.NodeId]
  cost : Double
}

// ============================================================================
// 堆操作（复用 dijkstra 的堆结构）
// ============================================================================

///|
/// 候选路径堆
priv struct CandidateHeap {
  mut data : Array[Candidate]
}

///|
fn cand_heap_new() -> CandidateHeap {
  CandidateHeap::{ data: [] }
}

///|
fn cand_heap_push(h : CandidateHeap, candidate : Candidate) -> CandidateHeap {
  let hh = h
  hh.data.push(candidate)
  cand_heap_sift_up(hh, hh.data.length() - 1)
  hh
}

///|
fn cand_heap_pop(h : CandidateHeap) -> (CandidateHeap, Candidate?) {
  let hh = h
  if hh.data.length() == 0 {
    return (hh, None)
  }
  let top = hh.data[0]
  let last_idx = hh.data.length() - 1
  hh.data[0] = hh.data[last_idx]
  hh.data = array_cand_pop_last(hh.data)
  if hh.data.length() > 0 {
    cand_heap_sift_down(hh, 0)
  }
  (hh, Some(top))
}

///|
fn cand_heap_is_empty(h : CandidateHeap) -> Bool {
  h.data.length() == 0
}

///|
fn cand_heap_sift_up(h : CandidateHeap, idx : Int) -> Unit {
  let mut i = idx
  while i > 0 {
    let parent = (i - 1) / 2
    if h.data[i].cost < h.data[parent].cost {
      let tmp = h.data[i]
      h.data[i] = h.data[parent]
      h.data[parent] = tmp
      i = parent
    } else {
      break
    }
  }
}

///|
fn cand_heap_sift_down(h : CandidateHeap, idx : Int) -> Unit {
  let mut i = idx
  let n = h.data.length()
  while true {
    let left = 2 * i + 1
    let right = 2 * i + 2
    let mut smallest = i
    if left < n && h.data[left].cost < h.data[smallest].cost {
      smallest = left
    }
    if right < n && h.data[right].cost < h.data[smallest].cost {
      smallest = right
    }
    if smallest != i {
      let tmp = h.data[i]
      h.data[i] = h.data[smallest]
      h.data[smallest] = tmp
      i = smallest
    } else {
      break
    }
  }
}

///|
fn[T] array_cand_pop_last(arr : Array[T]) -> Array[T] {
  let result : Array[T] = []
  let mut i = 0
  let len = arr.length() - 1
  while i < len {
    result.push(arr[i])
    i = i + 1
  }
  result
}

// ============================================================================
// 辅助函数：带禁止边的 Dijkstra
// ============================================================================

///|
/// 禁止边集合
priv struct ForbiddenEdges {
  edges : Array[(@core.NodeId, @core.NodeId)]
}

///|
fn forbidden_new() -> ForbiddenEdges {
  ForbiddenEdges::{ edges: [] }
}

///|
fn forbidden_add(
  fe : ForbiddenEdges,
  from : @core.NodeId,
  to : @core.NodeId,
) -> ForbiddenEdges {
  let f = fe
  f.edges.push((from, to))
  f
}

///|
fn forbidden_contains(
  fe : ForbiddenEdges,
  from : @core.NodeId,
  to : @core.NodeId,
) -> Bool {
  let mut found = false
  for e in fe.edges {
    match e {
      (u, v) => if u == from && v == to { found = true }
    }
  }
  found
}

///|
/// 带禁止边的 Dijkstra（从 spur_node 到 target）
fn[G : @core.GraphReadable] dijkstra_with_forbidden(
  graph : G,
  spur_node : @core.NodeId,
  target : @core.NodeId,
  forbidden : ForbiddenEdges,
) -> (Array[@core.NodeId], Double) {
  if spur_node == target && @core.GraphReadable::contains_node(graph, spur_node) {
    return ([spur_node], 0.0)
  }
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 ||
    !@core.GraphReadable::contains_node(graph, spur_node) ||
    !@core.GraphReadable::contains_node(graph, target) {
    return ([], -1.0)
  }
  let max_id = sp_find_max_id(graph)
  let size = Int::max(max_id + 1, 1)
  let inf = 1000000000000000000.0
  let distances : Array[Double?] = Array::make(size, None)
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  distances[spur_node.0] = Some(0.0)
  let mut pq = heap_new()
  pq = heap_push(pq, 0.0, spur_node)
  let visited : Array[Bool] = Array::make(size, false)
  let mut found_target = false
  while !heap_is_empty(pq) && !found_target {
    let (pq_next, top_opt) = heap_pop(pq)
    pq = pq_next
    match top_opt {
      Some((u, _)) => {
        let uid = u.0
        if visited[uid] {
          continue
        }
        visited[uid] = true
        if u == target {
          found_target = true
        }
        for vw in @core.GraphReadable::neighbors_with_weight(graph, u) {
          match vw {
            (v, weight) => {
              let vid = v.0
              if vid < 0 || vid >= size || visited[vid] {
                continue
              }
              if forbidden_contains(forbidden, u, v) {
                continue
              }
              let ud = match distances[uid] {
                None => continue
                Some(d) => d
              }
              let new_dist = ud + weight
              let should_update = match distances[vid] {
                None => true
                Some(d) => new_dist < d
              }
              if should_update {
                distances[vid] = Some(new_dist)
                parents[vid] = Some(u)
                pq = heap_push(pq, new_dist, v)
              }
            }
          }
        }
      }
      None => ()
    }
  }
  match distances[target.0] {
    None => ([], -1.0)
    Some(dist) => {
      let path : Array[@core.NodeId] = []
      let mut cur = target
      let mut done = false
      while !done {
        path.push(cur)
        let cidx = cur.0
        if cidx < 0 || cidx >= parents.length() {
          done = true
        } else {
          match parents[cidx] {
            None => done = true
            Some(p) => cur = p
          }
        }
      }
      let rev : Array[@core.NodeId] = []
      let mut j = path.length() - 1
      while j >= 0 {
        rev.push(path[j])
        j = j - 1
      }
      (rev, dist)
    }
  }
}

// ============================================================================
// 路径操作辅助函数
// ============================================================================

///|
/// 检查两条路径的前 length 个节点是否相同
fn paths_prefix_equal(
  path1 : Array[@core.NodeId],
  path2 : Array[@core.NodeId],
  length : Int,
) -> Bool {
  if path1.length() < length || path2.length() < length {
    return false
  }
  let mut i = 0
  while i < length {
    if path1[i] != path2[i] {
      return false
    }
    i = i + 1
  }
  true
}

///|
/// 计算路径的总权重
fn[G : @core.GraphReadable] compute_path_cost(
  graph : G,
  path : Array[@core.NodeId],
) -> Double {
  if path.length() <= 1 {
    return 0.0
  }
  let mut total = 0.0
  let mut i = 0
  while i < path.length() - 1 {
    match @core.GraphReadable::get_edge(graph, path[i], path[i + 1]) {
      Some(w) => total = total + w
      None => return -1.0
    }
    i = i + 1
  }
  total
}

///|
/// 拼接两个路径（跳过第二个路径的第一个节点以避免重复）
fn concat_paths(
  root : Array[@core.NodeId],
  spur : Array[@core.NodeId],
) -> Array[@core.NodeId] {
  let result : Array[@core.NodeId] = []
  for node in root {
    result.push(node)
  }
  let mut i = 1
  while i < spur.length() {
    result.push(spur[i])
    i = i + 1
  }
  result
}

///|
/// 深拷贝路径数组
fn deep_copy_path(path : Array[@core.NodeId]) -> Array[@core.NodeId] {
  let copy : Array[@core.NodeId] = []
  for node in path {
    copy.push(node)
  }
  copy
}

///|
/// 检查路径是否已在结果列表中（避免重复）
fn path_exists_in_list(
  path : Array[@core.NodeId],
  paths : Array[Array[@core.NodeId]],
) -> Bool {
  let mut exists = false
  for existing in paths {
    if path_equal(path, existing) {
      exists = true
    }
  }
  exists
}

///|
/// 比较两条路径是否完全相同
fn path_equal(path1 : Array[@core.NodeId], path2 : Array[@core.NodeId]) -> Bool {
  if path1.length() != path2.length() {
    return false
  }
  let mut i = 0
  while i < path1.length() {
    if path1[i] != path2[i] {
      return false
    }
    i = i + 1
  }
  true
}

// ============================================================================
// 主算法：Yen's K 最短路径
// ============================================================================

///|
/// Yen's K 最短路径算法
///
/// 在非负权图中找到从 source 到 target 的 K 条最短路径。
///
/// # 参数
///
/// - `graph`: 图（实现 GraphReadable trait）
/// - `source`: 源节点
/// - `target`: 目标节点
/// - `k`: 需要找到的最短路径数量
///
/// # 返回
///
/// - `Ok(KShortestPathsResult)`: 包含最多 K 条最短路径
/// - `Err(String)`: 错误信息（k <= 0 或源/目标不存在）
pub fn[G : @core.GraphReadable] yen_k_shortest_paths(
  graph : G,
  source : @core.NodeId,
  target : @core.NodeId,
  k : Int,
) -> Result[KShortestPathsResult, String] {
  // 参数验证
  if k <= 0 {
    return Err("K must be a positive integer")
  }
  if !@core.GraphReadable::contains_node(graph, source) {
    return Err("Source node not found in graph")
  }
  if !@core.GraphReadable::contains_node(graph, target) {
    return Err("Target node not found in graph")
  }

  // 第 1 步：使用 Dijkstra 找到第 1 条最短路径
  let first_path = dijkstra_targeted(graph, source, target)

  // 如果没有路径，返回空结果
  if first_path.length() == 0 {
    return Ok(KShortestPathsResult::{ paths: [], distances: [], k: 0 })
  }

  // 初始化结果列表
  let result_paths : Array[Array[@core.NodeId]] = []
  result_paths.push(deep_copy_path(first_path))
  let first_cost = compute_path_cost(graph, first_path)
  let result_distances : Array[Double] = [first_cost]

  // 初始化候选堆
  let mut candidates = cand_heap_new()

  // 主循环：寻找第 2 到第 K 条最短路径
  let mut loop_k = 1
  while loop_k < k {
    let prev_path = result_paths[loop_k - 1]

    // 对前一条路径的每个偏离点（除了目标节点）
    let mut spur_idx = 0
    while spur_idx < prev_path.length() - 1 {
      let spur_node = prev_path[spur_idx]

      // 根路径：从 source 到 spur_node
      let root_path : Array[@core.NodeId] = []
      let mut i = 0
      while i <= spur_idx {
        root_path.push(prev_path[i])
        i = i + 1
      }

      // 初始化禁止边集合
      let mut forbidden = forbidden_new()

      // 对于之前找到的每条路径，如果与根路径前缀相同，则禁止下一条边
      let mut path_idx = 0
      while path_idx < loop_k {
        let p = result_paths[path_idx]
        if paths_prefix_equal(p, prev_path, spur_idx + 1) {
          let from = p[spur_idx]
          let to = p[spur_idx + 1]
          forbidden = forbidden_add(forbidden, from, to)
        }
        path_idx = path_idx + 1
      }

      // 从 spur_node 到 target 运行带禁止边的 Dijkstra
      let (spur_path, spur_cost) = dijkstra_with_forbidden(
        graph, spur_node, target, forbidden,
      )

      // 如果找到了绕行路径
      if spur_path.length() > 0 && spur_cost >= 0.0 {
        // 拼接根路径和绕行路径
        let total_path = concat_paths(root_path, spur_path)
        let total_cost = compute_path_cost(graph, total_path)

        // 检查是否已存在（避免重复）
        if !path_exists_in_list(total_path, result_paths) {
          let cand = Candidate::{ path: total_path, cost: total_cost }
          candidates = cand_heap_push(candidates, cand)
        }
      }

      spur_idx = spur_idx + 1
    }

    // 从候选堆中取出最优路径
    if cand_heap_is_empty(candidates) {
      break
    }
    let (candidates_next, best_opt) = cand_heap_pop(candidates)
    candidates = candidates_next
    match best_opt {
      Some(best) => {
        result_paths.push(deep_copy_path(best.path))
        result_distances.push(best.cost)
      }
      None => break
    }

    loop_k = loop_k + 1
  }

  Ok(KShortestPathsResult::{
    paths: result_paths,
    distances: result_distances,
    k: result_paths.length(),
  })
}
