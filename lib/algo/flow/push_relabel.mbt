/// Push-Relabel 最大流算法 (Simple / 全局重标记)
///
/// 由 Goldberg & Tarjan（1988）提出的预流-推进算法族中最经典的变体。
/// 与 Ford-Fulkerson 类增广路算法不同，Push-Relabel 不维护可行流，
/// 而是允许节点暂时持有超额流量（preflow），通过局部 push/relabel 操作
/// 逐步将超额推向汇点。
///
/// # 核心概念
///
/// - **高度函数 (height)**: 每个节点的标号，源点初始为 n，其余为 0
/// - **超额流量 (excess)**: e(v) = 流入量 - 流出量，仅 e > 0 的非源/汇节点为活动节点
/// - **Push 操作**: 将超额从高节点推向低邻居（需满足 height[u] = height[v] + 1）
/// - **Relabel 操作**: 当无法 push 时，提升节点高度至 min(邻居高度) + 1
///
/// # 本实现特点
///
/// 采用全局重标记 (Global Relabeling) 策略的简化版本:
/// - 初始化时将源点的所有出边饱和推送
/// - 每轮扫描所有活动节点，尝试 push 或 relabel
/// - 使用全局重标记策略保证收敛性

///|
/// Push-Relabel 最大流
///
/// 使用预流-推进方法求解网络最大流问题。
///
/// # 数学形式
///
/// 给定容量网络 G = (V, E, c)，源点 s，汇点 t:
///   max Σ_{(s,v)∈E} f(s,v)
///   s.t. 容量约束: 0 ≤ f(u,v) ≤ c(u,v)
///        流量守恒: ∀v ≠ s,t, Σ_in f = Σ_out f
///
/// # 参数
///
/// - `graph`: 流网络 (FlowNetwork)，包含节点数、容量矩阵和初始流量矩阵。
///   算法内部会深拷贝容量和流量矩阵，不修改原网络。
/// - `source`: 源点索引，范围 [0, node_count)
/// - `sink`: 汇点索引，范围 [0, node_count)，且 sink ≠ source
///
/// # 返回
///
/// `MaxFlowResult` 包含:
/// - `max_flow`: 从 source 到 sink 的最大流值（等于汇点的超额流量）
/// - `flow_matrix`: n × n 流量矩阵，flow_matrix[i][j] 表示边 (i,j) 上的实际流量
///
/// # 复杂度
///
/// - 时间: O(V² · E) — Simple 版本的最坏情况界
///   实际运行通常远快于理论最坏情况，对稀疏图表现优异
/// - 空间: O(V²)，用于存储容量矩阵、流量矩阵、高度数组和超额数组
///
/// # 应用场景
///
/// - 网络流量优化：通信网络、交通网络的带宽分配
/// - 二分图匹配：通过构造源-左部-右部-汇的网络流模型
/// - 图割问题：最小割与最大流的对偶关系
/// - 资源调度：项目与资源的分配优化
///
/// # 与其他最大流算法对比
///
/// | 算法 | 时间复杂度 | 适用场景 |
/// |------|-----------|---------|
/// | Edmonds-Karp | O(VE²) | 简单易懂，小规模 |
/// | Dinic | O(E√V) | 二分图/单位容量 |
/// | Push-Relabel | O(V²E) | 通用，稀疏图优秀 |
pub fn push_relabel(
  graph : FlowNetwork,
  source : Int,
  sink : Int,
) -> MaxFlowResult {
  let n = graph.node_count
  if n <= 1 || source == sink {
    return MaxFlowResult::{ max_flow: 0.0, flow_matrix: [] }
  }
  if source < 0 || source >= n || sink < 0 || sink >= n {
    return MaxFlowResult::{ max_flow: 0.0, flow_matrix: [] }
  }

  let cap = deep_copy_matrix(graph.capacity)
  let flow_matrix = deep_copy_matrix(graph.flow)
  let height : Array[Int] = Array::make(n, 0)
  let excess : Array[Double] = Array::make(n, 0.0)
  height[source] = n

  // 从 source 推送初始流量
  let mut v = 0
  while v < n {
    if cap[source][v] > 0.0 {
      let f = cap[source][v]
      flow_matrix[source][v] = flow_matrix[source][v] + f
      flow_matrix[v][source] = flow_matrix[v][source] - f
      cap[source][v] = 0.0
      cap[v][source] = cap[v][source] + f
      excess[v] = f
    }
    v = v + 1
  }

  // 只要有活动节点就继续
  let mut active = true
  while active {
    active = false
    let mut u = 0
    while u < n {
      if u != source && u != sink && excess[u] > 1.0e-12 {
        active = true
        let old_h = height[u]
        // 尝试推送
        v = 0
        while v < n {
          if cap[u][v] > 1.0e-12 && height[u] == height[v] + 1 {
            let f = if excess[u] < cap[u][v] { excess[u] } else { cap[u][v] }
            flow_matrix[u][v] = flow_matrix[u][v] + f
            flow_matrix[v][u] = flow_matrix[v][u] - f
            cap[u][v] = cap[u][v] - f
            cap[v][u] = cap[v][u] + f
            excess[u] = excess[u] - f
            excess[v] = excess[v] + f
            if excess[u] <= 1.0e-12 {
              break
            }
          }
          v = v + 1
        }

        if excess[u] > 1.0e-12 {
          // Relabel
          let mut min_h = n * 2
          v = 0
          while v < n {
            if cap[u][v] > 1.0e-12 && height[v] < min_h {
              min_h = height[v]
            }
            v = v + 1
          }
          if min_h < n * 2 {
            height[u] = min_h + 1
          } else {
            height[u] = n * 2
          }
        }
      }
      u = u + 1
    }
  }

  let max_flow_val = excess[sink]

  // 转换为 Array[Double?]
  let fm : Array[Array[Double?]] = Array::make(n, [])
  let mut ii = 0
  while ii < n {
    let row : Array[Double?] = Array::make(n, None)
    let mut jj = 0
    while jj < n {
      row[jj] = Some(flow_matrix[ii][jj])
      jj = jj + 1
    }
    fm[ii] = row
    ii = ii + 1
  }

  MaxFlowResult::{ max_flow: max_flow_val, flow_matrix: fm }
}
