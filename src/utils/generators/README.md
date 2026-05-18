# 图生成器 (`generators`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 56 通过

提供经典图结构和随机图的快速构建能力，通过 `GraphWritable` trait 泛型支持所有可写存储类型。

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | 类型定义 + Trait 约束 |
| [`@storage`](../storage/) | 具体存储实现（测试用） |

## 文件结构

```
src/generators/
├── moon.pkg              # 包配置
├── classic.mbt           # 完全图 / 环图 / 路径图 / 星型图 (8 函数)
├── grid.mbt              # 网格图 (2 函数)
├── bipartite.mbt         # 二分图 (2 函数)
├── random.mbt            # Erdos-Renyi 随机图 (2 函数)
└── generators_test.mbt   # 56 个测试
```

## API 总览

### 经典图 ([classic.mbt](classic.mbt))

| 函数 | 有向/无向 | 说明 | 边数公式 |
|------|:--------:|------|---------|
| `complete_directed(g, n, w)` | 有向 | 完全图 K_n | n×(n-1) |
| `complete_undirected(g, n, w)` | 无向 | 完全图 K_n | n(n-1)/2 |
| `cycle_directed(g, n, w)` | 有向 | 环图 C_n | n |
| `cycle_undirected(g, n, w)` | 无向 | 环图 C_n | n |
| `path_directed(g, n, w)` | 有向 | 路径图 P_n | n-1 |
| `path_undirected(g, n, w)` | 无向 | 路径图 P_n | n-1 |
| `star_directed(g, n, w)` | 有向 | 星型图 S_n | n-1 |
| `star_undirected(g, n, w)` | 无向 | 星型图 S_n | n-1 |

### 网格图 ([grid.mbt](grid.mbt))

| 函数 | 说明 | 边数公式 |
|------|------|---------|
| `grid_directed(g, rows, cols, w)` | 有向网格 m×n | (m-1)×n + m×(n-1) |
| `grid_undirected(g, rows, cols, w)` | 无向网格 m×n | 同上 |

### 二分图 ([bipartite.mbt](bipartite.mbt))

| 函数 | 说明 | 边数公式 |
|------|------|---------|
| `bipartite_complete_directed(g, m, n, w)` | 有向完全二分图 K_{m,n} | m×n |
| `bipartite_complete_undirected(g, m, n, w)` | 无向完全二分图 K_{m,n} | m×n |

### 随机图 ([random.mbt](random.mbt))

| 函数 | 说明 |
|------|------|
| `random_erdos_renyi_directed(g, n, p, seed, w)` | 有向 G(n,p) 随机图 |
| `random_erdos_renyi_undirected(g, n, p, seed, w)` | 无向 G(n,p) 随机图 |

## 使用示例

```moonbit
import {
  "morning-start/mbtgraph/src/core" @core,
  "morning-start/mbtgraph/src/storage" @storage,
  "morning-start/mbtgraph/src/generators" @gen,
}

// 构建有向完全图 K5，边权重 1.0
let g = @storage.new_directed()
let g = @gen.complete_directed(g, 5, 1.0)

// 构建无向环图 C6
let ug = @storage.new_undirected()
let ug = @gen.cycle_undirected(ug, 6, 1.0)

// 构建 3×4 无向网格图
let grid = @storage.new_undirected()
let grid = @gen.grid_undirected(grid, 3, 4, 1.0)

// 构建可复现的随机图（相同 seed → 相同结果）
let rg = @storage.new_directed()
let rg = @gen.random_erdos_renyi_directed(rg, 10, 0.5, 42, 1.0)

// 直接用于算法（trait 抽象保证兼容）
let result = bfs(g, @core.NodeId(0))
```

## 设计要点

### 泛型约束

所有生成器签名均为 `[G : @core.GraphWritable]`，接受任意可写存储实例：

```moonbit
pub fn[G : @core.GraphWritable] complete_directed(
  g : G,
  n : Int,
  weight : Double,
) -> G
```

支持的存储类型：
- `DirectedAdjList` / `UndirectedAdjList`
- `DirectedMatrix` / `UndirectedMatrix`
- `EdgeListGraph` / `UndirectedEdgeListGraph`

### 参数说明

| 参数 | 类型 | 说明 |
|------|------|------|
| `g` | `G` (GraphWritable) | 空图实例，由调用者创建 |
| `n` / `rows` / `cols` / `m` | Int | 节点数量或维度 |
| `weight` | Double | 统一边权（默认 1.0） |
| `p` | Double | 随机图边存在概率 (0.0 ~ 1.0) |
| `seed` | Int | 随机种子（保证可复现性） |

### 节点编号规则

所有生成器使用**连续编号**：`NodeId(0)` 到 `NodeId(N-1)`。

特殊布局：
- **星型图**: Node(0) 为中心节点，Node(1..N-1) 为叶节点
- **二分图**: 左部 Node(0..M-1)，右部 Node(M..M+N-1)
- **网格图**: 按行优先排列，`(r,c)` → `NodeId(r * cols + c)`

### 边界处理

| 条件 | 行为 |
|------|------|
| `n <= 0` | 返回空图（不修改输入） |
| `p <= 0.0` | 返回空图（随机图专用） |
| `n == 1` | 单节点无边图（路径图/星型图）/ 自环（环图） |

### 随机数生成

内置 **LCG（线性同余生成器）**，参数来自 Numerical Recipes Minimal Standard：

- 乘数 `a = 1664525`
- 增量 `c = 1013904223`
- 模数 `m = 2^31 - 1`

**不依赖外部随机库**，保证跨平台一致性。相同 `(n, p, seed)` 三元组始终产生相同的图。

## 测试覆盖

| 类别 | 数量 | 内容 |
|------|:----:|------|
| 完全图 | 8 | K5/K1/K2/空图，有向+无向，自定义权重 |
| 环图 | 6 | C5/C4/C3/C1/空图，有向+无向 |
| 路径图 | 5 | P5/P1/P6/空图，有向+无向 |
| 星型图 | 7 | S5/S1/S6/中心度验证/空图，有向+无向 |
| 网格图 | 6 | 3×3/2×4/1×1/2×3/零维度，有向+无向 |
| 二分图 | 5 | 3×2/1×1/4×3/零参数，有向+无向 |
| 随机图 | 6 | 节点数/可复现性/p=0/n=0，有向+无向 |
| 权重验证 | 2 | 完全图+环图自定义权重检查 |
| **跨存储兼容** | **11** | AdjList/Matrix/EdgeList × 6 种生成器 |
| **合计** | **56** | |

## 与算法模块配合

```moonbit
// 用生成器快速构建测试图，直接喂给算法
let g = @storage.new_directed()
let g = @gen.complete_directed(g, 100, 1.0)

// BFS 遍历
let bfs_result = bfs(g, @core.NodeId(0))

// 环检测
let cyclic = has_cycle(g)

// 拓扑排序
match topo_sort_kahn(g) {
  Ok(order) => { /* ... */ }
  Err(msg) => { /* ... */ }
}
```
