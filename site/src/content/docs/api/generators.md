---
title: 图生成器 API
description: 随机图生成器模块的完整 API 参考
---

> **模块路径**: `lib/utils/generators/` | **16 种图生成器**

## 完全图

```moonbit
pub fn[G : @core.GraphWritable] complete_directed(G, Int, Double) -> G
pub fn[G : @core.GraphWritable] complete_undirected(G, Int, Double) -> G
```

## 随机图

```moonbit
pub fn[G : @core.GraphWritable] erdos_renyi(G, Int, Double, Double?) -> G
pub fn[G : @core.GraphWritable] barabasi_albert(G, Int, Int, Double?) -> G
pub fn[G : @core.GraphWritable] watts_strogatz(G, Int, Int, Double, Double?) -> G
```

| 生成器 | 模型 | 参数 | 特点 |
|--------|------|------|------|
| `erdos_renyi` | G(n,p) | n=节点数, p=边概率 | 经典随机图 |
| `barabasi_albert` | BA 模型 | n=节点数, m=每步边数 | 无标度（幂律）|
| `watts_strogatz` | WS 模型 | n,k,p | 小世界（高聚类）|

## 规则图

```moonbit
pub fn[G : @core.GraphWritable] grid_2d(G, Int, Int, Double?) -> G
pub fn[G : @core.GraphWritable] grid_3d(G, Int, Int, Int, Double?) -> G
pub fn[G : @core.GraphWritable] complete_bipartite(G, Int, Int, Double?) -> G
pub fn[G : @core.GraphWritable] cycle(G, Int, Double?) -> G
pub fn[G : @core.GraphWritable] path(G, Int, Double?) -> G
pub fn[G : @core.GraphWritable] star(G, Int, Double?) -> G
pub fn[G : @core.GraphWritable] wheel(G, Int, Double?) -> G
pub fn[G : @core.GraphWritable] hypercube(G, Int, Double?) -> G
```

| 生成器 | 说明 | 参数 |
|--------|------|------|
| `grid_2d` | 二维网格图 | rows, cols |
| `grid_3d` | 三维网格图 | x, y, z |
| `complete_bipartite` | 完全二分图 | left, right |
| `cycle` | 环图 | n 个节点 |
| `path` | 路径图 | n 个节点 |
| `star` | 星形图 | n 个节点 |
| `wheel` | 轮图 | n 个节点 |
| `hypercube` | 超立方体 | k 维 |

## 树

```moonbit
pub fn[G : @core.GraphWritable] random_tree(G, Int, Double?) -> G
```

## 使用示例

```moonbit
// 创建 Erdős-Rényi 随机图（50 节点，边概率 0.1）
let g = @storage.new_directed()
let g = generators.erdos_renyi(g, 50, 0.1, None)

// 创建 BA 无标度图（100 节点，每步加 3 条边）
let g = @storage.new_directed()
let g = generators.barabasi_albert(g, 100, 3, None)

// 创建 5x5 网格图
let g = @storage.new_undirected()
let g = generators.grid_2d(g, 5, 5, None)
```
