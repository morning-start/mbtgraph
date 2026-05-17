///|
/// 图格式转换器
///
/// 基于 `GraphReadable` trait，任意存储类型可互相转换。
pub fn[G : @core.GraphReadable] to_directed_adj_list(g : G) -> DirectedAdjList {
  let r = new_directed()
  for nid in g.node_ids() {
    match g.get_node(nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in g.edges() {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}

///|
pub fn[G : @core.GraphReadable] to_undirected_adj_list(
  g : G,
) -> UndirectedAdjList {
  let r = new_undirected()
  for nid in g.node_ids() {
    match g.get_node(nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in g.edges() {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}

///|
pub fn[G : @core.GraphReadable] to_directed_matrix(
  g : G,
  cap : Int,
) -> DirectedMatrix {
  let r = new_directed_matrix(cap)
  for nid in g.node_ids() {
    match g.get_node(nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in g.edges() {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}

///|
pub fn[G : @core.GraphReadable] to_undirected_matrix(
  g : G,
  cap : Int,
) -> UndirectedMatrix {
  let r = new_undirected_matrix(cap)
  for nid in g.node_ids() {
    match g.get_node(nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in g.edges() {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
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
    }
  }
  r
}
