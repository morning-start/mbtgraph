///|
/// operators — Python/NetworkX 随机图验证 (每算法 5 图)
///

///|
test "op_op_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let comp = @operators.complement(g)
      assert_eq(@core.GraphReadable::node_count(comp), 6)
      assert_eq(@core.GraphReadable::edge_count(comp), 10)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_op_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let comp = @operators.complement(g)
      assert_eq(@core.GraphReadable::node_count(comp), 8)
      assert_eq(@core.GraphReadable::edge_count(comp), 22)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_op_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let comp = @operators.complement(g)
      assert_eq(@core.GraphReadable::node_count(comp), 5)
      assert_eq(@core.GraphReadable::edge_count(comp), 4)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_op_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let comp = @operators.complement(g)
      assert_eq(@core.GraphReadable::node_count(comp), 10)
      assert_eq(@core.GraphReadable::edge_count(comp), 35)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_op_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6],\"edges\":[{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 7)
      let comp = @operators.complement(g)
      assert_eq(@core.GraphReadable::node_count(comp), 7)
      assert_eq(@core.GraphReadable::edge_count(comp), 15)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_cart_op_cart_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      let g2 = @storage.new_undirected()
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.cartesian_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 12)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_cart_op_cart_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let g2 = @storage.new_undirected()
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.cartesian_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 15)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_cart_op_cart_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 3)
      let g2 = @storage.new_undirected()
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.cartesian_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 9)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_cart_op_cart_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      let g2 = @storage.new_undirected()
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.cartesian_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 12)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_cart_op_cart_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let g2 = @storage.new_undirected()
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.cartesian_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 15)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_lex_op_lex_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.lexicographic_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 12)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_lex_op_lex_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.lexicographic_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 15)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_lex_op_lex_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 3)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.lexicographic_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 9)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_lex_op_lex_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.lexicographic_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 12)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_lex_op_lex_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.lexicographic_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 15)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_line_op_line_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let lg = @operators.line_graph(g)
      assert_eq(@core.GraphReadable::node_count(lg), 5)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_line_op_line_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let lg = @operators.line_graph(g)
      assert_eq(@core.GraphReadable::node_count(lg), 6)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_line_op_line_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let lg = @operators.line_graph(g)
      assert_eq(@core.GraphReadable::node_count(lg), 6)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_line_op_line_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let lg = @operators.line_graph(g)
      assert_eq(@core.GraphReadable::node_count(lg), 10)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_line_op_line_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6],\"edges\":[{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 7)
      let lg = @operators.line_graph(g)
      assert_eq(@core.GraphReadable::node_count(lg), 6)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_power_op_power_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let pg = @operators.power_graph(g, 2)
      assert_eq(@core.GraphReadable::node_count(pg), 6)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_power_op_power_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let pg = @operators.power_graph(g, 2)
      assert_eq(@core.GraphReadable::node_count(pg), 8)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_power_op_power_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let pg = @operators.power_graph(g, 2)
      assert_eq(@core.GraphReadable::node_count(pg), 5)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_power_op_power_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let pg = @operators.power_graph(g, 2)
      assert_eq(@core.GraphReadable::node_count(pg), 10)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_power_op_power_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 7)
      let pg = @operators.power_graph(g, 2)
      assert_eq(@core.GraphReadable::node_count(pg), 7)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_rev_op_rev_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":1,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":0,\"weight\":1.0},{\"source\":4,\"target\":3,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":5,\"target\":1,\"weight\":1.0},{\"source\":5,\"target\":2,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let rev = @operators.reverse(g)
      assert_eq(@core.GraphReadable::node_count(rev), 6)
      assert_eq(@core.GraphReadable::edge_count(rev), 12)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_rev_op_rev_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":4,\"target\":0,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":4,\"target\":3,\"weight\":1.0},{\"source\":5,\"target\":0,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let rev = @operators.reverse(g)
      assert_eq(@core.GraphReadable::node_count(rev), 8)
      assert_eq(@core.GraphReadable::edge_count(rev), 11)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_rev_op_rev_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":0,\"weight\":1.0},{\"source\":2,\"target\":1,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":1,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let rev = @operators.reverse(g)
      assert_eq(@core.GraphReadable::node_count(rev), 5)
      assert_eq(@core.GraphReadable::edge_count(rev), 9)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_rev_op_rev_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":1,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":2,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":2,\"weight\":1.0},{\"source\":5,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":1,\"weight\":1.0},{\"source\":7,\"target\":2,\"weight\":1.0},{\"source\":7,\"target\":3,\"weight\":1.0},{\"source\":8,\"target\":0,\"weight\":1.0},{\"source\":8,\"target\":2,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0},{\"source\":9,\"target\":8,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let rev = @operators.reverse(g)
      assert_eq(@core.GraphReadable::node_count(rev), 10)
      assert_eq(@core.GraphReadable::edge_count(rev), 19)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_rev_op_rev_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6],\"edges\":[{\"source\":1,\"target\":0,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":1,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":4,\"target\":2,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":2,\"weight\":1.0},{\"source\":6,\"target\":0,\"weight\":1.0},{\"source\":6,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 7)
      let rev = @operators.reverse(g)
      assert_eq(@core.GraphReadable::node_count(rev), 7)
      assert_eq(@core.GraphReadable::edge_count(rev), 15)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_tensor_op_tensor_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.tensor_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 12)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_tensor_op_tensor_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.tensor_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 15)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_tensor_op_tensor_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 3)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.tensor_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 9)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_tensor_op_tensor_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.tensor_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 12)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_tensor_op_tensor_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let p = @storage.new_undirected()
      for i in 0..<3 {
        @core.GraphWritable::add_node(p, 0.0) |> ignore
      }
      @core.GraphWritable::add_edge(p, @core.NodeId(0), @core.NodeId(1), 1.0)
      |> ignore
      @core.GraphWritable::add_edge(p, @core.NodeId(1), @core.NodeId(2), 1.0)
      |> ignore
      let r = @operators.tensor_product(g, p)
      assert_eq(@core.GraphReadable::node_count(r), 15)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_union_op_union_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let g2 = @storage.new_undirected()
      let u = @operators.graph_union(g, g2)
      assert_true(@core.GraphReadable::node_count(u) > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_union_op_union_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let g2 = @storage.new_undirected()
      let u = @operators.graph_union(g, g2)
      assert_true(@core.GraphReadable::node_count(u) > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_union_op_union_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let g2 = @storage.new_undirected()
      let u = @operators.graph_union(g, g2)
      assert_true(@core.GraphReadable::node_count(u) > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_union_op_union_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let g2 = @storage.new_undirected()
      let u = @operators.graph_union(g, g2)
      assert_true(@core.GraphReadable::node_count(u) > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "op_union_op_union_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6],\"edges\":[{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 7)
      let g2 = @storage.new_undirected()
      let u = @operators.graph_union(g, g2)
      assert_true(@core.GraphReadable::node_count(u) > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
