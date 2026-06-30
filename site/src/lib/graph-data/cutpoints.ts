/**
 * cutpoints.ts — 割点与桥可视化示例图数据
 *
 * 6 节点 · 7 边 · 无向图 (含割点和桥)
 */
export const cutpointsGraph = {
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
    { data: { id: 'e23', source: '2', target: '3' } },
    { data: { id: 'e34', source: '3', target: '4' } },
    { data: { id: 'e35', source: '3', target: '5' } },
    { data: { id: 'e45', source: '4', target: '5' } },
  ],
  startNode: '0',
};
