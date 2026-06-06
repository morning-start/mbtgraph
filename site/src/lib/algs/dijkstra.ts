import { createAlgo, snapshot, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'start' },
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
  { domain: 'node', key: 'relaxed' },
  { domain: 'edge', key: 'active' },
];

export interface DijkstraStep {
  type: 'init' | 'select' | 'relax' | 'finish';
  targets: string[];
  message: string;
  dist: Record<string, number>;
  parent: Record<string, string | null>;
  visited: Record<string, boolean>;
  current: string | null;
  edge?: [string, string];
  relaxed?: boolean;
}

const Dijkstra = createAlgo<DijkstraStep>({
  legendKeys,
  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights: Record<string, number>,
    startId: string
  ): DijkstraStep[] {
    const steps: DijkstraStep[] = [];
    const dist: Record<string, number> = {};
    const parent: Record<string, string | null> = {};
    const visited: Record<string, boolean> = {};

    nodes.forEach((n) => {
      dist[n.data.id] = n.data.id === startId ? 0 : Infinity;
      parent[n.data.id] = null;
      visited[n.data.id] = false;
    });

    steps.push({
      type: 'init',
      targets: [startId],
      message: `初始化: dist[${startId}]=0, 其他=∞`,
      dist: snapshot(dist),
      parent: snapshot(parent),
      visited: snapshot(visited),
      current: startId,
    });

    while (true) {
      let minDist = Infinity;
      let u: string | null = null;
      for (const nid in dist) {
        if (!visited[nid] && dist[nid] < minDist) {
          minDist = dist[nid];
          u = nid;
        }
      }

      if (u === null) break;

      visited[u] = true;

      steps.push({
        type: 'select',
        targets: [u],
        message: `选择最小距离节点: ${u} (dist=${dist[u] === Infinity ? '∞' : dist[u]})`,
        dist: snapshot(dist),
        parent: snapshot(parent),
        visited: snapshot(visited),
        current: u,
      });

      const neighbors = adjList[u] || [];
      for (let ni = 0; ni < neighbors.length; ni++) {
        const v = neighbors[ni];
        if (visited[v]) continue;

        const w = edgeWeights[u + '-' + v];
        if (w === undefined) continue;

        const newDist = dist[u] + w;
        const isRelaxed = newDist < dist[v];

        steps.push({
          type: 'relax',
          targets: [u, v],
          message: `检查边 ${u}→${v} (w=${w}): dist[${v}]=${dist[v] === Infinity ? '∞' : dist[v]} → ${newDist === Infinity ? '∞' : newDist}${isRelaxed ? ' ✓ 更新!' : ' 保持'}`,
          dist: snapshot(dist),
          parent: snapshot(parent),
          visited: snapshot(visited),
          current: u,
          edge: [u, v],
          relaxed: isRelaxed,
        });

        if (isRelaxed) {
          dist[v] = newDist;
          parent[v] = u;
        }
      }
    }

    const reachable = Object.keys(dist).filter(n => dist[n] < Infinity);
    steps.push({
      type: 'finish',
      targets: [],
      message: `✅ Dijkstra 完成! 可达节点: ${reachable.length}/${nodes.length}`,
      dist: snapshot(dist),
      parent: snapshot(parent),
      visited: snapshot(visited),
      current: null,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: DijkstraStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.start.value,
          borderColor: darken(colors.start.value),
          borderWidth: 4,
          width: 52,
          height: 52,
        }, mode, speed);
        break;

      case 'select':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors['node_active'].value,
          borderColor: darken(colors['node_active'].value),
          borderWidth: 3,
          width: 49,
          height: 49,
        }, mode, speed);
        break;

      case 'relax': {
        const src = step.targets[0];
        const tgt = step.targets[1];

        if (step.relaxed) {
          renderer.setEdge(src, tgt, {
            lineColor: colors['edge_active'].value,
            width: 4,
          }, mode);
          renderer.setNode(tgt, {
            backgroundColor: colors.relaxed.value,
            borderColor: darken(colors.relaxed.value),
            borderWidth: 3,
          }, mode, Math.max(100, speed * 0.5));
        } else {
          renderer.setEdge(src, tgt, {
            lineColor: '#94A3B8',
            width: 1.5,
            opacity: 0.45,
            lineStyle: 'dashed',
          }, mode);
        }
        break;
      }

      case 'finish':
        renderer.setNodesByFn((id: string) => {
          if (id === '0') return { backgroundColor: colors.start.value };
          if (step.visited[id]) return { backgroundColor: colors.visited.value };
          return { backgroundColor: colors.default.value };
        }, mode);
        break;
    }
  },

  getUIData(step: DijkstraStep | null, state: UIState): Record<string, string> {
    return {
      'current-node': (!step || state.isFinished || state.currentIdx < 0)
        ? ((step && step.current !== null) ? String(step.current) : '—')
        : (step?.current !== null ? String(step.current) : '—'),
      'dist-table': step ? formatDistTable(step.dist) : '-',
      'visited-nodes': step ? formatVisited(step.visited) : '-',
    };
  },
});

function formatDistTable(dist: Record<string, number>): string {
  const parts: string[] = [];
  for (const nid in dist) {
    const d = dist[nid];
    parts.push(`${nid}:${d === Infinity ? '∞' : d}`);
  }
  return '[' + parts.join(', ') + ']';
}

function formatVisited(visited: Record<string, boolean>): string {
  const list: string[] = [];
  for (const nid in visited) {
    if (visited[nid]) list.push(nid);
  }
  return list.length > 0 ? '[' + list.join(',') + ']' : '[ ]';
}

export default Dijkstra;
