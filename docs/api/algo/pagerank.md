# PageRank API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/pagerank`
> **路径**: `lib/algo/pagerank/`

## 概述

PageRank 模块实现 Google PageRank 算法，用于衡量网页（节点）的重要性。

---

## 函数

### pagerank

```moonbit
pub fn[G : @core.GraphReadable] pagerank(G, Double, Int, Double) -> PageRankResult
```

PageRank 算法。

**参数**:
- `G`: 图实例
- `Double`: 阻尼因子 (damping factor)，通常 0.85
- `Int`: 最大迭代次数
- `Double`: 收敛阈值

**返回**: `PageRankResult`

---

## 结果类型

### PageRankResult

```moonbit
pub(all) struct PageRankResult {
  ranks : Array[Double]
  iterations : Int
  converged : Bool
  damping_factor : Double
  tolerance : Double
} derive(Debug)
pub fn PageRankResult::get_rank(Self, @core.NodeId) -> Double?
pub fn PageRankResult::top_nodes(Self, Int) -> Array[(@core.NodeId, Double)]
pub fn PageRankResult::total_rank(Self) -> Double
```

**字段**:
- `ranks`: 节点 PageRank 分数数组
- `iterations`: 实际迭代次数
- `converged`: 是否收敛
- `damping_factor`: 阻尼因子
- `tolerance`: 收敛阈值

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `get_rank(NodeId)` | `Double?` | 获取节点 PageRank 分数 |
| `top_nodes(Int)` | `Array[(NodeId, Double)]` | 获取排名前 N 的节点 |
| `total_rank()` | `Double` | 所有节点分数总和（应为 1.0） |

---

## 使用示例

```moonbit
let result = @pagerank.pagerank(g, 0.85, 100, 1e-6)
println("Converged in \{result.iterations} iterations")

// 获取前 5 名
let top5 = result.top_nodes(5)
for (node, rank) in top5 {
  println("Node \{node}: PageRank = \{rank}")
}
```
