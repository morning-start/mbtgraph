---
title: IO 模块接口
description: DOT 格式读写、JSON 序列化与反序列化、图统计工具的函数签名
---

# IO 模块接口

> 模块路径: `lib/io/` · 文件: `dot.mbt`, `json_serializer.mbt`, `graph_stats.mbt`, `types.mbt`

---

## 一、DOT 格式读写 (dot.mbt)

兼容 Graphviz 的 DOT 格式，支持有向图 (`digraph`) 和无向图 (`graph`)。

```moonbit
// 将图序列化为 DOT 格式字符串
pub fn[G : @core.GraphReadable] write_dot(graph : G, graph_name : String) -> String

// 从 DOT 字符串解析构建到图中
pub fn[G : @core.GraphWritable] parse_dot_into(graph : G, dot_string : String) -> Result[Unit, IOError]
```

### 使用示例

```moonbit
// 导出
let dot = @io.write_dot(my_graph, "my_graph")
// 输出示例:
// digraph my_graph {
//     0 -> 1 [label="2.5"]
//     1 -> 2 [label="3.0"]
// }

// 导入
match @io.parse_dot_into(graph, dot) {
  Ok(_) => println("导入成功")
  Err(e) => println("导入失败: \(e)")
}
```

---

## 二、JSON 序列化 (json_serializer.mbt)

通用 JSON 格式，可直接被 Web 前端（如 Cytoscape.js）消费。

```moonbit
// 将图序列化为 JSON 格式字符串
pub fn[G : @core.GraphReadable] graph_to_json(graph : G, pretty : Bool) -> String

// 从 JSON 字符串解析并构建到图中
pub fn[G : @core.GraphWritable] parse_json_into(graph : G, json_string : String) -> Result[Unit, IOError]
```

### JSON 输出格式

```json
{
  "directed": true,
  "node_count": 5,
  "edge_count": 7,
  "nodes": [
    {"id": 0, "data": 1.0},
    {"id": 1, "data": 2.0}
  ],
  "edges": [
    {"from": 0, "to": 1, "data": 2.5},
    {"from": 1, "to": 2, "data": 3.0}
  ]
}
```

---

## 三、图统计工具 (graph_stats.mbt)

```moonbit
// 基本统计信息
pub fn[G : @core.GraphReadable] basic_stats(graph : G) -> GraphStats
// 度分布直方图
pub fn[G : @core.GraphReadable] degree_distribution(graph : G) -> DegreeDistribution
// 连通分量统计
pub fn[G : @core.GraphReadable] connectivity_stats(graph : G) -> ConnectivityStats
```

### GraphStats 字段

| 字段 | 类型 | 说明 |
|------|:----:|------|
| `node_count` | `Int` | 节点数 |
| `edge_count` | `Int` | 边数 |
| `directed` | `Bool` | 是否有向 |
| `avg_degree` | `Double` | 平均度 |
| `density` | `Double` | 图密度 |

### 进阶统计

```moonbit
// 直径 / 半径 / Wiener 指数 / 平均路径长度
pub fn[G : @core.GraphReadable] distance_metrics(graph : G) -> DistanceMetrics

// 三元组计数 + 全局聚类系数
pub fn[G : @core.GraphReadable] triad_counting(graph : G) -> TriadCount

// 网络效率（全局 + 局部）
pub fn[G : @core.GraphReadable] network_efficiency(graph : G) -> NetworkEfficiency
```

---

## 四、错误类型 (types.mbt)

```moonbit
pub(all) enum IOError {
  ParseError(String)
  UnsupportedFormat(String)
} derive(Debug, Eq)
```

| 变体 | 含义 |
|------|------|
| `ParseError(msg)` | 解析失败（格式错误） |
| `UnsupportedFormat(msg)` | 不支持的格式 |

---

## 五、完整使用示例

```moonbit
fn main {
  let mut g = @storage.DirectedAdjList::new()
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let _ = @core.GraphWritable::add_edge(g, n1, n2, 5.0)

  // DOT 导出
  println(@io.write_dot(g, "example"))

  // JSON 导出（格式化）
  println(@io.graph_to_json(g, true))

  // 图统计
  let s = @io.basic_stats(g)
  println("节点:\(s.node_count) 边:\(s.edge_count) 密度:\(s.density)")
}
```

---

**相关文档：**
- [Core 模块接口](/api/core/)
- [Storage 模块接口](/api/storage/)
- [各算法模块 API](/api/algorithms/)
- [序列化与反序列化](/core-concepts/serialization/)
