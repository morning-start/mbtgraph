///|
/// 最小生成树结果类型

pub(all) struct MstResult {
  total_weight : Double
  edges : Array[(@core.NodeId, @core.NodeId, Double)]
}

pub fn MstResult::edge_count(self : MstResult) -> Int {
  self.edges.length()
}

pub fn MstResult::has_edge(self : MstResult, u : @core.NodeId, v : @core.NodeId) -> Bool {
  for edge in self.edges {
    match edge {
      (a, b, _) => {
        if (a == u && b == v) || (a == v && b == u) {
          return true
        }
      }
    }
  }
  false
}
