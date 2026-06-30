/**
 * prim.ts — Prim 可视化示例图数据
 *
 * 6 节点 · 9 边 · 无向带权图
 */
export const primGraph = {
  nodes: [
    { data: { id: '0', label: '0' } },
    { data: { id: '1', label: '1' } },
    { data: { id: '2', label: '2' } },
    { data: { id: '3', label: '3' } },
    { data: { id: '4', label: '4' } },
    { data: { id: '5', label: '5' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1', weight: 6 } },
    { data: { id: 'e02', source: '0', target: '2', weight: 1 } },
    { data: { id: 'e03', source: '0', target: '3', weight: 5 } },
    { data: { id: 'e12', source: '1', target: '2', weight: 5 } },
    { data: { id: 'e14', source: '1', target: '4', weight: 3 } },
    { data: { id: 'e23', source: '2', target: '3', weight: 5 } },
    { data: { id: 'e24', source: '2', target: '4', weight: 6 } },
    { data: { id: 'e25', source: '2', target: '5', weight: 4 } },
    { data: { id: 'e45', source: '4', target: '5', weight: 2 } },
  ],
  startNode: '0',
};
