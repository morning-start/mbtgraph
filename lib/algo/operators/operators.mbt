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

/// 补图：顶点集不变，边集取补
///
/// 对无向图 G = (V, E) 构造其补图 Ḡ = (V, Ē)，
/// 其中 Ē 包含所有不在 E 中出现的顶点对（不含自环）。
/// 常用于团检测、图同构等场景的辅助变换。
///
/// **参数**
/// - `graph`: 输入图，需实现 `GraphReadable` trait
///
/// **返回值** 新建的 `UndirectedAdjList`，包含所有原图节点和补边集
///
/// **复杂度** O(V²)
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

/// 反转图：有向边的方向全部反转
///
/// 对有向图 G = (V, E) 构造其反转图 G^R = (V, E^R)，
/// 其中每条边 (u, v) ∈ E 变为 (v, u) ∈ E^R。
/// 常用于强连通分量（Kosaraju 算法）、可达性分析等场景。
///
/// **参数**
/// - `graph`: 输入有向图，需实现 `GraphReadable` trait
///
/// **返回值** 新建的 `DirectedAdjList`，节点不变，所有边方向取反
///
/// **复杂度** O(V + E)
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

/// 并图：顶点集取并，边集取并
///
/// 对两幅无向图 G₁ = (V₁, E₁) 和 G₂ = (V₂, E₂) 构造并图 G₁ ∪ G₂ = (V₁∪V₂, E₁∪E₂)。
/// 重复边仅保留一条（取先出现的权重）。节点数据以 a 为准，b 中新增节点保留原数据。
///
/// **参数**
/// - `a`: 第一幅输入图（主图）
/// - `b`: 第二幅输入图
///
/// **返回值** 新建的 `UndirectedAdjList`，包含并集节点和并集边
///
/// **复杂度** O(V₁ + V₂ + E₁ + E₂)
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

/// 交图：边集取交（仅保留两图中同时存在的边）
///
/// 对两幅无向图 G₁ 和 G₂ 构造交图 G₁ ∩ G₂，
/// 节点集取自 a，仅保留同时在两幅图中出现的边。
/// 若同一条边在两图中权重不同，优先采用 b 的权重。
///
/// **参数**
/// - `a`: 第一幅输入图（决定节点集）
/// - `b`: 第二幅输入图（用于边存在性判定和权重选取）
///
/// **返回值** 新建的 `UndirectedAdjList`，包含 a 的节点和交集边
///
/// **复杂度** O(V₁ + V₂ + E₁)
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

/// 差图：保留在 a 中但不在 b 中的边
///
/// 对两幅无向图 G₁ 和 G₂ 构造差图 G₁ \ G₂，
/// 节点集取自 a，仅保留存在于 a 但不存在于 b 的边。
/// 边权重沿用 a 中的原始值。
///
/// **参数**
/// - `a`: 被减图（决定节点集和候选边集）
/// - `b`: 减数图（用于边排除判定）
///
/// **返回值** 新建的 `UndirectedAdjList`，包含 a 的节点和差集边
///
/// **复杂度** O(V₁ + E₁)
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

/// 笛卡尔积 G₁ □ G₂（又称直积、盒积）
///
/// 顶点集为 V₁ × V₂，节点 (i, j) 的 ID 编码为 `i.0 * n2 + j.0`。
/// 边的构造规则：(u₁, v₁) 与 (u₂, v₂) 相邻当且仅当
/// - u₁ = u₂ 且 (v₁, v₂) ∈ E₂，或
/// - v₁ = v₂ 且 (u₁, u₂) ∈ E₁
///
/// **参数**
/// - `a`: 第一幅图 G₁
/// - `b`: 第二幅图 G₂
///
/// **返回值** 新建的 `UndirectedAdjList`，包含 n1×n2 个节点和积边
///
/// **复杂度** O(|V₁|·|E₂| + |V₂|·|E₁|)
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

/// 张量积 G₁ × G₂（又称 Kronecker 积、直接积）
///
/// 顶点集为 V₁ × V₂。
/// 边的构造规则：(u₁, v₁) 与 (u₂, v₂) 相邻当且仅当
/// (u₁, u₂) ∈ E₁ **且** (v₁, v₂) ∈ E₂。
/// 边权重取两图对应边权重之和。
///
/// **参数**
/// - `a`: 第一幅图 G₁
/// - `b`: 第二幅图 G₂
///
/// **返回值** 新建的 `UndirectedAdjList`，包含 n1×n2 个节点和积边
///
/// **复杂度** O(|E₁| · |E₂|)
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

/// 字典序积 G₁[G₂]（又称复合图）
///
/// 顶点集为 V₁ × V₂。
/// 边的构造规则：(u₁, v₁) 与 (u₂, v₂) 相邻当且仅当
/// - (u₁, u₂) ∈ E₁，或
/// - u₁ = u₂ **且** (v₁, v₂) ∈ E₂
///
/// 可视为将 G₂ 的副本替换 G₁ 的每个节点，再按 G₁ 的边连接各副本。
///
/// **参数**
/// - `a`: 第一幅图 G₁（外层/骨架图）
/// - `b`: 第二幅图 G₂（内层/替换图）
///
/// **返回值** 新建的 `UndirectedAdjList`，包含 n1×n2 个节点和积边
///
/// **复杂度** O(|V₁|² · |V₂| + |V₁| · |E₂| + |E₁| · |V₂|²)
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

/// 线图 L(G)（Line Graph）
///
/// 构造原图 G 的线图：L(G) 的每个顶点对应 G 的一条边，
/// L(G) 中两顶点相邻当且仅当它们对应的边在 G 中共享一个端点。
/// 线图的顶点数等于 |E(G)|，可用于边着色、欧拉路径等问题的转化。
///
/// **参数**
/// - `graph`: 输入无向图，需实现 `GraphReadable` trait
///
/// **返回值** 新建的 `UndirectedAdjList`，顶点对应原图的边
///
/// **复杂度** O(E²)
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

/// 边收缩：将节点 u 合并到节点 v 中
///
/// 移去节点 u，将所有与 u 关联的边重新连接到 v。
/// 若收缩操作产生自环（u-v 之间的边或重连后 f=v）则自动删除该边。
/// 节点 v 保留，u 被移除。常用于最小割、Stoer-Wagner 算法等场景。
///
/// **参数**
/// - `graph`: 输入无向图
/// - `u`: 被收缩的源节点（将被移除）
/// - `v`: 收缩目标节点（保留，接收 u 的邻接关系）
///
/// **返回值** 新建的 `UndirectedAdjList`，不含节点 u
///
/// **复杂度** O(V + E)
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

/// 幂图 G^k（k-th Power Graph）
///
/// 顶点集与原图相同，在所有最短路径距离 ≤ k 的节点对之间添加边。
/// 特别地，G¹ 即为原图的闭包（连通分量变为团）。
/// 内部使用 BFS 从每个节点出发计算距离，边权重统一为 1.0。
///
/// **参数**
/// - `graph`: 输入无向图
/// - `k`: 幂次参数，距离阈值（k ≥ 1）
///
/// **返回值** 新建的 `UndirectedAdjList`，节点不变，边集为距离 ≤ k 的节点对
///
/// **复杂度** O(V · (V + E))
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
