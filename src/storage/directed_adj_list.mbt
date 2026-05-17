///|
/// 有向图邻接表实现
///
/// 适用于有向图场景，维护正向邻接表 `adj` 和反向邻接表 `rev_adj`。
/// 空间复杂度 O(V+2E)，支持 O(deg) 的入边/出边查询。
pub struct DirectedAdjList {
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
impl @core.GraphReadable for DirectedAdjList with node_count(self) -> Int {
  self.node_cnt
}

///|
impl @core.GraphReadable for DirectedAdjList with edge_count(self) -> Int {
  self.edge_cnt
}

///|
impl @core.GraphReadable for DirectedAdjList with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length() && has_node(self.nodes, idx)
}

///|
impl @core.GraphReadable for DirectedAdjList with contains_edge(self, from, to) -> Bool {
  let fi = from.0
  if fi < 0 || fi >= self.adj.length() {
    return false
  }
  for entry in self.adj[fi] {
    match entry {
      (nid, _) => if nid == to { return true }
      _ => ()
    }
  }
  false
}

///|
impl @core.GraphReadable for DirectedAdjList with get_node(self, id) -> Double? {
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
impl @core.GraphReadable for DirectedAdjList with get_edge(self, from, to) -> Double? {
  let fi = from.0
  if fi < 0 || fi >= self.adj.length() {
    return None
  }
  for entry in self.adj[fi] {
    match entry {
      (nid, w) => if nid == to { return Some(w) }
      _ => ()
    }
  }
  None
}

///|
impl @core.GraphReadable for DirectedAdjList with neighbors(self, id) -> Iter[
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
      _ => ()
    }
  }
  r.iter()
}

///|
impl @core.GraphReadable for DirectedAdjList with degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.adj.length() {
    0
  } else {
    self.adj[idx].length()
  }
}

///|
impl @core.GraphReadable for DirectedAdjList with is_directed(self) -> Bool {
  true
}

///|
impl @core.GraphReadable for DirectedAdjList with is_empty(self) -> Bool {
  self.node_cnt == 0
}

///|
impl @core.GraphReadable for DirectedAdjList with node_ids(self) -> Iter[
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
impl @core.GraphReadable for DirectedAdjList with edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for i in 0..<self.nodes.length() {
    if has_node(self.nodes, i) {
      for entry in self.adj[i] {
        match entry {
          (nid, w) => r.push((@core.NodeId(i), nid, w))
          _ => ()
        }
      }
    }
  }
  r.iter()
}

///|
impl @core.GraphWritable for DirectedAdjList with add_node(self, data) -> @core.NodeId {
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
impl @core.GraphWritable for DirectedAdjList with remove_node(self, id) -> Bool {
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
          _ => ()
        }
      }
      for entry in g.rev_adj[idx] {
        match entry {
          (nid, _) => {
            g = dal_remove_from_adj(g, nid.0, idx)
            g.edge_cnt = g.edge_cnt - 1
          }
          _ => ()
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
impl @core.GraphWritable for DirectedAdjList with add_edge(self, from, to, data) -> Result[
  Unit,
  @core.GraphError,
] {
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
      _ => ()
    }
  }
  false
}

///|
impl @core.GraphWritable for DirectedAdjList with remove_edge(self, from, to) -> Bool {
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
impl @core.GraphWritable for DirectedAdjList with clear(self) -> Unit {
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
impl @core.GraphDirected for DirectedAdjList with in_neighbors(self, id) -> Iter[
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
      _ => ()
    }
  }
  r.iter()
}

///|
impl @core.GraphDirected for DirectedAdjList with out_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  @core.GraphReadable::neighbors(self, id)
}

///|
impl @core.GraphDirected for DirectedAdjList with in_degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.rev_adj.length() {
    0
  } else {
    self.rev_adj[idx].length()
  }
}

///|
impl @core.GraphDirected for DirectedAdjList with out_degree(self, id) -> Int {
  @core.GraphReadable::degree(self, id)
}

///|
impl @core.GraphDirected for DirectedAdjList with predecessors(self, id) -> Iter[
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
impl @core.GraphDirected for DirectedAdjList with successors(self, id) -> Iter[
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
