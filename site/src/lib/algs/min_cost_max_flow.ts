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

export interface MCMFStep {
  type: 'init' | 'spfa_start' | 'spfa_edge' | 'augment' | 'finish';
  targets: string[];
  message: string;
  flow: Record<string, number>;
  capacity: Record<string, number>;
  cost: Record<string, number>;
  parent: Record<string, string | null>;
  maxFlow: number;
  totalCost: number;
  augmented?: string[];
  bottleneck?: number;
}

function edgeKey(u: string, v: string): string { return u + '→' + v; }

const MCMF = createAlgo<MCMFStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights: Record<string, number>,
  ): MCMFStep[] {
    const steps: MCMFStep[] = [];
    const flow: Record<string, number> = {};
    const capacity: Record<string, number> = {};
    const cost: Record<string, number> = {};

    // 每条边的容量和费用从权重中编码: 整数部分=容量, 小数部分×100=费用
    for (const nid of nodes.map(n => n.data.id)) {
      for (const nbr of adjList[nid] || []) {
        const k = edgeKey(nid, nbr);
        const w = edgeWeights[k] ?? 10;
        capacity[k] = Math.floor(w);
        cost[k] = Math.round((w - Math.floor(w)) * 100) / 100 || 1;
        flow[k] = 0;
        const rk = edgeKey(nbr, nid);
        if (!(rk in capacity)) { capacity[rk] = 0; cost[rk] = -cost[k]; flow[rk] = 0; }
      }
    }

    const source = '0', sink = String(nodes.length - 1);
    let maxFlow = 0, totalCost = 0;

    steps.push({
      type: 'init', targets: [source, sink],
      message: `初始化: 最小费用最大流, 源点=${source}, 汇点=${sink}`,
      flow: snapshot(flow), capacity: snapshot(capacity),
      cost: snapshot(cost), parent: {}, maxFlow: 0, totalCost: 0,
    });

    while (true) {
      // SPFA (Bellman-Ford) 找最短路
      const dist: Record<string, number> = {};
      const parent: Record<string, string | null> = {};
      const inQueue: Record<string, boolean> = {};
      for (const n of nodes) { dist[n.data.id] = Infinity; parent[n.data.id] = null; }
      dist[source] = 0;
      const queue = [source];
      inQueue[source] = true;

      while (queue.length > 0) {
        const u = queue.shift()!;
        inQueue[u] = false;
        for (const v of adjList[u] || []) {
          const k = edgeKey(u, v);
          const residual = capacity[k] - flow[k];
          if (residual > 0 && dist[u] + cost[k] < dist[v]) {
            dist[v] = dist[u] + cost[k];
            parent[v] = u;
            if (!inQueue[v]) { queue.push(v); inQueue[v] = true; }
          }
        }
      }

      if (dist[sink] === Infinity) break;

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
      let pathCost = 0;
      for (let i = 0; i < augPath.length - 1; i++) {
        const k = edgeKey(augPath[i], augPath[i + 1]);
        flow[k] += bottleneck;
        pathCost += cost[k] * bottleneck;
        const rk = edgeKey(augPath[i + 1], augPath[i]);
        flow[rk] -= bottleneck;
      }
      maxFlow += bottleneck;
      totalCost += pathCost;

      steps.push({
        type: 'augment', targets: augPath,
        message: `💰 增广: ${augPath.join('→')}, +${bottleneck} 单位, +${pathCost} 费用`,
        flow: snapshot(flow), capacity: snapshot(capacity),
        cost: snapshot(cost), parent: snapshot(parent),
        maxFlow, totalCost, augmented: augPath, bottleneck,
      });
    }

    steps.push({
      type: 'finish', targets: [],
      message: `✅ 最小费用最大流: 流量=${maxFlow}, 总费用=${totalCost}`,
      flow: snapshot(flow), capacity: snapshot(capacity),
      cost: snapshot(cost), parent: {}, maxFlow, totalCost,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: MCMFStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    for (const k in step.capacity) {
      const [u, v] = k.split('→');
      const f = step.flow[k] || 0;
      const cap = step.capacity[k];
      const c = step.cost[k] || 0;
      if (cap > 0) {
        renderer.setEdge(u, v, {
          lineColor: f > 0 ? colors['edge_tree'].value : '#6B7280',
          width: 2 + (f / cap) * 3,
          opacity: 0.6 + (f / cap) * 0.4,
          label: `${f}/${cap} ¥${c}`,
        }, mode, true, 50);
      }
    }

    renderer.setNode('0', {
      backgroundColor: colors.start.value,
      borderColor: darken(colors.start.value), borderWidth: 3,
    }, mode, 50);
    const allIds = Object.keys(step.capacity).flatMap(k => k.split('→').map(Number));
    const lastId = String(allIds.length > 0 ? Math.max(...allIds) : 0);
    renderer.setNode(lastId, {
      backgroundColor: '#F59E0B',
      borderColor: darken('#F59E0B'), borderWidth: 3,
    }, mode, 50);

    switch (step.type) {
      case 'spfa_edge':
        renderer.setNode(step.targets[1], {
          backgroundColor: colors.ready.value,
          borderColor: darken(colors.ready.value), borderWidth: 3,
        }, mode, speed);
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
        }
        break;
    }
  },

  getUIData(step: MCMFStep | null, state: UIState): Record<string, string> {
    if (!step) return { 'max-flow': '-', 'total-cost': '-', 'edges': '-' };
    return {
      'max-flow': String(step.maxFlow),
      'total-cost': String(step.totalCost),
      'edges': formatEdges(step.flow, step.capacity, step.cost),
    };
  },
});

function formatEdges(flow: Record<string, number>, cap: Record<string, number>, cost: Record<string, number>): string {
  const parts: string[] = [];
  for (const k in cap) {
    if (cap[k] > 0) parts.push(`${k}: ${flow[k]||0}/${cap[k]} ¥${cost[k]}`);
  }
  return parts.join(', ') || '-';
}

export default MCMF;
