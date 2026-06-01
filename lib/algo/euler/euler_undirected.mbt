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
        None => first_odd = Some(nid.0)
        Some(_) =>
          match second_odd {
            None => second_odd = Some(nid.0)
            Some(_) => () |> ignore
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
/// 判定无向图是否存在欧拉路径
///
/// 欧拉路径是指能够访问图中每条边恰好一次的路径。
///
/// **时间复杂度**: O(V + E)，其中 V 为节点数，E 为边数
/// **空间复杂度**: O(V)，用于 BFS 连通性检查和度数统计
///
/// **参数**:
///   - `g`: 无向图（实现 GraphReadable trait）
///
/// **返回值**:
///   - `true`: 存在欧拉路径
///   - `false`: 不存在欧拉路径
///
/// **判定条件**:
///   - 图必须是连通的（孤立节点除外）
///   - 奇度节点的数量必须为 0 或 2
///     - 奇度节点数为 0：存在欧拉回路（也是欧拉路径的特例）
///     - 奇度节点数为 2：存在欧拉路径，起点和终点为这两个奇度节点
///
/// **使用示例**:
/// ```moonbit nocheck
/// let g = create_undirected_graph()
///
/// let g = g.add_edge(0, 1, 1.0) |> ignore
///
/// let g = g.add_edge(1, 2, 1.0) |> ignore
///
/// let g = g.add_edge(2, 3, 1.0) |> ignore
///
/// let g = g.add_edge(3, 0, 1.0) |> ignore
///
/// let result = has_euler_path_undirected(g) // 返回 true（存在欧拉回路）
/// ```
pub fn[G : @core.GraphReadable] has_euler_path_undirected(graph : G) -> Bool {
  if !is_connected_undirected(graph) {
    return false
  }
  let (odd_count, _, _) = check_degree_parity(graph)
  odd_count == 0 || odd_count == 2
}

///|
/// 判定无向图是否存在欧拉回路
///
/// 欧拉回路是指能够访问图中每条边恰好一次并回到起点的闭合路径。
///
/// **时间复杂度**: O(V + E)，其中 V 为节点数，E 为边数
/// **空间复杂度**: O(V)，用于 BFS 连通性检查和度数统计
///
/// **参数**:
///   - `g`: 无向图（实现 GraphReadable trait）
///
/// **返回值**:
///   - `true`: 存在欧拉回路
///   - `false`: 不存在欧拉回路
///
/// **判定条件**:
///   - 图必须是连通的（孤立节点除外）
///   - 所有节点度数均为偶数（奇度节点数量为 0）
///
/// **使用示例**:
/// ```moonbit nocheck
/// let g = create_undirected_graph()
///
/// let g = g.add_edge(0, 1, 1.0) |> ignore
///
/// let g = g.add_edge(1, 2, 1.0) |> ignore
///
/// let g = g.add_edge(2, 0, 1.0) |> ignore
///
/// let result = has_euler_circuit_undirected(g) // 返回 true（三角形存在欧拉回路）
/// ```
pub fn[G : @core.GraphReadable] has_euler_circuit_undirected(graph : G) -> Bool {
  if !is_connected_undirected(graph) {
    return false
  }
  let (odd_count, _, _) = check_degree_parity(graph)
  odd_count == 0
}

// ============================================================================
// Hierholzer 算法 - 欧拉路径/回路查找
// ============================================================================

///|
/// 从 Graph trait 构建内部邻接表（带边索引）
///
/// 邻接表格式: Array[Array[(neighbor_node_id, edge_index)]>
/// 无向图需要双向添加边，但每条物理边只有一个索引
///
/// 返回: (邻接表, 边总数, Edge 对象数组)
fn[G : @core.GraphReadable] build_adjacency_with_edges(
  g : G,
) -> (Array[Array[(Int, Int)]], Int, Array[@core.Edge]) {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return ([], 0, [])
  }
  let max_id = find_max_node_id(g)
  let size = Int::max(max_id + 1, 1)
  let adj : Array[Array[(Int, Int)]] = Array::make(size, [])
  let edges : Array[@core.Edge] = []
  let mut edge_index = 0
  for nid in @core.GraphReadable::node_ids(g) {
    for nbr in @core.GraphReadable::neighbors(g, nid) {
      if nbr.0 > nid.0 {
        let weight_opt = @core.GraphReadable::get_edge(g, nid, nbr)
        let weight = match weight_opt {
          Some(w) => w
          None => 0.0
        }
        let edge = @core.Edge::{ from: nid, to: nbr, data: weight }
        adj[nid.0].push((nbr.0, edge_index))
        adj[nbr.0].push((nid.0, edge_index))
        edges.push(edge)
        edge_index = edge_index + 1
      } else {
        ()
      }
    }
  }
  (adj, edge_index, edges)
}

///|
/// 找到第一个度数 > 0 的节点作为起始点
fn[G : @core.GraphReadable] find_first_non_isolated(g : G) -> Int {
  for nid in @core.GraphReadable::node_ids(g) {
    let deg = @core.GraphReadable::degree(g, nid)
    if deg > 0 {
      return nid.0
    } else {
      ()
    }
  }
  0
}

///|
/// Hierholzer 核心算法实现（无向图）
///
/// 使用栈模拟递归避免栈溢出
/// 栈元素类型: (current_node, next_edge_index_to_try)
/// 返回边索引序列（需要反转）
fn hierholzer_undirected_full(
  adj : Array[Array[(Int, Int)]],
  edge_count : Int,
  start_node : Int,
) -> Array[Int] {
  if edge_count == 0 {
    return []
  }
  let visited : Array[Bool] = Array::make(edge_count, false)
  let mut stack : Array[(Int, Int)] = [(start_node, 0)]
  let path : Array[Int] = []
  while stack.length() > 0 {
    let top_idx = stack.length() - 1
    let (cur_node, edge_pos) = stack[top_idx]
    if edge_pos < adj[cur_node].length() {
      let (next_node, edge_idx) = adj[cur_node][edge_pos]
      stack[top_idx] = (cur_node, edge_pos + 1)
      if !visited[edge_idx] {
        visited[edge_idx] = true
        stack.push((next_node, 0))
      } else {
        ()
      }
    } else {
      let new_stack : Array[(Int, Int)] = []
      let mut i = 0
      while i < top_idx {
        new_stack.push(stack[i])
        i = i + 1
      }
      stack = new_stack
      if top_idx > 0 {
        let new_top_idx = top_idx - 1
        let (_, prev_edge_pos) = stack[new_top_idx]
        if prev_edge_pos > 0 {
          let (prev_node, _) = stack[new_top_idx]
          let actual_edge_idx = adj[prev_node][prev_edge_pos - 1].1
          path.push(actual_edge_idx)
        } else {
          ()
        }
      } else {
        ()
      }
    }
  }
  let result : Array[Int] = []
  let mut i = path.length() - 1
  while i >= 0 {
    result.push(path[i])
    i = i - 1
  }
  result
}

///|
/// 查找无向图的欧拉路径
///
/// 先检查存在性，再使用 Hierholzer 算法查找具体路径。
/// 如果存在欧拉路径但不存在欧拉回路（即有 2 个奇度节点），
/// 路径从第一个奇度节点开始，到第二个奇度节点结束。
///
/// **时间复杂度**: O(E)，其中 E 为边数（Hierholzer 算法）
/// **空间复杂度**: O(E)，用于存储邻接表和路径
///
/// **参数**:
///   - `g`: 无向图（实现 GraphReadable trait）
///
/// **返回值**:
///   - `EulerPathResult`:
///     - `exists`: 是否存在欧拉路径
///     - `path`: 欧拉路径的边序列（按遍历顺序）
///     - `start_node`: 路径起点（存在时有值）
///     - `end_node`: 路径终点（存在时有值）
///
/// **算法说明**:
///   - 使用 Hierholzer 算法进行深度优先搜索
///   - 遇到死胡同时回溯并记录边
///   - 最终反转得到正确的欧拉路径
///
/// **使用示例**:
/// ```moonbit nocheck
/// let g = make_path_graph(4)  // 0-1-2-3 路径图
/// let result = find_euler_path_undirected(g)
/// if result.exists {
///   for edge in result.path {
///     println("访问边: ${edge.from} -> ${edge.to}")
///   }
/// }
/// ```
pub fn[G : @core.GraphReadable] find_euler_path_undirected(
  graph : G,
) -> EulerPathResult {
  if !has_euler_path_undirected(graph) {
    return EulerPathResult::{
      exists: false,
      path: [],
      start_node: None,
      end_node: None,
    }
  }
  let (adj, edge_count, edges) = build_adjacency_with_edges(graph)
  if edge_count == 0 {
    return EulerPathResult::{
      exists: true,
      path: [],
      start_node: None,
      end_node: None,
    }
  }
  let (odd_count, first_odd, second_odd) = check_degree_parity(graph)
  let start_node = match first_odd {
    Some(n) => n
    None => find_first_non_isolated(graph)
  }
  let edge_indices = hierholzer_undirected_full(adj, edge_count, start_node)
  let path_edges : Array[@core.Edge] = []
  for idx in edge_indices {
    if idx >= 0 && idx < edges.length() {
      path_edges.push(edges[idx])
    } else {
      ()
    }
  }
  let end_node_id = if path_edges.length() > 0 {
    Some(path_edges[path_edges.length() - 1].to)
  } else {
    None
  }
  EulerPathResult::{
    exists: true,
    path: path_edges,
    start_node: Some(@core.NodeId(start_node)),
    end_node: end_node_id,
  }
}

///|
/// 查找无向图的欧拉回路
///
/// 先检查存在性，再使用 Hierholzer 算法查找具体回路。
/// 回路从第一个非孤立节点开始，最终形成闭合路径。
///
/// **时间复杂度**: O(E)，其中 E 为边数（Hierholzer 算法）
/// **空间复杂度**: O(E)，用于存储邻接表和回路
///
/// **参数**:
///   - `g`: 无向图（实现 GraphReadable trait）
///
/// **返回值**:
///   - `EulerCircuitResult`:
///     - `exists`: 是否存在欧拉回路
///     - `circuit`: 欧拉回路的边序列（按遍历顺序，形成闭环）
///     - `start_node`: 回路起点（存在时有值，也是终点）
///
/// **算法说明**:
///   - 使用 Hierholzer 算法进行深度优先搜索
///   - 从任意非孤立节点开始遍历
///   - 遇到死胡同时回溯并记录边
///   - 最终反转得到正确的欧拉回路
///
/// **使用示例**:
/// ```moonbit nocheck
/// let g = make_triangle_graph()  // 三角形 0-1-2-0
/// let result = find_euler_circuit_undirected(g)
/// if result.exists {
///   for edge in result.circuit {
///     println("访问边: ${edge.from} -> ${edge.to}")
///   }
///   // 输出将包含所有 3 条边，每条恰好一次
/// }
/// ```
pub fn[G : @core.GraphReadable] find_euler_circuit_undirected(
  graph : G,
) -> EulerCircuitResult {
  if !has_euler_circuit_undirected(graph) {
    return EulerCircuitResult::{ exists: false, circuit: [], start_node: None }
  }
  let (adj, edge_count, edges) = build_adjacency_with_edges(graph)
  if edge_count == 0 {
    return EulerCircuitResult::{ exists: true, circuit: [], start_node: None }
  }
  let start_node = find_first_non_isolated(graph)
  let edge_indices = hierholzer_undirected_full(adj, edge_count, start_node)
  let circuit_edges : Array[@core.Edge] = []
  for idx in edge_indices {
    if idx >= 0 && idx < edges.length() {
      circuit_edges.push(edges[idx])
    } else {
      ()
    }
  }
  EulerCircuitResult::{
    exists: true,
    circuit: circuit_edges,
    start_node: Some(@core.NodeId(start_node)),
  }
}
