///|
/// 存储层公共工具函数
///
/// 所有存储实现共用的辅助逻辑，避免重复代码。
pub fn has_node(nodes : Array[@core.Node?], idx : Int) -> Bool {
  match nodes[idx] {
    None => false
    Some(_) => true
  }
}

///|
pub fn find_slot(nodes : Array[@core.Node?], i : Int, n : Int) -> Int {
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
pub fn remove_from_list(
  list : Array[(@core.NodeId, Double)],
  target : Int,
) -> (Bool, Array[(@core.NodeId, Double)]) {
  let nl : Array[(@core.NodeId, Double)] = []
  let mut found = false
  for entry in list {
    match entry {
      (nid, w) => if nid.0 == target { found = true } else { nl.push((nid, w)) }
      _ => ()
    }
  }
  (found, nl)
}

///|
pub fn bubble_sort_by_weight(
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
