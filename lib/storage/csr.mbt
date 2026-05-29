///|
/// CSR（压缩稀疏行）格式图实现
///
/// 只读格式，适合大规模图计算（亿级节点）。
/// 内存效率极高，缓存局部性极佳。
/// **不实现** `GraphWritable`，符合里氏替换原则 (LSP)。
pub(all) struct CSRGraph {
  nodes : Array[@core.Node]
  row_ptr : Array[Int]
  col_idx : Array[@core.NodeId]
  values : Array[Double]
  in_ptr : Array[Int]
  in_idx : Array[@core.NodeId]
  in_vals : Array[Double]
}

///|
pub(all) struct CSRBuilder {
  nodes : Array[@core.Node]
  edges : Array[(@core.NodeId, @core.NodeId, Double)]
}

///|
pub fn CSRBuilder::new() -> CSRBuilder {
  { nodes: [], edges: [] }
}

///|
pub fn CSRBuilder::add_node(
  self : CSRBuilder,
  id : @core.NodeId,
  data : Double,
) -> CSRBuilder {
  let idx = id.0
  let b = self
  while idx >= b.nodes.length() {
    b.nodes.push({ id: @core.NodeId(0), data: 0.0 })
  }
  b.nodes[idx] = { id, data }
  b
}

///|
pub fn CSRBuilder::add_edge(
  self : CSRBuilder,
  from : @core.NodeId,
  to : @core.NodeId,
  weight : Double,
) -> CSRBuilder {
  let b = self
  b.edges.push((from, to, weight))
  b
}

///|
fn csr_qsort(
  es : Array[(@core.NodeId, @core.NodeId, Double)],
  lo : Int,
  hi : Int,
) -> Unit {
  if lo < hi {
    let p = csr_partition(es, lo, hi)
    csr_qsort(es, lo, p - 1)
    csr_qsort(es, p + 1, hi)
  }
}

///|
fn csr_partition(
  es : Array[(@core.NodeId, @core.NodeId, Double)],
  lo : Int,
  hi : Int,
) -> Int {
  let pivot = es[hi].0.0
  let mut i = lo - 1
  let mut j = lo
  while j < hi {
    if es[j].0.0 <= pivot {
      i = i + 1
      let tmp = es[i]
      es[i] = es[j]
      es[j] = tmp
    }
    j = j + 1
  }
  let tmp = es[i + 1]
  es[i + 1] = es[hi]
  es[hi] = tmp
  i + 1
}

///|
pub fn CSRBuilder::build(self : CSRBuilder) -> CSRGraph {
  let es = self.edges
  let n = es.length()
  if n > 0 {
    csr_qsort(es, 0, n - 1)
  }
  let nc = self.nodes.length()
  let rp = Array::make(nc + 1, 0)
  let ci : Array[@core.NodeId] = []
  let vals : Array[Double] = []
  let mut cur_row = -1
  for e in es {
    ci.push(e.1)
    vals.push(e.2)
    let row = e.0.0
    if row != cur_row {
      let mut r = cur_row + 1
      while r <= row {
        rp[r] = ci.length() - 1
        r = r + 1
      }
      cur_row = row
    }
  }
  let mut r = cur_row + 1
  while r <= nc {
    rp[r] = ci.length()
    r = r + 1
  }
  // Build reverse index (in_ptr / in_idx / in_vals) in O(n + E)
  let in_deg = Array::make(nc, 0)
  for e in es {
    let ti = e.1.0
    if ti >= 0 && ti < nc {
      in_deg[ti] = in_deg[ti] + 1
    }
  }
  let in_ptr = Array::make(nc + 1, 0)
  let mut sum = 0
  for i in 0..<nc {
    in_ptr[i] = sum
    sum = sum + in_deg[i]
  }
  in_ptr[nc] = sum
  let in_idx : Array[@core.NodeId] = Array::make(sum, @core.NodeId(0))
  let in_vals : Array[Double] = Array::make(sum, 0.0)
  let pos = Array::make(nc, 0)
  for i in 0..<nc {
    pos[i] = in_ptr[i]
  }
  for e in es {
    let ti = e.1.0
    if ti >= 0 && ti < nc {
      let p = pos[ti]
      in_idx[p] = e.0
      in_vals[p] = e.2
      pos[ti] = p + 1
    }
  }
  {
    nodes: self.nodes,
    row_ptr: rp,
    col_idx: ci,
    values: vals,
    in_ptr: in_ptr,
    in_idx: in_idx,
    in_vals: in_vals,
  }
}

///|
pub impl @core.GraphReadable for CSRGraph with node_count(self) -> Int {
  self.nodes.length()
}

///|
pub impl @core.GraphReadable for CSRGraph with edge_count(self) -> Int {
  self.col_idx.length()
}

///|
pub impl @core.GraphReadable for CSRGraph with contains_node(self, id) -> Bool {
  let idx = id.0
  idx >= 0 && idx < self.nodes.length()
}

///|
pub impl @core.GraphReadable for CSRGraph with contains_edge(self, from, to) -> Bool {
  let fi = from.0
  if fi < 0 || fi >= self.row_ptr.length() - 1 {
    return false
  }
  let s = self.row_ptr[fi]
  let e = self.row_ptr[fi + 1]
  for k in s..<e {
    if self.col_idx[k] == to {
      return true
    }
  }
  false
}

///|
pub impl @core.GraphReadable for CSRGraph with get_node(self, id) -> Double? {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    None
  } else {
    Some(self.nodes[idx].data)
  }
}

///|
pub impl @core.GraphReadable for CSRGraph with get_edge(self, from, to) -> Double? {
  let fi = from.0
  if fi < 0 || fi >= self.row_ptr.length() - 1 {
    return None
  }
  let s = self.row_ptr[fi]
  let e = self.row_ptr[fi + 1]
  for k in s..<e {
    if self.col_idx[k] == to {
      return Some(self.values[k])
    }
  }
  None
}

///|
pub impl @core.GraphReadable for CSRGraph with neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  if idx < 0 || idx >= self.row_ptr.length() - 1 {
    return [].iter()
  }
  let s = self.row_ptr[idx]
  let e = self.row_ptr[idx + 1]
  let r : Array[@core.NodeId] = []
  for k in s..<e {
    r.push(self.col_idx[k])
  }
  r.iter()
}

///
pub impl @core.GraphReadable for CSRGraph with neighbors_with_weight(
  self,
  id,
) -> Iter[(@core.NodeId, Double)] {
  let idx = id.0
  if idx < 0 || idx >= self.row_ptr.length() - 1 {
    return [].iter()
  }
  let s = self.row_ptr[idx]
  let e = self.row_ptr[idx + 1]
  let r : Array[(@core.NodeId, Double)] = []
  for k in s..<e {
    r.push((self.col_idx[k], self.values[k]))
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for CSRGraph with degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.row_ptr.length() - 1 {
    0
  } else {
    self.row_ptr[idx + 1] - self.row_ptr[idx]
  }
}

///|
pub impl @core.GraphReadable for CSRGraph with is_directed(self) -> Bool {
  true
}

///|
pub impl @core.GraphReadable for CSRGraph with is_empty(self) -> Bool {
  self.nodes.length() == 0
}

///|
pub impl @core.GraphReadable for CSRGraph with node_ids(self) -> Iter[
  @core.NodeId,
] {
  let r : Array[@core.NodeId] = []
  for i in 0..<self.nodes.length() {
    r.push(self.nodes[i].id)
  }
  r.iter()
}

///|
pub impl @core.GraphReadable for CSRGraph with edges(self) -> Iter[
  (@core.NodeId, @core.NodeId, Double),
] {
  let r : Array[(@core.NodeId, @core.NodeId, Double)] = []
  let nc = self.nodes.length()
  for i in 0..<nc {
    let s = self.row_ptr[i]
    let e = self.row_ptr[i + 1]
    for k in s..<e {
      r.push((@core.NodeId(i), self.col_idx[k], self.values[k]))
    }
  }
  r.iter()
}

///|
pub impl @core.GraphBatchReadable for CSRGraph with batch_neighbors(
  self,
  ids : Array[@core.NodeId],
) -> Array[Array[@core.NodeId]] {
  let r : Array[Array[@core.NodeId]] = []
  for nid in ids {
    let idx = nid.0
    if idx >= 0 && idx < self.row_ptr.length() - 1 {
      let s = self.row_ptr[idx]
      let e = self.row_ptr[idx + 1]
      let nb : Array[@core.NodeId] = []
      for k in s..<e {
        nb.push(self.col_idx[k])
      }
      r.push(nb)
    } else {
      r.push([])
    }
  }
  r
}

///|
pub impl @core.GraphDirected for CSRGraph with in_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    return [].iter()
  }
  let s = self.in_ptr[idx]
  let e = self.in_ptr[idx + 1]
  let r : Array[@core.NodeId] = []
  for k in s..<e {
    r.push(self.in_idx[k])
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for CSRGraph with out_neighbors(self, id) -> Iter[
  @core.NodeId,
] {
  @core.GraphReadable::neighbors(self, id)
}

///|
pub impl @core.GraphDirected for CSRGraph with in_degree(self, id) -> Int {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    0
  } else {
    self.in_ptr[idx + 1] - self.in_ptr[idx]
  }
}

///|
pub impl @core.GraphDirected for CSRGraph with out_degree(self, id) -> Int {
  @core.GraphReadable::degree(self, id)
}

///|
pub impl @core.GraphDirected for CSRGraph with predecessors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let idx = id.0
  if idx < 0 || idx >= self.nodes.length() {
    return [].iter()
  }
  let s = self.in_ptr[idx]
  let e = self.in_ptr[idx + 1]
  let r : Array[(@core.NodeId, Double)] = []
  for k in s..<e {
    r.push((self.in_idx[k], self.in_vals[k]))
  }
  r.iter()
}

///|
pub impl @core.GraphDirected for CSRGraph with successors(self, id) -> Iter[
  (@core.NodeId, Double),
] {
  let idx = id.0
  if idx < 0 || idx >= self.row_ptr.length() - 1 {
    return [].iter()
  }
  let s = self.row_ptr[idx]
  let e = self.row_ptr[idx + 1]
  let r : Array[(@core.NodeId, Double)] = []
  for k in s..<e {
    r.push((self.col_idx[k], self.values[k]))
  }
  r.iter()
}

///|
pub impl @core.GraphBatchReadable for CSRGraph with batch_edges(
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
