/**
 * topo.js — Kahn 拓扑排序算法可视化步骤生成器
 * 
 * 提供 Kahn 算法的步骤生成、动画执行、快速重建和 UI 更新功能
 */

var Topo = {
  /**
   * 生成 Kahn 拓扑排序的所有步骤
   * @param {Array} nodes - 节点数据 [{ data: { id, label } }]
   * @param {Object} adjList - 邻接表 { nodeId: [neighborIds] }
   * @returns {Array} 步骤数组
   */
  generateSteps: function(nodes, adjList) {
    var steps = [];
    var queue = [];
    var result = [];
    var processedEdges = {};

    // 计算初始入度
    var inDegree = {};
    nodes.forEach(function(n) {
      inDegree[n.data.id] = 0;
    });
    
    // 从边数据计算入度（通过遍历所有邻接关系）
    for (var src in adjList) {
      var neighbors = adjList[src] || [];
      for (var i = 0; i < neighbors.length; i++) {
        inDegree[neighbors[i]]++;
      }
    }

    // 深拷贝初始入度
    var currentInDegree = {};
    for (var nid in inDegree) {
      currentInDegree[nid] = inDegree[nid];
    }

    // 初始化：找入度为0的节点
    var zeroInDegree = [];
    for (var zid in currentInDegree) {
      if (currentInDegree[zid] === 0) zeroInDegree.push(zid);
    }
    zeroInDegree.sort();

    steps.push({
      type: 'init',
      targets: [],
      message: '计算入度完成',
      inDegree: this._cloneInDegree(currentInDegree),
      queue: [],
      result: [],
      ready: zeroInDegree.slice()
    });

    // 入度为0的节点入队
    for (var qi = 0; qi < zeroInDegree.length; qi++) {
      queue.push(zeroInDegree[qi]);
    }

    steps.push({
      type: 'enqueue_ready',
      targets: queue.slice(),
      message: '入度为0的节点入队: [' + queue.join(', ') + ']',
      inDegree: this._cloneInDegree(currentInDegree),
      queue: queue.slice(),
      result: result.slice(),
      ready: []
    });

    // Kahn 主循环
    while (queue.length > 0) {
      var node = queue.shift();

      result.push(node);

      steps.push({
        type: 'dequeue',
        targets: [node],
        message: '出队: 节点 ' + node + ' 加入拓扑序',
        inDegree: this._cloneInDegree(currentInDegree),
        queue: queue.slice(),
        result: result.slice(),
        ready: []
      });

      // 处理所有出边
      var neighbors = adjList[node] || [];
      for (var ni = 0; ni < neighbors.length; ni++) {
        var nbr = neighbors[ni];
        var edgeId = 'e' + node + nbr;
        processedEdges[edgeId] = true;

        var oldDegree = currentInDegree[nbr];
        currentInDegree[nbr]--;

        steps.push({
          type: 'decrement',
          targets: [node, nbr],
          message: '边 ' + node + '\u2192' + nbr + ': 入度(' + nbr + ') ' + oldDegree + '\u2192' + currentInDegree[nbr],
          inDegree: this._cloneInDegree(currentInDegree),
          queue: queue.slice(),
          result: result.slice(),
          ready: []
        });

        if (currentInDegree[nbr] === 0) {
          queue.push(nbr);
          queue.sort();
          steps.push({
            type: 'ready',
            targets: [nbr],
            message: '节点 ' + nbr + ' 入度变为0，入队!',
            inDegree: this._cloneInDegree(currentInDegree),
            queue: queue.slice(),
            result: result.slice(),
            ready: []
          });
        }
      }
    }

    // 完成
    var visitedCount = result.length;
    var hasCycle = visitedCount < nodes.length;
    steps.push({
      type: 'finish',
      targets: [],
      message: hasCycle 
        ? '有环! 无法完成拓扑排序 (处理了 ' + visitedCount + '/' + nodes.length + ' 个节点)'
        : '拓扑排序完成: [' + result.join(' \u2192 ') + ']',
      inDegree: this._cloneInDegree(currentInDegree),
      queue: [],
      result: result.slice(),
      ready: []
    });

    return steps;
  },

  /**
   * 根据步骤类型执行动画
   * @param {Object} cy - Cytoscape 实例
   * @param {Object} step - 当前步骤
   * @param {boolean} animate - 是否播放动画
   * @param {number} speed - 动画速度（毫秒）
   */
  executeStep: function(cy, step, animate, speed) {
    var i;

    if (!animate) {
      speed = 0;
    }

    switch (step.type) {
      case 'init':
        // 高亮入度为0的节点（就绪状态 - 绿色边框）
        for (i = 0; i < step.ready.length; i++) {
          cy.getElementById(step.ready[i]).animate({
            style: { 'border-color': '#22C55E', 'border-width': 3 }
          }, { duration: speed });
        }
        break;

      case 'enqueue_ready':
        // 就绪节点保持绿色边框
        for (i = 0; i < step.targets.length; i++) {
          cy.getElementById(step.targets[i]).animate({
            style: { 'border-color': '#22C55E', 'border-width': 3 }
          }, { duration: speed });
        }
        break;

      case 'dequeue':
        // 节点变为处理中（橙色）
        var nodeId = step.targets[0];
        cy.getElementById(nodeId).animate({
          style: { 'background-color': '#F97316', 'border-color': '#EA580C', 'border-width': 3, 'width': 49, 'height': 49 }
        }, { duration: speed });
        break;

      case 'decrement':
        // 处理边高亮为红色
        var src = step.targets[0], tgt = step.targets[1];
        cy.edges('[source="' + src + '"][target="' + tgt + '"]')
          .animate({ style: { 'line-color': '#EF4444', 'target-arrow-color': '#EF4444', 'width': 4 } }, { duration: speed });
        // 目标节点如果入度变为0，高亮边框
        if (step.inDegree[tgt] === 0) {
          cy.getElementById(tgt).animate({
            style: { 'border-color': '#22C55E', 'border-width': 3 }
          }, { duration: speed });
        }
        break;

      case 'ready':
        // 新入队的节点（入度变为0）
        var readyNode = step.targets[0];
        cy.getElementById(readyNode).animate({
          style: { 'border-color': '#22C55E', 'border-width': 3 }
        }, { duration: speed });
        break;

      case 'finish':
        // 所有节点变为已处理（绿色）
        cy.nodes().animate({
          style: { 'background-color': '#22C55E', 'border-color': '#16A34A', 'border-width': 2, 'width': 46, 'height': 46 }
        }, { duration: speed });
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

    var processedNodes = {};
    var processedEdgesMap = {};

    // 逐步重建到指定步骤
    for (var i = 0; i <= idx; i++) {
      var step = steps[i];
      if (!step) continue;

      switch (step.type) {
        case 'init':
          for (var r = 0; r < step.ready.length; r++) {
            cy.getElementById(step.ready[r]).style({ 'border-color': '#22C55E', 'border-width': 3 });
          }
          break;

        case 'enqueue_ready':
          for (var e = 0; e < step.targets.length; e++) {
            cy.getElementById(step.targets[e]).style({ 'border-color': '#22C55E', 'border-width': 3 });
          }
          break;

        case 'dequeue':
          var dNode = step.targets[0];
          processedNodes[dNode] = true;
          cy.getElementById(dNode).style({ 
            'background-color': '#F97316', 
            'border-color': '#EA580C', 
            'border-width': 3 
          });
          break;

        case 'decrement':
          var ds = step.targets[0], dt = step.targets[1];
          processedEdgesMap['e' + ds + dt] = true;
          cy.edges('[source="' + ds + '"][target="' + dt + '"]')
            .style({ 'line-color': '#EF4444', 'target-arrow-color': '#EF4444', 'width': 4 });
          if (step.inDegree[dt] === 0) {
            cy.getElementById(dt).style({ 'border-color': '#22C55E', 'border-width': 3 });
          }
          break;

        case 'ready':
          cy.getElementById(step.targets[0]).style({ 'border-color': '#22C55E', 'border-width': 3 });
          break;

        case 'finish':
          cy.nodes().style({ 'background-color': '#22C55E', 'border-color': '#16A34A', 'border-width': 2 });
          break;
      }
    }

    // 根据 result 标记已处理节点（已完成的需要是绿色）
    for (var ri = 0; ri < step.result.length; ri++) {
      var nodeId = step.result[ri];
      if (!processedNodes[nodeId]) {
        cy.getElementById(nodeId).style({ 
          'background-color': '#22C55E', 
          'border-color': '#16A34A' 
        });
      }
    }
  },

  /**
   * 更新 UI 状态栏
   * @param {Object} step - 当前步骤
   * @param {Object} state - 状态对象 { isFinished, currentIdx, total, isPlaying }
   */
  updateUI: function(step, state) {
    var msgEl = document.getElementById('msg');
    var readyEl = document.getElementById('ready');
    var queueEl = document.getElementById('queue');
    var resultEl = document.getElementById('result');
    var indegreeEl = document.getElementById('indegree');

    if (!msgEl || !readyEl || !queueEl || !resultEl || !indegreeEl) return;

    if (state.isFinished) {
      // 完成态：展示最终结果
      if (msgEl) msgEl.textContent = step ? step.message : '完成';
      if (readyEl) readyEl.textContent = '[ ]';
      if (queueEl) queueEl.textContent = '[ ]';
      if (resultEl) resultEl.textContent = step && step.result && step.result.length > 0 
        ? '[' + step.result.join(' \u2192 ') + ']' 
        : '[ ]';
      if (indegreeEl && step) {
        indegreeEl.textContent = this._formatInDegree(step.inDegree);
      }
    } else if (state.currentIdx < 0) {
      // 重置态：显示初始入度
      if (msgEl) msgEl.textContent = '准备就绪 \u2014 点击 \u25B6 开始';
      if (readyEl) readyEl.textContent = '[ ]';
      if (queueEl) queueEl.textContent = '[ ]';
      if (resultEl) resultEl.textContent = '[ ]';
      if (indegreeEl && step) {
        indegreeEl.textContent = this._formatInDegree(step.inDegree);
      }
    } else {
      // 播放中/暂停态：当前步骤信息
      if (msgEl) msgEl.textContent = step ? step.message : '';
      if (readyEl) readyEl.textContent = step && step.ready && step.ready.length > 0 
        ? '[' + step.ready.join(',') + ']' 
        : '[ ]';
      if (queueEl) queueEl.textContent = step && step.queue && step.queue.length > 0 
        ? '[' + step.queue.join(',') + ']' 
        : '[ ]';
      if (resultEl) resultEl.textContent = step && step.result && step.result.length > 0 
        ? '[' + step.result.join(',') + ']' 
        : '[ ]';
      if (indegreeEl && step) {
        indegreeEl.textContent = this._formatInDegree(step.inDegree);
      }
    }
  },

  /**
   * 格式化入度显示字符串
   * @param {Object} inDegree - 入度表
   * @returns {string} 格式化后的字符串
   */
  _formatInDegree: function(inDegree) {
    if (!inDegree) return '-';
    var parts = [];
    for (var nid in inDegree) {
      parts.push(nid + ':' + inDegree[nid]);
    }
    parts.sort();
    return parts.join(', ');
  },

  /**
   * 深拷贝入度表
   * @param {Object} inDegree - 入度表
   * @returns {Object} 拷贝后的入度表
   */
  _cloneInDegree: function(inDegree) {
    var clone = {};
    for (var nid in inDegree) {
      clone[nid] = inDegree[nid];
    }
    return clone;
  }
};
