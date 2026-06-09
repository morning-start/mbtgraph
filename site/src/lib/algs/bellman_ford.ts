/**
 * bellman_ford.ts — Bellman-Ford 最短路径可视化
 *
 * 算法思想：对每条边做 V-1 轮松弛操作，再检查负环。
 * 能处理负权边（Dijkstra 不能），但速度较慢 O(VE)。
 *
 * 测试图：6 节点 · 7 边 · 带权有向图
 *   关键边 2→1(-2)：使 0→2→1 = 1 比直达 0→1=4 更短
 *
 * 步骤设计：
 * 1. init：dist[0]=0，其他 = ∞
 * 2. relax_each：对每条边尝试松弛，展示是否更新
 * 3. iter_end：一轮迭代结束，展示当前距离状态
 * 4. finish：完成或检测到负环
 *
 * 教学要点：
 * - V-1 轮必然收敛（无负环时）
 * - 第 V 轮若仍有更新 → 存在负环
 * - 负权边可使路径变短（Dijkstra 贪心策略会失败）
 */
import { createAlgo, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

// ── Legend 声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'start' },     // 源点
  { domain: 'node', key: 'default' },   // 未确定
  { domain: 'node', key: 'active' },    // 当前更新
  { domain: 'node', key: 'visited' },   // 已收敛
  { domain: 'edge', key: 'default' },   // 未处理
  { domain: 'edge', key: 'active' },    // 正在松弛
  { domain: 'edge', key: 'tree' },      // 松弛成功的边
];

// ── 步骤类型 ──

export interface BellmanFordStep {
  type: 'init' | 'relax_each' | 'iter_end' | 'negative_cycle' | 'finish';
  targets: string[];
  edge?: [string, string];
  weight: number;
  dist: Record<string, number>;
  parent: Record<string, string | null>;
  iteration: number;           // 当前轮次（1-based）
  isRelaxed?: boolean;         // 本轮当前边是否更新了距离
  relaxedInIter: number;       // 本轮已更新的边数
  totalIterations: number;     // V-1
  message: string;
}

// ── 算法实现 ──

const BellmanFord = createAlgo<BellmanFordStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights?: Record<string, number>,
    startNode?: string,
  ): BellmanFordStep[] {
    const ids = nodes.map(n => n.data.id);
    const N = ids.length;
    const steps: BellmanFordStep[] = [];
    const startId = startNode || ids[0];
    const maxIter = N - 1;

    if (N === 0) {
      steps.push({
        type: 'finish', targets: [], weight: 0,
        dist: {}, parent: {}, iteration: 0, relaxedInIter: 0, totalIterations: 0,
        message: '图为空，无节点',
      });
      return steps;
    }

    // 初始化距离
    const dist: Record<string, number> = {};
    const parent: Record<string, string | null> = {};
    for (const id of ids) {
      dist[id] = id === startId ? 0 : Infinity;
      parent[id] = null;
    }

    // 构建边列表（所有有向边）
    const edgeList: Array<{ src: string; tgt: string; weight: number }> = [];
    if (edgeWeights) {
      for (const [key, w] of Object.entries(edgeWeights)) {
        const [src, tgt] = key.split('-');
        edgeList.push({ src, tgt, weight: w });
      }
    }

    function snapshot(): Record<string, number> {
      return { ...dist };
    }

    // init
    steps.push({
      type: 'init',
      targets: [startId],
      weight: 0,
      dist: snapshot(),
      parent: { ...parent },
      iteration: 0,
      relaxedInIter: 0,
      totalIterations: maxIter,
      message: `初始化：dist[${startId}]=0，其他=∞，最大迭代 ${maxIter} 轮`,
    });

    // V-1 轮迭代
    let converged = false;
    for (let iter = 1; iter <= maxIter; iter++) {
      let relaxedCount = 0;

      for (const edge of edgeList) {
        const { src, tgt, weight } = edge;
        if (dist[src] === Infinity) continue; // src 尚不可达

        const newDist = dist[src] + weight;
        const isRelaxed = newDist < dist[tgt];

        steps.push({
          type: 'relax_each',
          targets: [src, tgt],
          edge: [src, tgt],
          weight,
          dist: snapshot(),
          parent: { ...parent },
          iteration: iter,
          isRelaxed,
          relaxedInIter: relaxedCount,
          totalIterations: maxIter,
          message: isRelaxed
            ? `第${iter}轮·松弛 ${src}→${tgt}：dist[${tgt}] = ${dist[tgt] === Infinity ? '∞' : dist[tgt]} → ${newDist} ✓`
            : `第${iter}轮·松弛 ${src}→${tgt}：dist[${tgt}] = ${dist[tgt] === Infinity ? '∞' : dist[tgt]}，无需更新`,
        });

        if (isRelaxed) {
          dist[tgt] = newDist;
          parent[tgt] = src;
          relaxedCount++;
        }
      }

      steps.push({
        type: 'iter_end',
        targets: [],
        weight: 0,
        dist: snapshot(),
        parent: { ...parent },
        iteration: iter,
        relaxedInIter: relaxedCount,
        totalIterations: maxIter,
        message: relaxedCount > 0
          ? `第${iter}轮结束：更新了 ${relaxedCount} 条边`
          : `第${iter}轮结束：无更新，提前收敛 ✓`,
      });

      if (relaxedCount === 0) {
        converged = true;
        break;
      }
    }

    // 检测负环（第 V 轮）
    let hasNegativeCycle = false;
    if (!converged) {
      for (const edge of edgeList) {
        const { src, tgt, weight } = edge;
        if (dist[src] === Infinity) continue;
        if (dist[src] + weight < dist[tgt]) {
          hasNegativeCycle = true;
          steps.push({
            type: 'negative_cycle',
            targets: [src, tgt],
            edge: [src, tgt],
            weight,
            dist: snapshot(),
            parent: { ...parent },
            iteration: maxIter + 1,
            relaxedInIter: 0,
            totalIterations: maxIter,
            message: `⛔ 负环检测！第 ${maxIter + 1} 轮边 ${src}→${tgt} 仍可松弛`,
          });
          break;
        }
      }
    }

    steps.push({
      type: 'finish',
      targets: [],
      weight: 0,
      dist: snapshot(),
      parent: { ...parent },
      iteration: hasNegativeCycle ? maxIter + 1 : (converged ? steps.filter(s => s.type === 'iter_end').length : maxIter),
      relaxedInIter: 0,
      totalIterations: maxIter,
      message: hasNegativeCycle
        ? `⛔ 检测到负环！图无最短路径`
        : `✅ Bellman-Ford 完成！${converged ? '提前收敛' : maxIter + ' 轮后结束'}`,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: BellmanFordStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    const allIds = Object.keys(step.dist);
    const minDist = Math.min(...allIds.map(id => step.dist[id]));
    const maxDist = Math.max(...allIds.filter(id => step.dist[id] < Infinity).map(id => step.dist[id]));

    // 按距离着色（距离越小越暖色）
    function colorByDist(activeSet: Set<string> = new Set()) {
      for (const id of allIds) {
        if (activeSet.has(id)) continue;
        const d = step.dist[id];
        if (d === 0) {
          renderer.setNode(id, {
            backgroundColor: colors.start.value,
            borderColor: darken(colors.start.value),
            borderWidth: 4,
            width: 52,
            height: 52,
          }, mode, speed);
        } else if (d === Infinity) {
          renderer.setNode(id, {
            backgroundColor: colors.default.value,
            borderColor: darken(colors.default.value),
            borderWidth: 2,
            width: 46,
            height: 46,
          }, mode, speed);
        } else {
          renderer.setNode(id, {
            backgroundColor: colors['node_visited'].value,
            borderColor: darken(colors['node_visited'].value),
            borderWidth: 2,
            width: 46,
            height: 46,
          }, mode, speed);
        }
      }
    }

    switch (step.type) {
      case 'init': {
        colorByDist();
        break;
      }

      case 'relax_each': {
        colorByDist();
        if (step.edge) {
          const [src, tgt] = step.edge;
          if (step.isRelaxed) {
            renderer.setEdge(src, tgt, {
              lineColor: colors['edge_active'].value,
              width: 4,
              opacity: 1.0,
            }, mode, speed);
            renderer.setNode(tgt, {
              backgroundColor: colors['node_active'].value,
              borderColor: darken(colors['node_active'].value),
              borderWidth: 4,
              width: 52,
              height: 52,
            }, mode, speed);
          } else {
            renderer.setEdge(src, tgt, {
              lineColor: '#94A3B8',
              width: 1.5,
              opacity: 0.45,
              lineStyle: 'dashed',
            }, mode, speed);
          }
        }
        break;
      }

      case 'iter_end': {
        colorByDist();
        // 迭代边界视觉标志：给所有已确定距离的节点加粗边框
        for (const id of allIds) {
          const d = step.dist[id];
          if (d !== Infinity && d !== 0) {
            renderer.setNode(id, {
              borderWidth: 4,
              borderColor: '#94A3B8',
            }, mode, speed);
          }
        }
        break;
      }

      case 'negative_cycle': {
        colorByDist();
        if (step.edge) {
          const [src, tgt] = step.edge;
          renderer.setNode(src, {
            backgroundColor: '#EF4444',
            borderColor: '#DC2626',
            borderWidth: 4,
            width: 52,
            height: 52,
          }, mode, speed);
          renderer.setNode(tgt, {
            backgroundColor: '#EF4444',
            borderColor: '#DC2626',
            borderWidth: 4,
            width: 52,
            height: 52,
          }, mode, speed);
          renderer.setEdge(src, tgt, {
            lineColor: '#EF4444',
            width: 5,
            opacity: 1.0,
          }, mode, speed);
        }
        break;
      }

      case 'finish': {
        if (step.message.includes('负环')) {
          // 负环场景已经在 negative_cycle 步骤渲染，这里保持
          break;
        }
        // 正常完成：用距离深浅着色
        for (const id of allIds) {
          const d = step.dist[id];
          if (d === 0) {
            renderer.setNode(id, {
              backgroundColor: colors.start.value,
              borderColor: darken(colors.start.value),
              borderWidth: 4,
              width: 52,
              height: 52,
            }, mode, speed);
          } else if (d < Infinity) {
            renderer.setNode(id, {
              backgroundColor: colors['node_visited'].value,
              borderColor: darken(colors['node_visited'].value),
              borderWidth: 3,
              width: 49,
              height: 49,
            }, mode, speed);
          } else {
            renderer.setNode(id, {
              backgroundColor: colors.default.value,
              borderColor: darken(colors.default.value),
              borderWidth: 2,
              width: 46,
              height: 46,
            }, mode, speed);
          }
        }
        break;
      }
    }
  },

  getUIData(step: BellmanFordStep | null, state: UIState): Record<string, string> {
    if (!step) {
      return {
        'iteration': '—',
        'current-edge': '—',
        'dist-table': '—',
        'has-update': '—',
      };
    }
    const distStr = Object.entries(step.dist)
      .map(([id, d]) => `${id}:${d === Infinity ? '∞' : d}`)
      .join(', ');
    return {
      'iteration': step.iteration > 0 ? `第 ${step.iteration} 轮` : (state.isFinished ? '完成' : '初始'),
      'current-edge': step.edge ? `${step.edge[0]}→${step.edge[1]}` : '—',
      'dist-table': `[${distStr}]`,
      'has-update': step.type === 'relax_each'
        ? (step.isRelaxed ? '✓ 更新' : '— 不变')
        : (step.type === 'iter_end' ? (step.relaxedInIter > 0 ? `${step.relaxedInIter} 条更新` : '已收敛') : '—'),
    };
  },
});

export default BellmanFord;
