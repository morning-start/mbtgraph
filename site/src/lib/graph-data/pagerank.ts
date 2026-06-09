/**
 * pagerank.ts — PageRank 可视化示例图
 *
 * 6 节点 · 9 边 · 带权有向图
 *
 * 设计意图：节点 2 和 4 是"枢纽"（多个入边 + 出边），rank 应最高。
 *   - 0 → 1, 0 → 2
 *   - 1 → 2
 *   - 2 → 0, 2 → 3
 *   - 3 → 4
 *   - 4 → 3, 4 → 5
 *   - 5 → 0
 */
export const pagerankGraph = {
  nodes: [
    { data: { id: '0', label: '0' } },
    { data: { id: '1', label: '1' } },
    { data: { id: '2', label: '2' } },
    { data: { id: '3', label: '3' } },
    { data: { id: '4', label: '4' } },
    { data: { id: '5', label: '5' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1' } },
    { data: { id: 'e02', source: '0', target: '2' } },
    { data: { id: 'e12', source: '1', target: '2' } },
    { data: { id: 'e20', source: '2', target: '0' } },
    { data: { id: 'e23', source: '2', target: '3' } },
    { data: { id: 'e34', source: '3', target: '4' } },
    { data: { id: 'e43', source: '4', target: '3' } },
    { data: { id: 'e45', source: '4', target: '5' } },
    { data: { id: 'e50', source: '5', target: '0' } },
  ],
};
