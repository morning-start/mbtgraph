///|
/// 边集数组图实现
///
/// 最简单的存储方式，边存储在连续数组中。
/// 主要适用于 Kruskal 等需要边排序的算法场景。
/// 参考: docs/design/graph_storage_survey.md §2.3
pub struct EdgeListGraph {
  mut node_cnt : Int
  nodes : Array[@core.Node?]
  mut edges : Array[@core.Edge]
}

///|
pub fn new_edge_list() -> EdgeListGraph {
  { node_cnt: 0, nodes: [], edges: [] }
}

///|
fn el_has_node(nodes : Array[@core.Node?], idx : Int) -> Bool {
  match nodes[idx] {
    None => false
    Some(_) => true
  }
}

///|
fn el_find_slot(nodes : Array[@core.Node?], i : Int, n : Int) -> Int {
  if i >= n {
    -1
  } else {
    match nodes[i] {
      None => i
      Some(_) => el_find_slot(nodes, i + 1, n)
    }
  }
}

///|
impl @core.GraphReadable for EdgeListGraph with node_count(self) -> Int {
  self.node_cnt
}

///|
impl @core.GraphReadable for EdgeListGraph with edge_count(self) -> Int {
  self.edges.length()
}

///|
impl @core.GraphReadable for EdgeListGraph with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length() && el_has_node(self.nodes, idx)
}

///|
impl @core.GraphReadable for EdgeListGraph with contains_edge(self, from, to) -> Bool {
  for e in self.edges {
    if e.from == from && e.to == to {
      return true
    }
  }
  false
}

///|
impl @core.GraphReadable for EdgeListGraph with get_node(self, id) -> Double? {
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
impl @core.GraphReadable for EdgeListGraph with get_edge(self, from, to) -> Double? {
  for e in self.edges {
    if e.from == from && e.to == to {
      return Some(e.data)
    }
  }
  None
}

///|
impl @core.GraphReadable for EdgeListGraph with neighbors(self, id) -> Iter[
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
impl @core.GraphReadable for EdgeListGraph with degree(self, id) -> Int {
  let mut c = 0
  for e in self.edges {
    if e.from == id {
      c = c + 1
    }
  }
  c
}

///|
impl @core.GraphReadable for EdgeListGraph with is_directed(self) -> Bool {
  true
}

///|
impl @core.GraphReadable for EdgeListGraph with is_empty(self) -> Bool {
  self.node_cnt == 0
}

///|
impl @core.GraphReadable for EdgeListGraph with node_ids(self) -> Iter[
  @core.NodeId,
] {
  let r : Array[@core.NodeId] = []
  for i in 0..<self.nodes.length() {
    if el_has_node(self.nodes, i) {
      r.push(@core.NodeId(i))
    }
  }
  r.iter()
}

///|
impl @core.GraphReadable for EdgeListGraph with edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for e in self.edges {
    r.push((e.from, e.to, e.data))
  }
  r.iter()
}

///|
impl @core.GraphWritable for EdgeListGraph with add_node(self, data) -> @core.NodeId {
  let slot = el_find_slot(self.nodes, 0, self.nodes.length())
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
impl @core.GraphWritable for EdgeListGraph with remove_node(self, id) -> Bool {
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
impl @core.GraphWritable for EdgeListGraph with add_edge(self, from, to, data) -> Result[
  Unit,
  @core.GraphError,
] {
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
            None => Err(@core.GraphError::InvalidNodeId)
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
impl @core.GraphWritable for EdgeListGraph with remove_edge(self, from, to) -> Bool {
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
impl @core.GraphWritable for EdgeListGraph with clear(self) -> Unit {
  let g = self
  for i in 0..<g.nodes.length() {
    g.nodes[i] = None
  }
  g.edges = []
  g.node_cnt = 0
}

///|
impl @core.GraphEdgeIterable for EdgeListGraph with edges_sorted(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let all : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for e in self.edges {
    all.push((e.from, e.to, e.data))
  }
  let sorted = el_bubble_sort(all)
  sorted.iter()
}

///|
fn el_bubble_sort(
  edges : Array[(@core.NodeId, @core.NodeId, Double)],
) -> Array[(@core.NodeId, @core.NodeId, Double)] {
  let es = edges
  let n = es.length()
  for i in 0..<n {
    for j in 0..<(n - i - 1) {
      let (_, _, w1) = es[j]
      let (_, _, w2) = es[j + 1]
      if w1 > w2 {
        let tmp = es[j]
        es[j] = es[j + 1]
        es[j + 1] = tmp
      }
    }
  }
  es
}
