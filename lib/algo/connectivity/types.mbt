///|
/// 连通性分析结果类型
pub(all) struct ConnectedComponentsResult {
  components : Array[Array[@core.NodeId]]
}

///|
pub fn ConnectedComponentsResult::count(self : ConnectedComponentsResult) -> Int {
  self.components.length()
}

///|
fn array_contains(arr : Array[@core.NodeId], item : @core.NodeId) -> Bool {
  for x in arr {
    if x == item {
      return true
    }
  }
  false
}

///|
pub fn ConnectedComponentsResult::component_of(
  self : ConnectedComponentsResult,
  id : @core.NodeId,
) -> Int {
  let mut i = 0
  while i < self.components.length() {
    if array_contains(self.components[i], id) {
      return i
    }
    i = i + 1
  }
  -1
}

///|
pub fn ConnectedComponentsResult::size(
  self : ConnectedComponentsResult,
  comp_id : Int,
) -> Int {
  if comp_id < 0 || comp_id >= self.components.length() {
    0
  } else {
    self.components[comp_id].length()
  }
}

// ============================================================================
// 强连通分量结果类型
// ============================================================================

///|
pub(all) struct StronglyConnectedComponentsResult {
  components : Array[Array[@core.NodeId]]
}

///|
pub fn StronglyConnectedComponentsResult::count(
  self : StronglyConnectedComponentsResult,
) -> Int {
  self.components.length()
}

///|
pub fn StronglyConnectedComponentsResult::component_of(
  self : StronglyConnectedComponentsResult,
  id : @core.NodeId,
) -> Int {
  let mut i = 0
  while i < self.components.length() {
    if array_contains(self.components[i], id) {
      return i
    }
    i = i + 1
  }
  -1
}
