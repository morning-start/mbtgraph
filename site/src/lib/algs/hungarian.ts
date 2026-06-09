/**
 * hungarian.ts — 匈牙利算法（二分图最小权完美匹配）可视化
 *
 * 算法思想：通过 feasible labeling（可行顶点标号）维护 equality graph，
 * 在其中找完美匹配，找不到时更新标号引入更多边。
 *
 * 测试图：3×3 完全二分图（左 A/B/C，右 X/Y/Z）
 *   成本矩阵：
 *         X  Y  Z
 *     A   3  7  5
 *     B   2  1  8
 *     C   6  4  9
 *
 * 步骤设计：
 * 1. init：展示成本矩阵，初始化 u/v 标号
 * 2. build_equality：构造 equality graph（紧边）
 * 3. find_match：在当前 equality graph 中找匹配
 * 4. augment：增广匹配（翻转交替路）
 * 5. update_labels：更新标号（引入新紧边）
 * 6. finish：完美匹配完成
 *
 * 教学要点：
 * - feasible labeling 保证匹配权 = 标号和的下界
 * - equality graph 中的完美匹配 = 最优解
 * - 标号更新是算法主动引入新边的关键步骤
 */
import { createAlgo, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

// ── Legend 声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },    // 未匹配
  { domain: 'node', key: 'active' },    // 正在处理
  { domain: 'node', key: 'visited' },   // 已匹配
  { domain: 'edge', key: 'default' },   // 非紧边
  { domain: 'edge', key: 'tree' },      // 紧边（equality graph）
  { domain: 'edge', key: 'active' },    // 当前探索
  { domain: 'edge', key: 'relaxed' },   // 匹配边
];

// ── 步骤类型 ──

export interface HungarianStep {
  type: 'init' | 'build_equality' | 'find_match' | 'augment' | 'update_labels' | 'finish';
  targets: string[];
  current: string | null;
  edge?: [string, string];
  u: Record<string, number>;       // 左节点标号
  v: Record<string, number>;       // 右节点标号
  matching: Record<string, string>; // 匹配：左→右 和 右→左
  tightEdges: Array<[string, string]>; // 当前紧边
  equalityMatching: Record<string, string>; // equality graph 中的匹配
  isAugmented?: boolean;           // 本步骤是否成功增广
  message: string;
}

// ── 算法实现 ──

const BIPARTITE_LEFT = ['A', 'B', 'C'];
const BIPARTITE_RIGHT = ['X', 'Y', 'Z'];
const BIPARTITE_COST: Record<string, Record<string, number>> = {
  A: { X: 3, Y: 7, Z: 5 },
  B: { X: 2, Y: 1, Z: 8 },
  C: { X: 6, Y: 4, Z: 9 },
};

const Hungarian = createAlgo<HungarianStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    _adjList: Record<string, string[]>,
  ): HungarianStep[] {
    const steps: HungarianStep[] = [];
    const left = BIPARTITE_LEFT;
    const right = BIPARTITE_RIGHT;
    const N = left.length;

    // 成本矩阵
    const cost = { ...BIPARTITE_COST };

    // 标号
    const u: Record<string, number> = {};
    const v: Record<string, number> = {};
    for (const l of left) {
      u[l] = Math.max(...right.map(r => cost[l][r]));
    }
    for (const r of right) v[r] = 0;

    // 匹配 (左→右 和 右→左)
    const matchL: Record<string, string | null> = {};
    const matchR: Record<string, string | null> = {};
    for (const l of left) matchL[l] = null;
    for (const r of right) matchR[r] = null;

    // Step 1: init
    steps.push({
      type: 'init', targets: [], current: null,
      u: { ...u }, v: { ...v },
      matching: {}, tightEdges: [], equalityMatching: {},
      message: `初始化标号：u[i] = max cost in row, v[j] = 0。u = [${left.map(l => u[l]).join(', ')}]，v = [${right.map(r => v[r]).join(', ')}]`,
    });

    // 构建紧边
    function computeTightEdges(): Array<[string, string]> {
      const edges: Array<[string, string]> = [];
      for (const l of left) {
        for (const r of right) {
          if (cost[l][r] === u[l] + v[r]) {
            edges.push([l, r]);
          }
        }
      }
      return edges;
    }

    // DFS 找增广路（在 equality graph 中）
    function dfsAugment(
      uNode: string,
      visitedL: Set<string>,
      visitedR: Set<string>,
      tightSet: Set<string>,
    ): string | null {
      visitedL.add(uNode);
      for (const r of right) {
        const key = uNode + '-' + r;
        if (!tightSet.has(key)) continue;
        if (visitedR.has(r)) continue;
        visitedR.add(r);
        if (matchR[r] === null || dfsAugment(matchR[r]!, visitedL, visitedR, tightSet)) {
          matchL[uNode] = r;
          matchR[r] = uNode;
          return r;
        }
      }
      return null;
    }

    let iter = 0;
    const maxIter = 20;

    while (iter < maxIter) {
      iter++;

      // 构建 equality graph
      const tightEdges = computeTightEdges();
      const tightSet = new Set<string>();
      for (const [l, r] of tightEdges) tightSet.add(l + '-' + r);

      // 复制当前匹配到 equalityMatching
      const eqMatch: Record<string, string> = {};
      for (const l of left) {
        if (matchL[l] !== null) eqMatch[l] = matchL[l]!;
      }

      steps.push({
        type: 'build_equality', targets: [], current: null,
        u: { ...u }, v: { ...v },
        tightEdges: tightEdges.slice(),
        matching: { ...eqMatch },
        equalityMatching: { ...eqMatch },
        message: `Equality graph：${tightEdges.length} 条紧边，当前匹配 ${Object.keys(eqMatch).length}/${N}`,
      });

      // 找未匹配的左节点
      let startL: string | null = null;
      for (const l of left) {
        if (matchL[l] === null) { startL = l; break; }
      }

      if (startL === null) {
        // 完美匹配！
        break;
      }

      // 尝试增广
      const visitedL = new Set<string>();
      const visitedR = new Set<string>();
      const oldMatchL = { ...matchL };
      const result = dfsAugment(startL, visitedL, visitedR, tightSet);

      if (result !== null) {
        // 增广成功
        const newMatch: Record<string, string> = {};
        for (const l of left) {
          if (matchL[l] !== null) newMatch[l] = matchL[l]!;
        }
        steps.push({
          type: 'augment', targets: [startL, result], current: startL,
          edge: [startL, result],
          u: { ...u }, v: { ...v },
          tightEdges: tightEdges.slice(),
          matching: { ...oldMatchL },
          equalityMatching: { ...newMatch },
          isAugmented: true,
          message: `增广成功：从 ${startL} 出发找到增广路，匹配数 ${Object.keys(newMatch).length}/${N}`,
        });
        continue;
      }

      // 增广失败 → 需要更新标号
      // δ = min(u[l] + v[r] - cost[l][r] for l in visitedL, r not in visitedR)
      let delta = Infinity;
      let deltaEdge: [string, string] | null = null;
      for (const l of left) {
        if (!visitedL.has(l)) continue;
        for (const r of right) {
          if (visitedR.has(r)) continue;
          const d = u[l] + v[r] - cost[l][r];
          if (d < delta) {
            delta = d;
            deltaEdge = [l, r];
          }
        }
      }

      if (delta === Infinity || delta <= 0) {
        // 无法更新，说明无完美匹配
        steps.push({
          type: 'finish', targets: [], current: null,
          u: { ...u }, v: { ...v },
          tightEdges: [], matching: {}, equalityMatching: {},
          message: `⛔ 无法找到完美匹配（delta=${delta})`,
        });
        return steps;
      }

      // 更新标号
      for (const l of left) {
        if (visitedL.has(l)) u[l] -= delta;
      }
      for (const r of right) {
        if (visitedR.has(r)) v[r] += delta;
      }

      const eqMatchAfter: Record<string, string> = {};
      for (const l of left) {
        if (matchL[l] !== null) eqMatchAfter[l] = matchL[l]!;
      }

      steps.push({
        type: 'update_labels', targets: [], current: null,
        edge: deltaEdge ?? undefined,
        u: { ...u }, v: { ...v },
        tightEdges: computeTightEdges(),
        matching: { ...eqMatchAfter },
        equalityMatching: { ...eqMatchAfter },
        message: `更新标号：δ=${delta}，u 减 δ，v 加 δ → 新紧边 ${deltaEdge?.[0]}→${deltaEdge?.[1]}`,
      });
    }

    // 最终匹配
    const finalMatch: Record<string, string> = {};
    let totalCost = 0;
    for (const l of left) {
      if (matchL[l] !== null) {
        finalMatch[l] = matchL[l]!;
        totalCost += cost[l][matchL[l]!];
      }
    }

    steps.push({
      type: 'finish', targets: [], current: null,
      u: { ...u }, v: { ...v },
      tightEdges: [], matching: { ...finalMatch }, equalityMatching: { ...finalMatch },
      message: `✅ 匈牙利完成！完美匹配：${Object.entries(finalMatch).map(([l, r]) => `${l}→${r}(${cost[l][r]})`).join(', ')}，总成本 = ${totalCost}`,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: HungarianStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    const left = BIPARTITE_LEFT;
    const right = BIPARTITE_RIGHT;

    // 构建紧边集合
    const tightSet = new Set<string>();
    for (const [l, r] of step.tightEdges) tightSet.add(l + '-' + r);

    // 匹配集合
    const matchedL = new Set(Object.keys(step.equalityMatching));
    const matchedR = new Set(Object.values(step.equalityMatching));

    // 渲染节点
    for (const id of left) {
      const isMatched = matchedL.has(id);
      const isActive = step.current === id;
      renderer.setNode(id, {
        backgroundColor: isActive ? colors['node_active'].value
          : isMatched ? colors['node_visited'].value : colors.default.value,
        borderColor: darken(isActive ? colors['node_active'].value
          : isMatched ? colors['node_visited'].value : colors.default.value),
        borderWidth: isActive ? 4 : (isMatched ? 3 : 2),
        width: isActive ? 52 : (isMatched ? 49 : 46),
        height: isActive ? 52 : (isMatched ? 49 : 46),
      }, mode, speed);
    }

    for (const id of right) {
      const isMatched = matchedR.has(id);
      const isActive = step.edge && step.edge[1] === id;
      renderer.setNode(id, {
        backgroundColor: isActive ? colors['node_active'].value
          : isMatched ? colors['node_visited'].value : colors.default.value,
        borderColor: darken(isActive ? colors['node_active'].value
          : isMatched ? colors['node_visited'].value : colors.default.value),
        borderWidth: isActive ? 4 : (isMatched ? 3 : 2),
        width: isActive ? 52 : (isMatched ? 49 : 46),
        height: isActive ? 52 : (isMatched ? 49 : 46),
      }, mode, speed);
    }

    // 渲染边
    for (const l of left) {
      for (const r of right) {
        const key = l + '-' + r;
        const isTight = tightSet.has(key);
        const isMatch = step.equalityMatching[l] === r;
        const isActive = step.edge && (step.edge[0] === l && step.edge[1] === r);

        if (isActive) {
          renderer.setEdge(l, r, {
            lineColor: colors['edge_active'].value,
            width: 4,
            opacity: 1.0,
          }, mode, speed);
        } else if (isMatch) {
          renderer.setEdge(l, r, {
            lineColor: colors['edge_relaxed'].value,
            width: 4,
            opacity: 1.0,
          }, mode, speed);
        } else if (isTight) {
          renderer.setEdge(l, r, {
            lineColor: colors['edge_tree'].value,
            width: 2,
            opacity: 0.75,
            lineStyle: 'dashed',
          }, mode, speed);
        } else {
          renderer.setEdge(l, r, {
            lineColor: colors['edge_default'].value,
            width: 1,
            opacity: 0.3,
            lineStyle: 'dotted',
          }, mode, speed);
        }
      }
    }
  },

  getUIData(step: HungarianStep | null, state: UIState): Record<string, string> {
    if (!step) {
      return {
        'phase': '—',
        'u-label': '—',
        'v-label': '—',
        'tight-count': '—',
        'matching-status': '—',
        'total-cost': '—',
      };
    }
    const uStr = `[${BIPARTITE_LEFT.map(l => `${l}:${step.u[l]}`).join(', ')}]`;
    const vStr = `[${BIPARTITE_RIGHT.map(r => `${r}:${step.v[r]}`).join(', ')}]`;
    const matchStr = Object.entries(step.equalityMatching).length > 0
      ? Object.entries(step.equalityMatching).map(([l, r]) => `${l}→${r}`).join(', ')
      : '无';

    let phaseStr = '';
    switch (step.type) {
      case 'init': phaseStr = '初始化标号'; break;
      case 'build_equality': phaseStr = '构建 Equality Graph'; break;
      case 'augment': phaseStr = '增广匹配'; break;
      case 'update_labels': phaseStr = '更新标号'; break;
      case 'finish': phaseStr = state.isFinished ? '✅ 完成' : '—'; break;
      default: phaseStr = step.type;
    }

    return {
      'phase': phaseStr,
      'u-label': uStr,
      'v-label': vStr,
      'tight-count': `${step.tightEdges.length} 条`,
      'matching-status': `${Object.keys(step.equalityMatching).length}/3`,
      'total-cost': matchStr !== '无' ? matchStr : '—',
    };
  },
});

export default Hungarian;
