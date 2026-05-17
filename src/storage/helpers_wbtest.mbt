// Whitebox tests for shared_helpers.
// Tests internal utility functions used by storage implementations.

///|
test "has_node returns true for occupied slot" {
  let nodes : Array[@core.Node?] = [
    Some({ id: @core.NodeId(0), data: 1.0 }),
    None,
    Some({ id: @core.NodeId(2), data: 3.0 }),
  ]

  assert_true(has_node(nodes, 0))
  assert_true(!has_node(nodes, 1))
  assert_true(has_node(nodes, 2))
}

///|
test "find_slot finds first free slot in array" {
  let nodes : Array[@core.Node?] = [
    Some({ id: @core.NodeId(0), data: 1.0 }),
    None,
    Some({ id: @core.NodeId(2), data: 3.0 }),
  ]

  assert_eq(find_slot(nodes, 0, 3), 1)
}

///|
test "find_slot returns -1 when no free slot exists" {
  let nodes : Array[@core.Node?] = [
    Some({ id: @core.NodeId(0), data: 1.0 }),
    Some({ id: @core.NodeId(1), data: 2.0 }),
  ]

  assert_eq(find_slot(nodes, 0, 2), -1)
}

///|
test "find_slot returns first index when array is empty" {
  let nodes : Array[@core.Node?] = []

  assert_eq(find_slot(nodes, 0, 0), -1)
}

///|
test "find_slot skips before start index" {
  let nodes : Array[@core.Node?] = [None, None, None]

  // start=1, should find slot at 1 even though 0 is also free
  assert_eq(find_slot(nodes, 1, 3), 1)
}

///|
test "remove_from_list removes matching entry and returns found=true" {
  let list : Array[(@core.NodeId, Double)] = [
    (@core.NodeId(0), 1.0),
    (@core.NodeId(1), 2.0),
    (@core.NodeId(2), 3.0),
  ]

  let (found, result) = remove_from_list(list, 1)
  assert_true(found)
  assert_eq(result.length(), 2)
  // Should contain entries 0 and 2
  let (id0, _) = result[0]
  match id0 { @core.NodeId(v) => assert_eq(v, 0) }
  let (id2, _) = result[1]
  match id2 { @core.NodeId(v) => assert_eq(v, 2) }
}

///|
test "remove_from_list returns found=false when target not present" {
  let list : Array[(@core.NodeId, Double)] = [
    (@core.NodeId(0), 1.0),
    (@core.NodeId(1), 2.0),
  ]

  let (found, result) = remove_from_list(list, 99)
  assert_true(!found)
  assert_eq(result.length(), 2)
}

///|
test "remove_from_list on empty list returns not found" {
  let list : Array[(@core.NodeId, Double)] = []

  let (found, result) = remove_from_list(list, 0)
  assert_true(!found)
  assert_eq(result.length(), 0)
}

///|
test "remove_from_list removes only first occurrence when duplicates exist" {
  let list : Array[(@core.NodeId, Double)] = [
    (@core.NodeId(0), 1.0),
    (@core.NodeId(1), 2.0),
    (@core.NodeId(0), 3.0),
  ]

  let (found, result) = remove_from_list(list, 0)
  assert_true(found)
  assert_eq(result.length(), 1)
  // Only non-matching entry remains
  let (id0, w0) = result[0]
  match id0 { @core.NodeId(v) => assert_eq(v, 1) }
  assert_eq(w0, 2.0)
}

///|
test "bubble_sort_by_weight sorts ascending by third element" {
  let edges : Array[(@core.NodeId, @core.NodeId, Double)] = [
    (@core.NodeId(0), @core.NodeId(1), 5.0),
    (@core.NodeId(0), @core.NodeId(2), 1.0),
    (@core.NodeId(1), @core.NodeId(2), 3.0),
  ]

  let sorted = bubble_sort_by_weight(edges)
  assert_eq(sorted.length(), 3)

  let (_, _, w0) = sorted[0]
  let (_, _, w1) = sorted[1]
  let (_, _, w2) = sorted[2]
  assert_true(w0 <= w1)
  assert_true(w1 <= w2)
  assert_eq(w0, 1.0)
  assert_eq(w2, 5.0)
}

///|
test "bubble_sort_by_weight on already-sorted input is stable" {
  let edges : Array[(@core.NodeId, @core.NodeId, Double)] = [
    (@core.NodeId(0), @core.NodeId(1), 1.0),
    (@core.NodeId(0), @core.NodeId(2), 2.0),
    (@core.NodeId(1), @core.NodeId(2), 3.0),
  ]

  let sorted = bubble_sort_by_weight(edges)
  assert_eq(sorted.length(), 3)

  let (_, _, w0) = sorted[0]
  let (_, _, w2) = sorted[2]
  assert_eq(w0, 1.0)
  assert_eq(w2, 3.0)
}

///|
test "bubble_sort_by_weight on single element returns same" {
  let edges : Array[(@core.NodeId, @core.NodeId, Double)] = [
    (@core.NodeId(0), @core.NodeId(1), 99.9),
  ]

  let sorted = bubble_sort_by_weight(edges)
  assert_eq(sorted.length(), 1)
  let (_, _, w) = sorted[0]
  assert_eq(w, 99.9)
}

///|
test "bubble_sort_by_weight on empty array returns empty" {
  let edges : Array[(@core.NodeId, @core.NodeId, Double)] = []

  let sorted = bubble_sort_by_weight(edges)
  assert_eq(sorted.length(), 0)
}
