---
title: 核心概念速查
description: mbtgraph 核心概念快速参考卡片
---

# 核心概念速查

本文档提供 mbtgraph 核心概念的快速参考，帮助你快速上手。

## 图的基本组成

### 节点 (Node)

图的顶点，代表实体。

```moonbit
// 创建节点 ID
let node_id = @core.NodeId(0)

// 节点数据可以是任意类型
let node_data = "User_Alice"
```

### 边 (Edge)

连接两个节点的线段，可带权重。

```moonbit
// 有向边：从 source 到 target
let edge = @core.Edge {
  source: @core.NodeId(0),
  target: @core.NodeId(1),
  weight: Some(1.5),
}

// 无权边（权重为 None）
let unweighted_edge = @core.Edge { ... weight: None }
```

### 权重 (Weight)

边的数值属性，表示距离、成本等。

```moonbit
// 带权重
let weighted = Some(10.0)

// 不带权重
let unweighted = None
```

## Trait 分层体系

### GraphReadable (基础只读)

所有存储必须实现的接口，提供 12 个只读方法：

```moonbit
pub trait GraphReadable {
  node_count(self) -> Int               // 节点数
  edge_count(self) -> Int               // 边数
  contains_node(self, NodeId) -> Bool   // 节点是否存在
  contains_edge(self, NodeId, NodeId) -> Bool  // 边是否存在
  neighbors(self, NodeId) -> Iter[NodeId]      // 邻居列表
  degree(self, NodeId) -> Int            // 度数
  node_ids(self) -> Iter[NodeId]         // 所有节点 ID
  edges(self) -> Iter[(NodeId, NodeId, Double)]  // 所有边 (from, to, weight)
  get_node(self, NodeId) -> Double?      // 获取节点数据
  get_edge(self, NodeId, NodeId) -> Double?  // 获取边数据
}
```

### GraphWritable (可写)

扩展自 `GraphReadable`，增加 5 个写入方法：

```moonbit
pub trait GraphWritable : GraphReadable {
  add_node(Self, Double) -> NodeId               // 添加节点，返回 NodeId
  remove_node(Self, NodeId) -> Bool               // 删除节点
  add_edge(Self, NodeId, NodeId, Double) -> Result[Unit, GraphError]  // 添加边
  remove_edge(Self, NodeId, NodeId) -> Bool       // 删除边
  clear(Self) -> Unit                             // 清空图
}
```

### 其他 Trait 层级

| Trait | 继承自 | 新增方法 | 适用场景 |
|-------|--------|---------|---------|
| GraphDirected | Readable | +6 (入边查询) | 有向图 |
| GraphFull | GraphWritable + GraphDirected | - | 便捷别名 |
| GraphBatchReadable | Readable | +2 (批量操作) | CSR/CSC |

## 存储结构一览

### 有向图存储

| 存储 | 空间复杂度 | 特点 | 适用场景 |
|------|-----------|------|---------|
| `DirectedAdjList` | O(V+E) | ⭐ 通用推荐 | 大多数场景 |
| `DirectedMatrix` | O(V²) | 稠密图优化 | 小规模稠密图 |
| `EdgeList` | O(E) | 边集合 | MST/Kruskal |
| `CSR` | O(V+E) | 缓存友好 | 大规模静态图 |
| `CSC` | O(V+E) | 入度 O(1) | 入边密集查询 |

### 无向图存储

| 存储 | 空间复杂度 | 特点 | 适用场景 |
|------|-----------|------|---------|
| `UndirectedAdjList` | O(V+E/2) | 半存储节省 50% | 无向通用图 |
| `UndirectedMatrix` | O(V²/2) | 对称矩阵 | 小型无向图 |
| `UndirectedEdgeList` | O(E/2) | 无向边集 | 无向 MST |

## 常用函数签名

### 遍历算法

```moonbit
// 广度优先搜索
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult

// 深度优先搜索
pub fn[G : @core.GraphReadable] dfs(graph : G, start : NodeId) -> DfsResult
```

### 最短路径

```moonbit
// Dijkstra（非负权）
pub fn[G : @core.GraphReadable] dijkstra(
  graph : G, source : NodeId,
) -> ShortestPathResult

// Bellman-Ford（允许负权，检测负环）
pub fn[G : @core.GraphReadable] bellman_ford(
  graph : G, source : NodeId,
) -> Result[ShortestPathResult, String]
```

### 最小生成树

```moonbit
// Kruskal（基于边排序 + Union-Find）
pub fn[G : @core.GraphReadable] kruskal(graph : G) -> MstResult

// Prim（从 root 出发的贪心生长）
pub fn[G : @core.GraphReadable] prim(
  graph : G, root : NodeId,
) -> MstResult
```

## 错误处理

mbtgraph 使用 `Result[T, E]` 类型处理错误：

```moonbit
match @core.GraphWritable::add_edge(g, invalid_source, target, 1.0) {
  Ok(_) => {
    // 成功
  }
  Err(e) => {
    // 错误：处理错误情况
    match e {
      @core.GraphError::NodeNotFound(id) => println("节点 \{id} 不存在")
      @core.GraphError::DuplicateEdge => println("边已存在")
      _ => println("未知错误")
    }
  }
}
```

## 快速决策树

```
需要什么功能？
├─ 只读访问？
│  └─ 任何实现了 GraphReadable 的存储
├─ 动态增删？
│  └─ 需要 GraphWritable（AdjList / Matrix / EdgeList）
├─ 有向图？
│  └─ 需要 GraphDirected（有向变体）
├─ 大规模静态图 (>100K 节点)？
│  └─ 推荐 CSR 或 CSC
├─ MST / Kruskal 算法？
│  └─ 需要 EdgeIterable（EdgeList）
└─ 不知道选哪个？
   └─ 默认 DirectedAdjList ⭐
```

## 相关文档

- [完整的 Trait 文档](/core-concepts/traits/)
- [存储选型指南](/core-concepts/storage-guide/)
- [错误处理详解](/core-concepts/error-handling/)
