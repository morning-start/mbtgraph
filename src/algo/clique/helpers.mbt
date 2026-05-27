///|
/// 公共辅助函数（供 clique 模块内所有文件使用）
fn copy_array_int(arr : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for elem in arr {
    result.push(elem)
  }
  result
}

///|
fn intersect_arrays(a : Array[Int], b : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for elem in a {
    for be in b {
      if elem == be {
        result.push(elem)
        break
      }
    }
  }
  result
}

///|
fn remove_from_array(arr : Array[Int], val : Int) -> Array[Int] {
  let result : Array[Int] = []
  for elem in arr {
    if elem != val {
      result.push(elem)
    }
  }
  result
}
