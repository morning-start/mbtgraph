///|
/// 图匹配结果类型
pub(all) struct MatchingResult {
  matching_edges : Array[(@core.NodeId, @core.NodeId)]
  cardinality : Int
}

///|
pub fn MatchingResult::size(self : MatchingResult) -> Int {
  self.cardinality
}

///|
pub fn MatchingResult::is_matched(
  self : MatchingResult,
  node : @core.NodeId,
) -> Bool {
  for edge in self.matching_edges {
    match edge {
      (u, v) => if u == node || v == node { return true }
    }
  }
  false
}

///|
pub fn MatchingResult::get_partner(
  self : MatchingResult,
  node : @core.NodeId,
) -> @core.NodeId? {
  for edge in self.matching_edges {
    match edge {
      (u, v) => {
        if u == node {
          return Some(v)
        }
        if v == node {
          return Some(u)
        }
      }
    }
  }
  None
}
