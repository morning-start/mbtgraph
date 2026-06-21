///|
/// flow — Python/NetworkX 随机图验证 (每算法 5 图)
///

///|
test "flow_flow_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":3.55},{\"source\":0,\"target\":4,\"weight\":17.1},{\"source\":0,\"target\":5,\"weight\":15.51},{\"source\":1,\"target\":0,\"weight\":5.85},{\"source\":1,\"target\":4,\"weight\":10.41},{\"source\":1,\"target\":5,\"weight\":9.54},{\"source\":2,\"target\":1,\"weight\":13.38},{\"source\":2,\"target\":4,\"weight\":15.99},{\"source\":2,\"target\":5,\"weight\":2.78},{\"source\":3,\"target\":1,\"weight\":1.54},{\"source\":3,\"target\":5,\"weight\":16.88},{\"source\":4,\"target\":0,\"weight\":9.22},{\"source\":4,\"target\":3,\"weight\":15.48},{\"source\":4,\"target\":5,\"weight\":1.04},{\"source\":5,\"target\":0,\"weight\":9.46},{\"source\":5,\"target\":1,\"weight\":14.71},{\"source\":5,\"target\":2,\"weight\":5.35},{\"source\":5,\"target\":3,\"weight\":18.96},{\"source\":5,\"target\":4,\"weight\":18.13}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => assert_eq(@core.GraphReadable::node_count(g), 6)
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "flow_flow_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":3,\"weight\":19.16},{\"source\":0,\"target\":4,\"weight\":19.01},{\"source\":1,\"target\":0,\"weight\":2.07},{\"source\":1,\"target\":5,\"weight\":2.61},{\"source\":1,\"target\":7,\"weight\":16.87},{\"source\":2,\"target\":6,\"weight\":14.98},{\"source\":2,\"target\":7,\"weight\":13.72},{\"source\":3,\"target\":0,\"weight\":6.85},{\"source\":3,\"target\":2,\"weight\":12.51},{\"source\":3,\"target\":4,\"weight\":12.53},{\"source\":4,\"target\":0,\"weight\":12.04},{\"source\":4,\"target\":1,\"weight\":4.01},{\"source\":4,\"target\":2,\"weight\":9.18},{\"source\":4,\"target\":3,\"weight\":8.48},{\"source\":5,\"target\":0,\"weight\":14.74},{\"source\":6,\"target\":0,\"weight\":19.9},{\"source\":6,\"target\":3,\"weight\":19.04},{\"source\":7,\"target\":5,\"weight\":11.34}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => assert_eq(@core.GraphReadable::node_count(g), 8)
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "flow_flow_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":5.52},{\"source\":0,\"target\":6,\"weight\":11.34},{\"source\":0,\"target\":7,\"weight\":8.03},{\"source\":0,\"target\":9,\"weight\":12.47},{\"source\":1,\"target\":0,\"weight\":12.89},{\"source\":1,\"target\":7,\"weight\":2.25},{\"source\":2,\"target\":4,\"weight\":1.25},{\"source\":2,\"target\":8,\"weight\":16.91},{\"source\":4,\"target\":1,\"weight\":5.93},{\"source\":4,\"target\":2,\"weight\":5.45},{\"source\":4,\"target\":3,\"weight\":19.92},{\"source\":6,\"target\":1,\"weight\":9.94},{\"source\":6,\"target\":8,\"weight\":16.89},{\"source\":7,\"target\":1,\"weight\":10.05},{\"source\":7,\"target\":2,\"weight\":13.14},{\"source\":7,\"target\":5,\"weight\":3.86},{\"source\":7,\"target\":9,\"weight\":13.06},{\"source\":8,\"target\":0,\"weight\":17.49},{\"source\":8,\"target\":3,\"weight\":10.94},{\"source\":8,\"target\":5,\"weight\":15.08},{\"source\":9,\"target\":4,\"weight\":13.76},{\"source\":9,\"target\":6,\"weight\":2.22},{\"source\":9,\"target\":7,\"weight\":15.41}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => assert_eq(@core.GraphReadable::node_count(g), 10)
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "flow_flow_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4],\"edges\":[{\"source\":0,\"target\":1,\"weight\":5.48},{\"source\":0,\"target\":2,\"weight\":2.96},{\"source\":0,\"target\":3,\"weight\":8.53},{\"source\":0,\"target\":4,\"weight\":3.94},{\"source\":1,\"target\":0,\"weight\":2.26},{\"source\":1,\"target\":2,\"weight\":8.63},{\"source\":2,\"target\":1,\"weight\":18.44},{\"source\":2,\"target\":3,\"weight\":16.21},{\"source\":2,\"target\":4,\"weight\":15.54},{\"source\":3,\"target\":0,\"weight\":5.22},{\"source\":3,\"target\":1,\"weight\":11.2},{\"source\":3,\"target\":2,\"weight\":6.26},{\"source\":4,\"target\":3,\"weight\":4.28}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => assert_eq(@core.GraphReadable::node_count(g), 5)
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "flow_flow_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6],\"edges\":[{\"source\":0,\"target\":6,\"weight\":10.0},{\"source\":1,\"target\":0,\"weight\":12.84},{\"source\":1,\"target\":6,\"weight\":15.09},{\"source\":2,\"target\":1,\"weight\":16.11},{\"source\":2,\"target\":5,\"weight\":18.91},{\"source\":2,\"target\":6,\"weight\":15.06},{\"source\":3,\"target\":0,\"weight\":18.52},{\"source\":3,\"target\":4,\"weight\":1.55},{\"source\":3,\"target\":6,\"weight\":9.85},{\"source\":4,\"target\":1,\"weight\":18.92},{\"source\":4,\"target\":2,\"weight\":13.33},{\"source\":4,\"target\":5,\"weight\":18.12},{\"source\":4,\"target\":6,\"weight\":3.15},{\"source\":5,\"target\":2,\"weight\":9.91},{\"source\":6,\"target\":0,\"weight\":5.68},{\"source\":6,\"target\":5,\"weight\":11.33}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => assert_eq(@core.GraphReadable::node_count(g), 7)
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
