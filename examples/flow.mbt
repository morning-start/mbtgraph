// 流网络示例
// 演示网络流算法的使用

import "morning-start/mbtgraph/lib/algo/flow" as @flow

/// 示例 1: 最大流问题
///
/// 问题：从源点 S 到汇点 T 的最大流量
///
///     (S)---16---(A)---12---(T)
///      |         |  \        |
///      13        10   4       20
///      |         |    \      |
///      (B)---9---(C)---14---(D)
///
fn max_flow_example() {
  println("=== 最大流问题 ===\n")

  println("网络结构:")
  println("  S -> A: 16, S -> B: 13")
  println("  A -> T: 12, A -> C: 10")
  println("  B -> C: 9")
  println("  C -> T: 14, C -> D: 4")
  println("  D -> T: 20")

  // 创建流网络
  let net = FlowNetwork::new(6)  // 6 个节点: S=0, A=1, B=2, C=3, D=4, T=5

  // 添加边（容量）
  let net = net.add_edge(0, 1, 16.0)  // S -> A
  let net = net.add_edge(0, 2, 13.0)  // S -> B
  let net = net.add_edge(1, 5, 12.0)  // A -> T
  let net = net.add_edge(1, 3, 10.0)  // A -> C
  let net = net.add_edge(2, 3, 9.0)   // B -> C
  let net = net.add_edge(3, 5, 14.0)  // C -> T
  let net = net.add_edge(3, 4, 4.0)   // C -> D
  let net = net.add_edge(4, 5, 20.0)  // D -> T

  // 运行 Edmonds-Karp 算法
  let result = @flow.edmonds_karp(net, 0, 5)

  println("\nEdmonds-Karp 结果:")
  println("  最大流量: \{result.max_flow}")

  // 运行 Dinic 算法
  let result = @flow.dinic(net, 0, 5)

  println("\nDinic 结果:")
  println("  最大流量: \{result.max_flow}")

  // 运行 Push-Relabel 算法
  let result = @flow.push_relabel(net, 0, 5)

  println("\nPush-Relabel 结果:")
  println("  最大流量: \{result.max_flow}")
}

/// 示例 2: 最小费用最大流问题
///
/// 问题：在满足最大流量的前提下，最小化总费用
fn min_cost_max_flow_example() {
  println("\n=== 最小费用最大流问题 ===\n")

  println("网络结构（容量, 费用）:")
  println("  S -> A: (10, 2), S -> B: (8, 3)")
  println("  A -> T: (5, 1), A -> B: (2, 1)")
  println("  B -> T: (10, 2)")

  // 创建费用流网络
  let net = CostFlowNetwork::new(4)  // 4 个节点: S=0, A=1, B=2, T=3

  // 添加边（容量, 费用）
  let net = net.add_edge(0, 1, 10.0, 2.0)  // S -> A
  let net = net.add_edge(0, 2, 8.0, 3.0)   // S -> B
  let net = net.add_edge(1, 3, 5.0, 1.0)   // A -> T
  let net = net.add_edge(1, 2, 2.0, 1.0)   // A -> B
  let net = net.add_edge(2, 3, 10.0, 2.0)  // B -> T

  // 运行最小费用最大流算法
  let result = @flow.min_cost_max_flow(net, 0, 3)

  println("\n结果:")
  println("  最大流量: \{result.max_flow}")
  println("  最小费用: \{result.min_cost}")
}

/// 示例 3: 全局最小割
///
/// 问题：找到将图分成两部分的最小割
fn stoer_wagner_example() {
  println("\n=== 全局最小割 (Stoer-Wagner) ===\n")

  println("图结构（邻接矩阵）:")
  println("  0-1: 3, 0-2: 2")
  println("  1-2: 4, 1-3: 1")
  println("  2-3: 5")

  // 创建邻接矩阵
  let adj = [
    [0.0, 3.0, 2.0, 0.0],
    [3.0, 0.0, 4.0, 1.0],
    [2.0, 4.0, 0.0, 5.0],
    [0.0, 1.0, 5.0, 0.0],
  ]

  // 运行 Stoer-Wagner 算法
  let result = @flow.stoer_wagner(adj)

  println("\n结果:")
  println("  最小割权重: \{result.min_cut_weight}")
  println("  分区: \{result.partition}")
}

/// 示例 4: 比较不同最大流算法
fn compare_max_flow_algorithms() {
  println("\n=== 比较最大流算法 ===\n")

  // 创建一个较大的测试网络
  let net = FlowNetwork::new(5)
  let net = net.add_edge(0, 1, 10.0)
  let net = net.add_edge(0, 2, 10.0)
  let net = net.add_edge(1, 2, 2.0)
  let net = net.add_edge(1, 3, 8.0)
  let net = net.add_edge(2, 4, 10.0)
  let net = net.add_edge(3, 4, 7.0)

  println("网络: 5 节点, 6 条边")
  println("源点: 0, 汇点: 4\n")

  // Edmonds-Karp
  let result = @flow.edmonds_karp(net, 0, 4)
  println("Edmonds-Karp: \{result.max_flow}")

  // Dinic
  let result = @flow.dinic(net, 0, 4)
  println("Dinic:        \{result.max_flow}")

  // Push-Relabel
  let result = @flow.push_relabel(net, 0, 4)
  println("Push-Relabel: \{result.max_flow}")

  // Capacity Scaling
  let result = @flow.capacity_scaling(net, 0, 4)
  println("Capacity Scaling: \{result.max_flow}")
}

/// 主函数
fn main {
  max_flow_example()
  min_cost_max_flow_example()
  stoer_wagner_example()
  compare_max_flow_algorithms()
}
