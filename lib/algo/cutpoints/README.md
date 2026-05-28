# Cutpoints 割点 & 桥 (Articulation Points & Bridges)

## 简介

本模块提供**割点（关节点）**和**桥（关键边）**的查找算法，
基于 **Tarjan DFS** 实现，时间复杂度 **O(V+E)**。

割点和桥是图论中的重要概念，广泛应用于网络可靠性分析、关键基础设施识别等领域。

## 快速开始

### 查找割点

```moonbit
let g = make_chain_graph(5)  // 0-1-2-3-4
let result = find_articulation_points_undirected(g)

if result.count > 0 {
  println("割点数量: ${result.count}")
  for cp in result.cut_points {
    println("割点节点: ${cp.value()}")
  }
}
// 输出:
// 割点数量: 3
// 割点节点: 1
// 割点节点: 2
// 割点节点: 3
```

### 查找桥

```moonbit
let g = make_chain_graph(5)
let result = find_bridges_undirected(g)

for bridge in result.bridges {
  println("桥: ${bridge.from.id.value()} -> ${bridge.to.id.value()}")
}
println("总桥数: ${result.count}")
// 输出:
// 桥: 0 -> 1
// 桥: 1 -> 2
// 桥: 2 -> 3
// 桥: 3 -> 4
// 总桥数: 4
```

### 有向图的基图分析

```moonbit
let mut g = @storage.DirectedAdjList::new(4)
g = @storage.DirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
g = @storage.DirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
g = @storage.DirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
g = @storage.DirectedAdjList::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0)

let ap_result = find_articulation_points_directed(g)
let br_result = find_bridges_directed(g)

println("有向环基图 - 割点数: ${ap_result.count}, 桥数: ${br_result.count}")
// 输出: 有向环基图 - 割点数: 0, 桥数: 0
```

## API 参考

### 核心函数

| 函数 | 说明 | 复杂度 | 适用图类型 |
|------|------|--------|-----------|
| `find_articulation_points_undirected` | 无向图割点查找 | O(V+E) | 无向图 (GraphReadable) |
| `find_articulation_points_directed` | 有向图基图割点查找 | O(V+E) | 有向图 (GraphDirected) |
| `find_bridges_undirected` | 无向图桥查找 | O(V+E) | 无向图 (GraphReadable) |
| `find_bridges_directed` | 有向图基图桥查找 | O(V+E) | 有向图 (GraphDirected) |

### 结果类型

#### CutPointResult（割点结果）

```moonbit
pub(all) struct CutPointResult {
  cut_points : Array[@core.NodeId]  // 所有割点的有序列表
  is_cut_point : Array[Bool]        // is_cut_point[i] = 节点 i 是否为割点
  count : Int                       // 割点总数
}
```

#### BridgeResult（桥结果）

```moonbit
pub(all) struct BridgeResult {
  bridges : Array[@core.Edge]  // 所有桥的边列表
  is_bridge : Array[Bool]      // is_bridge[i] = 边 i 是否为桥
  count : Int                  // 桥的总数
}
```

## 算法原理

### Tarjan DFS 割点算法

对每个节点 `u` 维护两个关键值：

- **disc[u]**: DFS 发现时间（discovery time）
- **low[u]**: `u` 或 `u` 的后代能通过回边到达的最小 disc 值

#### 割点判定规则

1. **根节点规则**: 如果 `u` 是 DFS 树的根且有 ≥ 2 个子树 → `u` 是割点
2. **非根节点规则**: 如果存在子节点 `v` 使得 `low[v] ≥ disc[u]` → `u` 是割点

### Tarjan DFS 桥算法

边 `(u, v)` 是**桥**当且仅当：

**low[v] > disc[u]**

这意味着 `v` 无法通过任何其他路径回到 `u` 或 `u` 的祖先，因此边 `(u, v)` 是唯一连接两个部分的桥梁。

### 算法特点

- ✅ **单次遍历**: 只需一次 DFS 即可找出所有割点/桥
- ✅ **线性时间**: 时间复杂度 O(V+E)，适合大规模图
- ✅ **通用性**: 支持无向图和有向图（基于基图）
- ✅ **完整信息**: 返回结果包含详细的位置信息（数组索引）

## 应用场景

### 🌐 网络可靠性分析

识别网络中的关键节点和链路，移除这些元素会导致网络分割：

```moonbit
// 分析通信网络的脆弱性
let network = build_communication_network()
let critical_nodes = find_articulation_points_undirected(network)
println("关键节点数量: ${critical_nodes.count}")
```

### 🏗️ 关键基础设施识别

在电力网、供水系统、交通网络中识别关键设施：

```moonbit
let power_grid = build_power_grid()
let critical_links = find_bridges_undirected(power_grid)
for link in critical_links.bridges {
  println("关键线路: ${link.from.id.value()} <-> ${link.to.id.value()}")
}
```

### 🔗 社交网络影响力分析

识别社交网络中的关键人物（意见领袖）：

```moonbit
let social_network = build_social_graph()
let influencers = find_articulation_points_undirected(social_network)
for person in influencers.cut_points {
  println("意见领袖: 用户 #${person.value()}")
}
```

### 📍 VLSI 电路板设计

在集成电路设计中识别关键连线，优化布线：

```moonbit
let circuit = build_circuit_graph()
let critical_wires = find_bridges_undirected(circuit)
println("需要冗余设计的连线数: ${critical_wires.count}")
```

## 测试

### 运行测试

```bash
# 运行 cutpoints 模块的全部测试
moon test lib/algo/cutpoints

# 更新测试快照（如有变更）
moon test lib/algo/cutpoints --update
```

### 测试覆盖

**总计 ~15 个测试用例**，覆盖以下场景：

#### 基础功能测试 (~30%)

| 测试名称 | 验证内容 |
|---------|---------|
| `chain_graph_has_cutpoints` | 链图中间节点是割点 |
| `cycle_graph_no_cutpoints` | 环图无割点 |
| `star_graph_center_is_cutpoint` | 星形图中心是割点 |
| `complete_graph_no_cutpoints` | 完全图无割点 |

#### 算法正确性测试 (~27%)

| 测试名称 | 验证内容 |
|---------|---------|
| `two_cycles_sharing_node` | 双环共享节点的割点检测 |
| `bridge_in_simple_graph` | 简单图中桥的正确识别 |
| `cycle_has_no_bridges` | 环图无桥 |
| `single_edge` | 单边图的割点和桥 |

#### 边界情况测试 (~27%)

| 测试名称 | 验证内容 |
|---------|---------|
| `empty_graph` | 空图处理 |
| `single_node` | 单节点图处理 |
| `directed_graph_base_cutpoints` | 有向图基图割点 |
| `directed_graph_base_bridges` | 有向图基图桥 |
| `grid_2x3_cutpoints` | 网格图割点检测 |

#### 属性验证测试 (~16%)

| 测试名称 | 验证内容 |
|---------|---------|
| `cutpoint_count_bound` | 割点数量上界验证 (≤ V-2) |
| `cutpoint_is_valid` | 割点有效性验证 |

## 设计决策

### 为什么使用独立类型而非 Graph Trait？

割点和桥算法具有以下特殊性：
1. **语义特殊**: 需要维护 DFS 状态（disc、low、parent），与普通图操作不同
2. **性能优化**: 使用数组而非哈希表存储状态，提高缓存命中率
3. **结果丰富**: 返回详细的位置信息（布尔数组），便于后续分析

### 有向图为何转换为基图？

对于有向图，割点和桥的定义通常基于其**基图**（underlying undirected graph）：
- 忽略边的方向，将其视为无向图
- 这样可以识别结构上的薄弱环节，无论方向如何
- 符合大多数实际应用场景的需求

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v1.0.0** | 2026-05-22 | 初始版本：Tarjan 割点和桥算法，~15 个测试用例 |

## 相关模块

- [connectivity](../connectivity/README.md): 连通分量、强连通分量
- [mst](../mst/README.md): 最小生成树（Kruskal/Prim）
- [shortest_path](../shortest_path/README.md): 最短路径算法

## 许可证

本项目采用 MIT 许可证。详见项目根目录的 LICENSE 文件。
