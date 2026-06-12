# 图匹配模块设计文档

> **模块**: `lib/algo/matching/`
> **创建日期**: 2026-06-12
> **状态**: ✅ 4 个算法全部实现

---

## 1. 算法全景

| 算法 | 复杂度 | 图类型 | 说明 |
|------|:------:|:------:|------|
| Hungarian | O(VE) | 二分图 | 基础指派问题 |
| Hopcroft-Karp ⭐ | O(E√V) | 二分图 | 最大基数匹配 |
| Edmonds Blossom | O(V³) | 一般图 | 奇环收缩 |
| Kuhn-Munkres (KM) | O(V³) | 二分图 | 最大权完美匹配 |

---

## 2. 设计决策记录

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

```
pub fn kuhn_munkres(weight_matrix : Array[Array[Double]]) -> KMMatchingResult
```

理由：KM 需要密集矩阵访问 O(V²)，Graph trait 方法调用开销不可接受。

### DDR-03: Hungarian 为二分图专用

Hungarian 算法（matching.mbt）实现的是指派问题的 O(VE) 解法，不同于 KM 的 O(V³) 解法。前者适用于稀疏图，后者适用于稠密图。

---

## 3. API 分组

### 二分图匹配
```moonbit
pub fn[G : GraphReadable] hopcroft_karp(graph) -> MatchingResult
pub fn[G : GraphReadable] bipartite_matching_graph(graph) -> MatchingResult
pub fn[G : GraphReadable] bipartite_matching(weight_matrix) -> KMMatchingResult
```

### 一般图匹配
```moonbit
pub fn[G : GraphReadable] edmonds_maximum_matching(graph) -> MatchingResult
```

### 最大权匹配
```moonbit
pub fn kuhn_munkres(weight_matrix) -> KMMatchingResult
```

---

## 4. 边界处理

| 边界 | 行为 |
|------|------|
| 空图 | `pairs: [], size: 0, is_perfect: false` |
| 单节点 | 无匹配边，返回空 |
| 非二分图（Hopcroft-Karp）| 结果无定义（调用方保证输入正确） |
| KM 矩阵非方阵 | 行为未定义（调用方保证） |

---

## 5. 测试策略

- 小规模完全二分图验证（2×2, 3×3, 4×4）
- 路径图/环图的一般图匹配
- Hungarian 与 KM 结果一致性验证
- 权重矩阵零边/负边处理
