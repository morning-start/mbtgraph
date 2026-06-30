---
title: 高级遍历技巧
description: 双向 BFS、迭代加深 DFS、拓扑排序变体等进阶图遍历方法
---

# 高级遍历技巧

> **核心思想**: 在基础 BFS/DFS 之上，通过改进搜索策略解决特定问题 \
> **API**: `bidirectional_bfs` · `topological_sort` · `cycle_detection`

---

## 一、双向 BFS (Bidirectional BFS)

从起点和终点**同时**进行 BFS，当两个搜索相遇时即找到最短路径。

```
单向 BFS:     s ──→ ──→ ──→ ──→ t   扩展了 ~b^d 节点
双向 BFS:     s ──→ ──→ ⋯ ←── ←── t 扩展了 ~2b^(d/2) 节点
```

对于分支因子 b=10、深度 d=6 的图：
- 单向 BFS: 10⁶ = 1,000,000 节点
- 双向 BFS: 2 × 10³ = 2,000 节点 — **快 500 倍！**

```moonbit
// 双向 BFS 用于无向无权图的最短路径
let result = @traversal.bidirectional_bfs(graph, start, target)
match result {
  Some(path) => println("最短路径长度: \(path.length() - 1)")
  None => println("目标不可达")
}
```

### 适用场景

| 场景 | 效果 |
|------|:----:|
| 社交网络"度分隔" | ⭐ 6 度分隔理论的基础工具 |
| 迷宫寻路 | 已知起终点时显著加速 |
| 单词接龙 | 典型双向 BFS 例题 |

---

## 二、拓扑排序变体

```moonbit
// Kahn 算法（基于入度）
let topo_result = @traversal.topological_sort(dag)
println("拓扑序: \(topo_result)")

// 检测环（拓扑排序失败的图必然存在环）
if topo_result.length() < @core.GraphReadable::node_count(dag) {
  println("图中存在环，无法拓扑排序")
}
```

也可以用拓扑排序做**关键路径分析**（项目管理的核心算法）。

---

## 三、环检测

```moonbit
// 有向图环检测
let has_cycle = @traversal.cycle_detection(directed_graph)
println("有向图是否含环: \(has_cycle)")

// 无向图环检测（并查集方法更高效）
```

### 环的应用

| 场景 | 意义 |
|------|------|
| 死锁检测 | 资源分配图中的环 = 死锁 |
| 依赖验证 | 包管理工具确保无循环依赖 |
| 语法分析 | 有向无环图保证编译可终止 |

---

## 四、技巧速查

| 技巧 | 解决的问题 | 复杂度 | 与基础版差异 |
|------|-----------|:------:|-------------|
| 双向 BFS | 缩短搜索空间 | O(b^(d/2)) | 同时向中间搜 |
| 迭代加深 DFS | 深度未知的最优解 | O(b^d) | DFS + 深度限制 |
| 拓扑排序 (Kahn) | DAG 线性化 | O(V+E) | 基于入度 |
| 环检测 | 依赖冲突检查 | O(V+E) | 改自 DFS/Topo |

---

**相关文档：**
- [BFS 广度优先搜索](/algorithms/traversal/bfs/)
- [DFS 深度优先搜索](/algorithms/traversal/dfs/)
- [拓扑排序](/algorithms/traversal/bfs/)
