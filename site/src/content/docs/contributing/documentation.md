---
title: 文档更新流程
description: 如何为 mbtgraph 文档网站贡献内容，包括页面创建、可视化嵌入和侧边栏更新
---

# 文档更新流程

> ⏱️ **预计阅读时间**: 10 分钟

## 文档站点架构

mbtgraph 的文档站点基于 **Astro + Starlight** 构建，位于 `site/` 目录下：

```
site/
├── src/
│   ├── content/docs/           # 📝 Starlight 文档内容
│   │   ├── algorithms/          #  算法教程（每个算法一个文件夹）
│   │   ├── getting-started/     #  入门指南
│   │   ├── core-concepts/       #  基础概念
│   │   ├── api/                 #  API 参考
│   │   ├── use-cases/           #  实战案例
│   │   └── contributing/        #  贡献指南
│   ├── lib/
│   │   ├── algs/               #   算法可视化 JS 模块
│   │   ├── graph-data/          #   可视化图数据
│   │   └── algorithms.config.ts #  算法注册表
│   ├── pages/
│   │   └── visualizations/     #   可视化 Astro 页面
│   └── components/             #   共享组件
├── astro.config.mjs            # Astro 配置（含侧边栏）
└── package.json
```

## 添加新算法教程

### 1. 创建教程页面

在 `site/src/content/docs/algorithms/{category}/{slug}/index.md` 创建文件：

```markdown
---
title: 算法名称
description: 简短描述（用于 SEO 和搜索）
---

# 算法名称

> 🎯 **本节目标**: 一句概况 | ⏱️ **预计阅读时间**: X 分钟

## 算法简介
概念讲解，3-5 句。

## 动画演示
[仅适用于适合动画的算法]

<div class="viz-preview-card">
  <iframe src="/visualizations/{slug}/" width="100%" height="540" frameborder="0" style="height:540px"></iframe>
  <a href="/visualizations/{slug}/" target="_blank" class="viz-fullscreen-btn">全屏演示</a>
</div>

## MoonBit 实现
核心代码（完全限定名，无 use 语句）。

## 使用示例
一个最小示例。

## 实际场景
2-3 条场景说明。

## 扩展阅读
相关算法链接。
```

### 2. 添加可视化（可选）

如果算法适合动画展示，创建：

| 文件 | 说明 | 参考 |
|------|------|------|
| `site/src/lib/algs/{slug}.ts` | 算法逻辑模块 | `bfs.ts` |
| `site/src/lib/graph-data/{slug}.ts` | 图数据定义 | `bfs.ts` |
| `site/src/pages/visualizations/{slug}.astro` | 页面 | `bfs.astro` |

然后在 `site/src/lib/algorithms.config.ts` 和 `site/src/lib/graph-data/index.ts` 中注册。

### 3. 更新侧边栏

编辑 `site/astro.config.mjs`，在 `starlight.sidebar` 中添加新条目：

```javascript
{
  label: '算法名',
  autogenerate: { directory: 'algorithms/{category}/{slug}' },
}
```

## 更新现有文档

### 文档内容

直接编辑 `site/src/content/docs/` 下的 Markdown 文件：

```markdown
---
title: 页面标题
description: 页面描述
---

# 页面标题

## 章节标题

正文内容... 支持 **粗体**、`行内代码`、[链接](/path/)。

### 代码块

```moonbit
let result = @traversal.bfs(graph, start)
```

### Callout

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">💡</span>
    <p class="callout-title">提示标题</p>
  </div>
  <div class="callout-content">
    <p>提示内容</p>
  </div>
</div>
```

### Frontmatter 字段

| 字段 | 必填 | 说明 |
|------|:----:|------|
| `title` | ✅ | 页面标题（也用于侧边栏） |
| `description` | ✅ | 页面描述（SEO 和搜索） |
| `sidebar` | ❌ | 自定义侧边栏标签（默认使用 title） |

## 构建与预览

```bash
cd site

# 开发服务器（热重载）
bun run dev

# 生产构建
bun run build

# 预览构建产物
bun run preview
```

构建成功后会输出到 `site/dist/`。

## 注意事项

- 算法页面中**不要**包含复杂度分析表格、练习题、总结清单——交互式动画代替了它们的作用
- 使用完全限定名（`@core.GraphReadable`），不要使用 `use` 语句
- 代码块必须标注语言（`` ```moonbit ``）以获得语法高亮
- 每个新文件提交前运行 `bun run build` 确认构建通过
- 新增可视化算法时确保 4 个文件全部创建并注册

---

**相关文档：**
- [开发环境搭建](/contributing/setup)
- [编码规范](/contributing/coding-standards)
- [测试规范](/contributing/testing)
