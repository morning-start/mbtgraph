# 链接预测算法 (`link_prediction`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 18 通过

基于图拓扑结构的链接预测能力，提供 **5 种经典相似性指标**，用于预测两个节点之间建立连接的可能性。

**应用场景**：
- 🌐 **社交网络** — 预测"你可能认识的人"
- 🛒 **推荐系统** — "购买了此商品的用户还购买了..."
- 🔬 **生物信息学** — 蛋白质相互作用预测
- 📚 **学术引用** — 论文引用关系推断

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | GraphReadable trait + NodeId 类型 |
| `@math` | 对数计算 (Adamic-Adar) |

## 文件结构

```
lib/algo/link_prediction/
├── moon.pkg                      # 包配置
├── types.mbt                     # LinkPredictionResult 结果类型
├── link_prediction.mbt           # 5 种预测算法实现
└── link_prediction_test.mbt      # 测试套件 (18 tests)
```

## API 总览

### 核心类型 ([types.mbt](types.mbt))

#### `LinkPredictionResult` — 综合预测结果

```moonbit
pub(all) struct LinkPredictionResult {
  u : @core.NodeId                        // 节点 u
  v : @core.NodeId                        // 节点 v
  common_neighbors : Int                   // 共同邻居数
  jaccard : Double                         // Jaccard 系数 [0,1]
  adamic_adar : Double                     // Adamic-Adar 指标
  preferential_attachment : Double         // 优先连接值
  resource_allocation : Double             // 资源分配指数
} derive(Debug)
```

**辅助方法**:

| 方法 | 返回 | 说明 |
|------|------|------|
| `node_pair(self)` | `(NodeId, NodeId)` | 提取节点对 |

### 预测算法 ([link_prediction.mbt](link_prediction.mbt))

所有算法均为 **Trait 泛型函数**，接受任意实现 `@core.GraphReadable` 的图存储。

| 函数 | 说明 | 返回 | 复杂度 |
|------|------|------|--------|
| `common_neighbors(graph, u, v)` | 共同邻居数量 \|N(u) ∩ N(v)\| | `Int` | O(d_u + d_v) |
| `jaccard_coefficient(graph, u, v)` | Jaccard 相似系数 | `Double` | O(d_u + d_v) |
| `adamic_adar_index(graph, u, v)` | Adamic-Adar 加权指标 | `Double` | O(d_u + d_v + \|C\|) |
| `preferential_attachment(graph, u, v)` | 度数乘积 deg(u) × deg(v) | `Double` | O(1) |
| `resource_allocation(graph, u, v)` | 资源分配指数 | `Double` | O(d_u + d_v + \|C\|) |
| `link_prediction_score(graph, u, v)` | **综合计算所有 5 种指标** | `LinkPredictionResult` | O(d_u + d_v + \|C\|) |

> **注**: d_u / d_v 为节点度数，\|C\| 为共同邻居数量

**设计要点**:
- 基于 `@core.GraphReadable` 泛型，兼容所有图存储类型（AdjList/Matrix/CSR/CSC）
- 纯函数语义，不修改输入图
- 内部使用排序数组模拟集合操作，避免额外数据结构依赖

## 使用示例

### 基础用法：计算单对节点的相似度

```moonbit
// 构建社交网络: 0-1-2 (路径图)
let g = @storage.new_undirected()
let _ = @core.GraphWritable::add_node(g, 0.0)
let _ = @core.GraphWritable::add_node(g, 0.0)
let _ = @core.GraphWritable::add_node(g, 0.0)
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore

// 计算节点 0 和节点 2 的共同邻居
let cn = common_neighbors(g, @core.NodeId(0), @core.NodeId(2))
// cn => 1 (共同邻居为节点 1)

// 计算 Jaccard 系数: |{1}| / |{0,1} ∪ {1,2}| = 1/3
let jc = jaccard_coefficient(g, @core.NodeId(0), @core.NodeId(2))
// jc ≈ 0.333...
```

### 综合评分：一次性获取所有指标

```moonbit
let score = link_prediction_score(g, @core.NodeId(0), @core.NodeId(2))

score.common_neighbors        // => 1
score.jaccard                 // => 0.333...
score.adamic_adar             // => 1.0 / ln(2) ≈ 1.4427 (deg(1)=2)
score.preferential_attachment // => 2.0 (deg(0)=1 × deg(2)=1，注意无向图边双向计数)
score.resource_allocation     // => 0.5 (1/deg(1) = 1/2)

let (u, v) = score.node_pair()
// u => NodeId(0), v => NodeId(2)
```

### 实际场景：推荐"可能认识的人"

```moonbit
// 假设已有社交网络图 social_graph
fn recommend_friends[G : @core.GraphReadable](
  graph : G,
  user : @core.NodeId,
  top_k : Int,
) -> Array[(@core.NodeId, Double)] {
  let candidates : Array[(@core.NodeId, Double)] = []
  let n = @core.GraphReadable::node_count(graph)
  let mut i = 0
  while i < n {
    let other = @core.NodeId(i)
    if other != user && !@core.GraphReadable::has_edge(graph, user, other) {
      let score = link_prediction_score(graph, user, other)
      // 使用 Adamic-Adar 作为排序依据（通常效果最好）
      candidates.push((other, score.adamic_adar))
    }
    i = i + 1
  }
  // 按 AA 分数降序排序，取 top_k
  candidates.sort_by(fn(a, b) { b.1.compare_to(a.1) })
  if candidates.length() > top_k {
    candidates.slice(0, top_k)
  } else {
    candidates
  }
}

// 推荐前 5 位潜在好友
let recommendations = recommend_friends(social_graph, current_user, 5)
```

### 多指标对比：选择最适合的算法

```moonbit
// 不同场景适合不同指标
let g = build_large_social_network()

let score = link_prediction_score(g, user_a, user_b)

// 场景 1: 紧密社区检测 → Common Neighbors 或 Jaccard
if score.common_neighbors >= 5 {
  "高度可能在同一社区"
}

// 场景 2: 稀疏网络中的弱关系 → Resource Allocation
if score.resource_allocation > 0.3 {
  "存在有意义的弱连接"

// 场景 3: 影响力用户识别 → Preferential Attachment
if score.preferential_attachment > 100.0 {
  "双方都是高影响力节点"
}
```

### 有向图支持

```moonbit
// 引用网络: 论文 A→B 表示 A 引用了 B
let citation = @storage.new_directed()
// ... 添加节点和边 ...

// 计算两篇论文的引用重叠
let cn = common_neighbors(citation, paper_a, paper_b)
// cn = 同时被 a 和 b 引用的论文数量
```

## 算法原理

### 直觉解释

链接预测的核心假设：**如果两个节点有很多共同的邻居，它们更可能在未来建立连接**。

想象一个社交聚会：
- Alice 和 Bob 都认识 Charlie、David 和 Eve
- 这暗示 Alice 和 Bob 处于相似的社交圈层
- 他们未来认识的概率很高 → 应该推荐他们互加好友

### 5 种指标的数学定义

#### 1. 共同邻居 (Common Neighbors, CN)

$$S_{CN}(u,v) = |N(u) \cap N(v)|$$

**直觉**: 直接数共享的朋友数量。简单直观，但偏向高度数节点。

**复杂度**: O(d_u + d_v)

---

#### 2. Jaccard 系数

$$S_{Jaccard}(u,v) = \frac{|N(u) \cap N(v)|}{|N(u) \cup N(v)|}$$

**直觉**: 共同邻居占双方总邻居的比例。归一化到 [0,1]，消除度数偏差。

**特点**: 当两个节点都是"社交达人"时，即使共同邻居多，Jaccard 值也可能不高。

**复杂度**: O(d_u + d_v)

---

#### 3. Adamic-Adar 指标 (AA)

$$S_{AA}(u,v) = \sum_{w \in N(u) \cap N(v)} \frac{1}{\log(|N(w)|)}$$

**直觉**: 对每个共同邻居按其**稀有程度**加权。
- 如果共同邻居 w 只有两个朋友（度=2），则权重 = 1/log(2) ≈ **1.44**（高价值）
- 如果 w 是社交蝴蝶（度=100），则权重 = 1/log(100) ≈ **0.22**（低价值）

**核心思想**: "通过一个只有少数朋友的人认识"比"通过一个万人迷认识"更能说明你们的关系。

**复杂度**: O(d_u + d_v + |C|)

---

#### 4. 资源分配指数 (Resource Allocation, RA)

$$S_{RA}(u,v) = \sum_{w \in N(u) \cap N(v)} \frac{1}{|N(w)|}$$

**直觉**: 与 AA 类似，但用线性衰减代替对数衰减。可以理解为：
- u 通过共同邻居 w 向 v 传输资源
- w 的度数越大，分配给每个邻居的资源越少
- 总传输量 = 连接可能性

**与 AA 的区别**: RA 对高度数节点的惩罚更严厉（1/k vs 1/log(k)）

**复杂度**: O(d_u + d_v + |C|)

---

#### 5. 优先连接 (Preferential Attachment, PA)

$$S_{PA}(u,v) = |N(u)| \times |N(v)|$$

**直觉**: 基于无标度网络的"富者愈富"原理——高度数节点更容易获得新连接。不需要知道共同邻居！

**特点**:
- 计算最快 O(1)，适合超大规模图的初筛
- 不依赖局部结构，只看全局度数
- 常与其他指标组合使用

---

### 指标对比总结

| 指标 | 偏好场景 | 惩罚热门节点？ | 计算成本 |
|------|---------|:-------------:|:--------:|
| **CN** | 小型稠密图 | ❌ 否 | ⭐ 低 |
| **Jaccard** | 需要归一化分数 | ✅ 弱 | ⭐ 低 |
| **AA** | **通用最佳** | ✅ 中等 | ⭐⭐ 中 |
| **RA** | 稀疏网络 | ✅ 强 | ⭐⭐ 中 |
| **PA** | 大规模初筛 | ❌ 否 | ⭐ 极低 |

### 时间复杂度详解

对于一对节点 (u, v):

| 操作 | CN/Jaccard | AA/RA | PA |
|------|-----------|-------|-----|
| 获取邻居列表 | O(d_u + d_v) | O(d_u + d_v) | - |
| 排序去重 | O(d log d) | O(d log d) | - |
| 计算交集 | O(d_u + d_v) | O(d_u + d_v) | - |
| 遍历共同邻居加权 | - | O(\|C\|) | - |
| 度数查询 | - | - | O(1) |
| **总计** | **O(d log d)** | **O(d log d + \|C\|)** | **O(1)** |

> 实际应用中，若需对所有节点对预测，总复杂度为 O(V² · d) 或 O(V²)（PA）。

## 内部组件

### 辅助函数 ([link_prediction.mbt](link_prediction.mbt))

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `neighbors_to_ids()` | priv | 将邻居 Iter 收集为 `Array[Int]` |
| `to_set()` | priv | 排序去重，将数组转为集合表示 |
| `intersection()` | priv | 双指针计算两个有序数组的交集 |
| `union_size()` | priv | 双指针计算两个有序数组的并集大小 |

**设计决策 — 为什么用排序数组而非 HashSet?**

MoonBit 标准库暂无 HashSet 实现，因此采用：
1. **排序去重** (`to_set`) — O(n log n) 一次性的预处理
2. **双指针扫描** (`intersection`/`union_size`) — O(n+m) 高效集合运算

这种方案在当前规模下性能足够，且保持零外部依赖。

### 数据流

```
输入: graph, u, v
  │
  ├─ neighbors_to_ids(graph, u) → Array[Int]  (u 的邻居 ID 列表)
  ├─ neighbors_to_ids(graph, v) → Array[Int]  (v 的邻居 ID 列表)
  │
  ├─ to_set() → 排序去重后的有序数组
  │
  ├─ intersection() → 共同邻居数组 C
  │
  ├─ union_size() → 并集大小 (仅 Jaccard 需要)
  │
  └─ 根据 C 计算:
     ├─ C.length()                    → common_neighbors
     ├─ |C| / |U|                     → jaccard
     ├─ Σ 1/log(deg(w))              → adamic_adar
     ├─ deg(u) × deg(v)              → preferential_attachment
     └─ Σ 1/deg(w)                   → resource_allocation
```

## 边界行为

| 条件 | 行为 | 返回值 |
|------|------|--------|
| **空图** (无边无节点) | 邻居列表为空 | 所有指标返回 0 / 0.0 |
| **孤立节点对** (无共同邻居) | 交集为空 | CN=0, Jaccard=0.0, AA=0.0, RA=0.0, PA=deg(u)×deg(v) |
| **同一节点** (u == v) | 自身邻居求交 | CN = deg(u), Jaccard = 1.0, PA = deg²(u) |
| **自环存在** | 取决于存储实现 | 包含在邻居迭代中则计入 |
| **并行边** | 取决于存储实现 | `to_set()` 自动去重 |
| **超大度数节点** | 正常处理 | 数组操作可能较慢，但无溢出风险 |

**特殊值处理**:

| 情况 | 处理方式 |
|------|---------|
| Jaccard 分母为 0 (并集为空) | 返回 0.0，避免除零错误 |
| AA 中 deg(w) ≤ 1 | 跳过该邻居（log(1)=0 会导致除零）|
| RA 中 deg(w) = 0 | 跳过该邻居（理论上不应出现）|

## 测试覆盖

| 类别 | 测试数 | 内容 |
|------|:------:|------|
| 基础功能 | 10 | 星形图/三角形各指标的正确性验证 |
| 边界情况 | 6 | 同一节点/断连对/空图 |
| 集成测试 | 2 | `link_prediction_score` 综合结果验证 |
| **合计** | **18** | **全部通过** |

**测试矩阵**:

| 图拓扑 | CN | Jaccard | AA | PA | RA | Score |
|-------|:--:|:-------:|:--:|:--:|:--:|:-----:|
| 星形图 (5 节点) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 三角形 (3 节点) | ✓ | ✓ | ✓ | — | ✓ | — |
| 断连节点对 | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| 空图 | ✓ | ✓ | — | ✓ | — | ✓ |
| 同一节点 | ✓ | ✓ | — | ✓ | — | — |

运行命令:
```bash
moon test lib/algo/link_prediction  # 18 tests
```

## 设计决策

### 为什么选择这 5 种指标？

这 5 种指标代表了链接预测领域的 **三个演进阶段** 和 **两种互补思路**:

#### 阶段一：基础指标 (CN, PA)
- **Common Neighbors (1999)** — 最朴素的想法，直接数共同朋友
- **Preferential Attachment (1999)** — Barabási-Albert 无标度网络模型的副产品

**优点**: 计算极快，直觉清晰
**缺点**: CN 偏向热门节点；PA 忽略局部结构

#### 阶段二：归一化改进 (Jaccard)
- **Jaccard (1901)** — 从生态学引入，解决 CN 的度数偏差问题

**优点**: 分数有明确语义（相似度百分比）
**缺点**: 在稀疏图中几乎所有分数都接近 0

#### 阶段三：加权细化 (AA, RA)
- **Adamic-Adar (2003)** — 信息检索领域引入的对数加权
- **Resource Allocation (2011)** — 物理学资源传播模型

**优点**: 区分高质量和低质量共同邻居，预测精度显著提升
**缺点**: 计算稍复杂（需要遍历共同邻居查度数）

#### 为什么没有包含其他指标?

| 未入选指标 | 原因 |
|------------|------|
| **SimRank** | 需要递归/迭代计算，复杂度高 O(kV³) |
| **Katz Index** | 需要矩阵求逆或幂迭代 |
| **Node2Vec/Graph Embedding** | 属于表示学习范畴，不是纯拓扑指标 |
| **DeepWalk** | 同上，且依赖随机游走 |

**选型原则**: 本模块聚焦于 **O(1) ~ O(d) 局部指标**，保证可解释性和计算效率。

### 为什么使用 Trait 泛型而非独立类型？

与 flow 模块不同，链接预测模块选择了 **Trait 兼容模式**:

| 维度 | FlowNetwork (独立类型) | LinkPrediction (Trait 泛型) |
|------|----------------------|--------------------------|
| 数据需求 | 容量/流量矩阵（专用语义） | 仅需 neighbors() + degree()（通用接口）|
| 存储适配 | 自包含邻接矩阵 | 兼容 AdjList/Matrix/CSR/CSC |
| 适用范围 | 流网络专属 | 任何可读图 |

**结论**: 链接预测只需要查询邻居和度数，这正是 `GraphReadable` 提供的接口，无需引入新类型。

### 为什么用排序数组模拟集合？

MoonBit 当前标准库缺少 HashSet/HashMap 数据结构，因此采用：

```
原始邻居列表 → sort() → unique() → 有序数组
                                    ↓
                          双指针 intersection/union
```

**权衡**:
- ✅ 零依赖，纯标准库实现
- ✅ 缓存友好的连续内存访问
- ⚠️ 排序开销 O(d log d)（但对小度数节点影响甚微）
- ⚠️ 未来若 MoonBit 引入 HashSet 可优化至 O(d) 平均

## 与其他模块配合

### 与遍历模块结合：全图链接预测

```moonbit
// 找出图中所有未连接的节点对，按 AA 指标排序
fn predict_all_missing_links[G : @core.GraphReadable](
  graph : G,
) -> Array[(LinkIdPredictionResult)] {
  let results : Array[LinkPredictionResult] = []
  let n = @core.GraphReadable::node_count(graph)
  let mut u_idx = 0
  while u_idx < n {
    let mut v_idx = u_idx + 1
    while v_idx < n {
      let u = @core.NodeId(u_idx)
      let v = @core.NodeId(v_idx)
      if !@core.GraphReadable::has_edge(graph, u, v) {
        results.push(link_prediction_score(graph, u, v))
      }
      v_idx = v_idx + 1
    }
    u_idx = u_idx + 1
  }
  // 按 Adamic-Adar 降序排列
  results.sort_by(fn(a, b) { b.adamic_adar.compare_to(a.adamic_adar) })
  results
}
```

### 与社区检测模块配合

```moonbit
// 先检测社区，再在社区内做链接预测（精度更高）
let communities = louvain(graph)  // 社区检测结果
for community in communities {
  for pair in all_pairs(community) {
    let score = link_prediction_score(graph, pair.0, pair.1)
    if score.jaccard > 0.3 {
      "高概率连接!"
    }
  }
}
```

### 与 I/O 模块配合：从文件加载图后预测

```moonbit
// 从 DOT 文件加载社交网络
let (graph, _) = @io.dot.read_undirected("social_network.dot")

// 预测潜在连接
let predictions = predict_all_missing_links(graph)

// 将结果写入 DOT 文件可视化
for pred in predictions.slice(0, 20) {
  // 高分预测可作为推荐依据
}
```

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.1.0 | 2026-06-01 | 初始版本：5 种预测算法 + LinkPredictionResult 类型 + 18 tests |

---

<div align="center">

**🔗 mbtgraph 链接预测模块**

*基于局部结构的轻量级链接预测，适用于社交网络分析与推荐系统*

</div>
