# traversal — 图遍历算法 (v0.2.0)

> **定位**: mbtgraph 的**首批算法实现**，基于 `@core.GraphReadable` trait 泛型约束，支持所有 8 种存储结构。
>
> **依赖**: [`@core`](../core/)（类型 + Trait）、[`@storage`](../../storage/)（测试用图构建）

---

## 模块总览

```txt
traversal/
├── types.mbt          结果类型（TraversalResult / BfsResult / DfsResult）
├── bfs.mbt             广度优先搜索 (3 函数)
├── dfs.mbt             深度优先搜索 (2 函数)
├── cycle.mbt           环检测 (3 函数)
├── topo_sort.mbt       拓扑排序 (2 函数)
├── traversal_test.mbt  主测试 (28 个，算法行为验证)
└── cross_storage_test.mbt 跨存储测试 (20 个，泛型一致性验证)
```

---

## 快速选择指南

| 你的需求                   | 推荐函数                                 | 复杂度 |
| -------------------------- | ---------------------------------------- | :----: |
| **按层遍历（最短路径）**   | `bfs(g, start)`                          | O(V+E) |
| **获取两点间最短路径**     | `bfs_shortest_path(g, s, t)`             | O(V+E) |
| **遍历全图（含断连分量）** | `bfs_all(g)` / `dfs_all(g)`              | O(V+E) |
| **深度优先探索**           | `dfs(g, start)`                          | O(V+E) |
| **检测图中是否有环**       | `has_cycle(g)`                           | O(V+E) |
| **DAG 节点排序**           | `topo_sort_kahn(g)` / `topo_sort_dfs(g)` | O(V+E) |

---

## API 总览

### 公开函数（10 个）

| 分类     | 函数                         | Trait 约束    | 返回值                |
| -------- | ---------------------------- | ------------- | --------------------- |
| BFS      | `bfs(g, start)`              | GraphReadable | BfsResult             |
| BFS      | `bfs_all(g)`                 | GraphReadable | BfsResult             |
| BFS      | `bfs_shortest_path(g, s, t)` | GraphReadable | Array[NodeId]         |
| DFS      | `dfs(g, start)`              | GraphReadable | DfsResult             |
| DFS      | `dfs_all(g)`                 | GraphReadable | DfsResult             |
| 环检测   | `has_cycle(g)`               | GraphReadable | Bool                  |
| 环检测   | `has_directed_cycle(g)`      | GraphDirected | Bool                  |
| 环检测   | `has_undirected_cycle(g)`    | GraphReadable | Bool                  |
| 拓扑排序 | `topo_sort_kahn(g)`          | GraphDirected | Result[Array, String] |
| 拓扑排序 | `topo_sort_dfs(g)`           | GraphDirected | Result[Array, String] |

---

## 核心类型

### TraversalResult — 基础遍历结果

BFS 和 DFS 共用的公共结果类型。

```moonbit
pub(all) struct TraversalResult {
  visited : Array[Bool]           // 按 NodeId 索引的访问标记
  order    : Array[@core.NodeId]   // 访问顺序
  parents : Array[@core.NodeId?]  // 前驱节点（用于路径重建）
}
```

**辅助方法**:

| 方法                | 签名               | 说明                        |
| ------------------- | ------------------ | --------------------------- |
| `is_visited(id)`    | `-> Bool`          | O(1) 查询是否访问过         |
| `reachable_count()` | `-> Int`           | 可达节点总数                |
| `path_to(target)`   | `-> Array[NodeId]` | 通过 parents[] 回溯重建路径 |

```moonbit
let result = bfs(my_graph, start)
result.base.is_visited(some_node)        // true/false
result.base.reachable_count()            // 已访问节点数
result.base.path_to(target_node)         // [start, ..., target]
```

### BfsResult — BFS 扩展

在 TraversalResult 基础上增加**层级距离**信息。

```moonbit
pub(all) struct BfsResult {
  base   : TraversalResult
  levels : Array[Int]    // start 到各节点的最短距离（边数）
}
```

| 方法           | 返回值 | 说明                    |
| -------------- | ------ | ----------------------- |
| `distance(id)` | Int    | 最短距离；不可达返回 -1 |

```moonbit
let result = bfs(g, start)
result.distance(node_a)     // 2 （相隔 2 条边）
result.distance(unreachable) // -1
```

### DfsResult — DFS 扩展

在 TraversalResult 基础上增加**时间戳**信息。

```moonbit
pub(all) struct DfsResult {
  base       : TraversalResult
  entry_time : Array[Int]  // 发现时间戳
  exit_time  : Array[Int]  // 完成时间戳
}
```

**不变量**: 对每个已访问节点，`entry_time[id] < exit_time[id]`。时间戳可用于：

- 拓扑排序（逆后序 = exit_time 降序）
- 强连通分量（Tarjan 算法）
- 桥/割点检测

---

## 各算法详解

### 1. BFS — 广度优先搜索

从起点开始**逐层向外扩展**，天然保证按最短路径顺序访问节点。

```moonbit
// 单源 BFS
let result : BfsResult = bfs(graph, @core.NodeId(0))

// 最短路径（无权图）
let path = bfs_shortest_path(graph, source, target)

// 全图遍历（多连通分量）
let all = bfs_all(graph)
```

**特点**:

- 使用**队列**（FIFO）管理待访问节点
- `levels[]` 数组记录每层的距离
- `parents[]` 记录前驱，支持 O(k) 路径重建（k = 路径长度）

**适用场景**: 无权图最短路径、层级遍历、社交网络 N 度好友。

> ⚠️ **重要限制 (v0.16.0 更新)**
>
> `bfs_shortest_path()` 仅适用于**无权图**（所有边权重相同）。
> 对于**有权图**，请使用：
> - [`dijkstra()`](../shortest_path/) — O((V+E)logV)
> - [`dijkstra_targeted()`](../shortest_path/) — 单目标优化
> - [`bellman_ford()`](../shortest_path/) — 支持负权边
>
> **推荐场景**：社交网络"六度分隔"、网页链接距离、无权图快速查询

### 2. DFS — 深度优先搜索

从起点开始**沿一条路径尽可能深入**，回溯后探索其他分支。

```moonbit
// 单源 DFS（迭代式，避免递归栈溢出）
let result : DfsResult = dfs(graph, @core.NodeId(0))

// 全图 DFS
let all = dfs_all(graph)
```

**特点**:

- 使用**显式栈**模拟递归（MoonBit 安全做法）
- `entry_time[]` / `exit_time[]` 记录发现/完成时刻
- 与 BFS 的区别：**可达节点集合相同，但访问顺序不同**

**适用场景**: 拓扑排序、环检测、连通分量、迷宫求解、回溯搜索。

### 3. 环检测

自动根据图的 `is_directed()` 分派到对应实现：

| 图类型 | 方法                        |  时间  | 空间 |
| :----: | --------------------------- | :----: | :--: |
| 有向图 | **DFS 三色标记** (白→灰→黑) | O(V+E) | O(V) |
| 无向图 | **DFS + 父节点排除**        | O(V+E) | O(V) |

```moonbit
// 自动分派（推荐）
has_cycle(my_graph)              // true / false

// 显式指定（编译期安全）
has_directed_cycle(dag_graph)     // false
has_undirected_cycle(tree_graph)  // false
```

**有向环检测原理（三色标记）**:

```txt
白(0): 未访问 → 可以开始探索
灰(1): 正在访问中 → 遇到灰节点 = 发现反向边 = 存在环！
黑(2): 已完成 → 无需再处理
```

**无向环检测原理（父节点排除）**:

```txt
DFS 遇到已访问邻居时：
  - 如果是父节点 → 忽略（这是来时的边，不是环）
  - 如果不是父节点 → 发现环！
```

**边界情况**:

- 空图 → `false`
- 单节点 → `false`
- 自环 (a→a) → `true` ✅

### 4. 拓扑排序

仅适用于 **有向无环图 (DAG)**。返回一个线性序列，使得对图中每条边 u→v，u 在 v 之前。

提供两种等价实现：

#### Kahn 算法（BFS 式）

基于**入度**：每次移除入度为 0 的节点加入结果。

```txt
1. 统计所有节点的入度
2. 将入度为 0 的节点入队
3. 反复弹出队首，加入结果，邻居入度 -1
4. 若邻居入度变为 0 则入队
5. 若结果长度 < 节点数 → 存在环
```

#### DFS 算法（逆后序式）

利用**完成时间降序**：DFS 完成时间越晚的节点，在拓扑序中越靠前。

```txt
1. 对每个未访问节点执行 DFS
2. 完成时将节点加入列表
3. 列表反转即为拓扑序
4. 若 DFS 过程中发现 on_stack 回边 → 存在环
```

```moonbit
match topo_sort_kahn(dag) {
  Ok(order) => println("拓扑序: ${order}")
  Err(msg) => println("错误: ${msg}")  // "graph contains a cycle"
}

match topo_sort_dfs(dag) {
  Ok(order) => println("拓扑序: ${order}")
  Err(msg) => println("错误: ${msg}")
}
```

**Kahn vs DFS 对比**:

| 特性       | Kahn                               | DFS                  |
| ---------- | ---------------------------------- | -------------------- |
| 数据结构   | 队列 + 入度数组                    | 栈 + on_stack 数组   |
| 结果确定性 | 不唯一（同入度的节点顺序依赖实现） | 不唯一               |
| 环检测方式 | 结果数量 < 节点数                  | on_stack 回边        |
| 典型应用   | 课程调度（先修课）                 | 构建系统（依赖解析） |

---

## 泛型约束体系

本包的所有函数都通过 **trait 约束** 接收图参数，不依赖任何具体存储结构：

```txt
                    ┌─────────────────────────────┐
                    │      GraphReadable          │
                    │  (bfs / dfs / has_cycle /    │
                    │   has_undirected_cycle /     │
                    │   bfs_all / dfs_all)        │
                    └──────────────┬──────────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │      GraphDirected           │
                    │  (has_directed_cycle /       │
                    │   topo_sort_kahn /           │
                    │   topo_sort_dfs)             │
                    └─────────────────────────────┘
```

这意味着 **8 种存储结构全部可用作输入**：

| 存储类型                | Writable | Directed | 可用作 BFS/DFS | 可用作 TopoSort |
| ----------------------- | :------: | :------: | :------------: | :-------------: |
| DirectedAdjList         |    ✅    |    ✅    |       ✅       |       ✅        |
| UndirectedAdjList       |    ✅    |    ❌    |       ✅       |       ❌        |
| DirectedMatrix          |    ✅    |    ✅    |       ✅       |       ✅        |
| UndirectedMatrix        |    ✅    |    ❌    |       ✅       |       ❌        |
| EdgeListGraph           |    ✅    |    ✅    |       ✅       |       ✅        |
| UndirectedEdgeListGraph |    ✅    |    ❌    |       ✅       |       ❌        |
| CSRGraph                |    ❌    |    ✅    |       ✅       |       ✅        |
| CSCGraph                |    ❌    |    ✅    |       ✅       |       ✅        |

> **跨存储一致性已通过 20 个 cross_storage_test 验证** ✅

---

## 复杂度一览

| 算法                   |  时间  | 空间 | 特点                    |
| ---------------------- | :----: | :--: | ----------------------- |
| `bfs`                  | O(V+E) | O(V) | 层级有序，最短路径      |
| `bfs_all`              | O(V+E) | O(V) | 多分量全覆盖            |
| `bfs_shortest_path`    | O(V+E) | O(V) | 无权图最短路            |
| `dfs`                  | O(V+E) | O(V) | 深度优先，时间戳        |
| `dfs_all`              | O(V+E) | O(V) | 多分量全覆盖            |
| `has_cycle`            | O(V+E) | O(V) | 自动分派有向/无向       |
| `has_directed_cycle`   | O(V+E) | O(V) | 三色标记法              |
| `has_undirected_cycle` | O(V+E) | O(V) | 父节点排除法            |
| `topo_sort_kahn`       | O(V+E) | O(V) | 基于 BFS，入度为 0 优先 |
| `topo_sort_dfs`        | O(V+E) | O(V) | 基于 DFS，逆后序        |

---

## 💡 使用提示

### bfs_all vs dfs_all 的区别

| 函数 | 行为 | 返回结果 |
|------|------|---------|
| `bfs(graph, start)` | 从 start 开始的单源 BFS | 仅遍历 start 所在连通分量 |
| `bfs_all(graph)` | 对每个未访问节点分别启动 BFS | 遍历全图所有连通分量 |
| `dfs(graph, start)` | 从 start 开始的单源 DFS | 仅遍历 start 所在连通分量 |
| `dfs_all(graph)` | 对每个未访问节点分别启动 DFS | 遍历全图所有连通分量 |

**选择建议**：
- 已知起点 → 使用单源版本
- 需要全图遍历/统计连通分量 → 使用 `_all` 版本

---

## 测试覆盖

| 文件                   | 类型     | 测试数 | 覆盖重点                                       |
| ---------------------- | -------- | :----: | ---------------------------------------------- |
| traversal_test.mbt     | Blackbox | **28** | 空图/单节点/线性/星形/DAG/环/树/自环/断连/拓扑 |
| cross_storage_test.mbt | Blackbox | **20** | AdjList+Matrix+EdgeList+CSR 一致性             |
| **合计**               |          | **48** |                                                |

### 测试场景矩阵

|             场景 | BFS | DFS |  环检测  | 拓扑排序 |
| ---------------: | :-: | :-: | :------: | :------: |
|             空图 | ✅  | ✅  |    ✅    |    ✅    |
|           单节点 | ✅  | ✅  |    ✅    |    ✅    |
|           线性链 | ✅  | ✅  |    —     |    —     |
|           星形图 | ✅  |  —  |    —     |    —     |
|              DAG |  —  |  —  | ✅(无环) |   ✅✅   |
|           有向环 |  —  |  —  | ✅(有环) | ✅(报错) |
|           无向树 |  —  |  —  | ✅(无环) |    —     |
|           无向环 |  —  |  —  | ✅(有环) |    —     |
|             自环 |  —  |  —  |    ✅    |    —     |
|           断连图 | ✅  | ✅  |    ✅    |    —     |
|         路径重建 | ✅  | ✅  |    —     |    —     |
|     时间戳不变量 |  —  | ✅  |    —     |    —     |
| Kahn vs DFS 一致 |  —  |  —  |    —     |    ✅    |
|       **跨存储** | ✅  | ✅  |    ✅    |    ✅    |

---

## 使用示例

### 示例 1: 社交网络好友推荐（BFS 层级）

```moonbit
let network = new_directed()
// ... 构建关注关系图 ...

let result = bfs(network, my_id)

// 一度好友（直接关注）
let level1 : Array[@core.NodeId] = []
for nid in result.base.order {
  if result.distance(nid) == 1 { level1.push(nid) }
}

// 二度好友（朋友的朋友）
let level2 : Array[@core.NodeId] = []
for nid in result.base.order {
  if result.distance(nid) == 2 { level2.push(nid) }
}
```

### 示例 2: 课程依赖排序（拓扑排序）

```moonbit
let courses = new_directed()
// ... 添加课程节点和先修依赖边 ...

match topo_sort_kahn(courses) {
  Ok(schedule) => {
    // schedule 即为合法选课顺序
    for course in schedule {
      println("第${i}门课: ${course}")
    }
  }
  Err(_) => println("存在循环依赖！无法排课")
}
```

### 示例 3: 死锁检测（环检测）

```moonbit
if has_cycle(resource_graph) {
  println("警告：检测到资源依赖环，可能发生死锁！")
} else {
  println("资源分配安全")
}
```

### 示例 4: 迷宫求解（DFS 路径重建）

```moonbit
let maze = new_directed()
// ... 构建迷宫格子图 ...

let result = dfs(maze, entrance)
let escape_path = result.base.path_to(exit)

if escape_path.length() > 0 {
  println("找到出口！路径长度: ${escape_path.length() - 1}")
} else {
  println("无路可逃")
}
```

---

## 后续扩展（不在本次范围）

| 算法               |        依赖本包         | 说明                                 |
| ------------------ | :---------------------: | ------------------------------------ |
| **Dijkstra**       |    BFS distance 思路    | 加权最短路径（非负权）               |
| **Bellman-Ford**   |     has_cycle 变体      | 含负权的最短路径                     |
| **Floyd-Warshall** |       Matrix 友好       | 全源最短路径 O(V³)                   |
| **Kruskal**        |      edges_sorted       | 最小生成树（已有 EdgeIterable 支持） |
| **Prim**           |        BFS 变体         | 最小生成树（稠密图友好）             |
| **SCC (Tarjan)**   |    DfsResult 时间戳     | 强连通分量                           |
| **双连通分量**     | DfsResult + bridge 检测 | 桥 / 割点                            |
| **A\***            |     BFS + 启发函数      | 启发式最短路径                       |

---

## API 变更历史

| 版本 | 日期 | 变更类型 | 说明 |
|:----:|:----:|:-------:|------|
| v0.2.0 | 2026-06-01 | 📝 文档增强 | `bfs_shortest_path()` 添加无权图限制警告和使用场景说明 |
| v0.2.0 | 2026-06-01 | 🔒 可见性调整 | `topo_validates()` 从公共 API 移除（现为测试内部函数）|
| v0.1.0 | 初始版本 | ✨ 初始发布 | 12 个遍历算法函数 |

---

## 相关文档

- **核心类型与 Trait**: [`../core/README.md`](../core/README.md)
- **存储实现**: [`../../storage/README.md`](../../storage/README.md)
- **设计文档**: [`../../../docs/design/traversal_design.md`](../../../docs/design/traversal_design.md)
- **项目规范**: [`../../../../AGENTS.md`](../../../../AGENTS.md)
