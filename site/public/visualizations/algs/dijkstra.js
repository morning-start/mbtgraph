/**
 * dijkstra.js — Dijkstra 最短路径算法可视化步骤生成器
 * 
 * 与 viz-engine.js 配合使用
 * 
 * 颜色方案:
 *   节点: 起点=#B45309, 当前=#F97316, 已访问=#22C55E, 未访问=#374151
 *   边:   当前/已更新=#EF4444, 未使用=#6B7280
 */

var Dijkstra = {
  
  /**
   * 生成 Dijkstra 算法执行步骤
   * @param {Array} nodes - 节点数组 [{ data: { id, label } }]
   * @param {Object} adjList - 邻接表 { nodeId: [neighborIds] }
   * @param {Object} edgeWeights - 边权重 { "src-tgt": weight }
   * @param {string} startId - 起始节点 ID
   * @returns {Array} 步骤数组
   */
  generateSteps: function(nodes, adjList, edgeWeights, startId) {
    var steps = [];
    var dist = {};
    var parent = {};
    var visited = {};
    
    // 初始化距离表和访问状态
    nodes.forEach(function(n) {
      dist[n.data.id] = n.data.id === startId ? 0 : Infinity;
      parent[n.data.id] = null;
      visited[n.data.id] = false;
    });
    
    // 初始化步骤
    steps.push({
      type: 'init',
      targets: [startId],
      message: '初始化: dist[' + startId + ']=0, 其他=∞',
      dist: JSON.parse(JSON.stringify(dist)),
      parent: JSON.parse(JSON.stringify(parent)),
      visited: JSON.parse(JSON.stringify(visited)),
      current: startId
    });
    
    // Dijkstra 主循环
    while (true) {
      // 找未访问的最小距离节点
      var minDist = Infinity;
      var u = null;
      for (var nid in dist) {
        if (!visited[nid] && dist[nid] < minDist) {
          minDist = dist[nid];
          u = nid;
        }
      }
      
      if (u === null) break; // 所有可达节点已处理
      
      visited[u] = true;
      
      // 选择节点步骤
      steps.push({
        type: 'select',
        targets: [u],
        message: '选择最小距离节点: ' + u + ' (dist=' + (dist[u] === Infinity ? '∞' : dist[u]) + ')',
        dist: JSON.parse(JSON.stringify(dist)),
        parent: JSON.parse(JSON.stringify(parent)),
        visited: JSON.parse(JSON.stringify(visited)),
        current: u
      });
      
      // 松弛所有出边
      var neighbors = adjList[u] || [];
      for (var ni = 0; ni < neighbors.length; ni++) {
        var v = neighbors[ni];
        if (visited[v]) continue;
        
        var w = edgeWeights[u + '-' + v];
        if (w === undefined) continue; // 跳过无边权重的边
        
        var newDist = dist[u] + w;
        var isRelaxed = newDist < dist[v];
        
        steps.push({
          type: 'relax',
          targets: [u, v],
          message: '检查边 ' + u + '→' + v + ' (w=' + w + '): dist[' + v + ']=' +
            (dist[v] === Infinity ? '∞' : dist[v]) + ' → ' +
            (newDist === Infinity ? '∞' : newDist) + (isRelaxed ? ' ✓ 更新!' : ' 保持'),
          dist: JSON.parse(JSON.stringify(dist)),
          parent: JSON.parse(JSON.stringify(parent)),
          visited: JSON.parse(JSON.stringify(visited)),
          current: u,
          edge: [u, v],
          relaxed: isRelaxed
        });
        
        if (isRelaxed) {
          dist[v] = newDist;
          parent[v] = u;
        }
      }
    }
    
    // 完成步骤
    var reachable = Object.keys(dist).filter(function(n) { return dist[n] < Infinity; });
    steps.push({
      type: 'finish',
      targets: [],
      message: '✅ Dijkstra 完成! 可达节点: ' + reachable.length + '/' + nodes.length,
      dist: JSON.parse(JSON.stringify(dist)),
      parent: JSON.parse(JSON.stringify(parent)),
      visited: JSON.parse(JSON.stringify(visited)),
      current: null
    });
    
    return steps;
  },
  
  /**
   * 执行单步动画
   * @param {Object} cy - Cytoscape 实例
   * @param {Object} step - 步骤对象
   * @param {boolean} animate - 是否执行动画
   * @param {number} speed - 动画速度（毫秒）
   */
  executeStep: function(cy, step, animate, speed) {
    var dur = animate ? Math.max(200, speed * 0.6) : 0;
    
    switch (step.type) {
      case 'init':
        // 起点标记为棕色
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
        
      case 'select':
        // 当前处理节点变为橙色
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
        
      case 'relax':
        var src = step.targets[0];
        var tgt = step.targets[1];
        var edgeSel = cy.edges('[source="' + src + '"][target="' + tgt + '"]');
        
        if (step.relaxed) {
          // 更新：边变红色
          edgeSel.animate({
            style: {
              'line-color': '#EF4444',
              'target-arrow-color': '#EF4444',
              'source-arrow-color': '#EF4444',
              'width': 4
            }
          }, { duration: dur });
          // 目标节点高亮为黄色
          cy.getElementById(tgt).animate({
            style: {
              'background-color': '#FBBF24',
              'border-color': '#F59E0B',
              'border-width': 3
            }
          }, { duration: Math.max(100, dur * 0.5) });
        } else {
          // 保持：边变灰虚线
          edgeSel.animate({
            style: {
              'line-color': '#94A3B8',
              'target-arrow-color': '#94A3B8',
              'source-arrow-color': '#94A3B8',
              'width': 1.5,
              'line-style': 'dashed',
              'opacity': 0.45
            }
          }, { duration: Math.max(80, dur * 0.4) });
        }
        break;
        
      case 'finish':
        // 所有节点最终状态
        cy.nodes().style({
          'background-color': function(ele) {
            var id = ele.data('id');
            if (id === step.targets[0] || id === '0') return '#B45309'; // 起点棕色
            if (step.visited[id]) return '#22C55E'; // 已访问绿色
            return '#374151'; // 未访问灰色
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
    
    // 逐步重建到目标步骤
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
          
        case 'select':
          cy.getElementById(step.targets[0]).style({
            'background-color': '#F97316',
            'border-color': '#EA580C',
            'border-width': 3,
            'width': 49,
            'height': 49
          });
          break;
          
        case 'relax':
          var srcR = step.targets[0];
          var tgtR = step.targets[1];
          var edgeSelR = cy.edges('[source="' + srcR + '"][target="' + tgtR + '"]');
          
          if (step.relaxed) {
            edgeSelR.style({
              'line-color': '#EF4444',
              'target-arrow-color': '#EF4444',
              'source-arrow-color': '#EF4444',
              'width': 4
            });
            cy.getElementById(tgtR).style({
              'background-color': '#FBBF24',
              'border-color': '#F59E0B'
            });
          } else {
            edgeSelR.style({
              'line-color': '#94A3B8',
              'target-arrow-color': '#94A3B8',
              'source-arrow-color': '#94A3B8',
              'width': 1.5,
              'line-style': 'dashed',
              'opacity': 0.45
            });
          }
          break;
          
        case 'finish':
          // 应用最终状态
          cy.nodes().style({
            'background-color': function(ele) {
              var id = ele.data('id');
              if (id === '0') return '#B45309';
              if (step.visited[id]) return '#22C55E';
              return '#374151';
            }
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
    var currentNodeEl = document.getElementById('current-node');
    var distTableEl = document.getElementById('dist-table');
    var visitedNodesEl = document.getElementById('visited-nodes');
    
    if (state.isFinished) {
      // 完成状态
      if (msgEl) msgEl.textContent = step ? step.message : '完成';
      if (currentNodeEl) currentNodeEl.textContent = '-';
      if (distTableEl) distTableEl.textContent = step ? this._formatDistTable(step.dist) : '-';
      if (visitedNodesEl) visitedNodesEl.textContent = step ? this._formatVisited(step.visited) : '-';
    } else if (state.currentIdx < 0) {
      // 重置状态
      if (msgEl) msgEl.textContent = '准备就绪 — 点击 ▶ 开始';
      if (currentNodeEl) currentNodeEl.textContent = '-';
      if (distTableEl) distTableEl.textContent = '-';
      if (visitedNodesEl) visitedNodesEl.textContent = '-';
    } else {
      // 播放中/暂停状态
      if (msgEl) msgEl.textContent = step ? step.message : '';
      if (currentNodeEl) currentNodeEl.textContent = step && step.current !== null ? step.current : '-';
      if (distTableEl) distTableEl.textContent = step ? this._formatDistTable(step.dist) : '-';
      if (visitedNodesEl) visitedNodesEl.textContent = step ? this._formatVisited(step.visited) : '-';
    }
  },
  
  // ==================== 内部辅助方法 ====================
  
  /**
   * 格式化距离表
   */
  _formatDistTable: function(dist) {
    var parts = [];
    for (var nid in dist) {
      var d = dist[nid];
      parts.push(nid + ':' + (d === Infinity ? '∞' : d));
    }
    return '[' + parts.join(', ') + ']';
  },
  
  /**
   * 格式化已访问节点列表
   */
  _formatVisited: function(visited) {
    var visitedList = [];
    for (var nid in visited) {
      if (visited[nid]) visitedList.push(nid);
    }
    return visitedList.length > 0 ? '[' + visitedList.join(',') + ']' : '[ ]';
  },
  
  /**
   * 显示提示框
   */
  _showTooltip: function(cy, nodeId, text) {
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
  _hideTooltip: function(cy) {
    var tooltipEl = document.getElementById('viz-tooltip');
    if (tooltipEl) tooltipEl.classList.add('hidden');
  }
};
