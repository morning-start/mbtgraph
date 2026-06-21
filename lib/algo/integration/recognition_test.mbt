///|
/// recognition — Python/NetworkX 随机图验证 (每算法 5 图)
///

///|
test "rec_rec_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8],\"edges\":[{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 9)
      assert_eq(@recognition.is_bipartite(g), true)
      assert_eq(@recognition.is_tree(g), false)
      assert_eq(@recognition.is_forest(g), false)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "rec_rec_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      assert_eq(@recognition.is_bipartite(g), false)
      assert_eq(@recognition.is_tree(g), false)
      assert_eq(@recognition.is_forest(g), false)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "rec_rec_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      assert_eq(@recognition.is_bipartite(g), false)
      assert_eq(@recognition.is_tree(g), false)
      assert_eq(@recognition.is_forest(g), false)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "rec_rec_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      assert_eq(@recognition.is_bipartite(g), true)
      assert_eq(@recognition.is_tree(g), true)
      assert_eq(@recognition.is_forest(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "rec_rec_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 9)
      assert_eq(@recognition.is_bipartite(g), true)
      assert_eq(@recognition.is_tree(g), false)
      assert_eq(@recognition.is_forest(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
