# 图匹配模块 (Matching)

> **包路径**: `src/algo/matching` | **状态**: ✅ 完成 | **测试**: 21/21 通过
>
> 二分图最大匹配算法，基于匈牙利算法（Kuhn's DFS 增广路）。

---

## API 总览

### 公开类型

| 类型 | 说明 |
|------|------|
| `MatchingResult` | 匹配结果，包含匹配边列表和基数 |

### 公开函数

| 函数 | 签名 | 说明 | 复杂度 |
|------|------|------|:-----:|
| `bipartite_matching` | `(n_left, n_right, edges) -> MatchingResult` | 邻接表版本，二分图最大匹配 | O(VE) |
| `bipartite_matching_graph` | `[G:GraphReadable](g, left, right) -> MatchingResult` | Trait 版本，基于图结构计算 | O(VE) |

### MatchingResult 方法

| 方法 | 返回值 | 说明 |
|------|-------|------|
| `size()` | `Int` | 匹配基数（匹配边数）|
| `is_matched(node)` | `Bool` | 节点是否在匹配中 |
| `get_partner(node)` | `NodeId?` | 获取匹配伙伴，未匹配返回 None |

---

## 使用示例

### 基础用法：邻接表输入

```moonbit
// 构建完全二分图 K_{3,3}
let edges : Array[(Int, Int)] = [
  (0, 0), (0, 1), (0, 2),
  (1, 0), (1, 1), (1, 2),
  (2, 0), (2, 1), (2, 2),
]

let result = bipartite_matching(3, 3, edges)

// 结果
result.size()        // => 3 (完美匹配)
result.is_matched(@core.NodeId(0))  // => true
result.get_partner(@core.NodeId(0)) // => Some(NodeId(3))
```

### 高级用法：GraphReadable 版本

```moonbit
// 基于现有图结构的二分图匹配
let left : Array[@core.NodeId] = [@core.NodeId(0), @core.NodeId(1)]
let right : Array[@core.NodeId] = [@core.NodeId(2), @core.NodeId(3), @core.NodeId(4)]

let result = bipartite_matching_graph(my_graph, left, right)
```

---

## 算法原理

### 匈牙利算法 (Hungarian / Kuhn's Algorithm)

**核心思想**: 通过反复寻找**增广路**来扩大匹配。

#### 算法流程

```
输入: 二分图 G = (U ∪ V, E)
输出: 最大匹配 M

1. M ← ∅ (空匹配)
2. FOR EACH u ∈ U DO:
3.   清空 visited 数组
4.   IF dfs_find_augment(u) THEN:
5.     |M| ← |M| + 1 (找到增广路，翻转匹配)
6. RETURN M
```

#### DFS 增广路搜索

```
dfs_find_augment(u):
  FOR EACH v ∈ neighbors(u) DO:
    IF v 未访问 THEN:
      标记 v 已访问
      IF v 未匹配 OR dfs_find_augment(match[v]) THEN:
        match[v] ← u
        RETURN true (找到增广路)
  RETURN false
```

#### 关键性质

- **增广路**: 交替路径（非匹配边→匹配边→...），两端均为未匹配节点
- **翻转操作**: 沿增广路交换匹配/非匹配状态，使 |M| + 1
- **正确性**: Berge 定理 — 当且仅当不存在增广路时，匹配为最大匹配

#### 复杂度分析

| 指标 | 值 |
|------|:--:|
| 时间复杂度 | O(VE)，V = \|U\|，E = \|E\| |
| 空间复杂度 | O(V + E) |
| 最坏情况 | 稠密完全二分图 O(V³) |
| 实际表现 | 稀疏图上接近线性 |

---

## 内部组件

| 组件 | 可见性 | 功能 |
|------|:------:|------|
| `hungarian_dfs()` | priv | DFS 在交替树上寻找增广路径 |
| `find_node_index()` | priv | 在 NodeId 数组中线性查找索引 |

---

## 边界行为

| 场景 | 行为 |
|------|------|
| 空图 (n=0) | 返回 cardinality=0, edges=[] |
| 无边图 | 返回 cardinality=0 |
| 单条边 | cardinality=1 |
| 左侧 > 右侧 | cardinality ≤ min(\|U\|, \|V\|) |
| 右侧 > 左侧 | cardinality ≤ min(\|U\|, \|V\|) |
| 不连通分量 | 各分量独立计算后合并 |
| 自环边 | 自动忽略（不在对侧分区）|

---

## 测试覆盖

| 类别 | 测试数 | 内容 |
|------|:-----:|------|
| **类型基础** | 5 | size/is_matched/get_partner 正常+边界 |
| **空图/边界** | 4 | 空图/无边/零左/零右 |
| **正常场景** | 5 | 单边/K22/K33/路径/星形 |
| **非对称** | 2 | 左大右小 / 右大左小 |
| **复杂场景** | 2 | 不连通/多路径 |
| **属性验证** | 3 | 基数≤min/无重复节点/边数一致 |
| **合计** | **21** | **100% 通过** ✅ |

运行命令:
```bash
moon test src/algo/matching  # 21 tests
```

---

## 设计决策

### Q1: 为什么用邻接表而非 Graph trait？

**A**: 二分图匹配的语义天然适合邻接表表示（左右分区 + 边列表）。强制适配 GraphReadable 会增加不必要的抽象层。同时提供两个版本：
- `bipartite_matching()`: 纯数据版本，零依赖，最高性能
- `bipartite_matching_graph()`: Trait 版本，与存储层无缝集成

### Q2: 为什么不用 FlowNetwork 归约？

**A**: 虽然二分图匹配可归约为最大流（添加源/汇，容量=1），但：
- 匈牙利 O(VE) 比 Edmonds-Karp O(VE²) 快一个数量级
- 无需构建残差网络和流量矩阵
- 内存占用更低（无需 Double 矩阵）

未来可提供 `matching_from_flow()` 作为备选方案。

### Q3: 匹配边的 NodeId 编码规则？

**A**: 结果中左边节点保持原始编号 (0..n_left-1)，右边节点偏移为 (n_left..n_left+n_right-1)。这保证全局唯一性，便于与 Graph trait 的 NodeId 系统一致。

---

## 配合模块

| 模块 | 关系 |
|------|------|
| `algo/flow` | 可通过最大流归约求解匹配（备用方案）|
| `core` | 提供 NodeId / GraphReadable trait |
| `storage` | GraphReadable 版本的底层图存储 |

---

## 版本历史

| 版本 | 日期 | 变更 |
|:----:|:----:|------|
| v0.1.0 | 2026-05-19 | 初始版本：Hungarian 算法 + 21 tests |
