/**
 * pagerank.ts — PageRank 算法可视化
 *
 * 算法思想：模拟"随机浏览者在网页间的跳转行为"。
 *   PR(v) = (1-d)/N + d * Σ PR(u)/out_degree(u)  for u→v
 *
 * 步骤设计（B 方案：整体计算 + 排序后逐个着色）：
 * 1. init：所有节点初始化 score = 1/N
 * 2. iterate：每轮幂法迭代（最多 N 次）
 * 3. computed：迭代收敛（或达到上限）
 * 4. color：按 score 从高到低，逐个染色
 * 5. finish：完成
 *
 * 教学要点：
 * - 阻尼系数 d=0.85 表示"85% 顺着链接点，15% 随机跳"
 * - 出度大的节点把 rank 分散给多个邻居，单邻居收到的"份额"少
 * - 排序后逐个染色：用颜色深浅表示 rank 高低（"重要性排序"）
 */

import { createAlgo, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

// ── Legend 声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },   // 初始状态
  { domain: 'node', key: 'active' },    // 正在着色
  { domain: 'edge', key: 'default' },   // 普通边
  { domain: 'edge', key: 'tree' },      // 高 rank 节点的入边
];

// ── 步骤类型 ──

export interface PageRankStep {
  type: 'init' | 'iterate' | 'computed' | 'color' | 'finish';
  targets: string[];
  ranks: Record<string, number>;
  sortedIds: string[];       // 从高到低排序后的节点 ID
  rankInOrder?: number;       // 当前在 color 步骤中染的是第几个（0-based）
  iteration?: number;         // 当前的迭代轮次
  damping: number;            // 阻尼系数
  message: string;
}

// ── 算法实现 ──
//
// 用纯 TS 写幂法迭代，避免依赖 cytoscape 实例（保持 TS 步骤生成器自洽）。
// 与 mbtgraph/lib/algo/pagerank/pagerank.mbt 的语义保持一致：
//   - 幂法迭代
//   - 处理 dangling nodes（出度=0）
//   - 收敛阈值 tolerance

interface PRConfig {
  damping: number;
  maxIter: number;
  tolerance: number;
}

const DEFAULT_CONFIG: PRConfig = {
  damping: 0.85,
  maxIter: 50,
  tolerance: 1e-6,
};

/**
 * 节点颜色（按 rank 从高到低映射）
 * 高 rank → 暖色（橙/红）
 * 中 rank → 黄
 * 低 rank → 冷色（青/蓝）
 */
function rankToColor(rank: number, min: number, max: number): string {
  // 归一化到 [0, 1]
  const t = max > min ? (rank - min) / (max - min) : 0.5;
  // 三段渐变：青(0) → 黄(0.5) → 橙(1)
  if (t < 0.5) {
    // 青 (#06B6D4) → 黄 (#FBBF24)
    const k = t * 2;
    return interpolateColor('#06B6D4', '#FBBF24', k);
  } else {
    // 黄 (#FBBF24) → 橙 (#F97316)
    const k = (t - 0.5) * 2;
    return interpolateColor('#FBBF24', '#F97316', k);
  }
}

function interpolateColor(a: string, b: string, t: number): string {
  const ar = parseInt(a.slice(1, 3), 16);
  const ag = parseInt(a.slice(3, 5), 16);
  const ab = parseInt(a.slice(5, 7), 16);
  const br = parseInt(b.slice(1, 3), 16);
  const bg = parseInt(b.slice(3, 5), 16);
  const bb = parseInt(b.slice(5, 7), 16);
  const r = Math.round(ar + (br - ar) * t);
  const g = Math.round(ag + (bg - ag) * t);
  const bC = Math.round(ab + (bb - ab) * t);
  return '#' + [r, g, bC].map(x => x.toString(16).padStart(2, '0')).join('');
}

const PageRank = createAlgo<PageRankStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
  ): PageRankStep[] {
    const config = DEFAULT_CONFIG;
    const ids = nodes.map(n => n.data.id);
    const N = ids.length;
    const steps: PageRankStep[] = [];

    if (N === 0) {
      steps.push({
        type: 'finish',
        targets: [],
        ranks: {},
        sortedIds: [],
        damping: config.damping,
        message: '图为空，无节点',
      });
      return steps;
    }

    // 初始化 rank = 1/N
    const ranks: Record<string, number> = {};
    ids.forEach(id => { ranks[id] = 1 / N; });

    steps.push({
      type: 'init',
      targets: [],
      ranks: { ...ranks },
      sortedIds: [],
      damping: config.damping,
      message: `初始化：每个节点 PR = 1/N = ${(1 / N).toFixed(4)}，阻尼 d=${config.damping}`,
    });

    // 幂法迭代
    let iter = 0;
    let converged = false;
    while (iter < config.maxIter) {
      iter++;
      const newRanks: Record<string, number> = {};
      ids.forEach(id => { newRanks[id] = (1 - config.damping) / N; });

      // 计算 dangling sum（出度为 0 的节点贡献的 rank 之和）
      let danglingSum = 0;
      for (const id of ids) {
        const outDeg = (adjList[id] || []).length;
        if (outDeg === 0) danglingSum += ranks[id];
      }
      const danglingShare = config.damping * danglingSum / N;
      ids.forEach(id => { newRanks[id] += danglingShare; });

      // 正常入边贡献
      for (const src of ids) {
        const outDeg = (adjList[src] || []).length;
        if (outDeg === 0) continue;
        const contribution = config.damping * ranks[src] / outDeg;
        for (const tgt of adjList[src] || []) {
          if (newRanks[tgt] !== undefined) {
            newRanks[tgt] += contribution;
          }
        }
      }

      // 检查收敛
      let maxDiff = 0;
      for (const id of ids) {
        const diff = Math.abs(newRanks[id] - ranks[id]);
        if (diff > maxDiff) maxDiff = diff;
      }

      steps.push({
        type: 'iterate',
        targets: [],
        ranks: { ...newRanks },
        sortedIds: [],
        iteration: iter,
        damping: config.damping,
        message: `第 ${iter} 次迭代：最大变化 = ${maxDiff.toExponential(2)}`,
      });

      // 复制到 ranks
      for (const id of ids) ranks[id] = newRanks[id];

      if (maxDiff < config.tolerance) {
        converged = true;
        break;
      }
    }

    // 排序（高到低）
    const sortedIds = ids.slice().sort((a, b) => ranks[b] - ranks[a]);
    const minRank = Math.min(...ids.map(id => ranks[id]));
    const maxRank = Math.max(...ids.map(id => ranks[id]));

    steps.push({
      type: 'computed',
      targets: [],
      ranks: { ...ranks },
      sortedIds,
      damping: config.damping,
      message: `✅ 迭代${converged ? '收敛' : '达到上限'}，共 ${iter} 轮。开始按 rank 排序着色`,
    });

    // 逐个染色
    for (let i = 0; i < sortedIds.length; i++) {
      const id = sortedIds[i];
      const rank = ranks[id];
      steps.push({
        type: 'color',
        targets: [id],
        ranks: { ...ranks },
        sortedIds,
        rankInOrder: i,
        damping: config.damping,
        message: `排名第 ${i + 1}：节点 ${id}，PR = ${rank.toFixed(4)}`,
      });
    }

    steps.push({
      type: 'finish',
      targets: [],
      ranks: { ...ranks },
      sortedIds,
      damping: config.damping,
      message: `✅ PageRank 完成：${converged ? '收敛' : '达到上限'}，共 ${iter} 轮迭代`,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: PageRankStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init':
      case 'iterate': {
        // 迭代过程中保持 default 着色（不显示中间状态）
        for (const id of Object.keys(step.ranks)) {
          renderer.setNode(id, {
            backgroundColor: colors.default.value,
            borderColor: darken(colors.default.value),
            borderWidth: 2,
            width: 46,
            height: 46,
          }, mode, 100);
        }
        break;
      }

      case 'computed': {
        // 准备染色（先全部恢复 default）
        for (const id of Object.keys(step.ranks)) {
          renderer.setNode(id, {
            backgroundColor: colors.default.value,
            borderColor: darken(colors.default.value),
            borderWidth: 2,
            width: 46,
            height: 46,
          }, mode, 100);
        }
        break;
      }

      case 'color':
      case 'finish': {
        // 按 rank 高低统一染色
        const ranks = step.ranks;
        const ids = Object.keys(ranks);
        const minRank = Math.min(...ids.map(id => ranks[id]));
        const maxRank = Math.max(...ids.map(id => ranks[id]));
        for (const id of ids) {
          const color = rankToColor(ranks[id], minRank, maxRank);
          const isTop = step.sortedIds.indexOf(id) < 3;
          renderer.setNode(id, {
            backgroundColor: color,
            borderColor: darken(color),
            borderWidth: isTop ? 4 : 2,
            width: isTop ? 52 : 46,
            height: isTop ? 52 : 46,
          }, mode, speed);
        }
        // 高亮 top-3 节点的入边
        if (step.type === 'finish' || (step.type === 'color' && (step.rankInOrder ?? 0) < 3)) {
          // 边高亮留给图例，本身只染节点
        }
        break;
      }
    }
  },

  getUIData(step: PageRankStep | null, state: UIState): Record<string, string> {
    if (!step) {
      return {
        'iteration': '—',
        'top-1': '—',
        'top-2': '—',
        'top-3': '—',
        'damping': '0.85',
      };
    }
    const top3 = step.sortedIds.slice(0, 3).map((id, i) =>
      `#${i + 1} ${id}(${step.ranks[id]?.toFixed(4) ?? '?'})`
    );
    return {
      'iteration': step.iteration !== undefined ? `第 ${step.iteration} 轮` : (step.type === 'finish' ? '完成' : '—'),
      'top-1': top3[0] ?? '—',
      'top-2': top3[1] ?? '—',
      'top-3': top3[2] ?? '—',
      'damping': step.damping.toFixed(2),
    };
  },
});

export default PageRank;
