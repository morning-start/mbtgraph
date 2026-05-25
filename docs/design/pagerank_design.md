# PageRank 算法设计文档

> **模块**: `src/algo/pagerank/`
> **创建日期**: 2026-05-25
> **状态**: ✅ 已完成 (TASK-001 ~ TASK-005)

---

## 1. 数学原理

### 1.1 PageRank 起源

PageRank 由 Larry Page 和 Sergey Brin 于 1996 年在斯坦福大学提出，
核心思想是：**一个页面的重要性取决于指向它的页面的数量和质量**。

### 1.2 基本公式

设图 G = (V, E)，|V| = N，节点 v 的 PageRank 定义为：

```
PR(v) = (1 - d)/N + d × Σ PR(u) / L(u)
              └──────┘   └─────────────┘
              随机跳转      来自邻居的贡献
                          L(u) = u 的出度
```

- **d** (damping factor): 阻尼系数，通常取 0.85
  - 表示用户有 85% 的概率点击当前页面的链接
  - 有 15% 的概率随机跳转到任意页面（模拟"无聊"行为）
- **(1-d)/N**: 随机跳转的基础概率，保证每个节点都有非零排名

### 1.3 Dangling Nodes 问题

**定义**: 出度为 0 的节点称为 dangling node。

**问题**: 如果不处理，dangling node 携带的 rank 值会在迭代中"泄漏"，导致总和不再为 1。

**解决方案** (Brin & Page, 1998):

将所有 dangling node 的 rank 总和 D 均匀分配回所有 N 个节点：

```
PR(v) = (1-d)/N + d/N × Σ PR(w) + d × Σ PR(u)/L(u)
             └──────┘   └──────────┘   └────────────┘
             基础值     dangling 分配    正常入边贡献
                       w: dangling     u→v 且 u 非 dangling
```

### 1.4 收敛性证明

**定理**: 幂法迭代在 d ∈ [0, 1) 时必然收敛到唯一不动点。

**证明思路**:
1. PageRank 迭代可表示为矩阵形式: **r** = **M** × **r**
2. 其中 **M** = d × **A** + (d/N) × **D** + ((1-d)/N) × **E**
3. **A** 是列随机的（每列和为 1），**D** 是 dangling 向量，**E** 是全 1 矩阵
4. **M** 是一个**素矩阵**（primitive matrix），由 Perron-Frobenius 定理：
   - 特征值 1 是单根且严格主导
   - 幂法必然收敛到主特征向量
5. 收敛速度: O(log(1/ε) / log(1/|λ₂|))，其中 λ₂ 为第二特征值

---

## 2. 设计决策记录

### DDR-01: 选择幂法迭代而非其他方法

**选项**:

| 方法 | 时间复杂度 | 空间复杂度 | 适用场景 |
|------|-----------|-----------|---------|
| 幂法迭代 | O(kE) | O(N+E) | 大规模稀疏图 ⭐ |
| 特征分解 | O(N³) | O(N²) | 小稠密图 |
| ARNOLDI | O(kNE) | O(kN) | 需要多个特征向量 |

**决策**: 选择幂法迭代

**理由**:
1. PageRank 场景的图通常是大规模稀疏图（网页链接、社交关系）
2. 只需主特征向量（Top-1），不需要完整的特征谱
3. 实现简单、数值稳定、内存高效
4. 与 Google 原始实现一致，结果可比

### DDR-02: 反向邻接表预构建

**问题**: GraphReadable trait 的 `neighbors(v)` 返回**出边**邻居，
但 PageRank 公式需要查询**入边**邻居（谁指向我）。

**方案对比**:

| 方案 | 每次迭代开销 | 总空间 |
|------|-------------|--------|
| A: 遍历所有边筛选 | O(E²) | 无额外 |
| B: 预构建反向邻接表 | O(E) | O(N+E) ⭐ |

**决策**: 方案 B — 预构建反向邻接表 `in_adj[v] = [u₁, u₂, ...]`

**理由**:
- k 次迭代中每次节省 O(E) → 总计节省 O((k-1)E)
- 对于 k ≈ 50 的典型场景，性能提升显著
- 空间换时间，O(N+E) 对现代内存完全可接受

### DDR-03: Dangling nodes 均匀分配策略

**备选方案**:

| 策略 | 描述 | 效果 |
|------|------|------|
| 均匀分配给所有节点 | D/N 分配给每个节点 | ⭐ 标准、公平 |
| 按出度比例分配 | 按各节点出度加权分配 | 偏向高连接度节点 |
| 仅分配给非 dangling | 排除 dangling 节点 | 可能导致二次泄漏 |

**决策**: 均匀分配给所有节点

**理由**:
1. Brin & Page 原论文的标准做法
2. 保证数学上的收敛性和唯一性
3. 结果与 NetworkX 等主流库一致

### DDR-04: 泛型约束使用 GraphReadable

**决策**: 使用 `G : @core.GraphReadable` 泛型约束

**影响**:
- ✅ 兼容全部 8 种存储实现（AdjList/Matrix/CSR/CSC/EdgeList 等）
- ✅ 无需为每种存储写独立实现
- ❌ 不能直接调用 `out_degree` / `in_neighbors`（需通过 edges() 间接获取）

**权衡**: 通过 `edges()` 和 `node_count()` 可以重建所需的度数和邻接信息，
牺牲少量性能换取通用性是值得的。

### DDR-05: 不支持个人化 PageRank (Personalized PR)

**当前状态**: 未实现

**原因**:
1. 个人化 PR 需要额外的 personalization vector 参数
2. 增加 API 复杂度，但实际使用频率较低
3. 可作为 v0.10.x 后续增强

**未来扩展接口预留**:

```moonbit
// 未来可能的扩展签名
pub fn pagerank_personalized[G : @core.GraphReadable](
  graph : G,
  damping_factor : Double,
  max_iterations : Int,
  tolerance : Double,
  personalization : Array[Double>?,  // 可选个性化向量
) -> PageRankResult
```

---

## 3. 数据结构设计

### 3.1 PageRankResult

```moonbit
pub(all) struct PageRankResult {
  ranks : Array[Double]       // 核心数据：每个节点的排名值
  iterations : Int            // 元数据：实际迭代次数
  converged : Bool            // 元数据：是否收敛
  damping_factor : Double     // 元数据：使用的阻尼系数
  tolerance : Double          // 元数据：收敛阈值
}
```

**设计原则**:
- 存储完整元数据，方便调试和复现
- ranks 使用 Array 而非 Map，保证 O(1) 随机访问
- derive(Debug)，方便测试输出

### 3.2 辅助方法

| 方法 | 设计动机 |
|------|---------|
| `get_rank(node_id)` | 安全查询，越界返回 None 而非 panic |
| `top_nodes(k)` | 高频操作（Top-K 查询），内置排序避免外部重复代码 |
| `total_rank()` | 属性验证工具，快速检查正确性 |

---

## 4. 内部算法流程

### 4.1 初始化阶段

```
输入: 图 G, N = node_count(G)

1. out_deg[N] = {0}        // 统计出度
2. in_adj[N] = [[]]         // 构建反向邻接表
3. ranks[N] = {1/N}         // 均匀初始化
```

### 4.2 迭代阶段（核心循环）

```
for iter = 1 to max_iterations:
  Step 1: 计算 dangling_sum = Σ ranks[w] where out_deg[w] == 0

  Step 2: 计算新 ranks
    base = (1-d)/N + d * dangling_sum / N
    for each node v:
      sum_in = 0
      for each u in in_adj[v]:
        if out_deg[u] > 0:
          sum_in += ranks[u] / out_deg[u]
      new_ranks[v] = base + d * sum_in

  Step 3: 收敛判断
    diff = max(|new_ranks[i] - ranks[i]|) for all i
    if diff < tolerance:
      converged = true
      break

  Step 4: 更新
    ranks = new_ranks
```

### 4.3 边界处理

| 输入 | 快速路径 | 说明 |
|------|---------|------|
| N == 0 | 直接返回空结果 | 避免除零错误 |
| N == 1 | 返回 ranks=[1.0] | 单节点 trivial 解，无需迭代 |

---

## 5. 测试策略

### 5.1 测试分类

| 类别 | 数量 | 重点 |
|------|:----:|------|
| 基础功能 | 5 | 各类图的正确运行和基本属性 |
| 参数验证 | 3 | 参数对结果的定性影响 |
| 属性验证 | 4 | 数学不变量（总和=1、对称均匀等） |
| 性能基准 | 3 | 规模和效率合理性 |

### 5.2 关键测试用例说明

#### 星形图中心最高

**原理**: 所有叶子 → 中心，中心汇聚所有入边。
**预期**: 中心节点的 rank 显著高于叶子节点。
**验证方式**: `top_nodes(1)[0].id == center_id`

#### 完全对称图均匀分布

**原理**: 双向完全图中每个节点结构完全相同。
**预期**: 所有节点 rank ≈ 1/N。
**验证方式**: `forall r in ranks: approx_eq(r, 1/N, eps)`

#### Rank 总和 ≈ 1.0

**原理**: PageRank 是概率分布，总和恒为 1。
**验证方式**: `approx_eq(total_rank(), 1.0, 0.001)`

#### 不可变性

**原理**: 算法不应修改输入图。
**验证方式**: 执行前后比较 node_count 和 edge_count

---

## 6. 已知限制与未来改进

### 当前限制

1. **不支持加权边**: 所有边权重视为相等
2. **无并行加速**: 迭代循环为串行
3. **无可视化输出**: 仅返回数值结果

### 可能的未来改进

- [ ] Personalized PageRank（个人化向量参数）
- [ ] 加权 PageRank（考虑边权重）
- [ ] BlockRank 分块算法（超大规模图优化）
- [ ] 并行迭代（利用 MoonBit 并发原语）

---

## 7. 参考文献

1. Page, L., Brin, S., Motwani, R., & Winograd, T. (1999). *The PageRank Citation Ranking: Bringing Order to the Web*. Stanford Digital Library Technologies Project.
2. Langville, A. N., & Meyer, C. D. (2006). *Google's PageRank and Beyond: The Science of Search Engine Rankings*. Princeton University Press.
3. NetworkX Documentation: `networkx.algorithms.link_analysis.pagerank`
