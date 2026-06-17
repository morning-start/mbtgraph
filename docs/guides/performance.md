# 性能优化技巧

> 提升 mbtgraph 算法性能的最佳实践。

---

## 存储优化

### 选择合适的存储

```moonbit
// ❌ 默认选择（可能不是最优）
let g = @storage.new_directed()

// ✅ 根据场景选择
// 稀疏图 → AdjList
let g = @storage.new_directed()

// 稠密图 → Matrix
let g = @storage.new_directed_matrix(capacity)

// 大规模静态图 → CSR
let csr = @storage.to_csr(g)
```

### 批量操作

```moonbit
// ❌ 逐个添加边
let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)
let _ = @core.GraphWritable::add_edge(g, n1, n2, 2.0)
let _ = @core.GraphWritable::add_edge(g, n2, n3, 3.0)

// ✅ 使用批量添加
let edges = [(n0, n1, 1.0), (n1, n2, 2.0), (n2, n3, 3.0)]
let _ = @storage.DirectedAdjList::add_edges_batch(g, edges)

// ✅ 使用 CSR 批量查询
let neighbors = @core.GraphBatchReadable::batch_neighbors(csr, [n0, n1, n2])
```

### 预分配容量

```moonbit
// ❌ 动态扩容
let g = @storage.new_directed()

// ✅ 预分配（已知规模时）
let g = @storage.new_directed_matrix(1000)  // 预分配 1000 节点
```

---

## 算法优化

### 预计算复用

```moonbit
// ❌ 重复计算
let sp1 = @shortest_path.floyd_warshall(g)
let sp2 = @shortest_path.floyd_warshall(g)  // 重复！

// ✅ 预计算一次，多次查询
let fw = @shortest_path.floyd_warshall(g)
let dist_a = fw.distance(n0, n1)
let dist_b = fw.distance(n2, n3)
```

### 选择合适算法

```moonbit
// ❌ 用复杂算法解决简单问题
let sp = @shortest_path.floyd_warshall(g)  // O(V³)

// ✅ 根据需求选择
// 单源最短路径
let sp = @shortest_path.dijkstra(g, source)  // O((V+E)logV)

// 两节点间最短路径
let path = @shortest_path.dijkstra_targeted(g, source, target)

// 无权图最短路径
let path = @traversal.bfs_shortest_path(g, source, target)  // O(V+E)
```

### 避免不必要的转换

```moonbit
// ❌ 频繁转换
for node in nodes {
  let adj = @storage.to_directed_adj_list(g)  // 每次循环都转换！
  // 处理...
}

// ✅ 一次转换
let adj = @storage.to_directed_adj_list(g)
for node in nodes {
  // 使用 adj
}
```

---

## 内存优化

### 使用 UndirectedAdjList

```moonbit
// ❌ 无向图用有向存储
let g = @storage.new_directed()  // 存储双向边，空间翻倍

// ✅ 专用无向存储
let g = @storage.new_undirected()  // 半存储，节省 50%
```

### 只读场景用 CSR

```moonbit
// ❌ 动态存储用于只读分析
let g = @storage.new_directed()
// ... 构建图
let result = @pagerank.pagerank(g, ...)  // 频繁遍历

// ✅ 转为 CSR 优化遍历
let csr = @storage.to_csr(g)
let result = @pagerank.pagerank(csr, ...)  // 缓存友好
```

---

## 并行化提示

### 独立计算

```moonbit
// 可并行的任务
let result1 = @shortest_path.dijkstra(g, source1)
let result2 = @shortest_path.dijkstra(g, source2)
// 两个计算相互独立，可并行
```

### 批量查询

```moonbit
// ❌ 逐个查询
for node in nodes {
  let sp = @shortest_path.dijkstra(g, node)
  // 处理...
}

// ✅ CSR 批量查询
let neighbors = @core.GraphBatchReadable::batch_neighbors(csr, nodes)
```

---

## 性能基准

### 常见操作耗时参考

| 操作 | 1K 节点 | 10K 节点 | 100K 节点 |
|------|---------|----------|-----------|
| BFS | < 1ms | ~5ms | ~50ms |
| Dijkstra | < 1ms | ~10ms | ~100ms |
| Floyd-Warshall | ~10ms | ~10s | N/A |
| PageRank | < 1ms | ~10ms | ~100ms |
| Louvain | < 1ms | ~5ms | ~50ms |

### 复杂度速查

| 算法 | 时间复杂度 | 适用规模 |
|------|-----------|---------|
| BFS/DFS | O(V+E) | 通用 |
| Dijkstra | O((V+E)logV) | 非负权图 |
| Floyd-Warshall | O(V³) | V < 1000 |
| Kruskal | O(ElogE) | 稀疏图 |
| Prim | O((V+E)logV) | 稠密图 |
| Dinic | O(V²E) | 网络流 |
| Louvain | O(nlogn) | 社区检测 |

---

## 调试技巧

### 验证图结构

```moonbit
// 检查图统计
let stats = @io.basic_stats(g)
println("Nodes: \{stats.node_count}")
println("Edges: \{stats.edge_count}")
println("Density: \{stats.density}")

// 检查连通性
let cc = @connectivity.connected_components(g)
println("Components: \{cc.count()}")
```

### 性能分析

```moonbit
// 使用 Bench 模块（如有）
// lib/bench/ 提供性能测试工具
```

---

## 常见陷阱

### 1. 忽略深拷贝

```moonbit
// ❌ 直接修改输入
let result = some_algorithm(g, ...)  // g 可能被修改

// ✅ 深拷贝后操作
let g_copy = @storage.to_directed_adj_list(g)
let result = some_algorithm(g_copy, ...)
```

### 2. 链式赋值

```moonbit
// ❌ 忽略返回值
@core.GraphWritable::add_edge(g, n0, n1, 1.0)  // 警告！

// ✅ 消费返回值
let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)

// ✅ 链式调用
let net = FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)
```

### 3. 错误处理

```moonbit
// ❌ 忽略错误
let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)

// ✅ 处理错误
match @core.GraphWritable::add_edge(g, n0, n1, 1.0) {
  Ok(()) => ()
  Err(e) => handle_error(e)
}
```
