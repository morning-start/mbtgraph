# 变更日志

本项目的所有重要变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)，
本项目遵循 [语义化版本](https://semver.org/spec/v2.0.0.html)规范。

## [v0.1.1] - 2026-07-03

### 新增

- 🚀 **补充算法模块**:
  - 社区检测: Leiden、谱聚类
  - 链接预测: 共同邻居/Jaccard/Adamic-Adar/优先连接/资源分配
  - 稠密子图: K-Core/K-Truss/三角计数/聚类系数
  - 图算子: 补图/反转/并交差/笛卡尔积/张量积/字典序积/线图/收缩/幂图
  - 特殊图识别: 弦图/二部图/正则图/完全图/树/森林/Havel-Hakimi
  - 中心性: Katz/Harmonic/通信/集团中心性
  - 匹配: Kuhn-Munkres/Push-Relabel/Stoer-Wagner
  - I/O: DOT/JSON 序列化 + 图统计工具

- 📚 **文档与示例完善**:
  - 新增 4 个模块示例: link_prediction、dense_subgraph、operators、recognition
  - 更新所有文档版本引用
  - 完善 API 参考文档 (23 个模块)
  - 完善使用指南 (入门/算法/存储/性能/FAQ)

- 🌐 **可视化站点调试**:
  - Astro + Cytoscape 可视化站点上线
  - 5 个算法动画演示页

- 🔄 **CI/CD 工作流上线**:
  - `ci.yml`: moon check + moon test + site build
  - `deploy-pages.yml`: GitHub Pages 自动部署

### 改进

- ⚡ **性能优化**:
  - Heap pop O(n) → O(1), Dijkstra 加速 2-5x
  - CSR Builder 冒泡排序 → 快排, 大图转换提速 10-100x
  - `neighbors_with_weight` 消除冗余, 最短路径提速 1.5-3x
  - Louvain 数据结构重构, 10K 节点提速 5-20x

- 🔧 **API 冻结**:
  - 5 Trait + 61 结构体 + ~136 函数
  - 11 个别名: Euler/Cutpoints/Hamiltonian/Clique 简短命名

### 统计数据

- 全量测试 **940**
- 算法模块 **19+**
- 算法总数 **65+**
- 代码行数 **~15,000+**

---

## [v0.1.0] - 2026-05-19

### 🎉 初始化项目 + 核心算法完成

**首个版本** — 完整的图数据结构和算法实现

### 核心模块

| 模块 | 核心功能 |
|------|---------|
| **core** | NodeId/Node/Edge 类型、5 层 Trait、GraphError |
| **storage** | AdjList/Matrix/EdgeList/CSR/CSC (有向/无向) |
| **traversal** | BFS、DFS、环检测、拓扑排序、双向 BFS |
| **shortest_path** | Dijkstra、Bellman-Ford、Floyd-Warshall、A*、Johnson、SPFA、双向 Dijkstra、Yen's K短路 |
| **mst** | Kruskal、Prim |
| **connectivity** | CC、Tarjan SCC、Kosaraju SCC、BCC 双连通分量 |
| **flow** | Edmonds-Karp、Dinic、最小费用最大流、Push-Relabel、Stoer-Wagner |
| **matching** | Hungarian、Hopcroft-Karp、Edmonds、Kuhn-Munkres |
| **euler** | Hierholzer 欧拉路径/回路 |
| **cutpoints** | Tarjan 割点与桥检测 |
| **coloring** | Greedy/Welch-Powell/DSATUR/回溯精确 |
| **clique** | Bron-Kerbosch 最大团/独立集/顶点覆盖 |
| **hamiltonian** | 哈密顿路径/回路、TSP |
| **pagerank** | 幂法迭代 |
| **centrality** | 度/介数/接近/特征向量 |
| **community** | Louvain/标签传播 |
| **generators** | 16 个图生成器 |
| **integration** | 跨模块集成测试 |

### 统计数据

- 全量测试 **940**
- 算法模块 **19+**
- 算法总数 **65+**
- 代码行数 **~15,000+**

### 致谢

感谢所有贡献者和 MoonBit 社区的支持！
