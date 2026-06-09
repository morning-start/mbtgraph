/**
 * cycle.ts — 环检测可视化示例图数据
 *
 * 7 节点 · 8 边 · 有向图 (包含环)
 */

export const cycleGraph = {
  nodes: [
    { data: { id: '0', label: '0' } },
    { data: { id: '1', label: '1' } },
    { data: { id: '2', label: '2' } },
    { data: { id: '3', label: '3' } },
    { data: { id: '4', label: '4' } },
    { data: { id: '5', label: '5' } },
    { data: { id: '6', label: '6' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1' } },
    { data: { id: 'e12', source: '1', target: '2' } },
    { data: { id: 'e20', source: '2', target: '0' } },
    { data: { id: 'e13', source: '1', target: '3' } },
    { data: { id: 'e34', source: '3', target: '4' } },
    { data: { id: 'e45', source: '4', target: '5' } },
    { data: { id: 'e56', source: '5', target: '6' } },
    { data: { id: 'e36', source: '3', target: '6' } },
  ],
  directed: true,
};
