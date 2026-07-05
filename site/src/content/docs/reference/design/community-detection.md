---
title: 社区检测模块设计
description: Louvain、Leiden、标签传播、谱聚类的设计决策与实现细节
---

> **模块**: `lib/algo/community/` | **状态**: ✅ 4 个算法全部实现

---

## 1. 数学原理

### 1.1 模块度 (Modularity)

社区检测的核心优化目标是模块度：

```
Q = 1/(2m) × Σ[A_ij - k_i·k_j/(2m)] · δ(c_i, c_j)
```

其中 `A_ij` 为邻接矩阵，`k_i` 为节点 i 的度数，`m` 为总边数。

### 1.2 算法对比

| 算法 | 复杂度 | 类型 | 特点 |
|------|:------:|------|------|
| Louvain | O(E·logV) | 贪心优化 | ⭐ 速度与质量的最佳平衡 |
| Leiden | O(E·logV) | 贪心优化 | 保证社区内连通性 |
| 标签传播 | O(E) | 局部传播 | ⚡ 最快，结果不稳定 |
| 谱聚类 | O(V³) | 谱分解+聚类 | 精确，适合 V ≤ 5000 |

---

## 2. 设计决策

### DDR-01: Louvain 数据结构

**问题**: 原始 Louvain 算法全边扫描导致 O(E·V·K) 退化。

**解决**: 预建 `node → neighbors` 邻接表映射，消除全边扫描。模块度增益计算公式已修复（补全 -k_i²/(2m²) 项）。

### DDR-02: Leiden vs Louvain

| 对比项 | Louvain | Leiden |
|--------|:-------:|:------:|
| 社区内连通性 | ❌ 可能不连通 | ✅ 保证连通 |
| 时间复杂度 | O(E·logV) | O(E·logV) |
| 模块度质量 | 高 | ⭐ 更高 |
| 实现复杂度 | 简单 | 稍复杂 |

选择同时实现两者，用户可根据需求选择。

### DDR-03: 标签传播的稳定性

标签传播算法结果不稳定（随机种子影响大），采用以下策略：
- 节点处理顺序随机打乱
- 多次运行取最佳模块度结果
- 提供 `random_seed` 参数

### DDR-04: 谱聚类接口

```moonbit
pub fn spectral_clustering(
  graph : G,
  k : Int  // 指定聚类数量
) -> CommunityResult
```

谱聚类需要指定 k 值，不同于 Louvain 的自动发现。

---

## 3. 结果类型

```moonbit
pub(all) struct CommunityResult {
  communities : Array[Array[NodeId]]  // 每个社区的节点列表
  num_communities : Int               // 社区数量
  modularity : Double                  // 模块度
}
```

---

## 4. API 速查

```moonbit
// Louvain 社区检测
let result = @community.louvain(graph)

// Leiden 社区检测（更高质量）
let result = @community.leiden(graph)

// 标签传播（快速）
let result = @community.label_propagation(graph)

// 谱聚类（指定数量）
let result = @community.spectral_clustering(graph, 4)
```
