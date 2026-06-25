---
title: "Dinic 算法：最大流（进阶）"
description: "层次图 BFS 分层 + DFS 阻塞流 + 当前弧优化，O(E√V) 时间复杂度，生产环境首选"
---

# ⚡ Dinic 算法：最大流（进阶）

> **"如果说 Edmonds-Karp 是每次只派一个人去探路，那 Dinic 就是先绘制一张完整的'地形图'（层次图），然后一次性派出多支探险队，每队都走到死路为止——效率提升一个数量级。"**

## 📖 目录

- [算法简介](#算法简介)
- [核心概念](#核心概念)
- [动画演示](#动画演示)
- [MoonBit 完整实现](#moonbit-完整实现)
- [代码详解](#代码详解)
- [Dinic vs Edmonds-Karp 深度对比](#dinic-vs-edmonds-karp-深度对比)
- [使用示例](#使用示例)
- [复杂度分析](#复杂度分析)
- [实际应用场景](#实际应用场景)
- [练习题](#练习题)
- [相关资源](#相关资源)
- [总结清单](#总结清单)

---

## 算法简介

### Dinic 是什么？

**Dinic 算法**（也称 Dinitz 算法，1970 年由 Yefim Dinitz 提出）是最大流问题的**高效求解器**。它在 Edmonds-Karp 的基础上做了三个关键优化：

```
┌─────────────────────────────────────────────────────────────┐
│                    Dinic 三大优化                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ① 层次图 (Level Graph)                                     │
│     └─ BFS 一次分层 → 所有后续增广都沿最短路径                 │
│                                                             │
│  ② 阻塞流 (Blocking Flow)                                   │
│     └─ 一次 DFS 找多条增广路 → 不是一条!                     │
│                                                             │
│  ③ 当前弧优化 (Current Arc)                                  │
│     └─ 跳过已检查的饱和边 → 不重复扫描                       │
│                                                             │
│  结果: O(VE²) → O(E√V)，快 10-100 倍!                      │
└─────────────────────────────────────────────────────────────┘
```

### 为什么比 Edmonds-Karp 快？

```
Edmonds-Karp 的工作方式:
  每次找 1 条增广路 → BFS → 增广 → 再 BFS → 再增广 ...
  问题: 同一条路径上的边被反复 BFS 扫描!

Dinic 的工作方式:
  1 次 BFS 构建层次图 → 在上面反复 DFS 增广 → 直到阻塞
       → 再 BFS 重建层次图 → 再 DFS ...
  优势: 每次 BFS 的"成果"被多次利用!
```

### 算法主流程

```
┌──────────────────────────────────────────────────────────┐
│                  DINIC 主循环                              │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  while true:                                             │
│    Phase 1: BFS 构建 level[]                             │
│      ├─ 从 S 出发, 按 BFS 顺序标记每个节点的"层级"         │
│      └─ 若 T 不可达 → 结束, 返回 max_flow                │
│                                                          │
│    Phase 2: DFS 反复找阻塞流                               │
│      ├─ 从 S 出发, 只走 level[v] == level[u] + 1 的边     │
│      ├─ 到达 T → 记录流量, 回溯继续找其他路径              │
│      └─ 无法到达 T 或流量用尽 → 本轮阻塞流完成             │
│                                                          │
│    total_flow += blocking_flow                            │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## 核心概念

### 📐 层次图 (Level Graph)

通过 **BFS** 给每个节点分配一个**层级编号**（距离源点的最短距离）：

```
原始网络:              层次图 (level[]):
                          BFS 后:
   S ──→ A ──→ T           level[S] = 0
   │     │     ↑           level[A] = 1
   ↓     ↓     │           level[B] = 1
   B ──→ C ──┘            level[C] = 2
                           level[T] = 3

关键规则: 增广时只能从 level k 走到 level k+1
          → 保证始终沿最短路径!
```

**性质**：
- `level[S] = 0`（源点在第 0 层）
- 若边 `(u,v)` 有剩余容量且 `level[v] == -1`，则 `level[v] = level[u] + 1`
- **只允许向下一层前进**，不允许后退或平层

### 🚧 阻塞流 (Blocking Flow)

在当前层次图上，**无法再找到任何增广路**时的流状态：

```
层次图中的"阻塞":
  S(0) → A(1) → C(2) → T(3)   ← 这条路还能送 5
  S(0) → B(1) → T(3)           ← 这条路饱和了 (0 剩余)
  S(0) → B(1) → C(2) → T(3)   ← B→C 也饱和了

此时:
  - 从 S 出发, 所有到 T 的路径中至少有一条边饱和
  - 称为"该层次图的阻塞流"
  → 需要重新 BFS 构建新的层次图!
```

**为什么叫"阻塞"？**
> 因为在当前分层结构下，流已经被"堵"到了极限。就像水管系统中某个阀门完全打开后，必须重新调整整体布局才能送更多水。

### 🎯 当前弧优化 (Current Arc Optimization)

这是 Dinic 的**秘密武器**！

```moonbit
// 核心思想: 对每个节点 u 维护一个指针 current_arc[u]
// 表示"下次从 u 出发时，从第 current_arc[u] 条边开始检查"

// 标准 DFS (无优化):
for v in 0..n {        // 每次都从第 0 条边开始!
  check_edge(u, v)     // 已饱和的边重复检查 😩
}

// 当前弧优化 DFS:
let mut i = current_arc[u]  // 从上次停下的位置开始!
while i < n {
  check_edge(u, i)
  i = i + 1
}
current_arc[u] = i          // 记住位置, 下次继续 ✅
```

**效果**：每条边在整个算法执行过程中**最多被检查一次 O(1)**！这是 Dinic 达到 O(VE) 上界的关键。

---

## 动画演示

<div class="viz-preview-card">
  <iframe src="/visualizations/dinic/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/dinic/" target="_blank" class="viz-fullscreen-btn">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
    全屏演示
  </a>
</div>

### 示例网络

使用与 Edmonds-Karp 相同的网络，方便对比：

```
          ┌───[10]──→ ②
         ↗            │ ↓
       [16]         [12]│ [9]
       ↓             ↓  ↓
   (S)① ────→ ③ ────→ (T)④
           [13]

   节点: ①=S(源), ②, ③, ④=T(汇)
   边:   ①→②(cap=10), ①→③(cap=16), ②→③(cap=12),
         ②→④(cap=9), ③→④(cap=13)
```

---

### 🎬 第 1 阶段：BFS 构建层次图

```
Step 1: 初始化
  level[] = [-1, -1, -1, -1]
  队列 = [①(S)]

Step 2: 处理 ① (level=0)
  ①→②: 剩余=10 > 0, level[②]=-1 → level[②]=1, 入队
  ①→③: 剩余=16 > 0, level[③]=-1 → level[③]=1, 入队
  队列 = [②, ③]

Step 3: 处理 ② (level=1)
  ②→③: 剩余=12 > 0, 但 level[③]!=-1 (已有level) → 跳过
  ②→④: 剩余=9 > 0, level[④]=-1 → level[④]=2, ⚡ 到达 T!
  返回成功!

最终层次图:
  level[①(S)] = 0
  level[②]     = 1
  level[③]     = 1
  level[④(T)]  = 2

可视化:
  Layer 0:   ①(S)
               ↙   ↘
  Layer 1:  ②     ③
               ↘   ↙
  Layer 2:   ④(T)
```

---

### 🎬 第 1 阶段：DFS 寻找阻塞流（第 1 次）

```
初始状态:
  flow 全为 0
  current_arc[] = [0, 0, 0, 0]

DFS(①, min_cap=∞):
  从 current_arc[①]=0 开始检查邻居:

  检查 ①→② (v=0): level[②]=1 == level[①]+1 ✓, 剩余=10 > 0 ✓
    → 递归 DFS(②, min_cap=min(∞,10)=10)

    DFS(②, min_cap=10):
      检查 ②→③ (v=0): level[③]=1 ≠ level[②]+1(=2) ✗ (同层!)
        → 跳过 (不满足层次约束)
      检查 ②→④ (v=1): level[④]=2 == level[②]+1 ✓, 剩余=9 > 0 ✓
        send = min(10, 9) = 9
        → 递归 DFS(④, min_cap=9)

        DFS(④, min_cap=9):
          u == sink! → return 9 ✅

      回到 ②: pushed = 9
        flow[②][4] += 9  → 9
        flow[4][2] -= 9  → -9
        total_sent = 9, remaining = 10-9 = 1
        current_arc[②] = 1  (记住位置!)

      继续检查 ② 的下一个邻居... 没有
      → return 9

  回到 ①: pushed = 9
    flow[①][2] += 9  → 9
    flow[2][1] -= 9  → -9
    total_sent = 9, remaining = ∞-9 = ∞
    current_arc[①] = 0  (还要继续!)

  继续检查 ① 的下一条边:

  检查 ①→③ (v=1): level[③]=1 == level[①]+1 ✓, 剩余=16 > 0 ✓
    send = min(∞, 16) = 16
    → 递归 DFS(③, min_cap=16)

    DFS(③, min_cap=16):
      检查 ③→④ (v=0): level[④]=2 == level[③]+1 ✓, 剩余=13 > 0 ✓
        send = min(16, 13) = 13
        → 递归 DFS(④, min_cap=13)
          → return 13 ✅

      回到 ③: pushed = 13
        flow[3][4] += 13 → 13
        flow[4][3] -= 13 → -13
        total_sent = 13, remaining = 16-13 = 3
        current_arc[③] = 1

      检查 ③ 的下一个邻居... ③ 只有到 ④ 的出边
      → return 13

  回到 ①: pushed = 13
    flow[①][3] += 13 → 13
    flow[3][1] -= 13 → -13
    total_sent = 9+13 = 22, remaining = ∞-22 = ∞
    current_arc[①] = 2

  ① 没有更多邻居了
  → return 22

🎉 第 1 次 DFS 推送了 22 单位流量!
   路径 1: ①→②→④ (9 单位)
   路径 2: ①→③→④ (13 单位)

total_flow = 22
```

---

### 🎬 第 1 阶段：DFS 第 2 次 — 尝试继续增广

```
DFS(①, min_cap=∞):
  从 current_arc[①]=2 开始 (上次停在 v=2)

  检查 v=2: ①→? ① 的邻居只有 ②(v=0), ③(v=1)
    v=2 已经超出范围!
  → return 0 (没有可推送的流量)

⛔ 第 2 次 DFS 推送 0 → 阻塞流达成!
  第 1 阶段结束, total_flow = 22
```

---

### 🎬 第 2 阶段：BFS 重建层次图

```
当前残差:

  ①→②: 10-9 = 1    ①→③: 16-13 = 3
  ②→③: 12-0 = 12   ②→④: 9-9 = 0 (饱和!)
  ③→④: 13-13 = 0 (饱和!)

BFS 从 ①:
  level[①] = 0
  队列 = [①]

  处理 ①:
    ①→②: 剩余=1 > 0, level[②]=-1 → level[②]=1, 入队
    ①→③: 剩余=3 > 0, level[③]=-1 → level[③]=1, 入队

  处理 ② (level=1):
    ②→③: 剩余=12 > 0, level[③]!=-1 → 跳过 (已在队列/已访问)
    ②→④: 剩余=0 → 跳过 (无剩余容量)

  处理 ③ (level=1):
    ③→④: 剩余=0 → 跳过 (无剩余容量)

  队列空! 未能到达 T(④)!
  can_reach = false

⛔ BFS 无法到达汇点 → 算法终止!

🎉 最终 MAX_FLOW = 22
```

---

### 📊 完整执行过程汇总

```
═══════════════════════════════════════════════════════
              DINIC 执行总览
═══════════════════════════════════════════════════════

  【Phase 1】
  ┌─────────────────────────────────────────────────┐
  │ BFS 分层: level=[0, 1, 1, 2]                   │
  │                                                  │
  │  DFS #1:                                        │
  │    ①→②→④  bottleneck=9  ✓                      │
  │    ①→③→④  bottleneck=13 ✓                      │
  │    总推送: 22                                    │
  │                                                  │
  │  DFS #2:                                        │
  │    从 current_arc[①]=2 开始 → 无可用边          │
  │    推送: 0  (阻塞!)                              │
  │                                                  │
  │  Phase 1 贡献: +22                               │
  └─────────────────────────────────────────────────┘

  【Phase 2】
  ┌─────────────────────────────────────────────────┐
  │ BFS 分层: ①→②(剩1), ①→③(剩3)                   │
  │          ② 和 ③ 都无法到达 ④ (全部饱和!)        │
  │                                                  │
  │  ⛔ T 不可达 → 终止                              │
  │                                                  │
  │  Phase 2 贡献: +0                                │
  └─────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════
  最终结果: MAX_FLOW = 22
  总 BFS 次数: 2 (vs Edmonds-Karp 的 5 次!)
  总 DFS 次数: 2 (vs Edmonds-Karp 的 5 次单次增广!)
═══════════════════════════════════════════════════════
```

---

### 🔁 与 Edmonds-Karp 的对比（同一网络）

```
┌──────────────────┬──────────────────┬──────────────────┐
│                  │  Edmonds-Karp    │  Dinic            │
├──────────────────┼──────────────────┼──────────────────┤
│ BFS/构建次数      │  5 次            │  2 次            │
│ 增广次数          │  5 次 (各1条路)   │  1次DFS送2条路   │
│ 边检查次数        │  多次重复         │  当前弧跳过      │
│ 最终结果          │  MAX_FLOW=22     │  MAX_FLOW=22     │
│ 效率感知          │  较慢             │  ⚡ 快!           │
└──────────────────┴──────────────────┴──────────────────┘

两者结果一致 (都是最优解!), 但 Dinic 用更少的迭代达到目标。
```

---

## MoonBit 完整实现

以下是 mbtgraph 中 Dinic 的完整实现：

```moonbit
///|
/// Dinic 最大流算法
///
/// 使用 BFS 构建层次图 + DFS 寻找阻塞流，时间复杂度 O(E√V)。
/// 比 Edmonds-Karp (O(VE²)) 快一个数量级，适合大规模密集网络。
///|

// 矩阵深拷贝 (保证纯函数语义)
fn dinic_deep_copy(src : Array[Array[Double]]) -> Array[Array[Double]] {
  let result : Array[Array[Double]] = []
  for i in 0..<src.length() {
    let row : Array[Double] = []
    for j in 0..<src[i].length() {
      row.push(src[i][j])
    }
    result.push(row)
  }
  result
}

// BFS 构建层次图
fn dinic_bfs(
  capacity : Array[Array[Double]],
  flow : Array[Array[Double]],
  n : Int,
  source : Int,
  sink : Int,
) -> (Array[Int], Bool) {
  let level : Array[Int] = Array::make(n, -1)
  level[source] = 0
  let queue : Array[Int] = [source]
  let mut head = 0

  while head < queue.length() {
    let u = queue[head]
    head = head + 1
    let mut v = 0
    while v < n {
      if level[v] == -1 {
        let residual = capacity[u][v] - flow[u][v]
        if residual > 0.000001 {
          level[v] = level[u] + 1
          if v == sink {
            return (level, true)  // 提前退出: 到达汇点即可
          }
          queue.push(v)
        }
      }
      v = v + 1
    }
  }

  (level, level[sink] != -1)
}

// DFS 在层次图上寻找阻塞流 (含当前弧优化)
fn dinic_dfs(
  u : Int,
  sink : Int,
  min_cap : Double,
  capacity : Array[Array[Double]],
  flow_ref : Array[Array[Double]],
  level : Array[Int],
  current_arc : Array[Int],
  n : Int,
) -> Double {
  // 到达汇点: 成功找到一条增广路
  if u == sink {
    return min_cap
  }

  let mut total_sent = 0.0
  let mut remaining = min_cap
  let mut i = current_arc[u]

  // 从 current_arc[u] 开始, 跳过之前已检查的边
  while i < n {
    let v = i
    let residual = capacity[u][v] - flow_ref[u][v]

    // 关键双重条件:
    // 1. 有剩余容量
    // 2. 满足层次约束 (只走向下一层)
    if residual > 0.000001 && level[v] == level[u] + 1 {
      let send_cap = if remaining < residual { remaining } else { residual }
      let pushed = dinic_dfs(
        v, sink, send_cap, capacity, flow_ref, level, current_arc, n,
      )
      if pushed > 0.000001 {
        flow_ref[u][v] = flow_ref[u][v] + pushed
        flow_ref[v][u] = flow_ref[v][u] - pushed
        total_sent = total_sent + pushed
        remaining = remaining - pushed
        if remaining <= 0.000001 {
          // 本次 DFS 的容量已用完, 记住位置, 下次继续
          current_arc[u] = i
          return total_sent
        }
      }
    }
    i = i + 1
  }

  // u 的所有边都已检查完毕
  current_arc[u] = i
  total_sent
}

// 公开 API
pub fn dinic(graph : FlowNetwork, source : Int, sink : Int) -> MaxFlowResult {
  let n = graph.node_count

  // 边界检查
  if n == 0 ||
    source < 0 || source >= n ||
    sink < 0 || sink >= n ||
    source == sink {
    return MaxFlowResult::{ max_flow: 0.0, flow_matrix: [] }
  }

  let work_flow = dinic_deep_copy(graph.flow)
  let mut total_flow = 0.0

  // 外层循环: 反复构建层次图
  while true {
    let (level, can_reach) = dinic_bfs(
      graph.capacity, work_flow, n, source, sink
    )

    if !can_reach {
      break  // 汇点不可达 → 最大流已达到
    }

    // 内层循环: 在当前层次图上反复 DFS 直到阻塞
    let current_arc : Array[Int] = Array::make(n, 0)

    while true {
      let pushed = dinic_dfs(
        source,
        sink,
        1000000000000000000.0,  // "无限大" 初始容量
        graph.capacity,
        work_flow,
        level,
        current_arc,
        n,
      )
      if pushed <= 0.000001 {
        break  // 阻塞流达成
      }
      total_flow = total_flow + pushed
    }
  }

  // 构建结果矩阵
  let result_matrix : Array[Array[Double?]] = []
  for i in 0..<n {
    let row : Array[Double?] = []
    for j in 0..<n {
      if work_flow[i][j] > 0.000001 {
        row.push(Some(work_flow[i][j]))
      } else {
        row.push(None)
      }
    }
    result_matrix.push(row)
  }

  MaxFlowResult::{ max_flow: total_flow, flow_matrix: result_matrix }
}
```

---

## 代码详解

### 设计决策 1️⃣：为什么 BFS 可以提前返回？

```moonbit
if v == sink {
  return (level, true)  // 提前退出: 到达汇点即可
}
```

**原因**：我们只需要确认**存在**从 S 到 T 的路径，以及每个节点的**最小层级**。不需要完整的 BFS 遍历。

**效果**：在实际稀疏图中，这可以显著减少 BFS 的工作量（一旦到达 T 就停止扩展）。

### 设计决策 2️⃣：DFS 如何实现"多路增广"？

```moonbit
fn dinic_dfs(u, ...) -> Double {
  // ...
  while i < n {           // ← 不是 if, 是 while!
    if find_augmenting_path() {
      total_sent += pushed
      remaining -= pushed
      if remaining <= 0 {
        return total_sent  // ← 不直接返回! 继续 try 下一条边!
      }
    }
    i = i + 1
  }
  total_sent  // ← 返回本轮所有增广路的总流量
}
```

**对比 Edmonds-Karp**：
| | Edmonds-Karp | Dinic |
|--|-------------|-------|
| 每次 DFS/BFS 返回 | 1 条路径的瓶颈 | **多条路径的总流量** |
| 找到路径后 | 立即返回，重新 BFS/DFS | **回溯继续搜索其他路径** |
| 一轮主循环的产出 | 1 个单位的增量 | **一个阻塞流的全部增量** |

### 设计决策 3️⃣：当前弧优化的精妙之处

```moonbit
let mut i = current_arc[u]  // 从上次停下处开始
while i < n {
  // ... 检查边 (u, i) ...
  i = i + 1
}
current_arc[u] = i  // 记住位置
```

**不变量**：在 DFS 的某一层节点 u 上，`current_arc[u]` 之前的所有边要么：
1. **已饱和**（`residual ≤ 0`），或
2. **违反层次约束**（`level[v] ≠ level[u]+1`），且在本 phase 中不会改变

因此**安全跳过**！

**性能影响**：将内层循环从 O(E) 降低到均摊 O(1)/次调用，是 Dinic 达到 O(VE) 的核心。

### 设计决策 4️⃣：为什么 Dinic 比 EK 快这么多？

```
理论分析 (单位网络特例):

Edmonds-Karp:
  每次增广使最短路径长度 ≥ 1
  最短路径最长 = V-1
  增广次数 = O(VE)
  每次增广 BFS = O(V+E)
  总计 = O(VE × (V+E)) = O(V²E + VE²)

Dinic:
  每个 phase 使最短路径长度 ≥ 1 (与 EK 相同)
  但每个 phase 内可以多次增广!
  phase 数量 = O(V) (同上界)
  每个 phase 内的工作 = O(所有边的当前弧扫描) = O(E)
  总计 = O(VE)

关键区别:
  EK: 每次增广都要一次 BFS → O(VE) 次 BFS
  Dinic: 每 O(VE) 次增广才需要一次 BFS → O(V) 次 BFS
  → BFS 次数减少 O(√V) 倍!
```

---

## Dinic vs Edmonds-Karp 深度对比

### 代码结构对比

```
┌─────────────────────────────────────────────────────────────┐
│                   EDMONDS-KARP 结构                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  while true:                                                │
│    bfs() → (parent, found)         ← 每次找 1 条路         │
│    if !found: break                                       │
│    bottleneck = calc_bottleneck(parent)                     │
│    augment(parent, bottleneck)                               │
│    total_flow += bottleneck                                 │
│                                                             │
│  → 简单直观, 但 BFS 频繁                                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      DINIC 结构                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  while true:                                                │
│    bfs_level() → (level[], can_reach)  ← 构建层次图        │
│    if !can_reach: break                                    │
│                                                             │
│    init_current_arc()                                      │
│    while true:                                             │
│      dfs_send(source, INF)           ← 可能送多条路!        │
│      if pushed <= 0: break          ← 阻塞                │
│      total_flow += pushed                                  │
│                                                             │
│  → BFS 少, DFS 多, 当前弧加速                              │
└─────────────────────────────────────────────────────────────┘
```

### 数据结构对比

| 方面 | Edmonds-Karp | Dinic |
|------|--------------|-------|
| **路径记录** | `parent[]` (单路径) | `level[]` (全局分层) |
| **遍历策略** | BFS 每次找 1 条路 | BFS 分层 + DFS 多路 |
| **边访问优化** | 无 | `current_arc[]` |
| **DFS 返回值** | 不适用 | **多条路总流量** |
| **终止条件** | BFS 找不到路 | BFS 到不了 T |

### 适用场景选择

```
选择 Edmonds-Karp 当:
  ✅ 学习最大流概念 (最易理解)
  ✅ 图规模小 (V < 100)
  ✅ 需要逐步调试中间过程
  ✅ 代码简洁性优先

选择 Dinic 当:
  ✅ 生产环境 / 大规模数据 (V > 1000)
  ✅ 二分图匹配 (O(E√V) 特性)
  ✅ 需要多次求解最大流
  ✅ 性能至关重要
```

---

## 使用示例

### 示例 1：基础用法 — 与 Edmonds-Karp 对比

```moonbit
use lib.algo.flow.{dinic, edmonds_karp, FlowNetwork}

fn main {
  // 构建相同的网络
  let net = FlowNetwork::new(4)
  let net = net.add_edge(0, 1, 10.0)
  let net = net.add_edge(0, 2, 16.0)
  let net = net.add_edge(1, 2, 12.0)
  let net = net.add_edge(1, 3, 9.0)
  let net = net.add_edge(2, 3, 13.0)

  // 两种方法计算
  let ek_result = edmonds_karp(net, 0, 3)
  let dinic_result = dinic(net, 0, 3)

  println("Edmonds-Karp: ${ek_result.max_flow}")
  println("Dinic:         ${dinic_result.max_flow}")
  // 两者都应该输出: 22.0

  // 验证一致性
  if ek_result.max_flow - dinic_result.max_flow |> abs() < 0.001 {
    println("✅ 两种算法结果一致!")
  }
}
```

### 示例 2：二分图最大匹配（Dinic 优势场景）

```moonbit
// 使用 Dinic 求解二分图最大匹配
// 对于单位容量网络, Dinic 达到 O(E√V) 最优复杂度

fn bipartite_matching_dinic(
  left_count : Int,
  right_count : Int,
  edges : Array[Tuple2[Int, Int]],
) -> Int {
  let s = left_count + right_count       // Source
  let t = s + 1                            // Sink
  let n = t + 1
  let mut net = FlowNetwork::new(n)

  // S → 左侧节点 (容量 1)
  let mut i = 0
  while i < left_count {
    let net = net.add_edge(s, i, 1.0)
    i = i + 1
  }

  // 右侧节点 → T (容量 1)
  let mut j = 0
  while j < right_count {
    let net = net.add_edge(left_count + j, t, 1.0)
    j = j + 1
  }

  // 匹配边 (左侧 → 右侧, 容量 1)
  for edge in edges {
    let net = net.add(edge.0, left_count + edge.1, 1.0)
  }

  let result = dinic(net, s, t)
  result.max_flow |> int()
}

// 大规模测试: 500 左侧 × 500 右侧, 2000 条边
let large_edges : Array[Tuple2[Int, Int]] = []
let mut k = 0
while k < 2000 {
  large_edges.push((k % 500, (k * 7) % 500))
  k = k + 1
}

let start_time = /* 记录时间 */
let match_count = bipartite_matching_dinic(500, 500, large_edges)
let end_time = /* 记录时间 */
println("最大匹配数: ${match_count}, 耗时: ${end_time - start_time}ms")
```

### 示例 3：多源多汇转换

```moonbit
// 将多源多汇问题转换为标准单源单汇问题
//
// 原问题: 从 sources[] 中任意节点出发, 到 sinks[] 中任意节点
// 转换: 新增超级源 S' 和超级汇 T'
//   S' → 每个 source (容量 = ∞)
//   每个 sink → T' (容量 = ∞)

fn multi_source_multi_sink_maxflow(
  net : FlowNetwork,
  sources : Array[Int],
  sinks : Array[Int],
) -> Double {
  let n = net.node_count + 2  // +S' +T'
  let super_source = net.node_count
  let super_sink = net.node_count + 1

  // 创建扩展网络 (这里简化: 假设原网络已包含 S'/T')
  // 实际实现需要复制原网络并添加超节点边...

  // 使用 Dinic 求解
  let result = dinic(net, super_source, super_sink)
  result.max_flow
}

// 应用: 应急物资调度
// sources = 各仓库, sinks = 各医院
// 边 = 仓库→医院的道路 (容量 = 道路运力)
// S'→仓库边容量 = 库存, 医院→T'边容量 = 需求
let warehouses = [0, 1, 2]   // 3 个仓库
let hospitals = [3, 4, 5]   // 3 家医院
// ... 构建网络 ...
// let max_supply = multi_source_multi_sink_maxflow(net, warehouses, hospitals)
```

---

## 复杂度分析

### 时间复杂度：O(E V²) 一般情况，O(E√V) 单位网络

| 阶段 | 操作 | 复杂度 | 次数 |
|------|------|--------|------|
| **外层 BFS** | 构建层次图 | O(V + E) | O(V) 次 |
| **内层 DFS** | 发送阻塞流 | O(VE) (当前弧优化) | 每个 phase 1 次 |
| **总计 (一般)** | | **O(E V²)** | |
| **总计 (单位网络)** | | **O(E√V)** | |

**什么是单位网络？**
- 所有边容量为 1
- 此时每个 phase 至少使最短路径长度 +1
- 且每个 phase 的阻塞流可以在 O(E) 内完成
- 总复杂度降至 O(E√V)

### 空间复杂度：O(V²)

| 数据结构 | 用途 | 大小 |
|---------|------|------|
| `capacity[][]` | 容量矩阵 | O(V²) |
| `flow[][]` | 流量矩阵 | O(V²) |
| `level[]` | 层级标记 | O(V) |
| `current_arc[]` | 当前弧指针 | O(V) |
| BFS 队列 | O(V) | O(V) |
| **总计** | | **O(V²)** |

### 与其他算法全面对比

```
┌────────────────┬───────────────┬───────────────┬──────────────────────┐
│    算法        │  时间复杂度    │  空间复杂度    │  最佳场景            │
├────────────────┼───────────────┼───────────────┼──────────────────────┤
│ Ford-Fulkerson │ O(E·max_flow)│ O(V²)        │ 小图, 整数容量      │
│ Edmonds-Karp   │ O(V·E²)       │ O(V²)        │ 学习, 通用          │
│ **Dinic**       │ **O(E·V²)**   │ O(V²)        │ **生产, 二分图**    │
│ Push-Relabel   │ O(V³)         │ O(V²)        │ 大规模, 并行        │
│ HLPP           │ O(V²√E)       │ O(V²)        │ 理论最优 (实际也快) │
└────────────────┴───────────────┴───────────────┴──────────────────────┘
```

---

## 实际应用场景

### 🏭 场景 1：大型二分图匹配

**问题**：求职平台将 10 万求职者匹配到 5 万岗位

**解决方案**：转化为单位容量网络，使用 Dinic 的 O(E√V) 优势

**实例**：Hopcroft-Karp 算法的替代方案

### 🌐 场景 2：网络路由调度

**问题**：数据中心每天处理 TB 级数据迁移，需要在数千台服务器间规划最大吞吐路径

**解决方案**：Dinic 的多路增广特性天然适合密集连接的网络拓扑

### 🎮 场景 3：游戏服务器匹配

**问题**：MOBA 游戏中 10 名玩家 vs 10 名玩家的公平对局匹配

**解决方案**：技能评分约束的二分图匹配，Dinic 可在毫秒级完成

### 📊 场景 4：图像分割（快速近似）

**问题**：实时视频流的背景/前景分离

**解决方案**：基于 Graph Cut 的图像分割，Dinic 提供快速的最大流-最小割求解

---

## 练习题

### 练习 1：手动执行 Dinic 算法 ⭐⭐

对以下网络手动执行 Dinic（S=0, T=3），写出：

1. 第一次 BFS 的 `level[]`
2. 第一次 DFS 的详细过程（包括 `current_arc` 变化）
3. 是否需要第二次 BFS？

```
  0 ──[3]──→ 1 ──[2]──→ 3
  │                       ↑
  └──[2]──→ 2 ──[3]──────┘
```

<details>
<summary>📖 参考答案</summary>

```
Phase 1 - BFS:
  level[0]=0, level[1]=1, level[2]=1, level[3]=2
  (与 EK 相同的最短路径结构)

Phase 1 - DFS #1:
  current_arc[0]=0: 检查 0→1 (level ok, 剩余=3)
    DFS(1): 检查 1→3 (level ok, 剩余=2)
      → 到达 T! pushed=min(∞,3,2)=2
    回溯: flow[0][1]+=2, flow[1][3]+=2
    remaining=∞-2=∞, continue
  current_arc[0]=1: 检查 0→2 (level ok, 剩余=2)
    DFS(2): 检查 2→3 (level ok, 剩余=3)
      → 到达 T! pushed=min(∞,2,3)=2
    回溯: flow[0][2]+=2, flow[2][3]+=2
    remaining=∞-2=∞, continue
  current_arc[0]=2: 超出范围
  → return 4

Phase 1 - DFS #2:
  current_arc[0]=2 → 超出范围 → return 0 (阻塞!)

Phase 2 - BFS:
  0→1: 剩余=3-2=1 > 0, level[1] 重置?
  0→2: 剩余=2-2=0 (饱和!)
  1→3: 剩余=2-2=0 (饱和!)
  2→3: 剩余=3-2=1 > 0, 但 0→2 已饱和, 2 无法被到达!

  实际 BFS: 0→1(剩1), 然后 1→? 1→3 饱和
  → T 不可达!

MAX_FLOW = 4 (与 EK 结果一致, 仅需 1 次 BFS!)
```

</details>

---

### 练习 2：实现 Dinic 的迭代器版本 ⭐⭐⭐

当前 mbtgraph 实现使用邻接矩阵 (`while v < n`)。请改写为**邻接表 + 迭代器**版本：

```moonbit
// 要求:
// 1. 使用 EdgeList 存储边 (from, to, capacity)
// 2. BFS/DFS 只遍历实际存在的边 (不是 O(n²) 枚举)
// 3. 保持当前弧优化
// 4. 分析在稀疏图 (E << V²) 上的性能提升
```

<details>
<summary>💡 提示</summary>

```moonbit
// 邻接表版的核心变化:

struct DinicEdge {
  to : Int
  rev : Int    // 反向边在邻接表中的索引
  cap : Double
  flow : Double
}

// BFS: 遍历 adj[u] 而非 0..n
fn dinic_bfs_adjlist(adj : Array[Array[DinicEdge]], ...) {
  for edge in adj[u] {
    let v = edge.to
    if level[v] == -1 && edge.cap - edge.flow > 0 {
      level[v] = level[u] + 1
      // ...
    }
  }
}

// DFS 类似: for i in current_arc[u]..adj[u].length()
```

**稀疏图性能**: 从 O(V²) per BFS 降低到 O(V+E)，当 E=O(V) 时提升 **O(V) 倍**。

</details>

---

### 练习 3：利用 Dinic 求解最小割 ⭐⭐⭐⭐

给定一个流网络，不仅要求最大流，还要求找出**一个具体的割集**（最小割的边集）：

**输入**：任意流网络 (source, sink)
**输出**：
1. 最大流值
2. 最小割容量（应等于最大流值）
3. 割集的具体边列表

**提示**：最后一次成功的 BFS 产生的 `level[]` 数组包含了关键信息。

<details>
<summary>📖 解题思路</summary>

```moonbit
fn find_min_cut(
  graph : FlowNetwork,
  source : Int,
  sink : Int,
) -> Tuple3[Double, Double, Array[Tuple2[Int, Int]]] {
  let result = dinic(graph, source, sink)

  // 最后一次 BFS 的 level[] 将节点分为两组:
  //   S 集: level[v] != -1 (从 source 可达, 在残差图中)
  //   T 集: level[v] == -1 (不可达)

  // 重建最后一次 BFS:
  let (final_level, _) = dinic_bfs_final(
    graph.capacity, result_flow, n, source, sink
  )

  let mut cut_edges : Array[Tuple2[Int, Int]] = []
  let mut cut_capacity = 0.0

  for u in 0..n {
    if final_level[u] != -1 {  // u 在 S 集
      for v in 0..n {
        if final_level[v] == -1 {  // v 在 T 集
          if graph.capacity[u][v] > 0.0 {
            cut_edges.push((u, v))
            cut_capacity = cut_capacity + graph.capacity[u][v]
          }
        }
      }
    }
  }

  (result.max_flow, cut_capacity, cut_edges)
}

// 验证: max_flow == cut_capacity (最大流最小割定理)
```

**应用**：网络可靠性分析（哪些边是"关键边"，断了就会降低最大吞吐量）。

</details>

---

## 相关资源

### 📚 推荐阅读

| 资源 | 类型 | 说明 |
|------|------|------|
| *Original Paper* | 论文 | Y. Dinitz, "Algorithm for solution of a problem of maximum flow," 1970 |
| *Dinic's Website* | 个人页 | https://www.cs.bgu.ac.il/~dinitz/ |
| *TopCoder* | 教程 | "Maximum Flow: Dinic" Tutorial |
| *EK 对比教程* | 本站文档 | [/algorithms/flow/max-flow/edmonds-karp](/algorithms/flow/max-flow/edmonds-karp) |

### 🔗 相关算法

```
Dinic (本文)
  ├── Edmonds-Karp      → 入门版最大流
  ├── Push-Relabel (HLPP) → 理论与实践皆优
  ├── Hopcroft-Karp       → 二分图匹配专用 (基于 Dinic 思想)
  ├── 最小费用最大流       → 扩展: 带成本的流
  └── 最小割               → 最大流的对偶问题
```

### 🛠️ mbtgraph 相关源码

| 文件 | 说明 |
|------|------|
| [`lib/algo/flow/dinic.mbt`](../../../lib/algo/flow/dinic.mbt) | Dinic 核心实现 |
| [`lib/algo/flow/edmonds_karp.mbt`](../../../lib/algo/flow/edmonds_karp.mbt) | Edmonds-Karp 实现 (对比参考) |
| [`lib/algo/flow/flow_network.mbt`](../../../lib/algo/flow/flow_network.mbt) | `FlowNetwork` 类型定义 |
| [`lib/algo/flow/types.mbt`](../../../lib/algo/flow/types.mbt) | `MaxFlowResult` 类型定义 |

---

## 总结清单

### ✅ 核心知识点

- [ ] **层次图 (Level Graph)**：BFS 分层，保证增广沿最短路径
- [ ] **阻塞流 (Blocking Flow)**：当前分层下无法再增广的流状态
- [ ] **当前弧优化 (Current Arc)**：跳过已检查边，均摊 O(1)/边
- [ ] **时间复杂度**：O(EV²) 一般，O(E√V) 单位网络
- [ ] **vs Edmonds-Karp**：少 O(√V) 次 BFS，多路增广

### 🔑 关键代码模式

```moonbit
// Dinic 双层循环
while true {
  let (level, can_reach) = bfs_level(...)  // 1. 分层
  if !can_reach { break }
  reset_current_arc()
  while true {
    let pushed = dfs_send(source, INF, ...)  // 2. 多路增广
    if pushed <= 0 { break }  // 阻塞
    total_flow += pushed
  }
}
```

### ⚠️ 常见陷阱

| 陷阱 | 后果 | 解决方法 |
|------|------|---------|
| DFS 忽略层次约束 | 可能走非最短路径 | 必须 `level[v] == level[u] + 1` |
| 忘记重置 `current_arc` | 新 phase 使用旧指针 | 每次 BFS 后 `Array::make(n, 0)` |
| 浮点精度误差 | 死循环 | ε = 10⁻⁶ 阈值 |
| `min_cap` 参数未正确传递 | 递归链路容量错误 | 每层取 `min(remaining, residual)` |
| 混淆 Dinic 与 EK 的 parent[] | 错误理解路径记录 | Dinic 用 `level[]` 非 `parent[]` |

### 📊 最大流算法选型速查

```
┌──────────────┬───────────┬───────────┬──────────────────────┐
│    场景        │  推荐      │  备选      │  避免使用          │
├──────────────┼───────────┼───────────┼──────────────────────┤
│ 学习/教学     │ EK        │ Dinic     │ Push-Relabel (复杂) │
│ 生产环境       │ Dinic     │ HLPP      │ EK (慢)           │
│ 二分图匹配     │ Dinic     │ HC-Karp   │ EK (太慢)          │
│ 超大规模 (>10⁵)│ HLPP      │ Dinic     │ Ford-Fulkerson     │
│ 单位容量网络   │ Dinic ⭐⭐ │ HC-Karp   │ EK                 │
└──────────────┴───────────┴───────────┴──────────────────────┘
```

---

<div align="center">

**⚡ Dinic 算法 — 层次图 + 阻塞流，生产级最大流**

*上一篇：[Edmonds-Karp](/algorithms/flow/max-flow/edmonds-karp) | [返回网络流目录](/algorithms/flow)*

</div>
