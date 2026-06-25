/**
 * prim.ts — Prim 最小生成树可视化算法模块
 *
 * 从根节点出发，逐步扩展已选集合，每次选择连接已选/未选的最小边。
 * 展示候选边集合、已选节点集和最小边选择过程。
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
  { domain: 'edge', key: 'mst' },
  { domain: 'edge', key: 'rejected' },
];

export interface PrimStep {
  type: 'init' | 'select_node' | 'explore' | 'expand' | 'finish';
  targets: string[];
  message: string;
  inTree: string[];
  candidates: [string, string, number][];
  selectedEdge: [string, string, number] | null;
  totalWeight: number;
}

const Prim = createAlgo<PrimStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights: Record<string, number>,
    startId: string
  ): PrimStep[] {
    const steps: PrimStep[] = [];
    const inTree: Set<string> = new Set();
    const mstEdges: [string, string, number][] = [];
    let totalWeight = 0;

    inTree.add(startId);
    steps.push({
      type: 'init', targets: [startId],
      message: `从节点 ${startId} 开始构建 MST`,
      inTree: [...inTree], candidates: [], selectedEdge: null, totalWeight: 0,
    });

    while (inTree.size < nodes.length) {
      // 扫描所有候选边（从已选节点到未选节点）
      const candidates: [string, string, number][] = [];
      for (const u of inTree) {
        const neighbors = adjList[u] || [];
        for (const v of neighbors) {
          if (!inTree.has(v)) {
            const w = edgeWeights[u + '-' + v];
            if (w !== undefined) candidates.push([u, v, w]);
          }
        }
      }
      if (candidates.length === 0) break;

      candidates.sort((a, b) => a[2] - b[2]);
      const [from, to, weight] = candidates[0];

      steps.push({
        type: 'explore', targets: [from, to],
        message: `候选边: ${from}→${to} (w=${weight})`,
        inTree: [...inTree], candidates: candidates.slice(0, 5),
        selectedEdge: [from, to, weight], totalWeight,
      });

      inTree.add(to);
      mstEdges.push([from, to, weight]);
      totalWeight += weight;

      steps.push({
        type: 'expand', targets: [from, to],
        message: `✅ 加入边 ${from}—${to} (w=${weight}), 总权重=${totalWeight}`,
        inTree: [...inTree], candidates: [],
        selectedEdge: [from, to, weight], totalWeight,
      });
    }

    steps.push({
      type: 'finish', targets: [],
      message: `✅ MST 完成! 总权重=${totalWeight}, 边数=${mstEdges.length}`,
      inTree: [...inTree], candidates: [],
      selectedEdge: null, totalWeight,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: PrimStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    // 标记所有已选节点
    for (const nid of step.inTree) {
      renderer.setNode(nid, {
        backgroundColor: nid === step.targets[0] && step.type === 'init'
          ? colors.start.value : colors.visited.value,
        borderColor: darken(colors.visited.value),
        borderWidth: 3,
      }, mode, 80);
    }

    // 标记未选节点为默认
    for (const nid of step.inTree) {
      renderer.setNode(nid, {}, mode, 0); // noop for inTree (already set)
    }

    switch (step.type) {
      case 'init':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.start.value,
          borderColor: darken(colors.start.value),
          borderWidth: 4, width: 52, height: 52,
        }, mode, speed);
        break;

      case 'explore':
        if (step.selectedEdge) {
          const [from, to] = step.selectedEdge;
          renderer.setEdge(from, to, {
            lineColor: colors['edge_active'].value, width: 4,
          }, mode, false, speed);
          renderer.setNode(to, {
            backgroundColor: colors.ready.value,
            borderColor: darken(colors.ready.value),
            borderWidth: 3,
          }, mode, speed);
        }
        break;

      case 'expand':
        if (step.selectedEdge) {
          const [from, to] = step.selectedEdge;
          renderer.setNode(to, {
            backgroundColor: colors.visited.value,
            borderColor: darken(colors.visited.value),
            borderWidth: 3, width: 48, height: 48,
          }, mode, speed);
          renderer.setEdge(from, to, {
            lineColor: colors['edge_mst'].value, width: 5,
          }, mode, false, speed);
        }
        break;

      case 'finish':
        renderer.setNodesByFn((id: string) => {
          if (id === '0') return { backgroundColor: colors.start.value };
          return { backgroundColor: colors.visited.value };
        }, mode);
        break;
    }
  },

  getUIData(step: PrimStep | null, state: UIState): Record<string, string> {
    if (!step || state.isFinished) {
      return {
        'current-node': '—', 'in-tree': '-', 'candidates': '-', 'total-weight': '-',
      };
    }
    const candStr = step.candidates
      .map(([f, t, w]) => `${f}—${t}(${w})`).join(', ') || '(无)';
    return {
      'current-node': step.targets[0] || '—',
      'in-tree': '[' + [...step.inTree].join(', ') + ']',
      'candidates': candStr,
      'total-weight': String(step.totalWeight),
    };
  },
});

export default Prim;
