///|
/// 重建 A* 搜索路径
fn a_star_reconstruct_path(
  parents : Array[@core.NodeId?],
  start : @core.NodeId,
  target : @core.NodeId,
) -> Array[@core.NodeId] {
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
        Some(p) => if p == cur { done = true } else { cur = p }
      }
    }
  }
  let rev : Array[@core.NodeId] = []
  let mut j = path.length() - 1
  while j >= 0 {
    rev.push(path[j])
    j = j - 1
  }
  rev
}

///|
/// A* 启发式搜索 — 从 start 到 target 的最短路径
///
/// 使用启发函数 f(n) = g(n) + h(n) 指导搜索方向，
/// 其中 g(n) 是起点到 n 的实际距离，h(n) 是 n 到 target 的估计距离。
/// 当 h(n) 满足可采纳性（不低估），A* 保证找到最优路径。
///
/// ## 参数
/// - `g`: 实现了 GraphReadable 的图结构
/// - `start`: 起点
/// - `target`: 终点
/// - `heuristic`: 启发函数 `|@core.NodeId| -> Double`，估算从给定节点到 target 的距离
///
/// ## 返回
/// 最短路径节点序列（含首尾），不可达返回空数组。
///
/// ## 复杂度
/// 取决于启发函数质量，最优时 O(b^d)，其中 b 是分支因子，d 是最优路径深度
pub fn[G : @core.GraphReadable] a_star(
  g : G,
  start : @core.NodeId,
  target : @core.NodeId,
  heuristic : (@core.NodeId) -> Double,
) -> Array[@core.NodeId] {
  if start == target && @core.GraphReadable::contains_node(g, start) {
    return [start]
  }
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 || !@core.GraphReadable::contains_node(g, start) {
    return []
  }
  let max_id = sp_find_max_id(g)
  let size = max_int(max_id + 1, 1)
  let g_scores : Array[Double?] = Array::make(size, None)
  let parents : Array[@core.NodeId?] = Array::make(size, None)
  g_scores[start.0] = Some(0.0)
  let mut pq = heap_new()
  pq = heap_push(pq, heuristic(start), start)
  let visited : Array[Bool] = Array::make(size, false)
  while !heap_is_empty(pq) {
    let (pq_next, top_opt) = heap_pop(pq)
    pq = pq_next
    match top_opt {
      Some((u, _)) => {
        if u == target {
          return a_star_reconstruct_path(parents, start, target)
        }
        let uid = u.0
        if visited[uid] {
          continue
        }
        visited[uid] = true
        for v in @core.GraphReadable::neighbors(g, u) {
          let vid = v.0
          if vid < 0 || vid >= size || visited[vid] {
            continue
          }
          match @core.GraphReadable::get_edge(g, u, v) {
            Some(weight) => {
              let ug = match g_scores[uid] {
                None => continue
                Some(d) => d
              }
              let new_g = ug + weight
              let should_update = match g_scores[vid] {
                None => true
                Some(d) => new_g < d
              }
              if should_update {
                g_scores[vid] = Some(new_g)
                parents[vid] = Some(u)
                pq = heap_push(pq, new_g + heuristic(v), v)
              }
            }
            None => ()
          }
        }
      }
      None => ()
    }
  }
  []
}
