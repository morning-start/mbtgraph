// ============================================================================
// 基准测试 - 中/小规模 (100 / 1000 节点)
//
// 使用 @moonbitlang.core.bench 模块进行性能测量。
// 输出 JSON 格式的基线数据到 stdout。
// 大图 (>10K) 请见 benchmarks_large/ 包。
// ============================================================================

// ============================================================================
// 轻量级图构建函数（避免 WASM 栈溢出）
// ============================================================================

///|
fn make_chain_graph(nodes : Int, k : Int) -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  for i in 1..<nodes {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    for j in 1..<(k + 1) {
      let to = i - j
      if to >= 0 {
        @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(to), 1.0)
        |> ignore
      }
    }
  }
  g
}

///|
fn make_chain_graph_undirected(
  nodes : Int,
  k : Int,
) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  for i in 1..<nodes {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    for j in 1..<(k + 1) {
      let to = i - j
      if to >= 0 {
        @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(to), 1.0)
        |> ignore
      }
    }
  }
  g
}

///|
fn make_flow_graph(nodes : Int) -> @flow.FlowNetwork {
  let net = @flow.FlowNetwork::new(nodes)
  let mut n = net
  for i in 0..<(nodes - 1) {
    n = n.add_edge(i, i + 1, 10.0)
  }
  n
}

// ============================================================================
// 基准测试 - 小规模 (100 节点, k=5)
// ============================================================================

///|
test "TASK-G: benchmark (100 nodes)" {
  let b = @bench.Bench()

  let g100 = make_chain_graph(100, 5)
  let src = @core.NodeId(0)

  let _ = @sp.dijkstra(g100, src)
  b.bench(
    fn() {
      let r = @sp.dijkstra(g100, src)
      b.keep(r)
    },
    name="dijkstra(n=100)",
  )

  let _ = @traversal.bfs(g100, src)
  b.bench(
    fn() {
      let r = @traversal.bfs(g100, src)
      b.keep(r)
    },
    name="bfs(n=100)",
  )

  let _ = @traversal.dfs(g100, src)
  b.bench(
    fn() {
      let r = @traversal.dfs(g100, src)
      b.keep(r)
    },
    name="dfs(n=100)",
  )

  let _ = @storage.to_csr(g100)
  b.bench(
    fn() {
      let r = @storage.to_csr(g100)
      b.keep(r)
    },
    name="csr_conversion(n=100)",
  )

  let flow100 = make_flow_graph(100)
  let _ = @flow.dinic(flow100, 0, 99)
  b.bench(
    fn() {
      let r = @flow.dinic(flow100, 0, 99)
      b.keep(r)
    },
    name="dinic(n=100)",
  )

  let g100u = make_chain_graph_undirected(100, 5)
  let _ = @community.louvain(g100u, 1.0)
  b.bench(
    fn() {
      let r = @community.louvain(g100u, 1.0)
      b.keep(r)
    },
    name="louvain(n=100)",
  )

  // --- 新增基准测试 ---

  let _ = @pagerank.pagerank(g100, 0.85, 100, 1.0e-6)
  b.bench(
    fn() {
      let r = @pagerank.pagerank(g100, 0.85, 100, 1.0e-6)
      b.keep(r)
    },
    name="pagerank(n=100)",
  )

  let _ = @connectivity.connected_components(g100u)
  b.bench(
    fn() {
      let r = @connectivity.connected_components(g100u)
      b.keep(r)
    },
    name="connected_components(n=100)",
  )

  let _ = @mst.kruskal(g100u)
  b.bench(
    fn() {
      let r = @mst.kruskal(g100u)
      b.keep(r)
    },
    name="kruskal(n=100)",
  )

  let _ = @storage.to_csc(g100)
  b.bench(
    fn() {
      let r = @storage.to_csc(g100)
      b.keep(r)
    },
    name="csc_conversion(n=100)",
  )

  // --- 第2批新增基准测试 ---

  let _ = @sp.bellman_ford(g100, src)
  b.bench(
    fn() {
      let r = @sp.bellman_ford(g100, src)
      b.keep(r)
    },
    name="bellman_ford(n=100)",
  )

  let _ = @mst.prim(g100u, src)
  b.bench(
    fn() {
      let r = @mst.prim(g100u, src)
      b.keep(r)
    },
    name="prim(n=100)",
  )

  let _ = @traversal.topo_sort_kahn(g100)
  b.bench(
    fn() {
      let r = @traversal.topo_sort_kahn(g100)
      b.keep(r)
    },
    name="topo_sort(n=100)",
  )

  let _ = @community.label_propagation(g100u, 100)
  b.bench(
    fn() {
      let r = @community.label_propagation(g100u, 100)
      b.keep(r)
    },
    name="label_propagation(n=100)",
  )

  let _ = @dense_subgraph.k_core_decomposition(g100u)
  b.bench(
    fn() {
      let r = @dense_subgraph.k_core_decomposition(g100u)
      b.keep(r)
    },
    name="k_core(n=100)",
  )

  let _ = @coloring.greedy_coloring(g100u)
  b.bench(
    fn() {
      let r = @coloring.greedy_coloring(g100u)
      b.keep(r)
    },
    name="greedy_coloring(n=100)",
  )

  let _ = @connectivity.kosaraju_scc(g100)
  b.bench(
    fn() {
      let r = @connectivity.kosaraju_scc(g100)
      b.keep(r)
    },
    name="kosaraju_scc(n=100)",
  )

  // --- 第3批新增基准测试 ---

  let target100 = @core.NodeId(99)
  let _ = @traversal.bidirectional_bfs(g100, src, target100)
  b.bench(
    fn() {
      let r = @traversal.bidirectional_bfs(g100, src, target100)
      b.keep(r)
    },
    name="bidirectional_bfs(n=100)",
  )

  let _ = @traversal.has_directed_cycle(g100)
  b.bench(
    fn() {
      let r = @traversal.has_directed_cycle(g100)
      b.keep(r)
    },
    name="has_cycle(n=100)",
  )

  let _ = @connectivity.is_bipartite(g100u)
  b.bench(
    fn() {
      let r = @connectivity.is_bipartite(g100u)
      b.keep(r)
    },
    name="is_bipartite(n=100)",
  )

  let _ = @connectivity.tarjan_scc(g100)
  b.bench(
    fn() {
      let r = @connectivity.tarjan_scc(g100)
      b.keep(r)
    },
    name="tarjan_scc(n=100)",
  )

  let _ = @mst.boruvka(g100u)
  b.bench(
    fn() {
      let r = @mst.boruvka(g100u)
      b.keep(r)
    },
    name="boruvka(n=100)",
  )

  let _ = @coloring.welsh_powell(g100u)
  b.bench(
    fn() {
      let r = @coloring.welsh_powell(g100u)
      b.keep(r)
    },
    name="welsh_powell(n=100)",
  )

  let _ = @sp.floyd_warshall(g100)
  b.bench(
    fn() {
      let r = @sp.floyd_warshall(g100)
      b.keep(r)
    },
    name="floyd_warshall(n=100)",
  )

  // --- 第4批新增基准测试 ---

  let _ = @centrality.degree_centrality(g100u, @centrality.DegreeMode::Total)
  b.bench(
    fn() {
      let r = @centrality.degree_centrality(
        g100u,
        @centrality.DegreeMode::Total,
      )
      b.keep(r)
    },
    name="degree_centrality(n=100)",
  )

  let _ = @dense_subgraph.count_triangles(g100u)
  b.bench(
    fn() {
      let r = @dense_subgraph.count_triangles(g100u)
      b.keep(r)
    },
    name="count_triangles(n=100)",
  )

  let _ = @coloring.dsatur_coloring(g100u)
  b.bench(
    fn() {
      let r = @coloring.dsatur_coloring(g100u)
      b.keep(r)
    },
    name="dsatur_coloring(n=100)",
  )

  let _ = @flow.edmonds_karp(flow100, 0, 99)
  b.bench(
    fn() {
      let r = @flow.edmonds_karp(flow100, 0, 99)
      b.keep(r)
    },
    name="edmonds_karp(n=100)",
  )

  let _ = @flow.push_relabel(flow100, 0, 99)
  b.bench(
    fn() {
      let r = @flow.push_relabel(flow100, 0, 99)
      b.keep(r)
    },
    name="push_relabel(n=100)",
  )

  // --- 第5批新增基准测试 ---

  let _ = @community.leiden(g100u, 1.0)
  b.bench(
    fn() {
      let r = @community.leiden(g100u, 1.0)
      b.keep(r)
    },
    name="leiden(n=100)",
  )

  let _ = @centrality.eigenvector_centrality(g100u, 100, 1.0e-6)
  b.bench(
    fn() {
      let r = @centrality.eigenvector_centrality(g100u, 100, 1.0e-6)
      b.keep(r)
    },
    name="eigenvector_centrality(n=100)",
  )

  let _ = @centrality.betweenness_centrality(g100u, false)
  b.bench(
    fn() {
      let r = @centrality.betweenness_centrality(g100u, false)
      b.keep(r)
    },
    name="betweenness_centrality(n=100)",
  )

  let _ = @dense_subgraph.average_clustering_coefficient(g100u)
  b.bench(
    fn() {
      let r = @dense_subgraph.average_clustering_coefficient(g100u)
      b.keep(r)
    },
    name="avg_clustering_coef(n=100)",
  )

  let _ = @flow.capacity_scaling(flow100, 0, 99)
  b.bench(
    fn() {
      let r = @flow.capacity_scaling(flow100, 0, 99)
      b.keep(r)
    },
    name="capacity_scaling(n=100)",
  )

  println(b.dump_summaries())
}

// ============================================================================
// 基准测试 - 中等规模 (1000 节点, k=10)
// ============================================================================

///|
test "TASK-G: benchmark (1000 nodes)" {
  let b = @bench.Bench()

  let g1k = make_chain_graph(1000, 10)
  let src = @core.NodeId(0)

  let _ = @sp.dijkstra(g1k, src)
  b.bench(
    fn() {
      let r = @sp.dijkstra(g1k, src)
      b.keep(r)
    },
    name="dijkstra(n=1000)",
  )

  let _ = @traversal.bfs(g1k, src)
  b.bench(
    fn() {
      let r = @traversal.bfs(g1k, src)
      b.keep(r)
    },
    name="bfs(n=1000)",
  )

  let _ = @traversal.dfs(g1k, src)
  b.bench(
    fn() {
      let r = @traversal.dfs(g1k, src)
      b.keep(r)
    },
    name="dfs(n=1000)",
  )

  let _ = @storage.to_csr(g1k)
  b.bench(
    fn() {
      let r = @storage.to_csr(g1k)
      b.keep(r)
    },
    name="csr_conversion(n=1000)",
  )

  let flow1k = make_flow_graph(1000)
  let _ = @flow.dinic(flow1k, 0, 999)
  b.bench(
    fn() {
      let r = @flow.dinic(flow1k, 0, 999)
      b.keep(r)
    },
    name="dinic(n=1000)",
  )

  // --- 新增基准测试 ---

  let _ = @pagerank.pagerank(g1k, 0.85, 100, 1.0e-6)
  b.bench(
    fn() {
      let r = @pagerank.pagerank(g1k, 0.85, 100, 1.0e-6)
      b.keep(r)
    },
    name="pagerank(n=1000)",
  )

  let g1k_u = make_chain_graph_undirected(1000, 10)
  let _ = @connectivity.connected_components(g1k_u)
  b.bench(
    fn() {
      let r = @connectivity.connected_components(g1k_u)
      b.keep(r)
    },
    name="connected_components(n=1000)",
  )

  let _ = @mst.kruskal(g1k_u)
  b.bench(
    fn() {
      let r = @mst.kruskal(g1k_u)
      b.keep(r)
    },
    name="kruskal(n=1000)",
  )

  let _ = @storage.to_csc(g1k)
  b.bench(
    fn() {
      let r = @storage.to_csc(g1k)
      b.keep(r)
    },
    name="csc_conversion(n=1000)",
  )

  // --- 第2批新增基准测试 ---

  let _ = @sp.bellman_ford(g1k, src)
  b.bench(
    fn() {
      let r = @sp.bellman_ford(g1k, src)
      b.keep(r)
    },
    name="bellman_ford(n=1000)",
  )

  let _ = @mst.prim(g1k_u, src)
  b.bench(
    fn() {
      let r = @mst.prim(g1k_u, src)
      b.keep(r)
    },
    name="prim(n=1000)",
  )

  let _ = @traversal.topo_sort_kahn(g1k)
  b.bench(
    fn() {
      let r = @traversal.topo_sort_kahn(g1k)
      b.keep(r)
    },
    name="topo_sort(n=1000)",
  )

  let _ = @community.label_propagation(g1k_u, 100)
  b.bench(
    fn() {
      let r = @community.label_propagation(g1k_u, 100)
      b.keep(r)
    },
    name="label_propagation(n=1000)",
  )

  let _ = @dense_subgraph.k_core_decomposition(g1k_u)
  b.bench(
    fn() {
      let r = @dense_subgraph.k_core_decomposition(g1k_u)
      b.keep(r)
    },
    name="k_core(n=1000)",
  )

  let _ = @coloring.greedy_coloring(g1k_u)
  b.bench(
    fn() {
      let r = @coloring.greedy_coloring(g1k_u)
      b.keep(r)
    },
    name="greedy_coloring(n=1000)",
  )

  let _ = @connectivity.kosaraju_scc(g1k)
  b.bench(
    fn() {
      let r = @connectivity.kosaraju_scc(g1k)
      b.keep(r)
    },
    name="kosaraju_scc(n=1000)",
  )

  // --- 第3批新增基准测试 ---

  let target1k = @core.NodeId(999)
  let _ = @traversal.bidirectional_bfs(g1k, src, target1k)
  b.bench(
    fn() {
      let r = @traversal.bidirectional_bfs(g1k, src, target1k)
      b.keep(r)
    },
    name="bidirectional_bfs(n=1000)",
  )

  let _ = @traversal.has_directed_cycle(g1k)
  b.bench(
    fn() {
      let r = @traversal.has_directed_cycle(g1k)
      b.keep(r)
    },
    name="has_cycle(n=1000)",
  )

  let _ = @connectivity.is_bipartite(g1k_u)
  b.bench(
    fn() {
      let r = @connectivity.is_bipartite(g1k_u)
      b.keep(r)
    },
    name="is_bipartite(n=1000)",
  )

  let _ = @connectivity.tarjan_scc(g1k)
  b.bench(
    fn() {
      let r = @connectivity.tarjan_scc(g1k)
      b.keep(r)
    },
    name="tarjan_scc(n=1000)",
  )

  let _ = @mst.boruvka(g1k_u)
  b.bench(
    fn() {
      let r = @mst.boruvka(g1k_u)
      b.keep(r)
    },
    name="boruvka(n=1000)",
  )

  let _ = @coloring.welsh_powell(g1k_u)
  b.bench(
    fn() {
      let r = @coloring.welsh_powell(g1k_u)
      b.keep(r)
    },
    name="welsh_powell(n=1000)",
  )

  // --- 第4批新增基准测试 ---

  let _ = @centrality.degree_centrality(g1k_u, @centrality.DegreeMode::Total)
  b.bench(
    fn() {
      let r = @centrality.degree_centrality(
        g1k_u,
        @centrality.DegreeMode::Total,
      )
      b.keep(r)
    },
    name="degree_centrality(n=1000)",
  )

  let _ = @dense_subgraph.count_triangles(g1k_u)
  b.bench(
    fn() {
      let r = @dense_subgraph.count_triangles(g1k_u)
      b.keep(r)
    },
    name="count_triangles(n=1000)",
  )

  let _ = @coloring.dsatur_coloring(g1k_u)
  b.bench(
    fn() {
      let r = @coloring.dsatur_coloring(g1k_u)
      b.keep(r)
    },
    name="dsatur_coloring(n=1000)",
  )

  // --- 第5批新增基准测试 ---

  let _ = @community.leiden(g1k_u, 1.0)
  b.bench(
    fn() {
      let r = @community.leiden(g1k_u, 1.0)
      b.keep(r)
    },
    name="leiden(n=1000)",
  )

  let _ = @centrality.eigenvector_centrality(g1k_u, 100, 1.0e-6)
  b.bench(
    fn() {
      let r = @centrality.eigenvector_centrality(g1k_u, 100, 1.0e-6)
      b.keep(r)
    },
    name="eigenvector_centrality(n=1000)",
  )

  let _ = @dense_subgraph.average_clustering_coefficient(g1k_u)
  b.bench(
    fn() {
      let r = @dense_subgraph.average_clustering_coefficient(g1k_u)
      b.keep(r)
    },
    name="avg_clustering_coef(n=1000)",
  )

  println(b.dump_summaries())
}
