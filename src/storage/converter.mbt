///|
/// 图格式转换器
///
/// 基于 trait 约束分层，保证语义安全：
/// - **有向转换组**: `[G : GraphDirected]` — 编译期保证源图是有向的
/// - **无向转换组**: `[G : GraphReadable]` + 运行时断言 — 保证源图是无向的
/// - **语义转换**: `as_undirected` / `as_directed` — 显式跨语义转换

// ============================================================================
// 有向图存储结构互转（编译期约束：源必须是有向图）
// ============================================================================

///|
/// 任意有向图 → 有向邻接表
pub fn[G : @core.GraphDirected] to_directed_adj_list(g : G) -> DirectedAdjList {
  let r = new_directed()
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}

///|
/// 任意有向图 → 有向邻接矩阵（需预分配容量）
pub fn[G : @core.GraphDirected] to_directed_matrix(
  g : G,
  cap : Int,
) -> DirectedMatrix {
  let r = new_directed_matrix(cap)
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}

///|
/// 任意有向图 → CSR（压缩稀疏行，只读）
pub fn[G : @core.GraphDirected] to_csr(g : G) -> CSRGraph {
  let b = CSRBuilder::new()
  let mut b2 = b
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => {
        b2 = b2.add_node(nid, data)
        ()
      }
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
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
/// 任意有向图 → CSC（压缩稀疏列，只读）
pub fn[G : @core.GraphDirected] to_csc(g : G) -> CSCGraph {
  let b = CSCBuilder::new()
  let mut b2 = b
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => {
        b2 = b2.add_node(nid, data)
        ()
      }
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
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
/// 任意有向图 → 有向边集数组
pub fn[G : @core.GraphDirected] to_edge_list(g : G) -> EdgeListGraph {
  let r = new_edge_list()
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}

// ============================================================================
// 无向图存储结构互转（运行时保护：源必须是无向图）
// ============================================================================

///|
/// 任意无向图 → 无向邻接表（半存储优化）
///
/// # Panics
///
/// 当 `g.is_directed() == true` 时 panic
pub fn[G : @core.GraphReadable] to_undirected_adj_list(
  g : G,
) -> UndirectedAdjList raise {
  assert_true(!@core.GraphReadable::is_directed(g))
  let r = new_undirected()
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}

///|
/// 任意无向图 → 无向邻接矩阵（需预分配容量）
///
/// # Panics
///
/// 当 `g.is_directed() == true` 时 panic
pub fn[G : @core.GraphReadable] to_undirected_matrix(
  g : G,
  cap : Int,
) -> UndirectedMatrix raise {
  assert_true(!@core.GraphReadable::is_directed(g))
  let r = new_undirected_matrix(cap)
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}

///|
/// 任意无向图 → 无向边集数组
///
/// # Panics
///
/// 当 `g.is_directed() == true` 时 panic
pub fn[G : @core.GraphReadable] to_undirected_edge_list(
  g : G,
) -> UndirectedEdgeListGraph raise {
  assert_true(!@core.GraphReadable::is_directed(g))
  let r = new_undirected_edge_list()
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}

// ============================================================================
// 显式语义转换（跨有向/无向边界，用户明确知情）
// ============================================================================

///|
/// 有向图 → 无向图（显式语义转换）
///
/// 每条有向边 `(a→b, w)` 变为无向边 `{a-b, w}`。
/// 如果同时存在 `(a→b)` 和 `(b→a)`，第二条会因为 `EdgeAlreadyExists` 被丢弃。
///
/// 典型用途：算法需要无向图输入，但数据源是有向的。
pub fn[G : @core.GraphReadable] as_undirected(g : G) -> UndirectedAdjList raise {
  assert_true(@core.GraphReadable::is_directed(g))
  let r = new_undirected()
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
    match triple {
      (f, t, w) =>
        match @core.GraphWritable::add_edge(r, f, t, w) {
          Ok(_) => ()
          Err(_) => () // 反向边已存在则跳过
        }
    }
  }
  r
}

///|
/// 无向图 → 有向图（显式语义转换）
///
/// 每条无向边 `{a-b, w}` 变为一条有向边 `a→b, w`（不生成反向边）。
/// 结果图中 `degree(node) == out_degree(node)`。
///
/// 典型用途：算法需要有向图输入，但数据源是无向的。
pub fn[G : @core.GraphReadable] as_directed(g : G) -> DirectedAdjList raise {
  assert_true(!@core.GraphReadable::is_directed(g))
  let r = new_directed()
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(g) {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  r
}
