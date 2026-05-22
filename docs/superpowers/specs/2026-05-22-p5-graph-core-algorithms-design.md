# P5 图论核心算法扩展设计规范

**日期**: 2026-05-22
**状态**: ✅ 已批准，待实现
**范围**: 4 个子模块（A/B/C/D）
**优先级**: P5（图论核心算法扩展）

---

## 1. 总体概述

### 1.1 模块目标

实现图论的 **4 大核心算法家族**：
- **A. 割点 & 桥**: 网络可靠性分析、关键基础设施识别
- **B. 图着色**: 调度问题、寄存器分配、地图填色
- **C. 团/独立集/顶点覆盖**: 社交网络分析、组合优化
- **D. 哈密顿路径/TSP**: 路径规划、物流优化

### 1.2 实现顺序（依赖关系）

```
A. 割点/桥 (cutpoints/) ── 最基础，Tarjan DFS 变种
    ↓
B. 图着色 (coloring/)   ── 独立模块
    ↓
C. 团/独立集 (clique/)  ── 可利用着色结果作为上界
    ↓
D. 哈密顿路径 (hamiltonian/) ── NP-hard，精确+近似
```

### 1.3 与现有模块的关系

```
现有模块:
├── connectivity/ (CC/Tarjan/Kosaraju) ← A 的理论基础
├── euler/ (Hierholzer)                  ← D 的"兄弟"问题
└── mst/ (Kruskal/Prim)                 ← C 的顶点覆盖可用 MST 近似

新增模块:
├── cutpoints/     ← A: 割点 + 桥
├── coloring/      ← B: 图着色
├── clique/        ← C: 团 / 独立集 / 顶点覆盖
└── hamiltonian/   ← D: 哈密顿路径 / TSP
```

---

## 2. 子模块 A：割点 & 桥 (Articulation Points & Bridges)

### 2.1 功能概述

**割点（Articulation Point）**: 删除该节点后图的连通分量数增加的节点。
**桥（Bridge）**: 删除该边后图的连通分量数增加的边。

**应用场景**:
- 🌐 网络可靠性：识别单点故障风险
- 🏗️ 基础设施：找到关键桥梁/路口
- 🔗 社交网络：识别关键影响力人物
- 📍 VLSI 设计：电路板布线关键点

### 2.2 文件结构

```
src/algo/cutpoints/
├── moon.pkg                    # 包配置（依赖 core）
├── types.mbt                   # CutPointResult / BridgeResult
├── articulation_points.mbt     # 割点查找算法
├── bridges.mbt                # 桥查找算法
└── cutpoints_test.mbt         # 测试套件 (~15 tests)
```

**预估代码量**: ~350 行（含测试）

### 2.3 类型系统设计

```moonbit
///|
/// 割点查找结果
pub(all) struct CutPointResult {
  cut_points : Array[@core.NodeId]  // 所有割点的有序列表
  is_cut_point : Array[Bool]        // is_cut_point[i] = 节点 i 是否为割点
  count : Int                       // 割点总数
}

///|
/// 桥查找结果
pub(all) struct BridgeResult {
  bridges : Array[@core.Edge]       // 所有桥的边列表
  is_bridge : Array[Bool]           // is_bridge[i] = 边 i 是否为桥
  count : Int                       // 桥的总数
}
```

### 2.4 公开 API 函数

#### 无向图 API

```moonbit
///|
/// 查找无向图的所有割点（关节点）
///
/// 使用 Tarjan 算法（DFS 变种），时间复杂度 O(V+E)。
///
/// **算法原理**:
/// - 对每个节点 u，维护 discovery time (disc) 和 low link value (low)
/// - low[u] = u 或 u 的后代能通过最多一条回边到达的最小 disc
/// - u 是割点当且仅当:
///   1. u 是 DFS 根且有 ≥ 2 个子树，或
///   2. u 不是根且存在子节点 v 使得 low[v] >= disc[u]
///
/// **时间复杂度**: O(V + E)
/// **空间复杂度**: O(V)
///
/// **参数**:
///   - `g`: 无向图（实现 GraphReadable trait）
///
/// **返回值**: CutPointResult
///   - `cut_points`: 割点列表
///   - `is_cut_point`: 布尔数组，O(1) 查询任意节点是否为割点
///
/// **示例**:
/// ```moonbit
/// let g = make_simple_cycle_with_chord()  // 一个环加一条弦
/// let result = find_articulation_points_undirected(g)
/// // 弦的端点是割点
/// ```
pub fn find_articulation_points_undirected[G : @core.GraphReadable](g : G) -> CutPointResult

///|
/// 查找无向图的所有桥
///
/// 使用 Tarjan 算法（DFS 变种），时间复杂度 O(V+E)。
///
/// **判定条件**: 边 u-v 是桥当且仅当 low[v] > disc[u]
/// （即 v 及其后代无法通过其他路径回到 u 或 u 的祖先）
///
/// **时间复杂度**: O(V + E)
/// **空间复杂度**: O(V)
pub fn find_bridges_undirected[G : @core.GraphReadable](g : G) -> BridgeResult
```

#### 有向图 API

```moonbit
///|
/// 查找有向图基图的所有割点
///
/// 在有向图的**基图**（忽略方向）上运行 Tarjan 算法。
///
/// **时间复杂度**: O(V + E)
pub fn find_articulation_points_directed[G : @core.GraphDirected](g : G) -> CutPointResult

///|
/// 查找有向图基图的所有桥
///
/// **注意**: 有向边的"桥"语义与无向图不同，
/// 这里返回基图中满足桥条件的无向边。
///
/// **时间复杂度**: O(V + E)
pub fn find_bridges_directed[G : @core.GraphDirected](g : T) -> BridgeResult
```

### 2.5 核心算法：Tarjan DFS

#### 割点算法伪代码

```
FIND_ARTICULATION_POINTS(G):
  Input: 连通无向图 G
  Output: CutPointResult
  
  1. 初始化:
     - disc[] = {-1}  // discovery time, -1 表示未访问
     - low[] = {∞}   // low link value
     - parent[] = {-1}
     - time = 0
     - ap[] = {false} // articulation points
  
  2. 对于每个未访问节点 v:
       AP_DFS(v, true)  // 第二个参数表示 v 是否为根
  
  3. 返回 CutPointResult(ap)

AP_DFS(u, is_root):
  1. disc[u] = low[u] = time++
  2. child_count = 0
  
  3. for each neighbor v of u:
       if disc[v] == -1:  // 树边
          parent[v] = u
          child_count++
          AP_DFS(v, false)
          
          // 回溯后更新 low
          low[u] = min(low[u], low[v])
          
          // 割点判定规则 2（非根）
          if !is_root && low[v] >= disc[u]:
             ap[u] = true
       
       else if v != parent[u]:  // 回边
          low[u] = min(low[u], disc[v])
  
  4. // 割点判定规则 1（根）
     if is_root && child_count >= 2:
        ap[u] = true
```

#### 桥算法伪代码

```
FIND_BRIDGES(G):
  Input: 连通无向图 G
  Output: BridgeResult
  
  1. 类似割点算法，但判定条件不同
  
  2. BRIDGE_DFS(u, parent_edge):
       disc[u] = low[u] = time++
       
       for each (v, edge_id) neighbor of u:
          if edge_id == parent_edge: continue
          
          if disc[v] == -1:  // 树边
             BRIDGE_DFS(v, edge_id)
             low[u] = min(low[u], low[v])
             
             // 桥判定条件
             if low[v] > disc[u]:
                bridges.add(edge_id)  // u-v 是桥
          
          else:  // 回边
             low[u] = min(low[u], disc[v])
```

### 2.6 测试策略（~15 个测试）

| 分类 | 数量 | 测试场景 |
|------|:----:|----------|
| **基础功能** | 5 | 简单链（中间是割点）、简单环（无割点）、星形图（中心是割点）、完全图 K4（无割点）、双连通图 |
| **经典案例** | 3 | "领结"图、两个环共享一个点（该点是割点）、网格图 2×3 |
| **边界情况** | 4 | 空图、单节点、单边、两节点一边 |
| **属性验证** | 3 | 删除割点后连通分量增加、删除桥后连通分量增加、割点数量 ≤ V-2 |

#### 关键测试用例

```moonbit
test "simple_chain_has_cutpoint" {
  // 0 — 1 — 2 — 3: 节点 1 和 2 是割点
  let g = make_chain_graph(4)
  let result = find_articulation_points_undirected(g)
  assert_eq(result.count, 2)
}

test "simple_cycle_no_cutpoint" {
  // 三角形或任意环：无割点
  let g = make_triangle_graph()
  let result = find_articulation_points_undirected(g)
  assert_eq(result.count, 0)
}

test "star_graph_center_is_cutpoint" {
  // 星形图：中心连接所有叶子，中心是唯一割点
  let g = make_star_graph(5)  // 1 中心 + 4 叶子
  let result = find_articulation_points_undirected(g)
  assert_eq(result.count, 1)
}

test "bridge_in_simple_graph" {
  // 两个三角形共享一条边：共享边是桥
  let g = make_two_triangles_sharing_edge()
  let result = find_bridges_undirected(g)
  assert_true(result.count > 0)
}

test "removal_increases_components" {
  // 属性验证：删除割点后连通分量数增加
  let g = make_simple_chain(5)
  let result = find_articulation_points_undirected(g)
  for cp in result.cut_points {
    let g_without_cp = remove_node(g, cp)
    assert_true(component_count(g_without_cp) > component_count(g))
  }
}
```

---

## 3. 子模块 B：图着色 (Graph Coloring)

### 3.1 功能概述

**图着色**: 用最少的颜色给图的每个顶点着色，使得相邻顶点颜色不同。

**应用场景**:
- 📅 调度问题：课程/会议时间表安排
- 💻 寄存器分配：编译器优化
- 🗺️ 地图填色：相邻区域不同色
- 📶 频率分配：无线通信信道分配
- ♟️ 数独求解：约束满足问题的特例

### 3.2 文件结构

```
src/algo/coloring/
├── moon.pkg              # 包配置
├── types.mbt             # ColoringResult / ChromaticNumberResult
├── coloring.mbt          # 贪心着色算法
├── chromatic.mbt         # 色数精确算法
└── coloring_test.mbt     # ~15 tests
```

**预估代码量**: ~400 行（含测试）

### 3.3 类型系统设计

```moonbit
///|
/// 图着色结果
pub(all) struct ColoringResult {
  colors : Array[Int]              // colors[i] = 节点 i 的颜色编号
  num_colors : Int                 // 使用的颜色总数
  is_valid : Bool                  // 着色是否合法（相邻节点不同色）
  chromatic_upper_bound : Int       // 色数的上界（≤ 实际色数）
}

///|
/// 色数计算结果
pub(all) struct ChromaticNumberResult {
  chromatic_number : Int?           // 色数（None 表示超时/未完成）
  optimal_coloring : Array[Int]?   // 最优着色方案
  upper_bound : Int                 // 上界（贪心算法结果）
  lower_bound : Int                 // 下界（最大团大小）
  exact : Bool                      // 是否为精确解
}
```

### 3.4 公开 API 函数

```moonbit
///|
/// 贪心图着色算法（顺序着色）
///
/// 按节点顺序依次着色，每步选择最小可用颜色。
/// 时间复杂度 O(V²)，空间复杂度 O(V)。
///
/// **参数**:
///   - `g`: 图（GraphReadable）
///   - `order`: 可选的节点访问顺序（默认按 ID 顺序）
///
/// **返回值**: ColoringResult
pub fn greedy_coloring[G : @core.GraphReadable](g : G) -> ColoringResult
pub fn greedy_coloring_with_order[G : @core.GraphReadable](g : G, order : Array[Int]) -> ColoringResult

///|
/// Welsh-Powell 着色算法
///
/// 按度数降序排列节点后再贪心着色，
/// 通常比朴素贪心使用更少的颜色。
///
/// **时间复杂度**: O(V²)
/// **空间复杂度**: O(V)
pub fn welsh_powell[G : @core.GraphReadable](g : G) -> ColoringResult

///|
/// 计算色数（精确算法）
///
/// 使用回溯法 + 上界/下界剪枝。
/// 对于小规模图（V ≤ 20）可求得精确色数。
///
/// **时间复杂度**: O(k^V) 最坏情况，其中 k 为色数
/// **参数**:
///   - `time_limit_ms`: 超时限制（毫秒），0 表示无限制
pub fn exact_chromatic_number[G : @core.GraphReadable](g : G, time_limit_ms : Int) -> ChromaticNumberResult

///|
/// DSATUR 着色算法（饱和度排序）
///
/// 每次选择"饱和度"最大的未着色节点（打破平局选度数最大者）。
/// 通常比 Welsh-Powell 效果更好。
///
/// **时间复杂度**: O(V²)
pub fn dsatur_coloring[G : @core.GraphReadable](g : G) -> ColoringResult
```

### 3.5 算法详解

#### 贪心着色

```
GREEDY_COLORING(G, order):
  colors[] = {-1}  // -1 表示未着色
  
  for each node u in order:
      used = {}  // 邻居已使用的颜色集合
      
      for each neighbor v of u:
          if colors[v] != -1:
             used.add(colors[v])
      
      // 找到最小的未使用颜色
      c = 0
      while c in used:
          c++
      
      colors[u] = c
  
  return ColoringResult(colors, max(colors)+1)
```

#### Welsh-Powell 改进

```
WELSH_POWELL(G):
  1. 将节点按度数降序排列: order = sort_by_degree_desc()
  2. 调用 GREEDY_COLORING(G, order)
  3. 返回结果
```

#### DSATUR 算法

```
DSATUR(G):
  saturation[] = {0}  // 每个节点的饱和度（邻居使用的不同颜色数）
  colors[] = {-1}
  
  while 存在未着色节点:
      // 选择饱和度最大的未着色节点（平局选度数最大的）
      u = select_max_saturation(uncolored_nodes)
      
      // 找到最小可用颜色
      c = min_available_color(u)
      colors[u] = c
      
      // 更新邻居的饱和度
      for each neighbor v of u:
          if colors[v] == -1 and c not in neighbor_colors(v):
             saturation[v]++
  
  return ColoringResult(colors, max(colors)+1)
```

### 3.6 测试策略（~15 个测试）

| 分类 | 数量 | 场景 |
|------|:----:|------|
| **基础功能** | 5 | 空图、完全图 K_n（n 色）、二分图（2 色）、奇环（3 色）、星形图（2 色） |
| **算法对比** | 3 | Greedy vs Welsh-Powell vs DSATUR（同一图的颜色数对比） |
| **边界情况** | 3 | 单节点、单边、非连通图（各分量独立着色） |
| **经典案例** | 2 | Petersen 图（色数=3）、Grötzsch 定理（平面三角图色数≤3） |
| **属性验证** | 2 | 合法性验证（无相邻同色）、颜色数 ≤ V |

---

## 4. 子模块 C：团 / 独立集 / 顶点覆盖

### 4.1 功能概述

**团（Clique）**: 图中两两相邻的顶点子集。
**独立集（Independent Set）**: 图中两两不相邻的顶点子集。
**顶点覆盖（Vertex Cover）**: 覆盖所有边的顶点子集（每条边至少有一个端点在集中）。

**三者互补关系**:
- S 是团 ⟺ S 是补图的独立集
- S 是独立集 ⟺ V \ S 是顶点覆盖
- 最大团 = 补图的最大独立集 = V \ 最小顶点覆盖

**应用场景**:
- 👥 社交网络：寻找紧密社群（最大团）
- 🧬 生物信息学：蛋白质相互作用网络
- 📊 调度问题：资源冲突检测
- 🔐 密码学：MDS 码构造

### 4.2 文件结构

```
src/algo/clique/
├── moon.pkg              # 包配置
├── types.mbt             # CliqueResult / IndependentSetResult / VertexCoverResult
├── bron_kerbosch.mbt    # 最大团算法
├── independent_set.mbt   # 最大独立集
├── vertex_cover.mbt      // 最小/近似顶点覆盖
└── clique_test.mbt       # ~12 tests
```

**预估代码量**: ~450 行（含测试）

### 4.3 类型系统设计

```moonbit
///|
/// 最大团查找结果
pub(all) struct CliqueResult {
  maximum_clique : Array[@core.NodeId]  // 最大团的节点列表
  size : Int                            // 团的大小（ω(G)）
  all_maximal_cliques : Array[Array[@core.NodeId]]  // 所极大团（可选）
}

///|
/// 最大独立集结果
pub(all) struct IndependentSetResult {
  maximum_set : Array[@core.NodeId]     // 最大独立集
  size : Int                           // 独立数 α(G)
}

///|
/// 顶点覆盖结果
pub(all) struct VertexCoverResult {
  cover : Array[@core.NodeId]          // 顶点覆盖
  size : Int                           // 覆盖大小 τ(G)
  is_optimal : Bool                     // 是否为最优解（精确 vs 近似）
  approximation_ratio : Double?         // 近似比（仅近似算法有值）
}
```

### 4.4 公开 API 函数

```moonbit
///|
/// 查找最大团（Bron-Kerbosch 算法 + 枢轴排序）
///
/// **时间复杂度**: O(3^{V/3}) （枢轴排序版本）
/// **空间复杂度**: O(V)
///
/// **算法原理**:
/// Bron-Kerbosch 是枚举所有极大团的回溯算法。
/// 基本递归:
///   BronKerbosch(R, P, X):
///     if P = ∅ and X = ∅: 报告 R 为极大团
///     选择枢轴 u ∈ P ∪ X
///     for each v in P \ N(u):
///         BronKerbosch(R ∪ {v}, P ∩ N(v), X ∩ N(v))
///         P = P \ {v}
///         X = X ∪ {v}
///
pub fn find_maximum_clique[G : @core.GraphReadable](g : G) -> CliqueResult

///|
/// 查找最大独立集
///
/// 通过在补图上查找最大团来实现。
///
/// **时间复杂度**: O(3^{V/3})
pub fn find_maximum_independent_set[G : @core.GraphReadable](g : G) -> IndependentSetResult

///|
/// 查找最小顶点覆盖（2-近似算法）
///
/// 基于最大匹配的近似算法，保证近似比 ≤ 2。
/// 对于二分图可通过 König 定理求得精确解。
///
/// **时间复杂度**: O(V × f(V,E)) 其中 f 为匹配算法复杂度
pub fn find_minimum_vertex_cover_approx[G : @core.GraphReadable](g : G) -> VertexCoverResult

///|
/// 枚举所有极大团
///
/// 用于需要所有极大团的应用（如社交网络社群发现）。
///
/// **注意**: 极大团的数量可能呈指数级增长！
pub fn enumerate_all_maximal_cliques[G : @core.GraphReadable](g : G) -> Array[Array[@core.NodeId]]
```

### 4.5 核心算法：Bron-Kerbosch

```
BRON_KERBOSCH_WITH_PIVOT(R, P, X):
  if P = ∅ and X = ∅:
     report R as maximal clique
     return
  
  // 选择枢轴：在 P ∪ X 中选择度数最大的节点
  pivot = select_pivot(P ∪ X)
  
  // 只需遍历 P \ N(pivot)（剪枝优化）
  for each v in P \ N(pivot):
     BRON_KERBOSCH(R ∪ {v}, P ∩ N(v), X ∩ N(v))
     P = P \ {v}
     X = X ∪ {v}
```

### 4.6 测试策略（~12 个测试）

| 分类 | 数量 | 场景 |
|------|:----:|------|
| **基础功能** | 4 | 空图（ω=0）、完全图 K_n（ω=n）、空图独立集=V、完全图独立集=1 |
| **经典案例** | 3 | Petersen 图（ω=2）、5-环（ω=2）、Chvátal 图 |
| **边界情况** | 2 | 单节点、无边的多节点图 |
| **互补性验证** | 2 | 团大小 = 补图独立集大小、独立集补集 = 顶点覆盖 |
| **近似质量** | 1 | 近似覆盖大小 ≤ 2 × 最优覆盖大小 |

---

## 5. 子模块 D：哈密顿路径 & TSP

### 5.1 功能概述

**哈密顿路径/回路**: 访问图中每个顶点恰好一次的路径/回路。
**旅行商问题 (TSP)**: 找到访问每个城市恰好一次并返回起点的最短路径。

**NP-hard 注意**: 这类问题没有已知的多项式时间精确算法（除非 P=NP）。
本模块提供**小规模精确解**和**启发式近似**。

**应用场景**:
- 🚚 物流配送：最短送货路线
- 🧬 DNA 测序：片段组装
- 🎯 电路板钻孔：最短钻孔路径
- 🗺️ 旅游规划：景点游览顺序优化

### 5.2 文件结构

```
src/algo/hamiltonian/
├── moon.pkg              # 包配置
├── types.mbt             # HamiltonianResult / TSPResult
├── hamiltonian_path.mbt  # 哈密顿路径/回路判定与查找
├── tsp.mbt              // TSP 精确算法（Held-Karp DP）
└── hamiltonian_test.mbt  # ~12 tests
```

**预估代码量**: ~420 行（含测试）

### 5.3 类型系统设计

```moonbit
///|
/// 哈密顿路径/回路查找结果
pub(all) struct HamiltonianResult {
  exists : Bool                         // 是否存在
  path : Array[@core.NodeId]            // 路径/回路的节点序列（空表示不存在）
  is_circuit : Bool                     // 是否为回路（起点=终点）
  start_node : @core.NodeId?            // 起点
}

///|
/// TSP 结果
pub(all) struct TSPResult {
  tour : Array[Int]                    // 最优/近似路径（节点索引序列）
  total_cost : Double                   // 总代价（权重之和）
  is_optimal : Bool                     // 是否为最优解
  algorithm : String                    // 使用的算法名称
  time_ms : Int                         // 计算耗时（毫秒）
}
```

### 5.4 公开 API 函数

```moonbit
///|
/// 判定哈密顿回路是否存在（必要条件快速检查）
///
/// **快速失败条件**:
/// - 任何节点度数 < 2 → 不存在哈密顿回路
/// - 图不连通 → 不存在
///
/// **注意**: 这些条件是必要的但非充分的！
///
/// **时间复杂度**: O(V + E)
pub fn has_hamiltonian_circuit_quick_check[G : @core.GraphReadable](g : G) -> Bool

///|
/// 查找哈密顿路径（回溯算法）
///
/// **时间复杂度**: O(V!) 最坏情况
/// **适用规模**: V ≤ 20（实际取决于图密度）
///
/// **优化**:
/// - 度数剪枝：跳过度数 < 2 的节点
/// - 连通性剪枝：提前检测不连通
/// - 前向检查（FC）：维护剩余节点的可达性矩阵
pub fn find_hamiltonian_path_backtrack[G : @core.GraphReadable](g : G) -> HamiltonianResult

///|
/// 查找哈密顿回路（位掩码 DP - Held-Karp）
///
/// **时间复杂度**: O(2^V · V²)
/// **空间复杂度**: O(2^V · V)
/// **适用规模**: V ≤ 20（精确解）
///
/// **算法原理**:
/// dp[S][v] = 从起点出发，经过节点集合 S（ bitmask 表示），
///            最后到达节点 v 的最短路径是否存在/代价
///
/// 状态转移:
/// dp[S | {u}][u] = min over v in S of (dp[S][v] + cost[v][u])
pub fn find_hamiltonian_circuit_dp[G : @core.GraphReadable](g : G) -> HamiltonianResult

///|
/// TSP 精确求解（Held-Karp DP）
///
/// 要求图为完全图（或先通过 Floyd-Warshall 计算全源最短路径）。
///
/// **时间复杂度**: O(2^V · V²)
/// **适用规模**: V ≤ 18-20（取决于硬件）
pub fn tsp_exact_held_karp(weights : Array[Array[Double]]) -> TSPResult

///|
/// TSP 近似算法（最近邻 + 2-opt 改进）
///
/// 适用于大规模实例（V > 20）。
/// 近似比通常在 1.2 ~ 1.5 之间。
///
/// **时间复杂度**: O(V²) 最近邻 + O(k · V²) 2-opt
pub fn tsp_approximate(weights : Array[Array[Double]], iterations : Int) -> TSPResult
```

### 5.5 算法详解

#### 位掩码 DP（Held-Karp）

```
TSP_DP(weights[V][V]):
  n = V
  INF = ∞
  dp[2^n][n] = INF
  
  // 基础情况：从节点 0 出发，只访问了节点 0
  dp[1][0] = 0
  
  // 枚举所有非空的节点集合 S
  for S from 1 to (1 << n) - 1:
      if S 的最低位不是 0: continue  // 必须包含起点 0
      
      for each u in 0..n:
          if u not in S: continue
          
          for each v in 0..n:
              if v in S: continue
              
              new_S = S | (1 << v)
              dp[new_S][v] = min(dp[new_S][v], dp[S][u] + weights[u][v])
  
  // 答案：从某个节点 u 回到起点 0
  answer = min over u of dp[(1<<n)-1][u] + weights[u][0]
  return answer
```

#### 2-opt 局部搜索

```
2_OPT_IMPROVE(tour, weights):
  improved = true
  
  while improved:
      improved = false
      for i in 0..n-2:
          for j in i+2..n:
              // 尝试反转 tour[i+1..j] 段
              new_tour = reverse_segment(tour, i+1, j)
              if cost(new_tour) < cost(tour):
                  tour = new_tour
                  improved = true
  
  return tour
```

### 5.6 测试策略（~12 个测试）

| 分类 | 数量 | 场景 |
|------|:----:|------|
| **基础功能** | 4 | 完全图 K_n（存在哈密顿回路）、环路图 C_n（存在）、树（不存在）、星形图（不存在） |
| **精确算法** | 2 | 小规模 TSP（4-6 城市已知答案）、DP vs 回溯一致性 |
| **边界情况** | 2 | 空/单/双节点、3 节点完全图 |
| **近似质量** | 2 | 近似解 ≤ 2 × 最优解、2-opt 收敛性 |
| **性能测试** | 2 | V=10 时 DP 时间 < 100ms、V=15 时回溯合理时间内完成 |

---

## 6. 跨模块协同

### 6.1 模块间数据流

```
用户输入图 G
    │
    ├─→ cutpoints/  ──→ 识别关键节点/边
    │       │
    │       └─→ 移除割点后得到更小的连通分量
    │
    ├─→ coloring/   ──→ 得到色数 χ(G)
    │       │
    │       └─→ χ(G) 作为团大小的下界传给 clique/
    │
    ├─→ clique/     ──→ 找到最大团 ω(G)
    │       │
    │       ├─→ ω(G) ≥ n/χ(G)（验证）
    │       │
    │       └─→ 独立集 α(G) = ω(补图)
    │               │
    │               └─→ 顶点覆盖 τ(G) = V - α(G)
    │
    └─→ hamiltonian/ ──→ 判定哈密顿性
            │
            └─→ δ(G) ≥ V/2 ⇒ 存在哈密顿回路（Dirac 定理）
```

### 6.2 共享辅助函数建议

以下函数可考虑提取到 `src/core/helpers.mbt` 或公共工具包：

| 函数 | 使用者 | 说明 |
|------|--------|------|
| `deep_copy_adj_list` | 全部 | 邻接表深拷贝 |
| `complement_graph` | coloring, clique | 构建补图 |
| `is_connected` | 全部 | 连通性检查（已有） |
| `component_count` | cutpoints | 连通分量计数 |
| `degree_sequence` | coloring, hamiltonian | 度数序列 |

---

## 7. 性能预算

### 7.1 各模块时间复杂度汇总

| 模块 | 算法 | 时间 | 适用规模 |
|------|------|:----:|:--------:|
| **cutpoints** | Tarjan DFS | **O(V+E)** | V ≤ 10^6 |
| **coloring** | Greedy/WP/DSATUR | **O(V²)** | V ≤ 10^5 |
| **coloring** | 精确色数 | O(k^V) | V ≤ 25 |
| **clique** | Bron-Kerbosch | **O(3^{V/3})** | V ≤ 80 |
| **hamiltonian** | 回溯 | O(V!) | V ≤ 20 |
| **hamiltonian** | 位掩码 DP | **O(2^V·V²)** | V ≤ 20 |
| **tsp** | Held-Karp | **O(2^V·V²)** | V ≤ 18 |
| **tsp** | 2-opt 近似 | O(k·V²) | V ≤ 10^4 |

### 7.2 内存预算

| 数据结构 | 空间 | 使用者 |
|----------|:----:|--------|
| 邻接矩阵 | O(V²) | coloring, hamiltonian, tsp |
| 邻接表 | O(V+E) | 全部 |
| DP 表 | O(2^V·V) | hamiltonian, tsp |
| 回溯栈 | O(V) | clique, hamiltonian |

---

## 8. 实现计划概要

### 8.1 分批提交策略

按照原子性原则，每个子模块分 3-4 次 commit：

```
子模块 A (cutpoints/): 3 commits
  1. feat(cutpoints): add base types
  2. feat(cutpoints): implement Tarjan articulation points algorithm
  3. feat(cutpoints): implement bridge detection + test(cutpoints): complete suite (15 tests)

子模块 B (coloring/): 3 commits
  4. feat(coloring): add types and greedy/Welsh-Powell algorithms
  5. feat(coloring): add DSATUR and exact chromatic number
  6. test(coloring): complete test suite (15 tests)

子模块 C (clique/): 3 commits
  7. feat(clique): add types and Bron-Kerbosch algorithm
  8. feat(clique): add independent set and vertex cover
  9. test(clique): complete test suite (12 tests)

子模块 D (hamiltonian/): 3 commits
  10. feat(hamiltonian): add types and backtracking algorithm
  11. feat(hamiltonian): add DP TSP and approximate TSP
  12. test(hamiltonian): complete test suite (12 tests)

文档: 1 commit
  13. docs(P5): add README files and design document
```

**总计**: ~13 commits

### 8.2 预估总代码量

| 子模块 | 源码 | 测试 | 文档 | **合计** |
|--------|:----:|:----:|:----:|:-------:|
| A. cutpoints | 200 | 250 | 150 | **600** |
| B. coloring | 220 | 280 | 160 | **660** |
| C. clique | 250 | 220 | 140 | **610** |
| D. hamiltonian | 230 | 220 | 130 | **580** |
| **总计** | **900** | **970** | **580** | **~2450** |

---

## 9. 验收标准

### 9.1 功能验收

**子模块 A (cutpoints)**:
- [ ] 4 个公开 API 函数全部实现
- [ ] 简单链/环/星形的割点判定正确
- [ ] 桥的判定正确
- [ ] 删除割点/桥后连通分量增加（属性验证）

**子模块 B (coloring)**:
- [ ] 4 种着色算法全部实现
- [ ] 完全图 K_n 返回 n 色
- [ ] 二分图返回 ≤ 2 色
- [ ] 着色合法性验证（无相邻同色）

**子模块 C (clique)**:
- [ ] 4 个公开 API 函数全部实现
- [ ] 完全图 K_n 的最大团大小 = n
- [ ] 团-独立集-顶点覆盖互补性验证
- [ ] 近似比 ≤ 2（顶点覆盖）

**子模块 D (hamiltonian)**:
- [ ] 5 个公开 API 函数全部实现
- [ ] 完全图存在哈密顿回路
- [ ] 小规模 TSP 答案正确（与暴力验证对比）
- [ ] 近似解质量合理

### 9.2 质量验收

- [ ] `moon check src/algo/cutpoints` 零错误零警告
- [ ] `moon check src/algo/coloring` 零错误零警告
- [ ] `moon check src/algo/clique` 零错误零警告
- [ ] `moon check src/algo/hamiltonian` 零错误零警告
- [ ] 各模块测试全通过（~54 tests 总计）
- [ ] `moon fmt` 格式化无变更
- [ ] `moon info` 更新 .mbti 文件

### 9.3 文档验收

- [ ] 每个子模块有 README.md（8 大章节）
- [ ] 所有 pub fn 有文档注释
- [ ] 本设计文档完整

---

## 10. 设计决策记录

### 决策 1：为什么割点和桥放在同一个模块？

**理由**:
1. **算法同源**: 都基于 Tarjan DFS（disc/low 数组）
2. **经常联用**: 网络分析中通常同时需要两者
3. **代码复用**: DFS 框架可以共享（抽象出通用 DFS visitor）

**权衡**: 如果未来 BCC（双连通分量）需求强烈，可拆分为 `articulation/` 和 `bridges/`

---

### 决策 2：为什么着色提供多种算法？

**理由**:
1. **精度-速度权衡**: 贪心 O(V²) 快但不精确；回溯精确但慢
2. **启发式改进**: Welsh-Powell 和 DSATUR 都是贪心的改进变体
3. **教学价值**: 展示同一问题的不同算法思路

**选择**: 提供 4 种算法让用户根据需求选择

---

### 决策 3：为什么 TSP 放在 hamiltonian 模块？

**理由**:
1. **问题关联**: TSP 是哈密顿回路的加权版本
2. **共享算法**: Held-Karp DP 同时解决两者
3. **避免碎片化**: 单独的 tsp/ 模块太小

**权衡**: 如果 TSP 算法扩展（如分支定界、Lin-Kernighan），可拆分为独立模块

---

### 决策 4：NP-hard 问题的处理策略

**原则**:
1. **明确标注复杂度**: 每个 NP-hard 函数的文档必须说明时间复杂度
2. **提供规模限制**: 注释中标明推荐的最大输入规模
3. **精确+近似并存**: 同时提供精确算法（小规模）和近似算法（大规模）
4. **超时机制**: 精确算法支持 `time_limit_ms` 参数

---

## 11. 扩展性预留

### 11.1 未来可能的扩展（P6+）

| 扩展 | 优先级 | 说明 |
|------|:------:|------|
| 双连通分量 (BCC/EBC) | P5.5 | 割点/桥的自然延伸 |
| 图同构 | P6 | Ullmann 算法 / VF2 |
| 平面性测试 | P6 | 平面嵌入（Boyer-Myrvold） |
| 最大流扩展 | P6 | 最小费用流 / 多商品流 |
| 更强 TSP | P7 | Concorde 级别的分支切割 |
| 并行算法 | P8 | 并行 Bron-Kerbosch / 并行着色 |

### 11.2 接口预留

```moonbit
// 未来可能添加的 API（不阻塞当前实现）
// pub fn find_biconnected_components(...) -> BCCResult  // 双连通分量
// pub fn is_planar(...) -> Bool                              // 平面性判定
// pub fn graph_isomorphism(g1, g2) -> IsoResult            // 图同构
// pub fn min_cost_max_flow(...) -> MCMFResult               // 最小费用最大流
```

---

## 附录 A：算法复杂度速查表

| 问题 | 精确算法 | 复杂度 | 近似算法 | 近似比 |
|------|---------|--------|---------|:------:|
| 割点 | Tarjan | O(V+E) | - | 最优 |
| 桥 | Tarjan | O(V+E) | - | 最优 |
| Δ-着色 | 贪心 | O(V²) | - | Δ+1 近似 |
| k-着色 | 回溯 | O(k^V) | DSATUR | 启发式 |
| 最大团 | B-K | O(3^{V/3}) | - | 精确 |
| 顶点覆盖 | 匹配 | O(V·E) | 贪心 | 2-近似 |
| 哈密顿 | DP | O(2^V·V²) | - | 精确（小规模）|
| TSP | H-K | O(2^V·V²) | 2-opt | 1.5-2x |

---

## 附录 B：参考资料

### 算法文献

1. **Tarjan, R.** (1972). *Depth-first search and linear graph algorithms*. SIAM Journal on Computing.
2. **Bron, C., Kerbosch, J.** (1973). *Algorithm 457: Finding all cliques of an undirected graph*. Communications of the ACM.
3. **Held, M., Karp, R.M.** (1970). *The traveling-salesman problem and minimum spanning trees*. Operations Research.
4. **Welsh, D.J., Powell, M.B.** (1967). *An upper bound for the chromatic number of a graph*. The Computer Journal.
5. **Brélaz, D.** (1979). *New methods to color the vertices of a graph*. Communications of the ACM.

### 在线资源

- Wikipedia: [Articulation point](https://en.wikipedia.org/wiki/Biconnected_component), [Graph coloring](https://en.wikipedia.org/wiki/Graph_coloring), [Clique problem](https://en.wikipedia.org/wiki/Clique_problem)
- VisuAlgo: [Graph Traversal](https://visualgo.net/en/dfsbfs)
- CP-Algorithms: [Articulation Points](https://cp-algorithms.com/graph/cutpoints.html), [Bron-Kerbosch](https://cp-algorithms.com/graph/bron_kerbosch.html), [TSP](https://cp-algorithms.com/graph/tsp.html)

---

**文档版本**: v1.0.0
**最后更新**: 2026-05-22
**作者**: mbtgraph-team (AI-assisted design)
**审核状态**: ✅ 待用户最终审批
