///|
/// 图格式转换器
///
/// 基于 `GraphReadable` trait，任意存储类型可互相转换。
pub fn[G : @core.GraphReadable] to_adjacency_list(g : G) -> AdjacencyListGraph {
  let d = g.is_directed()
  let r = new(d)
  for nid in g.node_ids() {
    match g.get_node(nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in g.edges() {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
      _ => ()
    }
  }
  r
}

///|
pub fn[G : @core.GraphReadable] to_adjacency_matrix(
  g : G,
  cap : Int,
) -> AdjacencyMatrixGraph {
  let d = g.is_directed()
  let r = new_matrix(cap, d)
  for nid in g.node_ids() {
    match g.get_node(nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in g.edges() {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
      _ => ()
    }
  }
  r
}

///|
pub fn[G : @core.GraphReadable] to_csr(g : G) -> CSRGraph {
  let b = CSRBuilder::new()
  let mut b2 = b
  for nid in g.node_ids() {
    match g.get_node(nid) {
      Some(data) => {
        b2 = b2.add_node(nid, data)
        ()
      }
      None => ()
    }
  }
  for triple in g.edges() {
    match triple {
      (f, t, w) => {
        b2 = b2.add_edge(f, t, w)
        ()
      }
      _ => ()
    }
  }
  b2.build()
}

///|
pub fn[G : @core.GraphReadable] to_edge_list(g : G) -> EdgeListGraph {
  let r = new_edge_list()
  for nid in g.node_ids() {
    match g.get_node(nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in g.edges() {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
      _ => ()
    }
  }
  r
}
