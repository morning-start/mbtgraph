///|
/// euler — Python/NetworkX 随机图验证 (每算法 5 图)
///

///|
test "euler_euler_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      assert_eq(@euler.has_euler_circuit(g), true)
      assert_eq(@euler.has_euler_path(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "euler_euler_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      assert_eq(@euler.has_euler_circuit(g), false)
      assert_eq(@euler.has_euler_path(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "euler_euler_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      assert_eq(@euler.has_euler_circuit(g), true)
      assert_eq(@euler.has_euler_path(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "euler_euler_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      assert_eq(@euler.has_euler_circuit(g), false)
      assert_eq(@euler.has_euler_path(g), false)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "euler_euler_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      assert_eq(@euler.has_euler_circuit(g), false)
      assert_eq(@euler.has_euler_path(g), false)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
