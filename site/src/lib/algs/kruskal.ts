/**
 * kruskal.ts — Kruskal 最小生成树可视化
 *
 * 算法思想：按边权从小到大选边，若连接不同分量则加入 MST。
 * 课代表例子：6 节点 · 9 边 · 无向带权图
 *   MST = {4-5(1), 0-1(2), 1-2(3), 3-5(4), 1-4(5)} = 15
 *
 * 步骤设计：
 * 1. init：所有节点独立分量，边按权排序
 * 2. check_edge：检查当前最小权边
 * 3. add_edge：边加入 MST，合并分量
 * 4. skip_edge：跳过边（成环）
 * 5. finish：MST 完成
 *
 * 教学要点：
 * - 贪心策略：局部最优 → 全局最优
 * - Union-Find 维护连通分量
 * - 安全边定理：最小权连接两个不同分量的边必在某个 MST 中
 */
import { createAlgo, darken, type LegendSelector } from '../alg-base';
import type { UIState } from '../alg-base';
import type { VizRenderer, RenderMode, ColorMap } from '../alg-base';

// ── Legend 声明 ──

export const legendKeys: LegendSelector[] = [
  { domain: 'node', key: 'default' },   // 未处理
  { domain: 'node', key: 'active' },    // 当前边关联节点
  { domain: 'node', key: 'visited' },   // 已加入 MST 分量
  { domain: 'edge', key: 'default' },   // 未检查
  { domain: 'edge', key: 'active' },    // 正在检查
  { domain: 'edge', key: 'tree' },      // MST 边
  { domain: 'edge', key: 'skipped' },   // 跳过（成环）
];

// ── 步骤类型 ──

export interface KruskalStep {
  type: 'init' | 'check_edge' | 'add_edge' | 'skip_edge' | 'finish';
  targets: string[];           // 当前边涉及的节点
  edge?: [string, string];     // 当前处理的边
  weight: number;              // 当前边权
  mstEdges: Array<[string, string]>;  // 已确定的 MST 边
  mstWeight: number;           // 当前 MST 总权
  sortedEdges: Array<{ src: string; tgt: string; weight: number }>; // 排序后的边列表
  edgeIndex: number;           // 当前处理的边在 sortedEdges 中的下标
  componentOf: Record<string, number>; // 每个节点所属分量编号（用于着色）
  message: string;
}

// ── 分量配色 ──

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

const Kruskal = createAlgo<KruskalStep>({
  legendKeys,

  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    _adjList: Record<string, string[]>,
    edgeWeights?: Record<string, number>,
  ): KruskalStep[] {
    const steps: KruskalStep[] = [];
    const ids = nodes.map(n => n.data.id);
    const N = ids.length;

    if (N === 0) {
      steps.push({
        type: 'finish',
        targets: [],
        weight: 0,
        mstEdges: [],
        mstWeight: 0,
        sortedEdges: [],
        edgeIndex: -1,
        componentOf: {},
        message: '图为空，无节点',
      });
      return steps;
    }

    // 构建排序边列表
    const sortedEdges: Array<{ src: string; tgt: string; weight: number }> = [];
    if (edgeWeights) {
      for (const [key, w] of Object.entries(edgeWeights)) {
        const [src, tgt] = key.split('-');
        sortedEdges.push({ src, tgt, weight: w });
      }
    }
    sortedEdges.sort((a, b) => a.weight - b.weight);

    // Union-Find
    const parent: Record<string, string> = {};
    const rank: Record<string, number> = {};
    ids.forEach(id => { parent[id] = id; rank[id] = 0; });

    function find(x: string): string {
      while (parent[x] !== x) {
        parent[x] = parent[parent[x]]; // 路径压缩
        x = parent[x];
      }
      return x;
    }

    function union(x: string, y: string): void {
      const rx = find(x);
      const ry = find(y);
      if (rx === ry) return;
      if (rank[rx] < rank[ry]) {
        parent[rx] = ry;
      } else if (rank[rx] > rank[ry]) {
        parent[ry] = rx;
      } else {
        parent[ry] = rx;
        rank[rx]++;
      }
    }

    // 获取每个节点当前的分量编号
    function getComponentLabels(): Record<string, number> {
      const compMap: Record<string, number> = {};
      const compIds: Record<string, number> = {};
      let nextLabel = 0;
      for (const id of ids) {
        const root = find(id);
        if (compIds[root] === undefined) {
          compIds[root] = nextLabel++;
        }
        compMap[id] = compIds[root];
      }
      return compMap;
    }

    const mstEdges: Array<[string, string]> = [];
    let mstWeight = 0;

    // init step
    steps.push({
      type: 'init',
      targets: [],
      weight: 0,
      mstEdges: [],
      mstWeight: 0,
      sortedEdges,
      edgeIndex: -1,
      componentOf: getComponentLabels(),
      message: `初始化：${N} 个节点各自独立分量，共 ${sortedEdges.length} 条边（已按权排序）`,
    });

    // 依次检查每条边
    for (let i = 0; i < sortedEdges.length; i++) {
      const { src, tgt, weight } = sortedEdges[i];

      // check_edge：检查当前边
      steps.push({
        type: 'check_edge',
        targets: [src, tgt],
        edge: [src, tgt],
        weight,
        mstEdges: mstEdges.slice(),
        mstWeight,
        sortedEdges,
        edgeIndex: i,
        componentOf: getComponentLabels(),
        message: `检查边 ${src}—${tgt} (权=${weight})`,
      });

      const r1 = find(src);
      const r2 = find(tgt);

      if (r1 !== r2) {
        // 不同分量 → 加入 MST
        union(src, tgt);
        mstEdges.push([src, tgt]);
        mstWeight += weight;

        steps.push({
          type: 'add_edge',
          targets: [src, tgt],
          edge: [src, tgt],
          weight,
          mstEdges: mstEdges.slice(),
          mstWeight,
          sortedEdges,
          edgeIndex: i,
          componentOf: getComponentLabels(),
          message: `✅ 加入 MST：${src}—${tgt} (权=${weight})，MST 总权=${mstWeight}`,
        });
      } else {
        // 同一分量 → 跳过（会成环）
        steps.push({
          type: 'skip_edge',
          targets: [src, tgt],
          edge: [src, tgt],
          weight,
          mstEdges: mstEdges.slice(),
          mstWeight,
          sortedEdges,
          edgeIndex: i,
          componentOf: getComponentLabels(),
          message: `⛔ 跳过 ${src}—${tgt} (权=${weight})：同分量，会形成环`,
        });
      }
    }

    // finish
    steps.push({
      type: 'finish',
      targets: [],
      weight: 0,
      mstEdges: mstEdges.slice(),
      mstWeight,
      sortedEdges,
      edgeIndex: sortedEdges.length,
      componentOf: getComponentLabels(),
      message: `✅ Kruskal 完成！MST 共 ${mstEdges.length} 条边，总权 = ${mstWeight}`,
    });

    return steps;
  },

  renderStep(renderer: VizRenderer, step: KruskalStep, mode: RenderMode, speed: number, colors: ColorMap): void {
    const nodeIds = Object.keys(step.componentOf);

    // 辅助：按分量着色
    function colorNodesByComponent(exceptIds: string[] = []) {
      const exceptSet = new Set(exceptIds);
      for (const id of nodeIds) {
        if (exceptSet.has(id)) continue;
        const compIdx = step.componentOf[id] ?? 0;
        const c = colorForComponent(compIdx);
        renderer.setNode(id, {
          backgroundColor: c,
          borderColor: darken(c),
          borderWidth: 2,
          width: 46,
          height: 46,
        }, mode, speed);
      }
    }

    switch (step.type) {
      case 'init': {
        // 所有节点按初始分量着色，所有边 default
        colorNodesByComponent();
        // 重置所有边为 default
        for (const e of step.sortedEdges) {
          renderer.setEdge(e.src, e.tgt, {
            lineColor: colors['edge_default'].value,
            width: 2,
            opacity: 0.85,
          }, mode, 0);
        }
        break;
      }

      case 'check_edge': {
        // 先按分量着色所有节点
        colorNodesByComponent();
        // 高亮当前检查的边
        if (step.edge) {
          const [src, tgt] = step.edge;
          renderer.setEdge(src, tgt, {
            lineColor: colors['edge_active'].value,
            width: 4,
            opacity: 1.0,
          }, mode, speed);
          // 高亮两个端点
          renderer.setNode(src, {
            backgroundColor: colors['node_active'].value,
            borderColor: darken(colors['node_active'].value),
            borderWidth: 4,
            width: 52,
            height: 52,
          }, mode, speed);
          renderer.setNode(tgt, {
            backgroundColor: colors['node_active'].value,
            borderColor: darken(colors['node_active'].value),
            borderWidth: 4,
            width: 52,
            height: 52,
          }, mode, speed);
        }
        break;
      }

      case 'add_edge': {
        // MST 边已加入，更新所有节点的分量颜色后，MST 边用 tree 色
        colorNodesByComponent();
        if (step.edge) {
          const [src, tgt] = step.edge;
          renderer.setEdge(src, tgt, {
            lineColor: colors['edge_tree'].value,
            width: 4,
            opacity: 1.0,
          }, mode, speed);
        }
        break;
      }

      case 'skip_edge': {
        // 跳过边：变灰虚线
        colorNodesByComponent();
        if (step.edge) {
          const [src, tgt] = step.edge;
          renderer.setEdge(src, tgt, {
            lineColor: colors['edge_skipped'].value,
            width: 1.5,
            opacity: 0.4,
            lineStyle: 'dashed',
          }, mode, speed);
        }
        break;
      }

      case 'finish': {
        // 最终：所有节点按分量着色，MST 边高亮，非 MST 边变灰虚线
        colorNodesByComponent();

        const mstSet = new Set<string>();
        for (const [s, t] of step.mstEdges) {
          mstSet.add(s + '-' + t);
          mstSet.add(t + '-' + s);
        }

        for (const e of step.sortedEdges) {
          const key1 = e.src + '-' + e.tgt;
          const key2 = e.tgt + '-' + e.src;
          if (mstSet.has(key1) || mstSet.has(key2)) {
            renderer.setEdge(e.src, e.tgt, {
              lineColor: colors['edge_tree'].value,
              width: 4,
              opacity: 1.0,
            }, mode, speed);
          } else {
            renderer.setEdge(e.src, e.tgt, {
              lineColor: colors['edge_skipped'].value,
              width: 1.5,
              opacity: 0.35,
              lineStyle: 'dashed',
            }, mode, speed);
          }
        }
        break;
      }
    }
  },

  getUIData(step: KruskalStep | null, state: UIState): Record<string, string> {
    if (!step) {
      return {
        'current-edge': '—',
        'edge-weight': '—',
        'mst-edges': '0',
        'mst-weight': '0',
        'status': '—',
      };
    }
    return {
      'current-edge': step.edge ? `${step.edge[0]}—${step.edge[1]}` : '—',
      'edge-weight': step.edgeIndex >= 0 ? String(step.weight) : '—',
      'mst-edges': `${step.mstEdges.length} 条`,
      'mst-weight': String(step.mstWeight),
      'status': step.type === 'init' ? '初始化' :
                step.type === 'check_edge' ? '检查中' :
                step.type === 'add_edge' ? '已加入 ✓' :
                step.type === 'skip_edge' ? '已跳过 ⛔' :
                step.type === 'finish' ? '✅ 完成' : '—',
    };
  },
});

export default Kruskal;
