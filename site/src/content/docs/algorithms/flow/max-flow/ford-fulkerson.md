---
title: Ford-Fulkerson 方法
description: 最大流问题的基础框架
---

# 🚧 内容建设中...

## Ford-Fulkerson 方法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 8 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>Ford-Fulkerson 方法的通用框架</li>
      <li>增广路径的选择策略</li>
      <li>收敛性分析（整数容量保证终止）</li>
      <li>作为其他算法的基础</li>
    </ul>
  </div>
</div>

## 方法简介
**Ford-Fulkerson** 不是具体算法，而是一个求解最大流的**方法框架**。

### 核心思想
1. 初始流量为 0
2. 在残差网络中寻找增广路径
3. 沿增广路径增加流量
4. 重复直到不存在增广路径

### 注意事项
- 如果选择增广路径的策略不当，可能不收敛（非整数容量时）
- 实际使用中通常采用 **Edmonds-Karp**（BFS 选择）或 **Dinic**

---

**相关文档：**
- [Edmonds-Karp 实现](/algorithms/flow/max-flow/edmonds-karp)
- [Dinic 优化](/algorithms/flow/max-flow/dinic)
