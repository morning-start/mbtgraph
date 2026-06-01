/// 图算子模块
///
/// 提供补图、反转、交并差、图积、线图、收缩、幂图等算子。
/// 所有算子返回具体存储类型（UndirectedAdjList / DirectedAdjList）。

// ============================================================================
// 辅助函数
// ============================================================================

///|
fn[G : @core.GraphReadable] copy_nodes(g : G, target : @storage.UndirectedAdjList) -> Unit {
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(target, data) |> ignore
      None => ()
    }
  }
}

///|
fn[G : @core.GraphReadable] copy_nodes_directed(g : G, target : @storage.DirectedAdjList) -> Unit {
  for nid in @core.GraphReadable::node_ids(g) {
    match @core.GraphReadable::get_node(g, nid) {
      Some(data) => @core.GraphWritable::add_node(target, data) |> ignore
      None => ()
    }
  }
}

///|
/// 为图积创建 n1 * n2 个节点
fn make_product_nodes(r : @storage.UndirectedAdjList, n1 : Int, n2 : Int) -> Unit {
  let mut i = 0
  while i < n1 {
    let mut j = 0
    while j < n2 {
      @core.GraphWritable::add_node(r, 0.0) |> ignore
      j = j + 1
    }
    i = i + 1
  }
}

///|
/// 收集所有边（含双向），用于图积计算
fn[G : @core.GraphReadable] collect_edges_bidi(g : G) -> Array[(@core.NodeId, @core.NodeId, Double)] {
  let result : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for triple in @core.GraphReadable::edges(g) {
    let (f, t, w) = triple
    result.push((f, t, w))
    result.push((t, f, w))
  }
  result
}

// ============================================================================
// 一元算子
// ============================================================================

///|
/// 补图：顶点集不变，边集取补
///
/// 复杂度: O(V²)
pub fn[G : @core.GraphReadable] complement(graph : G) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  copy_nodes(graph, r)
  let nids : Array[@core.NodeId] = []
  for nid in @core.GraphReadable::node_ids(graph) {
    nids.push(nid)
  }
  let mut i = 0
  while i < nids.length() {
    let mut j = i + 1
    while j < nids.length() {
      if !@core.GraphReadable::contains_edge(graph, nids[i], nids[j]) {
        @core.GraphWritable::add_edge(r, nids[i], nids[j], 1.0) |> ignore
      }
      j = j + 1
    }
    i = i + 1
  }
  r
}

///|
/// 反转图：有向边的方向全部反转
///
/// 复杂度: O(V + E)
pub fn[G : @core.GraphReadable] reverse(graph : G) -> @storage.DirectedAdjList {
  let r = @storage.new_directed()
  copy_nodes_directed(graph, r)
  for triple in @core.GraphReadable::edges(graph) {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, t, f, w) |> ignore
    }
  }
  r
}

// ============================================================================
// 二元算子
// ============================================================================

///|
/// 并图：顶点集取并，边集取并
///
/// 复杂度: O(V₁ + V₂ + E₁ + E₂)
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_union(
  a : G1,
  b : G2,
) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  for nid in @core.GraphReadable::node_ids(a) {
    match @core.GraphReadable::get_node(a, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for nid in @core.GraphReadable::node_ids(b) {
    if !@core.GraphReadable::contains_node(r, nid) {
      match @core.GraphReadable::get_node(b, nid) {
        Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
        None => ()
      }
    }
  }
  for triple in @core.GraphReadable::edges(a) {
    match triple {
      (f, t, w) => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
    }
  }
  for triple in @core.GraphReadable::edges(b) {
    match triple {
      (f, t, w) =>
        if !@core.GraphReadable::contains_edge(r, f, t) {
          @core.GraphWritable::add_edge(r, f, t, w) |> ignore
        }
    }
  }
  r
}

///|
/// 交图：边集取交（仅保留两图中同时存在的边）
///
/// 复杂度: O(V₁ + V₂ + E₁)
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_intersection(
  a : G1,
  b : G2,
) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  for nid in @core.GraphReadable::node_ids(a) {
    match @core.GraphReadable::get_node(a, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(a) {
    match triple {
      (f, t, w) =>
        if @core.GraphReadable::contains_edge(b, f, t) {
          let bw = @core.GraphReadable::get_edge(b, f, t)
          match bw {
            Some(w2) => @core.GraphWritable::add_edge(r, f, t, w2) |> ignore
            None => @core.GraphWritable::add_edge(r, f, t, w) |> ignore
          }
        }
    }
  }
  r
}

///|
/// 差图：保留在 a 中但不在 b 中的边
///
/// 复杂度: O(V₁ + E₁)
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_difference(
  a : G1,
  b : G2,
) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  for nid in @core.GraphReadable::node_ids(a) {
    match @core.GraphReadable::get_node(a, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(a) {
    match triple {
      (f, t, w) =>
        if !@core.GraphReadable::contains_edge(b, f, t) {
          @core.GraphWritable::add_edge(r, f, t, w) |> ignore
        }
    }
  }
  r
}

// ============================================================================
// 图积
// ============================================================================

///|
/// 笛卡尔积 G₁ □ G₂
///
/// 顶点集 V₁ × V₂，节点 (i,j) 的 ID = i.0 * n2 + j.0。
/// 边: (u₁,v₁)-(u₂,v₂) 当且仅当
/// (u₁=u₂ 且 (v₁,v₂)∈E₂) 或 (v₁=v₂ 且 (u₁,u₂)∈E₁)
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] cartesian_product(
  a : G1,
  b : G2,
) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  let n1 = @core.GraphReadable::node_count(a)
  let n2 = @core.GraphReadable::node_count(b)
  if n1 <= 0 || n2 <= 0 {
    return r
  }
  make_product_nodes(r, n1, n2)
  let edges_a = collect_edges_bidi(a)
  let edges_b = collect_edges_bidi(b)
  for i in @core.GraphReadable::node_ids(a) {
    for triple in edges_b {
      let (v1, v2, w) = triple
      let u = @core.NodeId(i.0 * n2 + v1.0)
      let v = @core.NodeId(i.0 * n2 + v2.0)
      @core.GraphWritable::add_edge(r, u, v, w) |> ignore
    }
  }
  for j in @core.GraphReadable::node_ids(b) {
    for triple in edges_a {
      let (u1, u2, w) = triple
      let u = @core.NodeId(u1.0 * n2 + j.0)
      let v = @core.NodeId(u2.0 * n2 + j.0)
      @core.GraphWritable::add_edge(r, u, v, w) |> ignore
    }
  }
  r
}

///|
/// 张量积 G₁ × G₂ (Kronecker 积)
///
/// 顶点集 V₁ × V₂。
/// 边: (u₁,v₁)-(u₂,v₂) 当且仅当 (u₁,u₂)∈E₁ 且 (v₁,v₂)∈E₂。
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] tensor_product(
  a : G1,
  b : G2,
) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  let n1 = @core.GraphReadable::node_count(a)
  let n2 = @core.GraphReadable::node_count(b)
  if n1 <= 0 || n2 <= 0 {
    return r
  }
  make_product_nodes(r, n1, n2)
  let edges_a = collect_edges_bidi(a)
  let edges_b = collect_edges_bidi(b)
  for triple1 in edges_a {
    let (u1, u2, w1) = triple1
    for triple2 in edges_b {
      let (v1, v2, w2) = triple2
      let u = @core.NodeId(u1.0 * n2 + v1.0)
      let v = @core.NodeId(u2.0 * n2 + v2.0)
      @core.GraphWritable::add_edge(r, u, v, w1 + w2) |> ignore
    }
  }
  r
}

///|
/// 字典序积 G₁[G₂]
///
/// 顶点集 V₁ × V₂。
/// 边: (u₁,v₁)-(u₂,v₂) 当且仅当
/// (u₁,u₂)∈E₁ 或 (u₁=u₂ 且 (v₁,v₂)∈E₂)。
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] lexicographic_product(
  a : G1,
  b : G2,
) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  let n1 = @core.GraphReadable::node_count(a)
  let n2 = @core.GraphReadable::node_count(b)
  if n1 <= 0 || n2 <= 0 {
    return r
  }
  make_product_nodes(r, n1, n2)
  let edges_a = collect_edges_bidi(a)
  let edges_b = collect_edges_bidi(b)
  for triple in edges_a {
    let (u1, u2, w) = triple
    for v1 in @core.GraphReadable::node_ids(b) {
      for v2 in @core.GraphReadable::node_ids(b) {
        let u = @core.NodeId(u1.0 * n2 + v1.0)
        let v = @core.NodeId(u2.0 * n2 + v2.0)
        if u != v && !@core.GraphReadable::contains_edge(r, u, v) {
          @core.GraphWritable::add_edge(r, u, v, w) |> ignore
        }
      }
    }
  }
  for i in @core.GraphReadable::node_ids(a) {
    for triple2 in edges_b {
      let (v1, v2, w) = triple2
      let u = @core.NodeId(i.0 * n2 + v1.0)
      let v = @core.NodeId(i.0 * n2 + v2.0)
      @core.GraphWritable::add_edge(r, u, v, w) |> ignore
    }
  }
  r
}

// ============================================================================
// 线图与收缩
// ============================================================================

///|
/// 线图 L(G)
///
/// 顶点 = G 的边，两条边在 L(G) 中相邻当且仅当它们在 G 中共享一个端点。
///
/// 复杂度: O(E²)
pub fn[G : @core.GraphReadable] line_graph(graph : G) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  let edge_list : Array[(@core.NodeId, @core.NodeId, Double)] = []
  for triple in @core.GraphReadable::edges(graph) {
    match triple {
      (f, t, w) => edge_list.push((f, t, w))
    }
  }
  let edge_ids : Array[@core.NodeId] = []
  let mut i = 0
  while i < edge_list.length() {
    let id = @core.GraphWritable::add_node(r, 1.0)
    edge_ids.push(id)
    i = i + 1
  }
  i = 0
  while i < edge_list.length() {
    let mut j = i + 1
    while j < edge_list.length() {
      let (f1, t1, _) = edge_list[i]
      let (f2, t2, _) = edge_list[j]
      if f1 == f2 || f1 == t2 || t1 == f2 || t1 == t2 {
        @core.GraphWritable::add_edge(r, edge_ids[i], edge_ids[j], 1.0) |> ignore
      }
      j = j + 1
    }
    i = i + 1
  }
  r
}

///|
/// 边收缩：将节点 u 合并到节点 v 中
///
/// 移去节点 u，所有与 u 关联的边重新连接到 v。
/// 如果产生自环则删除该边。
///
/// 复杂度: O(V + E)
pub fn[G : @core.GraphReadable] contract(
  graph : G,
  u : @core.NodeId,
  v : @core.NodeId,
) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  for nid in @core.GraphReadable::node_ids(graph) {
    match @core.GraphReadable::get_node(graph, nid) {
      Some(data) => @core.GraphWritable::add_node(r, data) |> ignore
      None => ()
    }
  }
  for triple in @core.GraphReadable::edges(graph) {
    match triple {
      (f, t, w) =>
        if (f == u && t == v) || (f == v && t == u) {
          // 收缩边本身 — 跳过
        } else if f == u {
          if t != v {
            @core.GraphWritable::add_edge(r, v, t, w) |> ignore
          }
        } else if t == u {
          if f != v {
            @core.GraphWritable::add_edge(r, f, v, w) |> ignore
          }
        } else {
          @core.GraphWritable::add_edge(r, f, t, w) |> ignore
        }
    }
  }
  r
}

// ============================================================================
// 幂图
// ============================================================================

///|
/// 幂图 G^k
///
/// 顶点集不变，边: 距离 ≤ k 的节点对之间有边。
/// 使用 BFS 计算距离。
///
/// 复杂度: O(V·(V+E))
pub fn[G : @core.GraphReadable] power_graph(
  graph : G,
  k : Int,
) -> @storage.UndirectedAdjList {
  let r = @storage.new_undirected()
  let n = @core.GraphReadable::node_count(graph)
  copy_nodes(graph, r)
  if n <= 0 {
    return r
  }
  for start in @core.GraphReadable::node_ids(graph) {
    let dist : Array[Int] = Array::make(n, -1)
    let queue : Array[@core.NodeId] = Array::make(n, @core.NodeId(0))
    let mut head = 0
    let mut tail = 0
    queue[tail] = start
    tail = tail + 1
    dist[start.0] = 0
    while head < tail {
      let cur = queue[head]
      head = head + 1
      let d = dist[cur.0]
      if d < k {
        for nxt in @core.GraphReadable::neighbors(graph, cur) {
          if dist[nxt.0] < 0 {
            dist[nxt.0] = d + 1
            queue[tail] = nxt
            tail = tail + 1
          }
        }
      }
    }
    for target in @core.GraphReadable::node_ids(graph) {
      let d = dist[target.0]
      if d > 0 && d <= k && !@core.GraphReadable::contains_edge(r, start, target) {
        @core.GraphWritable::add_edge(r, start, target, 1.0) |> ignore
      }
    }
  }
  r
}
