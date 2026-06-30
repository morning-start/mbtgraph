/**
 * cutpoints.ts — 割点与桥可视化算法模块
 *
 * 基于 Tarjan 的 DFS lowlink 算法，展示 DFS 树、lowlink 值变化和割点/桥的判定。
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
  { domain: 'edge', key: 'rejected' },
];

export interface CutpointStep {
  type: 'init' | 'discover' | 'backtrack' | 'found_cutpoint' | 'found_bridge' | 'finish';
  targets: string[];
  message: string;
  disc: Record<string, number>;
  low: Record<string, number>;
  cutpoints: string[];
  bridges: [string, string][];
  dfn: number;
}

const Cutpoints = createAlgo<CutpointStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
  ): CutpointStep[] {
    const steps: CutpointStep[] = [];
    const disc: Record<string, number> = {};
    const low: Record<string, number> = {};
    const parent: Record<string, string | null> = {};
    const cutpointsSet = new Set<string>();
    const bridges: [string, string][] = [];
    let time = 0;
    const nodeIds = nodes.map(n => n.data.id);

    for (const nid of nodeIds) { disc[nid] = -1; low[nid] = -1; parent[nid] = null; }

    steps.push({
      type: 'init', targets: [],
      message: `开始 Tarjan 割点/桥检测, ${nodes.length} 节点`,
      disc: snapshot(disc), low: snapshot(low),
      cutpoints: [], bridges: [], dfn: time,
    });

    function dfs(u: string, root: boolean) {
      let children = 0;
      time++;
      disc[u] = time;
      low[u] = time;

      steps.push({
        type: 'discover', targets: [u],
        message: `访问节点 ${u}: disc=${disc[u]}, low=${low[u]}`,
        disc: snapshot(disc), low: snapshot(low),
        cutpoints: [...cutpointsSet], bridges: [...bridges], dfn: time,
      });

      const neighbors = adjList[u] || [];
      for (const v of neighbors) {
        if (disc[v] === -1) {
          parent[v] = u;
          children++;
          dfs(v, false);

          low[u] = Math.min(low[u], low[v]);

          if (!root && low[v] >= disc[u]) {
            cutpointsSet.add(u);
            steps.push({
              type: 'found_cutpoint', targets: [u],
              message: `🔴 割点: ${u} (low[${v}]=${low[v]} ≥ disc[${u}]=${disc[u]})`,
              disc: snapshot(disc), low: snapshot(low),
              cutpoints: [...cutpointsSet], bridges: [...bridges], dfn: time,
            });
          }

          if (low[v] > disc[u]) {
            bridges.push([u, v]);
            steps.push({
              type: 'found_bridge', targets: [u, v],
              message: `🔴 桥: ${u}—${v} (low[${v}]=${low[v]} > disc[${u}]=${disc[u]})`,
              disc: snapshot(disc), low: snapshot(low),
              cutpoints: [...cutpointsSet], bridges: [...bridges], dfn: time,
            });
          }
        } else if (v !== parent[u] && disc[v] < disc[u]) {
          low[u] = Math.min(low[u], disc[v]);
          steps.push({
            type: 'backtrack', targets: [u, v],
            message: `回边 ${u}—${v}: low[${u}]=min(${low[u]}, disc[${v}]=${disc[v]}) = ${Math.min(low[u], disc[v])}`,
            disc: snapshot(disc), low: snapshot(low),
            cutpoints: [...cutpointsSet], bridges: [...bridges], dfn: time,
          });
        }
      }

      if (root && children > 1) {
        cutpointsSet.add(u);
        steps.push({
          type: 'found_cutpoint', targets: [u],
          message: `🔴 根割点: ${u} (子树数=${children}>1)`,
          disc: snapshot(disc), low: snapshot(low),
          cutpoints: [...cutpointsSet], bridges: [...bridges], dfn: time,
        });
      }
    }

    for (const nid of nodeIds) {
      if (disc[nid] === -1) {
        parent[nid] = null;
        dfs(nid, true);
      }
    }

    steps.push({
      type: 'finish', targets: [...cutpointsSet],
      message: `✅ 检测完成! 割点=${cutpointsSet.size}个, 桥=${bridges.length}条`,
      disc: snapshot(disc), low: snapshot(low),
      cutpoints: [...cutpointsSet], bridges, dfn: time,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: CutpointStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init':
        renderer.setNodesByFn(() => ({
          backgroundColor: colors.default.value, borderWidth: 2,
        }), 'instant');
        break;

      case 'discover':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors['node_active'].value,
          borderColor: darken(colors['node_active'].value),
          borderWidth: 3, width: 49, height: 49,
        }, mode, speed);
        // 已发现节点变绿
        for (const nid in step.disc) {
          if (step.disc[nid] > 0 && nid !== step.targets[0]) {
            renderer.setNode(nid, {
              backgroundColor: colors.visited.value, borderWidth: 2,
            }, mode, 50);
          }
        }
        break;

      case 'backtrack':
        renderer.setEdge(step.targets[0], step.targets[1], {
          lineColor: colors['edge_rejected'].value, width: 2.5, lineStyle: 'dashed',
        }, mode, false, speed);
        break;

      case 'found_cutpoint':
        renderer.setNode(step.targets[0], {
          backgroundColor: '#EF4444',
          borderColor: darken('#EF4444'),
          borderWidth: 4, width: 54, height: 54,
        }, mode, speed);
        break;

      case 'found_bridge':
        renderer.setEdge(step.targets[0], step.targets[1], {
          lineColor: '#F59E0B', width: 5,
        }, mode, false, speed);
        break;

      case 'finish':
        for (const nid in step.disc) {
          if (step.cutpoints.includes(nid)) {
            renderer.setNode(nid, {
              backgroundColor: '#EF4444', borderWidth: 4,
            }, mode, 100);
          } else if (step.disc[nid] > 0) {
            renderer.setNode(nid, {
              backgroundColor: colors.visited.value, borderWidth: 2,
            }, mode, 100);
          }
        }
        for (const [u, v] of step.bridges) {
          renderer.setEdge(u, v, {
            lineColor: '#F59E0B', width: 5,
          }, mode, false, 100);
        }
        break;
    }
  },

  getUIData(step: CutpointStep | null, state: UIState): Record<string, string> {
    if (!step || state.isFinished) {
      return {
        'current-node': '—', 'disc-time': '-', 'low-values': '-',
        'cutpoints': '-', 'bridges': '-',
      };
    }
    const lowStr = Object.entries(step.low)
      .filter(([_, v]) => v > 0)
      .map(([k, v]) => `${k}:${v}`).join(', ');
    return {
      'current-node': step.targets[0] || '—',
      'disc-time': String(step.dfn),
      'low-values': '{' + lowStr + '}' || '{}',
      'cutpoints': step.cutpoints.length > 0 ? '[' + step.cutpoints.join(', ') + ']' : '(无)',
      'bridges': step.bridges.length > 0
        ? '[' + step.bridges.map(([u, v]) => `${u}—${v}`).join(', ') + ']'
        : '(无)',
    };
  },
});

export default Cutpoints;
