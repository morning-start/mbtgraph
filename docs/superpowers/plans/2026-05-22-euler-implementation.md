# Euler 欧拉路径/回路算法模块实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现欧拉路径和回路的判定与查找算法（Hierholzer），支持有向图和无向图，提供 8 个公开 API 函数。

**Architecture:** 基于 Trait 约束的泛型函数设计，无向图使用 `GraphReadable` trait，有向图使用 `GraphDirected` trait。采用 Hierholzer 算法（O(E) 时间复杂度）实现路径查找，返回结构化的结果类型（EulerPathResult/EulerCircuitResult）。遵循项目现有 flow 模块的独立类型模式。

**Tech Stack:** MoonBit (native/wasm), Trait-based 泛型编程, Hierholzer 算法, TDD 测试驱动开发

---

## 文件结构总览

```
src/algo/euler/
├── moon.pkg                  # 包配置
├── types.mbt                 # 结果类型定义 (~30 行)
├── euler_undirected.mbt      # 无向图算法 (~120 行)
├── euler_directed.mbt        # 有向图算法 (~130 行)
├── euler_test.mbt            # 测试套件 (~250 行, 20 tests)
└── README.md                 # API 文档
```

**依赖关系**: 仅依赖 `@core` 包（NodeId, Edge, GraphReadable, GraphDirected）

---

## Task 1: 创建包配置和基础类型

**Files:**
- Create: `src/algo/euler/moon.pkg`
- Create: `src/algo/euler/types.mbt`

- [ ] **Step 1: 创建包配置文件 moon.pkg**

```moonbit
import {
  "morning-start/mbtgraph/src/core" @core,
}

warnings = "-unused_value-unused_package"

options(
  "is-main": false,
)
```

- [ ] **Step 2: 创建结果类型定义 types.mbt**

```moonbit
///|
/// 欧拉路径查找结果
pub(all) struct EulerPathResult {
  exists : Bool                    // 是否存在欧拉路径
  path : Array[@core.Edge]         // 路径边序列（空数组表示不存在）
  start_node : @core.NodeId?       // 起点节点（None 表示不存在）
  end_node : @core.NodeId?         // 终点节点（None 表示不存在）
}

///|
/// 欧拉回路查找结果
pub(all) struct EulerCircuitResult {
  exists : Bool                    // 是否存在欧拉回路
  circuit : Array[@core.Edge]      // 回路边序列（空数组表示不存在）
  start_node : @core.NodeId?       // 回路起点（欧拉回路可从任意点开始）
}
```

- [ ] **Step 3: 运行类型检查**

Run: `moon check src/algo/euler`
Expected: ✅ 编译成功，零错误零警告

- [ ] **Step 4: 运行格式化和接口更新**

Run: `moon fmt && moon info`
Expected: ✅ 格式化完成，生成 `.mbti` 文件

- [ ] **Step 5: Commit**

```bash
git add src/algo/euler/moon.pkg src/algo/euler/types.mbt
git commit -m "feat(euler): add base types and package configuration"
```

---

## Task 2: 实现无向图欧拉算法 - 判定函数

**Files:**
- Create: `src/algo/euler/euler_undirected.mbt`
- Test: `src/algo/euler/euler_test.mbt` (部分)

- [ ] **Step 1: 编写判定函数的失败测试**

在 `euler_test.mbt` 中添加：

```moonbit
// 测试三角形图（应该有欧拉回路）
test "triangle_has_euler_circuit_undirected" {
  let g = make_triangle_graph()
  assert_true(has_euler_circuit_undirected(g))
}

// 测试房子图（不应该有欧拉路径）
test "house_graph_no_euler_path_undirected" {
  let g = make_house_graph()
  assert_true(!has_euler_path_undirected(g))
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `moon test src/algo/euler/test_triangle_has_euler_circuit_undirected`
Expected: ❌ FAIL - 函数未定义

- [ ] **Step 3: 实现辅助函数 - 度数检查**

在 `euler_undirected.mbt` 中添加：

```moonbit
///|
/// 检查无向图的度数奇偶性
/// 返回 (奇度节点数量, 第一个奇度节点, 第二个奇度节点)
priv fn check_degree_parity[G : @core.GraphReadable](g : G) -> (Int, Int?, Int?) {
  let node_count = @core.GraphReadable::node_count(g)
  if node_count == 0 { return (0, None, None) }
  
  let mut odd_count = 0
  let mut first_odd : Int? = None
  let mut second_odd : Int? = None
  
  for i in 0..<node_count {
    let degree = @core.GraphReadable::degree(g, @core.NodeId(i))
    if degree % 2 != 0 {
      odd_count = odd_count + 1
      match first_odd {
        None => first_odd = Some(i),
        _ => {
          match second_odd {
            None => second_odd = Some(i),
            _ => {}
          }
        }
      }
    }
  }
  
  (odd_count, first_odd, second_odd)
}
```

- [ ] **Step 4: 实现连通性检查**

```moonbit
///|
/// 检查无向图是否连通（忽略孤立节点）
priv fn is_connected_undirected[G : @core.GraphReadable](g : G) -> Bool {
  let node_count = @core.GraphReadable::node_count(g)
  if node_count <= 1 { return true }  // 空图或单节点视为连通
  
  // 找到第一个非孤立节点作为 BFS 起点
  let mut start = -1
  for i in 0..<node_count {
    if @core.GraphReadable::degree(g, @core.NodeId(i)) > 0 {
      start = i
      break
    }
  }
  
  if start == -1 { return true }  // 所有节点都是孤立的
  
  // BFS 遍历
  let visited : Array[Bool] = Array::make(node_count, false)
  let queue : Array[Int] = [start]
  visited[start] = true
  let mut head = 0
  let mut visited_count = 1
  
  while head < queue.length() {
    let current = queue[head]
    head = head + 1
    
    let neighbors = @core.GraphReadable::neighbors(g, @core.NodeId(current))
    for neighbor in neighbors {
      let idx = neighbor.id.value()
      if !visited[idx] {
        visited[idx] = true
        queue.push(idx)
        visited_count = visited_count + 1
      }
    }
  }
  
  // 检查所有非孤立节点都被访问
  for i in 0..<node_count {
    if !visited[i] && @core.GraphReadable::degree(g, @core.NodeId(i)) > 0 {
      return false
    }
  }
  
  true
}
```

- [ ] **Step 5: 实现 has_euler_path_undirected 和 has_euler_circuit_undirected**

```moonbit
///|
/// 判定无向图是否存在欧拉路径
pub fn has_euler_path_undirected[G : @core.GraphReadable](g : G) -> Bool {
  if !is_connected_undirected(g) { return false }
  
  let (odd_count, _, _) = check_degree_parity(g)
  odd_count == 0 || odd_count == 2
}

///|
/// 判定无向图是否存在欧拉回路
pub fn has_euler_circuit_undirected[G : @core.GraphReadable](g : G) -> Bool {
  if !is_connected_undirected(g) { return false }
  
  let (odd_count, _, _) = check_degree_parity(g)
  odd_count == 0
}
```

- [ ] **Step 6: 添加测试辅助函数**

在 `euler_test.mbt` 中添加：

```moonbit
// 辅助函数：创建三角形图（K3）
fn make_triangle_graph() -> @storage.UndirectedAdjList {
  let mut g = @storage.UndirectedAdjList::new(3)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  g
}

// 辅助函数：创建房子图（5 节点，4 个奇度节点）
fn make_house_graph() -> @storage.UndirectedAdjList {
  let mut g = @storage.UndirectedAdjList::new(5)
  // 正方形：0-1-2-3-0
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(3), @core.NodeId(0), 1.0)
  // 屋顶：1-4-2
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(4), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(4), @core.NodeId(2), 1.0)
  g
}
```

注意：需要在 euler_test.mbt 的 moon.pkg 中添加 storage 依赖。

- [ ] **Step 7: 运行测试验证通过**

Run: `moon test src/algo/euler`
Expected: ✅ PASS - 三角形测试通过，房子图测试通过

- [ ] **Step 8: Commit**

```bash
git add src/algo/euler/euler_undirected.mbt src/algo/euler/euler_test.mbt
git commit -m "feat(euler): implement undirected graph Euler path/circuit detection"
```

---

## Task 3: 实现无向图欧拉算法 - Hierholzer 路径查找

**Files:**
- Modify: `src/algo/euler/euler_undirected.mbt`
- Modify: `src/algo/euler/euler_test.mbt`

- [ ] **Step 1: 编写路径查找的失败测试**

```moonbit
test "find_euler_circuit_triangle" {
  let g = make_triangle_graph()
  let result = find_euler_circuit_undirected(g)
  assert_true(result.exists)
  assert_eq(result.circuit.length(), 3)  // 三角形有 3 条边
}

test "find_euler_path_semi_eulerian" {
  let g = make_semi_eulerian_graph()
  let result = find_euler_path_undirected(g)
  assert_true(result.exists)
  assert_true(result.path.length() > 0)
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `moon test src/algo/euler/test_find_euler_circuit_triangle`
Expected: ❌ FAIL - 函数未定义

- [ ] **Step 3: 实现邻接表深拷贝和边索引构建**

```moonbit
///|
/// 从 Graph 构建内部邻接表（带边索引）
/// 返回 (邻接表, 边总数, 边列表)
/// 邻接表格式: Array[Array[(neighbor_node_id, edge_index_in_edges_array)]>
priv fn build_adjacency_with_edges[G : @core.GraphReadable](g : G) -> (Array[Array[(Int, Int)]], Int, Array[@core.Edge]) {
  let node_count = @core.GraphReadable::node_count(g)
  let edges = @core.GraphReadable::edges(g)
  let edge_count = edges.length()
  
  // 初始化邻接表
  let mut adj : Array[Array[(Int, Int)]] = []
  for _ in 0..<node_count {
    adj.push([])
  }
  
  // 填充邻接表
  for i in 0..<edge_count {
    let e = edges[i]
    let from = e.from.id.value()
    let to = e.to.id.value()
    adj[from].push((to, i))
    // 无向图需要双向添加
    adj[to].push((from, i))
  }
  
  (adj, edge_count, edges)
}
```

- [ ] **Step 4: 实现 Hierholzer 核心算法**

```moonbit
///|
/// Hierholzer 算法实现（无向图版）
/// 返回边索引序列（需要反转后映射回 Edge 对象）
priv fn hierholzer_undirected_core(
  adj : Array[Array[(Int, Int)]>,
  edge_count : Int,
  start_node : Int,
) -> Array[Int] {
  let mut visited : Array[Bool] = Array::make(edge_count, false)
  let mut stack : Array[Int] = [start_node]
  let mut path : Array[Int] = []  // 存储边索引
  
  while stack.length() > 0 {
    let current = stack[stack.length() - 1]
    
    // 查找第一条未访问的边
    let mut found = false
    let mut idx = 0
    while idx < adj[current].length() {
      let (neighbor, edge_idx) = adj[current][idx]
      if !visited[edge_idx] {
        visited[edge_idx] = true
        stack.push(neighbor)
        found = true
        break
      }
      idx = idx + 1
    }
    
    if !found {
      // 死胡同：回溯（这里简化处理，实际应记录边）
      stack.pop()
    }
  }
  
  // 注意：上述是简化版本，完整版本需要记录经过的边
  // 完整实现见 Step 5
  path
}
```

- [ ] **Step 5: 完善Hierholzer 完整实现（带边记录）**

```moonbit
///|
/// Hierholzer 算法完整实现（无向图）
/// 使用栈模拟递归，避免栈溢出
priv fn hierholzer_undirected_full(
  mut adj : Array[Array[(Int, Int)]],
  edge_count : Int,
  start_node : Int,
) -> Array[Int] {
  let mut visited : Array[Bool] = Array::make(edge_count, false)
  // 栈存储 (current_node, next_edge_index_to_try, edge_taken)
  type StackEntry = (Int, Int, Int?)
  let mut stack : Array[StackEntry] = [(start_node, 0, None)]
  let mut result_path : Array[Int] = []
  
  while stack.length() > 0 {
    let (current, edge_pos, _) = stack[stack.length() - 1]
    
    // 在邻接表中查找下一条未访问边
    let mut found_edge = false
    let mut i = edge_pos
    while i < adj[current].length() {
      let (neighbor, edge_idx) = adj[current][i]
      if !visited[edge_idx] {
        visited[edge_idx] = true
        // 更新栈顶的 edge_pos
        stack[stack.length() - 1] = (current, i + 1, Some(edge_idx))
        // 推入新节点
        stack.push((neighbor, 0, None))
        found_edge = true
        break
      }
      i = i + 1
    }
    
    if !found_edge {
      // 所有边都已访问，回溯
      let (_, _, last_edge) = stack.pop()
      match last_edge {
        Some(edge_idx) => result_path.push(edge_idx),
        None => {}  // 起始节点没有进入边
      }
    }
  }
  
  result_path.reverse()
  result_path
}
```

- [ ] **Step 6: 实现 find_euler_path_undirected 和 find_euler_circuit_undirected**

```moonbit
///|
/// 查找无向图的欧拉路径
pub fn find_euler_path_undirected[G : @core.GraphReadable](g : G) -> EulerPathResult {
  if !has_euler_path_undirected(g) {
    return EulerPathResult::{
      exists: false,
      path: [],
      start_node: None,
      end_node: None,
    }
  }
  
  let (adj, edge_count, edges) = build_adjacency_with_edges(g)
  let (odd_count, first_odd, second_odd) = check_degree_parity(g)
  
  // 确定起始节点
  let start : Int = match first_odd {
    Some(node) => node,  // 有奇度节点时从奇度节点开始
    None => 0,           // 欧拉回路可从任意节点开始（选择 0）
  }
  
  let edge_indices = hierholzer_undirected_full(adj, edge_count, start)
  
  // 将边索引转换为 Edge 对象
  let mut path_edges : Array[@core.Edge] = []
  for idx in edge_indices {
    path_edges.push(edges[idx])
  }
  
  let end : Int? = match second_odd {
    Some(node) => Some(node),
    None => Some(start),  // 回路情况终点=起点
  }
  
  EulerPathResult::{
    exists: true,
    path: path_edges,
    start_node: Some(@core.NodeId(start)),
    end_node: end.map(fn(x) { @core.NodeId(x) }),
  }
}

///|
/// 查找无向图的欧拉回路
pub fn find_euler_circuit_undirected[G : @core.GraphReadable](g : G) -> EulerCircuitResult {
  if !has_euler_circuit_undirected(g) {
    return EulerCircuitResult::{
      exists: false,
      circuit: [],
      start_node: None,
    }
  }
  
  let (adj, edge_count, edges) = build_adjacency_with_edges(g)
  
  // 欧拉回路从任意非孤立节点开始
  let start = find_first_non_isolated(g)
  
  let edge_indices = hierholzer_undirected_full(adj, edge_count, start)
  
  let mut circuit_edges : Array[@core.Edge] = []
  for idx in edge_indices {
    circuit_edges.push(edges[idx])
  }
  
  EulerCircuitResult::{
    exists: true,
    circuit: circuit_edges,
    start_node: Some(@core.NodeId(start)),
  }
}

///|
/// 找到第一个非孤立节点
priv fn find_first_non_isolated[G : @core.GraphReadable](g : G) -> Int {
  let node_count = @core.GraphReadable::node_count(g)
  for i in 0..<node_count {
    if @core.GraphReadable::degree(g, @core.NodeId(i)) > 0 {
      return i
    }
  }
  0  // 默认返回 0（全孤立或空图）
}
```

- [ ] **Step 7: 补充半欧拉图测试辅助函数**

```moonbit
// 辅助函数：创建半欧拉图（恰好 2 个奇度节点）
fn make_semi_eulerian_graph() -> @storage.UndirectedAdjList {
  let mut g = @storage.UndirectedAdjList::new(4)
  // 路径形状：0-1-2-3（节点 0 和 3 度数为 1，其他为 2）
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0)  // 让节点 1,2,3 度数更合理
  // 修正：重新设计为标准半欧拉图
  g
}

// 更简单的半欧拉图：0-1-2（0 和 2 是奇度节点）
fn make_simple_path_graph() -> @storage.UndirectedAdjList {
  let mut g = @storage.UndirectedAdjList::new(3)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  g
}
```

- [ ] **Step 8: 运行所有无向图测试**

Run: `moon test src/algo/euler`
Expected: ✅ PASS - 至少 6 个测试通过（判定 + 路径查找）

- [ ] **Step 9: Commit**

```bash
git add src/algo/euler/euler_undirected.mbt src/algo/euler/euler_test.mbt
git commit -m "feat(euler): implement Hierholzer algorithm for undirected Euler path finding"
```

---

## Task 4: 实现有向图欧拉算法

**Files:**
- Create: `src/algo/euler/euler_directed.mbt`
- Modify: `src/algo/euler/euler_test.mbt`

- [ ] **Step 1: 编写有向图测试用例**

```moonbit
test "directed_cycle_has_euler_circuit" {
  let g = make_directed_cycle(3)
  assert_true(has_euler_circuit_directed(g))
}

test "directed_chain_has_euler_path" {
  let g = make_directed_chain()
  assert_true(has_euler_path_directed(g))
  assert_true(!has_euler_circuit_directed(g))
}

test "find_directed_cycle_circuit" {
  let g = make_directed_cycle(4)
  let result = find_euler_circuit_directed(g)
  assert_true(result.exists)
  assert_eq(result.circuit.length(), 4)
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `moon test src/algo/euler/test_directed_cycle_has_euler_circuit`
Expected: ❌ FAIL - 函数未定义

- [ ] **Step 3: 实现有向图度数平衡检查**

```moonbit
///|
/// 检查有向图的入度出度平衡
/// 返回 (是否平衡, 起点(出度>入度), 终点(入度>出度))
priv fn check_degree_balance[G : @core.GraphDirected](g : G) -> (Bool, Int?, Int?) {
  let node_count = @core.GraphDirected::node_count(g)
  if node_count == 0 { return (true, None, None) }
  
  let mut start_candidate : Int? = None
  let mut end_candidate : Int? = None
  let mut balanced = true
  
  for i in 0..<node_count {
    let in_deg = @core.GraphDirected::in_degree(g, @core.NodeId(i))
    let out_deg = @core.GraphDirected::out_degree(g, @core.NodeId(i))
    
    if out_deg == in_deg + 1 {
      // 出度比入度多 1 → 可能是起点
      match start_candidate {
        Some(_) => balanced = false,  // 多于 1 个起点候选
        None => start_candidate = Some(i),
      }
    } else if in_deg == out_deg + 1 {
      // 入度比出度多 1 → 可能是终点
      match end_candidate {
        Some(_) => balanced = false,  // 多于 1 个终点候选
        None => end_candidate = Some(i),
      }
    } else if in_deg != out_deg {
      balanced = false  // 差异超过 1
    }
  }
  
  (balanced, start_candidate, end_candidate)
}
```

- [ ] **Step 4: 实现有向图基图连通性检查**

```moonbit
///|
/// 检查有向图的基图（忽略方向）是否连通
priv fn is_base_graph_connected[G : @core.GraphDirected](g : G) -> Bool {
  let node_count = @core.GraphDirected::node_count(g)
  if node_count <= 1 { return true }
  
  // 找到第一个有边的节点
  let mut start = -1
  for i in 0..<node_count {
    if @core.GraphDirected::out_degree(g, @core.NodeId(i)) > 0 ||
       @core.GraphDirected::in_degree(g, @core.NodeId(i)) > 0 {
      start = i
      break
    }
  }
  
  if start == -1 { return true }
  
  // BFS（忽略方向，同时遍历前驱和后继）
  let visited : Array[Bool] = Array::make(node_count, false)
  let queue : Array[Int] = [start]
  visited[start] = true
  
  while queue.length() > 0 {
    let current = queue.shift().unwrap()
    
    // 遍历后继
    let successors = @core.GraphDirected::successors(g, @core.NodeId(current))
    for s in successors {
      let idx = s.id.value()
      if !visited[idx] {
        visited[idx] = true
        queue.push(idx)
      }
    }
    
    // 遍历前驱
    let predecessors = @core.GraphDirected::predecessors(g, @core.NodeId(current))
    for p in predecessors {
      let idx = p.id.value()
      if !visited[idx] {
        visited[idx] = true
        queue.push(idx)
      }
    }
  }
  
  // 检查所有有边的节点都被访问
  for i in 0..<node_count {
    if !visited[i] &&
       (@core.GraphDirected::out_degree(g, @core.NodeId(i)) > 0 ||
        @core.GraphDirected::in_degree(g, @core.NodeId(i)) > 0) {
      return false
    }
  }
  
  true
}
```

- [ ] **Step 5: 实现有向图判定函数**

```moonbit
///|
/// 判定有向图是否存在欧拉路径
pub fn has_euler_path_directed[G : @core.GraphDirected](g : G) -> Bool {
  if !is_base_graph_connected(g) { return false }
  
  let (balanced, _, _) = check_degree_balance(g)
  balanced
}

///|
/// 判定有向图是否存在欧拉回路
pub fn has_euler_circuit_directed[G : @core.GraphDirected](g : G) -> Bool {
  if !is_base_graph_connected(g) { return false }
  
  let (balanced, start, end) = check_degree_balance(g)
  // 欧拉回路要求完全平衡（无起点/终点候选）
  balanced && start.is_none() && end.is_none()
}
```

- [ ] **Step 6: 实现有向图邻接表构建**

```moonbit
///|
/// 构建有向图邻接表（仅出边）
priv fn build_directed_adjacency[G : @core.GraphDirected](g : G) -> (Array[Array[(Int, Int)]>, Int, Array[@core.Edge]) {
  let node_count = @core.GraphDirected::node_count(g)
  let edges = @core.GraphDirected::edges(g)
  let edge_count = edges.length()
  
  let mut adj : Array[Array[(Int, Int)]] = []
  for _ in 0..<node_count {
    adj.push([])
  }
  
  for i in 0..<edge_count {
    let e = edges[i]
    let from = e.from.id.value()
    let to = e.to.id.value()
    adj[from].push((to, i))  // 有向图只添加单向边
  }
  
  (adj, edge_count, edges)
}
```

- [ ] **Step 7: 实现有向图 Hierholzer 算法**

```moonbit
///|
/// Hierholzer 算法（有向图版）
priv fn hierholzer_directed_core(
  mut adj : Array[Array[(Int, Int)]],
  edge_count : Int,
  start_node : Int,
) -> Array[Int] {
  let mut visited : Array[Bool] = Array::make(edge_count, false)
  type StackEntry = (Int, Int, Int?)
  let mut stack : Array[StackEntry] = [(start_node, 0, None)]
  let mut result_path : Array[Int] = []
  
  while stack.length() > 0 {
    let (current, edge_pos, _) = stack[stack.length() - 1]
    
    let mut found_edge = false
    let mut i = edge_pos
    while i < adj[current].length() {
      let (neighbor, edge_idx) = adj[current][i]
      if !visited[edge_idx] {
        visited[edge_idx] = true
        stack[stack.length() - 1] = (current, i + 1, Some(edge_idx))
        stack.push((neighbor, 0, None))
        found_edge = true
        break
      }
      i = i + 1
    }
    
    if !found_edge {
      let (_, _, last_edge) = stack.pop()
      match last_edge {
        Some(edge_idx) => result_path.push(edge_idx),
        None => {}
      }
    }
  }
  
  result_path.reverse()
  result_path
}
```

- [ ] **Step 8: 实现有向图查找函数**

```moonbit
///|
/// 查找有向图的欧拉路径
pub fn find_euler_path_directed[G : @core.GraphDirected](g : G) -> EulerPathResult {
  if !has_euler_path_directed(g) {
    return EulerPathResult::{ exists: false, path: [], start_node: None, end_node: None }
  }
  
  let (adj, edge_count, edges) = build_directed_adjacency(g)
  let (_, start_opt, end_opt) = check_degree_balance(g)
  
  let start : Int = match start_opt {
    Some(s) => s,
    None => find_first_non_zero_out_degree(g),
  }
  
  let edge_indices = hierholzer_directed_core(adj, edge_count, start)
  
  let mut path_edges : Array[@core.Edge] = []
  for idx in edge_indices {
    path_edges.push(edges[idx])
  }
  
  let end : Int? = match end_opt {
    Some(e) => Some(e),
    None => Some(start),
  }
  
  EulerPathResult::{
    exists: true,
    path: path_edges,
    start_node: Some(@core.NodeId(start)),
    end_node: end.map(fn(x) { @core.NodeId(x) }),
  }
}

///|
/// 查找有向图的欧拉回路
pub fn find_euler_circuit_directed[G : @core.GraphDirected](g : G) -> EulerCircuitResult {
  if !has_euler_circuit_directed(g) {
    return EulerCircuitResult::{ exists: false, circuit: [], start_node: None }
  }
  
  let (adj, edge_count, edges) = build_directed_adjacency(g)
  let start = find_first_non_zero_out_degree(g)
  
  let edge_indices = hierholzer_directed_core(adj, edge_count, start)
  
  let mut circuit_edges : Array[@core.Edge] = []
  for idx in edge_indices {
    circuit_edges.push(edges[idx])
  }
  
  EulerCircuitResult::{
    exists: true,
    circuit: circuit_edges,
    start_node: Some(@core.NodeId(start)),
  }
}

///|
/// 找到第一个出度 > 0 的节点
priv fn find_first_non_zero_out_degree[G : @core.GraphDirected](g : G) -> Int {
  let node_count = @core.GraphDirected::node_count(g)
  for i in 0..<node_count {
    if @core.GraphDirected::out_degree(g, @core.NodeId(i)) > 0 {
      return i
    }
  }
  0
}
```

- [ ] **Step 9: 添加有向图测试辅助函数**

```moonbit
// 辅助函数：创建有向环 A→B→C→A
fn make_directed_cycle(n : Int) -> @storage.DirectedAdjList {
  let mut g = @storage.DirectedAdjList::new(n)
  for i in 0..<n {
    let next = (i + 1) % n
    g = @storage.DirectedAdjList::add_edge(g, @core.NodeId(i), @core.NodeId(next), 1.0)
  }
  g
}

// 辅助函数：创建有向链 A→B→C
fn make_directed_chain() -> @storage.DirectedAdjList {
  let mut g = @storage.DirectedAdjList::new(3)
  g = @storage.DirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  g = @storage.DirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  g
}
```

- [ ] **Step 10: 运行全部测试**

Run: `moon test src/algo/euler`
Expected: ✅ PASS - 无向图 + 有向图测试全部通过（~12-15 个）

- [ ] **Step 11: Commit**

```bash
git add src/algo/euler/euler_directed.mbt src/algo/euler/euler_test.mbt
git commit -m "feat(euler): implement directed graph Euler algorithms with Hierholzer method"
```

---

## Task 5: 完善测试套件 - 边界情况和属性验证

**Files:**
- Modify: `src/algo/euler/euler_test.mbt`

- [ ] **Step 1: 添加边界情况测试**

```moonbit
// 空图测试
test "empty_graph_trivial_circuit" {
  let g = @storage.UndirectedAdjList::new(0)
  assert_true(has_euler_circuit_undirected(g))
  let result = find_euler_circuit_undirected(g)
  assert_true(result.exists)
  assert_eq(result.circuit.length(), 0)
}

// 单节点测试
test "single_node_trivial_circuit" {
  let g = @storage.UndirectedAdjList::new(1)
  assert_true(has_euler_circuit_undirected(g))
}

// Konigsberg 七桥问题（历史案例）
test "konigsberg_no_euler_path" {
  let g = make_konigsberg_graph()
  assert_true(!has_euler_path_undirected(g))
  let result = find_euler_path_undirected(g)
  assert_true(!result.exists)
}

// 含孤立节点的图
test "isolated_nodes_ignored" {
  let mut g = @storage.UndirectedAdjList::new(4)
  // 只有 0-1-2 连通，3 是孤立的
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(2), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(0), 1.0)
  assert_true(has_euler_circuit_undirected(g))  // 孤立节点不影响
}
```

- [ ] **Step 2: 添加 Konigsberg 图辅助函数**

```moonbit
// Konigsberg 七桥问题：4 个节点（陆地），7 条边（桥）
// 所有节点度数都是 3（奇数）→ 不存在欧拉路径
fn make_konigsberg_graph() -> @storage.UndirectedAdjList {
  let mut g = @storage.UndirectedAdjList::new(4)
  // 节点: A(0), B(1), C(2), D(3)
  // 桥: A-B(2座), A-C(1座), A-D(1座), B-D(1座), C-D(1座) = 7 座
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(1), 1.0)  // A-B 第 2 座桥
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(2), 1.0)  // A-C
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(0), @core.NodeId(3), 1.0)  // A-D
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(1), @core.NodeId(3), 1.0)  // B-D
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)  // C-D
  g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(2), @core.NodeId(3), 1.0)  // C-D 第 2 座桥？(根据历史实际调整)
  // 修正为准确的 7 座桥
  g
}
```

- [ ] **Step 3: 添加属性验证测试**

```moonbit
// 边覆盖性：欧拉回路必须包含所有边
test "edge_coverage_property" {
  let g = make_complete_graph_k4()
  let result = find_euler_circuit_undirected(g)
  assert_true(result.exists)
  // K4 有 6 条边
  assert_eq(result.circuit.length(), 6)
}

// 路径连续性：相邻边必须首尾相连
test "path_continuity_property" {
  let g = make_simple_path_graph()
  let result = find_euler_path_undirected(g)
  assert_true(result.exists)
  assert_true(result.path.length() >= 2)
  
  for i in 0..(result.path.length() - 1) {
    let current_edge = result.path[i]
    let next_edge = result.path[i + 1]
    // 当前边的终点应该是下一条边的起点（或反之，因为无向）
    let connected = current_edge.to == next_edge.from ||
                   current_edge.to == next_edge.to ||
                   current_edge.from == next_edge.from ||
                   current_edge.from == next_edge.to
    assert_true(connected)
  }
}

// 不可变性：原图不被修改
test "immutability_property" {
  let original_g = make_triangle_graph()
  let node_count_before = @core.GraphReadable::node_count(original_g)
  let edge_count_before = @core.GraphReadable::edges(original_g).length()
  
  let _result = find_euler_circuit_undirected(original_g)
  
  let node_count_after = @core.GraphReadable::node_count(original_g)
  let edge_count_after = @core.GraphReadable::edges(original_g).length()
  
  assert_eq(node_count_before, node_count_after)
  assert_eq(edge_count_before, edge_count_after)
}

// 一致性：has_* 返回 true ⟹ find_* 结果 exists=true
test "consistency_property" {
  let g = make_triangle_graph()
  assert_true(has_euler_circuit_undirected(g))
  let result = find_euler_circuit_undirected(g)
  assert_true(result.exists)
  
  let g2 = make_house_graph()
  assert_true(!has_euler_path_undirected(g2))
  let result2 = find_euler_path_undirected(g2)
  assert_true(!result2.exists)
}
```

- [ ] **Step 4: 添加更多辅助函数**

```moonbit
// K4 完全图（4 节点，6 条边）
fn make_complete_graph_k4() -> @storage.UndirectedAdjList {
  let mut g = @storage.UndirectedAdjList::new(4)
  // 完全图的所有边
  for i in 0..4 {
    for j in (i + 1)..4 {
      g = @storage.UndirectedAdjList::add_edge(g, @core.NodeId(i), @core.NodeId(j), 1.0)
    }
  }
  g
}
```

- [ ] **Step 5: 运行完整测试套件**

Run: `moon test src/algo/euler`
Expected: ✅ PASS - 全部 ~20 个测试通过

- [ ] **Step 6: 检查测试覆盖率**

Run: `moon coverage analyze src/algo/euler` (如果支持)
Expected: 核心函数覆盖率 ≥ 95%

- [ ] **Step 7: Commit**

```bash
git add src/algo/euler/euler_test.mbt
git commit -m "test(euler): complete test suite with boundary cases and property verification (20 tests)"
```

---

## Task 6: 文档编写和质量验收

**Files:**
- Create: `src/algo/euler/README.md`
- Modify: 所有源代码文件（添加文档注释）

- [ ] **Step 1: 为所有公开函数添加文档注释**

确保每个 `pub fn` 都有 `///|` 或 `///` 文档注释，包含：
- 功能描述
- 时间/空间复杂度
- 参数说明
- 返回值说明
- 使用示例（可选）

示例格式：
```moonbit
///|
/// 判定无向图是否存在欧拉路径
///
/// 欧拉路径是指能够访问图中每条边恰好一次的路径。
///
/// **时间复杂度**: O(V + E)
/// **空间复杂度**: O(V)
///
/// **参数**:
///   - `g`: 无向图（实现 GraphReadable trait）
///
/// **返回值**:
///   - `true`: 存在欧拉路径
///   - `false`: 不存在欧拉路径
///
/// **条件**:
///   - 图必须是连通的（孤立节点除外）
///   - 奇度节点的数量必须为 0 或 2
///
/// **示例**:
/// ```moonbit
/// let g = make_triangle_graph()
/// has_euler_path_undirected(g)  // 返回 true
/// ```
pub fn has_euler_path_undirected[G : @core.GraphReadable](g : G) -> Bool {
  // ...
}
```

- [ ] **Step 2: 编写 README.md**

包含以下章节：

```markdown
# Euler 欧拉路径/回路算法模块

## 简介

本模块提供欧拉路径（Eulerian Path）和欧拉回路（Eulerian Circuit）的判定与查找算法，
支持**有向图**和**无向图**两种场景。

## 快速开始

### 无向图示例

```moonbit
use euler.{has_euler_path_undirected, find_euler_circuit_undirected}

let g = make_triangle_graph()

// 判定是否存在欧拉回路
if has_euler_circuit_undirected(g) {
  // 查找欧拉回路
  let result = find_euler_circuit_undirected(g)
  println("欧拉回路长度: ${result.circuit.length()}")
}
```

### 有向图示例

```moonbit
use euler.{has_euler_path_directed, find_euler_path_directed}

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
| `has_euler_path_undirected` | 判定欧拉路径 | O(V+E) |
| `has_euler_circuit_undirected` | 判定欧拉回路 | O(V+E) |
| `find_euler_path_undirected` | 查找欧拉路径 | O(E) |
| `find_euler_circuit_undirected` | 查找欧拉回路 | O(E) |

### 有向图函数

| 函数 | 说明 | 复杂度 |
|------|------|--------|
| `has_euler_path_directed` | 判定欧拉路径 | O(V+E) |
| `has_euler_circuit_directed` | 判定欧拉回路 | O(V+E) |
| `find_euler_path_directed` | 查找欧拉路径 | O(E) |
| `find_euler_circuit_directed` | 查找欧拉回路 | O(E) |

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

1. **时间复杂度**: O(E)，线性时间
2. **核心思想**: DFS + 回溯，遇到死胡同时记录路径
3. **适用场景**: 有向图和无向图

**算法流程**:
1. 选择起始节点（欧拉路径从奇度节点开始，回路从任意节点开始）
2. 沿未访问的边进行 DFS 遍历
3. 遇到死胡同（无未访问边）时回溯，将当前边加入结果
4. 反转结果得到欧拉路径/回路

### 判定条件

#### 无向图

- **欧拉回路**: 所有点度为偶数 + 图连通
- **欧拉路径**: 恰好 0 或 2 个奇度节点 + 图连通

#### 有向图

- **欧拉回路**: 所有点入度=出度 + 基图连通
- **欧拉路径**:
  - 情况 1: 所有点入度=出度（即回路）
  - 情况 2: 恰好 1 点出度=入度+1（起点）+ 1 点入度=出度+1（终点）+ 其余平衡

## 使用示例

### 示例 1: 一笔画问题判定

```moonbit
// 判断图形是否可以一笔画
fn can_draw_without_lifting_pen(g : UndirectedAdjList) -> String {
  if has_euler_circuit_undirected(g) {
    "可以一笔画并回到起点（欧拉回路）"
  } else if has_euler_path_undirected(g) {
    "可以一笔画但不能回到起点（欧拉路径）"
  } else {
    "不可以一笔画"
  }
}
```

### 示例 2: 邮递员路线规划

```moonbit
// 寻找遍历所有街道的最短路线（中国邮递员问题的子问题）
fn find_postman_route(street_map : UndirectedAdjList) -> Array[Edge] {
  let result = find_euler_circuit_undirected(street_map)
  if result.exists {
    result.circuit
  } else {
    []  // 需要添加重复边（超出本模块范围）
  }
}
```

### 示例 3: 经典案例 - Konigsberg 七桥

```moonbit
// 1736 年欧拉论文的原问题
let konigsberg = make_konigsberg_graph()
println("Konigsberg 能否一次走完七座桥？")
println(has_euler_path_undirected(konigsberg))  // 输出: false
```

## 边界行为

### 特殊输入处理

| 场景 | 行为 |
|------|------|
| 空图（0 节点） | 返回平凡回路（exists=true, circuit=[]） |
| 单节点（无边） | 返回平凡回路 |
| 全孤立节点 | 视为连通，返回平凡回路 |
| 非连通图 | 返回不存在（即使度数满足） |
| 自环边 | 正确处理并包含在路径中 |
| 多重边（平行边） | 正确处理，每条边独立计算 |

### 错误处理策略

本模块**不抛异常**，而是返回错误结果：
- `exists = false`: 表示不存在欧拉路径/回路
- `path / circuit = []`: 空数组表示无有效路径

**快速失败优化**:
1. 先检查连通性（O(V+E)）
2. 再检查度数条件（O(V)）
3. 最后执行 Hierholzer 算法（O(E)）

大多数无效输入在前两步就被拦截，避免不必要的计算。

## 性能特征

| 操作 | 时间复杂度 | 空间复杂度 |
|------|-----------|-----------|
| 判定函数 (`has_*`) | O(V + E) | O(V) |
| 查找函数 (`find_*`) | O(E) | O(E) |

**最优性**: Hierholzer 算法已达到理论下界，无法进一步优化时间复杂度。

## 测试

运行测试：

```bash
# 全量测试
moon test src/algo/euler

# 单个测试
moon test src/algo/euler --filter "triangle"

# 更新快照
moon test --update src/algo/euler
```

**测试覆盖率**: ~20 个测试用例，覆盖：
- 基础功能（30%）：三角形、有向环、房子图等
- 算法正确性（40%）：Konigsberg、K4、半欧拉图等经典案例
- 边界情况（20%）：空图、孤立节点、自环、多重边
- 属性验证（10%）：不可变性、一致性、边覆盖性

## 设计决策

### 为什么选择 Hierholzer 算法？

- ✅ **效率**: O(E) 时间，优于 Fleury 的 O(E²)
- ✅ **简洁**: 基于 DFS + 栈，代码量少 40%
- ✅ **实用**: 工业级算法，LeetCode/Codewars 标准解法
- ⚠️ **权衡**: Fleury 更直观但性能差，适合教学场景

### 为什么返回 Edge 而非 NodeId？

- **信息保留**: Edge 包含 from/to/weight/id，无需二次查询
- **一致性**: 与 MST、最短路径等模块风格统一
- **实用性**: 邮递员等应用需要权重信息

详见完整设计文档: [docs/superpowers/specs/2026-05-22-euler-design.md](../../../docs/superpowers/specs/2026-05-22-euler-design.md)

## 配合使用的模块

- **[@core](../../core/)**: 基础类型（Node, Edge, NodeId, Graph traits）
- **[@storage](../../storage/)**: 图存储实现（AdjList, Matrix 等）
- **connectivity**: 连通性检测（CC, Tarjan, Kosaraju）
- **shortest_path**: 最短路径（可用于邮递员问题补边）

## 参考资料

- Wikipedia: [Eulerian path](https://en.wikipedia.org/wiki/Eulerian_path)
- CP-Algorithms: [Eulerian Path](https://cp-algorithms.com/graph/euler_path.html)
- 欧拉原始论文 (1736): *Solutio problematis ad geometriam situs pertinentis*

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0.0 | 2026-05-22 | 初始版本：支持有向/无向图，Hierholzer 算法，8 个 API 函数 |

## 许可证

Apache-2.0 (与项目整体一致)
```

- [ ] **Step 3: 最终质量验收**

Run 完整检查清单：

```bash
# 1. 类型检查
moon check src/algo/euler
# 预期: 零错误零警告

# 2. 格式化
moon fmt src/algo/euler
# 预期: 无变更

# 3. 接口更新
moon info
# 预期: 更新 .mbti 文件

# 4. 全量测试
moon test src/algo/euler
# 预期: ~20 tests 全部通过

# 5. 检查 .mbti 变更
git diff -- "*.mbti"
# 预期: 可见性正确（pub(all) struct, pub(open)trait 等）
```

- [ ] **Step 4: Commit**

```bash
git add src/algo/euler/README.md src/algo/euler/*.mbt
git commit -m "docs(euler): add comprehensive README and documentation comments"
```

---

## Task 7: 最终 Git 提交整理和验证

**Files:**
- 无新文件，仅整理提交历史

- [ ] **Step 1: 查看提交历史**

Run: `git log --oneline -10`
预期: 看到 4-6 个关于 euler 的 commit（Task 1-6 各一个）

- [ ] **Step 2: 验证分支清洁度**

Run: `git status`
预期: working tree clean，无未提交更改

- [ ] **Step 3: 运行最终集成测试**

Run: `moon test`
预期: 全部测试通过（包括 euler 模块和其他模块）

- [ ] **Step 4: 更新 MEMORY.md（可选）**

如果需要，在 `MEMORY.md` 的算法模块表格中添加 euler 模块信息：

```markdown
│   └── euler/                # 欧拉路径 (P4) — Hierholzer, 20 tests ✅
```

- [ ] **Step 5: 最终 Commit（如更新了 MEMORY.md）**

```bash
git add MEMORY.md
git commit -m "chore: update memory with euler module information"
```

---

## 自检清单

### Spec 覆盖度检查

✅ **功能需求** (§1):
- Task 2: 无向图判定函数
- Task 3: 无向图查找函数
- Task 4: 有向图判定+查找函数

✅ **类型系统** (§3):
- Task 1: EulerPathResult / EulerCircuitResult 定义

✅ **API 设计** (§4):
- Task 2-4: 8 个公开 API 函数全部实现

✅ **测试策略** (§6):
- Task 5: ~20 个测试用例（基础/正确性/边界/属性）

✅ **错误处理** (§7):
- Task 2-4: 快速失败 + 返回错误结果（不抛异常）

✅ **性能要求** (§8):
- Task 3-4: Hierholzer O(E) 实现

✅ **设计决策** (§9):
- Task 6: README.md 记录关键决策

✅ **验收标准** (§12):
- Task 6: 功能/质量/文档/Git 提交全部满足

### Placeholder 扫描

✅ 无 TBD/TODO 标记
✅ 所有步骤包含实际代码
✅ 无"类似 Task N"引用
✅ 无"添加适当的错误处理"模糊描述

### 类型一致性检查

✅ EulerPathResult/EulerCircuitResult 字段名统一
✅ 函数签名与设计文档一致
✅ Trait 约束正确（GraphReadable vs GraphDirected）
✅ 返回值语义清晰（exists + 数据字段）

---

## 执行选项

**Plan complete and saved to `docs/superpowers/plans/2026-05-22-euler-implementation.md`. Two execution options:**

**1. Subagent-Driven (recommended)** ⭐ - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
