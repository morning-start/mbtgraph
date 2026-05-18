///|
/// 有向图邻接矩阵实现
///
/// 适用于小规模稠密有向图（V < 1000）。
/// 查询边存在性 O(1)，遍历邻居 O(V)。
pub(all) struct DirectedMatrix {
  mut node_count : Int
  mut edge_count : Int
  capacity : Int
  nodes : Array[@core.Node?]
  matrix : Array[Array[Double?]]
}

///|
pub fn new_directed_matrix(capacity : Int) -> DirectedMatrix {
  let nodes = Array::make(capacity, None)
  let matrix : Array[Array[Double?]] = []
  for _ in 0..<capacity {
    matrix.push(Array::make(capacity, None))
  }
  { node_count: 0, edge_count: 0, capacity, nodes, matrix }
}

///|
pub impl @core.GraphReadable for DirectedMatrix with node_count(self) -> Int {
  self.node_count
}

///|
pub impl @core.GraphReadable for DirectedMatrix with edge_count(self) -> Int {
  self.edge_count
}

///|
pub impl @core.GraphReadable for DirectedMatrix with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length() && has_node(self.nodes, idx)
}

///|
pub impl @core.GraphReadable for DirectedMatrix with contains_edge(
  self,
  from,
  to,
) -> Bool {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.capacity || ti < 0 || ti >= self.capacity {
    false
  } else {
    match self.matrix[fi][ti] {
      Some(_) => true
      None => false
    }
  }
}

///|
pub impl @core.GraphReadable for DirectedMatrix with get_node(self, id) -> Double? {
  match self.nodes[id.0] {
    Some(n) => Some(n.data)
    None => None
  }
}

///|
pub impl @core.GraphReadable for DirectedMatrix with get_edge(self, from, to) -> Double? {
  self.matrix[from.0][to.0]
}

///|
pub impl @core.GraphReadable for DirectedMatrix with neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    return [].iter()
  }
  let r : Array[@core.NodeId] = []
  for j in 0..<self.capacity {
    match self.matrix[idx][j] {
      Some(_) => r.push(@core.NodeId(j))
      None => ()
    }
  }
  r.iter()
}

///|
fn dm_count_row(matrix : Array[Array[Double?]], cap : Int, row : Int) -> Int {
  let mut c = 0
  let mut j = 0
  while j < cap {
    match matrix[row][j] {
      Some(_) => c = c + 1
      None => ()
    }
    j = j + 1
  }
  c
}

///|
pub impl @core.GraphReadable for DirectedMatrix with degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    0
  } else {
    dm_count_row(self.matrix, self.capacity, idx)
  }
}

///|
pub impl @core.GraphReadable for DirectedMatrix with is_directed(self) -> Bool {
  true
}

///|
pub impl @core.GraphReadable for DirectedMatrix with is_empty(self) -> Bool {
  self.node_count == 0
}

///|
pub impl @core.GraphReadable for DirectedMatrix with node_ids(self) -> Iter[
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
pub impl @core.GraphReadable for DirectedMatrix with edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for i in 0..<self.capacity {
    if has_node(self.nodes, i) {
      for j in 0..<self.capacity {
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
pub impl @core.GraphWritable for DirectedMatrix with add_node(self, data) -> @core.NodeId {
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
pub impl @core.GraphWritable for DirectedMatrix with remove_node(self, id) -> Bool {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    return false
  }
  match self.nodes[idx] {
    None => false
    Some(_) => {
      let g = self
      for j in 0..<g.capacity {
        match g.matrix[idx][j] {
          Some(_) => {
            g.matrix[idx][j] = None
            g.edge_count = g.edge_count - 1
          }
          None => ()
        }
      }
      for i in 0..<g.capacity {
        match g.matrix[i][idx] {
          Some(_) => {
            g.matrix[i][idx] = None
            g.edge_count = g.edge_count - 1
          }
          None => ()
        }
      }
      g.nodes[idx] = None
      g.node_count = g.node_count - 1
      true
    }
  }
}

///|
pub impl @core.GraphWritable for DirectedMatrix with add_edge(
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
          Some(_) =>
            match self.matrix[fi][ti] {
              Some(_) => Err(@core.GraphError::EdgeAlreadyExists(from, to))
              None => {
                let g = self
                g.matrix[fi][ti] = Some(data)
                g.edge_count = g.edge_count + 1
                Ok(())
              }
            }
        }
    }
  }
}

///|
pub impl @core.GraphWritable for DirectedMatrix with remove_edge(self, from, to) -> Bool {
  let fi = from.0
  let ti = to.0
  if fi < 0 || fi >= self.capacity || ti < 0 || ti >= self.capacity {
    false
  } else {
    match self.matrix[fi][ti] {
      Some(_) => {
        let g = self
        g.matrix[fi][ti] = None
        g.edge_count = g.edge_count - 1
        true
      }
      None => false
    }
  }
}

///|
pub impl @core.GraphWritable for DirectedMatrix with clear(self) -> Unit {
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

///|
pub impl @core.GraphDirected for DirectedMatrix with in_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    return [].iter()
  }
  let r : Array[@core.NodeId] = []
  for i in 0..<self.capacity {
    match self.matrix[i][idx] {
      Some(_) => r.push(@core.NodeId(i))
      None => ()
    }
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for DirectedMatrix with out_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  @core.GraphReadable::neighbors(self, id)
}

///|
fn dm_count_col(matrix : Array[Array[Double?]], cap : Int, col : Int) -> Int {
  let mut c = 0
  let mut i = 0
  while i < cap {
    match matrix[i][col] {
      Some(_) => c = c + 1
      None => ()
    }
    i = i + 1
  }
  c
}

///|
pub impl @core.GraphDirected for DirectedMatrix with in_degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    0
  } else {
    dm_count_col(self.matrix, self.capacity, idx)
  }
}

///|
pub impl @core.GraphDirected for DirectedMatrix with out_degree(self, id) -> Int {
  @core.GraphReadable::degree(self, id)
}

///|
pub impl @core.GraphDirected for DirectedMatrix with predecessors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    return [].iter()
  }
  let r : Array[(@core.NodeId, Double)] = []
  for i in 0..<self.capacity {
    match self.matrix[i][idx] {
      Some(w) => r.push((@core.NodeId(i), w))
      None => ()
    }
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for DirectedMatrix with successors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    return [].iter()
  }
  let r : Array[(@core.NodeId, Double)] = []
  for j in 0..<self.capacity {
    match self.matrix[idx][j] {
      Some(w) => r.push((@core.NodeId(j), w))
      None => ()
    }
  }
  r.iter()
}
