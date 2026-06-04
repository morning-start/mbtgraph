/**
 * viz-engine.js — 图算法可视化核心引擎
 * 
 * 从 bfs.html 提取并参数化
 * 封装动画播放、UI 更新等通用逻辑
 */

var VizApp = {
  // 引擎内部状态
  _state: {
    cy: null,
    currentIdx: -1,
    isPlaying: false,
    isFinished: false,
    speed: 500,
    timerId: null,
    steps: [],
    adjList: {},
    config: null
  },

  /**
   * 初始化可视化引擎
   * @param {Object} config - 配置对象
   * @param {string} config.title - 算法标题
   * @param {string} config.subtitle - 图信息
   * @param {Array} config.nodes - 节点数据 [{ data: { id, label } }]
   * @param {Array} config.edges - 边数据 [{ data: { id, source, target, weight? } }]
   * @param {string} config.startNode - 起始节点 ID
   * @param {boolean} config.directed - 是否为有向图（默认 false，无向图）
   * @param {Function} config.generateSteps - 生成步骤数组的函数 (nodes, adjList, edgeWeights?, startId) => steps[]
   * @param {Function} config.executeStep - 执行单步的函数 (cy, step, animate, speed) => void
   * @param {Function} config.rebuildTo - 重建到指定步骤的函数 (cy, steps, idx) => void
   * @param {Function} config.updateUI - 更新 UI 的函数 (step, state) => void
   * @param {Array} config.legends - 图例数据 [{ color, label }]
   */
  init: function(config) {
    var self = this;
    var state = this._state;

    // 保存配置
    state.config = config;
    // 保存算法实例引用（用于 executeStep/rebuildTo/updateUI 的 this 绑定）
    state.algoInstance = config.algoInstance || null;
    state.currentIdx = -1;
    state.isPlaying = false;
    state.isFinished = false;
    state.speed = 500;
    state.timerId = null;

    // 检查依赖
    if (typeof cytoscape === 'undefined' || typeof dagre === 'undefined' || typeof cytoscapeDagre === 'undefined') {
      console.error('Cytoscape dependencies not loaded');
      return;
    }

    // 注册 dagre 布局
    cytoscape.use(cytoscapeDagre);

    // 构建邻接表
    state.adjList = {};
    config.nodes.forEach(function(n) {
      state.adjList[n.data.id] = [];
    });

    // 构建边权重映射（如果有权重属性）
    var edgeWeights = {};
    config.edges.forEach(function(e) {
      // 有向图：只从 source -> target 添加
      if (config.directed) {
        state.adjList[e.data.source].push(e.data.target);
      } else {
        // 无向图：双向添加
        state.adjList[e.data.source].push(e.data.target);
        state.adjList[e.data.target].push(e.data.source);
      }
      // 如果边有权重属性，保存到 edgeWeights
      if (e.data.weight !== undefined) {
        edgeWeights[e.data.source + '-' + e.data.target] = parseFloat(e.data.weight);
      }
    });

    // 生成步骤数组（根据 generateSteps 签名传递参数）
    if (config.generateSteps.length >= 4) {
      // 支持 edgeWeights 的算法（如 Dijkstra）
      state.steps = config.generateSteps(config.nodes, state.adjList, edgeWeights, config.startNode);
    } else {
      // 传统签名（如 BFS），兼容纯数组或对象格式
      var result = config.generateSteps(config.nodes, state.adjList, config.startNode);
      if (Array.isArray(result)) {
        state.steps = result;
        state.maxDepth = 0;
      } else {
        state.steps = result.steps || [];
        state.maxDepth = result.maxDepth || 0;
      }
    }

    // 初始化 Cytoscape
    var container = document.getElementById('viz-canvas');
    if (!container) {
      console.error('Canvas container not found');
      return;
    }

    state.cy = cytoscape({
      container: container,
      elements: config.nodes.concat(config.edges),

      layout: {
        name: 'dagre',
        rankDir: 'LR',
        nodeSep: 80,
        rankSep: 90,
        animate: false,
        fit: true,
        padding: 40
      },

      style: [
        {
          selector: 'node',
          style: {
            'label': 'data(label)',
            'text-valign': 'center',
            'text-halign': 'center',
            'background-color': '#1e293b',
            'background-blacken': 0.15,
            'border-color': '#334155',
            'border-width': 2.5,
            'color': '#e2e8f0',
            'font-family': '"DM Sans", -apple-system, system-ui, sans-serif',
            'font-size': 14,
            'font-weight': 700,
            'width': 48,
            'height': 48,
            'shape': 'ellipse',
            'text-outline-width': 2,
            'text-outline-color': '#1e293b',
            'transition-property': 'background-color,border-color,border-width,width,height,color,text-background-color,text-outline-color',
            'transition-duration': '0.35s'
          }
        },
        {
          selector: 'edge',
          style: {
            'width': 2,
            'line-color': '#475569',
            'target-arrow-color': '#475569',
            'source-arrow-color': '#475569',
            'arrow-scale': 0.8,
            'curve-style': 'bezier',
            'opacity': 0.85,
            'label': 'data(weight)',
            'text-background-color': '#0f172a',
            'text-background-opacity': 0.95,
            'text-background-padding': '4px 6px',
            'text-border-width': 1,
            'text-border-color': 'rgba(71,85,105,0.4)',
            'text-border-style': 'solid',
            'font-size': 10.5,
            'font-weight': 600,
            'color': '#94a3b8',
            'font-family': '"JetBrains Mono", ui-monospace, monospace',
            'transition-property': 'line-color,target-arrow-color,source-arrow-color,width,opacity,line-style',
            'transition-duration': '0.35s'
          }
        },
        {
          selector: '.highlighted',
          style: {
            'background-color': '#fef3c7',
            'border-color': '#f59e0b',
            'border-width': 3.5,
            'z-index': 10
          }
        }
      ],

      userZoomEnabled: true,
      userPanningEnabled: true,
      boxSelectionEnabled: false,
      minZoom: 0.3,
      maxZoom: 3,
      wheelSensitivity: 0.35
    });

    // 隐藏加载状态
    var loadingEl = document.getElementById('loading-overlay');
    if (loadingEl) {
      loadingEl.classList.add('fade-out');
      setTimeout(function() { loadingEl.style.display = 'none'; }, 320);
    }

    // 更新头部信息
    self._updateHeader(config.title, config.subtitle);

    // 更新图例
    self._updateLegends(config.legends);

    // 绑定控制事件
    self._bindControls();

    // 绑定键盘快捷键
    self._bindKeyboard();

    // 绑定进度条交互
    self._bindProgress();

    // 绑定速度控制
    self._bindSpeed();

    // 自动聚焦
    setTimeout(function() {
      var root = document.querySelector('.viz-wrapper');
      if (root) root.focus();
    }, 500);
  },

  // ==================== 内部方法 ====================

  /**
   * 执行单步（带/不带动画）
   */
  _executeStep: function(step, animate) {
    var state = this._state;
    var config = state.config;
    if (config.executeStep) {
      var dur = animate ? Math.max(200, state.speed * 0.6) : 0;
      // 使用算法实例作为 this 上下文，确保内部方法（如 _showTooltip）可访问
      var ctx = state.algoInstance;
      if (config.executeStep.length === 4) {
        config.executeStep.call(ctx, state.cy, step, animate, dur);
      } else {
        config.executeStep.call(ctx, state.cy, step, animate, state.speed);
      }
    }
  },

  /**
   * 快速重建到指定步骤（无动画）
   */
  _rebuildTo: function(idx) {
    var state = this._state;
    var config = state.config;
    if (config.rebuildTo) {
      // 使用算法实例作为 this 上下文
      config.rebuildTo.call(state.algoInstance, state.cy, state.steps, idx);
    }
  },

  /**
   * 重置视觉状态
   */
  _resetVisuals: function() {
    var state = this._state;
    var cy = state.cy;

    // 停止所有动画
    cy.elements().stop(true, false);

    // 重置节点样式
    cy.nodes().style({
      'background-color': '#374151',
      'border-color': '#4B5563',
      'border-width': 2,
      'color': '#F9FAFB',
      'width': 46,
      'height': 46,
      'transition-duration': '0s'
    });

    // 重置边样式
    cy.edges().style({
      'line-color': '#6B7280',
      'target-arrow-color': '#6B7280',
      'source-arrow-color': '#6B7280',
      'width': 2.5,
      'opacity': 1,
      'line-style': 'solid',
      'transition-duration': '0s'
    });

    this._hideTooltip();
  },

  /**
   * 更新 UI
   */
  _updateUI: function() {
    var state = this._state;
    var config = state.config;
    var steps = state.steps;
    var currentIdx = state.currentIdx;

    // 更新进度条
    var total = steps.length;
    var progressFill = document.getElementById('progress-fill');
    var progressThumb = document.getElementById('progress-thumb');
    var stepCounter = document.getElementById('step-counter');

    if (total > 0) {
      var pct = total > 1 ? (currentIdx / (total - 1)) * 100 : 0;
      if (progressFill) progressFill.style.width = pct + '%';
      if (progressThumb) progressThumb.style.left = pct + '%';
      if (stepCounter) stepCounter.textContent = Math.max(0, currentIdx) + ' / ' + (total - 1);
    }

    // 更新图标状态
    var iconPlay = document.getElementById('icon-play');
    var iconPause = document.getElementById('icon-pause');
    var btnPrimary = document.querySelector('.play-hero');

    if (iconPlay) {
      iconPlay.classList.toggle('hidden', state.isPlaying);
    }
    if (iconPause) {
      iconPause.classList.toggle('hidden', !state.isPlaying);
    }

    // 完成状态：显示重播图标
    if (state.isFinished) {
      if (iconPlay) {
        iconPlay.textContent = '\u21BB'; // ↻
        iconPlay.classList.remove('hidden');
      }
      if (iconPause) iconPause.classList.add('hidden');
      if (btnPrimary) btnPrimary.classList.add('replay-pulse');
      // fallback: 无 icon 子元素时直接改按钮文本
      if (!iconPlay && btnPrimary) btnPrimary.textContent = '\u21BB';
    } else {
      if (iconPlay) {
        iconPlay.textContent = '\u25B6'; // ▶
      }
      if (btnPrimary) btnPrimary.classList.remove('replay-pulse');
      // fallback: 无 icon 子元素时直接切换按钮文本
      if (!iconPlay && btnPrimary) {
        btnPrimary.textContent = state.isPlaying ? '\u23F8' : '\u25B6'; // ⏸ / ▶
      }
    }

    // 调用配置的自定义 UI 更新（绑定算法实例 this 上下文）
    if (config.updateUI) {
      var step = currentIdx >= 0 ? steps[currentIdx] : null;
      var uiState = {
        isFinished: state.isFinished,
        currentIdx: currentIdx,
        total: total - 1,
        isPlaying: state.isPlaying,
        maxDepth: state.maxDepth
      };
      config.updateUI.call(state.algoInstance, step, uiState);
    }
  },

  /**
   * 显示提示框
   */
  _showTooltip: function(nodeId, text) {
    var state = this._state;
    var cy = state.cy;
    var node = cy.getElementById(nodeId);
    if (!node) return;

    var pos = node.position();
    var pan = cy.pan();
    var zoom = cy.zoom();
    var rect = cy.container().getBoundingClientRect();

    var tooltipEl = document.getElementById('viz-tooltip');
    var ttText = document.getElementById('tooltip-text');

    if (!tooltipEl || !ttText) return;

    var x = pos.x * zoom + pan.x + rect.width / 2;
    var y = pos.y * zoom + pan.y + rect.height / 2;

    ttText.textContent = text;
    tooltipEl.classList.remove('hidden');
    tooltipEl.style.left = Math.min(x, rect.width - 130) + 'px';
    tooltipEl.style.top = Math.max(y - 65, 8) + 'px';
  },

  /**
   * 隐藏提示框
   */
  _hideTooltip: function() {
    var tooltipEl = document.getElementById('viz-tooltip');
    if (tooltipEl) tooltipEl.classList.add('hidden');
  },

  /**
   * 更新头部信息
   */
  _updateHeader: function(title, subtitle) {
    var badge = document.querySelector('.viz-header .badge');
    var info = document.querySelector('.viz-header .graph-info');

    if (badge && title) badge.textContent = title;
    if (info && subtitle) info.textContent = subtitle;
  },

  /**
   * 更新图例
   */
  _updateLegends: function(legends) {
    if (!legends || !legends.length) return;

    var legendEl = document.querySelector('.viz-legend');
    if (!legendEl) return;

    // 清空现有内容（保留第一个占位符或创建新容器）
    legendEl.innerHTML = legends.map(function(item) {
      return '<span class="legend-item"><i class="dot" style="background:' + item.color + '"></i> ' + item.label + '</span>';
    }).join('');
  },

  // ==================== 控制函数 ====================

  _togglePlay: function() {
    var state = this._state;
    if (state.isFinished) {
      this._doReset();
      this._play();
    } else {
      state.isPlaying ? this._pause() : this._play();
    }
  },

  _play: function() {
    var state = this._state;
    var self = this;

    if (state.currentIdx >= state.steps.length - 1) {
      this._jumpTo(0);
    }
    state.isFinished = false;
    state.isPlaying = true;
    this._updateUI();
    this._tick();
  },

  _pause: function() {
    var state = this._state;
    state.isPlaying = false;
    if (state.timerId) {
      clearTimeout(state.timerId);
      state.timerId = null;
    }
    this._updateUI();
  },

  _tick: function() {
    var state = this._state;
    var self = this;

    if (!state.isPlaying) return;

    if (state.currentIdx < state.steps.length - 1) {
      this._stepForward();
      state.timerId = setTimeout(function() { self._tick(); }, state.speed);
    } else {
      this._pause();
      state.isFinished = true;
      this._updateUI();
    }
  },

  _stepForward: function() {
    var state = this._state;
    if (state.currentIdx < state.steps.length - 1) {
      state.isFinished = false;
      state.currentIdx++;
      this._executeStep(state.steps[state.currentIdx], true);
      this._updateUI();
    }
  },

  _stepBack: function() {
    var state = this._state;
    if (state.currentIdx > 0) {
      state.isFinished = false;
      state.currentIdx--;
      this._rebuildTo(state.currentIdx);
      this._updateUI();
    }
  },

  _skipToStart: function() {
    this._pause();
    this._jumpTo(0);
  },

  _skipToEnd: function() {
    var state = this._state;
    this._pause();
    state.isFinished = true;
    this._jumpTo(state.steps.length - 1);
  },

  _jumpTo: function(idx) {
    var state = this._state;
    idx = Math.max(0, Math.min(idx, state.steps.length - 1));
    state.currentIdx = idx;
    this._rebuildTo(idx);
    this._updateUI();
  },

  _doReset: function() {
    var state = this._state;
    this._pause();
    state.isFinished = false;
    state.currentIdx = -1;
    // 重置进度条到初始状态
    var progressFill = document.getElementById('progress-fill');
    var progressThumb = document.getElementById('progress-thumb');
    if (progressFill) progressFill.style.width = '0%';
    if (progressThumb) progressThumb.style.left = '0%';
    this._resetVisuals();
    this._updateUI();
  },

  // ==================== 事件绑定 ====================

  _bindControls: function() {
    var self = this;

    // 播放/暂停按钮
    var playBtn = document.querySelector('[data-action="toggle-play"]');
    if (playBtn) playBtn.addEventListener('click', function() { self._togglePlay(); });

    // 上一步
    var stepForwardBtn = document.querySelector('[data-action="step-forward"]');
    if (stepForwardBtn) stepForwardBtn.addEventListener('click', function() { self._stepForward(); });

    // 下一步
    var stepBackBtn = document.querySelector('[data-action="step-back"]');
    if (stepBackBtn) stepBackBtn.addEventListener('click', function() { self._stepBack(); });

    // 跳到开始
    var skipStartBtn = document.querySelector('[data-action="skip-to-start"]');
    if (skipStartBtn) skipStartBtn.addEventListener('click', function() { self._skipToStart(); });

    // 跳到末尾
    var skipEndBtn = document.querySelector('[data-action="skip-to-end"]');
    if (skipEndBtn) skipEndBtn.addEventListener('click', function() { self._skipToEnd(); });

    // 重置
    var resetBtn = document.querySelector('[data-action="reset"]');
    if (resetBtn) resetBtn.addEventListener('click', function() { self._doReset(); });
  },

  _bindKeyboard: function() {
    var self = this;
    var root = document.querySelector('.viz-wrapper');
    if (!root) return;

    root.addEventListener('keydown', function(e) {
      switch (e.key) {
        case ' ':
          e.preventDefault();
          self._togglePlay();
          break;
        case 'ArrowRight':
          e.preventDefault();
          self._stepForward();
          break;
        case 'ArrowLeft':
          e.preventDefault();
          self._stepBack();
          break;
        case 'Home':
          e.preventDefault();
          self._skipToStart();
          break;
        case 'End':
          e.preventDefault();
          self._skipToEnd();
          break;
        case 'r':
        case 'R':
          if (!e.ctrlKey && !e.metaKey) {
            e.preventDefault();
            self._doReset();
          }
          break;
      }
    });
  },

  _bindProgress: function() {
    var self = this;
    var state = this._state;
    var progressTrack = document.getElementById('progress-track');
    if (!progressTrack) return;

    progressTrack.addEventListener('click', function(e) {
      var rect = this.getBoundingClientRect();
      var pct = (e.clientX - rect.left) / rect.width;
      var idx = Math.round(pct * (state.steps.length - 1));
      self._jumpTo(idx);
    });
  },

  _bindSpeed: function() {
    var self = this;
    var state = this._state;
    var speedSlider = document.getElementById('speed');
    var speedVal = document.getElementById('speed-val');
    if (!speedSlider) return;

    speedSlider.addEventListener('input', function(e) {
      var v = parseInt(e.target.value, 10);
      state.speed = Math.max(60, 1100 - v * 100);
      if (speedVal) speedVal.textContent = v + 'x';
    });
  },

  // ==================== 公开 API ====================

  /**
   * 获取当前状态
   */
  getState: function() {
    return {
      currentIdx: this._state.currentIdx,
      isPlaying: this._state.isPlaying,
      isFinished: this._state.isFinished,
      totalSteps: this._state.steps.length
    };
  },

  /**
   * 播放
   */
  play: function() {
    this._play();
  },

  /**
   * 暂停
   */
  pause: function() {
    this._pause();
  },

  /**
   * 重置
   */
  reset: function() {
    this._doReset();
  },

  /**
   * 跳转到指定步骤
   */
  jumpTo: function(idx) {
    this._jumpTo(idx);
  }
};
