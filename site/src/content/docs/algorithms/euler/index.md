---
title: 欧拉路径与回路算法
description: 从哥尼斯堡七桥到 Hierholzer 算法：判定与查找的完整指南，含动画演示、MoonBit 实现
---

# 欧拉路径与回路算法

> 🎯 **本节目标**: 掌握欧拉路径/回路的判定条件与 Hierholzer 查找算法 | ⏱️ **预计阅读时间**: 10 分钟

## 算法简介

**欧拉路径与回路**起源于 1736 年欧拉对**哥尼斯堡七桥问题**的研究——这也是图论诞生的标志。**欧拉回路**是从起点出发，经过每条边**恰好一次**并返回起点的路径；**欧拉路径**则不必返回起点。

判定条件极简：
- **无向图存在欧拉回路**：所有节点度数为偶数
- **无向图存在欧拉路径**：恰好 0 或 2 个奇数度节点
- **有向图存在欧拉回路**：所有节点入度 = 出度
- **有向图存在欧拉路径**：起点出度 = 入度 + 1，终点入度 = 出度 + 1，其余入度 = 出度

mbtgraph 使用 **Hierholzer 算法**（1873 年）构造路径：从起点开始深度优先遍历，边走边删除边，当无路可走时回溯加入结果，最终得到一个欧拉回路/路径。

## 动画演示

<div class="viz-preview-card">
  <iframe src="/mbtgraph/visualizations/euler/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/mbtgraph/visualizations/euler/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

| 颜色/状态 | 含义 |
|-----------|------|
| 橙色 | 当前遍历的边 |
| 绿色 | 已加入欧拉路径（已确认） |
| 红色 | 回溯阶段恢复的边 |
| 灰色 | 未遍历 |

## MoonBit 实现

核心代码来自 `lib/algo/euler/hierholzer.mbt`：

```moonbit
///|
/// Hierholzer 算法：查找欧拉回路/路径
/// 时间复杂度 O(V+E)，空间复杂度 O(V+E)
pub fn[G : @core.GraphReadable] find_eulerian_path(
  graph : G,
) -> EulerianResult {
  let nc = @core.GraphReadable::node_count(graph)
  if nc == 0 { return EulerianResult::{ path: [], has_eulerian_path: false } }

  // 1. 度分析：统计奇数度节点
  let max_id = find_max_node_id(graph)
  let size = max(max_id + 1, 1)
  let degree = Array::make(size, 0)
  let mut odd_count = 0
  let mut odd_node : @core.NodeId = @core.NodeId(0)

  for u in @core.GraphReadable::node_ids(graph) {
    let d = 0
    for _ in @core.GraphReadable::neighbors(graph, u) { d = d + 1 }
    degree[u.0] = d
    if d % 2 == 1 {
      odd_count = odd_count + 1
      odd_node = u
    }
  }

  // 2. 判定
  let start = if odd_count == 0 {  // 欧拉回路，任何节点均可
    对于 @core.GraphReadable::node_ids(graph).next().unwrap_or(@core.NodeId(0))
  } else if odd_count == 2 {  // 欧拉路径，从奇数度节点开始
    odd_node
  } else {  // 无欧拉路径
    return EulerianResult::{ path: [], has_eulerian_path: false }
  }

  // 3. Hierholzer 构造
  // 实际实现使用边列表和 visited 标记来模拟"边走边删"
  // ...
  // 此处为简化示意，完整实现见 lib/algo/euler/hierholzer.mbt

  EulerianResult::{ path: result_path, has_eulerian_path: true }
}
```

> 完整实现约 80 行，使用邻接表的副本和边访问标记模拟"边走边删边"的行为。核心逻辑是：从起点开始 DFS，每当无未访问的邻边时弹栈记录节点，最终得到逆序的欧拉路径。

## 使用示例

```moonbit
fn euler_demo() -> Unit {
  let mut g = @storage.UndirectedAdjList::new()
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 3]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[0], 1.0)

  let result = @euler.find_eulerian_path(g)
  if result.has_eulerian_path {
    println("欧拉回路: ${result.path}")
  }
}
```

## 实际场景

- **邮递员路线规划**：中国邮递员问题——在必须走每条街至少一次的前提下最小化总路程
- **DNA 测序组装**：使用欧拉路径从 DNA 片段中重建完整序列
- **电路板布线**：单层 PCB 的连续走线工艺设计

## 扩展阅读

- [哈密顿路径与 TSP](/algorithms/other/) — 另一种"边遍历"问题（NP-Hard）
- [Hierholzer 定理](https://en.wikipedia.org/wiki/Eulerian_path) — 欧拉路径的维基百科条目
