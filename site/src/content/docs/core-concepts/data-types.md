---
title: 节点与边的表示
description: 图的基本数据类型：NodeId、Node、Edge 的设计与使用
---

# 节点与边的表示

图（Graph）由**节点（Vertices）**和**边（Edges）**两种基本元素组成。mbtgraph 提供了三个核心类型来表示它们：`NodeId`、`Node` 和 `Edge`。

## 核心类型概览

| 类型 | 定义 | 用途 | 示例 |
|------|------|------|------|
| **NodeId** | `NodeId(Int)` | 节点的唯一标识符 | `NodeId(0)`, `NodeId(42)` |
| **Node** | `{ id: NodeId, data: Double }` | 带数据的节点 | `{ id: NodeId(0), data: 1.0 }` |
| **Edge** | `{ from: NodeId, to: NodeId, data: Double }` | 带权重的有向边 | `{ from: 0, to: 1, data: 2.5 }` |

---

## NodeId - 节点标识符

### 设计原理

`NodeId` 是一个**整数包装类型**，用于唯一标识图中的每个节点：

```moonbit
/// 节点唯一标识符（整数索引）
pub(all) struct NodeId(Int) derive(Debug, Eq)
```

### 为什么使用整数索引？

1. **内存效率**: 整数比字符串或 UUID 占用更少空间
2. **缓存友好**: 连续整数可作为数组下标，提升缓存命中率
3. **O(1) 查找**: 可直接用作邻接表/矩阵的索引
4. **类型安全**: 包装类型防止与普通 Int 混用

### 创建方式

```moonbit
// 方式 1: 直接构造
let node0 = @core.NodeId(0)
let node1 = @core.NodeId(1)

// 方式 2: 从 add_node 返回值获取（推荐）
let g = @storage.new_directed()
let id = @core.GraphWritable::add_node(g, 100.0)  // 返回 NodeId

// 方式 3: 从迭代器获取
@core.GraphReadable::node_ids(g) |> iter::each(fn(id) {
  println("节点 ID: ${id}")
})
```

### 使用注意事项

```moonbit
// ✅ 正确: 使用 NodeId 类型
let id : NodeId = @core.NodeId(0)

// ❌ 错误: 不能直接将 Int 当作 NodeId 使用
// let invalid : NodeId = 0  // 编译错误！

// ✅ 正确: 解构获取内部值（如需）
match id {
  NodeId(n) => println("内部值: ${n}")
}
```

---

## Node - 节点数据结构

### 定义

```moonbit
/// 带数据的节点
///
/// MVP 阶段数据固定为 Double，后续可泛型化为 Node[T]
pub(all) struct Node {
  id : NodeId    // 节点标识符
  data : Double  // 节点权重/标签/属性
} derive(Debug)
```

### 典型应用场景

#### 场景 1: 社交网络中的用户

```moonbit
// 用户节点，data 存储用户影响力分数
let alice = @core.Node {
  id = @core.NodeId(0),
  data = 0.95,  // 影响力指数 [0, 1]
}

let bob = @core.Node {
  id = @core.NodeId(1),
  data = 0.72,
}
```

#### 场景 2: 路径规划中的地点

```moonbit
// 地点节点，data 存储海拔高度
let beijing = @core.Node {
  id = @core.NodeId(0),
  data = 43.5,  // 海拔（米）
}

let shanghai = @core.Node {
  id = @core.NodeId(1),
  data = 4.0,
}
```

#### 场景 3: 网络拓扑中的路由器

```moonbit
// 路由器节点，data 存储处理能力（Gbps）
let router_a = @core.Node {
  id = @core.NodeId(0),
  data = 100.0,  // 100 Gbps
}
```

### 访问节点数据

```moonbit
// 从图中获取节点
let g = create_sample_graph()
let node_data = @core.GraphReadable::get_node(g, @core.NodeId(0))

// 处理 Option 返回值
match node_data {
  Some(data) => println("节点 0 的数据: ${data}")
  None => println("节点不存在！")
}

// 遍历所有节点
@core.GraphReadable::node_ids(g) |> iter::each(fn(id) {
  match @core.GraphReadable::get_node(g, id) {
    Some(data) => println("节点 ${id}: ${data}")
    None => ()  // 正常情况下不会发生
  }
})
```

---

## Edge - 边的数据结构

### 定义

```moonbit
/// 带数据的边
///
/// MVP 阶段数据固定为 Double，后续可泛型化为 Edge[T]
pub(all) struct Edge {
  from : NodeId   // 起点
  to : NodeId     // 终点
  data : Double   // 权重/距离/容量等
} derive(Debug)
```

### 有向 vs 无向边

在 mbtgraph 中，**所有边都是有向的**。无向图通过同时添加两条反向边来模拟：

```moonbit
// 有向边: A → B (权重 2.5)
let edge_ab = @core.Edge {
  from = @core.NodeId(0),  // A
  to = @core.NodeId(1),    // B
  data = 2.5,
}

// 无向边: A ↔ B (需要添加两条边)
let edge_ba = @core.Edge {
  from = @core.NodeId(1),  // B
  to = @core.NodeId(0),    // A
  data = 2.5,              // 相同权重
}
```

### 权重的语义

`data` 字段的含义取决于具体算法：

| 场景 | data 含义 | 典型值范围 | 示例 |
|------|----------|-----------|------|
| **最短路径** | 距离/成本 | 正实数 | `10.5` km |
| **网络流** | 容量/流量 | 正实数 | `100.0` Mbps |
| **PageRank** | 初始排名 | [0, 1] | `0.25` |
| **推荐系统** | 相似度/强度 | [0, 1] 或任意正数 | `0.85` |
| **依赖分析** | 依赖强度 | 整数或正实数 | `1.0`, `2.0` |

### 创建和查询边

```moonbit
// 添加边到图
let g = @storage.new_directed()
let g = @core.GraphWritable::add_node(g, 0.0)  // 节点 0
let g = @core.GraphWritable::add_node(g, 0.0)  // 节点 1
let result = @core.GraphWritable::add_edge(
  g,
  @core.NodeId(0),  // from
  @core.NodeId(1),  // to
  5.0              // weight
)

// 处理 Result
match result {
  Ok(_) => println("边添加成功")
  Err(e) =>
    match e {
      NodeNotFound(id) => println("节点 ${id} 不存在")
      EdgeAlreadyExists(f, t) => println("边 (${f}, ${t}) 已存在")
      InvalidNodeId => println("无效的节点 ID")
    }
}

// 查询边是否存在
if (@core.GraphReadable::contains_edge(g, @core.NodeId(0), @core.NodeId(1))) {
  let weight = @core.GraphReadable::get_edge(g, @core.NodeId(0), @core.NodeId(1))
  match weight {
    Some(w) => println("边权重: ${w}")
    None => println("边不存在")  // 理论上不会执行
  }
}
```

### 遍历邻居

```moonbit
// 获取节点的所有邻居（出边目标）
println("节点 0 的邻居:")
@core.GraphReadable::neighbors(g, @core.NodeId(0))
  |> iter::each(fn(neighbor) {
    println("  -> ${neighbor}")
  })

// 获取带权重的邻居（避免二次查询）
println("节点 0 的加权邻居:")
@core.GraphReadable::neighbors_with_weight(g, @core.NodeId(0))
  |> iter::each(fn((neighbor, weight)) {
    println("  -> ${neighbor} (权重: ${weight})")
  })
```

---

## 完整示例：构建一个简单图

```moonbit
fn build_social_network() -> DirectedAdjList {
  // 创建空的有向邻接表
  let mut g = @storage.new_directed()

  // 添加用户节点
  let alice_id = @core.GraphWritable::add_node(g, 0.95)   // Alice
  let bob_id = @core.GraphWritable::add_node(g, 0.72)     // Bob
  let charlie_id = @core.GraphWritable::add_node(g, 0.88) // Charlie

  // 添加关注关系（有向边）
  // Alice 关注 Bob 和 Charlie
  @core.GraphWritable::add_edge(g, alice_id, bob_id, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, alice_id, charlie_id, 1.0) |> ignore

  // Bob 关注 Charlie
  @core.GraphWritable::add_edge(g, bob_id, charlie_id, 1.0) |> ignore

  // Charlie 回关注 Alice（互关）
  @core.GraphWritable::add_edge(g, charlie_id, alice_id, 1.0) |> ignore

  g
}

// 使用示例
fn main() {
  let network = build_social_network()

  // 统计信息
  println("用户数量: ${@core.GraphReadable::node_count(network)}")
  println("关注关系数: ${@core.GraphReadable::edge_count(network)}")

  // 查看 Alice 的关注列表
  println("\nAlice 关注的用户:")
  @core.GraphReadable::neighbors_with_weight(network, @core.NodeId(0))
    |> iter::each(fn((user_id, weight)) {
      println("  -> 用户 ${user_id}")
    })
}
```

**输出**:
```
用户数量: 3
关注关系数: 4

Alice 关注的用户:
  -> 用户 1 (Bob)
  -> 用户 2 (Charlie)
```

---

## 最佳实践

### 1. 始终检查返回值

```moonbit
// ✅ 推荐: 处理 Result
match @core.GraphWritable::add_edge(g, from, to, weight) {
  Ok(_) => // 成功
  Err(NodeNotFound(_)) => // 处理节点不存在
  Err(EdgeAlreadyExists(_, _)) => // 处理重复边
  _ => ()
}

// ❌ 不推荐: 忽略错误可能导致静默失败
@core.GraphWritable::add_edge(g, from, to, weight) |> ignore
```

### 2. 批量操作时注意顺序

```moonbit
// ✅ 正确: 先添加所有节点，再添加边
let mut g = @storage.new_directed()
let ids = Array::map(
  Array::range(0, 100),
  fn(i) { @core.GraphWritable::add_node(g, 0.0) }
)
// 现在可以安全地添加边...

// ❌ 错误: 在节点存在前添加边会导致 NodeNotFound 错误
```

### 3. 利用链式赋值

```moonbit
// MoonBit 的纯函数语义要求消费返回值
let g = @storage.new_directed()
let g = @core.GraphWritable::add_node(g, 1.0)     // 必须接收新实例
let g = @core.GraphWritable::add_node(g, 2.0)
let g = @core.GraphWritable::add_edge(g, id0, id1, 3.0) |> ignore  // 或显式 ignore
```

### 4. 选择合适的数据语义

```moonbit
// 最短路径: data 表示距离，越小越好
let road = @core.Edge { from = A, to = B, data = 10.5 }  // 10.5 km

// 推荐系统: data 表示相似度，越大越好
let similarity = @core.Edge { from = user1, to = user2, data = 0.95 }

// 网络流: data 表示容量，非负数
let bandwidth = @core.Edge { from = router1, to = router2, data = 1000.0 }  // 1 Gbps
```

---

## 类型安全保证

mbtgraph 在编译期提供强类型检查：

```moonbit
// ✅ 编译通过: 参数类型正确
let id : NodeId = @core.NodeId(0)
let exists : Bool = @core.GraphReadable::contains_node(g, id)

// ❌ 编译错误: 类型不匹配
// let invalid = @core.GraphReadable::contains_node(g, 0)  // Int ≠ NodeId

// ❌ 编译错误: Option 必须处理
// let data = @core.GraphReadable::get_node(g, id)  // 返回 Double?，不能直接使用
```

这种设计确保了：
- **无空指针异常**: 所有可能失败的 API 都返回 `Option` 或 `Result`
- **类型推断清晰**: `NodeId` 不会与普通 `Int` 混淆
- **重构安全**: 修改类型定义会触发编译错误，而非运行时 bug

---

## 下一步

理解了基本数据类型后，接下来学习：

- **[5 层 Trait 详解](/core-concepts/traits/)** - 了解如何通过 Trait 抽象访问这些类型
- **[存储选型指南](/core-concepts/storage-guide/)** - 根据需求选择合适的底层存储
- **[创建第一个图](/getting-started/first-graph/)** - 动手实践完整示例

---

<div class="callout" data-color="note">
  <div class="callout-header">
    <span class="callout-icon">📖</span>
    <p class="callout-title">深入阅读</p>
  </div>
  <div class="callout-content">
    <p>源码位置：</p>
    <ul>
      <li><a href="https://github.com/your-repo/mbtgraph/blob/main/lib/core/types.mbt" target="_blank">lib/core/types.mbt</a> - 类型定义</li>
      <li><a href="/api/core/">API 参考 - Core 模块</a></li>
    </ul>
  </div>
</div>
