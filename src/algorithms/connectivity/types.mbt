///|
/// 连通性分析结果类型

pub(all) struct ConnectedComponents {
  components : Array[Array[@core.NodeId]]
}

pub fn ConnectedComponents::count(self : ConnectedComponents) -> Int {
  self.components.length()
}

fn array_contains(arr : Array[@core.NodeId], item : @core.NodeId) -> Bool {
  for x in arr {
    if x == item {
      return true
    }
  }
  false
}

fn max_int(a : Int, b : Int) -> Int {
  if a > b { a } else { b }
}

pub fn ConnectedComponents::component_of(self : ConnectedComponents, id : @core.NodeId) -> Int {
  let mut i = 0
  while i < self.components.length() {
    if array_contains(self.components[i], id) {
      return i
    }
    i = i + 1
  }
  -1
}

pub fn ConnectedComponents::size(self : ConnectedComponents, comp_id : Int) -> Int {
  if comp_id < 0 || comp_id >= self.components.length() {
    0
  } else {
    self.components[comp_id].length()
  }
}

// ============================================================================
// 强连通分量结果类型
// ============================================================================

pub(all) struct StronglyConnectedComponents {
  components : Array[Array[@core.NodeId]]
}

pub fn StronglyConnectedComponents::count(self : StronglyConnectedComponents) -> Int {
  self.components.length()
}

pub fn StronglyConnectedComponents::component_of(self : StronglyConnectedComponents, id : @core.NodeId) -> Int {
  let mut i = 0
  while i < self.components.length() {
    if array_contains(self.components[i], id) {
      return i
    }
    i = i + 1
  }
  -1
}
