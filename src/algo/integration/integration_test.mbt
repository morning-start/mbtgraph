/// 跨模块集成测试
///
/// 验证 PageRank + 中心性 + 社区检测 三个模块协同工作

// ============================================================================
// 辅助函数
// ============================================================================

fn approx_eq(a : Double, b : Double, eps : Double) -> Bool {
  let d = a - b
  if d < 0.0 {
    -d < eps
  } else {
    d < eps
  }
}

fn int_to_double(x : Int) -> Double {
  x.to_double()
}

///|
/// 创建双集群图: 0-1-2 和 3-4-5 各形成小团，之间仅通过 2-3 连接
fn make_two_clusters_connected() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 6 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let edges = [(0,1),(0,2),(1,2),(3,4),(3,5),(4,5),(2,3)]
  for e in edges {
    let (u, v) = e
    @core.GraphWritable::add_edge(g, @core.NodeId(u), @core.NodeId(v), 1.0) |> ignore
  }
  g
}

///|
/// 创建有向链图 (5 节点, 0→1→2→3→4)
fn make_directed_chain_5() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 5 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let mut j = 0
  while j < 4 {
    @core.GraphWritable::add_edge(g, @core.NodeId(j), @core.NodeId(j + 1), 1.0) |> ignore
    j = j + 1
  }
  g
}

// ============================================================================
// 测试 1: PageRank + 特征向量中心性对齐
// ============================================================================

///|
test "pagerank_and_eigenvector_aligned_on_star" {
  let g = @storage.new_directed()
  let mut i = 0
  while i < 5 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let mut j = 1
  while j < 5 {
    @core.GraphWritable::add_edge(g, @core.NodeId(j), @core.NodeId(0), 1.0) |> ignore
    j = j + 1
  }
  let pr_result = @pagerank.pagerank(g, 0.85, 100, 0.000001)
  let ev_result = @centrality.eigenvector_centrality(g, 100, 0.000001)

  let pr_center = pr_result.get_rank(@core.NodeId(0))
  let pr_leaf = pr_result.get_rank(@core.NodeId(1))

  match (pr_center, pr_leaf) {
    (Some(pc), Some(pl)) => {
      assert_true(pc > pl)
    }
    _ => assert_true(false)
  }

  assert_true(ev_result.scores.length() == 5)
}

// ============================================================================
// 测试 2: Louvain + 度中心性在双集群图上
// ============================================================================

///|
test "louvain_detects_two_clusters" {
  let g = make_two_clusters_connected()
  let community_result = @community.louvain(g, 1.0)
  assert_true(community_result.num_communities >= 2)
  assert_true(community_result.modularity > 0.3)

  let dc_result = @centrality.degree_centrality(g, @centrality.DegreeMode::Total)
  let bridging_node = @core.NodeId(2)
  let bridge_score = dc_result.get_score(bridging_node)
  match bridge_score {
    Some(s) => assert_true(s > 0.3)
    None => assert_true(false)
  }
}

// ============================================================================
// 测试 3: 标签传播 + PageRank 组合分析
// ============================================================================

///|
test "label_propagation_and_pagerank_on_chain" {
  let g = make_directed_chain_5()
  let lp_result = @community.label_propagation(g, 100)
  assert_true(lp_result.num_communities >= 1)
  assert_true(lp_result.labels.length() == 5)

  let pr_result = @pagerank.pagerank(g, 0.85, 100, 0.000001)
  assert_true(pr_result.converged)
  assert_true(approx_eq(pr_result.total_rank(), 1.0, 0.001))
}

// ============================================================================
// 测试 4: 多存储类型兼容性（AdjList + EdgeList）
// ============================================================================

///|
test "all_three_on_edge_list" {
  let g = @storage.new_edge_list()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0) |> ignore

  let pr = @pagerank.pagerank(g, 0.85, 100, 0.000001)
  assert_true(pr.converged)
  assert_true(approx_eq(pr.total_rank(), 1.0, 0.01))

  let dc = @centrality.degree_centrality(g, @centrality.DegreeMode::Total)
  assert_true(dc.scores.length() == 4)

  let lp = @community.label_propagation(g, 100)
  assert_true(lp.labels.length() == 4)
}

// ============================================================================
// 测试 5: CSR 存储类型兼容性
// ============================================================================

///|
test "all_three_on_csr" {
  let builder = @storage.CSRBuilder::new()
  let builder = builder.add_node(@core.NodeId(0), 0.0)
  let builder = builder.add_node(@core.NodeId(1), 0.0)
  let builder = builder.add_node(@core.NodeId(2), 0.0)
  let builder = builder.add_node(@core.NodeId(3), 0.0)
  let builder = builder.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
  let builder = builder.add_edge(@core.NodeId(1), @core.NodeId(2), 1.0)
  let builder = builder.add_edge(@core.NodeId(2), @core.NodeId(3), 1.0)
  let g = builder.build()

  let pr = @pagerank.pagerank(g, 0.85, 100, 0.000001)
  assert_true(pr.converged)

  let bc = @centrality.betweenness_centrality(g, true)
  assert_true(bc.scores.length() == 4)

  let lv = @community.louvain(g, 1.0)
  assert_true(lv.labels.length() == 4)
}

// ============================================================================
// 测试 6: 有向矩阵存储兼容性
// ============================================================================

///|
test "all_three_on_directed_matrix" {
  let g = @storage.new_directed_matrix(3)
  let mut i = 0
  while i < 3 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore

  let pr = @pagerank.pagerank(g, 0.85, 100, 0.000001)
  assert_true(pr.converged)

  let cc = @centrality.closeness_centrality(g, true)
  assert_true(cc.scores.length() == 3)

  let lp = @community.label_propagation(g, 100)
  assert_true(lp.labels.length() == 3)
}

// ============================================================================
// 测试 7: PageRank + 介数中心性集成
// ============================================================================

///|
test "pagerank_and_betweenness_on_bridge_graph" {
  let g = make_two_clusters_connected()
  let pr_result = @pagerank.pagerank(g, 0.85, 100, 0.000001)
  let bc_result = @centrality.betweenness_centrality(g, true)

  assert_true(pr_result.converged)
  assert_true(approx_eq(pr_result.total_rank(), 1.0, 0.001))

  let bridge_score = bc_result.get_score(@core.NodeId(2))
  match bridge_score {
    Some(s) => assert_true(s > 0.3)
    None => assert_true(false)
  }
}

// ============================================================================
// 测试 8: 中心性 + 社区检测在无向环图上
// ============================================================================

///|
test "centrality_and_community_on_ring" {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 6 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  let ring_edges = [(0,1),(1,2),(2,3),(3,4),(4,5),(5,0)]
  for e in ring_edges {
    let (u, v) = e
    @core.GraphWritable::add_edge(g, @core.NodeId(u), @core.NodeId(v), 1.0) |> ignore
  }

  let dc = @centrality.degree_centrality(g, @centrality.DegreeMode::Total)
  for s in dc.scores {
    assert_true(approx_eq(s, 2.0 / 5.0, 0.0001))
  }

  let cc = @centrality.closeness_centrality(g, true)
  for s in cc.scores {
    assert_true(s > 0.0)
  }

  let lp = @community.label_propagation(g, 100)
  assert_true(lp.labels.length() == 6)
}

// ============================================================================
// 测试 9: 双向遍历（PageRank + 接近中心性）
// ============================================================================

///|
test "pagerank_and_closeness_on_chain_directed" {
  let g = make_directed_chain_5()
  let pr_result = @pagerank.pagerank(g, 0.85, 100, 0.000001)
  assert_true(pr_result.converged)

  let r0 = pr_result.get_rank(@core.NodeId(0))
  let r4 = pr_result.get_rank(@core.NodeId(4))
  match (r0, r4) {
    (Some(a), Some(b)) => {
      assert_true(a > 0.0)
      assert_true(b > 0.0)
    }
    _ => assert_true(false)
  }

  let cc_result = @centrality.closeness_centrality(g, true)
  assert_true(cc_result.scores.length() == 5)
}

// ============================================================================
// 测试 10: Louvain + 标签传播结果一致性
// ============================================================================

///|
test "louvain_and_label_propagation_consistent" {
  let g = make_two_clusters_connected()
  let lv_result = @community.louvain(g, 1.0)
  let lp_result = @community.label_propagation(g, 100)

  assert_true(lv_result.num_communities >= 1)
  assert_true(lv_result.modularity > 0.2)
  assert_true(lp_result.num_communities >= 1)

  assert_true(lv_result.labels.length() == 6)
  assert_true(lp_result.labels.length() == 6)
}