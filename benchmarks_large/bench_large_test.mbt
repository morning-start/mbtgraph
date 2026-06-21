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
test "TASK-G: benchmark (5000 nodes)" {
  let b = @bench.Bench::new()
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
  println(b.dump_summaries())
}

///|
test "TASK-G: benchmark (10000 nodes)" {
  let b = @bench.Bench::new()
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
  println(b.dump_summaries())
}
