# Connectivity API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/connectivity`
> **路径**: `lib/algo/connectivity/`

## 概述

Connectivity 模块提供连通分量和强连通分量检测算法。

---

## 函数

### connected_components

```moonbit
pub fn[G : @core.GraphReadable] connected_components(G) -> ConnectedComponentsResult
```

无向图连通分量检测。

**返回**: `ConnectedComponentsResult`

---

### tarjan_scc

```moonbit
pub fn[G : @core.GraphDirected] tarjan_scc(G) -> StronglyConnectedComponentsResult
```

Tarjan 算法：有向图强连通分量检测。

**特点**:
- 一次 DFS 完成
- 时间复杂度 O(V + E)

---

### kosaraju_scc

```moonbit
pub fn[G : @core.GraphDirected] kosaraju_scc(G) -> StronglyConnectedComponentsResult
```

Kosaraju 算法：有向图强连通分量检测。

**特点**:
- 两次 DFS
- 需要转置图

---

### biconnected_components

```moonbit
pub fn[G : @core.GraphReadable] biconnected_components(G) -> BiconnectedComponentsResult
```

双连通分量检测（找到所有割点和桥）。

---

## 结果类型

### ConnectedComponentsResult

```moonbit
pub(all) struct ConnectedComponentsResult {
  components : Array[Array[@core.NodeId]]
}
pub fn ConnectedComponentsResult::component_of(Self, @core.NodeId) -> Int
pub fn ConnectedComponentsResult::count(Self) -> Int
pub fn ConnectedComponentsResult::size(Self, Int) -> Int
```

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `component_of(NodeId)` | `Int` | 获取节点所属分量 ID |
| `count()` | `Int` | 连通分量数量 |
| `size(Int)` | `Int` | 获取指定分量的大小 |

---

### StronglyConnectedComponentsResult

```moonbit
pub(all) struct StronglyConnectedComponentsResult {
  components : Array[Array[@core.NodeId]]
}
pub fn StronglyConnectedComponentsResult::component_of(Self, @core.NodeId) -> Int
pub fn StronglyConnectedComponentsResult::count(Self) -> Int
```

---

### BiconnectedComponentsResult

```moonbit
pub(all) struct BiconnectedComponentsResult {
  components : Array[Array[@core.NodeId]]
  articulation_points : Array[@core.NodeId]
}
pub fn BiconnectedComponentsResult::count(Self) -> Int
pub fn BiconnectedComponentsResult::is_articulation_point(Self, @core.NodeId) -> Bool
```

**方法**:
| 方法 | 返回类型 | 说明 |
|------|---------|------|
| `count()` | `Int` | 双连通分量数量 |
| `is_articulation_point(NodeId)` | `Bool` | 检查节点是否为割点 |

---

## 使用示例

```moonbit
// 无向图连通分量
let cc = @connectivity.connected_components(g)
println("Components: \{cc.count()}")

// 有向图强连通分量
let scc = @connectivity.tarjan_scc(directed_g)
for component in scc.components {
  println("SCC: \{component}")
}
```
