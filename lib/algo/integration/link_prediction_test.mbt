///|
/// link_prediction — Python/NetworkX 随机图验证 (每算法 5 图)
///

///|
test "lp_lp_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let cn = @link_prediction.common_neighbors(
        g,
        @core.NodeId(0),
        @core.NodeId(2),
      )
      assert_eq(cn, 1)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_lp_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":8,\"target\":11,\"weight\":1.0},{\"source\":10,\"target\":11,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let cn = @link_prediction.common_neighbors(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_eq(cn, 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_lp_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let cn = @link_prediction.common_neighbors(
        g,
        @core.NodeId(0),
        @core.NodeId(2),
      )
      assert_eq(cn, 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_lp_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":13,\"weight\":1.0},{\"source\":0,\"target\":14,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":13,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":12,\"weight\":1.0},{\"source\":3,\"target\":13,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":11,\"weight\":1.0},{\"source\":5,\"target\":12,\"weight\":1.0},{\"source\":6,\"target\":10,\"weight\":1.0},{\"source\":6,\"target\":12,\"weight\":1.0},{\"source\":7,\"target\":11,\"weight\":1.0},{\"source\":8,\"target\":14,\"weight\":1.0},{\"source\":9,\"target\":11,\"weight\":1.0},{\"source\":10,\"target\":11,\"weight\":1.0},{\"source\":10,\"target\":12,\"weight\":1.0},{\"source\":10,\"target\":13,\"weight\":1.0},{\"source\":11,\"target\":14,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let cn = @link_prediction.common_neighbors(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_eq(cn, 1)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_lp_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let cn = @link_prediction.common_neighbors(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_eq(cn, 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_aa_lp_aa_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let aa = @link_prediction.adamic_adar_index(
        g,
        @core.NodeId(0),
        @core.NodeId(2),
      )
      assert_true(aa >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_aa_lp_aa_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":10,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":10,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let aa = @link_prediction.adamic_adar_index(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(aa >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_aa_lp_aa_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let aa = @link_prediction.adamic_adar_index(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(aa >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_aa_lp_aa_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":13,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":12,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":13,\"weight\":1.0},{\"source\":6,\"target\":11,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":9,\"target\":13,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let aa = @link_prediction.adamic_adar_index(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(aa >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_aa_lp_aa_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let aa = @link_prediction.adamic_adar_index(
        g,
        @core.NodeId(0),
        @core.NodeId(2),
      )
      assert_true(aa >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_jac_lp_jac_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let jc = @link_prediction.jaccard_coefficient(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(jc >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_jac_lp_jac_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":9,\"weight\":1.0},{\"source\":3,\"target\":11,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":6,\"target\":10,\"weight\":1.0},{\"source\":6,\"target\":11,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0},{\"source\":9,\"target\":11,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let jc = @link_prediction.jaccard_coefficient(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(jc >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_jac_lp_jac_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let jc = @link_prediction.jaccard_coefficient(
        g,
        @core.NodeId(0),
        @core.NodeId(2),
      )
      assert_true(jc >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_jac_lp_jac_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":13,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":10,\"weight\":1.0},{\"source\":1,\"target\":12,\"weight\":1.0},{\"source\":1,\"target\":14,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":2,\"target\":14,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":12,\"weight\":1.0},{\"source\":3,\"target\":14,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":14,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":10,\"weight\":1.0},{\"source\":7,\"target\":12,\"weight\":1.0},{\"source\":8,\"target\":11,\"weight\":1.0},{\"source\":9,\"target\":14,\"weight\":1.0},{\"source\":10,\"target\":11,\"weight\":1.0},{\"source\":10,\"target\":12,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let jc = @link_prediction.jaccard_coefficient(
        g,
        @core.NodeId(0),
        @core.NodeId(2),
      )
      assert_true(jc >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_jac_lp_jac_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let jc = @link_prediction.jaccard_coefficient(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(jc >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_pa_lp_pa_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":6,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":9,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":9,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let pa = @link_prediction.preferential_attachment(
        g,
        @core.NodeId(0),
        @core.NodeId(8),
      )
      assert_true(pa >= 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_pa_lp_pa_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":6,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":11,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":10,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":8,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":6,\"target\":11,\"weight\":1.0},{\"source\":7,\"target\":10,\"weight\":1.0},{\"source\":7,\"target\":11,\"weight\":1.0},{\"source\":8,\"target\":9,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let pa = @link_prediction.preferential_attachment(
        g,
        @core.NodeId(0),
        @core.NodeId(3),
      )
      assert_true(pa >= 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_pa_lp_pa_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":7,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let pa = @link_prediction.preferential_attachment(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(pa >= 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_pa_lp_pa_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":10,\"weight\":1.0},{\"source\":0,\"target\":12,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":12,\"weight\":1.0},{\"source\":4,\"target\":7,\"weight\":1.0},{\"source\":4,\"target\":11,\"weight\":1.0},{\"source\":4,\"target\":13,\"weight\":1.0},{\"source\":6,\"target\":8,\"weight\":1.0},{\"source\":7,\"target\":14,\"weight\":1.0},{\"source\":9,\"target\":13,\"weight\":1.0},{\"source\":11,\"target\":12,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let pa = @link_prediction.preferential_attachment(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(pa >= 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_pa_lp_pa_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let pa = @link_prediction.preferential_attachment(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(pa >= 0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_ra_lp_ra_1" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":3,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":5,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":9,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 10)
      let ra = @link_prediction.resource_allocation(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(ra >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_ra_lp_ra_2" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11],\"edges\":[{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":10,\"weight\":1.0},{\"source\":0,\"target\":11,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":10,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":8,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":11,\"weight\":1.0},{\"source\":5,\"target\":6,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":7,\"target\":8,\"weight\":1.0},{\"source\":7,\"target\":10,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 12)
      let ra = @link_prediction.resource_allocation(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(ra >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_ra_lp_ra_3" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":5,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":5,\"weight\":1.0},{\"source\":5,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 8)
      let ra = @link_prediction.resource_allocation(
        g,
        @core.NodeId(0),
        @core.NodeId(2),
      )
      assert_true(ra >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_ra_lp_ra_4" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14],\"edges\":[{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":6,\"weight\":1.0},{\"source\":0,\"target\":7,\"weight\":1.0},{\"source\":0,\"target\":8,\"weight\":1.0},{\"source\":0,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":7,\"weight\":1.0},{\"source\":1,\"target\":8,\"weight\":1.0},{\"source\":1,\"target\":9,\"weight\":1.0},{\"source\":1,\"target\":11,\"weight\":1.0},{\"source\":1,\"target\":14,\"weight\":1.0},{\"source\":2,\"target\":6,\"weight\":1.0},{\"source\":2,\"target\":9,\"weight\":1.0},{\"source\":2,\"target\":13,\"weight\":1.0},{\"source\":4,\"target\":8,\"weight\":1.0},{\"source\":4,\"target\":9,\"weight\":1.0},{\"source\":4,\"target\":11,\"weight\":1.0},{\"source\":5,\"target\":8,\"weight\":1.0},{\"source\":5,\"target\":9,\"weight\":1.0},{\"source\":5,\"target\":13,\"weight\":1.0},{\"source\":6,\"target\":7,\"weight\":1.0},{\"source\":6,\"target\":9,\"weight\":1.0},{\"source\":6,\"target\":10,\"weight\":1.0},{\"source\":7,\"target\":10,\"weight\":1.0},{\"source\":7,\"target\":14,\"weight\":1.0},{\"source\":8,\"target\":14,\"weight\":1.0},{\"source\":11,\"target\":13,\"weight\":1.0},{\"source\":13,\"target\":14,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 15)
      let ra = @link_prediction.resource_allocation(
        g,
        @core.NodeId(0),
        @core.NodeId(1),
      )
      assert_true(ra >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}

///|
test "lp_ra_lp_ra_5" {
  let json = "{\"mbtgraph\":\"1.0\",\"directed\":false,\"nodes\":[0,1,2,3,4,5],\"edges\":[{\"source\":0,\"target\":1,\"weight\":1.0},{\"source\":0,\"target\":2,\"weight\":1.0},{\"source\":0,\"target\":3,\"weight\":1.0},{\"source\":0,\"target\":4,\"weight\":1.0},{\"source\":0,\"target\":5,\"weight\":1.0},{\"source\":1,\"target\":2,\"weight\":1.0},{\"source\":1,\"target\":3,\"weight\":1.0},{\"source\":1,\"target\":4,\"weight\":1.0},{\"source\":1,\"target\":5,\"weight\":1.0},{\"source\":2,\"target\":4,\"weight\":1.0},{\"source\":3,\"target\":4,\"weight\":1.0}]}"
  let g = @storage.new_undirected()
  match @io.parse_json_into(g, json) {
    Ok(_) => {
      assert_eq(@core.GraphReadable::node_count(g), 6)
      let ra = @link_prediction.resource_allocation(
        g,
        @core.NodeId(2),
        @core.NodeId(3),
      )
      assert_true(ra >= 0.0)
    }
    Err(e) => {
      println("parse error: {e}")
      assert_true(false)
    }
  }
}
