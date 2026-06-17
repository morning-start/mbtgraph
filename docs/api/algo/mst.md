# MST API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/mst`
> **路径**: `lib/algo/mst/`

## 概述

MST (Minimum Spanning Tree) 模块提供最小生成树算法。

---

## 函数

### kruskal

```moonbit
pub fn[G : @core.GraphReadable] kruskal(G) -> MstResult
```

Kruskal 算法：基于边排序的最小生成树。

**特点**:
- 贪心算法，按边权重升序处理
- 使用并查集检测环
- 适合稀疏图

**复杂度**: O(E log E)

---

### prim

```moonbit
pub fn[G : @core.GraphReadable] prim(G, @core.NodeId) -> MstResult
```

Prim 算法：基于顶点扩展的最小生成树。

**参数**:
- `G`: 图实例
- `@core.NodeId`: 起始节点

**特点**:
- 从指定节点开始扩展
- 使用优先队列选择最小边
- 适合稠密图

**复杂度**: O((V + E) log V)

---

## 结果类型

### MstResult

```moonbit
pub(all) struct MstResult {
  total_weight : Double
  edges : Array[(@core.NodeId, @core.NodeId, Double)]
}
pub fn MstResult::edge_count(Self) -> Int
pub fn MstResult::has_edge(Self, @core.NodeId, @core.NodeId) -> Bool
```

**字段**:
- `total_weight`: MST 总权重
- `edges`: MST 边列表

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `edge_count()` | `Int` | MST 边数量 |
| `has_edge(NodeId, NodeId)` | `Bool` | 检查边是否在 MST 中 |

---

## 使用示例

```moonbit
let g = @storage.new_undirected()
// ... 添加节点和边

// Kruskal
let result = @mst.kruskal(g)
println("MST weight: \{result.total_weight}")

// Prim
let result = @mst.prim(g, start_node)
for (from, to, weight) in result.edges {
  println("\{from} -- \{to}: \{weight}")
}
```
