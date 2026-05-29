///|
/// 无向图邻接矩阵实现（半存储优化版）
///
/// 采用左上角三角存储法：无向边仅存储在上三角区域 (from < to)。
/// 节省约 50% 矩阵空间，查询 O(1)，遍历 O(V)。
pub(all) struct UndirectedMatrix {
  mut node_count : Int
  mut edge_count : Int
  capacity : Int
  nodes : Array[@core.Node?]
  matrix : Array[Array[Double?]]
}

///|
pub fn new_undirected_matrix(capacity : Int) -> UndirectedMatrix {
  let nodes = Array::make(capacity, None)
  let matrix : Array[Array[Double?]] = []
  for _ in 0..<capacity {
    matrix.push(Array::make(capacity, None))
  }
  { node_count: 0, edge_count: 0, capacity, nodes, matrix }
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with node_count(self) -> Int {
  self.node_count
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with edge_count(self) -> Int {
  self.edge_count
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length() && has_node(self.nodes, idx)
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with contains_edge(
  self,
  from,
  to,
) -> Bool {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.capacity || ti < 0 || ti >= self.capacity {
    false
  } else {
    let (lo, hi) = if fi < ti { (fi, ti) } else { (ti, fi) }
    match self.matrix[lo][hi] {
      Some(_) => true
      None => false
    }
  }
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with get_node(self, id) -> Double? {
  match self.nodes[id.0] {
    Some(n) => Some(n.data)
    None => None
  }
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with get_edge(self, from, to) -> Double? {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.capacity {
    return None
  }
  let (lo, hi) = if fi < ti { (fi, ti) } else { (ti, fi) }
  self.matrix[lo][hi]
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    return [].iter()
  }
  let r : Array[@core.NodeId] = []
  for j in 0..<self.capacity {
    let (lo, hi) = if idx < j { (idx, j) } else { (j, idx) }
    match self.matrix[lo][hi] {
      Some(_) => r.push(@core.NodeId(j))
      None => ()
    }
  }
  r.iter()
}

///
pub impl @core.GraphReadable for UndirectedMatrix with neighbors_with_weight(
  self,
  id,
) -> Iter[(@core.NodeId, Double)] {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    return [].iter()
  }
  let r : Array[(@core.NodeId, Double)] = []
  for j in 0..<self.capacity {
    if j == idx {
      continue
    }
    let (lo, hi) = if idx < j { (idx, j) } else { (j, idx) }
    match self.matrix[lo][hi] {
      Some(w) => r.push((@core.NodeId(j), w))
      None => ()
    }
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    0
  } else {
    let mut d = 0
    for j in 0..<self.capacity {
      let (lo, hi) = if idx < j { (idx, j) } else { (j, idx) }
      match self.matrix[lo][hi] {
        Some(_) => d = d + 1
        None => ()
      }
    }
    d
  }
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with is_directed(self) -> Bool {
  false
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with is_empty(self) -> Bool {
  self.node_count == 0
}

///|
pub impl @core.GraphReadable for UndirectedMatrix with node_ids(self) -> Iter[
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
pub impl @core.GraphReadable for UndirectedMatrix with edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for i in 0..<self.capacity {
    if has_node(self.nodes, i) {
      for j in (i + 1)..<self.capacity {
        match self.matrix[i][j] {
          Some(w) => r.push((@core.NodeId(i), @core.NodeId(j), w))
          None => ()
        }
      }
    }
  }
  r.iter()
}

///|
pub impl @core.GraphWritable for UndirectedMatrix with add_node(self, data) -> @core.NodeId {
  let slot = find_slot(self.nodes, 0, self.nodes.length())
  let idx = if slot >= 0 { slot } else { self.nodes.length() }
  let g = self
  if idx >= 0 && idx < g.capacity {
    g.nodes[idx] = Some({ id: @core.NodeId(idx), data })
    g.node_count = g.node_count + 1
  }
  @core.NodeId(idx)
}

///|
pub impl @core.GraphWritable for UndirectedMatrix with remove_node(self, id) -> Bool {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    return false
  }
  match self.nodes[idx] {
    None => false
    Some(_) => {
      let g = self
      let mut ec = 0
      for j in (idx + 1)..<g.capacity {
        match g.matrix[idx][j] {
          Some(_) => {
            ec = ec + 1
            g.matrix[idx][j] = None
          }
          None => ()
        }
      }
      for i in 0..<idx {
        match g.matrix[i][idx] {
          Some(_) => {
            ec = ec + 1
            g.matrix[i][idx] = None
          }
          None => ()
        }
      }
      g.edge_count = g.edge_count - ec
      g.nodes[idx] = None
      g.node_count = g.node_count - 1
      true
    }
  }
}

///|
pub impl @core.GraphWritable for UndirectedMatrix with add_edge(
  self,
  from,
  to,
  data,
) -> Result[Unit, @core.GraphError] {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.capacity || ti < 0 || ti >= self.capacity {
    Err(@core.GraphError::InvalidNodeId)
  } else {
    match self.nodes[fi] {
      None => Err(@core.GraphError::NodeNotFound(from))
      Some(_) =>
        match self.nodes[ti] {
          None => Err(@core.GraphError::NodeNotFound(to))
          Some(_) => {
            let (lo, hi) = if fi < ti { (fi, ti) } else { (ti, fi) }
            match self.matrix[lo][hi] {
              Some(_) => Err(@core.GraphError::EdgeAlreadyExists(from, to))
              None => {
                let g = self
                g.matrix[lo][hi] = Some(data)
                g.edge_count = g.edge_count + 1
                Ok(())
              }
            }
          }
        }
    }
  }
}

///|
pub impl @core.GraphWritable for UndirectedMatrix with remove_edge(
  self,
  from,
  to,
) -> Bool {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.capacity || ti < 0 || ti >= self.capacity {
    false
  } else {
    let (lo, hi) = if fi < ti { (fi, ti) } else { (ti, fi) }
    match self.matrix[lo][hi] {
      Some(_) => {
        let g = self
        g.matrix[lo][hi] = None
        g.edge_count = g.edge_count - 1
        true
      }
      None => false
    }
  }
}

///|
pub impl @core.GraphWritable for UndirectedMatrix with clear(self) -> Unit {
  let g = self
  for i in 0..<g.capacity {
    g.nodes[i] = None
    for j in 0..<g.capacity {
      g.matrix[i][j] = None
    }
  }
  g.node_count = 0
  g.edge_count = 0
}
