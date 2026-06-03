# 可视化组件化重构设计文档

> **日期**: 2026-06-03
> **状态**: 已批准，待实施
> **方案**: 方案 A — 共享 JS 库

---

## 1. 背景与问题

### 1.1 当前状态

每个可视化文件（BFS/DFS/环检测/拓扑排序/Dijkstra）约 **800 行**，其中约 **75% 是重复代码**。

| 部分 | 行数 | 是否公共 |
|------|:----:|:--------:|
| HTML/CSS 加载/布局 | ~300 | ✅ 公共 |
| 依赖加载 (Cytoscape+dagre) | ~20 | ✅ 公共 |
| Cytoscape 初始化 | ~80 | ✅ 公共 |
| 动画引擎 `initEngine()` | ~200 | ✅ 公共 |
| 键盘快捷键 | ~30 | ✅ 公共 |
| `generateSteps()` | ~100 | ❌ 差异化 |
| `executeStep()` case | ~30 | ⚠️ 部分 |
| 状态栏 HTML | ~50 | ⚠️ 部分 |
| `updateUI()` | ~30 | ⚠️ 部分 |
| 图数据 | ~30 | ❌ 差异化 |

### 1.2 重构目标

- 每算法 HTML 文件从 **~800 行 → ~40 行**（减少 95%）
- 消除重复代码，CSS/JS/动画引擎只保留一份
- 新增算法只需编写 `generateSteps()` 函数
- 保持现有 UI 和交互不变

---

## 2. 架构设计

### 2.1 文件结构

```
site/public/visualizations/
├── css/
│   └── viz-common.css         # 共享样式 (~280行)
├── js/
│   ├── cytoscape-loader.js   # 依赖加载器 (~30行)
│   └── viz-engine.js          # 核心引擎 (~200行)
├── algs/
│   ├── bfs.js                 # BFS 步骤生成 (~80行)
│   ├── dfs.js                 # DFS 步骤生成 (~80行)
│   ├── cycle.js               # 环检测步骤 (~100行)
│   ├── topo.js                # 拓扑排序步骤 (~120行)
│   └── dijkstra.js            # Dijkstra 步骤 (~100行)
├── bfs.html                   # BFS 配置 (~40行)
├── dfs.html
├── cycle_detection.html
├── topo_sort.html
└── dijkstra.html
```

### 2.2 核心 API

#### `viz-engine.js` — 导出 `VizApp`

```javascript
var VizApp = {
  /**
   * 初始化可视化应用
   * @param {Object} config - 配置对象
   * @param {string} config.title - 标题
   * @param {string} config.subtitle - 副标题
   * @param {Array} config.nodes - 节点数组
   * @param {Array} config.edges - 边数组
   * @param {string} config.startNode - 起始节点 ID
   * @param {Function} config.generateSteps - 步骤生成函数 (nodes, adjList, startNode) => steps[]
   * @param {Function} config.executeStep - 步骤执行函数 (cy, step, animate, speed) => void
   * @param {Function} config.rebuildTo - 快速重建函数 (cy, steps, idx) => void
   * @param {Function} config.updateUI - UI更新函数 (step, dom) => void
   * @param {Object} config.statusFields - 状态栏字段定义
   * @param {Array} config.legends - 图例定义
   */
  init: function(config) { ... }
}
```

#### `cytoscape-loader.js` — 依赖加载器

```javascript
var CytoscapeLoader = {
  /**
   * 加载 Cytoscape + dagre 依赖
   * @param {Function} onSuccess - 加载成功回调
   * @param {Function} onError - 加载失败回调
   */
  load: function(onSuccess, onError) { ... }
}
```

### 2.3 配置示例

#### `bfs.html`

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>BFS 可视化</title>
  <link rel="stylesheet" href="/visualizations/css/viz-common.css">
</head>
<body>
  <!-- 加载状态、错误状态、画布、控制面板、图例 -->
  <!-- 详见设计文档第 3 节 -->

  <script src="/visualizations/js/cytoscape-loader.js"></script>
  <script src="/visualizations/js/viz-engine.js"></script>
  <script src="/visualizations/algs/bfs.js"></script>
  <script>
    CytoscapeLoader.load(function() {
      VizApp.init({
        title: "BFS 广度优先搜索",
        subtitle: "6 节点 · 7 边 · 无向图",
        nodes: [
          { data: { id: '0', label: '0' } },
          { data: { id: '1', label: '1' } },
          // ...
        ],
        edges: [
          { data: { id: 'e01', source: '0', target: '1' } },
          // ...
        ],
        startNode: '0',
        generateSteps: BFS.generateSteps,
        executeStep: BFS.executeStep,
        rebuildTo: BFS.rebuildTo,
        updateUI: BFS.updateUI,
        statusFields: {
          queue: { label: '队列', format: function(v) { return '[' + v.join(', ') + ']'; } },
          order: { label: '顺序', format: function(v) { return '[' + v.join(', ') + ']'; } },
          levels: { label: '层级', format: function(v) { return JSON.stringify(v); } }
        },
        legends: [
          { color: '#B45309', label: '起点' },
          { color: '#F97316', label: '处理中' },
          { color: '#22C55E', label: '已访问' }
        ]
      });
    }, function(err) {
      // 错误处理
    });
  </script>
</body>
</html>
```

### 2.4 算法模块示例

#### `algs/bfs.js`

```javascript
var BFS = {
  /**
   * 生成 BFS 步骤数组
   */
  generateSteps: function(nodes, adjList, startId) {
    var steps = [];
    var visited = {};
    var queue = [startId];
    var order = [];
    var levels = {};
    levels[startId] = 0;

    steps.push({
      type: 'init',
      targets: [startId],
      message: '起点 ' + startId + ' 入队',
      queue: queue.slice(),
      order: order.slice(),
      levels: JSON.parse(JSON.stringify(levels))
    });

    while (queue.length > 0) {
      var current = queue.shift();
      if (!visited[current]) {
        visited[current] = true;
        order.push(current);

        steps.push({
          type: 'visit_node',
          targets: [current],
          message: '访问节点 ' + current,
          queue: queue.slice(),
          order: order.slice(),
          levels: JSON.parse(JSON.stringify(levels))
        });

        // 处理邻居...
      }
    }

    // ... 更多步骤
    return steps;
  },

  /**
   * 执行单个步骤（动画）
   */
  executeStep: function(cy, step, animate, speed) {
    var dur = animate ? Math.max(200, speed * 0.6) : 0;
    switch (step.type) {
      case 'init':
        cy.getElementById(step.targets[0]).animate({
          style: { 'background-color': '#B45309' }
        }, { duration: dur });
        break;
      case 'visit_node':
        cy.getElementById(step.targets[0]).animate({
          style: { 'background-color': '#22C55E' }
        }, { duration: dur });
        break;
      // ... 更多 case
    }
  },

  /**
   * 快速重建到指定步骤（无动画）
   */
  rebuildTo: function(cy, steps, idx) {
    // 重置所有节点样式
    cy.nodes().style({ 'background-color': '#374151' });
    cy.edges().style({ 'line-color': '#6B7280' });

    // 按序重建
    for (var i = 0; i <= idx; i++) {
      this.executeStep(cy, steps[i], false, 0);
    }
  },

  /**
   * 更新状态栏 UI
   */
  updateUI: function(step, dom) {
    dom.order.textContent = '[' + step.order.join(', ') + ']';
    dom.queue.textContent = '[' + step.queue.join(', ') + ']';
  }
};
```

---

## 3. HTML 模板

每个算法 HTML 文件使用统一模板，结构如下：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{TITLE}}</title>
  <link rel="stylesheet" href="/visualizations/css/viz-common.css">
</head>
<body>
  <!-- 加载状态 -->
  <div id="loading-overlay">
    <div class="spinner"></div>
    <div class="loading-text">正在加载图可视化...</div>
  </div>

  <!-- 错误状态 -->
  <div id="error-overlay">
    <div class="error-box">
      <div class="error-title">加载失败</div>
      <div class="error-msg" id="error-msg"></div>
    </div>
  </div>

  <!-- 主容器 -->
  <div class="viz-wrapper">
    <!-- 头部 -->
    <div class="viz-header">
      <div class="viz-header-left">
        <span class="badge">{{TITLE}}</span>
        <span class="graph-info">{{SUBTITLE}}</span>
      </div>
      <span class="hint">方向键/空格</span>
    </div>

    <!-- 画布 -->
    <div class="viz-canvas-wrap">
      <div id="viz-canvas"></div>
      <div class="viz-tooltip">
        <span id="tooltip-text"></span>
      </div>
    </div>

    <!-- 底部控制栏 -->
    <div class="viz-bottom-bar">
      <!-- 控制按钮 -->
      <div class="viz-controls">
        <div class="viz-controls-left">
          <button class="btn btn-icon" data-action="reset" title="重置">↺</button>
          <button class="btn btn-icon" data-action="step-back" title="上一步">◀</button>
        </div>
        <div class="viz-controls-center">
          <div class="progress-track" id="progress-track">
            <div class="progress-fill" id="progress-fill" style="width:0%"></div>
            <div class="progress-thumb" id="progress-thumb"></div>
          </div>
        </div>
        <div class="viz-controls-right">
          <button class="btn btn-icon" data-action="step-forward" title="下一步">▶</button>
          <button class="btn btn-primary" data-action="toggle-play" id="play-btn">▶</button>
        </div>
      </div>

      <!-- 状态栏 -->
      <div class="viz-status-bar">
        <div class="viz-status-item">
          <span class="viz-status-label">步骤</span>
          <span class="viz-status-value" id="step-counter">0/0</span>
        </div>
        <div class="viz-status-item" id="status-queue">
          <span class="viz-status-label">队列</span>
          <span class="viz-status-value" id="queue">[]</span>
        </div>
        <div class="viz-status-item" id="status-order">
          <span class="viz-status-label">顺序</span>
          <span class="viz-status-value" id="order">[]</span>
        </div>
        <div class="viz-message" id="message">准备就绪</div>
      </div>

      <!-- 图例 -->
      <div class="viz-legend" id="legend"></div>
    </div>
  </div>

  <!-- 脚本 -->
  <script src="/visualizations/js/cytoscape-loader.js"></script>
  <script src="/visualizations/js/viz-engine.js"></script>
  <script src="/visualizations/algs/{{ALG}}.js"></script>
  <script>
    CytoscapeLoader.load(function() {
      VizApp.init({ /* 配置 */ });
    });
  </script>
</body>
</html>
```

---

## 4. 状态栏配置

每个算法定义自己的状态栏字段：

### BFS

```javascript
statusFields: {
  queue: { label: '队列', id: 'queue' },
  order: { label: '顺序', id: 'order' },
  levels: { label: '层级', id: 'levels' }
}
```

### DFS

```javascript
statusFields: {
  stack: { label: '栈', id: 'stack' },
  order: { label: '顺序', id: 'order' },
  depth: { label: '深度', id: 'depth' }
}
```

### Dijkstra

```javascript
statusFields: {
  dist: { label: '距离', id: 'dist' },
  visited: { label: '已访问', id: 'visited' }
}
```

### Topo Sort

```javascript
statusFields: {
  inDegree: { label: '入度', id: 'in-degree' },
  ready: { label: '就绪', id: 'ready' },
  result: { label: '拓扑序', id: 'result' }
}
```

### Cycle Detection

```javascript
statusFields: {
  stack: { label: 'DFS栈', id: 'stack' },
  cycle: { label: '环状态', id: 'cycle' }
}
```

---

## 5. 依赖关系图

```
┌─────────────────────────────────────────────────────────┐
│                        HTML 文件                         │
│  (bfs.html / dfs.html / cycle_detection.html / ...)    │
└─────────────────────┬───────────────────────────────────┘
                      │ 加载
          ┌───────────┼───────────┐
          ▼           ▼           ▼
   ┌──────────┐ ┌──────────┐ ┌──────────┐
   │ algs/bfs │ │ algs/dfs │ │ algs/... │  ← 算法特定
   └────┬─────┘ └────┬─────┘ └────┬─────┘
        │           │           │
        └───────────┼───────────┘
                    ▼
           ┌─────────────────┐
           │   viz-engine.js │
           │   (VizApp)      │
           └────────┬────────┘
                    │ 依赖
                    ▼
           ┌─────────────────┐
           │cytoscape-loader│
           │     .js        │
           └────────┬────────┘
                    │ 加载
                    ▼
           ┌─────────────────┐
           │ Cytoscape.js + │
           │ dagre + plugin │
           └─────────────────┘

           ┌─────────────────┐
           │ viz-common.css │
           └─────────────────┘  ← 无依赖
```

---

## 6. 实施步骤

### Phase 1: 创建共享资源

1. 创建 `css/viz-common.css`（从 bfs.html 提取样式）
2. 创建 `js/cytoscape-loader.js`（依赖加载逻辑）
3. 创建 `js/viz-engine.js`（核心引擎）

### Phase 2: 创建算法模块

4. 创建 `algs/bfs.js`（从 bfs.html 提取逻辑）
5. 创建 `algs/dfs.js`
6. 创建 `algs/cycle.js`
7. 创建 `algs/topo.js`
8. 创建 `algs/dijkstra.js`

### Phase 3: 重构 HTML 文件

9. 重写 `bfs.html` 为配置文件
10. 重写 `dfs.html` 为配置文件
11. 重写 `cycle_detection.html` 为配置文件
12. 重写 `topo_sort.html` 为配置文件
13. 重写 `dijkstra.html` 为配置文件

### Phase 4: 验证

14. 测试每个可视化是否正常工作
15. 测试动画播放/暂停/单步/重置
16. 验证样式和交互与原来一致

---

## 7. 收益预估

| 指标 | 重构前 | 重构后 | 减少 |
|------|--------|--------|------|
| 每算法 HTML 行数 | ~800 | ~40 | **95%** |
| 总代码行数（5算法） | ~4000 | ~800 | **80%** |
| CSS 重复 | 5份 | 1份 | **80%** |
| JS 动画引擎重复 | 5份 | 1份 | **80%** |
| 新增算法成本 | ~800行 | ~100行 | **88%** |
