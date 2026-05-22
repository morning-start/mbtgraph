///|
/// 图着色结果
pub(all) struct ColoringResult {
  colors : Array[Int] // colors[i] = 节点 i 的颜色编号（0-based）
  num_colors : Int // 使用的颜色总数
  is_valid : Bool // 着色是否合法（相邻节点不同色）
}

///|
/// 色数计算结果
pub(all) struct ChromaticNumberResult {
  chromatic_number : Int? // 色数（None 表示超时/未完成）
  optimal_coloring : Array[Int]? // 最优着色方案
  upper_bound : Int // 上界（贪心算法结果）
  lower_bound : Int // 下界（最大团大小，暂用 1）
  exact : Bool // 是否为精确解
}
