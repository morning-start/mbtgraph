---
title: 图匹配模块设计
description: Hungarian、Hopcroft-Karp、Edmonds、Kuhn-Munkres 的设计决策
---

> **模块**: `lib/algo/matching/` | **状态**: ✅ 4 个算法全部实现

---

## 1. 算法全景

| 算法 | 复杂度 | 图类型 | 说明 |
|------|:------:|:------:|------|
| Hungarian | O(VE) | 二分图 | 基础指派问题 |
| Hopcroft-Karp ⭐ | O(E√V) | 二分图 | 最大基数匹配 |
| Edmonds Blossom | O(V³) | 一般图 | 奇环收缩 |
| Kuhn-Munkres (KM) | O(V³) | 二分图 | 最大权完美匹配 |

---

## 2. 设计决策

### DDR-01: 返回值统一

所有匹配算法返回统一的 `MatchingResult`：

```moonbit
pub(all) struct MatchingResult {
  pairs : Array[(NodeId, NodeId)]
  size : Int
  is_perfect : Bool
  total_weight : Double?
}
```

KM 使用 `KMMatchingResult`（继承自 MatchingResult，增加权重矩阵）。

### DDR-02: KM 独立类型

Kuhn-Munkres 接受 `Array[Array[Double]]` 权重矩阵而非 Graph trait：

```moonbit
pub fn kuhn_munkres(weights : Array[Array[Double]]) -> KMMatchingResult
```

原因:
- KM 算法核心是矩阵操作，不需要图遍历
- 矩阵接口更简洁，用户可直接传入 cost/profit 矩阵

### DDR-03: Edmonds Blossom 实现

一般图匹配的核心难点是**奇环处理**：

1. DFS 寻找增广路
2. 遇到奇环 → 收缩为"花"（blossom）
3. 在收缩后的图上继续寻找增广路
4. 找到后展开花，获得原图匹配

实现使用 L0/L1/L2 标签状态机管理奇环收缩。

---

## 3. API 速查

```moonbit
// 匈牙利算法（二分图）
let result = @matching.hungarian(graph, left_nodes, right_nodes)

// Hopcroft-Karp（二分图，更快）
let result = @matching.hopcroft_karp(graph, left_nodes, right_nodes)

// Edmonds 一般图匹配
let result = @matching.edmonds_maximum_matching(graph)

// Kuhn-Munkres（加权二部图）
let weights = [
  [3.0, 2.0, 1.0],
  [2.0, 4.0, 3.0],
  [1.0, 3.0, 5.0]
]
let result = @matching.kuhn_munkres(weights)
```

### 结果使用

```moonbit
println("匹配数: \{result.size}")
println("完美匹配: \{result.is_perfect}")

for pair in result.pairs {
  let (u, v) = pair
  println("匹配: \{u} ↔ \{v}")
}
```
