---
title: 最小费用最大流
description: 在最大流的基础上优化成本
---

# 🚧 内容建设中...

## 最小费用最大流

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 8 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>费用网络的扩展定义</li>
      <li>最短增广路算法（Successive Shortest Path）</li>
      <li>消圈算法（Cycle Canceling）</li>
      <li>应用：物流调度、资源分配</li>
    </ul>
  </div>
</div>

## 问题定义
在所有达到**最大流量**的方案中，找到**总成本最低**的那个。

### 与纯最大流的区别
- **最大流**：只关心流量大小
- **最小费用最大流**：同时考虑流量和成本

### 应用场景
- 物流运输：最大化运量的同时最小化成本
- 任务分配：完成最多任务且总开销最小
- 网络设计：带宽分配的成本优化

---

**相关文档：**
- [Edmonds-Karp](/algorithms/flow/max-flow/edmonds-karp)
- [Dinic 算法](/algorithms/flow/max-flow/dinic)
- [实战案例 - 推荐系统](/use-cases/recommendation-system/collaborative-filtering)
