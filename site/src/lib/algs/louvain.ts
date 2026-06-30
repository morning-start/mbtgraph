/**
 * louvain.ts — Louvain 社区检测可视化算法模块
 *
 * 展示社区合并过程：节点逐个尝试加入邻居社区，显示模块度变化。
 */

import { createAlgo, snapshot, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

const COMMUNITY_COLORS = ['#EF4444', '#3B82F6', '#22C55E', '#F59E0B', '#A855F7', '#EC4899', '#14B8A6'];

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
];

export interface LouvainStep {
  type: 'init' | 'move_node' | 'phase_done' | 'finish';
  targets: string[];
  message: string;
  community: Record<string, number>;
  modularity: number;
  numCommunities: number;
  movedNode?: string;
  fromCommunity?: number;
  toCommunity?: number;
}

const Louvain = createAlgo<LouvainStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    _edgeWeights?: Record<string, number>,
  ): LouvainStep[] {
    const steps: LouvainStep[] = [];
    const community: Record<string, number> = {};
    const nodeIds = nodes.map(n => n.data.id);

    // 初始: 每个节点独立社区
    for (const nid of nodeIds) community[nid] = parseInt(nid);

    steps.push({
      type: 'init', targets: [],
      message: `Louvain 开始: ${nodeIds.length} 个节点初始各为一社区`,
      community: snapshot(community),
      modularity: -1, numCommunities: nodeIds.length,
    });

    let improved = true;
    let iter = 0;
    while (improved && iter < 3) {
      improved = false;
      iter++;

      for (const u of nodeIds) {
        const neighbors = adjList[u] || [];
        const neighborComms = new Map<number, number>();

        for (const v of neighbors) {
          if (v === u) continue;
          const c = community[v];
          neighborComms.set(c, (neighborComms.get(c) || 0) + 1);
        }

        let bestComm = community[u];
        let bestCount = 0;
        for (const [c, cnt] of neighborComms) {
          if (cnt > bestCount) {
            bestCount = cnt;
            bestComm = c;
          }
        }

        if (bestComm !== community[u]) {
          const oldComm = community[u];
          community[u] = bestComm;
          improved = true;

          steps.push({
            type: 'move_node', targets: [u],
            message: `节点 ${u}: 社区 ${oldComm} → ${bestComm} (${bestCount} 个邻居在此社区)`,
            community: snapshot(community),
            modularity: calculateModularity(community, adjList),
            numCommunities: new Set(Object.values(community)).size,
            movedNode: u, fromCommunity: oldComm, toCommunity: bestComm,
          });
        }
      }

      const mod = calculateModularity(community, adjList);
      steps.push({
        type: 'phase_done', targets: [],
        message: `第 ${iter} 轮完成: 社区=${new Set(Object.values(community)).size}, Q=${mod.toFixed(3)}`,
        community: snapshot(community),
        modularity: mod,
        numCommunities: new Set(Object.values(community)).size,
      });
    }

    const finalMod = calculateModularity(community, adjList);
    steps.push({
      type: 'finish', targets: [...new Set(Object.values(community)).values()].map(String),
      message: `✅ Louvain 完成! 社区=${new Set(Object.values(community)).size}, Q=${finalMod.toFixed(3)}`,
      community: snapshot(community),
      modularity: finalMod,
      numCommunities: new Set(Object.values(community)).size,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: LouvainStep, mode: RenderMode, speed: number, _colors: ColorMap): void {
    // 按社区着色
    for (const nid in step.community) {
      const cid = step.community[nid];
      const hex = COMMUNITY_COLORS[cid % COMMUNITY_COLORS.length];
      renderer.setNode(nid, {
        backgroundColor: hex,
        borderColor: darken(hex),
        borderWidth: 3, width: 48, height: 48,
      }, mode, 100);
    }

    switch (step.type) {
      case 'move_node':
        if (step.movedNode) {
          const hex = COMMUNITY_COLORS[step.community[step.movedNode] % COMMUNITY_COLORS.length];
          renderer.setNode(step.movedNode, {
            backgroundColor: hex,
            borderColor: '#FBBF24',
            borderWidth: 5, width: 54, height: 54,
          }, mode, speed);
        }
        break;
    }
  },

  getUIData(step: LouvainStep | null, state: UIState): Record<string, string> {
    if (!step) return { 'num-communities': '-', 'modularity': '-', 'last-move': '-' };
    return {
      'num-communities': String(step.numCommunities),
      'modularity': step.modularity >= 0 ? step.modularity.toFixed(3) : '-',
      'last-move': step.movedNode
        ? `${step.movedNode}: ${step.fromCommunity}→${step.toCommunity}`
        : '(无)',
    };
  },
});

function calculateModularity(community: Record<string, number>, adjList: Record<string, string[]>): number {
  let m = 0;
  let q = 0;
  const nodeIds = Object.keys(community);

  for (const u of nodeIds) {
    for (const v of adjList[u] || []) {
      if (v > u) m++;
    }
  }
  if (m === 0) return 0;

  for (const u of nodeIds) {
    for (const v of adjList[u] || []) {
      if (v > u) {
        const ku = (adjList[u] || []).length;
        const kv = (adjList[v] || []).length;
        const Auv = 1;
        const expected = (ku * kv) / (2 * m);
        const sameComm = community[u] === community[v] ? 1 : 0;
        q += (Auv - expected) * sameComm;
      }
    }
  }
  return q / (2 * m);
}

export default Louvain;
