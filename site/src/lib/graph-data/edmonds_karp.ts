export const edmondsKarpGraph = {
  nodes: [
    { data: { id: '0', label: 's' } },
    { data: { id: '1', label: 'A' } },
    { data: { id: '2', label: 'B' } },
    { data: { id: '3', label: 'C' } },
    { data: { id: '4', label: 'D' } },
    { data: { id: '5', label: 't' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1', weight: 10 } },
    { data: { id: 'e02', source: '0', target: '2', weight: 5 } },
    { data: { id: 'e13', source: '1', target: '3', weight: 8 } },
    { data: { id: 'e14', source: '1', target: '4', weight: 3 } },
    { data: { id: 'e23', source: '2', target: '3', weight: 6 } },
    { data: { id: 'e24', source: '2', target: '4', weight: 4 } },
    { data: { id: 'e35', source: '3', target: '5', weight: 9 } },
    { data: { id: 'e45', source: '4', target: '5', weight: 7 } },
  ],
  startNode: '0',
};
