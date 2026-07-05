---
title: 存储转换器使用
description: 在不同图存储结构之间使用泛型转换函数安全转换，涵盖有向/无向互转和动态/静态转换
---

# 存储转换器使用

> **位置**: `lib/storage/converter.mbt` · 10 个泛型转换函数 \
> **前置**: [8 种存储对比表](/core-concepts/storage-guide/)

---

## 一、为什么需要转换器？

不同的图算法对存储结构有不同的需求：

| 阶段 | 推荐存储 | 原因 |
|------|---------|------|
| **构建** | `DirectedAdjList` | 支持动态增删，灵活 |
| **遍历/最短路径** | `DirectedAdjList` | neighbors 查询快 |
| **Kruskal MST** | `EdgeList` | 需要 `sorted_edges` |
| **大规模静态计算** | `CSR` | 内存紧凑，缓存友好 |
| **稠密小图** | `Matrix` | O(1) 边查询 |

转换器让你可以在不同阶段使用不同的存储，而不需要重新建图。

---

## 二、转换函数一览

### 有向图转换组（编译期保证）

需要源图实现 `GraphDirected` trait，编译期确保只能传入有向图。

| 函数 | 目标 | 额外参数 |
|------|:----:|:--------:|
| `to_directed_adj_list(g)` | `DirectedAdjList` | — |
| `to_directed_matrix(g, cap)` | `DirectedMatrix` | `cap`: 矩阵容量 |
| `to_csr(g)` | `CSRGraph` | — |
| `to_csc(g)` | `CSCGraph` | — |
| `to_edge_list(g)` | `EdgeListGraph` | — |

```moonbit
// 泛型约束: G : GraphDirected
let adj = @converter.to_directed_adj_list(my_directed_graph)
let csr = @converter.to_csr(my_directed_graph)
let mat = @converter.to_directed_matrix(my_directed_graph, 1000)
```

### 无向图转换组（运行时保护）

需要源图实现 `GraphReadable`，运行时检查 `is_directed() == false`，否则 panic。

| 函数 | 目标 |
|------|:----:|
| `to_undirected_adj_list(g)` | `UndirectedAdjList` |
| `to_undirected_matrix(g, cap)` | `UndirectedMatrix` |
| `to_undirected_edge_list(g)` | `UndirectedEdgeListGraph` |

```moonbit
// 运行时检查: 如果 g 是有向图则 panic
let uadj = @converter.to_undirected_adj_list(my_undirected_graph)
let umat = @converter.to_undirected_matrix(my_undirected_graph, 500)
```

### 跨语义转换组（显式转换，用户知情）

跨有向/无向边界的转换，需用户明确调用，名字中体现了语义变化。

| 函数 | 源 | → | 目标 | 行为 |
|------|:---:|:-:|:----:|------|
| `as_undirected(g)` | 有向 | → | `UndirectedAdjList` | 有向边→无向边，反向边自动去重 |
| `as_directed(g)` | 无向 | → | `DirectedAdjList` | 无向边→单条有向边，不生成反向 |

---

## 三、典型场景

### 场景 1：构建 → 算法（AdjList → CSR）

```moonbit
// 阶段 1: 用邻接表动态建图
let mut g = @storage.DirectedAdjList::new()
let a = @core.GraphWritable::add_node(g, 1.0)
let b = @core.GraphWritable::add_node(g, 2.0)
let c = @core.GraphWritable::add_node(g, 3.0)
let _ = @core.GraphWritable::add_edge(g, a, b, 5.0)
let _ = @core.GraphWritable::add_edge(g, b, c, 3.0)
let _ = @core.GraphWritable::add_edge(g, a, c, 8.0)

// 阶段 2: 转为 CSR 做大规模计算
let csr = @converter.to_csr(g)

// CSR 上运行 PageRank
let pr = @pagerank.pagerank(csr, 0.85, 100)
println("Top-1: \(pr.top_nodes(1))")
```

**为什么这样做？** 构建阶段需要动态增删，适合 AdjList。算法阶段需要多次遍历，CSR 缓存友好且内存省 42%。

### 场景 2：Kruskal 需要 EdgeList

```moonbit
// 从任意有向图转为 EdgeList（需要 sorted_edges 方法）
let el = @converter.to_edge_list(directed_graph)
let mst = @mst.kruskal(el)
println("MST 总权重: \(mst.total_weight)")
```

`EdgeList` 实现了 `GraphWritable` trait，适合 Kruskal 等需要全边扫描的场景。

### 场景 3：有向 → 无向（语义转换）

社交网络中的关注关系（有向）转社群检测所需的无向图：

```moonbit
// 关注图是有向的
let mut follow_graph = @storage.DirectedAdjList::new()
// ... 添加关注关系 ...

// 社群检测需要无向图 → 使用 as_undirected 显式转换
let community_graph = @converter.as_undirected(follow_graph)
let communities = @community.louvain(community_graph, 1.0)
println("检测到 \(communities.num_communities) 个社区")
```

> `as_undirected` 处理反向边的方式：如果同时存在 `a→b` 和 `b→a`，只有第一条被保留，第二条被静默跳过（因为无向图中已存在该边）。

### 场景 4：小图快速验证 → Matrix

```moonbit
// 在稠密小图上用矩阵加速边查询
let mat = @converter.to_directed_matrix(small_dense_graph, 100)

// 矩阵的 contains_edge 是 O(1)
let exists = @core.GraphReadable::contains_edge(mat, a, b)
if exists { println("边存在") }
```

---

## 四、转换代价

| 转换 | 时间复杂度 | 空间 | 说明 |
|:----|:----------:|:----:|------|
| AdjList → CSR | O(V+E) | O(V+E) | 拷贝节点+边数据 |
| AdjList → Matrix | O(V+E) | O(V²) | ⚠️ 大图不可行 |
| AdjList → EdgeList | O(V+E) | O(V+E) | 轻量拷贝 |
| 有向 → 无向 | O(V+E) | O(V+E) | 反向边去重检查 |
| Matrix → AdjList | O(V²) | O(V+E) | 扫描整个矩阵 |

> 除了 Matrix 相关的转换，其他转换都是 **O(V+E)** 线性时间，对大多数图来说是秒级操作。

---

## 五、完整工作流示例

```moonbit
fn main {
  // 1. 构建：邻接表
  let mut g = @storage.DirectedAdjList::new()
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 1000]
  for i in 0..<5000 {
    let from = nodes[i % 1000]
    let to = nodes[(i * 7) % 1000]
    let _ = @core.GraphWritable::add_edge(g, from, to, 1.0)
  }

  // 2. 导出 JSON（需要 GraphReadable）
  let json = @io.graph_to_json(g, true)
  println("JSON: \(json.substring(0, 100))...")

  // 3. Kruskal：转 EdgeList
  let el = @converter.to_edge_list(g)
  let mst = @mst.kruskal(el)
  println("MST: \(mst.total_weight)")

  // 4. PageRank：转 CSR 加速
  let csr = @converter.to_csr(g)
  let pr = @pagerank.pagerank(csr, 0.85, 50)
  println("PageRank Top-3: \(pr.top_nodes(3))")
}
```

---

## 六、常见错误与注意事项

| 错误 | 原因 | 修复 |
|:----|:-----|:-----|
| `panic: assertion failed` | 对有向图调用了 `to_undirected_*` | 改用 `as_undirected` 或先确认图是无向的 |
| `EdgeAlreadyExists` | `as_undirected` 中反向边冲突 | 这是预期行为，静默跳过（自动处理） |
| 矩阵过大 | 用 `to_directed_matrix` 转大型图 | 限制矩阵到 ≤ 1000 节点，改用 CSR |

---

**相关文档：**
- [8 种存储对比表](/core-concepts/storage-guide/)
- [场景化选型决策树](/core-concepts/storage-decision/)
- [API 参考 - Storage 模块](/api/storage/)
- [性能基准测试](/core-concepts/benchmarks/)
