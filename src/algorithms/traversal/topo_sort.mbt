///|
/// 拓扑排序算法
///
/// 仅适用于**有向无环图 (DAG)**。
///
/// 提供两种实现：
/// - **Kahn 算法**: BFS 式，基于入度，每次移除入度为 0 的节点
/// - **DFS 算法**: 递归/迭代式，利用完成时间逆序

///|
/// Kahn 算法拓扑排序（BFS 式，基于入度）
///
/// 成功返回按拓扑序排列的节点列表。
/// 如果图包含环，返回 Err。
pub fn[G : @core.GraphDirected] topo_sort_kahn(
  g : G,
) -> Result[Array[@core.NodeId], String] {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return Ok([])
  }
  let max_id = topo_find_max_id(g)
  let size = max(max_id + 1, 1)
  let in_degree = Array::make(size, 0)
  for nid in @core.GraphReadable::node_ids(g) {
    for nbr in @core.GraphReadable::neighbors(g, nid) {
      let idx = nbr.0
      if idx >= 0 && idx < size {
        in_degree[idx] = in_degree[idx] + 1
      }
    }
  }
  let queue : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(g) {
    if in_degree[nid.0] == 0 {
      queue.push(nid)
    }
  }
  let result : Array[@core.NodeId] = []
  let mut count = 0
  let mut head = 0
  while head < queue.length() {
    let cur = queue[head]
    head = head + 1
    result.push(cur)
    count = count + 1
    for nid in @core.GraphReadable::neighbors(g, cur) {
      let idx = nid.0
      if idx >= 0 && idx < size {
        in_degree[idx] = in_degree[idx] - 1
        if in_degree[idx] == 0 {
          queue.push(nid)
        }
      }
    }
  }
  if count != nc {
    Err("graph contains a cycle")
  } else {
    Ok(result)
  }
}

///|
/// DFS 算法拓扑排序（逆后序 / 完成时间降序）
///
/// 成功返回按拓扑序排列的节点列表。
/// 如果图包含环，返回 Err。
pub fn[G : @core.GraphDirected] topo_sort_dfs(
  g : G,
) -> Result[Array[@core.NodeId], String] {
  let nc = @core.GraphReadable::node_count(g)
  if nc == 0 {
    return Ok([])
  }
  let max_id = topo_find_max_id(g)
  let size = max(max_id + 1, 1)
  let visited = Array::make(size, false)
  let on_stack = Array::make(size, false)
  let result : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(g) {
    let idx = nid.0
    if visited[idx] {
      continue
    }
    match topo_dfs_visit(g, nid, visited, on_stack, result, size) {
      Ok(r) => { let _ = r }
      Err(e) => return Err(e)
    }
  }
  let rev : Array[@core.NodeId] = []
  let mut j = result.length() - 1
  while j >= 0 {
    rev.push(result[j])
    j = j - 1
  }
  Ok(rev)
}

pub fn[G : @core.GraphDirected] topo_dfs_visit(
  g : G,
  cur : @core.NodeId,
  visited : Array[Bool],
  on_stack : Array[Bool],
  acc : Array[@core.NodeId],
  size : Int,
) -> Result[Array[@core.NodeId], String] {
  visited[cur.0] = true
  on_stack[cur.0] = true
  let result = acc
  for nid in @core.GraphReadable::neighbors(g, cur) {
    let idx = nid.0
    if idx < 0 || idx >= size {
      continue
    }
    if on_stack[idx] {
      return Err("graph contains a cycle")
    }
    if !visited[idx] {
      match topo_dfs_visit(g, nid, visited, on_stack, result, size) {
        Ok(r) => { let _ = r }
        Err(e) => return Err(e)
      }
    }
  }
  on_stack[cur.0] = false
  result.push(cur)
  Ok(result)
}

pub fn[G : @core.GraphReadable] topo_find_max_id(g : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(g) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}
