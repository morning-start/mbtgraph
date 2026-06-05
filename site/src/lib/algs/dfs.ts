/**
 * dfs.ts — DFS 深度优先搜索可视化（ES Module）
 */

import VizRenderer from '../viz-renderer';
import type { RenderMode } from '../viz-renderer';
import type { ColorMap, LegendSelector } from '../color-registry';
import { darken } from '../color-registry';
import type { UIState } from '../viz-engine';

// ── 图例声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'start' },
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
  { domain: 'edge', key: 'tree' },
  { domain: 'edge', key: 'back' },
];

// ── 类型定义 ──

export interface DFSStep {
  type: 'init' | 'push' | 'pop' | 'visit_edge' | 'skip_edge' | 'finish';
  targets: string[];
  message: string;
  stack: string[];
  depth: number;
  order: string[];
}

const DFS = {
  legendKeys,
  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    _edgeWeights?: Record<string, number>,
    startNode?: string,
  ): DFSStep[] {
    const startId = startNode ?? '0';
    const steps: DFSStep[] = [];
    const visited: Record<string, boolean> = {};
    const stack: string[] = [startId];
    const order: string[] = [];

    steps.push({
      type: 'init', targets: [startId],
      message: `初始化: 起点 ${startId} 入栈`,
      stack: [startId], depth: 1, order: [],
    });

    while (stack.length > 0) {
      const current = stack[stack.length - 1];

      if (!visited[current]) {
        visited[current] = true;
        order.push(current);

        steps.push({
          type: 'push', targets: [current],
          message: `访问节点 ${current}`,
          stack: stack.slice(), depth: stack.length, order: order.slice(),
        });

        const neighbors = adjList[current] || [];
        let pushed = false;
        for (let ni = neighbors.length - 1; ni >= 0; ni--) {
          const nbr = neighbors[ni];
          if (!visited[nbr]) {
            stack.push(nbr);
            pushed = true;
            steps.push({
              type: 'visit_edge', targets: [current, nbr],
              message: `探索边 ${current} → ${nbr}, 入栈`,
              stack: stack.slice(), depth: stack.length, order: order.slice(),
            });
          } else {
            steps.push({
              type: 'skip_edge', targets: [current, nbr],
              message: `${nbr} 已访问, 跳过`,
              stack: stack.slice(), depth: stack.length, order: order.slice(),
            });
          }
        }

        if (!pushed) {
          stack.pop();
          steps.push({
            type: 'pop', targets: [current],
            message: `${current} 无未访问邻居, 出栈`,
            stack: stack.slice(), depth: stack.length, order: order.slice(),
          });
        }
      } else {
        stack.pop();
        steps.push({
          type: 'pop', targets: [current],
          message: `${current} 已访问过, 出栈`,
          stack: stack.slice(), depth: stack.length, order: order.slice(),
        });
      }
    }

    steps.push({
      type: 'finish', targets: [],
      message: `✅ DFS 完成! 访问顺序: [${order.join(', ')}]`,
      stack: [], depth: 0, order,
    });
    return steps;
  },

  renderStep(renderer: VizRenderer, step: DFSStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.start.value,
          borderColor: darken(colors.start.value),
          borderWidth: 4, width: 52, height: 52,
        }, mode, speed);
        break;

      case 'push':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.active.value,
          borderColor: darken(colors.active.value),
          borderWidth: 3, width: 49, height: 49,
        }, mode, speed);
        break;

      case 'pop':
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
        renderer.setNodesByFn(() => ({ backgroundColor: colors.visited.value }), mode);
        break;
    }
  },

  getUIData(step: DFSStep | null, state: UIState): Record<string, string> {
    return {
      'current-node': (state.isFinished || state.currentIdx < 0)
        ? '—'
        : (step?.targets?.length ? String(step.targets[0]) : '—'),
      'order': step && step.order ? '[' + step.order.join(', ') + ']' : '[ ]',
      'stack': step && step.stack ? '[' + step.stack.join(',') + ']' : '[ ]',
      'depth': step && step.depth != null ? String(step.depth) : '-',
    };
  },
};

export default DFS;
