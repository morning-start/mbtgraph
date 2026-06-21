///|
/// mst — Python/NetworkX 随机图验证 (每算法 5 图)
///
fn approx_mst(a : Double, b : Double, eps : Double) -> Bool {
  let d = a - b
  if d < 0.0 {
    -d < eps
  } else {
    d < eps
  }
}

///|
test "mst_mst_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":2.21},{\"source\":0,\"target\":4,\"weight\":8.63},{\"source\":0,\"target\":9,\"weight\":7.87},{\"source\":1,\"target\":2,\"weight\":3.3},{\"source\":1,\"target\":6,\"weight\":5.46},{\"source\":1,\"target\":9,\"weight\":5.05},{\"source\":2,\"target\":5,\"weight\":6.86},{\"source\":2,\"target\":6,\"weight\":8.1},{\"source\":2,\"target\":9,\"weight\":1.84},{\"source\":3,\"target\":4,\"weight\":1.26},{\"source\":3,\"target\":6,\"weight\":8.52},{\"source\":3,\"target\":7,\"weight\":4.89},{\"source\":4,\"target\":5,\"weight\":7.86},{\"source\":4,\"target\":6,\"weight\":1.02},{\"source\":4,\"target\":7,\"weight\":5.01},{\"source\":4,\"target\":9,\"weight\":7.49},{\"source\":5,\"target\":6,\"weight\":3.06},{\"source\":6,\"target\":7,\"weight\":9.51},{\"source\":7,\"target\":8,\"weight\":9.11},{\"source\":7,\"target\":9,\"weight\":1.28}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @mst.kruskal(g)
      assert_eq(r.edge_count(), 9)
      assert_true(approx_mst(r.total_weight, 27.97, 0.1))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "mst_mst_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":3,\"weight\":9.6},{\"source\":0,\"target\":4,\"weight\":9.53},{\"source\":0,\"target\":8,\"weight\":1.51},{\"source\":0,\"target\":7,\"weight\":1.76},{\"source\":1,\"target\":2,\"weight\":8.52},{\"source\":1,\"target\":10,\"weight\":7.62},{\"source\":1,\"target\":11,\"weight\":7.03},{\"source\":2,\"target\":3,\"weight\":3.77},{\"source\":2,\"target\":5,\"weight\":6.45},{\"source\":2,\"target\":10,\"weight\":6.46},{\"source\":2,\"target\":11,\"weight\":6.23},{\"source\":3,\"target\":4,\"weight\":2.43},{\"source\":3,\"target\":5,\"weight\":4.88},{\"source\":3,\"target\":9,\"weight\":4.54},{\"source\":5,\"target\":6,\"weight\":7.51},{\"source\":8,\"target\":11,\"weight\":9.95},{\"source\":9,\"target\":10,\"weight\":9.54},{\"source\":10,\"target\":11,\"weight\":5.9}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let r = @mst.kruskal(g)
      assert_eq(r.edge_count(), 11)
      assert_true(approx_mst(r.total_weight, 55.09, 0.1))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "mst_mst_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":1,\"weight\":3.14},{\"source\":0,\"target\":6,\"weight\":5.9},{\"source\":0,\"target\":7,\"weight\":4.33},{\"source\":0,\"target\":9,\"weight\":6.44},{\"source\":0,\"target\":10,\"weight\":6.63},{\"source\":1,\"target\":3,\"weight\":1.59},{\"source\":1,\"target\":9,\"weight\":1.12},{\"source\":1,\"target\":13,\"weight\":8.54},{\"source\":2,\"target\":13,\"weight\":3.33},{\"source\":2,\"target\":14,\"weight\":3.11},{\"source\":3,\"target\":4,\"weight\":9.96},{\"source\":4,\"target\":10,\"weight\":5.23},{\"source\":5,\"target\":7,\"weight\":8.53},{\"source\":5,\"target\":10,\"weight\":5.29},{\"source\":5,\"target\":11,\"weight\":6.75},{\"source\":5,\"target\":14,\"weight\":2.36},{\"source\":6,\"target\":9,\"weight\":6.71},{\"source\":6,\"target\":10,\"weight\":8.81},{\"source\":6,\"target\":13,\"weight\":5.71},{\"source\":7,\"target\":8,\"weight\":7.67},{\"source\":8,\"target\":10,\"weight\":7.04},{\"source\":8,\"target\":12,\"weight\":1.58},{\"source\":8,\"target\":13,\"weight\":7.82},{\"source\":9,\"target\":11,\"weight\":6.32},{\"source\":9,\"target\":12,\"weight\":3.71}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let r = @mst.kruskal(g)
      assert_eq(r.edge_count(), 14)
      assert_true(approx_mst(r.total_weight, 52.72, 0.1))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "mst_mst_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":3.12},{\"source\":0,\"target\":2,\"weight\":1.93},{\"source\":0,\"target\":3,\"weight\":4.56},{\"source\":0,\"target\":4,\"weight\":2.39},{\"source\":0,\"target\":5,\"weight\":1.6},{\"source\":0,\"target\":6,\"weight\":4.61},{\"source\":1,\"target\":4,\"weight\":9.26},{\"source\":1,\"target\":6,\"weight\":8.2},{\"source\":1,\"target\":7,\"weight\":7.89},{\"source\":2,\"target\":3,\"weight\":3.0},{\"source\":2,\"target\":4,\"weight\":5.83},{\"source\":3,\"target\":5,\"weight\":3.49},{\"source\":3,\"target\":6,\"weight\":2.55},{\"source\":5,\"target\":6,\"weight\":1.96}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @mst.kruskal(g)
      assert_eq(r.edge_count(), 7)
      assert_true(approx_mst(r.total_weight, 21.44, 0.1))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "mst_mst_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],\"edges\":[{\"source\":0,\"target\":7,\"weight\":6.61},{\"source\":0,\"target\":12,\"weight\":7.68},{\"source\":0,\"target\":14,\"weight\":8.16},{\"source\":0,\"target\":17,\"weight\":9.48},{\"source\":0,\"target\":18,\"weight\":7.66},{\"source\":1,\"target\":4,\"weight\":9.3},{\"source\":1,\"target\":6,\"weight\":1.26},{\"source\":1,\"target\":8,\"weight\":5.19},{\"source\":1,\"target\":9,\"weight\":9.49},{\"source\":1,\"target\":11,\"weight\":6.84},{\"source\":1,\"target\":12,\"weight\":9.11},{\"source\":1,\"target\":19,\"weight\":2.02},{\"source\":2,\"target\":9,\"weight\":5.22},{\"source\":2,\"target\":10,\"weight\":3.22},{\"source\":2,\"target\":11,\"weight\":5.89},{\"source\":2,\"target\":14,\"weight\":6.17},{\"source\":3,\"target\":7,\"weight\":1.12},{\"source\":3,\"target\":9,\"weight\":2.95},{\"source\":3,\"target\":12,\"weight\":3.52},{\"source\":3,\"target\":16,\"weight\":9.25},{\"source\":3,\"target\":17,\"weight\":7.89},{\"source\":3,\"target\":18,\"weight\":2.44},{\"source\":4,\"target\":5,\"weight\":8.17},{\"source\":4,\"target\":13,\"weight\":2.25},{\"source\":4,\"target\":17,\"weight\":6.56},{\"source\":4,\"target\":19,\"weight\":2.14},{\"source\":5,\"target\":14,\"weight\":1.02},{\"source\":5,\"target\":15,\"weight\":8.84},{\"source\":5,\"target\":16,\"weight\":2.89},{\"source\":5,\"target\":19,\"weight\":2.94},{\"source\":6,\"target\":7,\"weight\":9.84},{\"source\":6,\"target\":11,\"weight\":8.85},{\"source\":6,\"target\":16,\"weight\":3.6},{\"source\":6,\"target\":18,\"weight\":9.65},{\"source\":7,\"target\":9,\"weight\":5.85},{\"source\":7,\"target\":14,\"weight\":7.1},{\"source\":7,\"target\":16,\"weight\":2.84},{\"source\":8,\"target\":18,\"weight\":9.47},{\"source\":9,\"target\":15,\"weight\":7.22},{\"source\":11,\"target\":18,\"weight\":9.7},{\"source\":15,\"target\":16,\"weight\":9.04},{\"source\":17,\"target\":18,\"weight\":3.69}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 20)
      let r = @mst.kruskal(g)
      assert_eq(r.edge_count(), 19)
      assert_true(approx_mst(r.total_weight, 64.43, 0.1))
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
