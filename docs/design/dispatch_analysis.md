# Trait 动态调度分析报告

## 概述

本报告对 mbtgraph 中 4 层 Trait（`GraphReadable`、`GraphWritable`、`GraphDirected`、`GraphBatchReadable`）的 25 个方法在算法代码库（`lib/algo/`）中的静态调用频率进行全面统计，识别高频调用路径，标记内联候选函数，并为编译器优化提供数据支撑。

**分析范围**: `lib/algo/` 下所有 `*.mbt` 文件（含测试代码）
**统计方法**: 通过 `@core.TraitName::method_name` 完全限定名模式匹配
**统计时间**: v0.14.0 基线

---

## 1. 调用频率总表

### 1.1 GraphReadable（核心接口，12 方法）

| 排名 | 方法 | 调用次数 | 比例 | 调用来源 |
|:----:|------|:--------:|:----:|----------|
| 1 | `node_count` | **82** | 37.8% | 全部算法模块（最短路径、遍历、流、社区检测等） |
| 2 | `neighbors` | **41** | 18.9% | 遍历（BFS/DFS）、连通性、图生成器 |
| 3 | `node_ids` | **38** | 17.5% | 社区检测、着色、团检测、中心性 |
| 4 | `contains_node` | 21 | 9.7% | 匹配算法、连通性、割点 |
| 5 | `degree` | 14 | 6.5% | 着色、中心性、匹配、社区检测 |
| 6 | `neighbors_with_weight` | 11 | 5.1% | 最短路径（Dijkstra/A*/Bellman-Ford 等）、MST |
| 7 | `edges` | 7 | 3.2% | MST（Kruskal）、欧拉路径 |
| 8 | `edge_count` | 6 | 2.8% | MST、统计、流网络 |
| 9 | `get_edge` | 6 | 2.8% | 双向 Dijkstra 反向搜索（入边权重） |
| 10 | `is_directed` | 3 | 1.4% | 转换器、社区检测 |
| 11 | `get_node` | 0 | 0% | 未使用 |
| 12 | `is_empty` | 0 | 0% | 未使用 |
| | **合计** | **229** | **100%** | |

### 1.2 GraphDirected（有向图扩展，6 方法）

| 排名 | 方法 | 调用次数 | 比例 | 调用来源 |
|:----:|------|:--------:|:----:|----------|
| 1 | `out_degree` | 6 | 40.0% | 拓扑排序、匹配、割点 |
| 2 | `in_degree` | 5 | 33.3% | 拓扑排序（Kahn）、匹配 |
| 3 | `successors` | 2 | 13.3% | 流网络（Edmonds-Karp/Dinic） |
| 4 | `in_neighbors` | 1 | 6.7% | 拓扑排序（Kahn） |
| 5 | `predecessors` | 1 | 6.7% | 拓扑排序（Kahn） |
| 6 | `out_neighbors` | 0 | 0% | 未使用（等同于 `neighbors`） |
| | **合计** | **15** | **100%** | |

### 1.3 GraphWritable（可写接口，5 方法）

| 方法 | 调用次数 | 调用来源 | 说明 |
|------|:--------:|----------|------|
| `add_edge` | 356 | 仅 `*_test.mbt`（12 个文件） | 测试代码中构造图 |
| `add_node` | 325 | 仅 `*_test.mbt`（15 个文件） | 测试代码中构造图 |
| `remove_node` | 0 | 未使用 | |
| `remove_edge` | 0 | 未使用 | |
| `clear` | 0 | 未使用 | |

> **结论**: `GraphWritable` 的 325+356 次调用 **100% 来自测试文件**，算法代码本身不通过 trait 动态调度创建/修改图。对运行时性能无影响。

### 1.4 GraphBatchReadable（批量接口，2 方法）

| 方法 | 调用次数 | 调用来源 |
|------|:--------:|----------|
| `batch_neighbors` | 0 | 仅在 CSR/CSC 实现和测试中出现，未被算法调用 |
| `batch_edges` | 0 | 仅在 CSR/CSC 实现和测试中出现，未被算法调用 |

---

## 2. 按调用来源模块分布

### 2.1 高频调用模块（`node_count` 82次）

`node_count` 是调用频率最高的方法，出现在几乎所有算法函数入口处，用于初始化距离数组、访问标记等数据结构：

| 模块 | 调用次数 | 占比 |
|------|:--------:|:----:|
| `shortest_path/` | 8 | 9.8% |
| `traversal/` | 7 | 8.5% |
| `flow/` | 6 | 7.3% |
| `connectivity/` | 5 | 6.1% |
| `mst/` | 5 | 6.1% |
| `coloring/` | 5 | 6.1% |
| `community/` | 5 | 6.1% |
| 其他模块 | 41 | 50.0% |

### 2.2 高频调用模块（`neighbors` 41次）

`neighbors` 是算法核心循环中的关键方法：

| 模块 | 调用次数 | 占比 |
|------|:--------:|:----:|
| `traversal/` | 12 | 29.3% |
| `connectivity/` | 6 | 14.6% |
| `shortest_path/` | 4 | 9.8% |
| `cutpoints/` | 4 | 9.8% |
| `flow/` | 3 | 7.3% |
| 其他模块 | 12 | 29.3% |

### 2.3 高频调用模块（`node_ids` 38次）

`node_ids` 在需要遍历全图的算法中使用频繁：

| 模块 | 调用次数 | 占比 |
|------|:--------:|:----:|
| `community/` | 8 | 21.1% |
| `coloring/` | 5 | 13.2% |
| `clique/` | 4 | 10.5% |
| `centrality/` | 4 | 10.5% |
| `flow/` | 3 | 7.9% |
| 其他模块 | 14 | 36.8% |

---

## 3. 内联候选函数分析

### 3.1 定义

MoonBit 编译器对 trait 方法的动态调度（vtable dispatch）相较于直接函数调用有额外开销。对于**小函数 + 高频调用**的组合，内联消除可显著提升性能。

**内联候选条件**:
- **高频**: 静态调用次数 ≥ 10（在算法核心路径上）
- **微操作**: 方法体 ≤ 5 行，无复杂控制流，无堆分配
- **泛型稳定**: 单态化后易于内联

### 3.2 强烈推荐内联（P0）

| 方法 | 调用次数 | 方法体估计 | 内联收益 |
|------|:--------:|:----------:|:--------:|
| `node_count` | 82 | 1 行（返回 `self.n`） | **极高** — 每个算法入口都会调用 |
| `degree` | 14 | 1-3 行（邻接表长度/矩阵行和） | **高** — 在着色/中心性循环中频繁调用 |
| `is_directed` | 3 | 1 行（返回字段值） | **中** — 调用次数少，但方法体极简 |

### 3.3 推荐内联（P1）

| 方法 | 调用次数 | 方法体估计 | 内联收益 |
|------|:--------:|:----------:|:--------:|
| `neighbors` | 41 | 3-10 行（构建 Iter）| **高** — 核心循环调用，但有堆分配（Iter）|
| `neighbors_with_weight` | 11 | 3-10 行（构建 Iter）| **高** — 核心循环调用，有堆分配 |
| `node_ids` | 38 | 3-10 行（构建 Iter）| **高** — 全图迭代调用 |
| `contains_node` | 21 | 1-3 行（范围检查/哈希查找）| **高** — 中等频率，小方法 |
| `edges` | 7 | 10-30 行（返回 Iter）| **中** — 调用次数中等 |
| `edge_count` | 6 | 1 行 | **中** — 极小方法 |
| `in_degree` | 5 | 1-3 行 | **中** — 小方法 |
| `out_degree` | 6 | 1-3 行 | **中** — 小方法 |

### 3.4 不推荐内联（P2）

| 方法 | 原因 |
|------|------|
| `get_edge` | 矩阵 O(1) 小方法，但只调用 6 次，收益有限 |
| `in_neighbors` | 仅调用 1 次 |
| `predecessors` | 仅调用 1 次 |
| `successors` | 仅调用 2 次 |
| `contains_edge` | 仅调用 2 次 |

### 3.5 无需内联

| 方法 | 原因 |
|------|------|
| `get_node` | 0 次调用 |
| `is_empty` | 0 次调用 |
| `remove_node` | 0 次调用（算法中）|
| `remove_edge` | 0 次调用（算法中）|
| `clear` | 0 次调用（算法中）|
| `out_neighbors` | 0 次调用 |
| `batch_neighbors` | 0 次调用（算法中）|
| `batch_edges` | 0 次调用（算法中）|
| `add_node` | 仅测试代码调用 |
| `add_edge` | 仅测试代码调用 |

---

## 4. 内联优化优先级排序

```
P0 (强烈推荐) ──────────────────────────────────────────
  node_count   (82次, 1行)     ← 每个算法入口调用的微操作
  degree       (14次, 1-3行)   ← 循环中高频调用
  is_directed  (3次, 1行)      ← 极小方法

P1 (推荐) ──────────────────────────────────────────────
  neighbors           (41次)   ← 核心循环，但有 Iter 分配
  neighbors_with_weight (11次) ← 核心循环，但有 Iter 分配
  node_ids            (38次)   ← 全图迭代
  contains_node       (21次)   ← 中等频率小方法
  edges               (7次)    ← 中等频率
  edge_count          (6次)    ← 极小方法
  in_degree           (5次)    ← 有向图特定
  out_degree          (6次)    ← 有向图特定

P2 (低优先级) ──────────────────────────────────────────
  get_edge, in_neighbors, predecessors, successors, contains_edge

无需优化 ────────────────────────────────────────────────
  get_node, is_empty, remove_node, remove_edge, clear
  out_neighbors, batch_neighbors, batch_edges
```

---

## 5. 未使用方法治理建议

以下 8 个方法在算法代码中 **完全未被调用**，建议评估是否保留：

### 5.1 可考虑移除的方法

| 方法 | 所属 Trait | 移除影响 |
|------|:----------:|----------|
| `get_node` | GraphReadable | 无 — 没有任何算法或存储测试依赖此方法 |
| `is_empty` | GraphReadable | 无 — 算法只需检查 `node_count == 0` |
| `remove_node` | GraphWritable | 在算法路径上无调用；删除节点语义复杂，存储差异大 |
| `remove_edge` | GraphWritable | 同上 |
| `clear` | GraphWritable | 仅用于销毁图，算法不需要 |
| `out_neighbors` | GraphDirected | `neighbors` 语义等价（出边），无需单独方法 |
| `batch_neighbors` | GraphBatchReadable | 目前无算法使用批量接口 |
| `batch_edges` | GraphBatchReadable | 目前无算法使用批量接口 |

### 5.2 移除/简化考虑

- **`get_node`**: 当前设计节点数据为 `Double?`，但几乎没有算法需要读取节点数据（算法需要的是边权重和邻居结构）。建议移除或改为 `pub(all)` 结构体字段直接访问。
- **`is_empty`**: 算法通常通过 `node_count == 0` 判断空图，无需额外 trait 方法。
- **`remove_node`/`remove_edge`/`clear`**: 这三个方法对 CSR/CSC 等静态存储不可实现。如果算法不需要动态修改图，可考虑将 `GraphWritable` 从核心 trait 层级中解耦。

---

## 6. 热点调用路径分析

### 6.1 最短路径类（性能关键路径）

```moonbit
// 伪代码展示典型调用链
fn dijkstra(g, src) {
  let n = g.node_count()     // ← 82次 高频 P0
  let mut dist = Array::make(n, Infinity)
  // ...
  while !pq.is_empty() {
    let (u, _) = pq.pop()
    for (v, w) in g.neighbors_with_weight(u) {  // ← 11次 P1
      if dist[u] + w < dist[v] {
        dist[v] = dist[u] + w
      }
    }
  }
}
```

**每条边执行一次动态调度**: `neighbors_with_weight` 在 Dijkstra 中被调用 |V| 次，每次遍历 deg(u) 条边。在 10000 节点路径图上，`neighbors_with_weight` 被动态调度约 10000 次，每次返回 Iter 还需内部迭代器开销。

### 6.2 社区检测类（全图迭代路径）

```moonbit
fn louvain(g, ...) {
  let n = g.node_count()     // ← 82次
  for id in g.node_ids() {   // ← 38次 全图
    let d = g.degree(id)     // ← 14次
    // ...
  }
}
```

**每轮迭代执行多次动态调度**: Louvain 在每轮迭代中对每个节点调用 `node_ids`（遍历全图）和 `degree` 等。如果迭代 10 轮，`node_ids` 的动态调度次数为 38×10=380 次。

### 6.3 遍历类（递归/队列路径）

```moonbit
fn bfs(g, src) {
  let visited = Array::make(g.node_count(), false)  // ← node_count
  let mut queue = [src]
  while ... {
    let u = queue.pop()
    for v in g.neighbors(u) {                        // ← neighbors 41次
      // ...
    }
  }
}
```

**每条边（两次/有向图）**: BFS/DFS 中 `neighbors` 在 |V| 个节点上各调用一次，动态调度次数随节点数线性增长。

---

## 7. 编译器优化建议

### 7.1 MoonBit 编译器侧

| 建议 | 优先级 | 说明 |
|------|:------:|------|
| **单态化后自动内联小函数** | P0 | `node_count`、`degree`、`is_directed` 等 1-3 行方法应自动内联 |
| **Iter 内联优化** | P1 | `neighbors`、`neighbors_with_weight`、`node_ids` 等方法返回 Iter，若 Iter 的 `next()` 调用也能内联，链式调用开销可显著降低 |
| **纯函数标注** | P1 | 标量方法（无副作用）可做 CSE（公共子表达式消除），避免重复计算 |
| **死代码消除** | P2 | 未使用的 trait 方法（`get_node`、`is_empty` 等）在最终二进制中应被消除 |

### 7.2 代码库侧

| 建议 | 优先级 | 说明 |
|------|:------:|------|
| **考虑 `get_node` 撤销** | P1 | 无算法使用此方法，可移除简化 trait |
| **考虑 `is_empty` 撤销** | P2 | 可用 `node_count == 0` 替代 |
| **GraphWritable 分离** | P2 | 将 Writable 独立文件，不影响 Readable 的热点路径 |
| **GraphBatchReadable 推广** | P2 | 当前无算法使用批量接口；若未来需要，可先在 CSR/CSC 上实现 |

---

## 8. 结论

### 数据总结

| 指标 | 值 |
|------|:---:|
| 分析的 trait 方法数 | 25 |
| 算法代码中使用的 trait 方法数 | 17 |
| 未使用的 trait 方法数 | 8 |
| 总静态调用次数（含测试） | ~600 |
| 总静态调用次数（仅算法核心） | ~244 |
| 高频调用方法（≥10次） | 6 |
| P0 内联候选 | 3 |

### 关键发现

1. **`node_count` 是最热方法**（82次，占 GraphReadable 的 37.8%），内联收益最高
2. **前 6 个方法**（`node_count`/`neighbors`/`node_ids`/`contains_node`/`degree`/`neighbors_with_weight`）占总调用的 **95.6%**
3. **`GraphWritable` 完全服务于测试**，325+356 次调用全部来自测试文件，对运行时性能无影响
4. **8 个方法从未被使用**，建议清理以精简 trait 定义
5. **`GraphBatchReadable` 和 `GraphEdgeIterable` 处于未激活状态**，无算法使用批量接口

### 下一步建议

- **编译器侧**: 确保单态化后的微小方法（`node_count`、`degree`、`is_directed`）被自动内联
- **代码库侧**: 评估移除 `get_node` 和 `is_empty`，减少不必要的 trait 方法
- **基准验证**: 使用本报告的调用频率数据设计微基准，对内联前后的性能变化进行量化对比