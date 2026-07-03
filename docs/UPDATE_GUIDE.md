# mbtgraph 项目配置与文档更新规范

> **定位**: 🤖 **Agent自动化指南** — 定义何时、何地、如何更新项目配置和文档
>
> **版本**: v0.1.1 | **创建日期**: 2026-05-23 | **适用范围**: 配置文件 + 文档文件（不含代码）
>
> **目标用户**: AI Agent / 开发者 / CI/CD Pipeline

---

## 📋 文档概览

### 核心目标

本规范旨在解决以下问题：
- ✅ **消除遗漏**：代码完成后忘记更新文档
- ✅ **保证一致性**：各处版本号/数据保持同步
- ✅ **提升效率**：Agent可自动判断需要更新哪些文件
- ✅ **标准化流程**：统一的更新优先级和检查项

### 适用范围

| 类别 | 包含 | 不包含 |
|------|------|--------|
| ✅ 配置文件 | `moon.mod.json`, `.gitignore`, `*.pkg` 等 | 源代码 `.mbt` |
| ✅ 项目文档 | `AGENTS.md`, `MEMORY.md`, `README*` 等 | 设计文档 `docs/design/*` |
| ✅ 版本管理 | Git Tags, `CHANGELOG.md` | 代码逻辑修改 |
| ❌ 代码文件 | 所有 `.mbt` 源文件 | — |
| ❌ 测试文件 | `*_test.mbt`, `*_wbtest.mbt` | — |

---

## 🎯 触发条件矩阵（何时更新）

### Level 1: 日常开发（每次代码提交后）

#### 1.1 完成单个算法函数

**触发条件**: 新增/修改了1个公开API函数

| 优先级 | 文件路径 | 更新内容 | 必要性 |
|:-----:|---------|----------|:-----:|
| P0 | 对应模块README.md | API文档（函数签名+示例） | ⭐⭐⭐ 必须 |
| P1 | CHANGELOG.md | [Unreleased] 区添加条目 | ⭐⭐ 推荐 |
| P2 | MEMORY.md | 如涉及新决策则记录 | ⭐ 可选 |

**示例**:
```bash
# 在 flow 模块新增 dinic 函数后
✅ 更新: lib/algo/flow/README.md (添加dinic API文档)
✅ 更新: CHANGELOG.md (Unreleased区添加"+ Dinic算法")
⏭️ 跳过: MEMORY.md (无架构决策变更)
```

---

#### 1.2 完成单个测试用例

**触发条件**: 新增/修改了测试代码

| 优先级 | 文件路径 | 更新内容 | 必要性 |
|:-----:|---------|----------|:-----:|
| P0 | 无（测试自包含） | — | — |
| P1 | docs/TODO.md | 如完成TODO任务则标记✅ | ⭐ 可选 |

**注意**: 测试代码本身是自文档化的，通常不需要额外更新。

---

### Level 2: 模块级完成（完成一个完整子模块）

#### 2.1 完成新的算法子模块（如 euler/clique）

**触发条件**: 一个新的 `lib/algo/xxx/` 子模块全部完成（类型+算法+测试+文档）

| 优先级 | 文件路径 | 更新内容 | 必要性 |
|:-----:|---------|----------|:-----:|
| **P0** | **moon.mod.json** | **version → minor+1 (如 0.4.0→0.5.0)** | **⭐⭐⭐ 必须** |
| **P0** | **MEMORY.md** | **包结构添加新模块 + 测试数据更新 + 决策记录** | **⭐⭐⭐ 必须** |
| **P0** | **README.mbt.md** | **算法表格添加新模块 + 总测试数更新 + 版本路线图** | **⭐⭐⭐ 必须** |
| **P0** | **CHANGELOG.md** | **新增版本章节 [vX.Y.Z] 记录完整变更** | **⭐⭐⭐ 必须** |
| **P0** | **Git Tag** | **创建标签 `git tag v0.X.0 -m "..."`** | **⭐⭐⭐ 必须** |
| P1 | docs/ROADMAP.md | 状态更新为✅ + 统计数据刷新 | ⭐⭐ 推荐 |
| P1 | docs/TODO.md | 相关任务标记已完成 + 里程碑更新 | ⭐⭐ 推荐 |
| P2 | AGENTS.md | 项目结构添加新模块行（仅低频更新） | ⭐ 可选 |

**完整 Checklist**:
```bash
# 假设完成 hamiltonian 模块后的标准操作流：

✅ P0-1: moon.mod.json        → "version": "0.5.0" (0.4.1→0.5.0)
✅ P0-2: MEMORY.md           → 包结构添加 hamiltonian + 测试数 483→503? + 决策记录
✅ P0-3: README.mbt.md       → 算法表添加 Hamiltonian 行 + 总测试数 + 路线图 v0.5.0当前
✅ P0-4: CHANGELOG.md        → 新增 [0.5.0] 章节 + Unreleased 清空
✅ P0-5: Git Tag             → git tag v0.5.0 -m "release(v0.5.0): ..."
✅ P1-1: docs/ROADMAP.md     → v0.5.0 状态改为✅ + 数据更新
✅ P1-2: docs/TODO.md        → T08 标记✅ + 里程碑表更新
⏭️ P2:   AGENTS.md          → 仅低频更新（项目结构新增模块行）
⏭️ P2:   hamiltonian/README.md → 应在Commit 4: docs阶段已完成
```

---

#### 2.2 完成重构或重大修改

**触发条件**: 跨模块重构、Trait变更、存储层修改

| 优先级 | 文件路径 | 更新内容 | 必要性 |
|:-----:|---------|----------|:-----:|
| P0 | AGENTS.md | 编码规范/架构概要/错误速查 | ⭐⭐⭐ 必须 |
| P0 | MEMORY.md | 关键决策记录 + 架构约定 | ⭐⭐⭐ 必须 |
| P0 | docs/ARCHITECTURE.md | 架构设计文档同步更新 | ⭐⭐⭐ 必须 |
| P1 | README.mbt.md | 架构说明/ Trait分层图 | ⭐⭐ 推荐 |
| P2 | CHANGELOG.md | Breaking Changes 记录 | ⭐ 可选 |

---

### Level 3: 版本发布（Release）

#### 3.1 发布新版本（Minor/Patch）

**触发条件**: 准备发布新版本到远程仓库

| 优先级 | 文件路径 | 更新内容 | 必要性 |
|:-----:|---------|----------|:-----:|
| **P0** | **moon.mod.json** | **确认 version 正确** | **⭐⭐⭐ 必须** |
| **P0** | **CHANGELOG.md** | **[Unreleased] 内容移至版本号下** | **⭐⭐⭐ 必须** |
| **P0** | **Git Tag** | **创建 Annotated Tag** | **⭐⭐⭐ 必须** |
| **P0** | **所有文档版本号** | **确保一致性** | **⭐⭐⭐ 必须** |
| P1 | README.mbt.md | Release Notes / 安装命令 | ⭐⭐ 推荐 |
| P2 | docs/ROADMAP.md | 里程碑时间轴更新 | ⭐ 可选 |

**发布前最终检查**:
```bash
# 1. 运行全量测试
moon test                          # 必须 100% 通过

# 2. 检查版本号一致性
grep -r "0\.5\." --include="*.json" --include="*.md"
# 确保所有位置都是同一版本号

# 3. 检查测试数一致性
grep -r "483 tests\|483t" --include="*.md"
# 确保文档中的测试数量与实际一致

# 4. 创建Tag
git tag -a v0.5.0 -m "release(v0.5.0): 详细描述"

# 5. 推送
git push origin master --tags
```

---

## 📊 文件更新规则详解

### 1. moon.mod.json（包配置）

**路径**: 项目根目录  
**更新频率**: 每次模块完成 / 版本发布  
**关键字段**:

```json
{
  "version": "0.5.0",           // ← 唯一权威版本号源
  "description": "...(P0-P5, 483 tests)",  // ← 反映当前状态
  "readme": "README.mbt.md"      // ← 通常不变
}
```

**更新规则**:
- **Minor版本递增** (`x.Y.z` → `x.(Y+1).z`): 完成新模块时
- **Patch版本递增** (`x.y.Z` → `x.y.(Z+1)`): Bug修复/文档更新时
- **description**: 每次更新时同步修改（反映完成的Phase和测试数）

**⚠️ 注意**: 此文件的version是整个项目的**唯一权威版本号源**，其他所有文件必须与此保持一致。

---

### 2. AGENTS.md（Agent协作配置）

**路径**: 项目根目录  
**更新频率**: **低频**（仅架构变更/规范重大更新时）— 设计为稳定文档，避免版本号/日期/统计数等动态元数据  
**关键区域**:

| 区域 | 触发更新条件 | 更新内容 |
|------|-------------|----------|
| **项目结构** | 新增/删除模块（低频） | `algo/` 下的模块列表 |
| **Trait分层** | Trait系统变更 | 层数/方法数描述 |
| **编码规范** | 发现新陷阱或规则变更 | R1-R7 规则表 |
| **错误速查** | 遇到新错误码 | 错误码速查表 |
| **算法开发流程** | 流程优化 | SOP 步骤 |

**⚠️ 不要更新以下内容（避免版本膨胀）**:
- 版本号/日期标记 — 委托给 CHANGELOG.md
- 测试数/算法数等统计 — 委托给 CHANGELOG.md
- 文档索引中的最后更新日期 — 仅保留路径和用途
- 版本历史表 — 委托给 CHANGELOG.md

---

### 3. MEMORY.md（项目记忆）

**路径**: 项目根目录  
**更新频率**: 重要决策 / 模块完成 / 架构变更  
**关键区域**:

| 区域 | 触发更新条件 | 更新内容 |
|------|-------------|----------|
| **包结构** | 新增/删除/重命名模块 | `lib/` 目录树 |
| **测试状态** | 测试数变化 | 覆盖率表格 |
| **关键决策记录** | 重要技术决策 | 决策表追加行 |
| **语法陷阱** | 遇到新陷阱 | 陷阱表追加行 |

**重要原则**:
- ✅ **必须记录**: 新算法选型理由、架构权衡、性能优化决策
- ✅ **建议记录**: 遇到的MoonBit特殊行为、编译器bug workaround
- ⏭️ **无需记录**: 日常bug修复、格式调整、注释改进

---

### 4. README.mbt.md（主文档）

**路径**: 项目根目录  
**更新频率**: 模块完成 / 版本发布 / 重大功能变更  
**关键区域**:

| 区域 | 触发更新 | 具体操作 |
|------|---------|----------|
| **安装命令** | 版本号变化 | `@0.x.y` 更新 |
| **算法覆盖表** | 新模块完成 | 添加新行（带🆕标记） |
| **总统计数字** | 测试数/代码行变化 | 更新数值 |
| **项目结构树** | 模块增删 | 同步目录树 |
| **版本路线图** | 里程碑达成 | 状态更新 + 当前版本标记 |
| **竞品对比表** | 显著优势变化 | 数据更新 |

**⚠️ 特别注意**:
- 算法覆盖表的测试数必须与 `moon test` 输出完全一致
- 版本路线图的"当前版本"必须有且仅有一个 ✅ 标记

---

### 5. CHANGELOG.md（变更日志）

**路径**: 项目根目录  
**更新频率**: 每次版本发布 / 重大功能添加  
**格式规范**:

```markdown
## [未发布]

### 新增
- 功能A
- 功能B

---

## [0.5.0] - 2026-05-23

### 重大新增
- 完整的功能描述...

### 统计数据
- 测试数: XXX (+YY)
- 包数: XX
```

**更新规则**:
1. **开发期间**: 所有变更累加到 `[未发布]` 区
2. **发布时**: 将 `[未发布]` 内容移至 `[vX.Y.Z]` 下
3. **清空 `[未发布]`**: 发布后清空或保留少量进行中项
4. **链接更新**: 底部链接列表添加新版本

---

### 6. Git Tags（版本标签）

**创建时机**: 每个重要里程碑完成时  
**命名规范**:

```
v0.1.0    # 初始版本 (P0-P3)
v0.4.0    # P4完成 (Matching+Dinic)
v0.5.0    # P5完成 (Euler/Cutpoints/Coloring/Clique/Hamiltonian)
v0.6.0    # 下一个模块或工程化里程碑
```

**创建命令**:
```bash
# Annotated Tag（推荐，包含详细信息）
git tag -a v0.5.0 -m "release(v0.5.0): P5图论核心算法扩展完成 (483 tests, 14 packages)"

# Lightweight Tag（仅用于临时标记）
git tag v0.5.0-temp
```

**推送Tags**:
```bash
# 推送单个tag
git push origin v0.5.0

# 推送所有tags
git push origin --tags
```

---

### 7. docs/ROADMAP.md（路线图）

**路径**: `docs/ROADMAP.md`  
**更新频率**: 里程碑达成 / 季度规划变更  
**关键区域**:

| 区域 | 更新时机 | 操作 |
|------|---------|------|
| 状态快照 | 模块完成 | 更新统计数据（包数/测试数/API数） |
| Phase进度 | 里程碑达成 | 进度条百分比更新 |
| 已完成模块表 | 新模块完成 | 添加新行 |
| 版本里程碑表 | 版本发布 | 状态列更新 |
| 依赖关系图 | 模块关系变化 | 图形更新 |
| 更新日志 | 每次更新 | 追加版本行 |

---

### 8. docs/TODO.md（行动清单）

**路径**: `docs/TODO.md`  
**更新频率**: 任务状态变更 / 新任务产生  
**关键区域**:

| 区域 | 更新时机 | 操作 |
|------|---------|------|
| 当前基线 | 版本/测试数变化 | 更新快照 |
| 已完成任务 | 任务完成 | 从P0/P1/P2移至此区并标记✅ |
| P0/P1/P2任务 | 新任务产生 | 添加到对应优先级区 |
| 进度追踪表 | 里程碑达成 | 状态更新 |
| Sprint布局 | 周期性规划 | 重新排列 |

---

## 🔍 一致性检查清单（更新后必做）

### 自动化检查（推荐加入CI）

```bash
#!/bin/bash
# check_doc_consistency.sh

echo "🔍 开始文档一致性检查..."

# 1. 版本号一致性检查
MOON_VERSION=$(grep '"version"' moon.mod.json | grep -o '[0-9]\.[0-9]\.[0-9]')
echo "📦 moon.mod.json 版本: $MOON_VERSION"

# 检查各文档是否包含该版本号
for file in README.mbt.md CHANGELOG.md; do
  if grep -q "$MOON_VERSION" "$file"; then
    echo "✅ $file 版本一致"
  else
    echo "❌ $file 版本不一致或缺失!"
  fi
done

# 2. 测试数一致性检查
ACTUAL_TESTS=$(moon test 2>&1 | grep -o 'passed: [0-9]*' | grep -o '[0-9]*')
echo "🧪 实际测试数: $ACTUAL_TESTS"

if grep -q "$ACTUAL_TESTS tests" README.mbt.md; then
  echo "✅ README.mbt.md 测试数一致"
else
  echo "⚠️ README.mbt.md 测试数可能需要更新"
fi

# 3. 模块计数检查
MODULE_COUNT=$(ls -d lib/algo/*/ 2>/dev/null | wc -l)
echo "📂 实际模块数: $MODULE_COUNT"

echo "✨ 检查完成!"
```

### 手动检查项（Checklist）

每次更新文档后，**必须**验证：

- [ ] **版本号一致性**: `moon.mod.json` = `README.mbt.md` = `CHANGELOG.md最新版`
- [ ] **测试数一致性**: `moon test输出` = `README.mbt.md总测试数` = `MEMORY.md合计` = `ROADMAP.md`
- [ ] **模块列表完整性**: `lib/algo/实际目录` = `AGENTS.md项目结构` = `README.mbt.md算法表` = `MEMORY.md包结构`
- [ ] **Git Tag存在性**: 每个已发布的版本都有对应的tag
- [ ] **无过期信息**: 没有"即将完成"、"规划中"但实际已完成的内容
- [ ] **链接有效性**: 内部Markdown链接可正常跳转

---

## 🚀 场景化快速参考

### 场景A: 刚完成euler模块开发

```bash
# Step 1: 确认测试通过
moon test lib/algo/euler  # 22 passed ✅

# Step 2: 更新P0文件（按顺序）
vim moon.mod.json         # version: "0.4.1" → "0.5.0"
vim MEMORY.md            # 添加 euler 到包结构 + 测试数更新 + 决策记录
vim README.mbt.md        # 算法表添加 Euler 行 + 总测试数 461→483
vim CHANGELOG.md         # 添加 [0.5.0] 章节

# Step 3: 创建Tag
git tag -a v0.5.0 -m "release(v0.5.0): euler模块完成"

# Step 4: 更新P1文件
vim docs/ROADMAP.md      # 状态更新
vim docs/TODO.md         # T06 标记✅

# Step 5: 验证
./check_doc_consistency.sh
moon test                 # 全量测试 483/483 ✅

# Step 6: 提交
git add moon.mod.json MEMORY.md README.mbt.md \
        CHANGELOG.md docs/ROADMAP.md docs/TODO.md
git commit -m "release(v0.5.0): euler模块完成 + 文档同步更新"
```

---

### 场景B: 修复了一个小bug（不涉及新功能）

```bash
# Step 1: 确认修复
moon test  # 全部通过 ✅

# Step 2: 仅更新必要文件
vim CHANGELOG.md  # [Unreleased] 区添加 "- 修复xxx bug"

# Step 3: 如果决定发patch版本
vim moon.mod.json  # 0.5.0 → 0.5.1
vim CHANGELOG.md   # 新增 [0.5.1] 章节
git tag v0.5.1

# Step 4: 提交
git commit -m "fix: 修复xxx问题"
```

---

### 场景C: 重构了Trait分层体系

```bash
# Step 1: 确认编译和测试通过
moon check && moon test  # ✅

# Step 2: 全面更新（架构变更影响大）
vim AGENTS.md           # Trait分层图 + 编码规范（低频更新）
vim MEMORY.md           # 关键决策记录（重要！）
vim docs/ARCHITECTURE.md # 架构文档（核心！）
vim README.mbt.md       # Trait分层体系说明
vim CHANGELOG.md        # Breaking Changes记录

# Step 3: 可能需要Major版本升级
vim moon.mod.json       # 0.5.0 → 1.0.0 (如果Breaking Change)

# Step 4: 提交
git commit -m "refactor(core): Trait分层从4层扩展至6层"
```

---

## 📈 更新优先级总结

### 必须立即更新（P0 - Blocking）

这些文件**不更新会导致不一致或误导**：
1. ✅ **moon.mod.json** - 版本号权威源
2. ✅ **MEMORY.md** - 项目记忆完整性
3. ✅ **README.mbt.md** - 用户第一印象
4. ✅ **CHANGELOG.md** - 变更追溯
5. ✅ **Git Tags** - 版本快照

### 应该尽快更新（P1 - Recommended）

这些文件**延迟更新会影响项目管理**：
1. ⚡ **docs/ROADMAP.md** - 战略规划
2. ⚡ **docs/TODO.md** - 任务追踪

### 有空再更新（P2 - Optional）

这些文件**不影响功能，但完善度更好**：
1. 💡 **AGENTS.md** - 仅架构变更时低频更新
2. 💡 **设计文档** (`docs/design/*`) - 技术细节
3. 💡 **竞品对比** (`docs/archive/reference/*`) - 参考信息

---

## 🎯 最佳实践

### 1. 原子性提交

将文档更新与代码提交分离，或合并为逻辑原子单元：

```bash
# ✅ 推荐：文档跟随功能一起提交
git add types.mbt algorithm.mbt test.mbt README.md
git commit -m "feat(module): 实现xxx算法 (含文档更新)"

# ✅ 或：独立文档提交
git add AGENTS.md MEMORY.md README.mbt.md CHANGELOG.md
git commit -m "docs: 同步更新项目文档至v0.5.0"
```

### 2. 批量更新策略

完成多个模块后一次性更新（避免频繁小更新）：

```bash
# 完成 euler + cutpoints + coloring 后统一更新
# 一次性：moon.mod.json → 0.5.0 (跨越多个minor版本)
# 或分步：v0.5.0(euler) → v0.6.0(cutpoints) → v0.7.0(coloring)
```

### 3. 版本号策略建议

对于mbtgraph项目，推荐：
- **每个P5子模块完成** → minor版本+1 (0.4.0, 0.5.0, 0.6.0...)
- **Bug修复/文档更正** → patch版本+1 (0.5.0, 0.5.1, 0.5.2...)
- **Breaking Change** → major版本+1 (1.0.0)

---

## 🔧 工具支持

### VS Code Snippet（推荐安装）

创建文件 `.vscode/snippets.code-snippets`:
```json
{
  "Update Docs for New Module": {
    "prefix": "updatedocs",
    "body": [
      "# 完成XXX模块后的文档更新Checklist",
      "",
      "## P0 必须",
      "- [ ] moon.mod.json: version+1",
      "- [ ] AGENTS.md: 添加模块行 + version+1",
      "- [ ] MEMORY.md: 包结构 + 测试数 + 决策",
      "- [ ] README.mbt.md: 算法表 + 统计 + 路线图",
      "- [ ] CHANGELOG.md: 新版本章节",
      "- [ ] Git: git tag -a v0.X.0",
      "",
      "## P1 推荐",
      "- [ ] docs/ROADMAP.md: 状态更新",
      "- [ ] docs/TODO.md: 任务标记",
      "",
      "## 验证",
      "- [ ] moon test (100%通过)",
      "- [ ] 版本号一致性检查",
      "- [ ] 测试数一致性检查"
    ],
    "description": "新模块完成后的文档更新清单"
  }
}
```

---

## 📚 相关文档

| 文档 | 用途 | 优先阅读 |
|------|------|:-------:|
| [AGENTS.md](../AGENTS.md) | 开发规范 | ⭐⭐⭐ |
| [MEMORY.md](../MEMORY.md) | 项目记忆 | ⭐⭐ |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | 贡献指南 | ⭐⭐ |
| [CHANGELOG.md](../CHANGELOG.md) | 变更历史 | ⭐ |

---

## 📝 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| **v1.0.0** | 2026-05-23 | 初始版本：定义完整的文档更新规范矩阵 |

---

> **💡 使用提示**: 
> 
> 1. **Agent使用**: 在完成代码后，对照本文档的"触发条件矩阵"自动识别需要更新的文件
> 
> 2. **开发者使用**: 每次commit前运行一致性检查脚本，确保无遗漏
> 
> 3. **CI集成**: 可将检查脚本加入pre-commit hook或CI pipeline
> 
> 4. **定期审查**: 每个版本发布前全面review一次所有文档的一致性
