---
title: Edmonds-Karp 实现
description: 基于 BFS 增广的最大流算法
---

# 🚧 内容建设中...

## Edmonds-Karp 算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月下旬（优先级：P2）</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>BFS 选择最短增广路径</li>
      <li>O(VE²) 时间复杂度证明</li>
      <li>MoonBit 完整实现</li>
      <li>入门级最大流算法，适合学习理解</li>
    </ul>
  </div>
</div>

## 算法简介
**Edmonds-Karp** 是 Ford-Fulkerson 方法的具体实现，使用 **BFS** 选择最短增广路径。

### 复杂度
- **时间**: O(VE²)
- **空间**: O(V²)

### 特点
- ✅ 保证在多项式时间内终止
- ✅ 实现简单，易于理解
- ❌ 对于大规模图效率较低

### 适用场景
- 学习最大流概念的入门算法
- 小规模图的实际应用
- 作为 Dinic 的学习铺垫

---

**相关文档：**
- [Ford-Fulkerson 方法](/algorithms/flow/max-flow/ford-fulkerson)
- [Dinic 优化算法](/algorithms/flow/max-flow/dinic) （更高效）
