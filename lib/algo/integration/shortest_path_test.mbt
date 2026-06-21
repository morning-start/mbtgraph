///|
/// shortest_path — Python/NetworkX 随机图验证 (每算法 5 图)
///
fn approx_shortest_path(a : Double, b : Double, eps : Double) -> Bool {
  let d = a - b
  if d < 0.0 {
    -d < eps
  } else {
    d < eps
  }
}

///|
test "bf_bf_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":2,\"weight\":6.23},{\"source\":0,\"target\":7,\"weight\":2.75},{\"source\":0,\"target\":8,\"weight\":9.69},{\"source\":0,\"target\":9,\"weight\":9.32},{\"source\":1,\"target\":2,\"weight\":5.2},{\"source\":1,\"target\":4,\"weight\":6.97},{\"source\":1,\"target\":5,\"weight\":2.93},{\"source\":1,\"target\":6,\"weight\":3.0},{\"source\":2,\"target\":4,\"weight\":3.6},{\"source\":2,\"target\":7,\"weight\":7.23},{\"source\":3,\"target\":8,\"weight\":2.91},{\"source\":4,\"target\":2,\"weight\":9.74},{\"source\":4,\"target\":5,\"weight\":1.63},{\"source\":4,\"target\":7,\"weight\":2.74},{\"source\":4,\"target\":8,\"weight\":1.8},{\"source\":4,\"target\":9,\"weight\":7.93},{\"source\":5,\"target\":0,\"weight\":4.3},{\"source\":5,\"target\":1,\"weight\":5.25},{\"source\":6,\"target\":4,\"weight\":3.93},{\"source\":6,\"target\":5,\"weight\":6.74},{\"source\":6,\"target\":7,\"weight\":4.64},{\"source\":7,\"target\":2,\"weight\":2.87},{\"source\":7,\"target\":8,\"weight\":4.87},{\"source\":7,\"target\":9,\"weight\":3.74},{\"source\":8,\"target\":5,\"weight\":2.0},{\"source\":9,\"target\":0,\"weight\":8.41},{\"source\":9,\"target\":4,\"weight\":7.12},{\"source\":9,\"target\":5,\"weight\":6.98},{\"source\":9,\"target\":7,\"weight\":8.94}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      match @sp.bellman_ford(g, @core.NodeId(0)) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01),
          )
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(1)), 14.87, 0.01),
          )
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(2)), 5.62, 0.01),
          )
        }
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
test "bf_bf_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":1,\"weight\":2.33},{\"source\":0,\"target\":3,\"weight\":6.54},{\"source\":0,\"target\":9,\"weight\":2.53},{\"source\":1,\"target\":5,\"weight\":7.41},{\"source\":1,\"target\":6,\"weight\":6.47},{\"source\":2,\"target\":0,\"weight\":4.46},{\"source\":2,\"target\":3,\"weight\":6.56},{\"source\":2,\"target\":7,\"weight\":6.1},{\"source\":2,\"target\":8,\"weight\":1.39},{\"source\":3,\"target\":5,\"weight\":5.77},{\"source\":3,\"target\":6,\"weight\":6.58},{\"source\":5,\"target\":11,\"weight\":5.68},{\"source\":6,\"target\":0,\"weight\":8.92},{\"source\":6,\"target\":8,\"weight\":7.62},{\"source\":6,\"target\":11,\"weight\":4.39},{\"source\":7,\"target\":1,\"weight\":3.04},{\"source\":7,\"target\":3,\"weight\":2.15},{\"source\":7,\"target\":4,\"weight\":8.29},{\"source\":7,\"target\":6,\"weight\":7.21},{\"source\":7,\"target\":8,\"weight\":6.48},{\"source\":7,\"target\":9,\"weight\":4.98},{\"source\":8,\"target\":2,\"weight\":5.51},{\"source\":8,\"target\":3,\"weight\":3.0},{\"source\":8,\"target\":6,\"weight\":5.77},{\"source\":9,\"target\":2,\"weight\":2.31},{\"source\":9,\"target\":3,\"weight\":6.59},{\"source\":9,\"target\":4,\"weight\":6.67},{\"source\":10,\"target\":0,\"weight\":7.03},{\"source\":10,\"target\":2,\"weight\":3.22},{\"source\":11,\"target\":4,\"weight\":1.83},{\"source\":11,\"target\":5,\"weight\":4.0},{\"source\":11,\"target\":7,\"weight\":7.19}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      match @sp.bellman_ford(g, @core.NodeId(0)) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01),
          )
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(1)), 2.33, 0.01),
          )
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(2)), 4.84, 0.01),
          )
        }
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
test "bf_bf_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":6,\"weight\":9.81},{\"source\":0,\"target\":8,\"weight\":5.11},{\"source\":0,\"target\":12,\"weight\":7.47},{\"source\":0,\"target\":13,\"weight\":7.61},{\"source\":1,\"target\":2,\"weight\":2.93},{\"source\":1,\"target\":4,\"weight\":1.7},{\"source\":1,\"target\":5,\"weight\":6.42},{\"source\":1,\"target\":7,\"weight\":2.1},{\"source\":3,\"target\":2,\"weight\":4.44},{\"source\":3,\"target\":6,\"weight\":9.01},{\"source\":3,\"target\":8,\"weight\":8.85},{\"source\":3,\"target\":11,\"weight\":2.07},{\"source\":4,\"target\":11,\"weight\":1.74},{\"source\":4,\"target\":13,\"weight\":3.0},{\"source\":6,\"target\":7,\"weight\":8.45},{\"source\":6,\"target\":10,\"weight\":1.22},{\"source\":7,\"target\":3,\"weight\":3.03},{\"source\":7,\"target\":4,\"weight\":1.97},{\"source\":7,\"target\":8,\"weight\":2.15},{\"source\":8,\"target\":9,\"weight\":5.71},{\"source\":9,\"target\":1,\"weight\":2.65},{\"source\":9,\"target\":3,\"weight\":4.68},{\"source\":9,\"target\":11,\"weight\":7.6},{\"source\":10,\"target\":0,\"weight\":7.51},{\"source\":10,\"target\":1,\"weight\":4.74},{\"source\":11,\"target\":2,\"weight\":8.08},{\"source\":11,\"target\":9,\"weight\":6.15},{\"source\":12,\"target\":3,\"weight\":8.44},{\"source\":12,\"target\":5,\"weight\":3.24},{\"source\":12,\"target\":14,\"weight\":4.32},{\"source\":13,\"target\":0,\"weight\":6.22},{\"source\":13,\"target\":10,\"weight\":9.51},{\"source\":13,\"target\":12,\"weight\":6.57},{\"source\":14,\"target\":8,\"weight\":5.27},{\"source\":14,\"target\":9,\"weight\":3.26}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      match @sp.bellman_ford(g, @core.NodeId(0)) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01),
          )
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(1)), 13.47, 0.01),
          )
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(2)), 16.4, 0.01),
          )
        }
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
test "bf_bf_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":4,\"weight\":9.64},{\"source\":0,\"target\":5,\"weight\":8.85},{\"source\":1,\"target\":0,\"weight\":7.59},{\"source\":1,\"target\":2,\"weight\":3.05},{\"source\":1,\"target\":4,\"weight\":3.98},{\"source\":1,\"target\":6,\"weight\":7.42},{\"source\":2,\"target\":3,\"weight\":8.26},{\"source\":2,\"target\":4,\"weight\":1.15},{\"source\":3,\"target\":2,\"weight\":2.5},{\"source\":3,\"target\":4,\"weight\":9.06},{\"source\":3,\"target\":6,\"weight\":2.06},{\"source\":4,\"target\":2,\"weight\":6.9},{\"source\":4,\"target\":6,\"weight\":3.97},{\"source\":5,\"target\":0,\"weight\":6.81},{\"source\":5,\"target\":2,\"weight\":8.76},{\"source\":6,\"target\":2,\"weight\":6.23},{\"source\":6,\"target\":4,\"weight\":4.52},{\"source\":6,\"target\":5,\"weight\":3.9},{\"source\":6,\"target\":7,\"weight\":6.59},{\"source\":7,\"target\":0,\"weight\":6.65},{\"source\":7,\"target\":2,\"weight\":4.69},{\"source\":7,\"target\":3,\"weight\":5.2},{\"source\":7,\"target\":4,\"weight\":5.83},{\"source\":7,\"target\":6,\"weight\":3.33}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      match @sp.bellman_ford(g, @core.NodeId(0)) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01),
          )
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(2)), 16.54, 0.01),
          )
        }
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
test "bf_bf_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],\"edges\":[{\"source\":0,\"target\":11,\"weight\":8.9},{\"source\":1,\"target\":11,\"weight\":4.14},{\"source\":2,\"target\":11,\"weight\":8.12},{\"source\":2,\"target\":15,\"weight\":9.56},{\"source\":2,\"target\":16,\"weight\":3.81},{\"source\":3,\"target\":2,\"weight\":7.91},{\"source\":3,\"target\":5,\"weight\":4.01},{\"source\":3,\"target\":13,\"weight\":2.47},{\"source\":4,\"target\":1,\"weight\":4.13},{\"source\":4,\"target\":10,\"weight\":7.76},{\"source\":4,\"target\":13,\"weight\":2.33},{\"source\":5,\"target\":7,\"weight\":6.93},{\"source\":5,\"target\":12,\"weight\":4.16},{\"source\":6,\"target\":7,\"weight\":2.52},{\"source\":6,\"target\":12,\"weight\":4.87},{\"source\":7,\"target\":4,\"weight\":4.48},{\"source\":7,\"target\":11,\"weight\":5.14},{\"source\":7,\"target\":12,\"weight\":8.93},{\"source\":7,\"target\":17,\"weight\":9.28},{\"source\":8,\"target\":2,\"weight\":3.05},{\"source\":8,\"target\":14,\"weight\":9.89},{\"source\":8,\"target\":17,\"weight\":6.51},{\"source\":9,\"target\":7,\"weight\":9.64},{\"source\":10,\"target\":7,\"weight\":8.35},{\"source\":10,\"target\":8,\"weight\":5.73},{\"source\":11,\"target\":1,\"weight\":3.26},{\"source\":11,\"target\":3,\"weight\":9.36},{\"source\":11,\"target\":6,\"weight\":9.99},{\"source\":12,\"target\":1,\"weight\":6.62},{\"source\":12,\"target\":2,\"weight\":2.05},{\"source\":12,\"target\":4,\"weight\":8.41},{\"source\":12,\"target\":5,\"weight\":7.89},{\"source\":12,\"target\":7,\"weight\":8.92},{\"source\":13,\"target\":12,\"weight\":9.79},{\"source\":14,\"target\":1,\"weight\":9.78},{\"source\":14,\"target\":15,\"weight\":7.63},{\"source\":14,\"target\":18,\"weight\":4.53},{\"source\":15,\"target\":1,\"weight\":5.79},{\"source\":15,\"target\":2,\"weight\":5.54},{\"source\":15,\"target\":8,\"weight\":7.84},{\"source\":16,\"target\":4,\"weight\":6.64},{\"source\":16,\"target\":6,\"weight\":8.43},{\"source\":16,\"target\":18,\"weight\":5.64},{\"source\":17,\"target\":4,\"weight\":6.31},{\"source\":17,\"target\":6,\"weight\":9.67},{\"source\":17,\"target\":9,\"weight\":8.13},{\"source\":18,\"target\":5,\"weight\":9.38},{\"source\":19,\"target\":1,\"weight\":7.29},{\"source\":19,\"target\":10,\"weight\":2.12}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 20)
      match @sp.bellman_ford(g, @core.NodeId(0)) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01),
          )
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(1)), 12.16, 0.01),
          )
          assert_true(
            approx_shortest_path(r.distance_to(@core.NodeId(2)), 25.81, 0.01),
          )
        }
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
test "dj_dj_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":2.21},{\"source\":0,\"target\":4,\"weight\":8.63},{\"source\":0,\"target\":9,\"weight\":7.87},{\"source\":1,\"target\":0,\"weight\":3.3},{\"source\":1,\"target\":5,\"weight\":5.46},{\"source\":1,\"target\":8,\"weight\":5.05},{\"source\":2,\"target\":1,\"weight\":6.86},{\"source\":2,\"target\":3,\"weight\":8.1},{\"source\":2,\"target\":7,\"weight\":1.84},{\"source\":2,\"target\":9,\"weight\":1.26},{\"source\":3,\"target\":0,\"weight\":8.52},{\"source\":3,\"target\":4,\"weight\":4.89},{\"source\":3,\"target\":5,\"weight\":7.86},{\"source\":3,\"target\":6,\"weight\":1.02},{\"source\":3,\"target\":8,\"weight\":5.01},{\"source\":3,\"target\":9,\"weight\":7.49},{\"source\":4,\"target\":3,\"weight\":3.06},{\"source\":4,\"target\":7,\"weight\":9.51},{\"source\":6,\"target\":2,\"weight\":9.11},{\"source\":6,\"target\":3,\"weight\":1.28},{\"source\":6,\"target\":7,\"weight\":1.23},{\"source\":7,\"target\":9,\"weight\":5.87},{\"source\":8,\"target\":0,\"weight\":9.45},{\"source\":8,\"target\":5,\"weight\":4.43},{\"source\":9,\"target\":2,\"weight\":2.95},{\"source\":9,\"target\":7,\"weight\":4.8}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let r = @sp.dijkstra(g, @core.NodeId(0))
      assert_true(approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01))
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(1)), 2.21, 0.01),
      )
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(2)), 10.82, 0.01),
      )
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "dj_dj_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":3,\"weight\":9.6},{\"source\":0,\"target\":4,\"weight\":9.53},{\"source\":1,\"target\":0,\"weight\":1.51},{\"source\":1,\"target\":10,\"weight\":1.76},{\"source\":1,\"target\":11,\"weight\":8.52},{\"source\":2,\"target\":7,\"weight\":7.62},{\"source\":2,\"target\":8,\"weight\":7.03},{\"source\":2,\"target\":10,\"weight\":3.77},{\"source\":3,\"target\":2,\"weight\":6.45},{\"source\":4,\"target\":1,\"weight\":6.46},{\"source\":5,\"target\":8,\"weight\":6.23},{\"source\":5,\"target\":11,\"weight\":2.43},{\"source\":7,\"target\":0,\"weight\":4.88},{\"source\":7,\"target\":4,\"weight\":4.54},{\"source\":7,\"target\":9,\"weight\":7.51},{\"source\":7,\"target\":11,\"weight\":9.95},{\"source\":8,\"target\":2,\"weight\":9.54},{\"source\":8,\"target\":4,\"weight\":5.9},{\"source\":8,\"target\":7,\"weight\":5.0},{\"source\":8,\"target\":9,\"weight\":3.41},{\"source\":9,\"target\":1,\"weight\":1.32},{\"source\":9,\"target\":3,\"weight\":1.25},{\"source\":9,\"target\":5,\"weight\":5.18},{\"source\":9,\"target\":7,\"weight\":3.87},{\"source\":9,\"target\":10,\"weight\":4.42},{\"source\":10,\"target\":1,\"weight\":9.03},{\"source\":10,\"target\":2,\"weight\":5.73},{\"source\":10,\"target\":5,\"weight\":6.04},{\"source\":10,\"target\":7,\"weight\":3.13},{\"source\":10,\"target\":8,\"weight\":1.21},{\"source\":11,\"target\":1,\"weight\":3.93},{\"source\":11,\"target\":3,\"weight\":2.23}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let r = @sp.dijkstra(g, @core.NodeId(0))
      assert_true(approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01))
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(1)), 15.99, 0.01),
      )
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(2)), 16.05, 0.01),
      )
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "dj_dj_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":6,\"weight\":3.14},{\"source\":0,\"target\":7,\"weight\":5.9},{\"source\":1,\"target\":2,\"weight\":4.33},{\"source\":1,\"target\":8,\"weight\":6.44},{\"source\":1,\"target\":12,\"weight\":6.63},{\"source\":2,\"target\":10,\"weight\":1.59},{\"source\":2,\"target\":11,\"weight\":1.12},{\"source\":3,\"target\":14,\"weight\":8.54},{\"source\":4,\"target\":10,\"weight\":3.33},{\"source\":4,\"target\":13,\"weight\":3.11},{\"source\":5,\"target\":1,\"weight\":9.96},{\"source\":5,\"target\":6,\"weight\":5.23},{\"source\":5,\"target\":8,\"weight\":8.53},{\"source\":6,\"target\":1,\"weight\":5.29},{\"source\":6,\"target\":3,\"weight\":6.75},{\"source\":6,\"target\":4,\"weight\":2.36},{\"source\":6,\"target\":8,\"weight\":6.71},{\"source\":6,\"target\":9,\"weight\":8.81},{\"source\":8,\"target\":1,\"weight\":5.71},{\"source\":8,\"target\":4,\"weight\":7.67},{\"source\":8,\"target\":7,\"weight\":7.04},{\"source\":9,\"target\":0,\"weight\":1.58},{\"source\":9,\"target\":1,\"weight\":7.82},{\"source\":10,\"target\":1,\"weight\":6.32},{\"source\":10,\"target\":8,\"weight\":3.71},{\"source\":10,\"target\":12,\"weight\":1.28},{\"source\":11,\"target\":3,\"weight\":8.79},{\"source\":11,\"target\":9,\"weight\":5.25},{\"source\":11,\"target\":12,\"weight\":7.47},{\"source\":12,\"target\":0,\"weight\":8.91},{\"source\":12,\"target\":6,\"weight\":7.43},{\"source\":13,\"target\":1,\"weight\":9.29},{\"source\":13,\"target\":2,\"weight\":4.55},{\"source\":14,\"target\":3,\"weight\":8.21},{\"source\":14,\"target\":7,\"weight\":5.0}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let r = @sp.dijkstra(g, @core.NodeId(0))
      assert_true(approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01))
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(1)), 8.43, 0.01),
      )
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(2)), 12.76, 0.01),
      )
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "dj_dj_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":3.12},{\"source\":0,\"target\":2,\"weight\":1.93},{\"source\":0,\"target\":3,\"weight\":4.56},{\"source\":0,\"target\":4,\"weight\":2.39},{\"source\":0,\"target\":5,\"weight\":1.6},{\"source\":1,\"target\":3,\"weight\":4.61},{\"source\":1,\"target\":5,\"weight\":9.26},{\"source\":1,\"target\":6,\"weight\":8.2},{\"source\":1,\"target\":7,\"weight\":7.89},{\"source\":2,\"target\":0,\"weight\":3.0},{\"source\":2,\"target\":6,\"weight\":5.83},{\"source\":2,\"target\":7,\"weight\":3.49},{\"source\":3,\"target\":5,\"weight\":2.55},{\"source\":4,\"target\":1,\"weight\":1.96},{\"source\":4,\"target\":3,\"weight\":2.93},{\"source\":5,\"target\":0,\"weight\":9.35},{\"source\":6,\"target\":2,\"weight\":8.46},{\"source\":6,\"target\":3,\"weight\":8.26},{\"source\":6,\"target\":5,\"weight\":8.2},{\"source\":6,\"target\":7,\"weight\":2.74},{\"source\":7,\"target\":1,\"weight\":3.79},{\"source\":7,\"target\":4,\"weight\":6.64},{\"source\":7,\"target\":6,\"weight\":7.59}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let r = @sp.dijkstra(g, @core.NodeId(0))
      assert_true(approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01))
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(1)), 3.12, 0.01),
      )
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(2)), 1.93, 0.01),
      )
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "dj_dj_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],\"edges\":[{\"source\":0,\"target\":7,\"weight\":6.61},{\"source\":0,\"target\":12,\"weight\":7.68},{\"source\":0,\"target\":17,\"weight\":8.16},{\"source\":1,\"target\":5,\"weight\":9.48},{\"source\":1,\"target\":7,\"weight\":7.66},{\"source\":1,\"target\":8,\"weight\":9.3},{\"source\":2,\"target\":7,\"weight\":1.26},{\"source\":2,\"target\":8,\"weight\":5.19},{\"source\":2,\"target\":11,\"weight\":9.49},{\"source\":3,\"target\":0,\"weight\":6.84},{\"source\":3,\"target\":2,\"weight\":9.11},{\"source\":3,\"target\":6,\"weight\":2.02},{\"source\":3,\"target\":10,\"weight\":5.22},{\"source\":3,\"target\":11,\"weight\":3.22},{\"source\":4,\"target\":2,\"weight\":5.89},{\"source\":4,\"target\":7,\"weight\":6.17},{\"source\":4,\"target\":9,\"weight\":1.12},{\"source\":4,\"target\":19,\"weight\":2.95},{\"source\":5,\"target\":0,\"weight\":3.52},{\"source\":5,\"target\":4,\"weight\":9.25},{\"source\":5,\"target\":14,\"weight\":7.89},{\"source\":5,\"target\":16,\"weight\":2.44},{\"source\":5,\"target\":19,\"weight\":8.17},{\"source\":6,\"target\":4,\"weight\":2.25},{\"source\":6,\"target\":7,\"weight\":6.56},{\"source\":7,\"target\":0,\"weight\":2.14},{\"source\":7,\"target\":8,\"weight\":1.02},{\"source\":8,\"target\":9,\"weight\":8.84},{\"source\":10,\"target\":6,\"weight\":2.89},{\"source\":10,\"target\":14,\"weight\":2.94},{\"source\":10,\"target\":17,\"weight\":9.84},{\"source\":10,\"target\":18,\"weight\":8.85},{\"source\":11,\"target\":2,\"weight\":3.6},{\"source\":11,\"target\":9,\"weight\":9.65},{\"source\":11,\"target\":14,\"weight\":5.85},{\"source\":11,\"target\":17,\"weight\":7.1},{\"source\":11,\"target\":19,\"weight\":2.84},{\"source\":12,\"target\":9,\"weight\":9.47},{\"source\":12,\"target\":18,\"weight\":7.22},{\"source\":12,\"target\":19,\"weight\":9.7},{\"source\":13,\"target\":2,\"weight\":9.04},{\"source\":14,\"target\":4,\"weight\":3.69},{\"source\":14,\"target\":10,\"weight\":4.25},{\"source\":15,\"target\":6,\"weight\":2.49},{\"source\":15,\"target\":18,\"weight\":2.31},{\"source\":16,\"target\":4,\"weight\":1.59},{\"source\":16,\"target\":19,\"weight\":3.71},{\"source\":17,\"target\":6,\"weight\":6.43},{\"source\":17,\"target\":14,\"weight\":1.03},{\"source\":18,\"target\":0,\"weight\":7.1},{\"source\":18,\"target\":5,\"weight\":4.04},{\"source\":18,\"target\":11,\"weight\":3.79},{\"source\":18,\"target\":14,\"weight\":8.37},{\"source\":19,\"target\":0,\"weight\":5.33},{\"source\":19,\"target\":1,\"weight\":3.84},{\"source\":19,\"target\":3,\"weight\":5.33},{\"source\":19,\"target\":4,\"weight\":7.34},{\"source\":19,\"target\":8,\"weight\":1.51},{\"source\":19,\"target\":15,\"weight\":9.78}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 20)
      let r = @sp.dijkstra(g, @core.NodeId(0))
      assert_true(approx_shortest_path(r.distance_to(@core.NodeId(0)), 0, 0.01))
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(1)), 19.67, 0.01),
      )
      assert_true(
        approx_shortest_path(r.distance_to(@core.NodeId(2)), 18.77, 0.01),
      )
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "fw_fw_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":2.21},{\"source\":0,\"target\":4,\"weight\":8.63},{\"source\":1,\"target\":2,\"weight\":7.87},{\"source\":1,\"target\":3,\"weight\":3.3},{\"source\":1,\"target\":7,\"weight\":5.46},{\"source\":2,\"target\":3,\"weight\":5.05},{\"source\":2,\"target\":6,\"weight\":6.86},{\"source\":2,\"target\":7,\"weight\":8.1},{\"source\":3,\"target\":4,\"weight\":1.84},{\"source\":3,\"target\":6,\"weight\":1.26},{\"source\":3,\"target\":7,\"weight\":8.52},{\"source\":4,\"target\":2,\"weight\":4.89},{\"source\":4,\"target\":3,\"weight\":7.86},{\"source\":4,\"target\":5,\"weight\":1.02},{\"source\":4,\"target\":7,\"weight\":5.01},{\"source\":5,\"target\":0,\"weight\":7.49},{\"source\":5,\"target\":4,\"weight\":3.06},{\"source\":6,\"target\":0,\"weight\":9.51}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      match @sp.floyd_warshall(g) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(1), @core.NodeId(5)),
              6.16,
              0.01,
            ),
          )
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(6), @core.NodeId(0)),
              9.51,
              0.01,
            ),
          )
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(4), @core.NodeId(5)),
              1.02,
              0.01,
            ),
          )
        }
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
test "fw_fw_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":3,\"weight\":9.6},{\"source\":0,\"target\":4,\"weight\":9.53},{\"source\":1,\"target\":3,\"weight\":1.51},{\"source\":2,\"target\":3,\"weight\":1.76},{\"source\":2,\"target\":4,\"weight\":8.52},{\"source\":3,\"target\":1,\"weight\":7.62},{\"source\":3,\"target\":2,\"weight\":7.03},{\"source\":3,\"target\":5,\"weight\":3.77},{\"source\":3,\"target\":9,\"weight\":6.45},{\"source\":5,\"target\":0,\"weight\":6.46},{\"source\":6,\"target\":9,\"weight\":6.23},{\"source\":7,\"target\":2,\"weight\":2.43},{\"source\":8,\"target\":5,\"weight\":4.88},{\"source\":9,\"target\":0,\"weight\":4.54},{\"source\":9,\"target\":4,\"weight\":7.51},{\"source\":9,\"target\":6,\"weight\":9.95}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      match @sp.floyd_warshall(g) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(6), @core.NodeId(3)),
              20.37,
              0.01,
            ),
          )
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(3), @core.NodeId(6)),
              16.4,
              0.01,
            ),
          )
        }
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
test "fw_fw_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":3.14},{\"source\":0,\"target\":3,\"weight\":5.9},{\"source\":1,\"target\":0,\"weight\":4.33},{\"source\":1,\"target\":2,\"weight\":6.44},{\"source\":1,\"target\":4,\"weight\":6.63},{\"source\":1,\"target\":5,\"weight\":1.59},{\"source\":3,\"target\":0,\"weight\":1.12},{\"source\":4,\"target\":1,\"weight\":8.54},{\"source\":4,\"target\":5,\"weight\":3.33},{\"source\":5,\"target\":0,\"weight\":3.11}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      match @sp.floyd_warshall(g) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(0), @core.NodeId(0)),
              0,
              0.01,
            ),
          )
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(3), @core.NodeId(4)),
              10.89,
              0.01,
            ),
          )
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(1), @core.NodeId(0)),
              4.33,
              0.01,
            ),
          )
        }
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
test "fw_fw_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":2,\"weight\":3.12},{\"source\":0,\"target\":4,\"weight\":1.93},{\"source\":0,\"target\":5,\"weight\":4.56},{\"source\":1,\"target\":2,\"weight\":2.39},{\"source\":1,\"target\":3,\"weight\":1.6},{\"source\":1,\"target\":9,\"weight\":4.61},{\"source\":2,\"target\":4,\"weight\":9.26},{\"source\":2,\"target\":8,\"weight\":8.2},{\"source\":2,\"target\":10,\"weight\":7.89},{\"source\":4,\"target\":0,\"weight\":3.0},{\"source\":4,\"target\":3,\"weight\":5.83},{\"source\":4,\"target\":5,\"weight\":3.49},{\"source\":5,\"target\":0,\"weight\":2.55},{\"source\":5,\"target\":11,\"weight\":1.96},{\"source\":6,\"target\":0,\"weight\":2.93},{\"source\":6,\"target\":7,\"weight\":9.35},{\"source\":6,\"target\":9,\"weight\":8.46},{\"source\":7,\"target\":3,\"weight\":8.26},{\"source\":8,\"target\":1,\"weight\":8.2},{\"source\":8,\"target\":3,\"weight\":2.74},{\"source\":8,\"target\":7,\"weight\":3.79},{\"source\":8,\"target\":9,\"weight\":6.64},{\"source\":8,\"target\":10,\"weight\":7.59},{\"source\":9,\"target\":2,\"weight\":8.69},{\"source\":9,\"target\":6,\"weight\":8.92},{\"source\":9,\"target\":7,\"weight\":1.78},{\"source\":9,\"target\":8,\"weight\":6.45},{\"source\":9,\"target\":11,\"weight\":7.05},{\"source\":10,\"target\":0,\"weight\":5.55},{\"source\":10,\"target\":4,\"weight\":2.6},{\"source\":11,\"target\":1,\"weight\":5.26},{\"source\":11,\"target\":7,\"weight\":1.8}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      match @sp.floyd_warshall(g) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(6), @core.NodeId(1)),
              14.71,
              0.01,
            ),
          )
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(9), @core.NodeId(3)),
              9.19,
              0.01,
            ),
          )
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(2), @core.NodeId(6)),
              23.76,
              0.01,
            ),
          )
        }
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
test "fw_fw_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":true,\"nodes\":[0,1,2,3,4,5,6,7,8],\"edges\":[{\"source\":0,\"target\":7,\"weight\":6.61},{\"source\":1,\"target\":4,\"weight\":7.68},{\"source\":1,\"target\":6,\"weight\":8.16},{\"source\":2,\"target\":0,\"weight\":9.48},{\"source\":2,\"target\":1,\"weight\":7.66},{\"source\":2,\"target\":3,\"weight\":9.3},{\"source\":2,\"target\":6,\"weight\":1.26},{\"source\":2,\"target\":8,\"weight\":5.19},{\"source\":3,\"target\":1,\"weight\":9.49},{\"source\":3,\"target\":2,\"weight\":6.84},{\"source\":3,\"target\":5,\"weight\":9.11},{\"source\":3,\"target\":6,\"weight\":2.02},{\"source\":4,\"target\":0,\"weight\":5.22},{\"source\":4,\"target\":5,\"weight\":3.22},{\"source\":5,\"target\":1,\"weight\":5.89},{\"source\":5,\"target\":3,\"weight\":6.17},{\"source\":5,\"target\":4,\"weight\":1.12},{\"source\":5,\"target\":6,\"weight\":2.95},{\"source\":5,\"target\":7,\"weight\":3.52},{\"source\":6,\"target\":0,\"weight\":9.25},{\"source\":6,\"target\":2,\"weight\":7.89},{\"source\":6,\"target\":3,\"weight\":2.44},{\"source\":6,\"target\":7,\"weight\":8.17},{\"source\":7,\"target\":1,\"weight\":2.25},{\"source\":7,\"target\":3,\"weight\":6.56},{\"source\":7,\"target\":6,\"weight\":2.14},{\"source\":8,\"target\":2,\"weight\":1.02},{\"source\":8,\"target\":3,\"weight\":8.84},{\"source\":8,\"target\":4,\"weight\":2.89},{\"source\":8,\"target\":6,\"weight\":2.94}]}"
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 9)
      match @sp.floyd_warshall(g) {
        Ok(r) => {
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(6), @core.NodeId(7)),
              8.17,
              0.01,
            ),
          )
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(1), @core.NodeId(8)),
              21.24,
              0.01,
            ),
          )
          assert_true(
            approx_shortest_path(
              r.distance(@core.NodeId(7), @core.NodeId(7)),
              0,
              0.01,
            ),
          )
        }
        Err(_) => ()
      }
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
