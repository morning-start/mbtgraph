# I/O API Reference

> **包名**: `morning-start/mbtgraph/lib/io`
> **路径**: `lib/io/`

## 概述

I/O 模块提供图的序列化/反序列化功能（DOT/JSON 格式）和图统计分析工具。

---

## 序列化函数

### write_dot

```moonbit
pub fn[G : @core.GraphReadable] write_dot(G, String) -> String
```

将图导出为 DOT 格式字符串。

**参数**:
- `G`: 图实例
- `String`: 图名称

**返回**: DOT 格式字符串

---

### graph_to_json

```moonbit
pub fn[G : @core.GraphReadable] graph_to_json(G, Bool) -> String
```

将图导出为 JSON 格式字符串。

**参数**:
- `G`: 图实例
- `Bool`: 是否格式化输出

**返回**: JSON 格式字符串

---

## 反序列化函数

### parse_dot_into

```moonbit
pub fn[G : @core.GraphWritable] parse_dot_into(G, String) -> Result[Unit, IOError]
```

解析 DOT 格式字符串并填充到图中。

**参数**:
- `G`: 可写图实例
- `String`: DOT 格式字符串

**返回**: `Result[Unit, IOError]`

---

### parse_json_into

```moonbit
pub fn[G : @core.GraphWritable] parse_json_into(G, String) -> Result[Unit, IOError]
```

解析 JSON 格式字符串并填充到图中。

**参数**:
- `G`: 可写图实例
- `String`: JSON 格式字符串

**返回**: `Result[Unit, IOError]`

---

## 图统计函数

### basic_stats

```moonbit
pub fn[G : @core.GraphReadable] basic_stats(G) -> GraphStats
```

获取图的基本统计信息。

**返回**: `GraphStats`

```moonbit
pub(all) struct GraphStats {
  node_count : Int
  edge_count : Int
  is_directed : Bool
  density : Double
  avg_degree : Double
  min_degree : Int
  max_degree : Int
  self_loop_count : Int
}
```

---

### degree_distribution

```moonbit
pub fn[G : @core.GraphReadable] degree_distribution(G) -> DegreeDistribution
```

获取图的度分布。

**返回**: `DegreeDistribution`

```moonbit
pub(all) struct DegreeDistribution {
  min_degree : Int
  max_degree : Int
  histogram : Array[Int]
}
```

---

### connectivity_stats

```moonbit
pub fn[G : @core.GraphReadable] connectivity_stats(G) -> ConnectivityStats
```

获取图的连通性统计。

**返回**: `ConnectivityStats`

```moonbit
pub(all) struct ConnectivityStats {
  component_count : Int
  largest_component_size : Int
  component_sizes : Array[Int]
}
```

---

### distance_metrics

```moonbit
pub fn[G : @core.GraphReadable] distance_metrics(G) -> DistanceMetrics
```

获取图的距离指标。

**返回**: `DistanceMetrics`

```moonbit
pub(all) struct DistanceMetrics {
  diameter : Int
  radius : Int
  wiener_index : Int
  avg_path_length : Double
}
```

---

### network_efficiency

```moonbit
pub fn[G : @core.GraphReadable] network_efficiency(G) -> NetworkEfficiency
```

获取图的网络效率。

**返回**: `NetworkEfficiency`

```moonbit
pub(all) struct NetworkEfficiency {
  global_efficiency : Double
  local_efficiency : Double
}
```

---

### triad_counting

```moonbit
pub fn[G : @core.GraphReadable] triad_counting(G) -> TriadCount
```

统计图中的三元组数量。

**返回**: `TriadCount`

```moonbit
pub(all) struct TriadCount {
  open_triads : Int
  closed_triads : Int
  global_clustering : Double
}
```

---

## 错误类型

### IOError

```moonbit
pub(all) enum IOError {
  ParseError(String)
  UnsupportedFormat(String)
  InvalidData(String)
}
pub fn IOError::to_string(Self) -> String
```

**变体**:
- `ParseError(String)`: 解析错误
- `UnsupportedFormat(String)`: 不支持的格式
- `InvalidData(String)`: 无效数据

---

## Token 类型

### DotToken

```moonbit
pub(all) enum DotToken {
  Ident(String)
  Number(Int)
  Arrow
  EdgeOp
  LBrace
  RBrace
  LBracket
  RBracket
  Equals
  Semicolon
  Eof
}
```

DOT 格式词法分析 Token 类型（内部使用）。
