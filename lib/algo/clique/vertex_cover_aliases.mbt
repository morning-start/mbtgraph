///|
/// 顶点覆盖 API 简短别名
///
/// 这些别名提供更简洁的函数名，原始函数名（带 _exact/_approx 后缀）保持可用。
/// - find_minimum_vertex_cover → find_minimum_vertex_cover_exact（精确版本应为默认）
/// - find_minimum_vertex_cover_greedy → find_minimum_vertex_cover_approx（明确算法策略）

///|
/// 查找最小顶点覆盖的精确解（find_minimum_vertex_cover_exact 的别名）
pub fn[G : @core.GraphReadable] find_minimum_vertex_cover(
  g : G,
) -> VertexCoverResult {
  find_minimum_vertex_cover_exact(g)
}

///|
/// 查找最小顶点覆盖的贪心近似解（find_minimum_vertex_cover_approx 的别名）
pub fn[G : @core.GraphReadable] find_minimum_vertex_cover_greedy(
  g : G,
) -> VertexCoverResult {
  find_minimum_vertex_cover_approx(g)
}
