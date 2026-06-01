---
title: 安装与环境配置
description: 快速安装 mbtgraph 并配置开发环境
---

# 安装与环境配置

## 前置要求

在开始使用 mbtgraph 之前，请确保你的系统已安装以下工具：

- **MoonBit 工具链** (>= 0.1.80)
- **Bun** (>= 1.0.0) 或 **npm** (>= 9.0.0)
- **Git**

## 安装步骤

### 1. 安装 MoonBit

```bash
# 使用官方安装脚本
curl -fsSL https://cli.moonbitlang.com/install/moon.sh | bash

# 或使用包管理器
brew install moonbit
```

### 2. 创建新项目

```bash
moon new my_graph_project
cd my_graph_project
```

### 3. 添加 mbtgraph 依赖

```bash
# 在项目根目录下
moon add mbtgraph
```

或者手动在 `moon.mod.json` 中添加：

```json
{
  "name": "my-graph-project",
  "version": "0.1.0",
  "deps": {
    "mbtgraph": "*"
  }
}
```

## 验证安装

创建一个简单的测试文件 `src/lib/test.mbt`：

```moonbit
// 测试 mbtgraph 是否正确导入
fn main {
  let g = @storage.DirectedAdjList::new()
  println("mbtgraph 安装成功！")
}
```

运行测试：

```bash
moon run src/lib/test.mbt
```

如果看到输出 `mbtgraph 安装成功！`，说明环境配置完成。

## 项目结构说明

```
my-graph-project/
├── moon.mod.json          # 项目配置文件
├── src/
│   ├── lib/               # 库代码目录
│   │   └── your_code.mbt # 你的代码
│   └── main/              # 可执行程序入口
└── target/                # 编译输出目录
    ├── native/            # 本地二进制
    ├── wasm/              # WebAssembly 输出
    └── js/                # JavaScript 输出
```

## 开发工具推荐

| 工具 | 用途 | 推荐插件 |
|------|------|---------|
| VS Code | 代码编辑 | MoonBit 官方插件 |
| Git | 版本控制 | - |
| Bun | 包管理器 | - |

## 常见问题

<details>
<summary>Q: MoonBit 安装失败怎么办？</summary>

请检查：
1. 网络连接是否正常
2. 是否有足够的磁盘空间
3. 是否使用了代理（需要配置 HTTP_PROXY）

</details>

<details>
<summary>Q: 如何更新 mbtgraph 到最新版本？</summary>

```bash
moon update
```
这会自动更新所有依赖到最新兼容版本。

</details>

---

<div class="callout" data-color="tip">
  <div class="callout-header">
    <span class="callout-icon">💡</span>
    <p class="callout-title">下一步</p>
  </div>
  <div class="callout-content">
    <p>安装完成后，让我们<a href="/getting-started/first-graph/">创建第一个图程序</a>！</p>
  </div>
</div>
