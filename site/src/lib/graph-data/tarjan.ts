/**
 * tarjan.ts — Tarjan SCC 可视化示例图
 *
 * 6 节点 · 7 边 · 有向图
 *
 * SCC：
 *   A: {0, 1, 2}  — 环状结构：0→1→2→0
 *   B: {3, 4}     — 双向连接：3→4→3
 *   C: {5}        — 孤立节点
 *
 * 跨 SCC 边：
 *   2→3（从 SCC A 到 SCC B）
 *   4→5（从 SCC B 到 SCC C）
 */
export const tarjanGraph = {
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
