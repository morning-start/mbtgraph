# 连通性分析 (`connectivity`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 21 通过

提供图的连通性分析能力：无向连通分量提取 + 有向强连通分量检测（Tarjan / Kosaraju）。

## 依赖

| 包                        | 用途                                                     |
| ------------------------- | -------------------------------------------------------- |
| [`@core`](../core/)       | 类型定义 + Trait 约束 (`GraphReadable`, `GraphDirected`) |
| [`@storage`](../storage/) | 具体存储实现（测试用）                                   |

## 文件结构

```
lib/algorithms/connectivity/
├── moon.pkg                # 包配置
├── types.mbt               # ConnectedComponents + SCC 结果类型 + 方法
├── components.mbt          # 无向连通分量 (BFS 分组)
├── tarjan.mbt              # Tarjan 强连通分量 (lowlink 栈)
├── kosaraju.mbt            # Kosaraju 强连通分量 (双 DFS)
└── connectivity_test.mbt   # 21 个测试
```

## API 总览

### 无向连通分量结果 — [types.mbt](types.mbt)

```moonbit
pub(all) struct ConnectedComponents {
  components : Array[Array[@core.NodeId>]   // 每个分量一组节点
}
```

| 方法               | 返回类型 | 说明                              |
| ------------------ | -------- | --------------------------------- |
| `count()`          | `Int`    | 连通分量总数                      |
| `component_of(id)` | `Int`    | 节点所属分量索引（不存在返回 -1） |
| `size(comp_id)`    | `Int`    | 指定分量的节点数                  |

### 强连通分量结果 — [types.mbt](types.mbt)

```moonbit
pub(all) struct StronglyConnectedComponents {
  components : Array[Array[@core.NodeId>]
}
```

| 方法               | 返回类型 | 说明              |
| ------------------ | -------- | ----------------- |
| `count()`          | `Int`    | 强连通分量总数    |
| `component_of(id)` | `Int`    | 节点所属 SCC 索引 |

### 无向连通分量 ([components.mbt](components.mbt))

**基于 BFS 的 visited[] 分组** — 时间复杂度 O(V+E)

| 函数                      | Trait 约束      | 返回                  |
| ------------------------- | --------------- | --------------------- |
| `connected_components(g)` | `GraphReadable` | `ConnectedComponents` |

**原理**: 对每个未访问节点启动 BFS，收集所有可达节点作为一个连通分量。重复直到所有节点被访问。

### Tarjan SCC ([tarjan.mbt](tarjan.mbt))

**基于 DFS lowlink 的单次遍历算法** — 时间复杂度 O(V+E)

| 函数            | Trait 约束      | 返回                          |
| --------------- | --------------- | ----------------------------- |
| `tarjan_scc(g)` | `GraphDirected` | `StronglyConnectedComponents` |

**原理**:

- 对每个未访问节点执行 DFS
- 维护 `index[]`（发现时间戳）和 `low_link[]`（能到达的最小时间戳）
- 当 `low_link[v] == index[v]` 时，栈顶到 v 构成一个 SCC
- 使用 `TarjanState` 结构体承载可变状态（MoonBit 限制）

### Kosaraju SCC ([kosaraju.mbt](kosaraju.mbt))

**基于两次 DFS 的经典算法** — 时间复杂度 O(V+E)

| 函数              | Trait 约束      | 返回                          |
| ----------------- | --------------- | ----------------------------- |
| `kosaraju_scc(g)` | `GraphDirected` | `StronglyConnectedComponents` |

**原理**:

1. **第一次 DFS**: 在原图上遍历，记录节点的**完成顺序**（后序）
2. **第二次 DFS**: 按**逆完成顺序**在转置图上（用 `in_neighbors` 模拟）遍历
3. 每次第二遍 DFS 发现的节点集合即为一个 SCC

## 使用示例

### 无向连通分量

```moonbit
// 两个独立分量: {0, 1} 有边连接，{2, 3} 有边连接
let g = @storage.new_undirected()
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore

let cc = connected_components(g)
cc.count()                           // => 2
cc.size(0)                            // => 2
cc.size(1)                            // => 2
cc.component_of(@core.NodeId(0))      // => 0
cc.component_of(@core.NodeId(2))      // => 1
```

### Tarjan 强连通分量

```moonbit
// 环: 0→1→2→0 (SCC#1), 尾巴: 2→3 (SCC#2)
let g = @storage.new_directed()
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0) |> ignore

let scc = tarjan_scc(g)
scc.count()                    // => 2
scc.component_of(@core.NodeId(0))  // => 0 (环内)
scc.component_of(@core.NodeId(3))  // => 1 (孤立尾节点)
```

### Kosaraju 强连通分量

```moonbit
// 同上图，两种算法结果一致
let kscc = kosaraju_scc(g)
kscc.count()                   // => 2
assert_true(scc.count() == kscc.count())
```

## 算法选择指南

| 场景                   | 推荐算法                       | 原因                   |
| ---------------------- | ------------------------------ | ---------------------- |
| 无向图连通性           | `connected_components`         | 唯一选项，O(V+E) BFS   |
| 有向图 SCC（通用）     | **Tarjan**                     | 单次 DFS，无需反转图   |
| 有向图 SCC（简洁实现） | **Kosaraju**                   | 逻辑直观：DFS × 2      |
| DAG 检测               | Tarjan/Kosaraju                | SCC 数 == 节点数 → DAG |
| 孤立节点识别           | `component_of` + `size(id)==1` | 任意 CC/SCC 结果       |

## Tarjan vs Kosaraju 对比

| 特性       | Tarjan                   | Kosaraju                                       |
| ---------- | ------------------------ | ---------------------------------------------- |
| DFS 次数   | **1 次**                 | **2 次**                                       |
| 额外空间   | O(V) 栈 + O(V) 数组      | O(V) finish_order + visited×2                  |
| 图访问方式 | 原图 neighbors           | 第1次原图 + 第2次 **in_neighbors**（转置语义） |
| Trait 约束 | `GraphDirected`          | `GraphDirected`                                |
| 实现复杂度 | 较高（lowlink + 栈管理） | 较低（两次标准 DFS）                           |
| 典型应用   | 需要频繁调用             | 一次性分析                                     |

## 边界行为

| 条件                    | connected_components | Tarjan                      | Kosaraju |
| ----------------------- | -------------------- | --------------------------- | -------- |
| 空图 (V=0)              | count=0              | count=0                     | count=0  |
| 全不连通 (V 个孤立节点) | count=V              | count=V                     | count=V  |
| 完全有向图              | N/A                  | count=1（全体 SCC）         | count=1  |
| DAG（无环有向图）       | N/A                  | count=V（每个节点独立 SCC） | count=V  |
| 自环单节点              | count=1              | count=1（自成 SCC）         | count=1  |

## 测试覆盖

| 类别           |  数量  | 内容                                     |
| -------------- | :----: | ---------------------------------------- |
| 无向 CC 基础   |   5    | 全连通/双分量/孤立节点/空图/component_of |
| Tarjan SCC     |   5    | 环图/DAG/空图/自环/环大小验证            |
| Kosaraju SCC   |   3    | 环图/DAG/空图                            |
| 一致性验证     |   1    | Tarjan vs Kosaraju 分量数一致            |
| **跨存储兼容** | **4**  | AdjList(Matrix)/EdgeList × 3 种算法      |
| **合计**       | **21** |                                          |

## 与其他模块配合

```moonbit
// 判断图是否为 DAG（无环有向图）
let scc = tarjan_scc(g)
let is_dag = scc.count() == @core.GraphReadable::node_count(g)

// 连通性 + MST 协同验证
let cc = connected_components(undirected_g)
let mst = kruskal(undirected_g)
// MST 边数 = 节点数 - 连通分量数
assert_true(mst.edge_count() == node_count - cc.count())

// SCC + 拓扑排序协同
let scc = tarjan_scc(dag)
if scc.count() > 1 {
  let order = topo_sort_kahn(dag)  // DAG 才能拓扑排序
}
```
