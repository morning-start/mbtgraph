# 存储类型选择指南

> 选择合适的图存储实现，平衡性能与功能。

---

## 存储选型速查

| 场景 | 推荐存储 | Trait | 复杂度 |
|------|---------|:-----:|--------|
| 通用稀疏图 | `DirectedAdjList` ⭐ | R+W+D+E | 邻居 O(k) |
| 无向通用图 | `UndirectedAdjList` ⭐ | R+W+E | 半存储 -50% |
| 稠密小图 (<1K) | `DirectedMatrix` | R+W+D | O(V²) 空间 |
| MST/Kruskal | `EdgeList` | R+W+E | O(E log E) |
| 大规模静态图 (>100K) | `CSR` | R+B | 缓存友好 |
| 入边密集查询 | `CSC` | R+B | in_degree O(1) |

---

## 详细对比

### DirectedAdjList ⭐ 首选

```moonbit
let g = @storage.new_directed()
```

**特点**:
- 最通用的存储实现
- 支持动态添加/删除节点和边
- 邻居查询 O(k)，k 为节点度数
- 同时维护正向和反向邻接表

**适用场景**:
- 通用图算法
- 需要频繁修改的图
- 中等规模图 (< 100K 节点)

**Trait 实现**: `GraphReadable + GraphWritable + GraphDirected + GraphFull`

---

### UndirectedAdjList ⭐ 无向图首选

```moonbit
let g = @storage.new_undirected()
```

**特点**:
- 无向图专用，节省 50% 存储空间
- 只维护一份邻接表（双向存储）
- 添加边时自动添加反向边

**适用场景**:
- 无向图算法
- 社交网络分析
- 连通性检测

**Trait 实现**: `GraphReadable + GraphWritable`

---

### DirectedMatrix 稠密图

```moonbit
let g = @storage.new_directed_matrix(capacity)
```

**特点**:
- 邻接矩阵实现
- 边查询 O(1)
- 空间 O(V²)

**适用场景**:
- 稠密图（边数接近 V²）
- 需要快速边查询
- 小规模图 (< 1K 节点)

**Trait 实现**: `GraphReadable + GraphWritable + GraphDirected`

---

### UndirectedMatrix

```moonbit
let g = @storage.new_undirected_matrix(capacity)
```

**特点**:
- 对称矩阵，只存储上三角
- 空间 O(V²/2)

---

### EdgeList 边集数组

```moonbit
let g = @storage.new_edge_list()
```

**特点**:
- 存储所有边的列表
- 适合边排序操作
- Kruskal 算法友好

**适用场景**:
- MST 算法 (Kruskal)
- 需要遍历所有边
- 边数较少的图

**Trait 实现**: `GraphReadable + GraphWritable + GraphDirected`

---

### CSR 压缩稀疏行 ⭐ 大规模静态图

```moonbit
// 使用 Builder 构建
let builder = @storage.CSRBuilder::new()
let builder = builder.add_node(n0, 0.0)
let builder = builder.add_edge(n0, n1, 1.0)
let g = builder.build()
```

**特点**:
- 只读存储，构建后不可修改
- 内存连续，缓存友好
- 支持批量邻居查询

**适用场景**:
- 大规模静态图 (> 100K 节点)
- 频繁的邻居遍历
- 性能敏感应用

**Trait 实现**: `GraphReadable + GraphDirected + GraphBatchReadable`

**额外方法**:
- `batch_neighbors(Array[NodeId])`: 批量获取邻居
- `batch_edges(Array[(NodeId, NodeId)])`: 批量获取边数据

---

### CSC 压缩稀疏列

```moonbit
let builder = @storage.CSCBuilder::new()
let g = builder.build()
```

**特点**:
- CSR 的转置
- `in_degree()` 查询 O(1)
- 入边查询高效

**适用场景**:
- PageRank 等入边密集算法
- 反向遍历
- 社区检测

**Trait 实现**: `GraphReadable + GraphDirected + GraphBatchReadable`

---

## 转换函数

```moonbit
// 任意有向图 → 邻接表
let adj = @storage.to_directed_adj_list(g)

// 任意图 → CSR（静态分析）
let csr = @storage.to_csr(g)

// 无向图 → 有向图（双向）
let directed = @storage.as_directed(ug)

// 有向图 → 无向图
let undirected = @storage.as_undirected(dg)
```

---

## 性能对比

| 操作 | AdjList | Matrix | CSR |
|------|---------|--------|-----|
| 添加节点 | O(1) | O(1) | N/A |
| 添加边 | O(1) | O(1) | N/A |
| 删除边 | O(k) | O(1) | N/A |
| 边查询 | O(k) | O(1) | O(log k) |
| 邻居遍历 | O(k) | O(V) | O(k) |
| 空间 | O(V+E) | O(V²) | O(V+E) |

---

## 使用建议

1. **默认选择**: `DirectedAdjList` 或 `UndirectedAdjList`
2. **性能优化**: 大规模图转 CSR
3. **特殊需求**: Matrix 用于快速边查询
4. **批量处理**: CSR 的 `batch_neighbors`
5. **内存敏感**: UndirectedAdjList 节省 50%

---

## 代码示例

```moonbit
// 动态构建
let g = @storage.new_directed()
let n0 = @core.GraphWritable::add_node(g, 0.0)
let n1 = @core.GraphWritable::add_node(g, 1.0)
let _ = @core.GraphWritable::add_edge(g, n0, n1, 1.0)

// Builder 模式（CSR）
let builder = @storage.CSRBuilder::new()
let builder = builder.add_node(n0, 0.0)
let builder = builder.add_edge(n0, n1, 1.0)
let csr = builder.build()

// 转换
let csr = @storage.to_csr(g)  // 动态图 → 静态 CSR
```
