---
title: 编码规范
description: mbtgraph 项目的编码约定和最佳实践
---

# 🚧 内容建设中...

## 编码规范（AGENTS.md 精简版）

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 11 月中旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>MoonBit 语言编码风格</li>
      <li>Trait 使用规范</li>
      <li>命名约定（变量、函数、类型）</li>
      <li>注释和文档要求</li>
      <li>Git 提交信息规范</li>
    </ul>
  </div>
</div>

## 核心规则摘要

### 强制规则

| # | 规则 | 正确示例 | 错误示例 |
|---|------|---------|---------|
| R1 | 使用 `@core.` 完全限定名 | `@core.NodeId(0)` | use 别名 |
| R2 | Impl 用 `(self)` 非 `mut self` | `let g = self` | `mut self` |
| R3 | 可变性按需声明 | 只改字段→`let g` | 需重新赋值→`let mut g` |
| R4 | 可见性正确选择 | 核心类型→`pub(all)` | trait→`pub(open)trait` |
| R5 | For 循环不直接解构元组 | 先绑定再 match | `for (a,b) in ...` |
| R6 | 嵌套泛型用 `]]` 结尾 | `Array[Array[Double?]]` | `Array[Array[Double?>>` |
| R7 | 避免保留字命名 | `net`, `graph` | `fn`, `var` |

### 命名约定

- **函数**: snake_case (e.g., `add_node`, `find_shortest_path`)
- **类型**: PascalCase (e.g., `GraphReadable`, `BfsResult`)
- **常量**: UPPER_SNAKE_CASE (e.g., `MAX_NODES`, `INF`)
- **文件名**: snake_case (e.g., `dijkstra.mbt`, `bellman_ford.mbt`)

### Git 提交规范

```
<type>(<scope>): <subject>

<body (可选)>

Types: feat, fix, refactor, test, docs, chore
```

---

**相关文档：**
- [开发环境搭建](/contributing/setup)
- [测试规范](/contributing/testing)
- [完整 AGENTS.md](https://github.com/moonbit/mbtgraph/blob/main/AGENTS.md)
