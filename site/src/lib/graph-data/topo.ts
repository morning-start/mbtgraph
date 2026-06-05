/**
 * topo.ts — 拓扑排序可视化示例图数据
 *
 * 6 节点 · 7 边 · DAG (有向无环图)
 */

export const topoGraph = {
  nodes: [
    { data: { id: '0', label: '0' } },
    { data: { id: '1', label: '1' } },
    { data: { id: '2', label: '2' } },
    { data: { id: '3', label: '3' } },
    { data: { id: '4', label: '4' } },
    { data: { id: '5', label: '5' } },
  ],
  edges: [
    { data: { id: 'e02', source: '0', target: '2' } },
    { data: { id: 'e12', source: '1', target: '2' } },
    { data: { id: 'e23', source: '2', target: '3' } },
    { data: { id: 'e34', source: '3', target: '4' } },
    { data: { id: 'e35', source: '3', target: '5' } },
    { data: { id: 'e04', source: '0', target: '4' } },
    { data: { id: 'e15', source: '1', target: '5' } },
  ],
  directed: true,
};
