/**
 * dfs.ts — DFS 可视化示例图数据
 *
 * 6 节点 · 8 边 · 无向图
 */

export const dfsGraph = {
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
    { data: { id: 'e13', source: '1', target: '3' } },
    { data: { id: 'e14', source: '1', target: '4' } },
    { data: { id: 'e24', source: '2', target: '4' } },
    { data: { id: 'e35', source: '3', target: '5' } },
    { data: { id: 'e45', source: '4', target: '5' } },
    { data: { id: 'e25', source: '2', target: '5' } },
  ],
  startNode: '0',
};
