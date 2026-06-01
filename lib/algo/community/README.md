# 社区检测 (`community`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 54 通过

提供图社区检测能力，包含 4 种经典算法：
- **Louvain** — 模块度优化贪心算法 O(E·logV)，社区发现质量高
- **Leiden** — Louvain 改进版，增加 Refinement 阶段保证连通性
- **标签传播 (LPA)** — 近线性时间 O(kE)，速度极快适合大规模图
- **谱聚类** — 拉普拉斯特征向量 + K-Means，数学基础扎实

## 简介

社区检测是图分析的核心任务之一，旨在将图中节点划分为若干内部紧密连接、外部稀疏连接的子集（社区）。本模块提供 4 种算法覆盖不同场景需求：

| 场景 | 推荐算法 | 理由 |
|------|---------|------|
| 通用高质量划分 | **Louvain** | 模块度优化，结果稳定可复现 |
| 需要连通性保证 | **Leiden** | Refinement 避免不连通社区 |
| 超大规模图 (>100K) | **标签传播** | 近线性时间，内存友好 |
| 预知簇数 / 数学严谨 | **谱聚类** | 基于谱图理论，结果可控 |

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | GraphReadable trait、NodeId 等类型定义 |
| `@la` (linear-algebra) | 谱聚类的矩阵运算与特征分解 |

## 文件结构

```
lib/algo/community/
├── moon.pkg                  # 包配置
├── types.mbt                 # CommunityResult 结果类型 + 辅助方法
├── louvain.mbt               # Louvain 算法实现 (O(E·logV))
├── leiden.mbt                # Leiden 算法实现（含 Refinement）
├── label_propagation.mbt     # 标签传播算法 (O(kE))
├── spectral_clustering.mbt   # 谱聚类实现（拉普拉斯 + K-Means）
└── community_test.mbt        # 完整测试套件 (54 tests)
```

## API 总览

### 核心类型 ([types.mbt](types.mbt))

#### `CommunityResult` — 社区检测结果

```moonbit
pub(all) struct CommunityResult {
  labels : Array[Int]          // 节点所属社区标签，索引对应 NodeId
  modularity : Double           // 模块度值，量化划分质量 [-1, 1]
  num_communities : Int         // 检测到的社区数量
  levels : Int                  // 算法层级数（Louvain/Leiden 有效层数，LPA/谱聚类为 1）
} derive(Debug)
```

**辅助方法**:

| 方法 | 说明 | 返回 |
|------|------|------|
| `get_label(node_id)` | 获取指定节点的社区标签 | `Int?`（越界返回 None）|
| `nodes_in_community(community_id)` | 获取属于指定社区的节点列表 | `Array[NodeId]` |
| `largest_community_size()` | 获取最大社区的节点数 | `Int` |

### Louvain ([louvain.mbt](louvain.mbt))

**基于模块度优化的层次聚类算法** — 时间复杂度 O(E·logV)，通过迭代移动节点到使模块度增益最大的邻居社区来优化划分。

| 函数 | 说明 | 返回 |
|------|------|------|
| `louvain(graph, resolution)` | 执行 Louvain 社区检测 | `CommunityResult` |

**参数说明**:
- `graph`: 实现 `@core.GraphReadable` 的任意图结构
- `resolution`: 分辨率参数 γ（Double），控制社区大小
  - `γ = 1.0`：标准模块度（默认）
  - `γ > 1.0`：倾向产生更多小社区
  - `γ < 1.0`：倾向产生更少大社区
  - `γ <= 0`：自动视为 1.0

**算法流程**:
1. 初始化：每个节点独立成社区
2. 局部移动 Phase：遍历所有节点，计算移入各邻居社区的模块度增益，选择增益最大的社区（需 > 0）
3. 重复 Phase 2 直到收敛或达到最大迭代次数（20 passes）
4. 重标记社区 ID 为连续整数
5. 计算最终模块度值

**特性**:
- 纯函数语义：输入图不被修改
- 确定性输出：相同输入始终产生相同结果
- 自动处理空图、单节点等边界情况

### Leiden ([leiden.mbt](leiden.mbt)) ✨ 改进版

**Louvain 的改进算法** — 在 Louvain 基础上增加 Refinement 阶段，解决 Louvain 可能产生内部不连通社区的问题。

| 函数 | 说明 | 返回 |
|------|------|------|
| `leiden(graph, resolution)` | 执行 Leiden 社区检测 | `CommunityResult` |

**参数说明**: 与 Louvain 完全一致（graph, resolution）

**算法流程**（相比 Louvain 的改进）:
1. **Phase 1: Local Moving** — 与 Louvain 相同的局部移动阶段（最多 15 passes）
2. **Phase 2: Refinement** ⭐ 新增 — 在每个社区内部运行子社区合并：
   - 将社区内每个节点初始化为独立子社区
   - 在子社区层面再次运行局部移动
   - 保证最终社区内部是强连通的

**核心改进 vs Louvain**:

| 特性 | Louvain | Leiden |
|------|---------|--------|
| 社区连通性 | ❌ 不保证 | ✅ 保证连通 |
| 最大迭代 | 20 passes | 15 passes + refinement |
| Refinement | 无 | 每社区内最多 10 次 |
| 适用场景 | 通用场景 | 需要连通性约束的场景 |

### 标签传播 ([label_propagation.mbt](label_propagation.mbt))

**近线性时间的社区检测算法** — 时间复杂度 O(kE)，k 通常 < 10。通过让节点采用邻居中最频繁的标签来迭代收敛。

| 函数 | 说明 | 返回 |
|------|------|------|
| `label_propagation(graph, max_iterations)` | 执行标签传播社区检测 | `CommunityResult` |

**参数说明**:
- `graph`: 实现 `@core.GraphReadable` 的任意图结构
- `max_iterations`: 最大迭代次数（Int），默认 100（<= 0 时自动设为 100）

**算法流程**:
1. 初始化：每个节点的标签 = 自身 NodeId
2. 迭代传播：
   - 按顺序遍历所有节点
   - 统计邻居中各标签的出现频率
   - 采用出现次数最多的标签（平局取最小标签值）
   - 若标签发生变化则标记为未收敛
3. 重复直到收敛或达到最大迭代次数
4. 重标记 + 计算近似模块度

**特性**:
- 极快速度：O(kE)，适合百万级节点图
- 非确定性：结果可能受节点访问顺序影响
- 无参数调优：无需预设社区数或分辨率

### 谱聚类 ([spectral_clustering.mbt](spectral_clustering.mbt))

**基于谱图理论的聚类方法** — 利用拉普拉斯矩阵的特征向量将节点嵌入低维空间，再使用 K-Means 进行划分。

| 函数 | 说明 | 返回 |
|------|------|------|
| `spectral_clustering(graph, k)` | 执行谱聚类社区检测 | `CommunityResult` |

**参数说明**:
- `graph`: 实现 `@core.GraphReadable` 的任意图结构
- `k`: 目标簇数（Int）
  - `k <= 1`：所有节点归为同一社区
  - `k >= n`：自动调整为 n-1（跳过平凡特征向量）
  - 推荐：根据先验知识或肘部法则选择

**算法流程**:
1. 构建邻接矩阵 A（n × n）
2. 计算非归一化拉普拉斯 L = D - A（D 为度矩阵）
3. 特征分解：计算 L 的特征值和特征向量
4. 特征选择：取 k 个最小特征值对应的特征向量，构建 U 矩阵（n × k）
5. K-Means 聚类：在 U 的行向量上运行 K-Means（最多 50 次迭代）
6. 返回聚类结果

**特性**:
- 数学基础扎实：基于谱图理论，有严格的理论保证
- 需要预指定 k：簇数必须作为参数传入
- modularity 字段固定为 0.0（谱聚类不直接优化模块度）
- 依赖 `@la` (linear-algebra) 库进行矩阵运算

## 使用示例

### 基础用法：Louvain 检测双社区

```moonbit
// 构建两个分离的三角形（6 节点，12 条边）
let g = @storage.new_directed()
let mut i = 0
while i < 6 {
  @core.GraphWritable::add_node(g, 0.0) |> ignore
  i = i + 1
}
// 社区 0: 节点 0-1-2 形成完全连接
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(0), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0) |> ignore
// 社区 1: 节点 3-4-5 形成完全连接
@core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(4), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(3), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(4), @core.NodeId(5), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(5), @core.NodeId(4), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(5), @core.NodeId(3), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(3), @core.NodeId(5), 1.0) |> ignore

// 执行 Louvain 检测
let result = louvain(g, 1.0)
result.num_communities        // => 2（成功识别两个社区）
result.modularity             // => ~0.35（高模块度表示优质划分）
result.levels                 // => 1

// 查询节点归属
match result.get_label(@core.NodeId(0)) {
  Some(label) => label        // => 0 或 1（社区标签）
  None => ()                  // 节点越界时返回 None
}

// 获取社区成员列表
let comm0_nodes = result.nodes_in_community(0)
comm0_nodes.length()          // => 3（社区 0 有 3 个节点）
```

### Leiden vs Louvain 对比

```moonbit
let g = make_two_clusters()

// Louvain: 标准模块度优化
let louvain_result = louvain(g, 1.0)
louvain_result.num_communities
louvain_result.modularity

// Leiden: 增加连通性保证
let leiden_result = leiden(g, 1.0)
leiden_result.num_communities
leiden_result.modularity

// 分辨率参数效果对比
let fine_grained = louvain(g, 2.0)    // 更高分辨率 → 更多小社区
let coarse_grained = louvain(g, 0.5)  // 更低分辨率 → 更少大社区
assert(fine_grained.num_communities >= coarse_grained.num_communities)
```

### 多算法适用场景

```moonbit
// 场景 1: 大规模社交网络 → 标签传播（最快）
let social_net = build_large_graph()
let lp_result = label_propagation(social_net, 100)

// 场景 2: 学术引用网络需要高质量划分 → Louvain
let citation_net = build_citation_network()
let lv_result = louvain(citation_net, 1.0)

// 场景 3: 生物网络需要连通性 → Leiden
let ppi_net = build_protein_network()
let ld_result = leiden(ppi_net, 1.0)

// 场景 4: 已知大致类别数 → 谱聚类
let known_k = 5
let sc_result = spectral_clustering(some_graph, known_k)

// 统一接口：所有算法返回 CommunityResult
let max_size = lp_result.largest_community_size()
let all_labels = ld_result.labels
```

### 边界情况处理

```moonbit
// 空图
let empty_g = @storage.new_directed()
let r_empty = louvain(empty_g, 1.0)
r_empty.labels.length()       // => 0
r_empty.num_communities       // => 0

// 单节点图
let single_g = @storage.new_directed()
@core.GraphWritable::add_node(single_g, 0.0) |> ignore
let r_single = leiden(single_g, 1.0)
r_single.labels.length()      // => 1
r_single.num_communities      // => 1

// 谱聚类 k 参数边界处理
let path_g = make_path_5()
let r_k10 = spectral_clustering(path_g, 10)  // k > n，自动调整
let r_k1 = spectral_clustering(path_g, 1)     // k=1，全部归为一类

// 标签传播零次迭代
let r_zero_iter = label_propagation(path_g, 0)  // max_iter<=0 默认 100
```

### 结果辅助方法使用

```moonbit
let result = louvain(my_graph, 1.0)

// 安全获取节点标签（含越界检查）
match result.get_label(@core.NodeId(99)) {
  Some(lbl) => println("节点属于社区: ${lbl}")
  None => println("节点 ID 越界")
}

// 获取指定社区的所有节点
let community_2 = result.nodes_in_community(2)
for node in community_2 {
  println("社区 2 成员: 节点 ${node.0}")
}

// 分析社区大小分布
let max_sz = result.largest_community_size()
println("最大社区包含 ${max_sz} 个节点")
```

## 算法原理

### 模块度 (Modularity)

Louvain 和 Leiden 的核心优化目标：

$$Q = \frac{1}{2m} \sum_{ij} \left[ A_{ij} - \frac{k_i k_j}{2m} \right] \delta(c_i, c_j)$$

其中：
- $A_{ij}$: 节点 i 和 j 之间的边权重
- $k_i$, $k_j$: 节点 i 和 j 的度数
- $m$: 图的总边权重
- $\delta(c_i, c_j)$: 若 i、j 同社区则为 1，否则为 0
- $\gamma$ (resolution): 分辨率参数，控制社区粒度

**物理意义**：模块度衡量实际社区内部边密度与随机期望的差异。Q ∈ [-1, 1]，通常 Q > 0.3 表示良好的社区结构。

### Louvain 局部移动策略

对于节点 i 从当前社区 C 移动到目标社区 T 的模块度增益：

$$\Delta Q = \left[ \frac{\Sigma_{in}^T + 2k_{i,T}}{2m} - \left(\frac{\Sigma_T + k_i}{2m}\right)^2 \right] - \left[ \frac{\Sigma_{in}^C}{2m} - \left(\frac{\Sigma_C}{2m}\right)^2 - \left(\frac{k_i}{2m}\right)^2 \right]$$

仅当 $\Delta Q > 0$ 时执行移动。

### Leiden Refinement 机制

Louvain 的已知缺陷：可能产生**内部不连通**的社区（节点被"错误地"聚合）。

Leiden 的解决方案 — Refinement 阶段：
1. 对 Phase 1 产生的每个社区，将其内部节点初始化为独立子社区
2. 在子社区层面重新运行局部移动（仅限社区内部边）
3. 合并后保证每个最终社区是**强连通**的

代价：额外的时间开销（每社区最多 10 次子迭代），但换来更好的拓扑质量。

### 标签传播机制

异步更新规则：
$$\ell_i^{t+1} = \arg\max_c \sum_{j \in N(i)} \mathbb{1}[\ell_j^t = c]$$

**特点**：
- 无显式目标函数，纯局部决策
- 收敛性依赖图结构（通常 5-10 轮即收敛）
- 平局处理：选择编号最小的标签（保证确定性）

### 谱聚类理论

**拉普拉斯矩阵**：$L = D - A$

关键性质：
- L 半正定，特征值 $\lambda_1 \leq \lambda_2 \leq ... \leq \lambda_n$
- $\lambda_1 = 0$，对应的特征向量为全 1 向量（平凡解）
- 第二小特征值 $\lambda_2$（代数连通度）反映图的连通程度
- k 个最小非零特征值对应的特征向量构成最优 k 维嵌入

**Fiedler 向量**（$\lambda_2$ 对应的特征向量）：可用于二分图切割。

## 内部组件

### 共享工具函数

| 函数 | 文件 | 功能 |
|------|------|------|
| `build_edge_info()` | louvain/leiden | 构建邻接表、度数数组、自环权重 |
| `find_neighbor_communities()` | louvain/leiden | 查找节点的邻居社区集合（去重）|
| `count_edges_to_community()` | louvain/leiden | 统计节点到目标社区的连边数 |
| `compute_gain()` | louvain/leiden | 计算模块度增益 ΔQ |
| `relabel_communities()` | louvain/leiden/spectral | 将稀疏标签重映射为连续整数 [0, n_comms) |
| `count_unique_comms()` | louvain/leiden/spectral | 统计社区总数 |
| `compute_modularity()` | louvain/leiden | 计算标准模块度 Q 值 |
| `int_to_double()` | types | Int → Double 类型转换辅助 |

### Louvain 私有函数

| 函数 | 功能 |
|------|------|
| `louvain()` | 主函数：初始化 + 局部移动循环 + 后处理 |
| `compute_gain()` | 模块度增益计算（含 resolution 缩放）|

### Leiden 私有函数

| 函数 | 功能 |
|------|------|
| `leiden()` | 主函数：Local Moving + Refinement 两阶段 |
| `refine_partition()` | Refinement 核心：社区内子社区合并 |

### 标签传播私有函数

| 函数 | 功能 |
|------|------|
| `label_propagation()` | 主函数：初始化 + 迭代传播 + 后处理 |
| `build_lp_adjacency()` | 构建无向邻接表（双向添加边）|
| `find_most_frequent_label()` | 邻居标签频率统计 + 众数选取 |
| `find_max_label()` | 辅助：查找邻居中的最大标签值 |
| `compute_lp_modularity()` | 计算近似模块度（用于评估质量）|

### 谱聚类私有函数

| 函数 | 功能 |
|------|------|
| `spectral_clustering()` | 主函数：构建矩阵 → 特征分解 → K-Means |
| `build_adjacency_matrix()` | 构建 n×n 邻接矩阵 A |
| `build_laplacian()` | 计算 L = D - A |
| `build_u_matrix()` | 提取 k 个最小特征向量组成 U 矩阵 |
| `k_means()` | 标准 K-Means 实现（欧氏距离，前 k 点初始化）|

## 边界行为

| 条件 | Louvain/Leiden | 标签传播 | 谱聚类 |
|------|----------------|----------|--------|
| **空图 (n=0)** | labels=[], num_comms=0, levels=0 | labels=[], num_comms=0, levels=1 | labels=[], num_comms=0, levels=0 |
| **单节点 (n=1)** | labels=[0], num_comms=1, levels=1 | labels=[0], num_comms=1, levels=1 | labels=[0], num_comms=1, levels=1 |
| **resolution ≤ 0** | 自动调整为 1.0 | N/A | N/A |
| **max_iterations ≤ 0** | N/A | 自动调整为 100 | N/A |
| **k ≤ 1** | N/A | N/A | 全部归为社区 0 |
| **k ≥ n** | N/A | N/A | 自动调整为 n-1 |
| **孤立节点（无边）** | 独立成社区 | 保持初始标签（自身 ID）| 归入某社区（取决于特征向量）|
| **完全图（全连接）** | 倾向合并为 1 个社区 | 快速收敛为单一社区 | 按 k 均匀划分 |
| **输入图不可变** | ✅ 纯函数语义，原图不变 | ✅ 纯函数语义，原图不变 | ✅ 纯函数语义，原图不变 |
| **get_label 越界** | 返回 `None` | 返回 `None` | 返回 `None` |

## 测试覆盖

| 类别 | Louvain | Leiden | LPA | Spectral | 集成 | 内容 |
|------|:-------:|:------:|:---:|:--------:|:----:|------|
| 双社区检测 | ✓ | ✓ | ✓ | ✓ | ✓ | 两个分离三角形的正确划分 |
| 稠密单社区 | ✓ | ✓ | ✓ | ✓ | — | 完全图（6 节点）归为 1 社区 |
| 环形图 | ✓ | ✓ | ✓ | — | — | 4 节点环的非平凡划分 |
| 路径图 | ✓ | ✓ | ✓ | — | — | 5 节点路径的正确处理 |
| 空图 | ✓ | ✓ | ✓ | ✓ | ✓ | n=0 边界情况 |
| 单节点 | ✓ | ✓ | ✓ | ✓ | ✓ | n=1 边界情况 |
| 分辨率/参数效应 | ✓ | ✓ | — | ✓ | — | 不同参数下的社区数变化 |
| 模块度合理性 | ✓ | ✓ | ✓ | — | — | Q ∈ [-1, 1] 范围验证 |
| 不可变性 | ✓ | — | ✓ | — | ✓ | 算法不修改输入图 |
| 标签范围验证 | ✓ | — | ✓ | — | ✓ | labels[i] ∈ [0, num_comms) |
| get_label 方法 | ✓ | — | ✓ | — | — | 含越界 None 返回测试 |
| nodes_in_community | ✓ | — | ✓ | — | — | 社区成员查询功能 |
| largest_community_size | ✓ | — | ✓ | — | — | 最大社区统计功能 |
| levels 正性 | ✓ | — | — | — | — | levels ≥ 1 验证 |
| 确定性结果 | ✓ | — | — | — | — | 相同输入→相同输出 |
| k>n / k=1 边界 | — | — | — | ✓ | — | 谱聚类参数越界处理 |
| **合计** | **16** | **9** | **14** | **10** | **5** | **54 total** |

运行命令:
```bash
moon test lib/algo/community  # 54 tests (16 Louvain + 9 Leiden + 14 LPA + 10 Spectral + 5 集成)
```

## 设计决策

### 为什么需要 4 种社区检测算法？

不同算法在**质量、速度、可控性、连通性**等维度上有不同的权衡：

| 维度 | Louvain | Leiden | LPA | 谱聚类 |
|------|---------|--------|-----|--------|
| **划分质量** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **运行速度** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **结果可复现** | ✅ 确定 | ✅ 确定 | ⚠️ 顺序相关 | ✅ 确定 |
| **连通性保证** | ❌ | ✅ | ❌ | ❌ |
| **需预设参数** | resolution | resolution | max_iter | **k (簇数)** |
| **理论保证** | 启发式 | 启发式+约束 | 启发式 | **严格数学** |
| **规模上限** | ~100K 节点 | ~100K 节点 | **~10M 节点** | ~10K 节点 |

**选型建议**:
- **默认首选 Louvain**：质量/速度平衡最佳，大多数场景下足够好
- **生物/网络科学用 Leiden**：PPI 网络、代谢网络等需要连通子结构的领域
- **超大规模用 LPA**：Twitter/微博级社交网络，速度优先
- **研究/学术用谱聚类**：需要严格数学解释或已知大致类别数的场景

### 为什么 CommunityResult 使用统一类型？

四种算法虽然原理迥异，但输出语义一致（节点→社区映射），统一类型带来：
1. **接口一致性**：调用方无需针对不同算法编写分支逻辑
2. **组合灵活性**：可轻松实现多算法集成/投票/对比
3. **扩展便利**：未来新增算法只需返回同一类型

### 为什么谱聚类 modularity 固定为 0.0？

谱聚类直接优化的是谱嵌入空间的 K-Means 目标函数（SSE），而非模块度。强行计算模块度会引入误导（谱聚类的最优划分不一定有高模块度）。若需要模块度指标，建议对结果单独调用 `compute_modularity()`。

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.1.0 | 2026-06-01 | 初始版本：Louvain + Leiden + 标签传播 + 谱聚类 + 54 tests |
