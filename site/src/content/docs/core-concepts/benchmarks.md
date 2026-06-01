---
title: 性能基准测试
description: 基于真实数据的存储性能对比与分析
---

# 🚧 内容建设中...

## 性能基准测试

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 7 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>基准测试环境与方法论</li>
      <li>不同规模数据集的测试结果</li>
      <li>创建/查询/遍历性能对比</li>
      <li>内存占用分析</li>
      <li>编译后端差异（native vs wasm vs js）</li>
    </ul>
    <p>在此期间，可以参考 <a href="/core-concepts/storage-guide/">存储对比表</a> 了解理论复杂度。</p>
  </div>
</div>

## 测试维度

### 操作类型

- **创建性能**：构建包含 N 个节点和 M 条边的图所需时间
- **查询性能**：
  - `neighbors()` - 邻居列表获取
  - `has_edge()` - 边存在性检查
  - `degree()` - 度数计算
- **遍历性能**：
  - `nodes()` - 全节点遍历
  - `edges()` - 全边遍历
- **修改性能**（仅动态存储）：
  - `add_node()` / `add_edge()`
  - `remove_node()` / `remove_edge()`

### 数据规模

| 规模 | 节点数 | 边数 | 典型场景 |
|------|:------:|:----:|---------|
| 小型 | 100 | 500 | 教学演示 |
| 中型 | 10K | 50K | 社交网络子集 |
| 大型 | 100K | 1M | 完整社交网络 |
| 超大型 | 1M+ | 10M+ | Web 图 |

---

**相关文档：**
- [8 种存储对比表](/core-concepts/storage-guide/)
- [场景化选型决策树](/core-concepts/storage-decision/)
