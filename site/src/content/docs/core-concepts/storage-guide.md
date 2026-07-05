---
title: 8 种存储对比表
description: 全面对比 mbtgraph 的 8 种图存储结构：复杂度、场景、优缺点
---

# 8 种存储对比表

mbtgraph 提供 **8 种图存储结构**，分为**有向**和**无向**两大类。选择合适的存储是性能优化的第一步。

## 存储分类总览

```
存储结构 (8 种)
├── 有向图 (5 种)
│   ├── DirectedAdjList      ⭐ 默认推荐
│   ├── DirectedMatrix        稠密小图
│   ├── EdgeList             Kruskal 友好
│   ├── CSR                  大规模静态图
│   └── CSC                  入边密集查询
│
└── 无向图 (3 种)
    ├── UndirectedAdjList    ⭐ 无向首选
    ├── UndirectedMatrix     小型无向图
    └── UndirectedEdgeList   无向 MST
```

---

## 一、有向图存储

### 1. DirectedAdjList - 有向邻接表 ⭐

**默认推荐**，适用于大多数有向图场景。

#### 数据结构

```moonbit
pub(all) struct DirectedAdjList {
  mut node_cnt : Int                          // 节点计数
  mut edge_cnt : Int                          // 边计数
  nodes       : Array[@core.Node?]            // 节点数据数组
  adj         : Array[Array[(NodeId, Double)]] // 正向邻接表
  rev_adj     : Array[Array[(NodeId, Double)]] // 反向邻接表（入边索引）
}
```

#### 特性

| 维度 | 数据 |
|------|------|
| **空间复杂度** | O(V + 2E) |
| **邻居查询** | O(k)，k 为节点度数 |
| **添加节点** | O(1) 均摊 |
| **添加边** | O(1) 均摊（使用 `add_edge_unchecked`）|
| **删除边** | O(k) 需遍历邻接表 |
| **入度查询** | O(1) 通过 `rev_adj` |
| **出度查询** | O(1) `adj[id].length` |
| **实现的 Trait** | **GraphFull** (Readable + Writable + Directed) |

#### 适用场景

- ✅ 社交网络（关注关系）
- ✅ 网页链接图（PageRank）
- ✅ 依赖关系图（需要频繁增删）
- ✅ 通用有向图算法（BFS/DFS/最短路径）

#### 代码示例

```moonbit
// 创建有向邻接表
let mut g = @storage.DirectedAdjList::new()

// 添加节点（返回 NodeId）
let alice = @core.GraphWritable::add_node(g, 0.95)    // Alice
let bob = @core.GraphWritable::add_node(g, 0.72)      // Bob
let charlie = @core.GraphWritable::add_node(g, 0.88)  // Charlie

// 添加边（自动维护正向 + 反向索引）
@core.GraphWritable::add_edge(g, alice, bob, 1.0) |> ignore      // Alice → Bob
@core.GraphWritable::add_edge(g, alice, charlie, 1.0) |> ignore  // Alice → Charlie
@core.GraphWritable::add_edge(g, bob, charlie, 1.0) |> ignore    // Bob → Charlie

// 查询入度/出度（O(1)）
let out_deg = @core.GraphDirected::out_degree(g, alice)
let in_deg = @core.GraphDirected::in_degree(g, alice)
println("Alice: 出度=${out_deg}, 入度=${in_deg}")

// 批量建图优化（跳过重复检查）
let edges : Array[(@core.NodeId, @core.NodeId, Double)] = [
  (alice, bob, 2.0),
  (bob, charlie, 3.0),
]
match g.add_edges_batch(edges) {
  Ok(count) => println("批量添加 ${count} 条边成功")
  Err(e) => println("错误: ${e}")
}
```

#### 优势与限制

**优势**:
- 🚀 **均衡性能**: 读写操作都是 O(1) 或 O(k)
- 🔍 **双向索引**: 同时支持高效入边/出边查询
- 🛠️ **动态友好**: 支持运行时增删节点和边
- 💾 **内存合理**: O(V+2E)，稀疏图时远优于矩阵

**限制**:
- ⚠️ 缓存局部性不如 CSR（链表 vs 连续内存）
- ⚠️ 删除边需要 O(k) 时间

---

### 2. DirectedMatrix - 有向邻接矩阵

适用于**稠密小图**（E ≈ V²）或需要 **O(1) 随机访问** 的场景。

#### 数据结构

```moonbit
pub(all) struct DirectedMatrix {
  mut node_cnt : Int
  mut edge_cnt : Int
  nodes : Array[@core.Node?]
  matrix : Array[Array[Double?]]  // V×V 矩阵，None 表示无边
}
```

#### 特性

| 维度 | 数据 |
|------|------|
| **空间复杂度** | O(V²) |
| **邻居查询** | O(V) 需扫描整行/列 |
| **边存在检查** | **O(1)** 直接访问 `matrix[i][j]` |
| **添加边** | O(1) |
| **删除边** | O(1) |
| **实现的 Trait** | GraphFull |

#### 适用场景

- ✅ 稠密图（边数接近 V²）
- ✅ 算法竞赛（需要 O(1) 边查询）
- ✅ 小型图（V < 1000）
- ✅ Floyd-Warshall 等矩阵算法

#### 代码示例

```moonbit
// 创建 4 个节点的稠密图
let mut g = @storage.DirectedMatrix::new_with_capacity(4)

// 添加节点
for i in 0..4 {
  @core.GraphWritable::add_node(g, i.to_double()) |> ignore
}

// 完全图：每对节点都有边
for i in 0..4 {
  for j in 0..4 {
    if (i != j) {
      let from = @core.NodeId(i)
      let to = @core.NodeId(j)
      @core.GraphWritable::add_edge(g, from, to, 1.0) |> ignore
    }
  }
}

// O(1) 边查询（这是 Matrix 的核心优势）
let id0 = @core.NodeId(0)
let id3 = @core.NodeId(3)
if (@core.GraphReadable::contains_edge(g, id0, id3)) {
  let weight = @core.GraphReadable::get_edge(g, id0, id3)
  match weight {
    Some(w) => println("边 (0→3) 权重: ${w}")
    None => ()
  }
}
```

#### 优势与限制

**优势**:
- ⚡ **O(1) 边存在性检查**
- ⚡ **O(1) 添加/删除边**
- 🎯 **算法竞赛友好**: 常用于 Floyd-Warshall、传递闭包

**限制**:
- 💸 **空间昂贵**: V=10000 时需 800MB（Double? 矩阵）
- 🐌 **邻居查询慢**: O(V) 扫描整行
- ❌ **不适合稀疏图**: V=100000, E=100000 时浪费 99.9% 空间

---

### 3. EdgeList - 有向边集数组

专为 **Kruskal MST** 和需要 **按权重排序边** 的算法设计。

#### 数据结构

```moonbit
pub(all) struct EdgeList {
  mut node_cnt : Int
  mut edge_cnt : Int
  nodes : Array[@core.Node?]
  edges : Array[@core.Edge]  // 边数组，可排序
}
```

#### 特性

| 维度 | 数据 |
|------|------|
| **空间复杂度** | O(V + E) |
| **边遍历** | O(E) 顺序访问 |
| **边排序** | **O(E log E)** 内置支持 |
| **邻居查询** | O(E) 需扫描所有边 |
| **添加边** | O(1) 追加到数组末尾 |
| **实现的 Trait** | GraphWritable + GraphDirected |

#### 适用场景

- ✅ **Kruskal 最小生成树**（需要排序边）
- ✅ **Borůvka 算法**
- ✅ 图的序列化/反序列化（天然线性格式）
- ✅ 内存极度受限的环境

#### 代码示例

```moonbit
// 构建边集（适合 Kruskal）
let mut g = @storage.EdgeList::new()

// 添加节点
let n0 = @core.GraphWritable::add_node(g, 0.0)
let n1 = @core.GraphWritable::add_node(g, 0.0)
let n2 = @core.GraphWritable::add_node(g, 0.0)
let n3 = @core.GraphWritable::add_node(g, 0.0)

// 添加带权边
@core.GraphWritable::add_edge(g, n0, n1, 10.0) |> ignore
@core.GraphWritable::add_edge(g, n0, n2, 6.0) |> ignore
@core.GraphWritable::add_edge(g, n0, n3, 5.0) |> ignore
@core.GraphWritable::add_edge(g, n1, n2, 15.0) |> ignore
@core.GraphWritable::add_edge(g, n2, n3, 4.0) |> ignore

// 使用 GraphReadable 获取边总数
// @core.GraphReadable::edge_count(g)
println("边总数: ${@core.GraphReadable::edge_count(g)}")
```

#### 优势与限制

**优势**:
- 📦 **紧凑存储**: 仅存边，无冗余
- 🔄 **易排序**: 天然支持 Kruskal 算法
- 💾 **内存最优**: 比 AdjList 节省 ~50%（无指针开销）

**限制**:
- 🐌 **邻居查询极慢**: O(E) 线性扫描
- ❌ **不支持高效 BFS/DFS**: 无法快速获取邻居列表

---

### 4. CSR - 压缩稀疏行（Compressed Sparse Row）

**大规模图计算的首选**，适用于 **亿级节点** 的静态图。

#### 数据结构

```moonbit
pub(all) struct CSRGraph {
  nodes   : Array[@core.Node]     // 节点数据
  row_ptr : Array[Int]           // 行指针：每行起始位置
  col_idx : Array[@core.NodeId]   // 列索引：邻接点 ID
  values  : Array[Double]        // 边权重
  in_ptr  : Array[Int]           // 入边行指针（可选）
  in_idx  : Array[@core.NodeId]   // 入边列索引
  in_vals : Array[Double]        // 入边权重
}
```

**CSR 的压缩原理**:

```
原始邻接表:
Node 0: [(1, 2.5), (3, 1.2)]
Node 1: [(2, 3.0)]
Node 2: []
Node 3: [(0, 4.1), (1, 2.8)]

CSR 压缩后:
row_ptr = [0, 2, 3, 3, 5]        // 每行的起始+结束位置
col_idx = [1, 3, 2, 0, 1]       // 所有邻接点扁平化
values  = [2.5, 1.2, 3.0, 4.1, 2.8]

查询 Node 0 的邻居:
  start = row_ptr[0] = 0
  end   = row_ptr[1] = 2
  neighbors = col_idx[0..2] = [1, 3]  // O(k) 但缓存友好!
```

#### 特性

| 维度 | 数据 |
|------|------|
| **空间复杂度** | O(V + E)（比 AdjList 更紧凑） |
| **邻居查询** | O(k) **缓存极其友好** |
| **批量查询** | **O(k)** 使用 `batch_neighbors` |
| **构建方式** | 通过 `CSRBuilder` 一次性构建 |
| **修改能力** | ❌ **只读**（构建后不可修改）|
| **实现的 Trait** | GraphReadable + GraphBatchReadable (+GraphDirected) |

#### 适用场景

- ✅ **大规模静态图**（V > 100,000）
- ✅ **PageRank 计算**（批量邻居查询）
- ✅ **图神经网络 (GNN)** 特征聚合
- ✅ **社交网络分析**（Twitter/Facebook 规模）

#### 代码示例

```moonbit
// 使用 Builder 模式构建 CSR（不可变）
let mut builder = @storage.CSRBuilder::new()

// 添加节点
builder = builder.add_node(@core.NodeId(0), 0.9)
builder = builder.add_node(@core.NodeId(1), 0.7)
builder = builder.add_node(@core.NodeId(2), 0.85)

// 添加边（可无序添加）
builder = builder.add_edge(@core.NodeId(0), @core.NodeId(1), 1.0)
builder = builder.add_edge(@core.NodeId(0), @core.NodeId(2), 2.0)
builder = builder.add_edge(@core.NodeId(1), @core.NodeId(2), 3.0)

// 构建 CSR（内部会排序优化）
match builder.build() {
  Ok(csr_graph) => {
    println("CSR 构建成功!")
    println("节点数: ${@core.GraphReadable::node_count(csr_graph)}")

    // 使用批量接口加速查询
    let ids = [@core.NodeId(0), @core.NodeId(1)]
    let batches = @core.GraphBatchReadable::batch_neighbors(csr_graph, ids)
    for (i, neighbors) in batches.indexed() {
      println("节点 ${ids[i]} 的邻居: ${neighbors}")
    }
  }
  Err(e) => println("构建失败: ${e}")
}
```

#### 优势与限制

**优势**:
- 🚀 **缓存极致优化**: 连续内存布局，CPU 预取友好
- 💾 **空间紧凑**: 无指针开销，比 AdjList 省 30-50%
- ⚡ **批量查询快**: `batch_neighbors` 利用 SIMD 加速
- 📈 **可扩展至亿级节点**

**限制**:
- 🚫 **不可修改**: 构建后为只读
- 🏗️ **构建成本高**: 需要排序和去重（O(E log E)）
- ❌ **不适合动态图**: 无法增删边

---

### 5. CSC - 压缩稀疏列（Compressed Sparse Column）

CSR 的**转置版本**，专为**入边密集查询**优化。

#### 数据结构

与 CSR 对称，但按**列（目标节点）**组织数据：
- `col_ptr`: 每个节点的入边起始位置
- `row_idx`: 入边的源节点
- `values`: 入边权重

#### 与 CSR 的对比

| 维度 | CSR | CSC |
|------|-----|-----|
| **核心优化** | 出边查询（`successors`） | 入边查询（`predecessors`）|
| **典型场景** | PageRank 分发排名 | PageRank 收集排名 |
| **空间** | O(V+E) | O(V+E) |
| **适用算法** | BFS/DFS 从源点出发 | 反向 BFS、入度统计 |

#### 适用场景

- ✅ **反向图遍历**（从终点找起点）
- ✅ **入度中心性计算**
- ✅ **HITS 算法**（权威值/枢纽值）
- ✅ **配合 CSR 使用**: 双向索引

#### 代码示例

```moonbit
// CSC 通常与 CSR 配合使用
let mut csc_builder = @storage.CSCBuilder::new()
csc_builder = csc_builder.add_node(@core.NodeId(0), 1.0)
csc_builder = csc_builder.add_node(@core.NodeId(1), 2.0)

// 添加边（注意：CSC 关注"谁指向我"）
csc_builder = csc_builder.add_edge(@core.NodeId(0), @core.NodeId(1), 5.0)  // 0→1
csc_builder = csc_builder.add_edge(@core.NodeId(2), @core.NodeId(1), 3.0)  // 2→1

match csc_builder.build() {
  Ok(csc) => {
    // 快速查询"谁指向节点 1"
    let preds = @core.GraphDirected::predecessors(csc, @core.NodeId(1))
    println("指向节点 1 的前驱:")
    preds |> iter::each(fn((src, w)) {
      println("  ← 节点 ${src} (权重: ${w})")
    })
  }
  Err(e) => println("错误: ${e}")
}
```

---

## 二、无向图存储

### 6. UndirectedAdjList - 无向邻接表 ⭐

**无向图的默认选择**，通过**半存储优化**节省 50% 边空间。

#### 核心优化

无向图中边 `{u, v}` 只需存储一次（而非有向的两条 `u→v` + `v→u`）：

```moonbit
pub(all) struct UndirectedAdjList {
  mut node_cnt : Int
  mut edge_cnt : Int
  nodes : Array[@core.Node?]
  adj   : Array[Array[(NodeId, Double)]]  // 单一邻接表
}
```

**空间节省**: O(V + E) 而非 O(V + 2E)

#### 特性

| 维度 | 数据 |
|------|------|
| **空间复杂度** | **O(V + E)** （比有向版省 ~50%）|
| **邻居查询** | O(k) |
| **实现的 Trait** | GraphWritable + GraphDirected |

#### 适用场景

- ✅ **无向社交网络**（好友关系）
- ✅ **物理网络**（道路、电路）
- ✅ **生物信息学**（蛋白质相互作用）
- ✅ **MST/Kruskal**（无向图专属）

#### 代码示例

```moonbit
let mut g = @storage.UndirectedAdjList::new()

// 添加节点
let a = @core.GraphWritable::add_node(g, 0.0)
let b = @core.GraphWritable::add_node(g, 0.0)
let c = @core.GraphWritable::add_node(g, 0.0)

// 添加无向边（自动处理对称性）
@core.GraphWritable::add_edge(g, a, b, 10.0) |> ignore  // A-B
@core.GraphWritable::add_edge(g, b, c, 20.0) |> ignore  // B-C
@core.GraphWritable::add_edge(g, a, c, 15.0) |> ignore  // A-C

// 查询邻居（无向：neighbors == in_neighbors == out_neighbors）
println("A 的邻居:")
@core.GraphReadable::neighbors_with_weight(g, a)
  |> iter::each(fn((nbr, w)) {
    println("  ↔ ${nbr} (${w})")
  })
```

---

### 7. UndirectedMatrix - 无向邻接矩阵

**对称矩阵优化**，仅存储上三角或下三角。

#### 特性

| 维度 | 数据 |
|------|------|
| **空间复杂度** | **O(V²/2)** （利用对称性）|
| **边查询** | O(1) |
| **适用规模** | V < 5000（否则内存爆炸）|

#### 适用场景

- ✅ 小型无向完全图
- ✅ 图像分割（像素网格）
- ✅ 密集无向图算法

---

### 8. UndirectedEdgeList - 无向边集数组

EdgeList 的无向版本，用于**无向 Kruskal**。

#### 特性

- 空间: O(V + E/2)
- 专用于无向 MST 场景

---

## 三、横向对比总表

### 复杂度对比

| 操作 | AdjList | Matrix | EdgeList | CSR | CSC |
|------|---------|--------|----------|-----|-----|
| **空间** | O(V+2E) | O(V²) | O(V+E) | O(V+E) | O(V+E) |
| **contains_edge** | O(k) | **O(1)** | O(E) | O(log k)* | O(log k)* |
| **neighbors** | O(k) | O(V) | O(E) | **O(k)** | O(E) |
| **add_node** | O(1)* | O(V) 重分配 | O(1) | ❌ | ❌ |
| **add_edge** | O(1)* | O(1) | O(1)* | ❌ | ❌ |
| **remove_edge** | O(k) | O(1) | O(E) | ❌ | ❌ |
| **in_degree** | **O(1)** | O(V) | O(E) | O(k) | **O(1)** |
| **out_degree** | **O(1)** | O(V) | O(E) | **O(1)** | O(k) |
| **batch_query** | O(k·q) | O(V·q) | O(E·q) | **O(k)** | O(k) |
| **sorted_edges** | O(E log E) | O(V² log V) | **O(E log E)** | O(E log E) | O(E log E) |

> \* 均摊复杂度  
> \* 二分查找（如果实现优化）

### 功能特性对比

| 特性 | AdjList | Matrix | EdgeList | CSR | CSC |
|------|:-------:|:------:|:--------:|:---:|:---:|
| **动态增删** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **双向索引** | ✅ | N/A | ❌ | ✅ | ✅ |
| **批量优化** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **边排序** | ❌ | ❌ | ✅ | ❌ | ❌ |
| **GraphFull** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **GraphBatch** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **GraphEdgeIter** | ❌ | ❌ | ✅ | ❌ | ❌ |

### 内存占用估算（V=100万, E=1000万）

| 存储 | 理论内存 | 实际估算 | 可否装入 16GB 内存？ |
|------|---------|---------|------------------|
| **DirectedAdjList** | ~480 MB | ~600 MB | ✅ 轻松 |
| **DirectedMatrix** | **8 TB** | - | ❌ 不可能 |
| **EdgeList** | ~320 MB | ~400 MB | ✅ 充裕 |
| **CSR** | ~280 MB | ~350 MB | ✅ 最优 |
| **CSC** | ~280 MB | ~350 MB | ✅ 最优 |

---

## 四、选型速查表

### 按场景选择

| 你的需求 | 推荐存储 | 原因 |
|----------|---------|------|
| **通用有向图** | **DirectedAdjList** ⭐ | 均衡性能，功能完整 |
| **无向社交网络** | **UndirectedAdjList** ⭐ | 半存储优化，省 50% |
| **稠密小图 (<1000 节点)** | DirectedMatrix | O(1) 边查询 |
| **Kruskal MST** | EdgeList / UndirectedEdgeList | 天然支持边排序 |
| **大规模静态图 (>10 万节点)** | **CSR** | 缓存友好，空间紧凑 |
| **PageRank 计算** | CSR 或 CSC | 批量查询优化 |
| **反向图遍历** | CSC | 入边 O(1) 查询 |
| **算法竞赛** | DirectedMatrix | O(1) 随机访问 |
| **内存受限** | CSR 或 EdgeList | 最紧凑存储 |
| **需要动态更新** | AdjList 系列 | 支持增删 |

### 按算法选择

| 算法 | 推荐存储 | 关键操作 |
|------|---------|----------|
| **BFS/DFS** | AdjList / CSR | 邻居迭代 |
| **Dijkstra** | AdjList | decrease_key 优先队列 |
| **Floyd-Warshall** | Matrix | O(1) 边查询 |
| **Kruskal MST** | EdgeList | 边排序 |
| **Prim MST** | AdjList | 切割边提取 |
| **PageRank** | CSR/CSC | 批量邻居 + 入边 |
| **Tarjan SCC** | AdjList | DFS + 低栈 |
| **Edmonds-Karp** | AdjList | BFS 层次图 |
| **Dinic** | AdjList | 当前弧优化 |
| **Hopcroft-Karp** | AdjList | 交替层遍历 |

---

## 五、最佳实践

### 1. 默认选择 AdjList

除非你有明确的性能瓶颈，否则**始终从 AdjList 开始**：

```moonbit
// ✅ 推荐：先用 AdjList 开发原型
let g = @storage.DirectedAdjList::new()
// ... 开发算法 ...

// 性能 profiling 后再决定是否迁移到 CSR
// if (graph_size > 100_000 && is_static) {
//   convert_to_csr(g)
// }
```

### 2. 大规模图用 CSR Builder

对于静态大图，使用 Builder 模式一次性构建：

```moonbit
// ✅ 正确: Builder 模式
let mut builder = @storage.CSRBuilder::new()
// ... 批量添加节点和边 ...
let csr = builder.build()  // 一次性优化

// ❌ 错误: 尝试动态修改 CSR
// let csr = csr.add_node(...)  // 编译错误！
```

### 3. 混合使用策略

在算法不同阶段使用不同存储：

```moonbit
// 阶段 1: 用 AdjList 动态构建图
let adj = build_graph_from_data()

// 阶段 2: 转换为 CSR 进行批量计算
let csr = @storage.converter::adj_list_to_csr(adj)

// 阶段 3: 运行 PageRank（利用 batch_neighbors）
let ranks = pagerank::compute(csr, iterations=100)
```

### 4. 无向图优先 UndirectedAdjList

如果你的图是无向的，**务必使用无向版本**：

```moonbit
// ✅ 正确: 无向图用无向存储
let undirected_g = @storage.UndirectedAdjList::new()
// 空间减半！

// ❌ 错误: 无向图用有向存储（浪费 2 倍空间）
let directed_g = @storage.DirectedAdjList::new()
// 每条边存两次...
```

---

## 下一步

理解了存储选项后，你可以：

- **[场景化选型决策树](/core-concepts/storage-decision/)** - 回答问题帮你选择
- **[性能基准测试](/core-concepts/benchmarks/)** - 查看实际 benchmark 数据
- **[存储转换器使用](/core-concepts/storage-converter/)** - 学习如何在存储间转换
- **[创建第一个图](/getting-started/first-graph/)** - 动手实践

---

<div class="callout" data-color="note">
  <div class="callout-header">
    <span class="callout-icon">📖</span>
    <p class="callout-title">深入阅读</p>
  </div>
  <div class="callout-content">
    <p><strong>源码位置：</strong></p>
    <ul>
      <li><code>lib/storage/directed_adj_list.mbt</code> - 有向邻接表（237 行）</li>
      <li><code>lib/storage/csr.mbt</code> - 压缩稀疏行（312 行）</li>
      <li><code>lib/storage/converter.mbt</code> - 8 个转换函数</li>
    </ul>
  </div>
</div>
