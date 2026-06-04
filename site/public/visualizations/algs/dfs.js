/**
 * DFS 深度优先搜索可视化步骤生成器
 */
var DFS = {
  // 颜色配置
  COLORS: {
    START: '#B45309',     // 起点 - 棕色
    ACTIVE: '#F97316',    // 处理中(栈顶) - 橙色
    VISITED: '#22C55E',   // 已访问 - 绿色
    TREE_EDGE: '#EF4444', // 树边 - 红色
    DEFAULT: '#374151'    // 默认 - 深灰
  },

  /**
   * 生成 DFS 步骤数组
   * @param {Array} nodes - 节点数组
   * @param {Object} adjList - 邻接表
   * @param {string} startId - 起始节点ID
   * @returns {Object} 包含 steps, colors, maxDepth
   */
  generateSteps: function(nodes, adjList, startId) {
    var steps = [];
    var visited = {};
    var stack = [startId];
    var order = [];
    var depth = {};
    depth[startId] = 0;

    // 初始化步骤
    steps.push({
      type: 'init',
      targets: [startId],
      message: '初始化: 起点 ' + startId + ' 入栈',
      stack: stack.slice(),
      order: [],
      depth: JSON.parse(JSON.stringify(depth))
    });

    // DFS 主循环
    while (stack.length > 0) {
      var current = stack.pop();

      if (!visited[current]) {
        visited[current] = true;
        order.push(current);

        // 访问节点
        steps.push({
          type: 'visit_node',
          targets: [current],
          message: '访问节点 ' + current + ' (深度 ' + depth[current] + ')',
          stack: stack.slice(),
          order: order.slice(),
          depth: JSON.parse(JSON.stringify(depth))
        });

        // 逆序遍历邻居（保证字典序）
        var neighbors = (adjList[current] || []).slice().sort().reverse();
        for (var ni = 0; ni < neighbors.length; ni++) {
          var nbr = neighbors[ni];
          if (!visited[nbr]) {
            stack.push(nbr);
            depth[nbr] = depth[current] + 1;
            steps.push({
              type: 'push_stack',
              targets: [current, nbr],
              message: '邻居 ' + nbr + ' 入栈 (深度 ' + depth[nbr] + ')',
              stack: stack.slice(),
              order: order.slice(),
              depth: JSON.parse(JSON.stringify(depth))
            });
          }
        }
      }
    }

    // 回溯步骤（栈为空时的完成步骤）
    steps.push({
      type: 'finish',
      targets: [],
      message: '✅ DFS 完成! 访问顺序: [' + order.join(', ') + ']',
      stack: [],
      order: order,
      depth: depth
    });

    // 计算最大深度
    var maxDepth = 0;
    for (var k in depth) {
      if (depth[k] > maxDepth) maxDepth = depth[k];
    }

    return {
      steps: steps,
      colors: this.COLORS,
      maxDepth: maxDepth
    };
  },

  /**
   * 执行单步动画
   * @param {Object} cy - Cytoscape 实例
   * @param {Object} step - 步骤对象
   * @param {boolean} animate - 是否使用动画
   * @param {number} speed - 动画速度（毫秒）
   */
  executeStep: function(cy, step, animate, speed) {
    var dur = animate ? Math.max(200, speed * 0.6) : 0;
    var colors = this.COLORS;

    switch (step.type) {
      case 'init':
        cy.getElementById(step.targets[0]).animate({
          style: {
            'background-color': colors.START,
            'border-color': '#92400E',
            'border-width': 4,
            'width': 52,
            'height': 52
          }
        }, { duration: dur });
        this._showTooltip(cy, step.targets[0], '起点\n' + step.message);
        break;

      case 'push_stack':
        var src = step.targets[0];
        var tgt = step.targets[1];
        // 高亮边为树边
        cy.edges('[source="' + src + '"][target="' + tgt + '"], [source="' + tgt + '"][target="' + src + '"]')
          .animate({
            style: {
              'line-color': colors.TREE_EDGE,
              'target-arrow-color': colors.TREE_EDGE,
              'source-arrow-color': colors.TREE_EDGE,
              'width': 4
            }
          }, { duration: dur });
        // 邻居节点变为处理中
        cy.getElementById(tgt).animate(
          {
            style: {
              'background-color': colors.ACTIVE,
              'border-color': '#EA580C',
              'border-width': 3,
              'width': 49,
              'height': 49
            }
          },
          { duration: Math.max(100, dur * 0.5) }
        );
        break;

      case 'visit_node':
        cy.getElementById(step.targets[0]).animate({
          style: {
            'background-color': colors.VISITED,
            'border-color': '#16A34A',
            'border-width': 2,
            'width': 46,
            'height': 46
          }
        }, { duration: dur });
        this._hideTooltip();
        break;

      case 'finish':
        cy.nodes().style({
          'background-color': function(ele) {
            return ele.data('id') === step.targets[0] ? colors.START : colors.VISITED;
          }
        });
        this._hideTooltip();
        break;
    }
  },

  /**
   * 快速重建到指定步骤（无动画）
   * @param {Object} cy - Cytoscape 实例
   * @param {Array} steps - 步骤数组
   * @param {number} idx - 目标步骤索引
   */
  rebuildTo: function(cy, steps, idx) {
    var colors = this.COLORS;

    // 重置所有节点和边
    cy.nodes().style({
      'background-color': colors.DEFAULT,
      'border-color': '#4B5563',
      'border-width': 2,
      'width': 46,
      'height': 46
    });
    cy.edges().style({
      'line-color': '#6B7280',
      'target-arrow-color': '#6B7280',
      'source-arrow-color': '#6B7280',
      'width': 2.5,
      'opacity': 1,
      'line-style': 'solid'
    });

    // 逐步重建到目标步骤
    for (var i = 0; i <= idx; i++) {
      var step = steps[i];
      if (!step) continue;

      switch (step.type) {
        case 'init':
          cy.getElementById(step.targets[0]).style({
            'background-color': colors.START,
            'border-color': '#92400E',
            'border-width': 4,
            'width': 52,
            'height': 52
          });
          break;

        case 'push_stack':
          cy.edges('[source="' + step.targets[0] + '"][target="' + step.targets[1] + '"], [source="' + step.targets[1] + '"][target="' + step.targets[0] + '"]')
            .style({
              'line-color': colors.TREE_EDGE,
              'target-arrow-color': colors.TREE_EDGE,
              'source-arrow-color': colors.TREE_EDGE,
              'width': 4
            });
          cy.getElementById(step.targets[1]).style({
            'background-color': colors.ACTIVE,
            'border-color': '#EA580C',
            'border-width': 3
          });
          break;

        case 'visit_node':
          cy.getElementById(step.targets[0]).style({
            'background-color': colors.VISITED,
            'border-color': '#16A34A',
            'border-width': 2
          });
          break;
      }
    }
  },

  /**
   * 更新状态栏 UI
   * @param {Object} step - 当前步骤
   * @param {Object} state - 状态对象 { isFinished, currentIdx, total, isPlaying, maxDepth }
   */
  updateUI: function(step, state) {
    var msgEl = document.getElementById('msg');
    var orderEl = document.getElementById('order');
    var stackEl = document.getElementById('stack');
    var depthEl = document.getElementById('depth');
    var iconPlay = document.getElementById('icon-play');
    var iconPause = document.getElementById('icon-pause');
    var btnPrimary = document.querySelector('.btn-primary');

    var total = state.total;
    var currentIdx = state.currentIdx;

    if (state.isFinished) {
      // 完成态
      if (msgEl) msgEl.textContent = step ? step.message : '✅ DFS 完成!';
      if (orderEl) orderEl.textContent = step && step.order ? '[' + step.order.join(', ') + ']' : '[ ]';
      if (stackEl) stackEl.textContent = '[ ]';
      if (depthEl) depthEl.textContent = '最大深度: ' + (state.maxDepth || 0);

      if (iconPlay) { iconPlay.textContent = '↻'; iconPlay.classList.remove('hidden'); }
      if (iconPause) iconPause.classList.add('hidden');
      if (btnPrimary) btnPrimary.classList.add('replay-pulse');
    } else if (currentIdx < 0) {
      // 重置态
      if (msgEl) msgEl.textContent = '准备就绪 — 点击 ▶ 开始';
      if (orderEl) orderEl.textContent = '[ ]';
      if (stackEl) stackEl.textContent = '[ ]';
      if (depthEl) depthEl.textContent = '-';

      if (iconPlay) { iconPlay.textContent = '▶'; iconPlay.classList.remove('hidden'); }
      if (iconPause) iconPause.classList.add('hidden');
      if (btnPrimary) btnPrimary.classList.remove('replay-pulse');
    } else {
      // 播放中/暂停态
      if (msgEl) msgEl.textContent = step ? step.message : '';
      if (orderEl) orderEl.textContent = step && step.order ? '[' + step.order.join(', ') + ']' : '[ ]';
      if (stackEl) stackEl.textContent = step && step.stack ? '[' + step.stack.join(',') + ']' : '[ ]';

      if (depthEl && step && step.depth && step.targets && step.targets[0]) {
        var currentDepth = step.depth[step.targets[0]] || 0;
        depthEl.textContent = '当前深度: ' + currentDepth;
      }

      if (iconPlay) iconPlay.classList.remove('hidden');
      if (iconPause) iconPause.classList.add('hidden');
      if (btnPrimary) btnPrimary.classList.remove('replay-pulse');
    }
  },

  /**
   * 显示提示框（内部方法）
   */
  _showTooltip: function(cy, nodeId, text) {
    if (typeof this._tooltipEl !== 'undefined' && this._tooltipEl) {
      var node = cy.getElementById(nodeId);
      if (!node) return;
      var pos = node.position();
      var pan = cy.pan();
      var zoom = cy.zoom();
      var rect = cy.container().getBoundingClientRect();
      var x = pos.x * zoom + pan.x + rect.width / 2;
      var y = pos.y * zoom + pan.y + rect.height / 2;
      var ttText = document.getElementById('tooltip-text');
      if (ttText) ttText.textContent = text;
      this._tooltipEl.classList.remove('hidden');
      this._tooltipEl.style.left = Math.min(x, rect.width - 130) + 'px';
      this._tooltipEl.style.top = Math.max(y - 65, 8) + 'px';
    }
  },

  /**
   * 隐藏提示框（内部方法）
   */
  _hideTooltip: function() {
    if (typeof this._tooltipEl !== 'undefined' && this._tooltipEl) {
      this._tooltipEl.classList.add('hidden');
    }
  },

  /**
   * 初始化提示框元素引用
   * @param {HTMLElement} tooltipEl - 提示框元素
   */
  setTooltipEl: function(tooltipEl) {
    this._tooltipEl = tooltipEl;
  },

  /**
   * 重置所有节点和边的样式（用于重置）
   * @param {Object} cy - Cytoscape 实例
   */
  resetVisuals: function(cy) {
    cy.elements().stop(true, false);
    cy.nodes().style({
      'background-color': this.COLORS.DEFAULT,
      'border-color': '#4B5563',
      'border-width': 2,
      'color': '#F9FAFB',
      'width': 46,
      'height': 46,
      'transition-duration': '0s'
    });
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
  }
};

// 导出（兼容 CommonJS 和全局）
if (typeof module !== 'undefined' && module.exports) {
  module.exports = DFS;
}
