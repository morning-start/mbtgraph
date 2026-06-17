# 常见问题解答

> mbtgraph 使用中的常见问题与解决方案。

---

## 基础问题

### Q: 如何创建图？

```moonbit
// 有向图
let g = @storage.new_directed()

// 无向图
let g = @storage.new_undirected()

// 有向矩阵（预分配容量）
let g = @storage.new_directed_matrix(1000)
```

### Q: 如何添加节点和边？

```moonbit
// 添加节点（返回 NodeId）
let n0 = @core.GraphWritable::add_node(g, 0.0)
let n1 = @core.GraphWritable::add_node(g, 1.0)

// 添加边（权重）
let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)

// 批量添加边
let edges = [(n0, n1, 1.0), (n1, n2, 2.0)]
let _ = @storage.DirectedAdjList::add_edges_batch(g, edges)
```

### Q: 如何遍历图？

```moonbit
// 遍历所有节点
for nid in @core.GraphReadable::node_ids(g) {
  println("Node: \{nid}")
}

// 遍历所有边
for (from, to, weight) in @core.GraphReadable::edges(g) {
  println("\{from} -> \{to}: \{weight}")
}

// 获取邻居
let neighbors = @core.GraphReadable::neighbors(g, node_id)
for nid in neighbors {
  // 处理邻居
}
```

---

## 算法问题

### Q: 如何选择最短路径算法？

| 场景 | 算法 | 代码 |
|------|------|------|
| 非负权图 | Dijkstra | `@shortest_path.dijkstra(g, source)` |
| 有负权图 | Bellman-Ford | `@shortest_path.bellman_ford(g, source)` |
| 全源最短路径 | Floyd-Warshall | `@shortest_path.floyd_warshall(g)` |
| 启发式搜索 | A* | `@shortest_path.a_star(g, start, goal, h)` |

### Q: 如何检测环？

```moonbit
// 自动选择有向/无向检测
let has_cycle = @traversal.has_cycle(g)

// 明确指定
let has_cycle = @traversal.has_directed_cycle(g)      // 有向图
let has_cycle = @traversal.has_undirected_cycle(g)    // 无向图
```

### Q: 如何进行拓扑排序？

```moonbit
// Kahn 算法（BFS）
match @traversal.topo_sort_kahn(g) {
  Ok(order) => println("Topological order: \{order}")
  Err(msg) => println("Graph has cycle: \{msg}")
}

// DFS 算法
match @traversal.topo_sort_dfs(g) {
  Ok(order) => // 处理
  Err(msg) => // 有环
}
```

---

## 存储问题

### Q: 如何选择存储类型？

```
通用场景 → DirectedAdjList / UndirectedAdjList
稠密图 → DirectedMatrix
大规模静态图 → CSR
入边查询 → CSC
MST 算法 → EdgeList
```

### Q: 如何转换存储类型？

```moonbit
// 动态 → 静态
let csr = @storage.to_csr(g)

// 有向 → 无向
let ug = @storage.as_undirected(g)

// 无向 → 有向（双向）
let dg = @storage.as_directed(ug)
```

### Q: CSR 有什么优势？

- 内存连续，缓存友好
- 支持批量查询 `batch_neighbors`
- 适合大规模静态图
- 构建后不可修改（保证纯函数语义）

---

## 错误处理

### Q: 添加边失败怎么办？

```moonbit
match @core.GraphWritable::add_edge(g, n0, n1, 1.0) {
  Ok(()) => println("Success")
  Err(@core.GraphError::NodeNotFound(nid)) => {
    println("Node \{nid} not found")
    // 先添加节点
  }
  Err(@core.GraphError::EdgeAlreadyExists(f, t)) => {
    println("Edge \{f}->\{t} already exists")
    // 跳过或更新
  }
  Err(e) => println("Other error: \{e}")
}
```

### Q: 如何处理不可达节点？

```moonbit
let sp = @shortest_path.dijkstra(g, source)

// 检查可达性
if sp.is_reachable(target) {
  let path = sp.path_to(target)
  // 处理路径
} else {
  println("Target not reachable")
}

// 获取距离（不可达返回 infinity）
let dist = sp.distance_to(target)
```

---

## 性能问题

### Q: 如何提升性能？

1. **选择合适的存储**: AdjList vs Matrix vs CSR
2. **预计算**: Floyd-Warshall 预计算后 O(1) 查询
3. **批量操作**: 使用 `add_edges_batch` 和 `batch_neighbors`
4. **避免转换**: 减少不必要的存储类型转换

### Q: 大规模图怎么处理？

```moonbit
// 1. 使用 CSR 存储
let csr = @storage.to_csr(g)

// 2. 使用批量查询
let neighbors = @core.GraphBatchReadable::batch_neighbors(csr, node_ids)

// 3. 选择高效算法
let result = @pagerank.pagerank(csr, 0.85, 100, 1e-6)
```

---

## 纯函数语义

### Q: 为什么算法不修改输入图？

mbtgraph 所有算法保证**输入不可变**：

```moonbit
let g = @storage.new_directed()
// ... 构建图
let original_edges = @core.GraphReadable::edge_count(g)

let result = some_algorithm(g, ...)

// g 不变
let current_edges = @core.GraphReadable::edge_count(g)
assert(original_edges == current_edges)
```

### Q: 如何修改图？

```moonbit
// 显式调用可写方法
let _ = @core.GraphWritable::add_node(g, data)
let _ = @core.GraphWritable::add_edge(g, from, to, weight)
let _ = @core.GraphWritable::remove_node(g, node_id)
let _ = @core.GraphWritable::remove_edge(g, from, to)
```

---

## 调试技巧

### Q: 如何验证图结构？

```moonbit
// 基本统计
let stats = @io.basic_stats(g)
println("Nodes: \{stats.node_count}")
println("Edges: \{stats.edge_count}")
println("Density: \{stats.density}")

// 连通性
let cc = @connectivity.connected_components(g)
println("Components: \{cc.count()}")

// 度分布
let dist = @io.degree_distribution(g)
println("Max degree: \{dist.max_degree}")
```

### Q: 如何导出图？

```moonbit
// DOT 格式
let dot = @io.write_dot(g, "my_graph")
println(dot)

// JSON 格式
let json = @io.graph_to_json(g, true)  // true = 格式化
println(json)
```

---

## 更多资源

- [API Reference](../api/README.md) — 完整 API 文档
- [Getting Started](getting_started.md) — 快速入门
- [Algorithm Guide](algorithm_guide.md) — 算法选择
- [Storage Guide](storage_guide.md) — 存储选型
