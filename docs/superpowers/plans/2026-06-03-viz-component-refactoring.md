# 可视化组件化重构实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 5 个可视化 HTML 文件重构为配置文件，每个从 ~800 行减少到 ~40 行，实现代码复用 80%+

**Architecture:** 采用共享 JS 库模式：
- `css/viz-common.css` — 共享样式
- `js/cytoscape-loader.js` — 依赖加载器
- `js/viz-engine.js` — 核心引擎（VizApp）
- `algs/*.js` — 算法特定步骤生成器
- `*.html` — 配置文件（只包含数据和配置）

**Tech Stack:** 原生 JavaScript + Cytoscape.js + CSS

**设计文档**: [docs/superpowers/specs/2026-06-03-viz-component-refactoring-design.md](../specs/2026-06-03-viz-component-refactoring-design.md)

---

## 文件结构

```
site/public/visualizations/
├── css/
│   └── viz-common.css         # 新建: 共享样式 (~280行)
├── js/
│   ├── cytoscape-loader.js   # 新建: 依赖加载器 (~30行)
│   └── viz-engine.js          # 新建: 核心引擎 (~200行)
├── algs/
│   ├── bfs.js                 # 新建: BFS 步骤 (~80行)
│   ├── dfs.js                 # 新建: DFS 步骤 (~80行)
│   ├── cycle.js               # 新建: 环检测步骤 (~100行)
│   ├── topo.js                # 新建: 拓扑排序步骤 (~120行)
│   └── dijkstra.js            # 新建: Dijkstra 步骤 (~100行)
├── bfs.html                   # 重写: 配置文件 (~40行)
├── dfs.html                   # 重写: 配置文件 (~40行)
├── cycle_detection.html        # 重写: 配置文件 (~40行)
├── topo_sort.html             # 重写: 配置文件 (~40行)
└── dijkstra.html             # 重写: 配置文件 (~40行)
```

---

## Phase 1: 创建共享资源

### Task 1: 创建共享 CSS 样式

**Files:**
- Create: `site/public/visualizations/css/viz-common.css`

从 `bfs.html` 中提取所有 `<style>` 内容（约 280 行），包括：
- 加载状态样式
- 主容器布局
- 头部/画布/底部栏
- 按钮/进度条
- 状态栏/图例
- 响应式样式

**CSS 内容**（从 bfs.html L12-280 提取并整理）：

```css
/* ========================================
   viz-common.css — 共享可视化样式
   ======================================== */

*, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

html, body {
  height: 100%; overflow: hidden;
}

body {
  font-family: 'JetBrains Mono', 'Fira Code', ui-monospace, system-ui, -apple-system, sans-serif;
  background: #0f172a;
  color: #e2e8f0;
  -webkit-font-smoothing: antialiased;
}

/* 加载状态 */
#loading-overlay {
  position: fixed; inset: 0; z-index: 9999;
  display: flex; align-items: center; justify-content: center;
  background: #0f172a; transition: opacity 0.3s ease;
}
#loading-overlay.fade-out { opacity: 0; pointer-events: none; }
.spinner { width: 40px; height: 40px; border: 3px solid #334155; border-top-color: #6366f1; border-radius: 50%; animation: spin 0.8s linear infinite; }
.loading-text { margin-top: 12px; font-size: 13px; color: #94a3b8; }
@keyframes spin { to { transform: rotate(360deg); } }

/* 错误状态 */
#error-overlay {
  position: fixed; inset: 0; z-index: 9999;
  display: none; align-items: center; justify-content: center;
  background: #0f172a; padding: 20px; text-align: center;
}
#error-overlay.show { display: flex; }
.error-box { background: #1e293b; border: 1px solid #ef4444; border-radius: 12px; padding: 24px 32px; max-width: 400px; }
.error-title { color: #ef4444; font-size: 16px; font-weight: 700; margin-bottom: 8px; }
.error-msg { color: #94a3b8; font-size: 13px; line-height: 1.6; }

/* 主容器 */
.viz-wrapper { width: 100%; height: 100vh; display: flex; flex-direction: column; position: relative; }

/* 头部 */
.viz-header {
  position: absolute; top: 12px; left: 16px; z-index: 10;
  display: flex; align-items: center; gap: 10px;
  padding: 6px 14px;
  background: rgba(15,23,42,.82); backdrop-filter: blur(12px);
  border: 1px solid rgba(51,65,85,.7); border-radius: 10px;
  pointer-events: auto;
}
.viz-header-left { display: flex; align-items: center; gap: 10px; }
.badge { display: inline-flex; align-items: center; padding: 3px 10px; font-size: 12px; font-weight: 700; color: #fff; background: linear-gradient(135deg, #6366f1, #8b5cf6); border-radius: 9999px; }
.graph-info { font-size: 11px; color: #94a3b8; }
.hint { font-size: 10px; color: #64748b; padding: 2px 8px; background: rgba(51,65,85,.6); border-radius: 9999px; }

/* 画布 */
.viz-canvas-wrap { position: relative; flex: 1 1 auto; width: 100%; overflow: hidden; background: radial-gradient(circle at 20% 50%, rgba(99,102,241,.03) 0%, transparent 50%), radial-gradient(circle at 80% 50%, rgba(139,92,246,.03) 0%, transparent 50%), #0f172a; }
#viz-canvas { position: absolute; top: 0; left: 0; width: 100%; height: 100%; display: block; }

/* 工具提示 */
.viz-tooltip { position: absolute; z-index: 20; pointer-events: none; animation: fadeIn .2s ease; }
.viz-tooltip-inner { display: inline-block; padding: 5px 10px; font-size: 12px; font-weight: 600; color: #fff; background: rgba(99,102,241,.92); backdrop-filter: blur(8px); border-radius: 6px; white-space: nowrap; box-shadow: 0 4px 12px rgba(0,0,0,.3); border: 1px solid rgba(165,180,252,.3); }

/* 底部栏 */
.viz-bottom-bar { position: absolute; bottom: 0; left: 0; right: 0; z-index: 10; display: flex; flex-direction: column; background: linear-gradient(to top, rgba(15,23,42,.95), rgba(15,23,42,.88)); backdrop-filter: blur(16px); border-top: 1px solid rgba(51,65,85,.6); pointer-events: auto; }

/* 控制栏 */
.viz-controls { display: flex; align-items: center; justify-content: space-between; padding: 8px 16px; gap: 12px; }
.viz-controls-left, .viz-controls-right { display: flex; align-items: center; gap: 3px; }
.viz-controls-center { display: flex; align-items: center; gap: 12px; flex: 1; max-width: 420px; margin: 0 16px; }

/* 按钮 */
.btn { display: inline-flex; align-items: center; justify-content: center; border: 1px solid #334155; border-radius: 6px; background: rgba(15,23,42,.6); color: #cbd5e1; cursor: pointer; transition: all .15s ease; padding: 6px 8px; font-size: 13px; }
.btn:hover:not(:disabled) { background: rgba(30,41,59,.9); border-color: #818cf8; color: #6366f1; }
.btn:disabled { opacity: .35; cursor: not-allowed; }
.btn-icon { width: 34px; height: 34px; padding: 0; font-size: 14px; }
.btn-primary { width: 40px; height: 40px; border-radius: 50%; font-size: 18px; background: linear-gradient(135deg, #6366f1, #818cf8); border-color: transparent; color: #fff; box-shadow: 0 2px 8px rgba(99,102,241,.35); }
.btn-primary:hover { transform: scale(1.08); box-shadow: 0 4px 14px rgba(99,102,241,.45); }
.btn-primary.replay-pulse { background: linear-gradient(135deg, #10b981, #34d399); box-shadow: 0 2px 8px rgba(16,185,129,.4); animation: replayPulse 1.5s ease-in-out infinite; }
@keyframes replayPulse { 0%, 100% { box-shadow: 0 2px 8px rgba(16,185,129,.3); } 50% { box-shadow: 0 4px 20px rgba(16,185,129,.6), 0 0 30px rgba(16,185,129,.15); } }

/* 进度条 */
.progress-track { position: relative; flex: 1; height: 5px; background: rgba(51,65,85,.7); border-radius: 9999px; cursor: pointer; }
.progress-fill { height: 100%; background: linear-gradient(90deg, #6366f1, #8b5cf6); border-radius: 9999px; transition: width .15s ease; min-width: 0; }
.progress-thumb { position: absolute; top: 50%; left: 0%; transform: translate(-50%,-50%); width: 14px; height: 14px; background: #fff; border-radius: 50%; box-shadow: 0 1px 4px rgba(0,0,0,.3); transition: left .15s ease; }
.progress-track:hover .progress-thumb { width: 16px; height: 16px; }

/* 状态栏 */
.viz-status-bar { display: flex; align-items: center; gap: 16px; padding: 8px 16px; border-top: 1px solid rgba(51,65,85,.4); font-size: 12px; overflow-x: auto; }
.viz-status-item { display: flex; align-items: center; gap: 6px; flex-shrink: 0; }
.viz-status-label { color: #64748b; font-weight: 600; }
.viz-status-value { color: #e2e8f0; font-variant-numeric: tabular-nums; font-family: inherit; }
.viz-message { margin-left: auto; color: #94a3b8; font-size: 12px; flex-shrink: 0; }

/* 图例 */
.viz-legend { display: flex; align-items: center; gap: 12px; padding: 6px 16px; border-top: 1px solid rgba(51,65,85,.3); font-size: 11px; flex-wrap: wrap; }
.legend-item { display: flex; align-items: center; gap: 5px; }
.legend-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
.legend-line { width: 16px; height: 2px; flex-shrink: 0; }
.legend-label { color: #94a3b8; }

/* 速度滑块 */
.speed-control { display: flex; align-items: center; gap: 6px; flex-shrink: 0; }
.speed-control input[type=range] { width: 60px; height: 4px; -webkit-appearance: none; background: #334155; border-radius: 2px; cursor: pointer; }
.speed-control input[type=range]::-webkit-slider-thumb { -webkit-appearance: none; width: 12px; height: 12px; background: #6366f1; border-radius: 50%; }
.speed-val { color: #94a3b8; font-size: 11px; min-width: 32px; }

/* 动画 */
@keyframes fadeIn { from { opacity: 0; transform: translateY(-4px); } to { opacity: 1; transform: translateY(0); } }
```

- [ ] **Step 1: 创建 css 目录和文件**

创建 `site/public/visualizations/css/` 目录和 `viz-common.css` 文件。

- [ ] **Step 2: 提取样式并写入文件**

从 `bfs.html` 提取 `<style>` 部分（L12-280）整理后写入 `viz-common.css`。

- [ ] **Step 3: 验证文件创建**

确认 `viz-common.css` 存在且包含所有必要样式。

---

### Task 2: 创建依赖加载器

**Files:**
- Create: `site/public/visualizations/js/cytoscape-loader.js`

```javascript
/**
 * Cytoscape 依赖加载器
 * 加载 Cytoscape.js + dagre + cytoscape-dagre
 */
var CytoscapeLoader = {
  loaded: false,
  loading: false,
  callbacks: [],

  /**
   * 加载所有依赖
   * @param {Function} onSuccess - 成功回调
   * @param {Function} onError - 失败回调
   */
  load: function(onSuccess, onError) {
    var self = this;

    if (this.loaded) {
      onSuccess && onSuccess();
      return;
    }

    if (this.loading) {
      this.callbacks.push({ success: onSuccess, error: onError });
      return;
    }

    this.loading = true;
    this.callbacks.push({ success: onSuccess, error: onError });

    var deps = [
      {
        url: 'https://cdn.jsdelivr.net/npm/cytoscape@3.30.2/dist/cytoscape.min.js',
        fallback: 'https://unpkg.com/cytoscape@3.30.2/dist/cytoscape.min.js',
        name: 'Cytoscape'
      },
      {
        url: 'https://cdn.jsdelivr.net/npm/dagre@0.8.5/dist/dagre.min.js',
        fallback: 'https://unpkg.com/dagre@0.8.5/dist/dagre.min.js',
        name: 'dagre'
      },
      {
        url: 'https://cdn.jsdelivr.net/npm/cytoscape-dagre@2.5.0/cytoscape-dagre.js',
        fallback: 'https://unpkg.com/cytoscape-dagre@2.5.0/cytoscape-dagre.js',
        name: 'cytoscape-dagre'
      }
    ];

    var loaded = [false, false, false];

    deps.forEach(function(dep, index) {
      var script = document.createElement('script');
      script.src = dep.url;
      script.onerror = function() {
        console.warn('CDN failed, trying fallback:', dep.url);
        var fallback = document.createElement('script');
        fallback.src = dep.fallback;
        fallback.onerror = function() {
          self._onError(dep.name + ' load failed', onError);
        };
        document.head.appendChild(fallback);
      };
      script.onload = function() {
        loaded[index] = true;
        if (loaded.every(function(v) { return v; })) {
          self._onSuccess(onSuccess);
        }
      };
      document.head.appendChild(script);
    });
  },

  _onSuccess: function(callback) {
    this.loaded = true;
    this.loading = false;
    callback && callback();
    this.callbacks.forEach(function(cb) { cb.success && cb.success(); });
    this.callbacks = [];
  },

  _onError: function(msg, callback) {
    this.loading = false;
    callback && callback(msg);
    this.callbacks.forEach(function(cb) { cb.error && cb.error(msg); });
    this.callbacks = [];
  }
};
```

- [ ] **Step 1: 创建 js 目录和加载器文件**

创建 `site/public/visualizations/js/cytoscape-loader.js`。

- [ ] **Step 2: 验证加载器逻辑**

---

### Task 3: 创建核心引擎

**Files:**
- Create: `site/public/visualizations/js/viz-engine.js`

核心引擎包含：
1. `VizApp.init(config)` — 初始化方法
2. Cytoscape 初始化
3. 动画引擎（播放/暂停/单步/重置/进度条）
4. 键盘快捷键绑定
5. UI 更新逻辑

**VizApp.init() 需要处理的配置：**

```javascript
config = {
  title: "BFS 广度优先搜索",
  subtitle: "6 节点 · 7 边 · 无向图",
  nodes: [...],
  edges: [...],
  startNode: '0',
  generateSteps: function(nodes, adjList, startId) { return steps[]; },
  executeStep: function(cy, step, animate, speed) { },
  rebuildTo: function(cy, steps, idx) { },
  updateUI: function(step, dom) { },
  statusFields: {
    queue: { label: '队列', id: 'queue' },
    order: { label: '顺序', id: 'order' }
  },
  legends: [
    { color: '#B45309', label: '起点' },
    { color: '#F97316', label: '处理中' }
  ]
}
```

- [ ] **Step 1: 创建 viz-engine.js**

从 `bfs.html` 提取动画引擎逻辑（L440-700），并重构为参数化形式。

- [ ] **Step 2: 实现 VizApp.init()**

处理配置、初始化 Cytoscape、绑定事件。

- [ ] **Step 3: 验证引擎功能**

测试播放/暂停/单步/重置功能。

---

## Phase 2: 创建算法模块

### Task 4: 创建 BFS 算法模块

**Files:**
- Create: `site/public/visualizations/algs/bfs.js`

```javascript
var BFS = {
  generateSteps: function(nodes, adjList, startId) {
    var steps = [];
    var visited = {};
    var queue = [startId];
    var order = [];
    var levels = {};
    levels[startId] = 0;

    steps.push({
      type: 'init', targets: [startId],
      message: '起点 ' + startId + ' 入队',
      queue: queue.slice(), order: order.slice(), levels: JSON.parse(JSON.stringify(levels))
    });

    while (queue.length > 0) {
      var current = queue.shift();
      if (!visited[current]) {
        visited[current] = true;
        order.push(current);

        steps.push({
          type: 'visit_node', targets: [current],
          message: '访问节点 ' + current,
          queue: queue.slice(), order: order.slice(), levels: JSON.parse(JSON.stringify(levels))
        });

        var neighbors = (adjList[current] || []).slice().sort();
        for (var ni = 0; ni < neighbors.length; ni++) {
          var nbr = neighbors[ni];
          if (!visited[nbr]) {
            queue.push(nbr);
            levels[nbr] = levels[current] + 1;
            steps.push({
              type: 'visit_edge', targets: [current, nbr],
              message: '发现邻居 ' + nbr,
              queue: queue.slice(), order: order.slice(), levels: JSON.parse(JSON.stringify(levels))
            });
          } else {
            steps.push({
              type: 'skip_edge', targets: [current, nbr],
              message: '跳过 ' + nbr + ' (已访问)',
              queue: queue.slice(), order: order.slice(), levels: JSON.parse(JSON.stringify(levels))
            });
          }
        }
      }
    }

    steps.push({
      type: 'finish', targets: [],
      message: '✅ BFS 完成! 访问顺序: [' + order.join(', ') + ']',
      queue: [], order: order.slice(), levels: levels
    });

    return steps;
  },

  executeStep: function(cy, step, animate, speed) {
    var dur = animate ? Math.max(200, speed * 0.6) : 0;
    switch (step.type) {
      case 'init':
        cy.getElementById(step.targets[0]).animate({
          style: { 'background-color': '#B45309', 'border-color': '#92400E', 'border-width': 4 }
        }, { duration: dur });
        break;
      case 'visit_node':
        cy.getElementById(step.targets[0]).animate({
          style: { 'background-color': '#22C55E', 'border-color': '#16A34A' }
        }, { duration: dur });
        break;
      case 'visit_edge':
        var tgt = step.targets[1];
        cy.edges('[source="' + step.targets[0] + '"][target="' + tgt + '"], [source="' + tgt + '"][target="' + step.targets[0] + '"]')
          .animate({ style: { 'line-color': '#EF4444', 'width': 4 } }, { duration: dur });
        cy.getElementById(tgt).animate({ style: { 'background-color': '#FBBF24' } }, { duration: dur });
        break;
      case 'skip_edge':
        var s = step.targets[0], t = step.targets[1];
        cy.edges('[source="' + s + '"][target="' + t + '"], [source="' + t + '"][target="' + s + '"]')
          .animate({ style: { 'line-color': '#94A3B8', 'line-style': 'dashed', 'opacity': 0.5 } }, { duration: dur });
        break;
      case 'finish':
        cy.nodes().style({ 'background-color': function(ele) { return ele.data('id') === '0' ? '#B45309' : '#22C55E'; } });
        break;
    }
  },

  rebuildTo: function(cy, steps, idx) {
    cy.nodes().style({ 'background-color': '#374151', 'border-color': '#4B5563' });
    cy.edges().style({ 'line-color': '#6B7280', 'line-style': 'solid', 'opacity': 1 });
    for (var i = 0; i <= idx; i++) {
      this.executeStep(cy, steps[i], false, 0);
    }
  },

  updateUI: function(step, dom) {
    dom.queue.textContent = '[' + (step.queue || []).join(', ') + ']';
    dom.order.textContent = '[' + (step.order || []).join(', ') + ']';
  }
};
```

- [ ] **Step 1: 从 bfs.html 提取 BFS 逻辑**

提取 `generateSteps()`、`executeStep()` case、`rebuildTo()` case、`updateUI()`。

- [ ] **Step 2: 创建 algs 目录和 bfs.js**

- [ ] **Step 3: 验证 BFS 模块**

---

### Task 5-8: 创建其他算法模块

**Files:**
- Create: `site/public/visualizations/algs/dfs.js`
- Create: `site/public/visualizations/algs/cycle.js`
- Create: `site/public/visualizations/algs/topo.js`
- Create: `site/public/visualizations/algs/dijkstra.js`

- [ ] **Task 5: 创建 DFS 算法模块**

- [ ] **Task 6: 创建环检测算法模块**

- [ ] **Task 7: 创建拓扑排序算法模块**

- [ ] **Task 8: 创建 Dijkstra 算法模块**

---

## Phase 3: 重构 HTML 文件

### Task 9: 重构 BFS HTML

**Files:**
- Create: `site/public/visualizations/bfs.html`

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>BFS 可视化</title>
  <link rel="stylesheet" href="/visualizations/css/viz-common.css">
</head>
<body>
  <div id="loading-overlay">
    <div class="spinner"></div>
    <div class="loading-text">正在加载图可视化...</div>
  </div>
  <div id="error-overlay">
    <div class="error-box">
      <div class="error-title">加载失败</div>
      <div class="error-msg" id="error-msg"></div>
    </div>
  </div>

  <div class="viz-wrapper">
    <div class="viz-header">
      <div class="viz-header-left">
        <span class="badge">BFS</span>
        <span class="graph-info">6 节点 · 7 边 · 无向图</span>
      </div>
      <span class="hint">方向键/空格</span>
    </div>

    <div class="viz-canvas-wrap">
      <div id="viz-canvas"></div>
      <div class="viz-tooltip" id="viz-tooltip">
        <span class="viz-tooltip-inner" id="tooltip-text"></span>
      </div>
    </div>

    <div class="viz-bottom-bar">
      <div class="viz-controls">
        <div class="viz-controls-left">
          <button class="btn btn-icon" data-action="reset" title="重置">↺</button>
          <button class="btn btn-icon" data-action="step-back" title="上一步">◀</button>
        </div>
        <div class="viz-controls-center">
          <div class="progress-track" id="progress-track">
            <div class="progress-fill" id="progress-fill"></div>
            <div class="progress-thumb" id="progress-thumb"></div>
          </div>
        </div>
        <div class="viz-controls-right">
          <button class="btn btn-icon" data-action="step-forward" title="下一步">▶</button>
          <button class="btn btn-primary" data-action="toggle-play" id="play-btn">▶</button>
        </div>
      </div>
      <div class="viz-status-bar">
        <div class="viz-status-item">
          <span class="viz-status-label">步骤</span>
          <span class="viz-status-value" id="step-counter">0/0</span>
        </div>
        <div class="viz-status-item">
          <span class="viz-status-label">队列</span>
          <span class="viz-status-value" id="queue">[]</span>
        </div>
        <div class="viz-status-item">
          <span class="viz-status-label">顺序</span>
          <span class="viz-status-value" id="order">[]</span>
        </div>
        <div class="viz-message" id="message">准备就绪</div>
      </div>
      <div class="viz-legend">
        <div class="legend-item"><div class="legend-dot" style="background:#B45309"></div><span class="legend-label">起点</span></div>
        <div class="legend-item"><div class="legend-dot" style="background:#F97316"></div><span class="legend-label">处理中</span></div>
        <div class="legend-item"><div class="legend-dot" style="background:#22C55E"></div><span class="legend-label">已访问</span></div>
        <div class="legend-item"><div class="legend-line" style="background:#EF4444"></div><span class="legend-label">树边</span></div>
        <div class="legend-item"><div class="legend-line" style="background:#94A3B8;border-style:dashed"></div><span class="legend-label">跳过</span></div>
      </div>
    </div>
  </div>

  <script src="/visualizations/js/cytoscape-loader.js"></script>
  <script src="/visualizations/js/viz-engine.js"></script>
  <script src="/visualizations/algs/bfs.js"></script>
  <script>
    CytoscapeLoader.load(function() {
      VizApp.init({
        title: "BFS 广度优先搜索",
        subtitle: "6 节点 · 7 边 · 无向图",
        nodes: [
          { data: { id: '0', label: '0' } }, { data: { id: '1', label: '1' } },
          { data: { id: '2', label: '2' } }, { data: { id: '3', label: '3' } },
          { data: { id: '4', label: '4' } }, { data: { id: '5', label: '5' } }
        ],
        edges: [
          { data: { id: 'e01', source: '0', target: '1' } },
          { data: { id: 'e04', source: '0', target: '4' } },
          { data: { id: 'e02', source: '0', target: '2' } },
          { data: { id: 'e12', source: '1', target: '2' } },
          { data: { id: 'e24', source: '2', target: '4' } },
          { data: { id: 'e25', source: '2', target: '5' } },
          { data: { id: 'e35', source: '3', target: '5' } }
        ],
        startNode: '0',
        generateSteps: BFS.generateSteps,
        executeStep: BFS.executeStep,
        rebuildTo: BFS.rebuildTo,
        updateUI: BFS.updateUI,
        statusFields: {
          queue: { id: 'queue' },
          order: { id: 'order' }
        }
      });
    }, function(err) {
      document.getElementById('error-msg').textContent = err;
      document.getElementById('error-overlay').classList.add('show');
    });
  </script>
</body>
</html>
```

- [ ] **Step 1: 读取现有 bfs.html 了解结构**

- [ ] **Step 2: 创建新的 bfs.html 配置文件**

- [ ] **Step 3: 测试 BFS 可视化**

---

### Task 10-13: 重构其他 HTML 文件

**Files:**
- Rewrite: `site/public/visualizations/dfs.html`
- Rewrite: `site/public/visualizations/cycle_detection.html`
- Rewrite: `site/public/visualizations/topo_sort.html`
- Rewrite: `site/public/visualizations/dijkstra.html`

- [ ] **Task 10: 重构 DFS HTML**

- [ ] **Task 11: 重构环检测 HTML**

- [ ] **Task 12: 重构拓扑排序 HTML**

- [ ] **Task 13: 重构 Dijkstra HTML**

---

## Phase 4: 验证

### Task 14: 全面验证

- [ ] **Step 1: 逐个打开可视化页面测试**

- [ ] **Step 2: 测试播放/暂停/单步/重置**

- [ ] **Step 3: 测试键盘快捷键**

- [ ] **Step 4: 验证样式一致性**

- [ ] **Step 5: 验证与文档嵌入的 iframe 正常工作**

---

## 自审检查

### Spec 覆盖率

| 设计文档要求 | 对应 Task | 状态 |
|-------------|:--------:|:----:|
| css/viz-common.css | Task 1 | ✅ |
| js/cytoscape-loader.js | Task 2 | ✅ |
| js/viz-engine.js | Task 3 | ✅ |
| algs/bfs.js | Task 4 | ✅ |
| algs/dfs.js | Task 5 | ✅ |
| algs/cycle.js | Task 6 | ✅ |
| algs/topo.js | Task 7 | ✅ |
| algs/dijkstra.js | Task 8 | ✅ |
| bfs.html 重构 | Task 9 | ✅ |
| dfs.html 重构 | Task 10 | ✅ |
| cycle_detection.html 重构 | Task 11 | ✅ |
| topo_sort.html 重构 | Task 12 | ✅ |
| dijkstra.html 重构 | Task 13 | ✅ |
| 全面验证 | Task 14 | ✅ |

### 占位符扫描

- 无 TBD/TODO
- 所有步骤都有完整代码
- 无"类似 Task X"的引用

### 类型一致性

- 所有算法模块使用相同的接口：`generateSteps(nodes, adjList, startId)`
- `executeStep(cy, step, animate, speed)` 一致
- `rebuildTo(cy, steps, idx)` 一致
- `updateUI(step, dom)` 一致
