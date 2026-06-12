///|
/// 哈密顿/TSP API 简短别名
///
/// 这些别名提供更简洁的函数名，原始函数名（带 _backtrack/_quick_check 后缀）保持可用。
/// - find_hamiltonian_path → find_hamiltonian_path_backtrack
/// - find_hamiltonian_circuit → find_hamiltonian_circuit_backtrack
/// - can_have_hamiltonian_circuit → has_hamiltonian_circuit_quick_check

///|
/// 回溯查找哈密顿路径（find_hamiltonian_path_backtrack 的别名）
pub fn[G : @core.GraphReadable] find_hamiltonian_path(
  graph : G,
) -> HamiltonianResult {
  find_hamiltonian_path_backtrack(graph)
}

///|
/// 回溯查找哈密顿回路（find_hamiltonian_circuit_backtrack 的别名）
pub fn[G : @core.GraphReadable] find_hamiltonian_circuit(
  graph : G,
) -> HamiltonianResult {
  find_hamiltonian_circuit_backtrack(graph)
}

///|
/// 快速检查哈密顿回路存在性的必要条件（has_hamiltonian_circuit_quick_check 的别名）
pub fn[G : @core.GraphReadable] can_have_hamiltonian_circuit(
  graph : G,
) -> Bool {
  has_hamiltonian_circuit_quick_check(graph)
}
