---
title: 测试规范
description: mbtgraph 的测试策略和编写指南
---

# 🚧 内容建设中...

## 测试规范

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 11 月下旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>双轨测试体系：Blackbox + Whitebox</li>
      <li>测试文件命名规范</li>
      <li>测试用例设计原则</li>
      <li>运行测试与覆盖率分析</li>
      <li>CI/CD 集成测试流程</li>
    </ul>
  </div>
</div>

## 测试体系概述

mbtgraph 采用**双轨制测试体系**：

### Blackbox 测试（功能测试）
- **文件命名**: `*_test.mbt`
- **目的**: 验证公开 API 的正确性
- **关注点**: 输入输出符合预期
- **示例**: `dijkstra_test.mbt`

### Whitebox 测试（内部逻辑验证）
- **文件命名**: `*_wbtest.mbt`
- **目的**: 验证内部实现细节
- **关注点**: 边界情况、算法正确性
- **示例**: `dijkstra_wbtest.mbt`

## 运行测试

```bash
# 全量测试
moon test

# 单模块测试
moon test lib/algo/pagerank

# 更新快照测试
moon test --update

# 覆盖率分析
moon coverage analyze
```

## 测试分类比例

| 类别 | 占比 | 说明 |
|------|:----:|------|
| 基础功能测试 | ~30% | 类型创建/方法正确性 |
| 算法正确性测试 | ~40% | 经典案例/已知答案 |
| 边界情况测试 | ~20% | 空图/越界/异常输入 |
| 属性验证测试 | ~10% | 不可变性/一致性约束 |

---

**相关文档：**
- [开发环境搭建](/contributing/setup)
- [编码规范](/contributing/coding-standards)
