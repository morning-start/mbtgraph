///|
/// 图着色算法
///
/// 包含贪心着色、Welsh-Powell、DSATUR 等启发式算法。
/// 适用于无向图的最小着色问题近似求解。

// ============================================================================
// 私有辅助函数
// ============================================================================

///|
/// 收集节点 u 的邻居中已使用的颜色集合
fn[G : @core.GraphReadable] collect_used_colors(
  g : G,
  colors : Array[Int],
  u : Int,
) -> Array[Bool] {
  let used : Array[Bool] = []
  let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(u))
  for neighbor in neighbors {
    let vi = neighbor.0
    if vi >= 0 && vi < colors.length() && colors[vi] >= 0 {
      let c = colors[vi]
      while used.length() <= c {
        used.push(false)
      }
      used[c] = true
    }
  }
  used
}

///|
/// 找到最小可用颜色（不在 used 集合中的最小非负整数）
fn find_min_available_color(used : Array[Bool]) -> Int {
  let mut c = 0
  while c < used.length() {
    if !used[c] {
      return c
    }
    c = c + 1
  }
  c
}

///|
/// 验证着色方案是否合法（相邻节点不同色）
fn[G : @core.GraphReadable] validate_coloring(
  g : G,
  colors : Array[Int],
) -> Bool {
  let n = @core.GraphReadable::node_count(g)
  let mut u = 0
  while u < n {
    if colors[u] < 0 {
      return false
    }
    let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(u))
    for neighbor in neighbors {
      let vi = neighbor.0
      if vi >= 0 && vi < n && colors[u] == colors[vi] {
        return false
      }
    }
    u = u + 1
  }
  true
}

///|
/// 计算使用的颜色总数
fn count_colors(colors : Array[Int]) -> Int {
  let mut max_c = -1
  for c in colors {
    if c > max_c {
      max_c = c
    }
  }
  if max_c < 0 {
    0
  } else {
    max_c + 1
  }
}

///|
/// 构建 ColoringResult
fn[G : @core.GraphReadable] build_result(
  colors : Array[Int],
  g : G,
) -> ColoringResult {
  let num_colors = count_colors(colors)
  let is_valid = validate_coloring(g, colors)
  ColoringResult::{ colors, num_colors, is_valid }
}

// ============================================================================
// 贪心着色算法
// ============================================================================

///|
/// 贪心着色算法（按节点 ID 自然顺序）
///
/// 按 0, 1, 2, ..., V-1 的顺序依次为每个节点选择最小可用颜色。
/// 这是最简单快速的着色启发式，适用于对解的质量要求不高的场景。
///
/// # 时间复杂度
///
/// O(V²)，其中 V 为节点数。每个节点需要检查所有邻居的颜色。
///
/// # 空间复杂度
///
/// O(V)，存储颜色分配数组。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable trait 的图结构（无向图）
///
/// # 返回值
///
/// ColoringResult 结构体，包含：
/// - `colors`: 颜色数组，colors[i] 表示节点 i 的颜色编号（0-based）
/// - `num_colors`: 使用的颜色总数
/// - `is_valid`: 着色是否合法（相邻节点不同色），始终为 true
///
/// # 算法原理
///
/// 1. 初始化所有节点颜色为 -1（未着色）
/// 2. 按节点 ID 从 0 到 V-1 的顺序遍历
/// 3. 对每个节点，收集其邻居已使用的颜色集合
/// 4. 选择最小的未使用颜色（从 0 开始尝试）
/// 5. 分配该颜色并继续下一个节点
///
/// 该算法保证生成合法着色，但颜色数不一定最优。最坏情况下使用 Δ+1 种颜色
/// （Δ 为图的最大度数）。
///
/// # 近似比
///
/// 贪心着色的近似比为 Δ+1，即使用的颜色数 ≤ χ(G) × (Δ+1)，
/// 其中 χ(G) 为真实色数。
///
/// # 示例
///
/// ```moonbit nocheck
/// let g = make_bipartite_graph(3, 3)
/// let result = greedy_coloring(g)
/// assert(result.is_valid == true)
/// println("使用颜色数: ${result.num_colors}")  // 通常 ≤ 2
/// ```
pub fn[G : @core.GraphReadable] greedy_coloring(graph : G) -> ColoringResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return build_result([], graph)
  }
  let colors : Array[Int] = Array::make(n, -1)
  let mut u = 0
  while u < n {
    let used = collect_used_colors(graph, colors, u)
    colors[u] = find_min_available_color(used)
    u = u + 1
  }
  build_result(colors, graph)
}

///|
/// 贪心着色算法（指定顺序）
///
/// 与 greedy_coloring 相同，但按照用户指定的 order 数组顺序着色。
/// 允许通过自定义节点访问顺序来优化着色质量。
///
/// # 时间复杂度
///
/// O(V²)，其中 V 为节点数。
///
/// # 空间复杂度
///
/// O(V)，存储颜色分配数组。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable trait 的图结构（无向图）
/// - `order`: 着色顺序数组，元素应为 [0, V-1] 范围内的唯一整数排列。
///   如果数组为空或包含无效 ID，对应节点将保持未着色状态（-1）。
///
/// # 返回值
///
/// ColoringResult 结构体，包含颜色分配、颜色数和合法性标志。
///
/// # 算法原理
///
/// 1. 初始化所有节点颜色为 -1（未着色）
/// 2. 按 order 数组指定的顺序遍历节点
/// 3. 对每个有效节点，收集其邻居已使用的颜色集合
/// 4. 选择最小的未使用颜色并分配
///
/// 节点着色顺序对最终结果有显著影响：
/// - 度数大的节点先着色通常能减少总颜色数
/// - 可以结合其他启发式（如 DSATUR）生成最优顺序
///
/// # 使用场景
///
/// - 当已知图的特殊结构时，可手动指定最优顺序
/// - 用于研究不同着色顺序对结果的影响
/// - 作为其他高级算法的基础组件
///
/// # 示例
///
/// ```moonbit nocheck
/// let g = make_cycle_graph(5)
/// // 按度数降序排列（对正则图效果相同）
/// let order = [4, 3, 2, 1, 0]
/// let result = greedy_coloring_with_order(g, order)
/// assert(result.is_valid == true)
/// println("使用颜色数: ${result.num_colors}")
/// ```
pub fn[G : @core.GraphReadable] greedy_coloring_with_order(
  graph : G,
  order : Array[Int],
) -> ColoringResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 || order.length() == 0 {
    return build_result([], graph)
  }
  let colors : Array[Int] = Array::make(n, -1)
  for u in order {
    if u >= 0 && u < n {
      let used = collect_used_colors(graph, colors, u)
      colors[u] = find_min_available_color(used)
    }
  }
  build_result(colors, graph)
}

// ============================================================================
// Welsh-Powell 算法
// ============================================================================

///|
/// Welsh-Powell 着色算法
///
/// 将节点按度数降序排列后执行贪心着色。这是贪心着色的经典改进版本，
/// 对于大多数图（特别是稀疏图），通常比朴素贪心使用更少的颜色。
///
/// # 时间复杂度
///
/// O(V² + V log V)，其中 V 为节点数。
/// - 度数计算: O(V × E/V) = O(E)
/// - 排序: O(V²)（使用简单冒泡排序）
/// - 贪心着色: O(V²)
///
/// # 空间复杂度
///
/// O(V)，存储颜色分配和排序后的节点顺序。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable trait 的图结构（无向图）
///
/// # 返回值
///
/// ColoringResult 结构体，包含颜色分配、颜色数和合法性标志。
///
/// # 算法原理
///
/// 1. 计算每个节点的度数（邻居数量）
/// 2. 将所有节点按度数降序排列（使用冒泡排序）
/// 3. 按排序后的顺序执行贪心着色：
///    - 对每个节点，选择最小可用颜色
///    - 可用颜色指该节点的邻居未使用的最小颜色编号
///
/// 核心思想：高度数的节点约束更多，应该优先处理。
/// 这样可以避免后期为高度数节点分配过多新颜色。
///
/// # 性能特点
///
/// - 对稀疏图效果显著优于朴素贪心
/// - 对稠密图（如完全图）与朴素贪心相同
/// - 通常比 DSATUR 快，但质量略差
/// - 保证生成合法着色
///
/// # 示例
///
/// ```moonbit nocheck
/// let g = make_wheel_graph(6)  // 轮图 W_6
/// let result = welsh_powell(g)
/// assert(result.is_valid == true)
/// // 轮图的色数为 3 或 4（取决于奇偶性）
/// println("Welsh-Powell 使用颜色数: ${result.num_colors}")
/// ```
pub fn[G : @core.GraphReadable] welsh_powell(graph : G) -> ColoringResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return build_result([], graph)
  }
  let nodes : Array[(Int, Int)] = []
  let mut i = 0
  while i < n {
    let d = @core.GraphReadable::degree(graph, @core.NodeId(i))
    nodes.push((i, d))
    i = i + 1
  }
  let sorted = sort_by_degree_desc(nodes)
  let order : Array[Int] = []
  for entry in sorted {
    match entry {
      (idx, _) => order.push(idx)
    }
  }
  greedy_coloring_with_order(graph, order)
}

///|
/// 按度数降序排序（简单冒泡排序）
fn sort_by_degree_desc(nodes : Array[(Int, Int)]) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  for node in nodes {
    result.push(node)
  }
  let mut i = 0
  while i < result.length() {
    let mut j = i + 1
    while j < result.length() {
      match (result[i], result[j]) {
        ((_, di), (_, dj)) =>
          if dj > di {
            let temp = result[i]
            result[i] = result[j]
            result[j] = temp
          }
      }
      j = j + 1
    }
    i = i + 1
  }
  result
}

// ============================================================================
// DSATUR 算法
// ============================================================================

///|
/// DSATUR 着色算法（饱和度排序）
///
/// 每次选择饱和度（已着色邻居的不同颜色数）最大的未着色节点进行着色。
/// 这是目前实践效果最好的贪心启发式算法，通常比 Welsh-Powell 和朴素贪心
/// 使用更少的颜色，接近最优解。
///
/// # 时间复杂度
///
/// O(V²)，其中 V 为节点数。
/// - 每次选择节点: O(V)（扫描所有未着色节点）
/// - 共 V 轮选择，每轮更新邻居饱和度: O(V)
///
/// # 空间复杂度
///
/// O(V)，存储颜色分配和饱和度数组。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable trait 的图结构（无向图）
///
/// # 返回值
///
/// ColoringResult 结构体，包含颜色分配、颜色数和合法性标志。
///
/// # 算法原理
///
/// 1. 初始化所有节点颜色为 -1（未着色），饱和度为 0
/// 2. 循环直到所有节点着色完成：
///    a. 选择未着色节点中饱和度最大的节点 u
///       - **饱和度**: 该节点的已着色邻居使用的不同颜色数量
///       - 平局时选择度数最大的节点（打破对称性）
///    b. 为节点 u 选择最小可用颜色
///    c. 更新 u 的所有未着色邻居的饱和度：
///      - 如果邻居没有其他已着色节点使用该颜色，则饱和度 +1
///
/// 核心思想：优先处理"约束最紧"的节点（饱和度高意味着可选颜色少），
/// 可以更有效地利用颜色资源。
///
/// # 性能特点
///
/// - **启发式中最优**：在大多数基准测试中表现最好
/// - 对随机图、稀疏图、稠密图都有良好表现
/// - 对某些特殊图（如二分图）可达到最优解
/// - 保证生成合法着色
/// - 时间开销略高于 Welsh-Powell，但质量提升显著
///
/// # 理论保证
///
/// - 对二分图总能找到 2-着色（最优）
/// - 对弦图（chordal graph）总能找到最优着色
/// - 近似比优于 Welsh-Powell 和朴素贪心
///
/// # 示例
///
/// ```moonbit nocheck
/// let g = make_petersen_graph()
/// let result = dsatur_coloring(g)
/// assert(result.is_valid == true)
/// assert(result.num_colors == 3)  // Petersen 图色数为 3
/// for i in 0..result.colors.length() {
///   println("节点 ${i} 的颜色: ${result.colors[i]}")
/// }
/// ```
pub fn[G : @core.GraphReadable] dsatur_coloring(graph : G) -> ColoringResult {
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 {
    return build_result([], graph)
  }
  let colors : Array[Int] = Array::make(n, -1)
  let saturation : Array[Int] = Array::make(n, 0)
  let mut colored_count = 0
  while colored_count < n {
    let best = select_dsatur_node(graph, colors, saturation, n)
    match best {
      Some(u) => {
        let used = collect_used_colors(graph, colors, u)
        colors[u] = find_min_available_color(used)
        update_saturation(graph, colors, saturation, u)
        colored_count = colored_count + 1
      }
      None => break
    }
  }
  build_result(colors, graph)
}

///|
/// 选择 DSATUR 下一个要着色的节点
///
/// 选择规则：
/// 1. 未着色的节点中 saturation 最大的
/// 2. 平局时选择 degree 最大的
fn[G : @core.GraphReadable] select_dsatur_node(
  g : G,
  colors : Array[Int],
  saturation : Array[Int],
  n : Int,
) -> Int? {
  let mut best_node = -1
  let mut best_sat = -1
  let mut best_deg = -1
  let mut u = 0
  while u < n {
    if colors[u] == -1 {
      let sat = saturation[u]
      let deg = @core.GraphReadable::degree(g, @core.NodeId(u))
      if sat > best_sat || (sat == best_sat && deg > best_deg) {
        best_node = u
        best_sat = sat
        best_deg = deg
      }
    }
    u = u + 1
  }
  if best_node >= 0 {
    Some(best_node)
  } else {
    None
  }
}

///|
/// 更新节点 u 所有未着色邻居的饱和度
fn[G : @core.GraphReadable] update_saturation(
  g : G,
  colors : Array[Int],
  saturation_ref : Array[Int],
  u : Int,
) -> Unit {
  let new_color = colors[u]
  let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(u))
  for neighbor in neighbors {
    let vi = neighbor.0
    if vi >= 0 && vi < colors.length() && colors[vi] == -1 {
      if !neighbor_has_color(g, colors, vi, new_color) {
        saturation_ref[vi] = saturation_ref[vi] + 1
      }
    }
  }
}

///|
/// 检查节点的已着色邻居是否已经使用了指定颜色
fn[G : @core.GraphReadable] neighbor_has_color(
  g : G,
  colors : Array[Int],
  u : Int,
  color : Int,
) -> Bool {
  let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(u))
  for neighbor in neighbors {
    let vi = neighbor.0
    if vi >= 0 && vi < colors.length() && colors[vi] == color {
      return true
    }
  }
  false
}
