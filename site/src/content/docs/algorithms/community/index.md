---
title: 社区检测算法
description: 发现图中紧密连接的节点群体
---

# 🚧 内容建设中...

## 社区检测算法

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 9 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>Louvain 算法（模块度优化）</li>
      <li>标签传播算法（LPA）</li>
      <li>Leiden 算法改进</li>
      <li>社区质量评估指标</li>
      <li>应用：社交网络社群发现、学术合作网络分析</li>
    </ul>
  </div>
</div>

## 问题定义
**社区检测（Community Detection）**：将图的节点划分为若干子集（社区），使得：
- 社区**内部**连接紧密
- 社区**之间**连接稀疏

### 主要算法

| 算法 | 思想 | 时间复杂度 | 特点 |
|------|------|-----------|------|
| **Louvain** | 模块度最大化 | O(n log n) | 高效、广泛应用 |
| **Label Propagation** | 标签传播 | O(n+m) | 极快但结果不稳定 |
| **Leiden** | Louvain 改进 | O(n log n) | 更高质量连通社区 |

### 应用场景
- **社交网络**：发现兴趣小组、朋友圈
- **生物网络**：蛋白质功能模块识别
- **引用网络**：研究领域划分
- **推荐系统**：基于社区的协同过滤

---

**相关文档：**
- [中心性指标](/algorithms/centrality/index/)
- [实战案例 - 社交网络](/use-cases/social-network/community-detection)
