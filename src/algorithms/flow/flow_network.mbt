///|
/// 流网络（Flow Network）
///
/// 独立管理容量矩阵和流量矩阵，用于最大流算法。
/// 不依赖 core 的 Edge 类型，完全自包含。

pub(all) struct FlowNetwork {
  node_count : Int
  capacity : Array[Array[Double]]
  flow : Array[Array[Double]]
}

///|
/// 创建指定节点数的空流网络
pub fn FlowNetwork::new(node_count : Int) -> FlowNetwork {
  if node_count <= 0 {
    return FlowNetwork::{
      node_count: 0,
      capacity: [],
      flow: [],
    }
  }
  let cap : Array[Array[Double]] = []
  let flw : Array[Array[Double]] = []
  for i in 0..<node_count {
    let row_c : Array[Double] = []
    let row_f : Array[Double] = []
    for j in 0..<node_count {
      row_c.push(0.0)
      row_f.push(0.0)
    }
    cap.push(row_c)
    flw.push(row_f)
  }
  FlowNetwork::{ node_count: node_count, capacity: cap, flow: flw }
}

///|
/// 添加有向边（含反向边用于残差图）
///
/// 正向边容量 = capacity，反向边初始容量 = 0（用于撤销流量）。
pub fn FlowNetwork::add_edge(
  self : FlowNetwork,
  from : Int,
  to : Int,
  capacity : Double,
) -> FlowNetwork {
  let net = self
  if from < 0 || from >= net.node_count || to < 0 || to >= net.node_count {
    return net
  }
  if from == to {
    return net
  }
  net.capacity[from][to] = capacity
  net.capacity[to][from] = 0.0
  net.flow[from][to] = 0.0
  net.flow[to][from] = 0.0
  net
}
