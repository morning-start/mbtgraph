///|
/// CSC（压缩稀疏列）格式图实现
///
/// 只读格式，与 CSR 互为转置关系。
/// CSR 按行（源节点）压缩，适合出边遍历；
/// CSC 按列（目标节点）压缩，适合入边遍历。
/// **不实现** `GraphWritable`，符合里氏替换原则 (LSP)。
pub(all) struct CSCGraph {
  nodes : Array[@core.Node]
  col_ptr : Array[Int]
  row_idx : Array[@core.NodeId]
  values : Array[Double]
}

///|
pub(all) struct CSCBuilder {
  nodes : Array[@core.Node]
  edges : Array[(@core.NodeId, @core.NodeId, Double)]
}

///|
pub fn CSCBuilder::new() -> CSCBuilder {
  { nodes: [], edges: [] }
}

///|
pub fn CSCBuilder::add_node(
  self : CSCBuilder,
  id : @core.NodeId,
  data : Double,
) -> CSCBuilder {
  let idx = id.0
  let b = self
  while idx >= b.nodes.length() {
    b.nodes.push({ id: @core.NodeId(0), data: 0.0 })
  }
  b.nodes[idx] = { id, data }
  b
}

///|
pub fn CSCBuilder::add_edge(
  self : CSCBuilder,
  from : @core.NodeId,
  to : @core.NodeId,
  weight : Double,
) -> CSCBuilder {
  let b = self
  b.edges.push((from, to, weight))
  b
}

///|
pub fn CSCBuilder::build(self : CSCBuilder) -> CSCGraph {
  let edges = self.edges
  let n = edges.length()
  let es = edges
  let mut j = 0
  while j < n {
    let mut k = 0
    while k < n - j - 1 {
      let (_, ti1, _) = es[k]
      let (_, ti2, _) = es[k + 1]
      if ti1.0 > ti2.0 {
        let tmp = es[k]
        es[k] = es[k + 1]
        es[k + 1] = tmp
      }
      k = k + 1
    }
    j = j + 1
  }
  let nc = self.nodes.length()
  let cp = Array::make(nc + 1, 0)
  let ri : Array[@core.NodeId] = []
  let vals : Array[Double] = []
  let mut cur_col = -1
  for e in es {
    ri.push(e.0)
    vals.push(e.2)
    let col = e.1.0
    if col != cur_col {
      let mut c = cur_col + 1
      while c <= col {
        cp[c] = ri.length() - 1
        c = c + 1
      }
      cur_col = col
    }
  }
  let mut c = cur_col + 1
  while c <= nc {
    cp[c] = ri.length()
    c = c + 1
  }
  { nodes: self.nodes, col_ptr: cp, row_idx: ri, values: vals }
}

///|
pub impl @core.GraphReadable for CSCGraph with node_count(self) -> Int {
  self.nodes.length()
}

///|
pub impl @core.GraphReadable for CSCGraph with edge_count(self) -> Int {
  self.row_idx.length()
}

///|
pub impl @core.GraphReadable for CSCGraph with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length()
}

///|
pub impl @core.GraphReadable for CSCGraph with contains_edge(self, from, to) -> Bool {
  let ti = to.0
  if ti < 0 || ti >= self.col_ptr.length() - 1 {
    return false
  }
  let s = self.col_ptr[ti]
  let e = self.col_ptr[ti + 1]
  for k in s..<e {
    if self.row_idx[k] == from {
      return true
    }
  }
  false
}

///|
pub impl @core.GraphReadable for CSCGraph with get_node(self, id) -> Double? {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    None
  } else {
    Some(self.nodes[idx].data)
  }
}

///|
pub impl @core.GraphReadable for CSCGraph with get_edge(self, from, to) -> Double? {
  let ti = to.0
  if ti < 0 || ti >= self.col_ptr.length() - 1 {
    return None
  }
  let s = self.col_ptr[ti]
  let e = self.col_ptr[ti + 1]
  for k in s..<e {
    if self.row_idx[k] == from {
      return Some(self.values[k])
    }
  }
  None
}

///|
pub impl @core.GraphReadable for CSCGraph with neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  if idx < 0 || idx >= self.col_ptr.length() - 1 {
    return [].iter()
  }
  let r : Array[@core.NodeId] = []
  for i in 0..<self.nodes.length() {
    if i == idx {
      continue
    }
    let s = self.col_ptr[idx]
    let e = self.col_ptr[idx + 1]
    for k in s..<e {
      if self.row_idx[k] == i {
        r.push(i)
        break
      }
    }
  }
  let s2 = self.col_ptr[idx]
  let e2 = self.col_ptr[idx + 1]
  for k in s2..<e2 {
    r.push(self.row_idx[k])
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for CSCGraph with degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.col_ptr.length() - 1 {
    0
  } else {
    self.col_ptr[idx + 1] - self.col_ptr[idx]
  }
}

///|
pub impl @core.GraphReadable for CSCGraph with is_directed(self) -> Bool {
  true
}

///|
pub impl @core.GraphReadable for CSCGraph with is_empty(self) -> Bool {
  self.nodes.length() == 0
}

///|
pub impl @core.GraphReadable for CSCGraph with node_ids(self) -> Iter[
  @core.NodeId,
] {
  let r : Array[@core.NodeId] = []
  for i in 0..<self.nodes.length() {
    r.push(self.nodes[i].id)
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for CSCGraph with edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let nc = self.nodes.length()
  for j in 0..<nc {
    let s = self.col_ptr[j]
    let e = self.col_ptr[j + 1]
    for k in s..<e {
      r.push((self.row_idx[k], @core.NodeId(j), self.values[k]))
    }
  }
  r.iter()
}

///|
pub impl @core.GraphBatchReadable for CSCGraph with batch_neighbors(
  self,
  ids : Array[@core.NodeId],
) -> Array[Array[@core.NodeId]] {
  let r : Array[Array[@core.NodeId]] = []
  for nid in ids {
    let idx = nid.0
    if idx >= 0 && idx < self.col_ptr.length() - 1 {
      let nb : Array[@core.NodeId] = []
      let s = self.col_ptr[idx]
      let e = self.col_ptr[idx + 1]
      for k in s..<e {
        nb.push(self.row_idx[k])
      }
      r.push(nb)
    } else {
      r.push([])
    }
  }
  r
}

///|
pub impl @core.GraphDirected for CSCGraph with in_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  if idx < 0 || idx >= self.col_ptr.length() - 1 {
    return [].iter()
  }
  let s = self.col_ptr[idx]
  let e = self.col_ptr[idx + 1]
  let r : Array[@core.NodeId] = []
  for k in s..<e {
    r.push(self.row_idx[k])
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for CSCGraph with out_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  let r : Array[@core.NodeId] = []
  let nc = self.nodes.length()
  for j in 0..<nc {
    let s = self.col_ptr[j]
    let e = self.col_ptr[j + 1]
    for k in s..<e {
      if self.row_idx[k] == id {
        r.push(@core.NodeId(j))
        break
      }
    }
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for CSCGraph with in_degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.col_ptr.length() - 1 {
    0
  } else {
    self.col_ptr[idx + 1] - self.col_ptr[idx]
  }
}

///|
pub impl @core.GraphDirected for CSCGraph with out_degree(self, id) -> Int {
  let idx = id.0
  let mut c = 0
  let nc = self.nodes.length()
  let mut j = 0
  while j < nc {
    let s = self.col_ptr[j]
    let e = self.col_ptr[j + 1]
    let mut k = s
    while k < e {
      if self.row_idx[k] == id {
        c = c + 1
        break
      }
      k = k + 1
    }
    j = j + 1
  }
  c
}

///|
pub impl @core.GraphDirected for CSCGraph with predecessors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let idx = id.0
  if idx < 0 || idx >= self.col_ptr.length() - 1 {
    return [].iter()
  }
  let s = self.col_ptr[idx]
  let e = self.col_ptr[idx + 1]
  let r : Array[(@core.NodeId, Double)] = []
  for k in s..<e {
    r.push((self.row_idx[k], self.values[k]))
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for CSCGraph with successors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let idx = id.0
  let r : Array[(@core.NodeId, Double)] = []
  let nc = self.nodes.length()
  for j in 0..<nc {
    let s = self.col_ptr[j]
    let e = self.col_ptr[j + 1]
    for k in s..<e {
      if self.row_idx[k] == id {
        r.push((@core.NodeId(j), self.values[k]))
        break
      }
    }
  }
  r.iter()
}

///|
pub impl @core.GraphBatchReadable for CSCGraph with batch_edges(
  self,
  pairs : Array[(@core.NodeId, @core.NodeId)],
) -> Array[Double?] {
  let r : Array[Double?] = []
  for p in pairs {
    match p {
      (f, t) => r.push(@core.GraphReadable::get_edge(self, f, t))
    }
  }
  r
}
