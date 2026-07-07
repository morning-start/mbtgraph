<h1 align="center">mbtgraph</h1>

<p align="center">
  <strong>MoonBit 图算法库</strong> — 从创建图到运行 65+ 算法，一行代码搞定
</p>

<p align="center">
  <a href="https://github.com/morning-start/mbtgraph/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/morning-start/mbtgraph/ci.yml?branch=master&label=build" alt="build status"></a>
  <a href="https://github.com/morning-start/mbtgraph/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="license"></a>
  <img src="https://img.shields.io/badge/tests-772-green" alt="tests">
  <img src="https://img.shields.io/badge/algorithms-65%2B-brightgreen" alt="algorithms">
  <img src="https://img.shields.io/badge/MoonBit-0.1.20260608-purple" alt="moonbit">
</p>

<p align="center">
  <a href="#-快速开始">快速开始</a> •
  <a href="#-能做什么">功能</a> •
  <a href="#-和竞品比好在哪">对比</a> •
  <a href="#-不想选型直接抄">选型</a> •
  <a href="https://morning-start.github.io/mbtgraph/">文档站点</a>
</p>

---

> **你在 MoonBit 里要做图算法？** BFS 遍历、Dijkstra 最短路径、社区检测、网络流……如果每次都要自己从零实现，太浪费时间了。mbtgraph 让你一行代码拿到生产级结果。

---

## 🚀 快速开始

```bash
moon add morning-start/mbtgraph
```

安装后，还需要在使用这些 API 的目标包 `moon.pkg` 中（而非 `.mbt` 源文件中）添加依赖：

```moonbit
// 在 moon.pkg 中添加以下依赖：
import {
  "morning-start/mbtgraph/lib/core",
  "morning-start/mbtgraph/lib/storage",
  "morning-start/mbtgraph/lib/algo/traversal",
  "morning-start/mbtgraph/lib/algo/shortest_path",
}
```

然后在 `.mbt` 源文件中直接使用 `@core`、`@storage` 等别名，无需 `import` 语句：

```moonbit
// 1. 创建图 → 2. 跑算法 → 3. 拿结果
let g = @storage.new_directed()
let n0 = @core.GraphWritable::add_node(g, 0.0)
let n1 = @core.GraphWritable::add_node(g, 1.0)
let n2 = @core.GraphWritable::add_node(g, 2.0)
let n3 = @core.GraphWritable::add_node(g, 3.0)
@core.GraphWritable::add_edge(g, n0, n1, 1.0) |> ignore
@core.GraphWritable::add_edge(g, n1, n2, 2.0) |> ignore
@core.GraphWritable::add_edge(g, n0, n2, 4.0) |> ignore
@core.GraphWritable::add_edge(g, n2, n3, 1.0) |> ignore

// BFS 遍历
let bfs_result = @traversal.bfs(g, n0)
bfs_result.distance(n3)              // => 2

// Dijkstra 最短路径
let sp_result = @shortest_path.dijkstra(g, n0)
sp_result.distance_to(n3)           // => 4.0
```

> 更多完整示例见 [`*_test.mbt`](lib/algo/traversal/)或[文档站点 → 教程](https://morning-start.github.io/mbtgraph/getting-started/first-graph/)。

---

## 📌 能做什么

| 你在做什么                | 用 mbtgraph 怎么做          | 省了什么                   |
| ------------------------- | --------------------------- | -------------------------- |
| 社交网络分析 → 找关键人物 | `betweenness_centrality(g)` | 手写 Brandes 算法 50+ 行   |
| 路径规划 → 最短路径       | `dijkstra(g, src)`          | 手写堆优化 Dijkstra 80+ 行 |
| 推荐系统 → 社区发现       | `louvain(g, resolution)`    | 手写模块度优化 200+ 行     |
| 依赖分析 → 拓扑排序       | `topological_sort(g)`       | 手写 Kahn 算法 30+ 行      |
| 网络流 → 最大流量         | `dinic(net, s, t)`          | 手写 Dinic 150+ 行         |
| 图可视化 → 导出 DOT       | `write_dot(g, "graph.dot")` | 手写 DOT 序列化 40+ 行     |

**覆盖 18 个模块 · 65+ 算法 · 8 种存储结构 —— 所有主流图算法开箱即用。**

---

## ✅ 为什么选 mbtgraph，而不是自己写？

| 维度           | 自己从零写                 | 用 mbtgraph                                       |
| -------------- | -------------------------- | ------------------------------------------------- |
| **时间成本**   | 每个算法 30-200 行 + debug | **一行函数调用**                                  |
| **测试覆盖**   | 你自己写几个 case          | **772 个测试**（黑盒 + 白盒 + NetworkX 交叉验证） |
| **存储选型**   | 写死一种结构，换场景重写   | **8 种存储**切换，只需改一行构造函数              |
| **跨存储兼容** | 不存在，换存储要重写算法   | **5 层 Trait 隔离**，算法与存储完全解耦           |
| **性能保证**   | 可能 O(n²) 而不自知        | 经过基准测试的工业实现                            |
| **bug 风险**   | 你的算法只有你知道         | 772 测试 + CI 门禁                                |

---

## ⚡️ 和竞品比好在哪

### MoonBit 生态内

| 维度       |  mgraph  |    graphviz    |  **mbtgraph**  |
| ---------- | :------: | :------------: | :------------: |
| 定位       | 轻量遍历 | Graphviz 封装  | **完整算法库** |
| 算法数     |    2     |       0        |    **65+**     |
| 存储种类   |    0     |       1        |     **8**      |
| Trait 层数 |    1     |       0        |     **5**      |
| 测试       |   ~10    | fixture parity |    **772**     |

### 跨语言对比

| 特性           |     mbtgraph      |  NetworkX   | petgraph | JGraphT  |
| -------------- | :---------------: | :---------: | :------: | :------: |
| **语言**       |    MoonBit ⭐     |   Python    |   Rust   |   Java   |
| **多后端**     | native+wasm+js ⭐ | Python only |  Native  | JVM only |
| **Trait 层数** |       5 ⭐        |      3      |    3     |    4     |
| **存储种类**   |       8 ⭐        |      4      |    5     |    6     |
| **wasm 体积**  | **53 KB**（gzip 23 KB）|     N/A     |   ~2MB   |  >50MB   |
| **纯函数语义** |        ✅         |     ❌      |   部分   |    ❌    |

---

## 💾 不想花时间选型？直接抄

| 你的场景             | 用这个存储                | 一句话理由            |
| -------------------- | ------------------------- | --------------------- |
| 80% 的通用有向图     | `DirectedAdjList` ⭐      | **默认选它，不出错**  |
| 无向图（好友关系等） | `UndirectedAdjList`       | 省一半内存            |
| 小图（<1000节点）    | `DirectedMatrix`          | O(1) 查边，写起来最快 |
| Kruskal 最小生成树   | `UndirectedEdgeListGraph` | 边已排序，拿来就用    |
| 10万+ 节点大图       | `CSRGraph`                | 缓存友好，内存紧凑    |

> **选型原则：** 不知道选什么 → `DirectedAdjList`。有特殊需求 → 看[存储选型指南](https://morning-start.github.io/mbtgraph/core-concepts/storage-guide/)。

---

## 🧪 测试说了算

```bash
moon test              # 全量 772 测试，秒级通过
moon test lib/algo/flow  # 只跑网络流模块
```

- **双轨制**: Blackbox（公开 API）+ Whitebox（内部实现）
- **跨存储一致性**: 同一算法在不同存储上结果相同
- **NetworkX 交叉验证**: 55 个算法、295 个随机图、Python ground truth 对照

---

## 🔧 版本 & 路线图

| 版本              | 重点                       |   状态    |
| ----------------- | -------------------------- | :-------: |
| **v0.1.0**        | 65+ 核心算法完成           |    ✅     |
| **v0.1.1**        | 18 个模块补齐 + 文档站点上线 |    ✅     |
| **v0.1.2** ← 当前 | 用户体验改进 + 文档完善     |    ✅     |
| **v0.2.0**        | 高级图算法 + 大规模优化    | ⬜ 规划中 |

完整变更记录 → [CHANGELOG.md](CHANGELOG.md)

---

## 🤝 贡献

欢迎任何形式的贡献！流程：

1. Fork → `git checkout -b feature/awesome-algo`
2. 编码 → 测试 (`moon test`)
3. PR → CI 通过 → merge

详见 [CONTRIBUTING.md](CONTRIBUTING.md) 和 [AGENTS.md](AGENTS.md)（含编码陷阱速查）。

---

## 📄 许可证

[MIT](LICENSE)

---

## 🙏 致谢

设计灵感来源: [NetworkX](https://networkx.org/) (Python), [petgraph](https://github.com/petgraph/petgraph) (Rust), [JGraphT](https://jgrapht.org/) (Java), [LEMON](https://lemon.cs.elte.hu/) (C++)

官方赛事支持: [2026 MoonBit 创新大赛](https://www.gitlink.org.cn/competitions/track1_2026MoonBit) — 本项目为 MoonBit 生态图算法赛道的参赛作品

<p>
  本项目的 AI API 支持由
  <a href="https://tokeness.io">
    Tokeness.io
  </a>
  赞助提供。
</p>

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给一个 Star！⭐**

Made with ❤️ using [MoonBit](https://www.moonbitlang.com/)

</div>
