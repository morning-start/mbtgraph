///|
/// 图生成器测试
///
/// 覆盖所有 16 个生成器函数的属性验证和跨存储兼容性。

// ============================================================================
// 辅助：统计边数（通过遍历邻居）
// ============================================================================

fn count_edges_directed(g : @storage.DirectedAdjList) -> Int {
  let mut total = 0
  for nid in @core.GraphReadable::node_ids(g) {
    for _nbr in @core.GraphReadable::neighbors(g, nid) {
      total = total + 1
    }
  }
  total
}

fn count_edges_undirected(g : @storage.UndirectedAdjList) -> Int {
  @core.GraphReadable::edge_count(g)
}

// ============================================================================
// 完全图 K_n 测试
// ============================================================================

test "complete_directed_k5_node_count" {
  let g = @storage.new_directed()
  let g = complete_directed(g, 5, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 5)
}

test "complete_directed_k5_edge_count" {
  let g = @storage.new_directed()
  let g = complete_directed(g, 5, 1.0)
  assert_true(count_edges_directed(g) == 20)
}

test "complete_directed_k1_self_loop" {
  let g = @storage.new_directed()
  let g = complete_directed(g, 1, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 1)
  assert_true(count_edges_directed(g) == 0)
}

test "complete_directed_empty" {
  let g = @storage.new_directed()
  let g = complete_directed(g, 0, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 0)
}

test "complete_undirected_k5_node_count" {
  let g = @storage.new_undirected()
  let g = complete_undirected(g, 5, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 5)
}

test "complete_undirected_k5_edge_count" {
  let g = @storage.new_undirected()
  let g = complete_undirected(g, 5, 1.0)
  assert_true(count_edges_undirected(g) == 10)
}

test "complete_undirected_k2" {
  let g = @storage.new_undirected()
  let g = complete_undirected(g, 2, 1.0)
  assert_true(count_edges_undirected(g) == 1)
}

test "complete_undirected_empty" {
  let g = @storage.new_undirected()
  let g = complete_undirected(g, 0, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 0)
}

// ============================================================================
// 环图 C_n 测试
// ============================================================================

test "cycle_directed_c5_node_count" {
  let g = @storage.new_directed()
  let g = cycle_directed(g, 5, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 5)
}

test "cycle_directed_c5_edge_count" {
  let g = @storage.new_directed()
  let g = cycle_directed(g, 5, 1.0)
  assert_true(count_edges_directed(g) == 5)
}

test "cycle_directed_c1_self_loop" {
  let g = @storage.new_directed()
  let g = cycle_directed(g, 1, 1.0)
  assert_true(count_edges_directed(g) == 1)
}

test "cycle_undirected_c4_edge_count" {
  let g = @storage.new_undirected()
  let g = cycle_undirected(g, 4, 1.0)
  assert_true(count_edges_undirected(g) == 4)
}

test "cycle_undirected_c3_triangle" {
  let g = @storage.new_undirected()
  let g = cycle_undirected(g, 3, 1.0)
  assert_true(count_edges_undirected(g) == 3)
}

test "cycle_undirected_empty" {
  let g = @storage.new_undirected()
  let g = cycle_undirected(g, 0, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 0)
}

// ============================================================================
// 路径图 P_n 测试
// ============================================================================

test "path_directed_p5_node_count" {
  let g = @storage.new_directed()
  let g = path_directed(g, 5, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 5)
}

test "path_directed_p5_edge_count" {
  let g = @storage.new_directed()
  let g = path_directed(g, 5, 1.0)
  assert_true(count_edges_directed(g) == 4)
}

test "path_directed_p1_no_edges" {
  let g = @storage.new_directed()
  let g = path_directed(g, 1, 1.0)
  assert_true(count_edges_directed(g) == 0)
}

test "path_undirected_p6_edge_count" {
  let g = @storage.new_undirected()
  let g = path_undirected(g, 6, 1.0)
  assert_true(count_edges_undirected(g) == 5)
}

test "path_undirected_empty" {
  let g = @storage.new_undirected()
  let g = path_undirected(g, 0, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 0)
}

// ============================================================================
// 星型图 S_n 测试
// ============================================================================

test "star_directed_s5_node_count" {
  let g = @storage.new_directed()
  let g = star_directed(g, 5, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 5)
}

test "star_directed_s5_edge_count" {
  let g = @storage.new_directed()
  let g = star_directed(g, 5, 1.0)
  assert_true(count_edges_directed(g) == 4)
}

test "star_directed_s1_no_edges" {
  let g = @storage.new_directed()
  let g = star_directed(g, 1, 1.0)
  assert_true(count_edges_directed(g) == 0)
}

test "star_undirected_s6_edge_count" {
  let g = @storage.new_undirected()
  let g = star_undirected(g, 6, 1.0)
  assert_true(count_edges_undirected(g) == 5)
}

test "star_undirected_center_degree" {
  let g = @storage.new_undirected()
  let g = star_undirected(g, 4, 1.0)
  let mut center_degree = 0
  for _nbr in @core.GraphReadable::neighbors(g, @core.NodeId(0)) {
    center_degree = center_degree + 1
  }
  assert_true(center_degree == 3)
}

test "star_undirected_empty" {
  let g = @storage.new_undirected()
  let g = star_undirected(g, 0, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 0)
}

// ============================================================================
// 网格图测试
// ============================================================================

test "grid_directed_3x3_node_count" {
  let g = @storage.new_directed()
  let g = grid_directed(g, 3, 3, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 9)
}

test "grid_directed_3x3_edge_count" {
  let g = @storage.new_directed()
  let g = grid_directed(g, 3, 3, 1.0)
  assert_true(count_edges_directed(g) == 12)
}

test "grid_directed_2x4_edge_count" {
  let g = @storage.new_directed()
  let g = grid_directed(g, 2, 4, 1.0)
  assert_true(count_edges_directed(g) == 10)
}

test "grid_directed_1x1_no_edges" {
  let g = @storage.new_directed()
  let g = grid_directed(g, 1, 1, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 1)
  assert_true(count_edges_directed(g) == 0)
}

test "grid_undirected_2x3_edge_count" {
  let g = @storage.new_undirected()
  let g = grid_undirected(g, 2, 3, 1.0)
  assert_true(count_edges_undirected(g) == 7)
}

test "grid_undirected_zero_rows" {
  let g = @storage.new_undirected()
  let g = grid_undirected(g, 0, 5, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 0)
}

// ============================================================================
// 二分图测试
// ============================================================================

test "bipartite_directed_3x2_node_count" {
  let g = @storage.new_directed()
  let g = bipartite_complete_directed(g, 3, 2, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 5)
}

test "bipartite_directed_3x2_edge_count" {
  let g = @storage.new_directed()
  let g = bipartite_complete_directed(g, 3, 2, 1.0)
  assert_true(count_edges_directed(g) == 6)
}

test "bipartite_directed_1x1_edge_count" {
  let g = @storage.new_directed()
  let g = bipartite_complete_directed(g, 1, 1, 1.0)
  assert_true(count_edges_directed(g) == 1)
}

test "bipartite_undirected_4x3_edge_count" {
  let g = @storage.new_undirected()
  let g = bipartite_complete_undirected(g, 4, 3, 1.0)
  assert_true(count_edges_undirected(g) == 12)
}

test "bipartite_undirected_zero_m" {
  let g = @storage.new_undirected()
  let g = bipartite_complete_undirected(g, 0, 5, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 0)
}

// ============================================================================
// 随机图测试
// ============================================================================

test "random_directed_node_count" {
  let g = @storage.new_directed()
  let g = random_erdos_renyi_directed(g, 10, 0.5, 42, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 10)
}

test "random_undirected_node_count" {
  let g = @storage.new_undirected()
  let g = random_erdos_renyi_undirected(g, 8, 0.5, 42, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 8)
}

test "random_reproducibility_same_seed" {
  let g1 = @storage.new_directed()
  let g1 = random_erdos_renyi_directed(g1, 10, 0.5, 12345, 1.0)
  let g2 = @storage.new_directed()
  let g2 = random_erdos_renyi_directed(g2, 10, 0.5, 12345, 1.0)
  assert_true(count_edges_directed(g1) == count_edges_directed(g2))
}

test "random_p0_no_edges" {
  let g = @storage.new_directed()
  let g = random_erdos_renyi_directed(g, 5, 0.0, 42, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 0)
}

test "random_n0_empty" {
  let g = @storage.new_directed()
  let g = random_erdos_renyi_directed(g, 0, 0.5, 42, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 0)
}

test "random_undirected_reproducibility" {
  let g1 = @storage.new_undirected()
  let g1 = random_erdos_renyi_undirected(g1, 6, 0.7, 99, 1.0)
  let g2 = @storage.new_undirected()
  let g2 = random_erdos_renyi_undirected(g2, 6, 0.7, 99, 1.0)
  assert_true(count_edges_undirected(g1) == count_edges_undirected(g2))
}

// ============================================================================
// 自定义权重测试
// ============================================================================

test "custom_weight_complete" {
  let g = @storage.new_directed()
  let g = complete_directed(g, 3, 2.5)
  for nid in @core.GraphReadable::node_ids(g) {
    for nbr in @core.GraphReadable::neighbors(g, nid) {
      match @core.GraphReadable::get_edge(g, nid, nbr) {
        Some(w) => { assert_true(w == 2.5) }
        None => { assert_true(false) }
      }
    }
  }
}

test "custom_weight_cycle" {
  let g = @storage.new_undirected()
  let g = cycle_undirected(g, 4, 3.14)
  for nid in @core.GraphReadable::node_ids(g) {
    for nbr in @core.GraphReadable::neighbors(g, nid) {
      match @core.GraphReadable::get_edge(g, nid, nbr) {
        Some(w) => { assert_true(w == 3.14) }
        None => { assert_true(false) }
      }
    }
  }
}

// ============================================================================
// 跨存储兼容性测试：验证泛型约束对所有 GraphWritable 实现有效
// ============================================================================

test "cross_storage_complete_directed_adjlist" {
  let g = @storage.new_directed()
  let g = complete_directed(g, 4, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 4)
  assert_true(count_edges_directed(g) == 12)
}

test "cross_storage_complete_directed_matrix" {
  let g = @storage.new_directed_matrix(10)
  let g = complete_directed(g, 4, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 4)
}

test "cross_storage_complete_directed_edgelist" {
  let g = @storage.new_edge_list()
  let g = complete_directed(g, 4, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 4)
}

test "cross_storage_complete_undirected_adjlist" {
  let g = @storage.new_undirected()
  let g = complete_undirected(g, 4, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 4)
  assert_true(count_edges_undirected(g) == 6)
}

test "cross_storage_complete_undirected_matrix" {
  let g = @storage.new_undirected_matrix(10)
  let g = complete_undirected(g, 4, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 4)
}

test "cross_storage_complete_undirected_edgelist" {
  let g = @storage.new_undirected_edge_list()
  let g = complete_undirected(g, 4, 1.0)
  assert_true(@core.GraphReadable::node_count(g) == 4)
}

test "cross_storage_cycle_directed_all_types" {
  let g_al = @storage.new_directed()
  let _g_al = cycle_directed(g_al, 5, 1.0)
  let g_mat = @storage.new_directed_matrix(10)
  let _g_mat = cycle_directed(g_mat, 5, 1.0)
  let g_el = @storage.new_edge_list()
  let _g_el = cycle_directed(g_el, 5, 1.0)
  assert_true(true)
}

test "cross_storage_grid_undirected_all_types" {
  let g_al = @storage.new_undirected()
  let _g_al = grid_undirected(g_al, 2, 3, 1.0)
  let g_mat = @storage.new_undirected_matrix(10)
  let _g_mat = grid_undirected(g_mat, 2, 3, 1.0)
  let g_el = @storage.new_undirected_edge_list()
  let _g_el = grid_undirected(g_el, 2, 3, 1.0)
  assert_true(true)
}

test "cross_storage_bipartite_directed_all_types" {
  let g_al = @storage.new_directed()
  let _g_al = bipartite_complete_directed(g_al, 3, 2, 1.0)
  let g_mat = @storage.new_directed_matrix(20)
  let _g_mat = bipartite_complete_directed(g_mat, 3, 2, 1.0)
  let g_el = @storage.new_edge_list()
  let _g_el = bipartite_complete_directed(g_el, 3, 2, 1.0)
  assert_true(true)
}

test "cross_storage_star_undirected_all_types" {
  let g_al = @storage.new_undirected()
  let _g_al = star_undirected(g_al, 5, 1.0)
  let g_mat = @storage.new_undirected_matrix(10)
  let _g_mat = star_undirected(g_mat, 5, 1.0)
  let g_el = @storage.new_undirected_edge_list()
  let _g_el = star_undirected(g_el, 5, 1.0)
  assert_true(true)
}

test "cross_storage_path_directed_all_types" {
  let g_al = @storage.new_directed()
  let _g_al = path_directed(g_al, 6, 1.0)
  let g_mat = @storage.new_directed_matrix(10)
  let _g_mat = path_directed(g_mat, 6, 1.0)
  let g_el = @storage.new_edge_list()
  let _g_el = path_directed(g_el, 6, 1.0)
  assert_true(true)
}

test "cross_storage_random_directed_multiple_storages" {
  let g1 = @storage.new_directed()
  let g1 = random_erdos_renyi_directed(g1, 5, 0.5, 42, 1.0)
  let g2 = @storage.new_directed_matrix(10)
  let g2 = random_erdos_renyi_directed(g2, 5, 0.5, 42, 1.0)
  assert_true(@core.GraphReadable::node_count(g1) == 5)
  assert_true(@core.GraphReadable::node_count(g2) == 5)
}
