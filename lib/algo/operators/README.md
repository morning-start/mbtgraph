# 图算子模块 (`operators`)

> **版本**: v0.2.0 | **状态**: 稳定 | **测试**: 28 通过

提供 11 种图运算操作（图算子），覆盖四大类别的经典图变换：

| 类别 | 算子 | 数量 |
|:----:|------|:----:|
| **基础运算** | 补图 (complement)、反转 (reverse) | 2 |
| **集合运算** | 并集 (union)、交集 (intersection)、差集 (difference) | 3 |
| **图积运算** | 笛卡尔积 (cartesian)、张量积 (tensor)、字典序积 (lexicographic) | 3 |
| **高级运算** | 线图 (line_graph)、收缩 (contract)、幂图 (power_graph) | 3 |

所有算子基于 `@core.GraphReadable` trait 泛型实现，返回具体存储类型（`UndirectedAdjList` / `DirectedAdjList`），支持任意存储后端的图输入。

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | GraphReadable trait + NodeId/Node 类型 |
| [`@storage`](../storage/) | UndirectedAdjList / DirectedAdjList 具体存储 |

## 文件结构

```
lib/algo/operators/
├── moon.pkg              # 包配置
├── operators.mbt         # 11 种算子实现 + 4 个私有辅助函数
└── operators_test.mbt    # 完整测试套件 (22 tests)
```

## API 总览

### 📐 基础运算（一元算子）

作用于单个图，产生新图。

#### `complement` — 补图 $\overline{G}$

```moonbit
pub fn[G : @core.GraphReadable] complement(graph : G) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $V(\overline{G}) = V(G)$, $E(\overline{G}) = \binom{V}{2} \setminus E(G)$ |
| **复杂度** | O(V²) |
| **返回类型** | `UndirectedAdjList` |
| **直觉解释** | 保留所有顶点，将"有边"变"无边"，"无边"变"有边" |

**应用场景**：
- 团检测：$\overline{G}$ 的独立集 ↔ $G$ 的团
- 图同构判定：$G \cong H \Leftrightarrow \overline{G} \cong \overline{H}$
- 社交网络分析：补图揭示"非直接关系"的潜在结构

---

#### `reverse` — 反转图 $G^R$

```moonbit
pub fn[G : @core.GraphReadable] reverse(graph : G) -> @storage.DirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $E(G^R) = \{(v, u) \mid (u, v) \in E(G)\}$ |
| **复杂度** | O(V + E) |
| **返回类型** | `DirectedAdjList` |
| **直觉解释** | 所有有向边方向取反，顶点集不变 |

**应用场景**：
- 强连通分量（Kosaraju 算法的核心步骤）
- 链接分析（反向链接计算）
- 可达性逆向查询

---

### 🔗 集合运算（二元算子）

作用于两个图，产生新图。

#### `graph_union` — 并图 $G_1 \cup G_2$

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_union(a : G1, b : G2) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $V = V_1 \cup V_2$, $E = E_1 \cup E_2$ |
| **复杂度** | O(V₁ + V₂ + E₁ + E₂) |
| **返回类型** | `UndirectedAdjList` |
| **直觉解释** | 合并两个图的顶点和边，重复边只保留一条 |

---

#### `graph_intersection` — 交图 $G_1 \cap G_2$

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_intersection(a : G1, b : G2) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $V = V_1$, $E = E_1 \cap E_2$（仅保留两图共有的边）|
| **复杂度** | O(V₁ + V₂ + E₁) |
| **返回类型** | `UndirectedAdjList` |
| **权重策略** | 优先使用 $G_2$ 的权重，回退到 $G_1$ |

---

#### `graph_difference` — 差图 $G_1 \setminus G_2$

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] graph_difference(a : G1, b : G2) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $V = V_1$, $E = E_1 \setminus E_2$（仅在 $G_1$ 中出现的边）|
| **复杂度** | O(V₁ + E₁) |
| **返回类型** | `UndirectedAdjList` |
| **直觉解释** | 从 $G_1$ 中删除与 $G_2$ 重叠的边 |

---

### 🔲 图积运算（二元算子）

两个图的乘积，产生更大的组合图。

#### `cartesian_product` — 笛卡尔积 $G_1 \square G_2$

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] cartesian_product(a : G1, b : G2) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $V = V_1 \times V_2$, 边: $(u_1,v_1)\text{-}(u_2,v_2) \Leftrightarrow (u_1\!=\!u_2 \land (v_1,v_2)\!\in\!E_2) \lor (v_1\!=\!v_2 \land (u_1,u_2)\!\in\!E_1)$ |
| **节点编码** | $(i, j) \mapsto \texttt{NodeId}(i \cdot n_2 + j)$ |
| **复杂度** | O(V₁·E₂ + V₂·E₁) |
| **返回类型** | `UndirectedAdjList` |
| **经典结果** | $P_m \square P_n = Q_{m,n}$（网格图）、$K_2 \square C_n = P_{2n}$（棱柱图）|

**直觉解释**：想象 $G_1$ 的每个节点被替换为一份 $G_2$ 的副本，副本间按 $G_1$ 的边连接。

---

#### `tensor_product` — 张量积 $G_1 \times G_2$（Kronecker 积）

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] tensor_product(a : G1, b : G2) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $V = V_1 \times V_2$, 边: $(u_1,v_1)\text{-}(u_2,v_2) \Leftrightarrow (u_1,u_2)\!\in\!E_1 \land (v_1,v_2)\!\in\!E_2$ |
| **权重合成** | $w = w_1 + w_2$（两边权重之和）|
| **复杂度** | O(E₁ · E₂) |
| **返回类型** | `UndirectedAdjList` |
| **经典结果** | $K_2 \times K_2 = 2K_2$（两条不相交的边）|

**直觉解释**：两个图各取一条边，组成积图中的一条边——"边的乘积"。

---

#### `lexicographic_product` — 字典序积 $G_1[G_2]$

```moonbit
pub fn[G1 : @core.GraphReadable, G2 : @core.GraphReadable] lexicographic_product(a : G1, b : G2) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $V = V_1 \times V_2$, 边: $(u_1,v_1)\text{-}(u_2,v_2) \Leftrightarrow (u_1,u_2)\!\in\!E_1 \lor (u_1\!=\!u_2 \land (v_1,v_2)\!\in\!E_2)$ |
| **复杂度** | O(V₁² · V₂² + V₁ · E₂ + V₂ · E₁) |
| **返回类型** | `UndirectedAdjList` |
| **特点** | 三种积中唯一使 $K_n[G_m] = K_{nm}$ 成立的积 |

**直觉解释**：先按 $G_1$ 分组（组间完全连接），组内按 $G_2$ 连接——最"稠密"的图积。

---

### ⚡ 高级运算

#### `line_graph` — 线图 $L(G)$

```moonbit
pub fn[G : @core.GraphReadable] line_graph(graph : G) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $V(L(G)) = E(G)$, 边: $e_1\text{-}e_2 \Leftrightarrow e_1 \cap e_2 \neq \emptyset$ |
| **复杂度** | O(E²) |
| **返回类型** | `UndirectedAdjList` |
| **经典结果** | $L(K_n) = K_{n(n-1)/2}$（完全图的线图是完全图）、$L(K_{1,n}) = K_n$（星图的线图是完全图）|

**直觉解释**：原图的每条边变成一个节点，共享端点的边之间连边——"边的关系图"。

**应用场景**：
- 路由问题：边着色 → 点着色
- Hamilton 圈判定：$G$ 有 Euler 回路 ⇔ $L(G)$ 有 Hamilton 圈
- 化学分子结构分析

---

#### `contract` — 边收缩 $G/uv$

```moonbit
pub fn[G : @core.GraphReadable] contract(graph : G, u : NodeId, v : NodeId) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **语义** | 将节点 $u$ 合并到节点 $v$ 中，移除 $u$ 及其关联的自环 |
| **复杂度** | O(V + E) |
| **返回类型** | `UndirectedAdjList` |
| **参数说明** | $u$ 被合并，$v$ 为目标保留节点 |

**行为细节**：
- 收缩边 $(u, v)$ 本身被删除（不产生自环）
- $u$ 的其他邻接点全部重连至 $v$
- 若重连产生 $(v, x)$ 自环则跳过该边

**应用场景**：
- 最小割算法（Stoer-Wagner）
- 图的树宽/路径宽度计算
- 平面性测试

---

#### `power_graph` — 幂图 $G^k$

```moonbit
pub fn[G : @core.GraphReadable] power_graph(graph : G, k : Int) -> @storage.UndirectedAdjList
```

| 属性 | 说明 |
|:----:|------|
| **数学定义** | $V(G^k) = V(G)$, 边: $(u, v) \in E(G^k) \Leftrightarrow d_G(u, v) \leq k$ |
| **距离计算** | BFS 单源最短路 |
| **复杂度** | O(V · (V + E)) |
| **返回类型** | `UndirectedAdjList` |
| **特殊性质** | $G^1 = G$, $G^{\text{diam}(G)} = K_V$（完全图）|

**直觉解释**：在原图基础上，让"距离不超过 k"的节点对也连上边——图的"模糊化"或"闭包"。

**应用场景**：
- 小世界网络建模
- 图的平方根问题（是否存在 $H$ 使 $H^2 = G$）
- 广播/ gossip 协议分析

## 使用示例

### 基础用法：补图与幂图

```moonbit
// 构建路径图 P3: 0 -- 1 -- 2
let g = @storage.new_undirected()
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore

// 补图: 仅剩边 0--2
let c = complement(g)
@core.GraphReadable::edge_count(c)     // => 1

// 幂图 k=2: 距离 ≤ 2 全部连通 → K3
let p = power_graph(g, 2)
@core.GraphReadable::edge_count(p)     // => 3
```

### 有向图反转

```moonbit
// 构建有向三角形: 0→1→2→0
let dg = @storage.new_directed()
@core.GraphWritable::add_node(dg, 0.0) |> ignore
@core.GraphWritable::add_node(dg, 0.0) |> ignore
@core.GraphWritable::add_node(dg, 0.0) |> ignore
@core.GraphWritable::add_edge(dg, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(dg, @core.NodeId(1), @core.NodeId(2), 2.0) |> ignore
@core.GraphWritable::add_edge(dg, @core.NodeId(2), @core.NodeId(0), 3.0) |> ignore

// 反转: 0←1←2←0
let rg = reverse(dg)
@core.GraphReadable::contains_edge(rg, @core.NodeId(1), @core.NodeId(0))  // => true
```

### 集合运算流水线

```moonbit
// 构建两个图
let a = make_path3()       // P3: 0-1-2
let b = make_triangle()    // K3: 0-1-2-0

// 并集: 合并所有边 (0-1, 1-2, 2-0)
let u = graph_union(a, b)
@core.GraphReadable::edge_count(u)     // => 3

// 交集: 共有边 (0-1, 1-2)
let i = graph_intersection(a, b)
@core.GraphReadable::edge_count(i)     // => 2

// 差集: a 有但 b 没有的边 (空集)
let d = graph_difference(a, b)
@core.GraphReadable::edge_count(d)     // => 0
```

### 图变换复合流水线

```moonbit
// 复合流水线: 原图 → 补图 → 与原图求交 → 取线图
let original = make_path3()            // P3: 2 edges

// Step 1: 补图 → 1 edge (0-2)
let comp = complement(original)

// Step 2: 与原图并集 → 3 edges (完整 K3)
let merged = graph_union(original, comp)

// Step 3: 线图 → L(K3) = K3 (3 nodes, 3 edges)
let lg = line_graph(merged)
@core.GraphReadable::node_count(lg)    // => 3
@core.GraphReadable::edge_count(lg)    // => 3
```

### 图积运算

```moonbit
// P2 □ P2 = C4 (4-环 / 正方形网格)
let p2_a = @storage.new_undirected()
@core.GraphWritable::add_node(p2_a, 0.0) |> ignore
@core.GraphWritable::add_node(p2_a, 0.0) |> ignore
@core.GraphWritable::add_edge(p2_a, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore

let p2_b = @storage.new_undirected()
@core.GraphWritable::add_node(p2_b, 0.0) |> ignore
@core.GraphWritable::add_node(p2_b, 0.0) |> ignore
@core.GraphWritable::add_edge(p2_b, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore

// 笛卡尔积: 4 节点 4 边 (正方形)
let cp = cartesian_product(p2_a, p2_b)
@core.GraphReadable::node_count(cp)    // => 4
@core.GraphReadable::edge_count(cp)    // => 4

// 张量积: 4 节点 2 边 (两条独立边)
let tp = tensor_product(p2_a, p2_b)
@core.GraphReadable::node_count(tp)    // => 4
@core.GraphReadable::edge_count(tp)    // => 2
```

### 边收缩

```moonbit
// P3: 0 -- 1 -- 2
let path = make_path3()

// 将节点 1 收缩到节点 0 → 结果: 0 -- 2 (单边)
let contracted = contract(path, @core.NodeId(1), @core.NodeId(0))
@core.GraphReadable::contains_edge(contracted, @core.NodeId(0), @core.NodeId(2))  // => true
@core.GraphReadable::contains_edge(contracted, @core.NodeId(0), @core.NodeId(1))  // => false
@core.GraphReadable::contains_edge(contracted, @core.NodeId(1), @core.NodeId(2))  // => false
```

### 双重补图恒等式验证

```moonbit
// 数学性质: complement(complement(G)) ≅ G
let original = make_path3()            // 2 edges
let c1 = complement(original)          // 1 edge
let c2 = complement(c1)                // 2 edges (恢复!)

assert(@core.GraphReadable::edge_count(c2) == @core.GraphReadable::edge_count(original))
```

## 算法原理

### 形式化定义速查表

| 算子 | 记号 | 顶点集 | 边条件 |
|:----:|:----:|--------|--------|
| 补图 | $\overline{G}$ | $V$ | $\{u,v\} \notin E(G)$ |
| 反转 | $G^R$ | $V$ | $(v,u) \in E(G)$ |
| 并图 | $G_1 \cup G_2$ | $V_1 \cup V_2$ | $e \in E_1 \lor e \in E_2$ |
| 交图 | $G_1 \cap G_2$ | $V_1$ | $e \in E_1 \land e \in E_2$ |
| 差图 | $G_1 \setminus G_2$ | $V_1$ | $e \in E_1 \land e \notin E_2$ |
| 笛卡尔积 | $G_1 \square G_2$ | $V_1 \times V_2$ | 同行∧邻列 或 同列∧邻行 |
| 张量积 | $G_1 \times G_2$ | $V_1 \times V_2$ | 两维同时邻接 |
| 字典序积 | $G_1[G_2]$ | $V_1 \times V_2$ | 行邻接 或 同行∧列邻接 |
| 线图 | $L(G)$ | $E(G)$ | 边共享端点 |
| 收缩 | $G/uv$ | $V \setminus \{u\}$ | 重连 $N(u)$ 到 $v$ |
| 幂图 | $G^k$ | $V$ | $d(u,v) \leq k$ |

### 三种图积对比

```
笛卡尔积 G₁ □ G₂:
  ┌─────────────────────┐
  │  (0,0)──(1,0)       │  ← 每个 G₁ 节点对应一行 G₂ 副本
  │   │      │          │  ← 行内按 G₂ 连接
  │  (0,1)──(1,1)       │  ← 列间按 G₁ 连接
  └─────────────────────┘

张量积 G₁ × G₂:
  (0,0)      (1,0)        ← 只有两维度都有边时才连接
    ╲        ╱
     ╲      ╱
  (0,1)      (1,1)

字典序积 G₁[G₂]:
  ┌─────────────────────┐
  │  (0,0)╲(1,0)╱(2,0)  │  ← 不同行之间全连接!
  │   │╲  ╳  ╱│         │  ← 行内按 G₂ 连接
  │  (0,1)╱(1,1)╲(2,1)  │  ← 最稠密的积
  └─────────────────────┘
```

### 复杂度汇总

| 算子 | 时间复杂度 | 空间复杂度 | 瓶颈因素 |
|:----:|:----------:|:----------:|----------|
| complement | O(V²) | O(V²) | 顶点对枚举 |
| reverse | O(V + E) | O(V + E) | 边遍历 |
| union | O(V₁+V₂+E₁+E₂) | O(V+E) | 合并去重 |
| intersection | O(V₁+V₂+E₁) | O(V+E) | 边查找 |
| difference | O(V₁+E₁) | O(V+E) | 边过滤 |
| cartesian_product | O(V₁·E₂+V₂·E₁) | O(V₁·V₂+E) | 双重循环 |
| tensor_product | O(E₁·E₂) | O(V₁·V₂+E₁·E₂) | 边的笛卡尔积 |
| lexicographic_product | O(V₁²·V₂²) | O(V₁·V₂+E) | 四重嵌套 |
| line_graph | O(E²) | O(E²) | 边对比较 |
| contract | O(V + E) | O(V + E) | 边重映射 |
| power_graph | O(V·(V+E)) | O(V²) | V 次 BFS |

## 内部组件

### 私有辅助函数

| 函数 | 功能 | 使用者 |
|------|------|--------|
| `copy_nodes()` | 将源图的所有节点复制到无向邻接表 | complement, power_graph |
| `copy_nodes_directed()` | 将源图的所有节点复制到有向邻接表 | reverse |
| `make_product_nodes()` | 创建 n₁ × n2 个节点的积图骨架 | cartesian_product, tensor_product, lexicographic_product |
| `collect_edges_bidi()` | 收集所有边（含双向对称边）用于积运算 | cartesian_product, tensor_product, lexicographic_product |

### 设计要点

1. **泛型输入，具体输出**：所有函数接受 `GraphReadable` trait 泛型参数，返回具体的 `UndirectedAdjList` 或 `DirectedAdjList`
2. **纯函数语义**：不修改输入图，每次调用创建全新实例
3. **统一节点复制**：通过 `copy_nodes` / `copy_nodes_directed` 统一处理节点数据迁移
4. **双向边收集**：`collect_edges_bidi` 自动为无向边生成对称表示，简化积运算逻辑
5. **积图节点编码**：采用行优先映射 `(i, j) ↦ i·n₂ + j`，支持 O(1) 坐标计算

## 边界行为

| 条件 | complement | reverse | union | intersection | difference | 积运算 | line_graph | contract | power_graph |
|------|:----------:|:-------:|:-----:|:------------:|:----------:|:------:|:----------:|:--------:|:-----------:|
| **空图 (V=0)** | ✅ 返回空图 | ✅ 返回空图 | ✅ 返回另一图 | ✅ 返回空图 | ✅ 返回空图 | ✅ 返回空图 | ✅ 返回空图 | ✅ 返回空图 | ✅ 返回空图 |
| **单节点 (V=1)** | ✅ 无边 | ✅ 无边 | ✅ 正常合并 | ✅ 正常求交 | ✅ 正常求差 | ✅ 返回空图 | ✅ 无边 | ✅ 正常收缩 | ✅ G¹=G |
| **不连通图** | ✅ 各分量独立取补 | ✅ 各分量独立反转 | ✅ 正常合并 | ✅ 正常求交 | ✅ 正常求差 | ✅ 正常计算 | ✅ 各分量独立线图 | ✅ 正常收缩 | ✅ 跨分量连边 |
| **完全图 Kn** | ✅ 返回空图 | N/A | ✅ 正常合并 | ✅ 返回相同图 | ✅ 返回空图 | ✅ 正常计算 | ✅ L(Kn)=Kn | N/A | ✅ Gᵏ=Kn |
| **自环处理** | N/A（无向） | 保留方向反转 | N/A | N/A | N/A | N/A | N/A | 删除产生的自环 | N/A |
| **并行边处理** | 去重（contains_edge） | 逐条添加 | 去重 | 去重 | 去重 | 可能产生 | 可能产生 | 去重 | 去重 |
| **k ≤ 0 (power_graph)** | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | ✅ 返回空边图 |

### 特殊恒等式验证

```moonbit
// 以下恒等式经测试验证成立:

// 1. 双重补图: complement(complement(G)) ≅ G
// 2. 双重反转: reverse(reverse(G)) = G
// 3. 幂图基例: power_graph(G, 1) = G
// 4. 幂图饱和: power_graph(P3, 2) = K3
// 5. 线图不变性: L(K3) = K3
// 6. 自差集: difference(G, G) = ∅
// 7. 幂等并: union(G, G) = G
// 8. 幂等交: intersection(G, G) = G
```

## 测试覆盖

| 类别 | 测试数 | 测试名称 | 内容 |
|:----:|:------:|----------|------|
| **基础运算** | | | |
| ├─ 补图 | 4 | complement_empty_graph, complement_triangle, complement_path3, complement_twice_is_original | 空图/K3/P3/双重补图恒等式 |
| └─ 反转 | 3 | reverse_empty_graph, reverse_directed_triangle, reverse_twice_is_original | 空图/有向三角形/双重反转恒等式 |
| **集合运算** | | | |
| ├─ 并图 | 3 | union_empty_with_triangle, union_path_with_path, union_different_vertices | 空∪K3/P3∪P3/不同顶点集 |
| ├─ 交图 | 3 | intersection_empty_with_triangle, intersection_same, intersection_partial | 空∩K3/P3∩P3/部分重叠 |
| └─ 差图 | 2 | difference_same, difference_path_minus_triangle | P3\P3(空)/P3\K3(空) |
| **图积运算** | | | |
| ├─ 笛卡尔积 | 2 | cartesian_product_empty, cartesian_product_single_edge | 空图/P2□P2=C4 |
| ├─ 张量积 | 2 | tensor_product_empty, tensor_product_single_edge | 空图/P2×P2=2K2 |
| └─ 字典序积 | 1 | lexicographic_product_empty | 空图 |
| **高级运算** | | | |
| ├─ 线图 | 3 | line_graph_empty, line_graph_triangle, line_graph_path3 | 空/L(K3)=K3/L(P3)=P2 |
| ├─ 收缩 | 2 | contract_empty, contract_path3 | 空/P3 收缩中间节点 |
| └─ 幂图 | 3 | power_graph_empty, power_graph_path_k1, power_graph_path_k2 | 空/G¹=G/G²=K3 |
| **合计** | **22** | | |

运行命令:
```bash
moon test lib/algo/operators  # 22 tests all pass
```

## 设计决策

### 为什么选择这 11 种算子？

选择依据来自**图论教科书的标准算子集** + **实际工程高频需求**：

| 优先级 | 算子 | 入选理由 |
|:------:|------|----------|
| 🔴 核心 | complement | 团/独立集对偶、自补图理论 |
| 🔴 核心 | reverse | Kosaraju SCC、链接分析必备 |
| 🔴 核心 | union / intersection / difference | 图数据库查询基础操作 |
| 🟡 重要 | cartesian_product | 网格图生成、笛卡尔积定理 |
| 🟡 important | tensor_product | 图同构下界、信道编码 |
| 🟡 重要 | lexicographic_product | 最强积、完美图刻画 |
| 🟢 扩展 | line_graph | 边着色、Euler/Hamilton 对偶 |
| 🟢 扩展 | contract | Stoer-Wagner 最小割、图子式理论 |
| 🟢 扩展 | power_graph | 小世界模型、广播分析 |

**未入选但有价值的算子**（未来可扩展）：
- **强积 (strong product)**：笛卡尔 ∪ 张量，复杂度介于两者之间
- **图补全 (graph completion)**：最小边数使图具有某性质
- **图商 (graph quotient)**：收缩的逆操作
- **Mycielski 构造**：保持色数增大团数的构造方法

### 为什么返回具体存储类型而非泛型？

1. **简洁性**：避免引入额外的 trait bound 或类型参数传播
2. **确定性**：用户明确知道返回值的存储结构和性能特征
3. **互操作性**：`UndirectedAdjList` / `DirectedAdjList` 是项目中最通用的存储类型
4. **链式调用友好**：具体类型可直接传入其他算子函数

### 为什么线图不使用 GraphEdgeIterable？

当前实现使用 `edges()` + 手动边对比较（O(E²)），而非 `GraphEdgeIterable::sorted_edges()`：
1. **通用性**：不依赖可选 trait，适用于所有 `GraphReadable` 实现
2. **正确性**：无需排序假设，天然处理无向边的对称性
3. **权衡**：对于稀疏图（E << V²），O(E²) 通常优于 O(V²)

## 与其他模块配合

```moonbit
// 典型工作流: 存储构建 → 算子变换 → 算法分析

// Step 1: 构建初始图
let g = @storage.new_undirected()
// ... 添加节点和边 ...

// Step 2: 算子变换
let complement_g = complement(g)
let powered_g = power_graph(g, 2)

// Step 3: 传入算法模块
// let components = connected_components(powered_g)   // 连通分量
// let coloring_result = greedy_coloring(complement_g) // 着色（补图上着色=原图最大团）

// Step 4: Kosaraju SCC 需要 reverse
// let reversed_dg = reverse(directed_graph)
// let sccs = kosaraju(directed_graph, reversed_dg)
```

## 已知限制

| 限制 | 影响 | 规避方案 |
|------|------|----------|
| 补图 O(V²) 不适合超大图 | V > 10⁴ 时性能下降 | 改用邻接矩阵存储 |
| 线图 O(E²) 二次复杂度 | 密集图（E ~ V²）时慢 | 仅对稀疏图使用 |
| 字典序积 O(V₁²V₂²) 四次复杂度 | 仅适合小规模图 | 预先检查图规模 |
| 交图仅保留 G1 的顶点 | 丢失 G2 独有顶点信息 | 如需完整顶点集，先 union 再 intersection |
| 积运算节点 ID 编码隐式 | 用户需了解 (i,j) → i·n2+j 映射 | 提供辅助解码函数 |

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| **v0.1.0** | **2026-06-01** | **初始版本：11 种图算子 + 22 测试 + 完整文档** |

---

<div align="center">

**📐 mbtgraph 图算子模块**

*11 种算子 · 4 大类别 · 泛型 Trait 实现*

</div>
