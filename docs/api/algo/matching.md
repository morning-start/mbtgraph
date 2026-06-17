# Matching API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/matching`
> **路径**: `lib/algo/matching/`

## 概述

Matching 模块提供图匹配算法，包括二部图匹配、一般图最大匹配和加权匹配。

---

## 函数

### hopcroft_karp

```moonbit
pub fn[G : @core.GraphReadable] hopcroft_karp(G, Array[@core.NodeId], Array[@core.NodeId]) -> MatchingResult
```

Hopcroft-Karp 算法：二部图最大匹配。

**参数**:
- `G`: 图实例
- `Array[NodeId]`: 左部节点
- `Array[NodeId]`: 右部节点

**复杂度**: O(E√V)

---

### bipartite_matching

```moonbit
pub fn bipartite_matching(Int, Int, Array[(Int, Int)]) -> MatchingResult
```

二部图匹配（基于邻接列表）。

**参数**:
- `Int`: 左部节点数
- `Int`: 右部节点数
- `Array[(Int, Int)]`: 边列表

---

### bipartite_matching_graph

```moonbit
pub fn[G : @core.GraphReadable] bipartite_matching_graph(G, Array[@core.NodeId], Array[@core.NodeId]) -> MatchingResult
```

二部图匹配（图实例版本）。

---

### edmonds_maximum_matching

```moonbit
pub fn[G : @core.GraphReadable] edmonds_maximum_matching(G) -> MatchingResult
```

Edmonds Blossom 算法：一般图最大匹配。

**特点**:
- 支持奇环（blossom 缩花）
- 适用于一般图（不限于二部图）

---

### kuhn_munkres

```moonbit
pub fn kuhn_munkres(Array[Array[Double]]) -> KMMatchingResult
```

Kuhn-Munkres (Hungarian) 算法：加权二部图最优匹配。

**参数**:
- `Array[Array[Double]]`: 权重矩阵

**返回**: `KMMatchingResult`

---

## 结果类型

### MatchingResult

```moonbit
pub(all) struct MatchingResult {
  matching_edges : Array[(@core.NodeId, @core.NodeId)]
  cardinality : Int
}
pub fn MatchingResult::get_partner(Self, @core.NodeId) -> @core.NodeId?
pub fn MatchingResult::is_matched(Self, @core.NodeId) -> Bool
pub fn MatchingResult::size(Self) -> Int
```

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `get_partner(NodeId)` | `NodeId?` | 获取匹配的伙伴节点 |
| `is_matched(NodeId)` | `Bool` | 检查节点是否已匹配 |
| `size()` | `Int` | 匹配边数量 |

---

### KMMatchingResult

```moonbit
pub(all) struct KMMatchingResult {
  matching : Array[Int]
  total_weight : Double
}
```

**字段**:
- `matching`: 匹配结果（matching[i] = j 表示左部 i 匹配右部 j）
- `total_weight`: 最优匹配总权重

---

## 使用示例

```moonbit
// 二部图匹配
let left_nodes = [n0, n1, n2]
let right_nodes = [n3, n4, n5]
let result = hopcroft_karp(g, left_nodes, right_nodes)
println("Matching size: \{result.size()}")

// 加权匹配
let weights = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]]
let result = kuhn_munkres(weights)
println("Total weight: \{result.total_weight}")
```
