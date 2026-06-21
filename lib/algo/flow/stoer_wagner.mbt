/// Stoer-Wagner 全局最小割算法
///
/// 由 Stoer & Wagner（1997）提出的确定性多项式时间算法，
/// 用于求解无向带权图的全局最小割 (Global Minimum Cut) 问题。
/// 算法基于一个关键定理：全局最小割必然在某一阶段的
/// 最大邻接搜索 (Maximum Adjacency Search, MAS) 中被找到。
///
/// # 核心思想
///
/// 每次迭代执行 MAS（类似 Prim MST 的贪心选择）:
/// 1. 从任意顶点开始，每次选择与已选集合连接最紧密的未选顶点加入
/// 2. 最后加入的顶点 s 与倒数第二个顶点 t 之间的割即为当前阶段的最小 s-t 割
/// 3. 合并 s 和 t 为超节点（边权累加），图规模减 1
/// 4. 重复 n-1 次，记录所有阶段中权重最小的割
///
/// # 与最大流的关系
///
/// 全局最小割 = min_{s≠t} min-cut(s,t)。Stoer-Wagner 不需要枚举所有 s-t 对，
/// 通过收缩策略保证最优割必在某阶段出现。

///|
/// Stoer-Wagner 结果
pub(all) struct StoerWagnerResult {
  /// 最小割的权重（即割集中所有边的权重之和）
  min_cut_weight : Double
  /// 割的一侧（另一侧为补集），包含该侧所有原始顶点编号
  partition : Array[Int]
}

///|
/// Stoer-Wagner 全局最小割算法
///
/// 求解无向带权图的全局最小割问题。
///
/// # 数学形式
///
/// 给定无向带权图 G = (V, E, w)，求将 V 划分为两个非空子集 S 和 T，
/// 使得割集 δ(S,T) 的总权重最小:
///   min Σ_{(u,v)∈E, u∈S, v∈T} w(u,v)
///   s.t. S ∪ T = V, S ∩ T = ∅, S ≠ ∅, T ≠ ∅
///
/// # 参数
///
/// - `adj`: n × n 对称邻接矩阵，adj[i][j] 表示顶点 i 与 j 之间的边权重。
///   无边时值为 0。要求对称性: adj[i][j] == adj[j][i]。
///   n ≤ 1 时返回空结果。
///
/// # 返回
///
/// `StoerWagnerResult` 包含:
/// - `min_cut_weight`: 最小割的总权重值
/// - `partition`: 割的一侧包含的顶点编号数组，另一侧为其补集
///
/// # 复杂度
///
/// - 时间: O(V³) — 使用朴素 MAS 实现（每次扫描 O(V²)，共 V 个阶段）
///   若使用 Fibonacci 堆优化 MAS 可达 O(VE + V² log V)
/// - 空间: O(V²)，用于存储邻接矩阵副本和顶点合并信息
///
/// # 应用场景
///
/// - 网络可靠性：找出网络中最脆弱的"瓶颈"边集
/// - 图分割/聚类：图像分割、社区检测中的基础操作
/// - VLSI 设计：电路划分以最小化跨区域连线
/// - 生物信息学：蛋白质相互作用网络的模块识别
///
/// # 算法变体对比
///
/// | 方法 | 时间复杂度 | 是否确定性 |
/// |------|-----------|-----------|
/// | Stoer-Wagner | O(V³) / O(VE+V²logV) | ✅ |
/// | Karger-Stein | O(V² log³V) | ❌ 随机 |
/// | 枚举 s-t 最大流 | O(V² · max_flow) | ✅ |
///
/// # 注意事项
///
/// - 仅适用于**无向**图，有向图需使用其他方法
/// - 边权重应为非负值（负权重行为未定义）
/// - 返回的 partition 只是割的一侧，完整划分为 {partition, V \ partition}
pub fn stoer_wagner(adj : Array[Array[Double]]) -> StoerWagnerResult {
  let n = adj.length()
  if n <= 1 {
    return StoerWagnerResult::{ min_cut_weight: 0.0, partition: [] }
  }

  let weights = deep_copy_matrix(adj)
  let vertices : Array[Array[Int]] = Array::make(n, [])
  let mut i = 0
  while i < n {
    vertices[i] = [i]
    i = i + 1
  }

  let mut best_cut = 1.0e100
  let mut best_partition : Array[Int] = []

  let mut phase = n
  while phase > 1 {
    // 最大邻接搜索 (Maximum Adjacency Search)
    let added : Array[Bool] = Array::make(n, false)
    let ws : Array[Double] = Array::make(n, 0.0)
    let mut prev = -1

    let mut iter = 0
    while iter < phase {
      // 选择与已选集合连接最紧密的未选顶点
      let mut sel = -1
      let mut max_w = -1.0
      let mut v = 0
      while v < n {
        if !added[v] && vertices[v].length() > 0 {
          if ws[v] > max_w {
            max_w = ws[v]
            sel = v
          }
        }
        v = v + 1
      }

      if sel < 0 {
        break
      }

      added[sel] = true
      if iter == phase - 1 {
        // 最后加入的顶点
        let cut_weight = ws[sel]
        if cut_weight < best_cut {
          best_cut = cut_weight
          let part : Array[Int] = []
          for x in vertices[sel] {
            part.push(x)
          }
          best_partition = part
        }

        // 合并 sel 和 prev
        if prev >= 0 && sel >= 0 && prev < n && sel < n {
          for x in vertices[sel] {
            vertices[prev].push(x)
          }
          vertices[sel] = []
          // 更新权重组
          let mut j = 0
          while j < n {
            if j != prev && j != sel && vertices[j].length() > 0 {
              let w_sum = weights[sel][j] + weights[prev][j]
              weights[prev][j] = w_sum
              weights[j][prev] = w_sum
            }
            j = j + 1
          }
          weights[prev][prev] = 0.0
          weights[prev][sel] = 0.0
          weights[sel][prev] = 0.0
          weights[sel][sel] = 0.0
        }
        break
      }

      prev = sel

      // 更新权重: 将 sel 的边权加入 ws
      v = 0
      while v < n {
        if !added[v] && vertices[v].length() > 0 {
          ws[v] = ws[v] + weights[sel][v]
        }
        v = v + 1
      }
      iter = iter + 1
    }

    phase = phase - 1
  }

  StoerWagnerResult::{ min_cut_weight: best_cut, partition: best_partition }
}
