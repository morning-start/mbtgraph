# Euler 欧拉路径/回路算法模块

## 简介

本模块提供欧拉路径（Eulerian Path）和欧拉回路（Eulerian Circuit）的判定与查找算法，
支持**有向图**和**无向图**两种场景。

## 快速开始

### 无向图示例

```moonbit
// 创建三角形图
let g = make_triangle_graph()

// 判定是否存在欧拉回路
if has_euler_circuit_undirected(g) {
  // 查找欧拉回路
  let result = find_euler_circuit_undirected(g)
  // result.circuit 包含所有边，每条边恰好访问一次
}
```

### 有向图示例

```moonbit
// 创建有向环
let g = make_directed_cycle(4)

if has_euler_circuit_directed(g) {
  let result = find_euler_circuit_directed(g)
  // 处理回路...
}
```

## API 参考

### 无向图函数

| 函数 | 说明 | 复杂度 |
|------|------|--------|
| `has_euler_path_undirected` | 判定无向图是否存在欧拉路径 | O(V+E) |
| `has_euler_circuit_undirected` | 判定无向图是否存在欧拉回路 | O(V+E) |
| `find_euler_path_undirected` | 查找无向图的欧拉路径 | O(E) |
| `find_euler_circuit_undirected` | 查找无向图的欧拉回路 | O(E) |

### 有向图函数

| 函数 | 说明 | 复杂度 |
|------|------|--------|
| `has_euler_path_directed` | 判定有向图是否存在欧拉路径 | O(V+E) |
| `has_euler_circuit_directed` | 判定有向图是否存在欧拉回路 | O(V+E) |
| `find_euler_path_directed` | 查找有向图的欧拉路径 | O(E) |
| `find_euler_circuit_directed` | 查找有向图的欧拉回路 | O(E) |

### 结果类型

#### EulerPathResult

```moonbit
pub(all) struct EulerPathResult {
  exists : Bool                    // 是否存在
  path : Array[Edge]               // 路径边序列
  start_node : NodeId?             // 起点
  end_node : NodeId?               // 终点
}
```

#### EulerCircuitResult

```moonbit
pub(all) struct EulerCircuitResult {
  exists : Bool                    // 是否存在
  circuit : Array[Edge]            // 回路边序列
  start_node : NodeId?             // 起点
}
```

## 算法原理

### Hierholzer 算法

本模块使用 **Hierholzer 算法** 实现欧拉路径/回路的查找：

- **时间复杂度**: O(E)，线性时间
- **核心思想**: DFS + 回溯，遇到死胡同时记录路径
- **适用场景**: 有向图和无向图

### 判定条件

#### 无向图

- **欧拉回路**: 所有点度为偶数 + 图连通
- **欧拉路径**: 恰好 0 或 2 个奇度节点 + 图连通

#### 有向图

- **欧拉回路**: 所有点入度=出度 + 基图连通
- **欧拉路径**:
  - 情况 1: 所有点入度=出度（即回路）
  - 情况 2: 恰好 1 点出度=入度+1（起点）+ 1 点入度=出度+1（终点）+ 其余平衡

## 边界行为

| 场景 | 行为 |
|------|------|
| 空图（0 节点） | 返回平凡回路（exists=true, circuit=[]） |
| 单节点（无边） | 返回平凡回路 |
| 全孤立节点 | 视为连通，返回平凡回路 |
| 非连通图 | 返回不存在（即使度数满足） |

## 性能特征

| 操作 | 时间复杂度 | 空间复杂度 |
|------|-----------|-----------|
| 判定函数 (`has_*`) | O(V + E) | O(V) |
| 查找函数 (`find_*`) | O(E) | O(E) |

## 测试

运行测试：

```bash
moon test src/algo/euler
```

**测试覆盖率**: 22 个测试用例，覆盖基础功能、算法正确性、边界情况和属性验证。

## 设计决策

### 为什么选择 Hierholzer 算法？

- ✅ 效率: O(E) 时间，优于 Fleury 的 O(E²)
- ✅ 简洁: 基于 DFS + 栈，代码量少
- ✅ 实用: 工业级标准算法

### 为什么返回 Edge 而非 NodeId？

- 信息保留: Edge 包含 from/to/weight/id
- 一致性: 与 MST、最短路径等模块风格统一

详见设计文档: [docs/superpowers/specs/2026-05-22-euler-design.md](../../../docs/superpowers/specs/2026-05-22-euler-design.md)

## 配合使用的模块

- **[@core](../../core/)**: 基础类型（Node, Edge, NodeId, Graph traits）
- **[@storage](../../storage/)**: 图存储实现（AdjList, Matrix 等）
- **connectivity**: 连通性检测（CC, Tarjan, Kosaraju）

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0.0 | 2026-05-22 | 初始版本：支持有向/无向图，Hierholzer 算法，8 个 API 函数 |

## 许可证

MIT (与项目整体一致)
