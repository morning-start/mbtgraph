# mbtgraph 问题记录 (BUG)

> **最后更新**: 2026-05-29
> **说明**: 本文档记录代码审查与开发过程中发现的问题、限制和待优化项，但不包含 `TODO.md` 中已规划的任务项。

---

## 一、算法实现问题

### 1. Louvain 模块度计算精度问题

- **问题描述**: `compute_modularity` 函数使用近似计算，通过遍历邻接表按 `labels[i] == labels[j]` 统计社区内边数贡献，未精确汇总社区内所有边权重的实际总和。在大规模异构图或权重分布不均的场景下，模块度值可能存在显著偏差。
- **影响**: 社区划分质量评估不准确，可能影响多轮迭代后的收敛行为。
- **位置**: [louvain.mbt:L279-302](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\algo\community\louvain.mbt#L279-L302)
- **优先级**: 🟡 P2
- **建议**: 改用社区聚合矩阵（将同社区节点合并为超节点）精确计算模块度，遵循原始 Louvain 论文中 Phase 2 的社区聚合步骤。

---

## 二、数据结构实现问题

### 1. CSC 存储 `neighbors()` 方法性能隐患

- **问题描述**: [csc.mbt:L158-185](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\storage\csc.mbt#L158-L185) 的 `neighbors()` 实现通过外层 `for i in 0..<n` 遍历所有节点，内层扫描列指针范围查找匹配行索引，时间复杂度 **O(V·E)**。对于大图（V > 10K），该实现将导致严重的性能退化。
- **对比**: `neighbors_with_weight()`（第 188 行起）继承了相同的双重循环模式，同样存在该问题。
- **根因**: CSC 列指针结构天然不适合出边查询——CSC 按列（入边）组织，`neighbors()` 需出边遍历。该实现试图在错误的数据结构上模拟出边查询。
- **影响**: 所有基于 `GraphReadable` 泛型的算法在 `CSCGraph` 上运行时，`neighbors()` 和 `neighbors_with_weight()` 的性能退化到 O(V·E)。
- **位置**: [csc.mbt:L158-202](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\storage\csc.mbt#L158-L202)
- **优先级**: 🔴 P0 —— 核心性能缺陷
- **建议**:
  - **方案 A**: `neighbors()` 返回空 Iter（CSC 不支持高效出边），调用方在 `neighbors()` 不可用时回退到其他存储。
  - **方案 B**: (推荐) 在 CSC 构建时额外维护出边索引（类 CSR 的行指针结构），实现 O(deg) 出边查询。
  - **方案 C**: 文档明确标注 `CSCGraph` 的出边查询复杂度为 O(V·E)，仅供入边密集型场景使用。

### 2. WASM GC 目标栈空间限制

- **问题描述**: MoonBit 测试运行在 WASM GC 目标上，其栈空间约 1-2MB，无法处理 10000 节点以上的图结构。10000 节点路径图（~9999 边）的构建与算法执行可正常通过，但链式图（k≥3，~30000 条边）或 Erdos-Renyi 随机图（edge_prob≥0.005，~500K 边）均导致栈溢出。
- **测试数据**:
  - ✅ 10000 节点路径图（k=1, ~10K 边）：正常
  - ❌ 10000 节点链式图（k=3, ~30K 边）：栈溢出
  - ❌ 1000 节点 Erdos-Renyi 图（p=0.05, ~50K 边）：栈溢出
  - ❌ 10000 节点 Erdos-Renyi 图（p=0.01, ~1M 边候选）：栈溢出
- **根因**: WASM GC 的线性内存模型在频繁分配/回收大数组时容易耗尽栈空间，且不具备自动栈扩展能力。
- **影响**: 超过 30K 边的图在 WASM GC 测试目标上不可用，需使用 native 目标或减少图规模。
- **绕过方案**: 使用路径图（k=1）替代链式图/随机图用于基准测试；或安装 C 编译器后使用 `moon test --target native` 运行。
- **优先级**: 🟢 P3
- **建议**: MoonBit 未来版本可能提供更大的 WASM 栈空间配置选项，届时更新测试配置。

### 3. CSC `neighbors_with_weight()` 与 `neighbors()` 实现不一致

- **问题描述**: [csc.mbt:L188-202](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\storage\csc.mbt#L188-L202) `neighbors_with_weight()` 的实现逻辑与 `neighbors()` 不同，它调用 `get_edge()` 获取出边权重而非直接索引存储，引入了额外 O(deg) 查找。
- **影响**: 即使重构出边查询，权重版本和非权重版本的查询路径也不一致，增加维护难度。
- **位置**: [csc.mbt:L158-202](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\storage\csc.mbt#L158-L202)
- **优先级**: 🟡 P2
- **建议**: 统一出边查询的内部实现路径，确保 `neighbors()` 和 `neighbors_with_weight()` 共享相同的索引逻辑。

---

## 三、Trait 接口设计问题

### 1. `GraphReadable` 缺少有向图入边权重查询方法

- **问题描述**: 当前 `GraphReadable` 的 `neighbors()` 和 `neighbors_with_weight()` 仅支持出边查询。对于有向图的入边权重查询，算法仍需要组合使用 `neighbors()` + `get_edge()`，无法高效地一次性获取入边节点及权重。
- **影响**: 双向 Dijkstra 的反向搜索、Kosaraju SCC 的反向图遍历等场景无法享受 `neighbors_with_weight()` 的优化收益。
- **位置**: [traits.mbt](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\core\traits.mbt)
- **优先级**: 🟡 P1
- **建议**: 在 `GraphDirected` trait 中扩展 `in_neighbors_with_weight()` 方法，为有向图存储提供统一的入边权重查询接口。

### 2. 无权图算法未统一到 `neighbors_with_weight()` 接口

- **问题描述**: BFS、DFS 等无权图算法仍使用 `neighbors()` 方法，未来若 `neighbors_with_weight()` 成为主要接口，这些算法将成为遗留代码。
- **受影响算法**:
  - BFS: [bfs.mbt:L41](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\algo\traversal\bfs.mbt#L41) 和 [bfs.mbt:L92](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\algo\traversal\bfs.mbt#L92)
  - DFS: [dfs.mbt:L43](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\algo\traversal\dfs.mbt#L43) 和 [dfs.mbt:L110](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\algo\traversal\dfs.mbt#L110)
  - 其他遍历类算法（如环检测、拓扑排序、双向 BFS）均未适配
- **优先级**: 🟢 P3
- **建议**: 在 API 冻结前统一将所有 `neighbors()` 调用替换为 `neighbors_with_weight()`，对不需要权重的调用方直接丢弃权重值。

---

## 四、具体算法实现限制

### 1. 双向 Dijkstra 反向搜索有向图语义问题

- **问题描述**: [bidirectional_dijkstra.mbt:L141-162](file:///e:\Workplace\APP\MoonBit\mbtgraph\lib\algo\shortest_path\bidirectional_dijkstra.mbt#L141-L162) 的反向搜索使用 `neighbors()` + `get_edge()` 组合获取入边权重。对于有向图，`neighbors()` 返回的是出边节点，反向搜索期望的是入边节点，导致语义错误——反向搜索实际仍遍历出边，仅通过 `get_edge(u, v)` 从反向获取权重。
- **影响**: 双向 Dijkstra 在有向图上的反向搜索路径探索方向错误：反向搜索本应沿入边方向（即原始图的反向边）扩展，但实际沿出边方向扩展并通过 `get_edge(u, v)` 获取权重（`u` 是出边邻居，`v` 是当前节点）。当原始图不存在 `u→v` 边时 `get_edge` 返回 `None`，边被跳过，导致搜索空间受限，可能错过最优路径。
- **严重性**: 🚨 逻辑错误 —— 可能导致有向图最短路径结果不正确
- **优先级**: 🟡 P1 —— 需与 `in_neighbors_with_weight()` 一起修复
- **前置条件**: 需先扩展 `GraphDirected` trait，新增 `in_neighbors_with_weight()` 方法，使所有有向图存储支持高效入边权重查询。

---

## 五、代码质量与可维护性问题

### 1. 路径重建代码碎片化

- **问题描述**: 最短路径模块中（Dijkstra、Bellman-Ford、SPFA、A*、双向 Dijkstra、Johnson、Yen），路径重建逻辑被多次重复实现，未抽取为公共辅助函数。各算法的重建逻辑存在细微差异（如双向 Dijkstra 需拼接正向和反向路径），但核心逻辑（从 parent 数组回溯）高度相似。
- **影响**: 增加维护成本，路径重建中的边界条件修正需要同步到所有文件。
- **优先级**: 🟢 P3
- **建议**: 在 `shared_helpers.mbt` 中抽取 `reconstruct_path(parents, target) -> Option[Array[NodeId]]` 辅助函数。

### 2. `moon test` 缺少自动化测试超时机制

- **问题描述**: 当前测试套件（736 测试）中没有单个测试的超时保护。若某个算法在极端输入下进入死循环或退化到 O(2^n) 复杂度，测试进程将被永久阻塞，无法自动终止。
- **影响**: CI 流水线可能被单个测试阻塞数小时。
- **优先级**: 🟢 P3
- **建议**: 探索 MoonBit 测试框架的 timeout 能力，或在测试中内置超时检测逻辑。

---

## 附录

### 优先级定义

| 级别 | 含义 | 预期响应 |
|:----:|------|---------|
| 🔴 P0 | 严重缺陷，影响核心功能或性能 | 应当前版本修复 |
| 🟡 P1 | 功能受限或存在逻辑隐患 | 建议当前或下个版本修复 |
| 🟡 P2 | 功能偏差或性能次优 | 规划修复时间 |
| 🟢 P3 | 代码质量或维护性改进 | 可延后处理 |