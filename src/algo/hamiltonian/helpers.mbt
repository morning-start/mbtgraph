///|
/// 公共辅助函数

fn copy_array_int(arr : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for elem in arr {
    result.push(elem)
  }
  result
}

fn array_contains(arr : Array[Int], val : Int) -> Bool {
  for elem in arr {
    if elem == val {
      return true
    }
  }
  false
}

fn remove_from_array(arr : Array[Int], val : Int) -> Array[Int] {
  let result : Array[Int] = []
  for elem in arr {
    if elem != val {
      result.push(elem)
    }
  }
  result
}
