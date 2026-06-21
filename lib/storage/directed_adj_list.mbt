///|
/// 有向图邻接表实现
///
/// 适用于有向图场景，维护正向邻接表 `adj` 和反向邻接表 `rev_adj`。
/// 空间复杂度 O(V+2E)，支持 O(deg) 的入边/出边查询。
pub(all) struct DirectedAdjList {
  mut node_cnt : Int
  mut edge_cnt : Int
  nodes : Array[@core.Node?]
  adj : Array[Array[(@core.NodeId, Double)]]
  rev_adj : Array[Array[(@core.NodeId, Double)]]
}

///|
pub fn new_directed() -> DirectedAdjList {
  { node_cnt: 0, edge_cnt: 0, nodes: [], adj: [], rev_adj: [] }
}

///|
/// 添加边（无查重检查）
///
/// 与 add_edge 功能相同，但跳过边重复性检查。
/// 调用方需确保 (from, to) 边不存在，否则可能导致重复边。
/// 适用于批量建图等确定无重复边的场景。
pub fn DirectedAdjList::add_edge_unchecked(
  self : DirectedAdjList,
  from : @core.NodeId,
  to : @core.NodeId,
  data : Double,
) -> Result[Unit, @core.GraphError] {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.nodes.length() {
    Err(@core.GraphError::InvalidNodeId)
  } else {
    match self.nodes[fi] {
      None => Err(@core.GraphError::InvalidNodeId)
      Some(_) =>
        if ti < 0 || ti >= self.nodes.length() {
          Err(@core.GraphError::InvalidNodeId)
        } else {
          match self.nodes[ti] {
            None => Err(@core.GraphError::NodeNotFound(to))
            Some(_) => {
              let g = self
              g.adj[fi].push((to, data))
              g.rev_adj[ti].push((from, data))
              g.edge_cnt = g.edge_cnt + 1
              Ok(())
            }
          }
        }
    }
  }
}

///|
/// 批量添加边
///
/// 使用 add_edge_unchecked 批量添加多条边。
/// 一条添加失败则终止并返回错误。
pub fn DirectedAdjList::add_edges_batch(
  self : DirectedAdjList,
  edges : Array[(@core.NodeId, @core.NodeId, Double)],
) -> Result[Int, @core.GraphError] {
  let mut count = 0
  for edge in edges {
    match edge {
      (from, to, data) =>
        match self.add_edge_unchecked(from, to, data) {
          Ok(_) => count = count + 1
          Err(e) => return Err(e)
        }
    }
  }
  Ok(count)
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn node_count(self) -> Int {
  self.node_cnt
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn edge_count(self) -> Int {
  self.edge_cnt
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length() && has_node(self.nodes, idx)
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn contains_edge(
  self,
  from,
  to,
) -> Bool {
  let fi = from.0
  if fi < 0 || fi >= self.adj.length() {
    return false
  }
  for entry in self.adj[fi] {
    match entry {
      (nid, _) => if nid == to { return true }
    }
  }
  false
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn get_node(self, id) -> Double? {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    return None
  }
  match self.nodes[idx] {
    Some(n) => Some(n.data)
    None => None
  }
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn get_edge(
  self,
  from,
  to,
) -> Double? {
  let fi = from.0
  if fi < 0 || fi >= self.adj.length() {
    return None
  }
  for entry in self.adj[fi] {
    match entry {
      (nid, w) => if nid == to { return Some(w) }
    }
  }
  None
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  if idx < 0 || idx >= self.adj.length() {
    return [].iter()
  }
  let r : Array[@core.NodeId] = []
  for entry in self.adj[idx] {
    match entry {
      (nid, _) => r.push(nid)
    }
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn neighbors_with_weight(
  self,
  id,
) -> Iter[(@core.NodeId, Double)] {
  let idx = id.0
  if idx < 0 || idx >= self.adj.length() {
    return [].iter()
  }
  let r : Array[(@core.NodeId, Double)] = []
  for entry in self.adj[idx] {
    r.push(entry)
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.adj.length() {
    0
  } else {
    self.adj[idx].length()
  }
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn is_directed(self) -> Bool {
  true
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn is_empty(self) -> Bool {
  self.node_cnt == 0
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn node_ids(self) -> Iter[
  @core.NodeId,
] {
  let r : Array[@core.NodeId] = []
  for i in 0..<self.nodes.length() {
    if has_node(self.nodes, i) {
      r.push(@core.NodeId(i))
    }
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for DirectedAdjList with fn edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for i in 0..<self.nodes.length() {
    if has_node(self.nodes, i) {
      for entry in self.adj[i] {
        match entry {
          (nid, w) => r.push((@core.NodeId(i), nid, w))
        }
      }
    }
  }
  r.iter()
}

///|
pub impl @core.GraphWritable for DirectedAdjList with fn add_node(self, data) -> @core.NodeId {
  let slot = find_slot(self.nodes, 0, self.nodes.length())
  let idx = if slot >= 0 { slot } else { self.nodes.length() }
  let g = self
  if idx == g.nodes.length() {
    g.nodes.push(None)
    g.adj.push([])
    g.rev_adj.push([])
  }
  g.nodes[idx] = Some({ id: @core.NodeId(idx), data })
  g.node_cnt = g.node_cnt + 1
  @core.NodeId(idx)
}

///|
pub impl @core.GraphWritable for DirectedAdjList with fn remove_node(self, id) -> Bool {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    return false
  }
  match self.nodes[idx] {
    None => false
    Some(_) => {
      let mut g = self
      for entry in g.adj[idx] {
        match entry {
          (nid, _) => {
            g = dal_remove_rev(g, nid.0, idx)
            g.edge_cnt = g.edge_cnt - 1
          }
        }
      }
      for entry in g.rev_adj[idx] {
        match entry {
          (nid, _) => {
            g = dal_remove_from_adj(g, nid.0, idx)
            g.edge_cnt = g.edge_cnt - 1
          }
        }
      }
      g.adj[idx] = []
      g.rev_adj[idx] = []
      g.nodes[idx] = None
      g.node_cnt = g.node_cnt - 1
      true
    }
  }
}

///|
fn dal_remove_rev(
  g : DirectedAdjList,
  from_idx : Int,
  to_idx : Int,
) -> DirectedAdjList {
  if from_idx < 0 || from_idx >= g.rev_adj.length() {
    return g
  }
  let (found, nl) = remove_from_list(g.rev_adj[from_idx], to_idx)
  if !found {
    return g
  }
  let g2 = g
  g2.rev_adj[from_idx] = nl
  g2
}

///|
fn dal_remove_from_adj(
  g : DirectedAdjList,
  from_idx : Int,
  target : Int,
) -> DirectedAdjList {
  if from_idx < 0 || from_idx >= g.adj.length() {
    return g
  }
  let (found, nl) = remove_from_list(g.adj[from_idx], target)
  if !found {
    return g
  }
  let g2 = g
  g2.adj[from_idx] = nl
  g2
}

///|
pub impl @core.GraphWritable for DirectedAdjList with fn add_edge(
  self,
  from,
  to,
  data,
) -> Result[Unit, @core.GraphError] {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.nodes.length() {
    Err(@core.GraphError::InvalidNodeId)
  } else {
    match self.nodes[fi] {
      None => Err(@core.GraphError::InvalidNodeId)
      Some(_) =>
        if ti < 0 || ti >= self.nodes.length() {
          Err(@core.GraphError::InvalidNodeId)
        } else {
          match self.nodes[ti] {
            None => Err(@core.GraphError::NodeNotFound(to))
            Some(_) =>
              if dal_contains_edge(self.adj, fi, ti) {
                Err(@core.GraphError::EdgeAlreadyExists(from, to))
              } else {
                let g = self
                g.adj[fi].push((to, data))
                g.rev_adj[ti].push((from, data))
                g.edge_cnt = g.edge_cnt + 1
                Ok(())
              }
          }
        }
    }
  }
}

///|
fn dal_contains_edge(
  adj : Array[Array[(@core.NodeId, Double)]],
  fi : Int,
  ti : Int,
) -> Bool {
  if fi < 0 || fi >= adj.length() {
    return false
  }
  for entry in adj[fi] {
    match entry {
      (nid, _) => if nid.0 == ti { return true }
    }
  }
  false
}

///|
pub impl @core.GraphWritable for DirectedAdjList with fn remove_edge(
  self,
  from,
  to,
) -> Bool {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.adj.length() {
    return false
  }
  let (removed, nl) = remove_from_list(self.adj[fi], ti)
  if !removed {
    return false
  }
  let g = self
  g.adj[fi] = nl
  g.edge_cnt = g.edge_cnt - 1
  let (_, nl2) = remove_from_list(g.rev_adj[ti], fi)
  g.rev_adj[ti] = nl2
  true
}

///|
pub impl @core.GraphWritable for DirectedAdjList with fn clear(self) -> Unit {
  let g = self
  for i in 0..<g.nodes.length() {
    g.nodes[i] = None
    g.adj[i] = []
    g.rev_adj[i] = []
  }
  g.node_cnt = 0
  g.edge_cnt = 0
}

///|
pub impl @core.GraphDirected for DirectedAdjList with fn in_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  if idx < 0 || idx >= self.rev_adj.length() {
    return [].iter()
  }
  let r : Array[@core.NodeId] = []
  for entry in self.rev_adj[idx] {
    match entry {
      (nid, _) => r.push(nid)
    }
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for DirectedAdjList with fn out_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  @core.GraphReadable::neighbors(self, id)
}

///|
pub impl @core.GraphDirected for DirectedAdjList with fn in_degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.rev_adj.length() {
    0
  } else {
    self.rev_adj[idx].length()
  }
}

///|
pub impl @core.GraphDirected for DirectedAdjList with fn out_degree(self, id) -> Int {
  @core.GraphReadable::degree(self, id)
}

///|
pub impl @core.GraphDirected for DirectedAdjList with fn predecessors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let idx = id.0
  if idx < 0 || idx >= self.rev_adj.length() {
    return [].iter()
  }
  let r : Array[(@core.NodeId, Double)] = []
  for pair in self.rev_adj[idx] {
    r.push(pair)
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for DirectedAdjList with fn successors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let idx = id.0
  if idx < 0 || idx >= self.adj.length() {
    return [].iter()
  }
  let r : Array[(@core.NodeId, Double)] = []
  for pair in self.adj[idx] {
    r.push(pair)
  }
  r.iter()
}
