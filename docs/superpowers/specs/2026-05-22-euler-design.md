# Euler 欧拉路径/回路算法模块设计规范

**日期**: 2026-05-22
**状态**: ✅ 已批准，待实现
**模块**: `src/algo/euler/`
**优先级**: P4（图论核心算法）

---

## 1. 功能概述

### 1.1 模块目标

实现欧拉路径（Eulerian Path）和欧拉回路（Eulerian Circuit）的判定与查找算法，支持有向图和无向图两种场景。

### 1.2 核心功能

| 功能 | 无向图 | 有向图 |
|------|:------:|:------:|
| 欧拉路径判定 | `has_euler_path_undirected` | `has_euler_path_directed` |
| 欧拉回路判定 | `has_euler_circuit_undirected` | `has_euler_circuit_directed` |
| 欧拉路径查找 | `find_euler_path_undirected` | `find_euler_path_directed` |
| 欧拉回路查找 | `find_euler_circuit_undirected` | `find_euler_circuit_directed` |

**总计**: 8 个公开 API 函数

### 1.3 应用场景

- **邮递员问题**（Chinese Postman Problem）：寻找最短邮递路线
- **DNA 序列组装**：生物信息学中的序列拼接
- **网络路由优化**：遍历所有链路的最优路径
- **图论教学**：经典算法演示（Konigsberg 七桥问题）

---

## 2. 技术选型

### 2.1 核心算法：Hierholzer 算法

**选择理由**:
- ✅ 时间复杂度 O(E)，优于 Fleury 的 O(E²)
- ✅ 实现简洁（基于 DFS + 栈）
- ✅ 支持有向图和无向图
- ✅ 工业级实用算法（非仅教学用途）

**算法原理**:

```
Hierholzer 算法流程：
1. 从起始节点开始 DFS 遍历
2. 每次走一条未访问的边，标记为已访问
3. 遇到死胡同（无未访问边）时回溯
4. 将当前节点加入路径栈
5. 回溯完成后反转路径得到欧拉路径/回路
```

### 2.2 判定条件

#### 无向图

| 类型 | 条件 |
|------|------|
| **欧拉回路** | 所有节点度为偶数 + 图连通 |
| **欧拉路径** | 恰好 0 或 2 个奇度节点 + 图连通 |

#### 有向图

| 类型 | 条件 |
|------|------|
| **欧拉回路** | 所有节点入度=出度 + 基图连通 |
| **欧拉路径** | 满足以下条件之一：<br>① 所有节点入度=出度（即回路）<br>② 恰好 1 节点出度=入度+1（起点）+ 1 节点入度=出度+1（终点）+ 其余平衡 + 基图连通 |

### 2.3 Trait 约束策略

```moonbit
// 无向图：使用基础 trait（只需查询邻接节点）
pub fn has_euler_path_undirected[G : @core.GraphReadable](g : G) -> Bool

// 有向图：需要 GraphDirected（查询入度/出度）
pub fn has_euler_path_directed[G : @core.GraphDirected](g : T) -> Bool
```

**设计决策**:
- 无向图使用 `GraphReadable`：兼容所有存储类型（AdjList/Matrix/CSR/EdgeList）
- 有向图使用 `GraphDirected`：需要 `in_degree`/`out_degree` 方法
- **不创建独立类型**：直接操作 Graph trait，保持轻量级

---

## 3. 类型系统设计

### 3.1 结果类型定义

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

**设计理由**:
1. **与 flow 模块一致**: 参考 [MaxFlowResult](../src/algo/flow/types.mbt) 的 `{ exists, data }` 模式
2. **返回 Edge 而非 NodeId**: 保留边的完整信息（权重、属性等），便于后续处理
3. **可选类型处理不存在**: 使用 `NodeId?` 避免 magic value（如 -1）

### 3.2 辅助类型（私有）

```moonbit
// 内部使用：边索引三元组 (neighbor, edge_index, edge_id)
type EdgeTriple = (Int, Int, Int)

// 边访问标记数组
type VisitedEdges = Array[Bool]
```

---

## 4. 公开 API 详细说明

### 4.1 无向图 API

#### `has_euler_path_undirected`

```moonbit
/// 判定无向图是否存在欧拉路径
/// 时间复杂度: O(V + E)
/// 空间复杂度: O(V)
///
/// 返回 true 当且仅当：
///   - 图是连通的（忽略孤立节点）
///   - 奇度节点的数量为 0 或 2
pub fn has_euler_path_undirected[G : @core.GraphReadable](g : G) -> Bool
```

**实现逻辑**:
1. 统计每个节点的度数
2. 计算奇度节点数量
3. 检查图的连通性（BFS/DFS 从非孤立节点开始）
4. 返回 `odd_count == 0 || odd_count == 2`

#### `find_euler_undirected`

```moonbit
/// 查找无向图的欧拉路径或回路
/// 时间复杂度: O(E)
/// 空间复杂度: O(E)
///
/// 如果存在欧拉回路，返回 circuit 字段
/// 如果只存在欧拉路径（非回路），返回 path 字段
/// 两者互斥：circuit 非空 ⟺ path 为空
pub fn find_euler_undirected[G : @core.GraphReadable](g : G) -> EulerResult
```

**返回值语义**:
- `exists = false`: 不存在欧拉路径/回路
- `exists = true && circuit.non_empty()`: 存在欧拉回路
- `exists = true && path.non_empty()`: 存在欧拉路径（非回路）

### 4.2 有向图 API

#### `has_euler_path_directed`

```moonbit
/// 判定有向图是否存在欧拉路径
/// 时间复杂度: O(V + E)
/// 空间复杂度: O(V)
///
/// 返回 true 当且仅当：
///   - 基图是连通的（忽略方向）
///   - 度数满足欧拉路径条件（见 §2.2）
pub fn has_euler_path_directed[G : @core.GraphDirected](g : T) -> Bool
```

**额外需求**:
- 使用 `@core.GraphDirected::in_degree` 和 `out_degree` 方法
- 维护 `in_deg[]` 和 `out_deg[]` 数组

#### `find_euler_directed`

```moonbit
/// 查找有向图的欧拉路径或回路
/// 时间复杂度: O(E)
/// 空间复杂度: O(E)
///
/// 实现细节：
///   - 自动识别起点（出度 > 入度的节点，或任意节点）
///   - Hierholzer 算法沿有向边遍历
pub fn find_euler_directed[G : @core.GraphDirected](g : T) -> EulerResult
```

---

## 5. 文件结构

```
src/algo/euler/
├── moon.pkg                  # 包配置（依赖 core）
├── types.mbt                 # EulerPathResult / EulerCircuitResult (~30 行)
├── euler_undirected.mbt      # 无向图算法实现 (~120 行)
│   ├── has_euler_path_undirected
│   ├── has_euler_circuit_undirected
│   ├── find_euler_path_undirected
│   ├── find_euler_circuit_undirected
│   └── priv 辅助函数
│       ├── check_degree_parity
│       ├── is_connected_undirected
│       └── hierholzer_undirected
├── euler_directed.mbt        # 有向图算法实现 (~130 行)
│   ├── has_euler_path_directed
│   ├── has_euler_circuit_directed
│   ├── find_euler_path_directed
│   ├── find_euler_circuit_directed
│   └── priv 辅助函数
│       ├── check_degree_balance
│       ├── is_base_graph_connected
│       └── hierholzer_directed
├── euler_test.mbt            # 测试套件 (~250 行, ~20 tests)
└── README.md                 # 文档
```

**行数统计**: ~530 行（含注释和测试）

---

## 6. 测试策略

### 6.1 测试分类（共 ~20 个测试）

#### 分类 1：基础功能测试（6 个，30%）

| # | 测试名称 | 输入 | 预期输出 | 说明 |
|---|---------|------|---------|------|
| 1 | `test_triangle_circuit` | 无向三角形 K₃ | ✅ 回路存在 | 所有节点度数=2（偶数） |
| 2 | `test_directed_cycle` | 有向环 A→B→C→A | ✅ 回路存在 | 入度=出度=1 |
| 3 | `test_house_graph_no_euler` | 房子图（5 节点） | ❌ 路径不存在 | 奇度节点数=4 |
| 4 | `test_directed_chain` | A→B→C | ⚠️ 路径存在 | 起点 A 出度+1, 终点 C 入度+1 |
| 5 | `test_empty_graph` | 空图（0 节点） | ✅ 平凡回路 | 特殊情况 |
| 6 | `test_single_node` | 单节点无自环 | ✅ 平凡回路 | 0 边也算回路 |

#### 分类 2：算法正确性测试（8 个，40%）

**经典案例**:

| # | 测试名称 | 历史背景 | 预期结果 |
|---|---------|---------|---------|
| 7 | `test_konigsberg` | Konigsberg 七桥问题（1736） | ❌ 不存在（4 个奇度节点） |
| 8 | `test_complete_graph_k4` | 4 节点完全图 | ✅ 回路长度 6 |
| 9 | `test_semi_eulerian` | 半欧拉图（恰好 2 奇度节点） | ✅ 路径存在 |
| 10 | `test_balanced_digraph` | 有向平衡强连通图 | ✅ 回路 |
| 11 | `test_disconnected_graph` | 2 个独立分量 | ❌ 即使度数满足也不行 |

**属性验证测试**:

| # | 测试名称 | 验证内容 |
|---|---------|---------|
| 12 | `test_edge_coverage` | `result.circuit.length() == edge_count`（必须包含所有边） |
| 13 | `test_path_continuity` | 相邻边首尾相连（`path[i].to == path[i+1].from`） |
| 14 | `test_no_duplicate_edges` | 路径中无重复边（每条边恰好访问一次） |
| 15 | `test_start_end_nodes` | 起点和终点正确（奇度节点或任意节点） |

#### 分类 3：边界情况测试（4 个，20%）

| # | 测试名称 | 场景 | 测试要点 |
|---|---------|------|---------|
| 16 | `test_isolated_nodes` | 含孤立节点的欧拉图 | 孤立节点不影响判定 |
| 17 | `test_parallel_edges` | 多重边（平行边） | Hierholzer 正确处理重复边 |
| 18 | `test_self_loops` | 自环边 | 自环被正确遍历和标记 |
| 19 | `test_large_sparse_graph` | 100 节点 101 边树+1 边 | 性能和正确性验证 |

#### 分类 4：属性验证测试（2 个，10%）

| # | 测试名称 | 验证内容 |
|---|---------|---------|
| 20 | `test_immutability` | 算法执行后原图未被修改（深拷贝保证） |
| 21 | `test_consistency` | `has_*` 返回 true ⟹ `find_*` 结果 exists=true |

### 6.2 辅助构建函数

```moonbit
// 测试用辅助函数
priv fn make_triangle_graph() -> @storage.UndirectedAdjList { ... }
priv fn make_konigsberg_graph() -> @storage.UndirectedAdjList { ... }
priv fn make_directed_cycle(n : Int) -> @storage.DirectedAdjList { ... }
priv fn make_semi_eulerian_graph() -> @storage.UndirectedAdjList { ... }
```

### 6.3 测试运行命令

```bash
# 全量测试
moon test

# 单模块测试
moon test src/algo/euler

# 更新快照（如有 snapshot 测试）
moon test --update src/algo/euler
```

---

## 7. 错误处理策略

### 7.1 不使用异常机制

遵循项目规范（参考 flow 模块），**不抛异常**，返回错误结果：

```moonbit
pub fn find_euler_path_undirected[G : @core.GraphReadable](g : G) -> EulerPathResult {
  // 快速失败检查
  if not is_connected_undirected(g) {
    return { exists: false, path: [], start_node: None, end_node: None }
  }
  
  if not check_degree_parity_undirected(g) {
    return { exists: false, path: [], start_node: None, end_node: None }
  }
  
  // 执行 Hierholzer 算法...
  let result = hierholzer_undirected(g)
  result
}
```

### 7.2 快速失败顺序

1. **连通性检查**（O(V+E)）：最先执行，过滤非连通图
2. **度数检查**（O(V)）：其次执行，快速排除不满足条件的图
3. **Hierholzer 算法**（O(E)）：最后执行，仅在通过前两项检查时运行

**优势**: 大多数无效输入在前两步就被拦截，避免不必要的 O(E) 计算。

### 7.3 防御性拷贝

```moonbit
// 内部深拷贝邻接表，避免修改输入图
priv fn hierholzer_undirected[G : @core.GraphReadable](g : G) -> EulerPathResult {
  let mut adj = deep_copy_adj_list(g)  // 深拷贝
  let mut visited = Array::make(edge_count, false)
  
  // 算法修改 adj 和 visited，但不影响原始 g
  ...
}
```

**保证纯函数语义**: 符合 AGENTS.md 规范（"数组修改需深拷贝"）。

---

## 8. 性能特征

### 8.1 时间复杂度分析

| 操作 | 复杂度 | 说明 |
|------|--------|------|
| `has_euler_*` | **O(V + E)** | 度数统计 + 连通性检查 |
| `find_euler_*` | **O(E)** | Hierholzer 主循环 |
| 总体 | **O(V + E)** | 线性时间，最优 |

### 8.2 空间复杂度分析

| 数据结构 | 空间 | 说明 |
|----------|:----:|------|
| 邻接表副本 | O(V + E) | 深拷贝输入图 |
| 边访问标记 | O(E) | `Array[Bool]` |
| DFS 栈 | O(E) | 最坏情况（链状图） |
| 结果路径 | O(E) | 存储边序列 |
| **总计** | **O(V + E)** | 线性空间 |

### 8.3 与其他算法对比

| 算法 | 时间 | 空间 | 适用场景 |
|------|:----:|:----:|---------|
| **Hierholzer**（本模块） | O(E) | O(E) | ✅ 通用推荐 |
| Fleury | O(E²) | O(E) | 教学演示（桥边检测） |
| 循环分解 | O(E) | O(E) | 并行化实现 |

---

## 9. 设计决策记录

### 决策 1：为什么选择 Hierholzer 而非 Fleury？

**选项**:
- A) Hierholzer 算法（O(E)）
- B) Fleury 算法（O(E²)）

**选择**: A) Hierholzer

**理由**:
1. **效率**: O(E) vs O(E²)，对于大规模图差异显著
2. **实现简洁**: 基于 DFS + 栈，代码量少 40%
3. **工业实用**: LeetCode/Codewars 等平台的标准解法
4. **扩展性**: 易于优化为并行版本（循环分解）

**权衡**: Fleury 更直观（"避免走桥边"），适合教学但性能差。

---

### 决策 2：为什么不创建 EulerGraph 包装类？

**选项**:
- A) 独立类型 + Trait 约束（本方案）
- B) EulerGraph 包装类
- C) 纯函数式（无结构体）

**选择**: A) 独立类型 + Trait 约束

**理由**:
1. **一致性**: 与 [flow 模块](../src/algo/flow/) 的 FlowNetwork 模式对齐
2. **灵活性**: 用户可传入任何符合 trait 的存储类型
3. **轻量级**: 无需维护额外的包装类状态
4. **可组合性**: 可与其他算法模块无缝配合

**权衡**: 
- B) 方案更面向对象，但增加耦合
- C) 方案极简，但丢失类型安全（返回值无结构化）

---

### 决策 3：返回 Edge 还是 NodeId？

**选项**:
- A) `Array[Edge]`（本方案）
- B) `Array[NodeId]`
- C) 两者都提供

**选择**: A) `Array[Edge]`

**理由**:
1. **信息保留**: Edge 包含 from/to/weight/id，后续处理无需二次查询
2. **一致性**: 与项目其他模块（MST、最短路径）返回风格统一
3. **实用性**: 邮递员问题等应用需要边的权重信息

**权衡**: 
- B) 方案更节省内存（无冗余数据）
- 如需 NodeId 序列，用户可通过 `.map(e => e.from)` 转换

---

### 决策 4：有向/无向分离为两个文件？

**选项**:
- A) 分离文件（euler_undirected.mbt + euler_directed.mbt）（本方案）
- B) 合并单文件（euler.mbt）
- C) 按功能分离（check.mbt + find.mbt）

**选择**: A) 分离文件

**理由**:
1. **清晰度**: 有向/无向的判定条件和算法差异大，分离后易读
2. **编译隔离**: 修改无向实现不影响有向代码
3. **可维护性**: 未来添加 Fleury 算法时只需新增文件
4. **符合惯例**: flow 模块的 edmonds_karp.mbt / dinic.mbt 也是按算法分离

**权衡**: 
- B) 方案文件少，但单文件可能超过 400 行
- C) 方案过度工程化（YAGNI 原则）

---

## 10. 扩展性预留

### 10.1 未来可能的扩展

| 扩展 | 优先级 | 说明 |
|------|:------:|------|
| Fleury 算法 | P5 | 教学友好版本，可作为备选实现 |
| 欧拉路径计数 | P6 | BEST 定理（矩阵树定理推广） |
| 中国邮递员问题 | P7 | 在欧拉基础上添加最短路径补边 |
| 并行 Hierholzer | P8 | 多线程循环分解实现 |
| 可视化输出 | P9 | 生成 Graphviz DOT 格式的路径图 |

### 10.2 接口预留

```moonbit
// 未来可能添加的 API（不阻塞当前实现）
// pub fn count_eulerian_circuits(...) -> Int  // BEST 定理
// pub fn chinese_postman(...) -> ChinesePostmanResult  // 邮递员问题
// pub fn fleury_find_path(...) -> EulerPathResult  // Fleury 备选
```

---

## 11. 实现约束与依赖

### 11.1 外部依赖

```moonbit
// moon.pkg 配置
import {
  "morning-start/mbtgraph/src/core" @core,
}
```

**依赖范围**:
- ✅ 必须依赖: `@core`（NodeId, Node, Edge, GraphReadable, GraphDirected）
- ❌ 不依赖: 其他算法模块（euler 是独立的）
- ❌ 不依赖: storage 层（通过 trait 泛型解耦）

### 11.2 MoonBit 语法约束

遵循 [AGENTS.md](../../AGENTS.md) 编码规范：

| 规则 | 应用示例 |
|------|---------|
| R1: 完全限定名 | `@core.NodeId(0)` 而非 use 别名 |
| R2: Impl 用 `(self)` | `fn method(self)` 而非 `mut self` |
| R3: 按需声明可变性 | 只改字段→`let g`；重新赋值→`let mut g` |
| R5: For 不解构元组 | `for x in arr { match x { (a,b) => } }` |
| R6: 嵌套泛型 `]]` | `Array[Array[Double?]]` 而非 `T?>>` |
| R7: 避免保留字 | 变量名不用 `fn`, `var`, `graph` |

### 11.3 测试约束

- **双轨制测试**: 黑盒 (`*_test.mbt`) + 白盒 (`*_wbtest.mbt`)
- **覆盖率目标**: 核心函数 100%，辅助函数 > 80%
- **断言方式**: 明确结果用 `assert_true/assert_eq`，复杂输出用 snapshot

---

## 12. 验收标准

### 12.1 功能验收

- [ ] 8 个公开 API 函数全部实现并通过编译
- [ ] 无向图欧拉路径/回路判定正确（三角形、房子图、Konigsberg）
- [ ] 有向图欧拉路径/回路判定正确（有向环、有向链、平衡图）
- [ ] Hierholzer 算法找到的路径包含所有边且无重复
- [ ] 边界情况处理正确（空图、孤立节点、自环、多重边）

### 12.2 质量验收

- [ ] `moon check src/algo/euler` 零错误零警告
- [ ] `moon test src/algo/euler` 全部通过（~20 tests）
- [ ] 不可变性测试通过（原图未被修改）
- [ ] `moon fmt` 格式化无变更
- [ ] `moon info` 更新 .mbti 文件并确认可见性

### 12.3 文档验收

- [ ] README.md 包含 8 大章节（API/示例/原理/内部组件/边界行为/测试/设计决策/配合）
- [ ] 代码注释覆盖所有公开函数（`///` 文档注释）
- [ ] 设计决策记录在本文档（§9）

### 12.4 Git 提交验收

按照原子性原则分 4 次 commit：

```bash
# Commit 1: feat(euler): add base types (types.mbt)
git add types.mbt && git commit -m "feat(euler): add EulerPathResult and EulerCircuitResult types"

# Commit 2: feat(euler): implement undirected and directed algorithms
git add euler_undirected.mbt euler_directed.mbt && git commit -m "feat(euler): implement Hierholzer algorithm for undirected and directed graphs"

# Commit 3: test(euler): add comprehensive test suite (20 tests)
git add euler_test.mbt && git commit -m "test(euler): add complete test suite with 20 test cases covering basic/correctness/boundary/property scenarios"

# Commit 4: docs(euler): add README and design document
git add README.md docs/superpowers/specs/2026-05-22-euler-design.md && git commit -m "docs(euler): add API documentation and design specification"
```

---

## 附录 A：算法伪代码

### A.1 Hierholzer 算法（无向图）

```
HIERHOLZER_UNDIRECTED(G):
  Input: 连通无向图 G（满足欧拉条件）
  Output: 欧拉回路边序列
  
  1. 选择任意起始节点 v₀
  2. 初始化栈 S = [v₀], 路径 P = []
  3. 初始化边访问标记 visited[e] = false ∀ e ∈ E
  4. 
  5. while S 非空 do
  6.   v = S.top()
  7.   if 存在未访问边 (v, u) then
  8.     标记 (v, u) 为已访问
  9.     S.push(u)
 10.   else
 11.     P.add(S.pop())  // 死胡同，回溯
 12.   
 13. return REVERSE(P)  // 反转得到欧拉回路
```

### A.2 Hierholzer 算法（有向图）

```
HIERHOLZER_DIRECTED(G):
  Input: 连通有向图 G（满足欧拉条件）
  Output: 欧拉路径/回路边序列
  
  1. 确定起点 s：
  2.   if 存在出度>入度的节点 then s = 该节点
  3.   else s = 任意节点
  4.
  5. 初始化栈 S = [s], 路径 P = []
  6. 初始化边访问标记 visited[e] = false ∀ e ∈ E
  7.
  8. while S 非空 do
  9.   v = S.top()
 10.   if 存在未访问出边 (v → u) then
 11.     标记 (v → u) 为已访问
 12.     S.push(u)
 13.   else
 14.     P.add(S.pop())
 15.
 16. return REVERSE(P)
```

---

## 附录 B：经典示例详解

### B.1 Konigsberg 七桥问题（1736 年）

**问题描述**:
- 4 块陆地（A, B, C, D）由 7 座桥连接
- 能否每座桥恰好走一次并回到起点？

**图模型**:
- 节点: A, B, C, D（4 个）
- 边: 7 座桥（7 条）
- 度数: deg(A)=3, deg(B)=3, deg(C)=3, deg(D)=3

**结论**: ❌ 不存在欧拉路径/回路
**原因**: 奇度节点数量 = 4 ≠ {0, 2}

**历史意义**: 欧拉论文开创了图论学科

### B.2 一笔画问题（儿童智力题）

**常见图形**:
- ✅ "日" 字：可以一笔画（2 个奇度节点）
- ✅ "田" 字：可以一笔画（4 个奇度节点？实际可以分解）
- ❌ "甲" 字：不可以（奇度节点 > 2）

**应用**: 本模块可程序化求解此类问题

---

## 附录 C：参考资料

### 算法文献

1. **Hierholzer, C.** (1873). *Über die Möglichkeit, einen Linienzug ohne Wiederholung und ohne Unterbrechung zu umfahren*. Mathematische Annalen.
2. **Fleury, M.** (1883). *Deux problèmes de géométrie de situation*. Journal de mathématiques élémentaires.
3. **Euler, L.** (1736). *Solutio problematis ad geometriam situs pertinentis*. Commentarii academiae scientiarum Petropolitanae.

### 在线资源

- Wikipedia: [Eulerian path](https://en.wikipedia.org/wiki/Eulerian_path)
- VisuAlgo: [Graph Traversal](https://visualgo.net/en/dfsbfs)
- CP-Algorithms: [Eulerian Path](https://cp-algorithms.com/graph/euler_path.html)

### 项目内部参考

- [Flow 模块设计](../docs/design/flow_design.md) - 独立类型模式参考
- [AGENTS.md](../../AGENTS.md) - 编码规范和陷阱速查
- [MEMORY.md](../../MEMORY.md) - 项目记忆和关键决策

---

**文档版本**: v1.0.0
**最后更新**: 2026-05-22
**作者**: mbtgraph-team (AI-assisted design)
**审核状态**: ✅ 待用户最终审批
