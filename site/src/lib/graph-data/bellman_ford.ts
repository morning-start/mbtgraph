/**
 * bellman_ford.ts — Bellman-Ford 可视化示例图
 *
 * 6 节点 · 7 边 · 带权有向图
 *
 * 关键设计：边 2→1(-2) 使 0→2→1 = 1 优于直接 0→1=4
 * 展示 Bellman-Ford 能处理负权边的能力。
 *
 * 从 0 出发：
 *   第 1 轮：0→1=4, 0→2=3
 *   第 2 轮：2→1: dist[1]=min(4, 3+(-2))=1 ✓
 *              1→3: dist[3]=1+2=3
 *              2→4: dist[4]=3+3=6
 *   第 3 轮：3→5: dist[5]=3+1=4
 *              4→5: dist[5]=min(4,6+5)=4（不变）
 *   第 4 轮：无更新 → 收敛
 */
export const bellmanFordGraph = {
  nodes: [
    { data: { id: '0', label: '0' } },
    { data: { id: '1', label: '1' } },
    { data: { id: '2', label: '2' } },
    { data: { id: '3', label: '3' } },
    { data: { id: '4', label: '4' } },
    { data: { id: '5', label: '5' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1', weight: 4 } },
    { data: { id: 'e02', source: '0', target: '2', weight: 3 } },
    { data: { id: 'e13', source: '1', target: '3', weight: 2 } },
    { data: { id: 'e21', source: '2', target: '1', weight: -2 } },
    { data: { id: 'e24', source: '2', target: '4', weight: 3 } },
    { data: { id: 'e35', source: '3', target: '5', weight: 1 } },
    { data: { id: 'e45', source: '4', target: '5', weight: 5 } },
  ],
  startNode: '0',
  directed: true,
};
