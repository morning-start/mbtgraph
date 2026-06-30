---
title: Ford-Fulkerson 方法
description: 最大流问题的通用框架，通过增广路径迭代逼近最大流
---

# Ford-Fulkerson 方法

> **核心思想**: 只要存在增广路径就推送流量，直到饱和 \
> **API**: `edmonds_karp(graph, source, sink)` · `dinic(graph, source, sink)` \
> **前置**: [流网络基础](/algorithms/flow/basics/)

---

## 一、算法框架

<div class="viz-preview-card">
  <iframe src="/visualizations/ford_fulkerson/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/ford_fulkerson/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

Ford-Fulkerson 不是一个具体的算法，而是一个**方法框架**：

```
初始化：所有边流量 f(e) = 0
while (存在从 s 到 t 的增广路径 P):
    计算 P 的最小残差容量 bottleneck
    沿 P 推送 bottleneck 流量
    更新残差网络
```

不同的**增广路径搜索策略**衍生出不同算法：

| 具体算法 | 搜索策略 | 时间复杂度 |
|---------|---------|:----------:|
| **Edmonds-Karp** | BFS（最短增广路） | O(VE²) |
| **Dinic** | BFS 分层 + DFS 阻塞流 | O(E√V) ~ O(V²E) |
| **容量缩放** | 优先大容量路径 | O(E² log C) |

---

## 二、核心原理：残差网络与反悔机制

Ford-Fulkerson 的精髓在于**允许"反悔"**——通过反向边撤销之前分配的流量：

```
边 (u→v) 容量 5，已流 3
  → 向前残差: 5-3 = 2（还能流 2）
  → 向后残差: 3（可以退 3）
```

这个机制让算法能自我修正：如果之前给 A 路径分配了流量，但发现经过 B 路径更优，可以通过反向边回收。

---

## 三、代码示例

```moonbit
fn main {
  // 经典示例：4 节点流网络
  // s(0) → A(1) → t(3)
  //   ↘   ↗       ↙
  //     B(2)
  let mut net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0)   // s→A: 10
  let net = net.add_edge(0, 2, 5.0)    // s→B: 5
  let net = net.add_edge(1, 2, 6.0)    // A→B: 6
  let net = net.add_edge(1, 3, 8.0)    // A→t: 8
  let net = net.add_edge(2, 3, 9.0)    // B→t: 9

  let result = @flow.edmonds_karp(net, 0, 3)
  println("最大流量: \(result.max_flow)")
  // 查看每条边的流量
  for e in result.flow_edges {
    let (from, to, f) = e
    println("  边 \(from)→\(to): 流量=\(f)")
  }
}
```

**输出：**
```
最大流量: 14.0
  边 0→1: 流量=8.0
  边 0→2: 流量=5.0
  边 1→2: 流量=1.0
  边 1→3: 流量=8.0
  边 2→3: 流量=5.0
```

**分析：** 最大流 14 的分布：
- 路径 s→A→t 贡献 8
- 路径 s→B→t 贡献 5
- 路径 s→A→B→t 贡献 1（A 的剩余 1 通过 B 绕行到 t）

---

## 四、复杂度分析

| 场景 | 复杂度 | 说明 |
|------|:------:|------|
| 整数容量 | O(E·f_max) | f_max 是最大流量值 |
| 实数容量 | 可能无限循环 | 需用 BFS（Edmonds-Karp）保证终止 |
| Edmonds-Karp | O(VE²) | BFS 保证多项式复杂度 |
| Dinic | O(E√V) | 单位容量图最快 |

---

**相关文档：**
- [Edmonds-Karp 算法](/algorithms/flow/max-flow/edmonds-karp)
- [Dinic 算法](/algorithms/flow/max-flow/dinic)
- [最小费用最大流](/algorithms/flow/min-cost-max-flow/index/)
