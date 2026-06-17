# Hamiltonian API Reference

> **包名**: `morning-start/mbtgraph/lib/algo/hamiltonian`
> **路径**: `lib/algo/hamiltonian/`

## 概述

Hamiltonian 模块提供哈密顿路径/回路检测和旅行商问题 (TSP) 算法。

---

## 函数

### 哈密顿路径

#### find_hamiltonian_path_backtrack

```moonbit
pub fn[G : @core.GraphReadable] find_hamiltonian_path_backtrack(G) -> HamiltonianResult
```

回溯法查找哈密顿路径。

---

#### find_hamiltonian_circuit_backtrack

```moonbit
pub fn[G : @core.GraphReadable] find_hamiltonian_circuit_backtrack(G) -> HamiltonianResult
```

回溯法查找哈密顿回路。

---

#### has_hamiltonian_circuit_quick_check

```moonbit
pub fn[G : @core.GraphReadable] has_hamiltonian_circuit_quick_check(G) -> Bool
```

快速检查是否存在哈密顿回路（必要条件检查）。

---

### TSP (旅行商问题)

#### tsp_nearest_neighbor

```moonbit
pub fn tsp_nearest_neighbor(Array[Array[Double]]) -> TSPResult
```

最近邻启发式 TSP 算法。

**参数**:
- `Array[Array[Double]]`: 距离矩阵

**特点**:
- 贪心算法
- 时间复杂度 O(n²)
- 不保证最优解

---

#### tsp_exact_held_karp

```moonbit
pub fn tsp_exact_held_karp(Array[Array[Double]]) -> TSPResult
```

Held-Karp 精确 TSP 算法。

**参数**:
- `Array[Array[Double]]`: 距离矩阵

**特点**:
- 动态规划
- 时间复杂度 O(n²2ⁿ)
- 保证最优解
- 适用于 n ≤ 20

---

## 结果类型

### HamiltonianResult

```moonbit
pub(all) struct HamiltonianResult {
  exists : Bool
  path : Array[@core.NodeId]
  is_circuit : Bool
  start_node : @core.NodeId?
}
```

**字段**:
- `exists`: 是否存在哈密顿路径/回路
- `path`: 路径节点序列
- `is_circuit`: 是否为回路
- `start_node`: 起始节点

---

### TSPResult

```moonbit
pub(all) struct TSPResult {
  tour : Array[Int]
  total_cost : Double
  is_optimal : Bool
  algorithm : String
}
```

**字段**:
- `tour`: 访问顺序
- `total_cost`: 总代价
- `is_optimal`: 是否为最优解
- `algorithm`: 使用的算法名称

---

## 使用示例

```moonbit
// 哈密顿回路
let result = @hamiltonian.find_hamiltonian_circuit_backtrack(g)
if result.exists {
  println("Circuit: \{result.path}")
}

// TSP
let dist_matrix = [[0.0, 1.0, 2.0], [1.0, 0.0, 3.0], [2.0, 3.0, 0.0]]
let result = tsp_exact_held_karp(dist_matrix)
println("Tour: \{result.tour}, Cost: \{result.total_cost}")
```
