---
title: 实体关系抽取
description: 从非结构化文本构建知识图谱
---

# 🚧 内容建设中...

## 实体关系抽取 (Entity-Relation Extraction)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 11 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>NLP 技术在知识图谱构建中的应用</li>
      <li>实体识别（NER）基础</li>
      <li>关系抽取方法概述</li>
      <li>将抽取结果构建为图结构</li>
    </ul>
  </div>
</div>

## 知识图谱构建流程

```
原始文本 → 实体识别 → 关系抽取 → 三元组 → 图结构
```

### 示例

**输入文本**：
> "马云于 1999 年在杭州创立了阿里巴巴公司"

**抽取结果**：
- 实体：[马云, 杭州, 阿里巴巴]
- 关系：
  - (马云, 创立, 阿里巴巴)
  - (阿里巴巴, 位于, 杭州)
  - (马云, 时间, 1999年)

**图结构**：
```
(马云) --[创立]--> (阿里巴巴) --[位于]--> (杭州)
   |
   +--[时间]--> (1999年)
```

---

**相关文档：**
- [图谱查询与分析](/use-cases/knowledge-graph/query)
- [可视化展示](/use-cases/knowledge-graph/visualization)
