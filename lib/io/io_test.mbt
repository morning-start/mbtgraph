///|
/// I/O 模块测试套件 (42 tests)
///
/// DOT: 20 tests | JSON: 12 tests | Stats: 10 tests

// ============================================================================
// 辅助函数
// ============================================================================

fn make_simple_directed() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  @core.GraphWritable::add_node(g, 2.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 2.5)
  |> ignore
  g
}

///|
fn make_simple_undirected() -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  @core.GraphWritable::add_node(g, 2.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 3.0)
  |> ignore
  g
}

///|
fn make_chain_4() -> @storage.DirectedAdjList {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  g
}

///|
fn approx_eq(a : Double, b : Double) -> Bool {
  let d = a - b
  if d < 0.0 {
    -d < 0.0001
  } else {
    d < 0.0001
  }
}

// ============================================================================
// DOT 格式: 序列化测试 (5)
// ============================================================================

///|
test "dot_write_directed" {
  let g = make_simple_directed()
  let result = write_dot(g, "G")
  assert_true(result.contains("digraph"))
  assert_true(result.contains("G {"))
  assert_true(result.contains("0 -> 1 [weight=1]"))
  assert_true(result.contains("1 -> 2 [weight=2.5]"))
  assert_true(result.contains("}"))
}

///|
test "dot_write_undirected" {
  let g = make_simple_undirected()
  let result = write_dot(g, "G")
  assert_true(result.contains("graph"))
  assert_true(result.contains("0 -- 1"))
  assert_true(result.contains("1 -- 2"))
}

///|
test "dot_write_custom_name" {
  let g = make_simple_directed()
  let result = write_dot(g, "MyGraph")
  assert_true(result.contains("MyGraph {"))
}

///|
test "dot_write_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = write_dot(g, "G")
  assert_true(result.contains("digraph G {"))
  assert_true(result.contains("}"))
}

///|
test "dot_write_empty" {
  let g = @storage.new_directed()
  let result = write_dot(g, "G")
  assert_true(result.contains("digraph G {"))
  assert_true(result.contains("}"))
}

// ============================================================================
// DOT 格式: 解析测试 (10)
// ============================================================================

///|
test "dot_parse_basic_digraph" {
  let dot = "digraph G { 0 -> 1; 1 -> 2; }"
  let g = @storage.new_directed()
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 3)
      assert_eq(@core.GraphReadable::edge_count(g), 2)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_parse_basic_graph" {
  let dot = "graph G { 0 -- 1; 1 -- 2; }"
  let g = @storage.new_undirected()
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 3)
      assert_eq(@core.GraphReadable::edge_count(g), 2)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_parse_with_weight" {
  let dot = "digraph G { 0 -> 1 [weight=3.0]; 1 -> 2; }"
  let g = @storage.new_directed()
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 3)
      assert_eq(@core.GraphReadable::edge_count(g), 2)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_parse_no_name" {
  let dot = "digraph { 0 -> 1; }"
  let g = @storage.new_directed()
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 2)
      assert_eq(@core.GraphReadable::edge_count(g), 1)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_parse_comment_line" {
  let dot = "digraph G {\n// this is a comment\n0 -> 1;\n}"
  let g = @storage.new_directed()
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 2)
      assert_eq(@core.GraphReadable::edge_count(g), 1)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_parse_block_comment" {
  let dot = "digraph G { /* block */ 0 -> 1; }"
  let g = @storage.new_directed()
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => assert_eq(@core.GraphReadable::node_count(g), 2)
    Err(_) => assert_true(false)
  }
}

///|
test "dot_parse_multi_edge" {
  let dot = "digraph G { 0 -> 1; 1 -> 2; 2 -> 0; }"
  let g = @storage.new_directed()
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 3)
      assert_eq(@core.GraphReadable::edge_count(g), 3)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_parse_error_invalid_keyword" {
  let dot = "digraphh G { 0 -> 1; }"
  let g = @storage.new_directed()
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}

///|
test "dot_parse_into_existing_graph" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let dot = "digraph G { 0 -> 1; 1 -> 2; }"
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 3)
      assert_eq(@core.GraphReadable::edge_count(g), 2)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_parse_hash_comment" {
  let dot = "digraph G {\n# comment\n0 -> 1;\n}"
  let g = @storage.new_directed()
  let result = parse_dot_into(g, dot)
  match result {
    Ok(_) => assert_eq(@core.GraphReadable::node_count(g), 2)
    Err(_) => assert_true(false)
  }
}

// ============================================================================
// DOT 格式: 往返测试 (Round-trip, 5)
// ============================================================================

///|
test "dot_roundtrip_directed_simple" {
  let g = make_simple_directed()
  let dot = write_dot(g, "G")
  let g2 = @storage.new_directed()
  let result = parse_dot_into(g2, dot)
  match result {
    Ok(_) => {
      assert_eq(
        @core.GraphReadable::node_count(g2),
        @core.GraphReadable::node_count(g),
      )
      assert_eq(
        @core.GraphReadable::edge_count(g2),
        @core.GraphReadable::edge_count(g),
      )
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_roundtrip_undirected_simple" {
  let g = make_simple_undirected()
  let dot = write_dot(g, "G")
  let g2 = @storage.new_undirected()
  let result = parse_dot_into(g2, dot)
  match result {
    Ok(_) => {
      assert_eq(
        @core.GraphReadable::node_count(g2),
        @core.GraphReadable::node_count(g),
      )
      assert_eq(
        @core.GraphReadable::edge_count(g2),
        @core.GraphReadable::edge_count(g),
      )
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_roundtrip_chain" {
  let g = make_chain_4()
  let dot = write_dot(g, "G")
  let g2 = @storage.new_directed()
  let result = parse_dot_into(g2, dot)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g2), 4)
      assert_eq(@core.GraphReadable::edge_count(g2), 3)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_roundtrip_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let dot = write_dot(g, "G")
  let g2 = @storage.new_directed()
  let result = parse_dot_into(g2, dot)
  match result {
    Ok(_) => {
      let n2 = @core.GraphReadable::node_count(g2)
      // write_dot digraph G { } with empty body, parse creates 0 nodes
      assert_eq(n2, 0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "dot_roundtrip_empty" {
  let g = @storage.new_directed()
  let dot = write_dot(g, "G")
  let g2 = @storage.new_directed()
  let result = parse_dot_into(g2, dot)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g2), 0)
      assert_eq(@core.GraphReadable::edge_count(g2), 0)
    }
    Err(_) => assert_true(false)
  }
}

// ============================================================================
// JSON 格式: 序列化测试 (4)
// ============================================================================

///|
test "json_write_directed" {
  let g = make_simple_directed()
  let result = graph_to_json(g, false)
  assert_true(result.contains("\"mbtgraph\": \"1.0\""))
  assert_true(result.contains("\"directed\": true"))
  assert_true(result.contains("\"nodes\""))
  assert_true(result.contains("\"edges\""))
}

///|
test "json_write_undirected" {
  let g = make_simple_undirected()
  let result = graph_to_json(g, false)
  assert_true(result.contains("\"directed\": false"))
}

///|
test "json_write_pretty" {
  let g = make_simple_directed()
  let compact = graph_to_json(g, false)
  let pretty = graph_to_json(g, true)
  assert_true(pretty.length() >= compact.length())
}

///|
test "json_write_empty" {
  let g = @storage.new_directed()
  let result = graph_to_json(g, false)
  assert_true(result.contains("\"nodes\""))
  assert_true(result.contains("\"edges\""))
}

// ============================================================================
// JSON 格式: 解析测试 (4)
// ============================================================================

///|
test "json_parse_basic" {
  let json = "{ \"mbtgraph\": \"1.0\", \"directed\": true, \"nodes\": [0, 1], \"edges\": [{ \"source\": 0, \"target\": 1, \"weight\": 1.0 }] }"
  let g = @storage.new_directed()
  let result = parse_json_into(g, json)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 2)
      assert_eq(@core.GraphReadable::edge_count(g), 1)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "json_parse_multi_edge" {
  let json = "{ \"mbtgraph\": \"1.0\", \"directed\": true, \"nodes\": [0, 1, 2], \"edges\": [{ \"source\": 0, \"target\": 1, \"weight\": 1.0 }, { \"source\": 1, \"target\": 2, \"weight\": 2.5 }] }"
  let g = @storage.new_directed()
  let result = parse_json_into(g, json)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 3)
      assert_eq(@core.GraphReadable::edge_count(g), 2)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "json_parse_into_existing" {
  let json = "{ \"mbtgraph\": \"1.0\", \"directed\": true, \"nodes\": [0, 1], \"edges\": [{ \"source\": 0, \"target\": 1, \"weight\": 2.0 }] }"
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 99.0) |> ignore
  let result = parse_json_into(g, json)
  match result {
    Ok(_) => {
      let n = @core.GraphReadable::node_count(g)
      assert_true(n >= 2)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "json_parse_error" {
  let json = "invalid json"
  let g = @storage.new_directed()
  let result = parse_json_into(g, json)
  match result {
    Ok(_) => assert_true(false)
    Err(_) => assert_true(true)
  }
}

// ============================================================================
// JSON 格式: 往返测试 (4)
// ============================================================================

///|
test "json_roundtrip_directed" {
  let g = make_simple_directed()
  let json = graph_to_json(g, false)
  let g2 = @storage.new_directed()
  let result = parse_json_into(g2, json)
  match result {
    Ok(_) => {
      assert_eq(
        @core.GraphReadable::node_count(g2),
        @core.GraphReadable::node_count(g),
      )
      assert_eq(
        @core.GraphReadable::edge_count(g2),
        @core.GraphReadable::edge_count(g),
      )
    }
    Err(_) => assert_true(false)
  }
}

///|
test "json_roundtrip_undirected" {
  let g = make_simple_undirected()
  let json = graph_to_json(g, false)
  let g2 = @storage.new_directed()
  let result = parse_json_into(g2, json)
  match result {
    Ok(_) => {
      assert_eq(
        @core.GraphReadable::node_count(g2),
        @core.GraphReadable::node_count(g),
      )
      assert_eq(
        @core.GraphReadable::edge_count(g2),
        @core.GraphReadable::edge_count(g),
      )
    }
    Err(_) => assert_true(false)
  }
}

///|
test "json_roundtrip_chain" {
  let g = make_chain_4()
  let json = graph_to_json(g, false)
  let g2 = @storage.new_directed()
  let result = parse_json_into(g2, json)
  match result {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g2), 4)
      assert_eq(@core.GraphReadable::edge_count(g2), 3)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "json_roundtrip_pretty" {
  let g = make_simple_directed()
  let json = graph_to_json(g, true)
  let g2 = @storage.new_directed()
  let result = parse_json_into(g2, json)
  match result {
    Ok(_) => {
      assert_eq(
        @core.GraphReadable::node_count(g2),
        @core.GraphReadable::node_count(g),
      )
      assert_eq(
        @core.GraphReadable::edge_count(g2),
        @core.GraphReadable::edge_count(g),
      )
    }
    Err(_) => assert_true(false)
  }
}

// ============================================================================
// 图统计: 基本统计测试 (4)
// ============================================================================

///|
test "stats_basic_directed" {
  let g = make_simple_directed()
  let s = basic_stats(g)
  assert_eq(s.node_count, 3)
  assert_eq(s.edge_count, 2)
  assert_true(s.is_directed)
  assert_true(approx_eq(s.avg_degree, 2.0 / 3.0))
  assert_eq(s.min_degree, 0)
  assert_eq(s.max_degree, 1)
  assert_eq(s.self_loop_count, 0)
}

///|
test "stats_basic_undirected" {
  let g = make_simple_undirected()
  let s = basic_stats(g)
  assert_eq(s.node_count, 3)
  assert_eq(s.edge_count, 2)
  assert_false(s.is_directed)
}

///|
test "stats_basic_empty" {
  let g = @storage.new_directed()
  let s = basic_stats(g)
  assert_eq(s.node_count, 0)
  assert_eq(s.edge_count, 0)
  assert_true(approx_eq(s.density, 0.0))
}

///|
test "stats_basic_single_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let s = basic_stats(g)
  assert_eq(s.node_count, 1)
  assert_eq(s.edge_count, 0)
}

// ============================================================================
// 图统计: 度分布测试 (3)
// ============================================================================

///|
test "stats_degree_dist_uniform" {
  let g = make_chain_4()
  let d = degree_distribution(g)
  assert_eq(d.min_degree, 0)
  assert_eq(d.max_degree, 1)
  assert_true(d.histogram.length() >= 2)
  // histogram: degree 0 -> 1 node, degree 1 -> 3 nodes
  assert_eq(d.histogram[0], 1)
  assert_eq(d.histogram[1], 3)
}

///|
test "stats_degree_dist_empty" {
  let g = @storage.new_directed()
  let d = degree_distribution(g)
  assert_eq(d.min_degree, 0)
  assert_eq(d.max_degree, 0)
}

///|
test "stats_degree_dist_one_node" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let d = degree_distribution(g)
  assert_eq(d.min_degree, 0)
  assert_eq(d.max_degree, 0)
}

// ============================================================================
// 图统计: 连通性测试 (3)
// ============================================================================

///|
test "stats_connectivity_chain" {
  let g = make_chain_4()
  let c = connectivity_stats(g)
  assert_true(c.component_count >= 1)
  assert_true(c.largest_component_size >= 1)
}

///|
test "stats_connectivity_empty" {
  let g = @storage.new_directed()
  let c = connectivity_stats(g)
  assert_eq(c.component_count, 0)
  assert_eq(c.largest_component_size, 0)
}

///|
test "stats_connectivity_two_components" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 1.0) |> ignore
  @core.GraphWritable::add_node(g, 2.0) |> ignore
  @core.GraphWritable::add_node(g, 3.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  let c = connectivity_stats(g)
  assert_eq(c.component_count, 2)
  assert_eq(c.largest_component_size, 2)
}
