///|
/// Kosaraju 强连通分量算法
///
/// 基于两次 DFS 的经典算法：第一次 DFS 记录完成顺序，
/// 第二次按逆序 DFS 得到 SCC。时间复杂度 O(V+E)。
///|
fn[T] reverse_array(arr : Array[T]) -> Array[T] {
  let n = arr.length()
  let result : Array[T] = []
  if n == 0 {
    return result
  }
  let mut j = n - 1
  while j >= 0 {
    result.push(arr[j])
    j = j - 1
  }
  result
}

///|
/// Kosaraju 强连通分量
///
/// 通过两次 DFS 检测有向图的强连通分量。
pub fn[G : @core.GraphDirected] kosaraju_scc(
  g : G,
) -> StronglyConnectedComponentsResult {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return StronglyConnectedComponentsResult::{ components: [] }
  }
  let max_id = @storage.find_max_node_id(g)
  let size = @storage.int_max(max_id + 1, 1)
  let visited : Array[Bool] = Array::make(size, false)
  let finish_order : Array[@core.NodeId] = []
  for start in @core.GraphReadable::node_ids(g) {
    if visited[start.0] {
      continue
    }
    let stack_data : Array[@core.NodeId] = Array::make(size, @core.NodeId(0))
    let mut stack_top = 0
    stack_data[stack_top] = start
    stack_top = stack_top + 1
    let processed : Array[Bool] = Array::make(size, false)
    visited[start.0] = true
    while stack_top > 0 {
      stack_top = stack_top - 1
      let cur = stack_data[stack_top]
      if processed[cur.0] {
        finish_order.push(cur)
        continue
      }
      stack_data[stack_top] = cur
      stack_top = stack_top + 1
      processed[cur.0] = true
      let mut has_unvisited_nbr = false
      for nbr in @core.GraphDirected::in_neighbors(g, cur) {
        if !visited[nbr.0] {
          visited[nbr.0] = true
          stack_data[stack_top] = nbr
          stack_top = stack_top + 1
          has_unvisited_nbr = true
        }
      }
    }
  }
  let reversed_order = reverse_array(finish_order)
  let visited2 : Array[Bool] = Array::make(size, false)
  let result : Array[Array[@core.NodeId]] = []
  for start in reversed_order {
    if visited2[start.0] {
      continue
    }
    let component : Array[@core.NodeId] = []
    let queue : Array[@core.NodeId] = [start]
    visited2[start.0] = true
    let mut qhead = 0
    while qhead < queue.length() {
      let cur = queue[qhead]
      component.push(cur)
      qhead = qhead + 1
      for nbr in @core.GraphReadable::neighbors(g, cur) {
        if !visited2[nbr.0] {
          visited2[nbr.0] = true
          queue.push(nbr)
        }
      }
    }
    result.push(component)
  }
  StronglyConnectedComponentsResult::{ components: result }
}

///|
fn[T] array_pop_last(arr : Array[T]) -> Array[T] {
  let result : Array[T] = []
  let mut i = 0
  let len = arr.length() - 1
  while i < len {
    result.push(arr[i])
    i = i + 1
  }
  result
}
