///|
/// traversal — Python/NetworkX 随机图验证 (每算法 5 图)
///

///|
test "bfs_bfs_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":0,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":1,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":3,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":2,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":8,\"target\":0,\"weight\":1.0},{\"source\":8,\"target\":5,\"weight\":1.0},{\"source\":9,\"target\":2,\"weight\":1.0},{\"source\":9,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @traversal.bfs(g, @core.NodeId(0))
      assert_eq(r.distance(@core.NodeId(0)), 0)
      assert_eq(r.distance(@core.NodeId(1)), 1)
      assert_eq(r.distance(@core.NodeId(2)), 2)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "bfs_bfs_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":0,\"weight\":1.0},{\"source\":1,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":3,\"target\":2,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":7,\"target\":0,\"weight\":1.0},{\"source\":7,\"target\":4,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":11,\"weight\":1.0},{\"source\":8,\"target\":2,\"weight\":1.0},{\"source\":8,\"target\":4,\"weight\":1.0},{\"source\":8,\"target\":7,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0},{\"source\":9,\"target\":1,\"weight\":1.0},{\"source\":9,\"target\":3,\"weight\":1.0},{\"source\":9,\"target\":5,\"weight\":1.0},{\"source\":9,\"target\":7,\"weight\":1.0},{\"source\":9,\"target\":10,\"weight\":1.0},{\"source\":10,\"target\":1,\"weight\":1.0},{\"source\":10,\"target\":2,\"weight\":1.0},{\"source\":10,\"target\":5,\"weight\":1.0},{\"source\":10,\"target\":7,\"weight\":1.0},{\"source\":10,\"target\":8,\"weight\":1.0},{\"source\":11,\"target\":1,\"weight\":1.0},{\"source\":11,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let r = @traversal.bfs(g, @core.NodeId(0))
      assert_eq(r.distance(@core.NodeId(0)), 0)
      assert_eq(r.distance(@core.NodeId(1)), 2)
      assert_eq(r.distance(@core.NodeId(2)), 2)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "bfs_bfs_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":12,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":14,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":4,\"target\":13,\"weight\":1.0},{\"source\":5,\"target\":1,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":1,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":4,\"weight\":1.0},{\"source\":6,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":8,\"target\":1,\"weight\":1.0},{\"source\":8,\"target\":4,\"weight\":1.0},{\"source\":8,\"target\":7,\"weight\":1.0},{\"source\":9,\"target\":0,\"weight\":1.0},{\"source\":9,\"target\":1,\"weight\":1.0},{\"source\":10,\"target\":1,\"weight\":1.0},{\"source\":10,\"target\":8,\"weight\":1.0},{\"source\":10,\"target\":12,\"weight\":1.0},{\"source\":11,\"target\":3,\"weight\":1.0},{\"source\":11,\"target\":9,\"weight\":1.0},{\"source\":11,\"target\":12,\"weight\":1.0},{\"source\":12,\"target\":0,\"weight\":1.0},{\"source\":12,\"target\":6,\"weight\":1.0},{\"source\":13,\"target\":1,\"weight\":1.0},{\"source\":13,\"target\":2,\"weight\":1.0},{\"source\":14,\"target\":3,\"weight\":1.0},{\"source\":14,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let r = @traversal.bfs(g, @core.NodeId(0))
      assert_eq(r.distance(@core.NodeId(0)), 0)
      assert_eq(r.distance(@core.NodeId(1)), 2)
      assert_eq(r.distance(@core.NodeId(2)), 3)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "bfs_bfs_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":0,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":4,\"target\":3,\"weight\":1.0},{\"source\":5,\"target\":0,\"weight\":1.0},{\"source\":6,\"target\":2,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":5,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":1,\"weight\":1.0},{\"source\":7,\"target\":4,\"weight\":1.0},{\"source\":7,\"target\":6,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @traversal.bfs(g, @core.NodeId(0))
      assert_eq(r.distance(@core.NodeId(0)), 0)
      assert_eq(r.distance(@core.NodeId(1)), 1)
      assert_eq(r.distance(@core.NodeId(2)), 1)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "bfs_bfs_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],\"edges\":[{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":12,\"weight\":1.0},{\"source\":0,\"target\":17,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":2,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":10,\"weight\":1.0},{\"source\":3,\"target\":11,\"weight\":1.0},{\"source\":4,\"target\":2,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":19,\"weight\":1.0},{\"source\":5,\"target\":0,\"weight\":1.0},{\"source\":5,\"target\":4,\"weight\":1.0},{\"source\":5,\"target\":14,\"weight\":1.0},{\"source\":5,\"target\":16,\"weight\":1.0},{\"source\":5,\"target\":19,\"weight\":1.0},{\"source\":6,\"target\":4,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":0,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0},{\"source\":10,\"target\":6,\"weight\":1.0},{\"source\":10,\"target\":14,\"weight\":1.0},{\"source\":10,\"target\":17,\"weight\":1.0},{\"source\":10,\"target\":18,\"weight\":1.0},{\"source\":11,\"target\":2,\"weight\":1.0},{\"source\":11,\"target\":9,\"weight\":1.0},{\"source\":11,\"target\":14,\"weight\":1.0},{\"source\":11,\"target\":17,\"weight\":1.0},{\"source\":11,\"target\":19,\"weight\":1.0},{\"source\":12,\"target\":9,\"weight\":1.0},{\"source\":12,\"target\":18,\"weight\":1.0},{\"source\":12,\"target\":19,\"weight\":1.0},{\"source\":13,\"target\":2,\"weight\":1.0},{\"source\":14,\"target\":4,\"weight\":1.0},{\"source\":14,\"target\":10,\"weight\":1.0},{\"source\":15,\"target\":6,\"weight\":1.0},{\"source\":15,\"target\":18,\"weight\":1.0},{\"source\":16,\"target\":4,\"weight\":1.0},{\"source\":16,\"target\":19,\"weight\":1.0},{\"source\":17,\"target\":6,\"weight\":1.0},{\"source\":17,\"target\":14,\"weight\":1.0},{\"source\":18,\"target\":0,\"weight\":1.0},{\"source\":18,\"target\":5,\"weight\":1.0},{\"source\":18,\"target\":11,\"weight\":1.0},{\"source\":18,\"target\":14,\"weight\":1.0},{\"source\":19,\"target\":0,\"weight\":1.0},{\"source\":19,\"target\":1,\"weight\":1.0},{\"source\":19,\"target\":3,\"weight\":1.0},{\"source\":19,\"target\":4,\"weight\":1.0},{\"source\":19,\"target\":8,\"weight\":1.0},{\"source\":19,\"target\":15,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 20)
      let r = @traversal.bfs(g, @core.NodeId(0))
      assert_eq(r.distance(@core.NodeId(0)), 0)
      assert_eq(r.distance(@core.NodeId(1)), 3)
      assert_eq(r.distance(@core.NodeId(2)), 4)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cycle_cycle_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":0,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":1,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":4,\"target\":0,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":4,\"target\":3,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":3,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":8,\"weight\":1.0},{\"source\":7,\"target\":5,\"weight\":1.0},{\"source\":8,\"target\":0,\"weight\":1.0},{\"source\":8,\"target\":1,\"weight\":1.0},{\"source\":8,\"target\":7,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      assert_eq(@traversal.has_cycle(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cycle_cycle_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":1,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":6,\"target\":10,\"weight\":1.0},{\"source\":7,\"target\":2,\"weight\":1.0},{\"source\":7,\"target\":4,\"weight\":1.0},{\"source\":9,\"target\":1,\"weight\":1.0},{\"source\":9,\"target\":5,\"weight\":1.0},{\"source\":9,\"target\":10,\"weight\":1.0},{\"source\":10,\"target\":1,\"weight\":1.0},{\"source\":10,\"target\":2,\"weight\":1.0},{\"source\":10,\"target\":5,\"weight\":1.0},{\"source\":10,\"target\":7,\"weight\":1.0},{\"source\":10,\"target\":9,\"weight\":1.0},{\"source\":11,\"target\":3,\"weight\":1.0},{\"source\":11,\"target\":6,\"weight\":1.0},{\"source\":11,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      assert_eq(@traversal.has_cycle(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cycle_cycle_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":0,\"target\":13,\"weight\":1.0},{\"source\":0,\"target\":14,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":14,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":1,\"weight\":1.0},{\"source\":3,\"target\":2,\"weight\":1.0},{\"source\":3,\"target\":14,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":11,\"weight\":1.0},{\"source\":4,\"target\":13,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":5,\"target\":12,\"weight\":1.0},{\"source\":5,\"target\":14,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":5,\"weight\":1.0},{\"source\":8,\"target\":0,\"weight\":1.0},{\"source\":8,\"target\":7,\"weight\":1.0},{\"source\":9,\"target\":1,\"weight\":1.0},{\"source\":9,\"target\":4,\"weight\":1.0},{\"source\":9,\"target\":8,\"weight\":1.0},{\"source\":9,\"target\":12,\"weight\":1.0},{\"source\":10,\"target\":6,\"weight\":1.0},{\"source\":11,\"target\":13,\"weight\":1.0},{\"source\":12,\"target\":3,\"weight\":1.0},{\"source\":12,\"target\":5,\"weight\":1.0},{\"source\":13,\"target\":0,\"weight\":1.0},{\"source\":13,\"target\":4,\"weight\":1.0},{\"source\":13,\"target\":6,\"weight\":1.0},{\"source\":13,\"target\":11,\"weight\":1.0},{\"source\":14,\"target\":0,\"weight\":1.0},{\"source\":14,\"target\":3,\"weight\":1.0},{\"source\":14,\"target\":4,\"weight\":1.0},{\"source\":14,\"target\":6,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      assert_eq(@traversal.has_cycle(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cycle_cycle_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":1,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":1,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":0,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":2,\"weight\":1.0},{\"source\":6,\"target\":4,\"weight\":1.0},{\"source\":6,\"target\":5,\"weight\":1.0},{\"source\":7,\"target\":2,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      assert_eq(@traversal.has_cycle(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cycle_cycle_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],\"edges\":[{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":13,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":13,\"weight\":1.0},{\"source\":1,\"target\":16,\"weight\":1.0},{\"source\":1,\"target\":18,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":12,\"weight\":1.0},{\"source\":3,\"target\":1,\"weight\":1.0},{\"source\":3,\"target\":2,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":13,\"weight\":1.0},{\"source\":4,\"target\":16,\"weight\":1.0},{\"source\":4,\"target\":19,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":14,\"weight\":1.0},{\"source\":6,\"target\":2,\"weight\":1.0},{\"source\":7,\"target\":1,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0},{\"source\":7,\"target\":17,\"weight\":1.0},{\"source\":7,\"target\":18,\"weight\":1.0},{\"source\":7,\"target\":19,\"weight\":1.0},{\"source\":8,\"target\":0,\"weight\":1.0},{\"source\":8,\"target\":3,\"weight\":1.0},{\"source\":8,\"target\":13,\"weight\":1.0},{\"source\":8,\"target\":16,\"weight\":1.0},{\"source\":8,\"target\":19,\"weight\":1.0},{\"source\":9,\"target\":3,\"weight\":1.0},{\"source\":9,\"target\":5,\"weight\":1.0},{\"source\":9,\"target\":6,\"weight\":1.0},{\"source\":9,\"target\":18,\"weight\":1.0},{\"source\":10,\"target\":6,\"weight\":1.0},{\"source\":10,\"target\":14,\"weight\":1.0},{\"source\":10,\"target\":19,\"weight\":1.0},{\"source\":11,\"target\":2,\"weight\":1.0},{\"source\":11,\"target\":7,\"weight\":1.0},{\"source\":11,\"target\":17,\"weight\":1.0},{\"source\":12,\"target\":1,\"weight\":1.0},{\"source\":12,\"target\":2,\"weight\":1.0},{\"source\":12,\"target\":3,\"weight\":1.0},{\"source\":12,\"target\":7,\"weight\":1.0},{\"source\":12,\"target\":9,\"weight\":1.0},{\"source\":12,\"target\":15,\"weight\":1.0},{\"source\":13,\"target\":3,\"weight\":1.0},{\"source\":13,\"target\":5,\"weight\":1.0},{\"source\":13,\"target\":7,\"weight\":1.0},{\"source\":13,\"target\":10,\"weight\":1.0},{\"source\":14,\"target\":0,\"weight\":1.0},{\"source\":14,\"target\":11,\"weight\":1.0},{\"source\":14,\"target\":16,\"weight\":1.0},{\"source\":15,\"target\":5,\"weight\":1.0},{\"source\":15,\"target\":6,\"weight\":1.0},{\"source\":15,\"target\":16,\"weight\":1.0},{\"source\":16,\"target\":3,\"weight\":1.0},{\"source\":16,\"target\":10,\"weight\":1.0},{\"source\":17,\"target\":8,\"weight\":1.0},{\"source\":19,\"target\":3,\"weight\":1.0},{\"source\":19,\"target\":8,\"weight\":1.0},{\"source\":19,\"target\":16,\"weight\":1.0},{\"source\":19,\"target\":17,\"weight\":1.0},{\"source\":19,\"target\":18,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 20)
      assert_eq(@traversal.has_cycle(g), true)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "topo_topo_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      assert_true(!@traversal.has_cycle(g))
      match @traversal.topo_sort_kahn(g) {
        Ok(o) => assert_eq(o.length(), 10)
        Err(_) => ()
      }
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "topo_topo_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":8,\"target\":11,\"weight\":1.0},{\"source\":10,\"target\":11,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      assert_true(!@traversal.has_cycle(g))
      match @traversal.topo_sort_kahn(g) {
        Ok(o) => assert_eq(o.length(), 12)
        Err(_) => ()
      }
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "topo_topo_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":0,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":13,\"weight\":1.0},{\"source\":2,\"target\":13,\"weight\":1.0},{\"source\":2,\"target\":14,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":5,\"target\":14,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":6,\"target\":10,\"weight\":1.0},{\"source\":6,\"target\":13,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0},{\"source\":8,\"target\":10,\"weight\":1.0},{\"source\":8,\"target\":12,\"weight\":1.0},{\"source\":8,\"target\":13,\"weight\":1.0},{\"source\":9,\"target\":11,\"weight\":1.0},{\"source\":9,\"target\":12,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      assert_true(!@traversal.has_cycle(g))
      match @traversal.topo_sort_kahn(g) {
        Ok(o) => assert_eq(o.length(), 15)
        Err(_) => ()
      }
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "topo_topo_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      assert_true(!@traversal.has_cycle(g))
      match @traversal.topo_sort_kahn(g) {
        Ok(o) => assert_eq(o.length(), 8)
        Err(_) => ()
      }
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "topo_topo_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],\"edges\":[{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":12,\"weight\":1.0},{\"source\":0,\"target\":14,\"weight\":1.0},{\"source\":0,\"target\":17,\"weight\":1.0},{\"source\":0,\"target\":18,\"weight\":1.0},{\"source\":0,\"target\":19,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":1,\"target\":12,\"weight\":1.0},{\"source\":1,\"target\":15,\"weight\":1.0},{\"source\":1,\"target\":19,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":14,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":12,\"weight\":1.0},{\"source\":3,\"target\":16,\"weight\":1.0},{\"source\":3,\"target\":17,\"weight\":1.0},{\"source\":3,\"target\":18,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":13,\"weight\":1.0},{\"source\":4,\"target\":17,\"weight\":1.0},{\"source\":4,\"target\":19,\"weight\":1.0},{\"source\":5,\"target\":14,\"weight\":1.0},{\"source\":5,\"target\":15,\"weight\":1.0},{\"source\":5,\"target\":16,\"weight\":1.0},{\"source\":5,\"target\":19,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":11,\"weight\":1.0},{\"source\":6,\"target\":16,\"weight\":1.0},{\"source\":6,\"target\":18,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":14,\"weight\":1.0},{\"source\":7,\"target\":16,\"weight\":1.0},{\"source\":7,\"target\":18,\"weight\":1.0},{\"source\":8,\"target\":16,\"weight\":1.0},{\"source\":8,\"target\":18,\"weight\":1.0},{\"source\":9,\"target\":15,\"weight\":1.0},{\"source\":9,\"target\":16,\"weight\":1.0},{\"source\":10,\"target\":18,\"weight\":1.0},{\"source\":11,\"target\":14,\"weight\":1.0},{\"source\":11,\"target\":18,\"weight\":1.0},{\"source\":12,\"target\":13,\"weight\":1.0},{\"source\":15,\"target\":16,\"weight\":1.0},{\"source\":17,\"target\":18,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 20)
      assert_true(!@traversal.has_cycle(g))
      match @traversal.topo_sort_kahn(g) {
        Ok(o) => assert_eq(o.length(), 20)
        Err(_) => ()
      }
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
