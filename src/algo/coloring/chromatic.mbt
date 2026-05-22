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
  if n == 0 {
    return 0
  }
  if n == 1 {
    return 1
  }
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
      return update_best(
        state,
        deep_copy_colors(current_colors),
        current_max_color,
      )
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
      let new_max = if color > current_max_color {
        color
      } else {
        current_max_color
      }
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
/// 精确色数计算（回溯法 + 剪枝优化）
///
/// 使用深度优先回溯搜索算法，结合上界/下界剪枝和超时机制，
/// 精确计算图的最小着色数（色数 χ(G)）。
///
/// 图着色问题是经典的 NP-hard 问题，本算法适用于中小规模图
/// （V ≤ 20-25）的精确求解。对于大规模图，建议使用启发式算法
/// （如 dsatur_coloring）获得近似解。
///
/// # 时间复杂度
///
/// O(k^V)，其中 V 为节点数，k 为颜色数上界。
/// - 最坏情况：需要枚举所有可能的 k-着色方案
/// - 实际运行时间依赖图的稀疏程度和剪枝效果
/// - 典型性能：V=15 时 < 1秒，V=20 时数秒到数十秒
///
/// # 空间复杂度
///
/// O(V)，存储颜色分配和回溯状态。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable trait 的图结构（无向图）
/// - `time_limit_ms`: 超时时间限制（毫秒）
///   - > 0: 在指定时间后停止搜索，返回当前最优解
///   - = 0: 无时间限制，直到找到最优解或搜索完成
///   - 推荐值：V ≤ 10 时设为 0；V = 15-20 时设为 5000-10000ms
///
/// # 返回值
///
/// ChromaticNumberResult 结构体，包含：
///
/// - `chromatic_number: Int?`:
///   - Some(chi): 找到的色数（精确或近似）
///   - None: 超时且未找到任何可行解（极少发生）
///
/// - `optimal_coloring: Array[Int]?`:
///   - Some(colors): 最优/近似着色方案，colors[i] 为节点 i 的颜色编号（1-based）
///   - None: 未找到任何可行解
///
/// - `upper_bound: Int`:
///   - 色数的上界，由贪心算法（greedy_coloring）得到
///   - 保证 χ(G) ≤ upper_bound
///
/// - `lower_bound: Int`:
///   - 色数的下界（目前使用保守值 1，可改进为最大团大小）
///   - 保证 lower_bound ≤ χ(G)
///
/// - `exact: Bool`:
///   - true: 结果为精确色数（χ(G) = chromatic_number）
///   - false: 因超时终止，结果为近似值（upper_bound ≥ χ(G) ≥ chromatic_number）
///
/// # 算法原理
///
/// ## 整体流程
///
/// 1. **预处理阶段**：
///    - 运行贪心算法得到初始上界 upper_bound
///    - 计算下界 lower_bound（保守值为 1）
///    - 如果 upper_bound ≤ 1，直接返回（平凡情况）
///
/// 2. **回溯搜索阶段**：
///    - 按节点顺序（0 到 V-1）依次尝试分配颜色
///    - 对每个节点尝试颜色 1 到 upper_bound
///    - 只选择与已着色邻居不冲突的颜色
///
/// 3. **剪枝优化**：
///    - **上界剪枝**: 如果当前使用的最大颜色 ≥ 已知最优解，剪枝
///    - **前向检查**: 分配颜色前验证合法性，避免无效搜索
///    - **迭代计数**: 基于 time_limit_ms 的超时机制
///
/// 4. **结果返回**：
///    - 正常结束：返回精确色数和最优着色
///    - 超时结束：返回当前找到的最优近似解
///
/// ## 回溯状态管理
///
/// 使用 BacktrackState 结构体维护可变状态（纯函数语义）：
/// - best_colors: 当前找到的最优着色方案
/// - best_count: 最优方案使用的颜色数
/// - timed_out: 是否因超时终止
/// - iteration_count / max_iterations: 迭代计数和上限
///
/// # 适用规模建议
///
/// | 节点数 V | 推荐设置 | 预期时间 |
/// |---------|---------|---------|
/// | V ≤ 10  | time_limit_ms = 0 | < 0.01s |
/// | V = 11-15 | time_limit_ms = 5000 | 0.01s - 1s |
/// | V = 16-20 | time_limit_ms = 10000 | 1s - 60s |
/// | V = 21-25 | time_limit_ms = 30000 | 数分钟 |
/// | V > 25   | 不推荐 | 可能极慢 |
///
/// # 边界行为
///
/// - **空图 (V=0)**: 返回 χ(G) = 0, exact = true
/// - **单节点 (V=1)**: 返回 χ(G) = 1, exact = true
/// - **无边多节点**: 返回 χ(G) = 1 (所有节点同色), exact = true
/// - **完全图 K_n**: 返回 χ(G) = n, exact = true
/// - **二分图**: 返回 χ(G) ≤ 2, exact = true
///
/// # 示例
///
/// ```moonbit nocheck
/// // Petersen 图（10 个节点，色数为 3）
/// let g = make_petersen_graph()
/// let result = exact_chromatic_number(g, 5000)  // 5 秒超时
///
/// match result.chromatic_number {
///   Some(chi) => {
///     println("色数 χ(G) = ${chi}")
///     if result.exact {
///       println("✓ 精确解")
///     } else {
///       println("△ 近似解（超时），真实色数范围: [${result.lower_bound}, ${result.upper_bound}]")
///     }
///     match result.optimal_coloring {
///       Some(colors) => {
///         for i in 0..colors.length() {
///           println("节点 ${i} → 颜色 ${colors[i]}")
///         }
///       }
///       None => ()
///     }
///   }
///   None => println("未找到可行解（异常情况）")
/// }
///
/// // 输出:
/// // 色数 χ(G) = 3
/// // ✓ 精确解
/// // 节点 0 → 颜色 1
/// // 节点 1 → 颜色 2
/// // ...
/// ```
///
/// # 与启发式算法的配合使用
///
/// 推荐的使用策略：
/// 1. 先调用 dsatur_coloring() 获得快速近似解
/// 2. 如果需要精确解且规模适中，再调用 exact_chromatic_number()
/// 3. 将启发式结果作为质量下界参考
///
/// ```moonbit nocheck
/// let g = make_random_graph(15, 0.5)
///
/// // 快速近似
/// let approx = dsatur_coloring(g)
/// println("DSATUR 近似颜色数: ${approx.num_colors}")
///
/// // 精确求解（如果规模允许）
/// let exact = exact_chromatic_number(g, 10000)
/// match exact.chromatic_number {
///   Some(chi) => println("精确色数: ${chi} (节省 ${approx.num_colors - chi} 种颜色)"),
///   None => ()
/// }
/// ```
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
      0 =>
        return ChromaticNumberResult::{
          chromatic_number: Some(0),
          optimal_coloring: Some([]),
          upper_bound: 0,
          lower_bound: 0,
          exact: true,
        }
      _ =>
        return ChromaticNumberResult::{
          chromatic_number: Some(1),
          optimal_coloring: Some(greedy_result.colors),
          upper_bound: 1,
          lower_bound: 1,
          exact: true,
        }
    }
  }
  let lower_bound = compute_lower_bound(n)
  let state = create_backtrack_state(n, time_limit_ms)
  let initial_colors : Array[Int] = Array::make(n, -1)
  let final_state = backtrack_search(
    g, state, 0, initial_colors, 0, upper_bound, n,
  )
  if final_state.timed_out && final_state.best_count > n {
    ChromaticNumberResult::{
      chromatic_number: None,
      optimal_coloring: None,
      upper_bound,
      lower_bound,
      exact: false,
    }
  } else if final_state.timed_out {
    ChromaticNumberResult::{
      chromatic_number: Some(final_state.best_count),
      optimal_coloring: Some(final_state.best_colors),
      upper_bound,
      lower_bound,
      exact: false,
    }
  } else {
    ChromaticNumberResult::{
      chromatic_number: Some(final_state.best_count),
      optimal_coloring: Some(final_state.best_colors),
      upper_bound,
      lower_bound,
      exact: true,
    }
  }
}
