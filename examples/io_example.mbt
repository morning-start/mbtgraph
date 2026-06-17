// I/O 示例
// 演示 DOT 和 JSON 格式的序列化/反序列化

import "morning-start/mbtgraph/lib/core" as @core
import "morning-start/mbtgraph/lib/storage" as @storage
import "morning-start/mbtgraph/lib/io" as @io

/// 创建示例图：简单有向图
fn create_sample_graph() -> DirectedAdjList {
  let g = @storage.new_directed()

  // 添加节点
  let _ = @core.GraphWritable::add_node(g, 0.0)  // A
  let _ = @core.GraphWritable::add_node(g, 1.0)  // B
  let _ = @core.GraphWritable::add_node(g, 2.0)  // C
  let _ = @core.GraphWritable::add_node(g, 3.0)  // D

  // 添加边
  let n0 = @core.NodeId(0)
  let n1 = @core.NodeId(1)
  let n2 = @core.NodeId(2)
  let n3 = @core.NodeId(3)

  let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)  // A -> B
  let _ = @core.GraphWritable::add_edge(g, n0, n2, 2.0)  // A -> C
  let _ = @core.GraphWritable::add_edge(g, n1, n3, 3.0)  // B -> D
  let _ = @core.GraphWritable::add_edge(g, n2, n3, 4.0)  // C -> D

  g
}

/// 示例 1: 导出为 DOT 格式
fn export_dot_example() {
  println("=== 导出 DOT 格式 ===\n")

  let g = create_sample_graph()

  // 导出为 DOT 格式
  let dot = @io.write_dot(g, "sample_graph")

  println("DOT 格式输出:")
  println(dot)
}

/// 示例 2: 导出为 JSON 格式
fn export_json_example() {
  println("\n=== 导出 JSON 格式 ===\n")

  let g = create_sample_graph()

  // 导出为 JSON 格式（格式化）
  let json = @io.graph_to_json(g, true)

  println("JSON 格式输出:")
  println(json)
}

/// 示例 3: 图统计信息
fn graph_stats_example() {
  println("\n=== 图统计信息 ===\n")

  let g = create_sample_graph()

  // 基本统计
  let stats = @io.basic_stats(g)
  println("基本统计:")
  println("  节点数: \{stats.node_count}")
  println("  边数: \{stats.edge_count}")
  println("  是否有向: \{stats.is_directed}")
  println("  密度: \{stats.density}")
  println("  平均度数: \{stats.avg_degree}")
  println("  最小度数: \{stats.min_degree}")
  println("  最大度数: \{stats.max_degree}")
  println("  自环数: \{stats.self_loop_count}")

  // 度分布
  let dist = @io.degree_distribution(g)
  println("\n度分布:")
  println("  最小度数: \{dist.min_degree}")
  println("  最大度数: \{dist.max_degree}")
  println("  直方图: \{dist.histogram}")

  // 连通性统计
  let conn = @io.connectivity_stats(g)
  println("\n连通性统计:")
  println("  连通分量数: \{conn.component_count}")
  println("  最大分量大小: \{conn.largest_component_size}")
  println("  各分量大小: \{conn.component_sizes}")

  // 距离指标
  let dist_metrics = @io.distance_metrics(g)
  println("\n距离指标:")
  println("  直径: \{dist_metrics.diameter}")
  println("  半径: \{dist_metrics.radius}")
  println("  Wiener 指数: \{dist_metrics.wiener_index}")
  println("  平均路径长度: \{dist_metrics.avg_path_length}")

  // 网络效率
  let eff = @io.network_efficiency(g)
  println("\n网络效率:")
  println("  全局效率: \{eff.global_efficiency}")
  println("  局部效率: \{eff.local_efficiency}")

  // 三元组统计
  let triad = @io.triad_counting(g)
  println("\n三元组统计:")
  println("  开三元组: \{triad.open_triads}")
  println("  闭三元组: \{triad.closed_triads}")
  println("  全局聚类系数: \{triad.global_clustering}")
}

/// 示例 4: 解析 DOT 格式
fn parse_dot_example() {
  println("\n=== 解析 DOT 格式 ===\n")

  // DOT 格式字符串
  let dot_str = "digraph test {
    0 [label=\"A\"];
    1 [label=\"B\"];
    2 [label=\"C\"];
    0 -> 1 [weight=1.0];
    0 -> 2 [weight=2.0];
    1 -> 2 [weight=3.0];
  }"

  println("输入 DOT 格式:")
  println(dot_str)

  // 创建空图并解析
  let g = @storage.new_directed()
  match @io.parse_dot_into(g, dot_str) {
    Ok(()) => {
      println("\n解析成功!")
      let stats = @io.basic_stats(g)
      println("  节点数: \{stats.node_count}")
      println("  边数: \{stats.edge_count}")

      // 重新导出验证
      let exported = @io.write_dot(g, "parsed_graph")
      println("\n重新导出:")
      println(exported)
    }
    Err(e) => {
      let err_str = match e {
        IOError::ParseError(msg) => "解析错误: \{msg}"
        IOError::UnsupportedFormat(msg) => "不支持的格式: \{msg}"
        IOError::InvalidData(msg) => "无效数据: \{msg}"
      }
      println("解析失败: \{err_str}")
    }
  }
}

/// 示例 5: 解析 JSON 格式
fn parse_json_example() {
  println("\n=== 解析 JSON 格式 ===\n")

  // JSON 格式字符串
  let json_str = "{
    \"nodes\": [0, 1, 2],
    \"edges\": [[0, 1, 1.0], [1, 2, 2.0], [0, 2, 3.0]]
  }"

  println("输入 JSON 格式:")
  println(json_str)

  // 创建空图并解析
  let g = @storage.new_directed()
  match @io.parse_json_into(g, json_str) {
    Ok(()) => {
      println("\n解析成功!")
      let stats = @io.basic_stats(g)
      println("  节点数: \{stats.node_count}")
      println("  边数: \{stats.edge_count}")

      // 重新导出验证
      let exported = @io.graph_to_json(g, true)
      println("\n重新导出:")
      println(exported)
    }
    Err(e) => {
      let err_str = match e {
        IOError::ParseError(msg) => "解析错误: \{msg}"
        IOError::UnsupportedFormat(msg) => "不支持的格式: \{msg}"
        IOError::InvalidData(msg) => "无效数据: \{msg}"
      }
      println("解析失败: \{err_str}")
    }
  }
}

/// 主函数
fn main {
  export_dot_example()
  export_json_example()
  graph_stats_example()
  parse_dot_example()
  parse_json_example()
}
