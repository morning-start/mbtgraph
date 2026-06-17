# mbtgraph 示例

> mbtgraph 算法库的使用示例，帮助你快速上手。

---

## 示例列表

| 示例 | 文件 | 说明 |
|------|------|------|
| 最短路径 | [shortest_path.mbt](shortest_path.mbt) | Dijkstra、A*、Floyd-Warshall、Bellman-Ford |
| 最小生成树 | [mst.mbt](mst.mbt) | Kruskal、Prim |
| 图遍历 | [traversal.mbt](traversal.mbt) | BFS、DFS、环检测、拓扑排序 |
| 连通性 | [connectivity.mbt](connectivity.mbt) | 连通分量、强连通分量 |
| 网络流 | [flow.mbt](flow.mbt) | 最大流、最小费用流、最小割 |

---

## 快速开始

### 运行单个示例

```bash
# 运行最短路径示例
moon run examples/shortest_path.mbt

# 运行 MST 示例
moon run examples/mst.mbt

# 运行遍历示例
moon run examples/traversal.mbt
```

### 运行所有示例

```bash
moon run examples/
```

---

## 示例说明

### 最短路径示例

演示各种最短路径算法的使用：

- **Dijkstra**: 非负权图单源最短路径
- **Dijkstra Targeted**: 两节点间最短路径
- **A***: 启发式搜索
- **Floyd-Warshall**: 全源最短路径
- **Bellman-Ford**: 支持负权边的最短路径

### 最小生成树示例

演示 MST 算法的使用：

- **Kruskal**: 基于边排序的 MST
- **Prim**: 基于顶点扩展的 MST
- **MST 成员检查**: 验证边是否在 MST 中

### 图遍历示例

演示遍历算法的使用：

- **BFS**: 广度优先搜索，层级遍历
- **DFS**: 深度优先搜索，时间戳
- **BFS 最短路径**: 无权图最短路径
- **环检测**: 检测图中是否存在环
- **拓扑排序**: 有向无环图的线性排序

### 连通性示例

演示连通性算法的使用：

- **连通分量**: 无向图连通分量检测
- **Tarjan SCC**: 强连通分量检测
- **Kosaraju SCC**: 另一种 SCC 算法

### 网络流示例

演示网络流算法的使用：

- **最大流**: Edmonds-Karp、Dinic、Push-Relabel
- **最小费用最大流**: 在最大流基础上最小化费用
- **全局最小割**: Stoer-Wagner 算法
- **算法比较**: 不同最大流算法的性能对比

---

## 代码结构

每个示例文件包含：

1. **图创建函数**: 构建示例图
2. **算法演示函数**: 展示算法使用
3. **主函数**: 调用所有演示函数

---

## 学习路径

1. **入门**: 从 `traversal.mbt` 开始，理解基本遍历
2. **进阶**: 学习 `shortest_path.mbt` 和 `mst.mbt`
3. **高级**: 探索 `connectivity.mbt` 和 `flow.mbt`

---

## 相关资源

- [Getting Started](../docs/guides/getting_started.md) — 快速入门指南
- [Algorithm Guide](../docs/guides/algorithm_guide.md) — 算法选择指南
- [API Reference](../docs/api/README.md) — 完整 API 文档
