// ============================================================================
// 大规模基准测试
// 注意：WASM GC 栈限制，只能使用有限规模
// ============================================================================

///|
fn make_path_graph(nodes : Int) -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  for i in 1..<nodes {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(i - 1), 1.0)
    |> ignore
  }
  g
}

///|
fn make_path_graph_undirected(nodes : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  for i in 1..<nodes {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(i - 1), 1.0)
    |> ignore
  }
  g
}

///|
test "TASK-G: benchmark (5000 nodes)" {
  let b = @bench.Bench()
  let g5k = make_path_graph(5000)
  let src = @core.NodeId(0)
  let _ = @sp.dijkstra(g5k, src)
  b.bench(
    fn() {
      let r = @sp.dijkstra(g5k, src)
      b.keep(r)
    },
    name="dijkstra(n=5000)",
  )
  let _ = @traversal.bfs(g5k, src)
  b.bench(
    fn() {
      let r = @traversal.bfs(g5k, src)
      b.keep(r)
    },
    name="bfs(n=5000)",
  )
  let _ = @traversal.dfs(g5k, src)
  b.bench(
    fn() {
      let r = @traversal.dfs(g5k, src)
      b.keep(r)
    },
    name="dfs(n=5000)",
  )
  let _ = @storage.to_csr(g5k)
  b.bench(
    fn() {
      let r = @storage.to_csr(g5k)
      b.keep(r)
    },
    name="csr_conversion(n=5000)",
  )
  // --- 新增基准测试 ---

  let _ = @pagerank.pagerank(g5k, 0.85, 100, 1.0e-6)
  b.bench(
    fn() {
      let r = @pagerank.pagerank(g5k, 0.85, 100, 1.0e-6)
      b.keep(r)
    },
    name="pagerank(n=5000)",
  )

  let g5k_u = make_path_graph_undirected(5000)
  let _ = @connectivity.connected_components(g5k_u)
  b.bench(
    fn() {
      let r = @connectivity.connected_components(g5k_u)
      b.keep(r)
    },
    name="connected_components(n=5000)",
  )

  let _ = @mst.kruskal(g5k_u)
  b.bench(
    fn() {
      let r = @mst.kruskal(g5k_u)
      b.keep(r)
    },
    name="kruskal(n=5000)",
  )

  let _ = @storage.to_csc(g5k)
  b.bench(
    fn() {
      let r = @storage.to_csc(g5k)
      b.keep(r)
    },
    name="csc_conversion(n=5000)",
  )

  // --- 第2批新增基准测试 ---

  let _ = @mst.prim(g5k_u, src)
  b.bench(
    fn() {
      let r = @mst.prim(g5k_u, src)
      b.keep(r)
    },
    name="prim(n=5000)",
  )

  let _ = @traversal.topo_sort_kahn(g5k)
  b.bench(
    fn() {
      let r = @traversal.topo_sort_kahn(g5k)
      b.keep(r)
    },
    name="topo_sort(n=5000)",
  )

  let _ = @dense_subgraph.k_core_decomposition(g5k_u)
  b.bench(
    fn() {
      let r = @dense_subgraph.k_core_decomposition(g5k_u)
      b.keep(r)
    },
    name="k_core(n=5000)",
  )

  let _ = @connectivity.kosaraju_scc(g5k)
  b.bench(
    fn() {
      let r = @connectivity.kosaraju_scc(g5k)
      b.keep(r)
    },
    name="kosaraju_scc(n=5000)",
  )

  // --- 第3批新增基准测试 ---

  let _ = @connectivity.tarjan_scc(g5k)
  b.bench(
    fn() {
      let r = @connectivity.tarjan_scc(g5k)
      b.keep(r)
    },
    name="tarjan_scc(n=5000)",
  )

  let _ = @connectivity.is_bipartite(g5k_u)
  b.bench(
    fn() {
      let r = @connectivity.is_bipartite(g5k_u)
      b.keep(r)
    },
    name="is_bipartite(n=5000)",
  )

  let _ = @mst.boruvka(g5k_u)
  b.bench(
    fn() {
      let r = @mst.boruvka(g5k_u)
      b.keep(r)
    },
    name="boruvka(n=5000)",
  )

  // --- 第4批新增基准测试 ---

  let _ = @centrality.degree_centrality(g5k_u, @centrality.DegreeMode::Total)
  b.bench(
    fn() {
      let r = @centrality.degree_centrality(
        g5k_u,
        @centrality.DegreeMode::Total,
      )
      b.keep(r)
    },
    name="degree_centrality(n=5000)",
  )

  let _ = @dense_subgraph.count_triangles(g5k_u)
  b.bench(
    fn() {
      let r = @dense_subgraph.count_triangles(g5k_u)
      b.keep(r)
    },
    name="count_triangles(n=5000)",
  )

  // --- 第5批新增基准测试 ---

  let _ = @dense_subgraph.average_clustering_coefficient(g5k_u)
  b.bench(
    fn() {
      let r = @dense_subgraph.average_clustering_coefficient(g5k_u)
      b.keep(r)
    },
    name="avg_clustering_coef(n=5000)",
  )

  println(b.dump_summaries())
}

///|
test "TASK-G: benchmark (10000 nodes)" {
  let b = @bench.Bench()
  let g10k = make_path_graph(10000)
  let src = @core.NodeId(0)
  let _ = @sp.dijkstra(g10k, src)
  b.bench(
    fn() {
      let r = @sp.dijkstra(g10k, src)
      b.keep(r)
    },
    name="dijkstra(n=10000)",
  )
  let _ = @traversal.bfs(g10k, src)
  b.bench(
    fn() {
      let r = @traversal.bfs(g10k, src)
      b.keep(r)
    },
    name="bfs(n=10000)",
  )
  let _ = @traversal.dfs(g10k, src)
  b.bench(
    fn() {
      let r = @traversal.dfs(g10k, src)
      b.keep(r)
    },
    name="dfs(n=10000)",
  )
  let _ = @storage.to_csr(g10k)
  b.bench(
    fn() {
      let r = @storage.to_csr(g10k)
      b.keep(r)
    },
    name="csr_conversion(n=10000)",
  )
  // --- 新增基准测试 ---

  let g10k_u = make_path_graph_undirected(10000)
  let _ = @connectivity.connected_components(g10k_u)
  b.bench(
    fn() {
      let r = @connectivity.connected_components(g10k_u)
      b.keep(r)
    },
    name="connected_components(n=10000)",
  )

  let _ = @mst.kruskal(g10k_u)
  b.bench(
    fn() {
      let r = @mst.kruskal(g10k_u)
      b.keep(r)
    },
    name="kruskal(n=10000)",
  )

  let _ = @storage.to_csc(g10k)
  b.bench(
    fn() {
      let r = @storage.to_csc(g10k)
      b.keep(r)
    },
    name="csc_conversion(n=10000)",
  )

  // --- 第2批新增基准测试 ---

  let _ = @traversal.topo_sort_kahn(g10k)
  b.bench(
    fn() {
      let r = @traversal.topo_sort_kahn(g10k)
      b.keep(r)
    },
    name="topo_sort(n=10000)",
  )

  let _ = @dense_subgraph.k_core_decomposition(g10k_u)
  b.bench(
    fn() {
      let r = @dense_subgraph.k_core_decomposition(g10k_u)
      b.keep(r)
    },
    name="k_core(n=10000)",
  )

  let _ = @connectivity.kosaraju_scc(g10k)
  b.bench(
    fn() {
      let r = @connectivity.kosaraju_scc(g10k)
      b.keep(r)
    },
    name="kosaraju_scc(n=10000)",
  )

  // --- 第3批新增基准测试 ---

  let _ = @connectivity.tarjan_scc(g10k)
  b.bench(
    fn() {
      let r = @connectivity.tarjan_scc(g10k)
      b.keep(r)
    },
    name="tarjan_scc(n=10000)",
  )

  let _ = @connectivity.is_bipartite(g10k_u)
  b.bench(
    fn() {
      let r = @connectivity.is_bipartite(g10k_u)
      b.keep(r)
    },
    name="is_bipartite(n=10000)",
  )

  let _ = @mst.boruvka(g10k_u)
  b.bench(
    fn() {
      let r = @mst.boruvka(g10k_u)
      b.keep(r)
    },
    name="boruvka(n=10000)",
  )

  // --- 第4批新增基准测试 ---

  let _ = @centrality.degree_centrality(g10k_u, @centrality.DegreeMode::Total)
  b.bench(
    fn() {
      let r = @centrality.degree_centrality(
        g10k_u,
        @centrality.DegreeMode::Total,
      )
      b.keep(r)
    },
    name="degree_centrality(n=10000)",
  )

  let _ = @dense_subgraph.count_triangles(g10k_u)
  b.bench(
    fn() {
      let r = @dense_subgraph.count_triangles(g10k_u)
      b.keep(r)
    },
    name="count_triangles(n=10000)",
  )

  // --- 第5批新增基准测试 ---

  let _ = @dense_subgraph.average_clustering_coefficient(g10k_u)
  b.bench(
    fn() {
      let r = @dense_subgraph.average_clustering_coefficient(g10k_u)
      b.keep(r)
    },
    name="avg_clustering_coef(n=10000)",
  )

  println(b.dump_summaries())
}
