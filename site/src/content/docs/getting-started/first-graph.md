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
  let mut g = @storage.DirectedAdjList::new()

  // 2️⃣ 添加节点（用户）
  g = @core.GraphWritable::add_node(g, "Alice") |> ignore
  g = @core.GraphWritable::add_node(g, "Bob") |> ignore
  g = @core.GraphWritable::add_node(g, "Charlie") |> ignore
  g = @core.GraphWritable::add_node(g, "Diana") |> ignore
  g = @core.GraphWritable::add_node(g, "Eve") |> ignore

  // 3️⃣ 添加边（关注关系）
  // Alice -> Bob, Charlie
  g = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0) |> ignore
  g = @core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0) |> ignore

  // Bob -> Diana
  g = @core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0) |> ignore

  // Charlie -> Eve
  g = @core.GraphWritable::add_edge(g, @core.NodeId(2), @core.NodeId(4), 1.0) |> ignore

  // 4️⃣ 执行 BFS 遍历（从 Alice 出发）
  let result = @traversal.bfs(g, @core.NodeId(0))

  // 5️⃣ 输出结果
  println("=== 社交网络分析 ===")
  println("总用户数: \(g.node_count())")
  println("总关注关系: \(g.edge_count())")
  println("")
  println("从 Alice 出发的 BFS 层级:")
  for level in result.levels {
    println("  层级 \(level.depth): \(level.nodes)")
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

从 Alice 出发的 BFS 层级:
  层级 0: [Alice]
  层级 1: [Bob, Charlie]
  层级 2: [Diana, Eve]
```

## 代码解析

### 存储选择

我们选择了 `DirectedAdjList`（有向邻接表），这是最通用的存储结构：
- ✅ 支持有向图
- ✅ 动态添加节点和边
- ✅ 高效的邻居查询 O(k)，k 为邻居数
- ✅ 适合大多数场景

### 链式赋值模式

注意每次调用 `@core.GraphWritable::add_node/add_edge` 后都重新赋值给 `g`：

```moonbit
let mut g = @storage.DirectedAdjList::new()
g = @core.GraphWritable::add_node(g, "Alice")  // 返回新的图实例
```

这是 mbtgraph 的**纯函数语义**设计：
- 每次修改返回新的不可变实例
- 原始数据不会被修改
- 便于推理、调试和并行化

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
    <p>你已经成功创建了第一个 mbtgraph 程序！这只是冰山一角，mbtgraph 还提供了 49+ 个强大的图算法等待你去探索。</p>
  </div>
</div>
