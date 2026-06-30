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

export interface HKStep {
  type: 'init' | 'bfs_layer' | 'dfs_search' | 'augment_match' | 'phase_end' | 'finish';
  targets: string[];
  message: string;
  match: Record<string, string | null>;
  layers: Record<string, number>;
  phase: number;
}

// 简单二分图：左 0..2 右 3..5
const LEFT = ['0', '1', '2'];
const RIGHT = ['3', '4', '5'];

const HopcroftKarp = createAlgo<HKStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
  ): HKStep[] {
    const steps: HKStep[] = [];
    const match: Record<string, string | null> = {};
    for (const n of nodes) match[n.data.id] = null;
    let phase = 0;

    steps.push({
      type: 'init', targets: [],
      message: `初始化: 左部 ${LEFT.join(',')}, 右部 ${RIGHT.join(',')}`,
      match: snapshot(match), layers: {}, phase,
    });

    while (true) {
      // BFS 分层
      const dist: Record<string, number> = {};
      const queue: string[] = [];
      for (const u of LEFT) {
        if (match[u] === null) { dist[u] = 0; queue.push(u); }
        else dist[u] = Infinity;
      }
      let found = false;
      let head = 0;
      while (head < queue.length) {
        const u = queue[head++];
        for (const v of adjList[u] || []) {
          if (match[u] === v) continue; // 不遍历已匹配边
          steps.push({
            type: 'bfs_layer', targets: [u, v],
            message: `BFS 分层: ${u}→${v} (dist[${u}]=${dist[u]})`,
            match: snapshot(match), layers: snapshot(dist), phase,
          });
          const mu = match[v];
          if (mu === null) { found = true; }
          else if (dist[mu] === Infinity) { dist[mu] = dist[u] + 1; queue.push(mu); }
        }
      }

      if (!found) break;

      // DFS 增广
      let augmented = 0;
      for (const u of LEFT) {
        if (match[u] !== null) continue;
        const visited = new Set<string>();
        if (dfsAugment(u, adjList, match, visited, dist, steps, phase)) {
          augmented++;
        }
      }

      steps.push({
        type: 'phase_end', targets: [],
        message: `Phase ${phase+1} 完成: 新增 ${augmented} 匹配`,
        match: snapshot(match), layers: {}, phase: ++phase,
      });
    }

    steps.push({
      type: 'finish', targets: [],
      message: `✅ 最大匹配 = ${Object.values(match).filter(v => v !== null).length}`,
      match: snapshot(match), layers: {}, phase,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: HKStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    // 渲染匹配边
    for (const v in step.match) {
      if (step.match[v] !== null) {
        if (LEFT.includes(v)) {
          renderer.setEdge(v, step.match[v]!, { lineColor: '#22C55E', width: 4 }, mode, true, 50);
        } else {
          renderer.setEdge(step.match[v]!, v, { lineColor: '#22C55E', width: 4 }, mode, true, 50);
        }
      }
    }

    // 渲染左/右分区
    for (const id of LEFT) {
      const m = step.match[id];
      renderer.setNode(id, {
        backgroundColor: m !== null ? colors.visited.value : colors.default.value,
        borderColor: darken(m !== null ? colors.visited.value : colors.default.value),
        borderWidth: 2, shape: 'ellipse',
      }, mode, 50);
    }
    for (const id of RIGHT) {
      const m = step.match[id];
      renderer.setNode(id, {
        backgroundColor: m !== null ? colors.visited.value : colors.default.value,
        borderColor: darken(m !== null ? colors.visited.value : colors.default.value),
        borderWidth: 2, shape: 'rectangle',
      }, mode, 50);
    }

    switch (step.type) {
      case 'bfs_layer':
        renderer.setNode(step.targets[0], { backgroundColor: colors.active.value, borderWidth: 3 }, mode, speed);
        renderer.setEdge(step.targets[0], step.targets[1], { lineColor: colors['edge_active'].value, width: 3 }, mode, true, speed);
        renderer.setNode(step.targets[1], { backgroundColor: colors.ready.value, borderWidth: 3 }, mode, speed);
        break;

      case 'augment_match':
        for (let i = 0; i < step.targets.length; i += 2) {
          renderer.setEdge(step.targets[i], step.targets[i + 1], { lineColor: '#22C55E', width: 5 }, mode, true, speed);
        }
        break;
    }
  },

  getUIData(step: HKStep | null, state: UIState): Record<string, string> {
    if (!step || state.isFinished) {
      const m = step?.match ? Object.values(step.match).filter(v => v !== null).length : 0;
      return { 'phase': String(step?.phase ?? '-'), 'matching': String(m) };
    }
    const matchCount = Object.values(step.match).filter(v => v !== null).length;
    return {
      'phase': String(step.phase),
      'matching': String(matchCount),
    };
  },
});

function dfsAugment(
  u: string, adjList: Record<string, string[]>,
  match: Record<string, string | null>,
  visited: Set<string>, dist: Record<string, number>,
  steps: HKStep[], phase: number,
): boolean {
  for (const v of adjList[u] || []) {
    if (match[u] === v) continue;
    const mu = match[v];
    if (mu === null || (dist[mu] === dist[u] + 1 && !visited.has(mu) && dfsAugment(mu, adjList, match, visited, dist, steps, phase))) {
      match[u] = v;
      match[v] = u;
      steps.push({
        type: 'augment_match', targets: [u, v],
        message: `✅ 增广: ${u}↔${v}`,
        match: snapshot(match), layers: {}, phase,
      });
      return true;
    }
  }
  visited.add(u);
  return false;
}

export default HopcroftKarp;
