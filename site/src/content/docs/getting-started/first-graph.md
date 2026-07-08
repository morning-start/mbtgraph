---
title: 第一个图程序
description: 5 分钟上手 mbtgraph，构建并操作你的第一个图
---

# 第一个图程序

在本教程中，我们将用 5 分钟时间创建一个简单的社交网络图，并进行基本的遍历操作。

## 目标

- 创建一个包含 5 个用户的有向图
- 添加关注关系（边）
- 执行 BFS 遍历，发现可达的用户

## 步骤 1：创建项目结构

```bash
moon new social_network
cd social_network
```

## 步骤 2：编写代码

创建文件 `src/main/main.mbt`：

```moonbit
// 📁 src/main/main.mbt
// 社交网络示例：构建关注关系图

fn main {
  // 1️⃣ 创建有向邻接表（存储结构）
  let g = @storage.new_directed()

  // 2️⃣ 添加节点（用户），返回 NodeId
  let n0 = @core.GraphWritable::add_node(g, 0.0)
  let n1 = @core.GraphWritable::add_node(g, 1.0)
  let n2 = @core.GraphWritable::add_node(g, 2.0)
  let n3 = @core.GraphWritable::add_node(g, 3.0)
  let n4 = @core.GraphWritable::add_node(g, 4.0)

  // 3️⃣ 添加边（关注关系）
  // 0 -> 1, 2
  @core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
  @core.GraphWritable::add_edge(g, n0, n2, 1.0) |> ignore

  // 1 -> 3
  @core.GraphWritable::add_edge(g, n1, n3, 1.0) |> ignore

  // 2 -> 4
  @core.GraphWritable::add_edge(g, n2, n4, 1.0) |> ignore

  // 4️⃣ 执行 BFS 遍历（从节点 0 出发）
  let result = @traversal.bfs(g, n0)

  // 5️⃣ 输出结果
  println("=== 社交网络分析 ===")
  println("总用户数: \{g.node_count()}")
  println("总关注关系: \{g.edge_count()}")
  println("")
  println("从节点 0 出发的 BFS 层级:")
  for i in 0..<g.node_count() {
    let level = result.levels[i]
    if level >= 0 {
      println("  节点 \{i}: 层级 \{level}")
    }
  }
}
```

## 步骤 3：运行程序

```bash
moon run src/main/main.mbt
```

## 预期输出

```
=== 社交网络分析 ===
总用户数: 5
总关注关系: 4

从节点 0 出发的 BFS 层级:
  节点 0: 层级 0
  节点 1: 层级 1
  节点 2: 层级 1
  节点 3: 层级 2
  节点 4: 层级 2
```

## 代码解析

### 存储选择

我们选择了 `DirectedAdjList`（有向邻接表），这是最通用的存储结构：
- ✅ 支持有向图
- ✅ 动态添加节点和边
- ✅ 高效的邻居查询 O(k)，k 为邻居数
- ✅ 适合大多数场景

### 可变图 API

mbtgraph 的存储结构采用**就地修改（mutable）** 设计：

```moonbit
let g = @storage.new_directed()
let n0 = @core.GraphWritable::add_node(g, 0.0)  // g 就地修改，返回 NodeId
```

- `add_node` 直接在原图上添加节点，返回新节点的 `NodeId`
- `add_edge` 直接在原图上添加边，返回 `Result[Unit, GraphError]`
- 所有修改操作都通过 `GraphWritable` trait 完成

这种设计简单直观，适合多数场景。

### 泛型函数调用

BFS 函数是泛型的，可以接受任何实现了 `GraphReadable` Trait 的存储：

```moonbit
let result = @traversal.bfs(g, start)
// g 可以是 AdjList, Matrix, CSR, EdgeList...
```

这就是 **Trait 分层架构** 的威力！

## 下一步

现在你已经掌握了基本用法，接下来可以：

1. [学习核心概念](/core-concepts/index/) - 深入理解 Trait 系统
2. [探索存储选型](/core-concepts/storage-guide/) - 选择最适合你场景的存储
3. [学习 BFS 教程](/algorithms/traversal/bfs/index/) - 完整的算法原理讲解

## 练习

尝试修改上面的代码：

1. 添加更多用户和关注关系
2. 尝试不同的存储结构（如 `UndirectedAdjList`）
3. 使用 DFS 替代 BFS，观察结果的差异

---

<div class="callout" data-color="note">
  <div class="callout-header">
    <span class="callout-icon">🎉</span>
    <p class="callout-title">恭喜！</p>
  </div>
  <div class="callout-content">
    <p>你已经成功创建了第一个 mbtgraph 程序！这只是冰山一角，mbtgraph 还提供了 90+ 个已实现图算法，覆盖 32 个算法类别，等待你去探索。</p>
  </div>
</div>
