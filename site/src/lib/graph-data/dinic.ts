/**
 * dinic.ts — Dinic 可视化示例图数据
 * 6 节点 · 8 边 · 有向带权图 (容量)
 */
export const dinicGraph = {
  nodes: [
    { data: { id: '0', label: 's' } },
    { data: { id: '1', label: 'A' } },
    { data: { id: '2', label: 'B' } },
    { data: { id: '3', label: 'C' } },
    { data: { id: '4', label: 'D' } },
    { data: { id: '5', label: 't' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1', weight: 12 } },
    { data: { id: 'e02', source: '0', target: '2', weight: 8 } },
    { data: { id: 'e13', source: '1', target: '3', weight: 6 } },
    { data: { id: 'e14', source: '1', target: '4', weight: 5 } },
    { data: { id: 'e23', source: '2', target: '3', weight: 4 } },
    { data: { id: 'e24', source: '2', target: '4', weight: 7 } },
    { data: { id: 'e35', source: '3', target: '5', weight: 10 } },
    { data: { id: 'e45', source: '4', target: '5', weight: 9 } },
  ],
  startNode: '0',
};
