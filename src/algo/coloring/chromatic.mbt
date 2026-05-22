///|
/// 精确色数计算算法
///
/// 使用回溯法 + 上界/下界剪枝计算图的最小着色数。
/// 适用于中小规模图的精确求解。

// ============================================================================
// 私有辅助函数
// ============================================================================

///|
/// 深拷贝颜色数组
fn deep_copy_colors(src : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for c in src {
    result.push(c)
  }
  result
}

///|
/// 检查给节点 u 分配 color 是否与已着色邻居冲突
fn[G : @core.GraphReadable] is_color_valid(
  g : G,
  colors : Array[Int],
  u : Int,
  color : Int,
) -> Bool {
  let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(u))
  for neighbor in neighbors {
    let vi = neighbor.0
    if vi >= 0 && vi < colors.length() && colors[vi] == color {
      return false
    }
  }
  true
}

///|
/// 计算简单下界（使用 1 作为保守下界）
fn compute_lower_bound(n : Int) -> Int {
  if n == 0 { return 0 }
  if n == 1 { return 1 }
  1
}

// ============================================================================
// 回溯状态（用于可变状态管理）
// ============================================================================

///|
/// 回溯搜索状态
priv struct BacktrackState {
  best_colors : Array[Int]
  best_count : Int
  timed_out : Bool
  iteration_count : Int
  max_iterations : Int
}

///|
/// 创建回溯状态
fn create_backtrack_state(n : Int, time_limit_ms : Int) -> BacktrackState {
  let max_iter = if time_limit_ms > 0 { time_limit_ms * 1000 } else { 0 }
  BacktrackState::{
    best_colors: Array::make(n, -1),
    best_count: n + 1,
    timed_out: false,
    iteration_count: 0,
    max_iterations: max_iter,
  }
}

///|
/// 检查是否超时（基于迭代次数）
fn check_timeout(state : BacktrackState) -> Bool {
  if state.max_iterations <= 0 {
    return false
  }
  state.iteration_count > state.max_iterations
}

///|
/// 更新超时标志
fn set_timed_out(state : BacktrackState) -> BacktrackState {
  BacktrackState::{
    best_colors: state.best_colors,
    best_count: state.best_count,
    timed_out: true,
    iteration_count: state.iteration_count,
    max_iterations: state.max_iterations,
  }
}

///|
/// 更新最优解
fn update_best(
  state : BacktrackState,
  new_colors : Array[Int],
  new_count : Int,
) -> BacktrackState {
  BacktrackState::{
    best_colors: new_colors,
    best_count: new_count,
    timed_out: state.timed_out,
    iteration_count: state.iteration_count,
    max_iterations: state.max_iterations,
  }
}

///|
/// 增加迭代计数
fn increment_iter(state : BacktrackState) -> BacktrackState {
  BacktrackState::{
    best_colors: state.best_colors,
    best_count: state.best_count,
    timed_out: state.timed_out,
    iteration_count: state.iteration_count + 1,
    max_iterations: state.max_iterations,
  }
}

// ============================================================================
// 核心回溯算法
// ============================================================================

///|
/// 回溯搜索最优着色
fn[G : @core.GraphReadable] backtrack_search(
  g : G,
  state : BacktrackState,
  node_idx : Int,
  current_colors : Array[Int],
  current_max_color : Int,
  upper_bound : Int,
  n : Int,
) -> BacktrackState {
  let state = increment_iter(state)
  if check_timeout(state) {
    return set_timed_out(state)
  }
  if node_idx == n {
    if current_max_color < state.best_count {
      return update_best(state, deep_copy_colors(current_colors), current_max_color)
    }
    return state
  }
  if current_max_color >= state.best_count {
    return state
  }
  let mut color = 1
  let mut result_state = state
  while color <= upper_bound {
    if is_color_valid(g, current_colors, node_idx, color) {
      current_colors[node_idx] = color
      let new_max = if color > current_max_color { color } else { current_max_color }
      result_state = backtrack_search(
        g,
        result_state,
        node_idx + 1,
        current_colors,
        new_max,
        upper_bound,
        n,
      )
      current_colors[node_idx] = -1
      if result_state.timed_out || result_state.best_count <= current_max_color {
        return result_state
      }
    }
    color = color + 1
  }
  result_state
}

// ============================================================================
// 公开 API
// ============================================================================

///|
/// 精确色数计算
///
/// 使用回溯法 + 上界/下界剪枝计算图的最小着色数。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable 的图结构
/// - `time_limit_ms`: 超时时间（毫秒），0 表示无限制
///
/// # 返回
///
/// ChromaticNumberResult 包含：
/// - chromatic_number: 色数（None 表示超时/未完成）
/// - optimal_coloring: 最优着色方案
/// - upper_bound: 上界（贪心算法结果）
/// - lower_bound: 下界
/// - exact: 是否为精确解
pub fn[G : @core.GraphReadable] exact_chromatic_number(
  g : G,
  time_limit_ms : Int,
) -> ChromaticNumberResult {
  let n = @core.GraphReadable::node_count(g)
  if n == 0 {
    return ChromaticNumberResult::{
      chromatic_number: Some(0),
      optimal_coloring: Some([]),
      upper_bound: 0,
      lower_bound: 0,
      exact: true,
    }
  }
  let greedy_result = greedy_coloring(g)
  let upper_bound = greedy_result.num_colors
  if upper_bound <= 1 {
    match greedy_result.colors.length() {
      0 => {
        return ChromaticNumberResult::{
          chromatic_number: Some(0),
          optimal_coloring: Some([]),
          upper_bound: 0,
          lower_bound: 0,
          exact: true,
        }
      }
      _ => {
        return ChromaticNumberResult::{
          chromatic_number: Some(1),
          optimal_coloring: Some(greedy_result.colors),
          upper_bound: 1,
          lower_bound: 1,
          exact: true,
        }
      }
    }
  }
  let lower_bound = compute_lower_bound(n)
  let state = create_backtrack_state(n, time_limit_ms)
  let initial_colors : Array[Int] = Array::make(n, -1)
  let final_state = backtrack_search(
    g,
    state,
    0,
    initial_colors,
    0,
    upper_bound,
    n,
  )
  if final_state.timed_out && final_state.best_count > n {
    ChromaticNumberResult::{
      chromatic_number: None,
      optimal_coloring: None,
      upper_bound: upper_bound,
      lower_bound: lower_bound,
      exact: false,
    }
  } else if final_state.timed_out {
    ChromaticNumberResult::{
      chromatic_number: Some(final_state.best_count),
      optimal_coloring: Some(final_state.best_colors),
      upper_bound: upper_bound,
      lower_bound: lower_bound,
      exact: false,
    }
  } else {
    ChromaticNumberResult::{
      chromatic_number: Some(final_state.best_count),
      optimal_coloring: Some(final_state.best_colors),
      upper_bound: upper_bound,
      lower_bound: lower_bound,
      exact: true,
    }
  }
}
