/**
 * louvain.ts — Louvain 社区检测可视化示例图数据
 *
 * 8 节点 · 12 边 · 无向图 (3 个自然社区)
 */
export const louvainGraph = {
  nodes: [
    { data: { id: '0', label: '0' } },
    { data: { id: '1', label: '1' } },
    { data: { id: '2', label: '2' } },
    { data: { id: '3', label: '3' } },
    { data: { id: '4', label: '4' } },
    { data: { id: '5', label: '5' } },
    { data: { id: '6', label: '6' } },
    { data: { id: '7', label: '7' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1' } },
    { data: { id: 'e02', source: '0', target: '2' } },
    { data: { id: 'e12', source: '1', target: '2' } },
    { data: { id: 'e13', source: '1', target: '3' } },
    { data: { id: 'e34', source: '3', target: '4' } },
    { data: { id: 'e35', source: '3', target: '5' } },
    { data: { id: 'e45', source: '4', target: '5' } },
    { data: { id: 'e46', source: '4', target: '6' } },
    { data: { id: 'e47', source: '4', target: '7' } },
    { data: { id: 'e56', source: '5', target: '6' } },
    { data: { id: 'e57', source: '5', target: '7' } },
    { data: { id: 'e67', source: '6', target: '7' } },
  ],
  startNode: '0',
};
