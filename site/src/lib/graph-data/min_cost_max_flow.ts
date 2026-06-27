export const minCostMaxFlowGraph = {
  nodes: [
    { data: { id: '0', label: 's' } },
    { data: { id: '1', label: 'A' } },
    { data: { id: '2', label: 'B' } },
    { data: { id: '3', label: 'C' } },
    { data: { id: '4', label: 't' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1', weight: 10.2 } },
    { data: { id: 'e02', source: '0', target: '2', weight: 5.3 } },
    { data: { id: 'e13', source: '1', target: '3', weight: 6.1 } },
    { data: { id: 'e23', source: '2', target: '3', weight: 8.4 } },
    { data: { id: 'e14', source: '1', target: '4', weight: 7.1 } },
    { data: { id: 'e34', source: '3', target: '4', weight: 9.2 } },
  ],
  startNode: '0',
};
