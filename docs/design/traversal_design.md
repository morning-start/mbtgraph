# 图遍历算法设计文档

> 日期: 2026-05-17
> 状态: 已批准，待实现
> 范围: BFS / DFS / 环检测 / 拓扑排序

## 1. 目标

为 mbtgraph 提供基础图遍历算法，作为 `algorithms/` 包的首批实现。验证 `[G : @core.GraphReadable]` 泛型约束在算法中的表现。

## 2. 目录结构

```txt
src/algorithms/traversal/
├── moon.pkg          is_test: true, link: @core, @storage
├── types.mbt         TraversalResult / BfsResult / DfsResult
├── bfs.mbt           BFS 遍历 + 最短路径 + 全图遍历
├── dfs.mbt           DFS 遍历 + 时间戳 + 全图遍历
├── cycle.mbt         有向环检测 + 无向环检测
├── topo_sort.mbt     Kahn 算法 + DFS 算法
└── README.md
```

## 3. 核心类型

### 3.1 TraversalResult — 基础遍历结果

所有遍历算法的公共结果类型。

```moonbit
pub(all) struct TraversalResult {
  visited : Array[Bool]          // 按 NodeId.0 索引，O(1) 查询
  order    : Array[@core.NodeId] // 访问顺序
  parents  : Array[@core.NodeId?] // 前驱节点（start 的前驱为 None）
}
```

**辅助方法**:

- `path_to(target)` — 通过 parents[] 回溯重建路径，O(path_len)
- `is_visited(id)` — O(1) 查询 visited[id.0]
- `reachable_count()` — 返回 order.length()

### 3.2 BfsResult — BFS 扩展

```moonbit
pub(all) struct BfsResult {
  base   : TraversalResult
  levels : Array[Int]  // start 到各节点的最短距离（BFS 层级）
}
```

**辅助方法**: `distance(id)` → levels[id.0]，不可达返回 -1。

### 3.3 DfsResult — DFS 扩展

```moonbit
pub(all) struct DfsResult {
  base       : TraversalResult
  entry_time : Array[Int]  // 发现时间戳
  exit_time  : Array[Int]  // 完成时间戳
}
```

时间戳用于高级分析：拓扑排序、强连通分量、桥/割点等。

## 4. API 设计

### 4.1 BFS

```moonbit
// 单源 BFS，从 start 开始遍历可达节点
pub fn[G : @core.GraphReadable] bfs(g : G, start : @core.NodeId) -> BfsResult

// BFS 最短路径（无权图），返回 start → target 节点序列
pub fn[G : @core.GraphReadable] bfs_shortest_path(
  g : G, start : @core.NodeId, target : @core.NodeId
) -> Array[@core.NodeId]

// 多源 BFS，遍历全图所有连通分量
pub fn[G : @core.GraphReadable] bfs_all(g : G) -> BfsResult
```

### 4.2 DFS

```moonbit
// 单源 DFS（递归或迭代）
pub fn[G : @core.GraphReadable] dfs(g : G, start : @core.NodeId) -> DfsResult

// 全图 DFS，处理多连通分量
pub fn[G : @core.GraphReadable] dfs_all(g : G) -> DfsResult
```

### 4.3 环检测

```moonbit
// 自动根据 is_directed() 分派到对应实现
pub fn[G : @core.GraphReadable] has_cycle(g : G) -> Bool

// 有向环检测（DFS 三色标记法）
pub fn[G : @core.GraphDirected] has_directed_cycle(g : G) -> Bool

// 无向环检测（DFS + 父节点排除）
pub fn[G : @core.GraphReadable] has_undirected_cycle(g : G) -> Bool
```

### 4.4 拓扑排序

```moonbit
// Kahn 算法（BFS 式，基于入度）
pub fn[G : @core.GraphDirected] topo_sort_kahn(
  g : G
) -> Result[Array[@core.NodeId], String]

// DFS 算法（逆后序）
pub fn[G : @core.GraphDirected] topo_sort_dfs(
  g : G
) -> Result[Array[@core.NodeId], String]
// Err(msg) 当图包含环时
```

## 5. 实现细节

### 5.1 内部数组大小确定

`visited`、`parents`、`levels` 等内部数组的容量通过 `node_count(g)` 或遍历 `node_ids(g)` 确定。对于 CSR/CSC 等 NodeId 可能不连续的情况，使用 `node_ids()` 收集最大 ID + 1 作为数组大小。

### 5.2 BFS 队列实现

MoonBit 标准库 Array 可用作简单队列（push + shift）。后续性能敏感时可优化为环形缓冲区。

### 5.3 DFS 实现方式

优先使用**迭代式**（显式栈），避免递归深度过大导致栈溢出。MoonBit 目前递归深度限制需验证。

### 5.4 has_cycle 自动分派逻辑

```moonbit
pub fn[G : @core.GraphReadable] has_cycle(g : G) -> Bool {
  if @core.GraphReadable::is_directed(g) {
    // 编译期无法缩小约束，运行时分派
    directed_has_cycle_impl(g)
  } else {
    undirected_has_cycle_impl(g)
  }
}
```

内部用两个 private 函数分别实现。

### 5.5 错误处理策略

- **输入验证**: start/target 不在图中 → 返回空结果或 Err
- **拓扑排序有环**: 返回 `Err("graph contains a cycle")`
- **空图**: 返回空 TraversalResult（order 为空数组）

## 6. 测试策略

| 测试类别     | 文件               | 覆盖                                 |
| ------------ | ------------------ | ------------------------------------ |
| BFS 基础     | traversal_test.mbt | 空图/单节点/线性图/星形图/二分图     |
| BFS 最短路径 | traversal_test.mbt | 最短路径正确性/不可达/同一起终点     |
| DFS 基础     | traversal_test.mbt | 与 BFS 结果对比（连通性一致）        |
| DFS 时间戳   | traversal_test.mbt | entry < exit / 父子关系              |
| 环检测       | traversal_test.mbt | 有向无环(DAG)/有向有环/无向树/无向环 |
| 拓扑排序     | traversal_test.mbt | Kahn vs DFS 一致性/有环报错/多种 DAG |
| 多存储兼容性 | traversal_test.mbt | AdjList/Matrix/CSR/EdgeList          |

每种场景至少用 **2 种不同存储结构** 验证泛型正确性。

## 7. 复杂度总览

| 算法               |  时间  | 空间 | 约束          |
| ------------------ | :----: | :--: | ------------- |
| bfs                | O(V+E) | O(V) | GraphReadable |
| bfs_all            | O(V+E) | O(V) | GraphReadable |
| bfs_shortest_path  | O(V+E) | O(V) | GraphReadable |
| dfs                | O(V+E) | O(V) | GraphReadable |
| dfs_all            | O(V+E) | O(V) | GraphReadable |
| has_cycle          | O(V+E) | O(V) | GraphReadable |
| has_directed_cycle | O(V+E) | O(V) | GraphDirected |
| topo_sort_kahn     | O(V+E) | O(V) | GraphDirected |
| topo_sort_dfs      | O(V+E) | O(V) | GraphDirected |

## 8. 后续扩展（不在本次范围）

- 强连通分量 (Tarjan/Kosaraju)
- 双连通分量 / 桥 / 割点
- A\* 启发式搜索
- Dijkstra (加权最短路径)
- Bellman-Ford / SPFA
