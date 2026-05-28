# core — 图算法库核心类型与 Trait 层

> **定位**: mbtgraph 的基础层，定义所有图操作共用的**类型系统**和 **Trait 抽象接口**。

---

## 快速导航

| 模块           | 文件                   | 职责                                  |
| -------------- | ---------------------- | ------------------------------------- |
| **类型定义**   | [types.mbt](types.mbt) | `NodeId`, `Node`, `Edge` 三大核心类型 |
| **Trait 接口** | [traits.mbt)           | 6 个分层 Trait，定义图操作的抽象契约  |
| **错误类型**   | [error.mbt](error.mbt) | `GraphError` 枚举，统一错误处理       |

---

## 类型系统

### `NodeId` — 节点唯一标识符

```moonbit
pub(all) struct NodeId(Int)
```

整数索引类型的节点 ID，从 0 开始自动分配。

```moonbit
// 创建
let id = @core.NodeId(0)

// 解包获取整数值
match id {
  @core.NodeId(i) => println("索引: ${i}")
}
```

**设计决策**: 使用 Newtype 模式包装 `Int`，避免与普通整数混淆。

---

### `Node` — 带数据的节点

```moonbit
pub(all) struct Node {
  id : NodeId    // 唯一标识
  data : Double  // 节点数据（MVP 阶段固定 Double）
}
```

```moonbit
let node = { id: @core.NodeId(0), data: 3.14 }
```

> **TODO**: 后续版本可泛型化为 `Node[T]` 支持任意数据类型。

---

### `Edge` — 带数据的边

```moonbit
pub(all) struct Edge {
  from : NodeId   // 起点
  to : NodeId     // 终点
  data : Double   // 边权值
}
```

```moonbit
let edge = { from: @core.NodeId(0), to: @core.NodeId(1), data: 2.5 }
```

---

## Trait 分层体系

core 包的核心是 **6 个分层 Trait**，遵循**接口隔离原则 (ISP)** 和**里氏替换原则 (LSP)**：

```txt
                    ┌─────────────────┐
                    │  GraphReadable   │  ← 所有存储必须实现
                    │  （只读基线）      │     12 个方法
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
    ┌─────────────┐  ┌──────────────┐  ┌────────────────┐
    │ GraphWritable│  │ GraphDirected│  │GraphBatchReadable│
    │ （可写扩展）  │  │ （有向扩展）  │  │ （批量优化）     │
    │ +5 方法      │  │ +6 方法       │  │ +2 方法         │
    └──────┬───────┘  └──────┬───────┘  └────────────────┘
           │                 │
           └────────┬────────┘
                    ▼
          ┌─────────────────┐
          │   GraphFull     │  ← Writable + Directed 组合
          │  （完整有向可写）  │
          └─────────────────┘

  独立扩展:
  ┌─────────────────────┐
  │ GraphEdgeIterable   │  ← 边排序能力（Kruskal 友好）
  │ +1 方法             │
  └─────────────────────┘
```

---

### Trait 详解

#### 1. `GraphReadable` — 只读基线接口

**继承**: 无（根 trait）

**适用**: **所有存储实现**

| 方法            | 签名                                       | 说明                       |
| --------------- | ------------------------------------------ | -------------------------- |
| `node_count`    | `(Self) -> Int`                            | 节点总数                   |
| `edge_count`    | `(Self) -> Int`                            | 边总数                     |
| `contains_node` | `(Self, NodeId) -> Bool`                   | 节点是否存在               |
| `contains_edge` | `(Self, NodeId, NodeId) -> Bool`           | 边是否存在                 |
| `get_node`      | `(Self, NodeId) -> Double?`                | 获取节点数据               |
| `get_edge`      | `(Self, NodeId, NodeId) -> Double?`        | 获取边权值                 |
| `neighbors`     | `(Self, NodeId) -> Iter[NodeId]`           | 邻居迭代器                 |
| `degree`        | `(Self, NodeId) -> Int`                    | 度数（无向）/ 出度（有向） |
| `is_directed`   | `(Self) -> Bool`                           | 是否有向图                 |
| `is_empty`      | `(Self) -> Bool`                           | 是否空图                   |
| `node_ids`      | `(Self) -> Iter[NodeId]`                   | 所有节点 ID 迭代器         |
| `edges`         | `(Self) -> Iter[(NodeId, NodeId, Double)]` | 所有边迭代器               |

**使用示例**:

```moonbit
// 泛型算法约束
pub fn[G : @core.GraphReadOnly] bfs(g : G, start : NodeId) -> Array[NodeId] {
  let visited = Array::make(g.node_count(), false)
  // ...
}

// 调用 trait 方法
@core.GraphReadable::node_count(my_graph)
@core.GraphReadable::neighbors(my_graph, some_id)
```

---

#### 2. `GraphWritable` — 可写接口

**继承**: `GraphReadable`

**适用**: 动态存储（AdjList, Matrix, EdgeList）；**CSR 不实现**（LSP）

| 方法          | 签名                                                         | 返回值    | 说明             |
| ------------- | ------------------------------------------------------------ | --------- | ---------------- |
| `add_node`    | `(Self, Double) -> NodeId`                                   | 新节点 ID | 添加节点         |
| `remove_node` | `(Self, NodeId) -> Bool`                                     | 是否成功  | 删除节点及关联边 |
| `add_edge`    | `(Self, NodeId, NodeId, Double) -> Result[Unit, GraphError]` | 成功/错误 | 添加边           |
| `remove_edge` | `(Self, NodeId, NodeId) -> Bool`                             | 是否成功  | 删除边           |
| `clear`       | `(Self) -> Unit`                                             | -         | 清空图           |

**错误处理**:

```moonbit
match @core.GraphWritable::add_edge(g, from, to, weight) {
  Ok(_) => println("成功")
  Err(e) => match e {
    @core.GraphError::NodeNotFound(id) => println("节点 ${id} 不存在")
    @core.GraphError::EdgeAlreadyExists(f, t) => println("边 ${f}→${t} 已存在")
    @core.GraphError::InvalidNodeId => println("无效的 ID")
  }
}
```

---

#### 3. `GraphDirected` — 有向图扩展

**继承**: `GraphReadable`

**适用**: 有向存储（DirectedAdjList, DirectedMatrix）

| 方法            | 签名                                       | 说明           |
| --------------- | ------------------------------------------ | -------------- |
| `in_neighbors`  | `(Self, NodeId) -> Iter[NodeId]`           | 入边邻居       |
| `out_neighbors` | `(Self, NodeId) -> Iter[NodeId]`           | 出边邻居       |
| `in_degree`     | `(Self, NodeId) -> Int`                    | 入度           |
| `out_degree`    | `(Self, NodeId) -> Int`                    | 出度           |
| `predecessors`  | `(Self, NodeId) -> Iter[(NodeId, Double)]` | 前驱边（带权） |
| `successors`    | `(Self, NodeId) -> Iter[(NodeId, Double)]` | 后继边（带权） |

---

#### 4. `GraphFull` — 完整图接口

**继承**: `GraphWritable + GraphDirected`

**适用**: 有向可写存储（如 `DirectedAdjList`）

无额外方法，仅作为**类型约束便捷别名**：

```moonbit
// 等价于
pub fn[G : (@core.GraphWritable + @core.GraphDirected)] some_algo(g : G) { ... }

// 可简写为
pub fn[G : @core.GraphFull] some_algo(g : G) { ... }
```

---

#### 5. `GraphBatchReadable` — 批量读取优化

**继承**: `GraphReadable`

**适用**: CSR、CSC 等连续内存存储

| 方法              | 签名                                                | 说明         |
| ----------------- | --------------------------------------------------- | ------------ |
| `batch_neighbors` | `(Self, Array[NodeId]) -> Array[Array[NodeId]]`     | 批量查询邻居 |
| `batch_edges`     | `(Self, Array[(NodeId, NodeId)]) -> Array[Double?]` | 批量查询边权 |

**性能优势**: 减少多次单次调用的开销，适合大规模图计算。

---

#### 6. `GraphEdgeIterable` — 边遍历优化

**继承**: `GraphReadable`

**适用**: 边集数组、无向邻接表等支持边排序的存储

| 方法           | 签名                                       | 说明               |
| -------------- | ------------------------------------------ | ------------------ |
| `edges_sorted` | `(Self) -> Iter[(NodeId, NodeId, Double)]` | 按权值升序排列的边 |

**典型用途**: Kruskal 最小生成树算法需要边按权值排序。

---

## 错误类型

### `GraphError` 枚举

```moonbit
pub(all) enum GraphError {
  NodeNotFound(NodeId)           // 节点不存在
  EdgeAlreadyExists(NodeId, NodeId)  // 边已存在
  InvalidNodeId                  // 节点 ID 无效
}
```

| 变体                     | 触发场景               | 处理建议                        |
| ------------------------ | ---------------------- | ------------------------------- |
| `NodeNotFound(id)`       | 对不存在的节点执行操作 | 先调用 `contains_node` 检查     |
| `EdgeAlreadyExists(f,t)` | 重复添加同一条边       | 调用 `contains_edge` 或忽略错误 |
| `InvalidNodeId`          | 使用负数或越界的 ID    | 校验输入范围                    |

---

## Trait 实现矩阵

下表展示了 storage 包中各存储类型对 core Trait 的实现情况：

| Trait                  | DirectedAdjList | UndirectedAdjList | DirectedMatrix | UndirectedMatrix | CSR/CSC | EdgeListGraph | UndirectedEdgeListGraph |
| ---------------------- | :-------------: | :---------------: | :------------: | :--------------: | :-----: | :-----------: | :---------------------: |
| **GraphReadable**      |       ✅        |        ✅         |       ✅       |        ✅        |   ✅    |      ✅       |           ✅            |
| **GraphWritable**      |       ✅        |        ✅         |       ✅       |        ✅        | ❌ LSP  |      ✅       |           ✅            |
| **GraphDirected**      |       ✅        |        ❌         |       ✅       |        ❌        |   ❌    |      ❌       |           ❌            |
| **GraphFull**          |       ✅        |        ❌         |       ✅       |        ❌        |   ❌    |      ❌       |           ❌            |
| **GraphBatchReadable** |       ❌        |        ❌         |       ❌       |        ❌        |   ✅    |      ❌       |           ❌            |
| **GraphEdgeIterable**  |       ❌        |        ✅         |       ❌       |        ❌        |   ❌    |      ✅       |           ✅            |

---

## 设计原则

### 接口隔离 (ISP)

每个 Trait 只包含特定场景需要的方法：

- 只读查询 → `GraphReadable`
- 动态修改 → `GraphWritable`
- 有向语义 → `GraphDirected`
- 批量优化 → `GraphBatchReadable`
- 边排序 → `GraphEdgeIterable`

### 里氏替换 (LSP)

CSR 是**只读格式**，故意不实现 `GraphWritable`：

- CSR 的 `add_edge()` 会破坏压缩结构的高效性
- 子类不能削弱父类的能力，但可以**不承诺**额外能力

### 依赖倒置 (DIP)

算法依赖 Trait 抽象，不依赖具体存储：

```moonbit
// ✅ 正确：依赖抽象
pub fn[G : @core.GraphReadable] dfs(g : G) -> ...

// ❌ 错误：依赖具体类型
pub fn dfs_adjlist(g : DirectedAdjList) -> ...
```

---

## 编码规范速查

| 规则           | 示例                                                     |
| -------------- | -------------------------------------------------------- |
| 完全限定名     | `@core.NodeId(0)` / `@core.GraphReadable::node_count(g)` |
| Impl 参数      | `(self)` 非 `mut self`                                   |
| Option 匹配    | 不需要 `_ => ()` 分支                                    |
| Trait 方法调用 | 必须用完全限定名 `@core.Trait::method(self, ...)`        |
| Result 丢弃    | `\|> ignore`                                             |

---

## 相关文档

- **存储实现**: [`../storage/README.md`](../storage/README.md)
- **项目规范**: [`../../AGENTS.md`](../../AGENTS.md)
- **架构设计**: [`../../docs/design/graph_trait_and_module_architecture.md`](../../docs/design/graph_trait_and_module_architecture.md)
