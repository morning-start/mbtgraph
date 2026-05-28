# mbtgraph 📊

<p align="center">
  <strong>MoonBit 图算法库</strong> — 完整的图数据结构与算法实现
</p>

<p align="center">
  <a href="#-快速开始">快速开始</a> •
  <a href="#-特性">特性</a> •
  <a href="#-算法目录">算法</a> •
  <a href="#-架构">架构</a> •
  <a href="#-存储选型">存储</a> •
  <a href="#-贡献指南">贡献</a>
</p>

---

## 🚀 快速开始

### 安装

```bash
moon add morning-start/mbtgraph
```

### 五分钟上手：从创建图到运行算法

```moonbit
import { morning-start/mbtgraph/lib/core } @core
import { morning-start/mbtgraph/lib/storage } @storage
import { morning-start/mbtgraph/lib/algo/traversal } @traversal
import { morning-start/mbtgraph/lib/algo/shortest_path } @sp
import { morning-start/mbtgraph/lib/algo/mst } @mst
import { morning-start/mbtgraph/lib/algo/flow } @flow

// === 1. 创建有向邻接表（推荐默认选择）===
let g = @storage.new_directed()

// 添加节点和边
let n0 = @core.GraphWritable::add_node(g, 0.0)
let n1 = @core.GraphWritable::add_node(g, 1.0)
let n2 = @core.GraphWritable::add_node(g, 2.0)
let n3 = @core.GraphWritable::add_node(g, 3.0)
@core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
@core.GraphWritable::add_edge(g, n1, n2, 2.0) |> ignore
@core.GraphWritable::add_edge(g, n0, n2, 4.0) |> ignore
@core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore

// === 2. BFS 遍历（无权最短路径）===
let bfs_result = @traversal.bfs(g, n0)
bfs_result.distance(n3)              // => 2

// === 3. Dijkstra 最短路径（加权）===
let sp_result = @sp.dijkstra(g, n0)
sp_result.distance_to(n3)           // => 4.0

// === 4. 最大流（Dinic）===
let net = @flow.FlowNetwork::new(4)
let net = net.add_edge(0, 1, 16.0)
let net = net.add_edge(0, 2, 13.0)
let net = net.add_edge(1, 3, 12.0)
let net = net.add_edge(2, 3, 14.0)
let flow_result = @flow.dinic(net, 0, 3)
flow_result.max_flow               // => 23.0

// === 5. 拓扑排序（检测环）===
match @traversal.topo_sort_kahn(g) {
  Ok(schedule) => println("拓扑序: ${schedule}")
  Err(msg)     => println("存在循环依赖!")
}
```

更多示例见各模块目录下的 `*_test.mbt` 文件。

---

## ✨ 特性

- **5 层 Trait 分层** — GraphReadable → Writable → Directed → Full + BatchRead，接口隔离设计
- **8 种存储结构** — 有向/无向邻接表、邻接矩阵、边集数组、CSR/CSC，覆盖稀疏/稠密/动态/静态全场景
- **49+ 图算法** — 覆盖遍历、最短路径、MST、连通性、网络流、匹配、欧拉路径、着色、团检测、TSP、PageRank、中心性、社区检测等
- **I/O 序列化** — DOT 格式读写、JSON 序列化、图统计工具
- **纯函数语义** — 深拷贝隔离副作用，保证算法不可变性
- **736 测试用例** — Blackbox + Whitebox 双轨测试，跨存储一致性验证

---

## 📖 算法目录

| 分类 | 算法 | 模块路径 |
|------|------|---------|
| **图遍历** | BFS · DFS · 环检测 · 拓扑排序 · 双向BFS | `algo/traversal` |
| **最短路径** | Dijkstra · Bellman-Ford · Floyd-Warshall · A* · Johnson · SPFA · 双向Dijkstra · Yen's K短路 | `algo/shortest_path` |
| **最小生成树** | Kruskal (+UnionFind) · Prim | `algo/mst` |
| **连通性** | 连通分量 · Tarjan SCC · Kosaraju SCC · 双连通分量 BCC | `algo/connectivity` |
| **网络流** | Edmonds-Karp · Dinic · 最小费用最大流 | `algo/flow` |
| **图匹配** | Hungarian · Hopcroft-Karp · Edmonds Blossom | `algo/matching` |
| **欧拉路径** | Hierholzer (有向/无向) | `algo/euler` |
| **割点与桥** | Tarjan | `algo/cutpoints` |
| **图着色** | Greedy · Welsh-Powell · DSATUR · Exact · 边着色 | `algo/coloring` |
| **最大团** | Bron-Kerbosch | `algo/clique` |
| **哈密顿/TSP** | 回溯 · Nearest Neighbor · Held-Karp | `algo/hamiltonian` |
| **PageRank** | 幂法迭代 (dangling/damping/个性化) | `algo/pagerank` |
| **中心性分析** | 度/介数/接近/特征向量 | `algo/centrality` |
| **社区检测** | Louvain · 标签传播 | `algo/community` |
| **I/O 序列化** | DOT 格式 · JSON 格式 · 图统计 | `lib/io` |
| **图生成器** | 经典图/随机图/网格/二分图 (16 个生成函数) | `algo/generators` |

> 详细 API 文档请查看各模块源码及 [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## 🏛️ 架构

### Trait 分层体系

```
                    ┌─────────────────┐
                    │  GraphReadable   │  ← 所有存储必须实现 (12 方法)
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
    ┌─────────────┐  ┌──────────────┐  ┌────────────────┐
    │ GraphWritable│  │ GraphDirected│  │GraphBatchReadable│
    │ (可写 +5方法) │  │ (有向 +6方法) │  │ (批量优化 +2方法) │
    └──────┬───────┘  └──────┬───────┘  └────────────────┘
           │                 │
           └────────┬────────┘
                    ▼
          ┌─────────────────┐
          │   GraphFull     │  ← Writable + Directed 组合别名
          └─────────────────┘
```

完整架构设计文档: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## 💾 存储选型

| 场景 | 推荐存储 | Trait | 说明 |
|------|---------|:-----:|------|
| 通用稀疏图（有向） | `DirectedAdjList` ⭐ | Full | 默认推荐，邻居查询 O(k) |
| 通用无向图 | `UndirectedAdjList` ⭐ | Writable | 半存储优化，节省 ~50% |
| 小规模稠密图 (<1K 节点) | `DirectedMatrix` | Full | O(1) 边查询，O(V²) 空间 |
| MST / Kruskal | `UndirectedEdgeListGraph` | Writable | 边排序友好（内部排序） |
| 大规模静态图 (>10K 节点) | `CSRGraph` | Read+BatchRead | 缓存友好，通过 `to_csr()` 转换 |
| 入边密集查询 | `CSCGraph` | Read+BatchRead | in_degree O(1) |

### 时间复杂度一览

| 操作 | AdjList | Matrix | CSR | EdgeList |
|------|:-------:|:------:|:---:|:--------:|
| `add_node()` | O(1)* | O(1) | Builder | O(1)* |
| `add_edge()` | O(1) | O(1) | Builder | O(1) |
| `contains_edge()` | O(deg) | **O(1)** | O(deg_out) | O(E) |
| `neighbors()` | O(deg) | O(V) | O(deg_out) | O(E) |
| `memory` | O(V+E) | O(V²) | **O(V+E)** | O(V+E) |

\* 均摊复杂度

---

## 🔄 与竞品对比

### MoonBit 生态内

| 维度 | mgraph | graphviz | **mbtgraph** |
|------|:------:|:--------:|:------------:|
| 定位 | 轻量遍历库 | Graphviz 重写 | **完整算法库** |
| 算法数 | 2 | 0 | **49+** |
| 存储数 | 0 | 1 | **8** |
| Trait 层 | 1 | 0 | **5** |
| 测试数 | ~10 | fixture parity | **736** |

### 技术特性

| 特性 | mbtgraph |
|------|:---------:|
| 语言 | MoonBit (native / wasm / js 三后端) |
| 类型安全 | 编译期 trait 绑定检查 |
| 存储种类 | 8 种（覆盖全场景） |
| 纯函数语义 | 深拷贝隔离副作用 |

---

## 🧪 测试

```bash
moon test                          # 全量测试 (736 tests)
moon test lib/algo/flow            # 单模块测试
moon test lib/io                   # I/O 模块测试
moon check lib/algo/shortest_path  # 单模块编译检查
```

**测试策略**: Blackbox (`*_test.mbt`) + Whitebox (`*_wbtest.mbt`) 双轨制，含跨存储一致性验证与结果不可变性验证。

详细测试策略: [docs/quality/test_strategy.md](docs/quality/test_strategy.md)

---

## 📈 版本路线图

| 版本 | 重点内容 | 状态 |
|------|---------|:----:|
| v0.1.0 – v0.5.0 | 核心基础 + P0-P5 图论核心算法 (30+ 算法) | ✅ 完成 |
| v0.9.0 | 文档体系成熟 | ✅ 完成 |
| v0.10.0 | 社交网络分析套件 (PageRank / 中心性 / 社区检测) | ✅ 完成 |
| v0.11.0 | I/O 数据交换模块 (DOT / JSON / 图统计) | ✅ 完成 |
| v0.12.0 | 经典算法增强 (A* / 双向BFS / HK / 费用流 / Edmonds) | ✅ 完成 |
| v0.13.0 | 接口重构 + P0/P1 算法补齐 (Johnson/SPFA/BCC/双向Dij/Yen's) | ✅ **当前版本** |

完整变更记录: [CHANGELOG.md](CHANGELOG.md)

---

## 🤝 贡献指南

欢迎贡献！流程：

1. Fork 本仓库 → 创建分支 `git checkout -b feature/amazing-algo`
2. 遵循编码规范（详见 [`AGENTS.md`](AGENTS.md)，含 Top 10 陷阱速查）
3. 运行测试 `moon test` → 全量通过
4. 提交 `git commit -m 'feat(algo): add amazing algorithm'` → Push → PR

### 编码规范速查

| 规则 | ✅ 正确 | ❌ 错误 |
|------|---------|---------|
| 完全限定名 | `@core.NodeId(0)` | use 别名 |
| Impl 参数 | `(self)` | `mut self` |
| 泛型嵌套结尾 | `Array[Array[T?]]` | `Array[Array[T?>>` |
| For 循环 | 先绑定再 match | `for (a,b) in ...` |
| 方法链式赋值 | `let g = g.add_edge(...)` | 忽略返回值 |

---

## 📄 许可证

[MIT](LICENSE)

---

## 🙏 致谢

设计灵感来源: [NetworkX](https://networkx.org/) (Python), [petgraph](https://github.com/petgraph/petgraph) (Rust), [JGraphT](https://jgrapht.org/) (Java), [LEMON](https://lemon.cs.elte.hu/) (C++)

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给一个 Star！⭐**

Made with ❤️ using [MoonBit](https://www.moonbitlang.com/)

</div>
