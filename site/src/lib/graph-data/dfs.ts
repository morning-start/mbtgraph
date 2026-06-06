/**
 * dfs.ts — DFS 可视化示例图数据
 *
 * 7 节点 · 6 边 · 无向图（树状结构，展示 DFS 深度优先特性）
 *
 * 拓扑结构:
 *       0
 *      / \
 *     1   2
 *    / \   \
 *   3   4   5
 *       |
 *       6
 *
 * BFS 遍历: 0 → 1 → 2 → 3 → 4 → 5 → 6
 * DFS 遍历: 0 → 1 → 3 → 4 → 6 → 2 → 5 (或类似深度优先路径)
 */

export const dfsGraph = {
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
    { data: { id: 'e02', source: '0', target: '2' } },
    { data: { id: 'e13', source: '1', target: '3' } },
    { data: { id: 'e14', source: '1', target: '4' } },
    { data: { id: 'e25', source: '2', target: '5' } },
    { data: { id: 'e46', source: '4', target: '6' } },
  ],
  startNode: '0',
};
