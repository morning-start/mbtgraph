---
title: Kosaraju 算法
description: 基于两次 DFS 的强连通分量算法
---

# 🚧 内容建设中...

## Kosaraju 算法 (SCC)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>Kosaraju 的两次 DFS 策略</li>
      <li>图的转置操作</li>
      <li>正确性证明直觉</li>
      <li>实现简单但效率同样优秀</li>
    </ul>
  </div>
</div>

## 算法简介
**Kosaraju 算法** 是另一种求解强连通分量的方法，比 Tarjan 更容易理解和实现。

### 算法步骤
1. **第一次 DFS**：对原图进行 DFS，记录完成顺序
2. **转置图**：将所有边反向
3. **第二次 DFS**：按逆序对转置图 DFS，每次得到一个 SCC

### 优势
- 思路清晰，易于理解
- 代码简洁，不易出错
- 时间复杂度同样是 O(V+E)

---

**相关文档：**
- [Tarjan 算法](/algorithms/connectivity/scc/tarjan)
- [连通分量 (CC)](/algorithms/connectivity/connected-components/index/)
