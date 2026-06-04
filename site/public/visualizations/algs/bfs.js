/**
 * BFS 广度优先搜索 - 步骤生成器和执行器
 * 用于图算法可视化
 */

var BFS = {
  /**
   * 生成 BFS 算法的执行步骤
   * @param {Array} nodes - 节点数组 [{ data: { id, label } }]
   * @param {Object} adjList - 邻接表 { nodeId: [neighborIds] }
   * @param {string} startId - 起始节点 ID
   * @returns {Array} 步骤数组
   */
  generateSteps: function(nodes, adjList, startId) {
    var steps = [];
    var visited = {};
    var queue = [startId];
    var order = [];
    var levels = {};
    levels[startId] = 0;

    // 初始化：起点入队
    steps.push({
      type: 'init',
      targets: [startId],
      message: '初始化: 起点 ' + startId + ' 入队',
      order: [],
      queue: [startId],
      levels: JSON.parse(JSON.stringify(levels))
    });

    var head = 0;
    while (head < queue.length) {
      var current = queue[head];
      head++;

      if (!visited[current]) {
        visited[current] = true;
        order.push(current);

        // 出队：当前节点
        steps.push({
          type: 'dequeue',
          targets: [current],
          message: '出队: 节点 ' + current,
          order: order.slice(),
          queue: queue.slice(head),
          levels: JSON.parse(JSON.stringify(levels))
        });

        // 遍历邻居
        var neighbors = adjList[current] || [];
        for (var ni = 0; ni < neighbors.length; ni++) {
          var nbr = neighbors[ni];
          if (!visited[nbr]) {
            // 发现新节点，入队
            queue.push(nbr);
            levels[nbr] = (levels[current] || 0) + 1;
            steps.push({
              type: 'visit_edge',
              targets: [current, nbr],
              message: '发现新节点 ' + nbr + '! 入队 (Level ' + levels[nbr] + ')',
              order: order.slice(),
              queue: queue.slice(head),
              levels: JSON.parse(JSON.stringify(levels))
            });
          } else {
            // 已访问，跳过
            steps.push({
              type: 'skip_edge',
              targets: [current, nbr],
              message: nbr + ' 已访问, 跳过',
              order: order.slice(),
              queue: queue.slice(head),
              levels: JSON.parse(JSON.stringify(levels))
            });
          }
        }

        // 节点处理完成
        steps.push({
          type: 'visit_node',
          targets: [current],
          message: current + ' 处理完成 \u2713',
          order: order.slice(),
          queue: queue.slice(head),
          levels: JSON.parse(JSON.stringify(levels))
        });
      } else {
        // 已在队列中，跳过
        steps.push({
          type: 'skip_edge',
          targets: [current],
          message: current + ' 已在队列中, 跳过',
          order: order.slice(),
          queue: queue.slice(head),
          levels: JSON.parse(JSON.stringify(levels))
        });
      }
    }

    // 完成
    steps.push({
      type: 'finish',
      targets: [],
      message: '\u2705 BFS 完成! 访问顺序: [' + order.join(', ') + ']',
      order: order,
      queue: [],
      levels: levels
    });

    return steps;
  },

  /**
   * 根据步骤类型执行动画
   * @param {Object} cy - Cytoscape 实例
   * @param {Object} step - 步骤对象
   * @param {boolean} animate - 是否使用动画
   * @param {number} speed - 动画速度（毫秒）
   */
  executeStep: function(cy, step, animate, speed) {
    var dur = animate ? Math.max(200, speed * 0.6) : 0;

    switch (step.type) {
      case 'init':
        cy.getElementById(step.targets[0]).animate({
          style: {
            'background-color': '#B45309',
            'border-color': '#92400E',
            'border-width': 4,
            'width': 52,
            'height': 52
          }
        }, { duration: dur });
        this._showTooltip(cy, step.targets[0], '起点\n' + step.message);
        break;

      case 'dequeue':
        cy.getElementById(step.targets[0]).animate({
          style: {
            'background-color': '#F97316',
            'border-color': '#EA580C',
            'border-width': 3,
            'width': 49,
            'height': 49
          }
        }, { duration: dur });
        break;

      case 'visit_node':
        cy.getElementById(step.targets[0]).animate({
          style: {
            'background-color': '#22C55E',
            'border-color': '#16A34A',
            'border-width': 2,
            'width': 46,
            'height': 46
          }
        }, { duration: dur });
        this._hideTooltip(cy);
        break;

      case 'visit_edge':
        var src = step.targets[0];
        var tgt = step.targets[1];
        // 找到对应的边（无向图，双向都可能）
        cy.edges('[source="' + src + '"][target="' + tgt + '"], [source="' + tgt + '"][target="' + src + '"]')
          .animate({
            style: {
              'line-color': '#EF4444',
              'target-arrow-color': '#EF4444',
              'source-arrow-color': '#EF4444',
              'width': 4
            }
          }, { duration: dur });
        // 高亮目标节点
        cy.getElementById(tgt).animate(
          {
            style: {
              'background-color': '#FBBF24',
              'border-color': '#F59E0B',
              'border-width': 3
            }
          },
          { duration: Math.max(100, dur * 0.5) }
        );
        break;

      case 'skip_edge':
        var s2 = step.targets[0];
        var t2 = step.targets[1];
        cy.edges('[source="' + s2 + '"][target="' + t2 + '"], [source="' + t2 + '"][target="' + s2 + '"]')
          .animate({
            style: {
              'line-color': '#94A3B8',
              'target-arrow-color': '#94A3B8',
              'source-arrow-color': '#94A3B8',
              'width': 1.5,
              'line-style': 'dashed',
              'opacity': 0.45
            }
          }, { duration: Math.max(80, dur * 0.4) });
        break;

      case 'finish':
        // 所有节点变为最终状态
        cy.nodes().style({
          'background-color': function(ele) {
            return ele.data('id') === step.targets[0] ? '#B45309' : '#22C55E';
          }
        });
        this._hideTooltip(cy);
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
    // 先全部重置
    cy.nodes().style({
      'background-color': '#374151',
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

    // 逐步重建到指定步骤
    for (var i = 0; i <= idx; i++) {
      var step = steps[i];
      if (!step) continue;

      switch (step.type) {
        case 'init':
          cy.getElementById(step.targets[0]).style({
            'background-color': '#B45309',
            'border-color': '#92400E',
            'border-width': 4,
            'width': 52,
            'height': 52
          });
          break;

        case 'dequeue':
          cy.getElementById(step.targets[0]).style({
            'background-color': '#F97316',
            'border-color': '#EA580C',
            'border-width': 3
          });
          break;

        case 'visit_node':
          cy.getElementById(step.targets[0]).style({
            'background-color': '#22C55E',
            'border-color': '#16A34A',
            'border-width': 2
          });
          break;

        case 'visit_edge':
          cy.edges('[source="' + step.targets[0] + '"][target="' + step.targets[1] + '"], [source="' + step.targets[1] + '"][target="' + step.targets[0] + '"]')
            .style({
              'line-color': '#EF4444',
              'target-arrow-color': '#EF4444',
              'source-arrow-color': '#EF4444',
              'width': 4
            });
          cy.getElementById(step.targets[1]).style({
            'background-color': '#FBBF24',
            'border-color': '#F59E0B'
          });
          break;

        case 'skip_edge':
          cy.edges('[source="' + step.targets[0] + '"][target="' + step.targets[1] + '"], [source="' + step.targets[1] + '"][target="' + step.targets[0] + '"]')
            .style({
              'line-color': '#94A3B8',
              'target-arrow-color': '#94A3B8',
              'source-arrow-color': '#94A3B8',
              'width': 1.5,
              'line-style': 'dashed',
              'opacity': 0.45
            });
          break;
      }
    }
  },

  /**
   * 更新状态栏 UI
   * @param {Object} step - 当前步骤对象
   * @param {Object} state - 状态对象 { isFinished, currentIdx, total, isPlaying }
   */
  updateUI: function(step, state) {
    var msgEl = document.getElementById('msg');
    var orderEl = document.getElementById('order');
    var queueEl = document.getElementById('queue');
    var levelsEl = document.getElementById('levels');

    if (state.isFinished) {
      // 完成态：展示最终结果
      if (msgEl) msgEl.textContent = step ? step.message : '\u2705 BFS 完成!';
      if (orderEl) orderEl.textContent = step && step.order ? '[' + step.order.join(', ') + ']' : '[ ]';
      if (queueEl) queueEl.textContent = '[ ]';
      if (levelsEl && step && step.levels) {
        levelsEl.textContent = this._formatLevels(step.levels);
      }
    } else if (state.currentIdx < 0) {
      // 重置态
      if (msgEl) msgEl.textContent = '\u51C6\u5907\u5C31\u7EEA \u2014 \u70B9\u51FB \u25B6 \u5F00\u59CB';
      if (orderEl) orderEl.textContent = '[ ]';
      if (queueEl) queueEl.textContent = '[ ]';
      if (levelsEl) levelsEl.textContent = '-';
    } else {
      // 播放中/暂停态
      if (msgEl) msgEl.textContent = step ? step.message : '';
      if (orderEl) orderEl.textContent = step && step.order ? '[' + step.order.join(', ') + ']' : '[ ]';
      if (queueEl) queueEl.textContent = step && step.queue ? '[' + step.queue.join(',') + ']' : '[ ]';
      if (levelsEl && step && step.levels) {
        levelsEl.textContent = this._formatLevels(step.levels);
      }
    }
  },

  /**
   * 格式化层级信息
   * @param {Object} levels - 层级映射 { nodeId: level }
   * @returns {string} 格式化后的字符串，如 "L0:[0] L1:[1,2,4]"
   */
  _formatLevels: function(levels) {
    if (!levels) return '-';
    var groups = {};
    for (var k in levels) {
      if (!groups[levels[k]]) groups[levels[k]] = [];
      groups[levels[k]].push(k);
    }
    var parts = Object.keys(groups).sort(function(a, b) {
      return Number(a) - Number(b);
    }).map(function(l) {
      return 'L' + l + ':[' + groups[l].join(',') + ']';
    });
    return parts.join(' ') || '-';
  },

  /**
   * 显示提示框
   * @param {Object} cy - Cytoscape 实例
   * @param {string} nodeId - 节点 ID
   * @param {string} text - 提示文本
   */
  _showTooltip: function(cy, nodeId, text) {
    var node = cy.getElementById(nodeId);
    if (!node) return;

    var tooltipEl = document.getElementById('viz-tooltip');
    var ttText = document.getElementById('tooltip-text');
    if (!tooltipEl || !ttText) return;

    var pos = node.position();
    var pan = cy.pan();
    var zoom = cy.zoom();
    var rect = cy.container().getBoundingClientRect();

    var x = pos.x * zoom + pan.x + rect.width / 2;
    var y = pos.y * zoom + pan.y + rect.height / 2;

    ttText.textContent = text;
    tooltipEl.classList.remove('hidden');
    tooltipEl.style.left = Math.min(x, rect.width - 130) + 'px';
    tooltipEl.style.top = Math.max(y - 65, 8) + 'px';
  },

  /**
   * 隐藏提示框
   * @param {Object} cy - Cytoscape 实例
   */
  _hideTooltip: function(cy) {
    var tooltipEl = document.getElementById('viz-tooltip');
    if (tooltipEl) tooltipEl.classList.add('hidden');
  }
};

// 导出供模块系统使用
if (typeof module !== 'undefined' && module.exports) {
  module.exports = BFS;
}
