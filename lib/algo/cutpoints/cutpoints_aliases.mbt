///|
/// 割点与桥 API 简短别名
///
/// 这些别名提供更简洁的函数名，原始函数名（带 _undirected/_directed 后缀）保持可用。
/// 无向图版本（GraphReadable）使用不带后缀的简短名称，
/// 有向图版本（GraphDirected）保留 _directed 后缀。

///|
/// 在无向图中查找所有割点（find_articulation_points_undirected 的别名）
pub fn[G : @core.GraphReadable] find_articulation_points(g : G) -> CutPointResult {
  find_articulation_points_undirected(g)
}

///|
/// 在无向图中查找所有桥（find_bridges_undirected 的别名）
pub fn[G : @core.GraphReadable] find_bridges(g : G) -> BridgeResult {
  find_bridges_undirected(g)
}
