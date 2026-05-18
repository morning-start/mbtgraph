# 最小生成树 (`mst`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 16 通过

提供无向图最小生成树（MST）的求解能力。

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | 类型定义 + Trait 约束 (`GraphReadable`) |
| [`@storage`](../storage/) | 具体存储实现（测试用） |

## 文件结构

```
src/algorithms/mst/
├── moon.pkg          # 包配置
├── types.mbt         # MstResult 结果类型 + 辅助方法
├── union_find.mbt    # Union-Find 并查集 (priv)
├── kruskal.mbt       # Kruskal 算法
├── prim.mbt          # Prim 算法
└── mst_test.mbt      # 16 个测试
```

## API 总览

### 结果类型 ([types.mbt](types.mbt))

#### `MstResult` — 最小生成树结果

```moonbit
pub(all) struct MstResult {
  total_weight : Double                                    // MST 总权重
  edges : Array[(@core.NodeId, @core.NodeId, Double)]       // MST 边列表 (u, v, weight)
}
```

| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `edge_count()` | `Int` | MST 中的边数 |
| `has_edge(u, v)` | `Bool` | 查询边 (u,v) 或 (v,u) 是否在 MST 中 |

### Kruskal ([kruskal.mbt](kruskal.mbt))

**基于边排序 + Union-Find 的贪心算法** — 时间复杂度 O(E log E)

| 函数 | 说明 | 返回 |
|------|------|------|
| `kruskal(g)` | 计算无向图的最小生成树 | `MstResult` |

**特点**:
- 收集所有无向边 → 按权重升序排序 → 贪心选取不形成环的边
- 图不连通时返回**森林**（每个连通分量的 MST）
- 核心依赖：Union-Find 并查集（路径压缩 + 按秩合并）

### Prim ([prim.mbt](prim.mbt))

**从根节点出发的贪心生长算法** — 时间复杂度 O(V²)（数组实现）

| 函数 | 说明 | 返回 |
|------|------|------|
| `prim(g, root)` | 从 root 开始构建最小生成树 | `MstResult` |

**特点**:
- 维护每个未加入节点的最小连接边权
- 每轮选择权值最小的边界节点加入 MST
- 与 Dijkstra 结构相似（区别：优先级为单边权而非累积距离）

## 使用示例

### 基础用法

```moonbit
// 构建有权无向图: 0—1(1.0)—2(2.0)—3(3.0), 0—3(7.0)
let g = @storage.new_undirected()
let g = @core.GraphWritable::add_node(g, 0.0) |> ignore
let g = @core.GraphWritable::add_node(g, 0.0) |> ignore
let g = @core.GraphWritable::add_node(g, 0.0) |> ignore
let g = @core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 2.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 3.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(3), 7.0) |> ignore

// Kruskal: 选出 3 条最短边，总权重 6.0
let mst = kruskal(g)
mst.total_weight              // => 6.0
mst.edge_count()               // => 3
mst.has_edge(@core.NodeId(0), @core.NodeId(1))   // => true
mst.has_edge(@core.NodeId(0), @core.NodeId(3))   // => false (被舍弃)

// Prim: 从 Node(0) 出发，结果一致
let pmst = prim(g, @core.NodeId(0))
pmst.total_weight             // => 6.0
```

### 不连通图（森林）

```moonbit
// 两个独立分量: {0,1} 和 {2,3}
let forest = kruskal(disconnected_g)
forest.edge_count()           // => 2 (每分量 n-1 条边)
forest.total_weight           // => 8.0
```

## 算法对比

| 特性 | Kruskal | Prim |
|------|---------|------|
| 时间复杂度 | O(E log E) | O(V²) 数组版 / O((V+E)log V) 堆版 |
| 适用场景 | **稀疏图**（E << V²） | **稠密图**或需要增量构建 |
| 数据结构需求 | Union-Find + 排序 | 优先队列 / 最小 key 数组 |
| 边权敏感度 | 需要完整边列表 | 仅需邻接信息 |
| 不连通图处理 | 自动返回森林 | 仅 root 所在分量的 MST |
| 结果一致性 | ✅ 权重相同，边可能不同 | ✅ 权重相同 |

## 内部组件

### Union-Find ([union_find.mbt](union_find.mbt))

并查集数据结构，**私有实现**，仅供 Kruskal 使用。

- **可见性**: `priv struct UnionFind`
- **操作**: `uf_new(size)` / `uf_find(uf, x)` / `uf_union(uf, x, y)`
- **优化**: 路径压缩 + 按秩合并（接近 O(α(n)) 均摊）

## 边界行为

| 条件 | Kruskal | Prim |
|------|---------|------|
| 空图 (V=0) | 空 MstResult (weight=0, edges=[]) | 同左 |
| 单节点图 | 空 MstResult (0 条边) | 同左 |
| 完全图 K_n | n-1 条边 | n-1 条边 |
| 根节点不存在 | 正常计算（忽略无效 root） | 空 MstResult |
| 所有边权重相同 | 任一合法生成树 | 同左 |
| 自环 (u→u) | 自动跳过（u.0 < v.0 过滤） | 不影响结果 |

## 测试覆盖

| 类别 | 数量 | 内容 |
|------|:----:|------|
| Kruskal 基础 | 7 | 权重/边数/预期边/重边排除/空图/单节点/不连通森林 |
| Prim 基础 | 5 | 权重/边数/不同根一致性/空图/根不存在 |
| 一致性验证 | 1 | Kruskal vs Prim 相同权重和边数 |
| **跨存储兼容** | **3** | AdjList/Matrix/EdgeList × Kruskal+Prim |
| **合计** | **16** | |

## 与其他模块配合

```moonbit
// 用生成器快速构建测试图
let g = @storage.new_undirected()
let g = @gen.complete_undirected(g, 10, 1.0)

// MST
let mst = kruskal(g)

// 结合连通性验证：MST 边数 = V - 连通分量数
let cc = connected_components(g)
assert_true(mst.edge_count() == nc - cc.count())
```
