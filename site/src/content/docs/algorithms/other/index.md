---
title: 其他算法总览
description: mbtgraph 中其他重要算法的索引，包括图生成器、图算子、特殊图识别、链接预测等
---

# 其他重要算法

mbtgraph 在 8 大核心算法领域之外，还提供了以下重要算法模块。

---

## 一、图生成器 (Generators)

16 种随机图生成算法，用于测试、基准和教学：

```moonbit
// 生成一个 100 节点 500 边的随机图
let er = @generators.erdos_renyi(100, 500, true)  // 有向
let ws = @generators.watts_strogatz(100, 4, 0.3)   // 小世界
let ba = @generators.barabasi_albert(100, 2)        // 无标度
```

### 生成器列表

| 生成器 | 模型 | 特点 |
|--------|------|------|
| `erdos_renyi` | G(n,m) / G(n,p) | 经典随机图 |
| `watts_strogatz` | 小世界 | 高聚类 + 短路径 |
| `barabasi_albert` | 无标度 | 幂律度分布 |
| `grid_2d` | 网格 | 规整结构 |
| `complete` | 完全图 | 最密图 |
| `tree` | 随机树 | 无环 |

---

## 二、图算子 (Graph Operators)

对已有图进行变换操作：

```moonbit
let complement = @operators.complement(g)   // 补图
let reversed = @operators.reverse(g)         // 反转有向边
let union = @operators.union(g1, g2)         // 并图
let product = @operators.cartesian(g1, g2)   // 笛卡尔积
```

| 算子 | 用途 |
|------|------|
| `complement` | 图着色下界估计 |
| `reverse` | 逆向关系分析 |
| `union` / `intersection` | 图合并/求交 |
| `cartesian` / `tensor` | 图乘积（网络科学） |

---

## 三、特殊图识别

```moonbit
@recognition.is_bipartite(graph)     // ✅ 是否为二分图
@recognition.is_complete(graph)      // ✅ 是否为完全图
@recognition.is_tree(graph)          // ✅ 是否为树
@recognition.is_regular(graph)       // ✅ 是否为正则图
@recognition.is_chordal(graph)       // ✅ 是否为弦图
```

---

## 四、稠密子图 (Dense Subgraph)

```moonbit
let kcore = @dense.k_core_decomposition(graph, 3)  // 3-核分解
let ktruss = @dense.k_truss(graph, 4)               // 4-truss分解
let triangles = @dense.triangle_count(graph)         // 三角计数
let cc = @dense.clustering_coefficient(graph)        // 聚类系数
```

---

## 五、链接预测 (Link Prediction)

基于局部拓扑相似度的链接预测指标：

```moonbit
let cn = @link_prediction.common_neighbors(g, u, v)
let jc = @link_prediction.jaccard_coefficient(g, u, v)
let aa = @link_prediction.adamic_adar(g, u, v)
let pa = @link_prediction.preferential_attachment(g, u, v)
```

| 指标 | 复杂度 | 直觉 |
|------|:------:|------|
| 共同邻居 (CN) | O(d) | 共同好友越多越可能连接 |
| Jaccard 系数 | O(d) | 归一化的共同邻居 |
| Adamic-Adar | O(d) | 稀有共同好友权重更高 |
| 优先连接 (PA) | O(1) | 度数高的节点更可能获得新连接 |

---

## 六、算法索引

| 模块 | API | 用途 |
|------|:---:|------|
| `@generators.*` | 16 种 | 随机图生成 |
| `@operators.*` | 9 种 | 图变换 |
| `@recognition.*` | 8 种 | 图性质判定 |
| `@dense.*` | 5 种 | 稠密子图分析 |
| `@link_prediction.*` | 5 种 | 链接预测 |
| `@euler.*` | 1 种 | 欧拉路径 |

---

**相关文档：**
- [算法总览](/algorithms/index/)
- [图着色算法](/algorithms/coloring/)
- [欧拉路径](/algorithms/euler/)
