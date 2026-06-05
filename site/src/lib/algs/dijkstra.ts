/**
 * dijkstra.ts — Dijkstra 最短路径算法可视化（ES Module）
 *
 * 重构后:
 *   - legendKeys: 从全局颜色注册表选取本算法需要的颜色
 *   - generateSteps: 纯算法逻辑，产出 Step[]
 *   - renderStep: 通过 VizRenderer + ColorMap 渲染（合并 executeStep+rebuildTo）
 *   - getUIData: 返回状态数据（不操作 DOM）
 */

import VizRenderer from '../viz-renderer';
import type { RenderMode } from '../viz-renderer';
import type { ColorMap, LegendSelector } from '../color-registry';
import { darken } from '../color-registry';
import type { UIState } from '../viz-engine';

// ── 图例声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'start' },
  { domain: 'node', key: 'default' },
  { domain: 'node', key: 'active' },
  { domain: 'node', key: 'visited' },
  { domain: 'node', key: 'relaxed' },
  { domain: 'edge', key: 'active' },
];

// ── 类型定义 ──

export interface DijkstraStep {
  type: 'init' | 'select' | 'relax' | 'finish';
  targets: string[];
  message: string;
  dist: Record<string, number>;
  parent: Record<string, string | null>;
  visited: Record<string, boolean>;
  current: string | null;
  edge?: [string, string];
  relaxed?: boolean;
}

// ── 算法实现 ──

const Dijkstra = {
  legendKeys,
  /**
   * 生成 Dijkstra 算法执行步骤（纯逻辑，无渲染）
   */
  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights: Record<string, number>,
    startId: string
  ): DijkstraStep[] {
    const steps: DijkstraStep[] = [];
    const dist: Record<string, number> = {};
    const parent: Record<string, string | null> = {};
    const visited: Record<string, boolean> = {};

    nodes.forEach((n) => {
      dist[n.data.id] = n.data.id === startId ? 0 : Infinity;
      parent[n.data.id] = null;
      visited[n.data.id] = false;
    });

    steps.push({
      type: 'init',
      targets: [startId],
      message: `初始化: dist[${startId}]=0, 其他=∞`,
      dist: JSON.parse(JSON.stringify(dist)),
      parent: JSON.parse(JSON.stringify(parent)),
      visited: JSON.parse(JSON.stringify(visited)),
      current: startId,
    });

    while (true) {
      let minDist = Infinity;
      let u: string | null = null;
      for (const nid in dist) {
        if (!visited[nid] && dist[nid] < minDist) {
          minDist = dist[nid];
          u = nid;
        }
      }

      if (u === null) break;

      visited[u] = true;

      steps.push({
        type: 'select',
        targets: [u],
        message: `选择最小距离节点: ${u} (dist=${dist[u] === Infinity ? '∞' : dist[u]})`,
        dist: JSON.parse(JSON.stringify(dist)),
        parent: JSON.parse(JSON.stringify(parent)),
        visited: JSON.parse(JSON.stringify(visited)),
        current: u,
      });

      const neighbors = adjList[u] || [];
      for (let ni = 0; ni < neighbors.length; ni++) {
        const v = neighbors[ni];
        if (visited[v]) continue;

        const w = edgeWeights[u + '-' + v];
        if (w === undefined) continue;

        const newDist = dist[u] + w;
        const isRelaxed = newDist < dist[v];

        steps.push({
          type: 'relax',
          targets: [u, v],
          message: `检查边 ${u}→${v} (w=${w}): dist[${v}]=${dist[v] === Infinity ? '∞' : dist[v]} → ${newDist === Infinity ? '∞' : newDist}${isRelaxed ? ' ✓ 更新!' : ' 保持'}`,
          dist: JSON.parse(JSON.stringify(dist)),
          parent: JSON.parse(JSON.stringify(parent)),
          visited: JSON.parse(JSON.stringify(visited)),
          current: u,
          edge: [u, v],
          relaxed: isRelaxed,
        });

        if (isRelaxed) {
          dist[v] = newDist;
          parent[v] = u;
        }
      }
    }

    const reachable = Object.keys(dist).filter(n => dist[n] < Infinity);
    steps.push({
      type: 'finish',
      targets: [],
      message: `✅ Dijkstra 完成! 可达节点: ${reachable.length}/${nodes.length}`,
      dist: JSON.parse(JSON.stringify(dist)),
      parent: JSON.parse(JSON.stringify(parent)),
      visited: JSON.parse(JSON.stringify(visited)),
      current: null,
    });

    return steps;
  },

  /**
   * 渲染单步（合并原 executeStep + rebuildTo）
   *
   * @param renderer   VizRenderer 实例
   * @param step       当前步骤数据
   * @param mode       animate(播放时) / instant(跳转/回退时)
   * @param speed      动画速度(ms)
   * @param colors     从注册表解析的颜色映射
   */
  renderStep(renderer: VizRenderer, step: DijkstraStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    switch (step.type) {
      case 'init':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.start.value,
          borderColor: darken(colors.start.value),
          borderWidth: 4,
          width: 52,
          height: 52,
        }, mode, speed);
        break;

      case 'select':
        renderer.setNode(step.targets[0], {
          backgroundColor: colors.active.value,
          borderColor: darken(colors.active.value),
          borderWidth: 3,
          width: 49,
          height: 49,
        }, mode, speed);
        break;

      case 'relax': {
        const src = step.targets[0];
        const tgt = step.targets[1];

        if (step.relaxed) {
          renderer.setEdge(src, tgt, {
            lineColor: colors.edgeActive.value,
            width: 4,
          }, mode);
          renderer.setNode(tgt, {
            backgroundColor: colors.relaxed.value,
            borderColor: darken(colors.relaxed.value),
            borderWidth: 3,
          }, mode, Math.max(100, speed * 0.5));
        } else {
          renderer.setEdge(src, tgt, {
            lineColor: '#94A3B8',
            width: 1.5,
            opacity: 0.45,
            lineStyle: 'dashed',
          }, mode);
        }
        break;
      }

      case 'finish':
        renderer.setNodesByFn((id: string) => {
          if (id === '0') return { backgroundColor: colors.start.value };
          if (step.visited[id]) return { backgroundColor: colors.visited.value };
          return { backgroundColor: colors.default.value };
        }, mode);
        break;
    }
  },

  /**
   * 返回 UI 状态数据（不操作 DOM，由引擎统一写入）
   */
  getUIData(step: DijkstraStep | null, state: UIState): Record<string, string> {
    return {
      'current-node': (!step || state.isFinished || state.currentIdx < 0)
        ? ((step && step.current !== null) ? String(step.current) : '—')
        : (step?.current !== null ? String(step.current) : '—'),
      'dist-table': step ? this._formatDistTable(step.dist) : '-',
      'visited-nodes': step ? this._formatVisited(step.visited) : '-',
    };
  },

  _formatDistTable(dist: Record<string, number>): string {
    const parts: string[] = [];
    for (const nid in dist) {
      const d = dist[nid];
      parts.push(`${nid}:${d === Infinity ? '∞' : d}`);
    }
    return '[' + parts.join(', ') + ']';
  },

  _formatVisited(visited: Record<string, boolean>): string {
    const list: string[] = [];
    for (const nid in visited) {
      if (visited[nid]) list.push(nid);
    }
    return list.length > 0 ? '[' + list.join(',') + ']' : '[ ]';
  },
};

export default Dijkstra;
