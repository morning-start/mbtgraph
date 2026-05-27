///|
/// I/O 操作错误类型
pub(all) enum IOError {
  ParseError(String)
  UnsupportedFormat(String)
  InvalidData(String)
}

///|
pub fn IOError::to_string(self : IOError) -> String {
  match self {
    ParseError(msg) => "ParseError: " + msg
    UnsupportedFormat(msg) => "UnsupportedFormat: " + msg
    InvalidData(msg) => "InvalidData: " + msg
  }
}

///|
/// 图统计信息结构体
pub(all) struct GraphStats {
  node_count : Int
  edge_count : Int
  is_directed : Bool
  density : Double
  avg_degree : Double
  min_degree : Int
  max_degree : Int
  self_loop_count : Int
}

///|
/// 连通性统计信息结构体
pub(all) struct ConnectivityStats {
  component_count : Int
  largest_component_size : Int
  component_sizes : Array[Int]
}

///|
/// 度分布（按度值索引的节点计数）
pub(all) struct DegreeDistribution {
  min_degree : Int
  max_degree : Int
  histogram : Array[Int]
}

///|
/// 换行符
let newline = "\n"

///|
/// 图元信息标记
let info_json_key = "mbtgraph"
