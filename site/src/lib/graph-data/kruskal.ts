/**
 * kruskal.ts — Kruskal 最小生成树可视化示例图
 *
 * 6 节点 · 9 边 · 无向带权图
 *
 * 边（按权排序）：
 *   4-5: 1, 0-1: 2, 1-2: 3, 3-5: 4, 1-4: 5,
 *   0-3: 6, 2-4: 7, 1-3: 8, 3-4: 9
 *
 * MST（5 条边）：{4-5(1), 0-1(2), 1-2(3), 3-5(4), 1-4(5)} = 15
 *   4-5 权最小 → 加入
 *   0-1 → 加入
 *   1-2 → 加入
 *   3-5 → 加入
 *   1-4 → 加入（连接两个大分量）
 *   其余均在同分量中 → 跳过（成环）
 */
export const kruskalGraph = {
  nodes: [
    { data: { id: '0', label: '0' } },
    { data: { id: '1', label: '1' } },
    { data: { id: '2', label: '2' } },
    { data: { id: '3', label: '3' } },
    { data: { id: '4', label: '4' } },
    { data: { id: '5', label: '5' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1', weight: 2 } },
    { data: { id: 'e03', source: '0', target: '3', weight: 6 } },
    { data: { id: 'e12', source: '1', target: '2', weight: 3 } },
    { data: { id: 'e13', source: '1', target: '3', weight: 8 } },
    { data: { id: 'e14', source: '1', target: '4', weight: 5 } },
    { data: { id: 'e24', source: '2', target: '4', weight: 7 } },
    { data: { id: 'e34', source: '3', target: '4', weight: 9 } },
    { data: { id: 'e35', source: '3', target: '5', weight: 4 } },
    { data: { id: 'e45', source: '4', target: '5', weight: 1 } },
  ],
};
