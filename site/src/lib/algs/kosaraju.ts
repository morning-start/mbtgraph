/**
 * kosaraju.ts — Kosaraju 强连通分量可视化
 *
 * 算法思想（两遍 DFS）：
 *   第一遍：在原图上 DFS，记录完成顺序（后序压栈）
 *   第二遍：在转置图上按完成顺序逆序 DFS，每次找到的即为一个 SCC
 *
 * 测试图：6 节点 · 7 边 · 有向图
 *   SCC A: {0, 1, 2}  SCC B: {3, 4}  SCC C: {5}
 *
 * 步骤设计：
 * 1. init：初始化
 * 2. dfs1_enter：第一遍 DFS 进入节点
 * 3. dfs1_exit：第一遍 DFS 离开节点（压栈）
 * 4. reverse_graph：构建转置图
 * 5. dfs2_enter：第二遍 DFS 进入节点（发现 SCC 成员）
 * 6. finish_scc：找到一个 SCC
 * 7. finish：完成
 *
 * 教学要点：
 * - 为什么转置？转置后反向处理可确保不会跨 SCC
 * - 完成栈 = 拓扑排序的逆序
 */
import { createAlgo, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

// ── Legend 声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },   // 未访问
  { domain: 'node', key: 'active' },    // 当前正在 DFS
  { domain: 'node', key: 'visited' },   // 第一遍已完成 / 已分配 SCC
  { domain: 'edge', key: 'default' },   // 普通边
  { domain: 'edge', key: 'tree' },      // DFS 树边
  { domain: 'edge', key: 'active' },    // 当前边
];

// ── 步骤类型 ──

export interface KosarajuStep {
  type: 'init' | 'dfs1_enter' | 'dfs1_exit' | 'reverse_graph' | 'dfs2_enter' | 'finish_scc' | 'finish';
  targets: string[];
  current: string | null;
  edge?: [string, string];
  phase: 1 | 2;                 // 当前算法阶段
  stack: string[];              // 完成栈（第一遍）
  sccs: string[][];             // 已找到的 SCC
  visited1: Record<string, boolean>;  // 第一遍访问状态
  visited2: Record<string, boolean>;  // 第二遍访问状态
  message: string;
}

// ── SCC 配色 ──

const SCC_COLORS = [
  '#22C55E', '#8B5CF6', '#F97316', '#06B6D4', '#FBBF24', '#EF4444',
];

function colorForSCC(idx: number): string {
  return SCC_COLORS[idx % SCC_COLORS.length];
}

// ── 算法实现 ──

const Kosaraju = createAlgo<KosarajuStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
  ): KosarajuStep[] {
    const ids = nodes.map(n => n.data.id);
    const N = ids.length;
    const steps: KosarajuStep[] = [];

    if (N === 0) {
      steps.push({
        type: 'finish', targets: [], current: null, phase: 2,
        stack: [], sccs: [], visited1: {}, visited2: {},
        message: '图为空，无节点',
      });
      return steps;
    }

    const visited1: Record<string, boolean> = {};
    const visited2: Record<string, boolean> = {};
    const stack: string[] = [];
    const sccs: string[][] = [];

    function initVisited(): Record<string, boolean> {
      const r: Record<string, boolean> = {};
      for (const id of ids) r[id] = false;
      return r;
    }

    // 初始化
    const initV1 = initVisited();
    const initV2 = initVisited();
    steps.push({
      type: 'init', targets: [], current: null, phase: 1,
      stack: [], sccs: [], visited1: initV1, visited2: initV2,
      message: `初始化：两遍 DFS，共 ${N} 个节点`,
    });

    // ── 第一遍 DFS ──
    function dfs1(u: string): void {
      visited1[u] = true;

      steps.push({
        type: 'dfs1_enter', targets: [u], current: u, phase: 1,
        stack: stack.slice(), sccs: sccs.slice(),
        visited1: { ...visited1 }, visited2: { ...visited2 },
        message: `第一遍·DFS 进入 ${u}`,
      });

      const neighbors = adjList[u] || [];
      for (const v of neighbors) {
        if (!visited1[v]) {
          steps.push({
            type: 'dfs1_enter', targets: [v], current: v, phase: 1,
            edge: [u, v],
            stack: stack.slice(), sccs: sccs.slice(),
            visited1: { ...visited1 }, visited2: { ...visited2 },
            message: `第一遍·树边 ${u}→${v}`,
          });
          dfs1(v);
        }
      }

      stack.push(u);
      steps.push({
        type: 'dfs1_exit', targets: [u], current: u, phase: 1,
        stack: stack.slice(), sccs: sccs.slice(),
        visited1: { ...visited1 }, visited2: { ...visited2 },
        message: `第一遍·完成 ${u}，压栈（栈: [${stack.join(', ')}]）`,
      });
    }

    for (const id of ids) {
      if (!visited1[id]) {
        dfs1(id);
      }
    }

    // ── 构建转置图 ──
    const revAdjList: Record<string, string[]> = {};
    for (const id of ids) revAdjList[id] = [];
    for (const u of ids) {
      for (const v of adjList[u] || []) {
        revAdjList[v].push(u);
      }
    }

    steps.push({
      type: 'reverse_graph', targets: [], current: null, phase: 2,
      stack: stack.slice(), sccs: sccs.slice(),
      visited1: { ...visited1 }, visited2: { ...visited2 },
      message: `转置图构建完成：边反向，共 ${Object.values(revAdjList).flat().length} 条反向边`,
    });

    // ── 第二遍 DFS ──
    function dfs2(u: string, currentSCC: string[]): void {
      visited2[u] = true;
      currentSCC.push(u);

      steps.push({
        type: 'dfs2_enter', targets: [u], current: u, phase: 2,
        stack: stack.slice(), sccs: sccs.slice(),
        visited1: { ...visited1 }, visited2: { ...visited2 },
        message: `第二遍·DFS 进入 ${u}（当前分量: [${currentSCC.join(', ')}]）`,
      });

      const neighbors = revAdjList[u] || [];
      for (const v of neighbors) {
        if (!visited2[v]) {
          steps.push({
            type: 'dfs2_enter', targets: [v], current: v, phase: 2,
            edge: [u, v],
            stack: stack.slice(), sccs: sccs.slice(),
            visited1: { ...visited1 }, visited2: { ...visited2 },
            message: `第二遍·转置边 ${u}→${v}`,
          });
          dfs2(v, currentSCC);
        }
      }
    }

    while (stack.length > 0) {
      const v = stack.pop()!;
      if (!visited2[v]) {
        const currentSCC: string[] = [];
        dfs2(v, currentSCC);
        sccs.push(currentSCC.slice());

        steps.push({
          type: 'finish_scc', targets: currentSCC.slice(), current: null, phase: 2,
          stack: stack.slice(), sccs: sccs.slice(),
          visited1: { ...visited1 }, visited2: { ...visited2 },
          message: `🎉 发现 SCC #${sccs.length}：{${currentSCC.join(', ')}}`,
        });
      }
    }

    // finish
    steps.push({
      type: 'finish', targets: [], current: null, phase: 2,
      stack: [], sccs: sccs.slice(),
      visited1: { ...visited1 }, visited2: { ...visited2 },
      message: `✅ Kosaraju 完成！共 ${sccs.length} 个强连通分量`,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: KosarajuStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    const allIds = Object.keys(step.visited1);

    // 收集已分配到 SCC 的节点
    const nodeSCC: Record<string, number> = {};
    for (let i = 0; i < step.sccs.length; i++) {
      for (const id of step.sccs[i]) {
        nodeSCC[id] = i;
      }
    }

    // 辅助：渲染所有节点
    function renderNodes(activeId?: string) {
      for (const id of allIds) {
        if (id === activeId) {
          renderer.setNode(id, {
            backgroundColor: colors['node_active'].value,
            borderColor: darken(colors['node_active'].value),
            borderWidth: 4,
            width: 52,
            height: 52,
          }, mode, speed);
        } else if (nodeSCC[id] !== undefined) {
          const c = colorForSCC(nodeSCC[id]);
          renderer.setNode(id, {
            backgroundColor: c,
            borderColor: darken(c),
            borderWidth: 3,
            width: 49,
            height: 49,
          }, mode, speed);
        } else if (step.visited1[id] && step.phase === 1) {
          renderer.setNode(id, {
            backgroundColor: colors['node_visited'].value,
            borderColor: darken(colors['node_visited'].value),
            borderWidth: 2,
            width: 46,
            height: 46,
          }, mode, speed);
        } else if (step.visited2[id] && step.phase === 2) {
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
    }

    switch (step.type) {
      case 'init': {
        renderNodes();
        break;
      }

      case 'dfs1_enter': {
        renderNodes(step.current ?? undefined);
        if (step.edge) {
          renderer.setEdge(step.edge[0], step.edge[1], {
            lineColor: colors['edge_active'].value,
            width: 3,
            opacity: 0.9,
          }, mode, speed);
        }
        break;
      }

      case 'dfs1_exit': {
        renderNodes(step.current ?? undefined);
        break;
      }

      case 'reverse_graph': {
        // 第一遍已完成，所有 visited1 的节点用 visited 色
        renderNodes();
        break;
      }

      case 'dfs2_enter': {
        renderNodes(step.current ?? undefined);
        if (step.edge) {
          renderer.setEdge(step.edge[1], step.edge[0], {
            lineColor: colors['edge_active'].value,
            width: 3,
            opacity: 0.9,
            lineStyle: 'dashed',
          }, mode, speed);
        }
        break;
      }

      case 'finish_scc': {
        renderNodes();
        const lastScc = step.sccs[step.sccs.length - 1];
        if (lastScc) {
          const c = colorForSCC(step.sccs.length - 1);
          for (const id of lastScc) {
            renderer.setNode(id, {
              backgroundColor: c,
              borderColor: darken(c),
              borderWidth: 4,
              width: 52,
              height: 52,
            }, mode, speed);
          }
        }
        break;
      }

      case 'finish': {
        for (let i = 0; i < step.sccs.length; i++) {
          const c = colorForSCC(i);
          for (const id of step.sccs[i]) {
            renderer.setNode(id, {
              backgroundColor: c,
              borderColor: darken(c),
              borderWidth: 3,
              width: 49,
              height: 49,
            }, mode, speed);
          }
        }
        break;
      }
    }
  },

  getUIData(step: KosarajuStep | null, state: UIState): Record<string, string> {
    if (!step) {
      return {
        'phase': '—',
        'current-node': '—',
        'stack': '[ ]',
        'scc-found': '0',
        'status': '—',
      };
    }
    const phaseStr = step.phase === 1 ? '第一遍 DFS（原图）' : '第二遍 DFS（转置图）';
    const stackStr = step.stack.length > 0 ? `[${step.stack.join(', ')}]` : '[ ]';
    const sccStr = step.sccs.map((s, i) => `C${i + 1}:{${s.join(',')}}`).join('; ');

    return {
      'phase': phaseStr,
      'current-node': step.current ?? '—',
      'stack': stackStr,
      'scc-found': step.sccs.length > 0 ? `C${step.sccs.length}` : '—',
      'status': sccStr || '—',
    };
  },
});

export default Kosaraju;
