---
title: Trait 架构设计
description: 6 层 Trait 架构的设计决策、分层原则与实现策略
---

> **核心文件**: `lib/core/traits.mbt` | **状态**: ✅ 已冻结

---

## 1. 设计哲学

### 三大原则

| 原则 | 实现方式 | 核心价值 |
|------|---------|----------|
| **接口隔离 (ISP)** | 每层只提供必要的方法 | 存储只需实现所需能力 |
| **里氏替换 (LSP)** | 只读存储不实现 Writable | 编译期类型安全 |
| **依赖倒置 (DIP)** | 算法依赖 Trait 抽象 | 新增存储无需修改算法 |

### 为什么需要分层？

传统图库（如 NetworkX）通常只有一种统一接口，问题：
- ❌ 无法区分只读/可写存储
- ❌ 编译器无法进行静态优化
- ❌ CSR 被迫实现不需要的接口

mbtgraph 的解决方案：

```moonbit
// 泛型约束让编译器知道存储的能力
pub fn[G : @core.GraphReadable] bfs(graph : G, start : NodeId) -> BfsResult {
  // 编译器知道 G 至少有 12 个方法
}
```

---

## 2. Trait 层级总览

```
Layer 0: GraphReadable (基础只读)
    │ 12 个方法，所有存储必须实现
    │
    ├── Layer 1A: GraphWritable (可写扩展)
    │   └── +5 方法，动态存储专属
    │       │
    │       └── Layer 2: GraphDirected (有向扩展)
    │           └── +6 方法，入边查询能力
    │               │
    │               └── Layer 3: GraphFull (便捷别名)
    │                   = GraphWritable + GraphDirected
    │
    ├── Layer 1B: GraphBatchReadable (批量优化)
    │   └── +2 方法，CSR/CSC 专属
    │
    └── Layer 1C: GraphEdgeIterable (边排序)
        └── +1 方法，Kruskal 算法友好
```

---

## 3. 设计决策

### DDR-01: 为何用 Trait 而非继承

MoonBit 的 Trait 系统支持泛型约束，编译期展开零开销：
- Trait 约束→编译器单态化→无虚表开销
- 继承体系→虚表→运行时开销

### DDR-02: GraphBatchReadable 独立层

CSR/CSC 的批量操作是性能关键优化，但语义上不适用于链表结构的 AdjList。独立为单独 Trait 既实现了 ISP，又让编译器能为 CSR 生成最优代码。

### DDR-03: GraphFull 别名

```moonbit
pub(open) trait GraphFull: GraphWritable + GraphDirected {
  // 无需额外方法
}
```

纯语法糖，减少 `GraphWritable + GraphDirected` 的书写负担。

---

## 4. 适用范围速查

| 存储类型 | Readable | Writable | Directed | BatchReadable | EdgeIterable |
|----------|:--------:|:--------:|:--------:|:-------------:|:------------:|
| DirectedAdjList | ✅ | ✅ | ✅ | ❌ | ✅ |
| UndirectedAdjList | ✅ | ✅ | ✅ | ❌ | ✅ |
| DirectedMatrix | ✅ | ✅ | ✅ | ❌ | ❌ |
| UndirectedMatrix | ✅ | ✅ | ✅ | ❌ | ❌ |
| EdgeList | ✅ | ✅ | ❌ | ❌ | ✅ |
| UndirectedEdgeList | ✅ | ✅ | ❌ | ❌ | ✅ |
| CSR | ✅ | ❌ | ❌ | ✅ | ❌ |
| CSC | ✅ | ❌ | ✅ | ✅ | ❌ |

---

## 5. 最佳实践

### 算法开发 Checklist

- [ ] 确定算法需要的**最小 Trait 集**
- [ ] 在泛型约束中使用**最具体的 Trait**
- [ ] 文档说明对 Trait 的要求
- [ ] 测试时覆盖**多种存储类型**

### 用户决策树

```
需要修改图？
├─ 是 → 需要 GraphWritable
│      ├─ 需要入边查询？→ 是 → GraphFull (DirectedAdjList)
│      └─ 否 → GraphWritable (UndirectedAdjList)
│
└─ 否 → 只读即可
       ├─ 大规模 (>10万)？→ 是 → GraphBatchReadable (CSR/CSC)
       ├─ 需要排序边？→ 是 → GraphEdgeIterable (EdgeList)
       └─ 一般用途 → GraphReadable (任意存储)
```
