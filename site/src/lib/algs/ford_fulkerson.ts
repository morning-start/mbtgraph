/**
 * ford_fulkerson.ts — Ford-Fulkerson 最大流可视化算法模块
 *
 * 展示增广路径搜索、残差网络更新和流量推送过程。
 */

import { createAlgo, snapshot, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'start' },
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
  { domain: 'edge', key: 'active' },
  { domain: 'edge', key: 'tree' },
  { domain: 'edge', key: 'rejected' },
];

export interface FFStep {
  type: 'init' | 'bfs_start' | 'bfs_edge' | 'augment' | 'finish';
  targets: string[];
  message: string;
  flow: Record<string, number>;
  capacity: Record<string, number>;
  parent: Record<string, string | null>;
  maxFlow: number;
  augmented?: string[];
  bottleneck?: number;
}

function edgeKey(u: string, v: string): string { return u + '→' + v; }

const FordFulkerson = createAlgo<FFStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights: Record<string, number>,
  ): FFStep[] {
    const steps: FFStep[] = [];
    const flow: Record<string, number> = {};
    const capacity: Record<string, number> = {};

    for (const nid of nodes.map(n => n.data.id)) {
      for (const nbr of adjList[nid] || []) {
        const k = edgeKey(nid, nbr);
        capacity[k] = edgeWeights[k] ?? 1;
        flow[k] = 0;
        // 反向边
        const rk = edgeKey(nbr, nid);
        if (!(rk in capacity)) capacity[rk] = 0;
        if (!(rk in flow)) flow[rk] = 0;
      }
    }

    const source = '0', sink = String(nodes.length - 1);
    let maxFlow = 0;

    steps.push({
      type: 'init', targets: [source, sink],
      message: `初始化: 源点=${source}, 汇点=${sink}`,
      flow: snapshot(flow), capacity: snapshot(capacity),
      parent: {}, maxFlow: 0,
    });

    while (true) {
      const parent: Record<string, string | null> = {};
      for (const n of nodes) parent[n.data.id] = null;
      const visited = new Set<string>();
      const queue: string[] = [source];
      visited.add(source);

      steps.push({
        type: 'bfs_start', targets: [],
        message: `搜索增广路径 (当前最大流=${maxFlow})`,
        flow: snapshot(flow), capacity: snapshot(capacity),
        parent: snapshot(parent), maxFlow,
      });

      let found = false;
      while (queue.length > 0 && !found) {
        const u = queue.shift()!;
        for (const v of adjList[u] || []) {
          const k = edgeKey(u, v);
          const residual = capacity[k] - flow[k];
          if (!visited.has(v) && residual > 0) {
            visited.add(v);
            parent[v] = u;
            queue.push(v);
            steps.push({
              type: 'bfs_edge', targets: [u, v],
              message: `检查边 ${u}→${v}: 残量=${residual}/${capacity[k]}`,
              flow: snapshot(flow), capacity: snapshot(capacity),
              parent: snapshot(parent), maxFlow,
            });
            if (v === sink) { found = true; break; }
          }
        }
      }

      if (!found) break;

      // 计算瓶颈
      let bottleneck = Infinity;
      const augPath: string[] = [sink];
      let cur: string | null = sink;
      while (parent[cur] !== null) {
        augPath.unshift(parent[cur]!);
        cur = parent[cur];
      }
      for (let i = 0; i < augPath.length - 1; i++) {
        const k = edgeKey(augPath[i], augPath[i + 1]);
        bottleneck = Math.min(bottleneck, capacity[k] - flow[k]);
      }

      // 推送流量
      for (let i = 0; i < augPath.length - 1; i++) {
        const k = edgeKey(augPath[i], augPath[i + 1]);
        flow[k] += bottleneck;
        const rk = edgeKey(augPath[i + 1], augPath[i]);
        flow[rk] -= bottleneck;
      }
      maxFlow += bottleneck;

      steps.push({
        type: 'augment', targets: augPath,
        message: `✅ 增广路径: ${augPath.join('→')}, 推送 ${bottleneck} 单位`,
        flow: snapshot(flow), capacity: snapshot(capacity),
        parent: { ...parent },
        maxFlow, augmented: augPath, bottleneck,
      });
    }

    steps.push({
      type: 'finish', targets: [],
      message: `✅ 最大流 = ${maxFlow}`,
      flow: snapshot(flow), capacity: snapshot(capacity),
      parent: {}, maxFlow,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: FFStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    // 渲染所有边的流量状态
    for (const k in step.capacity) {
      const [u, v] = k.split('→');
      const f = step.flow[k] || 0;
      const cap = step.capacity[k];
      if (cap > 0) {
        renderer.setEdge(u, v, {
          lineColor: f > 0 ? colors['edge_tree'].value : '#6B7280',
          width: 2 + (f / cap) * 3,
          opacity: 0.6 + (f / cap) * 0.4,
        }, mode, true, 50);
      }
    }

    // 标记源点和汇点
    renderer.setNode('0', {
      backgroundColor: colors.start.value,
      borderColor: darken(colors.start.value), borderWidth: 3,
    }, mode, 50);
    const lastId = String(Object.keys(step.flow).length > 0
      ? Math.max(...Object.keys(step.capacity).flatMap(k => k.split('→').map(Number)))
      : 0);
    renderer.setNode(lastId, {
      backgroundColor: '#F59E0B',
      borderColor: darken('#F59E0B'), borderWidth: 3,
    }, mode, 50);

    switch (step.type) {
      case 'bfs_edge':
        renderer.setNode(step.targets[1], {
          backgroundColor: colors.ready.value,
          borderColor: darken(colors.ready.value),
          borderWidth: 3,
        }, mode, speed);
        renderer.setEdge(step.targets[0], step.targets[1], {
          lineColor: colors['edge_active'].value, width: 4,
        }, mode, true, speed);
        break;

      case 'augment':
        if (step.augmented) {
          for (let i = 0; i < step.augmented.length - 1; i++) {
            renderer.setEdge(step.augmented[i], step.augmented[i + 1], {
              lineColor: '#22C55E', width: 5,
            }, mode, true, speed);
            renderer.setNode(step.augmented[i], {
              backgroundColor: colors.active.value,
              borderColor: darken(colors.active.value), borderWidth: 3,
            }, mode, speed);
          }
          renderer.setNode(step.augmented[step.augmented.length - 1], {
            backgroundColor: '#F59E0B',
            borderColor: darken('#F59E0B'), borderWidth: 3,
          }, mode, speed);
        }
        break;

      case 'finish':
        break;
    }
  },

  getUIData(step: FFStep | null, state: UIState): Record<string, string> {
    if (!step || state.isFinished) {
      return { 'source': '0', 'sink': '-', 'max-flow': String(step?.maxFlow ?? '-'), 'edges': '-' };
    }
    const totalNodes = Object.keys(step.capacity).length;
    return {
      'source': '0',
      'sink': String(Object.keys(step.capacity).flatMap(k => k.split('→').map(Number)).reduce((a, b) => Math.max(a, b), 0)),
      'max-flow': String(step.maxFlow),
      'edges': formatFlowEdges(step.flow, step.capacity),
    };
  },
});

function formatFlowEdges(flow: Record<string, number>, cap: Record<string, number>): string {
  const parts: string[] = [];
  for (const k in cap) {
    if (cap[k] > 0) {
      const f = flow[k] || 0;
      parts.push(`${k}:${f}/${cap[k]}`);
    }
  }
  return parts.join(', ') || '-';
}

export default FordFulkerson;
