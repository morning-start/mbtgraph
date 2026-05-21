///|
/// 无向图欧拉路径/回路判定算法
///
/// 基于欧拉路径定理：
/// - 欧拉回路：所有节点度数为偶数，且图是连通的
/// - 欧拉路径：恰好 0 或 2 个奇度节点，且图是连通的

///|
/// 检查节点的度数奇偶性
///
/// 遍历所有节点统计度数，返回 (奇度节点数, 第一个奇度节点, 第二个奇度节点)
fn[G : @core.GraphReadable] check_degree_parity(g : G) -> (Int, Int?, Int?) {
  let mut odd_count = 0
  let mut first_odd : Int? = None
  let mut second_odd : Int? = None
  for nid in @core.GraphReadable::node_ids(g) {
    let deg = @core.GraphReadable::degree(g, nid)
    if deg % 2 != 0 {
      odd_count = odd_count + 1
      match first_odd {
        None => { first_odd = Some(nid.0) }
        Some(_) => {
          match second_odd {
            None => { second_odd = Some(nid.0) }
            Some(_) => { () |> ignore }
          }
        }
      }
    }
  }
  (odd_count, first_odd, second_odd)
}

///|
/// 检查无向图的连通性（忽略孤立节点）
///
/// 使用 BFS 从第一个非孤立节点开始遍历，
/// 检查所有非孤立节点是否可达
fn[G : @core.GraphReadable] is_connected_undirected(g : G) -> Bool {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return true
  }
  if nc == 1 {
    return true
  }
  let mut start : @core.NodeId? = None
  for nid in @core.GraphReadable::node_ids(g) {
    let deg = @core.GraphReadable::degree(g, nid)
    if deg > 0 {
      start = Some(nid)
      break
    }
  }
  match start {
    None => true
    Some(start_node) => {
      let max_id = find_max_node_id(g)
      let size = Int::max(max_id + 1, 1)
      let visited : Array[Bool] = Array::make(size, false)
      let queue : Array[@core.NodeId] = [start_node]
      visited[start_node.0] = true
      let mut visited_non_isolated = 1
      let mut head = 0
      while head < queue.length() {
        let cur = queue[head]
        head = head + 1
        for nbr in @core.GraphReadable::neighbors(g, cur) {
          if !visited[nbr.0] {
            visited[nbr.0] = true
            queue.push(nbr)
            let nbr_deg = @core.GraphReadable::degree(g, nbr)
            if nbr_deg > 0 {
              visited_non_isolated = visited_non_isolated + 1
            }
          }
        }
      }
      let mut total_non_isolated = 0
      for nid in @core.GraphReadable::node_ids(g) {
        let deg = @core.GraphReadable::degree(g, nid)
        if deg > 0 {
          total_non_isolated = total_non_isolated + 1
        }
      }
      visited_non_isolated == total_non_isolated
    }
  }
}

///|
/// 找到图中最大的节点 ID
fn[G : @core.GraphReadable] find_max_node_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
/// 判断无向图是否存在欧拉路径
///
/// 条件：
/// 1. 图是连通的（忽略孤立节点）
/// 2. 奇度节点数量为 0 或 2
pub fn[G : @core.GraphReadable] has_euler_path_undirected(g : G) -> Bool {
  if !is_connected_undirected(g) {
    return false
  }
  let (odd_count, _, _) = check_degree_parity(g)
  odd_count == 0 || odd_count == 2
}

///|
/// 判断无向图是否存在欧拉回路
///
/// 条件：
/// 1. 图是连通的（忽略孤立节点）
/// 2. 所有节点度数均为偶数（奇度节点数量为 0）
pub fn[G : @core.GraphReadable] has_euler_circuit_undirected(g : G) -> Bool {
  if !is_connected_undirected(g) {
    return false
  }
  let (odd_count, _, _) = check_degree_parity(g)
  odd_count == 0
}
