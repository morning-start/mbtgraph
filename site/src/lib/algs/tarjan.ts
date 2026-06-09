/**
 * tarjan.ts — Tarjan 强连通分量可视化
 *
 * 算法思想：DFS 遍历，为每个节点记录 disc（发现时间）和 lowlink（可达的最早祖先），
 * 当 lowlink == disc 时发现一个 SCC。
 *
 * 测试图：6 节点 · 7 边 · 有向图
 *   SCC A: {0, 1, 2}  (0→1→2→0)
 *   SCC B: {3, 4}     (3→4→3)
 *   SCC C: {5}        (单独节点)
 *
 * 步骤设计：
 * 1. init：初始化所有节点未访问
 * 2. dfs_enter：进入节点，分配 disc/lowlink
 * 3. dfs_explore：探索出边（是否已在栈中决定是否更新 lowlink）
 * 4. dfs_backtrack：回溯，更新父节点 lowlink
 * 5. found_scc：发现一个 SCC（lowlink == disc），弹出栈中节点
 * 6. finish：所有 SCC 识别完成
 *
 * 教学要点：
 * - lowlink = min(disc[u], disc[v] for each back edge, lowlink[child])
 * - 栈中存放的是当前 DFS 路径上尚未分配 SCC 的节点
 * - 跨 SCC 的边（横叉边）遇到已分配 SCC 的节点时不更新 lowlink
 */
import { createAlgo, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

// ── Legend 声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },   // 未访问
  { domain: 'node', key: 'active' },    // 正在处理（在栈中）
  { domain: 'node', key: 'visited' },   // 已分配 SCC
  { domain: 'edge', key: 'default' },   // 未探索
  { domain: 'edge', key: 'tree' },      // DFS 树边
  { domain: 'edge', key: 'active' },    // 当前探索的边
  { domain: 'edge', key: 'cross' },     // 横叉边/返祖边（不形成 SCC）
];

// ── 步骤类型 ──

export interface TarjanStep {
  type: 'init' | 'dfs_enter' | 'dfs_explore' | 'dfs_backtrack' | 'found_scc' | 'finish';
  targets: string[];
  current: string | null;
  edge?: [string, string];
  disc: Record<string, number>;
  lowlink: Record<string, number>;
  stack: string[];
  sccs: string[][];
  sccIdx: number;
  nodeIds: string[];  // 所有节点 ID（用于 init 等栈/SCC 为空的步骤）
  message: string;
}

// ── SCC 配色 ──

const SCC_COLORS = [
  '#22C55E', // 绿
  '#8B5CF6', // 紫
  '#F97316', // 橙
  '#06B6D4', // 青
  '#FBBF24', // 黄
  '#EF4444', // 红
];

function colorForSCC(idx: number): string {
  return SCC_COLORS[idx % SCC_COLORS.length];
}

// ── 算法实现 ──

const Tarjan = createAlgo<TarjanStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
  ): TarjanStep[] {
    const ids = nodes.map(n => n.data.id);
    const N = ids.length;
    const steps: TarjanStep[] = [];

    if (N === 0) {
      steps.push({
        type: 'finish', targets: [], current: null,
        disc: {}, lowlink: {}, stack: [], sccs: [], sccIdx: 0,
        nodeIds: ids,
        message: '图为空，无节点',
      });
      return steps;
    }

    const disc: Record<string, number> = {};
    const lowlink: Record<string, number> = {};
    const inStack: Record<string, boolean> = {};
    const stack: string[] = [];
    const sccs: string[][] = [];
    let time = 0;
    let done = false; // 防止 finish 重复

    // 辅助：构建当前状态的 snapshot
    function snapshotDiscLowlink(): [Record<string, number>, Record<string, number>] {
      return [{ ...disc }, { ...lowlink }];
    }

    function dfs(u: string): void {
      if (done) return;
      disc[u] = time;
      lowlink[u] = time;
      time++;
      stack.push(u);
      inStack[u] = true;

      const [dSnap, lSnap] = snapshotDiscLowlink();
      steps.push({
        type: 'dfs_enter',
        targets: [u],
        current: u,
        disc: dSnap,
        lowlink: lSnap,
        stack: stack.slice(),
        sccs: sccs.slice(),
        sccIdx: sccs.length,
        nodeIds: ids,
        message: `进入节点 ${u}：disc=${disc[u]}，lowlink=${lowlink[u]}`,
      });

      const neighbors = adjList[u] || [];
      for (const v of neighbors) {
        if (done) return;
        if (disc[v] === undefined) {
          // 树边：递归 DFS
          const [dSnap2, lSnap2] = snapshotDiscLowlink();
          steps.push({
            type: 'dfs_explore',
            targets: [u, v],
            current: u,
            edge: [u, v],
            disc: dSnap2,
            lowlink: lSnap2,
            stack: stack.slice(),
            sccs: sccs.slice(),
            sccIdx: sccs.length,
            nodeIds: ids,
            message: `DFS 树边 ${u}→${v}（v 未访问，将递归）`,
          });

          dfs(v);

          // 回溯：更新 lowlink
          lowlink[u] = Math.min(lowlink[u], lowlink[v]);
          const [dSnap3, lSnap3] = snapshotDiscLowlink();
          steps.push({
            type: 'dfs_backtrack',
            targets: [u, v],
            current: u,
            disc: dSnap3,
            lowlink: lSnap3,
            stack: stack.slice(),
            sccs: sccs.slice(),
            sccIdx: sccs.length,
            nodeIds: ids,
            message: `回溯 ${v}→${u}：lowlink[${u}] = min(${lowlink[u]}, ${lowlink[v]}) = ${lowlink[u]}`,
          });
        } else if (inStack[v]) {
          // 返祖边（back edge）或横叉边（cross edge，指向栈中节点）
          const oldLowlink = lowlink[u];
          lowlink[u] = Math.min(lowlink[u], disc[v]);
          const [dSnap4, lSnap4] = snapshotDiscLowlink();
          steps.push({
            type: 'dfs_explore',
            targets: [u, v],
            current: u,
            edge: [u, v],
            disc: dSnap4,
            lowlink: lSnap4,
            stack: stack.slice(),
            sccs: sccs.slice(),
            sccIdx: sccs.length,
            nodeIds: ids,
            message: `返祖边 ${u}→${v}（v 在栈中）：lowlink[${u}] = min(${oldLowlink}, disc[${v}]=${disc[v]}) = ${lowlink[u]}`,
          });
        } else {
          // 横叉边：指向已分配 SCC 的节点（忽略）
          const [dSnap5, lSnap5] = snapshotDiscLowlink();
          steps.push({
            type: 'dfs_explore',
            targets: [u, v],
            current: u,
            edge: [u, v],
            disc: dSnap5,
            lowlink: lSnap5,
            stack: stack.slice(),
            sccs: sccs.slice(),
            sccIdx: sccs.length,
            nodeIds: ids,
            message: `横叉边 ${u}→${v}（v 已分配 SCC）：忽略，不更新 lowlink`,
          });
        }
      }

      // 检查是否为 SCC 根节点
      if (lowlink[u] === disc[u]) {
        const scc: string[] = [];
        while (stack.length > 0) {
          const w = stack.pop()!;
          inStack[w] = false;
          scc.push(w);
          if (w === u) break;
        }
        scc.reverse();
        sccs.push(scc);

        const [dSnap6, lSnap6] = snapshotDiscLowlink();
        steps.push({
          type: 'found_scc',
          targets: scc.slice(),
          current: u,
          disc: dSnap6,
          lowlink: lSnap6,
          stack: stack.slice(),
          sccs: sccs.slice(),
          sccIdx: sccs.length,
          nodeIds: ids,
          message: `🎉 发现 SCC #${sccs.length}：{${scc.join(', ')}}，lowlink=${lowlink[u]} == disc=${disc[u]}`,
        });
      }
    }

    // init step
    steps.push({
      type: 'init', targets: [], current: null,
      disc: {}, lowlink: {}, stack: [], sccs: [], sccIdx: 0,
      nodeIds: ids,
      message: `初始化：${N} 个节点，准备 Tarjan SCC 算法（DFS + lowlink）`,
    });

    // 遍历所有节点（可能有不连通的）
    for (const id of ids) {
      if (disc[id] === undefined && !done) {
        dfs(id);
      }
    }

    if (!done) {
      done = true;
      steps.push({
        type: 'finish', targets: [], current: null,
        disc: { ...disc }, lowlink: { ...lowlink },
        stack: [], sccs: sccs.slice(), sccIdx: sccs.length,
        nodeIds: ids,
        message: `✅ Tarjan 完成！共 ${sccs.length} 个强连通分量`,
      });
    }

    return steps;
  },

  renderStep(renderer: VizRenderer, step: TarjanStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    // 所有节点 ID（init 时 disc/sccs 为空，用 nodeIds 兜底）
    const allIds = Object.keys(step.disc).length > 0
      ? Object.keys(step.disc)
      : (step.sccs.length > 0 ? step.sccs.flat() : step.nodeIds);

    // 染所有节点
    //   activeId: 当前正在处理的节点（active 色 + 放大）
    //   stackSet: 栈中节点（用不同的"in-stack"色调）
    //   sccCompleted: 已分配到 SCC 的节点
    function renderAllNodes(activeId?: string, stackSet?: Set<string>, sccCompleted?: Set<string>) {
      const nodeSCC: Record<string, number> = {};
      for (let i = 0; i < step.sccs.length; i++) {
        for (const id of step.sccs[i]) {
          nodeSCC[id] = i;
        }
      }

      const knownIds = new Set<string>([...allIds, ...Object.keys(nodeSCC)]);
      const inStack = stackSet ?? new Set<string>();

      for (const id of knownIds) {
        if (id === activeId) {
          // 当前节点：亮色 + 放大
          renderer.setNode(id, {
            backgroundColor: colors['node_active'].value,
            borderColor: darken(colors['node_active'].value),
            borderWidth: 4,
            width: 52,
            height: 52,
          }, mode, speed);
        } else if (inStack.has(id)) {
          // 栈中其他节点（非当前）：半透明橙色边框
          renderer.setNode(id, {
            backgroundColor: '#FEF3C7',
            borderColor: '#F59E0B',
            borderWidth: 3,
            width: 48,
            height: 48,
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
        } else if (sccCompleted?.has(id)) {
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

    // 栈节点集合
    const stackSet = new Set(step.stack);

    // 已分配 SCC 的所有节点
    const sccCompletedSet = new Set<string>();
    for (const scc of step.sccs) {
      for (const id of scc) {
        sccCompletedSet.add(id);
      }
    }

    switch (step.type) {
      case 'init': {
        // init 时所有节点 default 色（由 cytoscape 默认样式承载）
        renderAllNodes(undefined, new Set(), sccCompletedSet);
        break;
      }

      case 'dfs_enter': {
        renderAllNodes(step.current ?? undefined, stackSet, sccCompletedSet);
        break;
      }

      case 'dfs_explore': {
        renderAllNodes(step.current ?? undefined, stackSet, sccCompletedSet);
        if (step.edge) {
          const [src, tgt] = step.edge;
          renderer.setEdge(src, tgt, {
            lineColor: colors['edge_active'].value,
            width: 4,
            opacity: 1.0,
          }, mode, speed);
        }
        break;
      }

      case 'dfs_backtrack': {
        renderAllNodes(step.current ?? undefined, stackSet, sccCompletedSet);
        if (step.edge) {
          const [src, tgt] = step.edge;
          renderer.setEdge(src, tgt, {
            lineColor: colors['edge_tree'].value,
            width: 3,
            opacity: 0.9,
          }, mode, speed);
        }
        break;
      }

      case 'found_scc': {
        renderAllNodes(undefined, new Set(), sccCompletedSet);
        // 刚找到的 SCC 额外高亮
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
        // 所有节点按 SCC 着色
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

  getUIData(step: TarjanStep | null, state: UIState): Record<string, string> {
    if (!step) {
      return {
        'current-node': '—',
        'disc': '—',
        'lowlink': '—',
        'stack': '[ ]',
        'scc-found': '0',
        'total-sccs': '0',
      };
    }

    const current = step.current ?? '—';
    const discStr = step.current && step.disc[step.current] !== undefined
      ? String(step.disc[step.current]) : '—';
    const lowlinkStr = step.current && step.lowlink[step.current] !== undefined
      ? String(step.lowlink[step.current]) : '—';
    const stackStr = step.stack.length > 0
      ? `[${step.stack.join(', ')}]` : '[ ]';
    const sccStr = step.sccs.map((s, i) => `C${i + 1}:{${s.join(',')}}`).join('; ');

    return {
      'current-node': current,
      'disc': discStr,
      'lowlink': lowlinkStr,
      'stack': stackStr,
      'scc-found': step.sccs.length > 0 ? `C${step.sccs.length}` : '—',
      'total-sccs': sccStr || '—',
    };
  },
});

export default Tarjan;
