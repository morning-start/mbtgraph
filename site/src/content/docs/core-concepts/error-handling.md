---
title: 错误处理机制
description: GraphError 错误类型详解、Result 处理模式、常见错误场景及调试技巧
---

# 错误处理机制

mbtgraph 使用 MoonBit 的 `Result[T, E]` 类型统一处理图操作中可能出现的错误。理解错误处理模式是编写健壮图应用的关键。

---

## 一、GraphError 类型

所有图操作错误都通过 `GraphError` 枚举表示，定义在 `lib/core/error.mbt`：

```moonbit
pub(all) enum GraphError {
  /// 节点不存在（携带无效的节点 ID）
  NodeNotFound(NodeId)
  /// 边已存在（携带冲突的边端点）
  EdgeAlreadyExists(NodeId, NodeId)
  /// 节点 ID 无效（如负数或超出范围）
  InvalidNodeId
} derive(Debug, Eq)
```

| 变体 | 含义 | 触发场景 |
|------|------|---------|
| `NodeNotFound(n)` | 节点 `n` 不存在 | `add_edge` 的起点/终点不存在 |
| `EdgeAlreadyExists(u,v)` | 边 `(u,v)` 已存在 | 重复添加已存在的边 |
| `InvalidNodeId` | 节点 ID 无效 | 传入负数或超出范围的 `NodeId` |

---

## 二、哪些操作会返回错误？

主要来自 `GraphWritable` trait 中的 `add_edge` 方法：

```moonbit
pub(open) trait GraphWritable: GraphReadable {
  fn add_node(Self, Double) -> NodeId                    // 不会失败
  fn remove_node(Self, NodeId) -> Bool                   // 返回 false 表示不存在
  fn add_edge(Self, NodeId, NodeId, Double) -> Result[Unit, GraphError]  // ⚠️ 可能失败
  fn remove_edge(Self, NodeId, NodeId) -> Bool           // 返回 false 表示不存在
  fn clear(Self) -> Unit                                 // 不会失败
}
```

只有 `add_edge` 返回 `Result`——因为建边时可能出现两种特有的错误（节点不存在、边重复）。

其他只读操作（`get_node`, `get_edge` 等）返回 `Option`，用 `None` 表示不存在。

---

## 三、基本处理模式

### 3.1 match 完整处理

最安全的做法，覆盖所有错误分支：

```moonbit
let result = @core.GraphWritable::add_edge(graph, a, b, 5.0)
match result {
  Ok(_) => println("✅ 边添加成功")
  Err(e) => match e {
    @core.GraphError::NodeNotFound(n) =>
      println("❌ 节点 \(n.0) 不存在，请先添加节点")
    @core.GraphError::EdgeAlreadyExists(u, v) =>
      println("⚠️ 边 (\(u.0), \(v.0)) 已存在，跳过")
    @core.GraphError::InvalidNodeId =>
      println("❌ 无效的节点 ID")
  }
}
```

### 3.2 忽略成功结果

当你确定操作不会失败，或者不想处理具体错误时：

```moonbit
// 简单忽略（仅丢弃 Ok，Err 时程序会 panic）
let _ = @core.GraphWritable::add_edge(graph, a, b, 5.0)

// 更安全：输出警告但不中断
let _ = match @core.GraphWritable::add_edge(graph, a, b, 5.0) {
  Ok(_) => ()
  Err(e) => println("警告: \(e)")
}
```

### 3.3 链式批量操作

批量添加边时，推荐逐条处理错误，避免一条错误导致整个批量失败：

```moonbit
let edges = [(a, b, 1.0), (b, c, 2.0), (c, a, 3.0)]
let mut success_count = 0
let mut error_count = 0

for (from, to, weight) in edges {
  match @core.GraphWritable::add_edge(graph, from, to, weight) {
    Ok(_) => success_count = success_count + 1
    Err(e) => {
      println("边 (\(from.0)→\(to.0)) 添加失败: \(e)")
      error_count = error_count + 1
    }
  }
}
println("成功: \(success_count), 失败: \(error_count)")
```

---

## 四、常见错误场景

### 场景 1：重复添加边

```moonbit
let mut graph = @storage.DirectedAdjList::new()
let a = @core.GraphWritable::add_node(graph, 0.0)
let b = @core.GraphWritable::add_node(graph, 0.0)

let _ = @core.GraphWritable::add_edge(graph, a, b, 5.0)  // ✅ 首次成功

let result = @core.GraphWritable::add_edge(graph, a, b, 5.0)  // ⚠️ 重复
match result {
  Err(@core.GraphError::EdgeAlreadyExists(u, v)) =>
    println("边 (\(u.0), \(v.0)) 已存在")
  _ => ()
}
```

**处理策略：** 如果你的业务语义允许重复添加（如同一条边看作"更新权重"），可以先用 `contains_edge` 检查：

```moonbit
if @core.GraphReadable::contains_edge(graph, a, b) {
  // 先删除再添加（更新权重）
  let _ = @core.GraphWritable::remove_edge(graph, a, b)
}
let _ = @core.GraphWritable::add_edge(graph, a, b, 5.0)
```

或者使用 `add_edge_unchecked`（跳过查重，需确保不会重复）：

```moonbit
let _ = graph.add_edge_unchecked(a, b, 5.0)  // 无查重，更快
```

### 场景 2：节点不存在

```moonbit
let mut graph = @storage.DirectedAdjList::new()
let a = @core.GraphWritable::add_node(graph, 0.0)

// 节点 b 未添加，直接使用无效的 NodeId
let invalid_node = @core.NodeId(99)
let result = @core.GraphWritable::add_edge(graph, a, invalid_node, 5.0)
match result {
  Err(@core.GraphError::NodeNotFound(n)) =>
    println("节点 \(n.0) 不存在")
  Err(@core.GraphError::InvalidNodeId) =>
    println("节点 ID 无效")
  _ => ()
}
```

**处理策略：** 在添加边之前检查节点是否存在：

```moonbit
fn safe_add_edge(
  graph,
  from : @core.NodeId,
  to : @core.NodeId,
  weight : Double,
) -> Result[Unit, String] {
  // 先验证节点是否存在
  if !@core.GraphReadable::contains_node(graph, from) {
    return Err("起点节点 \(from.0) 不存在")
  }
  if !@core.GraphReadable::contains_node(graph, to) {
    return Err("终点节点 \(to.0) 不存在")
  }
  // 再执行添加
  match @core.GraphWritable::add_edge(graph, from, to, weight) {
    Ok(_) => Ok(())
    Err(e) => Err("添加失败: \(e)")
  }
}
```

### 场景 3：无效的 NodeId

```moonbit
let negative_id = @core.NodeId(-1)
let result = @core.GraphWritable::add_edge(graph, negative_id, a, 5.0)
// → Err(GraphError::InvalidNodeId)
```

**处理策略：** 使用 `contains_node` 前置校验可以有效避免此错误（因为不存在的节点自然会触发 `NodeNotFound` 而非 `InvalidNodeId`）。

---

## 五、Option 类型操作

只读操作使用 `Option` 而非 `Result` 表示可能的不存在：

```moonbit
// get_node：返回 Option[Double]
let data = @core.GraphReadable::get_node(graph, node)
match data {
  Some(v) => println("节点数据: \(v)")
  None => println("节点不存在")
}

// get_edge：返回 Option[Double]
let weight = @core.GraphReadable::get_edge(graph, a, b)
match weight {
  Some(w) => println("边权重: \(w)")
  None => println("边不存在或节点不存在")
}
```

| 函数 | 返回类型 | 不存在时 |
|------|:--------:|:--------:|
| `get_node(g, n)` | `Double?` | `None` |
| `get_edge(g, u, v)` | `Double?` | `None` |
| `contains_node(g, n)` | `Bool` | `false` |
| `contains_edge(g, u, v)` | `Bool` | `false` |

---

## 六、调试技巧

### 6.1 使用 Debug 打印错误

`GraphError` 实现了 `Debug`，可以直接用 `println` 打印：

```moonbit
match @core.GraphWritable::add_edge(graph, a, b, 5.0) {
  Err(e) => println("调试: add_edge 失败, error=\(e)")
  _ => ()
}
// 输出: 调试: add_edge 失败, error=EdgeAlreadyExists(NodeId(0), NodeId(1))
```

### 6.2 批量操作中的错误收集

```moonbit
let mut errors : Array[String] = []
let edges = [(0, 1, 1.0), (1, 2, 2.0), (0, 2, 3.0)]

for (f, t, w) in edges {
  let from = @core.NodeId(f)
  let to = @core.NodeId(t)
  if !@core.GraphReadable::contains_node(graph, from) {
    errors.push("节点 \(f) 不存在")
    continue
  }
  if !@core.GraphReadable::contains_node(graph, to) {
    errors.push("节点 \(t) 不存在")
    continue
  }
  match @core.GraphWritable::add_edge(graph, from, to, w) {
    Ok(_) => ()
    Err(e) => errors.push("边 (\(f)→\(t)): \(e)")
  }
}

if errors.length() > 0 {
  println("共 \(errors.length()) 个错误:")
  for err in errors { println("  - \(err)") }
}
```

### 6.3 在算法中处理空图

```moonbit
// BFS 在空图上返回空结果而非 panic
let bfs_result = @traversal.bfs(graph, start)
// bfs_result.visit_order 在空图上为空数组
```

---

## 七、错误处理最佳实践

| 场景 | 推荐做法 |
|------|---------|
| 原型/脚本 | `let _ = add_edge(...)` 快速开发 |
| 生产代码 | `match` 全分支处理 |
| 批量建图 | 收集错误 + 前置验证 |
| 更新权重 | 先 `contains_edge` 检查，再 `remove_edge` + `add_edge` |
| 大数据量 | 用 `add_edge_unchecked`（需自行保证无重复） |
| Trait 泛型 | `Result[Unit, GraphError]` 兼容所有存储类型 |

---

**相关文档：**
- [节点与边的表示](/core-concepts/data-types/)
- [5 层 Trait 详解](/core-concepts/traits/)
- [API 参考 - Core 模块](/api/core/)
- [图的读写操作](/core-concepts/graph-operations/)
