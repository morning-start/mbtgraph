---
title: 开发环境搭建
description: 配置 mbtgraph 开发所需的完整环境，包括工具链安装、项目构建与测试
---

# 开发环境搭建

> ⏱️ **预计阅读时间**: 10 分钟

## 前置条件

| 工具 | 版本要求 | 用途 |
|------|---------|------|
| [MoonBit](https://www.moonbitlang.com/) | ≥ 0.14 | 核心语言工具链 |
| [Git](https://git-scm.com/) | ≥ 2.30 | 版本控制 |
| [VS Code](https://code.visualstudio.com/) | 最新 | 推荐编辑器 |
| [Bun](https://bun.sh/) | ≥ 1.0 | 站点构建（可选，仅需修改文档时） |

## 安装 MoonBit

```bash
# macOS / Linux
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

# Windows (PowerShell)
irm https://cli.moonbitlang.com/install/powershell.ps1 | iex

# 验证安装
moon version --all
```

MoonBit CLI 包含以下命令：

| 命令 | 功能 |
|------|------|
| `moon new` | 创建新项目 |
| `moon build` | 编译项目 |
| `moon test` | 运行测试 |
| `moon fmt` | 格式化代码 |
| `moon info` | 更新接口文件 (.mbti) |
| `moon check` | 类型检查 |
| `moon coverage` | 覆盖率分析 |

## 获取代码

```bash
# Fork Github 仓库后
git clone https://github.com/<your-username>/mbtgraph.git
cd mbtgraph

# 查看分支
git branch -a           # 主分支 main, 站点分支 site
git checkout site       # 文档/站点相关工作在 site 分支
```

## 项目结构

```
mbtgraph/
├── lib/                    # 🟣 MoonBit 核心库
│   ├── core/               #   基础定义（types, traits, error）
│   ├── storage/            #   8 种存储实现
│   ├── algo/               #   49+ 算法
│   │   ├── traversal/      #     BFS, DFS, 拓扑排序
│   │   ├── shortest_path/  #     Dijkstra, Bellman-Ford, Floyd-Warshall
│   │   ├── flow/           #     Dinic, Edmonds-Karp, 费用流
│   │   └── ...             #     着色、匹配、社区检测等
│   ├── io/                 #   序列化与统计
│   └── utils/              #   工具函数
├── site/                   # 🌐 Astro 文档站点
│   ├── src/content/docs/    #   文档内容（Starlight）
│   │   ├── algorithms/      #     算法教程
│   │   ├── getting-started/ #     入门指南
│   │   ├── core-concepts/   #     基础教程
│   │   ├── api/             #     API 参考
│   │   ├── use-cases/       #     实战案例
│   │   └── contributing/    #     贡献指南（你在这里）
│   ├── src/lib/algs/        #     算法可视化模块
│   └── src/pages/           #     Astro 页面
├── docs/                   # 📄 项目文档与设计记录
│   ├── ARCHITECTURE.md     #   架构设计
│   ├── TODO.md             #   任务清单
│   └── design/             #   详细设计文档
├── examples/               # 💡 用法示例
├── benchmarks/             # 📊 基准测试
└── tests/                  # 🔬 集成测试（Python 脚本）
```

## 开发工作流

```bash
# 1. 编译检查
moon check                      # 类型检查整个项目
moon check lib/algo/dijkstra    # 检查单模块

# 2. 格式化与接口更新
moon fmt                        # 格式化所有代码
moon info                       # 更新 .mbti 绑定文件

# 3. 运行测试
moon test                       # 全量测试
moon test lib/algo/pagerank     # 单模块测试
moon test --update              # 更新快照

# 4. 覆盖率
moon coverage analyze
```

## 文档站点（仅编辑文档时需要）

```bash
cd site

# 安装依赖
bun install

# 开发服务器
bun run dev                     # http://localhost:4321

# 构建
bun run build                   # 输出到 dist/

# 预览
bun run preview
```

## 提交 Pull Request

```bash
git checkout -b feature/your-feature
git add <files>
git commit -m "feat(module): description"
git push origin feature/your-feature
```

然后在 GitHub 上创建 PR 到 `moonbit/mbtgraph` 的 `main` 或 `site` 分支。

---

**相关文档：**
- [编码规范](/contributing/coding-standards)
- [测试规范](/contributing/testing)
- [文档更新流程](/contributing/documentation)
