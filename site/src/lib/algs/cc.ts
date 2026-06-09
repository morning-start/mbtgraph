/**
 * cc.ts — 连通分量（Connected Components）可视化
 *
 * 算法思想：对无向图做 BFS 找所有连通分量，每个分量用一种颜色标识。
 *
 * 步骤设计：
 * 1. init：初始化所有节点为 default 状态
 * 2. start_component：开始一个新的连通分量（第一个未访问节点）
 * 3. visit_node：访问分量内的一个节点
 * 4. traverse_edge：探索到邻居的边
 * 5. finish_component：完成当前分量（批量染色）
 * 6. finish：所有分量都已识别
 *
 * 教学要点：连通分量 = 任意两节点间都有路径的极大子图。
 * 通过 BFS 顺序访问节点，发现新分量时切换"色系"。
 */

import { createAlgo, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

// ── Legend 声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },   // 未访问
  { domain: 'node', key: 'start' },     // 当前分量起点
  { domain: 'node', key: 'active' },    // 正在处理
  { domain: 'node', key: 'visited' },   // 当前分量已加入
  { domain: 'node', key: 'ready' },     // 下一个分量候选
  { domain: 'edge', key: 'tree' },      // 探索过的边（BFS 树边）
];

// ── 步骤类型 ──

export interface CCStep {
  type: 'init' | 'start_component' | 'visit_node' | 'traverse_edge' | 'finish_component' | 'finish';
  targets: string[];
  edges?: [string, string];
  componentIdx: number;       // 当前正在处理的分量索引（0-based）
  components: string[][];     // 已识别的分量（含当前正在构建的）
  message: string;
}

// ── 分量配色 ──
//
// 用 ColorRegistry 已有色，按访问过的分量循环选择。
const COMPONENT_COLORS = [
  '#22C55E', // visited 绿
  '#8B5CF6', // ready 紫
  '#F97316', // active 橙
  '#06B6D4', // sorted 青
  '#FBBF24', // relaxed 黄
  '#EF4444', // cycle 红
];

function colorForComponent(idx: number): string {
  return COMPONENT_COLORS[idx % COMPONENT_COLORS.length];
}

// ── 算法实现 ──

const CC = createAlgo<CCStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
  ): CCStep[] {
    const steps: CCStep[] = [];
    const visited: Record<string, boolean> = {};
    const components: string[][] = [];
    let componentIdx = 0;

    steps.push({
      type: 'init',
      targets: [],
      componentIdx: 0,
      components: [],
      message: '初始化：所有节点未访问',
    });

    // 遍历所有节点，未访问的作为新分量的种子
    for (const node of nodes) {
      const start = node.data.id;
      if (visited[start]) continue;

      // 开始新分量
      const currentComponent: string[] = [];
      componentIdx = components.length; // 新分量的索引
      steps.push({
        type: 'start_component',
        targets: [start],
        componentIdx,
        components: [...components, [start]],
        message: `开始分量 ${componentIdx + 1}：从节点 ${start} 出发`,
      });

      // BFS 找连通分量
      const queue: string[] = [start];
      visited[start] = true;
      currentComponent.push(start);

      steps.push({
        type: 'visit_node',
        targets: [start],
        componentIdx,
        components: [...components, [start]],
        message: `分量 ${componentIdx + 1}：访问 ${start}`,
      });

      let head = 0;
      while (head < queue.length) {
        const cur = queue[head];
        head++;
        const neighbors = adjList[cur] || [];
        for (const nbr of neighbors) {
          if (visited[nbr]) continue;
          visited[nbr] = true;
          queue.push(nbr);
          currentComponent.push(nbr);

          steps.push({
            type: 'traverse_edge',
            targets: [nbr],
            edges: [cur, nbr],
            componentIdx,
            components: [...components, currentComponent.slice()],
            message: `发现邻居 ${nbr}，加入分量 ${componentIdx + 1}`,
          });

          steps.push({
            type: 'visit_node',
            targets: [nbr],
            componentIdx,
            components: [...components, currentComponent.slice()],
            message: `分量 ${componentIdx + 1}：访问 ${nbr}`,
          });
        }
      }

      // 当前分量 BFS 完成
      components.push(currentComponent);
      steps.push({
        type: 'finish_component',
        targets: currentComponent.slice(),
        componentIdx,
        components: components.slice(),
        message: `分量 ${componentIdx + 1} 完成：包含 ${currentComponent.length} 个节点 [${currentComponent.join(', ')}]`,
      });
    }

    steps.push({
      type: 'finish',
      targets: [],
      componentIdx: -1,
      components: components.slice(),
      message: `✅ CC 完成：共 ${components.length} 个连通分量`,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: CCStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init': {
        // 重置所有节点为 default
        renderer.setNodesByFn?.((id: string) => ({
          backgroundColor: colors.default.value,
          borderColor: darken(colors.default.value),
          borderWidth: 2,
          width: 46,
          height: 46,
        }), mode);
        // 也尝试用循环 setNode（兼容旧 API）
        // 这里依赖 setNodesByFn，如不存在则跳过
        break;
      }

      case 'start_component': {
        const c = colorForComponent(step.componentIdx);
        renderer.setNode(step.targets[0], {
          backgroundColor: c,
          borderColor: darken(c),
          borderWidth: 4,
          width: 52,
          height: 52,
        }, mode, speed);
        break;
      }

      case 'visit_node': {
        const c = colorForComponent(step.componentIdx);
        renderer.setNode(step.targets[0], {
          backgroundColor: c,
          borderColor: darken(c),
          borderWidth: 3,
          width: 49,
          height: 49,
        }, mode, speed);
        break;
      }

      case 'traverse_edge': {
        if (step.edges) {
          const [src, tgt] = step.edges;
          renderer.setEdge(src, tgt, {
            lineColor: colors['edge_tree'].value,
            width: 3,
            opacity: 0.9,
          }, mode, false, speed);
        }
        break;
      }

      case 'finish_component': {
        // 给整个分量上色
        const c = colorForComponent(step.componentIdx);
        for (const id of step.targets) {
          renderer.setNode(id, {
            backgroundColor: c,
            borderColor: darken(c),
            borderWidth: 3,
          }, mode, speed);
        }
        break;
      }

      case 'finish': {
        // 最终态：所有分量各自着色
        for (let i = 0; i < step.components.length; i++) {
          const c = colorForComponent(i);
          for (const id of step.components[i]) {
            renderer.setNode(id, {
              backgroundColor: c,
              borderColor: darken(c),
              borderWidth: 3,
            }, mode);
          }
        }
        break;
      }
    }
  },

  getUIData(step: CCStep | null, state: UIState): Record<string, string> {
    if (!step) {
      return {
        'current-component': '—',
        'current-node': '—',
        'component-size': '—',
        'total-components': '0',
      };
    }
    const compSize = step.components[step.componentIdx]?.length ?? 0;
    return {
      'current-component': step.componentIdx >= 0 ? `C${step.componentIdx + 1}` : '—',
      'current-node': step.targets[0] ?? '—',
      'component-size': compSize > 0 ? `${compSize} 节点` : '—',
      'total-components': `${step.components.length}`,
    };
  },
});

export default CC;
