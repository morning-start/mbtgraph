/**
 * dinic.ts — Dinic 最大流可视化算法模块
 *
 * BFS 分层 + DFS 阻塞流，展示层级图和增广过程。
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

export interface DinicStep {
  type: 'init' | 'bfs_level' | 'dfs_augment' | 'blocked' | 'finish';
  targets: string[];
  message: string;
  flow: Record<string, number>;
  capacity: Record<string, number>;
  level: Record<string, number>;
  maxFlow: number;
  augmented?: string[];
  bottleneck?: number;
}

function ek(u: string, v: string): string { return u + '→' + v; }

const Dinic = createAlgo<DinicStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights: Record<string, number>,
  ): DinicStep[] {
    const steps: DinicStep[] = [];
    const flow: Record<string, number> = {};
    const capacity: Record<string, number> = {};

    for (const nid of nodes.map(n => n.data.id)) {
      for (const nbr of adjList[nid] || []) {
        const k = ek(nid, nbr);
        capacity[k] = edgeWeights[k] ?? 1;
        flow[k] = 0;
        const rk = ek(nbr, nid);
        if (!(rk in capacity)) capacity[rk] = 0;
        if (!(rk in flow)) flow[rk] = 0;
      }
    }

    const source = '0', sink = String(nodes.length - 1);
    let maxFlow = 0;

    steps.push({
      type: 'init', targets: [source, sink],
      message: `Dinic: 源点=${source}, 汇点=${sink}`,
      flow: snapshot(flow), capacity: snapshot(capacity),
      level: {}, maxFlow: 0,
    });

    while (true) {
      // BFS 分层
      const level: Record<string, number> = {};
      for (const n of nodes) level[n.data.id] = -1;
      const q: string[] = [source];
      level[source] = 0;

      while (q.length > 0) {
        const u = q.shift()!;
        for (const v of adjList[u] || []) {
          if (level[v] === -1 && capacity[ek(u, v)] - flow[ek(u, v)] > 0) {
            level[v] = level[u] + 1;
            q.push(v);
            steps.push({
              type: 'bfs_level', targets: [u, v],
              message: `层级: ${v} 在 L${level[v]}`,
              flow: snapshot(flow), capacity: snapshot(capacity),
              level: snapshot(level), maxFlow,
            });
          }
        }
      }

      if (level[sink] === -1) {
        steps.push({
          type: 'finish', targets: [],
          message: `✅ 最大流 = ${maxFlow} (汇点不可达)`,
          flow: snapshot(flow), capacity: snapshot(capacity),
          level: snapshot(level), maxFlow,
        });
        break;
      }

      // DFS 阻塞流
      const dfsStack: string[] = [source];
      const visited = new Set<string>();

      while (dfsStack.length > 0) {
        const u = dfsStack[dfsStack.length - 1];
        if (u === sink) {
          // 找到增广路径
          const path = [...dfsStack];
          let bn = Infinity;
          for (let i = 0; i < path.length - 1; i++) {
            bn = Math.min(bn, capacity[ek(path[i], path[i + 1])] - flow[ek(path[i], path[i + 1])]);
          }
          for (let i = 0; i < path.length - 1; i++) {
            flow[ek(path[i], path[i + 1])] += bn;
            flow[ek(path[i + 1], path[i])] -= bn;
          }
          maxFlow += bn;

          steps.push({
            type: 'dfs_augment', targets: path,
            message: `阻塞流: ${path.join('→')}, +${bn}`,
            flow: snapshot(flow), capacity: snapshot(capacity),
            level: snapshot(level), maxFlow,
            augmented: path, bottleneck: bn,
          });
          // 清空栈重新开始
          dfsStack.length = 0;
          dfsStack.push(source);
          visited.clear();
          continue;
        }

        let found = false;
        for (const v of adjList[u] || []) {
          if (level[v] === level[u] + 1 && !visited.has(v) && capacity[ek(u, v)] - flow[ek(u, v)] > 0) {
            visited.add(v);
            dfsStack.push(v);
            found = true;
            break;
          }
        }
        if (!found) {
          dfsStack.pop();
          if (dfsStack.length === 0) {
            // 阻塞流阶段完成
            break;
          }
        }
      }
    }

    return steps;
  },

  renderStep(renderer: VizRenderer, step: DinicStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    // 源点/汇点
    renderer.setNode('0', { backgroundColor: colors.start.value, borderWidth: 3 }, mode, 50);
    const last = String(Math.max(...Object.keys(step.capacity).flatMap(k => k.split('→').map(Number))));
    renderer.setNode(last, { backgroundColor: '#F59E0B', borderWidth: 3 }, mode, 50);

    // 流量边
    for (const k in step.capacity) {
      if (step.capacity[k] > 0) {
        const [u, v] = k.split('→');
        const f = step.flow[k] || 0;
        const cap = step.capacity[k];
        renderer.setEdge(u, v, {
          lineColor: f > 0 ? '#22C55E' : '#6B7280',
          width: 2 + (f / cap) * 3,
          opacity: 0.5 + (f / cap) * 0.5,
        }, mode, true, 50);
      }
    }

    // 层级标签
    for (const nid in step.level) {
      if (step.level[nid] >= 0 && nid !== '0' && nid !== last) {
        renderer.setNode(nid, {
          backgroundColor: step.level[nid] > 0 ? '#8B5CF6' : colors.visited.value,
          borderWidth: 2,
        }, mode, 50);
      }
    }

    switch (step.type) {
      case 'bfs_level':
        renderer.setEdge(step.targets[0], step.targets[1], {
          lineColor: colors['edge_active'].value, width: 4,
        }, mode, true, speed);
        break;
      case 'dfs_augment':
        if (step.augmented) {
          for (let i = 0; i < step.augmented.length - 1; i++) {
            renderer.setEdge(step.augmented[i], step.augmented[i + 1], {
              lineColor: '#22C55E', width: 5,
            }, mode, true, speed);
          }
        }
        break;
    }
  },

  getUIData(step: DinicStep | null, state: UIState): Record<string, string> {
    if (!step) return { 'level': '-', 'max-flow': '0', 'edges': '-' };
    const lvls = Object.entries(step.level).filter(([_, v]) => v >= 0).map(([k, v]) => `${k}:L${v}`).join(', ');
    return {
      'level': lvls || '-',
      'max-flow': String(step.maxFlow),
      'edges': Object.entries(step.capacity).filter(([_, c]) => c > 0)
        .map(([k, c]) => `${k}:${step.flow[k] || 0}/${c}`).join(', '),
    };
  },
});

export default Dinic;
