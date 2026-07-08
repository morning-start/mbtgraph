---
title: I/O 与序列化模块设计
description: DOT/JSON 序列化与图统计工具的设计决策
---

> **模块**: `lib/io/` | **状态**: ✅ 4 个序列化 + 6 个统计函数

---

## 1. 架构设计

### 1.1 模块划分

```
lib/io/
├── dot.mbt              — DOT 格式序列化/反序列化
├── json_serializer.mbt  — JSON 格式序列化/反序列化
├── graph_stats.mbt      — 图统计与度量工具
├── types.mbt            — IOError + 统计结果类型
├── io_test.mbt          — 集成测试
└── moon.pkg
```

### 1.2 双轨序列化

```
Graph → String (write_dot / graph_to_json)
String → Result[UndirectedAdjList, IOError] (parse_dot_into / parse_json_into)
```

反序列化结果统一为 UndirectedAdjList，确保最大兼容性。

---

## 2. 设计决策

### DDR-01: DOT 解析器手写递归下降

| 方案 | 优势 | 劣势 |
|------|------|------|
| **手写递归下降** ⭐ | 零依赖，完全控制 | 维护成本 |
| 正则表达式 | 简单直接 | 嵌套结构无法处理 |
| 第三方库 | 功能完善 | 引入外部依赖 |

选择手写递归下降，不引入外部依赖。

### DDR-02: JSON 序列化对齐 Graphviz 标准

- 节点：`{"data": {"id": "0", "weight": 0.5}}`
- 边：`{"data": {"source": "0", "target": "1", "weight": 1.0}}`
- 完全兼容 Cytoscape.js 等前端可视化库

### DDR-03: 图统计返回值

```moonbit
pub(all) struct GraphStats {
  node_count : Int
  edge_count : Int
  density : Double
  is_directed : Bool
  is_connected : Bool
}
```

---

## 3. API 速查

```moonbit
// DOT 序列化
let dot = @io.write_dot(g, "my_graph")
println(dot)

// DOT 反序列化
let result = @io.parse_dot_into(graph, dot_string)
match result {
  Ok(g) => // 使用图
  Err(e) => println("Parse error: \{e}")
}

// JSON 序列化
let json = @io.graph_to_json(g, true)  // 格式化输出

// JSON 反序列化
let g = @io.parse_json_into(json_string) |>  // Result

// 图统计
let stats = @io.basic_stats(g)
println("Density: \{stats.density}")

// 度分布
let dist = @io.degree_distribution(g)
```
