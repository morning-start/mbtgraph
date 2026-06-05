/**
 * 第三方库类型声明
 *
 * cytoscape-dagre 等库未自带 TypeScript 类型定义，
 * 在此补充声明以消除 TS 编译警告。
 */

declare module 'cytoscape-dagre' {
  import type Cytoscape from 'cytoscape';

  interface DagreLayoutOptions {
    rankDir?: 'TB' | 'BT' | 'LR' | 'RL';
    nodeSep?: number;
    rankSep?: number;
    animate?: boolean;
    fit?: boolean;
    padding?: number;
    [key: string]: unknown;
  }

  const cytoscapeDagre: (cy: typeof Cytoscape) => void;
  export default cytoscapeDagre;
}

declare module 'dagre' {
  interface Graph {
    setNode(id: string, value?: unknown): Graph;
    setEdge(source: string, target: string, value?: unknown): Graph;
    graph(): Record<string, unknown>;
    nodes(): Array<{ v: string }>;
    edges(): Array<{ v: string; w: string }>;
    successors(v: string): Array<{ v: string }>;
    predecessors(v: string): Array<{ v: string }>;
    neighbors(v: string): Array<{ v: string }>;
    [key: string]: unknown;
  }

  interface DagreLayout {
    rankDir?: 'TB' | 'BT' | 'LR' | 'RL';
    nodeSep?: number;
    edgeSep?: number;
    rankSep?: number;
    marginX?: number;
    marginY?: number;
    acyclicer?: 'greedy' | undefined;
    ranker?: 'network-simplex' | 'tight-tree' | 'longest-path';
    [key: string]: unknown;
  }

  export function dagreGraph(): Graph;
  export function layout(g: Graph, opts?: DagreLayout): void;
}
