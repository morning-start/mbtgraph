# 🏗️ mbtgraph 项目架构设计方案

> 基于 5 大语言 8 个主流图算法库的深度调研，为 MoonBit 设计的高性能、类型安全、模块化的图算法库。

## 📋 设计原则

### 核心设计理念

1. **MoonBit 原生优先**：充分利用 MoonBit 的泛型、Trait、模式匹配等特性
2. **性能导向**：编译到原生代码，接近 Rust/C++ 性能
3. **类型安全**：编译期捕获错误，避免运行时异常
4. **模块化设计**：清晰的包边界，按需引入依赖
5. **渐进式复杂度**：从简单 API 开始，逐步暴露高级功能
6. **跨后端兼容**：支持 wasm/js/native 多目标编译

### 架构参考来源

| 参考库 | 借鉴点 |
|--------|--------|
| **NetworkX (Python)** | 模块化组织、全面的算法覆盖 |
| **petgraph (Rust)** | 多图类型设计、Index-based 节点标识 |
| **JGraphT (Java)** | 接口驱动、类型安全的 API |
| **LEMON (C++)** | 高性能流算法、LP 接口 |
| **gonum/graph (Go)** | 网络分析工具集 |

---

## 📐 整体项目结构

```
mbtgraph/
├── moon.mod.json                    # 模块元数据
├── README.mbt.md                    # 项目文档
├── LICENSE                          # Apache-2.0
│
├── src/                             # 🔧 核心源码目录
│   ├── core/                        # 📦 graph-core: 核心数据结构
│   │   ├── moon.pkg                 # 包配置
│   │   ├── types.mbt                # 类型定义 (Graph, Node, Edge)
│   │   ├── graph.mbt                # 图 trait 定义
│   │   ├── directed.mbt             # 有向图实现
│   │   ├── undirected.mbt           # 无向图实现
│   │   ├── weighted.mbt             # 加权图扩展
│   │   ├── multigraph.mbt           # 多重图实现
│   │   ├── mutable.mbt              # 可变操作接口
│   │   ├── builder.mbt              # Builder 模式构建器
│   │   └── iterators.mbt            # 迭代器 trait
│   │
│   ├── algo/                        # 📦 graph-algo: 基础算法
│   │   ├── moon.pkg                 # 包配置
│   │   ├── traverse/                # 遍历算法
│   │   │   ├── moon.pkg
│   │   │   ├── bfs.mbt              # 广度优先搜索
│   │   │   └── dfs.mbt              # 深度优先搜索
│   │   │
│   │   ├── shortest_path/           # 最短路径
│   │   │   ├── moon.pkg
│   │   │   ├── dijkstra.mbt         # Dijkstra 算法
│   │   │   ├── bellman_ford.mbt     # Bellman-Ford 算法
│   │   │   ├── astar.mbt            # A* 启发式搜索
│   │   │   ├── floyd_warshall.mbt   # Floyd-Warshall 全对
│   │   │   └── johnson.mbt          # Johnson 全对 (稀疏图优化)
│   │   │
│   │   ├── spanning_tree/           # 最小生成树
│   │   │   ├── moon.pkg
│   │   │   ├── kruskal.mbt          # Kruskal 算法
│   │   │   └── prim.mbt             # Prim 算法
│   │   │
│   │   ├── connectivity/            # 连通性分析
│   │   │   ├── moon.pkg
│   │   │   ├── scc.mbt              # 强连通分量 (Kosaraju + Tarjan)
│   │   │   ├── wcc.mbt              # 弱连通分量
│   │   │   ├── biconnectivity.mbt   # 双连通分量 (割点+桥)
│   │   │   └── toposort.mbt         # 拓扑排序
│   │   │
│   │   └── cycle/                   # 环检测
│   │       ├── moon.pkg
│   │       ├── cycle_detection.mbt # 有向环检测
│   │       └── eulerian.mbt        # 欧拉回路
│   │
│   ├── analysis/                    # 📦 graph-analysis: 网络分析 (核心优势!)
│   │   ├── moon.pkg                 # 包配置
│   │   ├── centrality/              # 中心性指标
│   │   │   ├── moon.pkg
│   │   │   ├── degree.mbt           # 度中心性
│   │   │   ├── betweenness.mbt      # 介数中心性
│   │   │   ├── closeness.mbt        # 紧密中心性
│   │   │   ├── pagerank.mbt         # PageRank 排名
│   │   │   ├── hits.mbt             # HITS (Hub-Authority)
│   │   │   └── harmonic.mbt         # 调和中心性
│   │   │
│   │   ├── community/               # 社区检测 ⭐ 差异化优势!
│   │   │   ├── moon.pkg
│   │   │   ├── louvain.mbt          # Louvain 算法
│   │   │   ├── leiden.mbt           # Leiden 算法 (改进版)
│   │   │   ├── label_propagation.mbt # 标签传播算法
│   │   │   ├── greedy_modularity.mbt # 贪心模块度
│   │   │   └── metrics.mbt          # 模块度评估指标
│   │   │
│   │   └── clustering/              # 聚类系数
│   │       ├── moon.pkg
│   │       ├── local.mbt            # 局部聚类系数
│   │       ├── global.mbt           # 全局聚类系数
│   │       └── triangle_counting.mbt # 三角形计数
│   │
│   ├── flow/                        # 📦 graph-flow: 流网络算法
│   │   ├── moon.pkg                 # 包配置
│   │   ├── max_flow/                # 最大流
│   │   │   ├── moon.pkg
│   │   │   ├── ford_fulkerson.mbt   # Ford-Fulkerson 方法
│   │   │   ├── edmonds_karp.mbt     # Edmonds-Karp (BFS增广)
│   │   │   ├── dinic.mbt            # Dinic 分层图算法
│   │   │   └── push_relabel.mbt     # Push-Relabel
│   │   │
│   │   ├── min_cost_flow/           # 最小费用流
│   │   │   ├── moon.pkg
│   │   │   ├── successive_shortest.mbt # 最短增广路
│   │   │   └── cycle_canceling.mbt  # 消圈算法
│   │   │
│   │   └── cut/                     # 割算法
│   │       ├── moon.pkg
│   │       ├── stoer_wagner.mbt     # Stoer-Wagner 全局最小割
│   │       └── edge_connectivity.mbt # 边连通度
│   │
│   ├── matching/                    # 📦 graph-matching: 匹配算法
│   │   ├── moon.pkg                 # 包配置
│   │   ├── greedy.mbt               # 贪心匹配 (近似)
│   │   ├── maximum_cardinality.mbt  # 最大基数匹配 (Edmonds' Blossom)
│   │   ├── maximum_weighted.mbt     # 最大权重匹配
│   │   └── bipartite.mbt            # 二分图匹配
│   │
│   ├── isomorphism/                 # 📦 graph-isomorphism: 同构检测
│   │   ├── moon.pkg                 # 包配置
│   │   ├── vf2.mbt                  # VF2 精确子图同构
│   │   ├── color_refinement.mbt     # 颜色细化 (快速近似)
│   │   └── tree_isomorphism.mbt     # 树同构 (线性时间)
│   │
│   ├── coloring/                    # 📦 graph-coloring: 图着色
│   │   ├── moon.pkg                 # 包配置
│   │   ├── greedy.mbt               # 贪心着色 (多种策略)
│   │   ├── dsatur.mbt               # DSATUR 着色
│   │   └── exact.mbt                # 精确最优着色 (回溯搜索)
│   │
│   └── tour/                        # 📦 graph-tour: 回路/游历
│       ├── moon.pkg                 # 包配置
│       ├── hamiltonian.mbt          # 哈密顿回路
│       ├── tsp/                     # TSP 近似算法
│       │   ├── two_approx.mbt       # 2-近似
│       │   ├── christofides.mbt     # Christofides 1.5-近似
│       │   └── nearest_neighbor.mbt # 最近邻启发式
│       └── eulerian_tour.mbt        # 欧拉回路 (Hierholzer)
│
├── utils/                           # 📦 graph-utils: 工具与I/O
│   ├── moon.pkg                     # 包配置
│   ├── io/                          # 输入输出
│   │   ├── moon.pkg
│   │   ├── dot.mbt                  # Graphviz DOT 格式
│   │   ├── graphml.mbt              # GraphML 格式
│   │   ├── json.mbt                 # JSON 格式
│   │   └── csv.mbt                  # CSV 边列表格式
│   │
│   ├── generators/                  # 图生成器
│   │   ├── moon.pkg
│   │   ├── classic.mbt              # 经典图 (完全图, 环形图, 星型图...)
│   │   ├── random_graphs.mbt        # 随机图模型 (ER, BA, WS...)
│   │   └── special.mbt              # 特殊图 (Petersen, Kneser...)
│   │
│   ├── layout/                      # 布局算法 (用于可视化)
│   │   ├── moon.pkg
│   │   ├── fruchterman_reingold.mbt # 力导向布局
│   │   ├── circular.mbt             # 环形布局
│   │   └── hierarchical.mbt         # 层次布局
│   │
│   └── convert/                     # 格式转换
│       ├── moon.pkg
│       └── adjacency_converters.mbt # 邻接表/矩阵互转
│
├── data_structures/                 # 📦 内部数据结构
│   ├── moon.pkg                     # 包配置
│   ├── priority_queue.mbt           # 优先队列 (二叉堆/斐波那契堆)
│   ├── union_find.mbt              # 并查集 (用于 MST/连通性)
│   ├── disjoint_set.mbt            # 不相交集
│   └── sparse_matrix.mbt           # 稀疏矩阵 (CSR/CSC)
│
├── cmd/                             # 🎯 应用入口
│   ├── main/
│   │   ├── main.mbt                 # 主程序入口
│   │   └── moon.pkg
│   ├── benchmarks/                  # 性能基准测试
│   │   ├── moon.pkg
│   │   ├── dijkstra_bench.mbt
│   │   ├── pagerank_bench.mbt
│   │   └── louvain_bench.mbt
│   └── examples/                    # 使用示例
│       ├── moon.pkg
│       ├── social_network.mbt       # 社交网络分析示例
│       ├── shortest_path_demo.mbt   # 最短路径演示
│       └── community_detection.mbt  # 社区检测演示
│
├── test/                            # 🧪 集成测试
│   ├── moon.pkg
│   ├── fixtures/                    # 测试数据
│   │   ├── karate_club.json         # Karate Club 网络
│   │   ├── small_graph.json         # 小型测试图
│   │   └── large_random.json        # 大规模随机图
│   ├── test_core.mbt                # 核心数据结构测试
│   ├── test_algo.mbt                # 基础算法测试
│   ├── test_analysis.mbt            # 分析算法测试
│   └── test_flow.mbt                # 流网络测试
│
└── docs/                            # 📚 文档
    ├── reference/                   # 调研报告 (已完成 ✓)
    │   ├── python-NetworkX.md
    │   ├── python-pyG.md
    │   ├── python-igraph.md
    │   ├── cpp-BoostGraph.md
    │   ├── cpp-Lemon.md
    │   ├── java-JGraphT.md
    │   ├── rust-petgraph.md
    │   └── go-gonumgraph.md
    ├── architecture/                # 架构文档
    │   ├── design_decisions.md      # 设计决策记录
    │   ├── api_guide.md             # API 设计指南
    │   └── performance_notes.md     # 性能优化笔记
    └── tutorials/                   # 教程文档
        ├── getting_started.md        # 快速开始
        ├── basic_usage.mbt           # 基础用法
        └── advanced_topics.mbt       # 进阶主题
```

---

## 🎯 模块详细设计

### 1️⃣ src/core - 核心数据结构包

#### 设计目标
提供类型安全、高性能的图数据结构，支持多种图类型和操作模式。

#### 核心 Trait 设计

```moonbit
// src/core/types.mbt

/// 图的基础 trait，定义所有图的通用接口
trait Graph[N, E] {
  /// 获取节点数量
  node_count() -> Int

  /// 获取边数量
  edge_count() -> Int

  /// 判断是否包含指定节点
  contains_node(node_id: NodeId) -> Bool

  /// 判断是否包含指定边
  contains_edge(from: NodeId, to: NodeId) -> Bool

  /// 获取节点的所有邻居
  neighbors(node_id: NodeId) -> Array[NodeId]

  /// 获取节点的出边邻居 (仅限有向图)
  successors(node_id: NodeId) -> Array[NodeId]

  /// 获取节点的入边邻居 (仅限有向图)
  predecessors(node_id: NodeId) -> Array[NodeId]

  /// 获取边的权重 (仅限加权图)
  weight(from: NodeId, to: NodeId) -> Option[Double]
}

/// 可变图 trait，支持添加/删除操作
trait MutableGraph[N, E] : Graph[N, E] {
  /// 添加节点，返回新节点的 ID
  add_node(data: N) -> NodeId

  /// 添加边，返回新边的 ID
  add_edge(from: NodeId, to: NodeId, data: E) -> EdgeId

  /// 移除节点及其关联的所有边
  remove_node(node_id: NodeId) -> Unit

  /// 移除边
  remove_edge(edge_id: EdgeId) -> Unit

  /// 设置边的权重
  set_weight(from: NodeId, to: NodeId, weight: Double) -> Unit
}

/// 加权图 trait
trait WeightedGraph[N, E] : Graph[N, E] {
  /// 获取边的权重
  edge_weight(edge_id: EdgeId) -> Double

  /// 获取所有边的总权重
  total_weight() -> Double
}

/// 有向图 trait
trait DirectedGraph[N, E] : Graph[N, E] {
  /// 反转图中所有边的方向
  reverse() -> Self
}

/// 无向图 trait
trait UndirectedGraph[N, E] : Graph[N, E] {
  /// 获取节点的度数
  degree(node_id: NodeId) -> Int
}
```

#### 数据结构实现

```moonbit
// src/core/directed.mbt

/// 基于邻接表的有向图实现
struct DirectedGraph[N, E] {
  nodes: Array[Option[N]]                    // 节点数据数组
  edges: HashMap[EdgeKey, EdgeData[E]]       // 边数据哈希表
  adj_list: Array[Array[NodeId]]             // 邻接表 (出边)
  reverse_adj: Array[Array[NodeId]]          // 反向邻接表 (入边)
  free_node_ids: Array[NodeId]               // 可复用的空闲节点 ID
  next_node_id: NodeId                       // 下一个可分配的节点 ID
}

impl[N, E] MutableGraph[N, E] for DirectedGraph[N, E] {
  pub fn add_node(self : DirectedGraph[N, E], data: N) -> NodeId { ... }
  pub fn add_edge(self : DirectedGraph[N, E], from: NodeId, to: NodeId, data: E) -> EdgeId { ... }
  // ... 其他方法
}
```

```moonbit
// src/core/undirected.mbt

/// 基于邻接表的无向图实现
struct UndirectedGraph[N, E] {
  nodes: Array[Option[N]]
  edges: HashSet[EdgeKey]
  adj_list: Array[HashSet[NodeId]]
  // ...
}

impl[N, E] UndirectedGraph[N, E] {
  pub fn new() -> UndirectedGraph[N, E] { ... }

  /// 创建带初始容量的无向图
  pub fn with_capacity(nodes: Int, edges: Int) -> UndirectedGraph[N, E] { ... }
}
```

#### 节点和边标识符

```moonbit
// src/core/types.mbt

/// 节点唯一标识符 (使用 i64 保证大图支持)
type NodeId = Int64

/// 边唯一标识符
type EdgeId = Int64

/// 边的唯一键 (用于去重查找)
struct EdgeKey {
  from: NodeId
  to: NodeId
}

impl Eq for EdgeKey {
  // 实现相等性比较
}

impl Hash for EdgeKey {
  // 实现哈希函数
}
```

---

### 2️⃣ src/algo - 基础算法包

#### 设计目标
提供经过验证的经典图算法，确保正确性和性能。

#### BFS 实现

```moonbit
// src/algo/traverse/bfs.mbt

/// BFS 遍历结果
struct BfsResult[N] {
  discovered_order: Array[NodeId]  // 发现顺序
  distance: HashMap[NodeId, Int]   // 距离 (层数)
  parent: HashMap[NodeId, Option[NodeId]]  // 父节点 (可用于重建路径)
}

/// 执行广度优先搜索
pub fn breadth_first_search[N, E](graph: Graph[N, E], start: NodeId) -> BfsResult[N] {
  let mut queue = Array::new()
  let mut visited = HashSet::new()
  let mut result = BfsResult { ... }

  queue.push(start)
  visited.add(start)

  while queue.length() > 0 {
    let current = queue.shift()
    result.discovered_order.push(current)

    for neighbor in graph.neighbors(current) {
      if !visited.contains(neighbor) {
        visited.add(neighbor)
        queue.push(neighbor)
        result.distance.set(neighbor, result.distance[current] + 1)
        result.parent.set(neighbor, Some(current))
      }
    }
  }

  result
}
```

#### Dijkstra 实现

```moonbit
// src/algo/shortest_path/dijkstra.mbt

/// Dijkstra 最短路径结果
struct ShortestPathResult {
  distances: HashMap[NodeId, Double]  // 到各节点的最短距离
  predecessors: HashMap[NodeId, Option[NodeId]]  // 前驱节点
}

/// 执行 Dijkstra 最短路径算法
pub fn dijkstra[N, E](
  graph: WeightedGraph[N, E],
  source: NodeId,
  target: Option<NodeId],  // 可选目标节点
) -> Result[ShortestPathResult, String] {

  let mut dist = HashMap::new()
  let mut prev = HashMap::new()
  let mut pq = BinaryMinHeap::new()

  // 初始化距离
  for node_id in 0..graph.node_count() {
    if node_id == source {
      dist.set(NodeId::from_int(node_id), 0.0)
    } else {
      dist.set(NodeId::from_int(node_id), f64::INFINITY)
    }
  }

  pq.insert(source, 0.0)

  while !pq.is_empty() {
    let (u, u_dist) = pq.extract_min()

    match target {
      Some(t) if u == t => break,  // 提前终止
      _ => ()
    }

    for v in graph.successors(u) {
      let alt = u_dist + graph.weight(u, v).or(Some(0.0)).unwrap()
      if alt < dist.get_or_default(v, f64::INFINITY) {
        dist.set(v, alt)
        prev.set(v, Some(u))
        pq.decrease_key(v, alt)
      }
    }
  }

  Ok(ShortestPathResult { distances: dist, predecessors: prev })
}

/// 从最短路径结果中重建具体路径
pub fn reconstruct_path(result: &ShortestPathResult, target: NodeId) -> Array[NodeId] {
  let mut path = Array::new()
  let mut current = Some(target)

  loop {
    match current {
      Some(node) => {
        path.unshift(node)
        current = result.predecessors[node]
      },
      None => break
    }
  }

  path
}
```

#### Kosaraju SCC 实现

```moonbit
// src/algo/connectivity/scc.mbt

/// 强连通分量结果
struct SccResult {
  components: Array<Array[NodeId>>  // 各分量的节点列表
  component_id: HashMap[NodeId, Int]  // 节点到分量ID的映射
  count: Int                         // 分量总数
}

/// Kosaraju 算法求强连通分量
pub fn kosaraju_scc[N, E](graph: DirectedGraph[N, E]) -> SccResult {
  // 第一次 DFS: 记录完成时间
  let mut finish_order = Array::new()
  let mut visited = HashSet::new()

  fn dfs_first_pass(graph, node, visited, finish_order) { ... }

  for node in 0..graph.node_count() {
    if !visited.contains(NodeId::from_int(node)) {
      dfs_first_pass(graph, NodeId::from_int(node), &mut visited, &mut finish_order)
    }
  }

  // 第二次 DFS: 在反转图上按完成时间逆序遍历
  let reversed_graph = graph.reverse()
  let mut components = Array::new()
  let mut component_map = HashMap::new()

  fn dfs_second_pass(reversed_graph, node, visited, current_component) { ... }

  visited.clear()

  for node in finish_order.reverse_iter() {
    if !visited.contains(node) {
      let mut component = Array::new()
      dfs_second_pass(&reversed_graph, node, &mut visited, &mut component)
      components.push(component)

      for n in component {
        component_map.set(n, components.length() - 1)
      }
    }
  }

  SccResult {
    components: components,
    component_id: component_map,
    count: components.length()
  }
}
```

---

### 3️⃣ src/analysis - 网络分析包 (核心优势!)

#### 设计目标
提供丰富的网络科学分析工具，这是 mbtgraph 的**差异化竞争优势**。

#### PageRank 实现

```moonbit
// src/analysis/centrality/pagerank.mbt

/// PageRank 计算结果
struct PageRankResult {
  scores: HashMap[NodeId, Double]  // 各节点的 PageRank 分值
  iterations: Int                   // 实际迭代次数
  converged: Bool                   // 是否收敛
  damping_factor: Double            // 阻尼系数
}

/// 计算 PageRank
pub fn compute_pagerank[N, E](
  graph: WeightedGraph[N, E],
  damping_factor: Double = 0.85,
  tolerance: Double = 1e-6,
  max_iterations: Int = 100,
) -> PageRankResult {

  let n = graph.node_count()
  let mut ranks = HashMap::new()
  let mut new_ranks = HashMap::new()

  // 初始化均匀分布
  for node_id in 0..n {
    ranks.set(NodeId::from_int(node_id), 1.0 / n.to_double())
  }

  let mut iteration = 0
  let mut converged = false

  while iteration < max_iterations && !converged {
    let mut max_diff = 0.0

    for node_id in 0..n {
      let node = NodeId::from_int(node_id)
      let mut rank_sum = 0.0

      for predecessor in graph.predecessors(node) {
        let pred_degree = graph.degree(predecessor)
        if pred_degree > 0 {
          rank_sum += ranks[predecessor] / pred_degree.to_double()
        }
      }

      let new_rank = (1.0 - damping_factor) / n.to_double()
                   + damping_factor * rank_sum
      new_ranks.set(node, new_rank)

      let diff = (new_rank - ranks[node]).abs()
      if diff > max_diff { max_diff = diff }
    }

    converged = max_diff < tolerance
    ranks = new_ranks.clone()
    iteration += 1
  }

  PageRankResult {
    scores: ranks,
    iterations: iteration,
    converged: converged,
    damping_factor: damping_factor
  }
}
```

#### Louvain 社区检测算法

```moonbit
// src/analysis/community/louvain.mbt

/// 社区检测结果
struct CommunityDetectionResult {
  communities: Array<Array[NodeId>>  // 各社区的节点列表
  membership: HashMap[NodeId, Int]  // 节点到社区ID的映射
  modularity: Double                // 最终模块度值
  num_communities: Int              // 社区数量
}

/// Louvain 算法实现
pub fn louvain_community_detection[N, E](
  graph: WeightedGraph[N, E],
) -> CommunityDetectionResult {

  let n = graph.node_count()

  // Phase 1: 初始化每个节点为一个独立社区
  let mut node_to_community = HashMap::new()
  for node_id in 0..n {
    node_to_community.set(NodeId::from_int(node_id), node_id)
  }

  let mut modularity = calculate_modularity(graph, &node_to_community)
  let mut improved = true

  while improved {
    improved = false

    for node_id in 0..n {
      let node = NodeId::from_int(node_id)
      let original_community = node_to_community[node]

      // 计算移除该节点后各社区的模块度增益
      let mut best_delta_q = 0.0
      let mut best_community = original_community

      let neighbor_communities = get_neighbor_communities(
        graph, node, &node_to_community
      )

      for community in neighbor_communities {
        let delta_q = calculate_modularity_gain(
          graph, node, original_community, community, &node_to_community
        )
        if delta_q > best_delta_q {
          best_delta_q = delta_q
          best_community = community
        }
      }

      if best_community != original_community {
        node_to_community.set(node, best_community)
        improved = true
      }
    }

    // 重新计算整体模块度
    let new_modularity = calculate_modularity(graph, &node_to_community)
    if new_modularity <= modularity {
      break
    }
    modularity = new_modularity
  }

  // Phase 2: 构建超图并递归 (可选优化)
  // ...

  build_result(graph, &node_to_community, modularity)
}
```

---

### 4️⃣ src/flow - 流网络算法包

#### Dinic 最大流算法

```moonbit
// src/flow/max_flow/dinic.mbt

/// 最大流结果
struct MaxFlowResult {
  max_flow_value: Double           // 最大流量
  flow_on_edges: HashMap[EdgeId, Double]  // 各边流量
  min_cut: HashSet[EdgeId]          // 最小割边集
}

/// Dinic 算法求解最大流
pub fn dinic_max_flow[N, E](
  graph: WeightedGraph[N, E],
  source: NodeId,
  sink: NodeId,
) -> MaxFlowResult {

  let n = graph.node_count()
  let mut residual_graph = build_residual_graph(graph)
  let mut flow = 0.0
  let mut level = Array::with_capacity(n)
  let mut iter = Array::with_capacity(n)

  loop {
    // BFS 构建层次图
    if !bfs_level_graph(&residual_graph, source, sink, &mut level) {
      break  // 无法到达汇点，结束
    }

    iter.fill(0)

    loop {
      let pushed = dfs_push_flow(
        &mut residual_graph, source, sink, f64::INFINITY,
        &level, &mut iter
      )
      if pushed <= 0.0 { break }
      flow += pushed
    }
  }

  extract_result(flow, &residual_graph)
}
```

---

### 5️⃣ utils - 工具与 I/O 包

#### DOT 格式导出

```moonbit
// utils/io/dot.mbt

/// 导出图为 Graphviz DOT 格式
pub fn export_dot[N, E](
  graph: Graph[N, E],
  options: DotExportOptions,
) -> String {
  let mut output = String::new()

  match options.graph_type {
    Directed => output += "digraph G {\n",
    Undirected => output += "graph G {\n",
  }

  // 输出全局属性
  if options.node_attributes.is_some() {
    output += "  node [" + options.node_attributes.unwrap() + "];\n"
  }
  if options.edge_attributes.is_some() {
    output += "  edge [" + options.edge_attributes.unwrap() + "];\n"
  }

  // 输出节点
  for node_id in 0..graph.node_count() {
    let label = format_node_label(graph, node_id, &options.label_fn)
    output += format!("  {} [{}];\n", node_id, label)
  }

  // 输出边
  let separator = match options.graph_type {
    Directed => " -> ",
    Undirected => " -- ",
  }

  for edge in graph.edges_iterator() {
    let weight_str = match graph.edge_weight(edge.id) {
      Some(w) => format!(", label=\"{:.2}\"", w),
      None => String::new(),
    }
    output += format!(
      "  {}{}{} [{}];\n",
      edge.from, separator, edge.to, weight_str.trim()
    )
  }

  output += "}\n"
  output
}
```

---

## 🔄 依赖关系图

```
                    ┌─────────────┐
                    │  cmd/main   │ (应用入口)
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌────────────┐  ┌────────────┐  ┌────────────┐
    │  examples  │  │benchmarks  │  │   test     │
    └────────────┘  └─────┬──────┘  └─────┬──────┘
                          │               │
           ┌──────────────┴───────────────┘
           ▼
    ┌──────────────────────────────────────────────┐
    │              Public API Layer                │
    ├──────────┬──────────┬──────────┬─────────────┤
    │ src/core │ src/algo │src/analysis│src/flow   │
    │  (数据结构)│ (基础算法)│ (网络分析)  │ (流网络)  │
    └────┬─────┴────┬─────┴─────┬────┴─────┬───────┘
         │          │           │           │
         ▼          ▼           ▼           ▼
    ┌──────────────────────────────────────────────┐
    │           Internal Dependencies              │
    │  ┌──────────────┐  ┌─────────────────────┐  │
    │  │data_structures│  │  src/matching       │  │
    │  │(优先队列/并查集)│  │  src/isomorphism   │  │
    │  └──────────────┘  │  src/coloring       │  │
    │                     │  src/tour          │  │
    │                     └─────────────────────┘  │
    └──────────────────────────────────────────────┘
                          │
                          ▼
    ┌──────────────────────────────────────────────┐
    │              Utils Layer                     │
    │  ┌────────┐ ┌──────────┐ ┌────────┐         │
    │  │utils/io│ │utils/gen │ │utils/layout│      │
    │  └────────┘ └──────────┘ └────────┘         │
    └──────────────────────────────────────────────┘
```

---

## 📊 开发路线图 (Phases)

### Phase 1: 核心基础 (MVP) ✅ 当前阶段

**目标**: 实现最小可用产品，支持基本图操作和核心算法

**包含模块**:
- ✅ `src/core` - 基础图类型 (DirectedGraph, UndirectedGraph)
- ✅ `src/algo/traverse` - BFS, DFS
- ✅ `src/algo/shortest_path` - Dijkstra, Bellman-Ford
- ✅ `src/algo/connectivity` - SCC (Kosaraju), TopoSort
- ✅ `data_structures` - PriorityQueue, UnionFind
- ✅ `cmd/examples` - 基础示例

**预计工作量**: 2-3 周
**验收标准**:
- [ ] 可以创建有向/无向图并添加节点和边
- [ ] BFS/DFS 正确工作
- [ ] Dijkstra 返回正确的最短路径
- [ ] SCC 正确识别强连通分量
- [ ] 单元测试覆盖率 > 80%

---

### Phase 2: 网络分析增强

**目标**: 提供强大的网络科学分析能力，形成差异化优势

**新增模块**:
- 🆕 `src/analysis/centrality` - PageRank, Betweenness, Closeness
- 🆕 `src/analysis/community` - Louvain, Leiden, Label Propagation
- 🆕 `src/analysis/clustering` - Local/Global Clustering Coefficient
- 🆕 `src/algo/spanning_tree` - Kruskal, Prim MST
- 🆕 `utils/generators` - 经典图和随机图生成器

**预计工作量**: 3-4 周
**验收标准**:
- [ ] PageRank 收敛且结果合理 (Karate Club 数据集验证)
- [ ] Louvain 模块度 > 0.4 (标准基准图)
- [ ] MST 总权重正确
- [ ] 支持生成 ER, BA, WS 随机图
- [ ] 性能基准测试通过 (10K 节点 < 100ms)

---

### Phase 3: 高级算法扩展

**目标**: 补齐高级算法，成为功能全面的图算法库

**新增模块**:
- 🆕 `src/flow` - MaxFlow (Dinic), MinCostFlow
- 🆕 `src/matching` - Maximum Matching (Edmonds' Blossom)
- 🆕 `src/isomorphism` - VF2 Subgraph Isomorphism
- 🆕 `src/coloring` - Greedy Coloring, DSATUR
- 🆕 `src/tour` - TSP Approximation, Eulerian Tour
- 🆕 `src/algo/cycle` - Cycle Detection, Hamiltonian Path

**预计工作量**: 4-5 周
**验收标准**:
- [ ] Dinic 最大流正确 (对比标准测试用例)
- [ ] VF2 正确识别子图模式 (小型图)
- [ ] TSP 近似比 < 2 (2-approx) 或 < 1.5 (Christofides)
- [ ] 图着色色数合理 (二分图=2, 五色定理验证)
- [ ] 综合单元测试覆盖率 > 85%

---

### Phase 4: 生态完善

**目标**: 提供完善的工具链和生态集成

**新增模块**:
- 🆕 `utils/io` - DOT, GraphML, JSON, CSV 导入导出
- 🆕 `utils/layout` - Fruchterman-Reingold 力导向布局
- 🆕 `utils/convert` - 邻接表/矩阵互转
- 🆕 `cmd/benchmarks` - 全面性能基准测试套件
- 🆕 `docs/tutorials` - 完整教程文档
- 🆕 发布到 mooncakes.io

**预计工作量**: 2-3 周
**验收标准**:
- [ ] 支持导入/导出至少 3 种文件格式
- [ ] 布局算法可视化效果合理
- [ ] 基准测试覆盖所有核心算法
- [ ] 完整的 API 文档和使用教程
- [ ] 成功发布到 mooncakes.io

---

## 🎨 API 设计规范

### 命名约定

| 类型 | 规范 | 示例 |
|------|------|------|
| **类型/Struct** | PascalCase | `DirectedGraph`, `ShortestPathResult` |
| **Trait** | PascalCase + 描述性 | `MutableGraph`, `WeightedGraph` |
| **函数 (公开)** | snake_case | `breadth_first_search`, `compute_pagerank` |
| **函数 (私有)** | 下划线前缀 | `_internal_helper`, `_bfs_visit` |
| **常量** | SCREAMING_SNAKE_CASE | `MAX_ITERATIONS`, `DEFAULT_DAMPING` |
| **枚举变体** | PascalCase | `Directed`, `Undirected`, `GreedyStrategy` |

### 错误处理策略

```moonbit
// 使用 Result 类型进行显式错误处理
pub fn dijkstra(...) -> Result[ShortestPathResult, Error] {
  // 成功时返回 Ok(value)
  // 失败时返回 Err(error_message)
}

// 使用 Option 表示可能缺失的值
pub fn weight(from: NodeId, to: NodeId) -> Option[Double] {
  // 存在返回 Some(weight)
  // 不存在返回 None
}

// 自定义错误类型
enum GraphError {
  NodeNotFound(NodeId)
  EdgeNotFound(EdgeId)
  NegativeCycleDetected
  InvalidInput(String)
}
```

### 泛型和 Trait 使用指南

```moonbit
// ✅ 推荐: 使用泛型参数化图的数据类型
fn create_graph<N, E>() -> DirectedGraph[N, E] where N: Display, E: Clone { ... }

// ✅ 推荐: 通过 Trait 约束行为
fn shortest_path<G>(graph: G, source: NodeId) -> Result[...]
  where G: WeightedGraph[String, Double] + DirectedGraph[String, Double]
{ ... }

// ❌ 避免: 过度抽象导致类型签名复杂
// 应该提供具体的便捷类型别名
type SimpleDiGraph = DirectedGraph[String, Unit]
type WeightedDiGraph = DirectedGraph[String, Double]
```

---

## ⚡ 性能优化策略

### 1. 数据结构选择

| 场景 | 推荐实现 | 时间复杂度 | 空间复杂度 |
|------|----------|------------|------------|
| **稀疏图 (< E/V < 10)** | 邻接表 + HashMap | O(V+E) | O(V+E) |
| **稠密图 (E ≈ V²)** | 邻接矩阵 | O(V²) | O(V²) |
| **静态只读图** | CSR (压缩稀疏行) | O(V+E) | O(V+E) (紧凑) |
| **频繁查询边存在性** | HashSet + 邻接表 | O(1) 查询 | O(E) |

### 2. 关键优化技术

- **对象池 (Object Pooling)**: 复用节点/边对象减少 GC 压力
- **缓存友好布局**: 连续内存存储提高缓存命中率
- **惰性计算 (Lazy Evaluation)**: 仅在需要时计算昂贵的结果
- **并行化**: 对独立子任务使用 MoonBit 的并发原语
- **SIMD 向量化**: 利用 MoonBit 后端的向量指令 (native/wasm)

### 3. 内存管理建议

```moonbit
// ✅ 推荐: 预分配容量避免动态扩容
let graph = DirectedGraph::with_capacity(expected_nodes, expected_edges)

// ✅ 推荐: 使用原始类型而非包装类型 (当可能时)
// NodeId = Int64 比 NodeId { id: Int64 } 更节省内存

// ❌ 避免: 在热循环中频繁分配临时对象
// 应该重用缓冲区和临时变量
```

---

## 🧪 测试策略

### 测试层级

```
tests/
├── unit/                    # 单元测试 (每个包内部)
│   ├── core_test.mbt
│   ├── algo_test.mbt
│   └── analysis_test.mbt
│
├── integration/             # 集成测试 (跨包交互)
│   ├── end_to_end_scenarios.mbt
│   └── performance_regression.mbt
│
├── fixtures/                # 测试数据
│   ├── karate_club.dot      # 经典社交网络 (34 节点)
│   ├── drosophila_ppi.dot   # 蛋白质相互作用网络
│   ├── usroads.gr           # 美国道路网 (部分)
│   └── random_large_10k.dot # 大规模随机图 (10K 节点)
│
└── properties/              # 属性测试 (基于 QuickCheck 思想)
    ├── graph_invariants.mbt  # 图不变量检验
    └── algorithm_properties.mbt  # 算法性质验证
```

### 测试用例分类

#### 正确性测试
```moonbit
// test/unit/shortest_path_test.mbt

test "dijkstra_shortest_path_correctness" {
  let graph = create_known_test_graph()
  let result = dijkstra(graph, source=0, target=Some(5))

  assert_eq!(result.unwrap().distances[NodeId(5)], 14.0)
  assert_eq!(reconstruct_path(&result.unwrap(), NodeId(5)),
             [NodeId(0), NodeId(2), NodeId(5)])
}

test "bellman_ford_handles_negative_weights" {
  let graph = create_graph_with_negative_edge()
  let result = bellman_ford(graph, source=0)
  assert!(result.is_ok())
}
```

#### 性能回归测试
```moonbit
// test/integration/performance_regression.mbt

test "dijkstra_performance_10k_nodes" {
  let large_graph = generate_random_graph(10000, 50000)
  let start_time = time::now()
  let _result = dijkstra(large_graph, source=NodeId(0))
  let elapsed = time::elapsed_since(start_time)

  assert!(elapsed < Duration::from_millis(100),
          "Dijkstra on 10K nodes should complete within 100ms")
}
```

#### 属性测试
```moonbit
// test/properties/graph_invariants.mbt

test "page_rank_scores_sum_to_one" {
  let graph = generate_random_graph(100, 500)
  let pr_result = compute_pagerank(graph)

  let sum = pr_result.scores.values().fold(0.0, |acc, x| acc + x)
  assert!(sum.approx_eq(1.0, epsilon=1e-6))
}

test "mst_connects_all_nodes" {
  let graph = generate_connected_graph(50, 200)
  let mst_edges = kruskal_mst(graph)

  let mst_subgraph = graph.induced_subgraph(mst_edges.nodes())
  assert!(is_connected(mst_subgraph))
}
```

---

## 📈 版本规划

### v0.1.0 - MVP (当前目标)
- 基础图数据结构 (有向/无向)
- BFS/DFS 遍历
- Dijkstra/Bellman-Ford 最短路径
- Kosaraju SCC + 拓扑排序
- 基础示例和文档

### v0.2.0 - 网络分析
- PageRank + 其他中心性指标
- Louvain/Leiden 社区检测
- Kruskal/Prim MST
- 图生成器 (经典 + 随机模型)
- 性能基准测试

### v0.3.0 - 高级算法
- 流网络 (Dinic 最大流)
- 匹配算法 (Edmonds' Blossom)
- VF2 子图同构
- 图着色
- TSP 近似算法

### v0.4.0 - 生态完善
- 多格式 I/O (DOT, GraphML, JSON)
- 布局算法
- 完整文档和教程
- 发布到 mooncakes.io

### v1.0.0 - 生产就绪
- 全面的 API 稳定性保证
- 100% 单元测试覆盖率
- 性能优化达到生产标准
- 企业级支持和维护计划

---

## 🎯 与竞品对比定位

| 维度 | NetworkX | petgraph | JGraphT | **mbtgraph (目标)** |
|------|----------|----------|---------|---------------------|
| **语言** | Python | Rust | Java | **MoonBit** |
| **性能** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | **⭐⭐⭐⭐⭐** (接近 Rust) |
| **易用性** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | **⭐⭐⭐⭐⭐** (简洁语法) |
| **类型安全** | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **⭐⭐⭐⭐⭐** (编译期检查) |
| **社区检测** | ⭐⭐⭐⭐⭐ | ❌ | ⚠️ | **⭐⭐⭐⭐⭐** (重点投入!) |
| **跨平台** | ✅ | ✅ | ✅ (JVM) | **✅✅✅** (wasm/js/native) |
| **部署大小** | ~50MB (Python) | ~5MB | ~50MB (JVM) | **~1MB** (WASM 目标) |
| **学习曲线** | 平缓 | 中等 | 中等 | **平缓** (类似 Python) |

### 核心卖点 (USPs)

1. **🚀 MoonBit 原生性能**: 编译到 WASM/Native，接近 Rust/C++ 性能
2. **🔒 编译期类型安全**: 比 Python 更安全，比 Java/Rust 更简洁
3. **🌐 多后端统一**: 一套代码编译到 Web/服务器/边缘设备
4. **📦 超小体积**: WASM 目标 < 1MB，适合浏览器和嵌入式
5. **🧠 社区检测专精**: Louvain/Leiden 实现优于大多数竞品
6. **📚 中文生态友好**: 面向中文开发者，文档和社区支持

---

## ✅ 下一步行动项

### 立即执行 (本周)

1. **创建项目骨架**
   ```bash
   mkdir -p src/{core,algo/{traverse,shortest_path,spanning_tree,connectivity,cycle},analysis/{centrality,community,clustering}}
   mkdir -p data_structures utils/{io,generators,layout} cmd/{main,examples,benchmarks} test
   ```

2. **实现核心类型定义**
   - `src/core/types.mbt`: NodeId, EdgeId, Graph trait
   - `src/core/graph.mbt`: 核心接口定义
   - `src/core/directed.mbt`: DirectedGraph 基础实现

3. **编写第一个测试**
   - `test/test_core.mbt`: 验证图的基本操作

### 短期目标 (2-4 周)

4. **完成 Phase 1 MVP**
   - 所有基础算法实现并通过测试
   - 至少 2 个完整的使用示例
   - 基础 README 文档

### 中期目标 (1-2 月)

5. **推进到 Phase 2**
   - PageRank 和 Louvain 是优先级最高的特性
   - 这些将构成 mbtgraph 的核心竞争力

---

## 📎 相关文档

- **调研报告**: [docs/reference/](./reference/) 目录下的 8 份详细调研
- **MoonBit 官方文档**: https://docs.moonbitlang.com/
- **MoonBit 工具链**: https://docs.moonbitlang.com/toolchain/
- **设计决策记录**: docs/architecture/design_decisions.md (待创建)

---

**文档版本**: v1.0
**最后更新**: 2026-05-02
**作者**: AI Assistant (基于调研结果自动生成)
**审核状态**: 待团队评审
