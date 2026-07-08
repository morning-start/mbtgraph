---
title: Storage 模块接口
description: 8 种图存储结构的构造器、方法签名和 Trait 实现对照表
---

# Storage 模块接口

> 模块路径: `lib/storage/` · 8 种实现 + 转换器

---

## 一、存储类型速查

| 存储 | 构造器 | Trait 支持 | 适用场景 |
|------|--------|:----------:|---------|
| `DirectedAdjList` | `new_directed()` | R+W+D+E | ⭐ 通用有向图 |
| `UndirectedAdjList` | `new_undirected()` | R+W+E | ⭐ 通用无向图 |
| `DirectedMatrix` | `new_directed_matrix(n)` | R+W+D | 稠密有向小图 |
| `UndirectedMatrix` | `new_undirected_matrix(n)` | R+W | 稠密无向小图 |
| `EdgeList` | `new_edge_list()` | R+W+E | Kruskal / 边排序 |
| `UndirectedEdgeList` | `new_undirected_edge_list()` | R+W+E | 无向边排序 |
| `CSR` | `CSRBuilder` → `build()` | R+B | ⭐ 大规模静态有向图 |
| `CSC` | `CSCBuilder` → `build()` | R+B | 大规模入边密集查询 |

> **R**=GraphReadable, **W**=GraphWritable, **D**=GraphDirected, **B**=GraphBatchReadable

---

## 二、有向邻接表 (DirectedAdjList)

最通用的有向图实现，O(1) 入边/出边查询。

### 构造

```moonbit
// 空图
let g = @storage.new_directed()
// 带容量预分配（推荐：预知节点/边数时）
let g = @storage.DirectedAdjList::new_with_capacity(1000, 5000)
```

### 独有方法

```moonbit
// 快速建边（跳过查重），适用于批量确定无重复边的场景
DirectedAdjList::add_edge_unchecked(self, from, to, data) -> Result[Unit, GraphError]
```

---

## 三、无向邻接表 (UndirectedAdjList)

半存储优化（边只存一次），空间比有向邻接表省 50%。

```moonbit
let g = @storage.new_undirected()
let g = @storage.UndirectedAdjList::new_with_capacity(1000, 2000)
```

---

## 四、邻接矩阵 (DirectedMatrix / UndirectedMatrix)

适用于节点数 < 1000 的稠密图。O(1) 边查询，但 O(V²) 空间。

```moonbit
// 创建 10×10 矩阵
let g = @storage.DirectedMatrix::new_with_capacity(10)
// 无向版
let g = @storage.UndirectedMatrix::new_with_capacity(10)
```

---

## 五、边集数组 (EdgeList / UndirectedEdgeList)

边的无序集合，适合 Kruskal 算法（需要 `sorted_edges`）。

```moonbit
let g = @storage.new_edge_list()
let g = @storage.new_undirected_edge_list()
```

---

## 六、CSR / CSC 压缩存储

### CSRBuilder 模式

```moonbit
let mut builder = @storage.CSRBuilder::new()
builder = builder.add_node(@core.NodeId(0), 0.9)
builder = builder.add_edge(@core.NodeId(0), @core.NodeId(1), 2.5)
match builder.build() {
  Ok(csr) => { /* 使用只读 CSR */ }
  Err(e) => println("构建失败: \(e)")
}
```

### CSCBuilder 模式

```moonbit
let mut builder = @storage.CSCBuilder::new()
builder = builder.add_node(@core.NodeId(0), 0.9)
builder = builder.add_edge(@core.NodeId(0), @core.NodeId(1), 2.5)
match builder.build() {
  Ok(csc) => { /* 使用只读 CSC */ }
  Err(e) => println("构建失败: \(e)")
}
```

CSR/CSC 特有方法（`GraphBatchReadable`）：

```moonbit
// 批量获取邻居（比逐条 neighbors 快 3-5 倍）
fn batch_neighbors(Self, Array[NodeId]) -> Array[Array[NodeId]]
// 批量获取边权重
fn batch_edges(Self, Array[(NodeId, NodeId)]) -> Array[Double?]
```

---

## 七、转换器 (Converter)

8 个泛型转换函数在 8 种存储之间互相转换。

```moonbit
// 任意 GraphReadable → DirectedAdjList
pub fn[G : @core.GraphReadable] to_directed_adj_list(g : G) -> DirectedAdjList

// 任意 GraphReadable → UndirectedAdjList
pub fn[G : @core.GraphReadable] to_undirected_adj_list(g : G) -> UndirectedAdjList

// 同上模式：to_directed_matrix, to_undirected_matrix,
//           to_edge_list, to_undirected_edge_list,
//           to_csr, to_csc
```

---

## 八、选型决策

```
图是动态修改的吗？
├─ 是 → 图是有向的吗？
│      ├─ 是 → DirectedAdjList ⭐
│      └─ 否 → UndirectedAdjList ⭐
└─ 否（静态只读）→ 图有多大？
       ├─ < 1K 节点 → DirectedMatrix / UndirectedMatrix
       └─ ≥ 1K 节点 → CSR（出边密集） / CSC（入边密集）
```

---

**相关文档：**
- [Core 模块接口](/api/core/)
- [IO 模块接口](/api/io/)
- [各算法模块 API](/api/algorithms/)
- [存储选型指南](/core-concepts/storage-guide/)
