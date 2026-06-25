---
title: A* 启发式搜索
description: 启发式搜索加速最短路径：f=g+h 核心公式、曼哈顿距离、可采纳性、MoonBit 实现与游戏寻路应用
---

# A* 启发式搜索

> 🎯 **本节目标**: 掌握 A* 算法原理、启发函数设计、可采纳性条件及游戏寻路实战
>
> ⏱️ **预计阅读时间**: 30 分钟 | 🎮 **互动演示**: 3 个可运行示例 + open/closed 集追踪

---

## 📖 算法简介

**A\* 算法**（发音: "A-star"）是一种用于在**带权图**中找到**从起点到终点的最短路径**的启发式搜索算法，由 Peter Hart、Nils Nilsson 和 Bertram Raphael 于 1968 年提出。

### 核心思想 💡

想象你是**一名熟悉城市路网的快递员**：

```
🚚 快递员类比:

  Dijkstra 小哥: "我不管目的地在哪，先把周围所有路口都探一遍再说"
                → 🌊🌊🌊🌊🌊🌊🌊🌊 （均匀扩散）

  A* 小哥:      "我知道目的地在东南方向，优先往东南方向探索！"
                → 🌊🌊🌊🌊▶️🎯      （有方向地搜索）
```

A* 就是这位"有方向感"的快递员——它利用**启发信息**指导搜索方向，大幅减少探索的节点数量。

### 为什么叫"A\*"?

| 信息 | 详情 |
|------|------|
| **发明者** | Hart, Nilsson, Raphael（斯坦福研究所） |
| **发表时间** | 1968 年 |
| **论文标题** | "A Formal Basis for the Heuristic Determination of Minimum Cost Paths" |
| **核心公式** | **f(n) = g(n) + h(n)** |
| **时间复杂度** | O(b^d)（取决于启发函数质量），其中 b = 分支因子，d = 深度 |
| **空间复杂度** | O(b^d)（保持 open 集中所有节点） |
| **前置条件** | ⚠️ 所有边权重非负 + 启发函数可采纳 |

### 核心公式：f(n) = g(n) + h(n)

```
f(n) = g(n) + h(n)
        ↑      ↑
    起点到 n   n 到目标
    的实际距离  的估计距离(启发函数)
```

| 符号 | 含义 | 例子 |
|:----:|------|------|
| **g(n)** | 起点到节点 n 的实际最短距离 | `dist["A"] = 5` |
| **h(n)** | 节点 n 到目标的估计距离（启发式） | 曼哈顿距离 `|Δx| + |Δy|` |
| **f(n)** | 经过 n 的预估总距离 | A* 用它排序 open 集 |

### 关键条件：可采纳性 (Admissibility)

**h(n) 永远不低估**实际到达目标的距离时，A* 保证找到最优路径。

| 启发函数 | 可采纳？ | 效果 |
|---------|:--------:|------|
| **曼哈顿距离** | ✅ 是（网格地图） | 经典选择，效率高 |
| **欧几里得距离** | ✅ 是 | 斜向移动 |
| **h(n) = 0** | ✅ 是 | → 退化为 Dijkstra |
| **h(n) 过高** | ❌ 否 | 更快但不保证最优 |

### A* vs Dijkstra 对比

```
搜索空间对比:

  Dijkstra (h=0):     ● ← 搜索边界呈圆形均匀扩散
                     ┌┴┐
                    ◇◇◆◇◇
                   ┌┼┼┼┼┼┐
                  ◇◇◇◆◆◇◇◇

  A* (h=曼哈顿):     ●     ← 搜索边界偏向目标方向
                     │
                   ◇─◆─◇
                     │
                    ┌┘
                  ◇─◆         ← 明显更少的节点
```

| 指标 | Dijkstra | A* |
|:----|:--------:|:--:|
| 搜索方向 | 均匀向四周 | **偏向目标方向** ⭐ |
| 探索节点数 | 更多 | 可减少 **30-90%** |
| 需要启发函数 | ❌ | ✅ |
| 最优性保证 | ✅ 始终 | ✅ **可采纳时** |
| 适用场景 | 单源全目标 | **单源单目标** ⭐ |

---

## 🎬 交互式动画：A* 分步执行过程

### 示例图: 带权有向图

<div class="viz-preview-card">
  <iframe src="/visualizations/a_star/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/a_star/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 配色含义（VisuAlgo 风格）

| 颜色 | 含义 |
|------|------|
| **深棕色** | 起点 (f=0) |
| **橙色** | 当前正在处理的节点（从 open 集取出） |
| **黄色** | 刚发现的节点（加入 open 集待探索） |
| **绿色** | 已处理的节点（移入 closed 集） |
| **红色粗线** | 正在探索的边 |
| **黄色粗线** | 最终最短路径 |
| **灰色虚线** | 已跳过的边（节点已在 closed 集或 g 值未改善） |

### 预期结果

A* 从节点 0 开始搜索，利用启发函数朝目标方向搜索：

```
最终路径: [0, 2, 4, 5]
路径长度: 3 步
搜索节点: 远少于 Dijkstra（利用启发函数缩小搜索范围）
```

---

## 二、算法步骤详解

### 伪代码

```
A*(start, target, heuristic):
  1. openSet = {start}
  2. gScore[start] = 0
  3. fScore[start] = heuristic(start, target)
  
  4. while openSet 不为空:
  5.   current = openSet 中 fScore 最小的节点
  6.   
  7.   if current == target:
  8.     重建路径并返回
  9.   
 10.   openSet.remove(current)
 11.   closedSet.add(current)
 12.   
 13.   for each neighbor of current:
 14.     if neighbor 在 closedSet 中: continue
 15.     tentative_g = gScore[current] + weight(current, neighbor)
 16.     
 17.     if tentative_g < gScore[neighbor]:
 18.       parent[neighbor] = current
 19.       gScore[neighbor] = tentative_g
 20.       fScore[neighbor] = gScore[neighbor] + heuristic(neighbor, target)
 21.       if neighbor 不在 openSet 中:
 22.         openSet.add(neighbor)
 23.   
 24. return 不可达
```

### 分步图解

```
第1步: 起点 S(0) 入 open 集
  open:  [S]      closed:  []
  f[S]=h[S]=曼哈顿距离

第2步: 从 open 取出 S, 探索邻居
  open:  [A(6), B(4)]    closed: [S]
  计算: f[A]=g[A]+h[A]=4+?   f[B]=g[B]+h[B]=2+?

第3步: 选 f 最小的 B(4) 优先探索
  因为 f[B]=2+2=4 < f[A]=4+3=7
  → A* 会先探索"更可能通往目标"的节点
```

---

## 三、启发函数详解

### 常见启发函数

| 启发函数 | 公式 | 适用场景 | 可采纳 |
|:--------|:----:|---------|:------:|
| **曼哈顿距离** | `|Δx| + |Δy|` | 四方向网格 | ✅ |
| **欧几里得距离** | `√(Δx² + Δy²)` | 任意方向 | ✅ |
| **对角线距离** | `max(Δx, Δy)` | 八方向网格 | ✅ |
| **切比雪夫距离** | `max(Δx, Δy)` | 八方向等权 | ✅ |
| **零启发** | `h(n) = 0` | 退化为 Dijkstra | ✅ |

### 启发函数对性能的影响

```
h 的质量 → 搜索效率:

h=0 (Dijkstra):     ●←━━━━━━━━━━━━━━━━→●  搜索所有方向
                    🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊

h 偏低:             ●←━━━━━━━━━━→●   搜索范围缩小
                    🌊🌊🌊🌊🌊🌊🌊

h 准确(理想):       ●━━━━→●           只搜最优路径
                    🌊🌊🌊

h 过高(不可采纳):   ●━→●              更快但不保证最优
                    🌊🌊
```

**经验法则：** 越接近真实距离的启发函数，搜索越少，但计算 h 的开销也越大。实际应用中通常选择**计算简单且可采纳**的启发函数。

---

## 四、MoonBit 完整实现

```moonbit
/// A* 启发式搜索
///
/// 参数:
///   - graph: 实现了 GraphReadable 的图
///   - start: 起点
///   - target: 终点
///   - heuristic: 启发函数 (NodeId) -> Double
///
/// 返回: 最短路径节点序列，不可达返回空数组
pub fn[G : @core.GraphReadable] a_star(
  graph : G,
  start : @core.NodeId,
  target : @core.NodeId,
  heuristic : (@core.NodeId) -> Double,
) -> Array[@core.NodeId] {
  if start == target { return [start] }
  let n = @core.GraphReadable::node_count(graph)
  if n == 0 { return [] }

  // 初始化 g 和 f 分数
  let max_id = max_node_id(graph)
  let size = max_int(max_id + 1, 1)
  let g_score : Array[Double?] = Array::make(size, None)
  let parent : Array[@core.NodeId?] = Array::make(size, None)
  g_score[start.0] = Some(0.0)

  // 优先队列 (按 f 值排序)
  let mut pq = heap_new()
  pq = heap_push(pq, heuristic(start), start)
  let visited : Array[Bool] = Array::make(size, false)

  while !heap_is_empty(pq) {
    let (pq_next, top_opt) = heap_pop(pq)
    pq = pq_next
    match top_opt {
      Some((u, _)) => {
        if u == target {
          return reconstruct_path(parent, start, target)
        }
        if visited[u.0] { continue }
        visited[u.0] = true

        // 松弛操作
        for v in @core.GraphReadable::neighbors(graph, u) {
          let w = @core.GraphReadable::get_edge(graph, u, v)
          match w {
            Some(weight) => {
              let new_g = g_score[u.0].as_or(0.0) + weight
              let old_g = g_score[v.0]
              if old_g == None || new_g < old_g.as_or(0.0) {
                g_score[v.0] = Some(new_g)
                parent[v.0] = Some(u)
                let f = new_g + heuristic(v)
                pq = heap_push(pq, f, v)
              }
            }
            None => ()
          }
        }
      }
      None => ()
    }
  }
  []  // 不可达
}
```

### 关键设计决策

| 决策 | 选择 | 原因 |
|------|------|------|
| **数据结构** | 二叉堆 (Binary Heap) | O(log V) 的 push/pop，生产常用 |
| **visited 数组** | `Array[Bool]` | 防止重复处理已关闭节点 |
| **启发函数** | 用户提供的高阶函数 | 灵活适配不同场景 |
| **路径重建** | parent 数组回溯 | O(d) 重建，d = 路径长度 |

---

## 五、使用示例

### 示例 1：网格地图寻路

```moonbit
fn main {
  // 建网格图
  let mut g = @storage.UndirectedAdjList::new()
  let nodes = [@core.GraphWritable::add_node(g, 0.0); 25]

  // 障碍物位置
  let obstacles : Array[Int] = [6, 7, 13, 17, 18]
  let dirs = [(1, 0), (-1, 0), (0, 1), (0, -1)]
  for y in 0..<5 {
    for x in 0..<5 {
      let id = y * 5 + x
      if obstacles.contains(id) { continue }
      for (dx, dy) in dirs {
        let nx = x + dx; let ny = y + dy
        if nx >= 0 && nx < 5 && ny >= 0 && ny < 5 {
          let nid = ny * 5 + nx
          if !obstacles.contains(nid) {
            let _ = @core.GraphWritable::add_edge(g, nodes[id], nodes[nid], 1.0)
          }
        }
      }
    }
  }

  let start = nodes[0]
  let target = nodes[24]

  // 曼哈顿距离启发函数
  let h = fn(n : @core.NodeId) -> Double {
    let x = n.0 % 5; let y = n.0 / 5
    ((4 - x).abs() + (4 - y).abs()).to_double()
  }

  let path = @shortest_path.a_star(g, start, target, h)
  println("路径长度: \(path.length() - 1)")
  // 输出: 路径长度: 8
}
```

### 示例 2：道路导航（加权图）

```moonbit
// 城市间道路网络 (带权有向图)
// 用欧几里得距离作为启发函数
fn euclidean(a : @core.NodeId, b : @core.NodeId) -> Double {
  // 假设每个节点有坐标 (x, y) 编码在 node data 中
  let ax = a.0 % 10; let ay = a.0 / 10
  let bx = b.0 % 10; let by = b.0 / 10
  let dx = (ax - bx).to_double()
  let dy = (ay - by).to_double()
  (dx * dx + dy * dy).sqrt()
}

// 在道路网上寻路
let path = @shortest_path.a_star(road_network, start, target, euclidean)
```

### 示例 3：h(n)=0 退化为 Dijkstra

```moonbit
// 当启发函数始终返回 0，A* 退化为 Dijkstra
let zero_h = fn(_ : @core.NodeId) -> Double { 0.0 }
let path = @shortest_path.a_star(g, start, target, zero_h)
// 行为等价于 Dijkstra，但效率更低（保持 open 集开销）
```

---

## 六、复杂度分析

| 指标 | 最优情况 | 最差情况 |
|:----|:--------:|:--------:|
| **时间复杂度** | O(b^d) | O(V!) |
| **空间复杂度** | O(b^d) | O(V) |
| **条件** | 完美启发函数 | h(n)=0 (退化为 Dijkstra) |

**b** = 分支因子（每个节点的平均邻居数）
**d** = 最短路径深度

### 对比其他算法

| 算法 | 复杂度 | 约束 | 适用 |
|:----|:------:|:----:|:----:|
| **BFS** | O(V+E) | 无权 | 简单图 |
| **Dijkstra** | O((V+E)log V) | 非负权 | 单源全目标 |
| **A\*** | O(b^d) | 非负权+启发式 | ⭐ 单源单目标 |
| **Bellman-Ford** | O(VE) | 可负权 | 负权检测 |

---

## 七、实际应用场景

| 场景 | 图模型 | 启发函数 | 说明 |
|:----|--------|---------|------|
| **游戏寻路** 🎮 | 网格地图 | 曼哈顿/对角线 | 角色自动寻路 |
| **GPS 导航** 🗺️ | 道路网络 | 欧几里得距离 | 路径规划 |
| **迷宫求解** 🌀 | 网格 | 曼哈顿 | 最短出口路径 |
| **机器人路径规划** 🤖 | 配置空间 | 自定义 | 避障路径 |
| **8 数码问题** 🧩 | 状态空间 | 曼哈顿距离 | 经典 AI 问题 |

---

## 八、练习题

<details>
<summary>⭐ 题 1：为什么 A* 的 open 集用优先队列？</summary>

因为 A* 每次需要从 open 集中取出 **f 值最小**的节点。优先队列（堆）可以在 O(log n) 时间内完成取最小值和插入操作。如果用普通数组，每次查找最小值需要 O(n)，当 open 集很大时性能急剧下降。
</details>

<details>
<summary>⭐⭐ 题 2：如果 h(n) 始终为 0，A* 等价于哪个算法？</summary>

当 h(n) = 0 时，f(n) = g(n)，A* 退化为 **Dijkstra 算法**。搜索边界呈圆形均匀扩散，不再偏向目标方向。
</details>

<details>
<summary>⭐⭐⭐ 题 3：什么情况下 A* 比 Dijkstra 更慢？</summary>

1. **启发函数计算开销大**：如果 h(n) 的计算比它节省的搜索更耗时
2. **目标不明确**：不知道目标在哪，启发函数无法提供有效指导
3. **图上所有节点都几乎等距**：启发函数失去区分度
实际上，**如果 h(n) 的计算开销 > 它节省的节点探索开销**，A* 可能比 Dijkstra 更慢。
</details>

---

**相关文档：**
- [Dijkstra 算法](/algorithms/shortest-path/dijkstra/)
- [Bellman-Ford 算法](/algorithms/shortest-path/bellman-ford/)
- [Floyd-Warshall 算法](/algorithms/shortest-path/floyd-warshall/)
- [图遍历算法](/algorithms/traversal/bfs/)
