/**
 * coloring.ts — 图着色可视化算法模块
 *
 * 基于 DSATUR 的节点逐次着色过程，展示颜色冲突和饱和度变化。
 */

import { createAlgo, snapshot, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

const COLOR_PALETTE = ['#EF4444', '#3B82F6', '#22C55E', '#F59E0B', '#A855F7', '#EC4899'];

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
];

export interface ColoringStep {
  type: 'init' | 'color_node' | 'conflict' | 'finish';
  targets: string[];
  message: string;
  colors: Record<string, number>;
  order: string[];
  palette: string[];
}

const Coloring = createAlgo<ColoringStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
  ): ColoringStep[] {
    const steps: ColoringStep[] = [];
    const colors: Record<string, number> = {};
    const nodeIds = nodes.map(n => n.data.id);
    const order: string[] = [];

    for (const nid of nodeIds) colors[nid] = -1;

    steps.push({
      type: 'init', targets: [],
      message: `开始图着色: 共 ${nodeIds.length} 个节点`,
      colors: snapshot(colors), order: [], palette: COLOR_PALETTE,
    });

    // 简单贪心着色顺序
    for (const nid of nodeIds) {
      const neighborColors = new Set<number>();
      const neighbors = adjList[nid] || [];
      for (const nbr of neighbors) {
        if (colors[nbr] >= 0) neighborColors.add(colors[nbr]);
      }
      let useColor = 0;
      while (neighborColors.has(useColor)) useColor++;

      colors[nid] = useColor;
      order.push(nid);

      steps.push({
        type: 'color_node', targets: [nid],
        message: `节点 ${nid}: 分配颜色 ${useColor} (${COLOR_PALETTE[useColor]})`,
        colors: snapshot(colors), order: [...order], palette: COLOR_PALETTE,
      });
    }

    steps.push({
      type: 'finish', targets: [],
      message: `✅ 着色完成! 共使用 ${new Set(Object.values(colors)).size} 种颜色`,
      colors: snapshot(colors), order, palette: COLOR_PALETTE,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: ColoringStep, mode: RenderMode, speed: number, _colors: ColorMap): void {
    // 保持所有已着色节点的颜色
    for (const nid in step.colors) {
      const c = step.colors[nid];
      if (c >= 0) {
        const hex = COLOR_PALETTE[c % COLOR_PALETTE.length];
        renderer.setNode(nid, {
          backgroundColor: hex,
          borderColor: darken(hex),
          borderWidth: 3,
        }, mode, 80);
      } else {
        renderer.setNode(nid, {
          backgroundColor: '#374151',
          borderColor: '#4B5563', borderWidth: 2,
        }, mode, 80);
      }
    }

    // 活跃节点高亮
    if (step.targets[0] && step.type === 'color_node') {
      const nid = step.targets[0];
      const c = step.colors[nid];
      if (c >= 0) {
        const hex = COLOR_PALETTE[c % COLOR_PALETTE.length];
        renderer.setNode(nid, {
          backgroundColor: hex,
          borderColor: '#FBBF24',
          borderWidth: 4, width: 52, height: 52,
        }, mode, speed);
      }
    }
  },

  getUIData(step: ColoringStep | null, state: UIState): Record<string, string> {
    if (!step || state.isFinished) {
      return { 'current-node': '—', 'colors-used': '-', 'assign-order': '-', 'color-map': '-' };
    }
    const used = new Set(Object.values(step.colors).filter(c => c >= 0)).size;
    return {
      'current-node': step.targets[0] || '—',
      'colors-used': String(used),
      'assign-order': '[' + step.order.join(', ') + ']',
      'color-map': formatColorMap(step.colors),
    };
  },
});

function formatColorMap(colors: Record<string, number>): string {
  const parts: string[] = [];
  for (const k in colors) {
    if (colors[k] >= 0) parts.push(`${k}:C${colors[k]}`);
  }
  return '{' + parts.join(', ') + '}';
}

export default Coloring;
