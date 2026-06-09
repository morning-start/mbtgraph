---
title: 可视化展示
description: 使用图形化工具展示知识图谱和网络结构
---

# 🚧 内容建设中...

## 可视化展示 (Visualization)

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 11 月下旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>DOT 格式导出与 Graphviz 集成</li>
      <li>JSON 格式导出与 D3.js/ECharts 集成</li>
      <li>力导向布局算法介绍</li>
      <li>交互式可视化最佳实践</li>
    </ul>
  </div>
</div>

## 可视化方案

### 方案 1：Graphviz（静态图）

mbtgraph 内置 DOT 导出功能：

```moonbit
// 导出为 DOT 格式
let dot_string = @io.dot::to_dot(graph)
// 保存为 .dot 文件后使用 graphviz 渲染
```

**优点**：
- 高质量矢量图输出
- 支持多种布局算法（dot、neato、circo 等）
- 学术论文标准格式

### 方案 2：D3.js / ECharts（交互式网页）

导出 JSON 后使用前端库渲染：

```javascript
// D3.js 力导向图示例
const simulation = d3.forceSimulation(nodes)
  .force("link", d3.forceLink(links))
  .force("charge", d3.forceManyBody())
  .force("center", d3.forceCenter(width/2, height/2));
```

**优点**：
- 交互性强（缩放、拖拽、高亮）
- 支持大规模图（万级节点）
- 可集成到 Web 应用

### 方案 3：专业工具

| 工具 | 特点 | 适用场景 |
|------|------|---------|
| Gephi | 开源桌面软件 | 数据探索 |
| Cytoscape | 生物网络专用 | 生物信息学 |
| Neo4j Bloom | 图数据库配套 | 企业应用 |

---

**相关文档：**
- [实体关系抽取](/use-cases/knowledge-graph/extraction)
- [图谱查询与分析](/use-cases/knowledge-graph/query)
- [IO 模块接口](/api/io/)
