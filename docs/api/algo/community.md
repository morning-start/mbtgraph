# Community API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/community`
> **路径**: `lib/algo/community/`

## 概述

Community 模块提供社区检测算法，用于发现图中的社区结构。

---

## 函数

### louvain

```moonbit
pub fn[G : @core.GraphReadable] louvain(G, Double) -> CommunityResult
```

Louvain 算法：基于模块度优化的社区检测。

**参数**:
- `Double`: 分辨率参数（越大社区越小）

**特点**:
- 层次化算法
- 时间复杂度 O(n log n)

---

### leiden

```moonbit
pub fn[G : @core.GraphReadable] leiden(G, Double) -> CommunityResult
```

Leiden 算法：Louvain 的改进版，保证连通社区。

**参数**:
- `Double`: 分辨率参数

---

### label_propagation

```moonbit
pub fn[G : @core.GraphReadable] label_propagation(G, Int) -> CommunityResult
```

标签传播算法：半监督社区检测。

**参数**:
- `Int`: 最大迭代次数

**特点**:
- 随机化算法
- 时间复杂度 O(n)

---

### spectral_clustering

```moonbit
pub fn[G : @core.GraphReadable] spectral_clustering(G, Int) -> CommunityResult
```

谱聚类：基于拉普拉斯矩阵的社区检测。

**参数**:
- `Int`: 社区数量

---

## 结果类型

### CommunityResult

```moonbit
pub(all) struct CommunityResult {
  labels : Array[Int]
  modularity : Double
  num_communities : Int
  levels : Int
} derive(Debug)
pub fn CommunityResult::get_label(Self, @core.NodeId) -> Int?
pub fn CommunityResult::largest_community_size(Self) -> Int
pub fn CommunityResult::nodes_in_community(Self, Int) -> Array[@core.NodeId]
```

**字段**:
- `labels`: 节点社区标签
- `modularity`: 模块度分数
- `num_communities`: 社区数量
- `levels`: 层次化层数

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `get_label(NodeId)` | `Int?` | 获取节点所属社区 |
| `largest_community_size()` | `Int` | 最大社区大小 |
| `nodes_in_community(Int)` | `Array[NodeId]` | 获取指定社区的所有节点 |

---

## 使用示例

```moonbit
let result = @community.louvain(g, 1.0)
println("Communities: \{result.num_communities}")
println("Modularity: \{result.modularity}")

for i in 0..<result.num_communities {
  let nodes = result.nodes_in_community(i)
  println("Community \{i}: \{nodes.length()} nodes")
}
```
