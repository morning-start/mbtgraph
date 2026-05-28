/// 社区检测类型定义
///
/// 包含社区检测结果结构和相关类型，
/// 用于 Louvain 和标签传播两种算法的返回值

///|
/// 社区检测结果
///
/// 提供节点的社区归属信息和模块度等元数据
pub(all) struct CommunityResult {
  /// 节点所属社区标签，索引对应 NodeId
  labels : Array[Int]
  /// 模块度（Modularity）值，量化划分质量
  modularity : Double
  /// 检测到的社区数量
  num_communities : Int
  /// 算法层级数（Louvain 的有效层数，标签传播时为 1）
  levels : Int
} derive(Debug)

///|
/// 社区检测结果辅助方法
pub fn CommunityResult::get_label(
  self : CommunityResult,
  node_id : @core.NodeId,
) -> Int? {
  let id = node_id.0
  if id < 0 || id >= self.labels.length() {
    None
  } else {
    Some(self.labels[id])
  }
}

///|
/// 获取属于指定社区的节点列表
pub fn CommunityResult::nodes_in_community(
  self : CommunityResult,
  community_id : Int,
) -> Array[@core.NodeId] {
  let result : Array[@core.NodeId] = []
  let mut i = 0
  while i < self.labels.length() {
    if self.labels[i] == community_id {
      result.push(@core.NodeId(i))
    }
    i = i + 1
  }
  result
}

///|
/// 获取最大的社区大小
pub fn CommunityResult::largest_community_size(self : CommunityResult) -> Int {
  let mut max_count = 0
  let visited : Array[Bool] = Array::make(self.labels.length(), false)
  let mut i = 0
  while i < self.labels.length() {
    if !visited[i] {
      let label = self.labels[i]
      let mut count = 0
      let mut j = 0
      while j < self.labels.length() {
        if self.labels[j] == label {
          count = count + 1
          visited[j] = true
        }
        j = j + 1
      }
      if count > max_count {
        max_count = count
      }
    }
    i = i + 1
  }
  max_count
}

///|
/// Int 转 Double 辅助
fn int_to_double(x : Int) -> Double {
  x.to_double()
}
