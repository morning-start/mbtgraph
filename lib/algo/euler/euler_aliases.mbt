///|
/// 欧拉路径/回路 API 简短别名
///
/// 这些别名提供更简洁的函数名，原始函数名（带 _undirected/_directed 后缀）保持可用。
/// 无向图版本（GraphReadable）使用不带后缀的简短名称，
/// 有向图版本（GraphDirected）保留 _directed 后缀。

///|
/// 判定无向图是否存在欧拉路径（has_euler_path_undirected 的别名）
pub fn[G : @core.GraphReadable] has_euler_path(graph : G) -> Bool {
  has_euler_path_undirected(graph)
}

///|
/// 判定无向图是否存在欧拉回路（has_euler_circuit_undirected 的别名）
pub fn[G : @core.GraphReadable] has_euler_circuit(graph : G) -> Bool {
  has_euler_circuit_undirected(graph)
}

///|
/// 查找无向图的欧拉路径（find_euler_path_undirected 的别名）
pub fn[G : @core.GraphReadable] find_euler_path(graph : G) -> EulerPathResult {
  find_euler_path_undirected(graph)
}

///|
/// 查找无向图的欧拉回路（find_euler_circuit_undirected 的别名）
pub fn[G : @core.GraphReadable] find_euler_circuit(
  graph : G,
) -> EulerCircuitResult {
  find_euler_circuit_undirected(graph)
}
