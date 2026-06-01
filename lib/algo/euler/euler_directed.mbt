///|
/// 有向图欧拉路径/回路判定与查找算法
///
/// 基于有向图欧拉路径定理：
/// - 欧拉回路：基图连通 + 所有节点入度=出度
/// - 欧拉路径：基图连通 + 至多一个节点出度=入度+1（起点）+ 至多一个节点入度=出度+1（终点）+ 其余平衡

// ============================================================================
// 度数平衡检查
// ============================================================================

///|
/// 检查有向图的度数平衡条件
///
/// 遍历所有节点统计 in_degree 和 out_degree，
/// 检查欧拉路径的度数约束：
/// - 出度 = 入度 + 1 的节点数 ≤ 1（起点候选）
/// - 入度 = 出度 + 1 的节点数 ≤ 1（终点候选）
/// - 其他节点必须 in_degree == out_degree
///
/// 返回: (是否满足条件, 起点?, 终点?)
fn[G : @core.GraphDirected] check_degree_balance(g : G) -> (Bool, Int?, Int?) {
  let mut start_candidate : Int? = None
  let mut end_candidate : Int? = None
  let mut balanced = true
  for nid in @core.GraphReadable::node_ids(g) {
    let indeg = @core.GraphDirected::in_degree(g, nid)
    let outdeg = @core.GraphDirected::out_degree(g, nid)
    if outdeg == indeg + 1 {
      match start_candidate {
        None => start_candidate = Some(nid.0)
        Some(_) => balanced = false
      }
    } else if indeg == outdeg + 1 {
      match end_candidate {
        None => end_candidate = Some(nid.0)
        Some(_) => balanced = false
      }
    } else if indeg != outdeg {
      balanced = false
    } else {
      ()
    }
  }
  (balanced, start_candidate, end_candidate)
}

// ============================================================================
// 基图连通性检查
// ============================================================================

///|
/// 找到图中最大的节点 ID
fn[G : @core.GraphReadable] find_max_node_id_directed(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
/// 检查有向图基图的连通性（忽略方向）
///
/// 找到第一个有边（in_degree > 0 或 out_degree > 0）的节点作为 BFS 起点，
/// BFS 同时遍历 successors 和 predecessors（忽略方向），
/// 检查所有有边的节点都被访问
fn[G : @core.GraphDirected] is_base_graph_connected(g : G) -> Bool {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return true
  }
  if nc == 1 {
    return true
  }
  let mut start : @core.NodeId? = None
  for nid in @core.GraphReadable::node_ids(g) {
    let indeg = @core.GraphDirected::in_degree(g, nid)
    let outdeg = @core.GraphDirected::out_degree(g, nid)
    if indeg > 0 || outdeg > 0 {
      start = Some(nid)
      break
    }
  }
  match start {
    None => true
    Some(start_node) => {
      let max_id = find_max_node_id_directed(g)
      let size = Int::max(max_id + 1, 1)
      let visited : Array[Bool] = Array::make(size, false)
      let queue : Array[@core.NodeId] = [start_node]
      visited[start_node.0] = true
      let mut visited_non_isolated = 1
      let mut head = 0
      while head < queue.length() {
        let cur = queue[head]
        head = head + 1
        for succ_pair in @core.GraphDirected::successors(g, cur) {
          match succ_pair {
            (succ_node, _) =>
              if !visited[succ_node.0] {
                visited[succ_node.0] = true
                queue.push(succ_node)
                let s_indeg = @core.GraphDirected::in_degree(g, succ_node)
                let s_outdeg = @core.GraphDirected::out_degree(g, succ_node)
                if s_indeg > 0 || s_outdeg > 0 {
                  visited_non_isolated = visited_non_isolated + 1
                }
              }
          }
        }
        for pred_pair in @core.GraphDirected::predecessors(g, cur) {
          match pred_pair {
            (pred_node, _) =>
              if !visited[pred_node.0] {
                visited[pred_node.0] = true
                queue.push(pred_node)
                let p_indeg = @core.GraphDirected::in_degree(g, pred_node)
                let p_outdeg = @core.GraphDirected::out_degree(g, pred_node)
                if p_indeg > 0 || p_outdeg > 0 {
                  visited_non_isolated = visited_non_isolated + 1
                }
              }
          }
        }
      }
      let mut total_non_isolated = 0
      for nid in @core.GraphReadable::node_ids(g) {
        let indeg = @core.GraphDirected::in_degree(g, nid)
        let outdeg = @core.GraphDirected::out_degree(g, nid)
        if indeg > 0 || outdeg > 0 {
          total_non_isolated = total_non_isolated + 1
        }
      }
      visited_non_isolated == total_non_isolated
    }
  }
}

// ============================================================================
// 欧拉路径/回路判定
// ============================================================================

///|
/// 判定有向图是否存在欧拉路径
///
/// 欧拉路径是指能够访问图中每条有向边恰好一次的路径。
///
/// **时间复杂度**: O(V + E)，其中 V 为节点数，E 为边数
/// **空间复杂度**: O(V)，用于基图连通性检查和度数统计
///
/// **参数**:
///   - `g`: 有向图（实现 GraphDirected trait）
///
/// **返回值**:
///   - `true`: 存在欧拉路径
///   - `false`: 不存在欧拉路径
///
/// **判定条件**:
///   - 基图必须是连通的（忽略方向，忽略孤立节点）
///   - 度数平衡条件满足：
///     - 至多一个节点出度 = 入度 + 1（起点候选）
///     - 至多一个节点入度 = 出度 + 1（终点候选）
///     - 其余所有节点入度 = 出度
///
/// **使用示例**:
/// ```moonbit nocheck
/// let g = make_directed_path(4) // 0→1→2→3 有向路径
///
/// let result = has_euler_path_directed(g) // 返回 true
/// ```
pub fn[G : @core.GraphDirected] has_euler_path_directed(graph : G) -> Bool {
  if !is_base_graph_connected(graph) {
    return false
  }
  let (balanced, _, _) = check_degree_balance(graph)
  balanced
}

///|
/// 判定有向图是否存在欧拉回路
///
/// 欧拉回路是指能够访问图中每条有向边恰好一次并回到起点的闭合路径。
///
/// **时间复杂度**: O(V + E)，其中 V 为节点数，E 为边数
/// **空间复杂度**: O(V)，用于基图连通性检查和度数统计
///
/// **参数**:
///   - `g`: 有向图（实现 GraphDirected trait）
///
/// **返回值**:
///   - `true`: 存在欧拉回路
///   - `false`: 不存在欧拉回路
///
/// **判定条件**:
///   - 基图必须是连通的（忽略方向，忽略孤立节点）
///   - 所有节点入度 = 出度（无起点/终点候选）
///
/// **使用示例**:
/// ```moonbit nocheck
/// let g = make_directed_cycle(4) // 0→1→2→3→0 有向环
///
/// let result = has_euler_circuit_directed(g) // 返回 true
/// ```
pub fn[G : @core.GraphDirected] has_euler_circuit_directed(graph : G) -> Bool {
  if !is_base_graph_connected(graph) {
    return false
  }
  let (balanced, start, end) = check_degree_balance(graph)
  balanced && start == None && end == None
}

// ============================================================================
// Hierholzer 算法 - 有向图版本
// ============================================================================

///|
/// 从 GraphDirected trait 构建内部邻接表（仅出边，带边索引）
///
/// 邻接表格式: Array[Array[(target_node_id, edge_index)]>
/// 有向图只添加单向边（不同于无向图的双向添加）
///
/// 返回: (邻接表, 边总数, Edge 对象数组)
fn[G : @core.GraphDirected] build_directed_adjacency(
  g : G,
) -> (Array[Array[(Int, Int)]], Int, Array[@core.Edge]) {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return ([], 0, [])
  }
  let max_id = find_max_node_id_directed(g)
  let size = Int::max(max_id + 1, 1)
  let adj : Array[Array[(Int, Int)]] = Array::make(size, [])
  let edges : Array[@core.Edge] = []
  let mut edge_index = 0
  for nid in @core.GraphReadable::node_ids(g) {
    for succ_pair in @core.GraphDirected::successors(g, nid) {
      match succ_pair {
        (succ_node, weight) => {
          let edge = @core.Edge::{ from: nid, to: succ_node, data: weight }
          adj[nid.0].push((succ_node.0, edge_index))
          edges.push(edge)
          edge_index = edge_index + 1
        }
      }
    }
  }
  (adj, edge_index, edges)
}

///|
/// 找到第一个 out_degree > 0 的节点
fn[G : @core.GraphDirected] find_first_non_zero_out_degree(g : G) -> Int {
  for nid in @core.GraphReadable::node_ids(g) {
    let outdeg = @core.GraphDirected::out_degree(g, nid)
    if outdeg > 0 {
      return nid.0
    } else {
      ()
    }
  }
  0
}

///|
/// Hierholzer 核心算法实现（有向图版）
///
/// 使用栈模拟递归避免栈溢出
/// 栈元素类型: (current_node, next_edge_index_to_try)
/// 返回边索引序列（需要反转）
fn hierholzer_directed_core(
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

// ============================================================================
// 欧拉路径/回路查找
// ============================================================================

///|
/// 查找有向图的欧拉路径
///
/// 先检查存在性，再使用 Hierholzer 算法查找具体路径。
/// 如果存在起点候选（出度=入度+1），从该节点开始；
/// 否则从第一个出度>0 的节点开始。
///
/// **时间复杂度**: O(E)，其中 E 为边数（Hierholzer 算法）
/// **空间复杂度**: O(E)，用于存储邻接表和路径
///
/// **参数**:
///   - `g`: 有向图（实现 GraphDirected trait）
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
///   - 仅沿有向边方向遍历
///   - 遇到死胡同时回溯并记录边
///   - 最终反转得到正确的欧拉路径
///
/// **使用示例**:
/// ```moonbit nocheck
/// let g = make_directed_path(4)  // 0→1→2→3 有向路径
/// let result = find_euler_path_directed(g)
/// if result.exists {
///   for edge in result.path {
///     println("访问边: ${edge.from} -> ${edge.to}")
///   }
/// }
/// ```
pub fn[G : @core.GraphDirected] find_euler_path_directed(
  graph : G,
) -> EulerPathResult {
  if !has_euler_path_directed(graph) {
    return EulerPathResult::{
      exists: false,
      path: [],
      start_node: None,
      end_node: None,
    }
  }
  let (adj, edge_count, edges) = build_directed_adjacency(graph)
  if edge_count == 0 {
    return EulerPathResult::{
      exists: true,
      path: [],
      start_node: None,
      end_node: None,
    }
  }
  let (_, start_candidate, _) = check_degree_balance(graph)
  let start_node = match start_candidate {
    Some(n) => n
    None => find_first_non_zero_out_degree(graph)
  }
  let edge_indices = hierholzer_directed_core(adj, edge_count, start_node)
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
/// 查找有向图的欧拉回路
///
/// 先检查存在性，再使用 Hierholzer 算法查找具体回路。
/// 回路从第一个出度>0 的节点开始，最终形成闭合路径。
///
/// **时间复杂度**: O(E)，其中 E 为边数（Hierholzer 算法）
/// **空间复杂度**: O(E)，用于存储邻接表和回路
///
/// **参数**:
///   - `g`: 有向图（实现 GraphDirected trait）
///
/// **返回值**:
///   - `EulerCircuitResult`:
///     - `exists`: 是否存在欧拉回路
///     - `circuit`: 欧拉回路的边序列（按遍历顺序，形成闭环）
///     - `start_node`: 回路起点（存在时有值，也是终点）
///
/// **算法说明**:
///   - 使用 Hierholzer 算法进行深度优先搜索
///   - 仅沿有向边方向遍历
///   - 从任意出度>0 的节点开始遍历
///   - 遇到死胡同时回溯并记录边
///   - 最终反转得到正确的欧拉回路
///
/// **使用示例**:
/// ```moonbit nocheck
/// let g = make_directed_cycle(4)  // 0→1→2→3→0 有向环
/// let result = find_euler_circuit_directed(g)
/// if result.exists {
///   for edge in result.circuit {
///     println("访问边: ${edge.from} -> ${edge.to}")
///   }
///   // 输出将包含所有 4 条有向边，每条恰好一次
/// }
/// ```
pub fn[G : @core.GraphDirected] find_euler_circuit_directed(
  graph : G,
) -> EulerCircuitResult {
  if !has_euler_circuit_directed(graph) {
    return EulerCircuitResult::{ exists: false, circuit: [], start_node: None }
  }
  let (adj, edge_count, edges) = build_directed_adjacency(graph)
  if edge_count == 0 {
    return EulerCircuitResult::{ exists: true, circuit: [], start_node: None }
  }
  let start_node = find_first_non_zero_out_degree(graph)
  let edge_indices = hierholzer_directed_core(adj, edge_count, start_node)
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
