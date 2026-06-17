# Generators API Reference

> **包名**: `morning-start/mbtgraph/lib/utils/generators`
> **路径**: `lib/utils/generators/`

## 概述

Generators 模块提供各种图结构的生成函数，用于测试和演示。

---

## 函数

### 完全图

#### complete_directed

```moonbit
pub fn[G : @core.GraphWritable] complete_directed(G, Int, Double) -> G
```

生成有向完全图。

**参数**:
- `G`: 图实例
- `Int`: 节点数量
- `Double`: 边权重

---

#### complete_undirected

```moonbit
pub fn[G : @core.GraphWritable] complete_undirected(G, Int, Double) -> G
```

生成无向完全图。

---

### 星图

#### star_directed

```moonbit
pub fn[G : @core.GraphWritable] star_directed(G, Int, Double) -> G
```

生成有向星图。

**参数**:
- `G`: 图实例
- `Int`: 节点数量（中心 + 叶子）
- `Double`: 边权重

---

#### star_undirected

```moonbit
pub fn[G : @core.GraphWritable] star_undirected(G, Int, Double) -> G
```

生成无向星图。

---

### 路径图

#### path_directed

```moonbit
pub fn[G : @core.GraphWritable] path_directed(G, Int, Double) -> G
```

生成有向路径图。

---

#### path_undirected

```moonbit
pub fn[G : @core.GraphWritable] path_undirected(G, Int, Double) -> G
```

生成无向路径图。

---

### 环图

#### cycle_directed

```moonbit
pub fn[G : @core.GraphWritable] cycle_directed(G, Int, Double) -> G
```

生成有向环图。

---

#### cycle_undirected

```moonbit
pub fn[G : @core.GraphWritable] cycle_undirected(G, Int, Double) -> G
```

生成无向环图。

---

### 网格图

#### grid_directed

```moonbit
pub fn[G : @core.GraphWritable] grid_directed(G, Int, Int, Double) -> G
```

生成有向网格图。

**参数**:
- `G`: 图实例
- `Int`: 行数
- `Int`: 列数
- `Double`: 边权重

---

#### grid_undirected

```moonbit
pub fn[G : @core.GraphWritable] grid_undirected(G, Int, Int, Double) -> G
```

生成无向网格图。

---

### 二部完全图

#### bipartite_complete_directed

```moonbit
pub fn[G : @core.GraphWritable] bipartite_complete_directed(G, Int, Int, Double) -> G
```

生成有向二部完全图。

**参数**:
- `G`: 图实例
- `Int`: 第一部节点数
- `Int`: 第二部节点数
- `Double`: 边权重

---

#### bipartite_complete_undirected

```moonbit
pub fn[G : @core.GraphWritable] bipartite_complete_undirected(G, Int, Int, Double) -> G
```

生成无向二部完全图。

---

### 随机图

#### random_erdos_renyi_directed

```moonbit
pub fn[G : @core.GraphWritable] random_erdos_renyi_directed(G, Int, Double, Int, Double) -> G
```

生成有向 Erdős-Rényi 随机图。

**参数**:
- `G`: 图实例
- `Int`: 节点数量
- `Double`: 边存在概率
- `Int`: 随机种子
- `Double`: 边权重

---

#### random_erdos_renyi_undirected

```moonbit
pub fn[G : @core.GraphWritable] random_erdos_renyi_undirected(G, Int, Double, Int, Double) -> G
```

生成无向 Erdős-Rényi 随机图。

---

## 使用示例

```moonbit
// 创建一个 5 节点的有向完全图
let g = @storage.new_directed()
let g = @generators.complete_directed(g, 5, 1.0)

// 创建一个 3x3 的无向网格
let grid = @storage.new_undirected()
let grid = @generators.grid_undirected(grid, 3, 3, 1.0)
```
