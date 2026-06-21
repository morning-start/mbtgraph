///|
/// connectivity — Python/NetworkX 随机图验证 (每算法 5 图)
///

///|
test "bcc_bcc_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @conn.biconnected_components(g)
      assert_true(r.count() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "bcc_bcc_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":11,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":10,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":8,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":5,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0},{\"source\":9,\"target\":10,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let r = @conn.biconnected_components(g)
      assert_true(r.count() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "bcc_bcc_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":10,\"weight\":1.0},{\"source\":0,\"target\":11,\"weight\":1.0},{\"source\":0,\"target\":14,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":13,\"weight\":1.0},{\"source\":1,\"target\":14,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":12,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":13,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":14,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":5,\"target\":12,\"weight\":1.0},{\"source\":5,\"target\":14,\"weight\":1.0},{\"source\":6,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":10,\"weight\":1.0},{\"source\":6,\"target\":14,\"weight\":1.0},{\"source\":7,\"target\":10,\"weight\":1.0},{\"source\":7,\"target\":11,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0},{\"source\":8,\"target\":11,\"weight\":1.0},{\"source\":9,\"target\":11,\"weight\":1.0},{\"source\":9,\"target\":13,\"weight\":1.0},{\"source\":11,\"target\":12,\"weight\":1.0},{\"source\":12,\"target\":14,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let r = @conn.biconnected_components(g)
      assert_true(r.count() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "bcc_bcc_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @conn.biconnected_components(g)
      assert_true(r.count() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "bcc_bcc_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":15,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":13,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":14,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":13,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":5,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":16,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":13,\"weight\":1.0},{\"source\":7,\"target\":11,\"weight\":1.0},{\"source\":7,\"target\":12,\"weight\":1.0},{\"source\":7,\"target\":14,\"weight\":1.0},{\"source\":7,\"target\":17,\"weight\":1.0},{\"source\":8,\"target\":12,\"weight\":1.0},{\"source\":9,\"target\":13,\"weight\":1.0},{\"source\":9,\"target\":16,\"weight\":1.0},{\"source\":12,\"target\":13,\"weight\":1.0},{\"source\":12,\"target\":16,\"weight\":1.0},{\"source\":13,\"target\":17,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 18)
      let r = @conn.biconnected_components(g)
      assert_true(r.count() > 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cc_cc_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":2.21},{\"source\":0,\"target\":4,\"weight\":8.63},{\"source\":0,\"target\":9,\"weight\":7.87},{\"source\":1,\"target\":2,\"weight\":3.3},{\"source\":1,\"target\":6,\"weight\":5.46},{\"source\":1,\"target\":9,\"weight\":5.05},{\"source\":2,\"target\":5,\"weight\":6.86},{\"source\":2,\"target\":6,\"weight\":8.1},{\"source\":2,\"target\":9,\"weight\":1.84},{\"source\":3,\"target\":4,\"weight\":1.26},{\"source\":3,\"target\":6,\"weight\":8.52},{\"source\":3,\"target\":7,\"weight\":4.89},{\"source\":4,\"target\":5,\"weight\":7.86},{\"source\":4,\"target\":6,\"weight\":1.02},{\"source\":4,\"target\":7,\"weight\":5.01},{\"source\":4,\"target\":9,\"weight\":7.49},{\"source\":5,\"target\":6,\"weight\":3.06},{\"source\":6,\"target\":7,\"weight\":9.51},{\"source\":7,\"target\":8,\"weight\":9.11},{\"source\":7,\"target\":9,\"weight\":1.28}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @conn.connected_components(g)
      assert_eq(r.count(), 1)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cc_cc_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":3,\"weight\":9.6},{\"source\":0,\"target\":4,\"weight\":9.53},{\"source\":0,\"target\":8,\"weight\":1.51},{\"source\":0,\"target\":7,\"weight\":1.76},{\"source\":1,\"target\":2,\"weight\":8.52},{\"source\":1,\"target\":10,\"weight\":7.62},{\"source\":1,\"target\":11,\"weight\":7.03},{\"source\":2,\"target\":3,\"weight\":3.77},{\"source\":2,\"target\":5,\"weight\":6.45},{\"source\":2,\"target\":10,\"weight\":6.46},{\"source\":2,\"target\":11,\"weight\":6.23},{\"source\":3,\"target\":4,\"weight\":2.43},{\"source\":3,\"target\":5,\"weight\":4.88},{\"source\":3,\"target\":9,\"weight\":4.54},{\"source\":5,\"target\":6,\"weight\":7.51},{\"source\":8,\"target\":11,\"weight\":9.95},{\"source\":9,\"target\":10,\"weight\":9.54},{\"source\":10,\"target\":11,\"weight\":5.9}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let r = @conn.connected_components(g)
      assert_eq(r.count(), 1)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cc_cc_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":1,\"weight\":3.14},{\"source\":0,\"target\":6,\"weight\":5.9},{\"source\":0,\"target\":7,\"weight\":4.33},{\"source\":0,\"target\":9,\"weight\":6.44},{\"source\":0,\"target\":10,\"weight\":6.63},{\"source\":1,\"target\":3,\"weight\":1.59},{\"source\":1,\"target\":9,\"weight\":1.12},{\"source\":1,\"target\":13,\"weight\":8.54},{\"source\":2,\"target\":13,\"weight\":3.33},{\"source\":2,\"target\":14,\"weight\":3.11},{\"source\":3,\"target\":4,\"weight\":9.96},{\"source\":4,\"target\":10,\"weight\":5.23},{\"source\":5,\"target\":7,\"weight\":8.53},{\"source\":5,\"target\":10,\"weight\":5.29},{\"source\":5,\"target\":11,\"weight\":6.75},{\"source\":5,\"target\":14,\"weight\":2.36},{\"source\":6,\"target\":9,\"weight\":6.71},{\"source\":6,\"target\":10,\"weight\":8.81},{\"source\":6,\"target\":13,\"weight\":5.71},{\"source\":7,\"target\":8,\"weight\":7.67},{\"source\":8,\"target\":10,\"weight\":7.04},{\"source\":8,\"target\":12,\"weight\":1.58},{\"source\":8,\"target\":13,\"weight\":7.82},{\"source\":9,\"target\":11,\"weight\":6.32},{\"source\":9,\"target\":12,\"weight\":3.71}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let r = @conn.connected_components(g)
      assert_eq(r.count(), 1)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cc_cc_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":3.12},{\"source\":0,\"target\":2,\"weight\":1.93},{\"source\":0,\"target\":3,\"weight\":4.56},{\"source\":0,\"target\":4,\"weight\":2.39},{\"source\":0,\"target\":5,\"weight\":1.6},{\"source\":0,\"target\":6,\"weight\":4.61},{\"source\":1,\"target\":4,\"weight\":9.26},{\"source\":1,\"target\":6,\"weight\":8.2},{\"source\":1,\"target\":7,\"weight\":7.89},{\"source\":2,\"target\":3,\"weight\":3.0},{\"source\":2,\"target\":4,\"weight\":5.83},{\"source\":3,\"target\":5,\"weight\":3.49},{\"source\":3,\"target\":6,\"weight\":2.55},{\"source\":5,\"target\":6,\"weight\":1.96}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @conn.connected_components(g)
      assert_eq(r.count(), 1)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "cc_cc_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17],\"edges\":[{\"source\":0,\"target\":7,\"weight\":6.61},{\"source\":0,\"target\":12,\"weight\":7.68},{\"source\":0,\"target\":14,\"weight\":8.16},{\"source\":0,\"target\":17,\"weight\":9.48},{\"source\":0,\"target\":16,\"weight\":7.66},{\"source\":1,\"target\":2,\"weight\":9.3},{\"source\":1,\"target\":6,\"weight\":1.26},{\"source\":1,\"target\":8,\"weight\":5.19},{\"source\":1,\"target\":10,\"weight\":9.49},{\"source\":1,\"target\":11,\"weight\":6.84},{\"source\":1,\"target\":13,\"weight\":9.11},{\"source\":1,\"target\":14,\"weight\":2.02},{\"source\":2,\"target\":6,\"weight\":5.22},{\"source\":2,\"target\":13,\"weight\":3.22},{\"source\":2,\"target\":14,\"weight\":5.89},{\"source\":2,\"target\":15,\"weight\":6.17},{\"source\":3,\"target\":4,\"weight\":1.12},{\"source\":3,\"target\":13,\"weight\":2.95},{\"source\":3,\"target\":15,\"weight\":3.52},{\"source\":4,\"target\":5,\"weight\":9.25},{\"source\":4,\"target\":9,\"weight\":7.89},{\"source\":4,\"target\":10,\"weight\":2.44},{\"source\":4,\"target\":11,\"weight\":8.17},{\"source\":4,\"target\":13,\"weight\":2.25},{\"source\":5,\"target\":9,\"weight\":6.56},{\"source\":5,\"target\":13,\"weight\":2.14},{\"source\":5,\"target\":15,\"weight\":1.02},{\"source\":6,\"target\":13,\"weight\":8.84},{\"source\":6,\"target\":14,\"weight\":2.89},{\"source\":6,\"target\":15,\"weight\":2.94},{\"source\":7,\"target\":8,\"weight\":9.84},{\"source\":7,\"target\":9,\"weight\":8.85},{\"source\":7,\"target\":13,\"weight\":3.6},{\"source\":8,\"target\":9,\"weight\":9.65},{\"source\":8,\"target\":11,\"weight\":5.85},{\"source\":8,\"target\":14,\"weight\":7.1},{\"source\":9,\"target\":11,\"weight\":2.84},{\"source\":9,\"target\":13,\"weight\":9.47},{\"source\":11,\"target\":13,\"weight\":7.22},{\"source\":12,\"target\":15,\"weight\":9.7}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 18)
      let r = @conn.connected_components(g)
      assert_eq(r.count(), 1)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "scc_scc_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":0,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":1,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":3,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":2,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":8,\"target\":0,\"weight\":1.0},{\"source\":8,\"target\":5,\"weight\":1.0},{\"source\":9,\"target\":2,\"weight\":1.0},{\"source\":9,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @conn.tarjan_scc(g)
      assert_eq(r.count(), 2)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "scc_scc_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":0,\"weight\":1.0},{\"source\":1,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":3,\"target\":2,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":7,\"target\":0,\"weight\":1.0},{\"source\":7,\"target\":4,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":11,\"weight\":1.0},{\"source\":8,\"target\":2,\"weight\":1.0},{\"source\":8,\"target\":4,\"weight\":1.0},{\"source\":8,\"target\":7,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0},{\"source\":9,\"target\":1,\"weight\":1.0},{\"source\":9,\"target\":3,\"weight\":1.0},{\"source\":9,\"target\":5,\"weight\":1.0},{\"source\":9,\"target\":7,\"weight\":1.0},{\"source\":9,\"target\":10,\"weight\":1.0},{\"source\":10,\"target\":1,\"weight\":1.0},{\"source\":10,\"target\":2,\"weight\":1.0},{\"source\":10,\"target\":5,\"weight\":1.0},{\"source\":10,\"target\":7,\"weight\":1.0},{\"source\":10,\"target\":8,\"weight\":1.0},{\"source\":11,\"target\":1,\"weight\":1.0},{\"source\":11,\"target\":3,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let r = @conn.tarjan_scc(g)
      assert_eq(r.count(), 2)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "scc_scc_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":12,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":14,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":4,\"target\":13,\"weight\":1.0},{\"source\":5,\"target\":1,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":1,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":4,\"weight\":1.0},{\"source\":6,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":8,\"target\":1,\"weight\":1.0},{\"source\":8,\"target\":4,\"weight\":1.0},{\"source\":8,\"target\":7,\"weight\":1.0},{\"source\":9,\"target\":0,\"weight\":1.0},{\"source\":9,\"target\":1,\"weight\":1.0},{\"source\":10,\"target\":1,\"weight\":1.0},{\"source\":10,\"target\":8,\"weight\":1.0},{\"source\":10,\"target\":12,\"weight\":1.0},{\"source\":11,\"target\":3,\"weight\":1.0},{\"source\":11,\"target\":9,\"weight\":1.0},{\"source\":11,\"target\":12,\"weight\":1.0},{\"source\":12,\"target\":0,\"weight\":1.0},{\"source\":12,\"target\":6,\"weight\":1.0},{\"source\":13,\"target\":1,\"weight\":1.0},{\"source\":13,\"target\":2,\"weight\":1.0},{\"source\":14,\"target\":3,\"weight\":1.0},{\"source\":14,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let r = @conn.tarjan_scc(g)
      assert_eq(r.count(), 4)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "scc_scc_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":0,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":4,\"target\":3,\"weight\":1.0},{\"source\":5,\"target\":0,\"weight\":1.0},{\"source\":6,\"target\":2,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":5,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":1,\"weight\":1.0},{\"source\":7,\"target\":4,\"weight\":1.0},{\"source\":7,\"target\":6,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @conn.tarjan_scc(g)
      assert_eq(r.count(), 1)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "scc_scc_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],\"edges\":[{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":12,\"weight\":1.0},{\"source\":0,\"target\":17,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":2,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":10,\"weight\":1.0},{\"source\":3,\"target\":11,\"weight\":1.0},{\"source\":4,\"target\":2,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":19,\"weight\":1.0},{\"source\":5,\"target\":0,\"weight\":1.0},{\"source\":5,\"target\":4,\"weight\":1.0},{\"source\":5,\"target\":14,\"weight\":1.0},{\"source\":5,\"target\":16,\"weight\":1.0},{\"source\":5,\"target\":19,\"weight\":1.0},{\"source\":6,\"target\":4,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":0,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0},{\"source\":10,\"target\":6,\"weight\":1.0},{\"source\":10,\"target\":14,\"weight\":1.0},{\"source\":10,\"target\":17,\"weight\":1.0},{\"source\":10,\"target\":18,\"weight\":1.0},{\"source\":11,\"target\":2,\"weight\":1.0},{\"source\":11,\"target\":9,\"weight\":1.0},{\"source\":11,\"target\":14,\"weight\":1.0},{\"source\":11,\"target\":17,\"weight\":1.0},{\"source\":11,\"target\":19,\"weight\":1.0},{\"source\":12,\"target\":9,\"weight\":1.0},{\"source\":12,\"target\":18,\"weight\":1.0},{\"source\":12,\"target\":19,\"weight\":1.0},{\"source\":13,\"target\":2,\"weight\":1.0},{\"source\":14,\"target\":4,\"weight\":1.0},{\"source\":14,\"target\":10,\"weight\":1.0},{\"source\":15,\"target\":6,\"weight\":1.0},{\"source\":15,\"target\":18,\"weight\":1.0},{\"source\":16,\"target\":4,\"weight\":1.0},{\"source\":16,\"target\":19,\"weight\":1.0},{\"source\":17,\"target\":6,\"weight\":1.0},{\"source\":17,\"target\":14,\"weight\":1.0},{\"source\":18,\"target\":0,\"weight\":1.0},{\"source\":18,\"target\":5,\"weight\":1.0},{\"source\":18,\"target\":11,\"weight\":1.0},{\"source\":18,\"target\":14,\"weight\":1.0},{\"source\":19,\"target\":0,\"weight\":1.0},{\"source\":19,\"target\":1,\"weight\":1.0},{\"source\":19,\"target\":3,\"weight\":1.0},{\"source\":19,\"target\":4,\"weight\":1.0},{\"source\":19,\"target\":8,\"weight\":1.0},{\"source\":19,\"target\":15,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 20)
      let r = @conn.tarjan_scc(g)
      assert_eq(r.count(), 4)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
