///|
/// 邻接矩阵图实现
///
/// 适用于小规模稠密图（V < 1000）。
/// 查询边存在性 O(1)，遍历邻居 O(V)。
/// 参考: docs/design/graph_storage_survey.md §2.1
pub struct AdjacencyMatrixGraph {
  mut node_count : Int
  mut edge_count : Int
  capacity : Int
  nodes : Array[@core.Node?]
  matrix : Array[Array[Double?]]
  directed : Bool
}

///|
pub fn new_matrix(capacity : Int, directed : Bool) -> AdjacencyMatrixGraph {
  let nodes = Array::make(capacity, None)
  let matrix = Array::make(capacity, Array::make(capacity, None))
  let m = { node_count: 0, edge_count: 0, capacity, nodes, matrix, directed }
  m
}

///|
fn am_has_node(nodes : Array[@core.Node?], idx : Int) -> Bool {
  match nodes[idx] {
    None => false
    Some(_) => true
  }
}

///|
fn am_count_row(matrix : Array[Array[Double?]], cap : Int, row : Int) -> Int {
  am_count_row_acc(matrix, cap, row, 0, 0)
}

///|
fn am_count_row_acc(
  matrix : Array[Array[Double?]],
  cap : Int,
  row : Int,
  j : Int,
  acc : Int,
) -> Int {
  if j >= cap {
    acc
  } else {
    match matrix[row][j] {
      None => am_count_row_acc(matrix, cap, row, j + 1, acc)
      Some(_) => am_count_row_acc(matrix, cap, row, j + 1, acc + 1)
    }
  }
}

///|
fn am_count_col(matrix : Array[Array[Double?]], cap : Int, col : Int) -> Int {
  am_count_col_acc(matrix, cap, col, 0, 0)
}

///|
fn am_count_col_acc(
  matrix : Array[Array[Double?]],
  cap : Int,
  col : Int,
  i : Int,
  acc : Int,
) -> Int {
  if i >= cap {
    acc
  } else {
    match matrix[i][col] {
      None => am_count_col_acc(matrix, cap, col, i + 1, acc)
      Some(_) => am_count_col_acc(matrix, cap, col, i + 1, acc + 1)
    }
  }
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with node_count(self) -> Int {
  self.node_count
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with edge_count(self) -> Int {
  self.edge_count
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length() && am_has_node(self.nodes, idx)
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with contains_edge(
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
impl @core.GraphReadable for AdjacencyMatrixGraph with get_node(self, id) -> Double? {
  match self.nodes[id.0] {
    Some(n) => Some(n.data)
    None => None
  }
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with get_edge(self, from, to) -> Double? {
  self.matrix[from.0][to.0]
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with neighbors(self, id) -> Iter[
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
impl @core.GraphReadable for AdjacencyMatrixGraph with degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    0
  } else {
    am_count_row(self.matrix, self.capacity, idx)
  }
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with is_directed(self) -> Bool {
  self.directed
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with is_empty(self) -> Bool {
  self.node_count == 0
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with node_ids(self) -> Iter[
  @core.NodeId,
] {
  let r : Array[@core.NodeId] = []
  for i in 0..<self.nodes.length() {
    if am_has_node(self.nodes, i) {
      r.push(@core.NodeId(i))
    }
  }
  r.iter()
}

///|
impl @core.GraphReadable for AdjacencyMatrixGraph with edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for i in 0..<self.capacity {
    if am_has_node(self.nodes, i) {
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
impl @core.GraphWritable for AdjacencyMatrixGraph with add_node(self, data) -> @core.NodeId {
  let slot = am_find_slot(self.nodes, 0, self.nodes.length())
  let idx = if slot >= 0 { slot } else { self.nodes.length() }
  let g = self
  if idx >= 0 && idx < g.capacity {
    g.nodes[idx] = Some({ id: @core.NodeId(idx), data })
    g.node_count = g.node_count + 1
  }
  @core.NodeId(idx)
}

///|
fn am_find_slot(nodes : Array[@core.Node?], i : Int, n : Int) -> Int {
  if i >= n {
    -1
  } else {
    match nodes[i] {
      None => i
      Some(_) => am_find_slot(nodes, i + 1, n)
    }
  }
}

///|
impl @core.GraphWritable for AdjacencyMatrixGraph with remove_node(self, id) -> Bool {
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
impl @core.GraphWritable for AdjacencyMatrixGraph with add_edge(
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
                if !g.directed {
                  g.matrix[ti][fi] = Some(data)
                  g.edge_count = g.edge_count + 1
                }
                Ok(())
              }
            }
        }
    }
  }
}

///|
impl @core.GraphWritable for AdjacencyMatrixGraph with remove_edge(
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
      Some(_) => {
        let g = self
        g.matrix[fi][ti] = None
        g.edge_count = g.edge_count - 1
        if !g.directed {
          g.matrix[ti][fi] = None
          g.edge_count = g.edge_count - 1
        }
        true
      }
      None => false
    }
  }
}

///|
impl @core.GraphWritable for AdjacencyMatrixGraph with clear(self) -> Unit {
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
impl @core.GraphDirected for AdjacencyMatrixGraph with in_neighbors(self, id) -> Iter[
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
impl @core.GraphDirected for AdjacencyMatrixGraph with out_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  @core.GraphReadable::neighbors(self, id)
}

///|
impl @core.GraphDirected for AdjacencyMatrixGraph with in_degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.capacity {
    0
  } else {
    am_count_col(self.matrix, self.capacity, idx)
  }
}

///|
impl @core.GraphDirected for AdjacencyMatrixGraph with out_degree(self, id) -> Int {
  @core.GraphReadable::degree(self, id)
}

///|
impl @core.GraphDirected for AdjacencyMatrixGraph with predecessors(self, id) -> Iter[
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
impl @core.GraphDirected for AdjacencyMatrixGraph with successors(self, id) -> Iter[
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
