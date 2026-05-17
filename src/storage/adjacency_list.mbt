///|
/// 邻接表图实现
///
/// 默认通用实现，支持动态增删节点/边。
/// 空间复杂度 O(V+E)，适合大多数稀疏图场景。
/// 参考: docs/design/graph_storage_survey.md §2.2
pub struct AdjacencyListGraph {
  mut node_cnt : Int
  mut edge_cnt : Int
  nodes : Array[@core.Node?]
  adj : Array[Array[(@core.NodeId, Double)]]
  directed : Bool
  rev_adj : Array[Array[(@core.NodeId, Double)]]
}

///|
pub fn new(directed : Bool) -> AdjacencyListGraph {
  { node_cnt: 0, edge_cnt: 0, nodes: [], adj: [], directed, rev_adj: [] }
}

///|
fn al_has_node(nodes : Array[@core.Node?], idx : Int) -> Bool {
  match nodes[idx] {
    None => false
    Some(_) => true
  }
}

///|
fn al_find_slot(nodes : Array[@core.Node?], i : Int, n : Int) -> Int {
  if i >= n {
    -1
  } else {
    match nodes[i] {
      None => i
      Some(_) => al_find_slot(nodes, i + 1, n)
    }
  }
}

///|
fn al_ensure(g : AdjacencyListGraph, idx : Int) -> Unit {
  let g = g
  while idx >= g.nodes.length() {
    g.nodes.push(None)
    g.adj.push([])
    g.rev_adj.push([])
  }
}

///|
impl @core.GraphReadable for AdjacencyListGraph with node_count(self) -> Int {
  self.node_cnt
}

///|
impl @core.GraphReadable for AdjacencyListGraph with edge_count(self) -> Int {
  self.edge_cnt
}

///|
impl @core.GraphReadable for AdjacencyListGraph with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length() && al_has_node(self.nodes, idx)
}

///|
impl @core.GraphReadable for AdjacencyListGraph with contains_edge(
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
      _ => ()
    }
  }
  false
}

///|
impl @core.GraphReadable for AdjacencyListGraph with get_node(self, id) -> Double? {
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
impl @core.GraphReadable for AdjacencyListGraph with get_edge(self, from, to) -> Double? {
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
impl @core.GraphReadable for AdjacencyListGraph with neighbors(self, id) -> Iter[
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
impl @core.GraphReadable for AdjacencyListGraph with degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.adj.length() {
    0
  } else {
    self.adj[idx].length()
  }
}

///|
impl @core.GraphReadable for AdjacencyListGraph with is_directed(self) -> Bool {
  self.directed
}

///|
impl @core.GraphReadable for AdjacencyListGraph with is_empty(self) -> Bool {
  self.node_cnt == 0
}

///|
impl @core.GraphReadable for AdjacencyListGraph with node_ids(self) -> Iter[
  @core.NodeId,
] {
  let r : Array[@core.NodeId] = []
  for i in 0..<self.nodes.length() {
    if al_has_node(self.nodes, i) {
      r.push(@core.NodeId(i))
    }
  }
  r.iter()
}

///|
impl @core.GraphReadable for AdjacencyListGraph with edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for i in 0..<self.nodes.length() {
    if al_has_node(self.nodes, i) {
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
impl @core.GraphWritable for AdjacencyListGraph with add_node(self, data) -> @core.NodeId {
  let slot = al_find_slot(self.nodes, 0, self.nodes.length())
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
impl @core.GraphWritable for AdjacencyListGraph with remove_node(self, id) -> Bool {
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
            g = al_remove_rev(g, nid.0, idx)
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
fn al_remove_rev(
  g : AdjacencyListGraph,
  from_idx : Int,
  to_idx : Int,
) -> AdjacencyListGraph {
  if from_idx < 0 || from_idx >= g.rev_adj.length() {
    return g
  }
  let nl : Array[(@core.NodeId, Double)] = []
  for entry in g.rev_adj[from_idx] {
    match entry {
      (nid, w) => if nid.0 != to_idx { nl.push((nid, w)) }
      _ => ()
    }
  }
  let g2 = g
  g2.rev_adj[from_idx] = nl
  g2
}

///|
impl @core.GraphWritable for AdjacencyListGraph with add_edge(
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
              if al_contains_edge(self.adj, fi, ti) {
                Err(@core.GraphError::EdgeAlreadyExists(from, to))
              } else {
                let g = self
                g.adj[fi].push((to, data))
                g.edge_cnt = g.edge_cnt + 1
                if !g.directed {
                  g.adj[ti].push((from, data))
                  g.edge_cnt = g.edge_cnt + 1
                } else {
                  g.rev_adj[ti].push((from, data))
                }
                Ok(())
              }
          }
        }
    }
  }
}

///|
fn al_contains_edge(
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
impl @core.GraphWritable for AdjacencyListGraph with remove_edge(self, from, to) -> Bool {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.adj.length() {
    return false
  }
  let (removed, nl) = al_remove_from_list(self.adj[fi], ti)
  if !removed {
    return false
  }
  let g = self
  g.adj[fi] = nl
  g.edge_cnt = g.edge_cnt - 1
  if !g.directed {
    let (_, nl2) = al_remove_from_list(g.adj[ti], fi)
    g.adj[ti] = nl2
    g.edge_cnt = g.edge_cnt - 1
  } else {
    let (_, nl2) = al_remove_from_list(g.rev_adj[ti], fi)
    g.rev_adj[ti] = nl2
  }
  true
}

///|
fn al_remove_from_list(
  list : Array[(@core.NodeId, Double)],
  target : Int,
) -> (Bool, Array[(@core.NodeId, Double)]) {
  let nl : Array[(@core.NodeId, Double)] = []
  let mut found = false
  for entry in list {
    match entry {
      (nid, w) => if nid.0 == target { found = true } else { nl.push((nid, w)) }
      _ => ()
    }
  }
  (found, nl)
}

///|
impl @core.GraphWritable for AdjacencyListGraph with clear(self) -> Unit {
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
impl @core.GraphDirected for AdjacencyListGraph with in_neighbors(self, id) -> Iter[
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
impl @core.GraphDirected for AdjacencyListGraph with out_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  @core.GraphReadable::neighbors(self, id)
}

///|
impl @core.GraphDirected for AdjacencyListGraph with in_degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.rev_adj.length() {
    0
  } else {
    self.rev_adj[idx].length()
  }
}

///|
impl @core.GraphDirected for AdjacencyListGraph with out_degree(self, id) -> Int {
  @core.GraphReadable::degree(self, id)
}

///|
impl @core.GraphDirected for AdjacencyListGraph with predecessors(self, id) -> Iter[
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
impl @core.GraphDirected for AdjacencyListGraph with successors(self, id) -> Iter[
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

///|
impl @core.GraphEdgeIterable for AdjacencyListGraph with edges_sorted(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let all : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for i in 0..<self.nodes.length() {
    if al_has_node(self.nodes, i) {
      for entry in self.adj[i] {
        match entry {
          (nid, w) => all.push((@core.NodeId(i), nid, w))
          _ => ()
        }
      }
    }
  }
  let sorted = al_bubble_sort_edges(all)
  sorted.iter()
}

///|
fn al_bubble_sort_edges(
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
