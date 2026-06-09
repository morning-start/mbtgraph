/**
 * hungarian.ts — 匈牙利算法可视化示例图
 *
 * 3×3 完全二分图（左：A/B/C，右：X/Y/Z）
 * 成本矩阵：
 *         X  Y  Z
 *     A   3  7  5
 *     B   2  1  8
 *     C   6  4  9
 *
 * 最优匹配：A→Z(5), B→Y(1), C→X(6) = 12
 * 或：A→X(3), B→Y(1), C→Z(9) = 13
 * 或：A→X(3), B→Z(8), C→Y(4) = 15
 *
 * 最优：A→Z(5), B→Y(1), C→X(6) = 12
 *
 * 注意：数据中边不包含 weight（匈牙利使用成本矩阵），
 * 但需要所有 9 条边来展示完全二分图。
 */
export const hungarianGraph = {
  nodes: [
    { data: { id: 'A', label: 'A' } },
    { data: { id: 'B', label: 'B' } },
    { data: { id: 'C', label: 'C' } },
    { data: { id: 'X', label: 'X' } },
    { data: { id: 'Y', label: 'Y' } },
    { data: { id: 'Z', label: 'Z' } },
  ],
  edges: [
    { data: { id: 'eAX', source: 'A', target: 'X' } },
    { data: { id: 'eAY', source: 'A', target: 'Y' } },
    { data: { id: 'eAZ', source: 'A', target: 'Z' } },
    { data: { id: 'eBX', source: 'B', target: 'X' } },
    { data: { id: 'eBY', source: 'B', target: 'Y' } },
    { data: { id: 'eBZ', source: 'B', target: 'Z' } },
    { data: { id: 'eCX', source: 'C', target: 'X' } },
    { data: { id: 'eCY', source: 'C', target: 'Y' } },
    { data: { id: 'eCZ', source: 'C', target: 'Z' } },
  ],
};
