/**
 * cycle.js — 环检测算法可视化模块
 * 
 * 基于 DFS 的有向图环检测算法
 * 三种节点状态：unvisited(灰) → visiting(橙) → visited(绿)
 * 发现环时目标节点处于 visiting 状态
 */

var Cycle = {
  /**
   * 生成环检测算法的执行步骤
   * @param {Array} nodes - 节点数组 [{ data: { id, label } }]
   * @param {Object} adjList - 邻接表 { nodeId: [neighborIds] }
   * @returns {Array} 步骤数组
   */
  generateSteps: function(nodes, adjList) {
    var steps = [];
    var status = {};  // 'unvisited', 'visiting', 'visited'
    var onStack = {};  // 正在 DFS 栈上的节点
    var stack = [];    // DFS 递归栈显示
    var order = [];    // 访问顺序
    var cycleFound = null;  // 检测到的环 [node1, node2, ..., node1]
    var cycleEdges = [];    // 环的边 ID

    // 初始化所有节点为未访问
    nodes.forEach(function(n) { status[n.data.id] = 'unvisited'; });

    // 初始化步骤
    steps.push({
      type: 'init',
      targets: [],
      message: '开始环检测 (DFS-based)',
      status: JSON.parse(JSON.stringify(status)),
      stack: [],
      order: [],
      cycle: null
    });

    /**
     * DFS 递归遍历
     */
    function dfs(nodeId) {
      if (cycleFound) return;  // 已知有环，停止搜索

      // 标记为正在访问
      status[nodeId] = 'visiting';
      onStack[nodeId] = true;
      stack.push(nodeId);
      order.push(nodeId);

      steps.push({
        type: 'visit_start',
        targets: [nodeId],
        message: '进入节点 ' + nodeId,
        status: JSON.parse(JSON.stringify(status)),
        stack: stack.slice(),
        order: order.slice(),
        cycle: null
      });

      var neighbors = adjList[nodeId] || [];
      for (var ni = 0; ni < neighbors.length; ni++) {
        var nbr = neighbors[ni];

        if (cycleFound) return;  // 发现环后停止

        if (status[nbr] === 'unvisited') {
          // 继续 DFS
          steps.push({
            type: 'explore_edge',
            targets: [nodeId, nbr],
            message: '探索边 ' + nodeId + ' → ' + nbr,
            status: JSON.parse(JSON.stringify(status)),
            stack: stack.slice(),
            order: order.slice(),
            cycle: null
          });
          dfs(nbr);
          if (cycleFound) return;
        } else if (onStack[nbr]) {
          // 发现环！
          // 重建环路径
          var cycleStart = stack.indexOf(nbr);
          cycleFound = stack.slice(cycleStart).concat([nbr]);

          // 标记环边
          for (var ci = cycleStart; ci < stack.length; ci++) {
            cycleEdges.push({ from: stack[ci], to: stack[ci + 1] || nbr });
          }
          cycleEdges.push({ from: stack[stack.length - 1], to: nbr });

          steps.push({
            type: 'cycle_found',
            targets: [nodeId, nbr],
            message: '发现环! ' + cycleFound.join(' → ') + ' → ' + nbr,
            status: JSON.parse(JSON.stringify(status)),
            stack: stack.slice(),
            order: order.slice(),
            cycle: cycleFound
          });
          return;
        }
      }

      // 回溯
      status[nodeId] = 'visited';
      delete onStack[nodeId];
      stack.pop();

      steps.push({
        type: 'backtrack',
        targets: [nodeId],
        message: '回溯节点 ' + nodeId,
        status: JSON.parse(JSON.stringify(status)),
        stack: stack.slice(),
        order: order.slice(),
        cycle: null
      });
    }

    // 从每个未访问节点开始 DFS
    for (var ni = 0; ni < nodes.length; ni++) {
      var nid = nodes[ni].data.id;
      if (status[nid] === 'unvisited') {
        dfs(nid);
        if (cycleFound) break;
      }
    }

    // 无环完成
    if (!cycleFound) {
      steps.push({
        type: 'finish',
        targets: [],
        message: '无环！图是 DAG',
        status: JSON.parse(JSON.stringify(status)),
        stack: [],
        order: order,
        cycle: null
      });
    }

    return steps;
  },

  /**
   * 执行单步动画
   * @param {Object} cy - Cytoscape 实例
   * @param {Object} step - 步骤对象
   * @param {boolean} animate - 是否使用动画
   * @param {number} speed - 动画速度
   */
  executeStep: function(cy, step, animate, speed) {
    var dur = animate ? Math.max(200, speed * 0.6) : 0;

    switch (step.type) {
      case 'init':
        // 初始化，不做特殊处理
        break;

      case 'visit_start':
        // 节点开始访问：变为橙色
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

      case 'explore_edge':
        // 探索边：高亮边为红色
        var src = step.targets[0], tgt = step.targets[1];
        cy.edges('[source="' + src + '"][target="' + tgt + '"]')
          .animate({
            style: {
              'line-color': '#EF4444',
              'target-arrow-color': '#EF4444',
              'width': 4
            }
          }, { duration: dur });
        break;

      case 'cycle_found':
        // 发现环：边和环上节点变红
        var csrc = step.targets[0], ctgt = step.targets[1];
        cy.edges('[source="' + csrc + '"][target="' + ctgt + '"]')
          .animate({
            style: {
              'line-color': '#EF4444',
              'target-arrow-color': '#EF4444',
              'width': 5
            }
          }, { duration: dur });
        // 高亮环上的所有节点
        if (step.cycle) {
          for (var ci = 0; ci < step.cycle.length; ci++) {
            cy.getElementById(step.cycle[ci]).animate({
              style: {
                'background-color': '#EF4444',
                'border-color': '#DC2626',
                'border-width': 4
              }
            }, { duration: dur });
          }
        }
        break;

      case 'backtrack':
        // 回溯完成：节点变为绿色
        cy.getElementById(step.targets[0]).animate({
          style: {
            'background-color': '#22C55E',
            'border-color': '#16A34A',
            'border-width': 2,
            'width': 46,
            'height': 46
          }
        }, { duration: dur });
        break;

      case 'finish':
        // 完成：所有节点变绿
        cy.nodes().style({
          'background-color': '#22C55E',
          'border-color': '#16A34A',
          'border-width': 2
        });
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
    // 先全部重置为初始状态
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

    // 逐步重建到目标步骤
    for (var i = 0; i <= idx; i++) {
      var step = steps[i];
      if (!step) continue;

      switch (step.type) {
        case 'visit_start':
          cy.getElementById(step.targets[0]).style({
            'background-color': '#F97316',
            'border-color': '#EA580C',
            'border-width': 3
          });
          break;

        case 'explore_edge':
          cy.edges('[source="' + step.targets[0] + '"][target="' + step.targets[1] + '"]')
            .style({
              'line-color': '#EF4444',
              'target-arrow-color': '#EF4444',
              'width': 4
            });
          break;

        case 'cycle_found':
          cy.edges('[source="' + step.targets[0] + '"][target="' + step.targets[1] + '"]')
            .style({
              'line-color': '#EF4444',
              'target-arrow-color': '#EF4444',
              'width': 5
            });
          if (step.cycle) {
            for (var ci = 0; ci < step.cycle.length; ci++) {
              cy.getElementById(step.cycle[ci]).style({
                'background-color': '#EF4444',
                'border-color': '#DC2626',
                'border-width': 4
              });
            }
          }
          break;

        case 'backtrack':
          cy.getElementById(step.targets[0]).style({
            'background-color': '#22C55E',
            'border-color': '#16A34A',
            'border-width': 2
          });
          break;

        case 'finish':
          cy.nodes().style({
            'background-color': '#22C55E',
            'border-color': '#16A34A',
            'border-width': 2
          });
          break;
      }
    }
  },

  /**
   * 更新 UI 状态栏
   * @param {Object} step - 当前步骤
   * @param {Object} state - 状态对象 { isFinished, currentIdx, total, isPlaying }
   */
  updateUI: function(step, state) {
    // 更新消息
    var msgEl = document.getElementById('msg');
    var orderEl = document.getElementById('order');
    var stackEl = document.getElementById('stack');
    var cycleEl = document.getElementById('cycle');

    if (state.isFinished) {
      // 完成态
      if (msgEl) msgEl.textContent = step ? step.message : '完成';
      if (orderEl) orderEl.textContent = step && step.order ? '[' + step.order.join(', ') + ']' : '[ ]';
      if (stackEl) stackEl.textContent = '[ ]';
      if (cycleEl) {
        if (step && step.cycle) {
          cycleEl.textContent = step.cycle.join(' → ');
          cycleEl.classList.add('status-cycle');
        } else {
          cycleEl.textContent = '无环';
          cycleEl.classList.remove('status-cycle');
        }
      }
    } else if (state.currentIdx < 0) {
      // 重置态
      if (msgEl) msgEl.textContent = '准备就绪 — 点击 ▶ 开始';
      if (orderEl) orderEl.textContent = '[ ]';
      if (stackEl) stackEl.textContent = '[ ]';
      if (cycleEl) {
        cycleEl.textContent = '-';
        cycleEl.classList.remove('status-cycle');
      }
    } else {
      // 播放中/暂停态
      if (msgEl) msgEl.textContent = step ? step.message : '';
      if (orderEl) orderEl.textContent = step && step.order ? '[' + step.order.join(', ') + ']' : '[ ]';
      if (stackEl) stackEl.textContent = step && step.stack ? '[' + step.stack.join(',') + ']' : '[ ]';
      if (cycleEl) {
        if (step && step.cycle) {
          cycleEl.textContent = step.cycle.join(' → ');
          cycleEl.classList.add('status-cycle');
        } else {
          cycleEl.textContent = '-';
          cycleEl.classList.remove('status-cycle');
        }
      }
    }
  }
};
