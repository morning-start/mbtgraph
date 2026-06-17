// 社区检测示例
// 演示 Louvain、Leiden 和标签传播算法的使用

import "morning-start/mbtgraph/lib/core" as @core
import "morning-start/mbtgraph/lib/storage" as @storage
import "morning-start/mbtgraph/lib/algo/community" as @community

/// 创建示例图：社交网络（具有社区结构）
///
/// 社区 1: {0, 1, 2, 3} - 朋友群
/// 社区 2: {4, 5, 6, 7} - 同事群
/// 社区 3: {8, 9, 10, 11} - 家族群
///
/// 跨社区连接: 3-4, 7-8 (桥梁节点)
fn create_social_network() -> UndirectedAdjList {
  let g = @storage.new_undirected()

  // 添加 12 个节点
  for i in 0..<12 {
    let _ = @core.GraphWritable::add_node(g, i.to_double())
  }

  // 社区 1: 朋友群 (0, 1, 2, 3)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)

  // 社区 2: 同事群 (4, 5, 6, 7)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(6), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(7), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(5), @core.NodeId(6), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(5), @core.NodeId(7), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(6), @core.NodeId(7), 1.0)

  // 社区 3: 家族群 (8, 9, 10, 11)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(8), @core.NodeId(9), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(8), @core.NodeId(10), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(8), @core.NodeId(11), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(9), @core.NodeId(10), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(9), @core.NodeId(11), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(10), @core.NodeId(11), 1.0)

  // 跨社区桥梁
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0)
  let _ = @core.GraphWritable::add_edge(g, @core.NodeId(7), @core.NodeId(8), 1.0)

  g
}

/// 示例 1: Louvain 社区检测
fn louvain_example() {
  println("=== Louvain 社区检测 ===\n")

  let g = create_social_network()

  // 运行 Louvain 算法
  let result = @community.louvain(g, 1.0)

  println("检测到的社区:")
  println("  社区数量: \{result.num_communities}")
  println("  模块度: \{result.modularity}")
  println("  层次化层数: \{result.levels}")

  println("\n各社区成员:")
  for i in 0..<result.num_communities {
    let nodes = result.nodes_in_community(i)
    print("  社区 \{i}: ")
    for j in 0..<nodes.length() {
      let node_id = match nodes[j] { NodeId(n) => n }
      print("\{node_id} ")
    }
    println("")
  }

  println("\n节点所属社区:")
  for i in 0..<12 {
    let node = @core.NodeId(i)
    let label = result.get_label(node)
    match label {
      Some(l) => println("  节点 \{i}: 社区 \{l}")
      None => println("  节点 \{i}: 未分类")
    }
  }
}

/// 示例 2: Leiden 社区检测
fn leiden_example() {
  println("\n=== Leiden 社区检测 ===\n")

  let g = create_social_network()

  // 运行 Leiden 算法
  let result = @community.leiden(g, 1.0)

  println("Leiden 算法结果:")
  println("  社区数量: \{result.num_communities}")
  println("  模块度: \{result.modularity}")

  println("\n各社区成员:")
  for i in 0..<result.num_communities {
    let nodes = result.nodes_in_community(i)
    print("  社区 \{i}: ")
    for j in 0..<nodes.length() {
      let node_id = match nodes[j] { NodeId(n) => n }
      print("\{node_id} ")
    }
    println("")
  }
}

/// 示例 3: 标签传播算法
fn label_propagation_example() {
  println("\n=== 标签传播算法 ===\n")

  let g = create_social_network()

  // 运行标签传播算法
  let result = @community.label_propagation(g, 10)

  println("标签传播结果:")
  println("  社区数量: \{result.num_communities}")
  println("  模块度: \{result.modularity}")

  println("\n节点标签:")
  for i in 0..<12 {
    let node = @core.NodeId(i)
    let label = result.get_label(node)
    match label {
      Some(l) => println("  节点 \{i}: 标签 \{l}")
      None => println("  节点 \{i}: 未分类")
    }
  }
}

/// 示例 4: 比较不同算法
fn compare_algorithms() {
  println("\n=== 比较社区检测算法 ===\n")

  let g = create_social_network()

  // Louvain
  let louvain = @community.louvain(g, 1.0)
  println("Louvain:  社区数=\{louvain.num_communities}, 模块度=\{louvain.modularity}")

  // Leiden
  let leiden = @community.leiden(g, 1.0)
  println("Leiden:   社区数=\{leiden.num_communities}, 模块度=\{leiden.modularity}")

  // 标签传播
  let lp = @community.label_propagation(g, 10)
  println("标签传播: 社区数=\{lp.num_communities}, 模块度=\{lp.modularity}")

  // 谱聚类
  let spectral = @community.spectral_clustering(g, 3)
  println("谱聚类:   社区数=\{spectral.num_communities}, 模块度=\{spectral.modularity}")
}

/// 主函数
fn main {
  louvain_example()
  leiden_example()
  label_propagation_example()
  compare_algorithms()
}
