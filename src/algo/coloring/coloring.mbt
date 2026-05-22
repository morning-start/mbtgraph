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
fn[G : @core.GraphReadable] validate_coloring(g : G, colors : Array[Int]) -> Bool {
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
  if max_c < 0 { 0 } else { max_c + 1 }
}

///|
/// 构建 ColoringResult
fn[G : @core.GraphReadable] build_result(colors : Array[Int], g : G) -> ColoringResult {
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
/// 时间复杂度 O(V²)，空间复杂度 O(V)。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable 的图结构
///
/// # 返回
///
/// ColoringResult 包含颜色分配、颜色数和合法性标志
pub fn[G : @core.GraphReadable] greedy_coloring(g : G) -> ColoringResult {
  let n = @core.GraphReadable::node_count(g)
  if n == 0 {
    return build_result([], g)
  }
  let colors : Array[Int] = Array::make(n, -1)
  let mut u = 0
  while u < n {
    let used = collect_used_colors(g, colors, u)
    colors[u] = find_min_available_color(used)
    u = u + 1
  }
  build_result(colors, g)
}

///|
/// 贪心着色算法（指定顺序）
///
/// 与 greedy_coloring 相同，但按照用户指定的 order 数组顺序着色。
/// order 数组应包含所有节点 ID（0 到 V-1）的一个排列。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable 的图结构
/// - `order`: 着色顺序数组，元素应为 [0, V-1] 范围内的唯一整数
pub fn[G : @core.GraphReadable] greedy_coloring_with_order(
  g : G,
  order : Array[Int],
) -> ColoringResult {
  let n = @core.GraphReadable::node_count(g)
  if n == 0 || order.length() == 0 {
    return build_result([], g)
  }
  let colors : Array[Int] = Array::make(n, -1)
  for u in order {
    if u >= 0 && u < n {
      let used = collect_used_colors(g, colors, u)
      colors[u] = find_min_available_color(used)
    }
  }
  build_result(colors, g)
}

// ============================================================================
// Welsh-Powell 算法
// ============================================================================

///|
/// Welsh-Powell 着色算法
///
/// 将节点按度数降序排列后执行贪心着色。
/// 对于大多数图，通常比朴素贪心使用更少的颜色。
/// 时间复杂度 O(V² + V log V)，空间复杂度 O(V)。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable 的图结构
pub fn[G : @core.GraphReadable] welsh_powell(g : G) -> ColoringResult {
  let n = @core.GraphReadable::node_count(g)
  if n == 0 {
    return build_result([], g)
  }
  let nodes : Array[(Int, Int)] = []
  let mut i = 0
  while i < n {
    let d = @core.GraphReadable::degree(g, @core.NodeId(i))
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
  greedy_coloring_with_order(g, order)
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
        ((_, di), (_, dj)) => {
          if dj > di {
            let temp = result[i]
            result[i] = result[j]
            result[j] = temp
          }
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
/// 每次选择饱和度（已着色邻居的不同颜色数）最大的未着色节点。
/// 平局时选择度数最大的节点。通常比 Welsh-Powell 效果更好。
/// 时间复杂度 O(V²)，空间复杂度 O(V)。
///
/// # 参数
///
/// - `g`: 实现了 GraphReadable 的图结构
pub fn[G : @core.GraphReadable] dsatur_coloring(g : G) -> ColoringResult {
  let n = @core.GraphReadable::node_count(g)
  if n == 0 {
    return build_result([], g)
  }
  let colors : Array[Int] = Array::make(n, -1)
  let saturation : Array[Int] = Array::make(n, 0)
  let mut colored_count = 0
  while colored_count < n {
    let best = select_dsatur_node(g, colors, saturation, n)
    match best {
      Some(u) => {
        let used = collect_used_colors(g, colors, u)
        colors[u] = find_min_available_color(used)
        update_saturation(g, colors, saturation, u)
        colored_count = colored_count + 1
      }
      None => { break }
    }
  }
  build_result(colors, g)
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
  if best_node >= 0 { Some(best_node) } else { None }
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
