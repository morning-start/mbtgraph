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

///|
/// 边着色结果
pub(all) struct EdgeColoringResult {
  edge_colors : Array[Array[Int?]] // edge_colors[u][v] = 边(u,v)的颜色编号，None=无此边
  num_colors : Int // 使用的颜色总数
  max_degree : Int // 图的最大度数 Δ
  is_valid : Bool // 着色是否合法（相邻边不同色）
}

///|
/// 查询边(u,v)的颜色，-1 表示未着色或边不存在
pub fn EdgeColoringResult::edge_color(
  self : EdgeColoringResult,
  u : @core.NodeId,
  v : @core.NodeId,
) -> Int {
  let ui = u.0
  let vi = v.0
  if ui < 0 ||
    ui >= self.edge_colors.length() ||
    vi < 0 ||
    vi >= self.edge_colors.length() {
    return -1
  }
  match self.edge_colors[ui][vi] {
    None => -1
    Some(c) => c
  }
}
