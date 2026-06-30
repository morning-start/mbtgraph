/**
 * a_star.ts — A* Search 可视化算法模块
 *
 * 使用 f(n) = g(n) + h(n) 启发式搜索，曼哈顿距离作为启发函数。
 * 展示搜索边界扩展、open/closed 集、f/g/h 值变化。
 */

import { createAlgo, snapshot, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'start' },
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
  { domain: 'node', key: 'ready' },
  { domain: 'edge', key: 'active' },
  { domain: 'edge', key: 'tree' },
  { domain: 'edge', key: 'rejected' },
];

export interface AStarStep {
  type: 'init' | 'pop' | 'explore' | 'skip' | 'reconstruct' | 'finish';
  targets: string[];
  message: string;
  gScore: Record<string, number>;
  fScore: Record<string, number>;
  parent: Record<string, string | null>;
  open: string[];
  closed: string[];
  current: string | null;
  nextNode?: string;
  edge?: [string, string];
  newG?: number;
  path?: string[];
}

function manhattan(a: string, b: string): number {
  const ax = parseInt(a.split('_')[0] || a);
  const ay = parseInt(a.split('_')[1] || '0');
  const bx = parseInt(b.split('_')[0] || b);
  const by = parseInt(b.split('_')[1] || '0');
  return Math.abs(ax - bx) + Math.abs(ay - by);
}

const AStar = createAlgo<AStarStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights: Record<string, number>,
    startId: string
  ): AStarStep[] {
    const steps: AStarStep[] = [];
    const targetId = 'T';

    const gScore: Record<string, number> = {};
    const fScore: Record<string, number> = {};
    const parent: Record<string, string | null> = {};
    const openSet: string[] = [];
    const closedSet: string[] = [];

    nodes.forEach((n) => {
      const id = n.data.id;
      gScore[id] = id === startId ? 0 : Infinity;
      fScore[id] = id === startId ? manhattan(startId, targetId) : Infinity;
      parent[id] = null;
    });

    openSet.push(startId);

    steps.push({
      type: 'init',
      targets: [startId],
      message: `初始化A*: 起点=${startId}, 终点=${targetId}, h(曼哈顿)`,
      gScore: snapshot(gScore),
      fScore: snapshot(fScore),
      parent: snapshot(parent),
      open: [startId],
      closed: [],
      current: null,
    });

    while (openSet.length > 0) {
      let lowestIdx = 0;
      for (let i = 1; i < openSet.length; i++) {
        if (fScore[openSet[i]] < fScore[openSet[lowestIdx]]) {
          lowestIdx = i;
        }
      }
      const current = openSet[lowestIdx];

      steps.push({
        type: 'pop',
        targets: [current],
        message: `从open集取出: ${current} (f=${fScore[current] === Infinity ? '∞' : fScore[current].toFixed(1)}, g=${gScore[current].toFixed(1)}, h=${(fScore[current] - gScore[current]).toFixed(1)})`,
        gScore: snapshot(gScore),
        fScore: snapshot(fScore),
        parent: snapshot(parent),
        open: [...openSet],
        closed: [...closedSet],
        current,
      });

      if (current === targetId) {
        // 重建路径
        const path: string[] = [];
        let cur: string | null = targetId;
        while (cur !== null) {
          path.unshift(cur);
          cur = parent[cur];
        }

        steps.push({
          type: 'reconstruct',
          targets: path,
          message: `✅ 找到目标! 路径: ${path.join(' → ')}`,
          gScore: snapshot(gScore),
          fScore: snapshot(fScore),
          parent: snapshot(parent),
          open: [...openSet],
          closed: [...closedSet],
          current: null,
          path,
        });

        steps.push({
          type: 'finish',
          targets: path,
          message: `✅ A* 完成! 路径长度=${path.length - 1}, 探索节点=${closedSet.length + 1}`,
          gScore: snapshot(gScore),
          fScore: snapshot(fScore),
          parent: snapshot(parent),
          open: [],
          closed: [...closedSet, current],
          current: null,
          path,
        });
        return steps;
      }

      // 移到 closed
      openSet.splice(lowestIdx, 1);
      closedSet.push(current);

      const neighbors = adjList[current] || [];
      for (let ni = 0; ni < neighbors.length; ni++) {
        const neighbor = neighbors[ni];
        if (closedSet.includes(neighbor)) {
          steps.push({
            type: 'skip',
            targets: [current, neighbor],
            message: `${neighbor} 已在closed集中, 跳过`,
            gScore: snapshot(gScore),
            fScore: snapshot(fScore),
            parent: snapshot(parent),
            open: [...openSet],
            closed: [...closedSet],
            current,
            edge: [current, neighbor],
          });
          continue;
        }

        const w = edgeWeights[current + '-' + neighbor] ?? 1;
        const tentativeG = gScore[current] + w;

        if (tentativeG < gScore[neighbor]) {
          parent[neighbor] = current;
          gScore[neighbor] = tentativeG;
          fScore[neighbor] = tentativeG + manhattan(neighbor, targetId);

          if (!openSet.includes(neighbor)) {
            openSet.push(neighbor);
          }

          steps.push({
            type: 'explore',
            targets: [current, neighbor],
            message: `探索 ${current}→${neighbor}: g=${tentativeG.toFixed(1)}, h=${manhattan(neighbor, targetId).toFixed(1)}, f=${fScore[neighbor].toFixed(1)}`,
            gScore: snapshot(gScore),
            fScore: snapshot(fScore),
            parent: snapshot(parent),
            open: [...openSet],
            closed: [...closedSet],
            current,
            nextNode: neighbor,
            newG: tentativeG,
            edge: [current, neighbor],
          });
        } else {
          steps.push({
            type: 'skip',
            targets: [current, neighbor],
            message: `${neighbor} 的 g=${tentativeG.toFixed(1)} ≥ 当前 g=${gScore[neighbor].toFixed(1)}, 不更新`,
            gScore: snapshot(gScore),
            fScore: snapshot(fScore),
            parent: snapshot(parent),
            open: [...openSet],
            closed: [...closedSet],
            current,
            edge: [current, neighbor],
          });
        }
      }
    }

    steps.push({
      type: 'finish',
      targets: [],
      message: '❌ 目标不可达 (open集已空)',
      gScore: snapshot(gScore),
      fScore: snapshot(fScore),
      parent: snapshot(parent),
      open: [],
      closed: [...closedSet],
      current: null,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: AStarStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.start.value,
          borderColor: darken(colors.start.value),
          borderWidth: 4, width: 52, height: 52,
        }, mode, speed);
        break;

      case 'pop': {
        const cur = step.targets[0];
        renderer.setNode(cur, {
          backgroundColor: colors['node_active'].value,
          borderColor: darken(colors['node_active'].value),
          borderWidth: 3, width: 49, height: 49,
        }, mode, speed);

        // 标记所有 closed 节点
        for (const cid of step.closed) {
          if (cid !== cur) {
            renderer.setNode(cid, {
              backgroundColor: colors.visited.value,
              borderColor: darken(colors.visited.value),
              borderWidth: 2, width: 46, height: 46,
            }, mode, 50);
          }
        }
        // 标记所有 open 节点
        for (const oid of step.open) {
          if (oid !== cur) {
            renderer.setNode(oid, {
              backgroundColor: colors.ready.value,
              borderColor: darken(colors.ready.value),
              borderWidth: 2,
            }, mode, 80);
          }
        }
        break;
      }

      case 'explore': {
        const src = step.targets[0], tgt = step.targets[1];
        renderer.setEdge(src, tgt, {
          lineColor: colors['edge_active'].value, width: 4,
        }, mode, true, speed);
        renderer.setNode(tgt, {
          backgroundColor: colors.ready.value,
          borderColor: darken(colors.ready.value),
          borderWidth: 3,
        }, mode, Math.max(100, speed * 0.5));
        break;
      }

      case 'skip': {
        if (step.edge) {
          renderer.setEdge(step.edge[0], step.edge[1], {
            lineColor: '#94A3B8', width: 1.5, opacity: 0.4, lineStyle: 'dashed',
          }, mode, true, speed);
        }
        break;
      }

      case 'reconstruct': {
        // 高亮最终路径
        const p = step.path || [];
        for (let i = 0; i < p.length; i++) {
          renderer.setNode(p[i], {
            backgroundColor: colors.visited.value,
            borderColor: '#FBBF24',
            borderWidth: 4, width: 50, height: 50,
          }, mode, speed);
          if (i > 0) {
            renderer.setEdge(p[i - 1], p[i], {
              lineColor: '#FBBF24', width: 5,
            }, mode, true, speed);
          }
        }
        break;
      }

      case 'finish':
        if (step.path && step.path.length > 0) {
          for (let i = 0; i < step.path.length; i++) {
            renderer.setNode(step.path[i], {
              backgroundColor: i === 0 ? colors.start.value : colors.visited.value,
              borderColor: '#FBBF24', borderWidth: 4,
            }, mode, 100);
            if (i > 0) {
              renderer.setEdge(step.path[i - 1], step.path[i], {
                lineColor: '#FBBF24', width: 5,
              }, mode, true, 100);
            }
          }
        } else {
          renderer.setNodesByFn((id: string) => {
            if (id === '0') return { backgroundColor: colors.start.value };
            return { backgroundColor: colors.default.value };
          }, mode);
        }
        break;
    }
  },

  getUIData(step: AStarStep | null, state: UIState): Record<string, string> {
    if (!step || state.isFinished) {
      return {
        'current-node': '—',
        'f-values': '-',
        'g-values': '-',
        'open-set': '-',
        'closed-set': '-',
      };
    }
    return {
      'current-node': step.current ?? '—',
      'f-values': formatFScore(step.fScore),
      'g-values': formatGScore(step.gScore),
      'open-set': '[' + step.open.join(', ') + ']',
      'closed-set': '[' + step.closed.join(', ') + ']',
    };
  },
});

function formatFScore(f: Record<string, number>): string {
  const parts: string[] = [];
  for (const k in f) {
    if (f[k] < Infinity) parts.push(`${k}:${f[k].toFixed(1)}`);
  }
  return '{' + parts.join(', ') + '}' || '{}';
}

function formatGScore(g: Record<string, number>): string {
  const parts: string[] = [];
  for (const k in g) {
    if (g[k] < Infinity) parts.push(`${k}:${g[k].toFixed(1)}`);
  }
  return '{' + parts.join(', ') + '}' || '{}';
}

export default AStar;
