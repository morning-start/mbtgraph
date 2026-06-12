# 社区检测模块设计文档

> **模块**: `lib/algo/community/`
> **创建日期**: 2026-06-12
> **状态**: ✅ 4 个算法全部实现

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

## 2. 设计决策记录

### DDR-01: Louvain 数据结构

**问题**: 原始 Louvain 算法全边扫描导致 O(E·V·K) 退化。

**解决**: 预建 `node → neighbors` 邻接表映射，消除全边扫描。同时在 v0.14.0 修复了模块度增益计算公式（符号错误 + 缺少 -k_i²/(2m²) 项）。

### DDR-02: Leiden vs Louvain

Leiden 在 Louvain 基础上增加**细化阶段**，保证每个社区内部导出子图连通。这修正了 Louvain 可能产生不连通社区的已知缺陷。

### DDR-03: 谱聚类依赖

谱聚类依赖 `@moonbitlang/core/linear-algebra` 进行特征分解，因此：
- 仅适用于 V ≤ 5000 的中小规模图
- 若缺失线性代数库，特征向量近似使用幂法迭代

---

## 3. API 设计

```moonbit
pub fn[G : GraphReadable] louvain(graph, resolution : Double = 1.0) -> CommunityResult
pub fn[G : GraphReadable] leiden(graph, resolution : Double = 1.0) -> CommunityResult
pub fn[G : GraphReadable] label_propagation(graph, max_iter : Int = 100) -> CommunityResult
pub fn[G : GraphReadable] spectral_clustering(graph, k : Int) -> CommunityResult
```

### CommunityResult

```
CommunityResult
├── labels : Array[Int]          // 节点→社区映射
├── modularity : Double           // 最终模块度
├── num_communities : Int         // 社区数量
└── community_sizes : Array[Int]  // 各社区大小
```

---

## 4. 性能优化

| 优化 | 收益 | 版本 |
|------|:----:|:----:|
| 邻接表预建 | 5-20x (10K nodes) | v0.14.0 |
| 模块度公式修正 | 计算结果正确性 | v0.14.0 |
| Leiden 细化阶段 | 社区连通性保证 | v0.15.0 |

---

## 5. 测试策略

- Louvain/Leiden 模块度单调性验证
- 标签传播收敛性测试
- 谱聚类与 Louvain 结果一致性对比（小图）
- 空图/单节点/完全图边界测试
