/**
 * cycle.ts — 环检测算法可视化（ES Module）
 *
 * 基于 DFS 的有向图环检测
 */

import type { VizRenderer, RenderMode } from '../viz-renderer';
import type { ColorMap, LegendSelector } from '../color-registry';

// ── 图例声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
  { domain: 'node', key: 'cycle' },
  { domain: 'edge', key: 'active' },
];

// ── 类型定义 ──

export interface CycleStep {
  type: 'init' | 'visit_start' | 'explore_edge' | 'cycle_found' | 'backtrack' | 'finish';
  targets: string[];
  message: string;
  status: Record<string, string>;
  stack: string[];
  order: string[];
  cycle: string[] | null;
}

export interface UIData {
  [elementId: string]: string;
}

function darken(hex: string): string {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `#${Math.round(r * 0.75).toString(16).padStart(2, '0')}${Math.round(g * 0.75).toString(16).padStart(2, '0')}${Math.round(b * 0.75).toString(16).padStart(2, '0')}`;
}

// ── 算法实现 ──

const Cycle = {
  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>
  ): CycleStep[] {
    const steps: CycleStep[] = [];
    const status: Record<string, string> = {};
    const onStack: Record<string, boolean> = {};
    const stack: string[] = [];
    const order: string[] = [];
    let cycleFound: string[] | null = null;

    nodes.forEach((n) => { status[n.data.id] = 'unvisited'; });

    steps.push({
      type: 'init', targets: [], message: '开始环检测 (DFS-based)',
      status: JSON.parse(JSON.stringify(status)), stack: [], order: [], cycle: null,
    });

    function dfs(nodeId: string): void {
      if (cycleFound) return;

      status[nodeId] = 'visiting';
      onStack[nodeId] = true;
      stack.push(nodeId);
      order.push(nodeId);

      steps.push({
        type: 'visit_start', targets: [nodeId],
        message: `进入节点 ${nodeId}`,
        status: JSON.parse(JSON.stringify(status)), stack: stack.slice(), order: order.slice(), cycle: null,
      });

      const neighbors = adjList[nodeId] || [];
      for (let ni = 0; ni < neighbors.length; ni++) {
        const nbr = neighbors[ni];
        if (cycleFound) return;

        if (status[nbr] === 'unvisited') {
          steps.push({
            type: 'explore_edge', targets: [nodeId, nbr],
            message: `探索边 ${nodeId} → ${nbr}`,
            status: JSON.parse(JSON.stringify(status)), stack: stack.slice(), order: order.slice(), cycle: null,
          });
          dfs(nbr);
          if (cycleFound) return;
        } else if (onStack[nbr]) {
          const cycleStart = stack.indexOf(nbr);
          cycleFound = stack.slice(cycleStart).concat([nbr]);

          steps.push({
            type: 'cycle_found', targets: [nodeId, nbr],
            message: `发现环! ${cycleFound.join(' → ')} → ${nbr}`,
            status: JSON.parse(JSON.stringify(status)), stack: stack.slice(), order: order.slice(), cycle: cycleFound,
          });
          return;
        }
      }

      status[nodeId] = 'visited';
      delete onStack[nodeId];
      stack.pop();

      steps.push({
        type: 'backtrack', targets: [nodeId],
        message: `回溯节点 ${nodeId}`,
        status: JSON.parse(JSON.stringify(status)), stack: stack.slice(), order: order.slice(), cycle: null,
      });
    }

    for (let ni = 0; ni < nodes.length; ni++) {
      const nid = nodes[ni].data.id;
      if (status[nid] === 'unvisited') {
        dfs(nid);
        if (cycleFound) break;
      }
    }

    if (!cycleFound) {
      steps.push({
        type: 'finish', targets: [], message: '无环！图是 DAG',
        status: JSON.parse(JSON.stringify(status)), stack: [], order: order, cycle: null,
      });
    }

    return steps;
  },

  renderStep(renderer: VizRenderer, step: CycleStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init':
        break;

      case 'visit_start':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.active.value,
          borderColor: darken(colors.active.value),
          borderWidth: 3, width: 49, height: 49,
        }, mode, speed);
        break;

      case 'explore_edge': {
        const src = step.targets[0], tgt = step.targets[1];
        renderer.setEdge(src, tgt, {
          lineColor: colors.edgeActive.value, width: 4,
        }, mode, true, speed);
        break;
      }

      case 'cycle_found': {
        const csrc = step.targets[0], ctgt = step.targets[1];
        renderer.setEdge(csrc, ctgt, {
          lineColor: colors.edgeActive.value, width: 5,
        }, mode, true, speed);
        if (step.cycle) {
          for (let ci = 0; ci < step.cycle.length; ci++) {
            renderer.setNode(step.cycle[ci], {
              backgroundColor: colors.cycle.value,
              borderColor: darken(colors.cycle.value),
              borderWidth: 4,
            }, mode, speed);
          }
        }
        break;
      }

      case 'backtrack':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.visited.value,
          borderColor: darken(colors.visited.value),
          borderWidth: 2, width: 46, height: 46,
        }, mode, speed);
        break;

      case 'finish':
        renderer.setNodesByFn(() => ({ backgroundColor: colors.visited.value }), mode);
        break;
    }
  },

  getUIData(step: CycleStep | null, state: { isFinished: boolean; currentIdx: number }): UIDData {
    const hasCycle = !!(step && step.cycle);
    return {
      'current-node': (state.isFinished || state.currentIdx < 0)
        ? '—'
        : (step?.targets?.length ? String(step.targets[0]) : '—'),
      'stack': step && step.stack ? '[' + step.stack.join(',') + ']' : '[ ]',
      'cycle': hasCycle
        ? (step!.cycle!).join(' → ')
        : (state.isFinished ? '无环' : '-'),
    };
  },
};

type UIData = Record<string, string>;

export default Cycle;
