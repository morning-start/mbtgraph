---
title: 构建关注关系图
description: 使用 mbtgraph 构建社交网络的图模型
---

# 🚧 内容建设中...

## 构建关注关系图

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 9 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>从真实数据集构建社交网络图</li>
      <li>数据清洗与预处理</li>
      <li>存储结构选择（有向邻接表）</li>
      <li>图的基本统计信息计算</li>
      <li>完整可运行的代码示例</li>
    </ul>
  </div>
</div>

## 项目背景

本案例将演示如何使用 mbtgraph 构建一个真实的社交网络关注关系图。

### 数据来源示例
```csv
user_id,following_id,timestamp
1,2,2024-01-01
1,3,2024-01-02
2,4,2024-01-03
...
```

### 技术要点
- 使用 `DirectedAdjList` 存储有向关注关系
- 节点数据存储用户 ID 和基本信息
- 边权重可以表示互动频率或关系强度

---

**相关文档：**
- [关键人物识别](/use-cases/social-network/influencers)
- [社群发现](/use-cases/social-network/community-detection)
- [中心性指标](/algorithms/centrality/index/)
