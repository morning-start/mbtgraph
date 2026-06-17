# Getting Started 快速入门

> **mbtgraph** — MoonBit 生态首个生产级图算法库

## 安装

在 `moon.pkg.json` 中添加依赖：

```json
{
  "import": ["morning-start/mbtgraph"]
}
```

---

## 核心概念

### 节点与边

```moonbit
import "morning-start/mbtgraph/lib/core" as @core

// NodeId: 节点唯一标识符（整数索）
let n0 = @core.NodeId(0)

// Node: 带数据的节点
let node = { id: n0, data: 1.0 }

// Edge: 带数据的边
let edge = { from: n0, to: @core.NodeId(1), data: 2.5 }
```

### Trait 分层

```
GraphReadable     ← 所有存储都实现
├── GraphWritable ← 动态存储（邻接表/矩阵）
├── GraphDirected ← 有向图扩展
│   └── GraphFull = Writable + Directed
└── GraphBatchReadable ← CSR/CSC 专属
```

---

## 快速示例

### 1. 创建图并添加数据

```moonbit
import "morning-start/mbtgraph/lib/storage" as @storage
import "morning-start/mbtgraph/lib/core" as @core

// 创建有向邻接表
let g = @storage.new_directed()

// 添加节点（返回 NodeId）
let n0 = @core.GraphWritable::add_node(g, 0.0)
let n1 = @core.GraphWritable::add_node(g, 1.0)
let n2 = @core.GraphWritable::add_node(g, 2.0)

// 添加边（权重）
let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)
let _ = @core.GraphWritable::add_edge(g, n1, n2, 2.0)
let _ = @core.GraphWritable::add_edge(g, n0, n2, 5.0)
```

### 2. 图遍历

```moonbit
import "morning-start/mbtgraph/lib/algo/traversal" as @traversal

// BFS 遍历
let result = @traversal.bfs(g, n0)

// 检查节点是否访问
if result.is_visited(n2) {
  // 获取最短路径
  let path = result.path_to(n2)
  // path = [n0, n1, n2]
}

// 获取距离
let dist = result.distance(n2)  // 2
```

### 3. 最短路径

```moonbit
import "morning-start/mbtgraph/lib/algo/shortest_path" as @shortest_path

// Dijkstra 单源最短路径
let sp = @shortest_path.dijkstra(g, n0)

// 获取到目标节点的距离
let dist = sp.distance_to(n2)  // 3.0

// 重建路径
let path = sp.path_to(n2)  // [n0, n1, n2]

// 检查可达性
if sp.is_reachable(n2) {
  println("Path found!")
}
```

### 4. 无向图

```moonbit
// 创建无向邻接表
let ug = @storage.new_undirected()

let a = @core.GraphWritable::add_node(ug, 0.0)
let b = @core.GraphWritable::add_node(ug, 1.0)
let _ = @core.GraphWritable::add_edge(ug, a, b, 1.0)

// 无向图的邻居查询返回双向
let neighbors_a = @core.GraphReadable::neighbors(ug, a)  // [b]
let neighbors_b = @core.GraphReadable::neighbors(ug, b)  // [a]
```

---

## 常用操作速查

### 节点操作

```moonbit
// 添加节点
let id = @core.GraphWritable::add_node(g, data)

// 检查节点存在
let exists = @core.GraphReadable::contains_node(g, id)

// 获取节点数据
let data = @core.GraphReadable::get_node(g, id)  // Double?

// 删除节点
let removed = @core.GraphWritable::remove_node(g, id)

// 节点数量
let count = @core.GraphReadable::node_count(g)
```

### 边操作

```moonbit
// 添加边
let result = @core.GraphWritable::add_edge(g, from, to, weight)
// result: Result[Unit, GraphError]

// 检查边存在
let exists = @core.GraphReadable::contains_edge(g, from, to)

// 获取边权重
let weight = @core.GraphReadable::get_edge(g, from, to)  // Double?

// 删除边
let removed = @core.GraphWritable::remove_edge(g, from, to)

// 边数量
let count = @core.GraphReadable::edge_count(g)
```

### 遍历操作

```moonbit
// 获取邻居
let neighbors = @core.GraphReadable::neighbors(g, node_id)  // Iter[NodeId]

// 获取邻居及权重
let neighbors_w = @core.GraphReadable::neighbors_with_weight(g, node_id)

// 获取节点度数
let deg = @core.GraphReadable::degree(g, node_id)

// 迭代所有节点
for nid in @core.GraphReadable::node_ids(g) {
  // 处理节点
}

// 迭代所有边
for (from, to, weight) in @core.GraphReadable::edges(g) {
  // 处理边
}
```

---

## 错误处理

```moonbit
// 添加边可能失败
match @core.GraphWritable::add_edge(g, n0, n1, 1.0) {
  Ok(()) => println("Edge added")
  Err(@core.GraphError::NodeNotFound(nid)) => println("Node \{nid} not found")
  Err(@core.GraphError::EdgeAlreadyExists(f, t)) => println("Edge \{f}->\{t} exists")
  Err(_) => println("Other error")
}
```

---

## 下一步

- [算法选择指南](algorithm_guide.md) — 何时用什么算法
- [存储类型选择](storage_guide.md) — 选择合适的存储实现
- [API Reference](../api/README.md) — 完整 API 文档
