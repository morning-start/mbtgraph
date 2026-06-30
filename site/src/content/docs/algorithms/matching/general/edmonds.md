---
title: Edmonds 一般图匹配
description: 使用开花算法 (Blossom Algorithm) 求解一般图的最大基数匹配
---

# Edmonds 一般图匹配 (Blossom Algorithm)

> **核心思想**: 用"开花"操作处理奇环，将一般图匹配问题规约到二分图匹配 \
> **API**: `edmonds_maximum_matching(graph)` → `MatchingResult` \
> **前置**: [匈牙利算法](/algorithms/matching/bipartite/hungarian)

---

## 一、为什么需要开花算法？

**二分图匹配**（匈牙利算法）的前提是图没有奇环。但**一般图**可能包含奇环，这时简单的增广路方法会失败。

**开花算法**的核心创新：当遇到奇环时，将整个奇环"收缩"为一个超级节点（花苞），在收缩图上继续搜索增广路。

```
奇环(5 节点)
  A ── B
  │    │
  E    C      →  收缩 →  花苞(AB C D E)
  │    │
  D ───┘
```

Edmonds 在 1965 年提出此算法，时间复杂度 O(V²E)。

---

## 二、代码示例

```moonbit
fn main {
  let mut g = @storage.UndirectedAdjList::new()
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 6]
  // 6 个节点的一般图
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[0], 1.0)  // 奇环!
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[4], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[4], nodes[5], 1.0)

  let result = @matching.edmonds_maximum_matching(g)
  println("最大匹配数: \(result.cardinality)")
  for (u, v) in result.matching_edges {
    println("  匹配: \(u.0) ↔ \(v.0)")
  }

  // 检查特定节点
  println("节点 0 匹配: \(result.is_matched(nodes[0]))")
  match result.get_partner(nodes[0]) {
    Some(p) => println("节点 0 的匹配对象: \(p.0)")
    None => println("节点 0 未匹配")
  }
}
```

**输出：**
```
最大匹配数: 3
  匹配: 0 ↔ 1
  匹配: 2 ↔ 3
  匹配: 4 ↔ 5
```

---

## 三、用途

| 场景 | 说明 |
|------|------|
| 一般图最大匹配 | 任何无向图上的最大匹配问题 |
| 奇环处理 | 与匈牙利算法互补 |
| 道路规划 | 巡检路线、邮差问题 |

---

**相关文档：**
- [匈牙利算法](/algorithms/matching/bipartite/hungarian)
- [Hopcroft-Karp 算法](/algorithms/matching/bipartite/hopcroft-karp)
