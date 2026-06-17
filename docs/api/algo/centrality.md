# Centrality API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/centrality`
> **路径**: `lib/algo/centrality/`

## 概述

Centrality 模块提供各种中心性分析算法，用于衡量节点在网络中的重要性。

---

## 函数

### degree_centrality

```moonbit
pub fn[G : @core.GraphReadable] degree_centrality(G, DegreeMode) -> CentralityResult
```

度中心性：节点连接数。

**参数**:
- `DegreeMode`: 计算模式 (In/Out/Total)

---

### betweenness_centrality

```moonbit
pub fn[G : @core.GraphReadable] betweenness_centrality(G, Bool) -> CentralityResult
```

介数中心性：节点在最短路径中的出现频率。

**参数**:
- `Bool`: 是否归一化

---

### closeness_centrality

```moonbit
pub fn[G : @core.GraphReadable] closeness_centrality(G, Bool) -> CentralityResult
```

接近中心性：节点到其他节点的平均最短距离的倒数。

---

### harmonic_centrality

```moonbit
pub fn[G : @core.GraphReadable] harmonic_centrality(G, Bool) -> CentralityResult
```

调和中心性：接近中心性的改进版，处理不可达节点。

---

### eigenvector_centrality

```moonbit
pub fn[G : @core.GraphReadable] eigenvector_centrality(G, Int, Double) -> CentralityResult
```

特征向量中心性：迭代算法。

**参数**:
- `Int`: 最大迭代次数
- `Double`: 收敛阈值

---

### katz_centrality

```moonbit
pub fn[G : @core.GraphReadable] katz_centrality(G, Double, Double, Int, Double) -> CentralityResult
```

Katz 中心性：考虑所有路径的影响力。

**参数**:
- `Double`: alpha 参数
- `Double`: beta 参数
- `Int`: 最大迭代次数
- `Double`: 收敛阈值

---

### communication_centrality

```moonbit
pub fn[G : @core.GraphReadable] communication_centrality(G) -> CommunicationResult
```

通信中心性：基于最短路径的通信能力。

---

### group_betweenness_centrality

```moonbit
pub fn[G : @core.GraphReadable] group_betweenness_centrality(G, Array[@core.NodeId]) -> Double
```

组介数中心性：一组节点的联合介数。

---

## 枚举类型

### DegreeMode

```moonbit
pub(all) enum DegreeMode {
  In
  Out
  Total
}
```

---

## 结果类型

### CentralityResult

```moonbit
pub(all) struct CentralityResult {
  scores : Array[Double]
  normalized : Bool
} derive(Debug)
pub fn CentralityResult::get_score(Self, @core.NodeId) -> Double?
pub fn CentralityResult::max_node(Self) -> (@core.NodeId, Double)?
pub fn CentralityResult::nonzero_count(Self) -> Int
```

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `get_score(NodeId)` | `Double?` | 获取节点中心性分数 |
| `max_node()` | `(NodeId, Double)?` | 获取中心性最高的节点 |
| `nonzero_count()` | `Int` | 非零分数节点数量 |

---

### CommunicationResult

```moonbit
pub(all) struct CommunicationResult {
  scores : Array[Double]
} derive(Debug)
pub fn CommunicationResult::get_score(Self, @core.NodeId) -> Double?
```

---

## 使用示例

```moonbit
// 度中心性
let result = @centrality.degree_centrality(g, Total)
if let Some((node, score)) = result.max_node() {
  println("Most connected: \{node} (score: \{score})")
}

// 介数中心性
let result = @centrality.betweenness_centrality(g, true)
for i in 0..<result.scores.length() {
  if result.scores[i] > 0.0 {
    println("Node \{i}: \{result.scores[i]}")
  }
}
```
