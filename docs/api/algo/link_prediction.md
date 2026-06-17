# Link Prediction API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/link_prediction`
> **路径**: `lib/algo/link_prediction/`

## 概述

Link Prediction 模块提供链接预测算法，用于预测图中可能存在的边。

---

## 函数

### link_prediction_score

```moonbit
pub fn[G : @core.GraphReadable] link_prediction_score(G, @core.NodeId, @core.NodeId) -> LinkPredictionResult
```

综合链接预测分数（计算所有指标）。

---

### common_neighbors

```moonbit
pub fn[G : @core.GraphReadable] common_neighbors(G, @core.NodeId, @core.NodeId) -> Int
```

共同邻居数量。

---

### jaccard_coefficient

```moonbit
pub fn[G : @core.GraphReadable] jaccard_coefficient(G, @core.NodeId, @core.NodeId) -> Double
```

Jaccard 系数：共同邻居 / 邻居并集。

---

### adamic_adar_index

```moonbit
pub fn[G : @core.GraphReadable] adamic_adar_index(G, @core.NodeId, @core.NodeId) -> Double
```

Adamic-Adar 指数：考虑邻居度数的加权共同邻居。

---

### preferential_attachment

```moonbit
pub fn[G : @core.GraphReadable] preferential_attachment(G, @core.NodeId, @core.NodeId) -> Double
```

优先连接：度数乘积。

---

### resource_allocation

```moonbit
pub fn[G : @core.GraphReadable] resource_allocation(G, @core.NodeId, @core.NodeId) -> Double
```

资源分配：共同邻居度数倒数之和。

---

## 结果类型

### LinkPredictionResult

```moonbit
pub(all) struct LinkPredictionResult {
  u : @core.NodeId
  v : @core.NodeId
  common_neighbors : Int
  jaccard : Double
  adamic_adar : Double
  preferential_attachment : Double
  resource_allocation : Double
} derive(Debug)
pub fn LinkPredictionResult::node_pair(Self) -> (@core.NodeId, @core.NodeId)
```

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `node_pair()` | `(NodeId, NodeId)` | 获取节点对 |

---

## 使用示例

```moonbit
let result = @link_prediction.link_prediction_score(g, node_u, node_v)
println("Common neighbors: \{result.common_neighbors}")
println("Jaccard: \{result.jaccard}")
println("Adamic-Adar: \{result.adamic_adar}")
```
