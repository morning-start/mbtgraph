# storage — 图数据存储实现层

> **定位**: mbtgraph 的数据存储层，提供 **8 种图存储结构**的实现，覆盖有向/无向、稀疏/稠密、动态/静态等不同场景。
>
> **依赖**: [`@core`](../core/)（类型定义 + Trait 接口）

---

## 存储总览

```txt
storage/
├── 有向图存储
│   ├── directed_adj_list.mbt    ⭐ 邻接表（推荐默认选择）
│   ├── directed_matrix.mbt       邻接矩阵（小规模稠密图）
│   └── edge_list.mbt            边集数组（Kruskal 友好）
│
├── 无向图存储
│   ├── undirected_adj_list.mbt  ⭐ 邻接表（半存储优化）
│   ├── undirected_matrix.mbt     邻接矩阵（半存储优化）
│   └── undirected_edge_list.mbt 边集数组（无向版）
│
├── 只读高性能存储
│   ├── csr.mbt                   🚀 压缩稀疏行（亿级节点）
│   └── csc.mbt                   🚀 压缩稀疏列（入边密集场景）
│
├── 格式转换器
│   └── converter.mbt            10 个泛型转换函数（三层语义安全架构）
│
└── 公共工具
    └── shared_helpers.mbt       4 个辅助函数
```

---

## 快速选择指南

| 你的需求                       | 推荐存储                  | 创建方式                     |
| ------------------------------ | ------------------------- | ---------------------------- |
| **通用目的（有向）**           | `DirectedAdjList`         | `new_directed()`             |
| **通用目的（无向）**           | `UndirectedAdjList`       | `new_undirected()`           |
| **小规模稠密图 (<1000 节点）** | `DirectedMatrix`          | `new_directed_matrix(cap)`   |
| **大规模静态图 (>10K 节点）**  | `CSRGraph`                | 通过 `to_csr()` 转换         |
| **入边密集查询**               | `CSCGraph`                | 通过 `to_csc()` 转换         |
| **Kruskal / 最小生成树**       | `UndirectedEdgeListGraph` | `new_undirected_edge_list()` |
| **格式互转**                   | Converter 函数            | 见下方转换器章节             |

---

## 各存储详解

### 1. DirectedAdjList — 有向邻接表 ⭐

**文件**: [directed_adj_list.mbt](directed_adj_list.mbt)

最适合大多数有向图场景。维护正向+反向双邻接表，支持 O(deg) 的入边/出边查询。

```moonbit
let g = new_directed()
let a = @core.GraphWritable::add_node(g, 1.0)
let b = @core.GraphWritable::add_node(g, 2.0)
@core.GraphWritable::add_edge(g, a, b, 3.14) |> ignore

// 有向图特有能力
@core.GraphDirected::in_neighbors(g, b)    // 入邻居
@core.GraphDirected::out_degree(g, a)      // 出度
@core.GraphDirected::predecessors(g, b)    // 前驱（带权）
```

| 特征       | 值                                 |
| ---------- | ---------------------------------- |
| 空间复杂度 | O(V + 2E)                          |
| 添加边     | O(1)                               |
| 查询边     | O(deg(v))                          |
| Trait      | Readable + Writable + **Directed** |

---

### 2. UndirectedAdjList — 无向邻接表（半存储优化）⭐

**文件**: [undirected_adj_list.mbt](undirected_adj_list.mbt)

采用**左上角三角存储法**：每条无向边仅存一次，节省 ~50% 内存。

```moonbit
let g = new_undirected()
let a = @core.GraphWritable::add_node(g, 1.0)
let b = @core.GraphWritable::add_node(g, 2.0)
@core.GraphWritable::add_edge(g, a, b, 3.14) |> ignore

// 双向查询均命中
@core.GraphReadable::contains_edge(g, a, b)  // true
@core.GraphReadable::contains_edge(g, b, a)  // true

// 支持 Kruskal 友好的边排序
@core.GraphEdgeIterable::edges_sorted(g)
```

| 特征       | 值                                     |
| ---------- | -------------------------------------- |
| 空间复杂度 | O(V + E)（比有向版省一半）             |
| 半存储策略 | 边 (u,v) 存于 `adj[min(u,v)]`          |
| Trait      | Readable + Writable + **EdgeIterable** |

---

### 3. DirectedMatrix — 有向邻接矩阵

**文件**: [directed_matrix.mbt](directed_matrix.mbt)

适合小规模稠密图。**O(1) 边查询**，但需预分配容量且邻居遍历为 O(V)。

```moonbit
// 必须指定容量
let g = new_directed_matrix(100)
let id = @core.GraphWritable::add_node(g, 42.0)
// matrix[id][target] 查询 O(1)
```

| 特征       | 值          |
| ---------- | ----------- |
| 空间复杂度 | O(V²)       |
| 边查询     | **O(1)** ✨ |
| 邻居遍历   | O(V)        |
| 适用规模   | V < 1000    |

---

### 4. UndirectedMatrix — 无向邻接矩阵（半存储优化）

**文件**: [undirected_matrix.mbt](undirected_matrix.mbt)

采用**上三角存储法**：无向边仅存于 `matrix[min(u,v)][max(u,v)]`，节省约 50% 矩阵空间。

| 特征       | 值              |
| ---------- | --------------- |
| 空间复杂度 | O(V²/2) ≈ O(V²) |
| 边查询     | **O(1)**        |
| 适用规模   | V < 1000        |

---

### 5. CSRGraph — 压缩稀疏行格式 🚀

**文件**: [csr.mbt](csr.mbt)

**只读格式**，适合亿级节点的大规模静态图。内存效率极高，缓存局部性极佳。

通过 **Builder 模式** 构建：

```moonbit
let builder = CSRBuilder::new()
let b1 = builder.add_node(@core.NodeId(0), 10.0)
let b2 = b1.add_edge(@core.NodeId(0), @core.NodeId(1), 3.14)
let csr = b2.build()  // 构建后不可修改
```

**内部结构**（三数组压缩）:

```txt
原始: Node0 → [(1, 2.0), (3, 1.5)]
CSR:  row_ptr=[0,2,...], col_idx=[1,3], values=[2.0,1.5]
```

| 特征       | 值                                          |
| ---------- | ------------------------------------------- |
| 空间复杂度 | O(V + E)（最优）                            |
| 邻居遍历   | O(deg(v))                                   |
| 可变性     | ❌ **只读**（LSP）                          |
| Trait      | Readable + **BatchReadable** + **Directed** |

**批量查询 API**:

```moonbit
@core.GraphBatchReadable::batch_neighbors(csr, ids)   // 批量邻居
@core.GraphBatchReadable::batch_edges(csr, pairs)     // 批量边权
```

**有向图 API**（CSR 同样支持 `GraphDirected`）:

```moonbit
@core.GraphDirected::out_neighbors(node)   // O(deg_out) — 行遍历，极快 ✨
@core.GraphDirected::in_degree(node)       // O(E) — 需全扫描
@core.GraphDirected::successors(node)      // 带权出边列表
```

> **CSR vs CSC 复杂度互补**: CSR 的 `out_*` 是 O(1)/O(deg)，`in_*` 是 O(E)；CSC 正好相反。

---

### 6. CSCGraph — 压缩稀疏列格式 🚀

**文件**: [csc.mbt)(csc.mbt)

CSR 的**转置变体**：按目标节点（列）压缩而非源节点（行）。适合**入边遍历密集**的场景（如反向 PageRank）。

| 特征     | CSR                 | CSC                   |
| -------- | ------------------- | --------------------- |
| 压缩维度 | 行（源节点/from）   | 列（目标节点/to）     |
| 主指针   | `row_ptr[i]`        | `col_ptr[j]`          |
| 副索引   | `col_idx[k]` → 目标 | `row_idx[k]` → 源     |
| 最优操作 | 出边遍历            | **入边遍历**          |
| 典型场景 | BFS/DFS/PageRank    | 反向PageRank/入度查询 |

同样通过 Builder 构建，同样为**只读格式**。

**有向图 API**（CSC 的 `in_*` 操作是 O(1)/O(deg)，与 CSR 互补）:

```moonbit
@core.GraphDirected::in_neighbors(node)    // O(deg_in) — 列遍历，极快 ✨
@core.GraphDirected::in_degree(node)      // O(1) — 指针差，常数时间 ✨
@core.GraphDirected::predecessors(node)   // 带权入边列表
```

---

### 7. EdgeListGraph — 有向边集数组

**文件**: [edge_list.mbt](edge_list.mbt)

最简单的存储：所有边存于一个连续数组。天然支持排序，但边查询为 O(E)。

```moonbit
let g = new_edge_list()
@core.GraphWritable::add_node(g, 1.0) |> ignore
@core.GraphWritable::add_node(g, 2.0) |> ignore
@core.GraphWritable::add_edge(g, a, b, 5.0) |> ignore

// Kruskal 核心：按权值排序的边
@core.GraphEdgeIterable::edges_sorted(g)
```

| 特征       | 值                                     |
| ---------- | -------------------------------------- |
| 空间复杂度 | O(V + E)                               |
| 添加边     | O(1)                                   |
| 查询边     | O(E)（线性扫描）                       |
| Trait      | Readable + Writable + **EdgeIterable** |

---

### 8. UndirectedEdgeListGraph — 无向边集数组

**文件**: [undirected_edge_list.mbt](undirected_edge_list.mbt)

无向版的边集数组。与有向版的核心差异在于**所有查询双向匹配**：

| 方法                 | 有向版     | 无向版         |
| -------------------- | ---------- | -------------- |
| `is_directed()`      | `true`     | **`false`**    |
| `contains_edge(f,t)` | 仅 `f→t`   | **`f↔t` 双向** |
| `neighbors(id)`      | 仅出边目标 | **入边+出边**  |
| `degree(id)`         | 仅出度     | **总度数**     |

---

## 格式转换器

**文件**: [converter.mbt](converter.mbt)

基于 **trait 约束分层** 的 **10 个泛型转换函数**，语义安全地支持存储结构互转：

### 三层架构

| 层级           | 约束                        | 函数数 | 保护机制                                        |
| -------------- | --------------------------- | :----: | ----------------------------------------------- |
| **有向转换组** | `[G : GraphDirected]`       |   5    | ✅ **编译期**保证源是有向图                     |
| **无向转换组** | `[G : GraphReadable] raise` |   3    | ✅ **运行时** `assert_true(!is_directed)` panic |
| **语义转换**   | `[G : GraphReadable] raise` |   2    | 函数名即文档，用户明确知情                      |

### 有向图存储结构互转（编译期安全）

> 源类型必须实现 `GraphDirected` trait（如 DirectedAdjList、CSRGraph、CSCGraph 等）。
> 如果传入无向图，**编译期直接报错**。

| 目标类型        | 函数签名                     | 需要容量参数？ |
| --------------- | ---------------------------- | :------------: |
| DirectedAdjList | `to_directed_adj_list(g)`    |       ❌       |
| DirectedMatrix  | `to_directed_matrix(g, cap)` |       ✅       |
| CSRGraph        | `to_csr(g)`                  |       ❌       |
| CSCGraph        | `to_csc(g)`                  |       ❌       |
| EdgeListGraph   | `to_edge_list(g)`            |       ❌       |

### 无向图存储结构互转（运行时保护）

> 源类型必须满足 `is_directed() == false`，否则运行时 **panic**。

| 目标类型                | 函数签名                             | 需要容量参数？ |
| ----------------------- | ------------------------------------ | :------------: |
| UndirectedAdjList       | `to_undirected_adj_list(g) raise`    |       ❌       |
| UndirectedMatrix        | `to_undirected_matrix(g, cap) raise` |       ✅       |
| UndirectedEdgeListGraph | `to_undirected_edge_list(g) raise`   |       ❌       |

### 显式语义转换（跨有向/无向边界）

> 用户通过函数名显式表达意图，不与结构转换混淆。

| 函数                     | 行为                                                 | 典型用途                         |
| ------------------------ | ---------------------------------------------------- | -------------------------------- |
| `as_undirected(g) raise` | 有向→无向：`(a→b, w)` → `{a-b, w}`，双向边自动去重   | 算法需要无向输入但数据源是有向的 |
| `as_directed(g) raise`   | 无向→有向：`{a-b, w}` → `(a→b, w)`，**不生成反向边** | 算法需要有向输入但数据源是无向的 |

```moonbit
// 结构优化：同一语义内切换存储格式
let csr = to_csr(my_directed_adj_list)        // AdjList → CSR（出边友好）
let csc = to_csc(csr)                         // CSR → CSC（入边友好）
let mat = to_directed_matrix(csc, 1000)        // CSC → Matrix

// 语义转换：跨有向/无向边界（用户明确知情）
let undirected = as_undirected(my_dag)         // DAG → 无向图（丢失方向信息）
let directed   = as_directed(my_undirected)    // 无向 → 有向（每条边只保留一个方向）

// Round-trip：无损验证
let roundtrip = to_directed_adj_list(to_csr(original))
```

### 设计原则

- **结构转换 ≠ 语义转换**：`to_xxx` 只做同语义内的格式优化；跨边界必须用 `as_*`
- **编译期优先**：有向组用 `GraphDirected` 约束，零运行时开销
- **防御性编程**：无向组和语义转换用 `assert_true` + `raise` 保护

---

## 公共工具函数

**文件**: [shared_helpers.mbt](shared_helpers.mbt)

所有存储实现复用的辅助逻辑：

| 函数                             | 功能               | 使用者                        |
| -------------------------------- | ------------------ | ----------------------------- |
| `has_node(nodes, idx)`           | 检查位置是否有节点 | 所有 `contains_node()`        |
| `find_slot(nodes, i, n)`         | 查找第一个空闲槽位 | 所有 `add_node()`（空洞复用） |
| `remove_from_list(list, target)` | 从邻接表中移除条目 | 所有 `remove_edge()`          |
| `bubble_sort_by_weight(edges)`   | 按权值冒泡排序     | `edges_sorted()` 实现         |

---

## 性能对比

### 时间复杂度

| 操作              | AdjList   | Matrix   | CSR          | CSC          | EdgeList |
| ----------------- | --------- | -------- | ------------ | ------------ | -------- |
| `add_node()`      | O(1)\*    | O(1)     | Builder only | Builder only | O(1)\*   |
| `remove_node()`   | O(deg(v)) | O(V)     | ❌           | ❌           | O(E)     |
| `add_edge()`      | O(1)      | O(1)     | Builder only | Builder only | O(1)     |
| `remove_edge()`   | O(deg(v)) | O(1)     | ❌           | ❌           | O(E)     |
| `contains_edge()` | O(deg(v)) | **O(1)** | O(deg_out)   | O(deg_in)    | O(E)     |
| `get_edge()`      | O(deg(v)) | **O(1)** | O(deg_out)   | O(deg_in)    | O(E)     |
| `neighbors()`     | O(deg(v)) | O(V)     | O(deg_out)   | O(E)         | O(E)     |
| `degree()`        | O(1)      | O(V)     | **O(1)**     | O(E)         | O(E)     |
| `in_degree()`     | O(1)\*    | O(V)     | O(E)         | **O(1)** ✨  | O(E)     |
| `out_degree()`    | O(1)      | O(V)     | **O(1)** ✨  | O(E)         | O(E)     |
| `memory`          | O(V+E)    | O(V²)    | **O(V+E)**   | **O(V+E)**   | O(V+E)   |

> \*均摊复杂度

### 空间复杂度

| 存储     | 有向      | 无向（半存储优化） |
| -------- | --------- | ------------------ |
| AdjList  | O(V + 2E) | O(V + E)           |
| Matrix   | O(V²)     | O(V²/2)            |
| CSR/CSC  | O(V + E)  | N/A（仅支持有向）  |
| EdgeList | O(V + E)  | O(V + E)           |

---

## 最佳实践

### 节点管理

```moonbit
// ✅ 正确：使用 add_node 返回的 ID
let id = @core.GraphWritable::add_node(g, data)
@core.GraphWritable::add_edge(g, id, other_id, w) |> ignore

// ❌ 错误：不要假设 ID 连续
let id = @core.NodeId(0)  // 可能已被删除
```

### 错误处理

```moonbit
// ✅ 完整处理 Result
match @core.GraphWritable::add_edge(g, f, t, w) {
  Ok(_) => ()
  Err(@core.GraphError::NodeNotFound(id)) => println("缺失: ${id}")
  Err(@core.GraphError::EdgeAlreadyExists(a, b)) => println("重复: ${a}→${b}")
  Err(@core.GraphError::InvalidNodeId) => println("无效 ID")
}

// ✅ 确定不会失败时丢弃结果
@core.GraphWritable::add_node(g, 1.0) |> ignore
```

### Trait 方法调用

```moonbit
// ✅ 始终使用完全限定名
@core.GraphReadable::node_count(g)
@core.GraphWritable::add_edge(g, f, t, w) |> ignore
@core.GraphDirected::in_degree(g, id)

// ❌ 不要 use 别名
use @core.{GraphReadable}  // 禁止！
```

---

## 已知限制

| 限制             | 影响                   | 解决方案                       |
| ---------------- | ---------------------- | ------------------------------ |
| CSR/CSC 不可修改 | 无法动态增删           | 先动态构建再 `to_csr()` 转换   |
| 矩阵需预分配容量 | 不能动态扩容           | 提前评估最大节点数             |
| 冒泡排序         | 大规模边集慢           | 中小规模够用，后续可替换快排   |
| 节点 ID 为整数   | 不支持字符串键         | 外部维护映射表                 |
| 无多重边支持     | 同一对节点只能有一条边 | 按需使用 EdgeList + 自定义逻辑 |

---

## 相关文档

- **核心类型与 Trait**: [`../core/README.md`](../core/README.md)
- **项目规范**: [`../../AGENTS.md`](../../AGENTS.md)
- **架构设计**: [`../../docs/design/graph_trait_and_module_architecture.md`](../../docs/design/graph_trait_and_module_architecture.md)
- **调研报告**: [`../../docs/design/graph_storage_survey.md`](../../docs/design/graph_storage_survey.md)
- **详细技术文档**: [`../../docs/packages/storage_package_doc.md`](../../docs/packages/storage_package_doc.md)
