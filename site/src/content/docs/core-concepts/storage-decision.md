---
title: 场景化选型决策树
description: 根据应用场景快速选择最合适的存储结构
---

# 🚧 内容建设中...

## 场景化选型决策树

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 6 月下旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>交互式决策树流程</li>
      <li>典型场景案例分析</li>
      <li>性能需求评估清单</li>
      <li>内存限制考量因素</li>
      <li>迁移与重构建议</li>
    </ul>
    <p>在此期间，可以先查看 <a href="/core-concepts/storage-guide/">8 种存储对比表</a> 了解基本特性。</p>
  </div>
</div>

## 快速选择指南

```
你的使用场景是什么？
│
├─ 社交网络 / 推荐系统？
│   └─ 推荐：AdjList（动态 + 高效邻居查询）
│
├─ 算法竞赛 / 教学演示？
│   ├─ 节点数 < 1000？→ Matrix（简单易用）
│   └─ 节点数 > 10000？→ AdjList（节省空间）
│
├─ 最小生成树 / Kruskal 算法？
│   └─ 必须：EdgeList（支持边排序）
│
├─ 大规模静态图（>100K 节点）？
│   ├─ 主要查询出边？→ CSR（缓存友好）
│   └─ 主要查询入边？→ CSC（入度 O(1)）
│
├─ 不知道 / 不确定？
│   └─ 默认：DirectedAdjList ⭐
│
└─ 需要在运行时切换存储？
    └─ 使用 converter 模块进行转换
```

---

**相关文档：**
- [8 种存储对比表](/core-concepts/storage-guide/)
- [性能基准测试](/core-concepts/benchmarks/)
- [存储转换器使用](/core-concepts/storage-converter/)
