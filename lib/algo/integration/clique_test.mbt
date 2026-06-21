///|
/// clique — Python/NetworkX 随机图验证 (每算法 5 图)
///

///|
test "clique_clique_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let r = @clique.find_maximum_clique(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_clique_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @clique.find_maximum_clique(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_clique_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let r = @clique.find_maximum_clique(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_clique_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      let r = @clique.find_maximum_clique(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_clique_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @clique.find_maximum_clique(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_is_clique_is_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let r = @clique.find_maximum_independent_set(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_is_clique_is_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @clique.find_maximum_independent_set(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_is_clique_is_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let r = @clique.find_maximum_independent_set(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_is_clique_is_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      let r = @clique.find_maximum_independent_set(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_is_clique_is_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @clique.find_maximum_independent_set(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_vc_clique_vc_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 5)
      let r = @clique.find_minimum_vertex_cover(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_vc_clique_vc_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @clique.find_minimum_vertex_cover(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_vc_clique_vc_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let r = @clique.find_minimum_vertex_cover(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_vc_clique_vc_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 4)
      let r = @clique.find_minimum_vertex_cover(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "clique_vc_clique_vc_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @clique.find_minimum_vertex_cover(g)
      assert_true(r.size > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
