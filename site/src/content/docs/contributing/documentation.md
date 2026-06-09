---
title: 文档更新流程
description: 如何为 mbtgraph 文档网站贡献内容
---

# 🚧 内容建设中...

## 文档更新流程

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 12 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>文档目录结构说明</li>
      <li>Markdown/MDX 编写规范</li>
      <li>Frontmatter 字段定义</li>
      <li>代码示例格式要求</li>
      <li>PR 提交与审查流程</li>
    </ul>
  </div>
</div>

## 文档位置

所有文档位于 `site/src/content/docs/` 目录下：

```
site/src/content/docs/
├── index.mdx                    # 首页
├── getting-started/             # 入门指南
├── core-concepts/               # 基础教程
├── algorithms/                  # 算法教程
├── use-cases/                   # 实战案例
├── api/                         # API 参考
└── contributing/                # 贡献指南
```

## 编写新文档

### 1. 创建文件

在对应目录下创建 `.md` 或 `.mdx` 文件。

### 2. 添加 Frontmatter

```yaml
---
title: 文档标题
description: 文档描述（用于 SEO 和搜索）
---
```

### 3. 编写内容

遵循以下规范：
- 使用清晰的标题层级（h2 → h3 → h4）
- 代码块标注语言（` ```moonbit `）
- 重要提示使用 callout 组件
- 图表使用 Mermaid 语法

### 4. 更新侧边栏

在 `astro.config.mjs` 中添加新页面的链接。

### 5. 提交 PR

```bash
git add site/src/content/docs/your-new-doc.md
git commit -m "docs(topic): add documentation for xxx"
git push origin feature/your-doc
```

然后在 GitHub 上提交 Pull Request。

---

**相关文档：**
- [开发环境搭建](/contributing/setup)
- [编码规范](/contributing/coding-standards)
- [测试规范](/contributing/testing)
