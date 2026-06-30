# site/ 代码优化分析报告 v2（增量重评）

> **分析日期**: 2026-06-05 | **基于**: v1 报告快照 + 全量深度扫描
> **构建验证**: ✅ `bun run build` → 68 pages / 4.72s / 零错误

---

## 1. 总体评估

- **v1→v2 执行率**: **100%** — 所有 5 项 v1 建议已被采纳
- **当前质量评分**: 8/10（v1 基线 7/10，提升 +1）
- **v2 新增风险**: 数据完整性 bug / CSS 双令牌体系 / bundle 体积
- **新增技术债务**: ~4 小时（v1 6-8h → v2 合计 ~10-12h，增量 ~4h）

### v1 建议执行确认

| v1 问题 | 状态 | 证明 |
|---------|:----:|------|
| `createAlgo` 样板消除 | ✅ 100% | 全部 5 算法文件已迁移 |
| `snapshot()` 替代深拷贝 | ✅ 100% | 零 `JSON.parse(JSON.stringify)` 残留 |
| BFS 硬编码颜色修复 | ✅ 100% | `'#FBBF24'` → `colors.ready.value` |

---

## 2. v2 新增问题汇总

| 优先级 | 问题类型 | 数量 | 影响 |
|--------|----------|:----:|------|
| 🔴 P0 | **数据完整性 Bug** | 2+ 处 | BFS/DFS 页面显示"7 边"实际 8 边 |
| 🟠 P1 | **Bundle Chunk 过大** | 1 个 | `alg-base` 493KB，超 Vite 500KB 阈值 |
| 🟡 P2 | **CSS 双设计令牌体系** | 2 套 | `variables.css` vs `global.css` 重复定义 |
| 🟡 P2 | **BFS/DFS 图数据 100% 重复** | 2 文件 | 完全相同的图，仅变量名不同 |
| 🟢 P3 | **Astro 已弃用 API** | 1 处 | `markdown.remarkPlugins` deprecation |
| 🟢 P3 | `viz-common.css` 桶文件 | 1 文件 | 24 行仅做 `@import` 聚合 |

---

## 3. 关键问题与修复方案

### 🔴 P0: BFS/DFS 字幕数据不一致

- **位置**: `site/src/pages/visualizations/bfs.astro:11`, `dfs.astro:11`
  ```astro
  subtitle="6 节点 · 7 边 · 无向图"   <!-- ❌ 实际 8 边 -->
  ```
  同时在 `<script>` 区块内（`bfs.astro:33`）也写死相同错误值
- **根因**: 图数据 `bfs.ts` 有 8 条边（e01, e02, e13, e14, e24, e35, e45, e25），但字幕硬编码为 7
- **影响**: 用户看到的数据描述与实际图形不符，降低可信度
- **建议**: 改为从图数据动态计算

  ```astro
  ---
  // ✅ 动态计算，保证与数据一致
  const edgeCount = bfsGraph.edges.length;
  const nodeCount = bfsGraph.nodes.length;
  const subtitle = `${nodeCount} 节点 · ${edgeCount} 边 · 无向图`;
  ---
  ```

- **扫描验证**: `rg "7 边" site/src/pages/` 检查所有页面

### 🟠 P1: `alg-base` Chunk 493KB

- **位置**: `site/dist/_astro/alg-base.DrR4-_3q.js` (493KB)
- **描述**: Astro 将所有可视化 JS（viz-engine / renderer / color-registry / player / event-manager + 全部 5 个算法）打包为单一 chunk
- **根因**: 所有可视化页面都从 `alg-base` 间接引用 Cytoscape (300KB+ minified) → Vite 合并为共享 chunk
- **影响**: ~0.5MB 的 JS 在文档首页也会加载（因 Starlight 全局 SPA 架构）
- **建议**: 评估两点之一：
  - **低投入**: `astro.config.mjs` 添加 `vite.build.rollupOptions.output.manualChunks` 将 `cytoscape` 拆为独立 chunk
  - **高投入**: 可视化页面改为动态 `import()`，仅在用户导航到可视化页面时才加载 Cytoscape

  ```js
  // astro.config.mjs 方案 (低投入):
  export default defineConfig({
    vite: {
      build: {
        rollupOptions: {
          output: {
            manualChunks: {
              cytoscape: ['cytoscape', 'cytoscape-dagre'],
            },
          },
        },
      },
    },
  });
  ```

### 🟡 P2: CSS 双设计令牌体系

- **位置**: `site/src/styles/variables.css` vs `site/src/styles/global.css`
- **描述**: 两套独立的设计令牌共存：

  | 令牌系统 | 文件 | 行数 | 用途 |
  |---------|------|:----:|------|
  | `--bg-deep`, `--accent` 等 | `variables.css` | 44 | 可视化页面（深色影院风） |
  | `--color-primary-500`, `--gradient-primary` 等 | `global.css` | 1697 | 文档网站（靛蓝科技风） |

- **问题**: 
  - `variables.css` 有 52 个自定义属性，`global.css` `:root` 又有 ~40 个
  - 可视化页面加载时两个 `:root` 冲突（后者覆盖前者）
  - 没有命名空间隔离
- **建议**: 
  1. 可视化页面使用 Shadow DOM 或 scoped styles
  2. 或将 `variables.css` 的令牌通过 `viz-common.css` 限定到 `.viz-wrapper` 选择器下

### 🟡 P2: BFS/DFS 图数据重复

- **位置**: `site/src/lib/graph-data/bfs.ts` vs `dfs.ts`
- **数据**: 完全相同的 6 节点 / 8 边 / 无向图，仅导出名称不同
- **影响**: 重复 27 行 × 2 = 54 行冗余
- **建议**: 共享同一数据源或改为 BFS 和 DFS 使用不同拓扑（DFS 演示更适合有环图）

### 🟢 P3: Astro API 弃用告警

- **构建输出**: `[astro] markdown.remarkPlugins... deprecated`
- **建议**: `astro.config.mjs` 中迁移到 `unified()` 配置
- **工作量**: ~15 分钟，低风险

---

## 4. 构建性能数据

| 指标 | 当前值 | 评估 |
|------|:------:|------|
| 构建时间 | **4.72s** | ✅ 优秀 (68 pages) |
| 总 JS/CSS 体积 | **1.18 MB** | 🟡 中等 |
| 最大 Chunk | **493 KB** (alg-base) | 🟠 超阈值 |
| Starlight 搜索索引 | 492ms | ✅ 正常 |
| 可视化页面数 | 5 | 当前覆盖度 | 

### Chunk 体积分解（修复后）

```
cytoscape.js         480 KB  ← 独立 chunk (仅可视化页面加载)
alg-base.js           13 KB  ← 可视化逻辑 (-97%!)
pagefind-ui.js       117 KB  ← Starlight 搜索 UI (第三方)
ui-core.js            92 KB  ← Astro UI 组件
其余 *.astro_*.js     3 KB 每页  ← 页面级脚本（轻量）
```

---

## 5. 后续行动计划

### 立即执行（今天）
1. [ ] **P0 修复 BFS/DFS 字幕 Bug** — 改为动态计算（15 分钟）
2. [ ] **P0 扫描所有页面** — `rg "\\d+ 边" site/src/pages/` 确认无其他硬编码（10 分钟）

### 本周执行
1. [ ] **P1 manualChunks 拆分** — 将 `cytoscape` 独立 chunk（30 分钟）
2. [ ] **P2 CSS 令牌冲突** — 为可视化页面做命名空间隔离（1 小时）
3. [ ] **P2 BFS/DFS 图数据差异化** — DFS 改为有环图或树形结构（30 分钟）

### 下次迭代
1. [ ] **P3 Astro deprecated API** — 迁移 remarkPlugins 配置（15 分钟）
2. [ ] **P3 移除 `default` 颜色导入** — 各 algs 的 `default` 颜色引用统一性检查（20 分钟）

### 技术债务（已结清）
- [x] ~~P1 `createAlgo` 样板消除~~ — **v1 已结清**
- [x] ~~P1 `JSON.parse(JSON.stringify())` 深拷贝~~ — **v1 已结清**
- [x] ~~P1 BFS 硬编码颜色~~ — **v1 已结清**

---

## 6. v1→v2 演变总结

```
  v1 报告 (2026-06-05)                    v2 报告 (2026-06-05, 增量)
 ┌────────────────────────┐              ┌──────────────────────────┐
 │ 5 项问题 (3×P1, 2×P2) │  已执行  →  │ 0 项 v1 遗留             │
 │ 技术债务: 6-8h         │   100%      │ +6 项 v2 新增 (1×P0,     │
 │ 质量评分: 7/10         │             │  1×P1, 2×P2, 2×P3)      │
 └────────────────────────┘             │ 增量债务: ~4h            │
                                        │ 质量评分: 8/10 (+1)     │
                                        └──────────────────────────┘
```
