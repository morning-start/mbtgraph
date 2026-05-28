///|
/// 无向图邻接表实现（半存储优化版）
///
/// 采用左上角三角存储法：每条无向边仅存储一次。
/// 边 `(u, v, w)` 按 `min(u,v) < max(u,v)` 规则存入 `adj[min(u,v)]`。
pub(all) struct UndirectedAdjList {
  mut node_cnt : Int
  mut edge_cnt : Int
  nodes : Array[@core.Node?]
  adj : Array[Array[(@core.NodeId, Double)]]
}

///|
pub fn new_undirected() -> UndirectedAdjList {
  { node_cnt: 0, edge_cnt: 0, nodes: [], adj: [] }
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with node_count(self) -> Int {
  self.node_cnt
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with edge_count(self) -> Int {
  self.edge_cnt
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length() && has_node(self.nodes, idx)
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with contains_edge(
  self,
  from,
  to,
) -> Bool {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.adj.length() || ti < 0 || ti >= self.adj.length() {
    return false
  }
  let (lo, hi) = if fi < ti { (fi, ti) } else { (ti, fi) }
  for entry in self.adj[lo] {
    match entry {
      (nid, _) => if nid == hi { return true }
    }
  }
  false
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with get_node(self, id) -> Double? {
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
pub impl @core.GraphReadable for UndirectedAdjList with get_edge(self, from, to) -> Double? {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.adj.length() {
    return None
  }
  let (lo, hi) = if fi < ti { (fi, ti) } else { (ti, fi) }
  for entry in self.adj[lo] {
    match entry {
      (nid, w) => if nid == hi { return Some(w) }
    }
  }
  None
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with neighbors(self, id) -> Iter[
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
  let mut i = 0
  while i < idx {
    for entry in self.adj[i] {
      match entry {
        (nid, _) => if nid == id { r.push(@core.NodeId(i)) }
      }
    }
    i = i + 1
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.adj.length() {
    0
  } else {
    let mut d = self.adj[idx].length()
    let mut i = 0
    while i < idx {
      for entry in self.adj[i] {
        match entry {
          (nid, _) => if nid == id { d = d + 1 }
        }
      }
      i = i + 1
    }
    d
  }
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with is_directed(self) -> Bool {
  false
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with is_empty(self) -> Bool {
  self.node_cnt == 0
}

///|
pub impl @core.GraphReadable for UndirectedAdjList with node_ids(self) -> Iter[
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
pub impl @core.GraphReadable for UndirectedAdjList with edges(self) -> Iter[
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
pub impl @core.GraphWritable for UndirectedAdjList with add_node(self, data) -> @core.NodeId {
  let slot = find_slot(self.nodes, 0, self.nodes.length())
  let idx = if slot >= 0 { slot } else { self.nodes.length() }
  let g = self
  if idx == g.nodes.length() {
    g.nodes.push(None)
    g.adj.push([])
  }
  g.nodes[idx] = Some({ id: @core.NodeId(idx), data })
  g.node_cnt = g.node_cnt + 1
  @core.NodeId(idx)
}

///|
pub impl @core.GraphWritable for UndirectedAdjList with remove_node(self, id) -> Bool {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    return false
  }
  match self.nodes[idx] {
    None => false
    Some(_) => {
      let g = self
      let mut ec = 0
      for entry in g.adj[idx] {
        match entry {
          _ => ec = ec + 1
        }
      }
      let mut i = 0
      while i < idx {
        let (removed, _) = remove_from_list(g.adj[i], idx)
        if removed {
          ec = ec + 1
        }
        i = i + 1
      }
      g.edge_cnt = g.edge_cnt - ec
      g.adj[idx] = []
      g.nodes[idx] = None
      g.node_cnt = g.node_cnt - 1
      true
    }
  }
}

///|
pub impl @core.GraphWritable for UndirectedAdjList with add_edge(
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
            None => Err(@core.GraphError::InvalidNodeId)
            Some(_) =>
              if ual_contains_edge(self, from, to) {
                Err(@core.GraphError::EdgeAlreadyExists(from, to))
              } else {
                let g = self
                let (lo, hi) = if fi < ti { (fi, ti) } else { (ti, fi) }
                g.adj[lo].push((hi, data))
                g.edge_cnt = g.edge_cnt + 1
                Ok(())
              }
          }
        }
    }
  }
}

///|
fn ual_contains_edge(
  g : UndirectedAdjList,
  from : @core.NodeId,
  to : @core.NodeId,
) -> Bool {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= g.adj.length() || ti < 0 || ti >= g.adj.length() {
    return false
  }
  let (lo, hi) = if fi < ti { (fi, ti) } else { (ti, fi) }
  for entry in g.adj[lo] {
    match entry {
      (nid, _) => if nid == hi { return true }
    }
  }
  false
}

///|
pub impl @core.GraphWritable for UndirectedAdjList with remove_edge(
  self,
  from,
  to,
) -> Bool {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.adj.length() || ti < 0 || ti >= self.adj.length() {
    return false
  }
  let (lo, target) = if fi < ti { (fi, ti) } else { (ti, fi) }
  let (removed, nl) = remove_from_list(self.adj[lo], target)
  if !removed {
    return false
  }
  let g = self
  g.adj[lo] = nl
  g.edge_cnt = g.edge_cnt - 1
  true
}

///|
pub impl @core.GraphWritable for UndirectedAdjList with clear(self) -> Unit {
  let g = self
  for i in 0..<g.nodes.length() {
    g.nodes[i] = None
    g.adj[i] = []
  }
  g.node_cnt = 0
  g.edge_cnt = 0
}



