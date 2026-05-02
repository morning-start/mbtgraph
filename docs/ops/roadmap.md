---
title: "mbtgraph 开发路线图 (ROADMAP)"
version: "0.1.0"
status: "draft"
type: "roadmap"
created: "2026-05-02"
updated: "2026-05-02"
author: "morning-start"
license: "Apache-2.0"
tags: ["roadmap", "planning", "graph", "algorithm", "strategy"]
traceability:
  source:
    - "docs/requirements/srs.md"
    - "docs/design/sad.md"
    - "docs/architecture/project_structure_design.md"
  targets:
    - "docs/ops/todo.md"
    - "README.mbt.md"
---

# mbtgraph 开发路线图 (ROADMAP)

> **版本**: v0.1.0 | **状态**: 草稿 | **日期**: 2026-05-02

---

## 📊 总览

本路线图定义了 mbtgraph 从项目初始化到生产就绪的完整开发路径，包含 **5 个主要阶段**，覆盖从核心基础到生态完善的全生命周期。

```mermaid
gantt
    title mbtgraph 开发路线图
    dateFormat  v0.1.0
    axisFormat  v%s
    
    section Phase 1: MVP
    核心图结构     :done, p1-core, 0, 2w
    遍历算法       :done, p1-traverse, 1w, 1w
    最短路径       :active, p1-sp, 2w, 1w
    连通性分析     : p1-conn, 3w, 1w
    
    section Phase 2: 网络分析
    中心性算法     : p2-centrality, 4w, 2w
    社区检测       : p2-community, 4w, 2w
    最小生成树     : p2-mst, 4w, 1w
    图生成器       : p2-gen, 5w, 1w
    
    section Phase 3: 高级算法
    流网络         : p3-flow, 6w, 2w
    匹配算法       : p3-matching, 6w, 2w
    同构检测       : p3-iso, 6w, 2w
    图着色         : p3-color, 6w, 2w
    回路游历       : p3-tour, 6w, 2w
    
    section Phase 4: 生态完善
    I/O 工具       : p4-io, 8w, 2w
    布局算法       : p4-layout, 8w, 2w
    文档完善       : p4-docs, 8w, 2w
    发布准备       : p4-release, 10w, 2w
    
    section Phase 5: 生产就绪
    API 稳定       : p5-api, 12w, 2w
    性能优化       : p5-perf, 12w, 2w
    全覆盖测试     : p5-test, 12w, 2w
```

---

## 🏗️ Phase 1: MVP 基础阶段

**目标**: 最小可用图算法库，验证核心架构

**版本**: v0.1.0 → v0.1.3

### 1.1 核心图结构

**优先级**: 🔴 最高

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `core/types.mbt` | 基础类型定义 (NodeId, EdgeId, EdgeKey) | 类型正确定义 | ⏳ |
| `core/traits.mbt` | Graph Trait (最小接口) | 编译通过 | ⏳ |
| `core/directed.mbt` | 有向图实现 (邻接表 + HashMap) | 可创建、添加、删除、查询 | ⏳ |
| `core/undirected.mbt` | 无向图实现 (邻接表 + HashSet) | 边对称性、无重复 | ⏳ |
| `core/weighted.mbt` | 加权图扩展 Trait | 支持权重读写 | ⏳ |
| `core/multigraph.mbt` | 多重图支持 (可延后) | 允许平行边 | 📋 |

### 1.2 遍历算法

**优先级**: 🔴 最高

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `algo/traverse/bfs.mbt` | BFS 广度优先搜索 | 顺序正确，距离正确 | ⏳ |
| `algo/traverse/dfs.mbt` | DFS 深度优先搜索 | 顺序正确，时间戳正确 | ⏳ |

### 1.3 最短路径

**优先级**: 🟠 高

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `algo/shortest_path/dijkstra.mbt` | Dijkstra 算法 (二叉堆) | 最短路径正确，支持提前终止 | ⏳ |
| `algo/shortest_path/bellman_ford.mbt` | Bellman-Ford 算法 | 支持负权，检测负权环 | ⏳ |
| `internal/priority_queue.mbt` | 优先队列 (二叉堆) | 支持 insert/extract_min/decrease_key | ⏳ |

### 1.4 连通性分析

**优先级**: 🟠 高

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `algo/connectivity/scc.mbt` | Kosaraju 强连通分量 | SCC 划分正确 | ⏳ |
| `algo/connectivity/toposort.mbt` | 拓扑排序 | 序列满足拓扑序 | ⏳ |
| `internal/union_find.mbt` | 并查集 (路径压缩 + 按秩合并) | 查询效率接近 O(1) | ⏳ |

### Phase 1 里程碑

```
v0.1.0 → 核心类型 + Trait + 有向图/无向图
v0.1.1 → BFS + DFS + Dijkstra
v0.1.2 → Bellman-Ford + Kosaraju SCC
v0.1.3 → 拓扑排序 + 并查集 + 测试覆盖 80%
```

---

## 🧠 Phase 2: 网络分析增强

**目标**: 构建差异化优势（社区检测 + 中心性）

**版本**: v0.2.0 → v0.2.3

### 2.1 中心性算法

**优先级**: 🟡 中

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `analysis/centrality/pagerank.mbt` | PageRank 迭代算法 | 与 NetworkX 一致 (误差 < 1e-5) | 📋 |
| `analysis/centrality/betweenness.mbt` | 介数中心性 | Brandes 算法 | 📋 |
| `analysis/centrality/closeness.mbt` | 紧密中心性 | 处理不连通图 | 📋 |
| `analysis/centrality/degree.mbt` | 度中心性 | 入度/出度 | 📋 |
| `analysis/centrality/hits.mbt` | HITS (Hub-Authority) | 收敛稳定 | 📋 |
| `analysis/centrality/harmonic.mbt` | 调和中心性 | 处理无穷距离 | 📋 |

### 2.2 社区检测 ⭐ (核心竞争力!)

**优先级**: 🟠 高 (差异化!)

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `analysis/community/louvain.mbt` | Louvain 算法 | 模块度 > 0.3 (Karate Club) | 📋 |
| `analysis/community/leiden.mbt` | Leiden 算法 | 比 Louvain 更稳定 | 📋 |
| `analysis/community/label_propagation.mbt` | 标签传播 (LPA) | 快速近似 | 📋 |
| `analysis/community/metrics.mbt` | 模块度计算 | 支持多种指标 | 📋 |

### 2.3 最小生成树

**优先级**: 🟡 中

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `algo/spanning_tree/kruskal.mbt` | Kruskal 算法 | MST 总权重正确 | 📋 |
| `algo/spanning_tree/prim.mbt` | Prim 算法 | 与 Kruskal 结果一致 | 📋 |

### 2.4 图生成器

**优先级**: 🟢 低

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `utils/generators/classic.mbt` | 经典图 (Kn, Cn, Sn, Petersen) | 节点/边数正确 | 📋 |
| `utils/generators/random_graphs.mbt` | 随机图 (ER, BA, WS) | 统计特性符合预期 | 📋 |

### Phase 2 里程碑

```
v0.2.0 → PageRank + 度中心性
v0.2.1 → Louvain + Leiden 社区检测
v0.2.2 → Kruskal/Prim MST + 图生成器
v0.2.3 → Betweenness/Closeness/HITS + 测试覆盖 85%
```

---

## 🚀 Phase 3: 高级算法补全

**目标**: 覆盖完整图论算法谱系

**版本**: v0.3.0 → v0.3.5

### 3.1 流网络

**优先级**: 🟡 中

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `flow/max_flow/dinic.mbt` | Dinic 分层图算法 | 最大流 = 最小割 | 📋 |
| `flow/max_flow/edmonds_karp.mbt` | Edmonds-Karp | BFS 增广路 | 📋 |
| `flow/max_flow/ford_fulkerson.mbt` | Ford-Fulkerson 方法 | 基础实现 | 📋 |
| `flow/max_flow/push_relabel.mbt` | Push-Relabel 算法 | 高性能实现 | 📋 |
| `flow/min_cost_flow/successive_shortest.mbt` | 连续最短增广路 | 最小费用流 | 📋 |
| `flow/cut/stoer_wagner.mbt` | Stoer-Wagner 全局最小割 | 割容量正确 | 📋 |

### 3.2 匹配算法

**优先级**: 🟡 中

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `matching/greedy.mbt` | 贪心匹配 (近似) | O(E) 时间复杂度 | 📋 |
| `matching/maximum_cardinality.mbt` | 最大基数匹配 (Blossom) | 精确最优 | 📋 |
| `matching/bipartite.mbt` | 二分图匹配 (匈牙利算法) | 特化优化 | 📋 |

### 3.3 同构检测

**优先级**: 🟢 低

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `isomorphism/vf2.mbt` | VF2 子图同构 | 精确匹配 | 📋 |
| `isomorphism/color_refinement.mbt` | 颜色细化 (快速近似) | 快速判定 | 📋 |

### 3.4 图着色

**优先级**: 🟢 低

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `coloring/greedy.mbt` | 贪心着色 (DSATUR) | 颜色数接近最优 | 📋 |
| `coloring/exact.mbt` | 精确最优着色 (回溯) | 小规模图最优 | 📋 |

### 3.5 回路与游历

**优先级**: 🟢 低

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `tour/eulerian.mbt` | 欧拉回路 (Hierholzer) | 正确识别并构造 | 📋 |
| `tour/hamiltonian.mbt` | 哈密顿回路 (NP-hard 近似) | 近似启发式 | 📋 |
| `tour/tsp/nearest_neighbor.mbt` | TSP 最近邻启发式 | 近似解 | 📋 |
| `tour/tsp/christofides.mbt` | TSP Christofides 1.5-近似 | 近似比达标 | 📋 |

### Phase 3 里程碑

```
v0.3.0 → Dinic + Edmonds-Karp 最大流
v0.3.1 → Blossom 最大基数匹配
v0.3.2 → VF2 子图同构
v0.3.3 → DSATUR 图着色
v0.3.4 → TSP + 欧拉回路
v0.3.5 → 测试覆盖 85%
```

---

## 🌐 Phase 4: 生态完善

**目标**: 工具链完善，准备发布

**版本**: v0.4.0

### 4.1 I/O 工具

**优先级**: 🟡 中

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `utils/io/dot.mbt` | Graphviz DOT 格式读写 | 正确导入/导出 | 📋 |
| `utils/io/json.mbt` | JSON 格式 | 序列化/反序列化 | 📋 |
| `utils/io/csv.mbt` | CSV 边列表格式 | 简单高效 | 📋 |
| `utils/io/graphml.mbt` | GraphML 格式 (可选) | 标准格式支持 | 📋 |

### 4.2 布局算法

**优先级**: 🟢 低

| 模块 | 任务 | 验收标准 | 状态 |
|------|------|----------|------|
| `utils/layout/force_directed.mbt` | 力导向布局 (Fruchterman-Reingold) | 坐标输出合理 | 📋 |
| `utils/layout/circular.mbt` | 环形布局 | 均匀分布 | 📋 |
| `utils/layout/hierarchical.mbt` | 层次布局 (Sugiyama) | 分层清晰 | 📋 |

### 4.3 文档完善

**优先级**: 🟡 中

| 任务 | 验收标准 | 状态 |
|------|----------|------|
| 所有公开 API 文档注释 | 100% 覆盖 | 📋 |
| 教程文档 (tutorials/) | 5+ 个入门教程 | 📋 |
| 示例代码 (cmd/examples/) | 每个算法一个示例 | 📋 |

### 4.4 发布准备

**优先级**: 🟡 中

| 任务 | 验收标准 | 状态 |
|------|----------|------|
| mooncakes.io 发布配置 | 可被外部依赖 | 📋 |
| CI/CD 配置 (GitHub Actions) | 自动测试 | 📋 |
| CHANGELOG.md | 完整版本历史 | 📋 |

### Phase 4 里程碑

```
v0.4.0 → I/O 工具 + 布局算法 + 完整文档 + mooncakes 发布
```

---

## 🏆 Phase 5: 生产就绪

**目标**: API 稳定，性能达标，可投入生产

**版本**: v1.0.0

### 5.1 API 稳定

| 任务 | 验收标准 | 状态 |
|------|----------|------|
| 冻结公开 API | 无破坏性变更 | 📋 |
| 语义化版本 | 遵循 SemVer | 📋 |
| 向后兼容 | 旧代码无需修改 | 📋 |

### 5.2 性能优化

| 任务 | 目标 | 状态 |
|------|------|------|
| BFS 100K 节点 | < 50ms (native) | 📋 |
| Dijkstra 100K 节点 | < 200ms (native) | 📋 |
| PageRank 100K 节点 | < 1s (native) | 📋 |
| Louvain 100K 节点 | < 5s (native) | 📋 |
| 内存优化 | 100K 节点 < 100MB | 📋 |

### 5.3 测试覆盖

| 任务 | 目标 | 状态 |
|------|------|------|
| 核心模块 | ≥ 90% 覆盖率 | 📋 |
| 算法模块 | ≥ 85% 覆盖率 | 📋 |
| 集成测试 | ≥ 70% 覆盖率 | 📋 |
| 多后端测试 | wasm/js/native 全部通过 | 📋 |

### Phase 5 里程碑

```
v1.0.0 → API 稳定 + 全覆盖测试 + 性能达标 + 生产就绪
```

---

## 📈 版本规划总览

| 版本 | 时间范围 | 重点 | 关键交付物 |
|------|---------|------|-----------|
| **v0.1.x** | 当前 | 核心基础 | 图结构 + BFS/DFS + Dijkstra + SCC |
| **v0.2.x** | 中期 | 网络分析 | PageRank + Louvain/Leiden + MST + 生成器 |
| **v0.3.x** | 中后期 | 高级算法 | MaxFlow + Matching + Isomorphism + Coloring + TSP |
| **v0.4.x** | 后期 | 生态完善 | I/O + Layout + 文档 + 发布 mooncakes |
| **v1.0.0** | 远期 | 生产就绪 | API 稳定 + 全覆盖测试 + 性能达标 |

---

## 🎯 关键里程碑

| 里程碑 | 版本 | 说明 |
|--------|------|------|
| **MVP** | v0.1.3 | 最小可用库，可执行基本图操作和算法 |
| **网络分析就绪** | v0.2.3 | 支持 PageRank + 社区检测，具备差异化优势 |
| **全算法覆盖** | v0.3.5 | 覆盖经典图论所有核心算法 |
| **生态成熟** | v0.4.0 | 工具链完善，可发布到 mooncakes.io |
| **生产发布** | v1.0.0 | API 稳定，性能达标，可用于生产环境 |

---

## 🔄 风险与应对

| 风险 | 影响 | 概率 | 应对策略 |
|------|------|------|----------|
| MoonBit 语言特性不足 | 高 | 中 | 提前调研，必要时调整设计 |
| 复杂算法实现难度超预期 | 中 | 高 | 先实现简化版，后续优化 |
| 性能目标难以达成 | 中 | 中 | 早期性能测试，及时调整数据结构 |
| 社区检测算法收敛性不稳定 | 低 | 中 | 多次运行取最优，增加随机种子控制 |

---

## 📚 参考文档

- [软件需求规格](docs/requirements/srs.md)
- [系统架构设计](docs/design/sad.md)
- [架构详细设计](docs/architecture/project_structure_design.md)
- [测试策略](docs/quality/test_strategy.md)

---

**文档状态**: 草稿 ⏳  
**最后更新**: 2026-05-02  
**下次更新**: 当 Phase 启动或完成时
