///|
/// 边集数组图实现（有向专用）
///
/// 最简单的存储方式，边存储在连续数组中。
/// 适用于 Kruskal 等需要边排序的算法场景。
pub(all) struct EdgeListGraph {
  mut node_cnt : Int
  nodes : Array[@core.Node?]
  mut edges : Array[@core.Edge]
}

///|
pub fn new_edge_list() -> EdgeListGraph {
  { node_cnt: 0, nodes: [], edges: [] }
}

///|
pub impl @core.GraphReadable for EdgeListGraph with node_count(self) -> Int {
  self.node_cnt
}

///|
pub impl @core.GraphReadable for EdgeListGraph with edge_count(self) -> Int {
  self.edges.length()
}

///|
pub impl @core.GraphReadable for EdgeListGraph with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length() && has_node(self.nodes, idx)
}

///|
pub impl @core.GraphReadable for EdgeListGraph with contains_edge(
  self,
  from,
  to,
) -> Bool {
  for e in self.edges {
    if e.from == from && e.to == to {
      return true
    }
  }
  false
}

///|
pub impl @core.GraphReadable for EdgeListGraph with get_node(self, id) -> Double? {
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
pub impl @core.GraphReadable for EdgeListGraph with get_edge(self, from, to) -> Double? {
  for e in self.edges {
    if e.from == from && e.to == to {
      return Some(e.data)
    }
  }
  None
}

///|
pub impl @core.GraphReadable for EdgeListGraph with neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let r : Array[@core.NodeId] = []
  for e in self.edges {
    if e.from == id {
      r.push(e.to)
    }
  }
  r.iter()
}

///
pub impl @core.GraphReadable for EdgeListGraph with neighbors_with_weight(
  self,
  id,
) -> Iter[(@core.NodeId, Double)] {
  let r : Array[(@core.NodeId, Double)] = []
  for e in self.edges {
    if e.from == id {
      r.push((e.to, e.data))
    }
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for EdgeListGraph with degree(self, id) -> Int {
  let mut c = 0
  for e in self.edges {
    if e.from == id {
      c = c + 1
    }
  }
  c
}

///|
pub impl @core.GraphReadable for EdgeListGraph with is_directed(self) -> Bool {
  true
}

///|
pub impl @core.GraphReadable for EdgeListGraph with is_empty(self) -> Bool {
  self.node_cnt == 0
}

///|
pub impl @core.GraphReadable for EdgeListGraph with node_ids(self) -> Iter[
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
pub impl @core.GraphReadable for EdgeListGraph with edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for e in self.edges {
    r.push((e.from, e.to, e.data))
  }
  r.iter()
}

///|
pub impl @core.GraphWritable for EdgeListGraph with add_node(self, data) -> @core.NodeId {
  let slot = find_slot(self.nodes, 0, self.nodes.length())
  let idx = if slot >= 0 { slot } else { self.nodes.length() }
  let g = self
  if idx == g.nodes.length() {
    g.nodes.push(None)
  }
  g.nodes[idx] = Some({ id: @core.NodeId(idx), data })
  g.node_cnt = g.node_cnt + 1
  @core.NodeId(idx)
}

///|
pub impl @core.GraphWritable for EdgeListGraph with remove_node(self, id) -> Bool {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    return false
  }
  match self.nodes[idx] {
    None => false
    Some(_) => {
      let ne : Array[@core.Edge] = []
      for e in self.edges {
        if e.from != id && e.to != id {
          ne.push(e)
        }
      }
      let g = self
      g.edges = ne
      g.nodes[idx] = None
      g.node_cnt = g.node_cnt - 1
      true
    }
  }
}

///|
pub impl @core.GraphWritable for EdgeListGraph with add_edge(
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
      None => Err(@core.GraphError::NodeNotFound(from))
      Some(_) =>
        if ti < 0 || ti >= self.nodes.length() {
          Err(@core.GraphError::InvalidNodeId)
        } else {
          match self.nodes[ti] {
            None => Err(@core.GraphError::NodeNotFound(to))
            Some(_) => {
              let g = self
              g.edges.push({ from, to, data })
              Ok(())
            }
          }
        }
    }
  }
}

///|
pub impl @core.GraphWritable for EdgeListGraph with remove_edge(self, from, to) -> Bool {
  let ne : Array[@core.Edge] = []
  let mut found = false
  for e in self.edges {
    if e.from == from && e.to == to {
      found = true
    } else {
      ne.push(e)
    }
  }
  let g = self
  g.edges = ne
  found
}

///|
pub impl @core.GraphWritable for EdgeListGraph with clear(self) -> Unit {
  let g = self
  for i in 0..<g.nodes.length() {
    g.nodes[i] = None
  }
  g.edges = []
  g.node_cnt = 0
}



///|
pub impl @core.GraphDirected for EdgeListGraph with in_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let r : Array[@core.NodeId] = []
  for e in self.edges {
    if e.to == id {
      r.push(e.from)
    }
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for EdgeListGraph with out_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let r : Array[@core.NodeId] = []
  for e in self.edges {
    if e.from == id {
      r.push(e.to)
    }
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for EdgeListGraph with in_degree(self, id) -> Int {
  let mut c = 0
  for e in self.edges {
    if e.to == id {
      c = c + 1
    }
  }
  c
}

///|
pub impl @core.GraphDirected for EdgeListGraph with out_degree(self, id) -> Int {
  let mut c = 0
  for e in self.edges {
    if e.from == id {
      c = c + 1
    }
  }
  c
}

///|
pub impl @core.GraphDirected for EdgeListGraph with predecessors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, Double)] = []
  for e in self.edges {
    if e.to == id {
      r.push((e.from, e.data))
    }
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for EdgeListGraph with successors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, Double)] = []
  for e in self.edges {
    if e.from == id {
      r.push((e.to, e.data))
    }
  }
  r.iter()
}
