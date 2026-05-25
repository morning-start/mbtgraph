/// 中心性分析类型定义
///
/// 包含通用中心性结果结构和度模式枚举，
/// 用于统一四种中心性算法的返回值

///|
/// 度中心性计算模式
pub(all) enum DegreeMode {
  /// 入度（仅对有向图有意义）
  In
  /// 出度（仅对有向图有意义）
  Out
  /// 总度 = 入度 + 出度（有向图）或度数（无向图）
  Total
}

///|
/// 中心性计算结果（通用）
///
/// 所有四种中心性算法共享此结果结构
pub(all) struct CentralityResult {
  /// 节点中心性得分数组，索引对应 NodeId
  scores : Array[Double]
  /// 是否已归一化到 [0, 1] 范围
  normalized : Bool
} derive(Debug)

///|
/// 获取指定节点的中心性得分
///
/// 当 node_id 超出范围时返回 None
pub fn CentralityResult::get_score(self : CentralityResult, node_id : @core.NodeId) -> Double? {
  let id = node_id.0
  if id < 0 || id >= self.scores.length() {
    None
  } else {
    Some(self.scores[id])
  }
}

///|
/// 获取得分最高的节点及其分数
pub fn CentralityResult::max_node(self : CentralityResult) -> (@core.NodeId, Double)? {
  let n = self.scores.length()
  if n == 0 {
    return None
  }
  let mut best_idx = 0
  let mut best_val = self.scores[0]
  let mut i = 1
  while i < n {
    if self.scores[i] > best_val {
      best_idx = i
      best_val = self.scores[i]
    }
    i = i + 1
  }
  Some((@core.NodeId(best_idx), best_val))
}

///|
/// 获取所有非零得分的节点数量
pub fn CentralityResult::nonzero_count(self : CentralityResult) -> Int {
  let mut count = 0
  for s in self.scores {
    if s > 0.0 {
      count = count + 1
    }
  }
  count
}

///|
/// Int 转 Double 辅助函数
fn int_to_double(x : Int) -> Double {
  x.to_double()
}
