/**
 * euler.ts — 欧拉路径可视化算法模块
 *
 * Hierholzer 算法: 沿边走，遇到死胡同时回溯并记录路径。
 */

import { createAlgo, snapshot, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
  { domain: 'edge', key: 'active' },
  { domain: 'edge', key: 'tree' },
];

export interface EulerStep {
  type: 'init' | 'walk' | 'backtrack' | 'record' | 'finish';
  targets: string[];
  message: string;
  path: string[];
  edgeCount: number;
  usedEdges: string[];
  currentTrail: string[];
}

const Euler = createAlgo<EulerStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
  ): EulerStep[] {
    const steps: EulerStep[] = [];
    const startId = '0';
    const usedEdges = new Set<string>();
    const path: string[] = [];

    steps.push({
      type: 'init', targets: [startId],
      message: `开始寻找欧拉路径, 起点=${startId}`,
      path: [], edgeCount: 0, usedEdges: [], currentTrail: [startId],
    });

    const stack: string[] = [startId];
    const trail: string[] = [];

    while (stack.length > 0) {
      const u = stack[stack.length - 1];
      const neighbors = adjList[u] || [];
      let found = false;

      for (const v of neighbors) {
        const ekey = u < v ? u + '-' + v : v + '-' + u;
        if (!usedEdges.has(ekey)) {
          usedEdges.add(ekey);
          stack.push(v);
          trail.push(v);

          steps.push({
            type: 'walk', targets: [u, v],
            message: `沿边 ${u}—${v} 前进`,
            path: [...path], edgeCount: usedEdges.size,
            usedEdges: [...usedEdges],
            currentTrail: [...trail],
          });

          found = true;
          break;
        }
      }

      if (!found) {
        const popped = stack.pop()!;
        if (stack.length > 0) {
          steps.push({
            type: 'backtrack', targets: [popped],
            message: `节点 ${popped} 无未用边, 回溯`,
            path: [...path], edgeCount: usedEdges.size,
            usedEdges: [...usedEdges],
            currentTrail: [...trail],
          });
        }
        trail.splice(trail.indexOf(popped), 1);
        path.push(popped);

        steps.push({
          type: 'record', targets: [popped],
          message: `记录节点 ${popped} 到路径`,
          path: [...path], edgeCount: usedEdges.size,
          usedEdges: [...usedEdges],
          currentTrail: [...trail],
        });
      }
    }

    steps.push({
      type: 'finish', targets: path,
      message: `✅ 欧拉路径: ${path.join(' → ')}`,
      path, edgeCount: usedEdges.size,
      usedEdges: [...usedEdges],
      currentTrail: [],
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: EulerStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    // 标记已用边
    for (const ekey of step.usedEdges) {
      const [s, t] = ekey.split('-');
      renderer.setEdge(s, t, {
        lineColor: colors['edge_tree'].value, width: 4,
      }, mode, false, 50);
    }

    switch (step.type) {
      case 'init':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.visited.value,
          borderColor: darken(colors.visited.value),
          borderWidth: 4, width: 52, height: 52,
        }, mode, speed);
        break;

      case 'walk':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.visited.value,
          borderColor: darken(colors.visited.value),
          borderWidth: 3,
        }, mode, 80);
        renderer.setNode(step.targets[1], {
          backgroundColor: colors['node_active'].value,
          borderColor: darken(colors['node_active'].value),
          borderWidth: 3, width: 49, height: 49,
        }, mode, speed);
        renderer.setEdge(step.targets[0], step.targets[1], {
          lineColor: colors['edge_active'].value, width: 5,
        }, mode, false, speed);
        break;

      case 'backtrack':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.visited.value,
          borderColor: '#FBBF24', borderWidth: 3,
        }, mode, speed);
        break;

      case 'record':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.visited.value,
          borderColor: darken(colors.visited.value),
          borderWidth: 2,
        }, mode, speed);
        break;

      case 'finish':
        for (let i = 0; i < step.path.length; i++) {
          renderer.setNode(step.path[i], {
            backgroundColor: i === 0 ? colors.visited.value : colors.visited.value,
            borderColor: '#FBBF24', borderWidth: 3,
          }, mode, 100);
          if (i > 0) {
            renderer.setEdge(step.path[i - 1], step.path[i], {
              lineColor: colors['edge_tree'].value, width: 5,
            }, mode, false, 100);
          }
        }
        break;
    }
  },

  getUIData(step: EulerStep | null, state: UIState): Record<string, string> {
    if (!step) {
      return { 'current-node': '—', 'path': '-', 'used-edges': '0', 'edge-count': '-' };
    }
    return {
      'current-node': step.targets[0] || '—',
      'path': step.path.length > 0 ? step.path.join(' → ') : '-',
      'used-edges': String(step.edgeCount),
      'edge-count': '总边待定',
    };
  },
});

export default Euler;
