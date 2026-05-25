# 图算法库竞品调研汇总

> **最后更新**: 2026-05-25 | **用途**: mbtgraph 设计参考与差异化定位

---

## 📊 主流图算法库对比

| 维度 | **NetworkX** (Python) | **petgraph** (Rust) | **JGraphT** (Java) | **LEMON** (C++) | **mbtgraph** (MoonBit) |
|------|:---------------------:|:-------------------:|:-------------------:|:---------------:|:-----------------------:|
| **语言** | Python | Rust | Java | C++ | MoonBit |
| **定位** | 通用图分析 | Rust 标准图库 | 工业级图计算 | 高性能模板库 | MoonBit 生态图算法库 |
| **Stars** | 13k+ | 2k+ | 1k+ | — | — |
| **协议** | BSD-3-Clause | MIT/Apache-2.0 | LGPL/EPL | Boost | MIT |
| **性能** | 🟡 中等 | 🟢 高 | 🟡 中等 | 🟢🟢 极高 | 🟢 高 (native/wasm) |
| **易用性** | 🟢🟢 极高 | 🟡 中等 | 🟡 中等 | 🔴 复杂 | 🟢 高 |
| **体积** | 大 (依赖 NumPy) | 小 (~2MB) | 大 (JVM) | 编译时 | **< 1MB** (wasm) |

---

## 🏗️ 架构设计对比

### Trait/接口设计

| 库 | 接口方式 | 层数 | 特点 |
|----|---------|:----:|------|
| **petgraph** | Trait (GraphBase, etc.) | **3 层** | IntoEdges, IntoNodeIdentifiers, Data 等 |
| **JGraphT** | Interface (Graph, Graph<V,E>) | **4 层** | 类型安全，工厂模式 |
| **LEMON** | C++ Template | **2 层** | ListGraph/SmartGraph, 概念分离 |
| **mbtgraph** | Trait (GraphReadable → ...) | **6 层** | 最细粒度，LSP 原则 |

### 存储结构支持

| 存储类型 | NetworkX | petgraph | JGraphT | LEMON | **mbtgraph** |
|--------|:--------:|:--------:|:-------:|:-----:|:-------------:|
| 邻接表 | ✅ Dict-based | ✅ Graph | ✅ Default*Graph | ✅ ListGraph | ✅ AdjList (有向/无向) |
| 邻接矩阵 | ✅ numpy array | ✅ MatrixGraph | ✅ DenseGraph | ✅ FullGraph | ✅ Matrix (有向/无向) |
| CSR/CSC | ✅ scipy.sparse | ✅ Csr | — | — | ✅ CSR + CSC |
| 边集数组 | ✅ EdgeView | — | ✅ *EdgeListGraph | — | ✅ EdgeList (有向/无向) |
| **总计** | 4+ | 5 | 6 | 3 | **8 种** |

---

## 🔬 算法覆盖对比

### 已实现的核心算法

| 算法类别 | NetworkX | petgraph | JGraphT | LEMON | **mbtgraph** |
|---------|:--------:|:--------:|:-------:|:-----:|:------------:|
| **遍历** | BFS/DFS | BFS/DFS | BFS/DFS | Bfs/Dfs | ✅ BFS/DFS |
| **最短路径** | Dijkstra/BF/FW/A*/Johnson | Dijkstra/BF/FW/A* | Dijkstra/BF/FW/A* | Dijkstra/BF | ✅ Dijkstra/BF/FW |
| **MST** | Kruskal/Prim | Kruskal/Prim | Kruskal/Prim | Kruskal/Prim | ✅ Kruskal/Prim |
| **连通性** | CC/Tarjan/Kosaraju | Kosaraju/Tarjan | Tarjan/Kosaraju | — | ✅ CC/Tarjan/Kosaraju |
| **网络流** | EK/Dinic/PushRelabel | — | PushRelabel | — | ✅ EK/Dinic |
| **匹配** | MaxWeight/MaxCard | — | General/HopcroftKarp | — | ✅ Hungarian |
| **中心性** | 10+ 指标 | PageRank only | Betweenness/Closeness | — | ⏳ v0.10.0 规划中 |
| **社区检测** | Louvain/GN/LP/Leiden | — | — | — | ⏳ v0.10.0 规划中 |
| **图着色** | Greedy/DSATUR/ASP | — | — | — | ✅ Greedy/WP/DSATUR/Exact |
| **欧拉路径** | eulerian_path | — | HierholzerEulerian | — | ✅ Hierholzer |
| **割点/桥** | articulation_points | — | BiconnectivityInspector | — | ✅ Tarjan DFN/Low |
| **团检测** | find_cliques | — | BronKerbosch | — | ✅ Bron-Kerbosch |
| **哈密顿/TSP** | — | TravelingSalesman | — | HeldKarp | ✅ Backtrack+NN+HK |

### 算法数量统计

| 库 | 经典图论 | 网络分析 | 高级/NP-Hard | **总计** |
|----|:--------:|:--------:|:-----------:|:--------:|
| NetworkX | ~50 | ~30 | ~20 | **~100+** |
| petgraph | ~15 | ~3 | ~2 | **~20** |
| JGraphT | ~40 | ~15 | ~8 | **~63** |
| LEMON | ~25 | — | — | **~25** |
| **mbtgraph** | **30+** | **0** (规划中) | **12** | **42+ (v0.9.0)** |

---

## 💡 关键设计决策参考

### 从 NetworkX 学到的经验

1. **模块化组织**: `algorithms.shortest_paths` 等子模块清晰
2. **多种图类型**: Graph/DiGraph/MultiGraph/MultiDiGraph
3. **属性图**: 节点和边可携带任意属性字典
4. **丰富的 I/O**: 支持 GML/GraphML/GEXF/Pajek/JSON 等 8+ 格式

### 从 petgraph 学到的经验

1. **Index-based 节点**: `NodeIndex<Ix>` 类型安全的索引
2. **Trait 分层**: `IntoEdges`, `IntoNodeIdentifiers`, `Data` 正交组合
3. **Feature flags**: 按需编译，减小二进制体积
4. **零成本抽象**: 泛型不带来运行时开销

### 从 JGraphT 学到的经验

1. **接口驱动**: 所有图类型实现统一接口
2. **工厂模式**: 图构建器封装复杂逻辑
3. **事件监听**: 算法进度可观测（如 TSP 下界）
4. **可视化集成**: JGraphT 适配器直接对接 JGraphX

### 从 LEMON 学到的经验

1. **概念分离**: 图结构 vs 算法完全解耦
2. **模板元编程**: 编译期多态，零开销
3. **内存管理**: 对象池、智能指针精细控制
4. **性能极致**: 竞赛级优化（如 Cost Scaling Push-Relabel）

---

## 🎯 mbtgraph 的差异化优势

| 优势维度 | 具体体现 | 来源借鉴 |
|---------|---------|---------|
| **🎯 MoonBit 原生** | 编译到 wasm/js/native 三目标 | — |
| **📦 超小体积** | wasm < 1MB，适合前端/嵌入场景 | petgraph Feature flags |
| **🔬 6 层 Trait** | 比 petgraph(3层)/JGraphT(4层) 更细粒度 | 全部竞品综合 |
| **💾 8 种存储** | 比所有竞品都多（含半存储优化） | 自研创新 |
| **⚡ 多后端** | native 性能 + wasm 浏览器 + js Node.js | — |
| **🧪 双轨测试** | 黑盒 + 白盒测试体系 | JGraphT 测试风格 |
| **📖 文档完善** | 每个模块 README + design doc | NetworkX 文档风格 |

---

## 📚 详细调研文档归档

> 以下为原始详细调研报告（已合并至本文档核心内容）：
>
> - [python-NetworkX.md](./python-NetworkX.md) (原始)
> - [rust-petgraph.md](./rust-petgraph.md) (原始)
> - [java-JGraphT.md](./java-JGraphT.md) (原始)
> - [cpp-Lemon.md](./cpp-Lemon.md) (原始)
> - [go-gonumgraph.md](./go-gonumgraph.md) (原始)
> - [python-igraph.md](./python-igraph.md) (原始)
> - [python-pyG.md](./python-pyG.md) (原始)

---

<div align="center">

**📌 本文档为 mbtgraph 设计提供竞品参考，定期更新**

*维护者: @morning-start | 创建: 2026-05-02 | 最后整理: 2026-05-25*

</div>
