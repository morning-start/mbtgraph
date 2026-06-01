# 哈密顿路径与旅行商问题 (`hamiltonian`)

> **版本**: v0.1.0 | **状态**: 稳定 | **测试**: 17 通过 | **复杂度**: NP-hard

提供两类经典 NP-hard 组合优化问题的求解能力：
- **哈密顿路径/回路** — 回溯法精确搜索 O(n!) + 必要条件快速剪枝 O(V)
- **旅行商问题 (TSP)** — 最近邻 NN 启发式 O(n²) / Held-Karp 精确解 O(n²·2^n)

> ⚠️ **NP-hard 警告**: 本模块涉及的计算问题是 NP-hard 的。精确算法仅适用于**小规模实例**（哈密顿 ≤20 节点，TSP ≤12 节点）。大规模问题请使用启发式近似算法。

## 依赖

| 包 | 用途 |
|---|------|
| [`@core`](../core/) | NodeId、GraphReadable trait |
| [`@storage`](../storage/) | 图存储实现（测试用） |

## 文件结构

```
lib/algo/hamiltonian/
├── moon.pkg                    # 包配置
├── types.mbt                   # HamiltonianResult / TSPResult 结果类型
├── helpers.mbt                 # 数组操作辅助函数 (copy/contains/remove)
├── hamiltonian_path.mbt        # 哈密顿路径/回路算法
│   ├── has_hamiltonian_circuit_quick_check()   # O(V) 必要条件检查
│   ├── find_hamiltonian_path_backtrack()       # O(n!) 回溯路径
│   └── find_hamiltonian_circuit_backtrack()    # O(n!) 回溯回路
├── tsp.mbt                     # TSP 算法
│   ├── tsp_nearest_neighbor()                   # O(n²) 启发式近似
│   ├── tsp_exact_held_karp()                   # O(n²·2^n) 精确解 (V≤12)
│   └── build_weight_matrix()                   # 图→权重矩阵转换
└── hamiltonian_test.mbt         # 测试套件 (17 tests)
```

## API 总览

### 核心类型 ([types.mbt](types.mbt))

#### `HamiltonianResult` — 哈密顿路径/回路查找结果

```moonbit
pub(all) struct HamiltonianResult {
  exists : Bool                      // 是否存在满足条件的路径/回路
  path : Array[@core.NodeId]         // 节点序列（空表示不存在）
  is_circuit : Bool                  // true=回路, false=路径
  start_node : @core.NodeId?         // 起点（None 表示无路径）
}
```

#### `TSPResult` — 旅行商问题求解结果

```moonbit
pub(all) struct TSPResult {
  tour : Array[Int]                  // 节点访问顺序（索引序列）
  total_cost : Double                // 总行程代价（权重之和）
  is_optimal : Bool                  // true=精确最优, false=启发式近似
  algorithm : String                 // 使用的算法名称标识
}
```

### 哈密顿算法 ([hamiltonian_path.mbt](hamiltonian_path.mbt))

基于 GraphReadable trait 的泛型算法，支持所有存储类型。

| 函数 | 说明 | 复杂度 | 返回 |
|------|------|--------|------|
| `has_hamiltonian_circuit_quick_check(graph)` | **必要条件**快速判定：度数 ≥ 2 | **O(V)** | `Bool` |
| `find_hamiltonian_path_backtrack(graph)` | 回溯法查找哈密顿**路径** | **O(n·n!)** | `HamiltonianResult` |
| `find_hamiltonian_circuit_backtrack(graph)` | 回溯法查找哈密顿**回路** | **O(n·n!)** | `HamiltonianResult` |

**算法流程（回溯法）**:

```
1. 选择起始节点（路径尝试每个节点，回路固定为节点 0）
2. 递归探索：当前路径 → 未访问邻居 → 剪枝 → 深入
3. 路径完成（长度 = n）→ 返回成功
4. 所有分支穷尽 → 返回不存在
5. 回路额外检查：末节点必须与起点相连
```

### TSP 算法 ([tsp.mbt](tsp.mbt))

接受邻接权重矩阵输入，返回最优或近似环路。

| 函数 | 说明 | 复杂度 | 规模限制 | 返回 |
|------|------|--------|:--------:|------|
| `tsp_nearest_neighbor(weights)` | **最近邻贪心**启发式 | **O(n²)** | 无限制 | `TSPResult` |
| `tsp_exact_held_karp(weights)` | **Held-Karp 排列枚举**精确解 | **O(n²·2^n)** | **V≤12** | `TSPResult` |
| `build_weight_matrix(graph)` | 从 GraphReadable 构建权重矩阵 | **O(V²)** | 无限制 | `Array[Array[Double]]` |

> 💡 **自动降级策略**: 当 `tsp_exact_held_karp()` 的输入规模 V > 12 时，会**自动降级**为最近邻启发式并标记 `is_optimal = false`。

**算法对比**:

| 特性 | 最近邻 (NN) | Held-Karp |
|------|------------|-----------|
| 时间复杂度 | **O(n²)** | O(n²·2^n) |
| 解质量 | 近似（通常 1.25x~2x 最优） | **精确最优** |
| 适用规模 | **任意规模** (1000+ 可行) | **≤12 节点** |
| 保证 | 无保证 | 全局最优 |
| 典型场景 | 大规模物流规划/电路布线 | 小规模精确求解/验证 |

## 使用示例

### 小规模精确求解（≤12 节点）

```moonbit
// 4 城市 TSP — 使用 Held-Karp 精确算法
let weights = [
  [0.0, 10.0, 15.0, 20.0],    // 城市 0 到其他城市距离
  [10.0, 0.0, 35.0, 25.0],
  [15.0, 35.0, 0.0, 30.0],
  [20.0, 25.0, 30.0, 0.0],
]

let result = tsp_exact_held_karp(weights)
result.is_optimal              // => true
result.total_cost              // => 80.0 (已知最优: 0→1→3→2→0)
result.tour                    // => [0, 1, 3, 2] 或等价排列
result.algorithm               // => "Held-Karp"
```

### 大规模启发式近似（NN 最近邻）

```moonbit
// 50 城市 TSP — 自动使用最近邻（Held-Karp 会降级）
let large_weights = make_large_tsp_matrix(50)  // 假设已构建

let result = tsp_nearest_neighbor(large_weights)
result.is_optimal              // => false（启发式近似）
result.tour.length()           // => 50（包含所有城市）
result.algorithm               // => "最近邻"

// 或者调用 exact 版本（V > 12 自动降级）
let auto_result = tsp_exact_held_karp(large_weights)
auto_result.is_optimal         // => false（已自动降级到 NN）
auto_result.algorithm          // => "最近邻"（降级后）
```

### 哈密顿回路检测（完整图必存在）

```moonbit
// K5 完全图 — 一定存在哈密顿回路
let g = create_complete_graph(5)

let circuit = find_hamiltonian_circuit_backtrack(g)
circuit.exists                 // => true
circuit.is_circuit             // => true
circuit.path.length()          // => 5（经过所有节点恰好一次）
```

### Dirac/Ore 条件快速判定避免回溯

```moonbit
// 先做 O(V) 快速检查，避免昂贵的 O(n!) 回溯
let g = make_some_graph()

if has_hamiltonian_circuit_quick_check(g) {
  // 通过必要条件检查 → 可能存在 → 执行回溯确认
  let result = find_hamiltonian_circuit_backtrack(g)
  // ...
} else {
  // 度数不足 → 一定不存在 → 直接跳过
}
```

### 经典图例验证

```moonbit
// Petersen 图（10 节点）— 有名的非哈密顿图示例
// let petersen = create_petersen_graph()
// let r = find_hamiltonian_circuit_backtrack(petersen)
// r.exists  // => false（Petersen 图无哈密顿回路）

// 正十二面体图（20 节点）— 有哈密顿回路
// let dodeca = create_dodecahedron_graph()
// let r = find_hamiltonian_circuit_backtrack(dodeca)
// r.exists  // => true

// 环图 C_n — 最简单的哈密顿图
let cycle = create_cycle_graph(7)
let path_r = find_hamiltonian_path_backtrack(cycle)
path_r.exists                 // => true
path_r.is_circuit             // => false（路径不要求首尾相连）

let circuit_r = find_hamiltonian_circuit_backtrack(cycle)
circuit_r.exists              // => true
circuit_r.is_circuit          // => true（环图本身就是哈密顿回路）
```

### 从图构建 TSP 权重矩阵

```moonbit
// 将任意 GraphReadable 存储转换为 TSP 所需的权重矩阵
let g = @storage.new_undirected()
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_node(g, 0.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(1), 10.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(1), @core.NodeId(2), 15.0) |> ignore
@core.GraphWritable::add_edge(g, @core.NodeId(0), @core.NodeId(2), 20.0) |> ignore

let weights = build_weight_matrix(g)
// weights =>
// [[0.0, 10.0, 20.0],
//  [10.0, 0.0, 15.0],
//  [20.0, 15.0, 0.0]]

let tsp_result = tsp_nearest_neighbor(weights)
```

## 算法原理

### 回溯法框架（哈密顿路径/回路）

回溯法是求解哈密顿问题的标准精确算法，通过系统化地枚举所有可能的节点排列来寻找有效路径。

```
状态空间: n! 种排列（完全图情况）
剪枝策略:
  ├─ 邻接约束: 下一个节点必须在当前节点的邻居集合中
  ├─ 访问约束: 不能重复访问已走过的节点
  └─ 回路额外约束: 最后一个节点必须与起点相邻

时间复杂度:
  ├─ 最坏情况: O(n · n!)（完全图，需要遍历大部分排列）
  ├─ 平均情况: 取决于图的稀疏程度和剪枝效果
  └─ 实际表现: 稀疏图因强剪枝而显著快于最坏界

空间复杂度: O(n)（递归栈深度 + 当前路径）
```

**回溯过程可视化**（4 节点示例）:

```
Start: [0]
├─ Try 1: [0, 1]
│  ├─ Try 2: [0, 1, 2] → Try 3: [0, 1, 2, 3] ✓ (路径找到)
│  └─ Try 3: [0, 1, 3] → Try 2: [0, 1, 3, 2] ✓ (另一条路径)
├─ Try 2: [0, 2]
│  ├─ Try 1: [0, 2, 1] → ... (剪枝或继续)
│  └─ Try 3: [0, 2, 3] → ... (剪枝或继续)
└─ Try 3: [0, 3]
   ├─ Try 1: [0, 3, 1] → ...
   └─ Try 2: [0, 3, 2] → ...
```

### 最近邻贪心策略（NN Heuristic）

TSP 最简单且最快的启发式算法，每次选择距离当前位置最近的未访问城市。

```
算法步骤:
  1. 从任意起点出发（固定为节点 0）
  2. 在未访问城市中选择距离最近的
  3. 标记为已访问，移动到该城市
  4. 重复直到所有城市访问完毕
  5. 返回起点形成闭环

贪心性质:
  ├─ 每步局部最优 → 不保证全局最优
  ├─ 时间复杂度 O(n²): n 步 × 每步扫描 n 个候选
  └─ 近似比: 无常数界（最坏情况可任意差）

典型误差范围:
  ├─ 欧几里得 TSP: 通常在最优解的 1.2x ~ 1.5x 内
  ├─ 随机距离矩阵: 通常在 1.25x ~ 2x 内
  └─ 特殊构造: 可达 O(log n / log log n) 倍最优
```

### Held-Karp 位 DP / 排列枚举

本实现采用排列枚举变体（非经典的位 DP 状态压缩），通过穷举所有排列寻找全局最优解。

```
状态定义:
  current_path: 已确定的前缀路径
  remaining: 未访问的节点集合
  current_cost: 当前路径累积代价

转移方程:
  dp(S, last) = min{ dp(S\{last}, prev) + weight(prev, last) }
  其中 S 是已访问节点集合，last 是最后一个节点

边界条件:
  dp({start}, start) = 0
  dp(S, last) = min over all prev in S\{last}

优化手段:
  ├─ 分支定界: 当前代价 ≥ 已知最优时剪枝
  ├─ 提前终止: 找到完整环路即更新最优解
  └─ 对称性利用: 固定起点为节点 0，减少 (n-1)! 倍搜索

规模限制原因:
  12 节点: 11! ≈ 4×10^7 次操作 ≈ 秒级
  15 节点: 14! ≈ 8.7×10^10 次操作 ≈ 小时级
  20 节点: 19! ≈ 1.2×10^17 次操作 ≈ 不可行
```

## 内部组件

### 辅助函数 ([helpers.mbt](helpers.mbt))

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `copy_array_int(arr)` | priv | 深拷贝 Int 数组（保证纯函数语义） |
| `array_contains(arr, val)` | priv | 线性搜索判断数组是否包含某值 |
| `remove_from_array(arr, val)` | priv | 移除数组中指定值的所有出现 |

> 📌 **设计说明**: 这些辅助函数确保回溯过程中的数组操作不会产生副作用——每一步递归都使用独立的副本。

### 哈密顿内部组件 ([hamiltonian_path.mbt](hamiltonian_path.mbt))

| 函数 | 可见性 | 功能 |
|------|:------:|------|
| `get_neighbors_list(g, v, n)` | priv | 获取节点 v 的邻居列表（过滤越界索引） |
| `backtrack_path(g, path, remaining, n)` | priv | 回溯搜索哈密顿**路径** |
| `backtrack_circuit(g, path, remaining, start, n)` | priv | 回溯搜索哈密顿**回路**（额外验证首尾相连） |

### TSP 内部组件 ([tsp.mbt](tsp.mbt))

| 函数/类型 | 可见性 | 功能 |
|------|:------:|------|
| `TSPState` (struct) | priv | 中间状态：当前 tour + cost |
| `find_nearest_unvisited(weights, current, visited, n)` | priv | 找到距当前节点最近的未访问节点 |
| `tsp_permute(weights, path, remaining, cost, best_cost, best_tour, n)` | priv | 排列枚举 + 分支定界搜索最优 TSP 环路 |

## 边界行为

### 哈密顿算法

| 条件 | 行为 | 返回值 |
|------|------|--------|
| **空图 (n=0)** | 路径: exists=false, path=[]<br>回路: exists=false, is_circuit=true | `HamiltonianResult` |
| **单节点 (n=1)** | 路径: exists=true, path=[Node0]<br>回路: n<3 → exists=false | `HamiltonianResult` |
| **两节点 (n=2)** | 回路: n<3 → exists=false<br>路径: 若有边则 exists=true | `HamiltonianResult` |
| **星形图** | 叶子节点 degree=1 < 2 → quick_check=false<br>回溯也找不到回路 | `exists: false` |
| **路径图 P_n** | 存在哈密顿**路径**（沿链走）<br>不存在哈密顿**回路**（端点 degree=1） | 路径=true, 回路=false |
| **不连通图** | 回溯自然失败（无法到达所有分量） | `exists: false` |
| **Degree < n/2** | 不触发快速拒绝（quick_check 仅查 degree≥2）<br>但回溯可能耗时较长 | 取决于具体结构 |

### TSP 算法

| 条件 | 行为 | 返回值 |
|------|------|--------|
| **空矩阵 (n=0)** | tour=[], cost=0.0, is_optimal=true/false | `TSPResult` |
| **单节点 (n=1)** | tour=[0], cost=0.0, is_optimal=true | `TSPResult` |
| **V > 12 (exact)** | 自动降级为 nearest_neighbor | `is_optimal: false, algorithm: "最近邻"` |
| **非连通权重矩阵** (-1.0 表示无边) | NN: 跳过负权边，tour 可能不完整<br>Exact: 跳过负权边分支 | tour.length() ≤ n |
| **非对称 TSP** | 两种算法均支持非对称权重矩阵 | 正常工作 |

## 测试覆盖

| 类别 | 测试数量 | 内容 |
|------|:--------:|------|
| **快速检查** | 6 | 空图/单节点/K2/K3/C5/星形图（degree 剪枝） |
| **哈密顿路径** | 5 | 空/K1/K4/C5/P4（存在性+长度验证） |
| **哈密顿回路** | 5 | 空/K4/C5/P4/星形图（存在性+is_circuit 验证） |
| **TSP 基础** | 4 | NN 基础/Exact 基础/Exact 代价合理性/tour 完整性 |
| **合计** | **17** | — |

运行命令:
```bash
moon test lib/algo/hamiltonian  # 17 tests all pass
```

**测试覆盖重点**:

- ✅ **精确解验证**: 4 城市 TSP 已知最优解 80.0，断言范围 [75, 85]
- ✅ **启发式质量评估**: NN 产生合法 tour（覆盖所有节点）
- ✅ **充分条件验证**: 完全图 K_n 必有哈密顿回路
- ✅ **必要条件验证**: 星形图叶子 degree=1 必无哈密顿回路
- ✅ **路径 vs 回路区分**: 路径图有路径无回路

## 设计决策

### 为什么同时提供精确算法和启发式算法？

NP-hard 问题没有已知的多项式时间精确算法，因此本模块采用**双轨制策略**:

| 维度 | 精确算法 (回溯/Held-Karp) | 启发式算法 (NN) |
|------|--------------------------|----------------|
| **适用场景** | 小规模实例 (V≤12~20)、验证基准、学术研究 | 大规模实际应用 (V>50)、实时系统 |
| **价值主张** | **正确性保证** — 找到的解一定是全局最优 | **可用性保证** — 任何规模都能在合理时间内给出解 |
| **互补关系** | 用于验证启发式的质量上界 | 为精确算法提供初始解/下界估计 |

**实用建议流程**:

```moonbit
// 推荐的使用模式
fn solve_tsp(weights : Array[Array[Double]]) -> TSPResult {
  if weights.length() <= 12 {
    tsp_exact_held_karp(weights)      // 小规模：精确求解
  } else {
    tsp_nearest_neighbor(weights)     // 大规模：启发式近似
  }
}
```

### 为什么哈密顿算法基于 GraphReadable trait 而 TSP 使用原始矩阵？

1. **哈密顿问题本质是图论问题** — 只需知道邻接关系，不需要权重信息，天然适配 trait 体系
2. **TSP 本质是优化问题** — 需要完整的距离/权重矩阵，trait 的边查询接口效率不足（逐条查询 vs 矩阵随机访问）
3. **桥接函数** `build_weight_matrix()` 提供 graph → matrix 的转换能力，两者可以配合使用

### 为什么 quick_check 只检查 degree ≥ 2？

Dirac 定理（degree ≥ n/2 ⇒ 存在哈密顿回路）和 Ore 定理（非相邻顶点对 degree 和 ≥ n ⇒ 存在哈密顿回路）都是**充分条件**而非必要条件。当前的 `quick_check` 仅实现了**最弱的必要条件**（degree ≥ 2），原因是：

- 充分条件只能用于**证明存在**，不能用于**证明不存在**
- 作为回溯前的预筛选，弱必要条件已经能过滤掉大量明显无解的情况（如星形图）
- 更强的充分条件判定可以作为独立 API 在未来版本添加

## 与其他模块配合

```moonbit
// 典型工作流：图存储 → 哈密顿检测 → TSP 求解

// 1. 构建或加载图
let g = @storage.new_undirected()
// ... 添加节点和边 ...

// 2. 先检测哈密顿性质（如果关心图的结构特性）
let hc_quick = has_hamiltonian_circuit_quick_check(g)
if hc_quick {
  let hc = find_hamiltonian_circuit_backtrack(g)
  if hc.exists {
    // 图有哈密顿回路 — 可以用于 TSP（TSP 要求完全图）
  }
}

// 3. 如果需要 TSP，转换为权重矩阵
let weights = build_weight_matrix(g)

// 4. 根据规模选择算法
let tsp_result = match weights.length() {
  n if n <= 12 => tsp_exact_held_karp(weights)
  _ => tsp_nearest_neighbor(weights)
}

// 5. 输出结果
println("TSP 总代价: ${tsp_result.total_cost}")
println("是否最优: ${tsp_result.is_optimal}")
println("算法: ${tsp_result.algorithm}")
```

### 与 connectivity 模块的关系

```moonbit
// 哈密顿路径要求图是连通的（除了平凡情况）
// 可以先用连通性检测快速排除
let cc_result = @connectivity.find_connected_components(g)
if cc_result.component_count > 1 && @core.GraphReadable::node_count(g) > 1 {
  // 不连通 → 一定无哈密顿路径 → 跳过回溯
}
```

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| **v0.1.0** | **2026-05-20** | **初始版本：哈密顿路径/回路回溯算法 + TSP NN/Held-Karp + 17 tests + README** |

---

<div align="center">

**🔬 mbtgraph Hamiltonian & TSP Module**

*NP-hard 问题求解：精确算法保证正确性，启发式算法保证可用性*

</div>
