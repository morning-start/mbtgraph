---
title: PageRank 算法设计
description: PageRank 数学原理、幂法迭代与 Dangling Nodes 处理的设计实现
---

> **模块**: `lib/algo/pagerank/` | **状态**: ✅ 已完成

---

## 1. 数学原理

### 1.1 核心思想

**一个页面的重要性取决于指向它的页面的数量和质量。**

### 1.2 基本公式

```
PR(v) = (1 - d)/N + d × Σ PR(u) / L(u)
              └──────┘   └─────────────┘
              随机跳转      来自邻居的贡献
                          L(u) = u 的出度
```

- **d** (damping factor): 阻尼系数，通常取 0.85
  - 85% 概率点击当前页面的链接
  - 15% 概率随机跳转到任意页面
- **(1-d)/N**: 随机跳转的基础概率，保证每个节点都有非零排名

### 1.3 Dangling Nodes

**问题**: 出度为 0 的节点会导致 rank 值在迭代中泄漏。

**解决**: 将所有 dangling node 的 rank 总和 D 均匀分配回所有 N 个节点：

```
PR(v_i) = (1-d)/N + d × ( Σ PR(u_j)/L(u_j) + D/N )
                                     ↑
                              dangling node 的 rank 再分配
```

---

## 2. 算法实现

### 2.1 幂法迭代

```moonbit
pub fn pagerank[G : @core.GraphReadable](
  graph : G,
  damping_factor : Double,  // 默认 0.85
  max_iterations : Int,     // 默认 100
  tolerance : Double        // 默认 1e-6
) -> PageRankResult
```

迭代过程:
1. 初始化所有节点 rank = 1/N
2. 每轮迭代：计算每个节点的 PR(v)
3. 检测收敛：max(|new - old|) < tolerance
4. 未收敛则重复步骤 2

### 2.2 Trait 兼容

PageRank 只需要 `GraphReadable` + `GraphDirected` 约束：
- `node_ids()` — 遍历所有节点
- `neighbors_with_weight()` — 获取出边
- `out_degree()` — 出度计算
- `degree()` — 无向图支持

--- 

## 3. 设计决策

### DDR-01: 收敛标准

| 标准 | 说明 | 推荐场景 |
|------|------|---------|
| 1e-4 | ~50 次迭代 | 快速近似 |
| 1e-6 ⭐ | ~100 次迭代 | **默认，通用场景** |
| 1e-8 | ~200 次迭代 | 高精度需求 |

### DDR-02: 稀疏优化

对于大规模稀疏图，利用 CSR `batch_neighbors` 批量获取出边信息，将 PageRank 单次迭代从 O(V·deg) 优化到 O(E)。

---

## 4. API 速查

```moonbit
// 基本用法
let result = @pagerank.pagerank(graph)

// 自定义参数
let result = @pagerank.pagerank(
  graph,
  damping_factor=0.85,
  max_iterations=100,
  tolerance=1e-6
)

// 结果
let scores = result.ranks  // Array[Double]
for i in 0..scores.length() {
  println("节点 \{i}: \{scores[i]}")
}

// CSR 优化（大规模图）
let csr = @storage.to_csr(graph)
let result = @pagerank.pagerank(csr, 0.85, 100, 1e-6)
```
