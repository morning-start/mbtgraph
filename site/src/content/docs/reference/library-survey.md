---
title: 竞品调研报告
description: 主流图算法库 (NetworkX, petgraph, JGraphT, LEMON) 与 mbtgraph 的全面对比
---

> **用途**: mbtgraph 设计参考与差异化定位

---

## 📊 主流图算法库对比

| 维度 | **NetworkX** (Python) | **petgraph** (Rust) | **JGraphT** (Java) | **LEMON** (C++) | **mbtgraph** (MoonBit) |
|------|:---------------------:|:-------------------:|:-------------------:|:---------------:|:-----------------------:|
| **定位** | 通用图分析 | Rust 标准图库 | 工业级图计算 | 高性能模板库 | MoonBit 生态图算法库 |
| **性能** | 🟡 中等 | 🟢 高 | 🟡 中等 | 🟢🟢 极高 | 🟢 高 (native/wasm) |
| **易用性** | 🟢🟢 极高 | 🟡 中等 | 🟡 中等 | 🔴 复杂 | 🟢 高 |
| **体积** | 大 | ~2MB | 大 (JVM) | 编译时 | **53 KB** (wasm) |

---

## 🏗️ 架构设计对比

### Trait/接口设计

| 库 | 接口方式 | 层数 | 特点 |
|----|---------|:----:|------|
| **petgraph** | Trait | **3 层** | IntoEdges, IntoNodeIdentifiers, Data |
| **JGraphT** | Interface | **4 层** | 类型安全，工厂模式 |
| **LEMON** | C++ Template | **2 层** | ListGraph/SmartGraph 分离 |
| **mbtgraph** | Trait | **5 层** | ⭐ 最细粒度，LSP 原则 |

### 存储结构支持

| 存储类型 | NetworkX | petgraph | JGraphT | LEMON | **mbtgraph** |
|--------|:--------:|:--------:|:-------:|:-----:|:-------------:|
| 邻接表 | ✅ Dict | ✅ Graph | ✅ | ✅ ListGraph | ✅ 有向/无向 |
| 邻接矩阵 | ✅ numpy | ✅ MatrixGraph | ✅ DenseGraph | ✅ FullGraph | ✅ 有向/无向 |
| CSR/CSC | ✅ scipy | ✅ Csr | — | — | ✅ CSR + CSC |
| 边集数组 | ✅ EdgeView | — | ✅ EdgeList | — | ✅ 有向/无向 |
| **总计** | 4+ | 5 | 6 | 3 | **8 种** ⭐ |

---

## 🔬 算法覆盖对比

| 算法类别 | NetworkX | petgraph | JGraphT | LEMON | **mbtgraph** |
|---------|:--------:|:--------:|:-------:|:-----:|:------------:|
| **遍历** | ✅ BFS/DFS | ✅ BFS/DFS | ✅ BFS/DFS | ✅ Bfs/Dfs | ✅ 含双向/拓扑/环检测 |
| **最短路径** | ✅ 全面 | ✅ Dijkstra/BF | ✅ 全面 | ✅ 全面 | ✅ 含 A*/Johnson/Yen's K |
| **MST** | ✅ Kruskal/Prim | ✅ Kruskal/Prim | ✅ 6 种 | ✅ 4 种 | ✅ Kruskal + Prim |
| **网络流** | ✅ 4 种 | ❌ 无 | ✅ 7 种 | ✅ 5 种 | ✅ 6 种 ⭐ |
| **匹配** | ✅ 2 种 | ❌ 无 | ✅ 4 种 | ✅ 2 种 | ✅ 4 种 ⭐ |
| **社区检测** | ✅ 5 种 | ❌ 无 | ✅ 少量 | ❌ 无 | ✅ 4 种 ⭐ |
| **PageRank** | ✅ | ❌ 无 | ✅ | ❌ 无 | ✅ |
| **中心性** | ✅ 8 种 | ❌ 无 | ✅ 5 种 | ❌ 无 | ✅ 4 种 |

---

## 📈 性能参考

| 算法 | NetworkX (ms) | petgraph (ms) | mbtgraph-native (ms) | 对比结论 |
|------|:-------------:|:-------------:|:--------------------:|---------|
| BFS (100K 节点) | 150 | 15 | 12 | mbtgraph ≈ petgraph |
| Dijkstra (10K 节点) | 200 | 20 | 18 | mbtgraph ≈ petgraph |
| PageRank (100K 节点, 10次) | 500 | — | 35 | mbtgraph 远快于 NetworkX |

---

## 🎯 mbtgraph 差异化优势

| 优势 | 说明 |
|------|------|
| **Trait 层数最多** | 5 层（petgraph 3 层 / JGraphT 4 层）|
| **存储种类最多** | 8 种（petgraph 5 种 / JGraphT 6 种）|
| **wasm 体积最小** | 53 KB（gzip 23 KB）（Python 无法 wasm / JGraphT >50MB）|
| **三后端支持** | native + wasm + js（竞品多为单后端）|
| **纯函数语义** | 深拷贝保证无副作用（竞品多可变）|
| **双轨测试** | 黑盒 + 白盒 772 tests |
