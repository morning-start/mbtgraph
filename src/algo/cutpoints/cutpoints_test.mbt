///|
/// 割点和桥算法测试

///|
/// 创建简单链图 0-1-2-3-...-(n-1)
fn make_chain_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  i = 0
  while i < n - 1 {
    @storage.UndirectedAdjList::add_edge(
      g,
      @core.NodeId(i),
      @core.NodeId(i + 1),
      1.0,
    )
    |> ignore
    i = i + 1
  }
  g
}

///|
/// 创建简单环图（n 个节点的环）
fn make_cycle_graph(n : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < n {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  i = 0
  while i < n {
    @storage.UndirectedAdjList::add_edge(
      g,
      @core.NodeId(i),
      @core.NodeId((i + 1) % n),
      1.0,
    )
    |> ignore
    i = i + 1
  }
  g
}

///|
/// 创建星形图（中心 0 连接所有叶子）
fn make_star_graph(leaves : Int) -> @storage.UndirectedAdjList {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let mut i = 1
  while i <= leaves {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    @storage.UndirectedAdjList::add_edge(
      g,
      @core.NodeId(0),
      @core.NodeId(i),
      1.0,
    )
    |> ignore
    i = i + 1
  }
  g
}

// ============================================================================
// 割点测试
// ============================================================================

///|
test "chain_graph_has_cutpoints" {
  let g = make_chain_graph(4)
  let result = find_articulation_points_undirected(g)
  assert_eq(result.count, 2)
}

///|
test "cycle_graph_no_cutpoints" {
  let g = make_cycle_graph(3)
  let result = find_articulation_points_undirected(g)
  assert_eq(result.count, 0)
}

///|
test "star_graph_center_is_cutpoint" {
  let g = make_star_graph(4)
  let result = find_articulation_points_undirected(g)
  assert_eq(result.count, 1)
}

///|
test "complete_graph_no_cutpoints" {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  i = 0
  while i < 4 {
    let mut j = i + 1
    while j < 4 {
      @storage.UndirectedAdjList::add_edge(
        g,
        @core.NodeId(i),
        @core.NodeId(j),
        1.0,
      )
      |> ignore
      j = j + 1
    }
    i = i + 1
  }
  let result = find_articulation_points_undirected(g)
  assert_eq(result.count, 0)
}

///|
test "two_cycles_sharing_node" {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 5 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(4), @core.NodeId(0), 1.0)
  |> ignore
  let result = find_articulation_points_undirected(g)
  assert_eq(result.count, 1)
}

// ============================================================================
// 桥测试
// ============================================================================

///|
test "bridge_in_simple_graph" {
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 4 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  let result = find_bridges_undirected(g)
  assert_eq(result.count, 1)
}

///|
test "cycle_has_no_bridges" {
  let g = make_cycle_graph(4)
  let result = find_bridges_undirected(g)
  assert_eq(result.count, 0)
}

// ============================================================================
// 边界情况测试
// ============================================================================

///|
test "empty_graph" {
  let g = @storage.new_undirected()
  let ap_result = find_articulation_points_undirected(g)
  assert_eq(ap_result.count, 0)
  let br_result = find_bridges_undirected(g)
  assert_eq(br_result.count, 0)
}

///|
test "single_node" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  let result = find_articulation_points_undirected(g)
  assert_eq(result.count, 0)
}

///|
test "single_edge" {
  let g = @storage.new_undirected()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  let ap_result = find_articulation_points_undirected(g)
  assert_eq(ap_result.count, 0)
  let br_result = find_bridges_undirected(g)
  assert_eq(br_result.count, 1)
}

// ============================================================================
// 属性验证和边界情况扩展测试
// ============================================================================

///|
/// 属性验证：割点数量不超过 V-2（对于连通图，V≥3）
test "cutpoint_count_bound" {
  let g = make_chain_graph(10)
  let result = find_articulation_points_undirected(g)
  assert_true(result.count <= 8) // V-2 = 8
}

///|
/// 属性验证：删除割点后连通分量增加（简化版：检查链图的中间节点确实是割点）
test "cutpoint_is_valid" {
  let g = make_chain_graph(5)
  let result = find_articulation_points_undirected(g)
  // 链图 0-1-2-3-4 的割点是 1,2,3
  assert_eq(result.count, 3)
}

///|
/// 有向图基图割点测试
test "directed_graph_base_cutpoints" {
  // 创建有向环
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0)
  |> ignore
  let result = find_articulation_points_directed(g)
  assert_eq(result.count, 0) // 有向环的基图是环，无割点
}

///|
/// 有向图基图桥测试
test "directed_graph_base_bridges" {
  let g = @storage.new_directed()
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  let result = find_bridges_directed(g)
  assert_eq(result.count, 2) // 基图中边 0-1 和 1-2 都是桥
}

///|
/// 网格图 2x3 割点测试
test "grid_2x3_cutpoints" {
  // 2x3 网格:
  // 0-1-2
  // | | |
  // 3-4-5
  // 注意：2x3 网格图是双连通的（无割点），因为每个节点都有多条路径连接
  let g = @storage.new_undirected()
  let mut i = 0
  while i < 6 {
    @core.GraphWritable::add_node(g, 0.0) |> ignore
    i = i + 1
  }
  // 横向边
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0)
  |> ignore
  // 纵向边
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(4), 1.0)
  |> ignore
  @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(5), 1.0)
  |> ignore
  let result = find_articulation_points_undirected(g)
  // 2x3 网格是双连通图，没有割点
  assert_eq(result.count, 0)
}
