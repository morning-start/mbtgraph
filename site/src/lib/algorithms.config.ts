/**
 * algorithms.config.ts — 算法注册表
 *
 * 集中管理所有可视化算法的配置：
 *   - 算法模块引用
 *   - 图数据引用
 *   - 页面元数据
 *
 * 新增算法只需在此添加一条记录
 */

import type { AlgoModule } from './alg-base';
import type { LegendSelector } from './color-registry';

// ── 导入算法模块 ──

import BFS from './algs/bfs';
import DFS from './algs/dfs';
import Dijkstra from './algs/dijkstra';
import Topo from './algs/topo';
import Cycle from './algs/cycle';
import CC from './algs/cc';
import PageRank from './algs/pagerank';
import Kruskal from './algs/kruskal';
import Tarjan from './algs/tarjan';
import BellmanFord from './algs/bellman_ford';
import Kosaraju from './algs/kosaraju';
import Hungarian from './algs/hungarian';
import AStar from './algs/a_star';
import Prim from './algs/prim';
import Coloring from './algs/coloring';
import Euler from './algs/euler';
import Cutpoints from './algs/cutpoints';

// ── 导入图数据 ──

import { bfsGraph } from './graph-data/bfs';
import { dfsGraph } from './graph-data/dfs';
import { dijkstraGraph } from './graph-data/dijkstra';
import { topoGraph } from './graph-data/topo';
import { cycleGraph } from './graph-data/cycle';
import { ccGraph } from './graph-data/cc';
import { pagerankGraph } from './graph-data/pagerank';
import { kruskalGraph } from './graph-data/kruskal';
import { tarjanGraph } from './graph-data/tarjan';
import { bellmanFordGraph } from './graph-data/bellman_ford';
import { kosarajuGraph } from './graph-data/kosaraju';
import { hungarianGraph } from './graph-data/hungarian';
import { aStarGraph } from './graph-data/a_star';
import { primGraph } from './graph-data/prim';
import { coloringGraph } from './graph-data/coloring';
import { eulerGraph } from './graph-data/euler';
import { cutpointsGraph } from './graph-data/cutpoints';

// ── 算法配置类型 ──

export interface AlgorithmConfig {
  /** 算法模块实例 */
  module: AlgoModule<unknown>;
  /** 图数据 */
  graph: {
    nodes: Array<{ data: { id: string; label: string } }>;
    edges: Array<{ data: { id: string; source: string; target: string; weight?: number | string } }>;
    startNode?: string;
    directed?: boolean;
  };
  /** 页面标题 */
  title: string;
  /** 页面副标题 */
  subtitle: string;
  /** 路由 slug (用于生成 URL) */
  slug: string;
}

// ── 算法注册表 ──

export const algorithms: Record<string, AlgorithmConfig> = {
  bfs: {
    module: BFS,
    graph: bfsGraph,
    title: 'BFS 广度优先搜索',
    subtitle: '6 节点 · 8 边 · 无向图',
    slug: 'bfs',
  },
  dfs: {
    module: DFS,
    graph: dfsGraph,
    title: 'DFS 深度优先搜索',
    subtitle: '6 节点 · 8 边 · 无向图',
    slug: 'dfs',
  },
  dijkstra: {
    module: Dijkstra,
    graph: dijkstraGraph,
    title: 'Dijkstra 最短路径',
    subtitle: '6 节点 · 9 边 · 带权有向图',
    slug: 'dijkstra',
  },
  topo: {
    module: Topo,
    graph: topoGraph,
    title: '拓扑排序 (Kahn 算法)',
    subtitle: '6 节点 · 7 边 · DAG',
    slug: 'topo_sort',
  },
  cycle: {
    module: Cycle,
    graph: cycleGraph,
    title: 'DFS 环检测',
    subtitle: '7 节点 · 8 边 · 有向图',
    slug: 'cycle_detection',
  },
  // 第 1 批：连通性 + 中心性
  cc: {
    module: CC,
    graph: ccGraph,
    title: '连通分量 (CC)',
    subtitle: '6 节点 · 5 边 · 无向图',
    slug: 'connected_components',
  },
  pagerank: {
    module: PageRank,
    graph: pagerankGraph,
    title: 'PageRank',
    subtitle: '6 节点 · 9 边 · 带权有向图',
    slug: 'pagerank',
  },
  // 第 2 批：最小生成树
  kruskal: {
    module: Kruskal,
    graph: kruskalGraph,
    title: 'Kruskal 最小生成树',
    subtitle: '6 节点 · 9 边 · 无向带权图',
    slug: 'kruskal',
  },
  // 第 3 批：强连通分量
  tarjan: {
    module: Tarjan,
    graph: tarjanGraph,
    title: 'Tarjan 强连通分量',
    subtitle: '6 节点 · 7 边 · 有向图',
    slug: 'tarjan',
  },
  // 第 4 批：最短路径（负权）
  bellman_ford: {
    module: BellmanFord,
    graph: bellmanFordGraph,
    title: 'Bellman-Ford 最短路径',
    subtitle: '6 节点 · 7 边 · 带权有向图',
    slug: 'bellman_ford',
  },
  // 第 5 批：强连通分量（Kosaraju）
  kosaraju: {
    module: Kosaraju,
    graph: kosarajuGraph,
    title: 'Kosaraju 强连通分量',
    subtitle: '6 节点 · 7 边 · 有向图',
    slug: 'kosaraju',
  },
  // 第 6 批：二分图匹配
  hungarian: {
    module: Hungarian,
    graph: hungarianGraph,
    title: '匈牙利算法（二分图匹配）',
    subtitle: '6 节点 · 9 边 · 完全二分图',
    slug: 'hungarian',
  },
  // 第 7 批：A* 启发式搜索
  a_star: {
    module: AStar,
    graph: aStarGraph,
    title: 'A* 启发式搜索',
    subtitle: '6 节点 · 9 边 · 带权有向图',
    slug: 'a_star',
  },
  // 第 8 批：Prim 最小生成树
  prim: {
    module: Prim,
    graph: primGraph,
    title: 'Prim 最小生成树',
    subtitle: '6 节点 · 9 边 · 无向带权图',
    slug: 'prim',
  },
  // 第 9 批：图着色
  coloring: {
    module: Coloring,
    graph: coloringGraph,
    title: '图着色 (Greedy)',
    subtitle: '6 节点 · 10 边 · 无向图 (轮图)',
    slug: 'coloring',
  },
  // 第 10 批：欧拉路径
  euler: {
    module: Euler,
    graph: eulerGraph,
    title: '欧拉路径 (Hierholzer)',
    subtitle: '6 节点 · 8 边 · 无向图',
    slug: 'euler',
  },
  // 第 11 批：割点与桥
  cutpoints: {
    module: Cutpoints,
    graph: cutpointsGraph,
    title: '割点与桥 (Tarjan)',
    subtitle: '6 节点 · 7 边 · 无向图',
    slug: 'cutpoints',
  },
};

// ── 辅助函数 ──

/**
 * 获取所有算法的 slug 列表
 */
export function getAlgorithmSlugs(): string[] {
  return Object.keys(algorithms);
}

/**
 * 根据 slug 获取算法配置
 */
export function getAlgorithmConfig(slug: string): AlgorithmConfig | undefined {
  return algorithms[slug];
}

/**
 * 获取算法的 legendKeys (用于 VizLayout)
 */
export function getAlgorithmLegendKeys(slug: string): LegendSelector[] {
  const config = algorithms[slug];
  if (!config) return [];
  return config.module.legendKeys;
}
