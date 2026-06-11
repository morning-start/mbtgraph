///|
/// 存储层内部工具函数
///
/// 所有存储实现共用的辅助逻辑，避免重复代码。
/// 仅供同包内 storage 模块使用。
fn has_node(nodes : Array[@core.Node?], idx : Int) -> Bool {
  match nodes[idx] {
    None => false
    Some(_) => true
  }
}

///|
fn find_slot(nodes : Array[@core.Node?], i : Int, n : Int) -> Int {
  if i >= n {
    -1
  } else {
    match nodes[i] {
      None => i
      Some(_) => find_slot(nodes, i + 1, n)
    }
  }
}

///|
fn remove_from_list(
  list : Array[(@core.NodeId, Double)],
  target : Int,
) -> (Bool, Array[(@core.NodeId, Double)]) {
  let nl : Array[(@core.NodeId, Double)] = []
  let mut found = false
  for entry in list {
    match entry {
      (nid, w) => if nid.0 == target { found = true } else { nl.push((nid, w)) }
    }
  }
  (found, nl)
}

///|
///|
/// 冒泡排序（按权重升序）
///
/// ⚠️ 已废弃：v0.14.0 起被快速排序替代，保留仅供内部兼容性使用。
/// 外部代码不应依赖此函数。
fn bubble_sort_by_weight(
  edges : Array[(@core.NodeId, @core.NodeId, Double)],
) -> Array[(@core.NodeId, @core.NodeId, Double)] {
  let es = edges
  let n = es.length()
  let mut j = 0
  while j < n {
    let mut k = 0
    while k < n - j - 1 {
      let (_, _, w1) = es[k]
      let (_, _, w2) = es[k + 1]
      if w1 > w2 {
        let tmp = es[k]
        es[k] = es[k + 1]
        es[k + 1] = tmp
      }
      k = k + 1
    }
    j = j + 1
  }
  es
}

// ============================================================================
// 算法层公共工具函数（跨模块复用）
// ============================================================================

///|
/// 查找图中节点 ID 的最大值（用于分配数组大小时避免越界）
pub fn[G : @core.GraphReadable] find_max_node_id(graph : G) -> Int {
  let mut m = -1
  for nid in @core.GraphReadable::node_ids(graph) {
    if nid.0 > m {
      m = nid.0
    }
  }
  m
}

///|
/// 返回两个整数中的较大值
///|
/// 返回两个整数中的较大值
///
/// ⚠️ **内部工具函数**：仅供 mbtgraph 内部模块使用。
/// 外部代码应自行实现或等待 MoonBit 标准库提供 `Int::max()` 方法。
pub fn int_max(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}
