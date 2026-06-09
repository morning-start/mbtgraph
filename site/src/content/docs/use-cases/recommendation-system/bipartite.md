---
title: 用户-物品二分图
description: 构建推荐系统的图模型基础
---

# 🚧 内容建设中...

## 用户-物品二分图

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 10 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>二分图在推荐系统中的应用</li>
      <li>用户-物品交互矩阵到图的转换</li>
      <li>评分/权重的设计策略</li>
      <li>数据稀疏性处理</li>
    </ul>
  </div>
</div>

## 推荐系统的图视角

传统推荐系统使用**用户-物品交互矩阵**：

```
        物品1  物品2  物品3  物品4
用户A   [  5     -     3     -  ]
用户B   [  -     4     -     2  ]
用户C   [  3     -     -     5  ]
用户D   [  -     2     4     -  ]
```

转换为**二分图**：
- 左侧节点：用户（User）
- 右侧节点：物品（Item）
- 边：用户对物品的交互（购买、点击、评分等）

### 为什么用图？
- ✅ 自然表达用户-物品关系
- ✅ 可应用图算法（匹配、路径、社区检测）
- ✅ 融入社交网络信息（用户-用户关系）
- ✅ 支持冷启动问题处理

---

**相关文档：**
- [协同过滤实现](/use-cases/recommendation-system/collaborative-filtering)
- [图嵌入入门](/use-cases/recommendation-system/embedding)
- [二分图匹配](/algorithms/matching/bipartite/hungarian)
