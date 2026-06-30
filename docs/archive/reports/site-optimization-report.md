# site/ 代码优化分析报告

> **目标**: Astro + Cytoscape 可视化站点 (TypeScript)
> **版本**: v0.16.0 (基于 `site` 分支)
> **分析日期**: 2026-06-05

---

## 1. 总体评估

- **代码质量评分**: 7/10 — 3 层架构清晰，但有明显可优化点
- **复杂度**: 中低
- **可维护性**: 中高
- **主要风险**:
  - 🟠 JSON.parse(JSON.stringify()) 深拷贝反模式 × 5 个算法文件（性能 + 正确性风险）
  - 🟠 算法文件样板代码重复（~40 行 × 5）
  - 🟡 颜色硬编码绕过 ColorRegistry 体系
- **技术债务**: ~6-8 小时

## 2. 问题汇总

| 优先级 | 问题类型 | 数量 | 影响范围 |
|--------|----------|:----:|----------|
| P1 | 硬编码颜色破坏配色体系 | 1 | bfs.ts |
| P1 | 深拷贝反模式 | 5 文件 × 多处 | 所有 5 个算法 generateSteps |
| P1 | 算法样板代码重复 | 5 文件 × ~40 行 | 所有 5 个算法文件 |
| P2 | `init()` 方法职责过重 | 1 | viz-engine.ts (99 行) |
| P2 | `_rebuildTo` O(n²) 渲染 | 1 | viz-engine.ts |
| P3 | 死注释 / 魔法数字 / 不一致 | 多处 | 全局 |

## 3. 关键问题与重构方案

### 🟠 问题 1: 深拷贝反模式（最高收益）

- **位置**: `site/src/lib/algs/*.ts` — 所有 5 个文件的 `generateSteps` 方法
- **描述**: 每个算法在每个 step 都使用 `JSON.parse(JSON.stringify(obj))` 深拷贝状态对象，导致：
  - O(steps × nodes) 序列化+解析开销
  - `Infinity` → `null` 语义丢失（Dijkstra 初始距离）
  - 内存分配爆炸
- **影响**: 对 100 节点 × 100 steps 的图，每次 step 拷贝 3-4 个对象 → 30,000+ 次属性操作
- **建议**: 使用浅拷贝快照 + 结构共享

- **重构代码**:
  ```typescript
  // ❌ 当前（所有算法文件）
  steps.push({
    dist: JSON.parse(JSON.stringify(dist)),  // Infinity → null
    parent: JSON.parse(JSON.stringify(parent)),
    visited: JSON.parse(JSON.stringify(visited)),
  });

  // ✅ 建议：轻量级快照函数
  function snapshot<T extends Record<string, unknown>>(obj: T): T {
    const copy = {} as T;
    for (const k in obj) copy[k] = obj[k];
    return copy;
  }

  steps.push({
    dist: snapshot(dist),     // 保留 Infinity
    parent: snapshot(parent),
    visited: snapshot(visited),
  });
  ```

- **验证方法**:
  1. `npm run build` 通过
  2. 手动测试每个可视化页面，确认步骤动画正确
  3. Dijkstra 页面确认 `∞` 符号正常显示

### 🟠 问题 2: 算法样板代码重复

- **位置**: `site/src/lib/algs/bfs.ts`, `dfs.ts`, `dijkstra.ts`, `topo.ts`, `cycle.ts`
- **描述**: 每个算法文件都重复以下完全相同或高度相似的样板 ~40 行：

  ```typescript
  import VizRenderer from '../viz-renderer';
  import type { RenderMode } from '../viz-renderer';
  import type { ColorMap, LegendSelector } from '../color-registry';
  import { darken } from '../color-registry';
  import type { UIState } from '../viz-engine';

  export const legendKeys: LegendSelector[] = [...];
  interface XStep { ... }

  const X = {
    legendKeys,
    generateSteps(...): XStep[] { ... },
    renderStep(renderer, step, mode, speed, colors) { ... },
    getUIData(step, state): Record<string, string> { ... },
  };
  export default X;
  ```

- **影响**: 5 个文件各 40 行 = ~200 行重复，新增算法需完整复制
- **建议**: 创建 `BaseAlgo` 工厂函数

- **重构代码**:

  新建 `site/src/lib/alg-base.ts`:
  ```typescript
  import VizRenderer from './viz-renderer';
  import type { RenderMode } from './viz-renderer';
  import type { ColorMap, LegendSelector } from './color-registry';
  import { darken } from './color-registry';
  import type { UIState } from './viz-engine';

  export interface AlgoImpl<TStep> {
    legendKeys: LegendSelector[];
    generateSteps(
      nodes: Array<{ data: { id: string; label: string } }>,
      adjList: Record<string, string[]>,
      edgeWeights?: Record<string, number>,
      startNode?: string,
    ): TStep[];
    renderStep(renderer: VizRenderer, step: TStep, mode: RenderMode, speed: number, colors: ColorMap): void;
    getUIData(step: TStep | null, state: UIState): Record<string, string>;
  }

  export function createAlgo<TStep>(impl: AlgoImpl<TStep>) {
    return impl;
  }
  ```

  各算法文件变为：
  ```typescript
  import { createAlgo } from '../alg-base';
  import type { AlgoModule } from '../viz-engine';

  // ... 仅核心逻辑，无样板 import ...

  const Dijkstra = createAlgo({
    legendKeys,
    generateSteps(...): DijkstraStep[] { ... },
    renderStep(...) { ... },
    getUIData(...) { ... },
  });
  export default Dijkstra;
  ```

- **验证方法**: `npm run build` + 各页面功能验证

### 🟠 问题 3: 硬编码颜色绕过 ColorRegistry

- **位置**: `site/src/lib/algs/bfs.ts:157-159`
  ```typescript
  renderer.setNode(tgt, {
    backgroundColor: '#FBBF24',   // ❌ 硬编码
    borderColor: '#F59E0B',       // ❌ 硬编码
    borderWidth: 3,
  }, mode, Math.max(100, speed * 0.5));
  ```
- **影响**: 换主题时此节点不会跟随变化；破坏单一颜色数据源原则
- **建议**: 在 ColorRegistry 中注册 `ready` 颜色，改用 `colors.*.value`

- **重构代码**:
  ```typescript
  // 在 color-registry.ts 中添加
  node: {
    // ... existing
    ready: { value: '#FBBF24', label: '就绪' },  // 新增
  }

  // bfs.ts 中改为
  renderer.setNode(tgt, {
    backgroundColor: colors.ready.value,
    borderColor: darken(colors.ready.value),
    borderWidth: 3,
  }, mode, Math.max(100, speed * 0.5));
  ```

### 🟡 问题 4: `init()` 职责过重

- **位置**: `viz-engine.ts:202-301`（99 行）
- **描述**: `init()` 同时处理 DOM 缓存、图构建、Cytoscape 初始化、Player/Event 初始化、Loading 遮罩、Header 更新
- **建议**: 拆分为 `_initCytoscape()`, `_initPlayer()`, `_initEvents()`, `_hideLoading()`, `_updateHeader()` 等职责方法
- **验证**: `npm run build` + 功能测试

### 🟡 问题 5: `_rebuildTo` O(n²) 渲染

- **位置**: `viz-engine.ts:366-380`
- **描述**: 跳转到 step N 时 `resetAll()` + 重渲染 0→N 所有步骤，每步可能更新多个元素
- **影响**: 50+ steps 时跳转有明显卡顿
- **建议**: 量化影响后决定是否优化。由于 DAG 布局是异步的，此问题被 Cytoscape 布局时间掩盖

## 4. 性能优化建议

| 建议 | 当前 | 优化后 | 预期提升 |
|------|------|--------|:--------:|
| 浅拷贝替代 JSON 深拷贝 | 序列化+解析 O(n) × steps × 3 | 属性复制 O(n) × steps | 3-5x 快 |
| `_rebuildTo` 增量渲染 | 全量重绘 0→N | 仅渲染差异步骤 | 2-3x（大图） |
| 缓存 Cytoscape element 引用 | 每次 setEdge 拼接 CSS 选择器字符串 | 缓存 ID → ele 映射 | 1.2-1.5x |

## 5. 安全性检查清单

- [x] XSS — 无用户输入渲染（数据硬编码）
- [x] CSRF — 无后端交互
- [x] 密钥泄露 — 无密钥
- [x] 依赖安全 — 仅 Astro + Cytoscape 标准依赖

## 6. 后续行动计划

**本周执行**:
1. [ ] **P1 深拷贝修复** — 所有 5 个算法文件改用 `snapshot()` (~1 小时)
2. [ ] **P1 bfs.ts 硬编码颜色修复** — 注册 `ready` 颜色 + 替换 (~30 分钟)
3. [ ] **P1 样板代码消除** — 创建 `alg-base.ts` + 改造 5 个文件 (~2 小时)

**下次迭代**:
1. [ ] **P2 `init()` 拆分** — ~1 小时
2. [ ] **P2 `_rebuildTo` 评估** — 对比 ~2 小时
3. [ ] **P3 魔法数字提取** — 集中到常量文件 ~1 小时
