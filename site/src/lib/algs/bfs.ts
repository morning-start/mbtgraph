/**
 * bfs.ts — BFS 广度优先搜索可视化（ES Module）
 *
 * 重构后:
 *   - legendKeys: 从全局颜色注册表选取
 *   - generateSteps: 纯算法逻辑
 *   - renderStep: 通过 VizRenderer 渲染
 *   - getUIData: 返回状态数据
 */

import type { VizRenderer, RenderMode } from '../viz-renderer';
import type { ColorMap, LegendSelector } from '../color-registry';
import { darken } from '../color-registry';

// ── 图例声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'start' },
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
  { domain: 'edge', key: 'tree' },
];

// ── 类型定义 ──

export interface BFSStep {
  type: 'init' | 'dequeue' | 'visit_edge' | 'skip_edge' | 'visit_node' | 'finish';
  targets: string[];
  message: string;
  order: string[];
  queue: string[];
  levels: Record<string, number>;
}

export interface UIData {
  [elementId: string]: string;
}

// ── 算法实现 ──

const BFS = {
  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    _edgeWeights?: Record<string, number>,
    startNode?: string,
  ): BFSStep[] {
    const startId = startNode ?? '0';
    const steps: BFSStep[] = [];
    const visited: Record<string, boolean> = {};
    const queue: string[] = [startId];
    const levels: Record<string, number> = {};
    levels[startId] = 0;

    steps.push({
      type: 'init', targets: [startId],
      message: `初始化: 起点 ${startId} 入队`,
      order: [], queue: [startId], levels: JSON.parse(JSON.stringify(levels)),
    });

    let head = 0;
    while (head < queue.length) {
      const current = queue[head];
      head++;

      if (!visited[current]) {
        visited[current] = true;
        order.push(current);

        steps.push({
          type: 'dequeue', targets: [current],
          message: `出队: 节点 ${current}`,
          order: order.slice(), queue: queue.slice(head),
          levels: JSON.parse(JSON.stringify(levels)),
        });

        const neighbors = adjList[current] || [];
        for (let ni = 0; ni < neighbors.length; ni++) {
          const nbr = neighbors[ni];
          if (!visited[nbr]) {
            queue.push(nbr);
            levels[nbr] = (levels[current] || 0) + 1;
            steps.push({
              type: 'visit_edge', targets: [current, nbr],
              message: `发现新节点 ${nbr}! 入队 (Level ${levels[nbr]})`,
              order: order.slice(), queue: queue.slice(head),
              levels: JSON.parse(JSON.stringify(levels)),
            });
          } else {
            steps.push({
              type: 'skip_edge', targets: [current, nbr],
              message: `${nbr} 已访问, 跳过`,
              order: order.slice(), queue: queue.slice(head),
              levels: JSON.parse(JSON.stringify(levels)),
            });
          }
        }

        steps.push({
          type: 'visit_node', targets: [current],
          message: `${current} 处理完成 ✓`,
          order: order.slice(), queue: queue.slice(head),
          levels: JSON.parse(JSON.stringify(levels)),
        });
      } else {
        steps.push({
          type: 'skip_edge', targets: [current],
          message: `${current} 已在队列中, 跳过`,
          order: order.slice(), queue: queue.slice(head),
          levels: JSON.parse(JSON.stringify(levels)),
        });
      }
    }

    steps.push({
      type: 'finish', targets: [],
      message: `✅ BFS 完成! 访问顺序: [${order.join(', ')}]`,
      order, queue: [], levels,
    });
    return steps;
  },

  renderStep(renderer: VizRenderer, step: BFSStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.start.value,
          borderColor: darken(colors.start.value),
          borderWidth: 4, width: 52, height: 52,
        }, mode, speed);
        break;

      case 'dequeue':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.active.value,
          borderColor: darken(colors.active.value),
          borderWidth: 3, width: 49, height: 49,
        }, mode, speed);
        break;

      case 'visit_node':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.visited.value,
          borderColor: darken(colors.visited.value),
          borderWidth: 2, width: 46, height: 46,
        }, mode, speed);
        break;

      case 'visit_edge': {
        const src = step.targets[0], tgt = step.targets[1];
        renderer.setEdge(src, tgt, {
          lineColor: colors.edgeActive.value,
          width: 4,
        }, mode, false, speed);
        renderer.setNode(tgt, {
          backgroundColor: '#FBBF24',
          borderColor: '#F59E0B',
          borderWidth: 3,
        }, mode, Math.max(100, speed * 0.5));
        break;
      }

      case 'skip_edge': {
        const s2 = step.targets[0], t2 = step.targets[1];
        renderer.setEdge(s2, t2, {
          lineColor: '#94A3B8', width: 1.5, opacity: 0.45, lineStyle: 'dashed',
        }, mode, false);
        break;
      }

      case 'finish':
        renderer.setNodesByFn((id: string) => {
          if (id === step.targets[0]) return { backgroundColor: colors.start.value };
          return { backgroundColor: colors.visited.value };
        }, mode);
        break;
    }
  },

  getUIData(step: BFSStep | null, state: { isFinished: boolean; currentIdx: number }): UIData {
    return {
      'current-node': (state.isFinished || state.currentIdx < 0)
        ? '—'
        : (step?.targets?.length ? String(step.targets[0]) : '—'),
      'order': step && step.order ? '[' + step.order.join(', ') + ']' : '[ ]',
      'queue': step && step.queue ? '[' + step.queue.join(',') + ']' : '[ ]',
      'levels': step && step.levels ? _formatLevels(step.levels) : '-',
    };
  },
};

function _formatLevels(levels: Record<string, number>): string {
  if (!levels) return '-';
  const groups: Record<number, string[]> = {};
  for (const k in levels) {
    if (!groups[levels[k]]) groups[levels[k]] = [];
    groups[levels[k]].push(k);
  }
  return Object.keys(groups)
    .map(Number).sort((a, b) => a - b)
    .map(l => `L${l}:[${groups[l].join(',')}]`)
    .join(' ') || '-';
}

export default BFS;
