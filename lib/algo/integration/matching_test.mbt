///|
/// matching — Python/NetworkX 随机图验证 (每算法 5 图)
///

///|
test "match_match_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let left_nodes = Array::make(5, @core.NodeId(0))
      let mut i = 0
      while i < 5 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(5, @core.NodeId(0))
      i = 0
      while i < 5 {
        right_nodes[i] = @core.NodeId(5 + i)
        i = i + 1
      }
      let r = @matching.hopcroft_karp(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_match_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let left_nodes = Array::make(6, @core.NodeId(0))
      let mut i = 0
      while i < 6 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(4, @core.NodeId(0))
      i = 0
      while i < 4 {
        right_nodes[i] = @core.NodeId(6 + i)
        i = i + 1
      }
      let r = @matching.hopcroft_karp(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_match_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13],\"edges\":[{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":13,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":11,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":6,\"target\":10,\"weight\":1.0},{\"source\":6,\"target\":11,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 14)
      let left_nodes = Array::make(8, @core.NodeId(0))
      let mut i = 0
      while i < 8 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(6, @core.NodeId(0))
      i = 0
      while i < 6 {
        right_nodes[i] = @core.NodeId(8 + i)
        i = i + 1
      }
      let r = @matching.hopcroft_karp(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_match_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let left_nodes = Array::make(4, @core.NodeId(0))
      let mut i = 0
      while i < 4 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(4, @core.NodeId(0))
      i = 0
      while i < 4 {
        right_nodes[i] = @core.NodeId(4 + i)
        i = i + 1
      }
      let r = @matching.hopcroft_karp(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_match_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":10,\"weight\":1.0},{\"source\":4,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":5,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let left_nodes = Array::make(7, @core.NodeId(0))
      let mut i = 0
      while i < 7 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(5, @core.NodeId(0))
      i = 0
      while i < 5 {
        right_nodes[i] = @core.NodeId(7 + i)
        i = i + 1
      }
      let r = @matching.hopcroft_karp(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_bp_match_bp_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let left_nodes = Array::make(5, @core.NodeId(0))
      let mut i = 0
      while i < 5 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(5, @core.NodeId(0))
      i = 0
      while i < 5 {
        right_nodes[i] = @core.NodeId(5 + i)
        i = i + 1
      }
      let r = @matching.bipartite_matching_graph(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_bp_match_bp_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":8,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let left_nodes = Array::make(6, @core.NodeId(0))
      let mut i = 0
      while i < 6 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(4, @core.NodeId(0))
      i = 0
      while i < 4 {
        right_nodes[i] = @core.NodeId(6 + i)
        i = i + 1
      }
      let r = @matching.bipartite_matching_graph(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_bp_match_bp_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13],\"edges\":[{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":12,\"weight\":1.0},{\"source\":0,\"target\":13,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":1,\"target\":13,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":12,\"weight\":1.0},{\"source\":2,\"target\":13,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":13,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0},{\"source\":7,\"target\":11,\"weight\":1.0},{\"source\":7,\"target\":12,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 14)
      let left_nodes = Array::make(8, @core.NodeId(0))
      let mut i = 0
      while i < 8 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(6, @core.NodeId(0))
      i = 0
      while i < 6 {
        right_nodes[i] = @core.NodeId(8 + i)
        i = i + 1
      }
      let r = @matching.bipartite_matching_graph(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_bp_match_bp_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let left_nodes = Array::make(4, @core.NodeId(0))
      let mut i = 0
      while i < 4 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(4, @core.NodeId(0))
      i = 0
      while i < 4 {
        right_nodes[i] = @core.NodeId(4 + i)
        i = i + 1
      }
      let r = @matching.bipartite_matching_graph(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_bp_match_bp_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":11,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let left_nodes = Array::make(7, @core.NodeId(0))
      let mut i = 0
      while i < 7 {
        left_nodes[i] = @core.NodeId(i)
        i = i + 1
      }
      let right_nodes = Array::make(5, @core.NodeId(0))
      i = 0
      while i < 5 {
        right_nodes[i] = @core.NodeId(7 + i)
        i = i + 1
      }
      let r = @matching.bipartite_matching_graph(g, left_nodes, right_nodes)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_ed_match_ed_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @matching.edmonds_maximum_matching(g)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_ed_match_ed_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":8,\"target\":11,\"weight\":1.0},{\"source\":10,\"target\":11,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let r = @matching.edmonds_maximum_matching(g)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_ed_match_ed_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":13,\"weight\":1.0},{\"source\":2,\"target\":13,\"weight\":1.0},{\"source\":2,\"target\":14,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":5,\"target\":14,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":6,\"target\":13,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0},{\"source\":8,\"target\":10,\"weight\":1.0},{\"source\":8,\"target\":12,\"weight\":1.0},{\"source\":8,\"target\":13,\"weight\":1.0},{\"source\":9,\"target\":11,\"weight\":1.0},{\"source\":9,\"target\":12,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let r = @matching.edmonds_maximum_matching(g)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_ed_match_ed_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @matching.edmonds_maximum_matching(g)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "match_ed_match_ed_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],\"edges\":[{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":12,\"weight\":1.0},{\"source\":0,\"target\":17,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":14,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":12,\"weight\":1.0},{\"source\":3,\"target\":16,\"weight\":1.0},{\"source\":3,\"target\":17,\"weight\":1.0},{\"source\":4,\"target\":13,\"weight\":1.0},{\"source\":4,\"target\":17,\"weight\":1.0},{\"source\":4,\"target\":19,\"weight\":1.0},{\"source\":5,\"target\":15,\"weight\":1.0},{\"source\":5,\"target\":16,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":16,\"weight\":1.0},{\"source\":6,\"target\":18,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":14,\"weight\":1.0},{\"source\":7,\"target\":16,\"weight\":1.0},{\"source\":8,\"target\":18,\"weight\":1.0},{\"source\":9,\"target\":15,\"weight\":1.0},{\"source\":11,\"target\":18,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 20)
      let r = @matching.edmonds_maximum_matching(g)
      assert_true(r.size() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
