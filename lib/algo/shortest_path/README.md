# 最短路径算法 (`shortest_path`)

> **版本**: v0.2.0 | **状态**: 稳定 | **测试**: 66 通过

提供加权图最短路径求解能力，覆盖单源和全源场景、非负权和负权边。

## 依赖

| 包                        | 用途                                    |
| ------------------------- | --------------------------------------- |
| [`@core`](../core/)       | 类型定义 + Trait 约束 (`GraphReadable`) |
| [`@storage`](../storage/) | 具体存储实现（测试用）                  |

## 文件结构

```txt
lib/algorithms/shortest_path/
├── moon.pkg              # 包配置
├── types.mbt             # ShortestPathResult + FloydWarshallResult + 辅助方法
├── heap.mbt              # BinaryHeap 二叉最小堆 (priv，内部使用)
├── dijkstra.mbt          # Dijkstra 算法
├── bellman_ford.mbt      # Bellman-Ford 算法
├── floyd_warshall.mbt     # Floyd-Warshall 算法
└── shortest_path_test.mbt # 32 个测试
```

## API 总览

### 结果类型 ([types.mbt](types.mbt))

#### `ShortestPathResult` — 单源最短路径结果

Dijkstra 和 Bellman-Ford 共用的返回类型。

```moonbit
pub(all) struct ShortestPathResult {
  distances : Array[Double?>    // None = 不可达
  parents : Array[@core.NodeId?]
}
```

| 方法                | 返回类型        | 说明                                                   |
| ------------------- | --------------- | ------------------------------------------------------ |
| `distance_to(id)`   | `Double`        | 查询到目标的最短距离，不可达返回 -1.0                  |
| `is_reachable(id)`  | `Bool`          | 查询节点是否可达                                       |
| `reachable_count()` | `Int`           | 可达节点总数                                           |
| `path_to(id)`       | `Array[NodeId]` | 重建最短路径 `[source, ..., target]`，不可达返回空数组 |

#### `FloydWarshallResult` — 全源最短路径结果

Floyd-Warshall 的返回类型。

```moonbit
pub(all) struct FloydWarshallResult {
  distances : Array[Array[Double?>>
  next : Array[Array[@core.NodeId?]>
}
```

| 方法                 | 返回类型        | 说明                                   |
| -------------------- | --------------- | -------------------------------------- |
| `distance(from, to)` | `Double`        | 查询 from→to 最短距离，不可达返回 -1.0 |
| `path(from, to)`     | `Array[NodeId]` | 重建最短路径，不可达返回空数组         |

### Dijkstra ([dijkstra.mbt](dijkstra.mbt))

**非负权图单源最短路径** — 时间复杂度 O((V+E)log V)，使用自建二叉最小堆。

| 函数                             | 说明                               | 返回                 |
| -------------------------------- | ---------------------------------- | -------------------- |
| `dijkstra(g, source)`            | 计算从 source 到所有节点的最短距离 | `ShortestPathResult` |
| `dijkstra_targeted(g, src, tgt)` | 提前终止优化版，仅计算到 target    | `Array[NodeId]`      |

**约束**: 所有边权重必须 ≥ 0。含负权边的结果未定义。

### Bellman-Ford ([bellman_ford.mbt](bellman_ford.mbt))

**支持负权边的单源最短路径** — 时间复杂度 O(VE)。

| 函数                      | 说明                     | 返回                  |
| ------------------------- | ------------------------ | --------------------- |
| `bellman_ford(g, source)` | 支持负权边的单源最短路径 | `Result[SPR, String]` |

**特性**:

- 正确处理负权边
- 自动检测负环 → 返回 `Err("negative cycle detected")`
- 无负环时结果与 Dijkstra 一致（非负权场景）

### Floyd-Warshall ([floyd_warshall.mbt](floyd_warshall.mbt))

**全源最短路径** — 时间复杂度 O(V³)，适合稠密小图。

| 函数                | 说明                         | 返回                  |
| ------------------- | ---------------------------- | --------------------- |
| `floyd_warshall(g)` | 计算所有节点对之间的最短路径 | `Result[FWR, String]` |

**特性**:

- 一次调用获得所有节点对的距离和路径
- 支持负权边
- 含负环时返回 Err

## 使用示例

### 基础用法：Dijkstra

```moonbit
import {
  "morning-start/mbtgraph/lib/core" @core,
  "morning-start/mbtgraph/lib/storage" @storage,
}

// 构建有权图: 0 → 1(2.0) → 2(3.0) → 3(1.0)
let g = @storage.new_directed()
let g = @core.GraphWritable::add_node(g, 0.0) |> ignore
let g = @core.GraphWritable::add_node(g, 0.0) |> ignore
let g = @core.GraphWritable::add_node(g, 0.0) |> ignore
let g = @core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 2.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 3.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore

// Dijkstra 最短路径
let sp = dijkstra(g, @core.NodeId(0))
sp.distance_to(@core.NodeId(3))     // => 6.0
sp.is_reachable(@core.NodeId(3))   // => true
sp.reachable_count()               // => 4
sp.path_to(@core.NodeId(3))        // => [Node(0), Node(1), Node(2), Node(3)]
```

### 提前终止：仅求两点间路径

```moonbit
// 只需要 0 到 3 的路径，不需要全部计算
let path = dijkstra_targeted(g, @core.NodeId(0), @core.NodeId(3))
// => [Node(0), Node(1), Node(2), Node(3)]
```

### 负权边：Bellman-Ford

```moonbit
// 图中包含负权边: 2 → 3(-2.0)
match bellman_ford(g, @core.NodeId(0)) {
  Ok(sp) => {
    sp.distance_to(@core.NodeId(3))   // => 负权处理后的正确值
  }
  Err(msg) => { /* msg = "negative cycle detected" */ }
}
```

### 全源最短路径：Floyd-Warshall

```moonbit
match floyd_warshall(g) {
  Ok(fw) => {
    fw.distance(@core.NodeId(0), @core.NodeId(3))  // => 6.0
    fw.path(@core.NodeId(0), @core.NodeId(3))       // => [Node(0), ..., Node(3)]

    // 对角线恒为 0
    fw.distance(@core.NodeId(1), @core.NodeId(1))   // => 0.0
  }
  Err(msg) => { /* 含负环 */ }
}
```

## 算法选择指南

| 场景             | 推荐算法                          | 原因                       |
| ---------------- | --------------------------------- | -------------------------- |
| 非负权图，单源   | **Dijkstra**                      | O((V+E)log V) 最快         |
| 仅需两点间路径   | **dijkstra_targeted**             | 提前终止，更高效           |
| 含负权边         | **Bellman-Ford**                  | 唯一支持负权的单源算法     |
| 需要检测负环     | **Bellman-Ford / Floyd-Warshall** | 两者均可检测               |
| 小规模全源查询   | **Floyd-Warshall**                | O(V³) 但一次解决所有节点对 |
| 大规模稀疏图多源 | 多次 Dijkstra                     | V × O((V+E)log V) < O(V³)  |

## 内部组件

### BinaryHeap ([heap.mbt](heap.mbt))

二叉最小堆，**私有实现**，仅供 Dijkstra 使用。

- **可见性**: `priv struct BinaryHeap`
- **存储元素**: `(Double, NodeId)` 元组，按 Double 升序排列
- **操作**: push / pop / is_empty / length
- **不暴露给外部包**

## 边界行为

| 条件       | Dijkstra             | Bellman-Ford               | Floyd-Warshall             |
| ---------- | -------------------- | -------------------------- | -------------------------- |
| 空图 (V=0) | 空 SPR               | `Ok(空 SPR)`               | `Ok(空 FWR)`               |
| 源点不存在 | 空 SPR               | `Err("source not found")`  | N/A（无源点参数）          |
| 目标不可达 | distance=-1, path=[] | 同左                       | distance=-1, path=[]       |
| 负权边     | ⚠️ 结果未定义        | ✅ 正确处理                | ✅ 正确处理                |
| 负环存在   | ⚠️ 可能死循环        | `Err("negative cycle...")` | `Err("negative cycle...")` |
| 自环 (u→u) | weight ≥ 0 时正确    | 正确处理                   | 正确处理                   |

## 测试覆盖

| 类别              |  数量  | 内容                                                    |
| ----------------- | :----: | ------------------------------------------------------- |
| Dijkstra 基础     |   9    | 距离/可达性/路径重建/空图/单节点/不可达                 |
| Dijkstra targeted |   2    | 同目标/正常路径                                         |
| Bellman-Ford      |   6    | 与 Dijkstra 一致/负权边/负环检测/空图/源不存在/路径重建 |
| Floyd-Warshall    |   5    | 距离矩阵/路径重建/空图/负环检测/自距离为 0              |
| **跨存储兼容**    | **6**  | AdjList/Matrix/EdgeList × 3 种算法                      |
| **合计**          | **32** |                                                         |

## 与其他模块配合

```moonbit
// 用生成器快速构建测试图
let g = @storage.new_directed()
let g = @gen.complete_directed(g, 10, 2.5)

// 最短路径
let sp = dijkstra(g, @core.NodeId(0))

// 结合遍历验证可达性
let bfs_result = bfs(g, @core.NodeId(0))
// BFS 可达节点数应与 Dijkstra reachable_count 一致
```
