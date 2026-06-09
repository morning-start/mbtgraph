---
title: 流网络基础概念
description: 网络流算法的理论基础
---

# 🚧 内容建设中...

## 流网络基础概念

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月下旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>流网络的形式化定义</li>
      <li>容量约束与流量守恒</li>
      <li>残差网络与增广路径</li>
      <li>最大流最小割定理（Max-Flow Min-Cut Theorem）</li>
      <li>FlowNetwork 数据结构设计</li>
    </ul>
  </div>
</div>

## 核心概念

### 流网络 (Flow Network)
一个有向图 G = (V, E)，其中：
- 每条边 e 有容量 c(e) ≥ 0
- 有源点 s 和汇点 t
- 流量 f(e) 满足 0 ≤ f(e) ≤ c(e)

### 最大流问题
在满足容量约束和流量守恒的前提下，从 s 到 t 的**最大流量**是多少？

---

**相关文档：**
- [Edmonds-Karp](/algorithms/flow/max-flow/edmonds-karp)
- [Dinic 算法](/algorithms/flow/max-flow/dinic)
- [最小费用最大流](/algorithms/flow/min-cost-max-flow/index/)
