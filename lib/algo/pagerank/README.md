# PageRank 算法模块

## 简介

本模块提供 **PageRank** 网页排名算法的实现，基于经典的幂法迭代（Power Iteration）方法。
PageRank 由 Larry Page 和 Sergey Brin 发明，最初用于 Google 搜索引擎的网页排序，
现已广泛应用于社交网络分析、推荐系统、引用网络等场景。

## 快速开始

### 基本用法

```moonbit
// 创建有向图
let g = @storage.new_directed()
@core.GraphWritable::add_node(g, 0.0) |> ignore  // 节点 0
@core.GraphWritable::add_node(g, 0.0) |> ignore  // 节点 1
@core.GraphWritable::add_node(g, 0.0) |> ignore  // 节点 2
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore

// 计算 PageRank（使用默认参数）
let result = pagerank(g, 0.85, 100, 0.000001)

// 查询节点排名
match result.get_rank(@core.NodeId(0)) {
  Some(rank) => println("Node 0 rank: ${rank}")
  None => println("Node not found")
}

// 获取 Top-K 节点
let top3 = result.top_nodes(3)
for (node_id, score) in top3 {
  println("Node ${node_id.0}: ${score}")
}
```

### 星形图示例

```moonbit
// 所有叶子节点指向中心 → 中心 rank 最高
let g = make_star_graph()
let result = pagerank(g, 0.85, 100, 0.000001)
let (best_node, best_score) = result.top_nodes(1)[0]
assert_eq(best_node.0, 0)  // 中心节点排名第一
```

## API 参考

### 核心函数

| 函数 | 说明 | 复杂度 |
|------|------|--------|
| `pagerank` | 计算 PageRank 排名（泛型，支持所有 GraphReadable 实现） | O(kE) |

#### pagerank 参数

```moonbit
pub fn[G : @core.GraphReadable] pagerank(
  graph : G,           // 输入图
  damping_factor : Double,  // 阻尼系数，默认 0.85
  max_iterations : Int,    // 最大迭代次数，默认 100
  tolerance : Double       // 收敛阈值，默认 0.000001
) -> PageRankResult
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|:------:|------|
| `damping_factor` | Double | 0.85 | 用户继续点击链接的概率，范围 (0, 1) |
| `max_iterations` | Int | 100 | 最大迭代轮数，防止不收敛时无限循环 |
| `tolerance` | Double | 1e-6 | 收敛判断阈值（L∞ 范数） |

### 结果类型

#### PageRankResult

```moonbit
pub(all) struct PageRankResult {
  ranks : Array[Double]        // 节点排名值数组，索引对应 NodeId
  iterations : Int              // 实际迭代次数
  converged : Bool              // 是否收敛
  damping_factor : Double       // 使用的阻尼系数
  tolerance : Double            // 收敛阈值
}
```

#### 方法

| 方法 | 签名 | 说明 |
|------|------|------|
| `get_rank` | `(self, NodeId) -> Double?` | 查询指定节点的排名值，越界返回 None |
| `top_nodes` | `(self, Int) -> Array[(NodeId, Double)]` | 获取排名前 K 的节点及得分（降序） |
| `total_rank` | `(self) -> Double` | 计算所有节点 rank 总和（应 ≈ 1.0） |

## 算法原理

### 数学公式

标准 PageRank 迭代公式：

```
PR(v) = (1 - d) / N + d × (Σ PR(u) / out_degree(u)) + d × D / N
                              u→v                        dangling
```

其中：
- **N**: 节点总数
- **d**: 阻尼系数（damping factor），通常 0.85
- **D**: 所有 dangling node 的 rank 总和

### 算法流程

```
输入: 图 G, 阻尼系数 d, 最大迭代 K, 容差 ε
输出: PageRankResult

1. 初始化: PR(v) = 1/N  对所有节点 v
2. 构建反向邻接表 in_adj[v] = {u | (u,v) ∈ E}
3. 统计出度 out_deg[v]
4. repeat:
   a. 计算 dangling_sum = Σ PR(w)  where out_deg[w] = 0
   b. 对每个节点 v:
      PR_new(v) = (1-d)/N + d×dangling_sum/N + d×Σ PR(u)/out_deg(u)
   c. if ||PR_new - PR||∞ < ε → 已收敛，退出
5. 返回结果
```

### Dangling Nodes 处理

**Dangling node**（悬挂节点）= 无出边的节点。

处理策略：将所有 dangling node 的 rank 值均匀分配给图中所有节点：
- 保证 rank 总和收敛到 1.0
- 避免排名"泄漏"

## 边界行为

| 场景 | 行为 |
|------|------|
| 空图（0 节点） | 返回空 ranks，converged=true，iterations=0 |
| 单节点（无边） | 返回 ranks=[1.0]，无需迭代 |
| 全 dangling nodes | 每个 node 的 rank 被重新分配回所有节点 |
| 不连通图 | 各连通分量独立计算，总和仍为 1.0 |

## 性能特征

| 操作 | 时间复杂度 | 空间复杂度 |
|------|-----------|-----------|
| `pagerank` (主算法) | O(k × E)，k 通常 < 50 | O(N + E) |
| `get_rank` | O(1) | O(1) |
| `top_nodes` | O(N × K) | O(N) |
| `total_rank` | O(N) | O(1) |

> 注: k 为实际迭代次数，通常在 30~60 次之间即可收敛到 1e-6 精度。

## 测试

运行测试：

```bash
moon test lib/algo/pagerank
```

**测试覆盖**: 15 个测试用例

| 分类 | 数量 | 内容 |
|------|:----:|------|
| 基础功能 | 5 | 简单链/星形图/完全图/单节点/空图 |
| 参数验证 | 3 | damping 效果/max_iter 截断/tolerance 敏感度 |
| 属性验证 | 4 | rank 总和≈1/对称均匀/dangling 处理/不可变性 |
| 性能基准 | 3 | 100 节点/top 排序/迭代合理性 |

## 设计决策

### 为什么选择幂法迭代而非特征分解？

- ✅ 效率: O(kE) vs O(N³) 特征分解，稀疏图优势巨大
- ✅ 内存: 只需存储两个向量，无需完整矩阵
- ✅ 可控: 通过 max_iterations + tolerance 双重保障终止性
- ✅ 工业标准: Google 原始实现即采用此方法

### 为什么构建反向邻接表？

- PageRank 公式需要查询「谁指向我」(in-neighbors)
- GraphReadable trait 的 neighbors() 返回的是出边邻居
- 预构建反向邻接表避免每次迭代 O(E²)

详见设计文档: [docs/design/pagerank_design.md](../../../docs/design/pagerank_design.md)

## 配合使用的模块

- **[@core](../../core/)**: 基础类型（NodeId, GraphReadable trait）
- **[@storage](../../storage/)**: 图存储实现（DirectedAdjList 等）
- **centrality**: 中心性分析（度/介数/接近/特征向量）
- **community**: 社区检测（Louvain/标签传播）

## 与 NetworkX 对比

| 特性 | mbtgraph | NetworkX |
|------|----------|----------|
| 泛型支持 | ✅ Trait 约束，8 种存储通用 | ❌ 仅 NetworkX 图 |
| 阻尼系数 | ✅ 自定义 | ✅ 默认 0.85 |
| Dangling 处理 | ✅ 均匀分配 | ✅ 均匀分配 |
| 个人化 PR | ⚠️ 待实现 | ✅ 支持 |
| 后端 | native/wasm/js | Python |

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0.0 | 2026-05-25 | 初始版本：幂法迭代、dangling 处理、15 个测试 |

## 许可证

MIT (与项目整体一致)
