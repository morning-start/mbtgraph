---
title: 开发环境搭建
description: 配置 mbtgraph 开发所需的完整环境
---

# 🚧 内容建设中...

## 开发环境搭建

<div class="callout" data-color="caution">
  <div class="callout-header">
    <span class="callout-icon">⚠️</span>
    <p class="callout-title">正在建设中</p>
  </div>
  <div class="callout-content">
    <p><strong>预计完成时间：</strong>2026 年 11 月上旬</p>
    <p><strong>内容概要：</strong></p>
    <ul>
      <li>Fork 与 Clone 仓库</li>
      <li>安装 MoonBit 工具链</li>
      <li>IDE/编辑器配置（VS Code 插件）</li>
      <li>构建与测试命令</li>
      <li>项目结构说明</li>
    </ul>
  </div>
</div>

## 快速开始

```bash
# 1. Fork 并克隆仓库
git clone https://github.com/<your-username>/mbtgraph.git
cd mbtgraph

# 2. 安装依赖（如果需要）
# mbtgraph 主要依赖 MoonBit 标准库

# 3. 运行测试
moon test

# 4. 检查代码格式
moon fmt
moon info
```

## 推荐工具

| 工具 | 用途 | 安装方式 |
|------|------|---------|
| MoonBit CLI | 编译、测试、格式化 | 官方安装脚本 |
| VS Code | 代码编辑 | VS Code Marketplace |
| Git | 版本控制 | 系统包管理器 |

---

**相关文档：**
- [编码规范](/contributing/coding-standards)
- [测试规范](/contributing/testing)
