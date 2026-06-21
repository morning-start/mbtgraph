///|
/// 二叉最小堆（内部使用，不对外暴露）
///
/// 存储 (priority, NodeId) 元组，按 priority 升序排列。
/// 用于 Dijkstra 算法的优先队列。
priv struct BinaryHeap {
  data : Array[(Double, @core.NodeId)]
}

///|
fn heap_new() -> BinaryHeap {
  BinaryHeap::{ data: [] }
}

///|
fn heap_push(
  h : BinaryHeap,
  priority : Double,
  id : @core.NodeId,
) -> BinaryHeap {
  let hh = h
  hh.data.push((priority, id))
  heap_sift_up(hh, hh.data.length() - 1)
  hh
}

///|
fn heap_pop(h : BinaryHeap) -> (BinaryHeap, (@core.NodeId, Double)?) {
  let hh = h
  if hh.data.length() == 0 {
    return (hh, None)
  }
  let top = hh.data[0]
  let last_idx = hh.data.length() - 1
  hh.data[0] = hh.data[last_idx]
  let _ = hh.data.pop()
  if hh.data.length() > 0 {
    heap_sift_down(hh, 0)
  }
  (hh, Some((top.1, top.0)))
}

///|
fn heap_is_empty(h : BinaryHeap) -> Bool {
  h.data.length() == 0
}

///|
fn heap_length(h : BinaryHeap) -> Int {
  h.data.length()
}

///|
fn heap_sift_up(h : BinaryHeap, idx : Int) -> Unit {
  let mut i = idx
  while i > 0 {
    let parent = (i - 1) / 2
    if h.data[i].0 < h.data[parent].0 {
      let tmp = h.data[i]
      h.data[i] = h.data[parent]
      h.data[parent] = tmp
      i = parent
    } else {
      break
    }
  }
}

///|
fn heap_sift_down(h : BinaryHeap, idx : Int) -> Unit {
  let mut i = idx
  let n = h.data.length()
  while true {
    let left = 2 * i + 1
    let right = 2 * i + 2
    let mut smallest = i
    if left < n && h.data[left].0 < h.data[smallest].0 {
      smallest = left
    }
    if right < n && h.data[right].0 < h.data[smallest].0 {
      smallest = right
    }
    if smallest != i {
      let tmp = h.data[i]
      h.data[i] = h.data[smallest]
      h.data[smallest] = tmp
      i = smallest
    } else {
      break
    }
  }
}
