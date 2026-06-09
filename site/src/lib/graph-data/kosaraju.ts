/**
 * kosaraju.ts — Kosaraju SCC 可视化示例图
 *
 * 与 Tarjan 使用相同图结构，便于对比两种算法。
 *
 * 6 节点 · 7 边 · 有向图
 * SCC A: {0, 1, 2}  SCC B: {3, 4}  SCC C: {5}
 */
export const kosarajuGraph = {
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
    { data: { id: 'e12', source: '1', target: '2' } },
    { data: { id: 'e20', source: '2', target: '0' } },
    { data: { id: 'e23', source: '2', target: '3' } },
    { data: { id: 'e34', source: '3', target: '4' } },
    { data: { id: 'e43', source: '4', target: '3' } },
    { data: { id: 'e45', source: '4', target: '5' } },
  ],
  directed: true,
};
