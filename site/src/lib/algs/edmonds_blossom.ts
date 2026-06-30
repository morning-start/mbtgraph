import { createAlgo, snapshot, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
  { domain: 'node', key: 'ready' },
  { domain: 'edge', key: 'active' },
  { domain: 'edge', key: 'tree' },
  { domain: 'edge', key: 'rejected' },
];

export interface BlossomStep {
  type: 'init' | 'search' | 'augment' | 'blossom_found' | 'blossom_contract' | 'finish';
  targets: string[];
  message: string;
  match: Record<string, string | null>;
  phase: number;
}

const NODES = ['0', '1', '2', '3', '4', '5'];
// 一般图：0-1-2-3-4-5-0 环 + 额外连接
const Blossom = createAlgo<BlossomStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
  ): BlossomStep[] {
    const steps: BlossomStep[] = [];
    const match: Record<string, string | null> = {};
    for (const n of nodes) match[n.data.id] = null;
    let phase = 0;

    steps.push({
      type: 'init', targets: [],
      message: '初始化: 一般图 (含奇环, 可用开花算法收缩)',
      match: snapshot(match), phase,
    });

    // 模拟 Edmonds 开花算法过程
    // 逐步构建匹配，遇到奇环时收缩为"花苞"
    for (const start of NODES) {
      if (match[start] !== null) continue;

      steps.push({
        type: 'search', targets: [start],
        message: `从节点 ${start} 出发搜索增广路`,
        match: snapshot(match), phase,
      });

      const neighbors = adjList[start] || [];
      let augmented = false;

      for (const nbr of neighbors) {
        if (match[nbr] === null) {
          // 自由节点 → 直接匹配
          match[start] = nbr;
          match[nbr] = start;
          steps.push({
            type: 'augment', targets: [start, nbr],
            message: `✅ 直接匹配: ${start}↔${nbr}`,
            match: snapshot(match), phase,
          });
          augmented = true;
          break;
        }
      }

      if (!augmented) {
        // 尝试通过已匹配节点寻找增广路
        for (const nbr of neighbors) {
          if (match[nbr] !== null) {
            const partner = match[nbr]!;
            const pnbrs = adjList[partner] || [];
            for (const pnbr of pnbrs) {
              if (pnbr !== nbr && match[pnbr] === null) {
                // 找到增广路: start→nbr- partner→pnbr
                steps.push({
                  type: 'search', targets: [partner, pnbr],
                  message: `尝试让 ${partner} 重新匹配 → ${pnbr}`,
                  match: snapshot(match), phase,
                });

                // 检测奇环: 如果 nbr 的邻居中有一个已匹配节点
                // 形成环 → 模拟开花收缩
                const cycleCheck = adjList[pnbr] || [];
                const inCycle = cycleCheck.find(x => x !== partner && match[x] !== null && x !== start);
                if (inCycle !== undefined) {
                  steps.push({
                    type: 'blossom_found', targets: [start, nbr, partner, pnbr, inCycle],
                    message: `🌸 发现奇环! 收缩为花苞 (节点 ${start},${nbr},${partner},${pnbr},${inCycle})`,
                    match: snapshot(match), phase,
                  });
                  steps.push({
                    type: 'blossom_contract', targets: [start, inCycle],
                    message: `🌸 花苞收缩完成, 继续搜索增广路`,
                    match: snapshot(match), phase,
                  });
                }

                // 模拟增广
                const oldPartner = match[nbr];
                if (oldPartner !== null) match[oldPartner] = null;
                match[start] = nbr;
                match[nbr] = start;
                match[partner] = pnbr;
                match[pnbr] = partner;

                steps.push({
                  type: 'augment', targets: [start, nbr, partner, pnbr],
                  message: `✅ 增广: ${start}↔${nbr}, ${partner}↔${pnbr}`,
                  match: snapshot(match), phase,
                });
                augmented = true;
                break;
              }
            }
            if (augmented) break;
          }
        }
      }
    }

    steps.push({
      type: 'finish', targets: [],
      message: `✅ 最大匹配 = ${Object.values(match).filter(v => v !== null).length / 2}`,
      match: snapshot(match), phase,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: BlossomStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    // 渲染匹配边
    for (const v in step.match) {
      if (step.match[v] !== null) {
        renderer.setEdge(v, step.match[v]!, { lineColor: colors['edge_tree'].value, width: 4 }, mode, true, 50);
      }
    }

    switch (step.type) {
      case 'init':
        for (const id of NODES) {
          renderer.setNode(id, {
            backgroundColor: colors.default.value,
            borderColor: darken(colors.default.value), borderWidth: 2,
          }, mode, 50);
        }
        break;

      case 'search':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.active.value,
          borderColor: darken(colors.active.value), borderWidth: 3,
        }, mode, speed);
        if (step.targets[1]) {
          renderer.setNode(step.targets[1], {
            backgroundColor: colors.ready.value,
            borderColor: darken(colors.ready.value), borderWidth: 3,
          }, mode, speed);
        }
        break;

      case 'augment':
        for (let i = 0; i < step.targets.length; i += 2) {
          renderer.setNode(step.targets[i], { backgroundColor: colors.visited.value, borderWidth: 3 }, mode, speed);
          renderer.setNode(step.targets[i + 1], { backgroundColor: colors.visited.value, borderWidth: 3 }, mode, speed);
        }
        break;

      case 'blossom_found': {
        // 高亮奇环中的所有节点
        for (const id of step.targets) {
          renderer.setNode(id, {
            backgroundColor: '#EC4899',
            borderColor: '#BE185D', borderWidth: 4, width: 56, height: 56,
          }, mode, speed);
        }
        // 环边标粉色
        for (let i = 0; i < step.targets.length; i++) {
          for (let j = i + 1; j < step.targets.length; j++) {
            renderer.setEdge(step.targets[i], step.targets[j], {
              lineColor: '#EC4899', width: 4, lineStyle: 'dashed',
            }, mode, true, speed);
          }
        }
        break;
      }

      case 'blossom_contract': {
        // 花苞收缩：将环节点标为同色
        renderer.setNode(step.targets[0], {
          backgroundColor: '#8B5CF6',
          borderColor: '#6D28D9', borderWidth: 4, width: 58, height: 58,
        }, mode, speed);
        renderer.setNode(step.targets[1], {
          backgroundColor: '#8B5CF6',
          borderColor: '#6D28D9', borderWidth: 4, width: 58, height: 58,
        }, mode, speed);
        break;
      }
    }
  },

  getUIData(step: BlossomStep | null): Record<string, string> {
    if (!step) return { 'matching': '-', 'phase': '-' };
    const matchCount = Object.values(step.match).filter(v => v !== null).length / 2;
    return {
      'phase': String(step.phase),
      'matching': String(matchCount),
    };
  },
});

export default Blossom;
