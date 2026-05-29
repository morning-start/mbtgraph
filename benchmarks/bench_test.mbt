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
        @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(to), 1.0) |> ignore
      }
    }
  }
  g
}

///|
fn make_chain_graph_undirected(nodes : Int, k : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  for i in 1..<nodes {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    for j in 1..<(k + 1) {
      let to = i - j
      if to >= 0 {
        @core.GraphWritable::add_edge(g, @core.NodeId(i), @core.NodeId(to), 1.0) |> ignore
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
  let b = @bench.Bench::new()

  let g100 = make_chain_graph(100, 5)
  let src = @core.NodeId(0)

  let _ = @sp.dijkstra(g100, src)
  b.bench(fn () { let r = @sp.dijkstra(g100, src); b.keep(r) }, name="dijkstra(n=100)")

  let _ = @traversal.bfs(g100, src)
  b.bench(fn () { let r = @traversal.bfs(g100, src); b.keep(r) }, name="bfs(n=100)")

  let _ = @traversal.dfs(g100, src)
  b.bench(fn () { let r = @traversal.dfs(g100, src); b.keep(r) }, name="dfs(n=100)")

  let _ = @storage.to_csr(g100)
  b.bench(fn () { let r = @storage.to_csr(g100); b.keep(r) }, name="csr_conversion(n=100)")

  let flow100 = make_flow_graph(100)
  let _ = @flow.dinic(flow100, 0, 99)
  b.bench(fn () { let r = @flow.dinic(flow100, 0, 99); b.keep(r) }, name="dinic(n=100)")

  let g100u = make_chain_graph_undirected(100, 5)
  let _ = @community.louvain(g100u, 1.0)
  b.bench(fn () { let r = @community.louvain(g100u, 1.0); b.keep(r) }, name="louvain(n=100)")

  println(b.dump_summaries())
}

// ============================================================================
// 基准测试 - 中等规模 (1000 节点, k=10)
// ============================================================================

///|
test "TASK-G: benchmark (1000 nodes)" {
  let b = @bench.Bench::new()

  let g1k = make_chain_graph(1000, 10)
  let src = @core.NodeId(0)

  let _ = @sp.dijkstra(g1k, src)
  b.bench(fn () { let r = @sp.dijkstra(g1k, src); b.keep(r) }, name="dijkstra(n=1000)")

  let _ = @traversal.bfs(g1k, src)
  b.bench(fn () { let r = @traversal.bfs(g1k, src); b.keep(r) }, name="bfs(n=1000)")

  let _ = @traversal.dfs(g1k, src)
  b.bench(fn () { let r = @traversal.dfs(g1k, src); b.keep(r) }, name="dfs(n=1000)")

  let _ = @storage.to_csr(g1k)
  b.bench(fn () { let r = @storage.to_csr(g1k); b.keep(r) }, name="csr_conversion(n=1000)")

  let flow1k = make_flow_graph(1000)
  let _ = @flow.dinic(flow1k, 0, 999)
  b.bench(fn () { let r = @flow.dinic(flow1k, 0, 999); b.keep(r) }, name="dinic(n=1000)")

  println(b.dump_summaries())
}