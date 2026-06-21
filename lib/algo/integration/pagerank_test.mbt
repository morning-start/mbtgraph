///|
/// pagerank — Python/NetworkX 随机图验证 (每算法 5 图)
///
fn approx_pagerank(a : Double, b : Double, eps : Double) -> Bool {
  let d = a - b
  if d < 0.0 {
    -d < eps
  } else {
    d < eps
  }
}

///|
test "pr_pr_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":0,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":1,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":3,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":0,\"weight\":1.0},{\"source\":5,\"target\":1,\"weight\":1.0},{\"source\":5,\"target\":2,\"weight\":1.0},{\"source\":5,\"target\":3,\"weight\":1.0},{\"source\":5,\"target\":4,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":5,\"target\":9,\"weight\":1.0},{\"source\":6,\"target\":2,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":8,\"target\":0,\"weight\":1.0},{\"source\":8,\"target\":5,\"weight\":1.0},{\"source\":9,\"target\":2,\"weight\":1.0},{\"source\":9,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @pagerank.pagerank(g, 0.85, 100, 0.000001)
      assert_true(approx_pagerank(r.total_rank(), 1.0, 0.01))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "pr_pr_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":12,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":1,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":12,\"weight\":1.0},{\"source\":6,\"target\":1,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":2,\"weight\":1.0},{\"source\":7,\"target\":4,\"weight\":1.0},{\"source\":7,\"target\":6,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":11,\"weight\":1.0},{\"source\":7,\"target\":14,\"weight\":1.0},{\"source\":8,\"target\":0,\"weight\":1.0},{\"source\":8,\"target\":3,\"weight\":1.0},{\"source\":8,\"target\":5,\"weight\":1.0},{\"source\":8,\"target\":6,\"weight\":1.0},{\"source\":8,\"target\":11,\"weight\":1.0},{\"source\":8,\"target\":13,\"weight\":1.0},{\"source\":9,\"target\":11,\"weight\":1.0},{\"source\":9,\"target\":14,\"weight\":1.0},{\"source\":10,\"target\":3,\"weight\":1.0},{\"source\":10,\"target\":8,\"weight\":1.0},{\"source\":10,\"target\":11,\"weight\":1.0},{\"source\":10,\"target\":12,\"weight\":1.0},{\"source\":10,\"target\":13,\"weight\":1.0},{\"source\":10,\"target\":14,\"weight\":1.0},{\"source\":11,\"target\":0,\"weight\":1.0},{\"source\":12,\"target\":2,\"weight\":1.0},{\"source\":12,\"target\":3,\"weight\":1.0},{\"source\":12,\"target\":5,\"weight\":1.0},{\"source\":12,\"target\":8,\"weight\":1.0},{\"source\":12,\"target\":9,\"weight\":1.0},{\"source\":13,\"target\":9,\"weight\":1.0},{\"source\":13,\"target\":12,\"weight\":1.0},{\"source\":13,\"target\":14,\"weight\":1.0},{\"source\":14,\"target\":8,\"weight\":1.0},{\"source\":14,\"target\":10,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let r = @pagerank.pagerank(g, 0.85, 100, 0.000001)
      assert_true(approx_pagerank(r.total_rank(), 1.0, 0.01))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "pr_pr_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],\"edges\":[{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":19,\"weight\":1.0},{\"source\":2,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":12,\"weight\":1.0},{\"source\":3,\"target\":19,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":4,\"target\":12,\"weight\":1.0},{\"source\":4,\"target\":17,\"weight\":1.0},{\"source\":5,\"target\":19,\"weight\":1.0},{\"source\":6,\"target\":2,\"weight\":1.0},{\"source\":6,\"target\":5,\"weight\":1.0},{\"source\":6,\"target\":13,\"weight\":1.0},{\"source\":6,\"target\":14,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":19,\"weight\":1.0},{\"source\":8,\"target\":12,\"weight\":1.0},{\"source\":9,\"target\":3,\"weight\":1.0},{\"source\":9,\"target\":14,\"weight\":1.0},{\"source\":10,\"target\":9,\"weight\":1.0},{\"source\":10,\"target\":14,\"weight\":1.0},{\"source\":11,\"target\":1,\"weight\":1.0},{\"source\":12,\"target\":5,\"weight\":1.0},{\"source\":12,\"target\":8,\"weight\":1.0},{\"source\":12,\"target\":16,\"weight\":1.0},{\"source\":12,\"target\":17,\"weight\":1.0},{\"source\":12,\"target\":18,\"weight\":1.0},{\"source\":12,\"target\":19,\"weight\":1.0},{\"source\":13,\"target\":0,\"weight\":1.0},{\"source\":13,\"target\":3,\"weight\":1.0},{\"source\":13,\"target\":14,\"weight\":1.0},{\"source\":13,\"target\":18,\"weight\":1.0},{\"source\":14,\"target\":17,\"weight\":1.0},{\"source\":15,\"target\":7,\"weight\":1.0},{\"source\":15,\"target\":16,\"weight\":1.0},{\"source\":15,\"target\":18,\"weight\":1.0},{\"source\":15,\"target\":19,\"weight\":1.0},{\"source\":16,\"target\":1,\"weight\":1.0},{\"source\":16,\"target\":2,\"weight\":1.0},{\"source\":16,\"target\":3,\"weight\":1.0},{\"source\":16,\"target\":6,\"weight\":1.0},{\"source\":16,\"target\":8,\"weight\":1.0},{\"source\":16,\"target\":15,\"weight\":1.0},{\"source\":17,\"target\":0,\"weight\":1.0},{\"source\":17,\"target\":3,\"weight\":1.0},{\"source\":17,\"target\":18,\"weight\":1.0},{\"source\":18,\"target\":11,\"weight\":1.0},{\"source\":18,\"target\":12,\"weight\":1.0},{\"source\":19,\"target\":14,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 20)
      let r = @pagerank.pagerank(g, 0.85, 100, 0.000001)
      assert_true(approx_pagerank(r.total_rank(), 1.0, 0.01))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "pr_pr_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":1,\"weight\":1.0},{\"source\":3,\"target\":2,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":10,\"weight\":1.0},{\"source\":3,\"target\":11,\"weight\":1.0},{\"source\":4,\"target\":0,\"weight\":1.0},{\"source\":4,\"target\":3,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":5,\"target\":0,\"weight\":1.0},{\"source\":5,\"target\":2,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":6,\"target\":0,\"weight\":1.0},{\"source\":6,\"target\":1,\"weight\":1.0},{\"source\":6,\"target\":4,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":3,\"weight\":1.0},{\"source\":8,\"target\":1,\"weight\":1.0},{\"source\":8,\"target\":3,\"weight\":1.0},{\"source\":8,\"target\":7,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0},{\"source\":8,\"target\":10,\"weight\":1.0},{\"source\":9,\"target\":2,\"weight\":1.0},{\"source\":9,\"target\":5,\"weight\":1.0},{\"source\":9,\"target\":6,\"weight\":1.0},{\"source\":9,\"target\":7,\"weight\":1.0},{\"source\":9,\"target\":8,\"weight\":1.0},{\"source\":9,\"target\":11,\"weight\":1.0},{\"source\":10,\"target\":0,\"weight\":1.0},{\"source\":10,\"target\":2,\"weight\":1.0},{\"source\":10,\"target\":4,\"weight\":1.0},{\"source\":10,\"target\":11,\"weight\":1.0},{\"source\":11,\"target\":1,\"weight\":1.0},{\"source\":11,\"target\":3,\"weight\":1.0},{\"source\":11,\"target\":7,\"weight\":1.0},{\"source\":11,\"target\":9,\"weight\":1.0},{\"source\":11,\"target\":10,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let r = @pagerank.pagerank(g, 0.85, 100, 0.000001)
      assert_true(approx_pagerank(r.total_rank(), 1.0, 0.01))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "pr_pr_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":0,\"weight\":1.0},{\"source\":3,\"target\":2,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":0,\"weight\":1.0},{\"source\":4,\"target\":1,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":5,\"target\":1,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":0,\"weight\":1.0},{\"source\":6,\"target\":1,\"weight\":1.0},{\"source\":6,\"target\":2,\"weight\":1.0},{\"source\":6,\"target\":3,\"weight\":1.0},{\"source\":6,\"target\":4,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":1,\"weight\":1.0},{\"source\":7,\"target\":2,\"weight\":1.0},{\"source\":7,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @pagerank.pagerank(g, 0.85, 100, 0.000001)
      assert_true(approx_pagerank(r.total_rank(), 1.0, 0.01))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
