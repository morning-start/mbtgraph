---
title: Kruskal 最小生成树
description: 通过排序所有边并贪心选择的最小生成树算法
---

# Kruskal 算法

> **核心思想**: 将所有边按权重排序，贪心连接不同连通分量 \
> **API**: `kruskal(graph)` → `MstResult` \
> **前置**: [Kruskal & Prim 对比详解](/algorithms/mst/kruskal-prim/)

---

## 一、算法原理

Kruskal 算法将所有边按权重从小到大排序，依次检查每条边：

```
边集排序：[0-3(1), 0-1(2), 1-3(3), 1-2(4), 2-3(5), 2-4(6), 3-4(7)]

0-3(1):  加入 → {0} {3} {1} {2} {4}     ← 两个不同分量，连接
0-1(2):  加入 → {0,3} {1} {2} {4}       ← 连接
1-3(3):  跳过 → {0,1,3} 已连通
1-2(4):  加入 → {0,1,2,3} {4}           ← 连接
2-3(5):  跳过 → 已连通
2-4(6):  加入 → {0,1,2,3,4}             ← 所有节点连通，完成!
```

总共 4 条边，总权重 1+2+4+6 = 13。

---

## 二、代码示例

```moonbit
fn main {
  let mut g = @storage.UndirectedAdjList::new()
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 5]
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[1], 2.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[0], nodes[3], 1.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[3], 3.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[1], nodes[2], 4.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[3], 5.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[2], nodes[4], 6.0)
  let _ = @core.GraphWritable::add_edge(g, nodes[3], nodes[4], 7.0)

  let result = @mst.kruskal(g)
  println("MST 总权重: \(result.total_weight)")
  for (u, v, w) in result.edges {
    println("  边 \(u.0)-\(v.0): 权重=\(w)")
  }
}
```

**输出：**
```
MST 总权重: 13.0
  边 0-3: 权重=1.0
  边 0-1: 权重=2.0
  边 1-2: 权重=4.0
  边 2-4: 权重=6.0
```

---

## 三、对比

| 特性 | Kruskal | Prim |
|:----|:-------:|:----:|
| 思路 | 边排序贪心 | 节点扩展 |
| 依赖 | `GraphEdgeIterable` | `GraphReadable` |
| 适用 | ⭐ **稀疏图** | 稠密图 |
| 不连通图 | ✅ 返回森林 | ⚠️ 只返回所在分量 |

---

**相关文档：**
- [Prim 算法](/algorithms/mst/prim/)
- [Kruskal & Prim 对比详解](/algorithms/mst/kruskal-prim/)
