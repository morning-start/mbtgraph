/**
 * topo.ts — Kahn 拓扑排序算法可视化（ES Module）
 */

import VizRenderer from '../viz-renderer';
import type { RenderMode } from '../viz-renderer';
import type { ColorMap, LegendSelector } from '../color-registry';
import { darken } from '../color-registry';

// ── 图例声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'ready' },
  { domain: 'node', key: 'sorted' },
  { domain: 'edge', key: 'active' },
];

// ── 类型定义 ──

export interface TopoStep {
  type: 'init' | 'enqueue_ready' | 'dequeue' | 'decrement' | 'ready' | 'finish';
  targets: string[];
  message: string;
  inDegree: Record<string, number>;
  queue: string[];
  result: string[];
  ready: string[];
}

export interface UIData {
  [elementId: string]: string;
}

function _clone(o: Record<string, number>): Record<string, number> {
  const c: Record<string, number> = {};
  for (const k in o) c[k] = o[k];
  return c;
}

function formatInDeg(d: Record<string, number>): string {
  if (!d) return '-';
  const p: string[] = [];
  for (const k in d) p.push(`${k}:${d[k]}`);
  p.sort();
  return p.join(', ');
}

// ── 算法实现 ──

const Topo = {
  legendKeys,
  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    _edgeWeights?: Record<string, number>,
    _startNode?: string,
  ): TopoStep[] {
    const steps: TopoStep[] = [];
    const queue: string[] = [];
    const result: string[] = [];

    const inDegree: Record<string, number> = {};
    nodes.forEach((n) => { inDegree[n.data.id] = 0; });

    for (const src in adjList) {
      const neighbors = adjList[src] || [];
      for (let i = 0; i < neighbors.length; i++) inDegree[neighbors[i]]++;
    }

    const currentInDegree: Record<string, number> = {};
    for (const nid in inDegree) currentInDegree[nid] = inDegree[nid];

    const zeroInDegree: string[] = [];
    for (const zid in currentInDegree) if (currentInDegree[zid] === 0) zeroInDegree.push(zid);
    zeroInDegree.sort();

    steps.push({
      type: 'init', targets: [], message: '计算入度完成',
      inDegree: _clone(currentInDegree), queue: [], result: [], ready: zeroInDegree.slice(),
    });

    for (let qi = 0; qi < zeroInDegree.length; qi++) queue.push(zeroInDegree[qi]);

    steps.push({
      type: 'enqueue_ready', targets: queue.slice(),
      message: `入度为0的节点入队: [${queue.join(', ')}]`,
      inDegree: _clone(currentInDegree), queue: queue.slice(), result: result.slice(), ready: [],
    });

    while (queue.length > 0) {
      const node = queue.shift()!;
      result.push(node);

      steps.push({
        type: 'dequeue', targets: [node],
        message: `出队: 节点 ${node} 加入拓扑序`,
        inDegree: _clone(currentInDegree), queue: queue.slice(), result: result.slice(), ready: [],
      });

      const neighbors = adjList[node] || [];
      for (let ni = 0; ni < neighbors.length; ni++) {
        const nbr = neighbors[ni];
        const oldDegree = currentInDegree[nbr];
        currentInDegree[nbr]--;

        steps.push({
          type: 'decrement', targets: [node, nbr],
          message: `边 ${node}→${nbr}: 入度(${nbr}) ${oldDegree}→${currentInDegree[nbr]}`,
          inDegree: _clone(currentInDegree), queue: queue.slice(), result: result.slice(), ready: [],
        });

        if (currentInDegree[nbr] === 0) {
          queue.push(nbr);
          queue.sort();
          steps.push({
            type: 'ready', targets: [nbr],
            message: `节点 ${nbr} 入度变为0，入队!`,
            inDegree: _clone(currentInDegree), queue: queue.slice(), result: result.slice(), ready: [],
          });
        }
      }
    }

    const visitedCount = result.length;
    const hasCycle = visitedCount < nodes.length;
    steps.push({
      type: 'finish', targets: [],
      message: hasCycle ? `有环! 无法完成拓扑排序 (${visitedCount}/${nodes.length})` : `拓扑排序完成: [${result.join(' → ')}]`,
      inDegree: _clone(currentInDegree), queue: [], result: result.slice(), ready: [],
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: TopoStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init':
        for (let i = 0; i < step.ready.length; i++) {
          renderer.setNode(step.ready[i], {
            backgroundColor: colors.default.value,
            borderColor: colors.ready.value,
            borderWidth: 3,
          }, mode, speed);
        }
        break;

      case 'enqueue_ready':
        for (let i = 0; i < step.targets.length; i++) {
          renderer.setNode(step.targets[i], {
            backgroundColor: colors.default.value,
            borderColor: colors.ready.value,
            borderWidth: 3,
          }, mode, speed);
        }
        break;

      case 'dequeue':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.active.value,
          borderColor: darken(colors.active.value),
          borderWidth: 3, width: 49, height: 49,
        }, mode, speed);
        break;

      case 'decrement': {
        const ds = step.targets[0], dt = step.targets[1];
        renderer.setEdge(ds, dt, {
          lineColor: colors.edgeActive.value, width: 4,
        }, mode, true, speed);
        if (step.inDegree[dt] === 0) {
          renderer.setNode(dt, {
            backgroundColor: colors.default.value,
            borderColor: colors.ready.value,
            borderWidth: 3,
          }, mode, speed);
        }
        break;
      }

      case 'ready':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.default.value,
          borderColor: colors.ready.value,
          borderWidth: 3,
        }, mode, speed);
        break;

      case 'finish':
        renderer.setNodesByFn(() => ({
          backgroundColor: colors.sorted.value,
          borderColor: darken(colors.sorted.value),
          borderWidth: 2,
        }), mode);
        break;
    }
  },

  getUIData(step: TopoStep | null, state: { isFinished: boolean; currentIdx: number }): UIData {
    const hasResult = !!(step && step.result?.length);
    const resultStr = hasResult
      ? (state.isFinished ? '[' + step!.result!.join(' → ') + ']' : '[' + step!.result!.join(',') + ']')
      : '[ ]';
    return {
      'current-node': '—',
      'ready': step && step.ready?.length ? '[' + step.ready.join(',') + ']' : '[ ]',
      'result': resultStr,
      'in-degree': step ? formatInDeg(step.inDegree) : '-',
    };
  },
};

export default Topo;
